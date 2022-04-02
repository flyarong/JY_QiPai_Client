-- 创建时间:2019-11-05
-- Panel:OpenBoxrPanel
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

OpenBoxrPanel = basefunc.class()
local C = OpenBoxrPanel
C.name = "OpenBoxrPanel"

function C.Create(data)
	return C.New(data)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
	self.lister = {}
	self.lister["AssetChange"] = basefunc.handler(self,self.on_AssetChange)
	self.lister["box_exchange_response"] = basefunc.handler(self,self.onGetInfo)
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

function C:ctor(data)

	ExtPanel.ExtMsg(self)

	local parent = GameObject.Find("Canvas/LayerLv5").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	self.data = GameItemModel.GetItemToKey(data)
	LuaHelper.GeneratingVar(self.transform, self)
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	if self.data then 
		self.box_id = self.data.box_id
		self.item_key = self.data.item_key
		self.box_img.sprite = GetTexture(self.data.image)
		self.box_img:SetNativeSize()
	end 
	self.one_btn.onClick:AddListener(
		function ()
			Network.SendRequest("box_exchange",{id = self.box_id,num = 1})
		end
	)
	self.use_one_btn.onClick:AddListener(
		function ()
			Network.SendRequest("box_exchange",{id = self.box_id,num = 1})
		end
	)
	self.use_more_btn.onClick:AddListener(
		function ()
			Network.SendRequest("box_exchange",{id = self.box_id,num = self:GetMoreNum()})
		end
	)
	self.close_btn.onClick:AddListener(
		function ()
			self:MyExit()
		end		
	)
	self:MyRefresh()
end

function C:MyRefresh()
	if GameItemModel.GetItemCount(self.item_key) > 1 then
		self.twoBtn.gameObject:SetActive(true)
		self.one_btn.gameObject:SetActive(false)
	else
		self.twoBtn.gameObject:SetActive(false)
		self.one_btn.gameObject:SetActive(true)
	end
	self.more_txt.text = "使 用 "..self:GetMoreNum().."个"
	if GameItemModel.GetItemCount(self.item_key) <= 0 then
		self:MyExit()
	end
end

function C:GetMoreNum()
	return GameItemModel.GetItemCount(self.item_key) > 5 and 5 or GameItemModel.GetItemCount(self.item_key)
end

function C:onGetInfo(_,data)
	dump(data,"<color=red>宝箱返回数据</color>")
	if data.result ~= 0 then
		HintPanel.ErrorMsg(data.result)
	end
end

function C:on_AssetChange(data)
	dump(data,"<color=red>----奖励类型-----</color>")
	if data.change_type and data.change_type == "box_exchange_active_award_"..self.box_id and not table_is_null(data.data) then
		Event.Brocast("AssetGet",data)
		self:MyRefresh()	
	end
end

