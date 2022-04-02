-- 创建时间:2019-12-26
-- Panel:DZYLPanel
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

DZYLPanel = basefunc.class()
local C = DZYLPanel
C.name = "DZYLPanel"
local M = DZYLManager

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
    self.lister["model_dzyl_data_change_msg"] = basefunc.handler(self, self.MyRefresh)

    self.lister["receive_click_like_activity_box_response"] = basefunc.handler(self, self.on_box_get_msg)
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
	self.dz_time = {}

	self:InitUI()
end

function C:InitUI()
    PointerEventListener.Get(self.dzbx_btn.gameObject).onDown = basefunc.handler(self, self.OnDown)
    PointerEventListener.Get(self.dzbx_btn.gameObject).onUp = basefunc.handler(self, self.OnUp)
    PointerEventListener.Get(self.dzbx_open.gameObject).onDown = basefunc.handler(self, self.OnDown)
    PointerEventListener.Get(self.dzbx_open.gameObject).onUp = basefunc.handler(self, self.OnUp)

	self.qw_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		GameManager.GotoUI({gotoui="game_MiniGame"})
	end)
	self.jysj_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		GameManager.GotoUI({gotoui="act_dzyl", goto_scene_parm="jysj"})
	end)
	self.dzbx_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:OnDzbxClick()
	end)
	self.game_type_list = {"by", "shxxl", "sgxxl", "qql"}
	self.game_type_map = {}
	for k,v in ipairs(self.game_type_list) do
		self.game_type_map[v] = k
	end
	self.game_ui_map = {}
	for i = 1, 4 do
		local gt = self.game_type_list[i]
		local ui = {}
		LuaHelper.GeneratingVar(self["prefab"..i], ui)
		ui.game_btn.onClick:AddListener(function ()
	        ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
			self:OnDzClick(gt)
		end)
		self.game_ui_map[gt] = ui
	end
	self:MyRefresh()
    Network.SendRequest("query_click_like_activity_info")
    Network.SendRequest("query_click_like_activity_box_status")
end

function C:MyRefresh()
	for k,v in pairs(self.game_ui_map) do
		v.zan_txt.text = "" .. M.GetAllDzByGame(k)
		if M.GetMyDzByGame(k) > 0 then
			v.d_zan.gameObject:SetActive(true)
		else
			v.d_zan.gameObject:SetActive(false)
		end
	end
	if M.m_data and M.m_data.box_status and M.m_data.box_status == 0 then
		self.dzbx_btn.gameObject:SetActive(true)
		self.dzbx_open.gameObject:SetActive(false)
	else
		self.dzbx_btn.gameObject:SetActive(false)
		self.dzbx_open.gameObject:SetActive(true)
	end
	if M.m_data.box_status and M.m_data.box_status == 0 then
		self.dzbx_red.gameObject:SetActive(true)
	else
		self.dzbx_red.gameObject:SetActive(false)
	end 
end
function C:OnDown()
    GameTipsPrefab.ShowDesc("2020年1月24日-2月8日可开启宝箱，最多可获得10万鲸币", UnityEngine.Input.mousePosition)
end
function C:OnUp()
    GameTipsPrefab.Hide()
end

function C:OnDzClick(gt)
	print(gt)
	if M.m_data and M.m_data.box_status and M.m_data.box_status == 1 then
		LittleTips.Create("宝箱已经领过了，不可参与点赞")
		return
	end
	if M.GetMyDzByGame(gt) <= 0 and M.GetMyDzNum() < 2 then
		if self.dz_time[gt] and (self.dz_time[gt] + 3) > os.time() then
			LittleTips.Create("点赞太频繁")
			return
		end
		self.dz_time[gt] = os.time()
		Network.SendRequest("click_like_activity_for_game", {game_type=gt, op=1}, "点赞", function (data)
			dump(data)
			if data.result == 0 then
				M.OnDzByGame(gt, 1)
			else
				HintPanel.ErrorMsg(data.result)
			end
		end)
	else
		if M.GetMyDzByGame(gt) > 0 then
			if self.dz_time[gt] and (self.dz_time[gt] + 3) > os.time() then
				LittleTips.Create("点赞太频繁")
				return
			end
			self.dz_time[gt] = os.time()
			Network.SendRequest("click_like_activity_for_game", {game_type=gt, op=2}, "取消点赞", function (data)
				dump(data)
				if data.result == 0 then
					M.OnDzByGame(gt, 2)
				else
					HintPanel.ErrorMsg(data.result)
				end				
			end)
		else
			if M.GetMyDzNum() >= 2 then
				LittleTips.Create("最多可为2个小游戏点赞")
			end
		end
	end
end
function C:OnDzbxClick()
	-- 是否点过赞
	if M.GetMyDzNum() > 0 then
		if M.m_data.box_status and M.m_data.box_status == 0 then
			Network.SendRequest("receive_click_like_activity_box", nil, "领取宝箱")
		else
			LittleTips.Create("您已经领取过宝箱了")
		end
	else
		LittleTips.Create("点赞后才能领取宝箱")
	end
end

function C:on_box_get_msg(_, data)
	if data.result == 0 then
		M.m_data.box_status = 1
		Event.Brocast("AssetGet",{data = {{asset_type="prop_box_click_like", value=1}}, tips="宝箱自动存入背包，请在规定时间内使用，过期消失"})	
		self:MyRefresh()
	else
		HintPanel.ErrorMsg(data.result)
	end
end
