-- 创建时间:2018-11-06
-- 结算界面荣誉改变

local basefunc = require "Game.Common.basefunc"

GameTaskBtnPrefab = basefunc.class()

GameTaskBtnPrefab.name = "GameTaskBtnPrefab"

-- oldval chgval
local instance
function GameTaskBtnPrefab.Create(parent)
    if GameGlobalOnOff.Task == false then
        return
    end
	if not instance then
        instance = GameTaskBtnPrefab.New(parent)
    end
    return instance
end
function GameTaskBtnPrefab.Close()
    if instance then
        instance:MyExit()
    end
    instance = nil
end

function GameTaskBtnPrefab:AddMsgListener()
    for proto_name, func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function GameTaskBtnPrefab:MakeLister()
    self.lister = {}
    self.lister["model_task_finish_msg"] = basefunc.handler(self, self.on_task_finish_msg)
end

function GameTaskBtnPrefab:RemoveListener()
    for proto_name, func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function GameTaskBtnPrefab:MyExit()
    self:RemoveListener()
    self.finish_data = nil
end

function GameTaskBtnPrefab:MyRefresh()
    self.finish_data = GameTaskModel.GetFinishTaskDataToType()
    if self.finish_data then
        local config = GameTaskModel.GetConfigDataToID(self.finish_data[1].id)
        self.task_red.gameObject:SetActive(true)
        self.finish_hint_btn.gameObject:SetActive(true)
        self.finish_task_txt.text = config.name
    else
        self.task_red.gameObject:SetActive(false)
        self.finish_hint_btn.gameObject:SetActive(false)
    end
end

function GameTaskBtnPrefab:ctor(parent)
    if not parent then
        parent = GameObject.Find("Canvas/LayerLv4").transform
    end
    self:MakeLister()
    self:AddMsgListener()
    local obj = newObject(GameTaskBtnPrefab.name, parent)
    local tran = obj.transform
    self.transform = tran
    self.gameObject = obj
    LuaHelper.GeneratingVar(self.transform, self)
    self:InitUI()
    self:MyRefresh()
end

function GameTaskBtnPrefab:InitUI()
    EventTriggerListener.Get(self.task_btn.gameObject).onClick = basefunc.handler(self, self.OnClickTask)
    EventTriggerListener.Get(self.finish_hint_btn.gameObject).onClick = basefunc.handler(self, self.OnClickFinish)
end

function GameTaskBtnPrefab:on_task_finish_msg()
    self:MyRefresh()
end

-- Btn
function GameTaskBtnPrefab:OnClickTask()
    self.finish_hint_btn.gameObject:SetActive(false)
    if self.finish_data then
        local data = self.finish_data[1]
        GameTaskPanel.Create(data.task_type)
    else
        GameTaskPanel.Create()
    end
end

function GameTaskBtnPrefab:OnClickFinish()
    self.finish_hint_btn.gameObject:SetActive(false)
	if self.finish_data then
        local data = self.finish_data[1]
        GameTaskPanel.Create(data.task_type)
    else
        GameTaskPanel.Create()
    end
end
