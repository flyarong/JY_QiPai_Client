local basefunc = require "Game/Common/basefunc"

local isDebug = false

CPL_LJYJCFKLotteryPanel = basefunc.class()
local C = CPL_LJYJCFKLotteryPanel
C.name = "CPL_LJYJCFKLotteryPanel"
local M = CPL_LJYJCFKManager


local instance
-- 动画状态
CPL_LJYJCFKLotteryPanel.AnimState = 
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

    if not instance then
        instance = C.New(data, parent)
    else
        instance:MyRefresh()
    end
    return instance
    --return C.New(data, parent)
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

    self.lister["cpl_ljyjcfk_get_task_award_response"] = basefunc.handler(self,self.get_task_award_response)
	self.lister["cpl_ljyjcfk_refresh"] = basefunc.handler(self, self.cpl_ljyjcfk_refresh)

    self.lister["AssetChange"] = basefunc.handler(self, self.OnAssetChange)
    self.lister["ExitScene"] = basefunc.handler(self, self.MyExit)
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
    instance = nil
	
end

function C:OnDestroy()
	self:MyExit()
end

function C:ctor(data, parent)

	ExtPanel.ExtMsg(self)

	self.can_show_award = true
	parent = parent or GameObject.Find("Canvas/LayerLv3").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	self:MakeLister()
	self:AddMsgListener()
	self.cell_num = 3
	self.isPlayAnim = false
	self.data = data

	self:InitUI()
end

function C:InitUI()
	self.task_data = M.GetData()
	if self.task_data.need_process == self.task_data.now_process then
		self.wc_lv = self.task_data.now_lv
	else
		self.wc_lv = self.task_data.now_lv - 1
	end
	if self.wc_lv > 0 then
		self.xz_lv = self.wc_lv
	else
		self.xz_lv = 1
	end
	self.anim_state = CPL_LJYJCFKLotteryPanel.AnimState.AS_Null
	self.index_list = {}

	self.cj_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		if self.xz_lv > self.wc_lv then
			return
		end

		self:AnimBegin()
	end)

	self.close_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		
		if instance then
			instance:MyExit()
		end
		 
    end)
    self.hint_anim = self.hint_txt.transform:GetComponent("Animator")

	self:MyRefresh()
end

function C:MyRefresh()
	self:RefreshHint()
	self:RefreshFD()
end

function C:RefreshHint()
	if not IsEquals(self.gameObject) then return end
	self.hint_anim:Play("NoPlayAnimation",-1,0)
	if self.anim_state == CPL_LJYJCFKLotteryPanel.AnimState.AS_Null then
		if self.xz_lv > self.wc_lv then
			self:RefreshJD()
		else
			self.hint_anim:Play("hintAnimation",-1,0)
			self.hint_txt.text = "点击立即抽取福卡"
		end
	else
		if self.anim_state == CPL_LJYJCFKLotteryPanel.AnimState.AS_Wait then
			self.hint_txt.text = "请从三个中选择一个领取"
		else
			self.hint_txt.text = ""
		end
	end
end
function C:RefreshJD()
	if self.anim_state == CPL_LJYJCFKLotteryPanel.AnimState.AS_Null and self.xz_lv > self.wc_lv then
		self.hint_txt.text = string.format("再赢金<color=#fffd00ff>%s</color>，可抽取<color=#fffd00ff>%s福卡！</color>", StringHelper.ToCash(self.task_data.need_process - self.task_data.now_process),M.config.base[self.task_data.now_lv].hb[3])	
	end
end
-- 中间福袋显示
function C:RefreshFD()
	self:CloseCellFD()
	self.index_list = {}
	self.config = M.GetHBRateConfigByIDIndex(self.xz_lv)
	dump({self.xz_lv,self.config},"<color=yellow>CPL抽福卡</color>")
	self.cell_num = #self.config
	-- 随机显示
	-- self.index_list = MathExtend.RandomGroup(self.cell_num)
	-- 顺序显示
	for i=1,#self.config do
		self.index_list[#self.index_list + 1] = i
	end

	self.CellPos = {}
	for i = 1, #self.config do
		local pre = CPL_LJYJCFKLotteryPrefab.Create(self.center, self.config[self:GetIndex(i)], self.OnGetClick, self, i)
		local pos = Vector3.New(-400 + 400 * (i - 1), 0, 0)
		pre:SetPos(pos)
		self.CellPos[#self.CellPos + 1] = pos
		self.CellList[#self.CellList + 1] = pre
		
	end
	dump(self.CellList,"<color=red>CellList</color>")

	self.center.gameObject.name = "LJYJCFKLotteryPanel_Guide"

	Event.Brocast("WZQGuide_Check",{guide = 2 ,guide_step =3})
	Event.Brocast("WZQGuide_Check",{guide = 3 ,guide_step =3})

end
function C:CloseCellFD()
	if self.CellList then
		for k,v in ipairs(self.CellList) do
			v:OnDestroy()
		end
	end
	self.CellList = {}
end

function C:cpl_ljyjcfk_refresh()
	if self.anim_state ~= CPL_LJYJCFKLotteryPanel.AnimState.AS_Null then
		return
	end
	self.wc_lv = M.GetCurTaskFinishLv()
	if self.xz_lv < self.wc_lv then
		self.xz_lv = self.wc_lv
		self.anim_state = CPL_LJYJCFKLotteryPanel.AnimState.AS_Null
		self.cj_btn.gameObject:SetActive(true)
	end
	self:MyRefresh()
end

function C:GetIndex(index)
	return self.index_list[index]
end

function C:OnDJClick(cfg)
	if self.anim_state == CPL_LJYJCFKLotteryPanel.AnimState.AS_Null then
		if cfg.index ~= self.xz_lv then
			self.xz_lv = cfg.index
			self:MyRefresh()
		end
	end
end

function C:OnBackClick()
	self:MyExit()
end

function C:get_task_award_response(data)
	dump(data, "<color=white>get_task_award_response</color>")
	if data.result == 0 then
		
		self:MyExit()
	else
		HintPanel.ErrorMsg(data.result)
	end
end

function C:SendGetTaskAward()
	Network.SendRequest("get_task_award", {id = M.task_id}, "发送请求")
end

function C:ShowAwardBrocast()
	self.isPlayAnim = false
	self:TryToShow()
end

function C:OnGetClick(index)
	if self.anim_state == CPL_LJYJCFKLotteryPanel.AnimState.AS_Wait then
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
	self.anim_state = CPL_LJYJCFKLotteryPanel.AnimState.AS_Begin

	self.seq = DoTweenSequence.Create({dotweenLayerKey = "cpl_ljyjcfk"})
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
	self.anim_state = CPL_LJYJCFKLotteryPanel.AnimState.AS_TheCard
	
	for i = 1, self.cell_num do
		self.CellList[i].hint.gameObject:SetActive(true)
		self.CellList[i]:SetBox(true)
	end
	self.anim_state = CPL_LJYJCFKLotteryPanel.AnimState.AS_Wait
	self:RefreshHint()
end

-- 开奖动画
function C:AnimShowAward()
	self:RefreshHint()
	self.anim_state = CPL_LJYJCFKLotteryPanel.AnimState.AS_AnimShowAward
	for i = 1, self.cell_num do
		self.CellList[i].hint.gameObject:SetActive(false)
	end
	self.fp_seq = GameComAnimTool.PlayShowAndHideAndCall(self.transform, "com_hongbao_fanpai", self.CellList[self.index].transform.position, 1, 0.7, function ()
		self.fp_seq = nil
		self:ShowAward()
	end)
end

function C:ShowAward()
	if not self.CellList[self.index] or not IsEquals(self.CellList[self.index].fx_chixu) then
		self.isPlayAnim = false
		self:TryToShow()
		return
	end
	self.anim_state = CPL_LJYJCFKLotteryPanel.AnimState.AS_Null

	if IsEquals(self.CellList[self.index].fx_chixu) then
		self.CellList[self.index].fx_chixu.gameObject:SetActive(true)
	end

	self.cj_btn.gameObject:SetActive(true)

	for i = 1, self.cell_num do
		self.CellList[i].hint.gameObject:SetActive(false)
		self.CellList[i]:SetFront()
	end
	self.isPlayAnim = false
	self:TryToShow()
end

function C:on_background_msg()
	if self.anim_state == CPL_LJYJCFKLotteryPanel.AnimState.AS_TheCard
		or self.anim_state == CPL_LJYJCFKLotteryPanel.AnimState.AS_Beginor
		or self.anim_state == CPL_LJYJCFKLotteryPanel.AnimState.AS_Wait then
		for i = 1, self.cell_num do
			self.CellList[i]:SetPos(self.CellPos[i])
			self.CellList[i]:SetBack()
			self.CellList[i]:SetBox(true)
		end
		self.anim_state = CPL_LJYJCFKLotteryPanel.AnimState.AS_Wait
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
	    if tonumber(v) == tonumber(award.value / 100) then
			return i
		end
	end
	return 1
end

function C:OnAssetChange(data)
	if data.change_type and data.change_type == "task_p_wqp_minigame_cumulative_wingold" then
		self.Award_Data = data
		self.award_index = C.GetIndexByAward(data.data[1], self.config)
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
		self.data.cur_award_status = 2
	end
end

function C:TryToShow()
	if self.Award_Data and not self.isPlayAnim then
		self.Award_Data.callback = function ()
			self:MyExit()
		end
		Event.Brocast("AssetGet",self.Award_Data)
		self.Award_Data = nil 
	end 
end
