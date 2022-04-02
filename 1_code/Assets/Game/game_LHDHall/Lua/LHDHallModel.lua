-- 创建时间:2019-11-18

LHDHallModel = {}
local M = LHDHallModel

M.DeskType = {
    DT_Nor = 0,
    DT_Vip = 1,
}
local this
local lister
local m_data
local update_time

local is_debug_data = false

--构建斗地主正常逻辑的消息事件（断线重连部分不在这里绑定）
local function MakeLister()
    lister = {}

    lister["fg_lhd_req_page_info_status_no_response"] = this.on_update_desk_state_msg
    lister["fg_lhd_req_page_info_data_response"] = this.on_update_desk_data_msg
end
--注册斗地主正常逻辑的消息事件
function M.AddMsgListener()
    for proto_name, call in pairs(lister) do
        Event.AddListener(proto_name, call)
    end
end

--删除斗地主正常逻辑的消息事件
function M.RemoveMsgListener()
    for proto_name, call in pairs(lister) do
        Event.RemoveListener(proto_name, call)
    end
end
local function InitData()
    M.data = {}
    m_data = M.data

    -- 桌子数据
    m_data.desk_data_map = {}
    m_data.desk_data_map[M.DeskType.DT_Nor] = {} -- [1] = {status_no=1, page_data={第一页的桌子数据...}}
    m_data.desk_data_map[M.DeskType.DT_Vip] = {} -- ...

    -- 测试
    if is_debug_data then
        -- 类型 id 分页
        -- [0] = {
        --     [1] = {
        --         page_count=5,
        --         page_data = {
        --             [1] = {
        --                 status_no = 1,
        --                 last_time=os.time(),
        --                 page_data = {
        --                     [1]={
        --                         room_no=1,
        --                         state=1,
        --                         p_info={
        --                             [1] ={
        --                                 name="ddd",
        --                                 ...
        --                             }
        --                         }
        --                     }
        --                 }
        --             }
        --         }
        --     } 
        -- }
        for k = 1, 4 do
            local game_id = k
            m_data.desk_data_map[M.DeskType.DT_Nor][game_id] = {}
            m_data.desk_data_map[M.DeskType.DT_Nor][game_id].page_count = 5
            m_data.desk_data_map[M.DeskType.DT_Nor][game_id].page_data = {}
            local page_data = m_data.desk_data_map[M.DeskType.DT_Nor][game_id].page_data
            for i = 1, 5 do
                local dd = {}
                dd.status_no = 1
                dd.last_time = os.time()
                dd.page_data = {}
                for j = 1, 10 do
                    local dd1 = {}
                    dd1.room_no = (i-1) * 10 + j
                    dd1.state = math.random(1, 2) - 1
                    dd1.p_info = {}
                    local nn = math.random(1, 5) - 1
                    for x = 1, nn do
                        local dd2 = {}
                        dd2.name = "name" .. math.random(1, 10000)
                        dd2.seat_num = math.random(1, 4)
                        dd1.p_info[#dd1.p_info + 1] = dd2
                    end
                    dd.page_data[#dd.page_data + 1] = dd1
                end
                page_data[#page_data + 1] = dd
            end
        end
    end
end
function M.Init()
    this = LHDHallModel
    InitData()
    MakeLister()
    this.AddMsgListener()
    M.InitConfig()
    update_time = Timer.New(M.Update, 3, -1, true, true)
    update_time:Start()

    return this
end

function M.Exit()
    if this then
        M.RemoveMsgListener()
        this = nil
        lister = nil
    end
end

function M.InitConfig()
end

function M.Update()
end

-- 请求桌子数据,要先去查询状态
-- 3秒内不重复请求
function M.query_desk_data(data)
    if is_debug_data then
        Event.Brocast("model_update_desk_data_msg", data)
        return
    end
    local game_id = data.game_id
    local dt = data.model
    local page = data.page
    if not m_data.desk_data_map[dt][game_id]
        or not m_data.desk_data_map[dt][game_id].page_data
        or not m_data.desk_data_map[dt][game_id].page_data[page]
        or not m_data.desk_data_map[dt][game_id].page_data[page].last_time
        or os.time() > (m_data.desk_data_map[dt][game_id].page_data[page].last_time+3) then
        Network.SendRequest("fg_lhd_req_page_info_status_no", data, "")
    else
        Event.Brocast("model_update_desk_data_msg", data)
    end
end
function M.get_desk_data(data)
    if is_debug_data then
        dump(data, "<color=red>query_desk_data</color>")
        dump(m_data.desk_data_map, "dd", 10000)
        return m_data.desk_data_map[data.model][data.game_id].page_data[data.page].page_data
    end
    local game_id = data.game_id
    local dt = data.model
    local page = data.page
    if not m_data.desk_data_map[dt][game_id]
        or not m_data.desk_data_map[dt][game_id].page_data
        or not m_data.desk_data_map[dt][game_id].page_data[page] then
        return {}
    else
        return m_data.desk_data_map[dt][game_id].page_data[page].page_data
    end
end
function M.get_desk_page_count(data)
    if is_debug_data then
        return m_data.desk_data_map[data.model][data.game_id].page_count
    end
    local game_id = data.game_id
    local dt = data.model
    local page = data.page
    if not m_data.desk_data_map[dt][game_id] or not m_data.desk_data_map[dt][game_id].page_count then
        return 1
    else
        return m_data.desk_data_map[dt][game_id].page_count
    end
end

function M.on_update_desk_state_msg(_, data)
    if data.result == 0 then
        local game_id = data.game_id
        local dt = data.model
        local page = data.page
        local status_no = data.status_no
        if not m_data.desk_data_map[dt][game_id]
            or not m_data.desk_data_map[dt][game_id].page_data
            or not m_data.desk_data_map[dt][game_id].page_data[page]
            or m_data.desk_data_map[dt][game_id].page_data[page].status_no ~= status_no then

            m_data.desk_data_map[dt][game_id] = m_data.desk_data_map[dt][game_id] or {}
            m_data.desk_data_map[dt][game_id].page_data = m_data.desk_data_map[dt][game_id].page_data or {}
            m_data.desk_data_map[dt][game_id].page_data[page] = m_data.desk_data_map[dt][game_id].page_data[page] or {}
            m_data.desk_data_map[dt][game_id].page_data[page].status_no = status_no
            Network.SendRequest("fg_lhd_req_page_info_data", {game_id=game_id, model=dt, page=data.page}, "请求桌子数据")
        else
            Event.Brocast("model_update_desk_data_msg", {game_id=game_id, model=dt, page=data.page})
        end
    else
        HintPanel.ErrorMsg(data.result)
    end
end
function M.on_update_desk_data_msg(_, data)
    dump(data, "<color=red>EEE on_update_desk_data_msg</color>")
    if data.result == 0 then
        local game_id = data.game_id
        local dt = data.model
        local page = data.page
        m_data.desk_data_map[dt][game_id].page_data[page].last_time = os.time()
        m_data.desk_data_map[dt][game_id].page_data[page].status_no = data.status_no
        m_data.desk_data_map[dt][game_id].page_data[page].page_data = data.page_data
        m_data.desk_data_map[dt][game_id].page_count = data.page_count
         
        Event.Brocast("model_update_desk_data_msg", {game_id=game_id, model=dt, page=data.page})
    else
        HintPanel.ErrorMsg(data.result)
    end
end

