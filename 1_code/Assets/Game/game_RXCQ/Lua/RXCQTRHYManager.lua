RXCQTRHYManager = {}
local C = RXCQTRHYManager
local _self = {}
local pos_config = {
	[1] = Vector3.New(-337,86),
	[2] = Vector3.New(-82,-182),
	[3] = Vector3.New(-386,-313),
	[4] = Vector3.New(-619,-20),
}
local TR_List = {}
--防止因为卡顿丢失关键的动画，导致界面卡死
local is_over = false
function C.Start(__self)
    _self = __self
	_self.playerAction.player.RXCQShowMoneyItem:ReSetMoney()
	_self.playerAction.player.RXCQShowMoneyItem:Show("trhy")
    local all_money = RXCQModel.game_data.award
    local all_money_list = RXCQNormalDie.get_money_num()
    dump(all_money_list,"<color=red>all_money_listall_money_list</color>")
	for i = 1,#pos_config do
		local tr = C.CreateTR(math.random(1,2),pos_config[i])
		tr.ChuanSong_func()
		TR_List[#TR_List + 1] = tr
	end
	local map = C.CreateHitMap()
	RXCQModel.DelayCall(
		function()
			C.StartHit(map,TR_List,all_money_list)
		end
	,1.5)
end

--创造天人
function C.CreateTR(sex,pos)
	local sex_config = {
		[1] = "RXCQ_FaShi_Nan",
		[2] = "RXCQ_FaShi_Nv",
	}
	local TR = {}
	local temp_ui = {}
	local prefab = GameObject.Instantiate(RXCQPrefabManager.Prefabs[sex_config[sex]],_self.player_node)
	local Animator = prefab:GetComponent("Animator")
	prefab.transform.localPosition = pos
	prefab.transform.localScale = Vector3.New(0.7,0.7,0.7)
	prefab.transform:SetSiblingIndex(4)
	LuaHelper.GeneratingVar(prefab.transform, temp_ui)
	TR.prefab = prefab
	local hit_func = function(backcall)
		RXCQModel.PlayAudioLimit("rxcq_bpcasting")
		prefab.gameObject:SetActive(false)
		prefab.gameObject:SetActive(true)
		Animator:Play(sex_config[sex].."_Hit")
		Animator.speed = 1.4
		temp_ui.node.gameObject:SetActive(true)
		TR.On_Hit = true
		RXCQModel.DelayCall(
			function()
				TR.On_Hit = false
				if backcall then
					backcall()
				end
			end
		,0.8)
		RXCQModel.DelayCall(
			function()
				TR.stand_func()
			end,0.9
		)
	end
	TR.hit_func = hit_func

	local stand_func = function()
		prefab.gameObject:SetActive(false)
		prefab.gameObject:SetActive(true)
		Animator:Play(sex_config[sex].."_Stand")
		Animator.speed = 1
		temp_ui.node.gameObject:SetActive(false)
	end
	TR.stand_func = stand_func

	local ChuanSong_func = function(backcall)
		RXCQModel.PlayAudioLimit("rxcq_trhy_ending")
		prefab:SetActive(false)
		local chuansong = GameObject.Instantiate(RXCQPrefabManager.Prefabs["chuanshongzhu"],prefab.transform)
		chuansong.transform.localPosition = Vector3.New(-61,-200)
		chuansong.transform.parent = prefab.transform.parent
		RXCQModel.DelayCall(function()
			chuansong:SetActive(false)
		end,3)
		RXCQModel.DelayCall(function()
			prefab:SetActive(true)
			if backcall then
				backcall()
			end
		end,1)
	end
	TR.ChuanSong_func = ChuanSong_func

	local Show_Over_func = function(backcall)
		TR.stand_func()
		local chuansong = GameObject.Instantiate(RXCQPrefabManager.Prefabs["chuanshong_xiaoshi"],prefab.transform)
		chuansong.transform.localPosition = Vector3.New(-61,-128)
		RXCQModel.PlayAudioLimit("rxcq_trhy_ending")
		RXCQModel.DelayCall(function()
			chuansong:SetActive(false)
			destroy(prefab)
		end,2)
		RXCQModel.DelayCall(function()
			prefab:SetActive(false)
			if backcall then
				backcall()
			end
		end,1)
	end
	TR.Show_Over_func = Show_Over_func

	stand_func()
	return TR
end

function C.CreateHitMap()
	local re = {}
	local index = 1
	for i = 1,#RXCQModel.game_data.monster do
		if RXCQModel.game_data.monster[i] > 0 then
			re[index] = re[index] or {}
			re[index][#re[index] + 1] = RXCQModel.game_data.monster[i]
		else
			index = index + 1
		end
	end
	return re
end

function C.StartHit(map,tr_list,all_money_list)
	local zero = RXCQNormalDie.get_zero_pos(RXCQGuaiWuManager.GetAllLiveGuaiWu())
	local temp_index = 1
	local create_pos_func = function()
		local pos_list_func = {}
		for i = 1,4 do
			local v = Vector3.New(zero.x + math.random(-200,200),zero.y + math.random(-200,200))
			pos_list_func[#pos_list_func + 1] = v
		end
		return pos_list_func
	end
	local guaiwu_list = {}
    for i = 1,#RXCQModel.game_data.monster do
        if RXCQModel.game_data.monster[i] > 0 then
            guaiwu_list[#guaiwu_list + 1] = RXCQModel.game_data.monster[i]
        end
    end
	local call = function(list)
		for i = 1,#list do
			local guaiwu = RXCQGuaiWuManager.GetGuaiWuByPos(list[i])
            if guaiwu then
				C.GuaiWuDie(guaiwu,list[i],all_money_list[temp_index],temp_index == #guaiwu_list)
				temp_index = temp_index + 1
				if temp_index > #guaiwu_list then
					RXCQModel.DelayCall(
						function()
							if is_over == false then
								is_over = true
								C.TRHYOver(
									function()
										_self.playerAction.player.RXCQShowMoneyItem:Hide()
										Event.Brocast("rxcq_call_next_anim")
									end
								)
							end
						end
					,5)
				end
            end			
		end
	end
	for i = 1,#map do
		RXCQModel.DelayCall(
			function()
				local pos_list_func = create_pos_func()
				for j = 1,#tr_list do
					tr_list[j].hit_func(
						function()
							RXCQModel.PlayAudioLimit("rxcq_bphit")
							local RXCQ_BPX_Item2 = GameObject.Instantiate(RXCQPrefabManager.Prefabs["RXCQ_BPX_Item2"],_self.guaiwu_node)
							RXCQ_BPX_Item2.transform:SetSiblingIndex(0)
							RXCQ_BPX_Item2.transform.localPosition = pos_list_func[j]
							GameObject.Destroy(RXCQ_BPX_Item2,0.9)
						end
					)
				end
				RXCQModel.DelayCall(function()
						call(map[i])
					end,0.8
				)
			end,
		(i - 0.99) * 2)
	end
end

function C.GuaiWuDie(guaiwu,guaiwu_pos,money,is_last)
    dump(money,"<color=red>总价格</color>")
	is_over = false
    guaiwu:Hit(function()
        guaiwu:Death(
            function()
                local map = RXCQNormalDie.create_jb_map(guaiwu,guaiwu_pos)
                local zero = RXCQNormalDie.get_zero_pos({guaiwu})
                local money_list = RXCQNormalDie.get_one_guaiwu_money_list(guaiwu_pos,money)
                local t = 0
                for i = 1,#money_list do
                    t = t + money_list[i] 
                end
                dump(t,"<color=red>总价格的和</color>")
                local max_finsh = #money_list
                local finsh_index = 0
                for i = 1,#money_list do
                    local b = RXCQMoneyItem.Create(_self.guaiwu_node,money_list[i],RXCQFightPrefab.player_zero_pos,
                        function()
                            finsh_index = finsh_index + 1
                            if finsh_index == max_finsh then
                                _self.playerAction.player.RXCQShowMoneyItem:DoPopAnim(money,is_last,
									function()
										is_over = true
										C.TRHYOver(
											function()
												_self.playerAction.player.RXCQShowMoneyItem:Hide()
												Event.Brocast("rxcq_call_next_anim")
											end
										)
									end
								)
                            end                        
                        end,
                    Vector3.New(map[i].x,map[i].y,0))
                    b.transform.localPosition = zero
                    b.transform:SetSiblingIndex(0)
                end
                local new_guaiwu = RXCQGuaiWuManager.CreateGuaiWu(nil,guaiwu_pos)
                new_guaiwu:ShowChuanSong(
                    function()
                        new_guaiwu:Stand()
                    end
                )
                end      
            ,2)
    end)
end

function C.TRHYOver(backcall)
	for i = 1,#TR_List  do
		TR_List[i].Show_Over_func()
	end
	TR_List = {}
	RXCQModel.DelayCall(
		function()
			RXCQMiniGameDie.ReSetUI(backcall)
		end
	,2)
end

function C.ForceOver()
	for i = 1,#TR_List do
		destroy(TR_List[i].prefab)
	end
end