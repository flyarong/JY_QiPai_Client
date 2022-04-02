-- 创建时间:2020-06-22
-- GameComRankManager 管理器

local basefunc = require "Game/Common/basefunc"
GameComRankManager = {}
local M = GameComRankManager
local this
local lister
local Rank_Types = {
    --存储使用通用排行的类型    
}

local Local_Datas = {
    --本地存储的个人排行榜数据   
}

local Rank_Datas = {
    --本地存储的排行榜数据   
}

--[[Rank_Type:{
    base_data = {}
    last_refresh_time = int
}--]]

local function AddLister()
    for msg,cbk in pairs(lister) do
        Event.AddListener(msg, cbk)
    end
end

local function RemoveLister()
    if lister then
        for msg,cbk in pairs(lister) do
            Event.RemoveListener(msg, cbk)
        end
    end
    lister=nil
end

local function MakeLister()
    lister = {}
    lister["OnLoginResponse"] = this.OnLoginResponse
    lister["query_rank_base_info_response"] = this.on_query_rank_base_info_response
    lister["ReConnecteServerSucceed"] = this.OnReConnecteServerSucceed
end

function M.Init()
	M.Exit()

	this = GameComRankManager
	this.m_data = {}
	MakeLister()
    AddLister()
	M.InitUIConfig()
end

function M.Exit()
	if this then
		RemoveLister()
		this = nil
	end
end

function M.InitUIConfig()
    this.UIConfig = {}
end

function M.OnLoginResponse(result)
	if result == 0 then
        for k ,v in pairs(Rank_Types) do
            Network.SendRequest("query_rank_base_info",{rank_type = v})
        end
	end
end

function M.OnReConnecteServerSucceed()

end

function M.AddQuery(RankType)
    Rank_Types[#Rank_Types + 1] = RankType
end

--生成子物体(类型,绑定函数)
function M.GetRankInfoTodo(rank_type,bind_func,page_index)
    local space_time = 60
    if Rank_Datas[rank_type] and Rank_Datas[rank_type][page_index] and Rank_Datas[rank_type][page_index].last_refresh_time + space_time > os.time() then
        bind_func(Rank_Datas[rank_type][page_index].base_data)
    else
        Network.SendRequest("query_base_info",{rank_type = rank_type},function (data)
            if data and data.result == 0 then  
                M.AddRankData(data)
                M.GetRankInfoTodo(rank_type,bind_func,page_index)
            end
        end)
    end
end

function M.GetMyInfoTodo(rank_type,bind_func)
    --10秒之内数据不请求
    local space_time = 10
    if Local_Datas[rank_type] and Local_Datas[rank_type].last_refresh_time + space_time > os.time() then
        bind_func(Local_Datas[rank_type].base_data)
    else
        Network.SendRequest("query_rank_base_info",{rank_type = rank_type},function (data)
            if data and data.result == 0 then
                M.AddBaseData(data)
                M.GetMyInfoTodo(rank_type,bind_func)
            end
        end)
    end
end

-- result 0 : integer                     # 0 成功
-- rank_type 1 : string				   # 排行榜类型
-- score 2 : string           		       # 我的分数
-- rank 3 : integer                       # 排名 ， -1表示未上榜
-- other_data 4 : string                  # 其他数据 

function M.on_query_rank_base_info_response(_,data)
    if data and data.result == 0 then     
        M.AddBaseData(data)
    end
end

function M.on_query_rank_data_response(_,data)
    if data and data.result == 0 then
        M.AddRankData(data)
    end
end

function M.AddBaseData(data)
    local t = {}
    t.base_data = data
    t.last_refresh_time = os.time()
    Local_Datas[data.rank_type] = t
end

function M.AddRankData(data)
    local t = {}
    t.rank_data = data
    t.last_refresh_time = os.time()
    Rank_Datas[data.rank_type][data.page_index] = t
end

function M.GetMyInfoData(rank_type)
    if Local_Datas[rank_type] then
        return Local_Datas[rank_type].base_data
    end
end

function M.GetRankData(rank_type)
    if Rank_Datas[rank_type] then
        return Rank_Datas[rank_type].base_data
    end
end