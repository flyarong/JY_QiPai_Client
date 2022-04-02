-- 创建时间:2020-07-27
-- Act_032_XXLDHManager 管理器

local basefunc = require "Game/Common/basefunc"
Act_032_XXLDHManager = {}
local M = Act_032_XXLDHManager
M.key = "act_032_xxldh"
local prefab

local parm_1 = {
    "prop_sgxxl_apple",
    "prop_sgxxl_bell",
    "prop_sgxxl_watermelon",
    "prop_sgxxl_redseven",
    "prop_sgxxl_bar",
}
--money "105407","prop_shxxl_axe",2000
local parm_2 = {
    "prop_shxxl_bowl",
    "prop_shxxl_winejar",
    "prop_shxxl_coin",
    "prop_shxxl_ingot",
    "prop_shxxl_axe",
}

local parm_3 = {
    "prop_csxxl_coin",
    "prop_csxxl_gemstone",
    "prop_csxxl_ruyi",
    "prop_csxxl_goldpig",
    "prop_csxxl_mammon",
}

local parm_4 = {
    "prop_xyxxl_kasaya",
    "prop_xyxxl_goldbowl",
    "prop_xyxxl_jadevase",
    "prop_xyxxl_sapodilla",
    "prop_xyxxl_scripture",
}

local parm_img1 = {
    "xxl_iconnew_1",
    "xxl_iconnew_2",
    "xxl_iconnew_3",
    "xxl_iconnew_4",
    "xxl_iconnew_5"
}

local parm_img2 = {
    "shxxl_iconnew_1",
    "shxxl_iconnew_2",
    "shxxl_iconnew_3",
    "shxxl_iconnew_4",
    "shxxl_iconnew_5"
}

local parm_img3 = {
    "csxxl_iconnew_1",
    "csxxl_iconnew_2",
    "csxxl_iconnew_3",
    "csxxl_iconnew_4",
    "csxxl_iconnew_5"
}

local parm_img4 = {
    "sdbgj_iconnew_dj1",
    "sdbgj_iconnew_dj2",
    "sdbgj_iconnew_dj3",
    "sdbgj_iconnew_dj4",
    "sdbgj_iconnew_dj5"
}
M.parm_img = {
    parm_img1,parm_img2,parm_img3,parm_img4
}
M.parm = {
    parm_1,parm_2,parm_3,parm_4
}

M.ex_change = {
	{need = {{parm = 1,num =100}},award ={{num = 10,_type = "jifen"},{num = 500,_type = "jing_bi"},{num = 5,_type = "jifen"}}},
	{need = {{parm = 2,num =100}},award ={{num = 20,_type = "jifen"},{num = 800,_type = "jing_bi"},{num = 10,_type = "jifen"}}},
	{need = {{parm = 3,num =70}},award ={{num = 30,_type = "jifen"},{num = 1000,_type = "jing_bi"},{num = 15,_type = "jifen"}}},
	{need = {{parm = 4,num =50}},award ={{num = 50,_type = "jifen"},{num = 1500,_type = "jing_bi"},{num = 25,_type = "jifen"}}},
	{need = {{parm = 5,num =30}},award ={{num = 100,_type = "jifen"},{num = 2000,_type = "jing_bi"},{num = 50,_type = "jifen"}}},
	{need = {{parm = 1,num =100},{parm = 2,num =80}},award ={{num = 30,_type = "jifen"},{num = 1000,_type = "jing_bi"},{num = 15,_type = "jifen"}}},
	{need = {{parm = 3,num =70},{parm = 4,num =50},{parm = 5,num = 30}},award ={{num = 200,_type = "jifen"},{num = 4500,_type = "jing_bi"},{num = 100,_type = "jifen"}}},
	{need = {{parm = 1,num =100},{parm = 2,num =100},{parm = 3,num =70},{parm = 4,num =50},{parm = 5,num =30}},award ={{num = 250,_type = "jifen"},{num = 1,_type = "shop_gold_sum"},{num = 120,_type = "jifen"}}},
}

M.ex_ids = {
	{67,68,69,70,71,72,73,74,},
	{75,76,77,78,79,80,81,82,},
	{83,84,85,86,87,88,89,90,},
	{91,92,93,94,95,96,97,98,},
}



local this
local lister
GameButtonManager.ExtLoadLua(M.key,"Act_032_XXLDHPanel")

-- 是否有活动
function M.IsActive()
    -- 活动的开始与结束时间
    local e_time = 2597679999
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
    if parm.goto_scene_parm == "panel" then
        if M.IsActive() then
            return Act_032_XXLDHPanel.Create(parm.parent)
        end
    elseif parm.goto_scene_parm == "enter" then
        if M.IsActive() then
            return Act_022_JFPHBEnterPrefab.Create(parm.parent, parm.cfg)
        end 
    end 
end
-- 活动的提示状态
function M.GetHintState(parm)
    if M.IsCanGetAward() then
        return ACTIVITY_HINT_STATUS_ENUM.AT_Get
    end
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
    lister["EnterScene"] = M.EnterScene
    lister["ExitScene"] = M.ExitScene
    lister["fishing_activity_begin"] = M.fishing_activity_begin
end

function M.Init()
	M.Exit()

	this = Act_032_XXLDHManager
	this.m_data = {}
	MakeLister()
    AddLister()
    M.InitUIConfig()
    MainModel.AddUnShow(function(t)
        if t == "task_award_xxl_element_collection_task" then
            return true
        end
    end)
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

function M.IButton()
    
end

function M.MaxShowNum(num,len,obj)
    local func = function (num)
        local str = "9"
        for i = 1,num do
            str = str.."9"
        end
        return  str
    end
    if num >= math.pow(10,len) then
        num = func(len - 1)
        if obj and (IsEquals(obj)) then
            obj.gameObject:SetActive(true)
        end
    else
        if obj and (IsEquals(obj)) then
            obj.gameObject:SetActive(false)
        end
    end
    return num
end

function M.EnterScene()
   
end
--捕鱼有加载过程
function M.fishing_activity_begin()
	-- if prefab then
    --     Timer.New(
    --         function ()
    --             if IsEquals(prefab.gameObject) then
    --                 if FishingModel.data.game_id and FishingModel.data.game_id ~= 4 then
    --                     prefab.gameObject:SetActive(true)
    --                 end
    --             end
    --         end
    --     ,1,1):Start()
	-- end
end

function M.ExitScene()
	prefab = nil
end

function M.IsCanGetAward()
    local cheak_func1 = function (parm,num)
        for i = 1,4 do
            if GameItemModel.GetItemCount(M.GetTypeName(i)[parm]) >= num then
                return true
            end
        end
		return false
    end
    local cheak_func2 = function(Index)
        if M.ex_change[Index] then
            for i=1,#M.ex_change[Index].need do
                if cheak_func1(M.ex_change[Index].need[i].parm,M.ex_change[Index].need[i].num) == false then
                    return false
                end
            end
            return true
        end
    end
    
    for i = 1,#M.ex_change do
        if cheak_func2(i) then
            return true
        end
    end
	return false
end

function M.GetImageName(index)
    return M.parm_img[index]
end

function M.GetTypeName(index)
    return M.parm[index]
end