ext_require_audio("Game.normal_fishing_common.Lua.audio_by_config","by")
-- 创建时间:2019-03-18
package.loaded["Game.game_FishingHall.Lua.FishingHallModel"] = nil
require "Game.game_FishingHall.Lua.FishingHallModel"
package.loaded["Game.game_FishingHall.Lua.FishingHallGamePanel"] = nil
require "Game.game_FishingHall.Lua.FishingHallGamePanel"

require "Game.normal_fishing_common.Lua.FishingMatchSignupPanel"
require "Game.normal_fishing_common.Lua.FishingMatchAwardPanel"
require "Game.normal_fishing_common.Lua.FishingMatchOldRankPanel"
require "Game.normal_fishing_common.Lua.FishingBKPanel"

FishingHallLogic = {}
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

function FishingHallLogic.setViewMsgRegister(lister, registerName)
    --检测是否已经注册
    if not registerName or viewLister[registerName] then
        return false
    end
    viewLister[registerName] = lister
    ViewMsgRegister(registerName)
end

function FishingHallLogic.clearViewMsgRegister(registerName)
    if not registerName then
        return false
    end
    cancelViewMsgRegister(registerName)
    viewLister[registerName] = nil
end



--初始化
function FishingHallLogic.Init(parm)
    ExtendSoundManager.PlaySceneBGM(audio_config.by.bgm_by_dating.audio_name)
    this = FishingHallLogic

    --初始化model
    local model = FishingHallModel.Init()
    MakeLister()
    AddMsgListener(lister)
    cur_panel = FishingHallGamePanel.Create(parm)
end
function FishingHallLogic.Exit()
    if this then
        FishingHallModel.Exit()
        if cur_panel then
            cur_panel:MyExit()
        end
        cur_panel = nil
        --Exit()
        RemoveMsgListener(lister)
        clearAllViewMsgRegister()
        this = nil
    end
end

return FishingHallLogic
