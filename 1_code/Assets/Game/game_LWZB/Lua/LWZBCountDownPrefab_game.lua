-- 创建时间:2020-09-04
-- Panel:LWZBCountDownPrefab_game
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

LWZBCountDownPrefab_game = basefunc.class()
local C = LWZBCountDownPrefab_game
C.name = "LWZBCountDownPrefab_game"

function C.Create(parent,time,type)
	return C.New(parent,time,type)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["ExitScene"] = basefunc.handler(self,self.MyExit)
    self.lister["lwzb_force_exit_game_countdown_msg"] = basefunc.handler(self,self.MyExit)
    --self.lister["EnterBackGround"] = basefunc.handler(self,self.on_background_msg)--切到后台
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	self:KillTween()
	self:StopTimer()
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:OnDestroy()
	self:MyExit()
end

function C:MyClose()
	self:MyExit()
end

function C:ctor(parent,time,type)
	self.time = time
	self.type = type
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
	self.node.gameObject:SetActive(false)
	self:Start()
	self:StartCountDownTimer(true)
	self:MyRefresh()
end

function C:MyRefresh()
end

function C:StartCountDownTimer(b)
	self:StopTimer()
	if b then
		self:RefreshTimeTxt()
		self.countdown_timer = Timer.New(function ()
			if self.time > 1 then
				self.time = self.time - 1
				self:RefreshTimeTxt()
			else
				self:End()
			end
		end,1,-1)
		self.countdown_timer:Start()
	end
end

function C:StopTimer()
	if self.countdown_timer then
		self.countdown_timer:Stop()
		self.countdown_timer = nil
	end
end

function C:RefreshTimeTxt()
	if self.time <= 5 then
		ExtendSoundManager.PlaySound(audio_config.lwzb.bgm_lwzb_daojishi.audio_name)
	end
	self.djs_txt.text = self.time
	self:TxtDoTween()
end

function C:Start()
	--[[if self.type == "Normal" then
		GameComAnimTool.PlayShowAndHideAndCall(self.transform, "lwzb_kscn_prefab", Vector3.zero, 2 ,nil,function ()
			self.node.gameObject:SetActive(true)
		end)
	elseif self.type == "ReConnencte" then--]]
		self.node.gameObject:SetActive(true)
	--end
end

function C:End()
	--GameComAnimTool.PlayShowAndHideAndCall(self.transform, "lwzb_tzcn_prefab", Vector3.zero, 2 ,nil,function ()
		self:MyExit()
	--end)
end

--倒计时数字scale由大到小动画
function C:TxtDoTween()
	self:KillTween()
	self.seq = DoTweenSequence.Create()
	self.djs_txt.transform.localScale = Vector3.New(2,2,1)
	self.seq:Append(self.djs_txt.transform:DOScale(Vector3.New(1.4,1.4,1),0.5))
end

function C:KillTween()
	if self.seq then
		self.seq:Kill()
		self.seq = nil
	end
end

function C:on_background_msg()
	self:MyExit()
end