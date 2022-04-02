
ScannerQRCodeModel = {}

local this
local lister
local m_data

--构建斗地主正常逻辑的消息事件（断线重连部分不在这里绑定）
local function MakeLister()
	lister = {}
end
--注册斗地主正常逻辑的消息事件
local function AddMsgListener()
	for proto_name, call in pairs(lister) do
		Event.AddListener(proto_name, call)
	end
end

--删除斗地主正常逻辑的消息事件
function ScannerQRCodeModel.RemoveMsgListener()
	for proto_name, call in pairs(lister) do
		Event.RemoveListener(proto_name, call)
	end
end

function ScannerQRCodeModel.Init()
	this = ScannerQRCodeModel
	MakeLister()
	AddMsgListener()
	return this
end

function ScannerQRCodeModel.Exit()
	if this then
		ScannerQRCodeModel.RemoveMsgListener()
		this = nil
		lister = nil
	end
end
