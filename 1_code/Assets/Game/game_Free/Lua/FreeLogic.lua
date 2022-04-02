-- 创建时间:2018-10-16
package.loaded["Game.game_Free.Lua.FreeModel"] = nil
require "Game.game_Free.Lua.FreeModel"
package.loaded["Game.game_Free.Lua.GameFreeHallPanel"] = nil
require "Game.game_Free.Lua.GameFreeHallPanel"
package.loaded["Game.game_Free.Lua.FreeHelpPanel"] = nil
require "Game.game_Free.Lua.FreeHelpPanel"
package.loaded["Game.game_Free.Lua.FreeSharePanel"] = nil
require "Game.game_Free.Lua.FreeSharePanel"

package.loaded["Game.game_Free.Lua.GameFreeLeftItemPrefab"] = nil
require "Game.game_Free.Lua.GameFreeLeftItemPrefab"
package.loaded["Game.game_Free.Lua.GameFreeRightItemPrefab"] = nil
require "Game.game_Free.Lua.GameFreeRightItemPrefab"
package.loaded["Game.game_Free.Lua.FreeOperatorPrefab"] = nil
require "Game.game_Free.Lua.FreeOperatorPrefab"
package.loaded["Game.game_Free.Lua.GameFreeMiniGameGuidePanel"] = nil
require "Game.game_Free.Lua.GameFreeMiniGameGuidePanel"
FreeLogic = {}
local this
local cur_panel
local lister
local viewLister
local is_allow_forward

local function MakeLister()
    lister = {}

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

local function ViewMsgRegister(registerName)
    if registerName then
        if viewLister and viewLister[registerName] and is_allow_forward then
            AddMsgListener(viewLister[registerName])
        end
    else
        if viewLister and is_allow_forward then
            for k, lister in pairs(viewLister) do
                AddMsgListener(lister)
            end
        end
    end
end
local function cancelViewMsgRegister(registerName)
    if registerName then
        if viewLister and viewLister[registerName] then
            RemoveMsgListener(viewLister[registerName])
        end
    else
        if viewLister then
            for k, lister in pairs(viewLister) do
                RemoveMsgListener(lister)
            end
        end
    end
    DOTweenManager.KillAllStopTween()
end

local function clearAllViewMsgRegister()
    cancelViewMsgRegister()
    viewLister = {}
end

function FreeLogic.setViewMsgRegister(lister, registerName)
    --检测是否已经注册
    if not registerName or viewLister[registerName] then
        return false
    end
    viewLister[registerName] = lister
    ViewMsgRegister(registerName)
end

function FreeLogic.clearViewMsgRegister(registerName)
    if not registerName then
        return false
    end
    cancelViewMsgRegister(registerName)
    viewLister[registerName] = nil
end



--初始化
function FreeLogic.Init(parm)
    ExtendSoundManager.PlaySceneBGM(audio_config.game.bgm_main_hall.audio_name)
    this = FreeLogic

    --初始化model
    local model = FreeModel.Init()

    MakeLister()
    AddMsgListener(lister)

    cur_panel = GameFreeHallPanel.Create(parm)
end
function FreeLogic.Exit()
    if this then
        FreeModel.Exit()

        if cur_panel then
            cur_panel:MyExit()
        end
        cur_panel = nil
        RemoveMsgListener(lister)
        clearAllViewMsgRegister()
        this = nil
    end
end

return FreeLogic
