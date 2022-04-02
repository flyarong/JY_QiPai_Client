-- 创建时间:2020-02-24
-- Panel:Fishing3DActXYCBOpenPrefab
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

Fishing3DActXYCBOpenPrefab = basefunc.class()
local C = Fishing3DActXYCBOpenPrefab
C.name = "Fishing3DActXYCBOpenPrefab"
local M = BY3DActXYCBManager

function C.Create(data)
	return C.New(data)
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
	self:StopTime()
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:ctor(data)
	self.data = data
	local da = M.m_data.caibei_all_info[self.data.index]
	self.cfg = M.GetIDConfig(da.type)

	local parent = GameObject.Find("Canvas/LayerLv3").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	self.back_btn.onClick:AddListener(function()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnBackClick()
    end)
	self.open_btn.onClick:AddListener(function()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnOpenClick()
    end)
    self.qz_open_btn.onClick:AddListener(function()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnOpenClick()
    end)

    self.hb_icon_img.sprite = GetTexture(self.cfg.icon)
    
	self:MyRefresh()
end

function C:MyRefresh()
	local da = M.m_data.caibei_all_info[self.data.index]
	if da.state == 1 then
		self.open_btn.gameObject:SetActive(true)
		self.open_sj_txt.gameObject:SetActive(true)
		self.qz_open_btn.gameObject:SetActive(false)
		self.open_djs_txt.gameObject:SetActive(false)

		self.open_sj_txt.text = StringHelper.formatTimeDHMS4(self.cfg.cd)
	elseif da.state == 2 then
		self.open_btn.gameObject:SetActive(false)
		self.open_sj_txt.gameObject:SetActive(false)
		self.qz_open_btn.gameObject:SetActive(true)
		self.open_djs_txt.gameObject:SetActive(true)
		self.down_t = da.start_time + self.cfg.cd - os.time()
		self.open_time = Timer.New(function ()
			self.down_t = self.down_t - 1
			if self.down_t <= 0 then
				self:StopTime()
				self:MyExit()
			end
			self:UpdateUI(true)
		end, 1, -1)
		self.open_time:Start()
		self:UpdateUI()
	end
end
function C:StopTime()
	if self.open_time then
		self.open_time:Stop()
		self.open_time = nil
	end
end
function C:UpdateUI(b)
	self.open_djs_txt.text = StringHelper.formatTimeDHMS3(self.down_t)
	if self.down_t <= 0 then
		self.open_djs_txt.gameObject:SetActive(false)
	else
		local mm = math.ceil(self.down_t / self.cfg.close_cd_hf[2])
		mm = mm * self.cfg.close_cd_hf[1]
		self.qzkq_jb_txt.text = "x" .. StringHelper.ToCash(mm)
	end
end

function C:OnBackClick()
	self:MyExit()
end
function C:OnOpenClick()
	local da = M.m_data.caibei_all_info[self.data.index]
	if da.state == 1 then
		M.OpenXYCB(self.data.index)
	else
		local mm = math.ceil(self.down_t / self.cfg.close_cd_hf[2])
		mm = mm * self.cfg.close_cd_hf[1]
		if mm <= MainModel.UserInfo.jing_bi then
			M.FinishXYCB(self.data.index)
		else
			print("<color=red>钱不够</color>")
			PayPanel.Create(GOODS_TYPE.jing_bi)
		end
	end
	self:MyExit()
end


