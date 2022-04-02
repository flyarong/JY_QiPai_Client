-- 创建时间:2018-11-06
GoldenPigLogic = {}

local this  -- 单例
local lister
local model

local function MakeLister()
    lister = {}
    lister["OnLoginResponse"] = this.OnLoginResponse
    lister["ReConnecteServerSucceed"] = this.OnReConnecteServerSucceed
    lister["ExitScene"] = this.OnExitScene
    lister["open_golden_pig"] = this.open_golden_pig
    lister["close_golden_pig"] = this.close_golden_pig
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

function GoldenPigLogic.Init()
    if not GameGlobalOnOff.GoldenPig then
		return
    end
    GoldenPigLogic.Exit()
    this = GoldenPigLogic
    -- model = GoldenPigModel.Init()
    MakeLister()
    AddLister()
    return this
end

function GoldenPigLogic.Exit()
    if this then
        this = nil
        RemoveLister()
        GoldenPigLogic.Close()
        GoldenPigModel.Exit()
    end
end

--正常登录成功
function GoldenPigLogic.OnLoginResponse(result)
    if result==0 then
    	if model then
    		model.Exit()
    	end
    	model = GoldenPigModel.Init()
    else
    end
end
--断线重连后登录成功
function GoldenPigLogic.OnReConnecteServerSucceed(result)
    if result==0 then
    	if model then
    		model.Exit()
    	end
    	model = GoldenPigModel.Init()
    else
    end
end

function GoldenPigLogic.Close()
    GoldenPigPanel.Close()
end

function GoldenPigLogic.OnExitScene()
    GoldenPigLogic.Close()
end

function GoldenPigLogic.open_golden_pig()
    GoldenPigPanel.Create()
end

function GoldenPigLogic.close_golden_pig()
    GoldenPigLogic.Close()
end