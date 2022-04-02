-- 创建时间:2018-12-20
local basefunc = require "Game.Common.basefunc"
GameMoneyCenterRHZQ1Panel = basefunc.class()
local C = GameMoneyCenterRHZQ1Panel
C.name = "GameMoneyCenterRHZQ1Panel"

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
	self.is_help_opened = PlayerPrefs.GetInt("RHZQ1" .. MainModel.UserInfo.user_id, 0) == 1
	-- self.yqzq_txt.text = string.format( "<color=#82211CFF><size=42>%s</size></color>","邀请1位好友，最高赚141元！" )
	self.copy_wx_btn.onClick:AddListener(
		function()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
			LittleTips.Create("已复制微信号请前往微信进行添加")
			UniClipboard.SetText(self.WXCode_txt.text)
		    Application.OpenURL("weixin://");			
		end
	)
	self.yqhy_btn.onClick:AddListener(function(  )
		--邀请好友
		local share_cfg = basefunc.deepcopy(share_link_config.img_money_center_rhzq)
		GameManager.GotoUI({gotoui = "sys_fx",goto_scene_parm = "panel",share_cfg = share_cfg})
	end)
	self.lb_btn.onClick:AddListener(function(  )
		--查看礼包
		GameManager.GotoUI({gotoui = "sys_cfzx_qflb",goto_scene_parm = "panel"})
	end)
	self.help_btn.onClick:AddListener(function(  )
		--帮助
		self.help_panel.gameObject:SetActive(true)
		PlayerPrefs.SetInt("RHZQ1" .. MainModel.UserInfo.user_id, 1)
		self.is_help_opened = true
		self.help_particle.gameObject:SetActive(not self.is_help_opened)
	end)
	self.help_particle.gameObject:SetActive(not self.is_help_opened)
	self.help_close_btn.onClick:AddListener(function(  )
		--帮助
		self.help_panel.gameObject:SetActive(false)
	end)
	if gameMgr:getMarketPlatform() ~= "normal" then
		self.transform:Find("bg/Text (3)").gameObject:SetActive(false)
	end

	if gameRuntimePlatform == "Ios" then
		for i=1,4 do
			self["android_txt" .. i].gameObject:SetActive(false)
			self["ios_txt" .. i].gameObject:SetActive(true)
		end
	end

	GameManager.GotoUI({gotoui = "sys_open_install_binding",goto_scene_parm = "rhzq"})
end

function C:UpdateUI()
	if IsEquals(self.all_money_txt) then
		self.all_money_txt.text = GameMoneyCenterModel.GetRebateValue()
	end
end

function C:on_query_sczd_total_rebate_value_response(data)
	self:UpdateUI()
end
