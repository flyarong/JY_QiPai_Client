-- 创建时间:2019-09-16
-- Panel:WelComeToSHPanel
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

WelComeToTGCJPanel = basefunc.class()
local C = WelComeToTGCJPanel
C.name = "WelComeToTGCJPanel"

function C.Create(callback)
    return C.New(callback)
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
    if self.callback then
        self.callback()
    end
    destroy(self.gameObject)

	 
end

function C:ctor(callback)

	ExtPanel.ExtMsg(self)

    local parent = GameObject.Find("Canvas/LayerLv5").transform
    local obj = newObject(C.name, parent)
    local tran = obj.transform
    self.transform = tran
    self.gameObject = obj
    self.callback = callback
    self.gameObject:SetActive(false)
    LuaHelper.GeneratingVar(self.transform, self)
    self:MakeLister()
    self:AddMsgListener()
    self:InitUI()
    self:OnButtonClick()

    if PlayerPrefs.GetInt("WelComeToTGCJPanel" .. "once" .. MainModel.UserInfo.user_id, 0) == 1 then
        print("<color=red>打开过页面</color>")
        self:MyExit()
        return    
    end
    self.gameObject:SetActive(true)
end

function C:InitUI()
    self:MyRefresh()
    self.GoButton = self.transform:Find("1/GoButton"):GetComponent("Button")
    self.panel1 = self.transform:Find("1")
    self.NameText = self.panel1.transform:Find("NameText"):GetComponent("Text")
    self.NameText.text = "亲爱的【"..MainModel.UserInfo.name.."】:"
    self:MyRefresh()
    self.panel1.gameObject:SetActive(true)
end

function C:OnButtonClick()
    self.GoButton.onClick:AddListener(
    function()
		AchievementTGCenterPanel.Create()
    	PlayerPrefs.SetInt("WelComeToTGCJPanel" .. "once" .. MainModel.UserInfo.user_id, 1)
        self.callback = nil    
        self:MyExit()
    end
    )
end

function C:MyRefresh()
end