local basefunc = require "Game/Common/basefunc"

XRHB1EnterPrefab = basefunc.class()
local C = XRHB1EnterPrefab
C.name = "XRHB1EnterPrefab"

function C.Create(parent, cfg)
	return C.New(parent, cfg)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
	self.lister["module_global_hint_state_change_msg"] = basefunc.handler(self, self.on_global_hint_state_change_msg)
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
	self:ResetGame()
end

function C:ctor(parent, cfg)
	self.config = cfg

	local obj = newObject("XRHB1EnterPrefab", parent)
	local tran = obj.transform
	--dump(parent.name , "<color=white>ParentName</color>")
	self.transform = tran
	self.gameObject = obj

	if string.find(parent.name , "@lc_btn") then--or string.find(parent.name , "@rt_btn_1") then
		obj.name = "XRHB1EnterPrefab_1"
	end
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()

	--self.transform.localPosition = Vector3.zero
	self.HongBaoAnimator = self.transform:Find("iconNode/hongbao"):GetComponent("Animator")
	self:InitUI()
	self:ChangeGame()
end

function C:InitUI()
	self.enter_btn = self.transform:GetComponent("Button")
	self.enter_btn.onClick:AddListener(function ()
    	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnEnterClick()
	end)
	coroutine.start(function ()
		Yield(0)
		self:MyRefresh()
	end)
	
end

function C:MyRefresh()
	
	Event.Brocast("global_hint_state_change_msg", {gotoui = ActivityXRHB1Logic.key})
end

function C:OnEnterClick()
	Event.Brocast("open_activity_seven_day", true)
end

function C:OnDestroy()
	self:MyExit()
end

function C:on_global_hint_state_change_msg(parm)
	if parm.gotoui ~= ActivityXRHB1Logic.key then return end
	if not IsEquals(self.gameObject) then return end
	local cur_state = ActivityXRHB1Logic.GetHintState()
	if cur_state == ACTIVITY_HINT_STATUS_ENUM.AT_Nor then
		--self.HongBaoAnimator.enabled = false
		self.HongBaoAnimator:SetBool("hasAward",false)
		self.xrhb1_red.gameObject:SetActive(false)
	elseif cur_state == ACTIVITY_HINT_STATUS_ENUM.AT_Get then
		--self.HongBaoAnimator.enabled = true
		self.HongBaoAnimator:SetBool("hasAward",true)
		self.xrhb1_red.gameObject:SetActive(true)
	end
end

function C:ChangeGame()
	self.cur_scene = MainLogic.GetCurSceneName()
	if not (self.cur_scene == "game_EliminateSH" or self.cur_scene == "game_Eliminate") then
		return
	end
	self.game = self.game or {}
	if not self.game.bgs then
		--第一次才改变具体看自己的需求
		local obj_name,anc1,anc2,size1,size2
		if self.cur_scene == "game_EliminateSH" then
			obj_name = "EliminateSHInfoPanel"
			anc1,anc2,size1,size2 = 2,20,296,550
		elseif self.cur_scene == "game_Eliminate" then
			obj_name = "EliminateInfoPanel"
			anc1,anc2,size1,size2 = 26,16,307,590
		end
		local info_panel = GameObject.Find(obj_name)
		if IsEquals(info_panel) then
			local bgs = info_panel.transform:Find("bgs")
			if IsEquals(bgs) then
				local rt = bgs:GetComponent("RectTransform")
				self.game.bgs = {}
				self.game.bgs.pos = {}
				self.game.bgs.pos.x = rt.anchoredPosition.x
				self.game.bgs.pos.y = rt.anchoredPosition.y
				self.game.bgs.size = {}
				self.game.bgs.size.x = rt.sizeDelta.x
				self.game.bgs.size.y = rt.sizeDelta.y
				rt.anchoredPosition = Vector2.New(anc1,anc2)
				rt.sizeDelta = Vector2.New(size1,size2)
			end
		end
	end
end

function C:ResetGame()
	self.cur_scene = MainLogic.GetCurSceneName()
	if not (self.cur_scene == "game_EliminateSH" or self.cur_scene == "game_Eliminate") then
		return
	end
	if not self.game then return end
	if self.game.bgs then
		local obj_name
		if self.cur_scene == "game_EliminateSH" then
			obj_name = "EliminateSHInfoPanel"
		elseif self.cur_scene == "game_Eliminate" then
			obj_name = "EliminateInfoPanel"
		end
		local info_panel = GameObject.Find(obj_name)
		if IsEquals(info_panel) then
			local bgs = info_panel.transform:Find("bgs")
			if IsEquals(bgs) then
				local rt = bgs:GetComponent("RectTransform")
				if IsEquals(rt) then
					rt.anchoredPosition = Vector2.New(self.game.bgs.pos.x,self.game.bgs.pos.y)
					rt.sizeDelta = Vector2.New(self.game.bgs.size.x,self.game.bgs.size.y)
				end
			end
		end						
	end
	self.game = nil
end
