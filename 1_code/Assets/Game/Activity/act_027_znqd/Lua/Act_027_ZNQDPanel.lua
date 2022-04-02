-- 创建时间:2020-08-14
-- Panel:Act_027_ZNQDPanel
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

Act_027_ZNQDPanel = basefunc.class()
local C = Act_027_ZNQDPanel
C.name = "Act_027_ZNQDPanel"
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


function C.Create(parent)
	return C.New(parent)
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
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:ctor(parent)
	ExtPanel.ExtMsg(self)
	local parent = parent or GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	self:InitAwardUI(config[self:GetCurVIPLevel()].award,self.AwardContent)
end

function C:InitUI()
	self.Btn_btn.onClick:AddListener(
		function()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
			if M.IsBacker() then
				Act_027_ZNFKLookBackPanel.Create()
			else
				
			end
		end
	)
	self:MyRefresh()
end

function C:MyRefresh()
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
		b.transform:GetComponent("Button").onClick:AddListener(
			function ()
			LittleTips.Create(award_config[i].tips)	
			end
		)
		self.award_ui[#self.award_ui + 1] = temp_ui
	end
end

function C:GetCurVIPLevel()
	return Act_027_ZNFKManager.GetLevel() or 1
end

function C:on_model_task_change_msg(_,data)

end

function C:OnDestroy()
	self:MyExit()
end