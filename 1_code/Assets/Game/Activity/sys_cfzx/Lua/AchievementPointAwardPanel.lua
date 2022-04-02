-- 创建时间:2019-08-13
--[[ *      ┌─┐       ┌─┐
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

AchievementPointAwardPanel = basefunc.class()
local C = AchievementPointAwardPanel
C.name = "AchievementPointAwardPanel"

function C.Create(parm)
    return C.New(parm)
end

function C:AddMsgListener()
    for proto_name, func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["EnterBackGround"] = basefunc.handler(self, self.onEnterBackGround)
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

function C:ctor(parm)
    self.parm = parm

    if not self.parm or not self.parm.text  then
        print("<color=red>参数不能为空</color>")
        return
    end
    local parent = GameObject.Find("Canvas/LayerLv50").transform
    local obj = newObject(C.name, parent)
    local tran = obj.transform

    self.transform = tran
    LuaHelper.GeneratingVar(self.transform, self)
    self.gameObject = obj
    self.CloseButton = self.transform:Find("CloseButton"):GetComponent("Button")
    self.QQtext = self.transform:Find("Text"):GetComponent("Text")
    self.CloseButton.onClick:AddListener(
    function()
        self:MyExit()
    end
    )
    self.confirm_btn.onClick:AddListener(
    function()
        if self.call then
            self.call()
            self.call = nil
        else
            self:onConfirmClick()
        end
    end
    )
    self.award_img.sprite = GetTexture("com_award_icon_cjd")
    self.award_txt.text = self.parm.text
    self:MakeLister()
    self:AddMsgListener()
    self:InitUI()
end

function C:InitUI()
    self:MyRefresh()
end

function C:MyRefresh()
end

function C:SetButtonTitle(str)
    self.confirm_btn.gameObject.transform:Find("ImgOneMore"):GetComponent("Text").text = str
end

function C:SetButtonCall(call)
    self.call = call
end

function C:onConfirmClick()
	self:MyExit()	
end

function C:onEnterBackGround()
    self:MyExit()
end