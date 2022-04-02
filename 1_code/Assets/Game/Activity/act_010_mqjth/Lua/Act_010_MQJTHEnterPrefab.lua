-- 创建时间:2020-04-23
-- Panel:Act_010_MQJTHEnterPrefab
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

Act_010_MQJTHEnterPrefab = basefunc.class()
local C = Act_010_MQJTHEnterPrefab
C.name = "Act_010_MQJTHEnterPrefab"

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

    self.lister["global_hint_state_change_msg"] = basefunc.handler(self,self.on_global_hint_state_change_msg)
	self.lister["Panel_back_mqjth"] = basefunc.handler(self,self.on_panel_back)

	self.lister["MQJTHManager_CreateFlowerItemInGame"] = basefunc.handler(self,self.CreateFlowerItemInGame)
	self.lister["ExitScene"] = basefunc.handler(self,self.MyExit)
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
	self:MyRefresh()
end

function C:MyRefresh()
	if Act_010_MQJTHManager.GetHintState({gotoui = Act_010_MQJTHManager.key}) == ACTIVITY_HINT_STATUS_ENUM.AT_Get then 
		self.LFL.gameObject:SetActive(true)
	else
		self.LFL.gameObject:SetActive(false)
		if PlayerPrefs.GetString(Act_010_MQJTHManager.key .. MainModel.UserInfo.user_id,0) == os.date("%Y%m%d",os.time()) then 
			self.Red.gameObject:SetActive(false)
		else
			self.Red.gameObject:SetActive(true)
		end 
	end
end


function C:OnEnterClick()
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	PlayerPrefs.SetString(Act_010_MQJTHManager.key .. MainModel.UserInfo.user_id, os.date("%Y%m%d",os.time()))
	Act_010_MQJTHPanel.Create()
	self:MyRefresh()
end


function C:on_global_hint_state_change_msg(parm)
	if parm.gotoui == Act_010_MQJTHManager.key then 
		self:MyRefresh()
	end 
end

function C:on_panel_back()
	self:MyRefresh()
end

function C:CreateFlowerItemInGame(score)
	local pre = Act_010_MQJTHFlowerItemInGame.Create(score,self.transform)
	if self.spawn_cell_list == nil then
		self.spawn_cell_list = {}
	end
	if pre then
		self.spawn_cell_list[#self.spawn_cell_list + 1] = pre
	end
end

function C:CloseItemPrefab()
	if self.spawn_cell_list then
		for k,v in ipairs(self.spawn_cell_list) do
			v:MyExit()
		end
	end
	self.spawn_cell_list = {}
end