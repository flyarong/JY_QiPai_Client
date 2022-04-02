-- 创建时间:2019-07-22
-- Buff管理

FishingMatchBuffManager = {}
local C = FishingMatchBuffManager
local buff_map = {}
function C.Init()
	C.MakeLister()
	C.AddMsgListener()
	for i = 1, 4 do
		buff_map[i] = {}
	end
end
function C.SetPanelSelf(ps)
    panelSelf = ps
end
function C.MyExit()
	panelSelf = nil
	C.RemoveListener()
end

function C.AddMsgListener()
    for proto_name,func in pairs(lister) do
        Event.AddListener(proto_name, func)
    end
end
function C.MakeLister()
    lister = {}
    lister["model_shoot"] = C.on_model_shoot
    lister["refresh_gun"] = C.on_refresh_gun
end

function C.RemoveListener()
    for proto_name,func in pairs(lister) do
        Event.RemoveListener(proto_name, func)
    end
    lister = {}
end

function C.on_model_shoot(data)
	if not panelSelf then
		return
	end
	local seat_num = data.seat_num
	local ks = FishingMatchModel.BuffType.BT_snap_shot
	if buff_map[seat_num] and buff_map[seat_num][ks] and buff_map[seat_num][ks].num > 0 then
		buff_map[seat_num][ks].num = buff_map[seat_num][ks].num - 1
		if buff_map[seat_num][ks].num <= 0 then
			buff_map[seat_num][ks] = nil
		end
		panelSelf.PlayerClass[seat_num]:SetQuickShoot(buff_map[seat_num][ks])
	end
end

function C.on_refresh_gun(data)
	if not panelSelf then
		return
	end
	local seat_num = data.seat_num
    local userdata = FishingMatchModel.GetSeatnoToUser(seat_num)
	if userdata and userdata.gun_info and userdata.gun_info.buffs then
		for k,v in ipairs(userdata.gun_info.buffs) do
            if v.name == FishingMatchModel.BuffType.BT_mask then
                buff_map[seat_num][v.name] = {time = v.time}
            elseif v.name == FishingMatchModel.BuffType.BT_snap_shot and v.time > 0 then
                buff_map[seat_num][v.name] = {num = v.time, rate = v.data}
                panelSelf.PlayerClass[seat_num]:SetQuickShoot(buff_map[seat_num][v.name])
            else
            	dump(v, "<color=red>EEE 未知BUFF </color>")
            end
		end
	end
end


