-- 创建时间:2018-12-19

GameMoneyCenterLogic = {}
local M = GameMoneyCenterLogic
M.key = "sys_cfzx"
M.money_center_config = GameButtonManager.ExtLoadLua(M.key, "money_center_config")
GameButtonManager.ExtLoadLua(M.key, "GameMoneyCenterModel")
GameButtonManager.ExtLoadLua(M.key, "MoneyCenterShowPrefab")
GameButtonManager.ExtLoadLua(M.key, "GameMoneyCenterPanel")
GameButtonManager.ExtLoadLua(M.key, "GameMoneyCenterWYHBPanel")
GameButtonManager.ExtLoadLua(M.key, "GameMoneyCenterRHZQPanel")
GameButtonManager.ExtLoadLua(M.key, "GameMoneyCenterRHZQ1Panel")
GameButtonManager.ExtLoadLua(M.key, "GameMoneyCenterTGJJPanel")
GameButtonManager.ExtLoadLua(M.key, "GameMoneyCenterWDHYPanel")
GameButtonManager.ExtLoadLua(M.key, "GameMoneyCenterTGEWMPanel")
GameButtonManager.ExtLoadLua(M.key, "GameMoneyCenterTGLBPanel")
GameButtonManager.ExtLoadLua(M.key, "MoneyCenterWYHBPrefab")
GameButtonManager.ExtLoadLua(M.key, "MoneyCenterTGJJPrefab")
GameButtonManager.ExtLoadLua(M.key, "MoneyCenterTGLBPrefab")
GameButtonManager.ExtLoadLua(M.key, "MoneyCenterTGJJGoldPigPrefab")
GameButtonManager.ExtLoadLua(M.key, "MoneyCenterWDHYPrefab")
GameButtonManager.ExtLoadLua(M.key, "MoneyCenterVipHintPanel")
GameButtonManager.ExtLoadLua(M.key, "MoneyCenterShareHintPanel")
GameButtonManager.ExtLoadLua(M.key, "GameMoneyCenterContributePanel")
GameButtonManager.ExtLoadLua(M.key, "GameMoneyCenterIncomeSpendingPanel")
GameButtonManager.ExtLoadLua(M.key, "GameMoneyCenterSharePanel")
GameButtonManager.ExtLoadLua(M.key, "GameMoneyCenterTGPHBPanel")
GameButtonManager.ExtLoadLua(M.key, "WelComeToTGCJPanel")
GameButtonManager.ExtLoadLua(M.key, "AchievementTGManager")


local this -- 单例
local model

function M.CheckIsShow()
    return true
end
function M.GotoUI(parm)
    if parm.goto_scene_parm == "panel" then
        return GameMoneyCenterPanel.Create(parm.goto_scene_parm1)
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
    lister["OnLoginResponse"] = this.OnLoginResponse
    lister["open_game_money_center"] = this.open_game_money_center
end

function GameMoneyCenterLogic.Init()
    GameMoneyCenterLogic.Exit()
    this = GameMoneyCenterLogic
    MakeLister()
    AddLister()
    return this
end
function GameMoneyCenterLogic.Exit()
    if this then
        if model then
            model.Exit()
        end
		model = nil
		RemoveLister()
		this = nil
	end
end

--正常登录成功
function GameMoneyCenterLogic.OnLoginResponse(result)
    if result==0 then
    	if model then
    		model.Exit()
    	end
    	model = GameMoneyCenterModel.Init()
    end
end

function GameMoneyCenterLogic.open_game_money_center()
    GameMoneyCenterPanel.Create()
end