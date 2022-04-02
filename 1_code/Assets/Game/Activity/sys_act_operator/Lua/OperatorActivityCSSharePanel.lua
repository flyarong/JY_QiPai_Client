-- 创建时间:2018-08-20

local basefunc = require "Game.Common.basefunc"

OperatorActivityCSSharePanel = basefunc.class()

local instance

function OperatorActivityCSSharePanel.Create(finishcall)
    if not instance then
        instance = OperatorActivityCSSharePanel.New(finishcall)
    end
    return instance
end

function OperatorActivityCSSharePanel:ctor(finishcall)

	ExtPanel.ExtMsg(self)

    self.finishcall = finishcall
    local parent = GameObject.Find("Canvas/LayerLv5")
    self.gameObject = newObject("OperatorActivityCSSharePanel", parent.transform)
    self.transform = self.gameObject.transform
    local tran = self.transform

    LuaHelper.GeneratingVar(self.transform, self)

    self.back_btn.onClick:AddListener(function ()
        self:OnBackClick()
    end)
	self.hy_btn.onClick:AddListener(function ()
        self:OnHYClick()
    end)
	self.pyq_btn.onClick:AddListener(function ()
        self:OnPYQClick()
    end)
    
    self.camera = GameObject.Find("Canvas/Camera"):GetComponent("Camera")

    self:InitUI()
end
function OperatorActivityCSSharePanel:ShowBack(b)
    if IsEquals(self.hy_btn) then
        self.hy_btn.gameObject:SetActive(b)
    end
    if IsEquals(self.pyq_btn) then
        self.pyq_btn.gameObject:SetActive(b)
    end
    if IsEquals(self.back_btn) then
    	self.back_btn.gameObject:SetActive(b)
    end
end
function OperatorActivityCSSharePanel:InitUI()
	self:ShowBack(false)
    URLImageManager.UpdateHeadImage(MainModel.UserInfo.head_image, self.head_img)
    URLImageManager.UpdateHeadImage(MainModel.UserInfo.head_image, self.ewm_icon_img)

    self.url = ShareModel.GetShareUrl()
    if self.url then
        self:ShowBack(true)
        self:UpdateUI()
    end
end
function OperatorActivityCSSharePanel:UpdateUI()
	self:EWM(self.ewm_img.mainTexture, ewmTools.getEwmDataWithPixel(self.url, self.size))
end

function OperatorActivityCSSharePanel:MyExit()
    Event.Brocast("game_share")
    Event.Brocast("activity_cs_share_close")
    if self.finishcall then
        self.finishcall = nil
    end

    if instance then
        instance = nil
    end
    destroy(self.gameObject)
end
function OperatorActivityCSSharePanel:Close()
    self:MyExit()
end

function OperatorActivityCSSharePanel:OnBackClick()
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	self:Close()
end
function OperatorActivityCSSharePanel:OnHYClick()
	self:WeChatShareImage(false)
end
function OperatorActivityCSSharePanel:OnPYQClick()
	self:WeChatShareImage(true)
end
function OperatorActivityCSSharePanel:WeChatShareImage(isCircleOfFriends)
    local strOff
    if isCircleOfFriends then
        strOff = "true"
    else
        strOff = "false"
    end

	self:ShowBack(false)
    local pos1 = self.node1.position
    local pos2 = self.node2.position
    local s1 = self.camera:WorldToScreenPoint(pos1)
    local s2 = self.camera:WorldToScreenPoint(pos2)
    local x = s1.x
    local y = s1.y
    local w = s2.x - s1.x
    local h = s2.y - s1.y
    local canvas = AddCanvasAndSetSort(self.gameObject, 100)
    panelMgr:MakeCameraImgAsync(x, y, w, h, imageName, function ()
        Destroy(canvas)
        print("<color=red>部分截图完成</color>")
        self:ShowBack(true)
        Event.Brocast("ui_share_end")
        sendcall()
    end,false,false)

end

function OperatorActivityCSSharePanel:EWM(texture, data)    
    if not texture or not data then
        return
    end
    local w = data.width
    local scale = math.floor(self.size/w)
    local py = (self.size-w*scale)/2
    py = math.floor(py)
    print(py .. " " .. w .. " " .. scale)
    local dots = data.data
    for i = 1, w do
        for j = 1, w do
            if dots[(i-1)*w + j] == 1 then
                texture:SetPixel(i-1+py, j-1+py, Color.New(0,0,0,1))
            else
                texture:SetPixel(i-1+py, j-1+py, Color.New(1,1,1,1))
            end
        end
    end
    texture:Apply()
end
