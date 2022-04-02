-- 创建时间:2020-08-26

LWZBHallModel = {}
local M = LWZBHallModel

local this
local game_lister
local lister
local m_data
local update
local updateDt = 0.1

function M.MakeLister()
	-- 游戏相关
    game_lister = {}

    -- 其他
    lister = {}
end
--注册斗地主正常逻辑的消息事件
function M.AddMsgListener()
    for proto_name, _ in pairs(game_lister) do
        Event.AddListener(proto_name, MsgDispatch)
    end
    for proto_name, _ in pairs(lister) do
        Event.AddListener(proto_name, _)
    end
end

--删除斗地主正常逻辑的消息事件
function M.RemoveMsgListener()
    for proto_name, _ in pairs(game_lister) do
        Event.RemoveListener(proto_name, MsgDispatch)
    end
    for proto_name, _ in pairs(lister) do
        Event.RemoveListener(proto_name, _)
    end
end

local function MsgDispatch(proto_name, data)
    -- dump(data, "<color=red>proto_name:</color>" .. proto_name)
    local func = lister[proto_name]

    if not func then
        error("brocast " .. proto_name .. " has no event.")
    end
    --临时限制   一般在断线重连时生效  由logic控制
    if m_data.limitDealMsg and not m_data.limitDealMsg[proto_name] then
        return
    end

    if data.status_no then
    	-- 断线重连的数据不用判断status_no
    	-- "all_info" 根据具体游戏命名
        if proto_name ~= "all_info" then
            if m_data.status_no + 1 ~= data.status_no and m_data.status_no ~= data.status_no then
                m_data.status_no = data.status_no
                print("<color=red>proto_name = " .. proto_name .. "</color>")
                dump(data)
                --发送状态编码错误事件
                Event.Brocast("model_status_no_error_msg")
                return
            end
        end
        m_data.status_no = data.status_no
    end
    func(proto_name, data)
end
local function InitData()
    M.data = {}
    m_data = M.data
end
function M.Init()
    this = M
    InitData()
    M.InitUIConfig()
    M.MakeLister()
    M.AddMsgListener()

    return this
end

function M.Exit()
    if this then
        M.RemoveMsgListener()
        this = nil
        game_lister = nil
        lister = nil
        m_data = nil
        M.data = nil
    end
end

function M.InitUIConfig()
    this.UIConfig = {}
end

