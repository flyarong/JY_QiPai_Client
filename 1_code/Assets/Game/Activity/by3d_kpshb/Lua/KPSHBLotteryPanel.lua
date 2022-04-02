-- 创建时间:2020-07-10
-- Panel:KPSHBLotteryPanel
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

local isDebug = false

KPSHBLotteryPanel = basefunc.class()
local C = KPSHBLotteryPanel
C.name = "KPSHBLotteryPanel"
local M = BY3DKPSHBManager

-- 动画状态
KPSHBLotteryPanel.AnimState = 
{
	AS_Null = "Null",
	AS_Begin = "开始",
	AS_TheCard = "魔术手换牌",
	AS_Wait = "等待抽奖",
	AS_AnimShowAward = "翻开奖励",
	AS_ShowAward = "展示奖励",
	AS_End = "结束",
}

function C.Create(data, parent)
	return C.New(data, parent)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
	self.lister = {}
    self.lister["EnterBackGround"] = basefunc.handler(self, self.on_background_msg)
    self.lister["EnterForeGround"] = basefunc.handler(self, self.on_backgroundReturn_msg)

    self.lister["get_task_award_new_response"] = basefunc.handler(self,self.buyu_spend_lottery_task_award)

	self.lister["kpshb_model_task_change_msg"] = basefunc.handler(self, self.kpshb_model_task_change_msg)
    self.lister["crr_level_state_change_msg"] = basefunc.handler(self,self.crr_level_state_change_msg)

    self.lister["AssetChange"] = basefunc.handler(self, self.OnAssetChange)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	if self.fp_seq then
		self.fp_seq:Kill()
		self.fp_seq = nil
	end
	if self.seq then
		self.seq:Kill()
		self.seq = nil
	end
	self:RemoveListener()
	self:ShowAwardBrocast()
	destroy(self.gameObject)
end

function C:OnDestroy()
	self:MyExit()
end

function C:ctor(data, parent)

	ExtPanel.ExtMsg(self)

	parent = parent or GameObject.Find("Canvas/LayerLv4").transform
	self.can_show_award = true
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	self:MakeLister()
	self:AddMsgListener()
	self.cell_num = 3
	self.isPlayAnim = false
if isDebug then
	config = {
		[1]=
	    {
	      index = 1,
	      level_id = 1,
	      icon = "gy_20_11",
	      desc = "0.01福卡",
	      tip = "0.01福卡",
	      asset_type = "shop_gold_sum",
	      value = 100,
	    },
	    [2]=
	    {
	      index = 2,
	      level_id = 1,
	      icon = "gy_20_11",
	      desc = "0.04福卡",
	      tip = "0.04福卡",
	      asset_type = "shop_gold_sum",
	      value = 500,
	    },
	    [3]=
	    {
	      index = 3,
	      level_id = 1,
	      icon = "gy_20_11",
	      desc = "0.1福卡",
	      tip = "0.1福卡",
	      asset_type = "shop_gold_sum",
	      value = 10000,
	      is_big = 1,
	    }
	}
end
	self.data = data

	self:InitUI()
end

function C:InitUI()
	self.task_data = M.GetTaskDataByID( M.GetTaskID(FishingModel.game_id) )
	self.wc_lv = M.GetCurTaskFinishLv()
	if self.wc_lv > 0 then
		self.xz_lv = self.wc_lv
	else
		self.xz_lv = 1
	end
	self.anim_state = KPSHBLotteryPanel.AnimState.AS_Null
	self.index_list = {}

	self.ui_config = {}
	self.ui_config[#self.ui_config + 1] = {index=1, name = "普通福卡"}
	self.ui_config[#self.ui_config + 1] = {index=2, name = "高级福卡", hint="省5%", hint_img="hbdzp_icon_bql"}
	self.ui_config[#self.ui_config + 1] = {index=3, name = "超级福卡", hint="省10%", hint_img="hbdzp_icon_bqz"}

	self.cj_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		if self.xz_lv > self.wc_lv then
			return
		end

		self:AnimBegin()
	end)
	self.TopCell = {}
	for k,v in ipairs(self.ui_config) do
		local pre = KPSHBLotteryTopPrefab.Create(self.top, v, self.OnDJClick, self)
		self.TopCell[#self.TopCell + 1] = pre
		if k < self.wc_lv then
			pre:SetDJState(false)
		else
			pre:SetDJState(true)
		end
	end
	self.help_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
     	self:ShowHelpPanel()
    end)
	self.back_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:MyExit()
	end)

    self.hint_anim = self.hint_txt.transform:GetComponent("Animator")

	self:MyRefresh()
end

function C:MyRefresh()
	self:RefreshTop()
	self:RefreshXZ()
	self:RefreshHint()
	self:RefreshFD()
end
function C:RefreshTop()
	self.wc_lv = M.GetCurTaskFinishLv()
	for k,v in ipairs(self.TopCell) do
		if k < self.wc_lv then
			v:SetDJState(false)
		else
			v:SetDJState(true)
		end
	end	
end
function C:RefreshXZ()
	for k,v in ipairs(self.TopCell) do
		if k == self.xz_lv then
			v:SetSelect(true)
		else
			v:SetSelect(false)
		end
	end
end
function C:RefreshHint()

	self.hint_anim:Play("NoPlayAnimation",-1,0)
	if self.anim_state == KPSHBLotteryPanel.AnimState.AS_Null then
		if self.xz_lv > self.wc_lv then
			self:RefreshJD()
		else
			self.hint_anim:Play("hintAnimation",-1,0)
			self.hint_txt.text = "点击立即抽取福卡"
		end
	else
		if self.anim_state == KPSHBLotteryPanel.AnimState.AS_Wait then
			self.hint_txt.text = "请从三个中选择一个领取"
		else
			self.hint_txt.text = ""
		end
	end
end
function C:RefreshJD()
	if self.anim_state == KPSHBLotteryPanel.AnimState.AS_Null and self.xz_lv > self.wc_lv then
		self.hint_txt.text = string.format("差<color=red>%s</color>炮可抽<color=red>%s</color>", 
			M.GetGunRateSurNum(self.xz_lv), self.ui_config[self.xz_lv].name)	
	end
end
-- 中间福袋显示
function C:RefreshFD()
	self:CloseCellFD()
	self.index_list = {}
	self.config = M.GetHBRateConfigByIDIndex(FishingModel.game_id, self.xz_lv)
	self.cell_num = #self.config
	-- 随机显示
	-- self.index_list = MathExtend.RandomGroup(self.cell_num)
	-- 顺序显示
	for i=1,#self.config do
		self.index_list[#self.index_list + 1] = i
	end

	self.CellPos = {}
	for i = 1, #self.config do
		local pre = KPSHBLotteryPrefab.Create(self.center, self.config[self:GetIndex(i)], self.OnGetClick, self, i)
		local pos = Vector3.New(-400 + 400 * (i - 1), 0, 0)
		pre:SetPos(pos)
		self.CellPos[#self.CellPos + 1] = pos
		self.CellList[#self.CellList + 1] = pre
	end

end
function C:CloseCellFD()
	if self.CellList then
		for k,v in ipairs(self.CellList) do
			v:OnDestroy()
		end
	end
	self.CellList = {}
end

function C:kpshb_model_task_change_msg()
	self:RefreshJD()
end
function C:crr_level_state_change_msg()
	self.wc_lv = M.GetCurTaskFinishLv()
	if self.xz_lv < self.wc_lv then
		self.xz_lv = self.wc_lv
		self.anim_state = KPSHBLotteryPanel.AnimState.AS_Null
		self.cj_btn.gameObject:SetActive(true)
	end
	self:MyRefresh()
end

function C:GetIndex(index)
	return self.index_list[index]
end

function C:OnDJClick(cfg)
	if self.anim_state == KPSHBLotteryPanel.AnimState.AS_Null then
		if cfg.index ~= self.xz_lv then
			self.xz_lv = cfg.index
			self:MyRefresh()
		end
	end
end

function C:OnBackClick()
	self:MyExit()
end

function C:buyu_spend_lottery_task_award(_, data)
	dump(data, "<color=white>buyu_spend_lottery_task_award</color>")
	if data.result == 0 then
		self.award_index = C.GetIndexByAward(data.award_list[1], self.config)
		if self.index_list[self.index] ~= self.award_index then
			for i = 1, self.cell_num do
				if self.index_list[i] == self.award_index then
					self.index_list[i],self.index_list[self.index] = self.index_list[self.index],self.index_list[i]
					break
				end
			end
			for i = 1, self.cell_num do
				self.CellList[i]:UpdateData(self.config[self.index_list[i]])
			end
		end

		self:AnimShowAward()
	else
		HintPanel.ErrorMsg(data.result)
	end
end

function C:SendGetTaskAward()
	Network.SendRequest("get_task_award_new", {award_progress_lv = self.xz_lv, id = M.GetCurrTaskID()}, "发送请求")
end

function C:ShowAwardBrocast()
	self.isPlayAnim = false
	self:TryToShow()
end

function C:OnGetClick(index)
	if self.anim_state == KPSHBLotteryPanel.AnimState.AS_Wait then
		dump(self.config[self:GetIndex(index)], "<color=red>抽奖 </color>")
		self.index = index
		self.CellList[index]:SetSelect()
		if isDebug then
			self.award_index = 1
			if self.index_list[self.index] ~= self.award_index then
				for i = 1, self.cell_num do
					if self.index_list[i] == self.award_index then
						self.index_list[i],self.index_list[self.index] = self.index_list[self.index],self.index_list[i]
						break
					end
				end
				for i = 1, self.cell_num do
					self.CellList[i]:UpdateData(self.config[self.index_list[i]])
				end
			end
			self:AnimShowAward()
		else
			self:SendGetTaskAward()
		end
	else
		print("<color=red>抽奖异常 <<<<<<<<< </color>")
		dump(self.anim_state)
	end
end

-- 动画
function C:AnimBegin()
	self.isPlayAnim = true
	self.cj_btn.gameObject:SetActive(false)
	self.anim_state = KPSHBLotteryPanel.AnimState.AS_Begin

	self.seq = DoTweenSequence.Create()
	for i = 1, self.cell_num do
		self.CellList[i]:SetBack()
		self.seq:Append(self.CellList[i].transform:DOLocalMove(Vector3.zero, 0.2):SetEase(DG.Tweening.Ease.InQuint))
		self.seq:AppendInterval(0.1)
		self.seq:Append(self.CellList[i].transform:DOLocalMove(self.CellPos[i], 0.2):SetEase(DG.Tweening.Ease.InQuint))
		self.seq:AppendInterval(-0.5)
	end
	self.seq:AppendInterval(0.5)
	self.seq:OnKill(function ()
		self.seq = nil
		self:AnimTheCard()
	end)
	self:RefreshHint()
end
-- 动画
function C:AnimTheCard()
	self.anim_state = KPSHBLotteryPanel.AnimState.AS_TheCard
	
	for i = 1, self.cell_num do
		self.CellList[i].hint.gameObject:SetActive(true)
		self.CellList[i]:SetBox(true)
	end
	self.anim_state = KPSHBLotteryPanel.AnimState.AS_Wait
	self:RefreshHint()
end

-- 开奖动画
function C:AnimShowAward()
	self:RefreshHint()
	self.anim_state = KPSHBLotteryPanel.AnimState.AS_AnimShowAward
	for i = 1, self.cell_num do
		self.CellList[i].hint.gameObject:SetActive(false)
	end
	self.fp_seq = GameComAnimTool.PlayShowAndHideAndCall(self.transform, "com_hongbao_fanpai_activity_by3d_kpshb", self.CellList[self.index].transform.position, 1, 0.7, function ()
		self.fp_seq = nil
		self:ShowAward()
	end)
end

function C:ShowAward()
	if not self.CellList[self.index] then
		self.isPlayAnim = false
		self:TryToShow()
		return
	end
	self.anim_state = KPSHBLotteryPanel.AnimState.AS_Null

	self.CellList[self.index].fx_chixu.gameObject:SetActive(true)

	self.cj_btn.gameObject:SetActive(true)

	for i = 1, self.cell_num do
		self.CellList[i].hint.gameObject:SetActive(false)
		self.CellList[i]:SetFront()
	end
	self.isPlayAnim = false
	self:TryToShow()
end

function C:on_background_msg()
	if self.anim_state == KPSHBLotteryPanel.AnimState.AS_TheCard
		or self.anim_state == KPSHBLotteryPanel.AnimState.AS_Beginor
		or self.anim_state == KPSHBLotteryPanel.AnimState.AS_Wait then
		for i = 1, self.cell_num do
			self.CellList[i]:SetPos(self.CellPos[i])
			self.CellList[i]:SetBack()
			self.CellList[i]:SetBox(true)
		end
		self.anim_state = KPSHBLotteryPanel.AnimState.AS_Wait
		self:RefreshHint()
	else
		self:ShowAward()
	end
end

function C:on_backgroundReturn_msg()
	
end

function C.GetIndexByAward(award,config)
	dump(award)
	dump(config)
	for i,v in ipairs(config) do
	    if tonumber(v) == tonumber(award.asset_value) then
			return i
		end
	end
	return 1
end

function C:ShowHelpPanel()
	KPSHBSMPrefabPanel.Create() 
end

function C:OnAssetChange(data)
	if data.change_type and data.change_type == "buyu_fire_award_hongbao_task" then
		self.Award_Data = data
		self:TryToShow()
	end
end

function C:TryToShow()
	if self.Award_Data and not self.isPlayAnim then
		self.Award_Data.callback = function ()
			self:MyExit()
			BY3DKPSHBManager.GuidePlayerGoGJC()
		end
		Event.Brocast("AssetGet",self.Award_Data)
		self.Award_Data = nil 
		Event.Brocast("kpshb_close_jl_msg")	
	end 

	self:MyExit()
end
