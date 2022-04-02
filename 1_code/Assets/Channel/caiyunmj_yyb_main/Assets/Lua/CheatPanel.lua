local basefunc = require "Game.Common.basefunc"

CheatPanel = basefunc.class()
CheatPanel.name = "CheatPanel"

local instance

function CheatPanel.Create()
	instance = CheatPanel.New()
	return instance
end

function CheatPanel.Close()
	if instance then
		instance:ClearServerList()
		GameObject.Destroy(instance.transform.gameObject)
		instance = nil
	end
end

function CheatPanel:ctor()
	local parent = GameObject.Find("Canvas/LayerLv5").transform
	local obj = newObject(CheatPanel.name, parent)
	self.transform = obj.transform
	LuaHelper.GeneratingVar(self.transform, self)
	self:InitRect()
	DOTweenManager.OpenPopupUIAnim(self.transform)
end

function CheatPanel:InitRect()
	local transform = self.transform

	self.ok_btn.onClick:AddListener(function()
		local ip_port = self.setting_txt.text
		local segs = basefunc.string.split(ip_port, ":")
		if segs ~= nil and #segs == 2 then
			AppConst.SocketAddress = ip_port
		end

		local version = self.inputVersionField.text
		print(version .. type(version))
		gameMgr:SetForceVersion(version)

		local remoteConfigDir = self.inputRemoteConfigDirField.text
		print(remoteConfigDir .. type(remoteConfigDir))
		gameMgr:SetForceConfig(remoteConfigDir)

		CheatPanel.Close()
	end)

	self.clear_localconfig_btn.onClick:AddListener(function()
		local local_cfgs = {"localconfig"}
		for _, v in pairs(local_cfgs) do
			local dir = gameMgr:getLocalPath(v)
			if Directory.Exists(dir) then
				Directory.Delete(dir, true)
			end
		end
		PlayerPrefs.DeleteKey("_CLAUSE_IDENT_")
	end)

	self.inputIPField = transform:Find("option/InputIPField"):GetComponent("InputField")
	self.inputIPField.onValueChanged:AddListener(function (val)
		self.setting_txt.text = val .. ":" .. self.inputPortField.text
	end)

	self.inputPortField = transform:Find("option/InputPortField"):GetComponent("InputField")
	self.inputPortField.onValueChanged:AddListener(function (val)
		self.setting_txt.text = self.inputIPField.text .. ":" .. val
	end)

	self.inputVersionField = transform:Find("version/InputVersionField"):GetComponent("InputField")
	self.inputVersionField.onValueChanged:AddListener(function (val)
		self.setting_version_txt.text = val
	end)
	self.inputRemoteConfigDirField = transform:Find("version/InputRemoteConfigDirField"):GetComponent("InputField")

	self.accountPwd = 0
	self.inputAccountField = transform:Find("user/InputAccountField"):GetComponent("InputField")
	self.inputAccountField.onValueChanged:AddListener(function (val)
		if LoginModel.loginData then
			--todo
			--LoginModel.loginData.youke = val
			--LoginModel.loginData.qq = val
		end
	end)

	self.inputAccountField.gameObject:SetActive(false)
	self.account_btn.onClick:AddListener(function()
		self.accountPwd = self.accountPwd + 1
		if self.accountPwd >= 6 then
			self.accountPwd = 0
			self.inputAccountField.gameObject:SetActive(true)
		end
	end)

	local versionNode = transform:Find("version")
	if MainModel.IsLoged then
		local UserInfo = MainModel.UserInfo or {}
		local player_level = UserInfo.player_level or 0
		if player_level > 0 then
			versionNode.gameObject:SetActive(true)
		end
	else
		versionNode.gameObject:SetActive(false)
	end

	self.serverList = {}

	self:Refresh()
end

function CheatPanel:Refresh()
	local IPTable = {
		"jygate.jyhd919.cn:5101",
		"47.107.102.33:5004",
		"jygame.jyhd919.cn:5002",
		"171.223.209.152:5101",
		"192.168.0.203:5101",
	}

	self.current_txt.text = AppConst.SocketAddress
	self.version_txt.text = gameMgr:GetVersionNumber()
	self.url_txt.text = gameMgr:GetRootURL()

	self:ClearServerList()
	for k, v in pairs(IPTable) do
		self.serverList[#self.serverList + 1] = self:CreateItem(v)
	end

	local loginData = LoginModel.loginData or {}
	self.inputAccountField.text = (loginData.wechat) or "" .. " # " .. (loginData.qq or "")
end

function CheatPanel:ClearServerList()
	for i,v in pairs(self.serverList) do
		GameObject.Destroy(v.gameObject)
	end
	self.serverList = {}
end

function CheatPanel:CreateItem(item)
	local obj = GameObject.Instantiate(self.server_item_tmpl)
	obj.transform:SetParent(self.list_node)
	obj.transform.localScale = Vector3.one

	local obj_t = {}
	LuaHelper.GeneratingVar(obj.transform, obj_t)
	obj_t.ip_btn.onClick:AddListener(function()
		self.setting_txt.text = item
		self.inputIPField.text = ""
		self.inputPortField.text = ""
	end)
	obj_t.ip_txt.text = item

	obj.gameObject:SetActive(true)

	return obj
end

--Æô¶¯ÊÂ¼þ--
function CheatPanel:Awake()
end

function CheatPanel:Start()	
end

function CheatPanel:OnDestroy()
end
