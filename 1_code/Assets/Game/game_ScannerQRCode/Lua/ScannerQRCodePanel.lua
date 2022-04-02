local basefunc = require "Game/Common/basefunc"

ScannerQRCodePanel = basefunc.class()
local M = ScannerQRCodePanel
local MController = ScannerQRCodeLogic
local MModel = ScannerQRCodeModel
M.name = "ScannerQRCodePanel"

local scanner = nil

local instance
function M.Create()
	instance = M.New()
	return instance
end

function M:ctor()
	local parent = GameObject.Find("Canvas/LayerLv50").transform
	local obj = newObject(M.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)

	self:MakeLister()
	self:AddMsgListener()

	self.back_btn.onClick:AddListener(function()
		M.Close()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		MainLogic.GotoScene("game_Hall")
	end)

	self:InitUI()
end

function M:InitUI()
	local permission = MainLogic.GetCameraPermission()
	print("[SCANNER QR CODE] InitUI permission:" .. permission)
	if permission == 0 then
		self:StartScan()
	else
		HintPanel.Create(1,"扫描二维码需要相机权限",function ()
			M.Close()
			MainLogic.GotoScene("game_Hall")
		end)
	end
end

function M:MyRefresh()
end

function M.Close()
	if instance then
		instance:MyExit()
	end
	instance = nil
end

function M:AddMsgListener()
	for proto_name,func in pairs(self.lister) do
		Event.AddListener(proto_name, func)
	end
end

function M:MakeLister()
	self.lister = {}
end

function M:RemoveListener()
	for proto_name,func in pairs(self.lister) do
		Event.RemoveListener(proto_name, func)
	end
	self.lister = {}
end

function M:MyExit()
	if scanner then
		scanner:StopScan(function()
			self:RemoveListener()
			GameObject.Destroy(self.transform.gameObject)
			scanner = nil
		end)
	else
		self:RemoveListener()
		GameObject.Destroy(self.transform.gameObject)
	end
end

function M:StartScan()
	scanner = self.gameObject:GetComponentInChildren(typeof(LuaFramework.ScannerQRCode))
	if not scanner then
		print("[SCANNER QR CODE] scanner is nil")
		return
	end
	scanner:StartScan(function(isOK, key, value)
		if isOK then
			MainLogic.HandleStartScan(key, value)
		end

		M.Close()
		MainLogic.GotoScene("game_Hall")
	end)
end
