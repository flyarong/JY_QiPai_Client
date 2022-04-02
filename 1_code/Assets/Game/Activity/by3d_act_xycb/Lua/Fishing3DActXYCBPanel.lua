-- 创建时间:2020-02-19
-- Panel:Fishing3DActXYCBPanel
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

Fishing3DActXYCBPanel = basefunc.class()
local C = Fishing3DActXYCBPanel
C.name = "Fishing3DActXYCBPanel"
local M = BY3DActXYCBManager

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
    self.lister["model_by3d_act_xycb_all_info"] = basefunc.handler(self, self.on_all_info_msg)
    self.lister["model_nor_fishing_3d_free_caibei_obtain"] = basefunc.handler(self, self.on_model_free_caibei_obtain)
    self.lister["model_nor_fishing_3d_caibei_complete"] = basefunc.handler(self, self.on_model_nor_fishing_3d_caibei_complete)

    self.lister["model_nor_fishing_3d_caibei_start"] = basefunc.handler(self, self.MyRefresh)
    self.lister["model_nor_fishing_3d_caibei_complete_use_jingbi"] = basefunc.handler(self, self.MyRefresh)
    self.lister["model_nor_fishing_3d_caibei_complete"] = basefunc.handler(self, self.MyRefresh)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	self:StopMFTime()
    self:CloseBK()
	self:RemoveListener()
	destroy(self.gameObject)

	 
end

function C:ctor()

	ExtPanel.ExtMsg(self)

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
	self.help_btn.onClick:AddListener(function()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnHelpClick()
    end)
	self.mflq_btn.onClick:AddListener(function()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnMFLQClick()
    end)

    self:CloseBK()
    for i = 1, 5 do
    	local pre = Fishing3DActBKPrefab.Create(self, self["bk_node"..i], i)
    	self.bk_list[#self.bk_list + 1] = pre
    end

    M.QueryAllInfo()
end
function C:on_all_info_msg()
	dump(data, "<color=red>on_all_info_msg</color>")
	self:MyRefresh()
end
function C:on_model_free_caibei_obtain(data)
	self:MyRefresh()
end
function C:on_model_nor_fishing_3d_caibei_complete(data)
	self:MyRefresh()
end

function C:MyRefresh()
	self.max_open_bk_num = M.GetOpeningCBMax()
	self.cur_open_bk_num = M.GetOpeningCBNum()
	self.hint_cb_txt.text = self.cur_open_bk_num .. "/" .. self.max_open_bk_num

	for i = 1, 5 do
		self.bk_list[i]:MyRefresh()
	end
	self:RefreshMF()
end
function C:RefreshMF()
	self:StopMFTime()
	local mf_data = M.m_data.free_caibei_obtain_info
	if mf_data and mf_data.obtain_num and mf_data.obtain_num < M.UIConfig.free_get_max_num then
		self.mflq_rect.gameObject:SetActive(true)
		local cd = M.GetFreeGetCD()
		dump(cd, "cd")
		if cd > 0 then
			self.mflq_btn.gameObject:SetActive(false)
			self.mflq_not.gameObject:SetActive(true)

			self.down_t = cd
			self.mflq_time = Timer.New(function ()
				self.down_t = self.down_t - 1
				if self.down_t <= 0 then
					self:StopMFTime()
				end
				self:UpdateMFUI(true)
			end, 1, -1)
			self.mflq_time:Start()
			self:UpdateMFUI()
		else
			self.mflq_btn.gameObject:SetActive(true)
			self.mflq_not.gameObject:SetActive(false)
		end
	else
		self.mflq_rect.gameObject:SetActive(false)
	end	
end
function C:StopMFTime()
	if self.mflq_time then
		self.mflq_time:Stop()
		self.mflq_time = nil
	end
end
function C:UpdateMFUI(b)
	self.lq_djs_txt.text = StringHelper.formatTimeDHMS(self.down_t)
	if self.down_t <= 0 then
		self.mflq_btn.gameObject:SetActive(true)
		self.mflq_not.gameObject:SetActive(false)
	end
end


function C:CloseBK()
	if self.bk_list then
		for k,v in ipairs(self.bk_list) do
			v:MyExit()
		end
	end
	self.bk_list = {}
end
function C:OnBackClick()
	self:MyExit()
end
function C:OnHelpClick()
	Fishing3DActXYCBHelpPanel.Create()
end
function C:OnMFLQClick()
	local mf_dd = M.m_data.free_caibei_obtain_info
	local cb_dd = M.m_data.caibei_all_info
	if mf_dd.obtain_num >= M.UIConfig.free_get_max_num then
		LittleTips.Create("今日已领完")
	else
		local cd = M.GetFreeGetCD()
		if cd > 0 then
			LittleTips.Create("领取时间还没有到")
		else
			if M.GetCurCBNum() >= M.GetCBMaxNum() then
				LittleTips.Create("拥有彩贝数量已达上限")
			else
				Network.SendRequest("nor_fishing_3d_free_caibei_obtain", nil, "领取")
			end
		end
	end
end

function C:OnBKClick(index)
	local bk_data = M.m_data.caibei_all_info[index]
	if bk_data then
		if bk_data.state == 1 then
			Fishing3DActXYCBOpenPrefab.Create({index=index})
		elseif bk_data.state == 2 then
			local cfg = M.GetIDConfig(bk_data.type)
			local tt = bk_data.start_time + cfg.cd - os.time()
			if tt > 0 then
				Fishing3DActXYCBOpenPrefab.Create({index=index})
			else
				M.AutoFinishXYCB(index)
			end
		end
	else
		LittleTips.Create("未解锁")
	end
end