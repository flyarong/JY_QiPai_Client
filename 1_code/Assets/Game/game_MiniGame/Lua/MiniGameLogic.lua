-- 创建时间:2019-05-30

package.loaded["Game.game_MiniGame.Lua.MiniGameModel"] = nil
require "Game.game_MiniGame.Lua.MiniGameModel"
package.loaded["Game.game_MiniGame.Lua.MiniGameHallPanel"] = nil
require "Game.game_MiniGame.Lua.MiniGameHallPanel"
package.loaded["Game.game_MiniGame.Lua.MiniGameHallPrefab"] = nil
require "Game.game_MiniGame.Lua.MiniGameHallPrefab"


MiniGameLogic = {}

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

function MiniGameLogic.setViewMsgRegister(lister, registerName)
    --检测是否已经注册
    if not registerName or viewLister[registerName] then
        return false
    end
    viewLister[registerName] = lister
    ViewMsgRegister(registerName)
end

function MiniGameLogic.clearViewMsgRegister(registerName)
    if not registerName then
        return false
    end
    cancelViewMsgRegister(registerName)
    viewLister[registerName] = nil
end



--初始化
function MiniGameLogic.Init(parm)
	soundMgr:CloseSound()
	Util.ClearMemory()
    ExtendSoundManager.PlaySceneBGM(audio_config.game.bgm_xiaoyouxibeijing.audio_name)
    this = MiniGameLogic

    --初始化model
    local model = MiniGameModel.Init()
    --Init(model)
    MakeLister()
    AddMsgListener(lister)

    cur_panel = MiniGameHallPanel.Create(parm)
end
function MiniGameLogic.Exit()
    if this then
        MiniGameModel.Exit()
        if cur_panel then
            cur_panel:MyExit()
        end
        cur_panel = nil
        RemoveMsgListener(lister)
        clearAllViewMsgRegister()
        this = nil
    end
end

return MiniGameLogic

