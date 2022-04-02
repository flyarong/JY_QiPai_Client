-- 创建时间:2018-08-06
local UIConfig = SysRoomCardManager.UIConfig

RoomCardModel = {}

local this
local m_data
local lister
--游戏类型映射
RoomCardModel.RoomCardGameTypeTable = {
    nor_mj_xzdd = "game_MjXzFK3D",
    game_MjXzFK3D = "nor_mj_xzdd",

    nor_ddz_nor = "game_DdzFK",
    game_DdzFK = "nor_ddz_nor",
    nor_ddz_lz = "game_DdzFK",
    game_DdzLZFK = "nor_ddz_lz",
}


local function MakeLister()
    lister = {}
    lister["friendgame_get_all_history_record_response"] = this.friendgame_get_all_history_record_response
    lister["friendgame_get_history_record_ids_response"] = this.friendgame_get_history_record_ids_response
    lister["friendgame_get_history_record_response"] = this.friendgame_get_history_record_response
end
local function AddLister()
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
local function InitData()
	RoomCardModel.data={}
end
function RoomCardModel.Init()
    InitData()
    this=RoomCardModel

    this.InitUIConfig()
    MakeLister()
    AddLister()

    return this
end
function RoomCardModel.Exit()
    if this then
        RemoveLister()
        this=nil
        m_data=nil
    end
end
function RoomCardModel.InitUIConfig()
    this.UIConfig={
	    areagame = {},
        rule = {},
        config = {},
        ruleNameMap = {},
    }
    this.UIConfig.areagame = UIConfig.areagame
    this.UIConfig.config = UIConfig.config

    for i,rl_it in ipairs(UIConfig.rule) do
        local rule_cfg = {}
        for ri,r_id in ipairs(rl_it.rule_item) do
            rule_cfg[ri]={}
            rule_cfg[ri].title = UIConfig.rule_item[r_id].title
            rule_cfg[ri].desc = UIConfig.rule_item[r_id].desc
            rule_cfg[ri].data={}
            for di,d_id in ipairs(UIConfig.rule_item[r_id].data) do
                rule_cfg[ri].data[di]=UIConfig.options[d_id]
                rule_cfg[ri].data[di].id=nil
            end
        end
        this.UIConfig.rule[i]=rule_cfg
    end

    local nn = 1
    for k,v in ipairs(this.UIConfig.rule) do
        for k1,v1 in ipairs(v) do
            for k2,v2 in ipairs(v1.data) do
                for k3,v3 in ipairs(v2.serV) do
                    local d = {}
                    d.name = v2.names[k3]
                    d.sort = nn
                    this.UIConfig.ruleNameMap[v3] = d
                    nn = nn + 1
                end
            end
        end
    end
end

--------------------------------账单-----------------------------------------------
local function test_all_data()
    local data = {}
    data.result = 0
    data.records = {}
    for i=1,10 do
        data.records[i] = {}
        data.records[i] = {}
        data.records[i].id = i
        data.records[i].game_name = "第" .. i .. "场"
        data.records[i].time = os.time()
        data.records[i].room_no = i
        data.records[i].player_infos = {}
        for k=1,3 do
            data.records[i].player_infos[k] = {}
            data.records[i].player_infos[k].name = "玩家名字"
            data.records[i].player_infos[k].head_link  = nil
            data.records[i].player_infos[k].score   = 1000
        end
    end
    return data
end

local function test_data(id)
    local data = {}
    data.result = 0
    data.record = {}
    data.record.id = id
    data.record.game_name = "第" .. id .. "场"
    data.record.time = os.time()
    data.record.room_no = id
    data.record.player_infos = {}
    for i=1,3 do
        data.record.player_infos[i] = {}
        data.record.player_infos[i].name = "玩家名字"
        data.record.player_infos[i].head_link  = nil
        data.record.player_infos[i].score   = 1000
    end
    return data
end

local function test_ids()
    local data = {}
    data.result = 0
    data.list = {}
    for i=1,10 do
        data.list[i] = i
    end
    return data
end
--[[
    @desc: 请求所有账单id,和本地文件进行交叉比对
    author:{ganshuangfeng}
    time:2018-08-07 08:58:39
    @return:
]]
function RoomCardModel.InitRoomCardBill()
    Network.SendRequest("friendgame_get_history_record_ids")
    -- Event.Brocast("friendgame_get_history_record_ids_response",nil,test_ids())
end

-- 获取账单文件
local function GetRoomCardBillFile()
    return AppDefine.LOCAL_DATA_PATH .. "/" .. MainModel.UserInfo.user_id .. "/room_card_bill.txt"
end

-- 获取账单路径
local function GetRoomCardBillPath()
    return AppDefine.LOCAL_DATA_PATH .. "/" .. MainModel.UserInfo.user_id
end

-- 获取账单路径
local function GetRoomCardBillFileName()
    return "room_card_bill.txt"
end

--[[a-b 数字集合 a 比 b 多了哪些
    a={1,3,5}
    b={2,3}
    more={1,5}
]]
local function tableMore(a,b)
    local bm = {}
    local ret = {}
    for k,v in ipairs(b) do
        bm[v] = 1
    end
    for k,v in ipairs(a) do
        if not bm[v] then
            ret[#ret+1]=v
        end
    end
    return ret
end
-- 表的交集
local function tableAND(a,b)
    local ret = {}
    for i,v_a in ipairs(a) do
        for k,v_b in ipairs(b) do
           if v_a == v_b then
                ret[#ret + 1] = v_a
           end
        end
    end
    return ret

    -- local bm = {}
    -- local ret = {}
    -- for k,v in ipairs(b) do
    --     bm[v] = 1
    -- end
    -- for k,v in ipairs(a) do
    --     if bm[v] then
    --         ret[#ret + 1] = v
    --     end
    -- end
    -- return ret
end

local function saveJsonData()
    local json_data = lua2json(RoomCardModel.histroy_record)
    local path = GetRoomCardBillPath()
    if not Directory.Exists(path) then
        Directory.CreateDirectory(path)
    end
    File.WriteAllText(GetRoomCardBillFile(), json_data)
end

local get_histroy_record_count = 0
function RoomCardModel.friendgame_get_history_record_response(_,data)
    if data.result == 0 then
        RoomCardModel.histroy_record[#RoomCardModel.histroy_record + 1] = data.record
        get_histroy_record_count = get_histroy_record_count - 1
        if get_histroy_record_count == 0 then
           --请求单条数据完成
           saveJsonData()
           Event.Brocast("model_friendgame_get_all_history_record_response",RoomCardModel.histroy_record)
        end
    else
        HintPanel.ErrorMsg(data.result)
    end
end

function RoomCardModel.friendgame_get_all_history_record_response(_,data)
    if data.result == 0 then
       RoomCardModel.histroy_record = {}
       RoomCardModel.histroy_record = data.records
       saveJsonData()
       Event.Brocast("model_friendgame_get_all_history_record_response",RoomCardModel.histroy_record)
    else
        HintPanel.ErrorMsg(data.result)
    end
end

function RoomCardModel.friendgame_get_history_record_ids_response(_,data)
    if data.result == 0 then
        if data.list and next(data.list) then
            local localData = nil
            local t = nil
            local localPath = GetRoomCardBillFile()
            if File.Exists(localPath) then
                localData = File.ReadAllText(localPath)
                t = json2lua(localData)
            end
            if t == nil then
                --没有数据请求所有数据并保存
                Network.SendRequest("friendgame_get_all_history_record")
            else
                local t_key = {}
                for i,v in ipairs(t) do
                    t_key[#t_key + 1] = v.id
                end
                --有数据比对是否相同
                local diffIDs = tableMore(data.list, t_key)
                local delIDs = tableMore(t_key, data.list)
                local andIDs = tableAND(t_key, data.list)

                if #diffIDs == 0 and #delIDs == 0 then
                    --完全一样用本地的数据即可
                    local data = {result = 0,records = t}
                    Event.Brocast("friendgame_get_all_history_record_response",nil,data)
                else                   
                    if #diffIDs > 1 then
                        --多余5条不一样请求所有数据
                        Network.SendRequest("friendgame_get_all_history_record")
                    else
                        get_histroy_record_count = #diffIDs
                        RoomCardModel.histroy_record = {}
                        for i,v in ipairs(andIDs) do
                            RoomCardModel.histroy_record[#RoomCardModel.histroy_record + 1] = t[i]
                        end
                        --请求每一条数据
                        for i,id in ipairs(diffIDs) do
                            Network.SendRequest("friendgame_get_history_record", {id=id})
                        end
                    end
                end
            end
        else
            --没有数据
            Event.Brocast("model_friendgame_get_all_history_record_response",nil)
        end
    else
        HintPanel.ErrorMsg(data.result)
    end
end
--------------------------------------------------------------------------------------------