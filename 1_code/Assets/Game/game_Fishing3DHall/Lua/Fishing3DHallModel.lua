-- 创建时间:2019-03-18

Fishing3DHallModel = {}
local fish_hall_config = SysFishingManager.fish_hall_config

local this
local lister
local m_data

--构建斗地主正常逻辑的消息事件（断线重连部分不在这里绑定）
local function MakeLister()
    lister = {}
end
--注册斗地主正常逻辑的消息事件
function Fishing3DHallModel.AddMsgListener()
    for proto_name, call in pairs(lister) do
        Event.AddListener(proto_name, call)
    end
end

--删除斗地主正常逻辑的消息事件
function Fishing3DHallModel.RemoveMsgListener()
    for proto_name, call in pairs(lister) do
        Event.RemoveListener(proto_name, call)
    end
end

function Fishing3DHallModel.Init()
    this = Fishing3DHallModel
    MakeLister()
    this.AddMsgListener()
    Fishing3DHallModel.InitConfig()
    Fishing3DHallModel.FishRapidBeginKey = "FishRapidBeginKey" .. MainModel.UserInfo.user_id
    return this
end

function Fishing3DHallModel.Exit()
    if this then
        Fishing3DHallModel.RemoveMsgListener()
        this = nil
        lister = nil
    end
end

function Fishing3DHallModel.InitConfig()
    local cfg = {}
    for k,v in pairs(fish_hall_config.game) do
        if v.is_on and v.is_on == 1 then
            cfg[v.game_id] = v
        end
    end
    fish_hall_config = cfg
end

function Fishing3DHallModel.GetHallCfg()
    return fish_hall_config
end

function Fishing3DHallModel.GetHallCfgNorScene(  )
    local cfg = {}
    for k,v in pairs(fish_hall_config) do
        if not Fishing3DHallModel.CehckIsTY(v.game_id) and v.is_on and v.is_on == 1 then
            cfg[v.game_id] = v
        end
    end
    dump(cfg, "<color=yellow>cfg:::::</color>")
    return cfg
end

function Fishing3DHallModel.GetGameCfg(game_id)
    return fish_hall_config[game_id]
end

-- 快速开始游戏的数据 大厅使用
function Fishing3DHallModel.CheckRapidBeginGameID()
    local gametypeid = PlayerPrefs.GetInt(Fishing3DHallModel.FishRapidBeginKey, 2)
    local gameCfg = Fishing3DHallModel.GetGameCfg(gametypeid)
    if not gameCfg or gameCfg.isOnOff == 0 then
        PlayerPrefs.SetInt(Fishing3DHallModel.FishRapidBeginKey, 2)
        gameCfg = Fishing3DHallModel.GetGameCfg(2)
    end
    return gameCfg
end

function Fishing3DHallModel.CheckRecommendBeginGameIDByGold()
    local cfg = Fishing3DHallModel.GetHallCfgNorScene()
    local gold =  Fishing3DHallModel.GetFishCoinAndJingBi(  )
    local _cfg = {}
    for i=#cfg,1,-1 do
        _cfg = cfg[i]
        if Fishing3DHallModel.CheckRecommendIDByGold(_cfg, gold) then
            return _cfg
        end
    end
    return nil
end

function Fishing3DHallModel.CheckCanBeginGameIDByGold(_cfg, gold)
    if not _cfg then return false end
    return Fishing3DHallModel.CheckRecommend(_cfg.enter_min,_cfg.enter_max, gold)
end

function Fishing3DHallModel.CheckRecommendIDByGold(_cfg, gold)
    if not _cfg then return false end
    return Fishing3DHallModel.CheckRecommend(_cfg.recommend_min,_cfg.recommend_max, gold)
end

function Fishing3DHallModel.CheckRecommend(gold_min,gold_max, gold)
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

function Fishing3DHallModel.GetFishCoinAndJingBi(  )
    if MainModel.UserInfo.jing_bi and MainModel.UserInfo.fish_coin then
        return MainModel.UserInfo.jing_bi + MainModel.UserInfo.fish_coin
    end
    return MainModel.UserInfo.jing_bi
end

function Fishing3DHallModel.CehckIsTY(id)
    return id == 4
end

function Fishing3DHallModel.CehckIsTYCfg()
    return fish_hall_config[4]
end