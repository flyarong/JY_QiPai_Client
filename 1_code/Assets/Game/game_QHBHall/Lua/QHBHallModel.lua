-- 创建时间:2019-05-30
QHBHallModel = {}
local M = QHBHallModel
local this
local lister
local m_data
package.loaded["Game.game_QHBHall.Lua.qhb_hall_config"] = nil
M.hall_config = HotUpdateConfig("Game.game_QHBHall.Lua.qhb_hall_config")

local function MakeLister()
    lister = {}
end
function M.AddMsgListener()
    for proto_name, call in pairs(lister) do
        Event.AddListener(proto_name, call)
    end
end

function M.RemoveMsgListener()
    for proto_name, call in pairs(lister) do
        Event.RemoveListener(proto_name, call)
    end
end

function M.Init()
    this = M
    MakeLister()
    this.AddMsgListener()
    this.InitUIConfig()
    return this
end

function M.Exit()
    if this then
        M.RemoveMsgListener()
        this = nil
        lister = nil
        M = nil
    end
end

function M.InitUIConfig()
end

function M.GetUICfg()
    return M.hall_config
end