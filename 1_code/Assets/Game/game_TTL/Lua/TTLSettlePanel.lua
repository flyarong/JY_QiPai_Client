-- 创建时间:2020-03-26
-- Panel:TTLSettlePanel
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

TTLSettlePanel = basefunc.class()
local C = TTLSettlePanel
C.name = "TTLSettlePanel"

function C.Create(all_money,all_rate)
	return C.New(all_money,all_rate)
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
		self.timer = nil
	end
	self:RemoveListener()
	
	destroy(self.gameObject)

	 
end

function C:ctor(all_money,all_rate)

	ExtPanel.ExtMsg(self)

	local parent = GameObject.Find("Canvas/LayerLv2").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	

	--dump(all_rate)
	if all_rate>=5 then
		ExtendSoundManager.PlaySound(audio_config.ttl.bgm_ttl_jiesuan2.audio_name)
		self.GoodluckPanel.gameObject:SetActive(true)
		self.award2_txt.text=all_money
	else
		ExtendSoundManager.PlaySound(audio_config.ttl.bgm_ttl_jiesuan1.audio_name)
		self.GetPanel.gameObject:SetActive(true)
		self.award1_txt.text=all_money
	end

	self:AutoDie()

	dump(all_money,"<color=yellow>+++++++++++++++++++总奖励+++++++++++++++++++</color>")

	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	self:MyRefresh()
end

function C:MyRefresh()
end



--自動死亡
function C:AutoDie()
	self.timer = Timer.New(function ()
						Event.Brocast("SettlePanel_on_settle_end_TTL")
		            	self:MyExit()
					end,2,1,false)
	self.timer:Start()
	-- body
end