-- 创建时间:2020-08-13
-- Act_065_ZNFKManager 管理器

local basefunc = require "Game/Common/basefunc"
Act_065_ZNFKManager = {}
local M = Act_065_ZNFKManager
M.key = "act_065_znfk"
GameButtonManager.ExtLoadLua(M.key, "Act_065_ZNFKSharePrefabMake")
GameButtonManager.ExtLoadLua(M.key, "Act_065_ZNFKLookBackPanel")
GameButtonManager.ExtLoadLua(M.key, "Act_065_BeginLookBackPanel")
GameButtonManager.ExtLoadLua(M.key, "Act_065_ZNFKPanel")
 
local this
local lister
M.gameName2Imgs = {
	ddz 	= {"斗地主","share_40_1","share_40_2"},
	mj      = {"麻将","share_40_3","share_40_4"},
	by      = {"街机捕鱼","share_40_7","share_40_8"},
	zjd     = {"敲敲乐","share_40_9","share_40_10"},
	xxl     = {"水果消消乐","share_40_11","share_40_12"},
	xxl_sh  = {"水浒消消乐","share_40_13","share_40_14"},
	xxl_cs  = {"财神消消乐","share_40_15","share_40_16"},
	xxl_xy  = {"西游消消乐","share_40_17","share_40_18"},
	ttl     = {"弹弹乐","share_40_19","share_40_20"},
	pgdz    = {"苹果大战","share_40_21","share_40_22"},
	fkby    = {"疯狂捕鱼","share_40_23","share_40_24"},
	jddld   = {"金蛋大乱斗","share_40_25","share_40_26"},
    dmbj    = {"盗墓笔记","share_40_27","share_40_28"},
    lwzb    = {"龙王争霸","share_40_27","share_40_28"},
    xxl_cj  = {"超级消消乐","share_40_27","share_40_28"},
    rxcq    = {"热血传奇","share_40_27","share_40_28"},
    xxl_sg  = {"三国消消乐","share_40_27","share_40_28"},
	default = {"游戏玩家","share_40_27","share_40_28"},
}
M.task_ids = {21866, 21867, 21868, 21869, 21870, 21871, 21872}

M.per_mis = {
    "actp_own_task_21866",
    "actp_own_task_21867",
    "actp_own_task_21868",
    "actp_own_task_21869",
    "actp_own_task_21870",
    "actp_own_task_21871",
    "actp_own_task_21872",
}

-- 是否有活动
function M.IsActive()
    -- 活动的开始与结束时间
    local e_time
    local s_time
    if (e_time and os.time() > e_time) or (s_time and os.time() < s_time) then
        return false
    end

    if not this.Is_Backer then
        return false
    end

    return true
    --return this.Is_Backer
end
-- 创建入口按钮时调用
function M.CheckIsShow()
    return M.IsActive()
end
-- 活动面板调用
function M.CheckIsShowInActivity()
    return M.IsActive()
end

-- 所有可以外部创建的UI
function M.GotoUI(parm)
    -- dump(parm, "<color=red>++++111111111111111111111+++</color>")
	-- dump(parm, "<color=red>++++111111111111111111111+++</color>")
    if parm.goto_scene_parm == "begin" then
        if this.Is_Backer and PlayerPrefs.GetInt(MainModel.UserInfo.user_id..M.key,0) == 0 then
            PlayerPrefs.SetInt(MainModel.UserInfo.user_id..M.key,1)
            if this.Is_Backer then
                return Act_065_BeginLookBackPanel.Create()
            end
        end
    elseif parm.goto_scene_parm == "panel" then
        return Act_065_ZNFKPanel.Create(parm.parent)
    elseif parm.goto_scene_parm == "act_panel" then
        if this.Is_Backer then
            return Act_065_ZNFKLookBackPanel.Create()

        end
    end
    --dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
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
-- 更新活动的提示状态(针对那种 打开界面就需要修改状态的需求)
function M.SetHintState()
    Event.Brocast("global_hint_state_change_msg", { gotoui = M.key })
end


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
    lister["AssetChange"] = this.OnAssetChange
    lister["OnLoginResponse"] = this.OnLoginResponse
    lister["query_znq_look_back_base_info_response"] = this.on_query_znq_look_back_base_info_response
    lister["ReConnecteServerSucceed"] = this.OnReConnecteServerSucceed
    lister["global_hint_state_set_msg"] = this.on_global_hint_state_set_msg
end

function M.Init()
	M.Exit()

	this = Act_065_ZNFKManager
	this.m_data = {}
	MakeLister()
    AddLister()
	M.InitUIConfig()
end
function M.Exit()
	if this then
		RemoveLister()
		this = nil
	end
end
function M.InitUIConfig()
    this.UIConfig = {}
end

function M.OnLoginResponse(result)
	if result == 0 then
        -- 数据初始化
        Network.SendRequest("query_znq_look_back_base_info")
	end
end
function M.OnReConnecteServerSucceed()
end

function M.on_query_znq_look_back_base_info_response(_,data)
	-- dump(data, "<color=red>++++on_query_znq_look_back_base_info_response+++</color>")
    this.Is_Backer = false
    if data and data.result == 0 then
        if  table_is_null(data.player_data) then
            this.Is_Backer = false  
        else
            this.m_data = data.player_data
            this.Is_Backer = true
        end
    end
end

function M.IsBacker()
    return this.Is_Backer and true
end

function M.GetData()
    return this.m_data
end

function M.GetLevel()
    local cheak_func = function(per)
        local _permission_key = per
        if _permission_key then
            local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key=_permission_key, is_on_hint = true}, "CheckCondition")
            if a and not b then
                return false
            end
            return true
        else
            return true
        end
    end

    for i = 1,#M.per_mis do
        if cheak_func(M.per_mis[i]) then
            return i
        end
    end
end

function M.GetTaskID()
    return  M.task_ids[M.GetLevel()]
end

function M.IsAwardCanGet()
    local data = GameTaskModel.GetTaskDataByID(M.GetTaskID())
    return data and data.award_status == 1
end

function M.OnAssetChange(data)
    --dump(data,"<color=red>奖励获得</color>")
end