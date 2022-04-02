-- 创建时间:2019-03-13
-- Panel:ShowMeTheMoney
local basefunc = require "Game/Common/basefunc"

ShowMeTheMoney = basefunc.class()
local C = ShowMeTheMoney
C.name = "ShowMeTheMoney"

local instance
function C.Create(data, parent)
	if not instance then
		instance = C.New(data, parent)
	else
		instance:MyRefresh()
	end
	return instance
end
function C.Close()
	if instance then
		instance:MyExit()
	end
	instance = nil
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	if instance then
		self:RemoveListener()
		GameObject.Destroy(self.transform.gameObject)
		instance = nil
	end
end

function C:ctor(data, parent)
	if not parent then
		parent = GameObject.Find("Canvas/LayerLv4").transform
	end

	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)

	self:MakeLister()
	self:AddMsgListener()
	self:InitUI(data)
end

function C:InitUI(data)
	dump(data, "<color=green>--->>>wyhb data:</color>")
	if data then
		self.container = self.transform:Find("ScrollView/Viewport/Content")
		self.barTmpl = self.transform:Find("bar")
		for i, v in ipairs(data) do
			if i ~= 1 then
				self.icon_img.sprite = GetTexture(v.icon)
				self.desc_txt.text = v.desc or ""
				self.tip_txt.text = v.tip or ""
				local bar = GameObject.Instantiate(self.barTmpl, self.container)
				local gotoBtn = bar.transform:Find("goto_btn")
				bar.gameObject:SetActive(true)
				if v.goto_ui and #v.goto_ui > 0 then
					EventTriggerListener.Get(gotoBtn.gameObject).onClick = function ()
						ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
						GameManager.GotoUI({gotoui=v.goto_ui[1], goto_scene_parm=v.goto_ui[2]})
						self:MyExit()
					end
				else
					bar.transform:Find("goto_btn").gameObject:SetActive(false)
				end
			end
		end
	end

	EventTriggerListener.Get(self.close_btn.gameObject).onClick = basefunc.handler(self, self.OnCloseClicked)
	DOTweenManager.OpenPopupUIAnim(self.transform)
end

function C:OnCloseClicked()
	ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
	self:MyExit()
end

function C:MyRefresh()
end
