-- package.loaded["Game.game_Zjd.Lua.ShatterGoldenEggModel"] = nil
require("Game.game_Zjd.Lua.ShatterGoldenEggModel")

package.loaded["Game.game_Zjd.Lua.ShatterGoldenEvent"] = nil
require("Game.game_Zjd.Lua.ShatterGoldenEvent")

package.loaded["Game.game_Zjd.Lua.ShatterGoldenEvent2Egg"] = nil
require "Game.game_Zjd.Lua.ShatterGoldenEvent2Egg"

ShatterGoldenEggLogic = {}

local this = nil
local lister = {}
local viewLister = {}
local cacheData = {}
local model = nil
local overrideHammer = -1
local eventTimer = nil
local playMode = 0

local MAX_RATE = 1000
local objectPools = {
	summary = {
		top = 0,
		map = {}
	},
	buckets = {}
}

local function MakeLister()
	lister = {}
	lister["model_sge_status"] = ShatterGoldenEggLogic.handle_sge_status
	lister["model_sge_hammer"] = ShatterGoldenEggLogic.handle_sge_hammer
	lister["model_sge_spawn"] = ShatterGoldenEggLogic.handle_sge_spawn
	lister["model_sge_hit"] = ShatterGoldenEggLogic.handle_sge_hit
	lister["model_sge_hit_nomoney"] = ShatterGoldenEggLogic.handle_sge_hit_nomoney
	lister["model_sge_exception"] = ShatterGoldenEggLogic.handle_sge_exception

	lister["model_sge_ranking"] = ShatterGoldenEggLogic.handle_sge_ranking
	lister["model_sge_giftbag_refresh"] = ShatterGoldenEggLogic.handle_sge_giftbag_refresh
end

local function AddMsgListener(lister)
    for proto_name,func in pairs(lister) do
        Event.AddListener(proto_name, func)
    end
end

local function RemoveMsgListener(lister)
    for proto_name,func in pairs(lister) do
        Event.RemoveListener(proto_name, func)
    end
end

local function ViewMsgRegister(registerName)
	if registerName then
		if viewLister[registerName] then
			AddMsgListener(viewLister[registerName])
		end
	else
		for k,lister in pairs(viewLister) do
			AddMsgListener(lister)
		end
	end
end

local function cancelViewMsgRegister(registerName)
	if  registerName then
		if viewLister[registerName] then 
			RemoveMsgListener(viewLister[registerName])
		end 
	else
		for k,lister in pairs(viewLister) do
			RemoveMsgListener(lister)
		end
	end
end

local function clearAllViewMsgRegister()
	cancelViewMsgRegister()
	viewLister={}
end

function ShatterGoldenEggLogic.setViewMsgRegister(lister, registerName)
	--检测是否已经注册
	if not registerName or viewLister[registerName] then
		return false
	end
	viewLister[registerName]=lister
	ViewMsgRegister(registerName)
end

function ShatterGoldenEggLogic.clearViewMsgRegister(registerName)
	cancelViewMsgRegister(registerName)
	viewLister[registerName] = nil
end

function ShatterGoldenEggLogic.Init(parm)
	ShatterGoldenEggLogic.Exit()
	this = ShatterGoldenEggLogic
	if parm then ShatterGoldenEggLogic.SetOverrideHammer(parm) end
	model = ShatterGoldenEggModel.Init()
	MakeLister()
	AddMsgListener(lister)

	cacheData = {}
	cacheData.locked = false

	if GameGlobalOnOff.ZJD_EVE then
		local event_active = ShatterGoldenEvent.CheckActive()

		eventTimer = Timer.New(function ()
			event_active = ShatterGoldenEggLogic.update_event_active(event_active)
			ShatterGoldenEggLogic.update_event_sale()
		end, 1, -1)
		eventTimer:Start()
	end
end

function ShatterGoldenEggLogic.Exit()
	if eventTimer then
		eventTimer:Stop()
		eventTimer = nil
	end

	RemoveMsgListener(lister)
	clearAllViewMsgRegister()
	if ActivityButtonLogic then
		ActivityButtonLogic.Exit()
	end
	if model then
		model.Exit()
		model = nil
	end

	cacheData = {}

	ShatterGoldenEggLogic.FreeObjects()

	this = nil
end

function ShatterGoldenEggLogic.update_event_active(event_active)
	if event_active == 0 then
		event_active = ShatterGoldenEvent.CheckActive()
		if event_active == 1 then
			Event.Brocast("view_sge_event_begin")
		end
	elseif event_active == 1 then
		event_active = ShatterGoldenEvent.CheckActive()
		if event_active == 2 then
			Event.Brocast("view_sge_event_end")
		end
	elseif event_active == 2 then
		event_active = ShatterGoldenEvent.CheckActive()
		if event_active == -1 then
			Event.Brocast("view_sge_event_over")
		end
	else
		--print("idle........")
	end
	return event_active
end

function ShatterGoldenEggLogic.FormatCountdownFimer(second)
	local timeHour = math.fmod(math.floor(second/3600), 24)
	local timeMinute = math.fmod(math.floor(second/60), 60)
	local timeSecond = math.fmod(second, 60)
	return string.format("%02d:%02d:%02d", timeHour, timeMinute, timeSecond)
end

function ShatterGoldenEggLogic.update_event_sale()
	local config_idx = ShatterGoldenEggLogic.GetHammer()

	local param = {}
	param.hammer_idx = config_idx
	param.timer = "00:00:00"

	local logic = model.getLogicConfig(config_idx)
	if not logic or not logic.sale then
		Event.Brocast("view_sge_sale_countdown", param)
		return
	end

	local countdown = ShatterGoldenEggLogic.GetHammerData(config_idx, "sale_countdown") or 0
	if countdown <= 0 then
		Event.Brocast("view_sge_sale_countdown", param)
	else
		countdown = countdown - 1
		ShatterGoldenEggLogic.SetHammerData(config_idx, "sale_countdown", countdown)

		param.timer = ShatterGoldenEggLogic.FormatCountdownFimer(countdown)
		Event.Brocast("view_sge_sale_countdown", param)
	end
end

function ShatterGoldenEggLogic.HandleTimer()
end

function ShatterGoldenEggLogic.GetOverrideHammer()
	return overrideHammer
end

function ShatterGoldenEggLogic.SetOverrideHammer(propName)
	local HAMMER_TBL = {
		"prop_hammer_1", "prop_hammer_2", "prop_hammer_3", "prop_hammer_4"
	}
	overrideHammer = -1
	for k, v in pairs(HAMMER_TBL) do
		if propName == v then
			overrideHammer = k
			break
		end
	end

	print("[Debug] SGE SetOverrideHammer: prop:" .. propName .. " : " .. overrideHammer)
end

function ShatterGoldenEggLogic.GetPlayMode()
	return playMode
end

function ShatterGoldenEggLogic.SetPlayMode(mode)
	playMode = mode
end

function ShatterGoldenEggLogic.IsNormalMode()
	return playMode == 0
end

function ShatterGoldenEggLogic.ConvertEgg2IDFromC2S(hammer_idx, id)
	local mode_idx = ShatterGoldenEggModel.getExtra2EggsData("mode_idx") or 0
	local mode_hammer = ShatterGoldenEggModel.getExtra2EggsData("mode_hammer") or hammer_idx

	local offset = 100
	if mode_idx == 1 then
		offset = offset + 6
	end
	return offset + (mode_hammer - 1) * 2 + id
end

function ShatterGoldenEggLogic.ConvertEgg2IDFromS2C(id)
	local mode_idx = ShatterGoldenEggModel.getExtra2EggsData("mode_idx") or 0
	local mode_hammer = ShatterGoldenEggModel.getExtra2EggsData("mode_hammer") or hammer_idx

	local offset = 100
	if mode_idx == 1 then
		offset = offset + 6
	end

	local idx = id - offset - (mode_hammer - 1) * 2
	if idx ~= 1 and idx ~= 2 then
		print(string.format("[SGE] ConvertEgg2IDFromS2C(%d) mode_idx(%d) mode_hammer(%d) exception:%d", id, mode_idx, mode_hammer, idx))
		idx = ((id + 1) % 2) + 1
	end

	return idx
end

function ShatterGoldenEggLogic.SetHammer(config_idx)
	local hammerData = cacheData.hammerData or {}
	if not hammerData[config_idx] then
		hammerData[config_idx] = {}
	end
	cacheData.activeHammer = config_idx
	cacheData.hammerData = hammerData
end

function ShatterGoldenEggLogic.GetHammer()
	return cacheData.activeHammer or 0
end

function ShatterGoldenEggLogic.getHammerBySaleID(item_id)
	local logics = model.getLogicConfig(-1)
	if not logics then return -1 end

	for k, v in ipairs(logics) do
		if v.sale then
			if v.sale.item_id == item_id then
				return k
			end
		end
	end

	return -1
end

function ShatterGoldenEggLogic.SetHammerData(config_idx, key, value)
	local hammerData = cacheData.hammerData or {}
	if not hammerData[config_idx] then
		hammerData[config_idx] = {}
	end
	cacheData.hammerData = hammerData
	hammerData[key] = value
end

function ShatterGoldenEggLogic.GetHammerData(config_idx, key)
	local hammerData = cacheData.hammerData or {}
	if not hammerData[config_idx] then
		hammerData[config_idx] = {}
	end
	cacheData.hammerData = hammerData
	return hammerData[key]
end

function ShatterGoldenEggLogic.CheckHammer(config_idx)
	local hammer_count = model.getHammerCount(config_idx)
	if hammer_count <= 0 then
		print("[Debug] SGE CheckHammer failed: hammer_count <= 0:" .. config_idx)
		return false
	end
	return true
end

function ShatterGoldenEggLogic.GetUnBrokenList(config_idx)
	local unbroken_list = {}

	local state = model.getStates(config_idx)
	if not state or #state <= 0 then
		print("[SGE] GetUnBrokenList failed: state is invalid:" .. config_idx)
		return unbroken_list
	end

	local stateConfig = model.getStateConfig()
	for k, v in ipairs(state) do
		if v ~= stateConfig.BROKEN then
			unbroken_list[#unbroken_list + 1] = k
		end
	end

	return unbroken_list
end

function ShatterGoldenEggLogic.GetBrokenCount(config_idx)
	local state = model.getStates(config_idx)
	if not state or #state <= 0 then
		print("[SGE] GetBrokenCount failed: state is invalid:" .. config_idx)
		return -1
	end

	local stateConfig = model.getStateConfig()
	local count = 0
	for _, v in ipairs(state) do
		if v == stateConfig.BROKEN then
			count = count + 1
		end
	end

	return count
end

function ShatterGoldenEggLogic.EstimateRespawn(config_idx, pad_count)
	local broken_count = ShatterGoldenEggLogic.GetBrokenCount(config_idx)
	if broken_count < 0 then return false end

	local logic = model.getLogicConfig(config_idx)
	if not logic then return false end

	return (broken_count + pad_count) >= logic.respawn
end

function ShatterGoldenEggLogic.CheckStates(config_idx)
	local broken_count = ShatterGoldenEggLogic.GetBrokenCount(config_idx)
	if broken_count < 0 then return false end

	local logic = model.getLogicConfig(config_idx)
	if not logic then return false end

	return broken_count < logic.respawn
end

function ShatterGoldenEggLogic.CheckBaseMoney(config_idx, isCSMode)
	local needMoney = model.getBaseMoney(config_idx, isCSMode)
	local currentMoney = MainModel.UserInfo.jing_bi or 0
	return currentMoney >= needMoney
end

function ShatterGoldenEggLogic.CheckReplaceMoney(config_idx)
	local needMoney = model.getReplaceMoney(config_idx)
	local currentMoney = MainModel.UserInfo.jing_bi or 0
	return currentMoney >= needMoney
end

function ShatterGoldenEggLogic.lock()
	cacheData.locked = true
end

function ShatterGoldenEggLogic.unlock()
	cacheData.locked = false
end

function ShatterGoldenEggLogic.is_locked()
	return cacheData.locked
end

function ShatterGoldenEggLogic.SendStatus()
	print("[Debug] SGE SendStatus")

	ShatterGoldenEggLogic.lock()

	Network.SendRequest("zjd_get_game_status")

	--[[Test]
	local result = {
		result = 0,
		status = {
			now_level = 1,
			status = {
				[1] = {
					level = 1,
					hammer_num = 4,
					fan_bei = 2,
					eggs_status = nil,--{1,2,1,2,1,2,1,2,1,2,3,3},
					replace_money = 1000
				},
				[2] = {
					level = 2,
					hammer_num = 3,
					fan_bei = 4,
					eggs_status = nil,--{1,2,1,2,1,2,1,2,1,2,3,3},
					replace_money = 1000
				}
			}
		}
	}
	Event.Brocast("zjd_get_game_status_response", result)]]--
end

function ShatterGoldenEggLogic.handle_sge_status(config_idx)
	print("[Debug] SGE handle_sge_status:" .. config_idx .. " : " .. overrideHammer)

	ShatterGoldenEggLogic.unlock()

	--override
	if overrideHammer > 0 then
		ShatterGoldenEggLogic.SendHammer(overrideHammer)
		overrideHammer = -1

	else
		ShatterGoldenEggLogic.SetHammer(config_idx)
		ShatterGoldenEggLogic.SendHammer(config_idx)
	end
end

function ShatterGoldenEggLogic.SendHammer(config_idx)
	print("[Debug] SGE SendHammer:" .. config_idx)

	ShatterGoldenEggLogic.lock()

	Network.SendRequest("zjd_replace_hammer" , {level = config_idx})

	--[[Test]
	local result = {
		result = 0,
		level = config_idx
	}
	Event.Brocast("zjd_replace_hammer_response", result)]]--
end

function ShatterGoldenEggLogic.handle_sge_hammer(config_idx)
	print("[Debug] SGE handle_sge_hammer:" .. config_idx)

	ShatterGoldenEggLogic.unlock()
	ShatterGoldenEggLogic.SetHammer(config_idx)

	Event.Brocast("view_sge_hammer", config_idx)

	--query giftbox
	local logic = model.getLogicConfig(config_idx)
	if logic and logic.sale then
		Network.SendRequest("query_gift_bag_status" , {gift_bag_id = logic.sale.item_id})
	else
		Event.Brocast("view_sge_hide_sale", config_idx)
	end
end

function ShatterGoldenEggLogic.SendSpawn(config_idx)
	if ShatterGoldenEggLogic.is_locked() then
		print("[SGE] SendSpawn failed: locked")
		return
	end

	ShatterGoldenEggLogic.lock()

	Network.SendRequest("zjd_replace_eggs", {level = config_idx})

	--[Test]
	--[[local data = {
		[1] = {
			result = 0,
			level = 1,
			award_list = { 1,3,5,7,9,1,2,3,4,5,11,12 }
		},
		[2] = {
			result = 0,
			level = 2,
			award_list = { 2,4,6,8,10,6,7,8,9,10,11,12 }
		}
	}
	Event.Brocast("zjd_replace_eggs_response", data[config_idx])--]]
end

function ShatterGoldenEggLogic.handle_sge_spawn(config_idx)
	print("[Debug] SGE handle_sge_spawn:" .. config_idx)
	ShatterGoldenEggLogic.unlock()

	Event.Brocast("view_sge_spawn", config_idx)
end

function ShatterGoldenEggLogic.SendHit(config_idx, slot_idx)
	if ShatterGoldenEggLogic.is_locked() then
		print("[SGE] SendHit failed: locked")
		return
	end

	ShatterGoldenEggLogic.lock()
	--log("<color=yellow>config_idx:" .. config_idx .. ", slot_idx:" .. slot_idx .. "</color>")
	Network.SendRequest("zjd_kaijiang", {level = config_idx, egg_no = slot_idx})

	--[Test]
	--[[local data = {
		result = 0,
		level = config_idx,
		egg_no = slot_idx,
		hammer_num = math.random(0, 3),
		egg_status = math.random(2, 6)
	}
	print("[Debug] SGE SendHit hammer_num:" .. data.hammer_num)
	Event.Brocast("zjd_kaijiang_response", data)--]]
end

function ShatterGoldenEggLogic.handle_sge_hit(result)
	print("[Debug] SGE handle_sge_hit")
	ShatterGoldenEggLogic.unlock()

	Event.Brocast("view_sge_hit", result)
end

function ShatterGoldenEggLogic.handle_sge_hit_nomoney(showType)
	print("[Debug] SGE handle_sge_hit_nomoney")
	ShatterGoldenEggLogic.unlock()

	Event.Brocast("view_sge_hit_nomoney", showType)
end

function ShatterGoldenEggLogic.handle_sge_exception(code)
	print("[Debug] SGE handle_sge_exception:" .. code)
	ShatterGoldenEggLogic.unlock()

	Event.Brocast("view_sge_exception", code)
end

function ShatterGoldenEggLogic.SendRanking(tab_idx, page_idx, count)
	local stamp = model.getRankingStamp(tab_idx)
	if (os.time() - stamp) > 3 then
		--Network.SendRequest("sge_req_ranking", {tab_idx = tab_idx, page_idx = page_idx, count = count})

		--[Test]
		local result = nil
		
		if tab_idx == 1 then
			result = {
				tab_idx = tab_idx,
				page_idx = page_idx,
				count = 4,
				data = {
					{name = "嘻嘻嘻的名字", id = math.random(1, 100), count = math.random(1, 100)},
					{name = "嘻嘻嘻的名字", id = math.random(1, 100), count = math.random(1, 100)},
					{name = "嘻嘻嘻的名字", id = math.random(1, 100), count = math.random(1, 100)},
					{name = "嘻嘻嘻的名字", id = math.random(1, 100), count = math.random(1, 100)}
				}
			}
		elseif tab_idx == 2 then
			result = {
				tab_idx = tab_idx,
				page_idx = page_idx,
				count = 4,
				data = {
					{id = math.random(1, 100), count = math.random(1, 100)},
					{id = math.random(1, 100), count = math.random(1, 100)},
					{id = math.random(1, 100), count = math.random(1, 100)},
					{id = math.random(1, 100), count = math.random(1, 100)}
				}
			}
		end


		Event.Brocast("sge_req_ranking_response", result)
	end
end

function ShatterGoldenEggLogic.handle_sge_ranking(result)
	print("[Debug] SGE handle_sge_ranking")

	Event.Brocast("view_sge_ranking", result)
end

function ShatterGoldenEggLogic.handle_sge_giftbag_refresh(gift_id)
	dump(gift_id, "<color=red>[Debug] SGE handle_sge_giftbag_refresh</color>")
	if gift_id == 37 or gift_id == 36 then
		local config_idx = ShatterGoldenEggLogic.getHammerBySaleID(gift_id)
		if config_idx <= 0 then
			print("[Debug] SGE handle_sge_giftbag_refresh can't find item_id:" .. gift_id)
			return
		end

		local second = 0
		if MainModel.IsCanBuyGiftByID(gift_id) then
			local data = MainModel.GetGiftDataByID(gift_id)
			dump(data)
	        local permit_time = tonumber(data.permit_time) or 0
	        local permit_start_time = tonumber(data.permit_start_time) or 0
	        local permit_end_time = permit_time + permit_start_time
			second = math.max(0, permit_end_time - os.time())
		end

		ShatterGoldenEggLogic.SetHammerData(config_idx, "sale_countdown", second)
	end
end

function ShatterGoldenEggLogic.TweenDelay(callbacks, finally_callback)
	local traceTbl = {}

	local seq = DG.Tweening.DOTween.Sequence()
	local tweenKey = DOTweenManager.AddTweenToStop(seq)
	seq:OnKill(function()
		DOTweenManager.RemoveStopTween(tweenKey)

		for k, v in ipairs(traceTbl) do
			if not v then
				if callbacks[k].method then callbacks[k].method() end
			end
		end

		if finally_callback then finally_callback() end
	end)

	for k, v in ipairs(callbacks) do
		traceTbl[k] = false
		seq:AppendInterval(v.stamp):AppendCallback(function()
			traceTbl[k] = true
			if v.method then v.method() end
		end)
	end

	return tweenKey
end

function ShatterGoldenEggLogic.TweenFade(tran, value, inverse, period, callback, delay)
	if not IsEquals(tran) then return end

	local seq = DG.Tweening.DOTween.Sequence()
	local tweenKey = DOTweenManager.AddTweenToStop(seq)
	seq:OnKill(function ()
		DOTweenManager.RemoveStopTween(tweenKey)

		--if IsEquals(tran) then
		--	local image = tran:GetComponent("Image")
		--	image.color = Color.white
		--end

		if callback then callback() end
	end)

	if inverse then
		seq:Append(tran:DOFade(value, period):From())
	else
		seq:Append(tran:DOFade(value, period))
	end

	delay = delay or 0
	if delay > 0 then
		seq:AppendInterval(delay):AppendCallback(function()
			--delay
		end)
	end
end

function ShatterGoldenEggLogic.TweenLocalMove(tran, offset, inverse, period, callback, axis, delay)
	if not IsEquals(tran) then return end

	local seq = DG.Tweening.DOTween.Sequence()
	local tweenKey = DOTweenManager.AddTweenToStop(seq)
	seq:OnKill(function ()
		DOTweenManager.RemoveStopTween(tweenKey)

		if IsEquals(tran) then
			tran.localPosition = Vector3.zero
		end

		if callback then callback() end
	end)

	axis = axis or "x"
	if axis == "x" then
		if inverse then
			seq:Append(tran:DOLocalMoveX(offset, period):From())
		else
			seq:Append(tran:DOLocalMoveX(offset, period))
		end
	elseif axis == "y" then
		if inverse then
			seq:Append(tran:DOLocalMoveY(offset, period):From())
		else
			seq:Append(tran:DOLocalMoveY(offset, period))
		end
	else
		print("[SGE] TweenLocalMove axis is invalid:" .. axis)
	end

	delay = delay or 0
	if delay > 0 then
		seq:AppendInterval(delay):AppendCallback(function()
			--delay
		end)
	end
end

function ShatterGoldenEggLogic.FlyingToTarget(node, targetPoint, targetScale, interval, callback, delay)
	if not IsEquals(node) then
		if callback then callback() end
		return
	end

	local seq = DG.Tweening.DOTween.Sequence()
	local tweenKey = DOTweenManager.AddTweenToExit(seq)

	delay = delay or 0
	if delay > 0 then		
		seq:AppendInterval(delay)
	end

	seq:Append(node.transform:DOMoveBezier(targetPoint, 300, interval))

	targetScale = targetScale or 1
	if targetScale ~= 1 then
		seq:Join(node.transform:DOScale(targetScale, interval))
	end

	seq:OnKill(function ()
		DOTweenManager.RemoveExitTween(tweenKey)
		if callback then callback() end
	end)
end

local function Clone(tmpl, parent)
	if not tmpl then return nil end
	local go = GameObject.Instantiate(tmpl)
	go.transform.localPosition = Vector3.zero
	go.transform.localScale = Vector3.one
	go.transform:SetParent(parent)
	return go
end

local function RegisterPool(name, size)
	local parent = GameObject.Find("GameManager").transform
	if not IsEquals(parent) then
		print("[POOL] RegisterPool failed, parent is invalid:" .. name)
		return
	end

	local summary = objectPools.summary
	if summary.map[name] then
		print("[POOL] RegisterPool failed, repeat:" .. name)
		return
	end
	
	local tmpl = GetPrefab(name)
	if tmpl == nil then
		print("[POOL] RegisterPool failed, tmpl is nil:" .. name)
		return
	end
	tmpl.gameObject:SetActive(false)
	tmpl.transform:SetParent(parent)

	local pool = {
		["tmpl"] = tmpl,
		["cursor"] = size,
		["index"] = {},
		["objects"] = {}
	}
	for idx = 1, size, 1 do
		local go = Clone(tmpl, parent)
		--go.gameObject:SetActive(false)

		pool["objects"][idx] = go
		pool["index"][idx] = idx
	end

	summary.top = summary.top + 1
	summary.map[name] = summary.top
	objectPools.buckets[summary.top] = pool
end

local function Alloc(name)
	local go = nil

	local summary = objectPools.summary
	local bucket_idx = summary.map[name] or 0
	if bucket_idx <= 0 then
		return -1, Clone(GetPrefab(name))
	end
	
	local pool = objectPools.buckets[bucket_idx]
	if not pool then
		print("[POOL] Alloc failed, buckets is nil:" .. name .. ": " .. summary.map[name])
		return -1, Clone(GetPrefab(name))
	end

	local cursor = pool["cursor"] or 0
	if cursor <= 0 then
		return -1, Clone(pool["tmpl"])
	else
		local idx = cursor
		cursor = cursor - 1
		pool["cursor"] = cursor

		go = pool["objects"][pool["index"][idx]]
		if not IsEquals(go) then
			print("error:" .. debug.traceback())
		end
		go.gameObject:SetActive(true)

		print("分配:" .. name .. "," .. bucket_idx .. "," .. idx)

		return bucket_idx * MAX_RATE + idx, go
	end
end

local function Free(idx)
	local bucket_idx = math.floor(idx / MAX_RATE)
	local index = idx % MAX_RATE

	print("回收:" .. bucket_idx .. "," .. index)

	local pool = objectPools.buckets[bucket_idx]
	if not pool then
		print("[POOL] Free failed, pool is invalid:" .. idx)
		return
	end

	local cursor = pool["cursor"]
	cursor = cursor + 1
	if cursor > #pool["index"] then
		print("[POOL] Free failed, pool cursor overflow:" .. idx)
		return
	end

	pool["cursor"] = cursor
	pool["index"][cursor] = index

	go = pool["objects"][index]

	if IsEquals(go) then
		go.gameObject:SetActive(false)
	end
end

local function ResetPools()
	-- for _, v in pairs(objectPools.buckets) do
	-- 	for _, go in pairs(v["objects"]) do
	-- 		if IsEquals(go) then
	-- 			GameObject.Destroy(go.gameObject)
	-- 		end
	-- 	end
	-- 	v["tmpl"] = nil
	-- end
	-- objectPools = {}
end

function ShatterGoldenEggLogic.PreloadObject(name, size)
	RegisterPool(name, size)
end

function ShatterGoldenEggLogic.AllocObject(name)
	return Alloc(name)
end

function ShatterGoldenEggLogic.FreeObject(idx)
	Free(idx)
end

function ShatterGoldenEggLogic.FreeObjects()
	ResetPools()
end

return ShatterGoldenEggLogic
