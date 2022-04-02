local basefunc = require "Game/Common/basefunc"

TeacherAndPupilPanel = basefunc.class()
local C = TeacherAndPupilPanel
C.name = "TeacherAndPupilPanel"
local btn_image = "sczd_btn_xz_activity_sys_stxt"
local btn_mask = "sczd_btn_xuanz_activity_sys_stxt"
local Button_DataS = {
	[1] = {name = "拜 师",goto_ui = "GetTeacher",},
	[2] = {name = "收 徒",goto_ui = "GetPupil"},
	[3] = {name = "我的徒弟",goto_ui = "MyPupil"},
	[4] = {name = "我的师傅",goto_ui = "MyTeacher"},
}

local Panel_DataS = {
	[1] = {name = "GetTeacherPanel",goto_ui = "GetTeacher"},
	[2] = {name = "GetPupilPanel",goto_ui = "GetPupil"},
	[3] = {name = "MyPupilPanel",goto_ui = "MyPupil"},
	[4] = {name = "MyTeacherPanel",goto_ui = "MyTeacher"},
}
local Buttons_UI
local Panels
function C.Create(parent,cfg)
	return C.New(parent,cfg)
end

function C:AddMsgListener()
	for proto_name,func in pairs(self.lister) do
		Event.AddListener(proto_name, func)
	end
end

function C:MakeLister()
	self.lister = {}
	self.lister["query_my_total_like_num_response"] = basefunc.handler(self,self.on_query_my_total_like_num_response)
	self.lister["tp_CloseTHENOpen"] = basefunc.handler(self,self.on_tp_CloseTHENOpen)
	self.lister["ExitScene"] = basefunc.handler(self,self.MyExit)
end

function C:RemoveListener()
	for proto_name,func in pairs(self.lister) do
		Event.RemoveListener(proto_name, func)
	end
	self.lister = {}
end

function C:MyExit()
	self:RemoveListener()
	self:DestroyAllPanel()
	destroy(self.gameObject)

	 
end

function C:ctor(parent,cfg)

	ExtPanel.ExtMsg(self)

	local parent = parent or GameObject.Find("Canvas/LayerLv5").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	Buttons_UI = {}
	Panels = {}
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	self:SetDefaultButton(cfg)
	Network.SendRequest("query_my_total_like_num")
end

function C:InitUI()
	Buttons_UI = self:InitAllButton(Button_DataS)
	self.close_btn.onClick:AddListener(
		function ()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
			self:MyExit()  
		end
	)
	self:MyRefresh()
end

function C:MyRefresh()
	self:Refresh_Button_Red()
end

function C:OnButtonClick(Button_Data)
	if Button_Data.goto_ui == self.Curr_UI then 
		return
	end 
	self:SetAllButtonMask()
	self:HideAllPanel()
	self:SetButtonMaskAcive(Buttons_UI[Button_Data.name],true)
	self:Goto_UI(Button_Data.goto_ui)
	self.Curr_UI = Button_Data.goto_ui
end

function C:Goto_UI(goto_ui)
	local panelName = self:GetPanelByGoToUI(goto_ui)
	if panelName then
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name) 
		if Panels[goto_ui] then 
			Panels[goto_ui].gameObject:SetActive(true)
		else
			if _G[panelName] then
				if _G[panelName].Create then 
					Panels[goto_ui] = _G[panelName].Create(self.panelContent)
				else
					print("该脚本没有实现Create")
				end 
			else
				print("该脚本没有载入")
			end 
		end 
	else
		print("没有这个goto_ui 或者是没得这个goto_ui对应的panel，总之检查配置")
	end 
end

function C:HideAllPanel()
	for k,v in pairs(Panels) do
		if IsEquals(v) then 
			v:OnDestroy()
			Panels[k] = nil
		else
			v = nil
		end 
	end 
end

function C:DestroyAllPanel()
	dump(Panels,"DestroyAllPanel")
	for k , v in pairs(Panels) do 
		if v.OnDestroy then 
			v:OnDestroy()
		end 
	end
end

function C:SetAllButtonMask()
	for k , v in pairs(Buttons_UI) do
		if IsEquals(v) then 
			self:SetButtonMaskAcive(v,false)
		end 
	end
end

function C:InitAllButton(Button_DataS)
	local buttons_ui = {}
	for i = 1,#Button_DataS do
		local b = GameObject.Instantiate(self.buttonItem_btn,self.buttonContent)
		b.gameObject:SetActive(true)
		local temp_ui = {}
		LuaHelper.GeneratingVar(b.transform,temp_ui)
		temp_ui.buttonName_txt.text = Button_DataS[i].name
		temp_ui.buttonMaskName_txt.text =  Button_DataS[i].name
		b.onClick:AddListener(
			function ()
				self:OnButtonClick(Button_DataS[i])
			end
		)
		buttons_ui[Button_DataS[i].name] = b
	end
	return 	buttons_ui
end

function C:SetButtonMaskAcive(button_ui,active)
	local temp_ui = {}
	LuaHelper.GeneratingVar(button_ui.transform,temp_ui)
	temp_ui.buttonItemMask.gameObject:SetActive(active)
	temp_ui.buttonItemBG.gameObject:SetActive(not active)
end

function C:OnDestroy()
	self:MyExit()
end

function C:GetPanelByGoToUI(gotoui)
	for k ,v in pairs(Panel_DataS)	do
		if v.goto_ui == gotoui then 
			return v.name
		end 
	end 
end

function C:GetButtonDataByGotoUI(gotoui)
	for k,v in pairs(Button_DataS) do  
		if 	v.goto_ui == gotoui then 
			return v
		end 
	end
	print("无此分页，再次确认") 
end
--设置默认打开的分页↓
--设置默认打开的分页↓
--设置默认打开的分页↓
--设置默认打开的分页↓
--设置默认打开的分页↓
function C:SetDefaultButton(cfg)
	local button_data
	if cfg and cfg.gotoui then 
		button_data = self:GetButtonDataByGotoUI(cfg.gotoui)
	end 
	self:OnButtonClick(button_data or Button_DataS[1])
end

function C:on_query_my_total_like_num_response(_,data)
	if data and data.result == 0 then
		self.hz_txt.text = data.total_like_num
	end 
end
--重新关闭页面再打开指定分页，相当于强制刷新
function C:on_tp_CloseTHENOpen(gotoUI)
	self:MyExit()
	local gotoUI  = gotoUI or self.Curr_UI
	TeacherAndPupilPanel.Create(nil,{gotoui = gotoUI})
end

function C:Refresh_Button_Red()
	local temp_ui = {}
	local temp_button_data 
	for k,v in pairs(Buttons_UI) do 
		LuaHelper.GeneratingVar(v.transform,temp_ui)
		temp_button_data = self:GetButtonDataByName(k)
		if temp_button_data then 
			temp_ui.red_img.gameObject:SetActive(SYSSTXTManager.CheakRed(temp_button_data.goto_ui))
		end 
	end
end

function C:GetButtonDataByName(button_name)
	for k,v in pairs(Button_DataS) do  
		if 	v.name == button_name then 
			return v
		end 
	end
	print("无此分页，再次确认:::"..button_name) 
end