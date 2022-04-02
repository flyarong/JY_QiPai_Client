-- 创建时间:2020-08-31
-- Panel:LWZBSnatchPanel
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

LWZBSnatchPanel = basefunc.class()
local C = LWZBSnatchPanel
C.name = "LWZBSnatchPanel"
local M = LWZBModel
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
    self.lister["ExitScene"] = basefunc.handler(self,self.MyExit)
    self.lister["model_lwzb_query_make_dragon_list_msg"] = basefunc.handler(self,self.on_model_lwzb_query_make_dragon_list_msg)
    self.lister["model_lwzb_make_dragon_msg"] = basefunc.handler(self,self.on_model_lwzb_make_dragon_msg)
    self.lister["model_lwzb_cancel_dragon_msg"] = basefunc.handler(self,self.on_model_lwzb_cancel_dragon_msg)
    self.lister["model_zdlw_dragon_list_change_msg"] = basefunc.handler(self,self.on_model_zdlw_dragon_list_change_msg)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	self:CloseItemPrefab()
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:OnDestroy()
	self:MyExit()
end

function C:MyClose()
	self:MyExit()
end

function C:ctor()
	local parent = GameObject.Find("Canvas/LayerLv4").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
		

	self.limit_txt.text = "当前场次龙王条件:   "..StringHelper.ToCash(M.GetSnatchLimit())

	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	self.back_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:OnBackClick()
	end)
	self.becomelw_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:OnBecomelwClick()
	end)
	self.cancellw_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:OnCancellwClick()
	end)

	M.QueryMakeDragonData()
	self:MyRefresh()
end

function C:MyRefresh()
end

function C:OnBackClick()
	self:MyExit()
end

function C:OnBecomelwClick()
	if MainModel.UserInfo.jing_bi >= M.GetSnatchLimit() then
		M.MakeDragon()
	else
		LittleTips.Create("您不满足当前场次龙王条件")
	end
end

function C:OnCancellwClick()
	M.CancelDragon()
end

function C:CreateItemPrefab()
	self:CloseItemPrefab()
	local dragon_list = M.GetDragonList()
	for i=1,#dragon_list do
		local pre = LWZBSnatchItemBase.Create(self.Content.transform,i,dragon_list[i])
		if pre then
			self.spawn_cell_list[#self.spawn_cell_list + 1] = pre
		end
	end
end

function C:CloseItemPrefab()
	if self.spawn_cell_list then
		for k,v in ipairs(self.spawn_cell_list) do
			v:MyExit()
		end
	end
	self.spawn_cell_list = {}
end

function C:on_model_lwzb_query_make_dragon_list_msg()
	self:CreateItemPrefab()
	self:RefreshButton()
end

function C:on_model_lwzb_make_dragon_msg()
	self:CreateItemPrefab()
	self:RefreshButton()
end

function C:on_model_zdlw_dragon_list_change_msg()
	self:CreateItemPrefab()
	self:RefreshButton()
end

function C:on_model_lwzb_cancel_dragon_msg()
	if self:CheckLWIsI() then
		LittleTips.Create("已成功退出争霸,下局将不再是龙王")
	else
		LittleTips.Create("已成功退出争霸")
	end
	self:CreateItemPrefab()
	self:RefreshButton()
end

--检查我自己是不是在龙王队列里
function C:CheckLWGroupIsI()
	local dragon_list = M.GetDragonList()
	for k,v in pairs(dragon_list) do
		if v.player_info.player_id == MainModel.UserInfo.user_id then
			return true
		end
	end
	return false
end

function C:RefreshButton()
	self.becomelw_btn.gameObject:SetActive(not self:CheckLWGroupIsI())
	self.cancellw_btn.gameObject:SetActive(self:CheckLWGroupIsI())
end

--检查我自己是不是龙王
function C:CheckLWIsI()
	local dragon_list = M.GetDragonList()
	if dragon_list and dragon_list[1] and dragon_list[1].player_info and dragon_list[1].player_info.player_id and dragon_list[1].player_info.player_id == MainModel.UserInfo.user_id then
		return true
	else
		return false
	end
end