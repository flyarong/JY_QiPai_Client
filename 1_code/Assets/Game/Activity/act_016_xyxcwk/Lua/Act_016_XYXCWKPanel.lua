-- 创建时间:2020-06-16
-- Panel:Act_016_XYXCWKPanel
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

Act_016_XYXCWKPanel = basefunc.class()
local C = Act_016_XYXCWKPanel
C.name = "Act_016_XYXCWKPanel"
local M = Act_016_XYXCWKManager
local base_item = {"day","father1","father2"}
local awardimg = {
	day = "pay_icon_gold4",
	father1 = "bbsc_icon_hb",
	father2 = "bbsc_icon_hb",
}
local awardstr = {
	day = "40000鲸币",
	father1 = "1元福卡",
	father2 = "4元福卡",
}
--↓↓↓↓↓↓↓↓成对使用
local key_word = {
	"超级消消乐","西游消消乐","萌宠消消乐","水浒消消乐","财神消消乐","敲敲乐","弹弹乐","苹果大战","疯狂捕鱼","街机捕鱼"
}
local goto_func = {
	"cjxxl","xyxxl","xxl","shxxl","csxxl","qql","ttl","zpg","fkby","by"
}
--↑↑↑↑↑↑↑
local had_show = false
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
	self.lister["act_016_cwk_time_over"] = basefunc.handler(self,self.act_016_cwk_time_over)
	self.lister["act_016_xyxcwk_new_info_get"] = basefunc.handler(self,self.act_016_xyxcwk_new_info_get)
	self.lister["refresh_chang_wan_ka_task_response"] = basefunc.handler(self,self.on_refresh_chang_wan_ka_task_response)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
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
	M.UpDateTime(self.time_txt)
	Network.SendRequest("query_one_task_data",{task_id = M.father_task_id2})
	Network.SendRequest("query_one_task_data",{task_id = M.father_task_id1})
	local today_id1 = M.GetTodayTask1()
	local today_id2 = M.GetTodayTask2()
	if today_id1 then
		Network.SendRequest("query_one_task_data",{task_id = today_id1})
	end
	if today_id2 then
		Network.SendRequest("query_one_task_data",{task_id = today_id2})
	end
	-- dump(GameTaskModel.GetTaskDataByID(M.day_task_id),"<color=red>PPPP</color>")
end

function C:InitUI()
	for i = 1,#base_item do
		self[base_item[i]] = {}
		self[base_item[i].."_item"] = GameObject.Instantiate(self.item,self.node)
		self[base_item[i].."_item"].gameObject:SetActive(true)
		LuaHelper.GeneratingVar(self[base_item[i].."_item"], self[base_item[i]])
		self[base_item[i]].award_img.sprite = GetTexture(awardimg[base_item[i]])
		self[base_item[i]].award_txt.text = awardstr[base_item[i]]
		self[base_item[i]].award_img:SetNativeSize()
		self[base_item[i]].Slider = self[base_item[i]].Slider:GetComponent("Slider")
		self[base_item[i]].refresh_btn.onClick:AddListener(
			function ()
				ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
				self:RefreshTask(i)
			end
		)
		self[base_item[i]].get_btn.onClick:AddListener(
			function ()
				ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
				self:GetAward(i)
			end
		)
		self[base_item[i]].go_btn.onClick:AddListener(
			function ()
				ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
				self:GoPlay(i)
			end
		)
	end
	self.day.task_txt.text = "登录时可领取"

	self.help_btn.onClick:AddListener(
		function ()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
			Act_016_XYXCWKHelpPanel.Create()
		end
	)
	self.close_btn.onClick:AddListener(
		function ()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
			self:MyExit()
		end
	)
	self:MyRefresh()
end

function C:MyRefresh()
	if	not IsEquals(self.gameObject) then return end
	if  had_show == false and M.IsAllGet() then
		had_show = true
		self:MyExit()
		Act_016_XYXCWKHintPanel.Create(1)
	end 
	local day_task = GameTaskModel.GetTaskDataByID(M.day_task_id)
	local today_id1 = M.GetTodayTask1()
	local today_id2 = M.GetTodayTask2()
	dump(today_id1,"<color=red>当前的每日任务第一个的ID</color>")
	dump(today_id2,"<color=red>当前的每日任务第二个的ID</color>")
	dump(GameTaskModel.GetTaskDataByID(today_id1),"<color=red>当前的每日任务第一个的数据</color>")
	dump(GameTaskModel.GetTaskDataByID(today_id2),"<color=red>当前的每日任务第二个的数据</color>")
	dump(day_task,"<color=red>当天的登录任务数据</color>")
	if day_task then
		self.day.shuaxin.gameObject:SetActive(false)
		self.day.refresh_btn.gameObject:SetActive(false)
		self.day.get_btn.gameObject:SetActive(day_task.award_status == 1)
		self.day.go_btn.gameObject:SetActive(day_task.award_status == 0)
		self.day.ylq.gameObject:SetActive(day_task.award_status == 2)
		self.day.count_txt.text = "剩余"..M.GetCount(1).."次"
		self.day.Slider.value = 1/1
		self.day.bfb_txt.text = "1/1"
	else
		self.day_item.gameObject:SetActive(false)
	end

	if today_id1 then
		local father1_task = GameTaskModel.GetTaskDataByID(today_id1)
		if father1_task then
			self.father1.shuaxin.gameObject:SetActive(not M.GetIsMf())
			self.father1.get_btn.gameObject:SetActive(father1_task.award_status == 1)
			self.father1.go_btn.gameObject:SetActive(father1_task.award_status == 0)
			self.father1.ylq.gameObject:SetActive(father1_task.award_status == 2)
			self.father1.count_txt.text = "剩余"..M.GetCount(2).."次"
			self.father1.Slider.value = father1_task.now_total_process / M.GetConfigByID(today_id1).total
			self.father1.bfb_txt.text = father1_task.now_total_process.."/"..M.GetConfigByID(today_id1).total
			self.father1.task_txt.text = M.GetConfigByID(today_id1).text
			self.father1.refresh_btn.gameObject:SetActive(father1_task.award_status ~= 2)
		end
	else
		self.father1_item.gameObject:SetActive(false)
	end

	if today_id2 then
		local father2_task = GameTaskModel.GetTaskDataByID(today_id2)
		if father2_task then
			self.father2.shuaxin.gameObject:SetActive(not M.GetIsMf())
			self.father2.get_btn.gameObject:SetActive(father2_task.award_status == 1)
			self.father2.go_btn.gameObject:SetActive(father2_task.award_status == 0)
			self.father2.ylq.gameObject:SetActive(father2_task.award_status == 2)
			self.father2.count_txt.text = "剩余"..M.GetCount(3).."次"
			self.father2.Slider.value = father2_task.now_total_process / M.GetConfigByID(today_id2).total
			self.father2.bfb_txt.text = father2_task.now_total_process.."/"..M.GetConfigByID(today_id2).total
			self.father2.task_txt.text = M.GetConfigByID(today_id2).text
			self.father2.refresh_btn.gameObject:SetActive(father2_task.award_status ~= 2)
		end
	else
		self.father2_item.gameObject:SetActive(false)
	end
end

function C:RefreshTask(index)
	if index == 1 then
		return
	else
		if MainModel.UserInfo.jing_bi >= 3000 or M.GetIsMf() then
			local today_id = M["GetTodayTask"..index - 1]()
			local task_data = GameTaskModel.GetTaskDataByID(today_id)
			if task_data then
				if task_data.now_total_process > 0 then
					local b = HintPanel.Create(7,"刷新后已累计的任务进度会被清空\n是否确定刷新？",function ()
						Network.SendRequest("refresh_chang_wan_ka_task",{task_type  = index - 1})
					end)
					b:SetBtnTitle("考虑一下","刷新")
				else
					Network.SendRequest("refresh_chang_wan_ka_task",{task_type  = index - 1})
				end
			end
		else
			HintPanel.Create(1,"您的鲸币不足！")
		end
	end
end

function C:on_refresh_chang_wan_ka_task_response(_,data)
	dump(data,"<color=red>刷新任务-----</color>")
	if data and data.result == 0 then
		local today_id1 = M.GetTodayTask1()
		local today_id2 = M.GetTodayTask2()
		if today_id1 then
			Network.SendRequest("query_one_task_data",{task_id = today_id1})
		end
		if today_id2 then
			Network.SendRequest("query_one_task_data",{task_id = today_id2})
		end
	else
		HintPanel.ErrorMsg(data.result)
	end
end

function C:act_016_xyxcwk_new_info_get()
	self:MyRefresh()
end

function C:GetAward(index)
	local task_id = {}
	task_id[1] = M.day_task_id
	task_id[2] = M.GetTodayTask1()
	task_id[3] = M.GetTodayTask2()
	Network.SendRequest("get_task_award",{id = task_id[index]})
end

function C:GoPlay(index)
	local task_id = {}
	task_id[1] = M.day_task_id
	task_id[2] = M.GetTodayTask1()
	task_id[3] = M.GetTodayTask2()
	local config = M.GetConfigByID(task_id[index])
	dump({index = index,config= config})
	if config then
		for i = 1,#key_word do
			if string.match(config.text,key_word[i]) == key_word[i] then
				self:OnEnterClick(goto_func[i])
				return
			end
		end
	end
end

function C:OnEnterClick(key)
	GameManager.GotoUI({gotoui = key})
end

function C:act_016_cwk_time_over()
	--Act_016_XYXCWKHintPanel.Create(2)
end

