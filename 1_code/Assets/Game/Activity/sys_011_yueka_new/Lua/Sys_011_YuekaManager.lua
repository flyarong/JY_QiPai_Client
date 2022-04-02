-- 创建时间:2020-05-01
-- Sys_011_YuekaManager 管理器

local basefunc = require "Game/Common/basefunc"
Sys_011_YuekaManager = {}
local M = Sys_011_YuekaManager
M.key = "sys_011_yueka_new"
GameButtonManager.ExtLoadLua(M.key, "Sys_011_YueKaPanel")
GameButtonManager.ExtLoadLua(M.key, "Sys_011_YueKa_NewNoticePanel")
GameButtonManager.ExtLoadLua(M.key, "Sys_011_YueKaEnterPrefab")

local this
local lister
--新版小月卡的ID
local yk_shopid_s =10235
--新版大月卡的ID
local yk_shopid_b =10236 
local m_data
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
    local is_show = false
    if MainModel.myLocation ~= "game_Hall" then
        if  M.IsBuySmallYueKa() and M.IsBuyBigYueKa() then
            is_show = false
        else
            is_show = true
        end
    else
        is_show = true
    end
    return M.IsActive() and is_show
end
-- 活动面板调用
function M.CheckIsShowInActivity()
    return M.IsActive()
end

-- 所有可以外部创建的UI
function M.GotoUI(parm)
    -- dump(parm, "<color=red>PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP</color>")
    if parm.goto_scene_parm == "panel" then
        return Sys_011_YueKaPanel.Create(parm.parent,not ((parm.mark == "game_activity") or (parm.mark == "year_activity")))
    elseif parm.goto_scene_parm == "enter" then
        return Sys_011_YueKaEnterPrefab.Create(parm.parent)
    elseif parm.goto_scene_parm == "jyfl_enter" then
		
    elseif parm.goto_scene_parm == "panel_act" then
        
    else
        dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
    end
end
-- 活动的提示状态
function M.GetHintState(parm)
	if parm and parm.gotoui == M.key then 
        if not M.CheckIsShowInActivity(parm) then
            return ACTIVITY_HINT_STATUS_ENUM.AT_Nor
        end
        if  M.IsAwardCanGet() then
            return ACTIVITY_HINT_STATUS_ENUM.AT_Get
        else
            local newtime = tonumber(os.date("%Y%m%d", os.time()))
            local user_id = MainModel.UserInfo and MainModel.UserInfo.user_id or ""
            local oldtime = tonumber(os.date("%Y%m%d", tonumber(PlayerPrefs.GetString(M.key .. user_id, 0))))
            if oldtime ~= newtime then
                return ACTIVITY_HINT_STATUS_ENUM.AT_Red
            end
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
    lister["OnLoginResponse"] = this.OnLoginResponse
    lister["ReConnecteServerSucceed"] = this.OnReConnecteServerSucceed
    lister["global_hint_state_set_msg"] = this.on_global_hint_state_set_msg
    lister["query_new_yueka_base_info_response"] = this.query_new_yueka_base_info_response
    lister["new_yueka_base_info_change_msg"] = this.new_yueka_base_info_change_msg
end
function M.Init()
	M.Exit()

	this = Sys_011_YuekaManager
	this.m_data = {}
	MakeLister()
    AddLister()
    M.ForceChangeIndex()
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
        Network.SendRequest("query_new_yueka_base_info")
	end
end
function M.OnReConnecteServerSucceed()

end

function M.query_new_yueka_base_info_response(_,data)
    dump(data,"<color=red>新月卡基础数据</color>")
    if data then
        if data.result == 0 then
            m_data = data
            Event.Brocast("YueKa_Got_New_Info")
            Event.Brocast("global_hint_state_change_msg", { gotoui = M.key })
        end    
    else
    
    end
end

function M.new_yueka_base_info_change_msg(_,data)
    dump(data,"<color=red>新月卡基础数据改变</color>")
    if data then
        m_data = data
        Event.Brocast("YueKa_Got_New_Info")
        Event.Brocast("global_hint_state_change_msg", { gotoui = M.key })
    else
    
    end
end

function M.GetMainData()
    return m_data
end
--获取大月卡的每日奖励
function M.GetBigYueKaAward()
    Network.SendRequest("new_yueka_receive_award")
end
--买小月卡
function M.BuySmallYueKa()
    M.BuyShop(yk_shopid_s)
end
--买大月卡
function M.BuyBigYueKa()
    M.BuyShop(yk_shopid_b)
end

function M.BuyShop(shopid)
    local gb =  MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, shopid)
    if not gb then return end
	local price = gb.price
	if  GameGlobalOnOff.PGPay and gameRuntimePlatform == "Ios" then
		ServiceGzhPrefab.Create({desc="请前往公众号获取"})
	else
		PayTypePopPrefab.Create(shopid, "￥" .. (price / 100))
	end
end

--看大月卡的每日奖励是否可以领取
function M.IsAwardCanGet()
    if m_data then
        if m_data.total_remain_num_2 > 0 and m_data.is_receive_2 == 0 then
            return true
        end
    end
end

function M.IsBuySmallYueKa()
    if m_data and m_data.total_remain_num_1 > 0 then
        return true
    end
end

function M.IsBuyBigYueKa()
    if m_data and m_data.total_remain_num_2 > 0 then
        return true
    end
end

function M.GetBestLevel()
    if not M.IsBuyBigYueKa() then
        return 3
    end
end

function M.ForceChangeIndex()
    -- local func = function()
    --     return true
    -- end
    -- GameActivityModel.ForceToChangeIndex(M.key,5,func)
end