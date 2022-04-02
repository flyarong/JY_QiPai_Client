-- 创建时间:2018-10-15

local zjf_hall_config = SysZjfManager.zjf_hall_config
local freestyle_ui = SysZjfManager.freestyle_ui
local zjf_ddz_base_config = SysZjfManager.zjf_ddz_base_config
local zjf_mj_base_config = SysZjfManager.zjf_mj_base_config
GameZJFModel = {}
GameZJFModel.game_type2scence =  {
	nor_ddz_nor = "game_DdzZJF",
	nor_ddz_lz = "game_DdzZJF",
	nor_mj_xzdd ="game_MJXzZJF3D",
	nor_ddz_er = "game_DdzZJF",
	nor_ddz_boom = "game_DdzZJF",
	nor_mj_xzdd_er_7 = "game_MJXzZJF3D",
}
GameZJFModel.fengding_bs_ddz_int = {
    24,48,96,192
}
GameZJFModel.fengding_bs_ddz_str = {
    "feng_ding_24b",
    "feng_ding_48b",
    "feng_ding_96b",
    "feng_ding_192b",
}

GameZJFModel.fengding_bs_mj_int = {
    3,5,6,7
}
GameZJFModel.fengding_bs_mj_str = {
    "feng_ding_3f",
    "feng_ding_5f",
    "feng_ding_6f",
    "feng_ding_7f",
}


local this
local m_data
local lister
local room_info = {}
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
local function MakeLister()
    lister={}
    lister["get_one_type_game_list_response"] = this.on_get_one_type_game_list_response
end

-- 初始化Data
local function InitMatchData()
    GameZJFModel.data={
    }
    m_data = GameZJFModel.data
end

function GameZJFModel.Init()
    this = GameZJFModel
    InitMatchData()
    MakeLister()
    AddLister()
    this.InitUIConfig()
    return this
end
function GameZJFModel.Exit()
    if this then
        RemoveLister()
        lister=nil
        this=nil
    end
end


function GameZJFModel.InitUIConfig()
	local areaid = MainModel.GetAreaID()

    this.UIConfig={}
    this.UIConfig.areagame = zjf_hall_config.areagame
    this.UIConfig.global = zjf_hall_config.global
    this.UIConfig.game = zjf_hall_config.game
    this.UIConfig.gamelist = this.UIConfig.areagame[areaid].gamelist
    this.UIConfig.closegamelist = this.UIConfig.areagame[areaid].closegamelist

    local map = {}
    for k,v in ipairs(freestyle_ui.config) do
        if v.isOnOff and v.isOnOff == 1 then
            if not map[v.game_type] then
                map[v.game_type] = {}
            end
            map[v.game_type][#map[v.game_type] + 1] = v
        end
    end
    this.UIConfig.gameConfigMap = map
end

-- 获取游戏配置 游戏id
function GameZJFModel.GetGameConfig(configname)
	return this.UIConfig.gameConfigMap[configname]
end
function GameZJFModel.SetCurrGameConfig(data)
	this.UIConfig.config = data
    this.UIConfig.configmap = {}
    if this.UIConfig.config then
        for k,v in ipairs(this.UIConfig.config) do
            this.UIConfig.configmap[v.game_id] = v
        end
    end
end
function GameZJFModel.SetCurrGameID(gameid)
	this.data.gameid = gameid
end

function GameZJFModel.GetCurrGameID()
    if this and this.data then
        return this.data.gameid
    end
end

function GameZJFModel.SetCurrSceneID(sceneID)
    this.data.sceneID = sceneID
end

-- 根据游戏ID获取
function GameZJFModel.GetGameCfg(gameid)
    if not this then this = GameZJFModel end
    if not this.UIConfig then return end
    local map = this.UIConfig.gameConfigMap
    for k,v in pairs(map) do
        for k1,v1 in ipairs(v) do
            if v1.game_id == gameid then
                return v1
            end
        end
    end
    dump(gameid, "<color=red>GetGameCfg gameid </color>")
end

function GameZJFModel.SendQueryToGetRoomInfo(game_type, page_index, sort_type)
    if not room_info[game_type]
        or not room_info[game_type].list
        or not room_info[game_type].list[page_index]
        or (page_index == 1 and (room_info[game_type].time+3) < os.time()) then
            if room_info[game_type] and room_info[game_type].time and (page_index == 1 and (room_info[game_type].time+3) < os.time()) then
                room_info[game_type] = {}
            end
            Network.SendRequest("get_one_type_game_list",{game_type = game_type, page_index = page_index}, "正在加载房间信息...")
    else
        dump(room_info[game_type].list[page_index], "<color=red>本地 房间信息</color>")
        Event.Brocast("zjf_room_info_get", room_info[game_type].list[page_index], false)
    end
end

function GameZJFModel.on_get_one_type_game_list_response(_,data)
    dump(data,"<color=red>房间信息------------</color>")
    if data and data.result == 0 then 
        room_info[data.game_type] = room_info[data.game_type] or {}
        if data.page_index == 1 then -- 首次请求时间
            room_info[data.game_type].time = os.time()
        end
        room_info[data.game_type].list = room_info[data.game_type].list or {}
        room_info[data.game_type].list[data.page_index] = data

        if data.page_index == 1 then
            Event.Brocast("zjf_room_info_get", data, true)
        else
            Event.Brocast("zjf_room_info_get", data, false)
        end
    end
end

function GameZJFModel.GetRoomInfo(sup_game_type)
    return room_info[sup_game_type]
end

function GameZJFModel.GetGameTypeByID(id)
    return this.UIConfig.game[id].support_game_type
end

function GameZJFModel.GetGameNameByID(id)
    return this.UIConfig.game[id].name
end


function GameZJFModel.get_ddz_enter_base_by_type(type)
    for i = 1,#zjf_ddz_base_config.base do
        if zjf_ddz_base_config.base[i].game_type == type then
            return zjf_ddz_base_config.base[i].room_enter_base
        end
    end
end

function GameZJFModel.get_ddz_enter_xishu_by_type(type)
    for i = 1,#zjf_ddz_base_config.base do
        if zjf_ddz_base_config.base[i].game_type == type then
            return zjf_ddz_base_config.base[i].room_enter_xishu
        end
    end
end

function GameZJFModel.get_ddz_enter_wanfa_by_type(type)
    for i = 1,#zjf_ddz_base_config.base do
        if zjf_ddz_base_config.base[i].game_type == type then
            return zjf_ddz_base_config.base[i].wanfa
        end
    end
end

function GameZJFModel.get_ddz_create_xishu_by_type(type)
    for i = 1,#zjf_ddz_base_config.base do
        if zjf_ddz_base_config.base[i].game_type == type then
            return zjf_ddz_base_config.base[i].room_create_xishu
        end
    end
end

function GameZJFModel.get_mj_enter_base_by_type(type)
    for i = 1,#zjf_mj_base_config.base do
        if zjf_mj_base_config.base[i].game_type == type then
            return zjf_mj_base_config.base[i].room_enter_base
        end
    end
end

function GameZJFModel.get_mj_enter_xishu_by_type(type)
    for i = 1,#zjf_mj_base_config.base do
        if zjf_mj_base_config.base[i].game_type == type then
            return zjf_mj_base_config.base[i].room_enter_xishu
        end
    end
end

function GameZJFModel.get_mj_enter_wanfa_by_type(type)
    for i = 1,#zjf_mj_base_config.base do
        if zjf_mj_base_config.base[i].game_type == type then
            return zjf_mj_base_config.base[i].wanfa
        end
    end
end

function GameZJFModel.get_mj_create_xishu_by_type(type)
    for i = 1,#zjf_mj_base_config.base do
        if zjf_mj_base_config.base[i].game_type == type then
            return zjf_mj_base_config.base[i].room_create_xishu
        end
    end
end