-- 创建时间:2021-01-04
-- Panel:Act_Ty_Collect_WordsCollectItemBase
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

Act_Ty_Collect_WordsCollectItemBase = basefunc.class()
local C = Act_Ty_Collect_WordsCollectItemBase
C.name = "Act_Ty_Collect_WordsCollectItemBase"
local M = Act_Ty_Collect_WordsManager

function C.Create(parent,config)
	return C.New(parent,config)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["ExitScene"]=basefunc.handler(self,self.MyExit)
    self.lister["ty_collect_activity_exchange_response_msg"] = basefunc.handler(self,self.on_ty_collect_activity_exchange_response_msg)
    self.lister["ty_collect_finish_gift_shop_msg"] = basefunc.handler(self,self.on_ty_collect_finish_gift_shop_msg)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	self:CloseAwardPrefab()
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

function C:ctor(parent,config)
	self.config = config
	local parent = parent or GameObject.Find("Canvas/GUIRoot").transform
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
	EventTriggerListener.Get(self.get_btn.gameObject).onClick = basefunc.handler(self, self.OnGetClick)
	self.title_txt.text = "拥有"..M.config.other_data[1].item_name..":"
	self:CreateItemPrefab()
	self:CreateAwardPrefab()
	self:MyRefresh()
end

function C:MyRefresh()
	local temp = 0
	for i=1,#self.config.need_item do
		if GameItemModel.GetItemCount(self.config.need_item[i]) >= self.config.need_num[i] then
			temp = temp + 1
		end
	end
	self.num_txt.text = temp .."/".. #self.config.need_item
	self.get_btn.gameObject:SetActive(temp == #self.config.need_item)
	self.get_img.gameObject:SetActive(temp ~= #self.config.need_item)
end

function C:CreateItemPrefab()
	self:CloseItemPrefab()
	dump(self.config,"<color=yellow><size=15>++++++++++self.config++++++++++</size></color>")
	for i=1,#self.config.need_item do
		local pre = GameObject.Instantiate(self.item_img,self.item_node.transform)
		pre.gameObject:SetActive(true)
		pre.transform:GetComponent("Image").sprite = GetTexture(GameItemModel.GetItemToKey(self.config.need_item[i]).image)
		self.spawn_cell_list[#self.spawn_cell_list + 1] = pre
	end
end

function C:CloseItemPrefab()
	if self.spawn_cell_list then
		for k,v in pairs(self.spawn_cell_list) do
			Destroy(v.gameObject)
		end
	end
	self.spawn_cell_list = {}
end


function C:CreateAwardPrefab()
	self:CloseAwardPrefab()
	for i=1,#self.config.award_txt do
		local pre = GameObject.Instantiate(self.award,self.award_node.transform)
		pre.gameObject:SetActive(true)
		pre.transform:Find("@award_img").transform:GetComponent("Image").sprite = GetTexture(self.config.award_img[i])
		pre.transform:Find("@award_txt").transform:GetComponent("Text").text = self.config.award_txt[i]
		if self.config.award_tip[i] ~= "" then
			local tip_btn = pre.transform:Find("@tips_btn")
			tip_btn.gameObject:SetActive(true)
			EventTriggerListener.Get(tip_btn.gameObject).onDown = function ()
				pre.transform:Find("@tips_btn/@tip").gameObject:SetActive(true)
			end
			EventTriggerListener.Get(tip_btn.gameObject).onUp = function ()
				pre.transform:Find("@tips_btn/@tip").gameObject:SetActive(false)
			end
		end
		self.spawn_cell_award_list[#self.spawn_cell_award_list + 1] = pre
	end
end

function C:CloseAwardPrefab()
	if self.spawn_cell_award_list then
		for k,v in pairs(self.spawn_cell_award_list) do
			Destroy(v.gameObject)
		end
	end
	self.spawn_cell_award_list = {}
end


function C:OnGetClick()
	M.GetCollectAward(self.config.exchange_type,self.config.exchange_id)
end

function C:on_ty_collect_activity_exchange_response_msg()
	self:MyRefresh()
end

function C:on_ty_collect_finish_gift_shop_msg()
	self:MyRefresh()
end