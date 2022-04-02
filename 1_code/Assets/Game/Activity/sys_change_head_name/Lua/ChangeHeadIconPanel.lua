-- 创建时间:2018-11-08
local basefunc = require "Game.Common.basefunc"

ChangeHeadIconPanel = basefunc.class()

ChangeHeadIconPanel.name = "ChangeHeadIconPanel"

local instance
function ChangeHeadIconPanel.Create(parent, parm)
    instance = ChangeHeadIconPanel.New(parent, parm)
    return instance
end
function ChangeHeadIconPanel.Exit()
    if instance then
        instance:MyExit()
    end
end

function ChangeHeadIconPanel:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function ChangeHeadIconPanel:MakeLister()
    self.lister = {}
end

function ChangeHeadIconPanel:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function ChangeHeadIconPanel:ctor(parent, parm)
    ExtPanel.ExtMsg(self)
    parent = parent or GameObject.Find("LayerLv5").transform
    local obj = newObject(ChangeHeadIconPanel.name, parent)
    local tran = obj.transform
    self.transform = tran
    self.gameObject = obj
    LuaHelper.GeneratingVar(self.transform, self)
    self:MakeLister()
    self:AddMsgListener()
    self:InitUI()
end

function ChangeHeadIconPanel:MyRefresh()
	
end

function ChangeHeadIconPanel:MyExit()
    self:RemoveListener()
    for i,v in pairs(self.headObj) do
        v:MyExit()
    end
    self.headObj = {}
    destroy(self.gameObject)
    if self.head_id ~= MainModel.UserInfo.img_type then
        Network.SendRequest("set_head_image", {img_type = self.head_id}, "请求数据")
    end
    instance = nil
end

--初始化UI
function ChangeHeadIconPanel:InitUI()
    self.close_btn.onClick:AddListener(function ()
        ChangeHeadIconPanel.Exit()
    end)
    self.headObj = {}
    local hl = {}
    for k,v in pairs(SysChangeHeadNameManager.head_image_server.head_images) do
        hl[#hl + 1] = v
    end
    hl = MathExtend.SortList(hl, "id", true)

    local vip_head_count = 0
    for i,v in pairs(hl) do
        if v.vip_permission == 0 then
            self.headObj[v.id] = ChangeHeadIconItem.Create(self.content_normal,v)
        else
            self.headObj[v.id] = ChangeHeadIconItem.Create(self.content_vip,v)
            vip_head_count = vip_head_count + 1
        end
    end

    if vip_head_count == 0 then
        self.content_vip.gameObject:SetActive(false)
        self.vip_txt.gameObject:SetActive(false)
    end
    
    for i,v in ipairs(hl) do
        self.headObj[v.id]:SetLastIndex()
    end
    ChangeHeadIconPanel.SetChoose(MainModel.UserInfo.img_type)
end

function ChangeHeadIconPanel.SetChoose(id)
    if not instance or not id then return end
    instance.head_id = id
    for i,v in pairs(instance.headObj) do
        if i == id then
            if v:GetState() ~= 1 then
                v:SetState(1)
            end
        else
            if v:GetState() ~= 0 then
                v:SetState(0)
            end
        end
    end
end