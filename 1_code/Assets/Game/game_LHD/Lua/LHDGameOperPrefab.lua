-- 创建时间:2019-11-20
-- Panel:LHDGameOperPrefab
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

LHDGameOperPrefab = basefunc.class()
local C = LHDGameOperPrefab
C.name = "LHDGameOperPrefab"
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
	self:StopHZTime()
	self.ready_clock_pre:StopRunTime()
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

	self.ready_clock_pre = LHDClockPrefab.Create(self.ready_node)
	self.ready_clock_pre:SetActive(false)

	self.ready_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        self:OnReadyClick()
    end)
    self.hz_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        self:OnHZClick()
    end)


    self.qp_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        self:OnFQClick()
    end)
    self.za_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        self:OnZAClick()
    end)
    self.ts_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        self:OnTSClick()
    end)
    self.bs_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        self:OnBSClick()
    end)
    self.qx_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        self:OnQXClick()
    end)
    EventTriggerListener.Get(self.bs_top.gameObject).onClick = basefunc.handler(self, self.ExitUI)

    self.select_list = {}
	for i = 1, 4 do
		local obj = self.bs_select_rect:Find("Image/Prefab" .. i)
		local rate_txt = self.bs_select_rect:Find("Image/Prefab" .. i.. "/@rate_txt"):GetComponent("Text")
		self.select_list[#self.select_list + 1] = {rate_txt = rate_txt, obj = obj}
		rate_txt.transform:GetComponent("Button").onClick:AddListener(function ()
	        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	        self:OnXZBSClick(i)
	    end)
	end

	local LHD_xz_tsd = GameObject.Instantiate(GetPrefab("LHD_xz_tsd"), self.qxz_ts_node).gameObject
	LHD_xz_tsd.transform.localPosition = Vector3.zero
	LHD_xz_tsd.transform.localScale = Vector3.one
	local LHD_xz_zkd = GameObject.Instantiate(GetPrefab("LHD_xz_zkd"), self.qxz_zd_node).gameObject
	LHD_xz_zkd.transform.localPosition = Vector3.zero
	LHD_xz_zkd.transform.localScale = Vector3.one
	
	self:InitUI()
end

function C:InitUI()	
	self:MyRefresh()
end

function C:MyRefresh()
	self.qx_btn.gameObject:SetActive(false)
	self.bs_select_rect.gameObject:SetActive(false)
	if M.data and M.data.model_status then
		self:RefreshReady()
		if M.data.model_status == M.Model_Status.gaming then
			if M.data.cur_p == M.data.seat_num and M.data.status == M.Status.mopai and M.data.player_state[M.data.seat_num] == 1 then
				local bs = M.GetCurRate()
				self.is_can_jb = false
				local cur_c = M.data["stake_round_" .. M.GetCurRound() .. "_rate_ids"]
				for k,v in ipairs(self.select_list) do
					local nn = M.data.room_info.init_stake * M.data.stake_rate_data[ cur_c[k] ]
					v.rate_txt.text = StringHelper.ToCash(nn)
					if M.data.stake_rate_data[ cur_c[k] ] <= bs then
						v.obj.gameObject:SetActive(false)
					else
						v.obj.gameObject:SetActive(true)
						self.is_can_jb = true
					end
				end
				if self.is_can_jb then
					self.bs_btn.gameObject:SetActive(true)
					self.bs_no.gameObject:SetActive(false)
				else
					self.bs_btn.gameObject:SetActive(false)
					self.bs_no.gameObject:SetActive(true)
				end

				local ts_nn = M.data.room_info.init_stake * M.data.stake_rate_data[M.data.super_rate]
				self.LHD_xz_tsd_txt.text = "<color=#f5fcffff>透视需要投入</color><color=#ff3f3fff>" .. StringHelper.ToCash(ts_nn) .."鲸币</color>"

				self.down_rect.gameObject:SetActive(true)

				if not M.IsCanOperTM() then
					self.ts_btn.gameObject:SetActive(false)
					self.ts_no.gameObject:SetActive(true)
				else
					self.ts_btn.gameObject:SetActive(true)
					self.ts_no.gameObject:SetActive(false)
				end

				-- self.cur_rate_txt.text = bs .. "倍"
			else
				self.down_rect.gameObject:SetActive(false)
			end
		else
			self.down_rect.gameObject:SetActive(false)
		end
	else
		self.down_rect.gameObject:SetActive(false)
	end
end

function C:RefreshReady()
	self:StopHZTime()
	self.ready_clock_pre:StopRunTime()
	self.ready_node.gameObject:SetActive(false)
	self.ready_btn.gameObject:SetActive(false)
	self.hz_btn.gameObject:SetActive(false)
	self.hz_not_img.gameObject:SetActive(false)

	if not M.IsLDC() and M.data.model_status == M.Model_Status.wait_begin
		and M.data.player_state[M.data.seat_num] == 0
		and M.IsPlayerReady(M.data.seat_num)
		and M.data.countdown > 0 then
		self.hz_btn.gameObject:SetActive(false)
		self.hz_not_img.gameObject:SetActive(true)
		self.down_t = M.data.countdown
		self.hz_time = Timer.New(function ()
			self.down_t = self.down_t - 1
			if self.down_t <= 0 then
				self:StopHZTime()
			end
			self:UpdateHZUI(true)
		end, 1, -1)
		self.hz_time:Start()
		self:UpdateHZUI()
		return
	end
	if M.IsLDC() and M.data.model_status == M.Model_Status.wait_begin and not M.IsPlayerReady(M.data.seat_num) then
		self.ready_btn.gameObject:SetActive(true)
		self.hz_btn.gameObject:SetActive(true)
		self.hz_btn.transform.localPosition = Vector3.New(-208, -394, 0)
		return
	end
	if M.data.model_status == M.Model_Status.gaming and M.data.player_state[M.data.seat_num] ~= 1 then
		self.hz_btn.gameObject:SetActive(true)
		self.hz_btn.transform.localPosition = Vector3.New(478, -394, 0)
		return
	end
end
function C:StopHZTime()
	if self.hz_time then
		self.hz_time:Stop()
		self.hz_time = nil
	end
end
function C:UpdateHZUI(b)
	self.hz_not_txt.text = "换桌(" .. self.down_t .. ")"
	if self.down_t <= 0 then
		self.hz_btn.gameObject:SetActive(true)
		self.hz_btn.transform.localPosition = Vector3.New(478, -394, 0)
		self.hz_not_img.gameObject:SetActive(false)
	end
end

function C:HideOperUI()
	self.down_rect.gameObject:SetActive(false)
	self.qx_btn.gameObject:SetActive(false)
	self.qxz_ts_node.gameObject:SetActive(false)
	self.qxz_zd_node.gameObject:SetActive(false)
end


function C:OnReadyClick()
	M.ZBCheck()
end

function C:OnHZClick()
	M.HZCheck()
end

function C:OnFQClick()
	if LHDModel.data.xsyd == 1 then
		LittleTips.Create("新手引导，不能弃牌")
		return
	end
	Network.SendRequest("nor_lhd_nor_surrender", nil, "")
end
function C:OnZAClick()
	local index = M.RandEggIndex()
	if index > 0 then
		self.down_rect.gameObject:SetActive(false)
		self.qx_btn.gameObject:SetActive(true)
		self.qxz_zd_node.gameObject:SetActive(true)
		Event.Brocast("lhd_guide_check")
	else
		print("<color=red>选不到蛋</color>")
		dump(M.data.select_pai_data)
	end
end
function C:OnTSClick()
	if not M.IsCanOperTM() then
		LittleTips.Create("当前没有可透视的蛋")
		return
	end
	if M.data.buf.is_ts_oper then
		M.data.buf.is_ts_oper = false
	else
		M.data.buf.is_ts_oper = true
	end
	self.down_rect.gameObject:SetActive(false)
	self.qx_btn.gameObject:SetActive(true)
	self.qxz_ts_node.gameObject:SetActive(true)
end
function C:OnBSClick()
	if self.is_can_jb then
		self.bs_select_rect.gameObject:SetActive(true)
	else
		print("<color=red>无法加倍</color>")
	end
end
function C:ExitUI()
	self.bs_select_rect.gameObject:SetActive(false)
end
function C:OnXZBSClick(index)
	self.bs_select_rect.gameObject:SetActive(false)
	local cur_c = M.data["stake_round_" .. M.GetCurRound() .. "_rate_ids"]
	M.data.stake_rate = cur_c[index]
	-- self.cur_rate_txt.text = M.data.stake_rate_data[M.data.stake_rate] .. "倍"

	self.down_rect.gameObject:SetActive(false)
	self.qx_btn.gameObject:SetActive(true)
	self.qxz_zd_node.gameObject:SetActive(true)

	-- 刷新当前倍率
	self.panelSelf.center_pre:MyRefresh()
	self.panelSelf.combat_pre:MyRefresh()
end
function C:OnQXClick()
	M.data.buf.is_ts_oper = false
	self.down_rect.gameObject:SetActive(true)
	self.qx_btn.gameObject:SetActive(false)
	self.qxz_zd_node.gameObject:SetActive(false)
	self.qxz_ts_node.gameObject:SetActive(false)
end

