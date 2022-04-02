-- 创建时间:2021-12-07
-- Act_071_SDZFManager 管理器

local basefunc = require "Game/Common/basefunc"
Act_071_SDZFManager = {}
local M = Act_071_SDZFManager
M.key = "act_071_sdzf"
local config = GameButtonManager.ExtLoadLua(M.key, "act_071_sdzf_config").config
GameButtonManager.ExtLoadLua(M.key, "Act_071_SDZFPanel")
GameButtonManager.ExtLoadLua(M.key, "Act_071_SDZFAwardItem")
GameButtonManager.ExtLoadLua(M.key, "Act_071_SDZFAwardContainer")
GameButtonManager.ExtLoadLua(M.key, "Act_071_SDZFAssetGet")

local this
local lister

--袜子
M.item_key = "prop_fish_drop_act_0"
--祝福礼包
M.gift_id = 10909
--截止时间
M.endTime = 1640620799

-- 是否有活动
function M.IsActive()
    -- 活动的开始与结束时间
    local e_time = 1640620799
    local s_time = 1640043000
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
        return Act_071_SDZFPanel.Create(parm.parent)
    end
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
    lister["christmas_blessing_get_info_response"] = this.on_christmas_blessing_get_info_response
    lister["christmas_blessing_recieve_award_response"] = this.on_christmas_blessing_recieve_award_response
    lister["christmas_blessing_lv_up_response"] = this.on_christmas_blessing_lv_up_response
    lister["AssetChange"] = this.on_asset_change
    lister["year_btn_created"] = this.on_year_btn_created
end

function M.Init()
	M.Exit()

	this = Act_071_SDZFManager
	this.m_data = {}
	MakeLister()
    AddLister()
	M.InitConfig()
    M.InitData()
end
function M.Exit()
	if this then
		RemoveLister()
		this = nil
	end
end

function M.InitConfig()
    for i = 1, #config do
        local itemKeyData = GameItemModel.GetItemToKey(config[i].normal_award)
        config[i].normal_award_name = itemKeyData.name
        config[i].normal_award_img = itemKeyData.image

        local itemKeyData = GameItemModel.GetItemToKey(config[i].zz_award1)
        config[i].zz_award1_name = itemKeyData.name
        config[i].zz_award1_img = itemKeyData.image

        local itemKeyData = GameItemModel.GetItemToKey(config[i].zz_award2)
        config[i].zz_award2_name = itemKeyData.name
        config[i].zz_award2_img = itemKeyData.image

        -- if config[i].normal_award == "shop_gold_sum" then
        --     config[i].normal_award_num = config[i].normal_award_num / 100
        -- end
        -- if config[i].zz_award1 == "shop_gold_sum" then
        --     config[i].zz_award1_num = config[i].zz_award1_num / 100
        -- end
        -- if config[i].zz_award2 == "shop_gold_sum" then
        --     config[i].zz_award2_num = config[i].zz_award2_num / 100
        -- end
    end
end

function M.InitData()
    this.m_data.curLv = 0
    this.m_data.curPorgress = 0
    --当前可领奖的等级
    this.m_data.curGetLvNormal = 0
    this.m_data.curGetLvZZ = 0
    this.m_data.isZZZF = false

    this.m_data.curGetAwardNormalSign = 0
    this.m_data.curGetAwardNormalAwardType = 0
end

function M.GetData()
    return this.m_data
end

function M.SetGetAwardSigns(award_type)
    if award_type == 1 or award_type == -1 then
        this.m_data.curGetAwardNormalSign = this.m_data.curGetLvNormal
        this.m_data.curGetAwardNormalAwardType = award_type
    end
end

function M.GetGetAwardSigns()
    return this.m_data.curGetAwardNormalSign
end

function M.GetGetAwardSignsAwardType()
    return this.m_data.curGetAwardNormalAwardType
end

-- function M.HandleAwardData(str)
--     local data = {}
--     if not str then
--         return data
--     end
--     local len = string.len(str)
--     if len > 0 then
--         for i = 1, len do
--             local v = string.sub(str, i, i) 
--             data[i] = tonumber(v)
--         end
--     end
--     return data
-- end

function M.HandleBaseData(data)
    if not data then
        return
    end
    M.HandleLockData(data)
    M.HandleLevelData(data)
    M.HandleAwardData(data)
    Event.Brocast("act_071_sdzf_level_data_change")
    Event.Brocast("act_071_sdzf_award_data_change")
end

function M.HandleLevelData(data)
    if not data then
        return
    end
    this.m_data.curLv = data.level or this.m_data.curLv
    this.m_data.curPorgress = data.exp or this.m_data.curPorgress
end

function M.HandleAwardData(data)
    if not data then
        return
    end

    if not this.m_data.curLv or this.m_data.curLv == 0 then
        this.m_data.curGetLvNormal = 0
        this.m_data.curGetLvZZ = 0
    else
        if not data.nor_get_level then
            this.m_data.curGetLvNormal = 1
        else
            this.m_data.curGetLvNormal = data.nor_get_level + 1
        end

        if not data.spec_get_level then
            this.m_data.curGetLvZZ = 1
        else
            this.m_data.curGetLvZZ = data.spec_get_level + 1
        end
    end
end

function M.HandleLockData(data)
    if not data then
        return
    end
    if data.spec_unlock and data.spec_unlock == 1 then
        this.m_data.isZZZF = true
    else
        this.m_data.isZZZF = false
    end
end

function M.GetConfigFromLevel(level)
    if level == 0 then
        return
    end
    if level > 30 and not config[level] then
        config[level] = M.GetConfigBigger30(level)
    end
    return config[level]
end

--大于30级的时候的配置
function M.GetConfigBigger30(level)
    local num = math.modf((level - 1) / 30)

    local cfg = {}
    cfg.level = level
    cfg.consume_num = (num + 1) * 1000
    cfg.normal_award = "jing_bi"
    cfg.normal_award_num = (num + 1) * 50000
    cfg.zz_award1 = "fish_coin"
    cfg.zz_award1_num = (num + 1) * 15000
    cfg.zz_award2 = "jing_bi"
    cfg.zz_award2_num = (num + 1) * 25000

    local itemKeyData = GameItemModel.GetItemToKey(cfg.normal_award)
    cfg.normal_award_name = itemKeyData.name
    cfg.normal_award_img = itemKeyData.image

    local itemKeyData = GameItemModel.GetItemToKey(cfg.zz_award1)
    cfg.zz_award1_name = itemKeyData.name
    cfg.zz_award1_img = itemKeyData.image

    local itemKeyData = GameItemModel.GetItemToKey(cfg.zz_award2)
    cfg.zz_award2_name = itemKeyData.name
    cfg.zz_award2_img = itemKeyData.image
    return cfg
end

function M.OnLoginResponse(result)
	if result == 0 then
        -- 数据初始化
        if M.IsActive() then
            Network.SendRequest("christmas_blessing_get_info")
        end
	end
end

function M.OnReConnecteServerSucceed()
end

function M.on_christmas_blessing_get_info_response(_, data)
    dump(data, "<color=white>+++++圣诞祝福 基本信息 on_christmas_blessing_get_info_response+++++</color>")
    if data.result == 0 then
        M.HandleBaseData(data.data)
    else
        HintPanel.ErrorMsg(data.result)
    end
end

function M.on_christmas_blessing_lv_up_response(_, data)
    dump(data, "<color=white>+++++圣诞祝福 升级返回 on_christmas_blessing_lv_up_response+++++</color>")
    if data.result == 0 then
        M.HandleBaseData(data.data)
    else
        HintPanel.ErrorMsg(data.result)
    end
end

function M.on_christmas_blessing_recieve_award_response(_, data)
    dump(data, "<color=white>+++++圣诞祝福 领取奖励返回 on_christmas_blessing_recieve_award_response+++++</color>")
    if data.result == 0 then
        M.HandleAwardData(data.data)
        Event.Brocast("act_071_sdzf_award_data_change")
    else
        HintPanel.ErrorMsg(data.result)
    end
end



--######奖励飞行动画######

local btn_gameObject

function M.on_year_btn_created(_data)
    if _data and _data.enterSelf then
        btn_gameObject = _data.enterSelf.gameObject
    end
end

function M.CheckShowFly()
   
    if MainModel.myLocation == "game_Fishing" then 
        return false 
    end
    if asset_change_type == "task_p_continuity_shop_nor" then
        return false
    end
    if asset_change_type == "task_award" then
        return false
    end
    return M.IsActive()
end

function M.on_asset_change(_data)
    if not _data then
        return 
    end
    for _k,_v in pairs(_data.data) do
        if _v.asset_type and _v.asset_type == M.item_key then
            if M.CheckShowFly() then
                M.PrefabCreator(_data.data[_k].value)
            end
        end
    end
end

function M.PrefabCreator(value)
    local base_layer = GameObject.Find("Canvas/LayerLv50")
    if not base_layer then return end
    local temp_ui = {}
    local can_auto = true
    local can_click = true
    local obj = newObject("Act_Ty_ExchangeItemGetPrefab", base_layer.transform)
    --math.randomseed(tostring(os.time()):reverse():sub(1, 7))
    obj.transform.position = Vector3.New(0, 550, 0)
    LuaHelper.GeneratingVar(obj.transform, temp_ui)
    --temp_ui.Image:GetComponent("Image").sprite = GetTexture(cfg.style_key.."_".."icon_1")
    local fly_img = temp_ui.Image:GetComponent("Image")
	SetTextureExtend(fly_img, "act_027_shengdanlaoren_act_ty_by_drop_7")
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
    local seq = DoTweenSequence.Create({ dotweenLayerKey = M.key })
    local path = {}
    path[0] = a
    path[1] = Vector3.New(0, 0, 0)
    seq:Append(obj.transform:DOLocalPath(path, 2, DG.Tweening.PathType.CatmullRom))
    seq:AppendInterval(1.6)
    if IsEquals(btn_gameObject) then
        local b = btn_gameObject.transform.position
        local path2 = {}
        path2[0] = Vector3.New(0, 0, 0)
        --path2[1] = Vector3.New(b.x - 30, b.y + 30, 0)
        path2[1] = Vector3.New(b.x, b.y, 0)
        seq:Append(obj.transform:DOPath(path2, 2, DG.Tweening.PathType.CatmullRom))
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

