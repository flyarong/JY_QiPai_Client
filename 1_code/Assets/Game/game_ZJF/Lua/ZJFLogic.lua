-- 创建时间:2018-10-16
package.loaded["Game.game_ZJF.Lua.ZJFModel"] = nil
require "Game.game_ZJF.Lua.ZJFModel"
package.loaded["Game.game_ZJF.Lua.GameZJFHallPanel"] = nil
require "Game.game_ZJF.Lua.GameZJFHallPanel"
package.loaded["Game.game_ZJF.Lua.ZJFHelpPanel"] = nil
require "Game.game_ZJF.Lua.ZJFHelpPanel"
package.loaded["Game.game_ZJF.Lua.ZJFSharePanel"] = nil
require "Game.game_ZJF.Lua.ZJFSharePanel"
package.loaded["Game.game_ZJF.Lua.ZJFJoin"] = nil
require "Game.game_ZJF.Lua.ZJFJoin"

package.loaded["Game.game_ZJF.Lua.GameZJFLeftItemPrefab"] = nil
require "Game.game_ZJF.Lua.GameZJFLeftItemPrefab"
package.loaded["Game.game_ZJF.Lua.GameZJFRightItemPrefab"] = nil
require "Game.game_ZJF.Lua.GameZJFRightItemPrefab"
package.loaded["Game.game_ZJF.Lua.ZJFOperatorPrefab"] = nil
require "Game.game_ZJF.Lua.ZJFOperatorPrefab"
package.loaded["Game.game_ZJF.Lua.GameZJFCreateRoomPanel"] = nil
require "Game.game_ZJF.Lua.GameZJFCreateRoomPanel"
package.loaded["Game.game_ZJF.Lua.ZJFDdzPrefab"] = nil
require "Game.game_ZJF.Lua.ZJFDdzPrefab"
package.loaded["Game.game_ZJF.Lua.ZJFMj3DPrefab"] = nil
require "Game.game_ZJF.Lua.ZJFMj3DPrefab"
package.loaded["Game.game_ZJF.Lua.ZJFHistoryPanel"] = nil
require "Game.game_ZJF.Lua.ZJFHistoryPanel"

ZJFLogic = {}
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

function ZJFLogic.setViewMsgRegister(lister, registerName)
    --检测是否已经注册
    if not registerName or viewLister[registerName] then
        return false
    end
    viewLister[registerName] = lister
    ViewMsgRegister(registerName)
end

function ZJFLogic.clearViewMsgRegister(registerName)
    if not registerName then
        return false
    end
    cancelViewMsgRegister(registerName)
    viewLister[registerName] = nil
end



--初始化
function ZJFLogic.Init(parm)
    ExtendSoundManager.PlaySceneBGM(audio_config.game.bgm_main_hall.audio_name)
    this = ZJFLogic

    --初始化model
    local model = ZJFModel.Init()

    MakeLister()
    AddMsgListener(lister)

    cur_panel = GameZJFHallPanel.Create(parm)
end
function ZJFLogic.Exit()
    if this then
        ZJFModel.Exit()

        if cur_panel then
            cur_panel:MyExit()
        end
        cur_panel = nil
        RemoveMsgListener(lister)
        clearAllViewMsgRegister()
        this = nil
    end
end

return ZJFLogic
