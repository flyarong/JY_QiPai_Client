-- 创建时间:2020-07-24
-- Panel:Act_038_SWITCHPanel
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
-- 取消按钮音效
-- ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
-- 确认按钮音效
-- ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
--]]

local basefunc = require "Game/Common/basefunc"

Act_038_SWITCHPanel = basefunc.class()
local C = Act_038_SWITCHPanel
C.name = "Act_038_SWITCHPanel"
local M = Act_038_SWITCHManager

local DESCRIBE_TEXT = {
	"1.活动时间：9月21日7:30~9月27日23:59:59",
	--"2.活动结束后，所有的道具将被全部清除，请及时兑换",
	--"3.购买“积分礼包”后兑换时可获得额外积分奖励",
	--"4.积分可参与“积分争霸”排行榜活动，活动结束后排行榜奖励通过邮件发放",
}

--had_switch_btn 这个事件子面板的按钮点击后
--switch_panel_closed 这个事件是此面板关闭

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
	self.lister["switch_change"] = basefunc.handler(self,self.on_switch_change)
	self.lister["ExitScene"] = basefunc.handler(self,self.OnExitScene)
	self.lister["had_switch_btn"] = basefunc.handler(self,self.on_had_switch_btn)
end

function C:RemoveListener()
	for proto_name,func in pairs(self.lister) do
		Event.RemoveListener(proto_name, func)
	end
	self.lister = {}
end

function C:MyExit()
	self:CloseAll()
	if self.backcall then
		self.backcall()
	end
	if self.HuXiIndex then
		CommonHuxiAnim.Stop(self.HuXiIndex)
	end
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:ctor(parent,backcall)
	ExtPanel.ExtMsg(self)
	local parent = parent or GameObject.Find("Canvas/LayerLv4").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	self.backcall = backcall
	self.default_buttons_list = {}
	self.default_buttons = {}
	LuaHelper.GeneratingVar(self.transform, self)
	self.config = M.GetConfig()
	dump(self.config)
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	self:LoadGiftBtn()
	if next(self.config) then
		if Act_038_JFZBManager.GetBestRank() <= 20 then
			self:CreateDefaultPanel(self.config[2].gotoui)
		else
			self:CreateDefaultPanel(self.config[1].gotoui)
		end
		
	end
end

function C:InitUI()
	self.close_btn.onClick:AddListener(
		function ()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
			self:MyExit()
		end
	)
	self.help_btn.onClick:AddListener(
		function()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
			self:OpenHelpPanel()
		end
	)
	self:InitDefaultButtons()
end

function C:InitDefaultButtons()
	for i = 1,#self.config do
		self:AskChildForButton(self.config[i])
	end
end

--向子面板控制器寻求一个切页按钮
function C:AskChildForButton(config)
	local manager_str = config.gotoui
	local IsAct,button = GameButtonManager.RunFun( {gotoui = manager_str,switchPanel = self},"IButton")
	--[[需要子脚本的Manager去实现一个空的IButton方法，因为GameButtonManager.RunFun没有办法分辨\
		是此子脚本没有或者是子脚本的IButton方法没有(即：IsAct在子脚本失效或者没有实现IButton方法时都为false)\,
		如果不实现IButton方法,这个控制系统会认为该子脚本不存在，就不会帮子脚本实现一个默认的Button
	--]]
	if IsAct then
		if button then
			return button
		else
			--实现一个默认的按钮
			local button = self:CreateDefaultButton(manager_str)
			button.gameObject:SetActive(true)
			local temp_ui = {}
			LuaHelper.GeneratingVar(button.transform,temp_ui)
			self.default_buttons = self.default_buttons or {}
			self.default_buttons[manager_str] = temp_ui
			self.default_buttons_list = self.default_buttons_list or {}
			self.default_buttons_list[#self.default_buttons_list + 1] = button
			return button
		end
	end
end

--创建一个默认的按钮
function C:CreateDefaultButton(manager_str)
	local btn = GameObject.Instantiate(self.defaultButtonItem,self.buttonNode)
	local temp_ui = {}
	LuaHelper.GeneratingVar(btn.transform,temp_ui)
	self:WorkBtn(temp_ui,manager_str)
	temp_ui.main_btn.onClick:AddListener(
		function ()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
			self:CreateDefaultPanel(manager_str)
		end
	)
	btn.gameObject:SetActive(true)
	return btn
end

--根据默认按钮创建面板
function C:CreateDefaultPanel(manager_str)
	local panel = GameButtonManager.GotoUI({gotoui = manager_str,goto_scene_parm = "panel",parent = self.panelNode,switchPanel = self,mark = M.key})
	if panel then
		self.default_panels = self.default_panels or {}
		self.default_panels[manager_str] = panel
		Event.Brocast("had_switch_btn",{gotoui = manager_str})
	end
end

--响应一个按钮按下时，其他按钮需要做出反应得事件,如果按钮是自定义的,需要自己处理这个事件
function C:on_had_switch_btn(parm)
	if parm then
		self.curr_active_button = parm.gotoui
		self:RefreshDefaultButtonStatus(parm.gotoui)
		self:RefreshDefaultPanel(parm.gotoui)
	if parm.gotoui == "act_038_hldh" then
			self.HuXiIndex = CommonHuxiAnim.Start(self.hongbao.gameObject,0.6)
		else
			if self.HuXiIndex then
				CommonHuxiAnim.Stop(self.HuXiIndex)
			end
		end
	end
end

--刷新所有默认按钮的状态
function C:RefreshDefaultButtonStatus(manager_str)
	for k,v in pairs(self.default_buttons) do
		if k == manager_str then
			v.Mask.gameObject:SetActive(true)
		else
			v.Mask.gameObject:SetActive(false)
		end
	end

end

function C:RefreshDefaultPanel(manager_str)
	for k,v in pairs(self.default_panels or {}) do
		if k == manager_str then

		else
			if v.onDestroy then
				v:onDestroy()
			elseif v.MyExit then
				v:MyExit()
			end
			v = nil
		end
	end 
end

function C:CloseAll()
	self:RefreshDefaultPanel()
	Event.Brocast("switch_panel_closed")
end

function C:ChangeLookAt(obj)
	obj.transform.localScale = Vector2.New(obj.transform.localScale.x * -1,obj.transform.localScale.y)
end

function C:WorkBtn(temp_ui,manager_str)
	if manager_str == "act_038_hldh" then
		dump(temp_ui)
		temp_ui.main_img.sprite = GetTexture("bzdh_imgf_hldh1")
		temp_ui.mask_img.sprite  = GetTexture("bzdh_imgf_hldh2")			
	else
		self:ChangeLookAt(temp_ui.main_btn.gameObject)
		self:ChangeLookAt(temp_ui.Mask.gameObject)
		self:ChangeLookAt(temp_ui.main_img.gameObject)
		self:ChangeLookAt(temp_ui.mask_img.gameObject)
		temp_ui.main_img.sprite  = GetTexture("bzdh_imgf_jfzb1")
		temp_ui.mask_img.sprite  = GetTexture("bzdh_imgf_jfzb2")
	end
end

function C:OnExitScene()
	self:MyExit()
end

function C:OpenHelpPanel()
	local str = DESCRIBE_TEXT[1]
	for i = 2, #DESCRIBE_TEXT do
		str = str .. "\n" .. DESCRIBE_TEXT[i]
	end
	self.introduce_txt.text = str
	IllustratePanel.Create({ self.introduce_txt.gameObject }, GameObject.Find("Canvas/LayerLv5").transform)
end

function C:on_switch_change(index)
	if index and self.config[index]  then
		self:CreateDefaultPanel(self.config[index].gotoui)
	end
end

function C:LoadGiftBtn()
	local _parm = {}
	GameManager.GotoUI({gotoui="act_ty_gifts", goto_scene_parm="enter", goto_type = "gift_wykl_jflb",parent = self.gift_node.transform})
end