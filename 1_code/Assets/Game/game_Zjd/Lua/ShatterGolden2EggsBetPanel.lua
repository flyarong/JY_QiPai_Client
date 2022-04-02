local basefunc = require "Game.Common.basefunc"

ShatterGolden2EggsBetPanel = basefunc.class()
ShatterGolden2EggsBetPanel.name = "ShatterGolden2EggsBetPanel"
local config=ShatterGoldenEggModel.getConfig()
local instance = nil

function ShatterGolden2EggsBetPanel:MakeLister()
	self.lister = {}
	self.lister["view_sge_close"] = basefunc.handler(self, self.handle_sge_close)
	self.lister["ExitScene"] = basefunc.handler(self, self.OnExitScene)
	self.lister["ZJDQuit"] = basefunc.handler(self, self.OnExitScene)
	self.lister["OnLoginResponse"] = basefunc.handler(self, self.OnExitScene)
	self.lister["will_kick_reason"] = basefunc.handler(self, self.OnExitScene)
	self.lister["DisconnectServerConnect"] = basefunc.handler(self, self.OnExitScene)
end

function ShatterGolden2EggsBetPanel:AddMsgListener()
    for proto_name, func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function ShatterGolden2EggsBetPanel:RemoveListener()
    for proto_name, func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function ShatterGolden2EggsBetPanel.Create(parent)
	if not instance then
		instance = ShatterGolden2EggsBetPanel.New(parent)
	end
	if IsEquals(instance.gameObject) then 
		instance.gameObject:SetActive(true)
	end  
	return instance
end

function ShatterGolden2EggsBetPanel:ctor(parent)

	ExtPanel.ExtMsg(self)

	local obj = newObject(ShatterGolden2EggsBetPanel.name, parent)
	self.transform = obj.transform
	self.gameObject=self.transform.gameObject
	LuaHelper.GeneratingVar(self.transform, self)
	self.ButtonChild=self.transform:Find("Button")
	self.Content=self.transform:Find("Image/BG")
	self:InitRect()
	local index=  self.GetBestBet()
	self:MakeLister()
	self:AddMsgListener()
	self:OnButtonDown(index)
end

function ShatterGolden2EggsBetPanel:MyExit()
	self:RemoveListener()
	destroyChildren(self.Content)
	destroy(self.gameObject)	
end

function ShatterGolden2EggsBetPanel.Close()
	if instance then
		instance:MyExit()
		instance = nil
	end
end

function ShatterGolden2EggsBetPanel.IsShow()
	if not instance then return false end
	if IsEquals(instance.transform) then
		return instance.transform.gameObject.activeSelf
	end
	return false
end

function ShatterGolden2EggsBetPanel:InitRect()
	local transform = self.transform
	
	EventTriggerListener.Get(self.check_click.gameObject).onClick = basefunc.handler(self, self.handle_click)
	self.childs={}
	for i = 1, #config.extra2eggs do
		local b= GameObject.Instantiate(self.ButtonChild, self.Content)
		b.transform:Find("Image"):GetComponent("Image").sprite=GetTexture("zjd_btn_dc2")
		b.transform:Find("Text"):GetComponent("Text").text=StringHelper.ToCash(config.extra2eggs[i].base_money).."鲸币"
		b.gameObject:SetActive(true)
		b.gameObject:GetComponent("Button").onClick:AddListener(
			function ()
				self:OnButtonDown(i)
			end
		)
		self.childs[#self.childs+1]=b

	end

	self:Refresh()
end

function ShatterGolden2EggsBetPanel:Refresh()
	local hammer_idx = ShatterGoldenEggLogic.GetHammer()
	local award = ShatterGoldenEggModel.getAward(hammer_idx)
	if not award or #award <= 0 then
		print("[SGE] award refresh getAward is invalid:" .. hammer_idx)
		return
	end

	--self:FillItemList(award)
end

function ShatterGolden2EggsBetPanel.GetBestBet()
	if MainModel.UserInfo.jing_bi<=config.extra2eggs[1].auto_select_max_money then
		return 1 
	end 
	if  MainModel.UserInfo.jing_bi >= config.extra2eggs[#config.extra2eggs].auto_select_max_money then
		return #config.extra2eggs 
	end
	for i=#config.extra2eggs,1,-1 do
		if i-1==0 then
			return 1
		end
		if MainModel.UserInfo.jing_bi<= config.extra2eggs[i].auto_select_max_money 
		and MainModel.UserInfo.jing_bi>=config.extra2eggs[i-1].auto_select_max_money 
		then 
			return  i
		end 		 
	end	
end

function ShatterGolden2EggsBetPanel:OnButtonDown(index)
	--去改变押注
	for i = 1, #self.childs do
		self.childs[i].transform:Find("Image"):GetComponent("Image").sprite=GetTexture("zjd_btn_dc2")
		self.childs[i].transform:Find("Text"):GetComponent("Text").color=Color.New(1,1,1,1)
	end
	self.childs[index].transform:Find("Image"):GetComponent("Image").sprite=GetTexture("zjd_btn_dc1")
	self.childs[index].transform:Find("Text"):GetComponent("Text").color=Color.New(207/255,111/255,24/255)
	Event.Brocast("2egg_bet_change",index)
	self.gameObject:SetActive(false)
end


function ShatterGolden2EggsBetPanel:handle_click()
	self.gameObject:SetActive(false)	
end

function ShatterGolden2EggsBetPanel:handle_sge_close()
	ShatterGolden2EggsBetPanel.Close()
end

function ShatterGolden2EggsBetPanel:OnExitScene()
	ShatterGolden2EggsBetPanel.Close()
end

