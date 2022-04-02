-- 创建时间:2018-09-11
-- 互动表情聊天
GameAnimChatLogic = {}

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

function GameAnimChatLogic.Init(model)
    GameAnimChatLogic.Exit()
    this = GameAnimChatLogic
    --初始化model
    GameAnimChatModel.Init()
    this.gameModel = model
    MakeLister()
    AddLister()
end

function GameAnimChatLogic.Exit()
    if this then
        this = nil
        RemoveLister()
        GameAnimChatModel.Exit()
        GameAnimChatPanel.Exit()
    end
end
