-- 创建时间:2020-07-27
-- Act_038_HLDHManager 管理器

local basefunc = require "Game/Common/basefunc"
Act_038_HLDHManager = {}
local M = Act_038_HLDHManager
M.key = "act_038_hldh"
local prefab
GameButtonManager.ExtLoadLua(M.key,"Act_038_HLDHPanel")
GameButtonManager.ExtLoadLua(M.key,"Act_038_HLDHPrefab")
--"♠ : 1","♥ : 2","♣ : 3","♦ : 4"
M.parm = {
    [1] = "prop_fish_drop_act_1",
    [2] = "prop_fish_drop_act_2",
    [3] = "prop_fish_drop_act_3",
    [4] = "prop_fish_drop_act_4",
    [5] = "prop_fish_drop_act_0",
}
M.parm_img = {
    [1] = "jfbd_icon_yb1",
    [2] = "jfbd_icon_yb2",
    [3] = "jfbd_icon_yb3",
    [4] = "jfbd_icon_yb4",
    [5] = "jfbd_icon_ybbx",
}
local this
local lister
-- 是否有活动
function M.IsActive()
    -- 活动的开始与结束时间
    local e_time = 1632758399
    local s_time = 1632180600
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
            return Act_038_HLDHPanel.Create(parm.parent)
        end
    elseif parm.goto_scene_parm == "enter" then
       
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

	this = Act_038_HLDHManager
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
    if not M.IsActive() then return end
    local is_nor = false
    local _permission_key  --= "bzdh_033_nor"
    local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key=_permission_key, is_on_hint = true}, "CheckCondition")
    if a and not b then
        is_nor = false
    else
        is_nor = true
    end
	if MainModel.myLocation == "game_Fishing" and is_nor then
        prefab = Act_038_HLDHPrefab.Create()
        prefab.gameObject:SetActive(false)
	end
end
--捕鱼有加载过程
function M.fishing_activity_begin()
	if prefab then
        Timer.New(
            function ()
                if IsEquals(prefab.gameObject) then
                    if FishingModel.data.game_id and FishingModel.data.game_id ~= 4 then
                        prefab.gameObject:SetActive(true)
                    end
                end
            end
        ,1,1):Start()
	end
end

function M.ExitScene()
	prefab = nil
end

function M.IsCanGetAward()
    for i = 1,4 do 
        if GameItemModel.GetItemCount(M.parm[i]) >= 2 then
            return true
        end
    end
    if GameItemModel.GetItemCount(M.parm[5]) >= 25 then
        return true
    end
    return false
end

function M.GetGiftNum()
    local a, b = GameButtonManager.RunFun({gotoui = "act_ty_gifts",gift_key = "gift_wykl_jflb"}, "GetBuyGiftsNumEx")
	if a then
		if b > 0 then
			return b
		end
	end
    return 0
end

function M.Refresh_Status()
    Event.Brocast("global_hint_state_change_msg",{gotoui = M.key})
end