ext_require_audio("Game.game_Zjd.Lua.audio_qql_config","qql")
-- package.loaded["Game.game_Zjd.Lua.ShatterGoldenEggLogic"] = nil
require("Game.game_Zjd.Lua.ShatterGoldenEggLogic")

package.loaded["Game.game_Zjd.Lua.ShatterGoldenEggPanel"] = nil
require("Game.game_Zjd.Lua.ShatterGoldenEggPanel")

package.loaded["Game.game_Zjd.Lua.ShatterGoldenEggRanking"] = nil
require("Game.game_Zjd.Lua.ShatterGoldenEggRanking")

package.loaded["Game.game_Zjd.Lua.ShatterGoldenEggAward"] = nil
require("Game.game_Zjd.Lua.ShatterGoldenEggAward")

package.loaded["Game.game_Zjd.Lua.ShatterGoldenEggHelp"] = nil
require("Game.game_Zjd.Lua.ShatterGoldenEggHelp")

package.loaded["Game.game_Zjd.Lua.ShatterGoldenRewardPanel"] = nil
require("Game.game_Zjd.Lua.ShatterGoldenRewardPanel")

package.loaded["Game.game_Zjd.Lua.ShatterGolden2EggsBetPanel"] = nil
require "Game.game_Zjd.Lua.ShatterGolden2EggsBetPanel"


ZjdLogic = {}

local this
local lister

local function MakeLister()
    lister = {}
    lister["ExitScene"] = ZjdLogic.OnExitScene
    lister["OnLoginResponse"] = ZjdLogic.OnExitScene
    lister["will_kick_reason"] = ZjdLogic.OnExitScene
    lister["DisconnectServerConnect"] = ZjdLogic.OnExitScene
    lister["ZJDQuit"] = ZjdLogic.OnExitScene
end

local function AddMsgListener(lister)
    for proto_name, func in pairs(lister) do
        Event.AddListener(proto_name, func)
    end
end

local function RemoveMsgListener(lister)
    for proto_name, func in pairs(lister) do
        Event.RemoveListener(proto_name, func)
    end
end

--³õÊ¼»¯
function ZjdLogic.Init(parm)
    ShatterGoldenEggLogic.Init()
    this = ZjdLogic

    MakeLister()
    AddMsgListener(lister)

    -- 创建缓冲池
    CachePrefabManager.InitCachePrefab("ComFlyGlodPrefab", 100, true)

    ShatterGoldenEggPanel.Create(parm)
end
function ZjdLogic.Exit()
    if this then
        -- 清空缓冲池
        CachePrefabManager.DelCachePrefab("ComFlyGlodPrefab")

        ShatterGoldenEggPanel.Close()
    	RemoveMsgListener(lister)
        this = nil
    end
end

function ZjdLogic.OnExitScene()
    ZjdLogic.Exit()
    GameManager.GotoSceneName("game_MiniGame")
end

function ZjdLogic.quit_game(call, quit_msg_call)
    print(debug.traceback())
    Network.SendRequest("zajindan_quit_game", nil, "", function (data)
        if quit_msg_call then
            quit_msg_call(data.result)
        end
        if data.result == 0 then
            if not call then
                ZjdLogic.OnExitScene()
            else
                call()
            end
        end
    end)    
end

return ZjdLogic
