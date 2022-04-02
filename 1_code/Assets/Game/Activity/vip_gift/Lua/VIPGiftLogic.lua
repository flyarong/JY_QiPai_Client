-- 创建时间:2018-11-06
-- 游戏任务系统
VIPGiftLogic = {}
local M = VIPGiftLogic
M.key = "vip_gift"
M.vip_gift_config = GameButtonManager.ExtLoadLua(M.key, "vip_gift_config")
GameButtonManager.ExtLoadLua(M.key, "VIPGiftModel")
GameButtonManager.ExtLoadLua(M.key, "VIPGiftPanel")

local this  -- 单例
local lister
local model

function M.CheckIsShow()
    return true
end
function M.GotoUI(parm)
    if parm.goto_scene_parm == "panel" then
        return VIPGiftPanel.Create()
    else
        dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
    end
end
-- 活动的提示状态
function M.GetHintState(parm)
    return ACTIVITY_HINT_STATUS_ENUM.AT_Nor
end
function M.on_global_hint_state_set_msg(parm)
    if parm.gotoui == M.key then
        M.SetHintState()
    end
end
function M.SetHintState()
end

local function MakeLister()
    lister = {}
    lister["OnLoginResponse"] = this.OnLoginResponse
    lister["ReConnecteServerSucceed"] = this.OnReConnecteServerSucceed
    lister["ExitScene"] = this.OnExitScene
    lister["open_vip_gift"] = this.open_vip_gift
    lister["close_vip_gift"] = this.close_vip_gift
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

function M.Init()
    if not GameGlobalOnOff.VIPGift then
		return
    end
    M.Exit()
    this = M
    -- model = VIPGiftModel.Init()
    MakeLister()
    AddLister()
    return this
end

function M.Exit()
    if this then
        this = nil
        RemoveLister()
        M.Close()
        VIPGiftModel.Exit()
    end
end

--正常登录成功
function M.OnLoginResponse(result)
    if result==0 then
    	if model then
    		model.Exit()
    	end
    	model = VIPGiftModel.Init()
    else
    end
end
--断线重连后登录成功
function M.OnReConnecteServerSucceed(result)
    if result==0 then
    	if model then
    		model.Exit()
    	end
    	model = VIPGiftModel.Init()
    else
    end
end

function M.Close()
    VIPGiftPanel.Close()
end

function M.OnExitScene()
    M.Close()
end

function M.open_vip_gift()
    VIPGiftPanel.Create()
end

function M.close_vip_gift()
    M.Close()
end