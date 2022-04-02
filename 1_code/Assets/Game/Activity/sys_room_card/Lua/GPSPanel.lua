local basefunc = require "Game.Common.basefunc"

GPSPanel = basefunc.class()

local instance
local trustDistance = 50
local isTrustDistance = false
local permission  -- 0 已授权 ，1 玩家还没有选择， 2 玩家未授权
local opposite_player = {}
local gps_ready = false
--[[GPS定位
    isCreate : true 创建 ， false 刷新
    my_seat : 玩家座位号
    playerInfo : 玩家数据
    data : GPS数据
    confirmCbk - 确定按钮回调
]]
function GPSPanel.Create(isCreate, isMustCreate, my_seat, playerInfo, data, callback, confirmCbk)
    if isCreate then
        if not instance then
		print("[DEBUG][GPS Panel] Create. instance = nil and isCreate = true")
            instance = GPSPanel.New(my_seat, playerInfo, data, confirmCbk)
        else
		print("[DEBUG][GPS Panel] Create. instance ~= nil and isCreate = true")
            instance:MyRefreshData(my_seat, playerInfo, data, confirmCbk)
            instance:MyRefresh()
        end
    else
        if isMustCreate then
            if not instance then
	    	print("[DEBUG][GPS Panel] Create. instance = nil and isCreate = false mustCreate = true")
                instance = GPSPanel.New(my_seat, playerInfo, data, confirmCbk)
            else
	    	print("[DEBUG][GPS Panel] Create. instance ~= nil and isCreate = false mustCreate = true")
                instance:MyRefreshData(my_seat, playerInfo, data, confirmCbk)
                instance:MyRefresh()
            end
        else
            if instance then
	    	print("[DEBUG][GPS Panel] Create. instance ~= nil and isCreate = false mustCreate = false")
                instance:MyRefreshData(my_seat, playerInfo, data, confirmCbk)
                instance:MyRefresh()
            else
	    	print("[DEBUG][GPS Panel] Create. instance = nil and isCreate = false mustCreate = false")
                --print("<color=yellow>instance == nil</color>")
            end
        end
    end

    --判断是否需要自动弹出
    isTrustDistance = GPSPanel.IsMustCreate(data.data)
    --print("[DEBUG][GPS Panel] Create IsMustCreate: " .. tostring(isTrustDistance))
    print("[DEBUG][GPS Panel] Create IsMustCreate: ", isTrustDistance)

    if callback then
        callback(isTrustDistance)
    end

    return instance
end

function GPSPanel:ctor(my_seat, playerInfo, data, confirmCbk)

	ExtPanel.ExtMsg(self)

    self.my_seat = my_seat
    self.player_info = playerInfo
    self.player_count = #playerInfo
    self.data = data.data
    self.confirmCbk = confirmCbk

    self.parent = GameObject.Find("Canvas/LayerLv3")

    self:InitUI()
end

-- 参考比赛场提示效果
function GPSPanel:InitUI()
    self.UIEntity = newObject("GPSPanel", self.parent.transform)
    self.gameObject = self.UIEntity
    LuaHelper.GeneratingVar(self.UIEntity.transform, self)
    self.topRT = {}
    self.downRT = {}
    self.leftRT = {}
    self.rightRT = {}
    LuaHelper.GeneratingVar(self.top, self.topRT)
    LuaHelper.GeneratingVar(self.down, self.downRT)
    LuaHelper.GeneratingVar(self.left, self.leftRT)
    LuaHelper.GeneratingVar(self.right, self.rightRT)
    self.color_red = Color.New(232 / 255, 17 / 255, 17 / 255, 1)

    self.confirm_btn.onClick:AddListener(
        function()
            if self.confirmCbk then
                self.confirmCbk()
            end
            GameObject.Destroy(self.UIEntity)
            instance = nil
	    print("[DEBUG][GPS Panel] Destroy. instance = nil")
        end
    )

    --权限相关
    permission = GPSPanel.GetGPSPermission()
    self.positioning_btn.gameObject:SetActive(permission ~= 0)
    self.positioning_btn.onClick:AddListener(
        function()
            GPSPanel.SetupGPS(GPSPanel.request_gps_info)
        end
    )

    --这里重新发起一次
    GPSPanel.SetupGPS(GPSPanel.request_gps_info)

    self:MyRefresh()
end

function GPSPanel:MyExit()
    self.my_seat = nil
    self.player_info = nil
    self.player_count = nil
    self.data = nil
    self.confirmCbk = nil
    destroy(self.gameObject)
end
function GPSPanel.Close()
    if instance then
        instance:MyExit()
        instance = nil
    end
end

function GPSPanel:MyRefreshData(my_seat, playerInfo, data, confirmCbk)
    self.my_seat = my_seat
    self.player_info = playerInfo
    self.player_count = #playerInfo
    self.data = data.data
    self.confirmCbk = confirmCbk
end

function GPSPanel:MyRefresh()
    local ui_pos = 1
    if self.player_count == 4 then
        if IsEquals(self.top) then
            self.top.gameObject:SetActive(true)
        end
        ui_pos = 3
        self:SetLeftAndRight(ui_pos, self.topRT)
        local topData = self.data[self:GetPosToSeatnoByCorrectUIPos(ui_pos)]
        if topData and next(topData) then
            local down_dis = topData.distance[self:GetPosToSeatnoByCorrectUIPos(ui_pos - 2)]
            opposite_player = self:GetPlayerInfoByUIPos(ui_pos - 2)
            self:SetLineByDistance(down_dis, self.topRT.other_distance_txt, self.topRT.other_line_img, opposite_player)
        else
            opposite_player = self:GetPlayerInfoByUIPos(ui_pos - 2)
            self:SetLineByDistance(-1, self.topRT.other_distance_txt, self.topRT.other_line_img, opposite_player)
            opposite_player = self:GetPlayerInfoByUIPos(ui_pos - 1)
            self:SetLineByDistance(-1, self.topRT.left_distance_txt, self.topRT.left_line_img, opposite_player)
            opposite_player = self:GetPlayerInfoByUIPos(ui_pos + 1)
            self:SetLineByDistance(-1, self.topRT.right_distance_txt, self.topRT.right_line_img, opposite_player)
        end
    elseif self.player_count == 3 then
        if IsEquals(self.top) then
            self.top.gameObject:SetActive(false)
        end
    end
    ui_pos = 1
    self:SetLeftAndRight(ui_pos, self.downRT)
    local my_left_ui_pos = ui_pos - 1
    local my_right_ui_pos = ui_pos + 1

    local left_data = self.data[self:GetPosToSeatnoByCorrectUIPos(my_left_ui_pos)]
    local right_data = self.data[self:GetPosToSeatnoByCorrectUIPos(my_right_ui_pos)]
    if (left_data and next(left_data)) and (right_data and next(right_data)) then
        local opposite = 0
        if self.player_count == 3 then
            opposite = my_left_ui_pos - 1
        else
            opposite = my_left_ui_pos - 2
        end
        local down_dis = left_data.distance[self:GetPosToSeatnoByCorrectUIPos(opposite)]
        opposite_player = self:GetPlayerInfoByUIPos(my_left_ui_pos)
        self:SetLineByDistance(down_dis, self.downRT.other_distance_txt, self.downRT.other_line_img, opposite_player)
    else
        self:SetLineByDistance(-1, self.downRT.other_distance_txt, self.downRT.other_line_img, nil)
    end

    if left_data and next(left_data) then
        self:SetPlayerInfoByGPSData(
            self.leftRT,
            true,
            left_data.ip,
            left_data.locations,
            self:GetPlayerInfoByUIPos(my_left_ui_pos).head_link
        )
    else
        self:SetPlayerInfoByGPSData(self.leftRT, false, "", "", "")
    end

    if right_data and next(right_data) then
        self:SetPlayerInfoByGPSData(
            self.rightRT,
            true,
            right_data.ip,
            right_data.locations,
            self:GetPlayerInfoByUIPos(my_right_ui_pos).head_link
        )
    else
        self:SetPlayerInfoByGPSData(self.rightRT, false, "", "", "")
    end

    isTrustDistance = GPSPanel.IsMustCreate(self.data)
    if IsEquals(self.warning) then
        self.warning.gameObject:SetActive(isTrustDistance)
    end
end

function GPSPanel:SetLeftAndRight(ui_pos, RT)
    local data = self.data[self:GetPosToSeatno(ui_pos)]
    local my_left_ui_pos = ui_pos - 1
    local my_right_ui_pos = ui_pos + 1
    if data and next(data) then
        self:SetPlayerInfoByGPSData(RT, true, data.ip, data.locations, self:GetPlayerInfoByUIPos(ui_pos).head_link)

        local left_dis = data.distance[self:GetPosToSeatnoByCorrectUIPos(my_left_ui_pos)]
        opposite_player = self:GetPlayerInfoByUIPos(my_left_ui_pos)
        self:SetLineByDistance(left_dis, RT.left_distance_txt, RT.left_line_img, opposite_player)

        local right_dis = data.distance[self:GetPosToSeatno(self:CorrectUIPos(my_right_ui_pos))]
        opposite_player = self:GetPlayerInfoByUIPos(my_right_ui_pos)
        self:SetLineByDistance(right_dis, RT.right_distance_txt, RT.right_line_img, opposite_player)
    else
        self:SetPlayerInfoByGPSData(RT, false, "", "", "")

        RT.left_line_img.color = Color.white
        RT.right_line_img.color = Color.white
        RT.left_distance_txt.color = Color.white
        RT.right_distance_txt.color = Color.white
        RT.left_distance_txt.text = ""
        RT.right_distance_txt.text = ""
    end
end

function GPSPanel:SetLineByDistance(dis, distance_txt, line_img, player_info)
    dis = dis or -1
    if dis < trustDistance and dis >= 0 then
        distance_txt.text = dis
        distance_txt.color = self.color_red
        line_img.color = self.color_red
    elseif dis > trustDistance or dis == -1 then
        distance_txt.text = player_info and (dis == -1 and "未知" or dis) or ""
        distance_txt.color = Color.white
        line_img.color = Color.white
    end
end

function GPSPanel:SetPlayerInfoByGPSData(RT, is_show, ip, locations, head_link)
    RT.head_img.gameObject:SetActive(is_show)
    RT.unknown_img.gameObject:SetActive(not is_show)
    RT.ip_txt.text = ip
    RT.locations_txt.text = locations
    URLImageManager.UpdateHeadImage(head_link, RT.head_img)
end

function GPSPanel:GetPlayerInfoByUIPos(ui_pos)
    return self.player_info[self:GetPosToSeatnoByCorrectUIPos(ui_pos)].base
end

function GPSPanel:GetPosToSeatnoByCorrectUIPos(ui_pos)
    return self:GetPosToSeatno(self:CorrectUIPos(ui_pos))
end

function GPSPanel:CorrectUIPos(ui_pos)
    if ui_pos > self.player_count then
        ui_pos = ui_pos % self.player_count
    elseif ui_pos <= 0 then
        ui_pos = (ui_pos + self.player_count)
    end
    return ui_pos
end

function GPSPanel.GetGPSPermission()
	local permission = sdkMgr:GetCanLocation()
	if permission == 2 then
		local PREF_KEY = "GPSPermission"
		local PlayerPrefs = UnityEngine.PlayerPrefs
		if not PlayerPrefs.HasKey(PREF_KEY) then
			PlayerPrefs.SetInt(PREF_KEY, 1)
			permission = 1
		end
	end
	return permission
end

function GPSPanel.GetGPSData()
    MainModel.CityName = gameMgr:GetCityName()
    MainModel.Latitude = gameMgr:GetLatitude()
    MainModel.Longitude = gameMgr:GetLongitude()

    return MainModel.CityName, MainModel.Latitude, MainModel.Longitude
end

function GPSPanel.send_gps_info() --
    --[[sdkMgr:StartGPS(function(result)
		if result > 0 then
			gps_ready = true
			if result == 2 then
				GPSPanel.request_gps_info()
			end
		end
    end)]] GPSPanel.SetupGPS(
        GPSPanel.request_gps_info
    )
end

function GPSPanel.SetupGPS(callback, unforced)
    local permission = GPSPanel.GetGPSPermission()
    -- print("<color=blue>permission</color>",permission)
    if permission == 0 then
        sdkMgr:QueryGPS(
            function()
                callback()
            end
        )
     --
    elseif permission == 1 then
        sdkMgr:OpenLocation()
    else
    	unforced = unforced or false
	if unforced then return end

	HintPanel.Create(
	    1,
	    "定位功能需要开启高精度定位模式\n",
	    function()
		sdkMgr:GotoSetScene("GPS")
	    end
	)
    end
end

function GPSPanel.request_gps_info()
    print(sdkMgr:GetLatitude())
    local qstr = GPSPanel:IsZJFModel() and "zijianfang_send_gps_info" or "send_gps_info"
    Network.SendRequest(
        qstr,
        --{locations = gameMgr:GetCityName() or "" , latitude = gameMgr:GetLatitude() or 0 , longitude = gameMgr:GetLongitude() or 0},
        {
            locations = sdkMgr:GetLocation() or "",
            latitude = sdkMgr:GetLatitude() or 0,
            longitude = sdkMgr:GetLongitude() or 0
        },
        -- {locations = "成都市", latitude = "10.12" .. math.random(1, 10), longitude = "11.11" .. math.random(1, 10)},
        "发送GPS数据",
        function(data)
            if data.result == 0 then
                -- print("<color=yellow>gsf:   GPS数据发送成功</color>")
            else
                HintPanel.ErrorMsg(data.result)
            end
        end
    )
end

--[[GPS定位
    isCreate : true 创建 ， false 刷新
    my_seat : 玩家座位号
    playerInfo : 玩家数据
    data : GPS数据
    confirmCbk - 确定按钮回调
]]
function GPSPanel.query_gps_info(isCreate, my_seat, playerInfo, callback, confirmCbk,is_zjf)
    local qstr = GPSPanel:IsZJFModel() and "zijianfang_query_gps_info" or "query_gps_info"
    Network.SendRequest(
        qstr,
        {},
        "请求GPS数据",
        function(data)
            if data.result == 0 then
                dump(data, "<color=yellow>GPS数据</color>")
                GPSPanel.Create(isCreate, GPSPanel.IsMustCreate(data.data), my_seat, playerInfo, data, callback, confirmCbk)
            else
                HintPanel.ErrorMsg(data.result)
            end
        end
    )
end

function GPSPanel.IsMustCreate(data)
    for i, v in ipairs(data) do
        if v.distance then
            for k, v_dis in ipairs(v.distance) do
                if v_dis >= 0 and v_dis <= trustDistance then
                    return true
                end
            end
        end
    end
    return false
end

-- 返回自己的座位号
function GPSPanel:GetPlayerSeat()
    return self.my_seat
end
-- 返回自己的UI位置
function GPSPanel:GetPlayerUIPos()
    return self.GetSeatnoToPos(self.my_seat)
end
-- 根据座位号获取玩家UI位置
function GPSPanel:GetSeatnoToPos(seatno)
    if seatno then
        local seftSeatno = self:GetPlayerSeat()
        return (seatno - seftSeatno + self.player_count) % self.player_count + 1
    else
        return self.my_seat
    end
end
-- 根据UI位置获取玩家座位号
function GPSPanel:GetPosToSeatno(uiPos)
    local seftSeatno = self:GetPlayerSeat()
    return (uiPos - 1 + seftSeatno - 1) % self.player_count + 1
end

function GPSPanel:IsZJFModel()
    if MainModel.myLocation == "game_DdzZJF" then
        return true
    end
end