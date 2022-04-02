-- 创建时间:2019-12-27
-- Panel:SNYJCJPanel
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

SNYJCJPanel = basefunc.class()
local C = SNYJCJPanel
C.name = "SNYJCJPanel"
local M = SNYJCJManager

function C.Create(parm)
	return C.New(parm)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["ui_button_data_change_msg"] = basefunc.handler(self, self.RefreshJF)
    self.lister["AssetChange"] = basefunc.handler(self, self.OnAssetChange)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	if self.CellList then
		for k,v in ipairs(self.CellList) do
			if v.OnDestroy then
				v:OnDestroy()
			end
		end
		self.CellList = {}
	end
	self:ShowAward()
	self:RemoveListener()
	destroy(self.gameObject)

	 
end
function C:OnDestroy()
	self:MyExit()
end

function C:ctor(parm)

	ExtPanel.ExtMsg(self)

	self.parm = parm or {}
	local parent = self.parm.parent or GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	self.config = SNYJCJManager.config

	self.top.gameObject:SetActive(false)
	self.zqjf_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		GameManager.GotoUI({gotoui="game_MiniGame"})
	end)
	self.help_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
	    IllustratePanel.Create({ self.introduce_txt.gameObject }, GameObject.Find("Canvas/LayerLv5").transform)
	end)
	self.jp_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
        if self.top.gameObject.activeSelf then
			self.top.gameObject:SetActive(false)
        else
    		self.top.gameObject:SetActive(true)
	    end
	end)
    EventTriggerListener.Get(self.top_mybutton.gameObject).onClick = basefunc.handler(self, self.OnTopClick)

    local str = self.config.DESCRIBE_TEXT[1].text
    for i = 2, #self.config.DESCRIBE_TEXT do
        str = str .. "\n" .. self.config.DESCRIBE_TEXT[i].text
    end
    self.introduce_txt.text = str

    self:InitTips()

    self.CellList = {}
    self.cell_size = {w=184, h=230}
    self.b_p = {x=-363, y=112}
    self.w_c = 5
    for i = 1, #self.config.Award do
    	local pre = SNYJCJPrefab.Create(self.center, i, self.OnXZClick, self)
    	local x = (i - 1) % self.w_c
    	x=self.b_p.x + self.cell_size.w*x
    	local y = math.floor((i - 1) / self.w_c)
    	y=self.b_p.y - self.cell_size.h*y
    	pre:SetPos({x=x,y=y,z=0})
    	self.CellList[#self.CellList + 1] = pre
    end

	self:MyRefresh()
end

function C:MyRefresh()
	local temp_ui = {}
	if SNYJCJManager.GetData() then 
		self.m_data = SNYJCJManager.GetData().at_data
	else
		return 
	end 
	dump(self.m_data,"<color=red>鼠年赢金抽大奖数据</color>")
	if self.m_data then
		self.index_map = M.GetGetUIPos()
		dump(self.index_map)
		for k,v in ipairs(self.CellList) do
			v:SetIndex()
			v:MyRefresh()
		end
		for i=1, self.m_data.now_game_num do
			self.CellList[self.index_map[i]]:SetIndex(i)
			self.CellList[self.index_map[i]]:MyRefresh()
		end
	end
	self:RefreshJF()
end
function C:RefreshJF(data)
	if data and SNYJCJManager.key ~= data.key then
		return
	end
	if SNYJCJManager.GetData() then 
		self.m_data = SNYJCJManager.GetData().at_data
	else
		return 
	end 
	if self.m_data then
		self.index_map = M.GetGetUIPos()
		self.cur_jf_txt.text = self.m_data.ticket_num
		self.now_game_num = self.m_data.now_game_num

		if self.now_game_num >= #self.config.Award then 
			self.hint_txt.gameObject:SetActive(false)
			self.xh_hint_txt.text = "<color=#FEF493FF>所有奖励已获取</color>"
		else
			if self.m_data.ticket_num >= self.config.Award[self.now_game_num + 1].need_credits then
				self.hint_txt.gameObject:SetActive(true)
			else
				self.hint_txt.gameObject:SetActive(false)
			end
			self.xh_hint_txt.text = "<color=#FEF493FF>消耗<color=#FFF9EDFF>" .. self.config.Award[self.now_game_num + 1].need_credits.."</color>积分翻一张牌</color>"
		end		
	end
end

function C:InitTips()
	for i=1,#self.config.Award do
		if self.config.Award[i].tips then 
			PointerEventListener.Get(self["show_item"..i].gameObject).onDown = function ()
				GameTipsPrefab.ShowDesc(self.config.Award[i].tips, UnityEngine.Input.mousePosition)
			end
			PointerEventListener.Get(self["show_item"..i].gameObject).onUp = function ()
				GameTipsPrefab.Hide()
			end
		end 
	end
end

function C:OnTopClick()
	self.top.gameObject:SetActive(false)
end

function C:OnXZClick(ui, index)
	if not self.m_data then
		print("<color=red>数据未准备</color>")
		return
	end
	if index then
		return
	end
	if self.m_data then
		if self.m_data.ticket_num < self.config.Award[self.now_game_num + 1].need_credits then
			HintPanel.Create(1, "当前积分不足，玩小游戏可获得积分")
			return
		end
	end
	local now_game_num = self.m_data.now_game_num or 0
	if self.is_cj_ing then
		return
	end
	self.is_cj_ing = true
	Network.SendRequest("common_lottery_kaijaing", {lottery_type = M.lottery_type}, "抽奖", function (data)
		if data.result == 0 then
			index = now_game_num + 1
			local cfg = self.config.Award[index]
			self.real = nil
			if cfg.real == 1 then
				self.real = {image = cfg.award_image ,text = cfg.award_text}
			end
			self.CellList[ui]:SetIndex(index)
			self.CellList[ui]:RunOpenAnim(function ()
				self:ShowAward()
				self:MyRefresh()
				self.is_cj_ing = false
			end)
			M.SetGetUIPos(ui, index)
		else
			self.is_cj_ing = false
			HintPanel.ErrorMsg(data.result)
		end
	end)
end
function C:OnAssetChange(data)
	if data.change_type and data.change_type == "common_lottery_" .. M.lottery_type then
		self.AssetGet = data
    end
end
-- 关闭界面调用或者动画完成调用
function C:ShowAward()
	if self.real then
		RealAwardPanel.Create(self.real)
	else
		if self.AssetGet then
			Event.Brocast("AssetGet", self.AssetGet)
		end
	end
	self.real = nil
	self.AssetGet = nil
end