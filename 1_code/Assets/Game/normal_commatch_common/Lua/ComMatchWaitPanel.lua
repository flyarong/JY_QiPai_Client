-- 创建时间:2018-12-05
local basefunc = require "Game.Common.basefunc"
ComMatchWaitPanel = basefunc.class()
local M = ComMatchWaitPanel

M.name = "ComMatchWaitPanel"
local instance
M.Model_Status = {
    --报名成功，收到nor_mg_signup_response进入状态,此时在等待界面
    wait_begin = "wait_begin",
    --等待分配桌子，收到nor_mg_begin_msg进入状态，进入游戏界面
    wait_table = "wait_table",
    --游戏状态处于游戏中
    gaming = "gaming",
    --玩家进入晋级
    promoted = "promoted",
    --等待复活
    wait_revive = "wait_revive",
    --等待结果
    wait_result = "wait_result",
    --比赛状态处于结束，退回到大厅界面
    gameover = "gameover"
}

--刷新
function M.Refresh(param)
	if not instance then
		M.Create(param)
	end
	instance:MyRefresh(param)
end

function M.Close()
	if instance then
		instance:MyExit()
	end
	instance = nil
end

function M.Create(param)
	local last_num = param.game_cfg.round[#param.game_cfg.round]
	if param.round_info.round_type == 1 and param.one_table_player_num == last_num and param.match_player_num == last_num then
        --最后一轮直接退出
        return
    end
	if instance then
		instance:MyExit()
	end
	instance = M.New(param)
	return instance
end

function M:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function M:MakeLister()
    self.lister = {}
    self.lister["ExitScene"] = basefunc.handler(self, self.ExitScene)
	self.lister["nor_mg_req_cur_player_num_response"] = basefunc.handler(self, self.on_nor_mg_req_cur_player_num)
	self.lister["nor_mg_rank_msg"] = basefunc.handler(self, self.nor_mg_rank_msg)
end

function M:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function M:ctor(param)

	ExtPanel.ExtMsg(self)

	self.param = param
	dump(self.param, "<color=white>param</color>")
	local obj = newObject(M.name, GameObject.Find("Canvas/LayerLv4").transform)
	self.gameObject = obj
	self.transform = obj.transform
	self:MakeLister()
    self:AddMsgListener()
	LuaHelper.GeneratingVar(obj.transform, self)
	self:MyRefresh()
	EventTriggerListener.Get(self.rank_reward_btn.gameObject).onClick = basefunc.handler(self, self.OnClickRankReawrd)
	EventTriggerListener.Get(self.rank_reward_back_btn.gameObject).onClick = basefunc.handler(self, self.OnClickRankReawrdBack)

	local data = {}
	data.anchor = self.progress_bar
	data.is_pro = self.param.is_pro
	data.game_cfg = self.param.game_cfg
	data.award_cfg = self.param.award_cfg
	data.match_player_num = self.param.match_player_num
	data.round_info = self.param.round_info
	data.total_players = self.param.total_players
	data.state = self.param.state

	if not (self.param.state == M.Model_Status.gameover and self.param.my_rank ~= 1) then
		--被淘汰不显示进度条
		ComMatchWaitProgress.Create(data)
	end
end

--[[param = {
	state, --当前状态，MatchResultState
	gameCfg, --游戏配置，match_ui.lua -> config
	awardCfg, --奖励设置， match_ui_lua -> award
	my_rank = self.param.myRank, --当前排名
	match_player_num,--当前在比赛中的玩家
	in_table_player_num,--当前正在比赛中的玩家
	one_table_player_num,--一桌的玩家数
}]]
function M:MyRefresh()
	if self.param.state == M.Model_Status.wait_table then
		self.title_ddpp.gameObject:SetActive(true)
		self.pipei_anim.gameObject:SetActive(true)
	elseif self.param.state == M.Model_Status.gaming then
		--游戏中退出
	elseif self.param.state == M.Model_Status.promoted then
		self.title_jj.gameObject:SetActive(true)
		self.promoted.gameObject:SetActive(true)
		self.pipei_anim.gameObject:SetActive(true)
		self:SetRank()
		self:StartClock()
	elseif self.param.state == M.Model_Status.wait_revive then
		--复活界面
		self.title_tt.gameObject:SetActive(true)
		self:SetRank()
	elseif self.param.state == M.Model_Status.wait_result then
		self.title_dd.gameObject:SetActive(true)
		self.wait.gameObject:SetActive(true)
		self.pipei_anim.gameObject:SetActive(true)
		self:SetRank()
		self:StartClock()
	elseif self.param.state == M.Model_Status.gameover then
		--淘汰或待定
		if self.param.my_rank == 1 then
			self.title_jj.gameObject:SetActive(true)
			self.pipei_anim.gameObject:SetActive(true)
		else
			self.title_tt.gameObject:SetActive(true)
		end
		self:SetRank()
	end
end

function M:MyExit()
	self:RemoveListener()
	ComMatchRankRewardPanel.Close()
	ComMatchWaitProgress.Close()
	self:StopClock()
	GameObject.Destroy(self.gameObject)
end

-- 场景退出
function M:ExitScene()
	self:MyExit()
end

function M:Reset()
	self.rank_reward_btn.gameObject:SetActive(false)
	self.rank_reward_back_btn.gameObject:SetActive(false)
	self.title_dd.gameObject:SetActive(false)
	self.title_ddpp.gameObject:SetActive(false)
	self.title_jj.gameObject:SetActive(false)
	self.title_tt.gameObject:SetActive(false)
	self.pipei_anim.gameObject:SetActive(false)
	self.promoted.gameObject:SetActive(false)
	self.wait.gameObject:SetActive(false)
	self.rank.gameObject:SetActive(false)
	self.time.gameObject:SetActive(false)

	self.rank_txt.text = ""
	self.rank_base_txt.text = ""
	self.wait_time_txt.tect = "已等待：00:00"
	self.wait_match_txt.text = "剩余未完成桌数：--"
end

function M:SetRank()
	self.rank.gameObject:SetActive(true)
	self.rank_txt.text = self.param.my_rank .. "/" or "--/"
	local mpn = self.param.match_player_num
	if self.param.match_player_num and self.param.my_rank and self.param.match_player_num < self.param.my_rank then
		mpn = self.param.my_rank		
	end
	self.rank_base_txt.text = mpn
end

function M:OnClickRankReawrd()
	ComMatchRankRewardPanel.Create(self.param.game_cfg, self.param.award_cfg,self.rank_reward_back_btn)
	self.rank_reward_btn.gameObject:SetActive(false)
	self.rank_reward_back_btn.gameObject:SetActive(true)
end

function M:OnClickRankReawrdBack()
	ComMatchRankRewardPanel.Close()
	self.rank_reward_btn.gameObject:SetActive(true)
	self.rank_reward_back_btn.gameObject:SetActive(false)
end

function M:StartClock()
	self.time.gameObject:SetActive(true)
	self.wait_time = 0
	self.taskRefreshWaitTime = Timer.New(basefunc.handler(self, self.RefreshWaitTime), 1, -1, false)
	self.taskRefreshWaitTime:Start()
end

function M:StopClock()
	self.time.gameObject:SetActive(false)
	if self.taskRefreshWaitTime then
		self.taskRefreshWaitTime:Stop()
		self.taskRefreshWaitTime = nil
	end
end

function M:RefreshWaitTime()
	if self.wait_time_txt then
		self.wait_time = self.wait_time + 1
		self.wait_time_txt.text = "已等待 " .. self.FormatTime(self.wait_time)
	end
end

function M.FormatTime(t)
	local m = math.floor(t/60)
	local s = t%60
	return (m < 10 and "0" .. m or m) .. ":" .. (s < 10 and "0" .. s or s)
end

function M:nor_mg_rank_msg(proto_name, data)
	self.param.my_rank = data.rank
	self.rank_txt.text = self.param.my_rank .. "/"
end

function M:on_nor_mg_req_cur_player_num(proto_name, data)
	if not data.result or (data.result and data.result ~= 0) then
        return
	end
	self.param.in_table_player_num = data.in_table_player_num
	self.param.match_player_num = data.match_player_num or self.param.match_player_num
	self:SetRank()
	if self.param.in_table_player_num > 0 then
		self.wait_match_txt.text = "剩余未完成桌数：" .. self.param.in_table_player_num / self.param.one_table_player_num
	else
		self.wait_match_txt.text = "全部完成"
	end
end

function M.ShowPromotionInfo(game_id,round_info)
	local n = round_info.rise_num
	if n == 1 then return end --第一名不再提示
	local baseScore = MatchModel.CheckIsTryouts(game_id) and round_info.init_stake or nil
				
	local pro_info_item = GameObject.Instantiate(GetPrefab("ComMatchWaitProInfoItem"), GameObject.Find("Canvas/LayerLv4").transform)
	local ui = {}
	LuaHelper.GeneratingVar(pro_info_item.transform,ui)
	ui.count_txt.text = n
	if baseScore then
		ui.basescore_txt.text = "<size=40>本局底分:</size> <size=46>" .. baseScore .. "</size>"
	else
		ui.basescore_txt.text = ""
	end

	local tween1 =
        pro_info_item.transform:DOLocalMoveX(-2000, 0.5):From():OnKill(
        function()
            if pro_info_item ~= nil then
                Destroy(pro_info_item.gameObject)
                pro_info_item = nil
            end
        end
    )
    local tween2 =
        pro_info_item.transform:DOLocalMoveX(2000, 0.5):OnComplete(
        function()
            if pro_info_item ~= nil then
                Destroy(pro_info_item.gameObject)
                pro_info_item = nil
            end
        end
    )
    local seq = DG.Tweening.DOTween.Sequence()
    local tweenKey = DOTweenManager.AddTweenToStop(seq)
    seq:Append(tween1):AppendInterval(1):Append(tween2):OnKill(
        function()
            DOTweenManager.RemoveStopTween(tweenKey)
            if pro_info_item ~= nil then
                Destroy(pro_info_item.gameObject)
                pro_info_item = nil
            end
        end
    )
end