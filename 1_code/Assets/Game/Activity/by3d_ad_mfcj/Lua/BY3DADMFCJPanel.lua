-- 创建时间:2020-08-03
-- Panel:BY3DADMFCJPanel
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

BY3DADMFCJPanel = basefunc.class()
local C = BY3DADMFCJPanel
C.name = "BY3DADMFCJPanel"
local M = BY3DADMFCJManager

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
    self.lister["ExitScene"] = basefunc.handler(self,self.MyExit)
    self.lister["by3d_ad_mfcj_query_ad_free_lottery"] = basefunc.handler(self,self.by3d_ad_mfcj_query_ad_free_lottery)
    self.lister["by3d_ad_mfcj_use_ad_free_lottery"] = basefunc.handler(self,self.by3d_ad_mfcj_use_ad_free_lottery)
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

function C:OnDestroy()
	self:MyExit()
end

function C:MyClose()
	self:MyExit()
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
end

function C:InitUI()

	-- local isActiveLS = true
	-- local _permission_key = "drt_ignore_watch_ad_4"  --连胜奖励的权限
	-- local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key=_permission_key, is_on_hint = true}, "CheckCondition")
	-- if a and b then
	-- 	isActiveLS = false
	-- end
	-- dump(isActiveLS , "<color=red>isActiveLS</color>")


	

	dump(SYSQXManager.CheckCondition({_permission_key="need_watch_ad", is_on_hint=true}) , "<color=red>need_watch_ad</color>")

	self.back_btn.onClick:AddListener(function ()
    	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:MyExit()
	end)
	self.ad_btn.onClick:AddListener(function ()
    	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnADClick()
	end)
	M.QueryInfoData()
	self:MyRefresh()
end

function C:MyRefresh()
	self.count =  M.GetNum()
	self.time_num = M.GetCDTime()
	if self.count > 0 then
		if self.time_num > 0 then
			self.ad_no.gameObject:SetActive(true)
			self.ad_btn.gameObject:SetActive(false)
			self:StartTime()
		else
			self.ad_no.gameObject:SetActive(false)
			self.ad_btn.gameObject:SetActive(true)
		end
	else
		self.ad_no.gameObject:SetActive(true)
		self.ad_btn.gameObject:SetActive(false)
		self.down_txt.text = "请明日再来"
	end
	self.hint2_txt.text = string.format("还可抽%s次", self.count)
end

function C:by3d_ad_mfcj_query_ad_free_lottery()
	self:MyRefresh()
end
function C:by3d_ad_mfcj_use_ad_free_lottery()
	self:MyRefresh()
end

function C:OnADClick()
	AdvertisingManager.RandPlay("mfcj", nil, function ()
		Network.SendRequest("use_ad_free_lottery", nil, "")
	end)
end

function C:StartTime()
	self:StopTime()
	self.update_time = Timer.New(function ()
		self:UpdateUI(true)
	end, 1, -1)
	self.update_time:Start()
	self:UpdateUI()
end

function C:StopTime()
	if self.update_time then
		self.update_time:Stop()
		self.update_time = nil
	end
end
function C:UpdateUI(b)
	if b then
		self.time_num = self.time_num - 1
	end

	if self.time_num <= 0 then
		self:StopTime()
		self:MyRefresh()
		return
	end

	local mm = math.floor(self.time_num / 60)
	local ss = self.time_num % 60
    self.down_txt.text = string.format("%02d", mm) .. ":" .. string.format("%02d", ss)
end
