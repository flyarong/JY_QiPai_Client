-- 创建时间:2020-09-25
-- Panel:LWZBCSDJTJPanel
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

LWZBCSDJTJPanel = basefunc.class()
local C = LWZBCSDJTJPanel
C.name = "LWZBCSDJTJPanel"
local M = LWZBModel

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
    self.lister["EnterBackGround"] = basefunc.handler(self,self.on_background_msg)--切到后台
    self.lister["lwzb_force_exit_qlcf_or_settel_msg"] = basefunc.handler(self,self.on_lwzb_force_exit_qlcf_or_settel_msg)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	self:StopExitTimer()
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
	local parent = GameObject.Find("Canvas/LayerLv5").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	ExtendSoundManager.PlaySound(audio_config.lwzb.bgm_lwzb_cs_huojiang.audio_name)
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	self:AutoExitTimer(true)
	local data = M.GetAllInfo()
	dump(data,"<color=red>7777777777777777777</color>")
	local big_data = data.settle_data.qlcf_big_award
	self.award_txt.text = big_data.award_value
	URLImageManager.UpdateHeadImage(big_data.player_info.head_image, self.head_img)
	self.name_txt.text = big_data.player_info.player_name
	self:MyRefresh()
end

function C:MyRefresh()
	
end

function C:AutoExitTimer(b)
	self:StopExitTimer()
	if b then
		self.auto_timer = Timer.New(function ()
			if not LWZBManager.CheckMoneyIsEnoughOnSettle() then
				M.CreateHint()
			end
			--self:MyExit()
		end,3,1)
		self.auto_timer:Start()
	end
end

function C:StopExitTimer()
	if self.auto_timer then
		self.auto_timer:Stop()
		self.auto_timer = nil
	end
end

function C:on_background_msg()
	--self:MyExit()
end


function C:on_lwzb_force_exit_qlcf_or_settel_msg()
	self:MyExit()
end