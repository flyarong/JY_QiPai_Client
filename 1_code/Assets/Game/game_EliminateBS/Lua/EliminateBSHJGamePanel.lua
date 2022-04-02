-- 创建时间:2021-07-16
-- Panel:EliminateBSHJGamePanel
--[[
 *      ┌─┐       ┌─┐
 *   ┌──┘ ┴───────┘ ┴──┐
 *   │                 │
 *   │       ───       │
 *   │  ─┬┘       └┬─  │
 *   │                 │
 *   │       ─┴─       │
 *   │                 │
 *   └───┐         ┌───┘
 *       │         │
 *       │         │
 *       │         │
 *       │         └──────────────┐
 *       │                        │
 *       │                        ├─┐
 *       │                        ┌─┘
 *       │                        │
 *       └─┐  ┐  ┌───────┬──┐  ┌──┘
 *         │ ─┤ ─┤       │ ─┤ ─┤
 *         └──┴──┘       └──┴──┘
 *                神兽保佑
 *               代码无BUG!
 -- 取消按钮音效
 -- ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
 -- 确认按钮音效
 -- ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
 --]]

local basefunc = require "Game/Common/basefunc"

EliminateBSHJGamePanel = basefunc.class()
local C = EliminateBSHJGamePanel
C.name = "EliminateBSHJGamePanel"
C.itemName = "EliminateBSHJItem"
local M = EliminateBSModel
local instance
function C.Create()
	if instance then
		return instance
	else
		instance = C.New()
	end
	return instance
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
	self.lister["model_bshj_next_lottery_success"] = basefunc.handler(self, self.on_model_bshj_next_lottery_success)
	self.lister["model_bshj_big_box_sel_success"] = basefunc.handler(self, self.on_model_bshj_big_box_sel_success)
	self.lister["xxl_baoshi_auto_big"] = basefunc.handler(self, self.xxl_baoshi_auto_big)
	self.lister["eliminateBS_had_settel_msg"] = basefunc.handler(self, self.on_eliminateBS_had_settel_msg)
	self.lister["ExitScene"] = basefunc.handler(self, self.MyExit)
	self.lister["EnterBackGround"] = basefunc.handler(self, self.OnEnterBackGround)
	self.lister["EnterForeGround"] = basefunc.handler(self, self.OnEnterForeGround)
	self.lister["logic_xxl_baoshi_all_info"] = basefunc.handler(self, self.on_logic_xxl_baoshi_all_info)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	self:ClearTimer()
	EliminateBSPartManager.ClearTweenBSHJ()
	self:SetBaseGamePanelActive(true)
	if EliminateBSModel.data and EliminateBSModel.data.state then
		EliminateBSModel.data.state = EliminateBSModel.xc_state.nor
	end
    ExtendSoundManager.PlaySceneBGM(audio_config.bsmz.bgm_bsmz_bg_1.audio_name)
	self:RemoveListener()
	self.moneyPanel:MyExit()
	instance = nil
	destroy(self.gameObject)
end
function C:on_logic_xxl_baoshi_all_info()
	self:MyExit()
end
local timers = {
	"lotteryBeginTimer",
	"selectTimer",
	"stayTimer",
	"lotteryEndTimer",
}

local ViewState = {
	wait_start = 0,
	wait_pause = 1,
	lottery = 2,
	lottery_select = 3,
}

function C:ClearTimer(timerName)
	if timerName and self[timerName] then
		self[timerName]:Stop()
		self[timerName] = nil
	else
		for i = 1, #timers do
			if self[timers[i]] then
				self[timers[i]]:Stop()
				self[timers[i]] = nil
			end
		end
	end
end

function C:OnDestroy()
	self:MyExit()
end

function C:MyClose()
	self:MyExit()
end

function C:ctor()
	ExtPanel.ExtMsg(self)
	local parent = GameObject.Find("Canvas/LayerLv4").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	self.isTest = false
	LuaHelper.GeneratingVar(self.transform, self)
	self:MakeLister()
	self:AddMsgListener()
	dump(debug.traceback())
	self:InitUI()
end

function C:InitUI()
	self.transform:SetSiblingIndex(0)
	self:SetBaseGamePanelActive(false)
	self.moneyPanel = EliminateBSHJMoneyPanel.Create()
	self:MyRefresh()
	self:IninData()
	self:InitState()
	self:InitHJItem()
	self.lotteryNum = 0
	self:InitLotteryContent()
	self:InitPipeline()
	self:RefreshBSItemSingleRateBg(false)
	self:RefreshLineRateView()
	dump(EliminateBSModel.is_ew_bet, "<color=white>宝石幻境:是否有额外押注</color>")

	if EliminateBSModel.is_ew_bet then
		local call = function()
			self:RefreshBSItemSingleRateBg(true)
			self:CheckAndLottery()
		end
		self:CreateExtLotteryFx(call)
	else
		self.lotteryBeginTimer = Timer.New(function()
			self:CheckAndLottery()
		end, 0.85, 1)
		self.lotteryBeginTimer:Start()
	end
	
	DOTweenManager.OpenPopupUIAnim(self.root.transform)
	ExtendSoundManager.PlaySceneBGM(audio_config.bsmz.bgm_bsmz_bg_2.audio_name)
end

--Init
function C:SetBaseGamePanelActive(isActive)
	self.basePrePath = {
		"Canvas/LayerLv1/EliminateBSMoneyPanel",
	}
	for i = 1, #self.basePrePath do
		local pre = GameObject.Find(self.basePrePath[i])
		if IsEquals(pre) then
			 pre.gameObject:SetActive(isActive)
		end
		pre = nil
	end
end

--初始化数据
function C:IninData()
	local data = "EWXIGXFWKJDDIMVHPGFAITOBSMFJRVV2CNTTRFUGSULXHNTDFGHQOQA"
	if self.isTest then
		self.bshj_map_data = eliminate_bs_algorithm.get_bshj_map_data(data)
		self.bshj_lottery_data = eliminate_bs_algorithm.get_bshj_lottery_data(data)
	else
		self.bshj_map_data = M.bshj_data.bshj_map_data
		self.bshj_lottery_data = M.bshj_data.bshj_lottery_data
	end
	dump(self.bshj_map_data,"<color=red>宝石幻境:初始5x5数据</color>")
	dump(self.bshj_lottery_data,"<color=red>宝石幻境:所有抽奖数据</color>")
	self.baseBet = EliminateBSModel.data.bet[1] * 5
	dump(self.baseBet, "<color=white>宝石幻境:基础倍率</color>")
end

--初始化状态
function C:InitState()
	self.viewState = ViewState.wait_start
	EliminateBSModel.data.state = EliminateBSModel.xc_state.bshj
end

--初始化5x5宝石
function C:InitHJItem()
	local itemSpaceX = 125
	local itemSpaceY = 126.3
	self.hjItems = {}
	for i = 1, #self.bshj_map_data do
		for j = 1, #self.bshj_map_data[i] do
			local curPos = eliminate_bs_algorithm.get_bshj_pos(i, j, itemSpaceX, itemSpaceY)
			local b = newObject(C.itemName, self.ItemContent.transform)
			b.transform.anchoredPosition = Vector2.New(curPos.x, curPos.y)
			local b_ui = {}
			LuaHelper.GeneratingVar(b.transform, b_ui)
			b_ui.obj = b
			b_ui.item_btn.onClick:AddListener(function()
				self:SelectItem(i, j)
			end)
			b_ui.icon_img.sprite = EliminateBSObjManager.bshj_item_obj["bshj_icon_" .. self.bshj_map_data[i][j]]
			self.hjItems[i] = self.hjItems[i] or {}
			self.hjItems[i][j] = b_ui
		end
	end
end

--初始化显示流水线
function C:InitPipeline()
	self:MakeLoteryViewPipeline(function()
		local call = function()
			self:CheckAndLottery()
		end
		self.viewState = ViewState.wait_pause
		self:StayAnim(call)
	end)
end

--Update TODO:这部分其中一些其实可以放到Model里面
function C:UpdateBaseData()
	self.curLotteryData = eliminate_bs_algorithm.get_bshj_cur_data(self.bshj_lottery_data[self.lotteryNum + 1], self.allMatchData, self.bshj_map_data)
	self.curLotteryMapData = eliminate_bs_algorithm.get_bshj_match_data_map_2(self.bshj_map_data, self.curLotteryData)
	self.curSelectData = eliminate_bs_algorithm.get_bshj_match_data_map(self.bshj_map_data, self.curLotteryData)
	dump(debug.traceback())
	dump(self.curLotteryData, "<color=red>宝石幻境:第" .. self.lotteryNum + 1 .."次抽奖数据</color>")
	dump(self.curLotteryMapData, "<color=red>宝石幻境:第" .. self.lotteryNum + 1 .."次抽奖Map数据</color>")
	dump(self.curSelectData, "<color=red>宝石幻境:第" .. self.lotteryNum + 1 .."次抽奖CurSelectMap数据</color>")
	if not self.allMatchData then
		self.allMatchData = self.curSelectData
		self.newMatchData = self.curSelectData
	else
		self.newMatchData = eliminate_bs_algorithm.get_bshj_macth_new_data_map(self.allMatchData, self.curSelectData)
		self.allMatchData = eliminate_bs_algorithm.get_bshj_match_all_data_map(self.allMatchData, self.curSelectData)
	end
	self.curNeedSelectNum = eliminate_bs_algorithm.get_bshj_cur_select_num(self.curLotteryData)
	self.allNeedSelectNum = eliminate_bs_algorithm.get_bshj_all_need_select_num(self.bshj_lottery_data, self.lotteryNum + 1)
	self.allSelectNum = #M.bshj_data.big_sel_list
	dump(self.allNeedSelectNum, "<color=red>所有需要选择的次数</color>")
	dump(self.allSelectNum, "<color=red>服务器已选择的次数</color>")
	dump(self.curNeedSelectNum, "<color=red>本次需要选择的次数</color>")
	dump(M.bshj_data.big_sel_list, "<color=red>服务器已选的数据</color>")
end

function C:CorrectAllMatchData()
	dump(self.allMatchData, "<color=white>修正前的数据</color>")
	self.allMatchData = eliminate_bs_algorithm.get_bshj_match_all_data_corect_map(self.allMatchData, M.bshj_data.big_sel_list)
	dump(self.allMatchData, "<color=white>修正后的数据</color>")
end

function C:UpdateLineData()
	self.curLotteryLineData = eliminate_bs_algorithm.get_bshj_line_map(self.allMatchData, self.curLotteryLineData)
	self.curLotteryLineRate = eliminate_bs_algorithm.get_bshj_line_rate(self.allMatchData)
	self.curLotteryAllRate = eliminate_bs_algorithm.get_bshj_all_rate(self.allMatchData, EliminateBSModel.is_ew_bet)
end

function C:UpdateSelBoxDataToMatchData(pos)
	self.allMatchData = eliminate_bs_algorithm.add_bshj_match_all_data_map(self.allMatchData, pos.i, pos.j)
	self.curSelectData = eliminate_bs_algorithm.add_bshj_match_all_data_map(self.curSelectData, pos.i, pos.j)
	self.newMatchData = eliminate_bs_algorithm.add_bshj_match_all_data_map(self.newMatchData, pos.i, pos.j)
end

function C:UpdateLotteryRateData()
	self.curLotteryLineData = eliminate_bs_algorithm.get_bshj_line_fx_end_map(self.curLotteryLineData)
	self.lastLotteryAllRate = self.lastLotteryAllRate or 0
	self.addRate = self.curLotteryAllRate - self.lastLotteryAllRate 
	dump(self.curLotteryAllRate, "<color=white>所有加成的倍数</color>")
	dump(self.addRate, "<color=white>当前加成的倍数</color>")
end

--Lottery
function C:CheckAndLottery()
	local isNeedRequest = true
	local isNeedCorrectView = false
	if self.lotteryNum == 0 and EliminateBSModel.bshj_data.bshj_game_index then
		dump(EliminateBSModel.bshj_data.bshj_game_index, "<color=red>bshj_game_index</color>")
		--此时已经是结算了
		if EliminateBSModel.bshj_data.bshj_game_index == 6 then
			self.lotteryNum = 6
		elseif EliminateBSModel.bshj_data.bshj_game_index == 1 then
			isNeedRequest = false
			isNeedCorrectView = true
		elseif EliminateBSModel.bshj_data.bshj_game_index - 1 > self.lotteryNum then
			for i = 1, EliminateBSModel.bshj_data.bshj_game_index - 1 do

				self:UpdateBaseData()
				self:UpdateLineData()
				self.lotteryNum = self.lotteryNum + 1
				self:LineEndCall()
			end
			self:CorrectAllMatchData()
			self:RefreshBSItemMatch()
			isNeedRequest = false
		end
	end

	if self.lotteryNum >= 6 then
		self.lotteryEndTimer = Timer.New(function()
			EliminateBSModel.SetDataLotteryEnd()
			Event.Brocast("view_lottery_end", EliminateBSModel.GetAllResultData())
			Event.Brocast("view_bshj_all_lottery_end")
		end, 0.55, 1)
		self.viewState = ViewState.wait_pause
		self.lotteryEndTimer:Start()
		return
	end

	--测试条件不用向服务器发送消息
	if self.isTest then
		self:StartLottery()
		return
	end

	if isNeedRequest then
		dump("<color=white>TTT 向服务器发送下一轮次的消息</color>")
		dump(debug.traceback())
		Network.SendRequest("xxl_baoshi_little_next")
	else
		self:StartLottery(isNeedCorrectView)
	end
end

function C:MyRefresh()
end

function C:StartLottery(isNeedCorrectView)
	self.viewState = ViewState.lottery
	self:UpdateBaseData()
	self:UpdateLineData()
	if isNeedCorrectView then
		--self:CorrectAllMatchData()
		self:RefreshBSItemMatch()
	end
	self.isSelect = false			--是否进入大宝箱选择状态
	self.isRandom = false			--是否进入小包厢随机状态
	self.Selects = {}				--所有大宝箱选择的回调
	self.SelectPos = {}				--所有大宝箱选择的位置
	self.curSelectNum = 0			--当前选择的个数
	self.isBackgroundBack = false	--是否刚从后台返回
	for i = 1, #self.curLotteryData do
		if self.curLotteryData[i] == 26 then
			self.isSelect = true
		elseif self.curLotteryData[i] >= 27 and self.curLotteryData[i] <= 31 then
			self.isRandom = true
		end
	end
	self.lotteryNum = self.lotteryNum + 1
	LittleTips.Create("第" .. self.lotteryNum .. "次开奖")
	self.StartLotteryViewPipleline()
end

function C:LotteryAnimEndCall(lotteryCall)
	
	if lotteryCall then
		lotteryCall()
	end
end

function C:LotteryFxEndCall(lotteryCall)

	if self.isSelect and not table_is_null(self.Selects) then
		self:UpdateLineData()
	end

	self:ExitSelect()
	self:RefreshBSItemMatch()
	if lotteryCall then
		lotteryCall()
	end
end

function C:LineEndCall(lotteryCall)
	self:UpdateLotteryRateData()
	self:RefreshLineRateView()
	self:RefreshGetAwardView()
	dump(self.addRate * self.baseBet, "<color=white>本次加的钱数</color>")
	Event.Brocast("view_bshj_lottery_end", { lottery_num = self.lotteryNum , add_money = self.addRate * self.baseBet})
	if lotteryCall then
		lotteryCall()
	end
end

--最左侧本局获得
function C:RefreshGetAwardView()
	if self.addRate > 0 then
		local cur_del_map = {[1] = {[1] = 1}}
		local parm =  {cur_del_map = cur_del_map, cur_rate = 0, isBshj = true}
		Event.Brocast("view_lottery_award", parm)
		self.lastLotteryAllRate = self.curLotteryAllRate
	end
end

function C:RefreshLineRateView()
	dump(self.addRate, "<color=white>当前连线倍数</color>")
	if not self.curLotteryLineRate or self.curLotteryLineRate == 0 then
		self.line_gold_txt.text = 1.5 * self.baseBet
	else
		self.line_gold_txt.text = self.curLotteryLineRate * self.baseBet
	end
end

function C:RefreshBSItemMatch()
	local selectFun = function(i, j, item)
		if self.allMatchData[i][j] == 1 then
			item.selected.gameObject:SetActive(true)
		else
			item.selected.gameObject:SetActive(false)
		end
	end
	self:RefreshBSItem(self.curSelectData, selectFun)
end

function C:RefreshBsItemMatchSingle(i, j, isSelect)
	if not self.hjItems[i][j] then
		dump("<color=red>Error:!!!</color>")
		return
	end
	self.hjItems[i][j].selected.gameObject:SetActive(isSelect)

	if self.newMatchData[i][j] == 1 then
		local glodRate = 0
		if eliminate_bs_algorithm.check_corner_single_match(i, j)
		or (EliminateBSModel.is_ew_bet and eliminate_bs_algorithm.check_ext_single_match(i, j)) then
			glodRate = 0.7
		elseif  eliminate_bs_algorithm.check_middle_single_match(i, j) then
			glodRate = 1.4
		end
		if glodRate > 0 then
			EliminateBSPartManager.CreateNumGoldInPosBSHJ(self.hjItems[i][j].obj.transform.position, glodRate * self.baseBet, self.fx.transform)
		end
		glodRate = nil
	end
end

function C:RefreshBSItemSingleRateBg(isext)
	local singleRateFun = function(i, j, item)
		if eliminate_bs_algorithm.check_corner_single_match(i, j)
		or eliminate_bs_algorithm.check_middle_single_match(i, j) 
		or (isext and eliminate_bs_algorithm.check_ext_single_match(i, j)) then
			item.init_award.gameObject:SetActive(true)
		else
			item.init_award.gameObject:SetActive(false)
		end
	end
	self:RefreshBSItem(self.curSelectData, singleRateFun)
end

function C:RefreshBSItem(data, handleFunc)
	for i = 1, #self.hjItems do
		for j = 1, #self.hjItems[i] do
			if handleFunc then
				handleFunc(i, j, self.hjItems[i][j])
			end
		end
	end
end

--抽奖表现的播放管线 当获得奖励数据的时候开启
function C:MakeLoteryViewPipeline(viewEndCall)
	self.lotteryPipleline = {"LotteryAnim", "LotteryAnimEndCall", "LotteryFx", 
	"LotteryFxEndCall", "LineFX", "LineEndCall",}
	self.lotteryPiplelineIndex = 0
	self.HandlePipleline = function()
		if not self.lotteryPiplelineIndex or self.lotteryPiplelineIndex > #self.lotteryPipleline then
			self.lotteryPiplelineIndex = 0
			if viewEndCall then
				viewEndCall()
			end
			return
		end
		self[self.lotteryPipleline[self.lotteryPiplelineIndex]](self, function()
			self.lotteryPiplelineIndex = self.lotteryPiplelineIndex + 1
			self.HandlePipleline()
		end)
	end

	local StartPipleline = function()
		self.lotteryPiplelineIndex = 1
		self.HandlePipleline()
	end

	self.StartLotteryViewPipleline = function()
		StartPipleline()
	end
end

--*************************************************************************
--大宝箱的选择
function C:SelectItem(i, j)
	--仅在大宝箱时刻进行选择
	if not self.isSelect then
		return
	end
	--以状态判断
	if self.viewState ~= ViewState.lottery_select then
		return
	end
	if self.allMatchData[i][j] == 1 then
		LittleTips.Create("请选择未点亮的宝石")
		return
	end
	local selIndex =  eliminate_bs_algorithm.transform_bshj_pos_to_index(i, j)

	if #self.SelectPos < #self.Selects then 
		self:AddSelectPosFromIndex(selIndex)
		dump("<color=white>TTT	向服务器发送 选择宝石</color>")
		Network.SendRequest("xxl_baoshi_little_big_box_sel", {big_sel = selIndex})
	end
end

function C:MakeSelect(selectCallFx ,isNeedfX)
	local data = {}
	data.selectCallFx = selectCallFx
	data.isNeedfX = isNeedfX
	return data
end

function C:AddSelect(selectCallFx, isNeedfX)
	local sel = self:MakeSelect(selectCallFx, isNeedfX)
	self.Selects[#self.Selects + 1] = sel
	dump(self.Selects, "<color=red>AddSelect</color>")
end

function C:AddSelectPosFromIndex(selIndex)
	local pos = eliminate_bs_algorithm.transform_bshj_index_to_pos(selIndex)
	self.SelectPos[#self.SelectPos + 1] = pos
	dump(self.SelectPos, "<color=red>SelectPos</color>")
end

function C:ChangeSelectFxCall(openOrClose)
	if table_is_null(self.Selects) then
		return
	end
	for i = 1, #self.Selects do
		if self.Selects[i].isNeedfX ~= openOrClose then
			self.Selects[i].isNeedfX = openOrClose
		end
	end
end

function C:HandleSelect()
	dump(self.curSelectNum + 1, "<color=red>curSelectNum + 1</color>")
	dump(self.Selects, "<color=red>HandleSelect</color>")
	dump(debug.traceback())
	dump(self.SelectPos, "<color=red>SelectPos</color>")
	if not self.Selects[self.curSelectNum + 1] then
		HintPanel.Create(1, "Exception")
		return
	end
	if not self.SelectPos[self.curSelectNum + 1] then
		HintPanel.Create(1, "Exception")
		return
	end
	self.curSelectNum = self.curSelectNum + 1

	local sel = self.Selects[self.curSelectNum]
	self.curSelectPos = self.SelectPos[self.curSelectNum]
	self:UpdateSelBoxDataToMatchData(self.curSelectPos)
	if sel.isNeedfX then
		sel.selectCallFx()
	else
		if self.curSelectPos then
			self:RefreshBsItemMatchSingle(self.curSelectPos.i, self.curSelectPos.j, true)
		end
	end

	if self.curSelectNum == self.curNeedSelectNum then
		self.viewState = ViewState.lottery
	end
end

--修正选择的特效 断线重连时修正那些服务器数据已经有了需要显示的数据
function C:CorrectSelect()
	--需要修正的数量
	local num = self.curNeedSelectNum - (self.allNeedSelectNum - self.allSelectNum)
	dump(num, "<color=white>需要修正的次数</color>")
	if num < 1 then
		return
	end
	for i = 1, num do
		local selIndex = M.bshj_data.big_sel_list[self.allSelectNum - (i - 1)]
		self:AddSelectPosFromIndex(selIndex)
		self:HandleSelect()
	end
end

function C:on_model_bshj_big_box_sel_success(data)
	--dump(data, "<color=white>on_model_bshj_big_box_sel_success</color>")
	if self.isBackgroundBack then
		self:ChangeSelectFxCall(false)
	end
	--为-1的时候是客户端选择
	--为其他值时是服务器代选
	if data.big_sel ~= -1 and data.big_sel then
		self:AddSelectPosFromIndex(tonumber(data.big_sel))
	end
	self:HandleSelect()
end

function C:xxl_baoshi_auto_big(_, data)
	dump(data, "<color=white>xxl_baoshi_auto_big</color>")
	dump(self.viewState, "<color=white>self.viewState</color>")
	if self.viewState ~= ViewState.lottery_select then
		self.startLotteryCallList = self.startLotteryCallList or {}
		self.startLotteryCallList[#self.startLotteryCallList + 1] = function()
			self:AddSelectPosFromIndex(tonumber(data.big_sel))
			self:HandleSelect()
		end
	else
		self:AddSelectPosFromIndex(tonumber(data.big_sel))
		self:HandleSelect()
	end
end

function C:IntoSelect()
	self.viewState = ViewState.lottery_select
	self:CorrectSelect()
	LittleTips.Create("触发大宝箱选择")
	if self.startLotteryCallList and #self.startLotteryCallList > 1 then
		for i = 1, #self.startLotteryCallList do
			self.startLotteryCallList[i]()
		end
		self.startLotteryCallList = {}
	end
	ExtendSoundManager.PlaySound(audio_config.bsmz.bgm_bsmz_dabaoxiang.audio_name)
	self.curSlectTime = 0
	local selectAllTime = 15
	local refreshSelectTime = function()
		local showS = selectAllTime - self.curSlectTime
		self.remain_time_txt.text = showS
	end

	local resetSelectTime = function()
		self.remain_time_txt.text = ""
	end
	refreshSelectTime()
	self.selectTimer = Timer.New(function()
		self.curSlectTime = self.curSlectTime + 1
		refreshSelectTime()
		if self.curSlectTime > selectAllTime then
			resetSelectTime()
			self:ExitSelect()
		end
	end, 1, 20)
	self.box_sel.gameObject:SetActive(true)
	self.selectTimer:Start()
end

function C:ExitSelect()	
	self.box_sel.gameObject:SetActive(false)
	self:ClearTimer("selectTimer")
end

function C:IntoRandom()
	LittleTips.Create("触发小宝箱随机")
    ExtendSoundManager.PlaySound(audio_config.bsmz.bgm_bsmz_xiaobaoxiang.audio_name)
end

--单次开奖
function C:on_model_bshj_next_lottery_success()
	self:StartLottery()
end

function C:on_eliminateBS_had_settel_msg()
	self:MyExit()
end

function C:OnEnterBackGround()
	self:ClearTimer()
	EliminateBSPartManager.ClearTweenBSHJ()
	if self.fx.transform.childCount > 0 then
		for i = 1, self.fx.transform.childCount do
			local item_obj = self.fx.transform:GetChild(i - 1)
			destroy(item_obj.gameObject)
		end
	end
	--选择状态下 切后台时通知服务器进行自动选择 
	if self.viewState == ViewState.lottery_select then
		if table_is_null(self.Selects) then
			return
		end
		if self.curSelectNum < #self.Selects then
			local len = #self.Selects - self.curSelectNum
			for i = 1, len do
				dump("<color=white>TTT	切后台时通知服务器进行自动选择</color>")
				Network.SendRequest("xxl_baoshi_little_big_box_sel")
			end
		end
	end
end

function C:OnEnterForeGround()
	self:ExitSelect()

	if self.viewState == ViewState.wait_start then
		if EliminateBSModel.is_ew_bet then
			self:RefreshBSItemSingleRateBg(true)
		end
		self:CheckAndLottery()
		return
	end

	if self.viewState == ViewState.wait_pause then
		self:CheckAndLottery()
		return
	end
	
	self:RefreshBSItemMatch()
	self:LineEndCall()
	self:CheckAndLottery()
	self.isBackgroundBack = true
end

--*****动画相关*****
local offSet = 0
local spaceY = 100
local primyLotteryData = {1, 26, 31, 26, 1}
local scrollLen = 50
local scrollTime = 2.8

function C:CreateLotteryContentRow(index, data)
	local b = GameObject.Instantiate(self.row, self.lottery_content)
	local b_ui = {}
	LuaHelper.GeneratingVar(b.transform, b_ui)
	for i = 1, #data do
		b_ui["icon_" .. i .. "_img"].sprite = EliminateBSObjManager.bshj_item_obj["bshj_icon_" .. data[i]]
	end
	b_ui.obj = b
	b_ui.obj.gameObject:SetActive(true)
	b_ui.index = index
	b_ui.obj.transform.localPosition = Vector3.New(0, (index - 1) * spaceY, 0)
	self.lotteryContents[#self.lotteryContents + 1] = b_ui
end

function C:ClearLotteryContent()
	if table_is_null(self.lotteryContents) then
		return
	end
	local len = self.lottery_content.transform.childCount
	for i = 1, len do
		destroy(self.lottery_content.transform:GetChild(len - i).gameObject)
	end
	self.lotteryContents = {}
end

local MakeRandomData = function()
	local d = {}
	for i = 1, 5 do
		local index = math.random(26)
		d[#d + 1] = index
	end
	return d
end

function C:InitLotteryContent()
	self.primyLotteryData = primyLotteryData
	self.lotteryContents = {}
	self:CreateLotteryContentRow(1, self.primyLotteryData)
end

function C:LotteryAnim(lotteryCall)
	self:ClearLotteryContent()
	self.lottery_content.transform.localPosition = Vector3.New(self.lottery_content.transform.localPosition.x, 0, 0)
	for i = 1, scrollLen do
		local curData
		if i == 1 then
			self:CreateLotteryContentRow(i, self.primyLotteryData)
		elseif i > 1 and i < scrollLen then
			self:CreateLotteryContentRow(i, MakeRandomData())
		else
			self:CreateLotteryContentRow(i, self.curLotteryData)
		end
	end
	--dump("<color=red>+++++++第".. self.lotteryNum .. "次抽奖动画开始+++++++</color>")
	local seq = DoTweenSequence.Create()
	local changeY = self.lottery_content.transform.localPosition.y - (scrollLen - 1) * spaceY
	seq:Append(self.lottery_content.transform:DOLocalMoveY(changeY, scrollTime))
	seq:SetEase(DG.Tweening.Ease.InOutQuint)
	seq:OnForceKill(function ()
		--dump("<color=red>+++++++第".. self.lotteryNum .. "次抽奖动画结束+++++++</color>")
		self.primyLotteryData = self.curLotteryData
		if lotteryCall then
			lotteryCall()
		end
	end)
	EliminateBSPartManager.AddTweenBSHJ(seq)
end

function C:StayAnim(lotteryCall)
	self:ClearTimer("stayTimer")
	self.stayTimer = Timer.New(function()
		if lotteryCall then
			lotteryCall()
		end
	end, 0.75, 1)
	self.stayTimer:Start()
end

--*****特效相关*****
function C:LotteryFx(lotteryCall)
	local indexC = 0
	local index = 0
	local fxSingleFinishCall = function(i, j)
		self:RefreshBsItemMatchSingle(i, j, true)
		index = index + 1
		if index >= indexC then
			if lotteryCall then
				lotteryCall()
			end
		end
	end

	local MakeLotteryFx = function(i, FxType)
		indexC = indexC + 1
		self:CreateBsLotteryedFX(i, fxSingleFinishCall, FxType)
	end

	for i = 1, 5 do
		if self.curLotteryData[i] == 26 and self.isSelect then
			indexC = indexC + 1
			local call = function(index)
				self:CreateBsLotteryedFX(i, fxSingleFinishCall, 3)
			end
			self:AddSelect(call, true)
		elseif self.curLotteryData[i] >= 27 and self.curLotteryData[i] <= 31 then
			MakeLotteryFx(i, 2)
		elseif self.curLotteryMapData[i] ~= 0 then
			MakeLotteryFx(i, 1)
		end
	end

	if self.isSelect then
		self:IntoSelect()
	end
	if self.isRandom then
		self:IntoRandom()
	end

	if indexC == 0 then
		if lotteryCall then
			lotteryCall()
		end
	end
end

function C:LineFX(lotteryCall)
	local indexC = 0
	local index = 0
	local fxLineSingleCall = function()
		index = index + 1
		if index >= indexC then
			if lotteryCall then
				lotteryCall()
			end
		end
	end

	local playLineSound = function()
		ExtendSoundManager.PlaySound(audio_config.bsmz.bgm_bsmz_lianxian.audio_name)
	end
	dump(self.curLotteryLineData, "<color=yellow>当前连线数据</color>")
	for i = 1, #self.curLotteryLineData do
		for j = 1, #self.curLotteryLineData[i] do
			if self.curLotteryLineData[i][j] == 1 then
				indexC = indexC + 1
				playLineSound()
				self:CreateLineFx(j, i, fxLineSingleCall)
			end
		end
	end

	if indexC == 0 then
		if lotteryCall then
			lotteryCall()
		end
	end
end

function C:CreateBsLotteryedFX(i, finishCall, fxType, selectCallIndex)
	local endPos = {}
	if self.isSelect and fxType == 3 then
		endPos.x = self.curSelectPos.i
		endPos.y = self.curSelectPos.j
	else
		endPos.x = i
		endPos.y = self.curLotteryMapData[i]
	end

	local call = function()
		if finishCall then
			finishCall(endPos.x, endPos.y, true)
		end
	end
	EliminateBSPartManager.CreateBsLotteryedFX(call, i, endPos, fxType, self.fx.transform)
end

function C:CreateLineFx(index, lineType, finishCall)
	EliminateBSPartManager.CreateLineFx(finishCall, index, lineType, self.award_get_fx, self.fx.transform)
end

function C:CreateExtLotteryFx(call)
	EliminateBSPartManager.CreateExtLotteryFx(call, self.fx.transform)
end