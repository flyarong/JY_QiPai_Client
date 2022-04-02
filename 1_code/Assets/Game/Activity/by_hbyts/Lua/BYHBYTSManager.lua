-- 创建时间:2021-01-28
-- BYHBYTSManager 管理器

local basefunc = require "Game/Common/basefunc"
BYHBYTSManager = {}
local M = BYHBYTSManager
M.key = "by_hbyts"
GameButtonManager.ExtLoadLua(M.key, "BYHBYTSEnterPrefab")

local this
local lister

-- 是否有活动
function M.IsActive()
    -- 活动的开始与结束时间
    local e_time
    local s_time
    if (e_time and os.time() > e_time) or (s_time and os.time() < s_time) then
        return false
    end

    if MainModel.myLocation ~= "game_Fishing3D"
        or not FishingModel
        or not this.UIConfig.game_map[FishingModel.game_id]
        or not FishingModel.GetPlayerData()
        or not this.m_data.down_t
        or this.m_data.down_t <= os.time() then
        return false
    end

    -- 对应权限的key
    local _permission_key
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
-- 创建入口按钮时调用
function M.CheckIsShow(parm, type)
    return M.IsActive()
end
-- 活动面板调用
function M.CheckIsShowInActivity()
    return M.IsActive()
end

-- 所有可以外部创建的UI
function M.GotoUI(parm)
    if not M.CheckIsShow(parm) then
        dump(parm, "<color=red>不满足条件</color>")
        return
    end
    if parm.goto_scene_parm == "enter" then
        return BYHBYTSEnterPrefab.Create(parm)
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
    lister["OnLoginResponse"] = this.OnLoginResponse
    lister["ReConnecteServerSucceed"] = this.OnReConnecteServerSucceed
    lister["global_hint_state_set_msg"] = this.on_global_hint_state_set_msg

    lister["ExitScene"] = this.OnExitScene
    lister["fishing_ready_finish"] = this.on_fishing_ready_finish
    lister["model_fish_wave"] = this.on_model_fish_wave
    lister["nor_fishing_3d_nor_query_image_create_list_response"] = this.on_query_image_create_list
    lister["model_time_skill_change_msg"] = this.on_model_time_skill_change_msg
end

function M.Init()
	M.Exit()

	this = BYHBYTSManager
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

    this.UIConfig.game_map = {}
    this.UIConfig.game_map[2] = {}
    this.UIConfig.game_map[3] = {}
    this.UIConfig.game_map[4] = {}
    this.UIConfig.game_map[5] = {}
end

function M.OnLoginResponse(result)
    if result == 0 then
        -- 数据初始化
    end
end
function M.OnReConnecteServerSucceed()
end

function M.GetDownTime()
    return this.m_data.down_t
end
--[[
random = 1,--随机鱼潮
guding = 2,--固定鱼潮
boss = 3,--boss鱼潮
--]]
function M.CheckDownTime()
    if FishingModel and FishingModel.data and FishingModel.data.image_type_index then
        dump(FishingModel.data.image_type_index, "<color=red>|||||||||||||||||||||</color>")
        dump(this.m_data.image_create_list, "<color=red>|||||||||||||||||||||</color>")
        if FishingModel.data.image_type_index ~= 3 then
            local tt = 0
            if this.m_data.image_create_list then
                for k,v in ipairs(this.m_data.image_create_list) do
                    if v.type == 1 then
                        tt = tt + 300
                        break
                    end
                    if v.type == 3 then
                        break
                    end
                    tt = tt + v.time/10
                end
            end
            dump(tt, "<color=red>|||||||||||||||||||||</color>")
            if FishingModel.data.end_time > FishingModel.data.system_time then
                tt = tt + (FishingModel.data.end_time - FishingModel.data.system_time)
            end
            dump(tt, "<color=red>|||||||||||||||||||||</color>")
            if FishingModel.data.image_type_index ~= 1 and tt > 0 then
                this.m_data.down_t = os.time() + tt
                dump(this.m_data.down_t, "<color=red>|||||||||||||||||||||</color>")
                Event.Brocast("ui_button_data_change_msg", {key=M.key})
            end
            if FishingModel.data.image_type_index == 1 and tt > 120 then
                dump((tt-120)%300)
                this.m_data.down_t = os.time() + (tt-120)%300
                dump(this.m_data.down_t, "<color=red>|||||||||||||||||||||</color>")
                Event.Brocast("ui_button_data_change_msg", {key=M.key})
            end
        end
    end
end

function M.UpdateData()
    this.m_data.cur_image_type_index = FishingModel.data.image_type_index
    dump(this.m_data.cur_image_type_index)
    if this.m_data.cur_image_type_index == 3 then
        this.m_data.down_t = nil
        Event.Brocast("ui_button_data_change_msg", {key=M.key})
    else
        Network.SendRequest("nor_fishing_3d_nor_query_image_create_list")    
    end
end

function M.OnExitScene()
    this.m_data = {}
end

function M.on_fishing_ready_finish()
    if FishingModel and FishingModel.data and FishingModel.data.image_type_index then
        M.UpdateData()
    end
end
function M.on_model_fish_wave()
    dump(this.m_data.cur_image_type_index)
    if this.m_data.cur_image_type_index == 3 then -- boss鱼潮结束需要重新获取数据
        M.UpdateData()
    else
        this.m_data.cur_image_type_index = FishingModel.data.image_type_index
    end
end
function M.on_query_image_create_list(_, data)
    dump(data, "<color=red>on_query_image_create_list</color>")
    if data.result == 0 then
        this.m_data.image_create_list = data.image_create_list
        M.CheckDownTime()
    end
end
function M.on_model_time_skill_change_msg(seat_num, skill_type, is_lose, t)
    if skill_type == "frozen" and not is_lose and this.m_data.down_t and t then
        this.m_data.down_t = this.m_data.down_t + t
        Event.Brocast("by_bossts_down_time_change_msg")
    end
end
