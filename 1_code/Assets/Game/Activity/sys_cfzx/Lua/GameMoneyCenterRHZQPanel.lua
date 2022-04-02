-- 创建时间:2018-12-20
local basefunc = require "Game.Common.basefunc"
GameMoneyCenterRHZQPanel = basefunc.class()
local C = GameMoneyCenterRHZQPanel
C.name = "GameMoneyCenterRHZQPanel"

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
	self.lister["model_query_sczd_total_rebate_value_response"] = basefunc.handler(self,self.on_query_sczd_total_rebate_value_response)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyClose()
	self:MyExit()
end

function C:MyExit()
	destroy(self.gameObject)
	if self.timer then
		self.timer:Stop()
		self.timer = nil
	end
	self:RemoveListener()
end

function C:ctor(parent)

	ExtPanel.ExtMsg(self)

	self.cfg = MoneyCenterQFLBManager.get_cfg()
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj

	self:MakeLister()
	self:AddMsgListener()
	LuaHelper.GeneratingVar(self.transform, self)
	self:InitUI()
	Network.SendRequest("query_sczd_total_rebate_value", nil, "请求数据")
	self:UpdateUI()
	self.timer = Timer.New(function(  )
		Network.SendRequest("query_sczd_total_rebate_value", nil, "请求数据")
	end,20,-1,false,false)
	self.timer:Start()
end

function C:InitUI()
	self.yqzq_txt.text = string.format( "<color=#82211CFF><size=42>%s</size></color>","邀请1位好友，最高赚133元/人，上不封顶！" )
	self.copy_wx_btn.onClick:AddListener(
		function()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
			LittleTips.Create("已复制微信号请前往微信进行添加")
			UniClipboard.SetText(self.WXCode_txt.text)
		    Application.OpenURL("weixin://");			
		end
	)
	self.start_tg_btn.onClick:AddListener(function(  )
		--开始推广
		Event.Brocast("open_money_center_tgewm")
	end)
	self.help_btn.onClick:AddListener(function(  )
		--帮助
		self.help_panel.gameObject:SetActive(true)
	end)
	self.help_close_btn.onClick:AddListener(function(  )
		--帮助
		self.help_panel.gameObject:SetActive(false)
	end)
	self.hidedesc_btn.onClick:AddListener(
		function ()
			self.hidedesc_btn.gameObject:SetActive(false)
			for i=1,3 do
				self["showdisc"..i].gameObject:SetActive(false)
			end
		end
	)
	if self.cfg and self.cfg.qflb then
		for i,v in ipairs(self.cfg.qflb) do
			self["gift"..i .. "_name_txt"].text = v.name
			self["gift"..i .. "_gain_txt"].text = v.award
			self["gift" .. i .. "_btn"].onClick:AddListener(
				function ()
					self:OnDown(v.desc,self["discnode"..i])
				end
			)
			self["name".. i .. "_txt"].text = v.name
			self["price".. i .. "_txt"].text = v.price_desc
			self["content".. i .. "_txt"].text = v.content_desc
			self["task".. i .. "_txt"].text = v.task_desc
			self["info".. i .. "_txt"].text = v.tg_explanation
		end
	end
end

function C:UpdateUI()
	if IsEquals(self.all_money_txt) then
		self.all_money_txt.text = GameMoneyCenterModel.GetRebateValue()
	end
end

function C:OnDown(desc,node)
	if node.transform.childCount == 0 then 
		if type(desc) == "table" then	
			for i = 1,#desc do 
				local b = GameObject.Instantiate(self.desc_item,self.transform)
				local t = b.gameObject.transform:GetComponent("Text")
				b.transform.parent = node
				t.text = desc[i]
				b.gameObject:SetActive(true)
			end 
		else
			local b = GameObject.Instantiate(self.desc_item,self.transform)
			local t = b.gameObject.transform:GetComponent("Text")
			b.transform.parent = node
			t.text = desc
			b.gameObject:SetActive(true)
		end 
	end
	node.parent.transform.gameObject:SetActive(true)
    self.hidedesc_btn.gameObject:SetActive(true)
end


function C:on_query_sczd_total_rebate_value_response(data)
	self:UpdateUI()
end
