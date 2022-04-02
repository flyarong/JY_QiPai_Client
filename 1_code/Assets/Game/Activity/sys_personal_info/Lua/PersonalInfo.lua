PersonalInfo = {}
PersonalInfo.ChinaList = {}
local this


--个人信息回调 {func,needData}
local personalInfoCbk

local lister
local function AddLister()
    lister={}
    lister["query_shipping_address_response"] = this.OnQueryShippingAddressResponse
    lister["get_statistics_player_match_response"] = this.OnGetStatisticsPlayerMatchDdzResponse
    lister["query_win_rate_response"] = this.on_query_win_rate_response
    for msg,cbk in pairs(lister) do
        Event.AddListener(msg, cbk)
    end
end

local function RemoveLister()
    for msg,cbk in pairs(lister) do
        Event.RemoveListener(msg, cbk)
    end
    lister=nil
end


--显示个人信息
function PersonalInfo.Init()
    this = PersonalInfo

    AddLister()

    -- 三层 province city area
    local ChinaList = {}
    local ChinaCityDict = {}
    for k,v in ipairs(cityconfig.config) do
        if v.qu then
            if not ChinaCityDict[v.name] then
                ChinaCityDict[v.name] = {}
            end
            if not ChinaCityDict[v.name][v.city] then
                ChinaCityDict[v.name][v.city] = {}
            end
            local t = {}
            t.area = v.qu
            t.code = v.code
            t.id = v.id
            ChinaCityDict[v.name][v.city][v.qu] = t
        end
    end

    -- 省
    for k,v in pairs(ChinaCityDict) do
        local t = {}
        ChinaList[#ChinaList + 1] = t

        -- 省的名称
        t.name = k
        t.list = {}
        -- 市
        for k1,v1 in pairs(v) do
            local t1 = {}
            -- 市的列表
            t.list[#t.list + 1] = t1

            -- 市的名称
            t1.name = k1
            t1.list = {}
            -- 县
            for k2,v2 in pairs(v1) do
                local t3 = {}
                t3.name = k2
                t3.code = v2.code
                t1.list[#t1.list + 1] = t3
                if not t.sort then
                    t.sort = tonumber(v2.id)
                end
            end
        end
    end
    ChinaList = MathExtend.SortList(ChinaList, "sort", true)
    PersonalInfo.ChinaList = ChinaList
end

--关闭个人信息
function PersonalInfo.Exit()

    if this then

        RemoveLister()

        personalInfoCbk=nil

        this = nil

    end

end

--[[请求玩家个人信息
    数据通过cbk返回过去
    cbk 会被调用多次，每次都会给某一部分的数据
]]
function PersonalInfo.ReqPersonalInfo()

    MainModel.GetVerifyStatus(function ()
        local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key="drt_block_real_name_verify", is_on_hint = true}, "CheckCondition")
        if (not a or (a and not b)) and GameGlobalOnOff.Certification then
            Event.Brocast("update_verifide")
	end
    end)

    MainModel.GetBindPhone(function ()    
        if GameGlobalOnOff.BindingPhone then
            Event.Brocast("update_query_bind_phone")
	end
    end)

    Network.SendRequest("get_statistics_player_match")
    Network.SendRequest("query_win_rate")
end

function PersonalInfo.OnQueryShippingAddressResponse(_,data)

    if data.result == 0 then
        MainModel.UserInfo.shipping_address = data.shipping_address
        Event.Brocast("update_shipping_address")
    else
        HintPanel.ErrorMsg(data.result)
    end
end

function PersonalInfo.OnGetStatisticsPlayerMatchDdzResponse(_,data)

    if data.result == 0 then
        Event.Brocast("update_playerinfo_match", data)
    else
        HintPanel.ErrorMsg(data.result)
    end
end

function PersonalInfo.on_query_win_rate_response(_,data)

    if data.result == 0 then
        Event.Brocast("update_playerinfo_win", data)
    else
        HintPanel.ErrorMsg(data.result)
    end
end

