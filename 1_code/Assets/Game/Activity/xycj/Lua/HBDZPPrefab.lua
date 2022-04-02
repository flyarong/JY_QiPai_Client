-- 创建时间:2019-12-05
-- Panel:HBDZPPrefab
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
 
 
HBDZPPrefab = basefunc.class()
local C = HBDZPPrefab
C.name = "HBDZPPrefab"
local M = XYCJActivityManager

HBDZPPrefab.XXCJState = 
{
	Nor = "正常",
	Anim_Ing = "动画中",
	Anim_Finish = "动画完成",
}
local max_count = 16
local max_get_award_count = 2
function C.Create(parent, type, panelSelf)
	return C.New(parent, type, panelSelf)
end

function C:AddMsgListener()
	for proto_name,func in pairs(self.lister) do
		Event.AddListener(proto_name, func)
	end
end

function C:MakeLister()
	self.lister = {}
	self.lister["ExitScene"] = basefunc.handler(self, self.OnExitScene)
	self.lister["AssetChange"] = basefunc.handler(self, self.OnAssetChange)
	self.lister["model_query_luck_lottery_data"] = basefunc.handler(self, self.on_query_luck_lottery_data)
end

function C:RemoveListener()
	for proto_name,func in pairs(self.lister) do
		Event.RemoveListener(proto_name, func)
	end
	self.lister = {}
end

function C:MyExit()
	print("<color=red>type ======= " .. self.type .. "</color>")

	if self.play_deng_time then 
		self.play_deng_time:Stop()
	end
	self:CloseAnimSound()
	self:RemoveListener()
	if self.run_seq then
		self.run_seq:Kill()
	end
end
function C:MyClose()
	self:MyExit()
	destroy(self.gameObject)
end


function C:ctor(parent, type, panelSelf)
	print("<color=red>type ======= " .. type .. "</color>")
	self.panelSelf = panelSelf
	self.type = type

	local pre_name
	if type == 2 then
		pre_name = "HBDZPVIPPrefab"
	else
		pre_name = "HBDZPPTPrefab"
	end
	local obj = newObject(pre_name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj

	self:MakeLister()
	self:AddMsgListener()
	LuaHelper.GeneratingVar(obj.transform, self)

	self.get_num = M.m_data.get_num
	if type == 2 then
		if not self.panelSelf.is_goto_open and ((M.m_data.ptcj_num and M.m_data.ptcj_num > 0) or (M.sxsj and M.sxsj > MainModel.FirstLoginTime())) then
			self.Rect1.gameObject:SetActive(false)
			self.Rect2.gameObject:SetActive(true)
		else
			self.Rect1.gameObject:SetActive(true)
			self.Rect2.gameObject:SetActive(false)
		end
	else
		self.Rect1.gameObject:SetActive(true)
		self.Rect2.gameObject:SetActive(false)
	end

	self.deng_node = {}
	for i = 1, 20 do
		self["deng_node" .. i].gameObject:SetActive(false)
		self.deng_node[#self.deng_node + 1] = self["deng_node" .. i]
		newObject("choujiang_ui_deng", self["deng_node" .. i])
	end

	self.help_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:OnHelpClick()
	end)
	self.get_award_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:OnGetAwardClick()
	end)
	self.select_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:OnSelectClick()
	end)
	if IsEquals(self.get_award10_btn) then
		self.get_award10_btn.onClick:AddListener(function ()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
			self:OnGetAwardClick(10)
		end)
	end

	self.cell_size = {w = 160, h = 140}
	self.map_size = {w = 6, h = 4}

	local py_w = (self.map_size.w + 1) / 2
	local py_h = (self.map_size.h + 1) / 2
	local py_h2 = (self.map_size.h - 1) / 2
	self.pos_list = {}
	-- 上
	for i = 1, self.map_size.w do
		local x = self.cell_size.w * (i-py_w)
		local y = self.cell_size.h * (py_h-1)
		local pos = Vector3.New(x, y, 0)
		self.pos_list[#self.pos_list + 1] = pos
	end
	-- 右
	for i = 1, self.map_size.h-2 do
		local x = self.cell_size.w * (self.map_size.w-py_w)
		local y = self.cell_size.h * (py_h2-i)
		local pos = Vector3.New(x, y, 0)
		self.pos_list[#self.pos_list + 1] = pos
	end
	-- 下
	for i = self.map_size.w, 1, -1 do
		local x = self.cell_size.w * (i-py_w)
		local y = self.cell_size.h * (py_h-self.map_size.h)
		local pos = Vector3.New(x, y, 0)
		self.pos_list[#self.pos_list + 1] = pos
	end
	-- 左
	for i = 1, self.map_size.h-2 do
		local x = self.cell_size.w * (1-py_w)
		local y = self.cell_size.h * (i-py_h2)
		local pos = Vector3.New(x, y, 0)
		self.pos_list[#self.pos_list + 1] = pos
	end
	self.xycj_state = HBDZPPrefab.XXCJState.Nor

	self:InitUI()
end

function C:InitUI()
	self.award_parm = self.panelSelf.Config.award_parm[self.type]
	self.cur_config = self.panelSelf.Config.award_map[self.type]
	self.cur_award_map = {}
	for k,v in ipairs(self.cur_config) do
		self.cur_award_map[v.id] = v
	end

	self:RefreshCell()
	self:PlayDeng()
	self:MyRefresh()
end
function C:on_query_luck_lottery_data()
	self.get_num = M.m_data.get_num
	self:RefreshCJCS()
end

function C:RefreshCell()
	self:ClearCellList()
	for k,v in ipairs(self.cur_config) do
		local pre = ActivityXXCJPrefab.Create(self.CellRect, v, nil, self)
		pre:SetPos(self.pos_list[k])
		self.CellList[#self.CellList + 1] = pre
	end
end

function C:PlayDeng()
	local call = function ()
		local mm = {}
		for i = 1, 8 do
			mm[math.random(1, 20)] = 1
		end
		for k,v in pairs(mm) do
			self.deng_node[k].gameObject:SetActive(false)
			self.deng_node[k].gameObject:SetActive(true)
		end
	end

	self.dan = true
	self.play_deng_time = Timer.New(function ()
		call()
		self.dan = not self.dan
	end, 1, -1, nil, true)
	self.play_deng_time:Start()
end

function C:ClearCellList()
	if self.CellList then
		for k,v in ipairs(self.CellList) do
			v:OnDestroy()
		end
	end
	self.CellList = {}
end

function C:MyRefresh()
	local ss = StringHelper.ToCash(self.award_parm.money)
	self.get_award_hint_txt.text = "消耗：" .. ss .. "鲸币"
	if IsEquals(self.get_award10_hint_txt) then
		self.get_award10_hint_txt.text = "消耗：" .. StringHelper.ToCash(self.award_parm.money * 10) .. "鲸币"
	end
	self:RefreshCJCS()

	if self.type == 2 then
			self.introduce_txt.text = "活动规则\n"..
		"1、VIP2及以上玩家才能参与超级转盘抽奖；\n"..
		"2、Vip等级越高，每天可在Vip超级转盘抽奖的次数越多；\n"..
		"3、本公司保留在法律规定范围内对上述规则解释的权利。\n"
	else
			self.introduce_txt.text = "活动规则\n"..
		"1、小福利转盘抽奖需要消耗福利券；\n"..
		"2、充值6元及以上可获得福利券；\n" .. 
		"3、超值礼包不赠送抽奖卷。\n"
	end
end
function C:RefreshCJCS()
	if self.type == 2 then
		self.cjcs_txt.text = "当日剩余抽奖次数:" .. (self.get_num or 0)
	end
end


function C:SetAwardData(list)
	self.cur_award = {}
	self.cur_award.data = {}
	self.cur_award.skip_data = true
	for i = 1, #list do
		local cfg = self.cur_award_map[ list[i].index ]
		if cfg then
			local _desc = list[i].num
			if cfg.asset_type == "shop_gold_sum" then
				_desc = StringHelper.ToCash(_desc/100) .. "福卡"
			elseif cfg.asset_type == "jing_bi" then
				_desc = StringHelper.ToCash(_desc) .. "鲸币"
			else
				_desc = cfg.desc
			end
			self.cur_award.data[#self.cur_award.data + 1] = {image=cfg.icon, desc=_desc, asset_type=cfg.asset_type, value=list[i].num}
		end
	end
	dump(self.cur_award,"<color=red>self.cur_award</color>")
end

function C:OnAssetChange(data)
	-- if data.change_type and data.change_type == "lottery_luck_box" then
	-- 	self.cur_award = data
	-- end
end
function C:OnExitScene()
	self:MyExit()
end
function C:OnHelpClick()
	if self.xycj_state ~= HBDZPPrefab.XXCJState.Nor then
		print("当前状态= " .. self.xycj_state)
		return
	end
	IllustratePanel.Create({self.introduce_txt}, self.panelSelf.transform)
end
function C:CloseAnimSound()
	if self.curSoundKey then
		soundMgr:CloseLoopSound(self.curSoundKey)
		self.curSoundKey = nil
	end
end
function C:BeginCJAnim(index)
	self:CloseAnimSound()
	self.curSoundKey = ExtendSoundManager.PlaySound(audio_config.game.bgm_duijihongbao.audio_name, 1, function ()
		self.curSoundKey = nil
	end)
	if self.run_seq then
		self.run_seq:Kill()
		self.run_seq = nil
	end

	local end_index
	for i = 1, #self.cur_config do
		if self.cur_config[i].id == index then
			end_index = i
			break
		end
	end
	if not end_index then
		print("奖励id没有找到" .. index)
		return
	end
	local step
	local begin_index = self.anim_begin_index or 1
	local quanshu = 10-- 转圈数
	if end_index > begin_index then
		step = max_count * quanshu + end_index - begin_index + 1
	else
		step = max_count * quanshu + max_count - begin_index + end_index + 1
	end

	local max_speed = 0.02
	local min_speed = 0.3

	local all_t = 6.3 -- 秒
	local qianzou = 1.6 -- 秒
	local zhongjian = max_count * quanshu * max_speed
	local houzou = all_t - qianzou - zhongjian - 0.3

	local frame = 7
	local end_frame = 17
	self.xycj_state = HBDZPPrefab.XXCJState.Anim_Ing
	self.run_seq = DoTweenSequence.Create()
	for i = 1, step do
		local k = begin_index + i - 1
		if k % max_count ~= 0 then
			k = k % max_count
		else
			k = max_count
		end
		local t
		if i <= frame then
			t = qianzou / frame
		elseif i >= (step - end_frame) then
			t = houzou / end_frame
		else
			t = max_speed
		end
		self.run_seq:AppendInterval(t)
		self.run_seq:AppendCallback(function ()
			self.CellList[k]:RunFX()
		end)
	end
	self.run_seq:AppendInterval(0.1)
	self.run_seq:AppendCallback(function ()
		self.CellList[end_index]:PlayXZ()
	end)
	self.run_seq:AppendInterval(1)
	self.run_seq:OnKill(function ()
		self:RunAnimFinish()
	end)
	self.run_seq:OnForceKill(function ()
		if self.xycj_state == HBDZPPrefab.XXCJState.Anim_Ing then
			if IsEquals(self.gameObject) then
				self:RunAnimFinish()
			else
				self:ShowAwardBrocast()
			end
		end
	end)
	self.anim_begin_index = end_index
end
function C:OnGetAwardClick(cj_num)
	-- 测试效果
	-- if true then
	-- 	self.cur_award = {
	-- 	     change_type = "lottery_luck_box",
	-- 	     data = {
	-- 	         [1] = {
	-- 	             asset_type = "shop_gold_sum",
	-- 	             value      = 14400,
	-- 	         },
	-- 	         [2] = {
	-- 	             asset_type = "jing_bi",
	-- 	             value      = 2001000,
	-- 	         },
	-- 	         [3] = {
	-- 	             asset_type = "shop_gold_sum",
	-- 	             value      = 13600,
	-- 	         },
	-- 	         [4] = {
	-- 	             asset_type = "shop_gold_sum",
	-- 	             value      = 16000,
	-- 	         },
	-- 	         [5] = {
	-- 	             asset_type = "shop_gold_sum",
	-- 	             value      = 16000,
	-- 	         },
	-- 	         [6] = {
	-- 	             asset_type = "shop_gold_sum",
	-- 	             value      = 12800,
	-- 	         },
	-- 	         [7] = {
	-- 	             asset_type = "shop_gold_sum",
	-- 	             value      = 14400,
	-- 	         },
	-- 	         [8] = {
	-- 	             asset_type = "jing_bi",
	-- 	             value      = 2008000,
	-- 	         },
	-- 	         [9] = {
	-- 	             asset_type = "shop_gold_sum",
	-- 	             value      = 12800,
	-- 	         },
	-- 	         [10] = {
	-- 	             asset_type = "jing_bi",
	-- 	             value      = 2005000,
	-- 	         },
	-- 	     },
	-- 	 }
	-- 	local pre = AssetsGet10Panel.Create(self.cur_award.data, function ()
	-- 			print("<color=red>确定</color>")
	-- 		end)
	-- 	pre.info_desc_txt.transform.localPosition = Vector3.New(0, -325, 0)
	-- 	local hb = 0
	-- 	local jb = 0
	-- 	for k,v in ipairs(self.cur_award.data) do
	-- 		if v.asset_type == "shop_gold_sum" then
	-- 			hb = hb + v.value
	-- 		elseif v.asset_type == "jing_bi" then
	-- 			jb = jb + v.value
	-- 		end
	-- 	end
	-- 	pre.info_desc_txt.text = "总共获得：" .. StringHelper.ToCash(hb/100) .. "福卡    " .. StringHelper.ToCash(jb) .. "鲸币"

	-- 	return
	-- end
	cj_num = cj_num or 1 -- 抽奖次数
	if self.xycj_state ~= HBDZPPrefab.XXCJState.Nor then
		print("当前状态= " .. self.xycj_state)
		return
	end
	if self.type == 1 then
		local n = GameItemModel.GetItemCount("prop_xycj_coin")
		if n < 1 then
			if M.m_data.ptcj_num > 0 then
				local pre = HintPanel.Create(2, "请前往VIP超级转盘，抽取更高的福利吧！", function ()
					Event.Brocast("xycj_change_ui_msg", {type = 2})
				end)
				pre:SetButtonText(nil, "前 往")
				self.panelSelf.is_goto_open = false
				return
			end
		end
	end
	local min_money = (cj_num+1) * self.award_parm.money
	if MainModel.UserInfo.jing_bi < min_money then
		local ss = StringHelper.ToCash(min_money)
		local pre = HintPanel.Create(2, "您携带的鲸币不足" .. ss .."，是否前往商城获得鲸币？", function ()
			self:OpenShop()
		end)
		pre:SetButtonText(nil, "前 往")
		return
	end

	-- 福利抽奖
	if self.type == 1 then
		local n = GameItemModel.GetItemCount("prop_xycj_coin")
		if n < 1 then
			local pre = HintPanel.Create(2, "在商城累计充值6元可获得福利券，是否前往商城充值？", function ()
				self:OpenShop()
			end)
			pre:SetButtonText(nil, "前 往")
			return
		end
	else
		local a,vip = GameButtonManager.RunFun({gotoui="vip"}, "get_vip_level")
		if a and vip > 1 then
			if self.get_num <= 0 then
				if vip == 12 then
					HintPanel.Create(1, "尊敬的VIP12，您当日的抽奖次数已用完，请明日再来！")
				else
					local pre = HintPanel.Create(6, "升级VIP可增加抽奖次数！", function ()
						GameManager.GotoUI({gotoui="vip", goto_scene_parm="VIP2"})
					end, function ()
						self:OpenShop()
					end)
					pre:SetButtonText("查看VIP", "成为VIP")
				end
				return
			end
			if cj_num == 10 and cj_num > self.get_num then
				HintPanel.Create(1, "十连抽需要消耗10次抽奖次数，您当日的抽奖次数不足，提升Vip可增加次数！")
				return
			end
		else
			local pre = HintPanel.Create(6, "VIP2及以上玩家才能进行抽奖", function ()
				GameManager.GotoUI({gotoui="vip", goto_scene_parm="VIP2"})
			end, function ()
				self:OpenShop()
			end)
			pre:SetButtonText("查看VIP", "成为VIP")
			return
		end
	end

	Network.SendRequest("pay_luck_lottery", {id=self.type, num = cj_num}, "请求数据", function (data)
		dump(data, "<color=red>pay_luck_lottery</color>")
		if data.result == 0 then
			self:SetAwardData(data.data)
			if #data.data == 1 then
				self:BeginCJAnim(data.data[1].index)
			else
				self:RunAnimFinish()
			end
			if self.type == 2 then
				self.get_num = self.get_num - #data.data
				M.m_data.get_num = self.get_num
				self:RefreshCJCS()
			else
				M.m_data.ptcj_num = M.m_data.ptcj_num + 1
			end

		else
			HintPanel.ErrorMsg(data.result)
		end
	end)
end
function C:RunAnimFinish()
	self.xycj_state = HBDZPPrefab.XXCJState.Anim_Finish
	for i = 1, #self.CellList do
		self.CellList[i]:RunEnd()
	end
	self.xycj_state = HBDZPPrefab.XXCJState.Nor
	self:CloseAnimSound()

	self:ShowAwardBrocast()
end
function C:ShowAwardBrocast()
	dump(self.cur_award, "<color=red>EEE cur_award</color>")
	if self.cur_award then
		if #self.cur_award.data == 1 then
			Event.Brocast("AssetGet", self.cur_award)
		else
			local pre = AssetsGet10Panel.Create(self.cur_award.data, function ()
				print("<color=red>确定</color>")
			end)
			pre.info_desc_txt.transform.localPosition = Vector3.New(0, -325, 0)
			local hb = 0
			local jb = 0
			for k,v in ipairs(self.cur_award.data) do
				if v.asset_type == "shop_gold_sum" then
					hb = hb + v.value
				elseif v.asset_type == "jing_bi" then
					jb = jb + v.value
				end
			end
			pre.info_desc_txt.text = "总共获得：" .. StringHelper.ToCash(hb/100) .. "福卡    " .. StringHelper.ToCash(jb) .. "鲸币"
		end
		self.cur_award = nil
	end
end
function C:OnSelectClick()
	if self.xycj_state ~= HBDZPPrefab.XXCJState.Nor then
		print("当前状态= " .. self.xycj_state)
		return
	end

	if self.type == 2 then
		Event.Brocast("xycj_change_ui_msg", {type = 1})
	else
		Event.Brocast("xycj_change_ui_msg", {type = 2})
	end
end

function C:OpenShop()	
	if VIPManager.get_vip_level() < 10 then
		PayPanel.Create(GOODS_TYPE.jing_bi, "normal")
	else
		GameManager.GotoUI({gotoui = "game_MiniGame"})
	end
	self.panelSelf:MyClose()
end

