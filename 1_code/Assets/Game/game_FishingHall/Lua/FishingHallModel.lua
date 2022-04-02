-- 创建时间:2019-03-18

FishingHallModel = {}
local fish_hall_config = SysFishingManager.fish_hall_config

local this
local lister
local m_data

--构建斗地主正常逻辑的消息事件（断线重连部分不在这里绑定）
local function MakeLister()
    lister = {}
end
--注册斗地主正常逻辑的消息事件
function FishingHallModel.AddMsgListener()
    for proto_name, call in pairs(lister) do
        Event.AddListener(proto_name, call)
    end
end

--删除斗地主正常逻辑的消息事件
function FishingHallModel.RemoveMsgListener()
    for proto_name, call in pairs(lister) do
        Event.RemoveListener(proto_name, call)
    end
end

function FishingHallModel.Init()
    this = FishingHallModel
    MakeLister()
    this.AddMsgListener()
    FishingHallModel.InitConfig()
    FishingHallModel.FishRapidBeginKey = "FishRapidBeginKey" .. MainModel.UserInfo.user_id
    return this
end

function FishingHallModel.Exit()
    if this then
        FishingHallModel.RemoveMsgListener()
        this = nil
        lister = nil
    end
end

function FishingHallModel.InitConfig()
    local cfg = {}
    for k,v in pairs(fish_hall_config.game) do
        if v.is_on and v.is_on == 1 then
            cfg[v.game_id] = v
        end
    end
    fish_hall_config = cfg
end

function FishingHallModel.GetHallCfg()
    return fish_hall_config
end

function FishingHallModel.GetHallCfgNorScene(  )
    local cfg = {}
    for k,v in pairs(fish_hall_config) do
        if not FishingHallModel.CehckIsTY(v.game_id) and v.is_on and v.is_on == 1 then
            cfg[v.game_id] = v
        end
    end
    dump(cfg, "<color=yellow>cfg:::::</color>")
    return cfg
end

function FishingHallModel.GetGameCfg(game_id)
    return fish_hall_config[game_id]
end

-- 快速开始游戏的数据 大厅使用
function FishingHallModel.CheckRapidBeginGameID()
    local gametypeid = PlayerPrefs.GetInt(FishingHallModel.FishRapidBeginKey, 2)
    local gameCfg = FishingHallModel.GetGameCfg(gametypeid)
    if not gameCfg or gameCfg.isOnOff == 0 then
        PlayerPrefs.SetInt(FishingHallModel.FishRapidBeginKey, 2)
        gameCfg = FishingHallModel.GetGameCfg(2)
    end
    return gameCfg
end

function FishingHallModel.CheckRecommendBeginGameIDByGold()
    local cfg = FishingHallModel.GetHallCfgNorScene()
    local gold =  FishingHallModel.GetFishCoinAndJingBi(  )
    local _cfg = {}
    for i=#cfg,1,-1 do
        _cfg = cfg[i]
        if FishingHallModel.CheckRecommendIDByGold(_cfg, gold) then
            return _cfg
        end
    end
    return nil
end

function FishingHallModel.CheckCanBeginGameIDByGold(_cfg, gold)
    if not _cfg then return false end
    return FishingHallModel.CheckRecommend(_cfg.enter_min,_cfg.enter_max, gold)
end

function FishingHallModel.CheckRecommendIDByGold(_cfg, gold)
    if not _cfg then return false end
    return FishingHallModel.CheckRecommend(_cfg.recommend_min,_cfg.recommend_max, gold)
end

function FishingHallModel.CheckRecommend(gold_min,gold_max, gold)
    if gold_min and gold_max then
        if gold >= gold_min and gold <= gold_max then
            return true
        elseif gold < gold_min then
            return false, 1
        elseif gold > gold_max then
            return false, 2
        end
    elseif gold_min and not gold_max then
        if gold >= gold_min then
            return true
        else
            return false, 1
        end
    elseif not gold_min and gold_max then
        if gold <= gold_max then
            return true
        else
            return false, 2
        end
    end
    return false, 1
end

function FishingHallModel.GetFishCoinAndJingBi(  )
    if MainModel.UserInfo.jing_bi and MainModel.UserInfo.fish_coin then
        return MainModel.UserInfo.jing_bi + MainModel.UserInfo.fish_coin
    end
    return MainModel.UserInfo.jing_bi
end

function FishingHallModel.CehckIsTY(id)
    return id == 4
end

function FishingHallModel.CehckIsTYCfg()
    return fish_hall_config[4]
end
