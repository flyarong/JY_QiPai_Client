QHBHallLogic = {}
local M = QHBHallLogic
ext_require_audio("Game.normal_qhb_common.Lua.audio_qhb_config","qhb")
package.loaded["Game.game_QHBHall.Lua.QHBHallModel"] = nil
require "Game.game_QHBHall.Lua.QHBHallModel"
package.loaded["Game.game_QHBHall.Lua.QHBHallPanel"] = nil
require "Game.game_QHBHall.Lua.QHBHallPanel"
package.loaded["Game.normal_qhb_common.Lua.QHBHelpPanel"] = nil
require "Game.normal_qhb_common.Lua.QHBHelpPanel"

M.switch = {
    hby = false,
}

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

function M.setViewMsgRegister(lister, registerName)
    --检测是否已经注册
    if not registerName or viewLister[registerName] then
        return false
    end
    viewLister[registerName] = lister
    ViewMsgRegister(registerName)
end

function M.clearViewMsgRegister(registerName)
    if not registerName then
        return false
    end
    cancelViewMsgRegister(registerName)
    viewLister[registerName] = nil
end

--初始化
function M.Init(parm)
    ExtendSoundManager.PlaySceneBGM(audio_config.qhb.bgm_qhb_beijing.audio_name)
    this = M

    --初始化model
    local model = QHBHallModel.Init()
    --Init(model)
    MakeLister()
    AddMsgListener(lister)

    cur_panel = QHBHallPanel.Create(parm)
end
function M.Exit()
    if this then
        QHBHallModel.Exit()
        if cur_panel then
            cur_panel:MyExit()
        end
        cur_panel = nil
        RemoveMsgListener(lister)
        clearAllViewMsgRegister()
        this = nil
    end
end

return M

