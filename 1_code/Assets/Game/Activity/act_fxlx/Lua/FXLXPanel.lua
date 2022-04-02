-- 创建时间:2020-01-25
-- Panel:FXLXPanel
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

FXLXPanel = basefunc.class()
local C = FXLXPanel
C.name = "FXLXPanel"
local M = FXLXManager
local hide_time = 17
local Wait_Broadcast_data = {}
local Wait_OBj
local Loop_Order = {"RollPrefab1","RollPrefab2","RollPrefab3"}
local hide_left_pos = -1300
local space = 1000
function C.Create(parent,backcall)
	return C.New(parent,backcall)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
	self.lister = {}
	self.lister["get_fxlx_award_response"] = basefunc.handler(self,self.on_get_fxlx_award_response)
	self.lister["AssetChange"] = basefunc.handler(self, self.OnAssetChange)
	self.lister["fxlx_Broadcast_Info"] = basefunc.handler(self,self.on_fxlx_Broadcast_Info)
	self.lister["ExitScene"] = basefunc.handler(self,self.MyExit)
	self.lister["global_hint_state_change_msg"] = basefunc.handler(self,self.on_global_hint_state_change_msg)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	for i = 1,#self.timer do 
		if self.timer[i] then 
			self.timer[i]:Stop()
		end
	end
	if self.DelayToShow_Timer then
		self.DelayToShow_Timer:Stop()
	end
	if self.Cheak_Timer then 
		self.Cheak_Timer:Stop()
	end
	if self.backcall then
		self.backcall()
	end 
	self:RemoveListener()
	destroy(self.gameObject)

	 
end

function C:ctor(parent,backcall)
	ExtPanel.ExtMsg(self)
	local parent =parent or GameObject.Find("Canvas/LayerLv5").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	self.backcall = backcall
	LuaHelper.GeneratingVar(self.transform, self)
	self.timer = {}
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	for i=1,#Loop_Order do
		self:LoopAnim(self[Loop_Order[i]])
	end
end

function C:InitUI()
	self.items = {}
	local temp_ui = {}
	for i=1,5 do
		local b = GameObject.Instantiate(self.player_item,self.node)
		b.gameObject:SetActive(true)
		self.items[i] = b
		LuaHelper.GeneratingVar(b.transform, temp_ui)
		temp_ui.invite_btn.onClick:AddListener(
			function ()
				GameManager.GotoUI({gotoui = "share_hall"})
			end
		)
	end
	self.share_btn.onClick:AddListener(
		function ()
			GameManager.GotoUI({gotoui = "share_hall"})
		end
	)
	self.close_btn.onClick:AddListener(
		function ()
			self:MyExit()
		end
	)
	self.help_btn.onClick:AddListener(
		function ()
			LTTipsPrefab.Show(self.help_btn.gameObject.transform,2,"活动截止时间：2月25日0点0分，每人最多获得5次奖励")
		end
	)
	self:MyRefresh()
end

function C:MyRefresh()
	if not IsEquals(self.gameObject) then return end 

	self.red.gameObject:SetActive(FXLXManager.GetIsNotShare())
	local data = M.GetData()
	local temp_ui = {}
	if not data then return end
	local num = #data
	if num > 5 then 
		num = 5
	end 
	for i=1,#data do
		local b = self.items[i]
		LuaHelper.GeneratingVar(b.transform, temp_ui)
		temp_ui.player_txt.text = data[i].name
		URLImageManager.UpdateHeadImage(data[i].head_image, temp_ui.player_img)
		temp_ui.player_btn.gameObject:SetActive(not (data[i].get_award == 1))
		temp_ui.player_not.gameObject:SetActive(false)
		temp_ui.player_got.gameObject:SetActive(data[i].get_award == 1)
		temp_ui.player_img.gameObject:SetActive(true)
		temp_ui.player_btn.onClick:AddListener(
			function ()
				self:AddWaitData(MainModel.UserInfo.name)
				Network.SendRequest("get_fxlx_award",{id = i})
			end
		) 
	end
end

function C:on_get_fxlx_award_response(_,data)
	dump(data,"<color=red> 分享拉新奖励----</color>")
	Network.SendRequest("query_fxlx_data")
end

function C:OnAssetChange(data)
	if data.change_type and data.change_type == "fxlx_award" then
		Event.Brocast("AssetGet",data)
	end
end

function C:on_fxlx_Broadcast_Info(data)
    self:AddWaitData(data.playname)
end

function C:AddWaitData(data)
	self:CheakNode()
    table.insert(Wait_Broadcast_data,1,data)
end

function C:RemoveWaitData()
    table.remove(Wait_Broadcast_data,#Wait_Broadcast_data)
end

function C:GetWaitData()
	return Wait_Broadcast_data[#Wait_Broadcast_data]
end


function C:LoopAnim(obj)
	local temp_ui = {}
	self.timer[#self.timer + 1] = Timer.New(function ()
        obj.transform:Translate(Vector3.left * 3)
		if obj.transform.localPosition.x <= hide_left_pos then
			LuaHelper.GeneratingVar(obj.transform, temp_ui)
			temp_ui.info_txt.text = ""
			obj.transform.localPosition = Vector3.New(hide_left_pos + space * #Loop_Order,0,0)
			if self:GetWaitData() then
				temp_ui.info_txt.text = "恭喜玩家<color=#4eea3d>"..self:GetWaitData().."</color>完成邀请,获得奖励<color=#ff9257>20000</color>鲸币"
				self:RemoveWaitData()
			end
        end
	end,0.016,-1,nil,true)
	self:SetPos()
end

function C:CheakNode()
	local ht = hide_time
	if self.DelayToShow_Timer then
		self.DelayToShow_Timer:Stop()
	end
	self.DelayToShow_Timer = Timer.New(
		function ()
			self.UINode.gameObject:SetActive(true)
		end
	,4,1) 
	self.DelayToShow_Timer:Start()
	if self.Cheak_Timer then 
		self.Cheak_Timer:Stop()
	end
	for i = 1,#self.timer do 
		if self.timer[i] then 
			self.timer[i]:Start()
		end
	end
	self.Cheak_Timer = Timer.New(
		function()
			ht = ht - 0.1
			if ht <= 0 then 
				ht = 9999999
				self.UINode.gameObject:SetActive(false)
				self:SetPos()
				for i = 1,#self.timer do 
					if self.timer[i] then 
						self.timer[i]:Stop()
					end
				end
			end 
		end 
	,0.1,-1)
	self.Cheak_Timer:Start()
end

function C:SetPos()
	for i=1,#Loop_Order do
		self[Loop_Order[i]].transform.localPosition = Vector3.New(hide_left_pos + space * (i - 1) + 2,0,0)
	end
end

function C:on_global_hint_state_change_msg(data)
	if data and data.gotoui == FXLXManager.key then 
		self:MyRefresh()
	end
end