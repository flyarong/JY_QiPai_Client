QHBModel = {}
local M = QHBModel
local this
local lister
local m_data
local update
local updateDt = 0.1
package.loaded["Game.game_QHB.Lua.qhb_config"] = nil
local qhb_config = require "Game.game_QHB.Lua.qhb_config"

--本地数据
M.save_path = AppDefine.LOCAL_DATA_PATH .. "/" .. MainModel.UserInfo.user_id
M.save_file = "qhb_data"

local is_init = true
function M.InitSaveData()
    if not is_init then return end
    is_init = false
    M.save_path = M.save_path .. m_data.game_id
    local lua_data = load_json2lua(M.save_file,M.save_path)
    if lua_data and next(lua_data) then
        M.local_data = {}
        for i,v in ipairs(lua_data) do
            M.local_data[v.hb_id] = v
        end
    end
end

function M.SaveData()
    if not M.local_data then return end
    local sd = {}
    for k,v in pairs(M.local_data) do
        table.insert(sd,v)
    end
    save_lua2json(sd,M.save_file,M.save_path)
end

local revise = true
function M.ReviseSaveData()
    if not revise then return end
    revise = false
    local ld
    if m_data and m_data.all_info and m_data.all_info.hb_id_begin and m_data.all_info.hb_id_end then
        if M.local_data then
            for k,v in pairs(M.local_data) do
                if k >= m_data.all_info.hb_id_begin and k <= m_data.all_info.hb_id_end then
                    ld = ld or {}
                    ld[v.hb_id] = v
                end
            end
        end
    end
    M.local_data = ld
    save_lua2json(M.local_data,M.save_file,M.save_path)
end

function M.SetLocalData(hb_data)
    M.local_data = M.local_data or {}
    hb_data.view = true
    M.local_data[hb_data.hb_id] = hb_data
end

function M.IsHBView(hb_id)
    return M.local_data and M.local_data[hb_id] and M.local_data[hb_id].view
end

--构建斗地主正常逻辑的消息事件（断线重连部分不在这里绑定）
local function MakeLister()
    lister = {}
    lister["qhb_hb_send_msg"] = this.on_qhb_hb_send_msg
    lister["qhb_hb_change_msg"] = this.on_qhb_hb_change_msg
    lister["qhb_my_hb_change_msg"] = this.on_qhb_my_hb_change_msg
    lister["qhb_force_quit_game_msg"] = this.on_qhb_force_quit_game_msg
    lister["qhb_time_stamp_msg"] = this.on_qhb_time_stamp_msg

    lister["qhb_quit_game_response"] = this.on_qhb_quit_game_response
    lister["qhb_all_info_response"] = this.on_qhb_all_info_response
    lister["qhb_hb_info_response"] = this.on_qhb_hb_info_response
    lister["qhb_hb_detail_response"] = this.on_qhb_hb_detail_response
    lister["qhb_hb_send_response"] = this.on_qhb_hb_send_response
    lister["qhb_hb_get_response"] = this.on_qhb_hb_get_response
    lister["qhb_hb_history_response"] = this.on_qhb_hb_history_response
    lister["qhb_get_qhb_data_response"] = this.on_qhb_get_qhb_data_response
    --资产改变
    lister["AssetChange"] = this.AssetChange
end

local function MsgDispatch(proto_name, data)
    -- dump({proto_name, data}, "<color=white>MsgDispatch???????????????????</color>")
    local func = lister[proto_name]
    if not func then
        error("brocast " .. proto_name .. " has no event.")
    end
    --临时限制   一般在断线重连时生效  由logic控制
    if m_data.limitDealMsg and not m_data.limitDealMsg[proto_name] then
        return
    end
    func(proto_name, data)
end

--注册斗地主正常逻辑的消息事件
function M.AddMsgListener()
    for proto_name, _ in pairs(lister) do
        Event.AddListener(proto_name, MsgDispatch)
    end
end

--删除斗地主正常逻辑的消息事件
function M.RemoveMsgListener()
    for proto_name, _ in pairs(lister) do
        if proto_name == "AssetChange" then
            Event.RemoveListener(proto_name, _)
        else
            Event.RemoveListener(proto_name, MsgDispatch)
        end
    end
end

function M.Update()
    if m_data then
        if m_data.countdown and m_data.countdown > 0 then
            m_data.countdown = m_data.countdown - updateDt
            if m_data.countdown < 0 then
                m_data.countdown = 0
            end
        end
    end
end

function M.InitCfg()
    M.cfg = {}
    if qhb_config then
        for k,v in pairs(qhb_config) do
            M.cfg[k] = M.cfg[k] or {}
            for i,v1 in ipairs(v) do
                M.cfg[k][v1.game_id] = v1
            end
        end
    end
end

function M.InitGameData()
    m_data = {}
    M.data = m_data
    print("<color=red>InitGameData m_data 重置</color>")
end

function M.Init()
    print("<color=white>初始化model</color>")
    M.InitCfg()
    M.InitGameData()
    this = M
    this.InitUIConfig()
    MakeLister()
    this.AddMsgListener()
    update = Timer.New(M.Update, updateDt, -1, true)
    update:Start()
    return this
end

function M.Exit()
    QHBModel.SaveData()
    if this then
        M.RemoveMsgListener()
        update:Stop()
        update = nil
        this = nil
        lister = nil
        m_data = nil
    end
end

function M.InitUIConfig()
    this.UIConfig = {}
end

--退出游戏---------------------------------
function M.request_qhb_quit_game()
    Network.SendRequest("qhb_quit_game",nil,"")
end

function M.on_qhb_quit_game_response(proto_name, data)
    dump(data, "<color=yellow>on_qhb_quit_game_response</color>")
    if data.result ~= 0 then 
        HintPanel.ErrorMsg(data.result,nil,nil,"HintPanelSP") 
        return
    end
    M.InitGameData()
    MainLogic.ExitGame()
    Event.Brocast("quit_game_success")
    Event.Brocast("model_qhb_quit_game_response", data.result)
end

--所有数据
function M.request_qhb_all_info()
    Network.SendRequest("qhb_all_info")
end

function M.on_qhb_all_info_response(proto_name, data)
    dump(data, "<color=yellow>on_qhb_all_info_response</color>")
    if data.result ~= 0 then
        --清除数据
        M.InitGameData()
        MainLogic.ExitGame()
    else
        M.InitGameData()
        MainLogic.EnterGame()
        m_data.game_id = data.game_id
        m_data.player_hb_data = data.player_hb_data
        m_data.all_info = {}
        m_data.all_info.hb_id_begin = data.hb_id_begin
        m_data.all_info.hb_id_end = data.hb_id_end
        m_data.all_info.his_count = data.his_count
        m_data.all_info.cur_time = data.time
        M.InitSaveData()
        M.ReviseSaveData()
    end
    Event.Brocast("model_qhb_all_info_response",data)
end

--红包次数
function M.request_qhb_get_qhb_data()
    if not m_data then return end
    if not M.IsSysScene() then return end
    Network.SendRequest("qhb_get_qhb_data",{game_id = m_data.game_id})
end

function M.on_qhb_get_qhb_data_response(_,data)
    dump(data, "<color=yellow>qhb_get_qhb_data_response</color>") 
    if not m_data then return end
    if data.result ~= 0 then
        HintPanel.ErrorMsg(data.result,nil,nil,"HintPanelSP")
        return
    end
    m_data.player_hb_data = data.data
    Event.Brocast("model_qhb_get_qhb_data_response",data.data)
end

--红包数据---------------------------------------------
function M.init_qhb_hb_info()
    m_data.hb_info = {}
    m_data.hb_info.can_req = true
    m_data.hb_info.hb_datas = {}
    m_data.hb_info.new = {}
    m_data.hb_info.req_count = 20    --默认请求count
end

--请求后面的红包
function M.request_qhb_hb_info_last()
    if not m_data then return end
    if not m_data.hb_info or not m_data.hb_info.can_req then return end
    local hb_id_begin = m_data.all_info.hb_id_begin
    local hb_id_end = m_data.all_info.hb_id_end
    --没有红包
    if not hb_id_begin or not hb_id_end then return end
    if hb_id_begin > hb_id_end then return end
    local begin_id
    local hb_count
    local local_begin_id,local_end_id
    if not table_is_null(m_data.hb_info.hb_datas) then
        for k,v in pairs(m_data.hb_info.hb_datas) do
            if not local_begin_id then local_begin_id = v.hb_id end
            if local_begin_id > v.hb_id then local_begin_id = v.hb_id end       
            if not local_end_id then local_end_id = v.hb_id end
            if local_end_id < v.hb_id then local_end_id = v.hb_id end       
        end
        --请求完
        if local_end_id >= hb_id_end then return end
        --没有请求完
        hb_count = hb_id_end - local_end_id + 1
    else
        hb_count = hb_id_end - hb_id_begin + 1
    end
    if hb_count > m_data.hb_info.req_count then
        hb_count = m_data.hb_info.req_count
    end
    begin_id = hb_id_end - hb_count + 1
    dump({begin_id = begin_id, hb_count = hb_count}, "<color=white>请求红包</color>")
    Network.SendRequest("qhb_hb_info",{begin_id = begin_id, hb_count = hb_count})
    m_data.hb_info.can_req = false
end

--请求前面的红包
function M.request_qhb_hb_info_first(  )
    if not m_data then return end
    if not m_data.hb_info or not m_data.hb_info.can_req then return end
    local hb_id_begin = m_data.all_info.hb_id_begin
    local hb_id_end = m_data.all_info.hb_id_end
    --没有红包
    if not hb_id_begin or not hb_id_end then return end
    if hb_id_begin > hb_id_end then return end
    local begin_id
    local hb_count
    local local_begin_id,local_end_id
    if not table_is_null(m_data.hb_info.hb_datas) then
        for k,v in pairs(m_data.hb_info.hb_datas) do
            if not local_begin_id then local_begin_id = v.hb_id end
            if local_begin_id > v.hb_id then local_begin_id = v.hb_id end       
            if not local_end_id then local_end_id = v.hb_id end
            if local_end_id < v.hb_id then local_end_id = v.hb_id end       
        end
        --请求完
        if local_begin_id <= hb_id_begin then return end
        --没有请求完
        hb_count = local_begin_id - hb_id_begin + 1
        if hb_count > m_data.hb_info.req_count then
            hb_count = m_data.hb_info.req_count
        end
        begin_id = local_begin_id - hb_count + 1
    else
        hb_count = hb_id_end - hb_id_begin + 1
        if hb_count > m_data.hb_info.req_count then
            hb_count = m_data.hb_info.req_count
        end
        begin_id = hb_id_end - hb_count + 1
    end
    dump({begin_id = begin_id, hb_count = hb_count}, "<color=white>请求红包</color>")
    Network.SendRequest("qhb_hb_info",{begin_id = begin_id, hb_count = hb_count})
    m_data.hb_info.can_req = false
end

function M.on_qhb_hb_info_response(proto_name, data)
    dump(data, "<color=yellow>on_qhb_hb_info_response</color>")
    if not m_data then return end
    if not m_data.hb_info then return end
    m_data.hb_info.can_req = true
    if data.result ~= 0 then
        HintPanel.ErrorMsg(data.result,nil,nil,"HintPanelSP")
        m_data.hb_info.new = {}
        return
    end

    if not m_data.hb_info.begin_id then
        m_data.hb_info.begin_id = m_data.all_info.hb_id_end - m_data.hb_info.req_count
    else
        m_data.hb_info.begin_id = m_data.hb_info.begin_id - m_data.hb_info.req_count
    end

    m_data.hb_info.hb_datas = m_data.hb_info.hb_datas or {}
    m_data.hb_info.new = data.hb_datas
    for k,v in pairs(data.hb_datas) do
        m_data.hb_info.hb_datas[v.hb_id] = v
    end
    m_data.all_info.hb_id_begin = data.hb_id_begin
    m_data.all_info.hb_id_end = data.hb_id_begin + data.hb_count - 1
    Event.Brocast("model_qhb_hb_info_response",m_data.hb_info.new)
end

--红包详情-----------------------------------------------
function M.request_qhb_hb_detail(hb_id)
    if not m_data then return end
    Network.SendRequest("qhb_hb_detail",{hb_id = hb_id})
end

function M.on_qhb_hb_detail_response(proto_name, data)
    dump(data, "<color=yellow>on_qhb_hb_detail_response</color>")
    if not m_data then return end
    m_data.hb_detail = {}
    if data.result ~= 0 then
        HintPanel.ErrorMsg(data.result,nil,nil,"HintPanelSP")
        return 
    end
    m_data.hb_detail.hb_data = data.hb_data
    m_data.hb_detail.get_data = data.get_data
    m_data.hb_info = m_data.hb_info or {}
    m_data.hb_info.hb_datas = m_data.hb_info.hb_datas or {}
    m_data.hb_info.hb_datas[data.hb_data.hb_id] = data.hb_data
    Event.Brocast("model_qhb_hb_detail_response", data)
end

--发红包--------------------------------------------------
function M.request_qhb_hb_send(hb_data)
    if not m_data then return end
    m_data.hb_send = {}
    m_data.hb_send.hb_count = hb_data.hb_count
    m_data.hb_send.asset = hb_data.asset
    m_data.hb_send.boom_num = hb_data.boom_num
    Network.SendRequest("qhb_hb_send",m_data.hb_send)
end

function M.on_qhb_hb_send_response(proto_name, data)
    dump(data, "<color=yellow>qhb_hb_send_response</color>")
    if not m_data then return end
    if data.result ~= 0 then 
        HintPanel.ErrorMsg(data.result,nil,nil,"HintPanelSP")
        m_data.hb_send = {}
        return 
    end
    LittleTips.CreateSP("红包发出...")
    Event.Brocast("model_qhb_hb_send_response", data)
end

--抢红包------------------------------------------------
function M.request_qhb_hb_get(hb_id)
    if not m_data then return end
    m_data.hb_get = {}
    m_data.hb_get.hb_id = hb_id
    Network.SendRequest("qhb_hb_get",m_data.hb_get)
end

function M.on_qhb_hb_get_response(proto_name, data)
    dump(data, "<color=yellow>qhb_hb_get_response</color>")
    if not m_data then return end
    m_data.hb_get = {}
    if data.result ~= 0 then
        --更新红包信息
        M.request_qhb_hb_detail(data.hb_id)
        --更新免费次数
        M.request_qhb_get_qhb_data()
        Event.Brocast("model_qhb_hb_get_response", data)
        return 
    end
    m_data.hb_get.hb_id = data.hb_id
    m_data.hb_get.asset = data.asset
    m_data.hb_get.boom = data.boom
    m_data.all_info.his_count = m_data.all_info.his_count + 1

    Event.Brocast("model_qhb_hb_get_response", data)

    --更新红包信息
    M.request_qhb_hb_detail(data.hb_id)
    --更新免费次数
    M.request_qhb_get_qhb_data()
end

--红包历史-----------------------------------
function M.init_qhb_hb_history()
    m_data.hb_history = {}
    m_data.hb_history.can_req = true
    m_data.hb_history.req_count = 20    --默认请求count
    m_data.hb_history.new = {}
    m_data.hb_history.data = {}
end

function M.request_qhb_hb_history_all()
    if not m_data then return end
    if not m_data.hb_history or not m_data.hb_history.can_req then return end
    if not m_data.all_info or not m_data.all_info.his_count or m_data.all_info.his_count == 0 then return end
    local index = 1
    local count = 30
    dump({index = index, count = count}, "<color=white>请求历史</color>")
    Network.SendRequest("qhb_hb_history",{index = index, count = count})
    m_data.hb_history.can_req = false
end

function M.request_qhb_hb_history()
    --直接请求30条数据
    if true then 
        M.request_qhb_hb_history_all()
        return
    end

    if not m_data then return end
    if not m_data.hb_history or not m_data.hb_history.can_req then return end
    if not m_data.all_info or not m_data.all_info.his_count or m_data.all_info.his_count == 0 then return end
    local index = m_data.all_info.his_count
    if not table_is_null(m_data.hb_history.data) then
        for k,v in pairs(m_data.hb_history.data) do
            index = index - 1
        end
        if index == 0 then return end
    end
    local count = index - 0
    if count > m_data.hb_history.req_count then
        count = m_data.hb_history.req_count
    end
    index = index - count + 1
    dump({index = index, count = count}, "<color=white>请求历史</color>")
    Network.SendRequest("qhb_hb_history",{index = index, count = count})
    m_data.hb_history.can_req = false
end

function M.on_qhb_hb_history_response(proto_name, data)
    dump(data, "<color=yellow>qhb_hb_history_response</color>")
    if not m_data then return end
    if not m_data.hb_history then return end
    m_data.hb_history.can_req = true
    if data.result ~= 0 then 
        HintPanel.ErrorMsg(data.result,nil,nil,"HintPanelSP")
        m_data.hb_history.new = {}
        return 
    end
    m_data.hb_history.new = data.data
    m_data.hb_history.data = m_data.hb_history.data or {}

    for k,v in pairs(data.data) do
        table.insert( m_data.hb_history.data, 1,v)
    end
    Event.Brocast("model_qhb_hb_history_response", m_data.hb_history.new)
end

--***********************msg
--别人发红包
function M.on_qhb_hb_send_msg(proto_name, data)
    dump(data, "<color=yellow>on_qhb_hb_send_msg</color>")
    m_data = m_data or {}
    m_data.hb_info = m_data.hb_info or {}
    m_data.all_info = m_data.all_info or {}
    m_data.hb_info.hb_datas = m_data.hb_info.hb_datas or {}
    if data.hb_data then
        for i,v in ipairs(data.hb_data) do
            m_data.hb_info.hb_datas[v.hb_id] = v
            if v.send_player.id == MainModel.UserInfo.user_id then
                m_data.all_info.his_count = m_data.all_info.his_count + 1
            end
        end
    end
    m_data.all_info.hb_id_begin = data.hb_id_begin
    m_data.all_info.hb_id_end = data.hb_id_end
    Event.Brocast("model_qhb_hb_send_msg",data.hb_data)
end

--红包改变
function M.on_qhb_hb_change_msg(proto_name, data)
    dump(data, "<color=yellow>on_qhb_hb_change_msg</color>")
    m_data = m_data or {}
    m_data.hb_info.hb_datas = m_data.hb_datas or {}
    m_data.hb_info.hb_datas[data.hb_data.hb_id] = data.hb_data
    Event.Brocast("model_qhb_hb_change_msg",data.hb_data)
end

function M.on_qhb_my_hb_change_msg(proto_name, data)
    dump(data, "<color=yellow>on_qhb_my_hb_change_msg</color>")
    m_data = m_data or {}
    m_data.hb_get_data = data
    Event.Brocast("model_qhb_my_hb_change_msg",data)

    if data.timeout and data.timeout == 1 then
        --过期
        QHBHBManager.RefreshHBByID(data.hb_id)
    else
        if data.geted_count and m_data and m_data.hb_info and m_data.hb_info.hb_datas and m_data.hb_info.hb_datas[data.hb_id] then
            m_data.hb_info.hb_datas[data.hb_id].geted_count = data.geted_count
            QHBHBManager.RefreshHB(m_data.hb_info.hb_datas[data.hb_id])
        end
    end
end

function M.on_qhb_force_quit_game_msg(proto_name, data)
    dump(data, "<color=yellow>on_qhb_force_quit_game_msg</color>")
    M.InitGameData()
    MainLogic.ExitGame()
    Event.Brocast("quit_game_success")
    Event.Brocast("model_qhb_force_quit_game_msg")
end

function M.on_qhb_time_stamp_msg(proto_name, data)
    dump(data, "<color=yellow>on_qhb_time_stamp_msg</color>")
    m_data = m_data or {}
    m_data.all_info = m_data.all_info or {}
    m_data.all_info.cur_time = data.time
end

function M.GetHBData(hb_id)
    if m_data and m_data.hb_info and m_data.hb_info.hb_datas and m_data.hb_info.hb_datas[hb_id] then
        return m_data.hb_info.hb_datas[hb_id]
    end
end

--是否是系统发红包场
function M.IsSysScene()
    if m_data  then
        return m_data.game_id == 41
    end
end

function M.GetCurTime()
    if m_data and m_data.all_info and m_data.all_info.cur_time then
        return m_data.all_info.cur_time
    end
    return os.time()
end

function M.CheckIsTimeOut(timeout)
    local ct = M.GetCurTime()
    return ct - timeout > 10
end