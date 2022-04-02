-- 创建时间:2021-01-04
-- Template_NAME 管理器

local basefunc = require "Game/Common/basefunc"
Act_Ty_GiftsManager = {}
local M = Act_Ty_GiftsManager
M.key = "act_ty_gifts"

GameButtonManager.ExtLoadLua(M.key, "Act_Ty_GiftsEnterPrefab")
GameButtonManager.ExtLoadLua(M.key, "Act_Ty_GiftsPanel")
GameButtonManager.ExtLoadLua(M.key, "Act_Ty_GiftsItemBase")

local config = GameButtonManager.ExtLoadLua(M.key, "act_ty_gifts_config")

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
function M.CheckIsShow(parm)

    if not M.IsActive() then
        return false
    end

    if not M.IsGiftActive(parm.goto_type) then
        return false
    end

    return true
end
-- 活动面板调用
function M.CheckIsShowInActivity()
    return M.IsActive()
end

-- 所有可以外部创建的UI
function M.GotoUI(parm)
    if not M.CheckIsShow(parm) then
        return
    end
    if parm.goto_scene_parm == "enter" then
        --local gift_key = parm.cfg.parm[2]
        local gift_key = parm.goto_type
        return Act_Ty_GiftsEnterPrefab.Create(parm.parent, gift_key)
    elseif parm.goto_scene_parm == "panel" then
        return Act_Ty_GiftsPanel.Create(parm.parent, parm.goto_type)
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
end

function M.Init()
	M.Exit()

	this = Act_Ty_GiftsManager
    this.m_data = {}
    this.m_data.gift_cfg = {}
	MakeLister()
    AddLister()

    M.InitGiftsCfg()
    -- dump(this.m_data.gift_cfg,"<color=red>Gifts_Cfg</color>")
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

--初始化配置信息
function M.InitGiftsCfg()
    this.m_data.gift_cfg = {}
    for i = 1, #config.base do
        local cur_cfg = config.base[i]
        if cur_cfg.isOnOff == 1 then
            cur_cfg.gifts = M.GetGiftsFromId(cur_cfg.gift_ids)
            this.m_data.gift_cfg[cur_cfg.act_gift_key] = cur_cfg
        end
    end
end

function M.GetGiftsFromId(gift_ids)
    local cur_gifts = {}
    for i = 1, #gift_ids do
        local id = gift_ids[i]
        cur_gifts[#cur_gifts + 1] = config.gifts[id] 
    end
    return cur_gifts
end

function M.GetGiftCfg(gift_key)
    if this.m_data.gift_cfg[gift_key] then
        return this.m_data.gift_cfg[gift_key]
    end
end

function M.GetGiftData(gift_key)
    local data = {}
    data.level = M.GetGiftLevel(gift_key)
    return data
end

function M.GetGiftItemCfg(gift_key)
    local cfg = M.GetGiftCfg(gift_key)
    local level = M.GetGiftLevel(gift_key)
    return cfg.gifts[level]
end

function M.IsGiftActive(gift_key)

    --do return true end 

    if not M.GetGiftCfg(gift_key) then
        return false
    end

    if not M.IsGiftInTime(gift_key)then
        return false
    end

    if M.GetGiftLevel(gift_key) == 0 then
        return false
    end

    return true
end

--礼包是否在开启时间内
function M.IsGiftInTime(gift_key)
    if M.GetGiftCfg(gift_key) then
        local cfg = M.GetGiftCfg(gift_key)
        return MathExtend.isTimeValidity(cfg.start_time, cfg.end_time)
    end
    return false
end

function M.GetGiftStyle(gift_key)
    if M.GetGiftCfg(gift_key) then
        local cfg = M.GetGiftCfg(gift_key)
        if cfg.style_key then
            return cfg.style_key
        else
            return "act_ty_gifts"
        end
    end
end

--用户允许购买的礼包等级（是否通过权限）
function M.GetGiftLevel(gift_key)
    local level = 0
    local check_func = function(_permission_key)
        local a, b = GameButtonManager.RunFun({ gotoui = "sys_qx", _permission_key = _permission_key, is_on_hint = true }, "CheckCondition")
        if a and not b then
            return false
        end
        return true
    end

    if not M.GetGiftCfg(gift_key) then
        return level
    end

    local cfg = M.GetGiftCfg(gift_key)
    for i = 1, #cfg.gifts do
        if check_func(cfg.gifts[i].permiss) then
            level = i
        end
    end
    return level
end

--礼包已经购买的数量
function M.GetBuyGiftsNum(gift_key)
    local num = 0

    if M.GetGiftLevel(gift_key) == 0 then
        return num
    end

    local cfg = M.GetGiftCfg(gift_key)
    local _gifts_ids = cfg.gifts[M.GetGiftLevel(gift_key)].gift_ids
    for i = 1, #_gifts_ids do
        local status = MainModel.GetGiftShopStatusByID(_gifts_ids[i])
        if status == 0 then
            num = num + 1
        end
    end
    return num
end

function M.GetBuyGiftsNumEx(parm)
    return M.GetBuyGiftsNum(parm.gift_key)
end

local function color16z10(str)
	if str and string.len(str) == 6 then
		local n1 = string.sub(str, 1, 2)
		local n2 = string.sub(str, 3, 4)
		local n3 = string.sub(str, 5, 6)
		local num1 = tonumber(string.format("%d", "0x"..n1))
		local num2 = tonumber(string.format("%d", "0x"..n2))
		local num3 = tonumber(string.format("%d", "0x"..n3))
        return Color.New(num1/255, num2/255, num3/255)
    elseif str and  string.len(str) == 8 then
        local n1 = string.sub(str, 1, 2)
		local n2 = string.sub(str, 3, 4)
		local n3 = string.sub(str, 5, 6)
		local n4 = string.sub(str, 7, 8)
		local num1 = tonumber(string.format("%d", "0x"..n1))
		local num2 = tonumber(string.format("%d", "0x"..n2))
		local num3 = tonumber(string.format("%d", "0x"..n3))
		local num4 = tonumber(string.format("%d", "0x"..n4))
        return Color.New(num1/255, num2/255, num3/255, num4/255)
	end
end

function M.ColorToRGB(str)
    return color16z10(str)
end

local gives = {
    "<color=#FFFF00>2万</color>鲸币",
    "<color=#FFFF00>3万</color>鲸币",
    "<color=#FFFF00>10万</color>鲸币",
    "<color=#FFFF00>20万</color>鲸币",
}

function M.GetCurBuyAllGive(gift_key)
    local lv = M.GetGiftLevel(gift_key)
    local giveTxt = gives[lv] or ""
    return giveTxt
end

function M.CheckCanBuySingle(gift_id)
	return not (MainModel.GetGiftShopStatusByID(gift_id) ~= 1)
end