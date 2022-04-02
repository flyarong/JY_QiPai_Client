-- 创建时间:2018-08-13

local basefunc = require "Game.Common.basefunc"
LookBackModel = {}
local this
local m_data
local lister
local lookback_kaijiang_data
local lookback_base_data
local function MakeLister()
    lister = {}
    lister["query_znq_look_back_kaijiang_base_info_response"] =this.is_show_look_back
    lister["query_znq_look_back_base_info_response"] =this.on_get_look_back_base_info
end
local function AddLister()
    for msg,cbk in pairs(lister) do
        Event.AddListener(msg, cbk)
    end
end

function LookBackModel.on_get_look_back_base_info(_,data)
    dump(data,"<color=red>on_get_look_back_base_info</color>")
   this.lookback_base_data=data  
end


function LookBackModel.is_show_look_back(_,data)
    dump(data,"<color=red>is_show_look_back</color>")
    this.lookback_kaijiang_data = data
end

function LookBackModel.GetLookbackKaiJiangData()
    return  this.lookback_kaijiang_data
end

function LookBackModel.GetLookbackBaseData()
    return  this.lookback_base_data
end

local function RemoveLister()
    for msg,cbk in pairs(lister) do
        Event.RemoveListener(msg, cbk)
    end
    lister=nil
end
local function InitData()
	LookBackModel.data={}
end
local  function SendReq()
    Network.SendRequest("query_znq_look_back_kaijiang_base_info")
    Network.SendRequest("query_znq_look_back_base_info")
end

function LookBackModel.Init()
    InitData()
    this=LookBackModel
    MakeLister()
    AddLister()
    SendReq()
    return this
end



function LookBackModel.Exit()
    if this then
        RemoveLister()
        this=nil
        m_data=nil
    end
end

local GetActivityRedKey = function (id)
    return "ActivityYearRedKey_UserID" .. MainModel.UserInfo.user_id .. "_ID" .. id
end

function LookBackModel.GetActiveTagData(tag)
    local tagMap = {"activity", "notice"}
    local tagStr = tagMap[tag]

    local data = {}
    local nowT = os.time()
    for k,v in ipairs(LookBackModel.UIConfig.config) do
        if v.type == tagStr and v.isOnOff == 1 and ((v.beginTime == -1 or nowT >= v.beginTime) and (v.endTime == -1 or nowT <= v.endTime)) then
            if not v.shop_id or MainModel.GetGiftShopShowByID(v.shop_id) then
                if v.ID == 1 then
                    if LookBackModel.GetLookbackKaiJiangData() == nil or LookBackModel.GetLookbackKaiJiangData().is_show == 0 or LookBackModel.GetLookbackBaseData()==nil or LookBackModel.GetLookbackBaseData().result ~= 0 then
                        dump(LookBackModel.GetLookbackKaiJiangData())
                        dump(LookBackModel.GetLookbackBaseData())
                        print("<color=yellow>不符合回馈用户条件</color>")
                    else                    
                        local a = {}
                        a.configId = k
                        a.order = v.order
                        data[#data + 1] = a
                    end
                else
                    local a = {}
                    a.configId = k
                    a.order = v.order
                    data[#data + 1] = a
                end
            end
        end
    end
    return data
end