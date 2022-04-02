-- 创建时间:2019-07-24
-- Panel:FishingMatchAwardPanel
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
require "Game.normal_fishing_common.Lua.FishingMatchAwardPrefab"
FishingMatchAwardPanel = basefunc.class()
local C = FishingMatchAwardPanel
C.name = "FishingMatchAwardPanel"

local instance
function C.Create(parm)
	if not instance then
		instance = C.New(parm)
	end
	return instance
end
function C.Close()
	if instance then
		instance:OnBackClick()
	end
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["ExitScene"] = basefunc.handler(self, self.onExitScene)
    if self.parm.signup_num_response then
	    self.lister[self.parm.signup_num_response] = basefunc.handler(self, self.on_fsmg_req_player_num)
	end
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	self:RemoveListener()
	instance = nil 
end

function C:ctor(parm)

	ExtPanel.ExtMsg(self)

	self.parm = parm
	local parent = GameObject.Find("Canvas/LayerLv5").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()

    self.hint_no_money.gameObject:SetActive(false)

    self.time_call_map = {}
    self.update_time = Timer.New(function ()
    	self:Update()
    end, 1, -1, nil, true)
    self.time_call_map["caidai"] = {time_call = self:GetCall(5), run_call = basefunc.handler(self, self.RunChaidai)}

	self:InitUI()
end

function C:InitUI()
    self.chaidai_par = self.chaidai:GetComponent("ParticleSystem")
	self:UpdateQueryAward(self.parm.num)
	self.back_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        self:OnBackClick()
    end)
	self:MyRefresh()
end
function C:GetCall(t)
	local tt = t
	local cur = 0
	return function (st)
		cur = cur + st
		if cur >= tt then
			cur = cur - tt
			return true
		end
		return false
	end
end
function C:Update()
	for k,v in pairs(self.time_call_map) do
		if v.time_call(1) then
			v.run_call()
		end
	end
end
function C:RunChaidai()
	self.chaidai_par:Play(true)
	self.time_call_map["caidai"].time_call = self:GetCall(math.random(10, 30))
end
function C:UpdateQueryAward(num)
	num = num or 0
	self.award_pool_txt.text = 10 * num .. "福卡"
end


function C:MyRefresh()
	self:ClearCellList()

    self.award = FishingManager.GetGameIDToAward(self.parm.game_id)
    if not self.award then
    	return
	end
	for k,v in ipairs(self.award) do
		local pre = FishingMatchAwardPrefab.Create(self.content, v, nil, self)
		self.CellList[#self.CellList + 1] = pre
	end
end
function C:ClearCellList()
	if self.CellList then
		for k,v in ipairs(self.CellList) do
			v:OnDestroy()
		end
	end
	self.CellList = {}
end

function C:onExitScene()
	self:MyExit()
end

function C:OnBackClick()
	self:MyExit()
	destroy(self.gameObject)
end
function C:on_fsmg_req_player_num(_, data)
	if data.result == 0 then
		self:UpdateQueryAward(data.signup_num)
	end
end
