-- 创建时间:2018-11-06
-- 游戏任务系统
GameTaskLogic = {}

local this  -- 单例
local lister
local model

local function MakeLister()
    lister = {}
    lister["OnLoginResponse"] = this.OnLoginResponse
    lister["ReConnecteServerSucceed"] = this.OnReConnecteServerSucceed
    lister["ExitScene"] = this.OnExitScene
    lister["open_task"] = this.open_task
    lister["close_task"] = this.close_task
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

function GameTaskLogic.Init()
    GameTaskLogic.Exit()
    this = GameTaskLogic
    -- model = GameTaskModel.Init()
    MakeLister()
    AddLister()
    return this
end

function GameTaskLogic.Exit()
    if this then
        this = nil
        if model then
            model.Exit()
        end
        RemoveLister()
        GameTaskLogic.Close()
        GameTaskModel.Exit()
    end
end

--正常登录成功
function GameTaskLogic.OnLoginResponse(result)
    if result==0 then
    	if model then
    		model.Exit()
    	end
    	model = GameTaskModel.Init()
    else
    end
end
--断线重连后登录成功
function GameTaskLogic.OnReConnecteServerSucceed(result)
    if result==0 then
    	if model then
    		model.Exit()
    	end
    	model = GameTaskModel.Init()
    else
    end
end

function GameTaskLogic.Close()
    GameTaskPanel.Close()
    GameTaskBtnPrefab.Close()
end

function GameTaskLogic.OnExitScene()
    GameTaskLogic.Close()
end

function GameTaskLogic.open_task()
    GameTaskPanel.Create()
end

function GameTaskLogic.close_task()
    GameTaskLogic.Close()
end