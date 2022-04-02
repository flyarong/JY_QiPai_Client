-- 创建时间:2019-05-30
MiniGameModel = {}
local this
local lister
local m_data

--构建斗地主正常逻辑的消息事件（断线重连部分不在这里绑定）
local function MakeLister()
    lister = {}
end
--注册斗地主正常逻辑的消息事件
function MiniGameModel.AddMsgListener()
    for proto_name, call in pairs(lister) do
        Event.AddListener(proto_name, call)
    end
end

--删除斗地主正常逻辑的消息事件
function MiniGameModel.RemoveMsgListener()
    for proto_name, call in pairs(lister) do
        Event.RemoveListener(proto_name, call)
    end
end

function MiniGameModel.Init()
    this = MiniGameModel
    MakeLister()
    this.AddMsgListener()

    this.InitUIConfig()
    return this
end

function MiniGameModel.Exit()
    if this then
        MiniGameModel.RemoveMsgListener()
        this = nil
        lister = nil
    end
end

function MiniGameModel.InitUIConfig()
    if MainModel.IsHWLowPlayer() then
        MiniGameModel.mini_game_config = HotUpdateConfig("Game/Channel/Lua/mini_game_config_hw")
    else
        MiniGameModel.mini_game_config = HotUpdateConfig("Game.game_MiniGame.Lua.mini_game_config")
    end
end

function MiniGameModel.GetUIConfig()
    local cfg = {}
    for k,v in pairs(MiniGameModel.mini_game_config.game) do
        if v.is_onoff == 1 then
            if v.gotoUI then
                local parm = {}
                parm.gotoui = v.gotoUI[1]
                parm.goto_scene_parm = v.gotoUI[2]
                local b,c = GameButtonManager.RunFun(parm, "IsActive")
                if b and c then
                    cfg[k] = v
                end
            else
                if k ~= "MiniGameLHDPrefab" or (LHDManager and LHDManager.IsActive()) then
                    if k ~= "MiniGameZPGPrefab" or MiniGameModel.CheckZPGActive() then
                        cfg[k] = v
                    end
                end
            end
        end
    end
    return cfg
end

function MiniGameModel.CheckZPGActive()
    --判断种苹果显示权限
    local _permission_key = "drt_guess_apple_show"
    if _permission_key then
        local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key=_permission_key, is_on_hint = true}, "CheckCondition")
        if a and not b then
            return false
        end
        return true
    else
        return true
    end
end