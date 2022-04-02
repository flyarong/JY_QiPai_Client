
ScannerQRCodeModel = {}

local this
local lister
local m_data

--���������������߼�����Ϣ�¼��������������ֲ�������󶨣�
local function MakeLister()
	lister = {}
end
--ע�ᶷ���������߼�����Ϣ�¼�
local function AddMsgListener()
	for proto_name, call in pairs(lister) do
		Event.AddListener(proto_name, call)
	end
end

--ɾ�������������߼�����Ϣ�¼�
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
