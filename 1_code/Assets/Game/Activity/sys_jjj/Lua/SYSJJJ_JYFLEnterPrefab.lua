-- 创建时间:2019-12-20
-- Panel:SYSJJJ_JYFLEnterPrefab
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

SYSJJJ_JYFLEnterPrefab = basefunc.class()
local C = SYSJJJ_JYFLEnterPrefab
C.name = "SYSJJJ_JYFLEnterPrefab"

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
	self.lister["global_hint_state_change_msg"] = basefunc.handler(self,self.MyRefresh)
	self.lister["query_broke_subsidy_is_can_get_response"] = basefunc.handler(self,self.query_broke_subsidy_is_can_get)
	self.lister["ExitScene"] = basefunc.handler(self,self.MyExit)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	if self.main_timer then 
		self.main_timer:Stop()
	end
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
	LuaHelper.GeneratingVar(self.transform, self)
	self.slider = self.HBSlider:GetComponent("Slider")
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	self:GetData()
	Network.SendRequest("query_broke_subsidy_is_can_get",nil)
end

function C:InitUI()
	self.BG_btn.onClick:AddListener(
		function ()
			self:Go()
		end
	)
	self.get_btn.onClick:AddListener(
		function ()
			self:Go()
		end
	)
	self:MyRefresh()
end

function C:MyRefresh()
	if IsEquals(self.gameObject) then 
		if SysJJJManager.GetHintState() == ACTIVITY_HINT_STATUS_ENUM.AT_Get  then
			self.get_btn.transform:GetComponent("Image").sprite = GetTexture("com_btn_5")
		else
			self.get_btn.transform:GetComponent("Image").sprite = GetTexture("com_btn_8")
		end
		local m_share = MainModel.UserInfo.shareCount or 0
		local m_free = MainModel.UserInfo.freeSubsidyNum or 0
		self.time_txt.text = "还可领".. (m_share + m_free) .."次"
		local shareAllNum = MainModel.UserInfo.shareAllNum or 0
		local freeSubsidyAllNum = MainModel.UserInfo.freeSubsidyAllNum or 0
		local totalnum = shareAllNum + freeSubsidyAllNum
		self.totalnum = totalnum
		self.slider.value = (totalnum - (m_share + m_free)) / totalnum 
		self.slider_txt.text = (totalnum - (m_share + m_free)).."/"..totalnum
	end 
end

function C:OnDestroy()
	self:MyExit()
end

function C:Go()
	if (not MainModel.UserInfo.shareCount or MainModel.UserInfo.shareCount <= 0) and (not MainModel.UserInfo.freeSubsidyNum or MainModel.UserInfo.freeSubsidyNum <= 0) then 
		HintPanel.Create(1,"今天的次数已领完")
		return 
	end
	if MainModel.UserInfo.jing_bi >= 3000 then 
		HintPanel.Create(1,"鲸币少于3000时，可免费领取")
		return
	end
	OneYuanGift.ChekcBroke()
end

function C:GetData()
	SysJJJManager.SentQ()
	if self.main_timer then 
		self.main_timer:Stop()
	end
	self.main_timer = Timer.New(function()
		if self.totalnum == 0 then 
			SysJJJManager.SentQ()
		else
			if self.main_timer then 
				self.main_timer:Stop()
			end
		end 
	end,5,-1)
	self.main_timer:Start()
end

function C:query_broke_subsidy_is_can_get(_,data)
	if not IsEquals(self.gameObject) then return end
	MainModel.UserInfo.query_broke_subsidy_is_can_get = data.is_can == 1
	if MainModel.UserInfo.query_broke_subsidy_is_can_get then return end
	self.BG_btn.onClick:RemoveAllListeners()
	self.BG_btn.onClick:AddListener(
		function ()
			HintPanel.Create(1,"正在游戏中无法领取")
		end
	)
	self.get_btn.onClick:RemoveAllListeners()
	self.get_btn.onClick:AddListener(
		function ()
			HintPanel.Create(1,"正在游戏中无法领取")
		end
	)
	local img = self.get_btn.transform:GetComponent("Image")
	if IsEquals(img) then
		img.sprite = GetTexture("com_btn_8")
	end
end