-- 创建时间:2019-01-03

local basefunc = require "Game.Common.basefunc"

OperatorActivityDJPanel = basefunc.class()

local C = OperatorActivityDJPanel

C.name = "OperatorActivityDJPanel"
local DJAnimState=
{
	DJAS_Node = "空闲",
	DJAS_Begin = "动画开始",
	DJAS_End = "动画结束",
	DJAS_BigShow = "大奖展示",
}
local award_count = 6
local instance
function C.Create()
	instance = C.New()
	return instance
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["activity_refresh_data_msg"] = basefunc.handler(self, self.activity_refresh_data_msg)
    self.lister["fg_get_activity_award_response"] = basefunc.handler(self, self.on_fg_get_activity_award_response)
	self.lister["activity_fp_msg"] = basefunc.handler(self, self.on_activity_fp_msg)
	self.lister["logic_activity_fg_signup_msg"] = basefunc.handler(self, self.on_activity_fg_signup_msg)
	self.lister["logic_activity_fg_join_msg"] = basefunc.handler(self, self.on_activity_fg_join_msg)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyClose()
	self:MyExit()
end

function C:MyExit()
	if self.curSoundKey then
		local csk = self.curSoundKey
		soundMgr:CloseLoopSound(csk)
		self.curSoundKey = nil
	end
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:ctor()

	ExtPanel.ExtMsg(self)

	local parent = GameObject.Find("Canvas/LayerLv4").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj

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
	self.Icon_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:OnOpenClick()
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

	self.Rect1.gameObject:SetActive(false)
	self.Rect2.gameObject:SetActive(false)

	self:MyRefresh()
	Event.Brocast("global_sysqx_uichange_msg", {key="djhb", panelSelf=self})
end

function C:activity_refresh_data_msg(data)
	local pp = OperatorActivityLogic.GetData()
	self.data_map = {}
	for k,v in ipairs(pp.activity_data) do
		self.data_map[v.key] = v.value
	end
	if self.anim_state == DJAnimState.DJAS_Node and not self.is_send then
		self:RefreshState()
	end
end

function C:UpdateUI()
	for i=1, award_count do
		local item = GameItemModel.GetItemToKey(self.activity_data.activity_award[i][1].asset_type)
		local value = self.activity_data.activity_award[i][1].value
		if item.item_key == "shop_gold_sum" then
			self.award_txt[i].text = "x" .. StringHelper.ToRedNum(value / 100)
		else
			self.award_txt[i].text = "x" .. value
		end
		GetTextureExtend(self.awardicon_img[i], item.image, item.is_local_icon)
		if self.activity_data.activity_parm[i].is_big == 1 then
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

function C:IsBigUI()
	if self.Rect1.gameObject.activeSelf then
		return true
	end
	return false
end

function C:MyRefresh()
	if self.curSoundKey then
		local csk = self.curSoundKey
		soundMgr:CloseLoopSound(csk)
		self.curSoundKey = nil
	end

	local pp = OperatorActivityLogic.GetData()
	self.activity_data = OperatorActivityModel.GetActivity(pp.game_id, 1)
	self.data_map = {}
	for k,v in ipairs(pp.activity_data) do
		self.data_map[v.key] = v.value
	end

	self:UpdateUI()
end

function C:RefreshState()
	local pp = OperatorActivityLogic.GetData()
	self.Rect2.gameObject:SetActive(self.data_map["round"] < self.data_map["max_round"])

	self.jt_no.gameObject:SetActive(true)
	self.jt_hi.gameObject:SetActive(false)
	self.hint_txt.text = self.data_map["cur_process"] .. "/" .. self.data_map["max_process"]
	if self.data_map["round"] >= self.data_map["max_round"] then
		self.runout.gameObject:SetActive(true)
		self.getaward_btn.gameObject:SetActive(false)
		self.getawarding.gameObject:SetActive(false)
		self.getaward_no.gameObject:SetActive(false)
		self.RedHint.gameObject:SetActive(false)
		self.count_txt.gameObject:SetActive(false)
		self.tip_txt.text = "本次活动已抽满" .. self.data_map["max_round"] .. "次\n请下次再来"
	elseif self.data_map["cur_process"] >= self.data_map["max_process"] then
		self.getaward_btn.gameObject:SetActive(true)
		self.getawarding.gameObject:SetActive(false)
		self.getaward_no.gameObject:SetActive(false)
		self.runout.gameObject:SetActive(false)
		self.RedHint.gameObject:SetActive(true)
		self.count_txt.gameObject:SetActive(true)
		self.count_txt.text = "还可抽奖" .. (self.data_map["max_round"] - self.data_map["round"]) .. "次"
	else
		self.getaward_btn.gameObject:SetActive(false)
		self.getawarding.gameObject:SetActive(false)
		self.getaward_no.gameObject:SetActive(true)
		self.runout.gameObject:SetActive(false)
		if pp and not OperatorActivityModel.IsActivated(pp.game_id, 1) then
			self.getaward_no_txt.text = "活动已结束"
		else
			self.getaward_no_txt.text = "胜利" .. self.data_map["max_process"] .. "次抽奖\n已完成" .. self.data_map["cur_process"] .. "/" .. self.data_map["max_process"]
		end
		self.count_txt.gameObject:SetActive(true)
		self.count_txt.text = "还可抽奖" .. (self.data_map["max_round"] - self.data_map["round"]) .. "次"
		self.RedHint.gameObject:SetActive(false)
	end
end

function C:OnBackClick()
	if self.anim_state == DJAnimState.DJAS_Node then
		self.Rect1.gameObject:SetActive(false)
	end

	self.Rect2.gameObject:SetActive(self.data_map["round"] < self.data_map["max_round"])
end

function C:OnOpenClick()
	self.Rect1.gameObject:SetActive(true)
end

function C:on_activity_fp_msg()
	-- self.Rect2.gameObject:SetActive(true)
end

function C:on_fg_get_activity_award_response(_, data)
	if data.result == 0 then
		self.selectIndex = data.data
		print("self.selectIndex = " .. self.selectIndex)
		self.anim_state = DJAnimState.DJAS_Node
		self:BeginRotaAnim()
	else
		HintPanel.ErrorMsg(data.result)
	end
	self.is_send = false
end
function C:OnGetawardClick()
	self.is_send = true
	Network.SendRequest("fg_get_activity_award", nil, "发送请求")
end

-- 开始抽奖动画
function C:BeginRotaAnim()
	self.zhuangpan_glow.gameObject:SetActive(false)
	if self.curSoundKey then
		soundMgr:CloseLoopSound(self.curSoundKey)
		self.curSoundKey = nil
	end
	self.curSoundKey = ExtendSoundManager.PlaySound(audio_config.game.bgm_duijihongbao.audio_name, 1, function ()
		self.curSoundKey = nil
	end)

	self.anim_state = DJAnimState.DJAS_Begin
	self.getaward_btn.gameObject:SetActive(false)
	self.getawarding.gameObject:SetActive(true)
	self.getaward_no.gameObject:SetActive(false)
	self.jt_no.gameObject:SetActive(false)
	self.jt_hi.gameObject:SetActive(true)
	self.rotaguang_node.gameObject:SetActive(true)

	local rota = -360 * 16 - 60 * (self.selectIndex-1)

	local seq = DG.Tweening.DOTween.Sequence()
	local tweenKey = DOTweenManager.AddTweenToStop(seq)
	seq:Append(self.rota_node:DORotate( Vector3.New(0, 0 , rota), 6, DG.Tweening.RotateMode.FastBeyond360):SetEase(DG.Tweening.Ease.InOutCubic))
	seq:Join(self.rotaguang_node:DORotate( Vector3.New(0, 0 , rota), 6, DG.Tweening.RotateMode.FastBeyond360):SetEase(DG.Tweening.Ease.InOutCubic))
	seq:OnKill(function ()
		DOTweenManager.RemoveStopTween(tweenKey)
		if self.anim_state == DJAnimState.DJAS_Begin and IsEquals(self.rota_node) then
			self.rota_node.localRotation = Quaternion:SetEuler(0, 0, rota)
			self:EndRotaAnim()
		end
	end)	
end
-- 结束抽奖动画
function C:EndRotaAnim()
	self.rotaguang_node.gameObject:SetActive(false)

	if self.activity_data.activity_parm[self.selectIndex].is_big == 1 then
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
function C:EndBigShowAnim()
	self.zhuangpan_zhongjiang.gameObject:SetActive(false)
	self:ShowAward()
end

-- 显示抽奖
function C:ShowAward()
	self.zhuangpan_glow.gameObject:SetActive(true)
	self.anim_state = DJAnimState.DJAS_Node
	self:RefreshState()

    Event.Brocast("AssetGet",{data = {{asset_type=self.activity_data.activity_award[self.selectIndex][1].asset_type, value=self.activity_data.activity_award[self.selectIndex][1].value}}})	
end

function C:on_activity_fg_signup_msg()
	if self.gameObject then
		self.gameObject:SetActive(false)
	end
end

function C:on_activity_fg_join_msg()
	if self.gameObject then
		self.gameObject:SetActive(true)
	end
end
