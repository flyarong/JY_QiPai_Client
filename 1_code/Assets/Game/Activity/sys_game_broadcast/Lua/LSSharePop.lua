-- 创建时间:2019-01-04

local basefunc = require "Game/Common/basefunc"

LSSharePop = basefunc.class()

LSSharePop.name = "LSSharePop"


local instance
function LSSharePop.Create(descTxt, winCount)
	if not instance then
		instance = LSSharePop.New(descTxt, winCount)
	end
	return instance
end

--启动事件--
function LSSharePop:ctor(descTxt, winCount)
	local parent = GameObject.Find("Canvas/LayerLv5").transform
	self.gameObject = newObject("LSSharePop", parent)
	LuaHelper.GeneratingVar(self.gameObject.transform, self)

	local isJingBi = string.find(descTxt, "鲸币") and true or false
	self.coin_img.gameObject:SetActive(isJingBi)
	self.cash_img.gameObject:SetActive(not isJingBi)
    self.desc_txt.text = descTxt
    self.WinCount_txt.text = winCount
    self.node1 = self.gameObject.transform:Find("node1")
    self.node2 = self.gameObject.transform:Find("node2")
    self.camera = GameObject.Find("Canvas/Camera"):GetComponent("Camera")

	EventTriggerListener.Get(self.back_btn.gameObject).onClick = basefunc.handler(self, self.OnShareBackBtnClicked)
	EventTriggerListener.Get(self.share2Friends_btn.gameObject).onClick = basefunc.handler(self, self.OnShare2FriendsBtnClicked)
	EventTriggerListener.Get(self.share2Circle_btn.gameObject).onClick = basefunc.handler(self, self.OnShare2CircleBtnClicked)

    -- 屏蔽分享朋友圈
    self.share2Circle_btn.gameObject:SetActive(false)
    self.share2Friends_btn.transform.localPosition = Vector3.New(0, -450, 0)

    self.share_cfg = basefunc.deepcopy(share_link_config.img_free_ddz_ls)
	self:Init()
end

function LSSharePop:Init()
	ShareHelper.RefreshQRCode(self.qr_code_img,self.share_cfg)
    ShareHelper.RefreshImage(self.head_img,self.icon_img,self.invite_txt)
end

function LSSharePop:SetButtonVisible(visible)
	self.back_btn.gameObject:SetActive(visible)
	self.share2Friends_btn.gameObject:SetActive(visible)
	-- self.share2Circle_btn.gameObject:SetActive(visible)
end

function LSSharePop:WeChatShareImage(isCircleOfFriends)
    self.share_cfg.isCircleOfFriends = isCircleOfFriends
    GameManager.GotoUI({gotoui = "sys_fx",goto_scene_parm = "image",share_cfg = self.share_cfg})
end

function LSSharePop:OnShareBackBtnClicked()
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	self:Close()
end

function LSSharePop:OnShare2FriendsBtnClicked()
	self:WeChatShareImage(false)
end

function LSSharePop:OnShare2CircleBtnClicked()
	self:WeChatShareImage(true)
end

function LSSharePop:Close()
	instance = nil
	GameObject.Destroy(self.gameObject)
end
