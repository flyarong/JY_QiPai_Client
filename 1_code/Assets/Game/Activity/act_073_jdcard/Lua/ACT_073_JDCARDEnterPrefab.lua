-- 创建时间:2022-03-02
-- Panel:ACT_073_JDCARDEnterPrefab
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
 -- 取消按钮音效
 -- ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
 -- 确认按钮音效
 -- ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
 --]]

local basefunc = require "Game/Common/basefunc"

ACT_073_JDCARDEnterPrefab = basefunc.class()
local C = ACT_073_JDCARDEnterPrefab
C.name = "ACT_073_JDCARDEnterPrefab"
local M = ACT_073_JDCARDManager
function C.Create(parent)
	return C.New(parent)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["ExitScene"] = basefunc.handler(self,self.MyExit)
    self.lister["get_jdcard_taskInfo_msg"] = basefunc.handler(self,self.on_get_jdcard_taskInfo_msg)
    self.lister["model_task_change_msg"] = basefunc.handler(self,self.on_model_task_change_msg)
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

function C:MyClose()
	self:MyExit()
end

function C:ctor(parent)
	ExtPanel.ExtMsg(self)
	local parent = parent or GameObject.Find("Canvas/GUIRoot").transform
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
    self.enter_btn.onClick:AddListener(
        function()
            ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
            self:OnEnterClick()
        end
    )
    M.QueryJDCardInfo()
end

function C:MyRefresh()
    if M.GetHintState({gotoui = M.key}) == ACTIVITY_HINT_STATUS_ENUM.AT_Get then 
        self.LFL.gameObject:SetActive(true)
    else
        self.LFL.gameObject:SetActive(false)
        if PlayerPrefs.GetString(M.key .. MainModel.UserInfo.user_id,0) == os.date("%Y%m%d",os.time()) then 
            self.Red.gameObject:SetActive(false)
        else
            self.Red.gameObject:SetActive(true)
        end 
    end
end

function C:OnEnterClick()
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    PlayerPrefs.SetString(M.key .. MainModel.UserInfo.user_id, os.date("%Y%m%d",os.time()))
    ACT_073_JDCARDPanel.Create()
    self:MyRefresh()
end

function C:on_get_jdcard_taskInfo_msg()
    self:MyRefresh()
end

function C:on_model_task_change_msg(data)
    if M.IsCareTask(data.id) then
        self:MyRefresh()
    end
end