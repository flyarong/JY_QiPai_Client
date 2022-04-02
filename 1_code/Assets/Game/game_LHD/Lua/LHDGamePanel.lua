-- 创建时间:2019-11-18
local basefunc = require "Game.Common.basefunc"

LHDGamePanel = basefunc.class()
local C = LHDGamePanel
C.name = "LHDGamePanel"
local M = LHDModel
local listerRegisterName = "lhdFreeGameListerRegister"

function C.Create(parm)
	return C.New(parm)
end

function C:ctor(parm)

	ExtPanel.ExtMsg(self)

	self.parm = parm
	local parent = GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
    self:MakeLister()
    LHDLogic.setViewMsgRegister(self.lister, listerRegisterName)

    self.PlayerClass = {}
    for i = 1, M.maxPlayerNumber do
        self.PlayerClass[i] = LHDPlayer.Create(self, self["player" .. i].gameObject, i)
    end
    
    EventTriggerListener.Get(self.top_menu.gameObject).onClick = basefunc.handler(self, self.OnTopMenu)
    self.menu_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        self:OnMenuClick()
    end)
	self.back_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        self:OnBackClick()
    end)
    self.help_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        self:OnHelpClick()
    end)
    self.set_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        GameManager.GotoUI({gotoui = "sys_setting",goto_scene_parm = "panel"})
    end)
    self.center_pre = LHDGameCenterPrefab.Create(self, self.game_rect)
    self.oper_pre = LHDGameOperPrefab.Create(self, self.oper_rect)
    self.combat_pre = LHDCombatPrefab.Create(self, self.combat_rect)
    self.bq_pre = LHDBQPanel.Create()

    self.lhd_guide = LHDGuidePanel.Create(self)

    local btn_map = {}
    btn_map["left_top"] = {self.lt_node1, self.lt_node2, self.lt_node3}
    self.game_btn_pre = GameButtonPanel.Create(btn_map, "lhd_game")

    self.begin_time_node_anim = self.begin_time_node:GetComponent("Animator")
    self:InitUI()
    self:MyRefresh()
end
function C:InitUI()
    self.begin_time_node.gameObject:SetActive(false)
    self.begin_time_hint.gameObject:SetActive(false)
    self.rt_rect1.gameObject:SetActive(false)
	self.oper_rect.gameObject:SetActive(true)
end
function C:MyExit()
	self.center_pre:MyExit()
	self.combat_pre:MyExit()
	self.oper_pre:MyExit()
	self.bq_pre:MyExit()
	self.lhd_guide:MyExit()

    LHDLogic.clearViewMsgRegister(listerRegisterName)
	for i = 1, M.maxPlayerNumber do
		self.PlayerClass[i]:MyExit()
	end
	if self.js_pre and IsEquals(self.js_pre.gameObject) then
		self.js_pre:MyExit()
	end
	if self.wait_pre then
		self.wait_pre:MyExit()
		self.wait_pre = nil
	end

    if self.game_btn_pre then
        self.game_btn_pre:MyExit()
        self.game_btn_pre = nil
    end

	local bgl = self.transform:Find("BGL"):GetComponent("Image")
	bgl.sprite = nil
	local bgr = self.transform:Find("BGR"):GetComponent("Image")
	bgr.sprite = nil

	destroy(self.gameObject)
end
function C:MyClose()
    self:MyExit()
end
function C:OnTopMenu()
	self.rt_rect1.gameObject:SetActive(false)
end
function C:OnMenuClick()
	if LHDModel.data.xsyd == 1 then
		LittleTips.Create("新手引导中")
		return
	end
	local b = self.rt_rect1.gameObject.activeInHierarchy
	self.rt_rect1.gameObject:SetActive(not b)
end
function C:OnBackClick()
	local callback = function(  )
		Network.SendRequest("fg_lhd_quit_game", nil, "请求退出")
	end
	GameButtonManager.RunFun({gotoui="sys_act_operator",showHint = true,callback = callback}, "CanLeaveGameBeforeEnd")
end
function C:OnHelpClick()
	LHDHelpPanel.Create()
end

function C:MakeLister()
    self.lister = {}
	self.lister["model_fg_join_msg"] = basefunc.handler(self, self.on_model_fg_join_msg)
	self.lister["model_fg_leave_msg"] = basefunc.handler(self, self.on_model_fg_leave_msg)
	self.lister["model_fg_gameover_msg"] = basefunc.handler(self, self.on_model_fg_gameover_msg)
	self.lister["model_fg_ready_msg"] = basefunc.handler(self, self.on_model_fg_ready_msg)
	self.lister["model_nor_lhd_nor_begin_msg"] = basefunc.handler(self, self.on_model_nor_lhd_nor_begin_msg)
	self.lister["model_nor_lhd_nor_pai_msg"] = basefunc.handler(self, self.on_model_nor_lhd_nor_pai_msg)
	self.lister["model_nor_lhd_nor_show_pai_msg"] = basefunc.handler(self, self.on_model_nor_lhd_nor_show_pai_msg)
	self.lister["model_nor_lhd_nor_mopai_msg"] = basefunc.handler(self, self.on_model_nor_lhd_nor_mopai_msg)
	self.lister["model_nor_lhd_nor_ding_zhuang_msg"] = basefunc.handler(self, self.on_model_nor_lhd_nor_ding_zhuang_msg)
	self.lister["model_nor_lhd_nor_surrender_msg"] = basefunc.handler(self, self.on_model_nor_lhd_nor_surrender_msg)
	self.lister["model_nor_lhd_nor_permit_msg"] = basefunc.handler(self, self.on_model_nor_lhd_nor_permit_msg)
	self.lister["model_nor_lhd_nor_auto_msg"] = basefunc.handler(self, self.on_model_nor_lhd_nor_auto_msg)
	self.lister["model_nor_lhd_nor_new_game_msg"] = basefunc.handler(self, self.on_model_nor_lhd_nor_new_game_msg)
	self.lister["model_nor_lhd_nor_equip_msg"] = basefunc.handler(self, self.on_model_nor_lhd_nor_equip_msg)
	self.lister["model_nor_lhd_nor_settlement_msg"] = basefunc.handler(self, self.on_model_nor_lhd_nor_settlement_msg)

	self.lister["model_nor_lhd_nor_buqi_msg"] = basefunc.handler(self, self.on_model_nor_lhd_nor_buqi_msg)

	self.lister["model_fg_huanzhuo_response"] = basefunc.handler(self, self.on_model_fg_huanzhuo_response)
	self.lister["model_fg_ready_response"] = basefunc.handler(self, self.on_model_fg_ready_response)
	self.lister["model_update_player_score_msg"] = basefunc.handler(self, self.on_model_update_player_score_msg)

	self.lister["ui_gold_fly_finish_msg"] = basefunc.handler(self, self.on_ui_gold_fly_finish_msg)
	self.lister["ui_dz_anim_finish_msg"] = basefunc.handler(self, self.on_ui_dz_anim_finish_msg)
	self.lister["ui_fp_anim_finish_msg"] = basefunc.handler(self, self.on_ui_fp_anim_finish_msg)
	self.lister["ui_combat_finish_msg"] = basefunc.handler(self, self.on_ui_combat_finish_msg)
	self.lister["ui_begin_fly_gold_msg"] = basefunc.handler(self, self.on_ui_begin_fly_gold_msg)

	self.lister["model_fg_all_info"] = basefunc.handler(self, self.on_model_fg_all_info)
	self.lister["model_begin_game_djs"] = basefunc.handler(self, self.on_model_begin_game_djs)
	self.lister["model_new_yilun_zadan_msg"] = basefunc.handler(self, self.on_model_new_yilun_zadan)
	self.lister["model_nor_lhd_nor_wait_pay_msg"] = basefunc.handler(self, self.on_model_nor_lhd_nor_wait_pay_msg)
end

function C:on_model_fg_join_msg(seat_num)
	local uiPos = M.GetSeatnoToPos(seat_num)
    self.PlayerClass[uiPos]:SetPlayerEnter()
end
function C:on_model_fg_leave_msg(seat_num)
	local uiPos = M.GetSeatnoToPos(seat_num)
    self.PlayerClass[uiPos]:SetPlayerExit()
end
function C:on_model_fg_gameover_msg(data)
	self:MyRefresh()
end
function C:on_model_fg_ready_msg(seat_num)
	if seat_num == M.data.seat_num then
		self:MyRefresh()
	else
		local uiPos = M.GetSeatnoToPos(seat_num)
	    self.PlayerClass[uiPos]:MyRefresh()
	end
end
function C:on_model_nor_lhd_nor_begin_msg(data)
	ExtendSoundManager.PlaySound(audio_config.dld.dld_start.audio_name)
	LHDAnimation.PlayGCFX(self.transform, Vector3.zero, "yxks")
	self:MyRefresh()
end
-- 发牌
function C:on_model_nor_lhd_nor_pai_msg(data)
	-- 两张牌
	local jd = 1
	local tt = 0.1
	for i = 1, 2 do
	    for k,v in ipairs(M.data.player_pai) do
	        if M.data.player_state[k] == 1 then
				local uiPos = M.GetSeatnoToPos(k)
				local d = {}
				d.seat_num = k
				d.uipos = uiPos
				d.pai = v[i]
				d.index = i
				local endPos = self.PlayerClass[uiPos]:GetCardPos(i)
				LHDAnimation.PlayFP(d, self.transform, Vector3.zero, endPos, tt*(jd-1))
				jd = jd + 1
	        end
	    end
	end
	self.center_pre:FDAnim(1)
end
-- 一张牌 发到玩家面前
function C:on_ui_fp_anim_finish_msg(data)
    self.PlayerClass[data.uipos]:AddCard(data.index, data.pai)
end

function C:on_model_nor_lhd_nor_show_pai_msg(data)
	local uiPos = M.GetSeatnoToPos(data.seat_num)
	local endPos = self.PlayerClass[uiPos]:GetPos("kp")
	LHDAnimation.PlayTShint(self.transform, endPos, function ()
		ExtendSoundManager.PlaySound(audio_config.dld.magic_cards.audio_name)
		self.center_pre:on_model_nor_lhd_nor_show_pai_msg(data)
	end)

	if data.seat_num == M.data.seat_num then
		self.oper_pre:HideOperUI()
	end
end
function C:on_model_nor_lhd_nor_mopai_msg(data)
	local seat_num = data.seat_num
	local uiPos = M.GetSeatnoToPos(seat_num)
    self.PlayerClass[uiPos]:StopRunTime()
    local call = function ()
		self.center_pre:on_model_nor_lhd_nor_mopai_msg(data)
		ExtendSoundManager.PlaySound(audio_config.dld.dld_zayixia.audio_name)
    end

	local uiPos = M.GetSeatnoToPos(seat_num)
	self.PlayerClass[uiPos]:RefreshBJ()

	if data.is_change_rate then
		ExtendSoundManager.PlaySound(audio_config.dld.double_bet.audio_name)
		local mm = M.data.stake_rate_data[data.rate]*M.data.room_info.init_stake
		LHDAnimation.PlayJBAnim(self.transform, self.PlayerClass[uiPos]:GetPos("jb"), mm, function ()
			LHDAnimation.PlayQBHAnim(data.change_rate_val, self.center_pre.za)
			call()
		end)
	else
		call()
	end
	if data.seat_num == M.data.seat_num then
		self.oper_pre:HideOperUI()
	end
end
-- 定庄
function C:on_model_nor_lhd_nor_ding_zhuang_msg(data)
	-- LHDAnimation.PlayGCFX(self.transform, Vector3.zero, "zjxz", function ()
	-- 	local z_objs = {}
	-- 	for k,v in ipairs(M.data.player_state) do
	-- 		if v == 1 then
	-- 			local uiPos = M.GetSeatnoToPos(k)
	-- 			z_objs[#z_objs + 1] = self.PlayerClass[uiPos].select_node
	-- 		end
	-- 	end
	-- 	LHDAnimation.PlayDZ(z_objs, M.data.zhuang_seat_num)
	-- end)

	LHDAnimation.PlayGCFX(self.transform, Vector3.zero, "zjxz", function ()
		local uiPos = M.GetSeatnoToPos(M.data.zhuang_seat_num)

		local z_objs = {}
		local uu_zj = 1
		for k,v in ipairs(M.data.player_state) do
			if v == 1 then
				local uiPos = M.GetSeatnoToPos(k)
				z_objs[#z_objs + 1] = self.PlayerClass[uiPos].select_node
				if k == M.data.zhuang_seat_num then
					uu_zj = #z_objs
				end
			end
		end
		LHDAnimation.PlayDZ(self.transform, z_objs, uu_zj)
	end)
end
-- 定庄动画完成
function C:on_ui_dz_anim_finish_msg()
	local uiPos = M.GetSeatnoToPos(M.data.zhuang_seat_num)
	for i = 1, M.maxPlayerNumber do
		if uiPos == i then
			self.PlayerClass[i].zj_node.gameObject:SetActive(true)
		else
			self.PlayerClass[i].zj_node.gameObject:SetActive(false)
		end
	end		
end
-- 投降
function C:on_model_nor_lhd_nor_surrender_msg(seat_num)
	ExtendSoundManager.PlaySound(audio_config.dld.give_up.audio_name)
	local uiPos = M.GetSeatnoToPos(seat_num)
    self.PlayerClass[uiPos]:MyRefresh()
    self.oper_pre:MyRefresh()
    if seat_num == M.data.seat_num then
    	self.oper_pre:HideOperUI()
    end
end
-- 结算
function C:on_model_nor_lhd_nor_settlement_msg(data)
	for i = 1, M.maxPlayerNumber do
		self.PlayerClass[i].cur_cz.gameObject:SetActive(false)
	end

	local anim_data = {}
	for k,v in ipairs(data.settlement_info.player_info) do
		if M.data.player_state[v.seat_num] == 1 then
			local dd = {}
			anim_data[#anim_data + 1] = dd
			dd.seat_num = v.seat_num
			dd.ui_pos = M.GetSeatnoToPos(v.seat_num)
			if data.settlement_info.winner == v.seat_num then
				dd.is_win = true
			else
				dd.is_win = false
			end
			dd.beginPos = self.PlayerClass[dd.ui_pos]:GetCardPos(3)
		end
	end
	if #anim_data > 1 then
		LHDAnimation.PlayGCFX(self.transform, Vector3.zero, "zdks", function ()
			ExtendSoundManager.PlaySceneBGM(audio_config.dld.fight.audio_name)

			for k,v in ipairs(data.settlement_info.player_pai) do
				if M.data.player_state[k] == 1 then
					local uiPos = M.GetSeatnoToPos(k)
					self.PlayerClass[uiPos]:ShowSPAnim(v.pai)
					LHDAnimation.PlayPXAnim(data.settlement_info.pai_type[k], self.PlayerClass[uiPos].px_node, 1)
				end
			end
			LHDAnimation.PlayNewCZAnim(anim_data, self.transform, 3)
		end)
	else
		self:MyRefresh()
	end
end
function C:on_ui_combat_finish_msg()
	ExtendSoundManager.PlayOldBGM()
	ExtendSoundManager.PlaySound(audio_config.dld.win_money.audio_name)
	local node = self.combat_pre.jc
	local seat_num = M.data.settlement_info.winner
	local win_num = M.data.settlement_info.award
	local desc = "+" .. StringHelper.ToCash(win_num)
	local uiPos = M.GetSeatnoToPos(seat_num)
	local endPos = self.PlayerClass[uiPos]:GetPos()
	LHDAnimation.PlayJSGoldAnim({seat_num=seat_num, desc=desc}, self.transform, node.position, endPos)
end
function C:on_ui_begin_fly_gold_msg()
	ExtendSoundManager.PlayOldBGM()
	ExtendSoundManager.PlaySound(audio_config.dld.win_money.audio_name)
	local node = self.combat_pre.jc
	local seat_num = M.data.settlement_info.winner
	local win_num = M.data.settlement_info.award
	local desc = "+" .. StringHelper.ToCash(win_num)
	local uiPos = M.GetSeatnoToPos(seat_num)
	local endPos = self.PlayerClass[uiPos]:GetPos()
	LHDAnimation.PlayJSGoldAnim({seat_num=seat_num, desc=desc}, self.transform, node.position, endPos)
end

function C:on_model_nor_lhd_nor_permit_msg(data)
	if data.cur_p == M.data.seat_num and M.data.status then
		if M.data.status == M.Status.mopai then
			LHDAnimation.PlayGCFX(self.transform, Vector3.zero, "zd")
		end
	end
	-- 首次出战 放动画
	if M.data.status == M.Status.equip and M.IsFirstCZ() then
		LHDAnimation.PlayGCFX(self.transform, Vector3.zero, "czxz")
		ExtendSoundManager.PlaySound(audio_config.dld.start_operation.audio_name)
	end
	M.data.buf.is_ts_oper = false
	self:MyRefresh()

	Event.Brocast("lhd_guide_check")
end
function C:on_model_nor_lhd_nor_equip_msg(data)
	if data.is_gen then
		ExtendSoundManager.PlaySound(audio_config.dld.follow_up.audio_name)
	else
		ExtendSoundManager.PlaySound(audio_config.dld.double_bet.audio_name)

		LHDAnimation.PlayQBHAnim(data.change_rate_val, self.combat_pre.cz)
	end
	local uiPos = M.GetSeatnoToPos(data.seat_num)
    self.PlayerClass[uiPos]:MyRefresh()
    self.combat_pre:RefreshMoney()
    Event.Brocast("lhd_guide_check")
end
function C:on_model_nor_lhd_nor_auto_msg(data)
	self:MyRefresh()
end
function C:on_model_nor_lhd_nor_new_game_msg(data)
	self:MyRefresh()
end
function C:on_model_nor_lhd_nor_buqi_msg(data)
	if data.buqi == 0 then
	else
		ExtendSoundManager.PlaySound(audio_config.dld.follow_up.audio_name)
		local uiPos = M.GetSeatnoToPos(data.seat_num)
	    self.PlayerClass[uiPos]:MyRefresh()
	end
end
function C:on_model_fg_huanzhuo_response(data)
end
function C:on_model_fg_ready_response(data)
end
function C:on_model_update_player_score_msg(data)
	for i = 1, M.maxPlayerNumber do
		self.PlayerClass[i]:RefreshMoney()
	end
	self.center_pre:RefreshMoney()
	self.combat_pre:RefreshMoney()

	if data.type == "chongzi" then
		return
	end
	if data.type == "xd" then
		if M.data.player_state[M.data.seat_num] == 1 then
			ExtendSoundManager.PlaySound(audio_config.dld.bet_money.audio_name)
		else
			return
		end
	end
	if data.type ~= "ff" then
		local seat_num = data.seat_num or M.data.seat_num
		local uiPos = M.GetSeatnoToPos(seat_num)
		local beginPos = self.PlayerClass[uiPos]:GetPos()
		local endPos = Vector3.New(beginPos.x, beginPos.y + 50, beginPos.z)
		local desc = "-" .. StringHelper.ToCash(data.score)
		LHDAnimation.PlayGoldText(self.transform, beginPos, endPos, nil, "lhd_gold_text", desc)
	end
end
-- 金币飞行完成
function C:on_ui_gold_fly_finish_msg(data)
	self:MyRefresh()
end
-- 新的一轮砸蛋
function C:on_model_new_yilun_zadan(data)
	local lun = M.GetCurPlayerMaxPaiNum()
	if M.IsNewRound() and lun < 5 then
		print("<color=red>lun lun lun = " .. lun .. "</color>")
		LHDAnimation.PlayGCFX(self.transform, Vector3.zero, "blzdks", nil, lun)
		ExtendSoundManager.PlaySound(audio_config.dld.start_operation.audio_name)
	end
end
function C:on_model_nor_lhd_nor_wait_pay_msg(data)
	for i = 1, M.maxPlayerNumber do
		self.PlayerClass[i]:MyRefresh()
	end
	self.bq_pre:MyRefresh()
end
function C:on_model_begin_game_djs(b)
	if b and not self.begin_time_node.gameObject.activeSelf then
		self.begin_time_node_anim:Play("lhd_kjdjs", 0, 0)
	    self.begin_time_node.gameObject:SetActive(true)
	    self.begin_time_hint.gameObject:SetActive(true)
	else
	    self.begin_time_node.gameObject:SetActive(false)
	    self.begin_time_hint.gameObject:SetActive(false)
	end
end
function C:on_model_fg_all_info()
	print("<color=red>UI on_model_fg_all_info</color>")
	local cfg = LHDManager.GetGameIdByConfig(M.data.room_info.game_id)
	self.room_desc_txt.text = cfg.game_name .. " 底分:" .. M.data.room_info.init_stake

    self.begin_time_node.gameObject:SetActive(false)
	if M.GetReadyPlayerNum(M.data.playerInfo) > 1 and M.data.model_status == M.Model_Status.wait_begin then
	    -- self.begin_time_hint.gameObject:SetActive(true)
	    self:on_model_begin_game_djs(true)
	else
	    self.begin_time_hint.gameObject:SetActive(false)
	end

end
function C:MyRefresh()
	
	for i = 1, M.maxPlayerNumber do
		self.PlayerClass[i]:MyRefresh()
	end
	self.center_pre:MyRefresh()
	self.combat_pre:MyRefresh()
	self.oper_pre:MyRefresh()
	self.bq_pre:MyRefresh()

	if M.data.model_status == M.Status.gameover then
		if self.js_pre and IsEquals(self.js_pre.gameObject) then
			self.js_pre:MyRefresh()
		else
			self.js_pre = LHDClearingPanel.Create()
		end
	else
		if self.js_pre and IsEquals(self.js_pre.gameObject) then
			self.js_pre:MyExit()
		end
		self.js_pre = nil
	end

	-- 等待界面
	if M.data.model_status == M.Model_Status.wait_table then
		if not self.wait_pre then
			self.wait_pre = LHDWaitPanel.Create({countdown = M.data.countdown})
		end
	else
		if self.wait_pre then
			self.wait_pre:MyExit()
			self.wait_pre = nil
		end
	end
end

