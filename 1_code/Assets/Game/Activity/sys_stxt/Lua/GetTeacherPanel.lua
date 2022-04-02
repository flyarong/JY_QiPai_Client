-- 创建时间:2019-11-28
-- Panel:GetTeacherPanel
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

GetTeacherPanel = basefunc.class()
local C = GetTeacherPanel
C.name = "GetTeacherPanel"
local Item_UI 
local curr_index 
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
	self.lister["query_master_square_info_response"] = basefunc.handler(self,self.on_query_master_square_info_response)
	self.lister["search_master_square_info_response"] = basefunc.handler(self,self.on_search_master_square_info_response)
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

function C:ctor(parent)

	ExtPanel.ExtMsg(self)

	local parent = parent or GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	curr_index = 1
	Item_UI = {}
	LuaHelper.GeneratingVar(self.transform, self)
	self.sv = self.transform:Find("Scroll View"):GetComponent("ScrollRect")
	self.transform.localPosition = Vector3.zero
	self.InputField = self.transform:Find("InputField"):GetComponent("InputField")
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	Network.SendRequest("query_master_square_info")
end

function C:InitUI()
	self.search_btn.onClick:AddListener(
		function ()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name) 
			Network.SendRequest("search_master_square_info",{player_id = self.id_input_txt.text})
		end
	)
	self.clear_btn.onClick:AddListener(
		function ()
			self.InputField.text = ""
		end
	)
	EventTriggerListener.Get(self.sv.gameObject).onEndDrag = function()
		local VNP = self.sv.verticalNormalizedPosition
		if VNP <= 0 then
			self:RefreshInfo()		
		end
	end
end

function C:Refresh_Item_UI(data)
	if not IsEquals(self.gameObject) or table_is_null(data) then return end
	local Data = table.sort(data,function (a,b)
		return a.publish_time > b.publish_time
	end) or data
	local temp_ui = {}
	for i = 1, #Data do
		local b = GameObject.Instantiate(self.teacher_info_item,self.Content)
		b.gameObject:SetActive(true)
		Item_UI[Data[i].id] = b
		LuaHelper.GeneratingVar(b.transform,temp_ui)
		temp_ui.name_txt.text = Data[i].player_name
		temp_ui.id_txt.text = Data[i].player_id
		temp_ui.vip_txt.text = "VIP"..Data[i].vip_level
		URLImageManager.UpdateHeadImage(Data[i].head_image,temp_ui.head_img)
		temp_ui.choose_btn.onClick:AddListener(
			function ()
				ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name) 
				ShowTeacherPanel.Create(nil,Data[i])
			end
		)
		temp_ui.like_txt.text = Data[i].total_like_num
		temp_ui.message_txt.text = self:GetMessageByID(Data[i].message_id)
	end
end

function C:GetMessageByID(__id)
	return SYSSTXTManager.master_message_config.master_message_config[__id].master_message
end

function C:RefreshInfo()
	-- if curr_index >= SYSSTXTManager.GetLimitByKey("max_req") then
	-- 	LittleTips.Create("更多收徒信息正在处理中，但您可以尝试搜索玩家信息")
	-- 	return
	-- end 
	--Network.SendRequest("query_master_square_info")
end

function C:on_query_master_square_info_response(_,data)
	if data and data.result == 0 then 
		self:Refresh_Item_UI(data.master_square_info)
		if not table_is_null(data.master_square_info) then 
			curr_index  = curr_index + 1
		end 
	end 
end

function C:on_search_master_square_info_response(_,data)
	if data and data.result == 0 then 
		ShowTeacherPanel.Create(nil,data.master_square_info[1])
	else
		HintPanel.Create(1,"没有找到此玩家")
	end
end

function C:OnDestroy()
	self:MyExit()
end