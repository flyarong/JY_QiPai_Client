-- 创建时间:2020-05-01
-- Act_010_WYSCManager 管理器

local basefunc = require "Game/Common/basefunc"
Act_010_WYSCManager = {}
local M = Act_010_WYSCManager
M.key = "act_010_wysc"

local base_data = {
   [3] = {task_id = 21264,count = 1},
   [4] = {task_id = 21265,count = 2},
   [5] = {task_id = 21266,count = 4},
   [111] = {task_id = 21267,count = 8},
   [6] = {task_id = 21268,count = 18},
   [108] = {task_id = 21269,count = 38},
   [110] = {task_id = 21270,count = 98},
}

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
function M.CheckIsShow()
    return M.IsActive()
end
-- 活动面板调用
function M.CheckIsShowInActivity()
    return M.IsActive()
end

-- 所有可以外部创建的UI
function M.GotoUI(parm)
    dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
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
    lister["paypanel_goods_created"] = this.on_paypanel_goods_created
    lister["model_task_change_msg"] = this.on_model_task_change_msg
end

function M.Init()
	M.Exit()

	this = Act_010_WYSCManager
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
	end
end
function M.OnReConnecteServerSucceed()
end

local items = {}
items.jing_bi = {}
items.goods = {}
function M.on_paypanel_goods_created(data)
    if  1588028400 < os.time() and os.time() < 1588607999  then      
        local temp_ui = {}
        LuaHelper.GeneratingVar(data.prefab.transform, temp_ui)
        if M.CheckIsShow() then
            temp_ui.give_img.gameObject:SetActive(false)
            local GoodsData = data.goodsData
            if GoodsData.id == 7 and  GoodsData.type == "jing_bi" then-- 剔除钻石换金币
                return
            end
            if not base_data[GoodsData.goods_id] then return end --剔除不需要的
            local obj = newObject("act_010_wyscprefab", temp_ui.act_node)
            obj.transform.localPosition = Vector3.New(0,144,0)
            local obj_childs = {}
            LuaHelper.GeneratingVar(obj.transform, obj_childs)
            local task_id = base_data[GoodsData.goods_id].task_id
            dump(task_id,"<color=red>task_id</color>")
            if task_id and base_data[GoodsData.goods_id] then
                obj_childs.T_txt.text = "×"..base_data[GoodsData.goods_id].count
                if GoodsData.type == "jing_bi" then 
                    items.jing_bi[task_id] = obj
                elseif GoodsData.type == "goods" then
                    items.goods[task_id] = obj
                end
            else
                obj.gameObject:SetActive(false)  
            end
            M.RefreshItems()
        end
    end
end

function M.RefreshItems()
    for k ,v in pairs(items.jing_bi) do
        local data = GameTaskModel.GetTaskDataByID(k)
        if IsEquals(v) then
            v.gameObject:SetActive((data and data.now_process < 1))
        end
    end
    for k ,v in pairs(items.goods) do
        if IsEquals(v) then
            v.gameObject:SetActive(false)
        end
    end
end

function M.on_model_task_change_msg()
    M.RefreshItems()
end