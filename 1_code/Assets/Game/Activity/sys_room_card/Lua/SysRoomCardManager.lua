-- 创建时间:2019-10-24
local basefunc = require "Game/Common/basefunc"
SysRoomCardManager = {}
local M = SysRoomCardManager
M.key = "sys_room_card"
M.UIConfig = GameButtonManager.ExtLoadLua(M.key, "room_card_rule")
GameButtonManager.ExtLoadLua(M.key, "RoomCardLogic")
GameButtonManager.ExtLoadLua(M.key, "RoomCardModel")
GameButtonManager.ExtLoadLua(M.key, "RoomCardJoin")
GameButtonManager.ExtLoadLua(M.key, "RoomCardGameOver")
GameButtonManager.ExtLoadLua(M.key, "RoomCardBillPanel")
GameButtonManager.ExtLoadLua(M.key, "RoomCardDissolve")
GameButtonManager.ExtLoadLua(M.key, "RoomCardCreate")
GameButtonManager.ExtLoadLua(M.key, "RoomCardDown")
GameButtonManager.ExtLoadLua(M.key, "RoomCardHallPopPrefab")
GameButtonManager.ExtLoadLua(M.key, "GPSPanel")
local lister
function M.CheckIsShow()
    return true
end
function M.GotoUI(parm)
    if parm.goto_scene_parm == "panel" then
        return RoomCardHallPopPrefab.Create(nil,parm.backcall)
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
    lister["OnLoginResponse"] = M.OnLoginResponse
    lister["ReConnecteServerSucceed"] = M.OnReConnecteServerSucceed
    lister["global_hint_state_set_msg"] = M.on_global_hint_state_set_msg
end

function M.Init()
	M.Exit()
	M.m_data = {}
	MakeLister()
    AddLister()
    M.InitUIConfig()
    RoomCardLogic.Init()
    GPSPanel.SetupGPS(function()
        local locations = sdkMgr:GetLocation() or ""
        local latitude = sdkMgr:GetLatitude() or 0
        local longitude = sdkMgr:GetLongitude() or 0
		print(string.format("[GPS] %s, %d, %d\n", locations, latitude, longitude))
    end, true)
end
function M.Exit()
	if M then
		RemoveLister()
		M.m_data = nil
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