-- 创建时间:2019-11-19
-- Panel:ActivityGEYLPanel
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

ActivityGEYLPanel = basefunc.class()
local C = ActivityGEYLPanel
C.name = "ActivityGEYLPanel"
C.key = "gratitude_propriety"
local config = GEYLManager.config
local c_gray = Color.gray
local curr_level = 0
function C.Create(parent, cfg, backcall)
	return C.New(parent, cfg, backcall)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
	self.lister = {}
	self.lister["AssetChange"] = basefunc.handler(self, self.OnAssetChange)
	self.lister["AssetsGetPanelConfirmCallback"] = basefunc.handler(self, self.AssetsGetPanelConfirmCallback)
	self.lister["get_one_common_lottery_info"] = basefunc.handler(self, self.RefreshMyHL)
	self.lister["common_lottery_kaijaing_response"] = basefunc.handler(self, self.Get_KAIJIANG_info)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	if self.show_anim_timer then 
		self.show_anim_timer:Stop()
	end
	self:RemoveListener()
	destroy(self.gameObject)

	 
end

function C:ctor(parent, cfg, backcall)

	ExtPanel.ExtMsg(self)

	self.backcall = backcall
	local parent = parent or GameObject.Find("Canvas/LayerLv3").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	self:Refresh()
end

function C:InitUI()
	self.help_btn.onClick:AddListener(
		function()
			self:OpenHelpPanel()
		end
	)
	self.make_hl_btn.onClick:AddListener(
		function()
			self:GoToUI()
		end	
	)
	self.close_btn.onClick:AddListener(
		function ()
			if self.backcall then
				self.backcall()
			end
			self:MyExit()
		end
	)
	self.hezi_btn.onClick:AddListener(
		function ()
			self:GetAward()
		end
	)
	for i = 1,#config.Award do
		local temp_ui = {} 
		LuaHelper.GeneratingVar(self["award_item"..i], temp_ui)
		temp_ui.need_txt.text = "消耗"..config.Award[i].need_credits.."积分"
	end 
end


function C:OpenHelpPanel()
    local str = config.DESCRIBE_TEXT[1].text
    for i = 2, #config.DESCRIBE_TEXT do
        str = str .. "\n" .. config.DESCRIBE_TEXT[i].text
    end
    self.introduce_txt.text = str
    IllustratePanel.Create({ self.introduce_txt.gameObject }, GameObject.Find("Canvas/LayerLv5").transform)
end

function C:GoToUI()
	GameManager.GotoUI({gotoui = "game_MiniGame"})
end

function C:Refresh()
	if not IsEquals(self.gameObject) then return end 
	self:ShowNeed()
	self:SetDzPos()
	self:SetMask()
	self:RefreshMyHL()
end

function C:SetDzPos()
	local temp_ui = {}
	local data = LotteryBaseManager.GetData(C.key)
	local curr_level = 11
	if data then 
		curr_level = data.now_game_num + 1
	end 
	if curr_level <= 10 then
		if LotteryBaseManager.IsAwardCanGet(C.key) then 			 
			self.dz_item.gameObject.transform.parent = self["dz_node"..curr_level]			
			self:SetShowAward(curr_level)
			self.had_open.gameObject:SetActive(false)
			self.hezi_btn.gameObject:SetActive(true)
		else
			self.dz_item.gameObject.transform.parent = self["dz_node"..curr_level - 1]
			self:SetShowAward(curr_level - 1)
			if curr_level - 1 > 0 then
				self.had_open.gameObject:SetActive(true)
				self.hezi_btn.gameObject:SetActive(false)
				LuaHelper.GeneratingVar(self["award_item"..curr_level - 1], temp_ui)
				temp_ui.need.gameObject:SetActive(false)
			else
				self.had_open.gameObject:SetActive(false)
				self.hezi_btn.gameObject:SetActive(true)
			end  
		end 
		self.dz_item.gameObject:SetActive(true)
		self.dz_item.gameObject.transform.localPosition = Vector3.New(0, 0, 0)  
		self.dz_item.gameObject.transform.localScale = Vector3.New(1, 1, 1) 
	else
		self.dz_item.gameObject:SetActive(false)
		for i=1,#config.Award do
			LuaHelper.GeneratingVar(self["award_item"..i], temp_ui)
			temp_ui.award_img.gameObject:SetActive(true)
		end
		self:HideAllNeed()
	end
	self.hezi_btn.gameObject:SetActive(true)
	self.open.gameObject:SetActive(false) 
end

function C:ShowNeed()
	local data = LotteryBaseManager.GetData(C.key)
	local curr_level = 11
	if data then 
		curr_level = data.now_game_num + 1
	end
	self:HideAllNeed()
	if not LotteryBaseManager.IsAwardCanGet(C.key) then
		curr_level = curr_level - 1
	end
	if curr_level <= 10 then 
		self:ShowNeedItem(curr_level)
	end 
	if curr_level + 1 <= 10 then 
		self:ShowNeedItem(curr_level + 1)
	end
end

function C:SetMask()
	local data = LotteryBaseManager.GetData(C.key)
	if data then 
		for i = 1,data.now_game_num do 
			local  temp_ui = {}
			LuaHelper.GeneratingVar(self["award_item"..i], temp_ui)
			temp_ui.award_mask.gameObject:SetActive(true)
			temp_ui.award_txt.color = c_gray
			temp_ui.award_img.color = c_gray
		end 
	end 
end

function C:PlayAnim()
	if self.show_anim_timer then 
		self.show_anim_timer:Stop()
	end 
	self.show_anim_timer = nil
	self.show_anim_timer = Timer.New(function ()		
		if self.real then
			RealAwardPanel.Create(self.real)
			self.real = nil
		elseif self.award_data then 
			Event.Brocast("AssetGet", self.award_data)
			self.award_data = nil
		end 
	end,0.9,1)
	self.hezi_btn.gameObject:SetActive(false)
	self.open.gameObject:SetActive(true)
	self.show_anim_timer:Start()
end

function C:OnAssetChange(data)
    dump(data, "<color=red>----奖励类型-----</color>")
    if data.change_type and data.change_type == "common_lottery_" .. C.key then
        self.award_data = data
    end
end

function C:GetAward()
	local data = LotteryBaseManager.GetData(C.key)
	local curr_level = 11
	if data then 
		curr_level = data.now_game_num + 1
	end 
	if curr_level <= 10 then
		if data.ticket_num >= config.Award[curr_level].need_credits then 
			Network.SendRequest("common_lottery_kaijaing", {lottery_type = C.key})		
			if config.Award[curr_level].real == 1 then 
				local real = {text = config.Award[curr_level].type, image = config.Award[curr_level].img}
				self.real = real
			else
				self:PlayAnim()
				self.real = nil
			end 
		else
			HintPanel.Create(1,"活力不足哦，赶快去玩小游戏赚取活力吧")
		end 	
	else
		print("<color=red>奖励已经完全领取</color>")
	end 
end

function C:HideAllNeed()
	for i = 1,#config.Award do 
		local temp_ui = {}
		LuaHelper.GeneratingVar(self["award_item"..i], temp_ui)
		temp_ui.need.gameObject:SetActive(false)
	end 
end

function C:ShowNeedItem(index)
	local temp_ui = {}
	LuaHelper.GeneratingVar(self["award_item"..index], temp_ui)
	temp_ui.need.gameObject:SetActive(true)
end

function C:AssetsGetPanelConfirmCallback()
	self:Refresh()
end

function C:RefreshMyHL()
	if not IsEquals(self.gameObject) then return end 
	local data = LotteryBaseManager.GetData(C.key)
	if data then
		self.curr_hl_txt.text = "当前活力："..data.ticket_num 
		if LotteryBaseManager.IsAwardCanGet(C.key) then 
			self.can_get_award.gameObject:SetActive(true)
		else
			self.can_get_award.gameObject:SetActive(false)
		end 
	end  
end

function C:Get_KAIJIANG_info(_,data)
	if data and data.result == 0 then 
		if self.real then 
			self:PlayAnim(self.real)
		end 
	end 
end

function C:SetShowAward(index)
	local temp_ui = {}
	for i=1,#config.Award do				
		LuaHelper.GeneratingVar(self["award_item"..i], temp_ui)
		temp_ui.award_img.gameObject:SetActive(true)
	end
	LuaHelper.GeneratingVar(self["award_item"..index], temp_ui)
	temp_ui.award_img.gameObject:SetActive(false)
end