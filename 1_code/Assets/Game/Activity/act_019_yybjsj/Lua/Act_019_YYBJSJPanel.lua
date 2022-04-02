-- 创建时间:2020-06-23
-- Panel:Act_019_YYBJSJPanel
--[[
 *      ┌─┐       ┌─┐
 *   ┌──┘ ┴───────┘ ┴──┐
 *   │                 │
 *   │       ───       │
 *   │  ─┬┘       └┬─  │
 *   │                 │
 *   │       ─┴─       │
 *   │                 │
 *   └───┐         ┌───┘
 *       │         │
 *       │         │
 *       │         │
 *       │         └──────────────┐
 *       │                        │
 *       │                        ├─┐
 *       │                        ┌─┘
 *       │                        │
 *       └─┐  ┐  ┌───────┬──┐  ┌──┘
 *         │ ─┤ ─┤       │ ─┤ ─┤
 *         └──┴──┘       └──┴──┘
 *                神兽保佑
 *               代码无BUG!
 --]]

local basefunc = require "Game/Common/basefunc"

Act_019_YYBJSJPanel = basefunc.class()
local C = Act_019_YYBJSJPanel
C.name = "Act_019_YYBJSJPanel"
local M = Act_019_YYBJSJManager

local DESCRIBE_TEXT = {
	[1] = "1.活动时间：7月7日-7月20日，每晚21:30至凌晨2点可参与",
	[2] = "2.使用指定鲸币档次完成任务可立得福卡",
	[3] = "3.每次任务有效时间3小时，超时未完成视为失效",
	[4] = "4.活动期间内，每完成5次任务，可额外拆一次红包，最高得1000福卡,若活动结束还未领取奖励，视为放弃",
	[5] = "5.累计充值任务仅限游戏内充值，不包括公众号等渠道"
}
--↓↓↓↓↓↓↓↓成对使用
local key_word = {
	"水果消消乐","水浒消消乐","财神消消乐","敲敲乐","弹弹乐","苹果大战","疯狂捕鱼","街机捕鱼","充值"
}
local goto_func = {
	"xxl","shxxl","csxxl","qql","ttl","zpg","fkby","by","shop"
}
local goto_scene = {
	"game_Eliminate","game_EliminateSH","game_EliminateCS","game_Zjd","game_TTL","game_ZPG","game_FishingDR","game_FishingHall","shop"
}
--↑↑↑↑↑↑↑

function C.Create()
	return C.New()
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
	self.lister = {}
	self.lister["act_019_yybjsj_refresh"] = basefunc.handler(self,self.MyRefresh)
	self.lister["act_019_yybjsj_chb_refresh"] = basefunc.handler(self,self.RefreshCHB)
	self.lister["sleep_act_new_get_false_data_response"] = basefunc.handler(self,self.sleep_act_new_get_false_data_response)
	self.lister["sleep_act_new_signup_response"] = basefunc.handler(self,self.sleep_act_new_signup_response)
	self.lister["AssetChange"] = basefunc.handler(self, self.OnAssetChange)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	if self.dianji_node_timer then
		self.dianji_node_timer:Stop()	
	end
	if self.PMD_Timer then
		self.PMD_Timer:Stop()
	end
	if self.update_timer then
		self.update_timer:Stop()
	end
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:ctor()
	local parent = GameObject.Find("Canvas/LayerLv4").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	self:UpdateOverTime()
	CommonHuxiAnim.Start(self.get_chb_award_btn.gameObject,1)
	self.pmd_cont = CommonPMDManager.Create({parent = self.pmd_node,speed = 5,space_time = 10})
	Network.SendRequest("sleep_act_new_get_task")
	Network.SendRequest("query_one_task_data",{task_id = 21389})
	if self.PMD_Timer then
		self.PMD_Timer:Stop()
	end
	self.PMD_Timer = Timer.New(function ()
		Network.SendRequest("sleep_act_new_get_false_data")
	end,5,-1)
	PlayerPrefs.SetString(M.key .. MainModel.UserInfo.user_id, os.date("%Y%m%d",os.time()))
	PlayerPrefs.SetInt("act_019_yybjsj"..MainModel.UserInfo.user_id..M.GetDayIndex(),1)
	Event.Brocast("cplxrqtl_task_change")
	self.PMD_Timer:Start()
end

function C:InitUI()
	self.close_btn.onClick:AddListener(
		function ()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
			self:MyExit()
		end
	)
	self.sighup_btn.onClick:AddListener(
		function ()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
			Network.SendRequest("sleep_act_new_signup")
		end
	)
	self.refresh1_btn.onClick:AddListener(
		function ()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
			self:RefreshTask()
		end
	)
	self.refresh2_btn.onClick:AddListener(
		function ()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
			self:RefreshTask()
		end
	)
	self.help_btn.onClick:AddListener(
		function ()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
			self:OpenHelpPanel()
		end
	)
	self.get_chb_award_btn.onClick:AddListener(
		function ()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
			self:CHBClick()
		end
	)
	self.get_award_btn.onClick:AddListener(
		function ()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
			Network.SendRequest("get_task_award",{id = M.task_id})
		end
	)
	self.go_game_btn.onClick:AddListener(
		function ()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
			self:OnEnterClick()
		end
	)
	self:MyRefresh()
	self:RefreshCHB()
end

function C:MyRefresh()
--"{"award_vec":[0.11,0.29],"task_index":1,"sleep_act":{"max":"最高58元","name":"苹果大战种出1次金苹果","need":"单笔使用5000及以上鲸币"},"task_status":"begin","index_jingbi":1,"selected_tasks":[true],"index_vip":1}"
	local data = GameTaskModel.GetTaskDataByID(M.task_id)
	dump(data,"<color=red>随机任务数据</color>")
	if data and IsEquals(self.gameObject) then
		local str_map = json2lua(data.other_data_str)
		dump(str_map,"<color=red>Str_Map</color>")
		if str_map and str_map.sleep_act then
			self.sx1_txt.gameObject:SetActive(not M.IsFreeToRefresh())
			self.sx2_txt.gameObject:SetActive(not M.IsFreeToRefresh())
			if str_map.sleep_act.name == "财神消消乐出现1次天女散花" and str_map.sleep_act.need == "单笔使用4000及以上鲸币" then
				str_map.sleep_act.name = "水果消消乐出现1次幸运时刻"
			end
			if (not M.IsSignUP()) and (not M.IsEnd())then
				self.node1.gameObject:SetActive(true)
				self.node2.gameObject:SetActive(false)
				self.taskname1_txt.text = str_map.sleep_act.name
				self.key_str = str_map.sleep_act.name
				self.max_fk_txt.text = str_map.sleep_act.max.."福卡"
			else
				self.key_str = str_map.sleep_act.name
				local str = self.key_str
				local is_money = false
				if str then
					for i = 1,#key_word do
						if string.match(str,key_word[i]) == key_word[i] then
							if goto_func[i] == "shop" then
								is_money = true
							end
						end
					end
				end
				self.node2.gameObject:SetActive(true)
				self.node1.gameObject:SetActive(false)
				self.max_fk2_txt.text = str_map.sleep_act.max.."福卡"
				local a = is_money and data.now_process/100 or data.now_process
				local b = is_money and data.need_process/100 or data.need_process	
				self.task_name = str_map.sleep_act.name
				self.taskname2_txt.text = str_map.sleep_act.name.."\n"..a.."/"..b
				str_map.sleep_act.need = str_map.sleep_act.need == "" and str_map.sleep_act.need or "要求："..str_map.sleep_act.need
				self.need_name_txt.text = str_map.sleep_act.need
				self.remain_time_txt.gameObject:SetActive(os.time() < 1595278800)
				if data.award_status == 2 or M.IsEnd() then
					self.get_award_btn.gameObject:SetActive(false)
					self.go_game_btn.gameObject:SetActive(false)
					self.got.gameObject:SetActive(true)
					if os.time() > 1595208600 then
						self.bjbs.gameObject:SetActive(false)
					end
					self.remain_time_txt.gameObject:SetActive(false)
					self.refresh1_btn.gameObject:SetActive(false)
					self.refresh2_btn.gameObject:SetActive(false)
					self.sx1_txt.gameObject:SetActive(false)
					self.sx2_txt.gameObject:SetActive(false)			
				elseif data.award_status == 1 then
					self.get_award_btn.gameObject:SetActive(true)
					self.go_game_btn.gameObject:SetActive(false)
					self.got.gameObject:SetActive(false)
				else
					self.get_award_btn.gameObject:SetActive(false)
					self.go_game_btn.gameObject:SetActive(true)
					self.got.gameObject:SetActive(false)
				end				
			end			
		end
		self:UpdateOverTime()
	end
end

function C:RefreshCHB()
	local data = GameTaskModel.GetTaskDataByID(M.chb_task_ids[M.level])
	if self.dianji_node_timer then
		self.dianji_node_timer:Stop()	
	end
	dump(data,"<color=red>拆红包任务数据</color>")
	local sum = 0
	self.max_fk3_txt.text = M.GetCHBMaxStr()
	if data then
		if data.award_status == 1 then
			self.dianji_node.gameObject:SetActive(true)
			self.dianji_node_timer = Timer.New(function ()
				if IsEquals(self.gameObject) then
					self.dianji_node.gameObject:SetActive(not self.dianji_node.gameObject.activeSelf)
				end
			end,1,-1)
			self.dianji_node_timer:Start()
		else
			self.dianji_node.gameObject:SetActive(false)
		end
		self.finsh_num_txt.text = "已完成次数："..data.now_total_process
	end
end

function C:sleep_act_new_signup_response(_,data)
	if data.result == 0 then

	else
		HintPanel.ErrorMsg(data.result)
	end
end

function C:RefreshTask()
	local send_q = function ()
		local task_data = GameTaskModel.GetTaskDataByID(M.task_id)
		if task_data then
			if task_data.now_total_process > 0 then
				local b = HintPanel.Create(7,"刷新后已累计的任务进度会被清空\n是否确定刷新？",function ()
					Network.SendRequest("sleep_act_new_refresh_task")
				end)
				b:SetBtnTitle("考虑一下","刷新")
			else
				Network.SendRequest("sleep_act_new_refresh_task")
			end
		end
	end
	if M.IsFreeToRefresh() then
		send_q()
	elseif MainModel.UserInfo.jing_bi >= 500 then
		send_q()
	else
		HintPanel.Create(1,"您的鲸币不足！")
	end
end

function C:UpdateOverTime()
	if self.update_timer then
		self.update_timer:Stop()
	end
	local t = M.GetTaskOverTime() - os.time()
	self.remain_time_txt.text ="任务有效时间："..StringHelper.formatTimeDHMS3(t)
	self.update_timer = Timer.New(function ()
		t = t - 1
		if t > 0 and IsEquals(self.gameObject) then
			self.remain_time_txt.text ="任务有效时间："..StringHelper.formatTimeDHMS3(t)
		end
	end,1,-1)
	self.update_timer:Start()
end

function C:OpenHelpPanel()
    local str = DESCRIBE_TEXT[1]
    for i = 2, #DESCRIBE_TEXT do
        str = str .. "\n" .. DESCRIBE_TEXT[i]
    end
    self.introduce_txt.text = str
    IllustratePanel.Create({ self.introduce_txt.gameObject }, GameObject.Find("Canvas/LayerLv5").transform)
end

function C:CHBClick()
	local data = GameTaskModel.GetTaskDataByID(M.chb_task_ids[M.level])
	if data then
		if data.award_status == 1 then
			Network.SendRequest("get_task_award",{id = M.chb_task_ids[M.level]})
		elseif data.award_status == 2 then
			HintPanel.Create(1,"红包拆完啦")
		else
			HintPanel.Create(1,"完成五次小目标即可拆红包哦！")
		end
	end
end

function C:OnEnterClick()
	local str = self.key_str
	if str then
		for i = 1,#key_word do
			if string.match(str,key_word[i]) == key_word[i] then
				if goto_func[i] == "shop" then
					PayPanel.Create(GOODS_TYPE.jing_bi, "normal")
				else
					GameManager.CommonGotoScence({gotoui = goto_scene[i]}, function ()
						self:MyExit()
					end)
				end
				return
			end
		end
	end
end

function C:AddPMD(data)
	local b = GameObject.Instantiate(self.pmd_item,self.pmd_node)
	b.gameObject:SetActive(true)
	local temp_ui = {}
	LuaHelper.GeneratingVar(b.transform,temp_ui)
	temp_ui.t1_txt.text = "玩家【"..data.player_name.."】通过"..data.task_name.."获得"
	temp_ui.t2_txt.text = data.value.."福卡"
	UnityEngine.UI.LayoutRebuilder.ForceRebuildLayoutImmediate(b.transform)
	self.pmd_cont:AddObj(b)
end

-- player_name	1 : string
-- 		value 2 : integer
-- 		task_name 3 : string

function C:sleep_act_new_get_false_data_response(_,data)
	if data and data.result == 0 and IsEquals(self.gameObject) then
		self:AddPMD(data)
	end	
end

function C:OnAssetChange(data)
	if data.change_type and data.change_type == "task_award_21390" then
		self.cur_award_value = data.data[1].value / 100
		self:AddPMD({player_name = MainModel.UserInfo.name,value = self.cur_award_value,task_name = self.task_name})
	end
end