-- 创建时间:2018-09-10
-- 快速聊天
GameSpeedyLogic = {}

local this  -- 单例
local lister
local function MakeLister()
    lister = {}
end
local function AddLister()
     for msg, cbk in pairs(lister) do
        Event.AddListener(msg, cbk)
    end
end

local function RemoveLister()
    for msg, cbk in pairs(lister) do
        Event.RemoveListener(msg, cbk)
    end
    lister = nil
end

function GameSpeedyLogic.Init(model)
    GameSpeedyLogic.Exit()
    this = GameSpeedyLogic
    --初始化model
    GameSpeedyModel.Init()
    this.gameModel = model
    MakeLister()
    AddLister()
end

function GameSpeedyLogic.Exit()
    if this then
        this = nil
        RemoveLister()
        GameSpeedyModel.Exit()
        GameSpeedyPanel.Hide()
    end
end

