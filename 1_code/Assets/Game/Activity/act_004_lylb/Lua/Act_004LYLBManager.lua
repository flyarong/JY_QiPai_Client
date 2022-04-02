-- 创建时间:2020-03-10
-- Act_004LYLBManager 管理器

local basefunc = require "Game/Common/basefunc"
Act_004LYLBManager = {}
local M = Act_004LYLBManager
M.key = "act_004_lylb"
GameButtonManager.ExtLoadLua(M.key, "Act_004LYLBPanel")
GameButtonManager.ExtLoadLua(M.key, "Act_004LYLBEnterPrefab")
local this
local lister
local shopid = 10169
-- 是否有活动
function M.IsActive()
    -- 活动的开始与结束时间
    local e_time = 1588003199
    local s_time = 1587425400 
    if (e_time and os.time() > e_time) or (s_time and os.time() < s_time) then
        return false
    end

    -- 对应权限的key
    local _permission_key = "actp_show_gift_bag_10169"
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
            return Act_004LYLBPanel.Create(parm.parent,parm.backcall)
        end 
    elseif parm.goto_scene_parm == "enter" then
        if M.IsActive() then
            return Act_004LYLBEnterPrefab.Create(parm.parent)
        end 
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
    lister["EnterScene"] = this.OnEnterScene
end

function M.Init()
	M.Exit()

	this = Act_004LYLBManager
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

function M.OnEnterScene()
    local status = MainModel.GetGiftShopStatusByID(shopid)
    dump(MainModel.myLocation,status,"<color=red>当前场景--零元礼包</color>")
    if not M.IsActive() then return end
    if status ~= 1 then return end
    if MainModel.UserInfo.xsyd_status ~= 1 then return end
    if MainModel.myLocation == "game_MiniGame" then 
        if PlayerPrefs.GetInt(MainModel.UserInfo.user_id.."game_MiniGame"..M.key..os.date("%Y%m%d", os.time()),0) == 0 then 
            --打开页面
            Act_004LYLBPanel.Create()
            PlayerPrefs.SetInt(MainModel.UserInfo.user_id.."game_MiniGame"..M.key..os.date("%Y%m%d", os.time()),1)
        end
    end
    
    if MainModel.myLocation == "game_Free" then 
        if PlayerPrefs.GetInt(MainModel.UserInfo.user_id.."game_Free"..M.key..os.date("%Y%m%d", os.time()),0) == 0 then 
            --打开页面
            Act_004LYLBPanel.Create()
            PlayerPrefs.SetInt(MainModel.UserInfo.user_id.."game_Free"..M.key..os.date("%Y%m%d", os.time()),1)
        end
    end

    if MainModel.myLocation == "game_MatchHall" then 
        if PlayerPrefs.GetInt(MainModel.UserInfo.user_id.."game_MatchHall"..M.key..os.date("%Y%m%d", os.time()),0) == 0 then 
            --打开页面
            Act_004LYLBPanel.Create()
            PlayerPrefs.SetInt(MainModel.UserInfo.user_id.."game_MatchHall"..M.key..os.date("%Y%m%d", os.time()),1)
        end
    end
end

