-- 创建时间:2020-07-21

local basefunc = require "Game/Common/basefunc"

KPSHBTCPanel = basefunc.class()
local C = KPSHBTCPanel
C.name = "KPSHBTCPanel"
local M = BY3DKPSHBManager

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
    self.lister["ExitScene"] = basefunc.handler(self, self.ExitScene)
    self.lister["crr_level_state_change_msg"] = basefunc.handler(self,self.on_kpshb_task_lv_msg)
    self.lister["kpshb_model_task_change_msg"] = basefunc.handler(self,self.on_kpshb_model_task_change_msg)
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

function C:OnDestroy()
	self:MyExit()
end
function C:ExitScene()
	self:MyExit()
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
	self.GoGame_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
     	self:MyExit()
    end)
	self.BackButton_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
     	FishingLogic.quit_game()
     	self:MyExit()
    end)

	self:MyRefresh()
end

function C:MyRefresh()
	self.hb_txt.text = StringHelper.ToCash(M.GetTaskMaxNumByLv( M.GetCurTaskLv() ) / 100)

	self:RefreshTaskLv()
	self:RefreshSYP()
end
function C:RefreshSYP()
	self.need_txt.text = M.GetGunRateSurNum( M.GetCurTaskLv() )	
end
function C:RefreshTaskLv()
	local lv = M.GetCurTaskLv()

	if lv == 1 then
		self.flq_img.sprite = GetTexture("kpshb_imgf_ptflq")
	elseif lv == 2 then
		self.flq_img.sprite = GetTexture("kpshb_imgf_gjflq")
	elseif lv == 3 then
		self.flq_img.sprite = GetTexture("kpshb_imgf_cjflq")	
	end
end

function C:on_kpshb_task_lv_msg(data)
	self:RefreshTaskLv()
end

function C:on_kpshb_model_task_change_msg(data)
	self:RefreshSYP()
end