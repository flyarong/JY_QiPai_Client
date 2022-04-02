-- 创建时间:2019-09-16
-- Panel:WelComeToSHPanel
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

WelComeToSHPanel = basefunc.class()
local C = WelComeToSHPanel
C.name = "WelComeToSHPanel"

local Begin_time= -1 
local End_time=1569859199
function C.Create(callback)
	return C.New(callback)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	self:RemoveListener()
	if self.callback then 
		self.callback()
	end 
	destroy(self.gameObject)

	 
end

function C:ctor(callback)

	ExtPanel.ExtMsg(self)

	local parent = GameObject.Find("Canvas/LayerLv5").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	self.callback=callback
	self.gameObject:SetActive(false)
	LuaHelper.GeneratingVar(self.transform, self)
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	self:OnButtonClick()
	if os.time() < Begin_time or os.time() > End_time then 
		print("<color=red>时间不满足条件</color>")
		self:MyExit()
		return 
	end
	
	-- if MainModel.UserInfo.ui_config_id ~= 1 then
	-- 	print("<color=red>不是老玩家</color>")
	-- 	self:MyExit()
	-- 	return 	
	-- end 	
	if PlayerPrefs.GetInt("WelComeToSH".."once"..MainModel.UserInfo.user_id,0)==1 then 
		print("<color=red>已经进入过一次水浒消消乐</color>")
		self:MyExit()
		return 		
	end  
	self.gameObject:SetActive(true)
end

function C:InitUI()
	self:MyRefresh()
	self.Button=self.transform:Find("Button"):GetComponent("Button")
	self.Text2=self.transform:Find("2/Text"):GetComponent("Text")
	self.GoButton=self.transform:Find("2/GoButton"):GetComponent("Button")
	self.panel2=self.transform:Find("2")
	self.panel1=self.transform:Find("1")
	self.NameText=self.panel2.transform:Find("NameText"):GetComponent("Text")
	self.NameText.text=MainModel.UserInfo.name
	self:MyRefresh()
	self.panel1.gameObject:SetActive(true)
	self.panel2.gameObject:SetActive(false)
end

function C:OnButtonClick()
	self.Button.onClick:AddListener(
		function ()
			self.panel2.gameObject:SetActive(true)
			self.panel1.gameObject:SetActive(false)
		end
	)
	self.GoButton.onClick:AddListener(
		function ()
			GameManager.CommonGotoScence({gotoui="game_EliminateSH"}, function ()
				self.callback=nil 	
				PlayerPrefs.SetInt("WelComeToSH".."once"..MainModel.UserInfo.user_id,1)
				self:MyExit()	
			end)
		end
	)
end

function C:MyRefresh()
end
