-- 创建时间:2021-08-24
-- Panel:Act_065_ZNFKPanel
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

Act_065_ZNFKPanel = basefunc.class()
local C = Act_065_ZNFKPanel
C.name = "Act_065_ZNFKPanel"
local M = Act_065_ZNFKManager

local config = {
	[1] = {level = {"VIP0"},award = {[1] = { img = "eznhk_icon_1",txt = "鲸币礼包",tips ="鲸币礼包：最高可获得10万鲸币！",tishi="最高可获得10万鲸币!"}}},
	[2] = {level = {"VIP1、2"},award = { [1] = {img = "xyznq_icon_hjbx",txt = "黄金宝箱",tips ="黄金宝箱：最高可获得50万鲸币！",tishi="最高可获得50万鲸币!"}}},
	[3] = {level = {"VIP3、4"},award = {[1] = { img = "xyznq_icon_bjbx",txt = "铂金宝箱",tips ="铂金宝箱：最高可获得100万鲸币！",tishi="最高可获得100万鲸币!"}}},
	[4] = {level = {"VIP5、6、7"},award = { [1] = {img = "xyznq_icon_zsbx",txt = "钻石宝箱",tips ="钻石宝箱：最高可获得100万鲸币！",tishi="最高可获得100万鲸币!"}}},
	[5] = {level = {"VIP8、9"},award = {[1] = { img = "xyznq_icon_zsbx",txt = "钻石宝箱",tips ="钻石宝箱：最高可获得200万鲸币！"},[2] = { img = "xyznq_icon_jnbz",txt = "纯银纪念币",tips ="纯银纪念币：纯银10g纪念币"}}},
	[6] = {level = {"VIP10"},award = {[1] = { img = "xyznq_icon_wzbx",txt = "王者宝箱",tips ="钻石宝箱：最高可获得500万鲸币！"},[2] = { img = "xyznq_icon_djjnbz",txt = "纯银镀金纪念币",tips ="纯银镀金纪念币：纯银20g镀金纪念币"}}},
	[7] = {level = {"VIP11、12"},award = {[1] = { img = "xyznq_icon_wzbx",txt = "王者宝箱",tips ="王者宝箱：最高可获得500万鲸币！"},[2] = { img = "xyznq_icon_hjysxl",txt = "黄金羽毛吊坠",tips ="黄金羽毛吊坠：黄金羽毛吊坠大版"}}},
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

function C:OnDestroy()
	self:MyExit()
end

function C:MyClose()
	self:MyExit()
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
	self.get_btn.onClick:AddListener(function()
		self:OnClickGetBtn()
	end)

	self:MyRefresh()
	self:RepairPanel()
end

function C:MyRefresh()
	self:RefreshPanel()
end

function C:OnClickGetBtn()
	local data = GameTaskModel.GetTaskDataByID(M.GetTaskID())
	GameManager.GotoUI({gotoui = "act_065_znfk", goto_scene_parm = "act_panel"})
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
		b.transform:GetComponent("Button").onClick:AddListener(
			function ()
			LittleTips.Create(award_config[i].tips)	
			end
		)
		self.award_ui[#self.award_ui + 1] = temp_ui
	end
end

function C:RefreshPanel()
	--local data = GameTaskModel.GetTaskDataByID(M.GetTaskID())
	--self.get_btn.gameObject:SetActive(data.award_status ~= 2)
end

function C:GetCurVIPLevel()
	return Act_065_ZNFKManager.GetLevel() or 1
end

function C:on_model_task_change_msg(data)
	if data and data.id == M.GetTaskID() then
		self:RefreshPanel()
	end
end

function C:RepairPanel()
	local repair = GameObject.New("repair")
	repair.gameObject:AddComponent(typeof(UnityEngine.UI.Image))
	local img = repair.transform:GetComponent("Image")
	img.color = Color.New(252 / 255, 236 / 255, 159 / 255, 255 / 255)
	local imgTrans = img.transform:GetComponent("RectTransform")
	repair.transform:SetParent(self.transform)
	imgTrans.localPosition = Vector2.New(-249.5, 151.7)
	imgTrans.sizeDelta = { x = 115, y = 25}

	local repairTxt = GameObject.Instantiate(self.award_txt)
	repairTxt.name = "repair_txt"
	local txt = repairTxt.transform:GetComponent("Text")
	txt.color = Color.New(212 / 255, 50 / 255, 25 / 255, 255 / 255)
	local txtTrans = txt.transform:GetComponent("RectTransform")
	repairTxt.transform:SetParent(self.transform)
	txtTrans.localPosition = Vector2.New(-249.5, 151.5)
	txtTrans.sizeDelta = { x = 160, y = 30}
	txt.alignment = UnityEngine.TextAnchor.MiddleCenter

	local platform = gameMgr:getMarketPlatform()
	if platform == "wqp" then
		txt.text = "玩棋牌斗地主"
		txt.fontSize = 18
	else
		txt.text = "彩云麻将"
		txt.fontSize = 22
	end
end