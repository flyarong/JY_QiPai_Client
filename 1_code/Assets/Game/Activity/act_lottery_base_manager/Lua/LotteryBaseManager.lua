local basefunc = require "Game/Common/basefunc"
LotteryBaseManager = {}
local M = LotteryBaseManager
local this
local m_data
local lister
local total_num
local my_num
local UnShowChannel_List = { "pceggs", "xianwan", "xiaozhuo" }

--☆--☆--☆--☆--☆--☆--☆--☆--☆--☆--☆--☆--☆--☆--☆
local types_data_map = {
	-- {
	-- 	type = "gratitude_propriety",
	-- 	start_time = 1574724600,
    -- 	end_time = 1575302399, 
    --  config = HotUpdateConfig("Game.CommonPrefab.Lua.activity_geyl_config"),
    -- },
    -- {
	-- 	type = "snowball_battle",
	-- 	start_time = 1575329400,
    -- 	end_time = 1575907199, 
    --  config = HotUpdateConfig("Game.CommonPrefab.Lua.activity_xqdzz_config"),
    -- },
    
}
--☆--☆--☆--☆--☆--☆--☆--☆--☆--☆--☆--☆--☆--☆--☆

local function MakeLister()
	lister = {}
	lister["OnLoginResponse"] = this.OnLoginResponse
    lister["common_lottery_base_info_change"] = this.on_common_lottery_base_info_change
    lister["query_common_lottery_base_info_response"] = this.on_query_common_lottery_base_info_response
    lister["common_lottery_kaijaing_response"] = this.on_common_lottery_kaijaing_response
    lister["common_lottery_get_round_lottery_num_response"] = this.on_common_lottery_get_round_lottery_num_response
    lister["common_lottery_get_my_lottery_num_response"] = this.on_common_lottery_get_my_lottery_num_response
    lister["common_lottery_my_lottery_num_change"] = this.on_common_lottery_my_lottery_num_change
end

local function AddLister()
    for msg, cbk in pairs(lister) do
        Event.AddListener(msg, cbk)
    end
end

local function RemoveLister()
    if lister == nil then return end
    for msg, cbk in pairs(lister) do
        Event.RemoveListener(msg, cbk)
    end
    lister = nil
end

local function InitData()
    M.data = {}
    m_data = M.data
    total_num = {}
    my_num = {}
end

function M.Init()
    M.Exit()
    this = M
    InitData()
    MakeLister()
	AddLister()
    return this
end

function M.Exit()
    if this then
        RemoveLister()
        m_data = nil
        this = nil
    end
end

function M.AddQuery(data)
    types_data_map[#types_data_map + 1] = data 
end 

function M.IsRightChannel()
    for i = 1, #UnShowChannel_List do
        if MainModel.GetMarketChannel() == UnShowChannel_List[i] then 
            return false
        end 
    end
    return true
end

function M.OnLoginResponse(result)
    if result == 0 then 
        M.SendQuery()
    end
end

function M.SendQuery()
    print("<color>开始请求数据</color>")
    dump(types_data_map,"开始请求数据")
	for i = 1,#types_data_map do
		if os.time() > types_data_map[i].start_time and os.time() < types_data_map[i].end_time then 
            Network.RandomDelayedSendRequest("query_common_lottery_base_info", {lottery_type = types_data_map[i].type})
            -- Network.SendRequest("common_lottery_get_round_lottery_num", {lottery_type = types_data_map[i].type})
            -- Network.SendRequest("common_lottery_get_my_lottery_num", {lottery_type = types_data_map[i].type})
		end 
	end	
end

function M.on_common_lottery_base_info_change(_,data)
	m_data[data.lottery_type] = data
	Event.Brocast("get_one_common_lottery_info")
end

function M.on_query_common_lottery_base_info_response(_,data)
	if data.result == 0 and  data.lottery_type then 
		m_data[data.lottery_type] = data
		Event.Brocast("get_one_common_lottery_info")
    end
end
--请求全服还剩下多少个
function M.on_common_lottery_get_round_lottery_num_response(_,data)
    dump(data,"<color=red>全服各种物品获得次数</color>")
    if data.result == 0 and  data.lottery_type then 
        total_num[data.lottery_type] = data
        Event.Brocast("total_lottery_num_get")
    end 
end
--请求个人抽奖次数
function M.on_common_lottery_get_my_lottery_num_response(_,data)
    dump(data,"<color=red>个人各种物品获得次数</color>")
    if data.result == 0 and  data.lottery_type then
        my_num[data.lottery_type] = data
        Event.Brocast("preson_lottery_num_get")     
    end 
end
--个人抽奖次数改变
function M.on_common_lottery_my_lottery_num_change(_,data)
    -- dump(data,"<color=red>个人各种物品获得次数</color>")
    if  data.lottery_type then
        my_num[data.lottery_type] = data 
        Event.Brocast("preson_lottery_num_change")
    end 
end

function M.on_common_lottery_kaijaing_response(_,data)
    if data and data.result ~= 0 then 
        HintPanel.ErrorMsg(data.result)
    end 
end
--得到基础数据
function M.GetData(type)
    if type then
        if table_is_null(m_data[type]) then 
            return false
        else
            return m_data[type]
        end 
    else
        if table_is_null(m_data) then 
            return false
        else
            return m_data
        end 		
	end 
end
--获取全服各物品一共领了多少次数
function M.GetTotalNum(type)
    if type then
        if table_is_null(total_num[type]) then 
            return false
        else
            return total_num[type]
        end 
    else
        if table_is_null(total_num) then 
            return false
        else
            return total_num
        end 		
	end 
end 
--获取自己各物品一共领了多少次数
function M.GetPresonNum(type)
    if type then
        if table_is_null(my_num[type]) then 
            return false
        else
            return my_num[type]
        end 
    else
        if table_is_null(my_num) then 
            return false
        else
            return my_num
        end 		
	end 
end 
--是否有奖励可以领取,注意，按照顺序领取时，可用这个方法
function M.IsAwardCanGet(type,config)
    dump(m_data,"m_data")
    dump(type,"type")
    if m_data[type] then 
        for i = 1,#types_data_map do
            if types_data_map[i].type == type then
                local c = types_data_map[i].config or config
                if m_data[type].now_game_num >= #c.Award then 
                    return false
                else
                    if m_data[type].ticket_num >= c.Award[m_data[type].now_game_num + 1].need_credits then
                        return true
                    else
                        return false
                    end 
                end 
            end 
        end
    end
    return false
end

function M.GetConfigByType(type)
    if type then
        for i=1,#types_data_map do
           if types_data_map[i].type == type then 
                return types_data_map[i].config
           end 
        end
    end 
end

--雪球大作战或类型情况下的检测是否有奖励可以领取
function M.IsAwardCanGet_XQDZZ(type)
    dump(m_data,"m_data")
    dump(type,"type")
    dump(my_num,"my_num")
    dump(total_num,"total_num")
    if m_data[type] and total_num[type] and my_num[type] then 
        local min_need_and_exist = -1  -- 最小还没有兑换完的奖励
        local MNAE = min_need_and_exist
        local config =  M.GetConfigByType(type)
        for i = 1,#total_num[type].lottery_num  do
           if config.Award[i].award_total - total_num[type].lottery_num[i] >= 1 
            and config.Award[i].person_total - my_num[type].lottery_num[i] >= 1  then
                MNAE = i
                break
            end 
        end
        if  MNAE == -1 then 
            return false
        elseif m_data[type].ticket_num >= config.Award[MNAE].award_need then 
            return true
        end 
    end
    return false 
end
