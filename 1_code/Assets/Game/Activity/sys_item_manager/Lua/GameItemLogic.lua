-- 创建时间:2018-12-10
GameItemLogic = {}
local this -- 单例
local model

local lister
local function AddLister()
    for msg,cbk in pairs(lister) do
        Event.AddListener(msg, cbk)
    end
end

local function RemoveLister()
    if lister then
        for msg,cbk in pairs(lister) do
            Event.RemoveListener(msg, cbk)
        end
    end
    lister=nil
end
local function MakeLister()
    lister = {}
end

function GameItemLogic.Init()
    GameItemLogic.Exit()
    this = GameItemLogic
    MakeLister()
    AddLister()
    if model then
        model.Exit()
    end
    model = GameItemModel.Init()
    return this
end
function GameItemLogic.Exit()
	if this then
		model.Exit()
		model = nil
		RemoveLister()
		this = nil
	end
end


