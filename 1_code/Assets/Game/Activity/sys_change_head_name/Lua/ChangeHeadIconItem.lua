-- 创建时间:2018-11-08
local basefunc = require "Game.Common.basefunc"

ChangeHeadIconItem = basefunc.class()

ChangeHeadIconItem.name = "ChangeHeadIconItem"

local instance
function ChangeHeadIconItem.Create(parent, parm)
    instance = ChangeHeadIconItem.New(parent, parm)
    return instance
end
function ChangeHeadIconItem.Exit()
    if instance then
        instance:MyExit()
    end
end

function ChangeHeadIconItem:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function ChangeHeadIconItem:MakeLister()
    self.lister = {}
end

function ChangeHeadIconItem:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function ChangeHeadIconItem:ctor(parent, parm)
    ExtPanel.ExtMsg(self)
    self.parm = parm
    local obj = newObject(ChangeHeadIconItem.name, parent)
    local tran = obj.transform
    self.transform = tran
    self.gameObject = obj
    LuaHelper.GeneratingVar(self.transform, self)
    self:MakeLister()
    self:AddMsgListener()
    self:InitUI()
end

function ChangeHeadIconItem:MyRefresh()
	
end

function ChangeHeadIconItem:MyExit()
    self:RemoveListener()
    destroy(self.gameObject)
    instance = nil
end

--初始化UI
function ChangeHeadIconItem:InitUI()
    self.head_img_btn = self.head_img.transform:GetComponent("Button")
    self.head_img_btn.onClick:AddListener(function (  )
        self:OnClickHeadIcon()
    end)
    URLImageManager.UpdateHeadImage(self.parm.url, self.head_img)
end

function ChangeHeadIconItem:OnClickHeadIcon()
    ChangeHeadIconPanel.SetChoose(self.parm.id)
end

function ChangeHeadIconItem:SetLastIndex(  )
    self.transform:SetAsLastSibling()
end

function ChangeHeadIconItem:SetState(st)
    self.state = st
    self.kuang.gameObject:SetActive(self.state == 1)
    self.gou.gameObject:SetActive(self.state == 1)
end

function ChangeHeadIconItem:GetState(st)
    if not self.state then 
        self.state = 0
    end
    return self.state
end