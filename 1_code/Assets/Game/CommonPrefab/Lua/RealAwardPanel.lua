-- 创建时间:2019-08-13
-- Panel:RealAwardPanel
--[[
 *      ┌─┐       ┌─┐
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

RealAwardPanel = basefunc.class()
local C = RealAwardPanel
C.name = "RealAwardPanel"

function C.Create(parm)
	return C.New(parm)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
	self.lister = {}
	self.lister["EnterBackGround"] = basefunc.handler(self, self.onEnterBackGround)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	Event.Brocast("AssetsGetPanelConfirmCallback")
	self:RemoveListener()
	destroy(self.gameObject)
	CommonAwardPanelManager.DelPanel(self)	 
end

function C:ctor(parm)

	ExtPanel.ExtMsg(self)

	self.parm = parm
	if not  self.parm or not self.parm.text or not self.parm.image  then 
		print("<color=red>参数不能为空</color>")
		return 
	end 
 	local parent = GameObject.Find("Canvas/LayerLv50").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	LuaHelper.GeneratingVar(self.transform, self)
	self.gameObject = obj
	self.CloseButton=self.transform:Find("CloseButton"):GetComponent("Button")
	self.QQtext=self.transform:Find("Text"):GetComponent("Text")
	self.CloseButton.onClick:AddListener(
		function ()
			self:CopyQQCode()
			self:MyExit()
		end
	)
	self.confirm_btn.onClick:AddListener(
		function ()
			if self.call then 
				self.call()
				self.call=nil
			else
				self:CopyQQCode()
				self:MyExit()
			end 
		end
	)
	if type(self.parm.image) == "table" and type(self.parm.text) == "table" then 
		self.one_item.gameObject:SetActive(false)
		self.AwardContent.gameObject:SetActive(true)
		for i = 1, #self.parm.image do
			local b = GameObject.Instantiate(self.more_item,self.AwardContent)
			b.gameObject:SetActive(true)
			local temp_ui ={}
			LuaHelper.GeneratingVar(b.transform, temp_ui)
			temp_ui.more_award_img.sprite = GetTexture(self.parm.image[i])
			temp_ui.more_award_txt.text = self.parm.text[i]
		end		
	else
		self.one_item.gameObject:SetActive(true)
		self.AwardContent.gameObject:SetActive(false)
		self.award_img.sprite=GetTexture(self.parm.image)
		self.award_txt.text=self.parm.text 
	end 
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	CommonAwardPanelManager.AddPanel(self)
end

function C:InitUI()
	self.QQtext.text="请联系QQ：4008882620 领取奖励"
	self:MyRefresh()
end

function C:MyRefresh()
end

function C:SetButtonTitle(str)
	self.confirm_btn.gameObject.transform:Find("ImgOneMore"):GetComponent("Text").text=str
end

function C:SetButtonCall(call)
	self.call = call 
end

function C:CopyQQCode()
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	--LittleTips.Create("已复制QQ号请前往QQ进行添加")
	if self.parm.qq then 
    	UniClipboard.SetText(self.parm.qq) -- qq也可以是微信
	else
		UniClipboard.SetText("4008882620")
	end 
end

function C:SetQQtext(text)
	self.QQtext.text = text
end

function C:onEnterBackGround()
	--self:MyExit()
end