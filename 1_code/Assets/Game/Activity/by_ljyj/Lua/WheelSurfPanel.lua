-- 创建时间:2019-01-03
local basefunc = require "Game.Common.basefunc"
WheelSurfPanel = basefunc.class()
local M = WheelSurfPanel
M.name = "WheelSurfPanel"

local DJAnimState=
{
	DJAS_Node = "空闲",
	DJAS_Begin = "动画开始",
	DJAS_End = "动画结束",
	DJAS_BigShow = "大奖展示",
}
local award_count = 6
function M.Create(data,config)
	M.New(data,config)
end

function M:AddMsgListener(data)
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function M:MakeLister()
    self.lister = {}
    self.lister["asset_get_fishing_task_chou_jiang"] = basefunc.handler(self, self.on_asset_get_fishing_task_chou_jiang)
end

function M:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function M:MyClose()
	self:MyExit()
end

function M:MyExit()
	if self.curSoundKey then
		soundMgr:CloseLoopSound(self.curSoundKey)
		self.curSoundKey = nil
	end
	self:RemoveListener()
	self:ShowAwardBrocast()

	destroy(self.gameObject)
end

function M:ctor(data,config)

	ExtPanel.ExtMsg(self)

	self.can_show_award = true
	local parent = GameObject.Find("Canvas/LayerLv5").transform
	local obj = newObject(M.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	self.data = data
	self.config = config

	self:MakeLister()
	self:AddMsgListener()
	LuaHelper.GeneratingVar(self.transform, self)

	self.back_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:OnBackClick()
	end)

	self.getaward_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:OnGetawardClick()
	end)

	self.anim_state = DJAnimState.DJAS_Node

	self.awardicon_img = {}
	self.award_txt = {}
	self.bigaward = {}
	for i=1, award_count do
		self.awardicon_img[i] = self["rect"..i]:Find("awardicon"):GetComponent("Image")
		self.award_txt[i] = self["rect"..i]:Find("awardtext"):GetComponent("Text")
		self.bigaward[i] = self["bigaward"..i]
	end
	self:MyRefresh()
end

function M:UpdateUI()
	for i=1, award_count do
		local item = GameItemModel.GetItemToKey(self.config[i].asset_type)
		local value = self.config[i].value
		if item.item_key == "shop_gold_sum" then
			self.award_txt[i].text = "x" .. StringHelper.ToRedNum(value / 100)
		else
			self.award_txt[i].text = "x" .. value
		end
		GetTextureExtend(self.awardicon_img[i], item.image, item.is_local_icon)
		if self.config[i].is_big and self.config[i].is_big == 1 then
			self.bigaward[i].gameObject:SetActive(true)
		else
			self.bigaward[i].gameObject:SetActive(false)
		end
	end
	self.zhuangpan_glow.gameObject:SetActive(true)
	self.zhuangpan_zhongjiang.gameObject:SetActive(false)
	self.rotaguang_node.gameObject:SetActive(false)

	self:RefreshState()
end

function M:MyRefresh()
	if self.curSoundKey then
		soundMgr:CloseLoopSound(self.curSoundKey)
		self.curSoundKey = nil
	end
	self:UpdateUI()
end

function M:RefreshState()
	if self.data.cur_award_status == 1 then
		self.getaward_btn.transform:GetComponent("Image").color = Color.New(1,1,1)
		self.getaward_btn.enabled = true
	else
		self.getaward_btn.transform:GetComponent("Image").color = Color.New(0.7,0.7,0.7)
		self.getaward_btn.enabled = false
	end
	self.getawarding.gameObject:SetActive(false)
end

function M:OnBackClick()
	self:MyClose()
end

function M:on_asset_get_fishing_task_chou_jiang(data)
	if data.change_type == "fishing_task_chou_jiang" then
		self.selectIndex = M.GetIndexByAward(data.data[1], self.config)
		print("self.selectIndex = " .. self.selectIndex)
		self.anim_state = DJAnimState.DJAS_Node
		self:BeginRotaAnim()
	end
	self.data.cur_award_status = 2
	self.is_send = false
end
function M:OnGetawardClick()
	self.is_send = true
	local data = {}
	data.award_progress_lv = self.data.now_level
	data.id = self.data.task_id
	dump(data, "<color=yellow>发送：：：</color>")
	Network.SendRequest("get_task_award_new", data, "发送请求")
end

-- 开始抽奖动画
function M:BeginRotaAnim()
	self.zhuangpan_glow.gameObject:SetActive(false)
	if self.curSoundKey then
		soundMgr:CloseLoopSound(self.curSoundKey)
		self.curSoundKey = nil
	end
	self.curSoundKey = ExtendSoundManager.PlaySound(audio_config.game.bgm_duijihongbao.audio_name, 1, function ()
		self.curSoundKey = nil
	end)

	self.anim_state = DJAnimState.DJAS_Begin
	-- self.getaward_btn.gameObject:SetActive(false)
	self.getawarding.gameObject:SetActive(true)
	self.jt_no.gameObject:SetActive(false)
	self.jt_hi.gameObject:SetActive(true)
	self.rotaguang_node.gameObject:SetActive(true)

	local rota = -360 * 16 - 60 * (self.selectIndex-1)

	local seq = DG.Tweening.DOTween.Sequence()
	local tweenKey = DOTweenManager.AddTweenToStop(seq)
	seq:Append(self.rota_node:DORotate( Vector3.New(0, 0 , rota), 6, DG.Tweening.RotateMode.FastBeyond360):SetEase(DG.Tweening.Ease.InOutCubic))
	seq:Join(self.rotaguang_node:DORotate( Vector3.New(0, 0 , rota), 6, DG.Tweening.RotateMode.FastBeyond360):SetEase(DG.Tweening.Ease.InOutCubic))
	seq:OnComplete(function ()
		self:EndRotaAnim()
	end)
	seq:OnKill(function ()
		DOTweenManager.RemoveStopTween(tweenKey)
		if self.anim_state == DJAnimState.DJAS_Begin and IsEquals(self.rota_node) then
			self.rota_node.localRotation = Quaternion:SetEuler(0, 0, rota)
			self:EndRotaAnim()
		end
	end)	
end
-- 结束抽奖动画
function M:EndRotaAnim()
	self.rotaguang_node.gameObject:SetActive(false)
	if self.config[self.selectIndex] and self.config[self.selectIndex].is_big and self.config[self.selectIndex].is_big == 1 then
		self.anim_state = DJAnimState.DJAS_BigShow
		self.zhuangpan_zhongjiang.gameObject:SetActive(true)
		self.zhuangpan_zhongjiang.transform.localRotation = Quaternion:SetEuler(0, 0, - 60 * (self.selectIndex-1))

		ExtendSoundManager.PlaySound(audio_config.game.bgm_duijihongbaodajiang.audio_name, 1)

		local seq = DG.Tweening.DOTween.Sequence()
		local tweenKey = DOTweenManager.AddTweenToStop(seq)
		seq:AppendInterval(2)
		seq:OnComplete(function ()
			self:EndBigShowAnim()
		end)
		seq:OnKill(function ()
			DOTweenManager.RemoveStopTween(tweenKey)
			if self.anim_state == DJAnimState.DJAS_BigShow then
				self:EndBigShowAnim()
			end
		end)
	else
		self:ShowAward()
	end
end

-- 结束大奖展示
function M:EndBigShowAnim()
	if IsEquals(self.zhuangpan_zhongjiang) then
	self.zhuangpan_zhongjiang.gameObject:SetActive(false)
	end
	self:ShowAward()
end

-- 显示抽奖
function M:ShowAward()
	self.zhuangpan_glow.gameObject:SetActive(true)
	self.anim_state = DJAnimState.DJAS_Node
	self:RefreshState()
	self:ShowAwardBrocast()
end

function M:ShowAwardBrocast()
	if self.can_show_award and self.selectIndex then
		Event.Brocast("AssetGet",{data = {{asset_type=self.config[self.selectIndex].asset_type, value=self.config[self.selectIndex].value}}})	
		self.can_show_award = false
		self.selectIndex = nil
	end
end

function M.GetIndexByAward(award,config)
	for i,v in ipairs(config) do
		if v.asset_type == award.asset_type and tonumber(v.value) == tonumber(award.value) then
			return i
		end
	end
	return 1
end