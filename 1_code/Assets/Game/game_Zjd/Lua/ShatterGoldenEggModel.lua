local basefunc = require "Game.Common.basefunc"

package.loaded["Game.game_Zjd.Lua.ShatterGoldenEggConfig"] = nil
local config = require "Game.game_Zjd.Lua.ShatterGoldenEggConfig"

package.loaded["Game.game_Zjd.Lua.zajindan_service"] = nil
local data_config = require "Game.game_Zjd.Lua.zajindan_service"


ShatterGoldenEggModel = {}

local this 
local lister = {}
local dataTbl = {}
local realDataTbl = {}
local extra2EggsTbl = {}

local rankingTbl = {}

local function MakeLister()
	lister={}
	lister["zjd_get_game_status_response"] = ShatterGoldenEggModel.handle_status_response
	lister["zjd_replace_hammer_response"] = ShatterGoldenEggModel.handle_hammer_response
	lister["zjd_replace_eggs_response"] = ShatterGoldenEggModel.handle_spawn_response
	lister["zjd_kaijiang_response"] = ShatterGoldenEggModel.handle_hit_response

	lister["sge_req_ranking_response"] = ShatterGoldenEggModel.handle_ranking_response
	lister["main_change_gift_bag_data_msg"] = ShatterGoldenEggModel.handle_gift_bag_status_change
	lister["main_query_gift_bag_data_msg"] = ShatterGoldenEggModel.handle_gift_bag_status_response
end

local function AddMsgListener(lister)
	if lister then
	    for proto_name,func in pairs(lister) do
	        Event.AddListener(proto_name, func)
	    end
	end
end

local function RemoveMsgListener(lister)
	if lister then
	    for proto_name,func in pairs(lister) do
	        Event.RemoveListener(proto_name, func)
	    end
	end
end

function ShatterGoldenEggModel.Init()
	ShatterGoldenEggModel.Exit()
	this = ShatterGoldenEggModel

	MakeLister()
	AddMsgListener(lister)

	dataTbl = {}
	rankingTbl = {}
	realDataTbl = {}
	extra2EggsTbl = {}
	
	return this
end

function ShatterGoldenEggModel.Exit()
	if this then
		RemoveMsgListener(lister)
		dataTbl = {}
		rankingTbl = {}
		realDataTbl = {}
		extra2EggsTbl = {}

		this = nil
	end
end

function ShatterGoldenEggModel.handle_status_response(msg,result)
	dump(result,"<color=yellow>------------  handle_status_response</color>")
	if result.result ~= 0 then
		print("[SGE] handle_status_response exception:" .. result.result)
		HintPanel.ErrorMsg(result.result)
		Event.Brocast("model_sge_exception", result.result)
		return
	end

	local status_data = result.status or {}
	local config_idx = status_data.now_level or 1
	local detail_status = status_data.status or {}

	for k, v in pairs(detail_status) do
		local level = v.level
		local base_money = v.base_money
		local eggs_status = v.eggs_status
		local award_list = v.award_list
		local replace_money = v.replace_money

		local data = dataTbl[level] or {}
		data.base_money = base_money
		data.replace_money = replace_money
		data.state = eggs_status
		data.award = award_list
		dataTbl[level] = data
	end

	realDataTbl = basefunc.deepcopy(dataTbl)

	Event.Brocast("model_sge_status", config_idx)
end

function ShatterGoldenEggModel.handle_hammer_response(msg,result)
	dump(result,"<color=yellow>------------  handle_hammer_response</color>")
	if result.result ~= 0 then
		print("[SGE] handle_hammer_response exception:" .. result.result)
		HintPanel.ErrorMsg(result.result)
		Event.Brocast("model_sge_exception", result.result)
		return
	end

	local config_idx = result.level
	local hammerId = ShatterGoldenEggModel.GetHammerIdxByPlayerMoney()
	if ShatterGoldenEggLogic.GetOverrideHammer() < 0 and hammerId and hammerId ~= config_idx then
		log("<color=yellow>--->>>auto select hammer:" .. hammerId .. "</color>")
		ShatterGoldenEggLogic.SendHammer(hammerId)
	else
		Event.Brocast("model_sge_hammer", config_idx)
	end
end

function ShatterGoldenEggModel.handle_spawn_response(msg,result)
	dump(result,"<color=yellow>------------  handle_spawn_response</color>")
	print("[Debug] handle_spawn_response")

	if result.result ~= 0 then
		print("[SGE] handle_spawn_response exception:" .. result.result)
		HintPanel.ErrorMsg(result.result)
		Event.Brocast("model_sge_exception", result.result)
		return
	end

	local stateConfig = ShatterGoldenEggModel.getStateConfig()

	local config_idx = result.level
	local award = result.award_list or {}
	if #award <= 0 then
		print("[SGE] handle_spawn_response award_list is empty:" .. config_idx)
		return
	end
	--��һ������Ǯ;��һ�µ��������һ������Ǯ�����
	local replace_money = result.replace_money

	local data = dataTbl[config_idx] or {}
	data.award = award
	data.state = {}
	for idx = 1, #award, 1 do
		data.state[idx] = stateConfig.STAND
	end
	data.replace_money = replace_money

	dataTbl[config_idx] = data
	if #award == 12 then
		realDataTbl[config_idx] = basefunc.deepcopy(dataTbl[config_idx])
	end

	Event.Brocast("model_sge_spawn", config_idx)
end

function ShatterGoldenEggModel.handle_hit_response(msg,result)
	dump(result,"<color=yellow>------------  handle_hit_response</color>")
	print("[Debug] handle_hit_response")

	--��ע:4600��4601Ϊ��ʱ������ui�޼�
	if result.result ~= 0 then
		if result.result == 1023 then		--���Ҳ���
			Event.Brocast("model_sge_hit_nomoney", 1)
			return
		elseif result.result == 4601 then	--钱不够，弹出限时特惠
			Event.Brocast("model_sge_hit_nomoney", 1)
			return
		elseif result.result == 4600 then	--够敲这一锤，但没中奖，敲完后钱不够，弹出限时特惠
			Event.Brocast("model_sge_hit_nomoney", 1)
		else					--��������
			-- HintPanel.ErrorMsg(result.result)
			Event.Brocast("model_sge_exception", result.result)
			return
		end
	end

	local syncData = true
	if result.egg_no and result.egg_no > 100 then
		result.egg_no = ShatterGoldenEggLogic.ConvertEgg2IDFromS2C(result.egg_no)

		--result.egg_no = result.egg_no - 100
		result.replace_money = ShatterGoldenEggModel.getReplaceMoney(result.level)
		syncData = false
	end

	if result.kaijiang and #result.kaijiang > 0 then
		for i = 1, #result.kaijiang do
			if result.kaijiang[i].egg_no > 100 then
				result.kaijiang[i].egg_no = ShatterGoldenEggLogic.ConvertEgg2IDFromS2C(result.kaijiang[i].egg_no)

				--result.kaijiang[i].egg_no = result.kaijiang[i].egg_no - 100
				syncData = false
			end
		end
	end

	local config_idx = result.level
	local slot_idx = result.egg_no
	local state = result.egg_status
	local replace_money = result.replace_money
	local kaijiang = result.kaijiang
	
	--[[
	status $ : integer            #0��ʾ��ͨ 1-N��ʾ����Ŀ���
	zjd_kaijiang_result {
		egg_no $  : integer
		award $ : integer             # ����id
		award_value $ : integer       # ���� ����
	}
	]]--

	--if kaijiang ~= nil then
	--	print("award:" .. data_config.award[kaijiang.award].name)
	--end

	local data = dataTbl[config_idx]
	if not data then
		print("[SGE] handle_hit_response failed: data is invalid:" .. config_idx)
		return
	end
	data.state[slot_idx] = state
	data.replace_money = replace_money

	if syncData then
		realDataTbl[config_idx] = basefunc.deepcopy(dataTbl[config_idx])
	end

	Event.Brocast("model_sge_hit", result)
end

function ShatterGoldenEggModel.handle_ranking_response(msg,result)
	dump(result,"<color=yellow>------------  handle_ranking_response</color>")
	local tab_idx = result.tab_idx
	local page_idx = result.page_idx
	local count = result.count
	local data = result.data

	print("tab_idx:" .. tab_idx .. ", page_idx:" .. page_idx .. ", count:" .. count)

	local rankingData = rankingTbl[tab_idx] or {}
	rankingData.data = rankingData.data or {}

	local base_idx = #rankingData.data
	for i = 1, count, 1 do
		data[i].text = string.format("%s_%d", data[i].text, base_idx + i)
		rankingData.data[#rankingData.data + 1] = data[i]
	end
	rankingTbl[tab_idx] = rankingData

	if #rankingData == count then
		rankingData.stamp = os.time()
	end

	Event.Brocast("model_sge_ranking", result)
end

function ShatterGoldenEggModel.handle_gift_bag_status_change(gift_id)
	dump(gift_id,"<color=yellow>------------  handle_gift_bag_status_change</color>")

	Event.Brocast("model_sge_giftbag_refresh", gift_id)
end

function ShatterGoldenEggModel.handle_gift_bag_status_response(gift_id)
	dump(gift_id,"<color=yellow>------------  handle_gift_bag_status_response</color>")
	
	Event.Brocast("model_sge_giftbag_refresh", gift_id)
end

function ShatterGoldenEggModel.getConfig()
	return config
end

function ShatterGoldenEggModel.getHammerNormalConfig()
	return data_config.hammer
end

function ShatterGoldenEggModel.getHammer2EggConfig()
	return config.extra2eggs
end

function ShatterGoldenEggModel.getAwardConfig()
	return data_config.award
end

function ShatterGoldenEggModel.getLogicConfig(idx)
	idx = idx or -1
	if idx <= 0 then
		return config.logics
	else
		return config.logics[idx]
	end
end

function ShatterGoldenEggModel.getStateConfig()
	return config.state
end

function ShatterGoldenEggModel.getAward(idx)
	if not dataTbl[idx] then return nil end
	return dataTbl[idx].award
end

function ShatterGoldenEggModel.SetAward(idx, award)
	if not dataTbl[idx] then return end
	dataTbl[idx].award = award
end

function ShatterGoldenEggModel.getStates(idx)
	if not dataTbl[idx] then return nil end
	return dataTbl[idx].state
end

function ShatterGoldenEggModel.getState(idx, slot_idx)
	if not dataTbl[idx] then return -1 end
	return dataTbl[idx].state[slot_idx] or -1
end

function ShatterGoldenEggModel.setState(idx, slot_idx, state)
	if not dataTbl[idx] then return end
	dataTbl[idx].state[slot_idx] = state
end

function ShatterGoldenEggModel.setStates(idx, states)
	if not dataTbl[idx] then return end
	dataTbl[idx].state = states
end

function ShatterGoldenEggModel.setExtra2EggsData(k, v)
	extra2EggsTbl[k] = v
	dump(extra2EggsTbl,"<color=red>--------------setExtra2EggsData-----------------</color>")
end

function ShatterGoldenEggModel.getExtra2EggsData(k)
	return extra2EggsTbl[k]
end

function ShatterGoldenEggModel.RecoveryData(idx)
	idx = idx or -1
	if idx <= 0 then
		dataTbl = basefunc.deepcopy(realDataTbl)
	else
		dataTbl[idx] = dataTbl[idx] or {}
		dataTbl[idx] = basefunc.deepcopy(realDataTbl[idx] or {})
	end
end

function ShatterGoldenEggModel.getHammerCount(idx)
	local HAMMER_TBL = {
		"prop_hammer_1", "prop_hammer_2", "prop_hammer_3", "prop_hammer_4"
	}
	return MainModel.UserInfo[HAMMER_TBL[idx]] or 0
end

function ShatterGoldenEggModel.getReplaceMoney(idx)
	if dataTbl and dataTbl[idx] then
		return dataTbl[idx].replace_money
	end
end

function ShatterGoldenEggModel.getBaseMoney(idx, isCSMode)
	if isCSMode then
		-- local mode_idx = ShatterGoldenEggModel.getExtra2EggsData("mode_idx") or 0
		-- local money = 0
		-- if mode_idx == 1 then
		-- 	money = config.extra2eggs[math.min(6,idx + 3)].base_money or 0
		-- else
		-- 	money = config.extra2eggs[idx].base_money or 0
		-- end

		-- return money
		return  ShatterGoldenEggModel.getConfig().extra2eggs[idx].base_money
	else
		if dataTbl[idx] then
			return dataTbl[idx].base_money
		else
			return 0
		end
	end
end

function ShatterGoldenEggModel.getRankingStamp(index)
	local rankingData = rankingTbl[index] or {}
	return rankingData.stamp or 0
end

function ShatterGoldenEggModel.checkRanking(index, page, interval)
	local rankingData = rankingTbl[index]
	if not rankingData or not rankingData.data then return false end

	interval = interval or 0
	if interval <= 0 then
		return true, rankingData.data
	end

	local diff = os.time() - rankingData.stamp
	return diff < interval, rankingData.data
end

function ShatterGoldenEggModel.GetHammerIdxByPlayerMoney()
	local id
	if SG_Config.AutoSelHammerOnEnter and not ShatterGoldenEggModel.IsInited then
		local myMoney = MainModel.GetItemCount("jing_bi")
		for i, cfg in ipairs(data_config.hammer) do
			if myMoney < cfg.auto_select_max_money or cfg.auto_select_max_money == -1 then
				id = i
				break
			end
		end
		ShatterGoldenEggModel.IsInited = true
	end
	return id
end

function ShatterGoldenEggModel.SetHitEggCount(n)
	if n and type(n) == "number" then
		for _, l in ipairs(config.logics) do
			l.respawn = n
		end
	end
end

function ShatterGoldenEggModel.GetActivityState(mode)
	local ret = 0
	if mode and data_config.activity_config then
		local curT = os.time()
		for _, cfg in ipairs(data_config.activity_config) do
			if cfg.mode == mode then
				if curT >= cfg.start_time and curT <= cfg.end_time then
					ret = 1
				elseif curT > cfg.end_time and curT <= cfg.over_time then
					ret = 2
				end
				break
			end
		end
	end
	return ret
end

function ShatterGoldenEggModel.GetActivityConfig(mode)
	if mode and data_config.activity_config then
		local curT = os.time()
		for _, cfg in ipairs(data_config.activity_config) do
			if cfg.mode == mode then
				return cfg
			end
		end
	end
end
