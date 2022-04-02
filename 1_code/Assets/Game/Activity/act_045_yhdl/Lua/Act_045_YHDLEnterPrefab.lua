local basefunc = require "Game/Common/basefunc"

Act_045_YHDLEnterPrefab = basefunc.class()
local C = Act_045_YHDLEnterPrefab
C.name = "Act_045_YHDLEnterPrefab"
local M = Act_045_YHDLManager
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
	--self.lister["model_xnfl_EnterPrefab_move"] = basefunc.handler(self,self.on_model_xnfl_EnterPrefab_move)

end

function C:RemoveListener()
	for proto_name,func in pairs(self.lister) do
		Event.RemoveListener(proto_name, func)
	end
	self.lister = {}
end

function C:MyExit()
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

	self:MyRefresh()
end

function C:MyRefresh()
	if M.GetHintState({gotoui = M.key}) == ACTIVITY_HINT_STATUS_ENUM.AT_Get then 
		self.lfl.gameObject:SetActive(true)
	else
		self.lfl.gameObject:SetActive(false)
		if PlayerPrefs.GetString(M.key .. MainModel.UserInfo.user_id,0) == os.date("%Y%m%d",os.time()) then 
			self.red.gameObject:SetActive(false)
		else
			self.red.gameObject:SetActive(true)
		end 
	end
end


function C:Ck(_permission_key)
	if _permission_key then
		local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key=_permission_key, is_on_hint = true}, "CheckCondition")
		if a and not b then
			return false
		end
		return true
	else
		return true
	end
end



function C:OnEnterClick()
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	PlayerPrefs.SetString(M.key .. MainModel.UserInfo.user_id, os.date("%Y%m%d",os.time()))
	if self:Ck("wqp_to_hlby_conversion") then
		SYSACTBASEManager.CreateHallAct(nil,nil,{ID = 165})
	else
		SYSACTBASEManager.CreateHallAct(nil,nil,{ID = 164})
	end
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