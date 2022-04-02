-- 创建时间:2019-11-28
-- Panel:LHDCombatPrefab
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

LHDCombatPrefab = basefunc.class()
local C = LHDCombatPrefab
C.name = "LHDCombatPrefab"
local M = LHDModel

function C.Create(panelSelf, obj)
	return C.New(panelSelf, obj)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
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

function C:ctor(panelSelf, obj)
	self.panelSelf = panelSelf
	self.uipos = uipos
	self.transform = obj.transform
	self.gameObject = obj.gameObject
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	self.cz_btn = {}
	self.cz_txt = {}
	self.cz_xz_node = {}
	for i = 1, 4 do
		self.cz_btn[#self.cz_btn + 1] = self["cz" .. i .. "_btn"]
		self.cz_txt[#self.cz_txt + 1] = self["cz_xz" .. i .. "_txt"]
		self.cz_xz_node[#self.cz_xz_node + 1] = self["cz_xz_node" .. i]
	end

    EventTriggerListener.Get(self.cz_bs_top.gameObject).onClick = basefunc.handler(self, self.ExitUI)

	for i = 1, 4 do
		local a = i
		self.cz_btn[i].onClick:AddListener(function ()
	        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	        self:OnCZClick(a)
	    end)
	end
	self.cz_qipai_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        self:OnQZClick()
    end)
	self.cz_jia_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        self:OnJiaClick()
    end)
    self.cz_gen_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        self:OnGenClick()
    end)
	self:MyRefresh()
end

function C:MyRefresh()
	if M.data.model_status == M.Model_Status.gaming and M.data.status == M.Status.equip then
		self.gameObject:SetActive(true)
		self:ExitUI()
		self:RefreshMoney()

		if M.data.cur_p == M.data.seat_num and M.data.player_state[M.data.seat_num] == 1 then
			self.cz_oper_node.gameObject:SetActive(true)
			local cur_cz_rate = M.GetCurCombatRateIndex()

		    local my_ls_cz = 0
		    if M.data.player_equip_rate then
			    my_ls_cz = M.data.player_equip_rate[M.data.seat_num]
		    end
		    if my_ls_cz and my_ls_cz > 0 then
		        my_ls_cz = M.data.stake_rate_data[ my_ls_cz ] * M.data.room_info.init_stake
		    else
		    	my_ls_cz = 0
		    end
		    local cur_max_cz = M.GetCurCombatRate() * M.data.room_info.init_stake

			self.gen_hint_txt.text = "投入" .. StringHelper.ToCash(cur_max_cz - my_ls_cz) .. "跟战"
			self.is_can_jb = false
			for k,v in ipairs(M.data.equip_round_rate_ids) do
				if v <= cur_cz_rate then
					self.cz_xz_node[k].gameObject:SetActive(false)
				else
					self.is_can_jb = true
					self.cz_xz_node[k].gameObject:SetActive(true)
					local val = M.data.stake_rate_data[v] * M.data.room_info.init_stake
					self.cz_txt[k].text = StringHelper.ToCash(val - my_ls_cz)
				end
			end
			if self.is_can_jb then
				self.cz_jia_btn.gameObject:SetActive(true)
				self.cz_jia_no.gameObject:SetActive(false)
			else
				self.cz_jia_btn.gameObject:SetActive(false)
				self.cz_jia_no.gameObject:SetActive(true)
			end
		else
			self.cz_oper_node.gameObject:SetActive(false)
		end
	else
		self.gameObject:SetActive(false)
	end
end
function C:RefreshMoney()
	if M.data.model_status == M.Model_Status.gaming and M.data.status == M.Status.equip  then
		self.all_bet_txt.text = M.GetTotalXZ()
		self.cur_bet_txt.text = M.data.room_info.init_stake * M.GetCurCombatRate()
	end
end

function C:OnCZClick(index)
	local rate = M.data.equip_round_rate_ids[index]
	Network.SendRequest("nor_lhd_nor_equip", {rate=rate}, "出战", function (data)
		if data.result ~= 0 then
			if data.result == 1003 then
				M.hintCondition()
			else
				HintPanel.ErrorMsg(data.result)
			end
		end
	end)
	self.cz_oper_node.gameObject:SetActive(false)
end
function C:OnQZClick()
	Network.SendRequest("nor_lhd_nor_surrender", nil, "弃战")
	self.cz_oper_node.gameObject:SetActive(false)
end
function C:ExitUI()
	self.cz_select_rect.gameObject:SetActive(false)
end
function C:OnJiaClick()
	self.cz_select_rect.gameObject:SetActive(true)
end
function C:OnGenClick()
	local rate = M.GetCurCombatRateIndex()
	Network.SendRequest("nor_lhd_nor_equip", {rate=rate}, "跟", function (data)
		if data.result ~= 0 then
			if data.result == 1003 then
				M.hintCondition()
			else
				HintPanel.ErrorMsg(data.result)
			end
		end
	end)
	self.cz_oper_node.gameObject:SetActive(false)	
end
