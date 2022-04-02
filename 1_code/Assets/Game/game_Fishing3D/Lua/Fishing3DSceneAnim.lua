-- 创建时间:2020-03-23

local basefunc = require "Game/Common/basefunc"
Fishing3DSceneAnim = {}

local M = Fishing3DSceneAnim

local fish_map = {}
local fish_data_map = {}
local fish_data_index = {}
local fish_data_create_log = {}

local FishNode1
local FishNode2
local pilotID = -1
local time

local lister
local function MakeLister()
    lister = {}

    lister["EnterForeGround"] = M.on_backgroundReturn_msg
    lister["EnterBackGround"] = M.on_background_msg

    lister["fishing_ready_finish"] = M.ReadyFinish
end
local function AddMsgListener()
    for proto_name, func in pairs(lister) do
        Event.AddListener(proto_name, func)
    end
end
local function RemoveMsgListener()
    for proto_name, func in pairs(lister) do
        Event.RemoveListener(proto_name, func)
    end
end
function M.GetID()
    pilotID = pilotID - 1
    if pilotID > 0 then
    	pilotID = -1
    end
    return pilotID
end
--游戏前台消息
function M.on_backgroundReturn_msg()
end
--游戏后台消息
function M.on_background_msg()
	M.StopTime()
end
function M.ReadyFinish()
	if time then
		time:Start()
	end
	M.begin_time = os.time()

	for k,v in pairs(fish_map) do
		v:MyExit()
	end
	fish_map = {}
	fish_data_create_log = {}
end
function M.Init(_fishNodeTran, _fishGroupNodeTran)
	FishNode1 = _fishNodeTran
    FishNode2 = _fishGroupNodeTran
    M.InitData()
    M.StopTime()
    MakeLister()
    AddMsgListener()

    time = Timer.New(function ()
        M.FrameUpdate()
    end, 1, -1,false,true)
end
function M.Exit()
	RemoveMsgListener()
end
function M.StopTime()
	if time then
		time:Stop()
	end
end
function M.InitData()	
    local var = {}
    var.fish_id = -1
    var.fish_type = 24
    var.path = 94
    var.time = 0
    var.speed = 50
    var.clear_level = 10
    var.rate = 100
    var.local_scale = 1.2
    var.cd = 10
    var.sc_cd = 10
    var.cur_z_val = 9900

    fish_data_map[var.fish_id] = var
    fish_data_index[#fish_data_index + 1] = var.fish_id
end

function M.FrameUpdate()
    if FishingModel.data and FishingModel.data.game_id and FishingModel.data.game_id == 2 then
        local cur_t = os.time()
        local beg_t = M.begin_time
        local cha = cur_t - beg_t
        for k,v in pairs(fish_data_map) do
            if not fish_map[v.fish_id] then
                local log = fish_data_create_log[k]
                if (not log and (not v.sc_cd or cha > v.sc_cd) ) or (log and cur_t > (log.create_t + v.cd) ) then
                    M.CreateFish(v)
                end
            end
        end
    end
end
-- 根据ID清除鱼
function M.FishMoveFinish(_fishID)
    if fish_map[_fishID] then
    	local data = fish_data_map[_fishID]
	    if data.fish_type == 24 then
	    	local shuibo = fish_map[_fishID].transform:Find("shuibo")
	    	if IsEquals(shuibo) then
	    		shuibo.gameObject:SetActive(true)
	    	end
	    end

        fish_map[_fishID]:MyExit()
        fish_map[_fishID] = nil
    end
end
function M.CreateFish(data)
	-- 创建领航员
	local id = M.GetID()
	local cfg = FishingModel.Config.steer_map[data.path]
    local m_vPos = {x=cfg.posX, y=cfg.posY}
    local m_vHeading = {x=cfg.headX, y=cfg.headY}
    m_vHeading = Vec2DNormalize(m_vHeading)
    local m_vSide = Vec2DPerp(m_vHeading)

    local pilot = VehicleManager.Create(FishNode2, {ID=id, m_vPos=m_vPos, m_vHeading=m_vHeading, m_vSide=m_vSide})
    for k,v in ipairs(cfg.steer) do
        VehicleManager.AddSteerings(pilot, v)
    end
    local speed
    if data.speed then
        speed = data.speed / 100
    else
        speed = fish_cfg.max_speed or 1
    end
    pilot:SetMaxSpeed(speed)
    pilot:Start()

    local scale = data.local_scale or 1
    local fish = Fish.Create(FishNode2, data)
    fish.fish_base.root_scale = scale
    fish.fish_base.cur_z_val = data.cur_z_val or 9600
    if data.fish_type == 24 then
    	local shuibo = fish.transform:Find("shuibo")
    	if IsEquals(shuibo) then
    		shuibo.gameObject:SetActive(false)
    	end
    end

    fish:SetFeignDead(true)
    fish.fish_base.anim_pay.speed = 0.4
    VehicleManager.SetInstantiate(id, fish)

    if fish_map[data.fish_id] then
    	fish_map[data.fish_id]:MyExit()
    end
    fish_map[data.fish_id] = fish
    fish_data_create_log[data.fish_id] = {create_t = os.time()}
end


