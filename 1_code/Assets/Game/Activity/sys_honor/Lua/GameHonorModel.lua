-- 创建时间:2018-11-01
local honor_config = SysHonorManager.config

GameHonorModel = {}

local this
local m_data
local lister

--需要显示预制体的类型
GameHonorModel.HonorPrefabType = {
    my_honor = "my_honor",
    honor_rule = "honor_rule",
    my_progress = "my_progress",
}

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
end

-- 初始化Data
local function InitMatchData()
    GameHonorModel.data={
    }
    m_data = GameHonorModel.data    
end

function GameHonorModel.Init()
    this = GameHonorModel
    InitMatchData()
    MakeLister()
    AddLister()
    this.InitUIConfig()
    return this
end
function GameHonorModel.Exit()
    if this then
        RemoveLister()
        lister=nil
        this=nil
    end
end

function GameHonorModel.InitUIConfig()
    this.game_honor_config = {}
    local config = this.game_honor_config
    local award_config = {}
    for i,v in ipairs(honor_config.config) do
        config[v.level] = config[v.level] or {}
        config[v.level] = v
        config[v.level].award = config[v.level].award or {}
        award_config = config[v.level].award
        if v.item_key then
            for i=1,#v.item_key do
                award_config[v.item_key[i]] = v.item_val[i]
            end
        end
    end
end

-- 更新数据 当前荣誉值
function GameHonorModel.UpdateHonorValue(val)
    MainModel.UserInfo.glory_data.score = val
end

-- 获取当前val
function GameHonorModel.GetCurHonorValue()
    return MainModel.UserInfo.glory_data.score
end

-- 获取当前data
function GameHonorModel.GetCurHonorData()
    local val = MainModel.UserInfo.glory_data.score
    return GameHonorModel.GetHonorData(val)
end

-- 获取data
function GameHonorModel.GetHonorData(val)
    if not this then this = GameHonorModel end
    for i=1,#this.game_honor_config do
        local v = this.game_honor_config[i]
        if (v.min_val == -1 or val >= v.min_val) and (v.max_val == -1 or val < v.max_val) then
            return v
        end
        if i == #this.game_honor_config then
            return v
        end
    end
end

-- 获取下一个等级的data
function GameHonorModel.GetNextHonorData(val)
    for i,v in ipairs(this.game_honor_config) do
        if val >= v.min_val and val < v.max_val then
            if this.game_honor_config[i+1] then
                return this.game_honor_config[i+1]
            end
            break
        end
    end
    return nil
end

-- 获取上一个等级的data
function GameHonorModel.GetPrevHonorData(val)
    for i,v in ipairs(this.game_honor_config) do
        if val >= v.min_val and val < v.max_val then
            if this.game_honor_config[i-1] then
                return this.game_honor_config[i-1]
            end
            break
        end
    end
    return nil
end

function GameHonorModel.GetHonorDataByID(level)
    if level then
        return this.game_honor_config[level]
    else
        return this.game_honor_config
    end
end