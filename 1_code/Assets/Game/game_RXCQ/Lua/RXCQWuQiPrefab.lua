-- 创建时间:2021-02-23
-- Panel:RXCQWuQiPrefab
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
 -- 取消按钮音效
 -- ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
 -- 确认按钮音效
 -- ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
 --]]

local basefunc = require "Game/Common/basefunc"

RXCQWuQiPrefab = basefunc.class()
local C = RXCQWuQiPrefab
C.name = "RXCQWuQiPrefab"

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
	if self.delay_time then
		self.delay_time:Stop()
	end
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:OnDestroy()
	self:MyExit()
end

function C:MyClose()
	self:MyExit()
end

function C:ctor(parent)
	ExtPanel.ExtMsg(self)
	local parent = parent or GameObject.Find("Canvas/GUIRoot").transform
	local obj = GameObject.Instantiate(RXCQPrefabManager.GetPrefab("RXCQWuQi1"),parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	self.Animator = self.transform:GetComponent("Animator")
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	self:MyRefresh()
end

function C:MyRefresh()
end

function C:Run(use_time)
	self.Tx_Node.gameObject:SetActive(false)
	self.Animator:Play("rxcq_wuqi_1_run")
	if use_time then
		self.Animator.speed = 35/60/use_time
	else
		self.Animator.speed = 1
	end
end

function C:Hit(use_time,skill_name)
	self.Tx_Node.gameObject:SetActive(true)
	self.Animator:Play("rxcq_wuqi_1_hit")
	if use_time then
		self.Animator.speed = 35/60/use_time
	else
		self.Animator.speed = 1
	end
	local key_tx = {
        BanYueWanDao = "tx_banyuewandao",
        CiShaJianShu = "tx_cishajianshu",
        GongShaJianShu = "tx_gongshajianshu",
        LieHuoJianFa = "tx_liehuodaofa",
    }
	local key_sound = {
		BanYueWanDao = "rxcq_bycasting",
		CiShaJianShu = "rxcq_cscasting",
		GongShaJianShu = "rxcq_gscasting",
		LieHuoJianFa = "rxcq_lhcasting",		
	}
	for k,v in pairs(key_tx) do
		self[v].gameObject:SetActive(false)
	end
	if skill_name then
		self[key_tx[skill_name]].gameObject:SetActive(true)
	end
	if skill_name then
		ExtendSoundManager.PlaySound(audio_config.rxcq[key_sound[skill_name]].audio_name)
	end
	self.delay_time = Timer.New(
		function()
			for k,v in pairs(key_tx) do
				self[v].gameObject:SetActive(false)
			end
		end
	,use_time + 0.2,1,nil,true)
	self.delay_time:Start()
	RXCQModel.AddTimers(self.delay_time)
end

function C:Stand(use_time)
	self.Tx_Node.gameObject:SetActive(false)
	self.Animator:Play("rxcq_wuqi_1_stand")
	if use_time then
		self.Animator.speed = 1/use_time
	else
		self.Animator.speed = 1
	end
end