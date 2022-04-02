-- 创建时间:2021-03-03
-- Panel:RXCQMoneyItem
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

RXCQMoneyItem = basefunc.class()
local C = RXCQMoneyItem
C.name = "RXCQMoneyItem"
--用具体金币作为判断 决定了图片
RXCQMoneyItem.img_config = {
	2000,50000,1000000,10000000
}
local img_config = RXCQMoneyItem.img_config
--用倍率作为判断 决定了颜色
RXCQMoneyItem.color_config = {
	0.1,0.3,1,10
}
local color_config = RXCQMoneyItem.color_config
local config = {
	[1] = {img = "djdl_icon_1",color = "#26C0D2"},
	[2] = {img = "djdl_icon_2",color = "#21B336"}, 
	[3] = {img = "djdl_icon_5",color = "#E9CF3F"}, 
	[4] = {img = "djdl_icon_3",color = "#FF8A00"}, 
	[5] = {img = "djdl_icon_4",color = "#D02D2D"}, 
}

function C.Create(parent,money,player_zero_pos,backcall,target_pos)
	return C.New(parent,money,player_zero_pos,backcall,target_pos)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	if self.Timer then
		self.Timer:Stop()
	end
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:OnDestroy()
	self:MyExit()
end

function C:MyClose()
	self:MyExit()
end

function C:ctor(parent,money,player_zero_pos,backcall,target_pos)
	ExtPanel.ExtMsg(self)
	local parent = parent or GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	self.money = money
	self.target_pos = target_pos
	self.player_zero_pos = player_zero_pos
	self.backcall = backcall
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	RXCQModel.PlayAudioLimit("rxcq_itemdrop")
	--ExtendSoundManager.PlaySound(audio_config.rxcq.rxcq_itemdrop.audio_name)
end

function C:InitUI()
	local rate = self.money / rxcq_main_config.base[RXCQModel.BetIndex].Bet
	self.main_img.sprite = GetTexture(config[1].img)
	for i = #config,2,-1 do
		if self.money > img_config[i - 1] then
			self.main_img.sprite = GetTexture(config[i].img)
			break
		end
	end

	self.num_txt.text = string.format("<color=%s>"..self.money.."</color>",config[1].color)
	for i = #config,2,-1 do
		if rate > color_config[i - 1] then
			self.num_txt.text = string.format("<color=%s>"..self.money.."</color>",config[i].color)
			break
		end
	end

	local seq1 = DoTweenSequence.Create({dotweenLayerKey = "rxcq"})
	seq1:Append(self.transform:DOLocalMove(self.target_pos, 0.1):SetEase(DG.Tweening.Ease.Linear))
	self.Timer = Timer.New(
		function()
			self.seq = DoTweenSequence.Create({dotweenLayerKey = "rxcq"})
			RXCQModel.PlayAudioLimit("rxcq_itemrecovery")
			self.seq:Append(self.transform:DOLocalMove(self.money_target_pos or RXCQFightPrefab.player_zero_pos, 0.3 * 1/RXCQModel.GetAutoSpeed()):SetEase(DG.Tweening.Ease.Linear))
			self.seq:AppendCallback(function ()
				Event.Brocast("rxcq_moneyitem_fly_over",{money = self.money})
				if self.backcall then
					self.backcall()
				end
				self:MyExit()
			end)
		end
	,1,1)
	self.Timer:Start()
	--RXCQModel.AddTimers(self.Timer)
	self:MyRefresh()
end

function C:ForceSetTargetPos()
	self.money_target_pos = self.player_zero_pos
end

function C:MyRefresh()
end
