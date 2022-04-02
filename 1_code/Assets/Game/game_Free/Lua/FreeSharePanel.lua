-- 创建时间:2018-10-18
local basefunc = require "Game.Common.basefunc"

FreeSharePanel = basefunc.class()

function FreeSharePanel.Create(shareType, parm, finishcall)
    return FreeSharePanel.New(shareType, parm, finishcall)
end

function FreeSharePanel:ctor(shareType, parm, finishcall)

	ExtPanel.ExtMsg(self)

    self.parm = parm
    self.shareType = shareType
    self.finishcall = finishcall

    self.parent = GameObject.Find("Canvas/LayerLv4")
    self.gameObject = newObject("FreeSharePanel", self.parent.transform)
    self.transform = self.gameObject.transform
    LuaHelper.GeneratingVar(self.gameObject.transform,  self)

    self.wx_btn.onClick:AddListener(function ()
        self:WeChatShareImage(false)
        self:OnBackClick()
    end)

    self.pyq_btn.onClick:AddListener(function ()
        self:WeChatShareImage(true)
        self:OnBackClick()
    end)
    
    self.close_btn.onClick:AddListener(function ()
        self:OnBackClick()
    end)

    self:InitUI()
    
    DOTweenManager.OpenPopupUIAnim(self.transform)
end

function FreeSharePanel:InitUI()

end

function FreeSharePanel:MyExit()
    destroy(self.gameObject)
end

function FreeSharePanel:OnBackClick()
    self:MyExit()
end

function FreeSharePanel:WeChatShareImage(isCircleOfFriends)
    local share_cfg = basefunc.deepcopy(share_link_config.img_hall)
    share_cfg.isCircleOfFriends = isCircleOfFriends
    GameManager.GotoUI({gotoui = "sys_fx",goto_scene_parm = "image",share_cfg = share_cfg})
end
