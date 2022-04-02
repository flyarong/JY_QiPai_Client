package.loaded["Game.game_Hall.Lua.HallModel"] = nil
require "Game.game_Hall.Lua.HallModel"
package.loaded["Game.game_Hall.Lua.HallPanel"] = nil
require "Game.game_Hall.Lua.HallPanel"

HallLogic = {}

local this  -- 单例

local cur_panel

--get push devicetoken timer
local UpdatePushDeviceTokenTimer
local UPDATE_PUSHDEVICETOKEN_INTERVAL = 5

local lister
local function AddLister()
    lister = {}
    lister["EnterForeGround"] = this.on_backgroundReturn_msg
    lister["EnterBackGround"] = this.on_background_msg
    lister["ReConnecteServerSucceed"] = this.OnReConnecteServerSucceed
	lister["EnterScene"] = this.OnEnterScene

    -- lister["OnLoginResponse"] = this.OnLoginResponse
    for msg, cbk in pairs(lister) do
        Event.AddListener(msg, cbk)
    end
end

local function RemoveLister()
    if lister then
        for msg, cbk in pairs(lister) do
            Event.RemoveListener(msg, cbk)
        end    
    end
    lister = nil
end
 --

--游戏后台重进入消息
function HallLogic.on_backgroundReturn_msg()
    if cur_panel then
        cur_panel:MyRefresh()
    end
end
--游戏后台消息
function HallLogic.on_background_msg()
    DOTweenManager.KillAllStopTween()
end
function HallLogic.OnReConnecteServerSucceed()
    if cur_panel then
        cur_panel:MyRefresh()
    end
end

function HallLogic.Init()
	soundMgr:CloseSound()
	Util.ClearMemory()
    ExtendSoundManager.PlaySceneBGM(audio_config.game.bgm_main_hall.audio_name, true)
    this = HallLogic

    HallModel.Init()
    AddLister()
	local call = function ()
		local guideCall = function ()
	        if (GameGlobalOnOff.IsOpenGuide and GuideModel and GuideModel.data and GuideModel.data.currGuideId == 1)
			or (GameGlobalOnOff.IsOpenGuide and WQPGuideModel and WQPGuideModel.GetCurGuideId() == 1 and WQPGuideModel.GetCurGuideStepId() == 1 ) then
				GameManager.GotoUI({gotoui = "sys_guide_select_game",goto_scene_parm = "panel"})
			else
				if GuideLogic then
					GuideLogic.CheckRunGuide("hall", function ()
						GameManager.GotoUI({gotoui = "sys_banner",goto_scene_parm="panel"})
					end)
				else
					GameManager.GotoUI({gotoui = "sys_banner",goto_scene_parm="panel"})
				end
	        end
		end
        if GameGlobalOnOff.ForceVerifide then -- 实名认证最高优先级
	    	MainModel.GetVerifyStatus(function ()		
		    	local b,c = GameButtonManager.RunFunExt("sys_binding_verifide", "IsVerify", nil)
			    if not b or c then
			        guideCall()
			    else
			    	GameManager.GotoUI({gotoui = "sys_binding_verifide", goto_scene_parm="panel", backcall = function ()
				        guideCall()
			    	end})
			    end
	    	end)
	    else
	    	guideCall()
	    end

        GameManager.CheckCurrGameScene()
    end

    cur_panel = HallPanel.Create(call)

    MainLogic.SetupAppPurchasing()
    MainModel.CacheShop()

    UpdatePushDeviceTokenTimer = Timer.New(this.UpdatePushDeviceToken, UPDATE_PUSHDEVICETOKEN_INTERVAL, -1, nil, true)
    UpdatePushDeviceTokenTimer:Start()
    return this
end

--进入支付
function HallLogic.gotoPay()
    PayPanel.Create(GOODS_TYPE.jing_bi, "normal")
end

function HallLogic.UpdatePushDeviceToken()
	local pushDeviceToken = sdkMgr:GetPushDeviceToken()
	if pushDeviceToken == nil or pushDeviceToken == "" then
		--print("[PUSH] deviceToken is invalid")
		return
	end

	local device_os = string.lower(MainModel.LoginInfo.device_os)
	if string.find(device_os, "iphone") ~= nil or string.find(device_os, "ios") ~= nil then
		device_os = "ios"
	elseif string.find(device_os, "android") ~= nil then
		device_os = "android"
	end
	print("[PUSH] deviceToken: " .. pushDeviceToken .. ", device_os: " .. device_os)

	Network.SendRequest("device_info", {device_type=device_os, device_token=pushDeviceToken})

	UpdatePushDeviceTokenTimer:Stop()
	UpdatePushDeviceTokenTimer = nil
end

function HallLogic.Exit()
    if this then
        HallModel.Exit()
        if cur_panel then
            cur_panel:MyExit()
        end
        cur_panel = nil

	if UpdatePushDeviceTokenTimer then
		UpdatePushDeviceTokenTimer:Stop()
		UpdatePushDeviceTokenTimer = nil
	end

        RemoveLister()

        this = nil
    end
end

function HallLogic.OnEnterScene()
	-- dump("<color=white>**************OnEnterScene*************</color>")
	-- dump(MainModel.lastmyLocation,"<color=white>**************lastmyLocation*************</color>")
	if MainModel.lastmyLocation == "game_Free" or
	MainModel.lastmyLocation == "game_MiniGame" then
		AdvertisingManager.RandPlay("gamehall")
		--local timer_ad = Timer.New(function()
			--sdkMgr:ClearAllAD()
		--end,5,1)
		--timer_ad:Start()
	end
end


local hall_activity_time_config = nil
if AppDefine.IsEDITOR() then
	hall_activity_time_config = require "Game.game_Hall.Lua.hall_activity_time_config"
else
	hall_activity_time_config = LocalDatabase.LoadFileDataToTable(gameMgr:getLocalPath("localconfig/hall_activity_time_config.lua"))
	if not hall_activity_time_config then
		hall_activity_time_config = require "Game.game_Hall.Lua.hall_activity_time_config"
	end
end

local function SplitGroupPairs(value, groupSplit, pairSplit)
	local result = {}

	local groups = StringHelper.Split(value, groupSplit)
	if not groups or #groups <= 0 then return result end

	for k, v in pairs(groups) do
		local pair = StringHelper.Split(v, pairSplit)
		if pair and #pair == 2 then
			result[#result + 1] = {tonumber(pair[1]), tonumber(pair[2])}
		end
	end

	return result
end

--[[
[id] = {
	time_type = 0,
	activity_time = {
		{begin, end}, {begin, end}
	}
	activity_node = "but",
}
]]--
local function parse_activity_time(config)
	local monday_time = StringHelper.getThisWeekMonday()

	local time_table = {}
	for k, v in pairs(config) do
		local times = SplitGroupPairs(v.activity_time, "#", "+")
		if #times > 0 then
			if v.time_type == 1 then
				for _, t in pairs(times) do
					t[1] = t[1] + monday_time
					t[2] = t[2] + monday_time
				end
			end

			local item = {}
			item.time_type = v.time_type
			item.activity_node = v.activity_node
			item.activity_time = times
			time_table[k] = item
		end
	end
	return time_table
end

local activity_time_table = parse_activity_time(hall_activity_time_config.config)
function HallLogic.GetActivityTimeTable()
	return activity_time_table
end

-- function HallLogic.IsHaveWQPYHGuide()
--     local a,b = GameButtonManager.RunFun({gotoui="wqp_cpl_yh",uiname = "hall"}, "IsHaveGuide")
--     dump({a = a,b = b},"<color=yellow>玩棋牌CPL优化是否有引导</color>")
--     if a and b then
--         return true
--     end
-- end

return HallLogic
