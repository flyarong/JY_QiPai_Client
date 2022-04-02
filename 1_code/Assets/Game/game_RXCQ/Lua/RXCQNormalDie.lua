RXCQNormalDie = {}
local C = RXCQNormalDie
local _self = {}

local jing_ying = {
	x = 4,
	y = 4,
	min = 6,
	max = 16,
}
local pu_tong = {
	x = 3,
	y = 3,
	min = 2,
	max = 6,
}
local boss = {
	x = 4,
	y = 4,
	min = 3,
	max = 8,
}

local create_gold_pos = function(x_max,y_max,zero_pos)
	local x_spcae = 100
	local y_space = 100
	local map = {}
	for j = 1,y_max do
		for i = 1,x_max do
			local v = {x = (i - 1) * x_spcae + zero_pos.x - x_spcae * x_max / 2,y = (1 - j) * y_space + zero_pos.y + y_space * y_max / 2}
			map[#map + 1] = v
		end
	end
	return map
end
C.create_gold_pos = create_gold_pos

local get_zero_pos = function(guaiwu_pos_list)
	local v = {x = 0,y = 0,z = 0}
	for i = 1,#guaiwu_pos_list do
		local pos = guaiwu_pos_list[i].transform.localPosition
		v = {x = v.x + pos.x,y = v.y + pos.y,z = v.z + pos.z}
	end
	v = {x = v.x / #guaiwu_pos_list,y = v.y / #guaiwu_pos_list,z = v.z / #guaiwu_pos_list}
	return v
end
C.get_zero_pos = get_zero_pos

--打乱
local romdomlist = function(list)
	for i = 1,#list do
		local r = math.random(1,#list)
		list[i],list[r] = list[r],list[i]
	end
	return list
end
C.romdomlist = romdomlist

local fen_jingbi = function(min,max,all,lengh)
	local re = {}
	local all_money = all
	local max_num = math.random(min,max)
	local max_value = math.floor(all_money * 0.3)
	local remain_value = all_money - max_value
	local sum = 0
	for i = 1,max_num do
		local d = math.floor(max_value / max_num)
		sum = sum + d
		re[#re + 1] = d
	end
	local remain_num = lengh - max_num
	local org = math.floor(remain_value / remain_num)
	for i = #re + 1,lengh - 1 do
		re[#re + 1] = org
		sum = sum + org
	end
	local remain = all_money - sum
	re[#re + 1] = remain
	re = romdomlist(re)
	return re
end
C.fen_jingbi = fen_jingbi

function C.all_die_gold(GuaiWu_List)
	--当全部怪物死亡
	local zero = get_zero_pos(GuaiWu_List or RXCQGuaiWuManager.GetAllLiveGuaiWu())
	local map = create_gold_pos(8,6,Vector3.New(zero.x,zero.y - 100))
	local gold = C.get_all_die_gold()
	for i = 1,#map do
		local b = RXCQMoneyItem.Create(_self.guaiwu_node,gold[i],RXCQFightPrefab.player_zero_pos,nil,Vector3.New(map[i].x,map[i].y,0))
		b.transform.localPosition = zero
		b.transform:SetSiblingIndex(0)
		_self.JingBiItem[#_self.JingBiItem + 1] = b
	end
end

function C.GetGuaiWuNum()
	local guaiwu_num = 0
    for i = 1,#RXCQModel.game_data.monster do
        if RXCQModel.game_data.monster[i] > 0 then
            guaiwu_num = guaiwu_num + 1
        end
    end
	return guaiwu_num
end
--判断当前场次的当前位置的怪物是什么级别的怪物
function C.GetCurrGuaiwuLevel(pos_index)
	local map = {
		[1] = "boss",
		[2] = "jing_ying",
		[4] = "pu_tong",
	}
	local config = rxcq_main_config.base[RXCQModel.BetIndex].GuaiWu_Map
	local max = 0
	local value = config[pos_index]
	for i = 1,#config do
		if value == config[i] then
			max = max + 1
		end
	end
	return map[max]
end

function C.get_money_num()
	local _max = 0
	local quanzhong = {
		boss = 5,
		jing_ying = 2,
		pu_tong = 1,
	}
	for i = 1,#RXCQModel.game_data.monster do
		if RXCQModel.game_data.monster[i] > 0 then
			local l = C.GetCurrGuaiwuLevel(RXCQModel.game_data.monster[i])
			_max = _max + quanzhong[l]
		end
	end
	--获取一个怪物最多分配多少金币
	local all_money_list = {}
	local sum = 0
	local guaiwu_num = C.GetGuaiWuNum()
	for i = 1,#RXCQModel.game_data.monster do
		if RXCQModel.game_data.monster[i] > 0 then
			local l = C.GetCurrGuaiwuLevel(RXCQModel.game_data.monster[i])
 			local num = math.floor(RXCQModel.game_data.award * quanzhong[l] / _max)
			if #all_money_list == guaiwu_num - 1 then
				all_money_list[#all_money_list + 1] = RXCQModel.game_data.award - sum
			else
				all_money_list[#all_money_list + 1] = num
				sum = sum + num
			end
		end
	end
	return all_money_list
end

function C.get_guaiwu_money_map()
	local all_money_list = C.get_money_num()
	dump(all_money_list,"<color=red>每个怪物分配的鲸币数量</color>")
	--随机每一个怪物分成多少堆
	local guai_num_map = {}

	for i = 1,#RXCQModel.game_data.monster do
		if RXCQModel.game_data.monster[i] > 0 then
			local d = C.get_one_guaiwu_money_list(RXCQModel.game_data.monster[i],all_money_list[i])
			guai_num_map[RXCQModel.game_data.monster[i]] = d
		end
	end
	dump(guai_num_map,"<color=red>每个死亡怪物分配的鲸币，再将这些鲸币如何分成堆</color>")
	return guai_num_map
end

function C.get_one_guaiwu_money_list(guaiwu_pos,all_money)
	local l = C.GetCurrGuaiwuLevel(guaiwu_pos)
	local d = {}
	if l == "jing_ying" then
		d = fen_jingbi(1,2,all_money,math.random(jing_ying.min,jing_ying.max))
	elseif l == "pu_tong" then
		d = fen_jingbi(1,2,all_money,math.random(pu_tong.min,pu_tong.max))
	elseif l == "boss" then
		d = fen_jingbi(1,2,all_money,math.random(boss.min,boss.max))
	end
	return d
end

function C.create_jb_map(guaiwu,guaiwu_pos)
	local zero = get_zero_pos({guaiwu})
	local l = C.GetCurrGuaiwuLevel(guaiwu_pos)
	local map = {}
	if l == "jing_ying" then
		map = create_gold_pos(jing_ying.x,jing_ying.y,Vector3.New(zero.x - 50,zero.y - 100,0))
	elseif l == "pu_tong" then
		map = create_gold_pos(pu_tong.x,pu_tong.y,Vector3.New(zero.x - 50,zero.y - 100,0))
	elseif  l == "boss" then
		map = create_gold_pos(boss.x,boss.y,Vector3.New(zero.x - 50,zero.y - 100,0))
	end
	dump(l,"<color=red>怪物死亡的等级</color>")
	dump(map,"<color=red>怪物死亡掉落地图</color>")
	return map
end

function C.guaiwu_die(dead_list,get_guaiwu_money_map)
	local get_guaiwu_money_map = get_guaiwu_money_map or C.get_guaiwu_money_map()
	dump(get_guaiwu_money_map,"<color=red>每个死亡怪物分配的鲸币，再将这些鲸币如何分成堆</color>")
	dead_list = dead_list or RXCQModel.game_data.monster
	for i = 1,#dead_list do
		if dead_list[i] > 0 then
			local map = C.create_jb_map(RXCQGuaiWuManager.GetGuaiWuByPosliveOrDie(dead_list[i]),dead_list[i])
			local zero = get_zero_pos({RXCQGuaiWuManager.GetGuaiWuByPosliveOrDie(dead_list[i])})
			for j = 1,#get_guaiwu_money_map[dead_list[i]] do
				local b = RXCQMoneyItem.Create(_self.guaiwu_node,get_guaiwu_money_map[dead_list[i]][j],RXCQFightPrefab.player_zero_pos,nil,Vector3.New(map[j].x,map[j].y,0))
				b.transform.localPosition = zero
				b.transform:SetSiblingIndex(0)
				_self.JingBiItem[#_self.JingBiItem + 1] = b
			end
		end
	end
end
--获取一个长度为48的鲸币列表，综合为奖励，其中有30%左右的奖励集中在1~2个堆堆上
function C.get_all_die_gold()
	return fen_jingbi(1,2,RXCQModel.game_data.award,48)
end

function C.Die(__self,dead_list,get_guaiwu_money_map,att_over)
	local GuaiWu_List = RXCQGuaiWuManager.GetAllLiveGuaiWu()
	dead_list = dead_list or RXCQModel.game_data.monster
	_self = __self
	local first_hit = true
	local first_die = true
	if #dead_list > 0 then
		GuaiWu_List[1]:PlayHitSound()
	end
	local is_dead = function(GuaiWu)
		for i = 1,#dead_list do
			if GuaiWu.pos == dead_list[i] then
				return true
			end 
		end
		return false
	end
	for i = 1,#GuaiWu_List do
		GuaiWu_List[i]:Hit(
		function()
			if first_hit then
				local zero
				if #dead_list == 0 then
					zero = get_zero_pos(GuaiWu_List)
				else
					local guaiwu = {}
					for i = 1,#dead_list do
						guaiwu[#guaiwu + 1] = RXCQGuaiWuManager.GetGuaiWuByPosliveOrDie(dead_list[i])
					end
					zero = get_zero_pos(guaiwu)
					guaiwu = nil
				end
				--miss
				if #RXCQModel.game_data.monster == 0 then
					local b = newObject("RXCQMiss",_self.guaiwu_node)
					b.transform.localPosition = zero
					GameObject.Destroy(b,1)
				else
					local rate = RXCQModel.GetBaoJiRate()
					if rate > 0 then
						local b = newObject("RXCQBaoJi",_self.guaiwu_node)
						b.transform:Find("Text"):GetComponent("Text").text = "x"..rate + 1
						b.transform.localPosition = zero
						GameObject.Destroy(b,1)
					end
				end
				if att_over then
					local seq = DoTweenSequence.Create({dotweenLayerKey = M.key})			
					seq:AppendInterval(1)
					seq:Append(_self.playerAction.player.transform:DOLocalMove(RXCQFightPrefab.backup_player_zero_pos,0.1):SetEase(DG.Tweening.Ease.Linear))	
					seq:AppendCallback(
						function()
							_self.playerAction:Stand()
							--miss特殊处理
							if #RXCQModel.game_data.monster == 0 then
								Event.Brocast("rxcq_moneyitem_fly_over",{money = 0})
							end
						end
					)
				end
				first_hit = false
			end	
			if is_dead(GuaiWu_List[i]) then
				GuaiWu_List[i]:Death(
					function()
						if first_die then		
							if #RXCQModel.game_data.monster < 8  then
								if #dead_list == 7 then
									C.all_die_gold(GuaiWu_List)
								else
									C.guaiwu_die(dead_list,get_guaiwu_money_map)
								end
							else
							end
							first_die = false
						end
					end
				,1.5 * RXCQModel.GetAutoSpeed())
			else
				GuaiWu_List[i]:Stand()
			end
		end)
	end
end