-- 创建时间:2018-06-28

local basefunc = require "Game.Common.basefunc"

ServicePrefab = basefunc.class()

ServicePrefab.name = "ServicePrefab"

ServicePrefab.instance = nil

function ServicePrefab.Show(parent)
	if ServicePrefab.instance then
		ServicePrefab.instance:ShowUI(parent)
		return
	end
	ServicePrefab.Create(parent)
end
function ServicePrefab.Create(parent)
	ServicePrefab.instance = ServicePrefab.New(parent)
	return ServicePrefab.instance
end
function ServicePrefab:ctor(parent)
	parent = GameObject.Find("Canvas/LayerLv4").transform
	local obj = newObject(ServicePrefab.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	self.WXNumber = ""
	self.BackButton = tran:Find("BackButton"):GetComponent("Button")
	self.BackButton.onClick:AddListener(function (val)
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:OnBackClick()
	end)

	self.CopyButton = tran:Find("CopyNumber"):GetComponent("Button")
	self.CopyButton.onClick:AddListener(function (val)
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:OnCopyButton()
	end)

	self.DHButton = tran:Find("BGImage/DHButton"):GetComponent("Button")
	self.DHButton.onClick:AddListener(function (val)
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		sdkMgr:CallUp("400-8882620")
	end)
	

	self.WXNumber = tran:Find("BGImage/WX"):GetComponent("Text").text

	self.URLText = tran:Find("BGImage/URLNode/URLText"):GetComponent("InlineText")
	self.URLText.OnHrefClick:AddListener(function (hrefName, id)
		print("<color=red>hrefName = " .. hrefName .. "id = " .. id .. "</color>")
	 	Application.OpenURL(hrefName)
	end)

	self:InitRect()
end
function ServicePrefab:InitRect()
end



-- 
function ServicePrefab:OnCopyButton()
	print("<color=red>复制内容"..self.WXNumber.."</color>")

	LittleTips.Create("已复制微信号请前往微信进行添加")

	UniClipboard.SetText(self.WXNumber)
	
end


-- 显示
function ServicePrefab:ShowUI(parent)
	self.transform:SetParent(parent)
	self:InitRect()
end
-- 关闭
function ServicePrefab:OnBackClick()
	print("<color=red>关闭界面</color>")
	GameObject.Destroy(self.gameObject)
	ServicePrefab.instance = nil
end