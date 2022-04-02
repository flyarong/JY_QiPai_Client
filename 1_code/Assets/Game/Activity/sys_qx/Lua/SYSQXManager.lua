-- 创建时间:2019-11-29
-- SYSQXManager 管理器

local basefunc = require "Game/Common/basefunc"
SYSQXManager = {}
local M = SYSQXManager
M.key = "sys_qx"
local cpm = GameButtonManager.ExtLoadLua(M.key, "common_permission_manager")
local sysqx_ui_change_config = GameButtonManager.ExtLoadLua(M.key, "sysqx_ui_change_config")
GameButtonManager.ExtLoadLua(M.key, "MatchQXMXBPrefab")
GameButtonManager.ExtLoadLua(M.key, "MatchQX5YuanPrefab")
GameButtonManager.ExtLoadLua(M.key, "MatchQX1YuanPrefab")
GameButtonManager.ExtLoadLua(M.key, "ZYJQXPrefab")
GameButtonManager.ExtLoadLua(M.key, "GetQXPrefab")
GameButtonManager.ExtLoadLua(M.key, "ActQXPrefab")

local this
local lister

TagVecKey = {
    tag_new_player = "tag_new_player", --- 新人用户
    tag_free_player = "tag_free_player", --- 免费
    tag_stingy_player = "tag_stingy_player", --- 小额用户
    tag_vip_low = "tag_vip_low", --- vip 1-2
    tag_vip_mid = "tag_vip_mid", --- vip 3-6
    tag_vip_high = "tag_vip_high", --- vip 7-10
}

-- 创建入口按钮时调用
function M.CheckIsShow()
    return true
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

    lister["global_sysqx_uichange_msg"] = this.on_global_sysqx_uichange_msg

    -- 权限管理相关消息
    lister["model_query_system_variant_data"] = this.query_system_variant_data
    lister["on_system_variant_data_change_msg"] = this.on_system_variant_data_change_msg
    lister["on_player_permission_error"] = this.on_player_permission_error
end

local tag_name = {
    tag_new_player = "新人用户", --- 新人用户
    tag_free_player = "免费", --- 免费
    tag_stingy_player = "小额用户", --- 小额用户
    tag_vip_low = "vip 1-2", --- vip 1-2
    tag_vip_mid = "vip 3-6", --- vip 3-6
    tag_vip_high = "vip 7-10", --- vip 7-10
}
function M.debug_test()
    if this.m_data.tag_vec_map then
        local desc = ""
        for k,v in pairs(this.m_data.tag_vec_map) do
            if tag_name[k] then
                desc = desc .. "\n" .. tag_name[k]
            end
        end
        return desc
    end
end

function M.Init()
    if not this then
        M.Exit()

        this = SYSQXManager
        cpm.init(true)

        this.m_data = {}
        this.m_data.tag_vec_map = {} -- 标签map
        this.m_data.no_act_permission_map = {} -- 不能玩的活动
        MakeLister()
        AddLister()
        M.InitUIConfig()
    end
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
	end
end
function M.OnReConnecteServerSucceed()
end

function M.convert_variant_to_table( _data )
    local ret_vec = {}
    for key,data in pairs(_data) do
        local value_vec = basefunc.string.split( data.variant_value , ",")
        if value_vec then
            for _key,value in pairs(value_vec) do
                if data.variant_type == "string" then
                    value_vec[_key] = tostring( value )
                elseif data.variant_type == "number" then
                    value_vec[_key] = tonumber( value )
                end
            end
        end

        local ret = value_vec
        if data.variant_value_type == "table" then
            if not value_vec or #value_vec == 0 then
                ret = {}
            end
        end
        if data.variant_value_type == "value" then
            ret = value_vec and value_vec[1]
        end
        ret_vec[ data.variant_name ] = ret
  end
  
    -- 转成 map
    ret_vec.diff_act_permission_map = {}
    if ret_vec.diff_act_permission then
        for _,v in ipairs(ret_vec.diff_act_permission) do
            ret_vec.diff_act_permission_map[v] = true
        end
    end

    return ret_vec
end

function M.query_system_variant_data(_, data)
    dump(data, "<color=red>SYS QX query_system_variant_data</color>")
    if data.result == 0 then
        this.m_data.permission_data = M.convert_variant_to_table(data.variant_data)
        if this.m_data.permission_data.tag_vec then
            this.m_data.tag_vec_map = this.m_data.tag_vec_map or {}
            local ll = {}
            for k,v in pairs(this.m_data.tag_vec_map) do
                ll[#ll + 1] = k
            end
            for k,v in ipairs(ll) do
                this.m_data.tag_vec_map[v] = nil
            end
            for k,v in ipairs(this.m_data.permission_data.tag_vec) do
                this.m_data.tag_vec_map[v] = 1
            end
        end
        dump(this.m_data.tag_vec_map)
        if this.m_data.permission_data.no_act_permission then
            this.m_data.no_act_permission_map = this.m_data.tag_vec_map or {}
            for k,v in ipairs(this.m_data.permission_data.no_act_permission) do
                this.m_data.no_act_permission_map[v] = 1
            end
        end
    end
end
function M.on_system_variant_data_change_msg(_, data)
    dump(data, "<color=red>SYS QX on_system_variant_data_change_msg</color>")
    this.m_data.permission_data = M.convert_variant_to_table(data.variant_data)
    if this.m_data.permission_data.tag_vec then
        this.m_data.tag_vec_map = this.m_data.tag_vec_map or {}
        local ll = {}
        for k,v in pairs(this.m_data.tag_vec_map) do
            ll[#ll + 1] = k
        end
        for k,v in ipairs(ll) do
            this.m_data.tag_vec_map[v] = nil
        end
        for k,v in ipairs(this.m_data.permission_data.tag_vec) do
            this.m_data.tag_vec_map[v] = 1
        end
        dump(this.m_data.tag_vec_map)
        if this.m_data.permission_data.no_act_permission then
            this.m_data.no_act_permission_map = {}
            for k,v in ipairs(this.m_data.permission_data.no_act_permission) do
                this.m_data.no_act_permission_map[v] = 1
            end
        end
    end
    Event.Brocast("client_system_variant_data_change_msg")
end
function M.on_player_permission_error(_, data)
    dump(data, "<color=red>SYS QX on_player_permission_error</color>")
    HintPanel.Create(1, data.error_desc, function ()
        -- 门槛相关逻辑
        if MainModel.myLocation == "game_DdzFree"
            or MainModel.myLocation == "game_DdzPDK"
            or MainModel.myLocation == "game_Mj3D"
            or MainModel.myLocation == "game_Gobang"
            or MainModel.myLocation == "game_LHD" then
    
            local huiqu
            if MainModel.lastmyLocation then
                huiqu = MainModel.lastmyLocation
            else
                huiqu = "game_Hall"
            end
            GameManager.GotoUI({gotoui = huiqu})
        end
    end)
end

function M.get_tag_vec_map()
    return M.m_data.tag_vec_map
end

-- 检查条件或权限
function M.CheckCondition(parm)
    local _permission_key
    local is_on_hint
    if type(parm) == "table" then
        _permission_key = parm._permission_key
        is_on_hint = parm.is_on_hint
    end
    if this.m_data.permission_data and _permission_key then
        local a,b = cpm.judge_permission_effect_client(_permission_key, this.m_data.permission_data)
        if b then
            -- 是不是 不要提示(调用的地方自己处理)
            if not is_on_hint then
                GameManager.GotoUI({gotoui="vip", goto_scene_parm="hint", data={desc=b,type = parm.vip_hint_type,cw_btn_desc = parm.cw_btn_desc}})
            end
        end
        return a
    else
        -- print("<color=red>CheckCondition data nil 检查条件或权限  数据为空</color>")
        return true
    end
end

-- 权限相关界面修改
-- Event.Brocast("global_sysqx_uichange_msg", {key="", panelSelf=self})
-- key
function M.on_global_sysqx_uichange_msg(parm)
    -- 测试
    -- this.m_data.tag_vec_map[TagVecKey.tag_new_player] = nil
    -- this.m_data.tag_vec_map[TagVecKey.tag_free_player] = 1
    if AdvertisingManager.IsCloseAD() then
        return
    end

    if parm and parm.key then
        if parm.key == "match_hall" or parm.key == "match_detail" or parm.key == "match_js" then
            local config = parm.panelSelf.config
            if parm.key == "match_js" then
                config = MatchModel.GetGameCfg(parm.panelSelf.parm.game_id)
            end
            if config.game_id == 2 or config.game_id == 5 then
                MatchQX5YuanPrefab.ExtLogic(parm)
            elseif config.game_id == 10 then
                MatchQX1YuanPrefab.ExtLogic(parm)
            end
            if config.game_tag == "mxb" then
                --明星杯
                MatchQXMXBPrefab.ExtLogic(parm)
            end
            if (parm.key == "match_hall" or parm.key == "match_detail") and config.game_tag == "sws" then
                GameManager.GotoUI({gotoui="sys_gg", goto_scene_parm="panel", parm=parm})
            end
                -- 全返礼包按钮在千元赛结算的展示
            if parm.key == "match_js" then
                Event.Brocast("qflb_qysclear_uichange",{panelSelf = parm.panelSelf})
            end
        elseif parm.key == "zyj" then
            ZYJQXPrefab.ExtLogic(parm)
        elseif parm.key == "dh" then
            --福卡分享活动的ui改动
            Event.Brocast("hbfx_clear_uichange",{panelSelf = parm.panelSelf})
            ActQXPrefab.ExtLogic(parm)
        elseif parm.key == "djhb" then
            ActQXPrefab.ExtLogic(parm)
        elseif parm.key == "ls" then
            ActQXPrefab.ExtLogic(parm)
        end
    end
end

function M.GetRegressTime()
    if this.m_data and this.m_data.permission_data then 
        return this.m_data.permission_data["regress_time"]
    end 
end 

function M.IsNeedWatchAD()
    -- return this.m_data.tag_vec_map[TagVecKey.tag_free_player]
    -- 运营需求：广告权限判定修改-CPL渠道 2020/5/26


    do return false end
    if gameMgr:getMarketPlatform() == "wqp" then
        return false
    end

    return M.CheckCondition({_permission_key="need_watch_ad", is_on_hint=true})
end

function M.CheckIsWQP()
    local mp = gameMgr:getMarketPlatform()
    if not mp or mp ~= "wqp" then return end
    return true
end

function M.Debug(key)
    local a,b = cpm.judge_permission_effect_client(key, this.m_data.permission_data)
    dump(this.m_data.permission_data , "xxx-----------------this.m_data.permission_data")
    print("<color=red>++++++++++++ permission_key ++++++++++++</color>")
    dump(a)--结果
    dump(b)--错误码
end
--@SYSQXManager.Debug("actp_own_task_p_task_cymj_cpl_show")