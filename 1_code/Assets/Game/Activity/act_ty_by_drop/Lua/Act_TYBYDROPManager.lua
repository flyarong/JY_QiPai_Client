-- 创建时间:2020-06-09
-- Act_TYBYDROPManager 管理器
--[[
tips:适用于普通的活动，掉落单一道具,
    :对于同一活动掉落多种道具的情况可扩展可新做(以前有活动掉落桃心梅方)
--]]

local basefunc = require "Game/Common/basefunc"
Act_TYBYDROPManager = {}
local M = Act_TYBYDROPManager
M.key = "act_ty_by_drop"
local config = GameButtonManager.ExtLoadLua(M.key, "act_ty_by_drop_style")

local this
local lister
local btn_gameObject
local unShowType_func = {}

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
    lister["AssetChange"] = this.OnAssetChange

    lister["year_btn_created"] = this.on_year_btn_created
    lister["ReConnecteServerSucceed"] = this.OnReConnecteServerSucceed
    lister["global_hint_state_set_msg"] = this.on_global_hint_state_set_msg
end

function M.Init()
    M.Exit()

    this = Act_TYBYDROPManager
    this.m_data = {}
    MakeLister()
    AddLister()
    --M.AddUnShowAward()
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
        M.StopUpdateTime()
        RemoveLister()
        this = nil
    end
end
function M.InitUIConfig()
    this.UIConfig = {}
    this.UIConfig.style_list = {}
    this.UIConfig.style_map = {}
    for k,v in ipairs(config) do
        this.UIConfig.style_list[#this.UIConfig.style_list + 1] = v
        this.UIConfig.style_map[v.path] = v
    end
end

function M.OnLoginResponse(result)
    if result == 0 then
        -- 数据初始化
        M.UpdateAllModuleConfig()

        M.StopUpdateTime()
        this.m_data.update_time = Timer.New(function ()
            M.UpdateAllModuleConfig()
        end, 20, -1, nil, true)
        this.m_data.update_time:Start()
    end
end


function M.OnReConnecteServerSucceed()

end

function M.StopUpdateTime()
    if this.m_data.update_time then
        this.m_data.update_time:Stop()
    end
    this.m_data.update_time = nil
end

function M.on_year_btn_created(data)
    if data and data.enterSelf then
        btn_gameObject = data.enterSelf.gameObject
    end
end

function M.FlyAnim(obj)
    if not IsEquals(obj) then return end
    local a  = obj.transform.position
    --path[2] = Vector3.New(0,0,0)
    if true then
        local seq = DoTweenSequence.Create({dotweenLayerKey = M.key})
        local path = {}
        path[0] = a
        path[1] = Vector3.New(0,0,0)
        seq:Append(obj.transform:DOLocalPath(path,2,DG.Tweening.PathType.CatmullRom))
        seq:AppendInterval(1.6)
        if false then
            local b  = btn_gameObject.transform.position
            local path2 = {}
            path2[0] = Vector3.New(0,0,0)
            path2[1] = Vector3.New(b.x - 30,b.y + 30 ,0)
            seq:Append(obj.transform:DOLocalPath(path2,2,DG.Tweening.PathType.CatmullRom))
        end
        seq:OnKill(function ()
            if IsEquals(obj) then 
                --obj.transform.position = Vector3.New(path[2].x,path[2].y,path[2].z)
                local temp_ui = {}
                LuaHelper.GeneratingVar(obj.transform, temp_ui)
                temp_ui.Image.gameObject:SetActive(false)
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
    --if data.change_type and data.change_type == "task_award_no_show" then
        --M.PrefabCreator(data.data[1].value)
    --end
end

function M.PrefabCreator(value)
    local style_path = M.GetCurStylePath()
    local temp_ui = {}
    local can_auto = true
    local can_click = true
    local obj = newObject("Act_TYBYDROPPrefab",GameObject.Find("Canvas/LayerLv5").transform)
    math.randomseed(tostring(os.time()):reverse():sub(1, 7))
    obj.transform.position = Vector3.New(0,550,0)
    LuaHelper.GeneratingVar(obj.transform, temp_ui)
    temp_ui.num_txt.text = "+"..value
    temp_ui.icon_img.sprite = GetTexture(style_path .. "_" .. "act_ty_by_drop_7")
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
    end,1,1)
    t:Start()
end

-- function M.AddUnShowAward()
--     local check_func = function (type)
--         if "task_award_no_show" == type  then
--             return true
--         end
--     end
--     M.AddUnShow(check_func)
-- end

-- function M.AddUnShow(check_func)
--     unShowType_func[#unShowType_func + 1] = check_func
-- end

-- 皮肤代码
function M.CalcCurStylePath()
    local cur_style = this.UIConfig.style_list[#this.UIConfig.style_list].path -- 默认选择最后一个
    local cur_t = os.time()
    for k,v in ipairs(this.UIConfig.style_list) do
        if v.beginTime <= cur_t and cur_t <= v.endTime then
            local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key=v.condi_key, is_on_hint = true}, "CheckCondition")
            if a and b then
                cur_style = v.path
                break
            end
        end
    end
    return cur_style
end
function M.UpdateAllModuleConfig()
    local style_path = M.CalcCurStylePath()
    if this.m_data.cur_style == style_path then
        return
    end
    this.m_data.cur_style = style_path

    -- 道具表
    local cfg = GameItemModel.GetItemToKey("prop_fish_drop_act_0")
    cfg.image = style_path .. "_" .. "act_ty_by_drop_7"
    cfg.is_show_bag = 0
    cfg.name = this.UIConfig.style_map[style_path].name
end
function M.GetCurStylePath()
    return this.m_data.cur_style
end

-- 掉落滚动奖励特效
function M.GetDLPrefab(ext_id)
    local style_path = M.GetCurStylePath()
    local prefab_name = "ty_by_drop_anim_prefab"
    local prefab = CachePrefabManager.Take(prefab_name)
    local tran = prefab.prefab.prefabObj.transform

    local tiaodai = tran:Find("tiaodai"):GetComponent("Image")
    local tiaodai_02 = tran:Find("tiaodai/tiaodai_02"):GetComponent("Image")
    local zi = tran:Find("tiaodai/zi"):GetComponent("Image")
    local zi_glow = tran:Find("tiaodai/zi/zi_glow"):GetComponent("Image")
    tiaodai.sprite = GetTexture(style_path .. "_" .. "act_ty_by_drop_1")
    tiaodai_02.sprite = GetTexture(style_path .. "_" .. "act_ty_by_drop_1")
    SetTextureExtend(zi, style_path .. "_" .. "act_ty_by_drop_2")
    SetTextureExtend(zi_glow, style_path .. "_" .. "act_ty_by_drop_2")
    
    if ext_id then
        SetTextureExtend(zi, style_path .. "_" .. "act_ty_by_drop_2" .. "_" .. ext_id)
        SetTextureExtend(zi_glow, style_path .. "_" .. "act_ty_by_drop_2" .. "_" .. ext_id)
    end
    return prefab
end

-- 掉落奖励特效
function M.GetDLFlyPrefab(ext_id)
    local style_path = M.GetCurStylePath()
    local prefab_name = "ty_by_drop_fly_prefab"
    local prefab = CachePrefabManager.Take(prefab_name)
    local tran = prefab.prefab.prefabObj.transform

    local Image = tran:Find("Image"):GetComponent("Image")
    SetTextureExtend(Image, style_path .. "_" .. "act_ty_by_drop_7")
    if ext_id then
        SetTextureExtend(Image, style_path .. "_" .. "act_ty_by_drop_7".. "_" .. ext_id)
    end
    return prefab
end

function M.GetFishAttrPrefab(ext_id)
    local style_path = M.GetCurStylePath()
    local prefab_name = "zongzi"
    local prefab = CachePrefabManager.Take(prefab_name)
    local tran = prefab.prefab.prefabObj.transform

    local bytx_card_bd1 = tran:Find("bytx_card_bd1"):GetComponent("SpriteRenderer")
    SetTextureExtend(bytx_card_bd1, style_path .. "_" .. "act_ty_by_drop_4")
    if ext_id then
        SetTextureExtend(bytx_card_bd1, style_path .. "_" .. "act_ty_by_drop_4".. "_" .. ext_id)
    end
    return prefab
end

-- 配置
function M.GetFishConfig()
    local cfg = {}
    local style_path = M.GetCurStylePath()
    cfg.prefab = "Fish_Act_" .. style_path
    cfg.icon = style_path .. "_" .. "act_ty_by_drop_8"
    cfg.name_image = style_path .. "_" .. "act_ty_by_drop_9"
    return cfg
end