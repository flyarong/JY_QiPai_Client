local basefunc = require "Game/Common/basefunc"
Act_010_WYWBManager = {}
local M = Act_010_WYWBManager
M.key = "act_010_wywb"
local this
local lister
local btn_gameObject
local NotDuringAnim = true
GameButtonManager.ExtLoadLua(M.key, "Act_010_WYWBPanel")
GameButtonManager.ExtLoadLua(M.key, "Act_010_WYWBMorePanel")
package.loaded["Game.CommonPrefab.Lua.common_robot_names_boy"] = nil
local boy_names = require "Game.CommonPrefab.Lua.common_robot_names_boy"

package.loaded["Game.CommonPrefab.Lua.common_robot_names_girl"] = nil
local girl_names = require "Game.CommonPrefab.Lua.common_robot_names_girl"

M.config = GameButtonManager.ExtLoadLua(M.key, "activity_010_wywb_config")
M.task_id = 21262
M.game_task_id = 21263
M.last_process = 0
M.box_id = 17
-- 是否有活动
function M.IsActive()
    local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key="actp_own_task_p_recharge_shovel_value", is_on_hint = true}, "CheckCondition")
    if a and not b then
        return false
    end
    return true
end
-- 创建入口按钮时调用
function M.CheckIsShow()
    if M.IsActive() then
        -- 活动的开始与结束时间
        local e_time =  -1
        local s_time =  2583796600
        if (not e_time or os.time() < e_time) and (not s_time or os.time() > s_time) then
            return true and MainModel.user_id.ui_config_id == 1
        end
    end
    return false
end
-- 活动面板调用
function M.CheckIsShowInActivity()
    return M.IsActive()
end

-- 所有可以外部创建的UI
function M.GotoUI(parm)
    if parm.goto_scene_parm == "panel" then
        return Act_010_WYWBPanel.Create(parm.parent)
    end 
end
-- 活动的提示状态
function M.GetHintState(parm)
    if parm and parm.gotoui == M.key then 
        if not M.CheckIsShowInActivity(parm) then
            return ACTIVITY_HINT_STATUS_ENUM.AT_Nor
        end
        if GameItemModel.GetItemCount("prop_shovel") >= 2 or M.CheakAwardCanGet() then
            return ACTIVITY_HINT_STATUS_ENUM.AT_Get
        else
            local newtime = tonumber(os.date("%Y%m%d", os.time()))
            local oldtime = tonumber(os.date("%Y%m%d", tonumber(PlayerPrefs.GetString(M.key .. MainModel.UserInfo.user_id, 0))))
            if oldtime ~= newtime then
                return ACTIVITY_HINT_STATUS_ENUM.AT_Red
            end
            return ACTIVITY_HINT_STATUS_ENUM.AT_Nor
        end
    end 
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
    lister["AssetChange"] = this.OnAssetChange
    lister["year_btn_created"] = this.on_year_btn_created
    lister["model_task_change_msg"] = this.on_model_task_change_msg
    lister["EnterScene"] = this.OnEnterScene
    lister["model_query_one_task_data_response"] = this.model_query_one_task_data_response
end

function M.Init()
	M.Exit()
	this = Act_010_WYWBManager
	this.m_data = {}
	MakeLister()
    AddLister()
    M.InitUIConfig()
    M.SendBroadcastInfo()
end
function M.Exit()
	if this then
		RemoveLister()
		this = nil
	end
end
function M.InitUIConfig()
    this.UIConfig={
    }
end

function M.OnLoginResponse(result)
    if result == 0 then
		Network.SendRequest("query_one_task_data", {task_id = M.game_task_id})
	end
end
function M.OnReConnecteServerSucceed()
end

function M.on_global_hint_state_set_msg(parm)
	if parm.gotoui == M.key then
		M.SetHintState()
        Event.Brocast("global_hint_state_change_msg", parm)
	end
end
-- 更新活动的提示状态(针对那种 打开界面就需要修改状态的需求)
function M.SetHintState()
    PlayerPrefs.SetString(M.key .. MainModel.UserInfo.user_id, os.time())
end

function M.OnAssetChange(data)
    Event.Brocast("global_hint_state_change_msg",{gotoui = M.key})
    if data.change_type and data.change_type == "task_p_digging_treasure" then
        if not IsEquals(btn_gameObject) then return end
        local temp_ui = {}
        local obj = newObject("Act_010_WYWBchanziPrefab",GameObject.Find("Canvas/LayerLv50").transform)
        math.randomseed(tostring(os.time()):reverse():sub(1, 7))
        obj.transform.position = Vector3.New(math.random(-800,800),math.random(-400,400),0)
        LuaHelper.GeneratingVar(obj.transform, temp_ui)
        temp_ui.yes_btn.onClick:AddListener(
            function ()
                if NotDuringAnim then
                    M.ChanziFlyAnim(obj)
                end
            end
        )
        M.Test(obj)
	end
end

function M.Test(obj)
    Timer.New(
        function()
            M.ChanziFlyAnim(obj)
        end,3,1
    ):Start()
end

function M.on_year_btn_created(data)
    if data and data.enterSelf then
        btn_gameObject = data.enterSelf.gameObject
    end
end

function M.ChanziFlyAnim(obj)
    if IsEquals(btn_gameObject) == false then return end
    if IsEquals(obj) == false then return end
    local path = {}
    local a  = obj.transform.position
    local b  = btn_gameObject.transform.position
    path[0] = a
    path[1] = Vector3.New((a.x > b.x and math.random(a.x,b.x) or math.random(b.x,a.x)) + 60,(a.y > b.y and math.random(a.y,b.y) or math.random(b.y,a.y)) + 60,0)
    path[2] = Vector3.New(b.x - 30,b.y + 30 ,0)
    if true then
        local targetV3 = btn_gameObject.transform.position
        NotDuringAnim = false
        local seq = DoTweenSequence.Create()
		seq:Append(obj.transform:DOLocalPath(path,2,DG.Tweening.PathType.CatmullRom))
		seq:OnKill(function ()
			if IsEquals(btn_gameObject) then 
                --obj.transform.position = Vector3.New(path[2].x,path[2].y,path[2].z)
                destroy(obj)
                NotDuringAnim = true
			end 
		end)
    end
end


function M.GetRomdomAwardName()
    this.total = this.total or 0
    if table_is_null(this.area) then
        local area = {}
        local get_area_fun = function (_M)
            local _min = 0
            local _max = 0
            for i = 1,_M do 
                _max = _max + M.config.fake_base[i].weight
                if i >= 2 then 
                    _min = _min + M.config.fake_base[i - 1].weight
                else
                    _min = 0
                end 
            end
            area[_M] = {_min = _min,_max = _max}
        end

        for i = 1 ,#M.config.fake_base do 
            this.total = this.total + M.config.fake_base[i].weight
            get_area_fun(i)
        end
        this.area = area
    end
    local r = math.random(1,this.total * 10)
    local get_award_index = 1
    for i = 1,#this.area do
        local r = r / 10
        if r >= this.area[i]._min and r <= this.area[i]._max then 
            get_award_index = i
            break
        end
    end
    local award_name = M.config.fake_base[get_award_index].award_name
    if M.config.fake_base[get_award_index].asset_type == "shop_gold_sum" then
        award_name = "福卡".." x"
    elseif M.config.fake_base[get_award_index].asset_type == "jing_bi" then 
        award_name = "鲸币".." x"
    end
    local award_count = 1
    if type(M.config.fake_base[get_award_index].asset_count) == "table" then 
        local r = math.random(M.config.fake_base[get_award_index].asset_count[1],M.config.fake_base[get_award_index].asset_count[2])
        award_count = r
    else
        award_count = M.config.fake_base[get_award_index].asset_count or ""
    end
    if M.config.fake_base[get_award_index].asset_type == "shop_gold_sum" then 
        award_count = award_count / 100
    end
    return award_name..award_count
end
function M.SendBroadcastInfo()
    math.randomseed(tostring(os.time()):reverse():sub(1, 7))
    local random = math.random(1,8)
    local curr_Hour = tonumber(os.date("%H",os.time()))
    if curr_Hour <= 5 or curr_Hour >= 22 then 
        random = math.random(8,20)
    end 
    local func = function ()
        Event.Brocast("Act_010_wywb_Broadcast_Info",{playname = M.GetPlayerName(),awardname = M.GetRomdomAwardName()})
    end 
    if this_timer then 
        this_timer:Stop()
    end
    this_timer = nil 
    this_timer = Timer.New(function ()
        func()
        M.SendBroadcastInfo()
    end,random,1)
    this_timer:Start()
end

function M.GetPlayerName()
    local random = math.random(0,99)
    local name
    if random > 30 then 
        name = basefunc.deal_hide_player_name(boy_names[math.random(1,#boy_names)])
    else
        name = basefunc.deal_hide_player_name(girl_names[math.random(1,#girl_names)])
    end
    return name
end

function M.on_model_task_change_msg(data)
    dump(data,"<color=red>任务数据000000</color>")
    if data and data.id == M.game_task_id then
       
    end
end

function M.OnEnterScene()
    NotDuringAnim = true
end

function M.model_query_one_task_data_response(data)
end

function M.CheakAwardCanGet()
    local data = GameTaskModel.GetTaskDataByID(M.task_id)
    if data and data.award_status == 1 then
        return true
    end
    return false
end