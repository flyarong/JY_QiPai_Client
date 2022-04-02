-- 创建时间:2020-02-19
-- Panel:Fishing3DAct6in1Panel
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
 --]]

local basefunc = require "Game/Common/basefunc"

Fishing3DAct6in1Panel = basefunc.class()
local C = Fishing3DAct6in1Panel
C.name = "Fishing3DAct6in1Panel"
local M = BY3DAct6in1Manager

local update_timer
local timeout=10
local max_bk_num = 6
function C.Create()
	return C.New()

end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
	self.lister["model_by3d_act_6in1_lottery"] = basefunc.handler(self, self.on_6in1_lottery)
	self.lister["nor_fishing_panel_active_finish"] = basefunc.handler(self, self.OnAssetChange)

	self.lister["EnterBackGround"] = basefunc.handler(self, self.onEnterBackGround)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end
function C:MyExit()
	self:KillSeq()
	if update_timer then
		update_timer:Stop()
	end
	if self.seq then
		self.seq:Kill()
		self.seq = nil
	end
	if self.seq_settlement then
		self.seq_settlement:Kill()
		self.seq_settlement = nil
	end

    self:BoxExit()
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:ctor()
	ExtPanel.ExtMsg(self)
	print("Fishing3DAct6in1Panel init!")
	local parent = GameObject.Find("Canvas/LayerLv3").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	update_timer = Timer.New(function ()
		self:update()
	end, 1, -1)

	self.timer_count = timeout

	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	self.bk_list = {}
	self.bk_node_pos = {}
    for i = 1, max_bk_num do
    	local pre = Fishing3DAct6in1BoxPrefab.Create(self, self["bk_node"..i], i)
		self.bk_list[#self.bk_list + 1] = pre
		self.bk_node_pos[#self.bk_node_pos + 1] = self["bk_node"..i].transform.localPosition
		pre:showState(Fishing3DAct6in1BoxPrefab.State.Normal)
	end
	self.next_anim = self.xiayilun.transform:GetComponent("Animator")
	self.begin_anim = self.zhunbei.transform:GetComponent("Animator")
	self.feixing = GetPrefab("fish3d_act6in1_box_feixing")

	self:RefreshTimer()
	self:MyRefresh()
	
	self.Center.transform.localScale = Vector3.zero
	self.seq = DoTweenSequence.Create()
	self.seq:Append(self.Center.transform:DOScale(1, 1))
	self.seq:OnKill(function ()
		self.seq = nil
		self:beginAnimation()
	end)
end

function C:beginAnimation()
	self:stopLottery()
	self.begin_anim:Play("run",-1,0)
	self:KillSeq()
	self.seq = DoTweenSequence.Create()
	self.seq:AppendInterval(1)
	self.seq:OnKill(function ()
		self:beginLottery()
	end)
end

function C:on_6in1_lottery()
	local award_data = M.GetAwardData()
	if award_data.result ~= 0 then
		self:MyExit()
		return
	end

	self.lottery_index = self.lottery_index or 1
	local box = self.bk_list[self.lottery_index]
	self.get_rate = award_data.award_multiple - self.cur_award_multiple
	if not IsEquals(box) then
		MainLogic.SendBreakdownInfoToServer("self.lottery_index=" .. self.lottery_index, lua2json(award_data))
		self:MyExit()
		return
	end
	box:playAnimation(function ()
		if award_data.lottery_result == 0 then
			box:showState(Fishing3DAct6in1BoxPrefab.State.Award, self.get_rate)
		else
			box:showState(Fishing3DAct6in1BoxPrefab.State.Lose)
		end

		self:AnimZS(function ()
			if award_data.lottery_result == 0 then
				self:AnimAwardGet(function ()
					self:AnimHP()
				end)
			else
				self:stopLottery()
			end
		end, 1)

	end)
	
end

function C:MyRefresh()
	self:RefreshAward()
end
function C:RefreshAward()
	local data = M.GetAwardData()
	self.beishu_txt.text = data.award_multiple
	self.cur_award_multiple = data.award_multiple
end
function C:KillSeq()
	if self.seq then
		self.seq:Kill()
	end
	self.seq = nil
end
-- 合牌
function C:AnimHP()
	self:KillSeq()
	self.seq = DoTweenSequence.Create()
	for i = 1, max_bk_num do
		local tran = self["bk_node"..i]
		self.bk_list[i]:showState(Fishing3DAct6in1BoxPrefab.State.Normal)
		self.seq:Join(tran:DOLocalMove(Vector3.zero, 0.5))
	end
	self.seq:AppendInterval(1)
	for i = 1, max_bk_num do
		local tran = self["bk_node"..i]
		self.seq:Join(tran:DOLocalMove(self.bk_node_pos[i], 0.5))
	end
	self.seq:OnKill(function ()
		self.seq = nil
		self:beginLottery()
	end)
end
-- 展示
function C:AnimZS(backcall, delta_t)

	local call = function ()
		local cfg = BY3DAct6in1Manager.GetRoundCfg()
		local randi = MathExtend.RandomGroup(max_bk_num)
		local award_data = M.GetAwardData()

		if cfg[ randi[self.lottery_index] ] > 0 and award_data.lottery_result ~= 0 then
			for k,v in ipairs(randi) do
				if cfg[ v ] == 0 then
					randi[k],randi[self.lottery_index] = randi[self.lottery_index],randi[k]
					break
				end
			end
		elseif cfg[ randi[self.lottery_index] ] ~= self.get_rate and award_data.lottery_result == 0 then
			for k,v in ipairs(randi) do
				if cfg[ v ] == self.get_rate then
					randi[k],randi[self.lottery_index] = randi[self.lottery_index],randi[k]
					break
				end
			end
		end

		for i = 1, max_bk_num do
			if self.lottery_index ~= i then
				if cfg[ randi[i] ] > 0 then
					self.bk_list[i]:showState(Fishing3DAct6in1BoxPrefab.State.Award, cfg[ randi[i] ])
				else
					self.bk_list[i]:showState(Fishing3DAct6in1BoxPrefab.State.Lose)
				end
			end
		end

		if backcall then
			backcall()
		end
	end

	if delta_t then
		self:KillSeq()
		self.seq = DoTweenSequence.Create()
		self.seq:AppendInterval(delta_t)
		self.seq:OnKill(function ()
			self.seq = nil
			call()
		end)
	else
		call()
	end
end
-- 奖励获得
function C:AnimAwardGet(backcall)
	local obj = GameObject.Instantiate(self.feixing, self.transform)
	local tran = obj.transform
	tran.position = self.bk_list[self.lottery_index]:GetXingPos()
	local endPos = self.beishu_txt.transform.position

	self:KillSeq()
	self.seq = DoTweenSequence.Create()
	self.seq:Append(tran:DOMove(endPos, 0.5))
	self.seq:AppendCallback(function ()
		destroy(obj)
		obj = nil
		FishingAnimManager.PlayShowAndHideFXAndCall(self.transform, "fish3d_act6in1_box_beishu", endPos, 1, true, function ()
			self:RefreshAward()
		end, 0.4)		
	end)
	self.seq:AppendInterval(1)
	self.seq:AppendCallback(function ()
		self.next_anim:Play("run",-1,0)
	end)
	self.seq:AppendInterval(1)
	self.seq:OnKill(function ()
		local round = self:NumToStr(1 + M.GetCurRound())
		self.cur_lunshu_txt.text = "第"..round.."轮"
		self.seq = nil
		if backcall then
			backcall()
		end
	end)
	self.seq:OnForceKill(function ()
		destroy(obj)
		obj = nil
	end)
end

function C:RefreshTimer()
	self.cd_txt.text = string.format("%ds",self.timer_count)
end

function C:beginLottery()
	for i = 1, 6 do
		self.bk_list[i]:showState(Fishing3DAct6in1BoxPrefab.State.Normal)
		self.bk_list[i]:setEnable(true)
	end

	self.timer_count = timeout
	if update_timer then
		update_timer:Start()
	end

	self:RefreshTimer()
end

function C:stopLottery()
	for i = 1, 6 do
		self.bk_list[i]:setEnable(false)
	end

	if update_timer then
		update_timer:Stop()
	end
end

function C:BoxExit()
	if self.bk_list then
		for k,v in ipairs(self.bk_list) do
			v:MyExit()
		end
	end
	self.bk_list = {}
end

function C:OnBoxClick(index)
	assert(index >= 1 and index <= #self.bk_list)
	self.lottery_index = index

	M.RequestLottery()

	self:stopLottery()
end

function C:update()
	self.timer_count = self.timer_count - 1
	if self.timer_count <= 0 then
		self.timer_count = 0

		self:OnBoxClick(1)
	end

	self:RefreshTimer()
end

function C:OnAssetChange(_, data)
	dump(data, "<color=red>----奖励类型-----</color>")
	if data.type == 29 then
		local money = 0
		for i = 1, #data.assets do
			if data.assets[i].asset_type == "jing_bi" then 
				money = tonumber(data.assets[i].value)
				break
			end
		end

		local seq = DoTweenSequence.Create()
		seq:AppendInterval(0.5)
		seq:OnKill(function ()
			local parent = GameObject.Find("Canvas/LayerLv4").transform
			self:PlayShowAndHideFXAndCall(parent, "fish3d_act6in1_box_anim1", Vector3.zero, 3, nil, function ()
				self:ActSettlement(money)
			end, 1)
		end)
	end
end

function C:ActSettlement(money)
	dump(money,"<color=green>++++++++++++++++ActSettlement+++++++++++++++++</color>")
	self:KillSeq()
	if not FishingLogic.GetPanel() then return end
	local parent = FishingLogic.GetPanel().LayerLv2
	local data = { seat_num = 1,score = money}
	self.seq_settlement = DoTweenSequence.Create()
	self.seq_settlement:AppendInterval(2)
	self.seq_settlement:OnKill(function ()
		self.seq_settlement = nil
		ExtendSoundManager.PlaySound(audio_config.by.bgm_by_jiangli6.audio_name)
    	FishingAnimManager.PlayMultiplyingPower200(parent, Vector2.zero, Vector2.New(-429,-264), money, function ()
			Event.Brocast("ui_gold_fly_finish_msg", data)
    	end,1,nil)
		self:MyExit()
	end)
end

function C:onEnterBackGround()
	self:MyExit()
end


function C:PlayShowAndHideFXAndCall(parent, fx_name, beginPos, keepTime, no_take, call, calltime)
	dump(fx_name,"<color=green>++++++++++++++++PlayShowAndHideFXAndCall+++++++++++++++++</color>")
	local prefab
	prefab = CachePrefabManager.Take(fx_name)
	prefab.prefab:SetParent(parent)
	local tran = prefab.prefab.prefabObj.transform
	tran.position = beginPos
	tran.localScale = Vector3.one
	local rate_txt = tran:Find("@rate_txt")
	local data = M.GetAwardData()
	rate_txt.transform:GetComponent("Text").text = StringHelper.ToCash(data.award_multiple).."倍"
	local seq = DoTweenSequence.Create()
	seq:AppendInterval(calltime)
	seq:AppendCallback(function ()
		if call then
			call()
		end
	end)
	seq:AppendInterval(keepTime-calltime)
	seq:OnForceKill(function ()
		CachePrefabManager.Back(prefab)
	end)		
end

function C:NumToStr(num)
	local str = {"一", "二", "三", "四", "五", "六", "七", "八", "九", "十"}
	if str[num] then
		return str[num]
	else
		return num
	end
end