-- 创建时间:2019-12-03
-- Panel:NewOneYuanEnterPrefab
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

NewOneYuanEnterPrefab = basefunc.class()
local C = NewOneYuanEnterPrefab
C.name = "NewOneYuanEnterPrefab"
C.key = "sys_xbyylb"
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
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	if self.timer then 
		self.timer:Stop()
	end 
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:ctor(parent)
	local parent = parent or GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject("xbyylb_btn", parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	self.Button = self.transform:GetComponent("Button")
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	self.Button.onClick:AddListener(
		function ()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
			NewOneYuanPanel.Create()
		end
	)
	self:MyRefresh()
end

function C:MyRefresh()
	local s = GameButtonManager.GetHintState({gotoui = C.key})
	if s == ACTIVITY_HINT_STATUS_ENUM.AT_Nor then 
		self.Red.gameObject:SetActive(false)
		self.LFL.gameObject:SetActive(false)		
	else 
		if s == ACTIVITY_HINT_STATUS_ENUM.AT_Get then 
			self.Red.gameObject:SetActive(false)
			self.LFL.gameObject:SetActive(true)
		elseif ACTIVITY_HINT_STATUS_ENUM.AT_Red then 
			self.Red.gameObject:SetActive(true)
			self.LFL.gameObject:SetActive(false)
		end
	end 
	if MainModel.GetGiftShopStatusByID(NewOneYuanManager.GetShopID()) == 0 and GameTaskModel.GetTaskDataByID(NewOneYuanManager.GetTaskID()) then 
		self.timer_txt.gameObject.transform.parent.gameObject:SetActive(true)
	else
		self.timer_txt.gameObject.transform.parent.gameObject:SetActive(false)
		self.timer_txt.gameObject.transform.parent.gameObject:SetActive(true)
	end
	self:InitTimer()
end

function C:OnDestroy()
	self:MyExit()
end

function C:InitTimer()
	local T
	if  MainModel.GetGiftShopStatusByID(NewOneYuanManager.GetShopID()) == 1 then
		T = MainModel.FirstLoginTime() + 7 * 86400
	elseif GameTaskModel.GetTaskDataByID(NewOneYuanManager.GetTaskID()) then 
		T = NewOneYuanManager.DisappearTime(tonumber(GameTaskModel.GetTaskDataByID(NewOneYuanManager.GetTaskID()).create_time))	
	end 
	local t = T - os.time()
	if self.timer then 
		self.timer:Stop()
	end 
	self.timer_txt.text = StringHelper.formatTimeDHMS3(t)
	self.timer = Timer.New(function ()
		t = t - 1 
		if t < 0 then 
			t = 0
		end 
		self.timer_txt.text = StringHelper.formatTimeDHMS3(t)
	end,1,-1)
	self.timer:Start()
end

