package.loaded["Game.game_ScannerQRCode.Lua.ScannerQRCodeModel"] = nil
require "Game.game_ScannerQRCode.Lua.ScannerQRCodeModel"

package.loaded["Game.game_ScannerQRCode.Lua.ScannerQRCodePanel"] = nil
require "Game.game_ScannerQRCode.Lua.ScannerQRCodePanel"

ScannerQRCodeLogic = {}

local this
local lister
local viewLister
local cur_panel

local function MakeLister()
	lister = {}
end
local function AddMsgListener(lister)
	for proto_name, func in pairs(lister) do
		Event.AddListener(proto_name, func)
	end
end

local function RemoveMsgListener(lister)
	for proto_name, func in pairs(lister) do
		Event.RemoveListener(proto_name, func)
	end
end

--初始化
function ScannerQRCodeLogic.Init()
	this = ScannerQRCodeLogic

	--初始化model
	local model = ScannerQRCodeModel.Init()
	MakeLister()
	AddMsgListener(lister)

	cur_panel = ScannerQRCodePanel.Create()
end
function ScannerQRCodeLogic.Exit()
	if this then
		if cur_panel then
			cur_panel:MyExit()
		end
		cur_panel = nil

		ScannerQRCodeModel.Exit()
		RemoveMsgListener(lister)
		this = nil
	end
end

return ScannerQRCodeLogic
