-- 创建时间:2021-08-16
-- Panel:ACT_065_ZNCFKItemBase
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

ACT_065_ZNCFKItemBase = basefunc.class()
local C = ACT_065_ZNCFKItemBase
C.name = "ACT_065_ZNCFKItemBase"
local M = ACT_065_ZNCFKManager

function C.Create(parent,config)
	return C.New(parent,config)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["ExitScene"]=basefunc.handler(self,self.MyExit)
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

function C:ctor(parent,config)
	ExtPanel.ExtMsg(self)
    self.config = config
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
    self.slider = self.Slider.transform:GetComponent("Slider")
    EventTriggerListener.Get(self.get_btn.gameObject).onClick = basefunc.handler(self, self.OnGetClick)
    EventTriggerListener.Get(self.go_btn.gameObject).onClick = basefunc.handler(self, self.OnGoClick)
	self:MyRefresh()
end

function C:MyRefresh()
    self.icon_img.sprite = GetTexture(self.config.award_icon)
    self.num_txt.text = self.config.award_txt
    self.desc_txt.text = self.config.desc_txt
    local data = GameTaskModel.GetTaskDataByID(self.config.task_id)
    dump(data,"<color=yellow><size=15>+++++++右+++++++++</size></color>")
    if data then
        self.process_txt.text = data.now_process .. "/" .. data.need_process
        self.slider.value = data.now_process / data.need_process
        self.get_btn.gameObject:SetActive(data.award_status == 1)
        self.go_btn.gameObject:SetActive(data.award_status == 0)
        self.get_img.gameObject:SetActive(data.award_status == 2)
    end
end

function C:OnGetClick()
    Network.SendRequest("get_task_award", {id = self.config.task_id})
end

function C:OnGoClick()
    if MainModel.myLocation == self.config.gotoUI then
        LittleTips.Create("您当前正在匹配场~")
    else
        GameManager.CommonGotoScence({gotoui = self.config.gotoUI})
    end
end
