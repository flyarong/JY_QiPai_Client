-- 创建时间:2021-11-02
-- Panel:Act_069_XYHLBasePanel
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

Act_069_XYHLBasePanel = basefunc.class()
local C = Act_069_XYHLBasePanel
C.name = "Act_069_XYHLBasePanel"
local M = Act_069_XYHLManager

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
    self.lister["model_xyhl_bind_success_msg"] = basefunc.handler(self,self.on_model_xyhl_bind_success_msg)
    self.lister["model_xyhl_get_data_msg"] = basefunc.handler(self,self.on_model_xyhl_get_data_msg)
    self.lister["model_xyhl_task_change_msg"] = basefunc.handler(self,self.on_model_xyhl_task_change_msg)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	for i = 1, #self.rightPanels do
		-- dump(#self.rightPanels,"<color=white>AAAAAAAAAAAAAAA</color>")
		self.rightPanels[i].panel:MyExit()
	end
	self.rightPanels = nil
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:OnDestroy()
	self:MyExit()
end

function C:MyClose()
	self:MyExit()
end

local help_info = {
	"1.新游ID必须是官方渠道ID；",
	"2.成功绑定新游戏中的游戏ID即可激活任务，绑定即得3福卡；",
	"3.在新游戏中参与游戏、充值等可积攒任务进度；",
	"4.在新游中联系客服QQ：4008882620可直升VIP3；",
	"5.累计赢金范围包括所有游戏，捕鱼类游戏赢金按50%计算，苹果大战只计算纯赢；",
	"6.累计充值任务中购买带有“超值标签”的商品不计入任务；",
	"7.玩新游，可两边领奖励，更多福利请在新游中发现吧！",
}

function C:ctor()
	ExtPanel.ExtMsg(self)
	local parent = GameObject.Find("Canvas/LayerLv5").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()

	self:InitIndexMap()
	self:InitPanelCfgUI()
	self.rightPanels = {}
	self:InitLeftTitItem()
	self:LoadBindPanel()
	self:RefreshLeftTitItem()
	self:RefershLeftContent(1)
	self:RefreshLeftHint()
	self:RefreshRightContent(1)
	M.QueryMainData()
end

function C:InitUI()
	self.back_btn.onClick:AddListener(function()
		self:MyExit()
	end)
	
	self:MyRefresh()
end

function C:MyRefresh()
end
function C:InitIndexMap()
	self.indexndexSortMap = M.GetIndexSortMap()
end

function C:InitPanelCfgUI()
	self.panel_cfg = M.panel_cfg
end

function C:InitRightContent()
end

function C:InitLeftTitItem()
	self.leftTitItems = {}
	for i = 1, #self.panel_cfg do
		local leftTitItem = { obj = {}, ui = {} }
		leftTitItem.obj = newObject("Act_069_XYHLLeftTitItem", self.l_content)
		LuaHelper.GeneratingVar(leftTitItem.obj.transform, leftTitItem.ui)
		leftTitItem.ui.item_btn.onClick:AddListener(function()
			self:RefershLeftContent(i)
			self:RefreshRightContent(i)
		end)
		self.leftTitItems[#self.leftTitItems + 1] = leftTitItem
	end
end

function C:RefreshLeftTitItem()
	for i = 1, #self.panel_cfg do
		local leftTitItem = self.leftTitItems[i]
		leftTitItem.ui.tit_txt.text = self.panel_cfg[self.indexndexSortMap[i]].name
		leftTitItem.ui.tit2_txt.text = self.panel_cfg[self.indexndexSortMap[i]].name
	end
end

function C:RefershLeftContent(index)
	for i = 1, #self.leftTitItems do
		if i == index then
			self.leftTitItems[i].ui.selected.gameObject:SetActive(true)
		else
			self.leftTitItems[i].ui.selected.gameObject:SetActive(false)
		end
	end
end

function C:RefreshLeftHint()
	for i = 1, #self.panel_cfg do
		local leftTitItem = self.leftTitItems[i]
		if M.IsHint(self.panel_cfg[self.indexndexSortMap[i]].key) then
			leftTitItem.ui.LFL.gameObject:SetActive(true)
		else
			leftTitItem.ui.LFL.gameObject:SetActive(false)
		end
	end
end

function C:RefreshRightContent(targetPageIndex)
	if targetPageIndex == self.curPageIndex then
		return
	end
	if self.rightPanels[targetPageIndex] then
		local curPanel = self.rightPanels[targetPageIndex]
		curPanel.panel.gameObject:SetActive(true)
	else
		local cfgIndex = self.indexndexSortMap[targetPageIndex]
		local curPanelName = M.panel_cfg[cfgIndex].panel
		if _G[curPanelName]	then
			local _panel = _G[curPanelName].Create(self.r_content.transform, cfgIndex)
			self.rightPanels[targetPageIndex] = { panel = _panel}
		else
			LittleTips.Create("未找到")
		end
	end
	if self.curPageIndex then
		local lastPanel = self.rightPanels[self.curPageIndex]
		lastPanel.panel.gameObject:SetActive(false)
	end
	self.curPageIndex = targetPageIndex
	self:RefreshBindNode()
end

function C:RefreshBindNode()
	local cfgIndex = self.indexndexSortMap[self.curPageIndex]
	if self.panel_cfg[cfgIndex].key == "xyhl" then
		self.bind_node.gameObject:SetActive(false)
	else
		self.bind_node.gameObject:SetActive(true)
		self:RefreshBindPanel()
	end
end

function C:LoadBindPanel()
	self.bindPanel = newObject("Act_069_XYHLBindPanel", self.bind_node.transform)
	self.bindPanelUI = {}
	LuaHelper.GeneratingVar(self.bindPanel.transform, self.bindPanelUI)
	self.bindPanelUI.bind_btn.onClick:AddListener(function()
		Act_069_XYHLBindIdPanel.Create()
	end)
	self.bindPanelUI.help_btn.onClick:AddListener(function()
		self:OnHelpClick()
	end)
end

function C:RefreshBindPanel()
	local isBindNewPlayer = M.GetBindNewPlayer()
	if not isBindNewPlayer then
		self.bindPanelUI.bind_data.gameObject:SetActive(false)
		self.bindPanelUI.bind_btn.gameObject:SetActive(true)
	else
		self.bindPanelUI.bind_data.gameObject:SetActive(true)
		self.bindPanelUI.bind_btn.gameObject:SetActive(false)
		self.bindPanelUI.remain_time_txt.fontSize = 30
		CommonTimeManager.GetCutDownTimer(M.GetTaskEndTime(), self.bindPanelUI.remain_time_txt)
		
		local data = M.GetBindData()
		self.bindPanelUI.id_txt.text = data.new_id
		self.bindPanelUI.vip_lv_txt.text = data.new_vip
		self.bindPanelUI.yj_txt.text = data.ljyj_progress
		self.bindPanelUI.cz_txt.text = data.ljcz_progress
	end
end

function C:on_model_xyhl_bind_success_msg()
	self:RefreshBindPanel()
end

function C:on_model_xyhl_get_data_msg()
	self:RefreshBindPanel()
end

function C:on_model_xyhl_task_change_msg()
	self:RefreshLeftHint()
end

function C:OnHelpClick()
    local str = help_info[1]
    for i = 2, #help_info do
        str = str .. "\n" .. help_info[i]
    end
    self.introduce_txt.text = str
    IllustratePanel.Create({ self.introduce_txt.gameObject }, GameObject.Find("Canvas/LayerLv5").transform)
end