-- 创建时间:2019-08-19
-- Panel:BeginLookBackPanel
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

BeginLookBackPanel = basefunc.class()
local C = BeginLookBackPanel
C.name = "BeginLookBackPanel"
local config -- = GameActivityManager.lookbackconfig
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
	self.lister["query_znq_look_back_base_info_response"]=basefunc.handler(self,self.onGetInfo)
end


function C:onGetInfo(_,data)
	dump(data,"---------")
	if data and data.result==0 and 	IsEquals(self.gameObject) then 
		self.basedata=data
		self.DayText.text= 365 -- data.player_data.login_day
		self.NameText.text=MainModel.UserInfo.name..":"
		self.gameObject:SetActive(true)
	else
		print("<color=red>不是名单中的人</color>")
		self:MyExit()
	end 
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
	--PlayerPrefs.DeleteAll()
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
	if os.time() < config.time[1].begintime or os.time() > config.time[1].endtime then 
		print("<color=red>时间不满足条件</color>")
		self:MyExit()
		return 
	end 	
	if PlayerPrefs.GetInt("lookback".."once"..MainModel.UserInfo.user_id,0)==1 then 
		print("<color=red>已经显示过一次</color>")
		self:MyExit()
		return 
	else
		PlayerPrefs.SetInt("lookback".."once"..MainModel.UserInfo.user_id,1) 			
	end  
	Network.SendRequest("query_znq_look_back_base_info", nil, "")
end

function C:InitUI()
	self.Button=self.transform:Find("Button"):GetComponent("Button")
	self.Text2=self.transform:Find("2/Text"):GetComponent("Text")
	self.GoButton=self.transform:Find("2/GoButton"):GetComponent("Button")
	self.panel2=self.transform:Find("2")
	self.panel1=self.transform:Find("1")
	self.DayText=self.panel2.transform:Find("DayText"):GetComponent("Text")
	self.NameText=self.panel2.transform:Find("NameText"):GetComponent("Text")
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
			LookBackPanel.Create(self.callback)
			self.callback=nil 		
			self:MyExit()	
		end
	)
end
function C:MyRefresh()
end
