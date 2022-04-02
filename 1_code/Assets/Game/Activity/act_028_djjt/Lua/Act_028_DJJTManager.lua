-- 创建时间:2020-08-20
-- Act_028_DJJTManager 管理器

local basefunc = require "Game/Common/basefunc"
Act_028_DJJTManager = {}
local M = Act_028_DJJTManager
M.key = "act_028_djjt"
local this
local lister
local btn_gameObject
M.item_keys = {
    "prop_2year_pintu1",
    "prop_2year_pintu2",
    "prop_2year_pintu3",
    "prop_2year_pintu4",
    "prop_2year_pintu5"
}
M.task_ids = {
    21468,
    21469,
    21470,
    21471,    
}
M.shop_id = 10409
local item_keys = M.item_keys
GameButtonManager.ExtLoadLua(M.key,"Act_028_DJJTPanel")
GameButtonManager.ExtLoadLua(M.key,"Act_028_DJJTLBPanel")
-- 是否有活动
function M.IsActive()
    -- 活动的开始与结束时间
    local e_time = 1600099199
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
        return Act_028_DJJTPanel.Create(parm.parent)
    end
    dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
end
-- 活动的提示状态
function M.GetHintState(parm)
    if M.IsCanGetAward() then
        return ACTIVITY_HINT_STATUS_ENUM.AT_Get  
    end
    local newtime = tonumber(os.date("%Y%m%d", os.time()))
    local oldtime = tonumber(os.date("%Y%m%d", tonumber(PlayerPrefs.GetString(M.key .. MainModel.UserInfo.user_id, 0))))
    if oldtime ~= newtime then
        return ACTIVITY_HINT_STATUS_ENUM.AT_Red
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
    PlayerPrefs.SetString(M.key .. MainModel.UserInfo.user_id, os.time())
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
    lister["pdkclear_created"] = this.on_pdkclear_created
    lister["ddzfreeclear_created"] = this.on_ddzfreeclear_created
    lister["mjfreeclear_created"] = this.on_mjfreeclear_created
    lister["model_task_change_msg"] = this.on_model_task_change_msg
    lister["year_btn2_created"] = this.on_year_btn_created
    lister["OnLoginResponse"] = this.OnLoginResponse
    lister["ReConnecteServerSucceed"] = this.OnReConnecteServerSucceed
    lister["global_hint_state_set_msg"] = this.on_global_hint_state_set_msg
end

function M.Init()
	M.Exit()

	this = Act_028_DJJTManager
	this.m_data = {}
	MakeLister()
    AddLister()
    M.AddUnShowAward()
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
--是否可以领奖
function M.IsCanGetAward()
    local need_num = 0
    for i = 1,4 do
        if GameItemModel.GetItemCount(item_keys[i]) <= 0 then
            need_num = need_num + 1
        end
    end
    if need_num == 0 or GameItemModel.GetItemCount(item_keys[5]) >= need_num then
        return true
    end 
    return false 
end

function M.on_year_btn_created(data)
    if data and data.enterSelf then
        btn_gameObject = data.enterSelf.gameObject
    end
end


function M.IsUseWan()
    local need_type_num = 0
    for i = 1,#M.item_keys - 1 do
        if GameItemModel.GetItemCount(M.item_keys[i]) <= 0 then
            need_type_num = need_type_num + 1
        end
    end
    if need_type_num ~= 0 and GameItemModel.GetItemCount(M.item_keys[5]) >= need_type_num then
        return true
    else
        return false 
    end
end


function M.FlyAnim(obj)
    if not IsEquals(btn_gameObject) then return end
    if not IsEquals(obj) then return end
   
    local a  = obj.transform.position
    local b  = btn_gameObject.transform.position
    --path[2] = Vector3.New(0,0,0)
    
    if true then
        local targetV3 = btn_gameObject.transform.position
        local seq = DoTweenSequence.Create()
        local path = {}
        path[0] = a
        path[1] = Vector3.New(0,0,0)
        seq:Append(obj.transform:DOLocalPath(path,2,DG.Tweening.PathType.CatmullRom))
        seq:AppendInterval(1.6)
        local path2 = {}
        path2[0] = Vector3.New(0,0,0)
        path2[1] = Vector3.New(b.x - 30,b.y + 30 ,0)
        seq:Append(obj.transform:DOLocalPath(path2,2,DG.Tweening.PathType.CatmullRom))
		seq:OnKill(function ()
			if IsEquals(btn_gameObject) and IsEquals(obj) then 
                --obj.transform.position = Vector3.New(path[2].x,path[2].y,path[2].z)
                local temp_ui = {}
                LuaHelper.GeneratingVar(obj.transform, temp_ui)
                temp_ui.award_img.gameObject:SetActive(false)
                temp_ui.glow_01.gameObject:SetActive(false)
                temp_ui.num_txt.gameObject:SetActive(true)
                Timer.New(function ()
                    if IsEquals(obj) then
                        destroy(obj)
                    end
                end,2,1):Start()
			end 
		end)
    end
end

function M.OnAssetChange(data)
    Event.Brocast("global_hint_state_change_msg",{gotoui = M.key})
    if data.change_type and data.change_type == "task_duiju_collect_picture" then
        M.PrefabCreator(data.data[1].value,data.data[1].asset_type)
    end
end

local d_t = 1
function M.PrefabCreator(value,_type)
    if not IsEquals(btn_gameObject) then return end
    d_t = d_t + 1.6
    if d_t > 6 then
        d_t = 0
    end
    local temp_ui = {}
    local can_auto = true
    local can_click = true
    local obj = newObject("Act_028_DJJTPrefab",GameObject.Find("Canvas/LayerLv50").transform)
    math.randomseed(tostring(os.time()):reverse():sub(1, 7))
    obj.transform.position = Vector3.New(0,550,0)
    LuaHelper.GeneratingVar(obj.transform, temp_ui)
    local _type2img = {
        prop_2year_pintu1 = "djpt_icon_1",
        prop_2year_pintu2 = "djpt_icon_2",
        prop_2year_pintu3 = "djpt_icon_3",
        prop_2year_pintu4 = "djpt_icon_4",
        prop_2year_pintu5 = "djpt_icon_5",
    }
    temp_ui.num_txt.text = "+"..value
    temp_ui.award_img.sprite = GetTexture(_type2img[_type])
    temp_ui.new.gameObject:SetActive(GameItemModel.GetItemCount(_type) == 1)
    temp_ui.yes_btn.onClick:AddListener(function ()
        if can_click then
            -- M.FlyAnim(obj)
            -- can_auto = false
        end
    end)
    
    local t = Timer.New(function ()
        if can_auto then          
            M.FlyAnim(obj)
            can_click = false
        end
    end,d_t,1)
    t:Start()
end

function M.AddUnShowAward()
    local check_func = function (type)
        if "task_duiju_collect_picture" == type then
            return true
        end
    end
    MainModel.AddUnShow(check_func)
end

function M.on_model_task_change_msg(data)
    if data and M.IsCareID(data.id) then
        this.ReadyToGo = data.need_process - data.now_process
    end
end

function M.on_pdkclear_created(data)
    if data and data.panelSelf  then
        M.CreateTips(data)
    end
end

function M.on_ddzfreeclear_created(data)
    if data and data.panelSelf  then
        M.CreateTips(data)
    end
end

function M.on_mjfreeclear_created(data)
    if data and data.panelSelf  then
        M.CreateTips(data)
    end
end

function M.IsCareID(id)
    for i = 1,#M.task_ids do
        if id == M.task_ids[i] then
            return true
        end
    end
end

function M.CreateTips(data)
    Timer.New(function() 
        if this.ReadyToGo then 
            local b = newObject("Act_028_DJJTTips",data.panelSelf.transform)
            b.transform:Find("@t_txt"):GetComponent("Text").text = "再打"..this.ReadyToGo.."局可获得拼图"
            this.ReadyToGo = nil
        end
     end,3,1):Start() 
end