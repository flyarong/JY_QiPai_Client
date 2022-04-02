local basefunc = require "Game/Common/basefunc"

FKSSEEnterPrefab = basefunc.class()
local C = FKSSEEnterPrefab
C.name = "FKSSEEnterPrefab"
C.key = "act_fksse" 
function C.Create(parent)
    return C.New(parent)
end

function C:AddMsgListener()
    for proto_name, func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
end

function C:RemoveListener()
    for proto_name, func in pairs(self.lister) do
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


function C:ctor(parent)
    local obj = newObject("fksse_btn", parent)
    local tran = obj.transform
    self.transform = tran
    self.gameObject = obj
    LuaHelper.GeneratingVar(self.transform, self)

    self:MakeLister()
    self:AddMsgListener()
    self:InitUI()
end

function C:InitUI()
    self:MyRefresh()
    self.transform:GetComponent("Button").onClick:AddListener(function()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        self:OnEnterClick()
    end)
end

function C:OnEnterClick()
    ActivityFKSSEPanel.Create()
end

function C:MyRefresh()
    local s = GameManager.GetHintState({gotoui = C.key})
    if s == ACTIVITY_HINT_STATUS_ENUM.AT_Red then 
        self.LFL.gameObject:SetActive(false)
        self.Red.gameObject:SetActive(true)   
    elseif s == ACTIVITY_HINT_STATUS_ENUM.AT_Get then 
        self.LFL.gameObject:SetActive(true)
        self.Red.gameObject:SetActive(false)
    else    
        self.LFL.gameObject:SetActive(false)
        self.Red.gameObject:SetActive(false)
    end 
end