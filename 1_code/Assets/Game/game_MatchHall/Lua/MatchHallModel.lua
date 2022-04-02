MatchHallModel = {}
local M = MatchHallModel
local this
local lister
local m_data

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
    m_data = {}
    MakeLister()
    this.AddMsgListener()
    MatchModel.QueryNowMatchStatus()
    MatchModel.ClearSignupData()
    return this
end

function M.Exit()
    if this then
        M.RemoveMsgListener()
        m_data = nil
        this = nil
        lister = nil
    end
end