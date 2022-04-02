local basefunc = require "Game.Common.basefunc"
MatchHallHintQYSPanel = basefunc.class()
local M = MatchHallHintQYSPanel

local instance
function M.Create(cfg, parent)
    if instance then
        M.Close()
    end
    instance = M.New(cfg, parent)
    return instance
end

-- isOpenType 打开方式 normal正常打开 其余是货币不足打开
function M:ctor(cfg, parent)
	ExtPanel.ExtMsg(self)
    self.cfg = cfg
    self.parent = parent or GameObject.Find("Canvas/LayerLv3")
    self.gameObject = newObject("MatchHallHintQYSPanel", self.parent.transform)
    self.transform = self.gameObject.transform
    LuaHelper.GeneratingVar(self.transform, self)
    self:Init()
    DOTweenManager.OpenPopupUIAnim(self.transform)
end


function M:MyExit()
    if instance then
        destroy(self.gameObject)
        instance = nil
    end	 
end

-- 关闭
function MatchHallHintQYSPanel.Close()
    if instance then
        instance:MyExit()
    end
end

function M:Init()
    EventTriggerListener.Get(self.close_btn.gameObject).onClick = basefunc.handler(self, self.OnHintPayCloseClick)
    EventTriggerListener.Get(self.qys_share_btn.gameObject).onClick = basefunc.handler(self, self.OnHintPayShareClick)
    EventTriggerListener.Get(self.qys_pay_btn.gameObject).onClick = basefunc.handler(self, self.OnHintPayGotoClick)
end

function M:OnHintPayCloseClick()
    self:MyExit()
end

function M:OnHintPayShareClick()
    local share_cfg = basefunc.deepcopy(share_link_config.img_qys_share)
    GameManager.GotoUI({gotoui = "sys_fx",goto_scene_parm = "image",share_cfg = share_cfg})
    self:MyExit()
end

function M:OnHintPayGotoClick()
    ComMatchReviveBuyPanel.CheckBuyTicket(self.cfg)
    self:MyExit()
end