-- 创建时间:2019-11-28
-- Panel:GetPupilPanel
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

GetPupilPanel = basefunc.class()
local C = GetPupilPanel
C.name = "GetPupilPanel"
local config = SYSSTXTManager.master_message_config
local Item_UI 
local Curr_Index = 1
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
	self.lister["publish_master_info_response"] = basefunc.handler(self,self.on_publish_master_info_response)
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
	Item_UI = {}
	LuaHelper.GeneratingVar(self.transform, self)
	self.transform.localPosition =  Vector3.zero
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	self:OnItemClick(1)
end

function C:InitUI()
	local temp_ui = {}
	for i=1,#config.master_message_config do
		local b = GameObject.Instantiate(self.Popil_item,self.Content)
		Item_UI[#Item_UI + 1] = b
		b.gameObject:SetActive(true)
		local btn = b.transform:GetComponent("Button")
		btn.onClick:AddListener(
			function ()
				self:OnItemClick(i)
			end
		)
		LuaHelper.GeneratingVar(b.transform,temp_ui)
		temp_ui.message_txt.text = i..", "..config.master_message_config[i].master_message
	end
	self.go_btn.onClick:AddListener(
		function ()
			HintPanel.Create(2,"发布收徒信息需要100万鲸币，是否发布？",
			function ()
				self:GoPublish()
			end)
		end
	)
end

function C:OnItemClick(index)
	local temp_ui = {}
	for i = 1,#Item_UI do
		LuaHelper.GeneratingVar(Item_UI[i].transform,temp_ui)
		temp_ui.mask.gameObject:SetActive(false)
	end
	LuaHelper.GeneratingVar(Item_UI[index].transform,temp_ui)
	temp_ui.mask.gameObject:SetActive(true)
	Curr_Index = index
end

function C:GoPublish()
	if VIPManager.get_vip_level() >= SYSSTXTManager.GetLimitByKey("vip_s_limit") and MainModel.UserInfo.jing_bi >= SYSSTXTManager.GetLimitByKey("gold_s_limit") then
		self:Refresh_Confirm_Panel()
		Network.SendRequest("publish_master_info",{message_id = Curr_Index})
	elseif 	MainModel.UserInfo.jing_bi < SYSSTXTManager.GetLimitByKey("gold_s_limit") then 
		HintPanel.Create(1,"鲸币不足",
		function ()
			PayPanel.Create("jing_bi")
		end
		)
	else	
		HintPanel.Create(1,"VIP等级不足，是否前往升级？",
		function ()
			PayPanel.Create("jing_bi")
		end
		)
	end
end

function C:Refresh_Confirm_Panel()

end

function C:on_publish_master_info_response(_,data)
	if data and data.result == 0 then 
		HintPanel.Create(1,"发布成功")
		Event.Brocast("tp_CloseTHENOpen","GetPupil")
	end 
end

function C:OnDestroy()
	self:MyExit()
end