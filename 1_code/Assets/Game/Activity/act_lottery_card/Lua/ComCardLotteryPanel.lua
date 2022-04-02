-- 创建时间:2019-06-19
-- Panel:ComCardLotteryPanel
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

ComCardLotteryPanel = basefunc.class()
local C = ComCardLotteryPanel
C.name = "ComCardLotteryPanel"

-- 动画状态
ComCardLotteryPanel.AnimState = 
{
	AS_Begin = "开始",
	AS_TheCard = "魔术手换牌",
	AS_Wait = "等待抽奖",
	AS_AnimShowAward = "翻开奖励",
	AS_ShowAward = "展示奖励",
	AS_End = "结束",
}

function C.Create(data,config, parent)
	return C.New(data,config, parent)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
	self.lister = {}
	self.lister["buyu_spend_lottery_task_award"] = basefunc.handler(self, self.buyu_spend_lottery_task_award)
    self.lister["EnterBackGround"] = basefunc.handler(self, self.on_background_msg)
    self.lister["EnterForeGround"] = basefunc.handler(self, self.on_backgroundReturn_msg)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	if self.seq then
		self.seq:Kill()
		self.seq = nil
	end
	self:RemoveListener()
	self:ShowAwardBrocast()
	destroy(self.gameObject)

	 
end

function C:ctor(data,config, parent)

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
	self.config = config
	self.index_list = MathExtend.RandomGroup(self.cell_num)

	self.CellList = {}
	self.CellPos = {}
	for i = 1, self.cell_num do
		local pre = ComCardLotteryPrefab.Create(self.CenterRect, self.config[self:GetIndex(i)], self.OnGetClick, self, i)
		local pos = Vector3.New(-440 + 440 * (i - 1), 0, 0)
		pre:SetPos(pos)
		self.CellPos[#self.CellPos + 1] = pos
		self.CellList[#self.CellList + 1] = pre
	end
	self.TopNorRect.gameObject:SetActive(true)
	self.TopGetRect.gameObject:SetActive(false)

	self.fx_fanpai = newObject("hongbao_fanpai", self.transform)
	self.fx_chixu = newObject("hongbao_chixu", self.transform)
	self.fx_chixu.transform.localPosition = Vector3.New(0, 18, 0)
	self.fx_fanpai.gameObject:SetActive(false)
	self.fx_chixu.gameObject:SetActive(false)
	self.anim1.gameObject:SetActive(false)

    self.topbutton = self.topbutton:GetComponent("MyButton")
    EventTriggerListener.Get(self.topbutton.gameObject).onClick = basefunc.handler(self, self.OnBackClick)

	self.anim_time = Timer.New(function ()
		self:Update()
	end, 0.1, -1)
	self.anim_time:Start()
	self:InitUI()
end

function C:InitUI()
	self:AnimBegin()
end

function C:Update()

end

function C:GetIndex(index)
	return self.index_list[index]
end

function C:OnBackClick()
	if self.anim_state == ComCardLotteryPanel.AnimState.AS_End then
		self:MyExit()
	end
end

function C:buyu_spend_lottery_task_award(data)
	dump(data, "<color=white>buyu_spend_lottery_task_award</color>")
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

	self.award_data = data.data
	self:AnimShowAward()
	self.data.cur_award_status = 2
end

function C:SendGetTaskAward()
	local data = {}
	data.award_progress_lv = self.data.now_level
	data.id = self.data.task_id
	dump(data, "<color=yellow>发送：：：</color>")
	Network.SendRequest("get_task_award_new", data, "发送请求")
end

function C:ShowAwardBrocast()
	if self.can_show_award and self.award_data then
		Event.Brocast("AssetGet",{data = self.award_data})
		self.award_data = nil
		self.can_show_award = false
	end
end

function C:OnGetClick(index)
	if self.anim_state == ComCardLotteryPanel.AnimState.AS_Wait then
		dump(self.config[self:GetIndex(self.index)], "<color=red>抽奖 </color>")
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
	self.anim_state = ComCardLotteryPanel.AnimState.AS_Begin
	self.TopRect.transform.localScale = Vector3.New(0, 0, 0)
	self.seq = DoTweenSequence.Create()
	self.seq:Join(self.TopRect.transform:DOScale(1, 0.2):SetEase(DG.Tweening.Ease.InQuint))
	for i = 1, self.cell_num do
		self.CellList[i].transform.localScale = Vector3.New(0, 0, 0)
		self.CellList[i].transform.localPosition = Vector3.New(0, 0, 0)
		self.CellList[i]:SetFront()
		self.seq:Join(self.CellList[i].transform:DOLocalMove(self.CellPos[i], 0.2):SetEase(DG.Tweening.Ease.InQuint))
		self.seq:Join(self.CellList[i].transform:DOScale(1, 0.2):SetEase(DG.Tweening.Ease.InQuint))
	end
	self.seq:AppendInterval(1)
	self.seq:OnKill(function ()
		self.seq = nil
		self:AnimTheCard()
	end)
end
-- 动画
function C:AnimTheCard()
	self.anim_state = ComCardLotteryPanel.AnimState.AS_TheCard
	
	self.seq = DoTweenSequence.Create()
	for i = 1, self.cell_num do
		local p = i
		self.seq:Append(self.CellList[p].transform:DORotate(Vector3.New(0, 90.0, 0), 0.2, DG.Tweening.RotateMode.FastBeyond360))
		self.seq:AppendCallback(function ()
			self.CellList[p]:SetBack()
		end)
		self.seq:Append(self.CellList[p].transform:DORotate(Vector3.New(0, 0, 0), 0.2, DG.Tweening.RotateMode.FastBeyond360))
		self.seq:AppendInterval(0.4)
		self.seq:Append(self.CellList[i].transform:DOLocalMove(Vector3.zero, 0.6):SetEase(DG.Tweening.Ease.OutElastic))
		self.seq:Append(self.CellList[i].transform:DOLocalMove(self.CellPos[i], 0.6):SetEase(DG.Tweening.Ease.OutElastic))
		self.seq:AppendInterval(-2)
	end
	self.seq:AppendInterval(2)
	self.seq:OnKill(function ()
		self.seq = nil
		self.anim_state = ComCardLotteryPanel.AnimState.AS_Wait
		for i = 1, self.cell_num do
			self.CellList[i]:SetBox(true)
		end
	end)
end

-- 开奖动画
function C:AnimShowAward()
	self.anim_state = ComCardLotteryPanel.AnimState.AS_AnimShowAward
	self.CellList[self.index]:SetParent(self.ShowRect)

	self.seq = DoTweenSequence.Create()
	self.seq:AppendInterval(0.3)
	if self.index ~= 2 then
		self.seq:Append(self.CellList[self.index].transform:DOLocalMove(Vector3.zero, 0.8))
		self.seq:Join(self.CellList[2].transform:DOLocalMove(self.CellPos[self.index], 0.8))
	end
	self.seq:AppendCallback(function ()
		ExtendSoundManager.PlaySound(audio_config.game.bgm_choudaohongbao.audio_name)
		self.fx_fanpai.gameObject:SetActive(false)
		self.fx_fanpai.gameObject:SetActive(true)
		self.CellList[self.index]:AnimShowAward(1.2)
	end)
	self.seq:AppendInterval(0.5)
	self.seq:AppendCallback(function ()
		self.anim1.gameObject:SetActive(false)
		self.fx_chixu.gameObject:SetActive(false)
		self.fx_chixu.gameObject:SetActive(true)
		for i = 1, self.cell_num do
			if self.index ~= i then
				self.CellList[i]:AnimShowAward(0.8)
			end
		end
	end)
	self.seq:OnKill(function ()
		self.seq = nil
		self:ShowAward()
	end)
end

function C:ShowAward()
	self.anim_state = ComCardLotteryPanel.AnimState.AS_End
	self.TopNorRect.gameObject:SetActive(false)
	self.TopGetRect.gameObject:SetActive(true)
	self.fx_chixu.gameObject:SetActive(true)
	self.anim1.gameObject:SetActive(false)

	local ii = 1
	for i = 1, self.cell_num do
		if self.index ~= i then
			self.CellList[i]:SetPos(self.CellPos[ii])
			self.CellList[i]:SetFront()
			self.CellList[i].transform.localScale = Vector3.New(0.8, 0.8, 0.8)
			self.CellList[i].transform.rotation = Quaternion:SetEuler(0, 0, 0)

			ii = ii + 1
			if ii == 2 then
				ii = ii + 1
			end
		else
			self.CellList[i]:SetPos(self.CellPos[2])
			self.CellList[i]:SetFront()
			self.CellList[i].transform.localScale = Vector3.New(1.2, 1.2, 1.2)
			self.CellList[i].transform.rotation = Quaternion:SetEuler(0, 0, 0)
		end
	end
end

function C:on_background_msg()
	self.fx_fanpai.gameObject:SetActive(false)
	if self.anim_state == ComCardLotteryPanel.AnimState.AS_TheCard or self.anim_state == ComCardLotteryPanel.AnimState.AS_Beginor or self.anim_state == ComCardLotteryPanel.AnimState.AS_Wait then
		for i = 1, self.cell_num do
			self.CellList[i]:SetPos(self.CellPos[i])
			self.CellList[i]:SetBack()
			self.CellList[i]:SetBox(true)
			self.CellList[i].transform.localScale = Vector3.one
			self.CellList[i].transform.rotation = Quaternion:SetEuler(0, 0, 0)
		end
		self.anim_state = ComCardLotteryPanel.AnimState.AS_Wait
	else
		self:ShowAward()
	end
end

function C:on_backgroundReturn_msg()
	
end

function C.GetIndexByAward(award,config)
  for i,v in ipairs(config) do
    if v.asset_type == award.asset_type and tonumber(v.value) == tonumber(award.value) then
      return i
    end
  end
  return 1
end
