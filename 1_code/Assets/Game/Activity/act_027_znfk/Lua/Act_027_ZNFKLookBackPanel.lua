-- 创建时间:2020-08-13
-- Panel:Act_027_ZNFKLookBackPanel
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

Act_027_ZNFKLookBackPanel = basefunc.class()
local C = Act_027_ZNFKLookBackPanel
C.name = "Act_027_ZNFKLookBackPanel"
local M = Act_027_ZNFKManager
local config = {
	[1] = {level = {"VIP0"},award = {[1] = { img = "eznhk_icon_1",txt = "鲸币礼包",tips ="鲸币礼包：最高可获得10万鲸币！",tishi="最高可获得10万鲸币!"}}},
	[2] = {level = {"VIP1、2"},award = { [1] = {img = "eznhk_icon_2",txt = "鲸币宝箱",tips ="鲸币宝箱：最高可获得50万鲸币！",tishi="最高可获得50万鲸币!"}}},
	[3] = {level = {"VIP3、4"},award = {[1] = { img = "eznhk_icon_3",txt = "大额鲸币宝箱",tips ="大额鲸币宝箱：最高可获得200万鲸币！",tishi="最高可获得200万鲸币!"}}},
	[4] = {level = {"VIP5、6、7"},award = { [1] = {img = "eznhk_icon_4",txt = "巨额鲸币宝箱",tips ="巨额鲸币宝箱：最高可获得500万鲸币！",tishi="最高可获得500万鲸币!"}}},
	[5] = {level = {"VIP8、9"},award = {[1] = { img = "eznhk_icon_4",txt = "巨额鲸币宝箱",tips ="巨额鲸币宝箱：最高可获得500万鲸币！"},[2] = { img = "activity_icon_gift201_dlb",txt = "回馈大礼包",tips ="回馈大礼包：保温杯，自动雨伞，笔记本和签字笔，联系客服QQ：4008882620领取！"}}},
	[6] = {level = {"VIP10"},award = {[1] = { img = "eznhk_icon_4",txt = "巨额鲸币宝箱",tips ="巨额鲸币宝箱：最高可获得500万鲸币！"},[2] = { img = "activity_icon_gift201_dlb",txt = "回馈大礼包",tips ="回馈大礼包：保温杯，自动雨伞，笔记本和签字笔，联系客服QQ：4008882620领取！"},[3] = {img = "activity_icon_gift203_jnb",txt = "纯银纪念币",tips ="纯银纪念币：鲸鱼新家园专属纪念币，联系客服QQ：4008882620领取！"}}},
	[7] = {level = {"VIP11、12"},award = {[1] = { img = "eznhk_icon_4",txt = "巨额鲸币宝箱",tips ="巨额鲸币宝箱：最高可获得500万鲸币！"},[2] = { img = "activity_icon_gift201_dlb",txt = "回馈大礼包",tips ="回馈大礼包：保温杯，自动雨伞，笔记本和签字笔，联系客服QQ：4008882620领取！"},[3] = {img = "activity_icon_gift202_zyz",txt = "黄金转运珠",tips ="黄金转运珠：12生肖黄金转运珠（可选），联系客服QQ：4008882620领取！"}}},
}
local vip_config = {{0},{1,2},{3,4},{5,6,7},{8,9},{10},{11,12}}


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
	self.lister["model_task_change_msg"] = basefunc.handler(self,self.on_model_task_change_msg)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	self.Hy:MyExit()
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:ctor()
	ExtPanel.ExtMsg(self)
	local parent = GameObject.Find("Canvas/LayerLv5").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	self.Hy = CommonHYAnim.Create(self.Content,1,true)
	self.Hy:OnIndexCall(
		function(index)
			self:ButtonHideOrShow(index)
		end
	)
	self:MakeLister()
	self:AddMsgListener()
	self:InitAwardUI(config[self:GetCurVIPLevel()].award,self.AwardNode)
	self:InitUI()
	self.str = gameMgr:getMarketPlatform() == "wqp" and "玩棋牌斗地主" or "鲸鱼斗地主"
	self.t1_txt.text = "我第一次进入"..self.str
end

function C:InitUI()
	self.close_btn.onClick:AddListener(
		function()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
			self:MyExit()
		end
	)
	self.left_btn.onClick:AddListener(
		function()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
			self.Hy:GoLast()
		end
	)
	self.right_btn.onClick:AddListener(
		function()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
			self.Hy:GoNext()
		end
	)
	self.share_btn.onClick:AddListener(
		function()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
			self.ZNQ_guang_lookback.gameObject:SetActive(false)
			local b = Act_027_ZNFKSharePrefabMake.Create()
			local data = GameTaskModel.GetTaskDataByID(M.GetTaskID())
			dump(M.GetLevel(),"<color=red>等级+++</color>")
			dump(M.GetTaskID(),"<color=red>任务ID</color>")
			dump(data,"<color=red>任务数据</color>")
			dump(M.IsAwardCanGet(),"<color=red>x</color>")
		end
	)
	self:MyRefresh()
end

function C:ButtonHideOrShow(index)
	self.right_btn.gameObject:SetActive(not (index == 3))
	self.left_btn.gameObject:SetActive(not (index == 1))
end

function C:MyRefresh()
	self:RefreshAwardStatus()
	local data = M.GetData()
	self.first_time_txt.text = os.date("%Y<color=#BD1C1C>年</color>%m<color=#BD1C1C>月</color>%d<color=#BD1C1C>日</color>",data.first_login_time)
	self.day_txt.text = math.floor(((os.time() - data.first_login_time) / 86400))
	self.MaxMoney_txt.text = StringHelper.ToCash(data.most_money)
	self.day1_txt.text = os.date("%Y%m%d",data.most_money_time).."\n我的最高鲸币数："
	self.day2_txt.text = os.date("%Y%m%d",data.once_win_most_time)
	self.WinMoney_txt.text = StringHelper.ToCash(data.once_win_most_win_money)
	self.max_game_name_txt.text = Act_027_ZNFKManager.gameName2Imgs[data.once_win_most_game_name][1]
end

function C:InitAwardUI(award_config,obj)
	self.award_ui = {}
	for i = 1,#award_config do
		local temp_ui = {}
		local b = GameObject.Instantiate(self.MoneyItem,obj.transform)
		b.gameObject:SetActive(true)
		LuaHelper.GeneratingVar(b.transform,temp_ui)
		temp_ui.award_txt.text = award_config[i].txt
		temp_ui.award_img.sprite = GetTexture(award_config[i].img)
		temp_ui.award_img:SetNativeSize()
		self.award_ui[#self.award_ui + 1] = temp_ui
	end
end

function C:GetCurVIPLevel()
	return M.GetLevel() or 1
end

function C:on_model_task_change_msg(_,data)
	if data and data.id == M.GetTaskID() then
		if IsEquals(self.gameObject) then
			for i = 1,#self.award_ui do
				if self.award_ui[i] then
					self:RefreshAwardStatus()
				end
			end
		end
	end
end


function C:RefreshAwardStatus()	
	if IsEquals(self.gameObject) then
		local data = GameTaskModel.GetTaskDataByID(M.GetTaskID())
		for i = 1,#self.award_ui do			
			if data then
				self.award_ui[i].Mask.gameObject:SetActive(data.award_status == 2)
			end
		end
	end
end
