local basefunc = require "Game/Common/basefunc"

Act_027_ZNQWYJNBPanel = basefunc.class()
local C = Act_027_ZNQWYJNBPanel
C.name = "Act_027_ZNQWYJNBPanel"

local instance
function C.Create()
    if instance then
        instance:MyExit()
    end
    instance = C.New()
	return instance
end

function C.Close()
    if instance then
        instance:MyExit()
    end
    instance = nil
end

function C:AddMsgListener()
	for proto_name,func in pairs(self.lister) do
		Event.AddListener(proto_name, func)
	end
end

function C:MakeLister()
	self.lister = {}
	self.lister["model_task_change_msg"] = basefunc.handler(self,self.on_model_task_change_msg)
	self.lister["model_query_one_task_data_response"] = basefunc.handler(self,self.on_model_query_one_task_data_response)
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
    instance = nil
end

function C:ctor()
    ExtPanel.ExtMsg(self)
    self:ChangeTaskUI()
	local parent = parent or GameObject.Find("ActivityYearPanel_2").transform
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
	self:MyRefresh()
end

function C:MyRefresh()
    self.task_data = GameTaskModel.GetTaskDataByID(Act_027_ZNQWYJNBManager.task_id)
    if table_is_null(self.task_data) then return end
    dump(self.task_data,"<color=white>task_data</color>")
    self.cur_txt.text = StringHelper.ToCash(self.task_data.now_total_process)
	self.need_txt.text = StringHelper.ToCash(self.task_data.need_process - self.task_data.now_process)
end

function C:OnDestroy()
	self:MyExit()
end

function C:on_model_task_change_msg(task_data)
    if task_data.id ~= Act_027_ZNQWYJNBManager.task_id then return end 
    self:MyRefresh()
end

function C:on_model_query_one_task_data_response(task_data)
    if task_data.id ~= Act_027_ZNQWYJNBManager.task_id then return end 
    self:MyRefresh()
end

function C:ChangeTaskUI()
    local tp = GameObject.Find("ActivityTaskPanel")
    if not IsEquals(tp) then return end
    tp = tp.transform
    local ui = tp:Find("BG"):GetComponent("Image")
    ui.sprite = GetTexture("yjlqjnb_bg")
    ui = ui.transform:GetComponent("RectTransform")
    ui.sizeDelta = Vector2.New(1130,786)
    ui.gameObject:SetActive(true)
    ui = tp:Find("@help_btn"):GetComponent("Image")
    ui.sprite = GetTexture("pzsl_btn_hdgz_activity_act_027_znqwyjnb")
    ui:SetNativeSize()
    ui.gameObject:SetActive(true)
    ui = tp:Find("@Center/@sv_item(Clone)"):GetComponent("RectTransform")
    ui.sizeDelta = Vector2.New(1092,512)
    local ui_content = tp:Find("@Center/@sv_item(Clone)/Viewport/@sv_content")
    local count = ui_content.childCount;
    local child
    for i=0, count-1, 1 do
        child = ui_content:GetChild(i);
        ui = child:Find("BG"):GetComponent("Image")
        ui.sprite = GetTexture("yjlqjnb_bg_1")
        ui = child:Find("title"):GetComponent("Text")
        ui.color = Color.New(112/255,52/255,6/255,1)
        ui = child:Find("progress")
        ui.gameObject:SetActive(false)
        ui = child:Find("list_node/item_tmpl(Clone)/icon/count"):GetComponent("Text")
        ui.fontSize = 48
        ui.color = Color.New(245/255,238/255,191/255,1)
        ui = ui.gameObject:AddComponent(typeof(UnityEngine.UI.Outline))
        ui.effectColor = Color.New(166/255,101/255,71/255,1)
    end
    child = nil
    count = nil
    ui_content = nil
    ui = nil
    tp = nil
end

--[[
    GetTexture("znqd_bg_2")
]]