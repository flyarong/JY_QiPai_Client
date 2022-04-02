-- 创建时间:2020-09-07
-- Panel:LWZBJLPanel

local basefunc = require "Game/Common/basefunc"

LWZBJLPanel = basefunc.class()
local C = LWZBJLPanel
C.name = "LWZBJLPanel"
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
    self.lister["model_lwzb_add_kaijiang_log_msg"] = basefunc.handler(self,self.on_model_lwzb_add_kaijiang_log_msg)
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
	
	--self.page_index = 1

	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	self.Back_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
       	self:MyExit()
 	end)
 	--[[self.sv = self.ScrollView.transform:GetComponent("ScrollRect")
	EventTriggerListener.Get(self.sv.gameObject).onEndDrag = function()
		local VNP = self.sv.verticalNormalizedPosition
		if VNP <= 0 then
			self:RefreshRankInfo()		
		end
	end--]]
	self:MyRefresh()
end

function C:MyRefresh()
	self:CreateItemPrefab()
end

function C:CreateItemPrefab()
	self:CloseItemPrefab()

	local all_info = M.GetAllInfo()
	local data = all_info.history_data
	--dump(data,"<color=red>xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx</color>")
	local len = 10
	for i=1,5 do
		destroyChildren(self["Content"..i].transform)
	end


	-- local data = {}
	-- for i=1,34 do
	-- 	data[i] = {
	-- 		win_lost_data = {
	-- 			0,0,0,0,
	-- 		}
	-- 	}
	-- end

	local  index = #data%10
	if #data >10 and index ~= 0 then
	  	for i = 1,index do
	  		table.remove(data,#data)
	  	end

	end

	dump(data,"<color=red>xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx</color>")
	if not table_is_null (data) then
		self.new.gameObject:SetActive(true)
		self.ScrollbarVertical.gameObject:GetComponent("Image").enabled = true
		for i=1,math.ceil(#data/10) do
			if #data <= 10 * i then
				if #data > 10 then
					for j=1,#data%10 do
						self.pre = LWZBJLItemBase.Create(self["Content"..i].transform,data[j].win_lost_data)
						if self.pre  then
							self.spawn_cell_list[#self.spawn_cell_list + 1] = self.pre 
						end
					end
				else
					for j=1,#data do
						self.pre = LWZBJLItemBase.Create(self["Content"..i].transform,data[j].win_lost_data)
						if self.pre  then
							self.spawn_cell_list[#self.spawn_cell_list + 1] = self.pre 
						end
					end
				end
				-- 	for j=1,len do
				-- 		self.pre = LWZBJLItemBase.Create(self["Content"..i].transform,data[len*(i-1)+j].win_lost_data)
				-- 		if self.pre  then
				-- 			self.spawn_cell_list[#self.spawn_cell_list + 1] = self.pre 
				-- 		end
				-- 	end
			

			else
				for j=1,len do
					self.pre  = LWZBJLItemBase.Create(self["Content"..i].transform,data[len*(i-1)+j].win_lost_data)
				end
				if self.pre  then
					self.spawn_cell_list[#self.spawn_cell_list + 1] = self.pre 
				end
			end
			
		end	
	end
	if #data >10 then
		self.Content.gameObject.transform:GetComponent("RectTransform").sizeDelta = Vector2.New(0, 650*((#data-index)/10))
	else
		self.Content.gameObject.transform:GetComponent("RectTransform").sizeDelta = Vector2.New(0, 850)
	end
	UnityEngine.UI.LayoutRebuilder.ForceRebuildLayoutImmediate(self.Content.transform:GetComponent("RectTransform"))

end

function C:CloseItemPrefab()
	if self.spawn_cell_list then
		for k,v in ipairs(self.spawn_cell_list) do
			v:MyExit()
		end
	end
	self.spawn_cell_list = {}
end

function C:on_model_lwzb_add_kaijiang_log_msg()
	self:MyRefresh()
end

function C:RefreshRankInfo()
	SYSByPmsManager.GetHallRank_data(self.id, self.page_index)
end