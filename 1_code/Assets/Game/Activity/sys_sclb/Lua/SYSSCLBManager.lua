-- 创建时间:2019-10-24
-- 首充礼包

local basefunc = require "Game/Common/basefunc"
SYSSCLBManager = {}
local M = SYSSCLBManager
M.key = "sys_sclb"
GameButtonManager.ExtLoadLua(M.key, "SCLBEnterPrefab")
GameButtonManager.ExtLoadLua(M.key, "StageShopPanel")

local this
local lister

-- M.shopid = {95,96,97,98,99,100}
-- M.iconname={"hall_btn_gift29_activity_sys_sclb","hall_btn_giftxs","hall_btn_giftcz","hall_btn_gifthh","hall_btn_giftwz","hall_btn_giftzz"}
-- M.imatext={"hall_btn_gift19_activity_sys_sclb","hall_btn_gift20","hall_btn_gift21","hall_btn_gift22","hall_btn_gift23","hall_btn_gift24"}
M.shopid = {95,96,97,98}
M.iconname={"hall_btn_gift29_activity_sys_sclb","hall_btn_giftxs","hall_btn_giftcz","hall_btn_gifthh"}
M.imatext={"hall_btn_gift19_activity_sys_sclb","hall_btn_gift20","hall_btn_gift21","hall_btn_gift22"}

function M.CheckIsShow()
    local add = 0
	for i=1, #M.shopid do
		local status = MainModel.GetGiftShopStatusByID(M.shopid[i])
		add = add + status
	end
	if add <= 0 or MainModel.UserInfo.ui_config_id == 1 then
		return
	end
    return true
end
function M.GotoUI(parm)
    if parm.goto_scene_parm == "panel" then

        return StageShopPanel.Create(nil,parm.backcall)
    elseif parm.goto_scene_parm == "enter" then
    	return SCLBEnterPrefab.Create(parm.parent, parm.cfg)
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

    lister["finish_gift_shop"] = this.on_finish_gift_shop_shopid
end

function M.Init()
	M.Exit()

	this = SYSSCLBManager
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
end

function M.OnLoginResponse(result)
	if result == 0 then
	end
end
function M.OnReConnecteServerSucceed()
end

function M.GetOutTime()
    if MainModel.UserInfo.ui_config_id == 2 then 
        local f_t = tonumber(MainModel.UserInfo.first_login_time) 
        if not f_t then return 0 end  
        return f_t + 7 * 24 * 3600 - os.time()
    else
        return 0
    end 
end

function M.GetCurrentShopID()
    if MainModel.UserInfo.ui_config_id == 2 then 
        for i=1, #M.shopid do
            local status = MainModel.GetGiftShopStatusByID(M.shopid[i])
            if status==1 then               
                return i 
            end
        end 
    end 
end

function M.on_finish_gift_shop_shopid(id)
    if id<=M.shopid[#M.shopid] and id>=M.shopid[1] then 
        MainModel.UserInfo.GiftShopStatus[id].status=0
        if id <= M.shopid[#M.shopid - 1] then
            MainModel.UserInfo.GiftShopStatus[id+1] = MainModel.UserInfo.GiftShopStatus[id+1] or {}
            MainModel.UserInfo.GiftShopStatus[id+1].status = 1
        end
        Event.Brocast("model_sclb_gift_change_msg")
    end
end