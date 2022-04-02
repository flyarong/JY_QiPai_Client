-- 创建时间:2020-05-11
-- Panel:Act_044_XNFLEnterPrefab
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

Act_044_XNFLEnterPrefab = basefunc.class()
local C = Act_044_XNFLEnterPrefab
C.name = "Act_044_XNFLEnterPrefab"
local M = Act_044_XNFLManager
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
	self.lister["ExitScene"] = basefunc.handler(self,self.MyExit)
	self.lister["global_hint_state_change_msg"] = basefunc.handler(self,self.on_global_hint_state_change_msg)
	self.lister["Panel_back_xnfl"] = basefunc.handler(self,self.on_panel_back)
	self.lister["finish_gift_shop"] = basefunc.handler(self,self.on_finish_gift_shop)
	--self.lister["model_xnfl_EnterPrefab_move"] = basefunc.handler(self,self.on_model_xnfl_EnterPrefab_move)

end

function C:RemoveListener()
	for proto_name,func in pairs(self.lister) do
		Event.RemoveListener(proto_name, func)
	end
	self.lister = {}
end

function C:MyExit()
	if self.huxi then
		self.huxi:Stop()
		self.huxi = nil
	end
	self:update_time(false)
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:OnDestroy()
	self:MyExit()
end

function C:ctor(parent)
	local parent = parent or GameObject.Find("Canvas/GUIRoot").transform
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
	EventTriggerListener.Get(self.enter_btn.gameObject).onClick = basefunc.handler(self, self.OnEnterClick)

	-- if os.time() >= 1591027199 then
	-- 	self:MyExit()
	-- end

	self:update_time(true)
	self:MyRefresh()

	--呼吸效果
	self.huxi = CommonHuxiAnim.Go(self.gameObject, 1.2, 0.95, 1.05)
	self.huxi:Start()
end

function C:MyRefresh()
	if M.GetHintState({gotoui = M.key}) == ACTIVITY_HINT_STATUS_ENUM.AT_Get then 
		self.LFL.gameObject:SetActive(true)
	else
		self.LFL.gameObject:SetActive(false)
		if PlayerPrefs.GetString(M.key .. MainModel.UserInfo.user_id,0) == os.date("%Y%m%d",os.time()) then 
			self.Red.gameObject:SetActive(false)
		else
			self.Red.gameObject:SetActive(true)
		end 
	end
	
	if M.GetBuyTime() == 0 then
		self.XLB.gameObject:SetActive(true)
	else
		self.XLB.gameObject:SetActive(false)
	end
end

function C:OnEnterClick()
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	PlayerPrefs.SetString(M.key .. MainModel.UserInfo.user_id, os.date("%Y%m%d",os.time()))
	Act_044_XNFLPanel.Create()
	self:MyRefresh()
end

function C:on_global_hint_state_change_msg(parm)
	if parm.gotoui == M.key then 
		self:MyRefresh()
	end 
end

function C:on_panel_back()
	self:MyRefresh()
end


function C:StopUpdateTime()
	if self.time then
		self.time:Stop()
		self.time = nil
	end
end
function C:update_time(b)
	self:StopUpdateTime()
	-- if b then
	-- 	self.time = Timer.New(function ()
	-- 		if os.time() >= 1591027199 then
	-- 			self:MyExit()
	-- 		end
	-- 	end, 10, -1, nil, true)
	-- 	self.time:Start()
	-- end
end

function C:on_finish_gift_shop(id)
	if id == M.shopid1 or M.shopid1 == id then
		self:MyRefresh()
	end
end