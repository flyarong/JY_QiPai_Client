-- 创建时间:2020-02-19
-- Panel:Fishing3DAct6in1BoxPrefab
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

Fishing3DAct6in1BoxPrefab = basefunc.class()
local C = Fishing3DAct6in1BoxPrefab
C.name = "Fishing3DAct6in1BoxPrefab"
local M = BY3DAct6in1Manager

C.State = {
	Normal = 0, -- 正常（未打开）
	Award = 1, -- 获奖
	Lose = 2, -- 章鱼
}
function C.Create(panelSelf, parent, index)
	return C.New(panelSelf, parent, index)
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
	self:RemoveListener()

	if self.boxAniTimer then
        self.boxAniTimer:Stop()
        self.boxAniTimer=nil
	end

	destroy(self.gameObject)
end

function C:ctor(panelSelf, parent, index)
	self.panelSelf = panelSelf
	self.index = index
	local obj = newObject("fish3d_act6in1_box_prefab", parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	tran.localPosition = Vector3.zero
	
	self.boxAniTimer = nil
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	self:showState(C.State.Normal)
	self:setEnable(false)

	self.dj_btn.onClick:AddListener(function()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnBoxClick()
    end)
	
end

function C:OnBoxClick()
	self.panelSelf:OnBoxClick(self.index)
end

function C:showState(state, rate)
	if state == C.State.Normal then
		self.box_close_node.gameObject:SetActive(true)
		self.box_open_node.gameObject:SetActive(false)
		self.zhenzhu_node.gameObject:SetActive(false)
		self.zhangyu_node.gameObject:SetActive(false)
	elseif state == C.State.Award then
		self.box_close_node.gameObject:SetActive(false)
		self.box_open_node.gameObject:SetActive(true)
		self.zhenzhu_node.gameObject:SetActive(true)
		self.zhangyu_node.gameObject:SetActive(false)
		self.rate_txt.text = rate .. " 倍" 
	elseif state == C.State.Lose then
		self.box_close_node.gameObject:SetActive(false)
		self.box_open_node.gameObject:SetActive(true)
		self.zhenzhu_node.gameObject:SetActive(false)
		self.zhangyu_node.gameObject:SetActive(true)
	else
	end
end

function C:setEnable(enable)
	self.dj_btn.gameObject:SetActive(enable)
end

function C:playAnimation(callback)
	if IsEquals(self.gameObject) then
		local ani = self.gameObject.transform:GetComponent("Animator")
		if IsEquals(ani) then
			print("box playAnimation!")
			ani:Play("fish3d_act6in1_box_prefab", -1,0)
		end
	end

	if self.boxAniTimer then
        self.boxAniTimer:Stop()
        self.boxAniTimer=nil
	end
	self.boxAniTimer = Timer.New(function ()

		if callback then
			callback()
		end
	end,0.3,1,true)
	self.boxAniTimer:Start()
end

function C:GetXingPos()
	return self.zhenzhu_node.position
end