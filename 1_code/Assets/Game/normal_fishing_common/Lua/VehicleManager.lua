-- 创建时间:2019-03-07

VehicleManager = {}

local vehicle_map = {}

function VehicleManager.FrameUpdate(time_elapsed)
	if vehicle_map and next(vehicle_map) then
		for k,v in pairs(vehicle_map) do
			if not v.is_stop then
				v.vehicle:FrameUpdate(time_elapsed)
			end
		end
	end
end
function VehicleManager.Create(parent, parm)
	local vehicle = Vehicle.Create(parent, parm)
	vehicle_map[parm.ID] = {vehicle=vehicle, is_stop = false}
	return vehicle
end

function VehicleManager.AddLeaderChild(leader, vehicle)
	if not leader.child_map then
		leader.child_map = {}
	end
	leader.child_map[vehicle.ID] = {vehicle=vehicle, is_stop = false}
end

function VehicleManager.SetInstantiate(id, obj)
	local vehicle = VehicleManager.GetVehicleByID(id)
	if vehicle then
		vehicle.vehicle:SetInstantiate(obj)
	end
end

function VehicleManager.Exit()
	if vehicle_map and next(vehicle_map) then
		for k,v in pairs(vehicle_map) do
			v.vehicle:MyExit()
		end
	end
	vehicle_map = {}
end

function VehicleManager.GetSteerings(parm)	
	local steerings
	if parm.type == 1 then
		steerings = SteeringForFollowPath.New(parm)
	elseif parm.type == 2 then
		steerings = SteeringForCircle.New(parm)
	elseif parm.type == 3 then
		steerings = SteeringForWait.New(parm)
	else
		steerings = SteeringForOffsetPursuit.New(parm)
	end

	return steerings
end

function VehicleManager.AddSteerings(vehicle, parm)
	local list = {}
	for k,v in ipairs(parm) do
		v.m_pVehicle = vehicle
		list[#list + 1] = VehicleManager.GetSteerings(v)
	end
	vehicle:AddSteerings(list)
end

function VehicleManager.GetVehicleByID(id)
	if vehicle_map[id] then
		return vehicle_map[id]
	end
end

function VehicleManager.RemoveVehicle(id)
	if id then
		local fish = FishManager.GetFishByID(id)
		if not fish or not fish.data.status or fish.data.status <= 1 then
			vehicle_map[id] = nil
		end
	end
end

function VehicleManager.RemoveAll()
	vehicle_map = {}
end

local flee_list = {}
local flee_leader_list = {}
function VehicleManager.RemoveAllFlee()
	for k,v in ipairs(flee_list) do
		vehicle_map[v] = nil
	end
	flee_list = {}
end
function VehicleManager.PlayFlee(clear_level)
	if vehicle_map and next(vehicle_map) then
		for k,v in pairs(vehicle_map) do
			if v.vehicle.game_entity and clear_level >= v.vehicle.game_entity.data.clear_level then
				v.vehicle:PlayFlee()
				flee_list[#flee_list + 1] = k
			end
		end
	end
end

-- 暂停移动
function VehicleManager.Stop(id)
	if id < 0 then -- 特殊鱼，场景创建做表现用的
		return
	end
	if vehicle_map[id] then
		vehicle_map[id].is_stop = true
	end
end
-- 恢复移动
function VehicleManager.Recover(id, pos)
	if vehicle_map[id] then
		vehicle_map[id].is_stop = false
		local _pos = {x=pos.x, y=pos.y}
		vehicle_map[id].vehicle:SetPos(_pos)
	end
end
-- 播放加速游动
function VehicleManager.PlaySpeedUp(id, velocity_scale)
	if vehicle_map[id] then
		vehicle_map[id].vehicle:PlayFlee(velocity_scale)
	end
end

function VehicleManager.SetIceState(b)
	if vehicle_map and next(vehicle_map) then
		for k,v in pairs(vehicle_map) do
			if k > 0 then
				v.is_stop = b
			end
		end
	end
end
