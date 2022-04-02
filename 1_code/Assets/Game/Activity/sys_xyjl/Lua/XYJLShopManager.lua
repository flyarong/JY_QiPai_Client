-- 2019/11/12
local basefunc = require "Game/Common/basefunc"
XYJLShopManager = {}
local M = XYJLShopManager
local this
local lister
local m_data = {}
local function MakeLister()
	lister = {}
	lister["get_accurate_gift_bag_response"] = this.on_get_accurate_gift_bag_response
	lister["accurate_gift_bag_change_msg"] = this.on_accurate_gift_bag_change_msg
    lister["finish_gift_shop"] = this.on_finish_gift_shop
    lister["OnLoginResponse"] = this.OnLoginResponse
end

local function AddLister()
    for msg,cbk in pairs(lister) do
        Event.AddListener(msg, cbk)
    end
end
local function RemoveLister()
    if lister == nil then return end
    for msg,cbk in pairs(lister) do
        Event.RemoveListener(msg, cbk)
    end
    lister=nil
end
local function InitData()
	M.data={}
	m_data = M.data
end
function M.Init()
    M.Exit()
    this=M
    InitData()
    MakeLister()
    AddLister()
    return this
end

function M.Exit()
    if this then
        RemoveLister()
        m_data=nil
        this=nil
    end
end

function M.OnLoginResponse(result)
    if result ~= 0 then return end
    M.SendQuary()
end

function M.SendQuary()
	Network.SendRequest("get_accurate_gift_bag")
end

function M.on_accurate_gift_bag_change_msg(_,data)
    dump(data,"<color=red>精准礼包数据改变</color>")
    m_data = data
    M.MixConfigWithData()
    Event.Brocast("Refresh_XYJL_UI")
end

function M.on_get_accurate_gift_bag_response(_,data)
    dump(data,"<color=red>请求的精准推送的礼包</color>")
    m_data = data
    M.MixConfigWithData()
    Event.Brocast("Refresh_XYJL_UI")
end

function M.on_finish_gift_shop()
    M.MixConfigWithData()
    Event.Brocast("Refresh_XYJL_UI")
end

function M.GetData()
    if  table_is_null(m_data) or table_is_null(m_data.gift_bag) then --如果m_data是个空表，那么返回nil，勿直接设m_data为nil
        return nil
    end
    return m_data
end

function M.GetMaxTime()
    local time = nil
    if not table_is_null(m_data) then 
        for i=1,#m_data.gift_bag do
            local t = tonumber(m_data.gift_bag[i].end_time) 
            if time == nil then time = t end
            if t > time then 
                time = t
            end 
        end
    end 
    return time or os.time()
end

function M.GetMinTime()
    local time = nil
    if not table_is_null(m_data) then 
        for i=1,#m_data.gift_bag do
            local t = tonumber(m_data.gift_bag[i].start_time) 
            if time == nil then time = t end
            if  t  < time then 
                time = t
            end 
        end
    end 
    return time or os.time()
end

function M.MixConfigWithData(data)
    data = data or m_data.gift_bag
    if not table_is_null(data) then 
        for i=1,#data do
            local c = MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, data[i].id)
            local s = MainModel.GetGiftShopStatusByID(c.id)
            data[i].config = c
            data[i].status = s
        end
    end
    return data  
end

XYJLShopManager.Init()