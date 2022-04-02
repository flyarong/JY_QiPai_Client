-- 创建时间:2018-08-15
GameVoiceLogic = {}

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

function GameVoiceLogic.Init(model)
    GameVoiceLogic.Exit()
    this = GameVoiceLogic
    --初始化model
    GameVoiceModel.Init()
    this.gameModel = model
    MakeLister()
    AddLister()
end

function GameVoiceLogic.Exit()
    if this then
        this = nil
        RemoveLister()
        GameVoiceModel.Exit()
        GameVoicePanel.Exit()
    end
end


