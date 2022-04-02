-- 创建时间:2018-07-16

local basefunc = require "Game.Common.basefunc"

ShareImage = basefunc.class()
local M = ShareImage
M.name = "ShareImage"

local lister

function M:AddLister()
	lister={}
	lister["screen_shot_begin"] = basefunc.handler(self, self.screen_shot_begin)
	lister["screen_shot_end"] = basefunc.handler(self, self.screen_shot_end)
	lister["qr_code_apply_success"] = basefunc.handler(self, self.qr_code_apply_success)
	lister["qr_code_apply_fial"] = basefunc.handler(self, self.qr_code_apply_fial)
	for proto_name,func in pairs(lister or {}) do
        Event.AddListener(proto_name, func)
    end
end

function M:RemoveLister()
    for msg,cbk in pairs(lister or {}) do
        Event.RemoveListener(msg, cbk)
    end
    lister=nil
end

function M.Create(share_cfg)
    return M.New(share_cfg)
end

function M:ctor(share_cfg)
    self.share_cfg = share_cfg
    local parent = GameObject.Find("Canvas/LayerLv5").transform
    local obj = newObject(M.name, parent)
    local tran = obj.transform
    self.gameObject = obj
    self.transform = obj.transform
    LuaHelper.GeneratingVar(self.transform,self)
    self:AddLister()
    self:Init()
    ShareHelper.RefreshQRCode(self.qr_code_img,self.share_cfg)
    ShareHelper.RefreshImage(self.head_img,self.icon_img,self.invite_txt,self.share_img_id)
    if gameMgr:getMarketPlatform() == "wqp" then
        self.icon_img.transform.localPosition = Vector3.New(-215, 448, 0)
        self.icon_img.transform.localScale = Vector3.New( 0.35, 0.35, 1)
    end
    HandleLoadChannelLua("ShareImage", self)
end

function M:Init()
    self.share_img_id = ShareHelper.RefreshShareImage(self.share_img,self.share_cfg)
    local share_img_rect = self.share_img.transform:GetComponent("RectTransform")
    local width = Screen.width
    local height = Screen.height
    if width / height < 1 then
        width,height = height,width
    end
    local wh = MainModel.GetScene_MatchWidthOrHeight(width, height)
    local c = 1
    if wh == 1 then
        c = Screen.height / 1080
    else
        c = Screen.width / 1920
    end
    local w = 640 * c
    local h = 1020 * c
    if IsEquals(share_img_rect) then
        w = share_img_rect.sizeDelta.x * c
        h = share_img_rect.sizeDelta.y * c
    end

    self.rect = UnityEngine.Rect.New(Screen.width / 2 - w / 2,Screen.height / 2 - h / 2,w,h)    
    self.share_btn.onClick:AddListener(function()
        ShareHelper.ScreenShot(nil,self.rect)
    end)
    self.close_btn.onClick:AddListener(function()
        self:Exit()
    end)
    Event.Brocast("share_image_init")
end

function M:Exit()
    self:RemoveLister()
    self.share_btn.onClick:RemoveAllListeners()
    self.close_btn.onClick:RemoveAllListeners()
    destroy(self.gameObject)
    Event.Brocast("share_image_exit")
end

function M:screen_shot_end()
    RemoveCanvas(self.gameObject)
    self:Exit()
end

function M:screen_shot_begin()
    AddCanvasAndSetSort(self.gameObject, 100)
end

--生成二维码失败
function M:qr_code_apply_fial()
    LittleTips.Create("生成二维码失败，请重新分享")
    self:Exit()
end

--生成二维码成功
function M:qr_code_apply_success()
    if not self.rect then
        --分享失败
        LittleTips.Create("生成二维码失败，请重新分享")
        self:Exit()
        return
    end
    ShareHelper.ScreenShot(nil,self.rect)
end