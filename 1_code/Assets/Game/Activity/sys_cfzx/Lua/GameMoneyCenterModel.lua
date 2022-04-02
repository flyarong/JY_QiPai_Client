-- 创建时间:2018-12-19
local money_center_config = GameMoneyCenterLogic.money_center_config
GameMoneyCenterModel = {}
local this
local m_data
local lister
local function AddLister()
    for msg, cbk in pairs(lister) do
        Event.AddListener(msg, cbk)
    end
end

local function RemoveLister()
    for msg, cbk in pairs(lister) do
        Event.RemoveListener(msg, cbk)
    end
    lister = nil
end

local function MakeLister()
    lister = {}
    lister["query_son_base_contribute_info_response"] = this.query_son_base_contribute_info_response
    lister["query_son_details_contribute_info_response"] = this.query_son_details_contribute_info_response
    lister["query_my_sczd_income_details_response"] = this.query_my_sczd_income_details_response
    lister["query_my_sczd_spending_details_response"] = this.query_my_sczd_spending_details_response
    lister["get_player_sczd_base_info_response"] = this.on_get_player_sczd_base_info_response
    lister["sczd_activate_change_msg"] = this.on_sczd_activate_change_msg
    lister["query_my_son_main_info_response"] = this.on_query_my_son_main_info_response
    lister["tglb_profit_activate"] = this.on_tglb_profit_activate
    lister["goldpig_profit_cache_change"] = this.goldpig_profit_cache_change
    lister["search_son_by_id_response"] = this.search_son_by_id_response
    lister["query_sczd_total_rebate_value_response"] = this.query_sczd_total_rebate_value_response
end

-- 初始化Data
local function InitMatchData()
    GameMoneyCenterModel.data = {}
    m_data = GameMoneyCenterModel.data
end

function GameMoneyCenterModel.Init()
    this = GameMoneyCenterModel
    InitMatchData()
    MakeLister()
    AddLister()
    this.InitUIConfig()
    return this
end

function GameMoneyCenterModel.Exit()
    if this then
        RemoveLister()
        lister = nil
        this = nil
    end
end

function GameMoneyCenterModel.InitUIConfig()
    this.UIConfig = {}

    this.UIConfig.wyhb = money_center_config.wyhb
    this.UIConfig.tgjj = money_center_config.tgjj
    this.UIConfig.tge = money_center_config.income_spending_tge
    this.UIConfig.tglb = money_center_config.tglb
end

function GameMoneyCenterModel.GetWyhbData()
    return this.UIConfig.wyhb
end

function GameMoneyCenterModel.GetTgjjData()
    return this.UIConfig.tgjj
end

function GameMoneyCenterModel.GetTglbData()
    if this and this.UIConfig then
        return this.UIConfig.tglb
    end
end

local update_data_time = 10
GameMoneyCenterModel.contribute_page_index = 1
GameMoneyCenterModel.income_page_index = 1
GameMoneyCenterModel.spending_page_index = 1

function GameMoneyCenterModel.LoadData(key, dtype)
    if dtype == "base_contribute" then
        if GameMoneyCenterModel[key] then
            return GameMoneyCenterModel[key].base_contribute_data
        end
    elseif dtype == "detail_contribute" then
        if GameMoneyCenterModel[key] then
            return GameMoneyCenterModel[key].detail_contribute_data
        end
    elseif dtype == "income_info" then
        return GameMoneyCenterModel.income_data
    elseif dtype == "spending_info" then
        return GameMoneyCenterModel.spending_data
    end
end

function GameMoneyCenterModel.ClearData(key, dtype)
    if dtype == "base_contribute" then
        if GameMoneyCenterModel[key] then
            GameMoneyCenterModel[key].base_contribute_data = nil
        end
    elseif dtype == "detail_contribute" then
        if GameMoneyCenterModel[key] then
            GameMoneyCenterModel[key].detail_contribute_data = nil
        end
    elseif dtype == "income_info" then
        GameMoneyCenterModel.income_data = nil
    elseif dtype == "spending_info" then
        GameMoneyCenterModel.spending_data = nil
    end
end

function GameMoneyCenterModel.query_son_base_contribute_info(son_id)
    local local_data = GameMoneyCenterModel.LoadData(son_id, "base_contribute")
    if local_data then
        local diff_time = os.time() - local_data.time
        if diff_time < update_data_time then
            GameMoneyCenterModel[son_id] = GameMoneyCenterModel[son_id] or {}
            GameMoneyCenterModel[son_id].base_contribute_data = local_data
            Event.Brocast("model_query_son_base_contribute_info_response")
        else
            --时间超过一小时更新数据
            Event.Brocast("model_update_contribute_info")
            GameMoneyCenterModel.ClearData(son_id, "base_contribute")
            GameMoneyCenterModel.ClearData(son_id, "detail_contribute")
            GameMoneyCenterModel.contribute_page_index = 1
            Network.SendRequest("query_son_base_contribute_info", {son_id = son_id}, "请求数据")
            Network.SendRequest("query_son_details_contribute_info", {son_id = son_id, page_index = GameMoneyCenterModel.contribute_page_index}, "请求数据")
        end
    else
        Network.SendRequest("query_son_base_contribute_info", {son_id = son_id}, "请求数据")
    end
end

function GameMoneyCenterModel.query_son_base_contribute_info_response(_, data)
    dump(data, "<color=green>query_son_base_contribute_info_response</color>")
    if data.result == 0 then
        local m_data = data
        m_data.time = os.time()
        GameMoneyCenterModel[m_data.son_id] = GameMoneyCenterModel[m_data.son_id] or {}
        GameMoneyCenterModel[m_data.son_id].base_contribute_data = m_data
        Event.Brocast("model_query_son_base_contribute_info_response")
    else
        HintPanel.ErrorMsg(data.result)
    end
end

function GameMoneyCenterModel.query_son_details_contribute_info(son_id, page_index)
    local local_data = GameMoneyCenterModel.LoadData(son_id, "detail_contribute")
    if local_data then
        local local_page_data = local_data[page_index]
        local diff_time = os.time() - local_data[1].time
        if diff_time < update_data_time then
            if local_page_data then
                GameMoneyCenterModel[son_id] = GameMoneyCenterModel[son_id] or {}
                GameMoneyCenterModel[son_id].detail_contribute_data = GameMoneyCenterModel[son_id].detail_contribute_data or {}
                GameMoneyCenterModel[son_id].detail_contribute_data[page_index] = local_page_data
                Event.Brocast("model_query_son_details_contribute_info_response", page_index)
            else
                GameMoneyCenterModel.contribute_page_index = page_index
                Network.SendRequest("query_son_details_contribute_info", {son_id = son_id, page_index = GameMoneyCenterModel.contribute_page_index}, "请求数据")
            end
        else
            --时间超过一小时更新数据
            print("<color=white>时间超过一小时更新数据</color>")
            Event.Brocast("model_update_contribute_info")
            GameMoneyCenterModel.ClearData(son_id, "base_contribute")
            GameMoneyCenterModel.ClearData(son_id, "detail_contribute")

            GameMoneyCenterModel.contribute_page_index = 1
            Network.SendRequest("query_son_base_contribute_info", {son_id = son_id}, "请求数据")
            Network.SendRequest("query_son_details_contribute_info", {son_id = son_id, page_index = GameMoneyCenterModel.contribute_page_index}, "请求数据")
        end
    else
        GameMoneyCenterModel.contribute_page_index = 1
        Network.SendRequest("query_son_details_contribute_info", {son_id = son_id, page_index = GameMoneyCenterModel.contribute_page_index}, "请求数据")
    end
end

function GameMoneyCenterModel.query_son_details_contribute_info_response(_, data)
    dump(data, "<color=green>query_son_details_contribute_info_response</color>")
    if data.result == 0 then
        if not data.detail_infos then
            LittleTips.Create("暂无新数据")
            return
        end
        local m_data = data
        if GameMoneyCenterModel[m_data.son_id] and GameMoneyCenterModel[m_data.son_id].base_contribute_data then
            m_data.time = GameMoneyCenterModel[m_data.son_id].base_contribute_data.time
        else
            m_data.time = os.time()
        end
        m_data.page_index = GameMoneyCenterModel.contribute_page_index

        GameMoneyCenterModel[m_data.son_id] = GameMoneyCenterModel[m_data.son_id] or {}
        GameMoneyCenterModel[m_data.son_id].detail_contribute_data = GameMoneyCenterModel[m_data.son_id].detail_contribute_data or {}
        GameMoneyCenterModel[m_data.son_id].detail_contribute_data[m_data.page_index] = m_data
        Event.Brocast("model_query_son_details_contribute_info_response", m_data.page_index)
        GameMoneyCenterModel.contribute_page_index = GameMoneyCenterModel.contribute_page_index + 1
    else
        HintPanel.ErrorMsg(data.result)
    end
end

function GameMoneyCenterModel.query_my_sczd_income_details(page_index)
    local local_data = GameMoneyCenterModel.LoadData("income", "income_info")
    if local_data then
        local local_page_data = local_data[page_index]
        local diff_time = os.time() - local_data[1].time
        if diff_time < update_data_time then
            if local_page_data then
                GameMoneyCenterModel.income_data = GameMoneyCenterModel.income_data or {}
                GameMoneyCenterModel.income_data[page_index] = local_page_data
                Event.Brocast("model_query_my_sczd_income_details_response", page_index)

                GameMoneyCenterModel.income_page_index = GameMoneyCenterModel.income_page_index + 1
            else
                GameMoneyCenterModel.income_page_index = page_index
                Network.SendRequest("query_my_sczd_income_details", {page_index = GameMoneyCenterModel.income_page_index}, "请求数据")
            end
        else
            --时间超过一小时更新数据
            print("<color=white>时间超过一小时更新数据</color>")
            Event.Brocast("model_update_income_info")
            GameMoneyCenterModel.ClearData("income", "income_info")
            GameMoneyCenterModel.income_page_index = 1
            Network.SendRequest("query_my_sczd_income_details", {page_index = GameMoneyCenterModel.income_page_index}, "请求数据")
        end
    else
        GameMoneyCenterModel.income_page_index = 1
        Network.SendRequest("query_my_sczd_income_details", {page_index = GameMoneyCenterModel.income_page_index}, "请求数据")
    end
end

function GameMoneyCenterModel.query_my_sczd_income_details_response(_, data)
    dump(data, "<color=green>query_my_sczd_income_details_response</color>")
    if data.result == 0 then
        if not data.detail_infos then
            LittleTips.Create("暂无新数据")
            return
        end
        local m_data = data
        if GameMoneyCenterModel.income_page_index == 1 then
            m_data.time = os.time()
        else
            m_data.time = GameMoneyCenterModel.income_data[1].time
        end
        m_data.page_index = GameMoneyCenterModel.income_page_index

        GameMoneyCenterModel.income_data = GameMoneyCenterModel.income_data or {}
        GameMoneyCenterModel.income_data[m_data.page_index] = m_data
        Event.Brocast("model_query_my_sczd_income_details_response", m_data.page_index)
        GameMoneyCenterModel.income_page_index = GameMoneyCenterModel.income_page_index + 1
    else
        HintPanel.ErrorMsg(data.result)
    end
end

function GameMoneyCenterModel.query_my_sczd_spending_details(page_index)
    local local_data = GameMoneyCenterModel.LoadData("spending", "spending_info")
    if local_data then
        local local_page_data = local_data[page_index]
        local diff_time = os.time() - local_data[1].time
        if diff_time < update_data_time then
            if local_page_data then
                GameMoneyCenterModel.spending_data = GameMoneyCenterModel.spending_data or {}
                GameMoneyCenterModel.spending_data[page_index] = local_page_data
                Event.Brocast("model_query_my_sczd_spending_details_response", page_index)

                GameMoneyCenterModel.spending_page_index = GameMoneyCenterModel.spending_page_index + 1
            else
                GameMoneyCenterModel.spending_page_index = page_index
                Network.SendRequest("query_my_sczd_spending_details", {page_index = GameMoneyCenterModel.spending_page_index}, "请求数据")
            end
        else
            --时间超过一小时更新数据
            print("<color=white>时间超过一小时更新数据</color>")
            Event.Brocast("model_update_spending_info")
            GameMoneyCenterModel.ClearData("spending", "spending_info")
            GameMoneyCenterModel.spending_page_index = 1
            Network.SendRequest("query_my_sczd_spending_details", {page_index = GameMoneyCenterModel.spending_page_index}, "请求数据")
        end
    else
        GameMoneyCenterModel.spending_page_index = 1
        Network.SendRequest("query_my_sczd_spending_details", {page_index = GameMoneyCenterModel.spending_page_index}, "请求数据")
    end
end

function GameMoneyCenterModel.query_my_sczd_spending_details_response(_, data)
    dump(data, "<color=green>query_my_sczd_spending_details_response</color>")
    if data.result == 0 then
        if not data.extract_infos then
            LittleTips.Create("暂无新数据")
            return
        end
        local m_data = data
        if GameMoneyCenterModel.spending_page_index == 1 then
            m_data.time = os.time()
        else
            m_data.time = GameMoneyCenterModel.spending_data[1].time
        end
        m_data.page_index = GameMoneyCenterModel.spending_page_index

        GameMoneyCenterModel.spending_data = GameMoneyCenterModel.spending_data or {}
        GameMoneyCenterModel.spending_data[m_data.page_index] = m_data
        Event.Brocast("model_query_my_sczd_spending_details_response", m_data.page_index)
        GameMoneyCenterModel.spending_page_index = GameMoneyCenterModel.spending_page_index + 1
    else
        HintPanel.ErrorMsg(data.result)
    end
end

function GameMoneyCenterModel.GetBaseContributeInfo(son_id)
    if GameMoneyCenterModel[son_id] then
        return GameMoneyCenterModel[son_id].base_contribute_data
    end
    return nil
end

function GameMoneyCenterModel.GetDetailContributeInfo(son_id, page_index)
    if GameMoneyCenterModel[son_id] and GameMoneyCenterModel[son_id].detail_contribute_data then
        return GameMoneyCenterModel[son_id].detail_contribute_data[page_index]
    end
    return nil
end

function GameMoneyCenterModel.GetIncomeInfo(page_index)
    if GameMoneyCenterModel.income_data then
        return GameMoneyCenterModel.income_data[page_index]
    end
    return nil
end

function GameMoneyCenterModel.GetSpendingInfo(page_index)
    if GameMoneyCenterModel.spending_data then
        return GameMoneyCenterModel.spending_data[page_index]
    end
    return nil
end

function GameMoneyCenterModel.GetPlayerSczdBaseInfo(son_id)
    if m_data.friend_list_map then
        return m_data.friend_list_map[son_id]
    end
    return nil
end

function GameMoneyCenterModel.GetIncomeSpendingTge()
    return this.UIConfig.tge
end

-- 获取财富中心的基础数据
function GameMoneyCenterModel.GetSCZDBaseInfo()
    Network.SendRequest("get_player_sczd_base_info", nil, "请求数据")
end

function GameMoneyCenterModel.on_get_player_sczd_base_info_response(_, data)
    dump(data, "<color=yellow>player_sczd_base_info_response</color>")
    if data.result == 0 then
        m_data.is_activce_profit = data.is_activate_bbsc_profit
        m_data.my_get_award = data.my_get_award
        m_data.my_all_son_count = data.my_all_son_count
        m_data.is_active_tglb1_profit = data.is_activate_tglb_profit
        m_data.goldpig_profit_cache = data.goldpig_profit_cache

        GameMoneyCenterModel.SetTGJJActivateData(data)
        m_data.is_new_player_sys = data.is_new_player_sys --是否是新的玩家系统
    else
        --HintPanel.ErrorMsg(data.result)
    end
    Event.Brocast("model_get_player_sczd_base_info_response")
end

function GameMoneyCenterModel.on_sczd_activate_change_msg(pName, data)
    dump(data, "<color=yellow>on_sczd_activate_change_msg</color>")
    GameMoneyCenterModel.SetTGJJActivateData(data)
    Event.Brocast("model_on_sczd_activate_change_msg")
end

--推广奖金激活状态
function GameMoneyCenterModel.SetTGJJActivateData(data)
    m_data.is_activate_xj_profit = data.is_activate_xj_profit or 0
    m_data.is_activate_xj_profit2 = data.is_activate_xj_profit2 or 0
    m_data.is_activate_xj_profit3 = data.is_activate_xj_profit3 or 0
    m_data.is_active_tglb1_profit = data.is_activate_tglb_profit or 0
    m_data.is_activate_bisai_profit = data.is_activate_bisai_profit or 0
    m_data.is_activate_gjhhr = data.is_activate_gjhhr or 0
    m_data.xj_award_num = data.xj_award_num or 0
    m_data.bisai_award_num = data.bisai_award_num or 0
    m_data.vip_lb_award_num = data.vip_lb_award_num or 0
    m_data.is_buy_goldpig1_old = data.is_buy_goldpig1_old or 0
    m_data.goldpig1_award_num = data.goldpig1_award_num or 0
    m_data.goldpig2_award_num = data.goldpig2_award_num or 0
    Event.Brocast("UpdataHallMoneyCenterRedHint")
end

-- 截取数据段
local cutdata = function(data, a, b)
    local list = {}
    if data then
        local len = #data
        for i = a, b do
            if i > len then
                break
            end
            list[#list + 1] = data[i]
        end
    end
    return list
end

local friend_page_num = 20
-- 获取财富中心的好友数据
-- 排序类型 ，1 为贡献值 升序 ，2 贡献值降序 3 注册时间升序 4 注册时间降序
function GameMoneyCenterModel.GetSCZDFriend(page_index, sort_type)
    if false then
        m_data.friend_page_index = page_index
        m_data.friend_page_num = friend_page_num

        if not m_data.friend_list or (m_data.friend_list and #m_data.friend_list < 60) then
            local data = {}
            data.result = 0
            data.is_clear_old_data = 0
            data.son_main_infos = {}
            local list = {}
            for i = 1, 20 do
                local v = {}
                v.id = math.random(1, 99999)
                v.name = "名字" .. math.random(100, 999)
                v.is_have_login = 0
                v.my_all_gx = math.random(100, 999)
                v.m_register_time = os.time() - math.random(3600, 360000)
                v.last_login_time = os.time() - math.random(3600, 360000)
                data.son_main_infos[#data.son_main_infos + 1] = v
            end
            Event.Brocast("query_my_son_main_info_response", "query_my_son_main_info_response", data)
        else
            local data = {}
            data.result = 0
            data.is_clear_old_data = 0
            data.son_main_infos = {}
            Event.Brocast("query_my_son_main_info_response", "query_my_son_main_info_response", data)
        end
        return
    end
    local local_data
    if GameMoneyCenterModel.friend_time then
        local_data = GameMoneyCenterModel.friend_time[page_index]
    end
    if local_data then
        local diff_time = os.time() - local_data.time
        if diff_time < update_data_time then
            local list = cutdata(m_data.friend_list, (page_index - 1) * friend_page_num + 1, page_index * friend_page_num)
            Event.Brocast("model_query_my_son_main_info_response", list, 0)
        else
            GameMoneyCenterModel.friend_time = nil
            m_data.friend_page_index = 1
            m_data.friend_page_num = friend_page_num
            Network.SendRequest("query_my_son_main_info", {sort_type = sort_type, page_index = page_index}, "请求数据")
        end
    else
        m_data.friend_page_index = page_index
        m_data.friend_page_num = friend_page_num
        Network.SendRequest("query_my_son_main_info", {sort_type = sort_type, page_index = page_index}, "请求数据")
    end
end

function GameMoneyCenterModel.on_query_my_son_main_info_response(_, data)
    dump(data, "<color=green>on_query_my_son_main_info_response</color>")
    if data.result == 0 then
        local is_clear_old_data
        if not GameMoneyCenterModel.friend_time then
            is_clear_old_data = 1
        end
        if data.is_clear_old_data == 1 then
            is_clear_old_data = 1
            m_data.friend_list = {}
            m_data.friend_page_index = 1
            GameMoneyCenterModel.friend_time = {}
        end
        if m_data.friend_list and next(m_data.friend_list) then
            if data.son_main_infos and next(data.son_main_infos) then
                for k, v in ipairs(data.son_main_infos) do
                    if not m_data.friend_list_map[v.id] then
                        table.insert(m_data.friend_list, v)
                        m_data.friend_list_map[v.id] = v
                    else
                        m_data.friend_list_map[v.id] = v
                        for k1, v1 in ipairs(m_data.friend_list) do
                            if v1.id == v.id then
                                m_data.friend_list[k1] = v
                                break
                            end
                        end
                    end
                end
            end
        else
            m_data.friend_list_map = {}
            m_data.friend_list = data.son_main_infos
            for k, v in ipairs(data.son_main_infos) do
                m_data.friend_list_map[v.id] = v
            end
        end
        if not GameMoneyCenterModel.friend_time then
            GameMoneyCenterModel.friend_time = {}
        end
        local page_index = m_data.friend_page_index
        local page_num = m_data.friend_page_num
        GameMoneyCenterModel.friend_time[page_index] = {time = os.time()}
        local list = cutdata(m_data.friend_list, (page_index - 1) * page_num + 1, page_index * page_num)
        Event.Brocast("model_query_my_son_main_info_response", list, is_clear_old_data)
    else
        HintPanel.ErrorMsg(data.result)
    end
end

function GameMoneyCenterModel:on_tglb_profit_activate(data)
    dump(data, "<color=yellow>on_tglb_profit_activate</color>")
    m_data.is_active_tglb1_profit = data.is_active_tglb1_profit
    GameMoneyCenterModel.GoldpigProfitCacheChange(0)
    Event.Brocast("model_tglb_profit_activate")
end

----------------------------------------------------测试数据
function GameMoneyCenterModel.GetcontributeBaseTestData(son_id)
    if not GameMoneyCenterModel.contribute_data then
        local data = {}
        data.result = 0
        data.son_id = son_id
        data.son_tgli_gx = math.random(100, 999)
        data.son_bbsc_gx = math.random(100, 999)
        data.son_bbsc_progress = math.random(1, 7)
        Event.Brocast("query_son_base_contribute_info_response", "query_son_base_contribute_info_response", data)
    else
        local data = {}
        data.result = 1
        Event.Brocast("query_son_base_contribute_info_response", "query_son_base_contribute_info_response", data)
    end
end

local contribute_page_num = 20
function GameMoneyCenterModel.GetcontributeTestData(son_id, page_index)
    if not GameMoneyCenterModel.contribute_data or (GameMoneyCenterModel.contribute_data and #GameMoneyCenterModel.contribute_data < 3) then
        local data = {}
        data.result = 0
        data.son_id = son_id
        data.detail_infos = {}
        local list = {}
        for i = 1, contribute_page_num do
            local v = {}
            v.id = math.random(1, 99999)
            v.name = "名字" .. math.random(100, 999)
            v.treasure_type = math.random(1, 101)
            v.treasure_value = math.random(100, 999)
            v.time = os.time()
            v.is_active = math.random(1, 2) - 1
            data.detail_infos[#data.detail_infos + 1] = v
        end
        Event.Brocast("query_son_details_contribute_info_response", "query_son_details_contribute_info_response", data)
    else
        local data = {}
        data.result = 0
        Event.Brocast("query_son_details_contribute_info_response", "query_son_details_contribute_info_response", data)
    end
end

local income_page_num = 20
function GameMoneyCenterModel.GetIncomeTestData(page_index)
    if not GameMoneyCenterModel.income_data or (GameMoneyCenterModel.income_data and #GameMoneyCenterModel.income_data < 3) then
        local data = {}
        data.result = 0
        data.detail_infos = {}
        local list = {}
        for i = 1, income_page_num do
            local v = {}
            v.id = math.random(1, 99999)
            v.name = "名字" .. math.random(100, 999)
            v.treasure_value = math.random(100, 700)
            v.treasure_type = math.random(1, 7)
            v.time = os.time()
            v.is_active = math.random(0, 1)
            data.detail_infos[#data.detail_infos + 1] = v
        end
        Event.Brocast("query_my_sczd_income_details_response", "query_my_sczd_income_details_response", data)
    else
        local data = {}
        data.result = 0
        Event.Brocast("query_my_sczd_income_details_response", "query_my_sczd_income_details_response", data)
    end
end

local spending_page_num = 20
function GameMoneyCenterModel.GetspendingTestData(page_index)
    if not GameMoneyCenterModel.spending_data or (GameMoneyCenterModel.spending_data and #GameMoneyCenterModel.spending_data < 3) then
        local data = {}
        data.result = 0
        data.extract_infos = {}
        local list = {}
        for i = 1, spending_page_num do
            local v = {}
            v.id = math.random(1, 99999)
            v.extract_value = math.random(100, 700)
            v.extract_time = os.time()
            data.extract_infos[#data.extract_infos + 1] = v
        end
        Event.Brocast("query_my_sczd_spending_details_response", "query_my_sczd_spending_details_response", data)
    else
        local data = {}
        data.result = 0
        Event.Brocast("query_my_sczd_spending_details_response", "query_my_sczd_spending_details_response", data)
    end
end

function GameMoneyCenterModel.GetGoldPigCacheData()
    return m_data.goldpig_profit_cache
end

function GameMoneyCenterModel:goldpig_profit_cache_change(data)
    dump(data, "<color=yellow>goldpig_profit_cache_change</color>")
    GameMoneyCenterModel.GoldpigProfitCacheChange(data.now_goldpig_profit_cache)
end

function GameMoneyCenterModel.GoldpigProfitCacheChange(now_goldpig_profit_cache)
    m_data.goldpig_profit_cache = now_goldpig_profit_cache
    Event.Brocast("model_goldpig_profit_cache_change")
end

function GameMoneyCenterModel.search_son_by_id_response(_, data)
    dump(data, "<color=green>search_son_by_id_response</color>")
    if data.result == 0 then
        m_data.search_son_info = data.son_info
        Event.Brocast("model_search_son_by_id_response")
    else
        HintPanel.ErrorMsg(data.result)
    end
end

function GameMoneyCenterModel.GetSearchSonInfoData()
    return m_data.search_son_info
end

function GameMoneyCenterModel.ClearSearchSonInfoData()
    m_data.search_son_info = {}
end

function GameMoneyCenterModel.CheckIsNewPlayerSys()
    return false
    -- return m_data.is_new_player_sys and m_data.is_new_player_sys == 1
end

function GameMoneyCenterModel.query_sczd_total_rebate_value_response(_,data)
    dump(data, "<color=green>model_query_sczd_total_rebate_value_response</color>")
    if data.result == 0 then
        m_data.rebate_value  = data.rebate_value / 100
        Event.Brocast("model_query_sczd_total_rebate_value_response")
    else
        HintPanel.ErrorMsg(data.result)
    end
end

function GameMoneyCenterModel.GetRebateValue()
    return m_data.rebate_value
end

HandleLoadChannelLua("GameMoneyCenterModel", nil)
