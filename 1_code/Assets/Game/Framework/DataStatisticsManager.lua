-- 数据统计 创建时间:2019-07-11
local basefunc=require "Game.Common.basefunc"
DSM = {}
local M = DSM
local on_off_pay = true
local on_off_ad = true
local is_pay = 0 --是否完成了一次购买
M.player_act = {}

--统计类型
M.TYPE = {
	pay = "pay",	--付费
	consume = "consume",	--消费
	ad_trigger = "ad_trigger", --广告触发
	ad_show = "ad_show",	--广告播放
}

function M.Init()
	if not on_off_pay then return end
	if not MainModel.UserInfo or not MainModel.UserInfo.user_id then return end
	is_pay = PlayerPrefs.GetInt("DataStatisticsPay" .. MainModel.UserInfo.user_id, 0)
end

-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
--玩家行为记录 scene panel button
function M.PushAct(data)
	if not on_off_pay then return end
	if data.scene then
		M.player_act = M.player_act or {}
		table.insert(M.player_act, data)
	elseif data.panel then
		M.player_act = M.player_act or {}
		if not next(M.player_act) then
			table.insert( M.player_act,MainLogic.GetCurSceneName())
		end
		local a_c = #M.player_act
		M.player_act[a_c].panel = M.player_act[a_c].panel or {}
		local p_c = #M.player_act[a_c].panel
		if M.player_act[a_c].panel[p_c] and next(M.player_act[a_c].panel[p_c]) then
			data.pre_panel = M.player_act[a_c].panel[p_c].panel
		end
		table.insert(M.player_act[a_c].panel, data)
	elseif data.button then
		M.player_act = M.player_act or {}
		if not next(M.player_act) then
			table.insert( M.player_act,MainLogic.GetCurSceneName())
		end
		local a_c = #M.player_act
		M.player_act[a_c].panel = M.player_act[a_c].panel or {}
		if not next(M.player_act[a_c].panel) then
			table.insert( M.player_act[a_c].panel,{panel = "panel"})
		end
		local p_c = #M.player_act[a_c].panel
		M.player_act[a_c].panel[p_c].button = M.player_act[a_c].panel[p_c].button or {}
		table.insert(M.player_act[a_c].panel[p_c].button, data.button)
	elseif data.info then
		M.player_act = M.player_act or {}
		if not next(M.player_act) then
			table.insert( M.player_act,MainLogic.GetCurSceneName())
		end
		local a_c = #M.player_act
		M.player_act[a_c].panel = M.player_act[a_c].panel or {}
		if not next(M.player_act[a_c].panel) then
			table.insert( M.player_act[a_c].panel,{panel = "panel"})
		end
		local p_c = #M.player_act[a_c].panel
		M.player_act[a_c].panel[p_c].info = M.player_act[a_c].panel[p_c].info or {}
		table.insert(M.player_act[a_c].panel[p_c].info, data.info)
	end
	dump(M.player_act, "<color=white>PushAct player_act</color>")
end

--返回前一个panel，在弹出界面关闭时调用，这里不是删除而是重载入前一个panel
function M.PopAct()
	if not on_off_pay then return end
	M.player_act = M.player_act or {}
	if not next(M.player_act) then
		table.insert( M.player_act,MainLogic.GetCurSceneName())
	end
	M.player_act[#M.player_act].panel = M.player_act[#M.player_act].panel or {}
	local a_c = #M.player_act
	local p_c = #M.player_act[a_c].panel
	if M.player_act[a_c].panel[p_c] and next(M.player_act[a_c].panel[p_c]) and M.player_act[a_c].panel[p_c].pre_panel then
		local pre_panel = M.player_act[a_c].panel[p_c].pre_panel
		local v
		for i=#M.player_act[a_c].panel,1,-1 do
			v = M.player_act[a_c].panel[i]
			if v.panel == pre_panel then
				table.insert(M.player_act[a_c].panel, basefunc.deepcopy(v))
				break
			end
		end
	end
	dump(M.player_act, "<color=white>PopAct player_act</color>")
end

--检查panel中的最后一次button点击
function M.check_top_button_in_panel(p_name,b_name)
	local a_c = #M.player_act
	local p_c = #M.player_act[a_c].panel
	local v
	for i=p_c,1,-1 do
		v = M.player_act[a_c].panel[i]
		if v.panel == p_name then
			if not table_is_null(v.button) then
				local btn = v.button[#v.button]
				if btn == b_name then
					return true
				end
			end
		end					
	end
end

--Get panel中的最后一个info
function M.get_top_info_in_panel(p_name)
	local a_c = #M.player_act
	local p_c = #M.player_act[a_c].panel
	local v
	for i=p_c,1,-1 do
		v = M.player_act[a_c].panel[i]
		if v.panel == p_name then
			if not table_is_null(v.info) then
				return v.info[#v.info]
			end
		end					
	end
end

function M.get_info_in_panel(p_name)
	local a_c = #M.player_act
	local p_c = #M.player_act[a_c].panel
	local v
	for i=p_c,1,-1 do
		v = M.player_act[a_c].panel[i]
		if v.panel == p_name then
			if not table_is_null(v.info) then
				return v.info
			end
		end					
	end
end
--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

function M.data_statistics(cur_s,cur_p,_type,get_fun)
	if not cur_s or not cur_p or not _type or not get_fun then return end
	local content = get_fun(cur_s, cur_p, _type)
	if content then
		dump({type =_type,content = content},"<color=white>付费数据统计>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>></color>")
		Network.SendRequest("data_statistics", {type = _type,content = content},"付费数据")
		return true
	end
end

--付费统计----------------------------
--充值
function M.Pay(data)
	if not on_off_pay then return end
	is_pay = 1
	PlayerPrefs.SetInt("DataStatisticsPay" .. MainModel.UserInfo.user_id, is_pay)
	dump(data, "<color=white>付费统计————————————————————————————————————————————</color>")
	dump(M.player_act, "<color=white>PushAct player_act</color>")
	if table_is_null(M.player_act) then return end
	local a_c = #M.player_act
	if not M.player_act[a_c].scene then return end
	if table_is_null(M.player_act[a_c].panel) then return end

	local p_c = #M.player_act[a_c].panel
	local cur_s = M.player_act[a_c].scene
	local cur_p = M.player_act[a_c].panel[p_c]
	if not cur_p.panel then return end

	local _type =  M.TYPE.pay
	if M.data_statistics(cur_s,cur_p,_type,M.get_vip_up_content) then return end
	if M.data_statistics(cur_s,cur_p,_type,M.get_hall_content_pay) then return end
	if M.data_statistics(cur_s,cur_p,_type,M.get_free_content) then return end
	if M.data_statistics(cur_s,cur_p,_type,M.get_eliminate_content) then return end
	if M.data_statistics(cur_s,cur_p,_type,M.get_eliminate_sh_content) then return end
	if M.data_statistics(cur_s,cur_p,_type,M.get_qql_content) then return end
	if M.data_statistics(cur_s,cur_p,_type,M.get_qql_cs_content) then return end
	if M.data_statistics(cur_s,cur_p,_type,M.get_fishing_content) then return end
	if M.data_statistics(cur_s,cur_p,_type,M.get_fishing_match_content) then return end
	if M.data_statistics(cur_s,cur_p,_type,M.get_fishing_dr_content) then return end
	if M.data_statistics(cur_s,cur_p,_type,M.get_minigame_hall_content_pay) then return end
	if M.data_statistics(cur_s,cur_p,_type,M.get_qys_content_pay) then return end
end

--消费
function M.Consume(data)
	if not on_off_pay then return end
	is_pay = PlayerPrefs.GetInt("DataStatisticsPay" .. MainModel.UserInfo.user_id,0)
	if is_pay == 0 then return end
	is_pay = 0
	PlayerPrefs.SetInt("DataStatisticsPay" .. MainModel.UserInfo.user_id, is_pay)
	dump(data, "<color=white>消费统计————————————————————————————————————————————</color>")
	if table_is_null(M.player_act) then return end
	local a_c = #M.player_act
	if not M.player_act[a_c].scene then return end
	if table_is_null(M.player_act[a_c].panel) then return end
	local p_c = #M.player_act[a_c].panel
	local cur_s = M.player_act[a_c].scene
	local cur_p = M.player_act[a_c].panel[p_c]
	if not cur_p.panel then return end
	local _type =  M.TYPE.consume
	if M.data_statistics(cur_s,cur_p,_type,M.get_hall_content_consume) then return end
	if M.data_statistics(cur_s,cur_p,_type,M.get_match_content_consume) then return end
	if M.data_statistics(cur_s,cur_p,_type,M.get_free_content) then return end
	if M.data_statistics(cur_s,cur_p,_type,M.get_eliminate_content) then return end
	if M.data_statistics(cur_s,cur_p,_type,M.get_eliminate_sh_content) then return end
	if M.data_statistics(cur_s,cur_p,_type,M.get_qql_content) then return end
	if M.data_statistics(cur_s,cur_p,_type,M.get_qql_cs_content) then return end
	if M.data_statistics(cur_s,cur_p,_type,M.get_fishing_content) then return end
	if M.data_statistics(cur_s,cur_p,_type,M.get_fishing_match_content) then return end
	if M.data_statistics(cur_s,cur_p,_type,M.get_fishing_dr_content) then return end
end

--提升VIP
function M.get_vip_up_content(cur_s,cur_p)
	if cur_p.panel == "PayPanel" then
		if cur_p.pre_panel and cur_p.pre_panel == "VipShowTQPanel" then
			--VIP特权购买
			return "VIP特权购买"
		end
		if cur_p.pre_panel and cur_p.pre_panel == "VipShowLBPanel" then
			--VIP礼包购买
			return "VIP礼包购买"
		end
		if cur_p.pre_panel and cur_p.pre_panel == "GameActivityXXCJPanel" then
			--福卡大转盘
			return "福卡大转盘"
		end
		if cur_p.pre_panel and cur_p.pre_panel == "SignInPanel" then
			--签到奖励
			return "签到奖励"
		end
		if cur_p.pre_panel and cur_p.pre_panel == "MatchHallPanel" then
			if not table_is_null(cur_p.info) then
				local info = cur_p.info[#cur_p.info]
				if info and info.vip and info.vip == "vip_up" then
					--公益赛高场次
					return "公益赛高场次"
				end
			end
		end
		if cur_p.pre_panel and cur_p.pre_panel == "GameFreeHallPanel" then
			dump(cur_p.info, "<color=yellow>info</color>")
			if not table_is_null(cur_p.info) then
				local info = cur_p.info[#cur_p.info]
				if info and info.vip and info.vip == "vip_up" then
					--匹配场高场次
					return "匹配场高场次"
				end
				if info and not table_is_null(info.fg_cfg) and info.is_auto then
					--最新的是自动选择的查看上一个
					info = cur_p.info[#cur_p.info - 1]
					if info and info.vip and info.vip == "vip_up" then
						--匹配场高场次
						return "匹配场高场次"
					end
				end
			end
		end
		if cur_p.pre_panel and cur_p.pre_panel == "QQLPanel" then
			if not table_is_null(cur_p.info) then
				local info = cur_p.info[#cur_p.info]
				if info and info.vip and info.vip == "vip_up" then
					--敲敲乐普通模式提升档次
					return "敲敲乐普通模式提升档次"
				end
			end
		end
		if cur_p.pre_panel and cur_p.pre_panel == "QQLCSPanel" then
			if not table_is_null(cur_p.info) then
				local info = cur_p.info[#cur_p.info]
				if info and info.vip and info.vip == "vip_up" then
					--敲敲乐财神模式提升档次
					return "敲敲乐财神模式提升档次"
				end
			end
		end
		if cur_p.pre_panel and cur_p.pre_panel == "EliminateGamePanel" then
			if not table_is_null(cur_p.info) then
				local info = cur_p.info[#cur_p.info]
				if info and info.vip and info.vip == "vip_up" then
					--水果消消乐提升档次
					return "水果消消乐提升档次"
				end
			end
		end
		if cur_p.pre_panel and cur_p.pre_panel == "EliminateSHGamePanel" then
			if not table_is_null(cur_p.info) then
				local info = cur_p.info[#cur_p.info]
				if info and info.vip and info.vip == "vip_up" then
					--水浒消消乐提升档次
					return "水浒消消乐提升档次"
				end
			end
		end
		if cur_p.pre_panel and cur_p.pre_panel == "FishingHallGamePanel" then
			if not table_is_null(cur_p.info) then
				local info = cur_p.info[#cur_p.info]
				if info and info.vip and info.vip == "vip_up" then
					--街机捕鱼提升档次
					return "街机捕鱼提升档次"
				end
			end
		end
		if not table_is_null(cur_p.info) then
			local info = cur_p.info[#cur_p.info]
			local info1 = cur_p.info[#cur_p.info - 1]
			if info and info.vip and info.vip == "vip_up" and info1 and info1.vip and info1.vip == "vip_up_hb_limit" then
				--福卡上限提示
				return "福卡上限提示"
			end
		end
	end
end

--大厅
function M.get_hall_content_pay(cur_s,cur_p)
	if cur_s ~= "game_Hall" then return end
	--全返礼包
	if cur_p.panel == "Act_006_QFLB2Panel" then 
		if cur_p.pre_panel and cur_p.pre_panel == "HallPanel" then
			--大厅商城购买
			return "全返礼包2活动页购买"
		end
	end
	if cur_p.panel == "Act_006_QFLB3Panel" then 
		if cur_p.pre_panel and cur_p.pre_panel == "HallPanel" then
			--大厅商城购买
			return "全返礼包3活动页购买"
		end
	end
	
	if cur_p.panel == "HallPanel" then
		--大厅直购
		return "大厅直购"
	end
	if cur_p.panel == "BannerPanel" or (cur_p.pre_panel and cur_p.pre_panel == "BannerPanel") then
		--登录弹出
		return "登录弹出购买"
	end
	if cur_p.panel == "GameActivityPanel" then
		--活动页购买
		return "活动页面购买"
	end
	if cur_p.panel == "PayPanel" then
		if cur_p.pre_panel and cur_p.pre_panel == "HallPanel" then
			--大厅商城购买
			return "大厅商城购买"
		end
	end
end

--大厅
function M.get_hall_content_consume(cur_s,cur_p)
	if cur_s ~= "game_Hall" then return end
	if cur_p.panel == "GameActivityXXCJPanel" and cur_p.pre_panel == "HallPanel" then
		return "大厅福卡大转盘"
	end
end

--比赛场
function M.get_match_content_consume(cur_s, cur_p, _type)
	--屏蔽购买
	if _type == M.TYPE.pay then return end
	if cur_s ~= "game_MatchHall" or cur_s ~= "game_DdzMatch" or cur_s ~= "game_DdzPDKMatch" or cur_s ~= "game_MjXzMatchER3D" then return end
	local match_cfg = MatchModel.GetGameCfg(MatchModel.GetCurrGameID())
	if not table_is_null(match_cfg) and match_cfg.game_tag == "hbs" then
		local name = match_cfg.game_type_name .. match_cfg.game_name
		return name
	end
end

--匹配场
function M.get_free_content(cur_s, cur_p, _type)
	--匹配场大厅
	if cur_s == "game_Free" then
		local infos
		local info
		if cur_p.panel == "PayPanel" then
			if cur_p.pre_panel and cur_p.pre_panel == "MatchHallPanel" then
				infos = M.get_info_in_panel(cur_p.pre_panel)
				info = M.get_top_info_in_panel(cur_p.pre_panel)
			end
		end
		if cur_p.panel == "GameFreeHallPanel" then
			infos = M.get_info_in_panel(cur_p.panel)
			info = M.get_top_info_in_panel(cur_p.panel)
		end
		if not table_is_null(infos) then
			if _type == M.TYPE.pay and #infos > 1 then
				if not table_is_null(info) and info.is_auto then
					--最新的一个是自动选择的
					info = infos[#infos - 1]
				end 
			end
		end
		if not table_is_null(info) and not table_is_null(info.fg_cfg) then
			local cfg = GameFreeModel.GetGameTypeToConfig(info.fg_cfg.game_type)
			if cfg then
				local name = cfg.name .. "-" .. info.fg_cfg.game_name
				return name
			end
		end

	end

	local game_id
	--匹配场斗地主
	if cur_s == "game_DdzFree" then
		if DdzFreeModel and DdzFreeModel.baseData and DdzFreeModel.baseData.game_id then
			game_id = DdzFreeModel.baseData.game_id
		end
	end

	--匹配场跑得快
	if cur_s == "game_DdzPDK" then
		if DdzPDKModel and DdzPDKModel.baseData and DdzPDKModel.baseData.game_id then
			game_id = DdzPDKModel.baseData.game_id
		end
	end

	--匹配场五子棋
	if cur_s == "game_Gobang" then
		if GobangModel and GobangModel.baseData and GobangModel.baseData.game_id then
			game_id = GobangModel.baseData.game_id
		end
	end

	--匹配场麻将血战
	if cur_s == "game_Mj3D" then
		if MjXzModel and MjXzModel.baseData and MjXzModel.baseData.game_id then
			game_id = MjXzModel.baseData.game_id
		end
	end

	--匹配场麻将血流
	if cur_s == "game_MjXl3D" then
		if MjXlModel and MjXlModel.baseData and MjXlModel.baseData.game_id then
			game_id = MjXlModel.baseData.game_id
		end
	end

	if game_id then
		local gameCfg = GameFreeModel.GetGameIDToConfig(game_id)
		if gameCfg then
			local cfg = GameFreeModel.GetGameTypeToConfig(gameCfg.game_type)
			if cfg then
				local name = cfg.name .. "-" .. gameCfg.game_name
				return name
			end
		end
	end
end

--消消乐
function M.get_eliminate_content(cur_s,cur_p)
	if cur_s ~= "game_Eliminate" then return end
	if EliminateModel then
		local bet = EliminateModel.GetBet()
		if not table_is_null(bet) then
			local money = bet[1] * 5
			return  "消消乐" .. money
		end
	end
end

--水浒消消乐
function M.get_eliminate_sh_content(cur_s,cur_p)
	if cur_s ~= "game_EliminateSH" then return end
	if EliminateSHModel then
		local bet = EliminateSHModel.GetBet()
		if not table_is_null(bet) then
			local money = bet[1] * 5
			return "水浒消消乐" .. money
		end
	end
end

--敲敲乐
function M.get_qql_content(cur_s,cur_p)
	if cur_s ~= "game_Zjd" then return end
	if cur_p.pre_panel and cur_p.pre_panel == "QQLPanel" then
		if ShatterGoldenEggModel and ShatterGoldenEggLogic then
			local k = ShatterGoldenEggLogic.GetHammer()
			local money = ShatterGoldenEggModel.getBaseMoney(k, false)
			if money then
				return "敲敲乐" .. money
			end
		end
	end
end

--小游戏大厅
function M.get_minigame_hall_content_pay(cur_s,cur_p)
	if cur_s ~= "game_MiniGame" then return end  
	if cur_p.panel == "Act_006_QFLB2Panel" then 
		return "全返礼包2活动页购买"
	end
	if cur_p.panel == "Act_006_QFLB3Panel" then 
		return "全返礼包3活动页购买"
	end
end

--千元赛购买
function M.get_qys_content_pay(cur_s,cur_p)
	if cur_s ~= "game_DdzMatch" then return end  
	if cur_p.panel == "Act_006_QFLB2Panel" then 
		return "全返礼包2活动页购买"
	end
	if cur_p.panel == "Act_006_QFLB3Panel" then 
		return "全返礼包3活动页购买"
	end
end

--财神敲敲乐
function M.get_qql_cs_content(cur_s,cur_p)
	if cur_s ~= "game_Zjd" then return end
	if cur_p.pre_panel and cur_p.pre_panel == "QQLCSPanel" then
		if ShatterGoldenEggModel and ShatterGolden2EggsBetPanel then
			local k = ShatterGoldenEggLogic.GetHammer()
			k = ShatterGoldenEggModel.getExtra2EggsData("mode_hammer") or k
			local money = ShatterGoldenEggModel.getBaseMoney(k, true)
			if money then
				return "财神敲敲乐" .. money
			end
		end
	end
end

--捕鱼
function M.get_fishing_content(cur_s,cur_p)
	if cur_s ~= "game_Fishing" then return end
	if FishingModel then
		local cfg = FishingModel.GetCurHallCfg()
		if not table_is_null(cfg) then
			--街机捕鱼
			return "街机捕鱼" .. cfg.name
		end
	end
end

--捕鱼比赛
function M.get_fishing_match_content(cur_s,cur_p)
	if cur_s ~= "game_FishingMatch" then return end
	if FishingMatchModel then
		return "捕鱼比赛"
	end
end

--捕鱼达人
function M.get_fishing_dr_content(cur_s,cur_p)
	if cur_s ~= "game_FishingDR" then return end
	if FishingDRModel then
		return "疯狂捕鱼"
	end
end

--广告统计----------------------------
local ad_key = {
	zyj= "广告点1",	--转运金
	match_detail_10 = "广告点2",
	match_js_10 = "广告点2",
	match_hall_10 = "广告点2",
	dh = "广告点3",	--为你将本局赢得的%s鲸币兑换成%s福卡
	djhb = "广告点4",	--恭喜你,本次抽奖获得了%s奖励!
	ls = "广告点5",	--恭喜你,连胜挑战成功,获得了%s奖励!
	match_detail_2 = "广告点6",
	match_detail_5 = "广告点6",
	match_js_2 = "广告点6",
	match_js_5 = "广告点6",
	match_hall_2 = "广告点6",	
	match_hall_5 = "广告点6",	
	vow = "广告点7",	--许愿池
	sjjbjl = "广告点8",	--随机鲸币奖励
	mflhb = "广告点9",	--鲸鱼福利
	jbzk = "广告点10",	--鲸币周卡
	awrdg = "广告点11",	--领取奖励时的banner广告
	gamehall = "广告点12",	--从匹配场或者小游戏大厅返回主界面时的插屏广告
}
function M.ADShow(key)
	if not on_off_ad then return end
	if not key then return end
	local content = ad_key[key] or "???"
	local _type = M.TYPE.ad_show
	dump({type =_type,content = content},"<color=white>广告播放数据统计>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>></color>")
	Network.SendRequest("data_statistics", {type = _type,content = content},"广告播放数据")
end

function M.ADTrigger(key)	
	if not on_off_ad then return end
	if not key then return end
	local content = ad_key[key]
	local _type = M.TYPE.ad_trigger
	dump({type =_type,content = content},"<color=white>广告触发数据统计>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>></color>")
	Network.SendRequest("data_statistics", {type = _type,content = content},"广告触发数据")
end

function M.GetPlayerAct(  )
	return M.player_act
end