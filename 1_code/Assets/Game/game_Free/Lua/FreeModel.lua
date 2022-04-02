-- 创建时间:2018-10-16

FreeModel = {}
local this
local lister
local m_data

--构建斗地主正常逻辑的消息事件（断线重连部分不在这里绑定）
local function MakeLister()
    lister = {}
end
--注册斗地主正常逻辑的消息事件
function FreeModel.AddMsgListener()
    for proto_name, call in pairs(lister) do
        Event.AddListener(proto_name, call)
    end
end

--删除斗地主正常逻辑的消息事件
function FreeModel.RemoveMsgListener()
    for proto_name, call in pairs(lister) do
        Event.RemoveListener(proto_name, call)
    end
end

function FreeModel.Init()
    this = FreeModel
    MakeLister()
    this.AddMsgListener()
    return this
end

function FreeModel.Exit()
    if this then
        FreeModel.RemoveMsgListener()
        this = nil
        lister = nil
    end
end

