-- 创建时间:2019-10-24
-- 通用礼包管理器

local basefunc = require "Game/Common/basefunc"
TYGiftManager = {}
local M = TYGiftManager
M.key = "ty_gift"
GameButtonManager.ExtLoadLua(M.key, "GameComGiftT3Panel")
GameButtonManager.ExtLoadLua(M.key, "GameComGiftT4Panel")
GameButtonManager.ExtLoadLua(M.key, "GameComGiftT1Panel")
GameButtonManager.ExtLoadLua(M.key, "GiftEnterPrefab")
local game_gift_style_config = GameButtonManager.ExtLoadLua(M.key, "game_gift_style_config")

local this
local lister

function M.get_giftkey_by_cfg(gift_key)
    local gift_list = this.UIConfig.map_config[ gift_key ]
    -- dump(gift_list, "<color=red>EEE get_giftkey_by_cfg</color>")
    if gift_list and #gift_list > 0 then
        for k,v in ipairs(gift_list) do
            local cfg = v
            local gift_id = cfg.gift_id[1]
            local a,b
            if cfg.condi_key then
                a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key="actp_buy_gift_bag_class_" .. cfg.condi_key, is_on_hint=true}, "CheckCondition")
            else
                a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key="actp_buy_gift_bag_" .. gift_id, is_on_hint=true}, "CheckCondition")
            end
            if not a or b then
                local gift_config = MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, gift_id)
                if gift_config and MathExtend.isTimeValidity(gift_config.start_time, gift_config.end_time) then
                    return cfg
                end
            end
        end
    end
end
function M.CheckIsShow(parm, type)
    local buf_cfg = M.get_giftkey_by_cfg(parm.goto_type)
    if not buf_cfg then
        return
    end

    return true
end
function M.GotoUI(parm)
    if not M.CheckIsShow(parm) then
        dump(parm, "<color=red>不满足条件</color>")
        return
    end
	if parm.goto_scene_parm == "panel" then
        local cfg = M.get_giftkey_by_cfg(parm.goto_type)
        if cfg then
            if cfg.temp == "T3" then
                return GameComGiftT3Panel.Create(parm.parent, parm.backcall, cfg)
            elseif cfg.temp == "T4" then
                if parm.mark == "game_activity" or parm.mark == "year_activity" then
                    return GameComGiftT4Panel.Create(parm.parent, parm.backcall, cfg,true)
                end
                return GameComGiftT4Panel.Create(parm.parent, parm.backcall, cfg)
            else
                return GameComGiftT1Panel.Create(parm.parent, parm.backcall, cfg)
            end
        end
        dump(parm, "<color=red>parm 打开失败 这些礼包不能购买或显示</color>")
    elseif parm.goto_scene_parm == "enter" then
        local cfg = M.get_giftkey_by_cfg(parm.goto_type)
        if cfg then
            return GiftEnterPrefab.Create(parm.parent, cfg)
        end
        dump(parm, "<color=red>parm 入口创建失败 这些礼包不能购买或显示</color>")
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
function M.SetHintState()
end

-- 活动面板调用
function M.CheckIsShowInActivity()
    if M.get_giftkey_by_cfg("gift_cglb_mini") then
        return true
    end
    return false
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
end

function M.Init()
	M.Exit()

	this = TYGiftManager
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
    this.UIConfig={
        config = {},
        map_config = {},
    }
    this.UIConfig.config = game_gift_style_config.config
    for k,v in ipairs(game_gift_style_config.config) do
        this.UIConfig.map_config[v.gift_key] = this.UIConfig.map_config[v.gift_key] or {}
    	this.UIConfig.map_config[v.gift_key][#this.UIConfig.map_config[v.gift_key] + 1] = v
    end
end

function M.OnLoginResponse(result)
	if result == 0 then
	end
end
function M.OnReConnecteServerSucceed()
end

