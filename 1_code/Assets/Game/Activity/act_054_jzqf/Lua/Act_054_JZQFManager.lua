-- 创建时间:2021-03-17
-- Act_054_JZQFManager 管理器

local basefunc = require "Game/Common/basefunc"
Act_054_JZQFManager = {}
local M = Act_054_JZQFManager
M.key = "act_054_jzqf"
M.config = GameButtonManager.ExtLoadLua(M.key, "act_054_jzqf_config") 
GameButtonManager.ExtLoadLua(M.key, "Act_054_JZQFPanel") 
GameButtonManager.ExtLoadLua(M.key, "Act_054_JZQFMorePanel") 

local this
local lister

--prop_qmjz_xiang
M.item1_key = "prop_qmjz_xiang"
M.item2_key = "shop_gold_sum"
M.item1_consume_num = 10
M.item2_consume_num = 200
M.endTime = 1617638399


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
    if parm.goto_scene_parm == "panel" then
        return Act_054_JZQFPanel.Create(parm.parent)
    end 

    dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
end
-- 活动的提示状态
function M.GetHintState(parm)
	if parm and parm.gotoui == M.key then 
        if not M.CheckIsShowInActivity(parm) then
            return ACTIVITY_HINT_STATUS_ENUM.AT_Nor
        end
        if M.IsHintGet()  then
            return ACTIVITY_HINT_STATUS_ENUM.AT_Get
        else
            -- local newtime = tonumber(os.date("%Y%m%d", os.time()))
            -- local oldtime = tonumber(os.date("%Y%m%d", tonumber(PlayerPrefs.GetString(M.key .. MainModel.UserInfo.user_id, 0))))
            -- if oldtime ~= newtime then
            --     return ACTIVITY_HINT_STATUS_ENUM.AT_Red
            -- end
            return ACTIVITY_HINT_STATUS_ENUM.AT_Nor
        end
    end 
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
    lister["AssetChange"] = this.on_asset_change
    lister["year_btn_created"] = this.on_year_btn_created
end

function M.Init()
	M.Exit()

	this = Act_054_JZQFManager
	this.m_data = {}
	MakeLister()
    AddLister()
	M.InitUIConfig()

    local check_func = function (type)
        if type == "task_award_no_show" then
            return true
        end
    end
    MainModel.AddUnShow(check_func)
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

function M.on_asset_change(data)
    --dump(data,"<color=white>+++++on_asset_change+++++</color>")
    Event.Brocast("global_hint_state_change_msg",{gotoui = M.key})
    if data.change_type and data.change_type == "task_award_no_show" and data.data[1].asset_type == "prop_qmjz_xiang" then
        dump("<color=white>+++++PrefabCreator+++++</color>")
        M.PrefabCreator(data.data[1].value)
    end
end

local btn_gameObject
function M.on_year_btn_created(_data)
    if _data and _data.enterSelf then
        btn_gameObject = _data.enterSelf.gameObject
    end
end

function M.PrefabCreator(value)
    local temp_ui = {}
    local can_auto = true
    local can_click = true
    local obj = newObject("Act_Ty_ExchangeItemGetPrefab", GameObject.Find("Canvas/LayerLv50").transform)
    --math.randomseed(tostring(os.time()):reverse():sub(1, 7))
    obj.transform.position = Vector3.New(0, 550, 0)
    LuaHelper.GeneratingVar(obj.transform, temp_ui)
    temp_ui.Image:GetComponent("Image").sprite = GetTexture("jzqf_icon_xiang")
    temp_ui.num_txt.text = "+" .. value
    local t = Timer.New(function()
        if can_auto then
            M.FlyAnim(obj)
            can_click = false
        end
    end, 1, 1)
    t:Start()
end

function M.FlyAnim(obj)
    if not IsEquals(obj) then return end
    local a = obj.transform.position
    local seq = DoTweenSequence.Create({ dotweenLayerKey = "jzqf_fly" })
    local path = {}
    path[0] = a
    path[1] = Vector3.New(0, 0, 0)
    seq:Append(obj.transform:DOLocalPath(path, 2, DG.Tweening.PathType.CatmullRom))
    seq:AppendInterval(1.6)
    if IsEquals(btn_gameObject) then
        local b = btn_gameObject.transform.position
        local path2 = {}
        path2[0] = Vector3.New(0, 0, 0)
        path2[1] = Vector3.New(b.x - 30, b.y + 30, 0)
        seq:Append(obj.transform:DOLocalPath(path2, 2, DG.Tweening.PathType.CatmullRom))
    end
    seq:OnKill(function()
        if IsEquals(obj) then
            local temp_ui = {}
            LuaHelper.GeneratingVar(obj.transform, temp_ui)
            temp_ui.Image.gameObject:SetActive(false)
            temp_ui.glow_01.gameObject:SetActive(false)
            temp_ui.num_txt.gameObject:SetActive(true)
            Timer.New(function()
                if IsEquals(obj) then
                    destroy(obj)
                end
            end, 2, 1):Start()
        end
    end)
end


function M.IsHintGet()
    if MainModel.GetItemCount(M.item1_key) > M.item1_consume_num 
    or MainModel.GetItemCount(M.item2_key) > M.item2_consume_num then
        return true
    end
    return false
end

function M.GetItemCount(kind)
    if kind == 1 then
        return MainModel.GetItemCount(M.item1_key)
    elseif kind == 2 then 
        return MainModel.GetItemCount(M.item2_key)
    end
    return 0
end