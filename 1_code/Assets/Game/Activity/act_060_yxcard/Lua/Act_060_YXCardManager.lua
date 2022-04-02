-- 创建时间:2021-06-15
-- Act_060_YXCardManager 管理器

local basefunc = require "Game/Common/basefunc"
Act_060_YXCardManager = {}
local M = Act_060_YXCardManager
M.key = "act_060_yxcard"

local this
local lister
GameButtonManager.ExtLoadLua(M.key, "Act_060_YXCardComposePanel")
GameButtonManager.ExtLoadLua(M.key, "Act_060_YXCardSelectPanel")
local config = GameButtonManager.ExtLoadLua(M.key, "act_060_yxcard_config") 
local composePanel

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
    lister["yxcard_compose"] = this.on_yxcard_compose
    lister["ExitScene"] = this.OnExitScene
end

function M.Init()
	M.Exit()

	this = Act_060_YXCardManager
	this.m_data = {}
    this.yxCardConfig = {}
    this.cur_select_yxcard = nil
    this.cur_yxcard_chip = nil
	MakeLister()
    AddLister()
	M.InitUIConfig()
    M.InitConfig()
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

function M.InitConfig()
    this.yxCardConfig = config.yxcard
end

-- function M.GetCardListByChip(chip_key)
--     for k,v in ipairs(this.yxCardConfig) do
--         if v.need_chip_key == chip_key then
--             return v.card_list
--         end
--     end
-- end

function M.GetConfigByChip(chip_key)
    for k,v in ipairs(this.yxCardConfig) do
        if v.need_chip_key == chip_key then
            return v
        end
    end
end

--当前选择的游戏卡
function M.CurChosedYXCard(op, value)
    if op == "GET" then
        return this.cur_select_yxcard
    elseif op == "SET" then
        this.cur_select_yxcard = value
    end
end

--当前选择的碎片
function M.CurYXCardChip(op, value)
    if op == "GET" then
        return this.cur_yxcard_chip
    elseif op == "SET" then
        this.cur_yxcard_chip = value
    end
end

--游戏卡合成
function M.on_yxcard_compose(data)
    local chip_key = data
    M.CurYXCardChip("SET", chip_key)
    local card_list = M.GetConfigByChip(chip_key).card_list
    local index = math.random(1, #card_list)
    M.CurChosedYXCard("SET", card_list[index])
    composePanel = Act_060_YXCardComposePanel.Create()
end

function M.OnExitScene()
    if composePanel then
        composePanel:MyClose()
    end
end

--***************************************************

function M.GetCurGameCard(parm)
    local card_key
    local game_level
    local qp_image
    for i = 1, #this.yxCardConfig do
        local _card_key = parm.card_type .. "_" .. i
        local card_count = GameItemModel.GetItemCount(_card_key)
        local jingbi_count = GameItemModel.GetItemCount("jing_bi")
        if card_count > 0 and jingbi_count >= this.yxCardConfig[i].game_level then
            card_key = _card_key
            game_level = this.yxCardConfig[i].game_level
            qp_image = this.yxCardConfig[i].qp_image
        end
    end
    if card_key then
        return card_key, game_level, qp_image
    end
end

