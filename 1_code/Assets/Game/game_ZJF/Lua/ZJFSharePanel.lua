-- 创建时间:2018-10-18
local basefunc = require "Game.Common.basefunc"

ZJFSharePanel = basefunc.class()

function ZJFSharePanel.Create(shareType, parm, finishcall)
    return ZJFSharePanel.New(shareType, parm, finishcall)
end

function ZJFSharePanel:ctor(shareType, parm, finishcall)
    self.parm = parm
    self.shareType = shareType
    self.finishcall = finishcall

    self.parent = GameObject.Find("Canvas/LayerLv4")
    self.gameObject = newObject("ZJFSharePanel", self.parent.transform)
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

function ZJFSharePanel:InitUI()

end

function ZJFSharePanel:OnBackClick()
    GameObject.Destroy(self.gameObject)
end

function ZJFSharePanel:WeChatShareImage(isCircleOfFriends)
    local share_cfg = basefunc.deepcopy(share_link_config.img_hall)
    share_cfg.isCircleOfFriends = isCircleOfFriends
    GameManager.GotoUI({gotoui = "sys_fx",goto_scene_parm = "image",share_cfg = share_cfg})
end
