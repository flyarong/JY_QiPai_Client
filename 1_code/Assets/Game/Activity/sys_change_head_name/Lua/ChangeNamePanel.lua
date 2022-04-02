-- 创建时间:2018-11-08
local basefunc = require "Game.Common.basefunc"

ChangeNamePanel = basefunc.class()

ChangeNamePanel.name = "ChangeNamePanel"

local instance
function ChangeNamePanel.Create(parent, parm)
    instance = ChangeNamePanel.New(parent, parm)
    return instance
end
function ChangeNamePanel.Exit()
    if instance then
        instance:MyExit()
    end
end

function ChangeNamePanel:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function ChangeNamePanel:MakeLister()
    self.lister = {}
end

function ChangeNamePanel:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function ChangeNamePanel:ctor(parent, parm)
    ExtPanel.ExtMsg(self)
    parent = parent or GameObject.Find("LayerLv5").transform
    local obj = newObject(ChangeNamePanel.name, parent)
    local tran = obj.transform
    self.transform = tran
    self.gameObject = obj
    LuaHelper.GeneratingVar(self.transform, self)
    self:MakeLister()
    self:AddMsgListener()
    self:InitUI()
end

function ChangeNamePanel:MyRefresh()
	
end

function ChangeNamePanel:MyExit()
    self:RemoveListener()
    destroy(self.gameObject)
    instance = nil
end

--初始化UI
function ChangeNamePanel:InitUI()
    self.name_ipf.onValidateInput = function (text, charIndex, addedChar)
        local str = text
        if utf8.len(str) == 16 then
            self.name_ipf.text = string.sub(str,1,15)
            LittleTips.Create("昵称长度不符合规则")
        end
        return addedChar
    end

    self.change_btn.onClick:AddListener(function ()
        --修改邀请码
        local input_str = self.name_ipf.text
        if not input_str or input_str == "" then
            LittleTips.Create("昵称不能为空")
            return
        end
        if input_str == MainModel.UserInfo.name then
            LittleTips.Create("昵称不能重复")
            return
        end
        Network.SendRequest("update_player_name", {name = tostring(input_str)}, "请求数据")
        self:MyExit()
    end)

    self.close_btn.onClick:AddListener(function ()
        ChangeNamePanel.Exit()
    end)
    local b = MainModel.UserInfo.udpate_name_num and MainModel.UserInfo.udpate_name_num > 0
    self.scxiugai.gameObject:SetActive(not b)
    self.xhxiugai.gameObject:SetActive(b)
end