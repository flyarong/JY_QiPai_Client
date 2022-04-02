-- 创建时间:2020-05-11
-- Panel:Sys_013_FFYDGameHallPrefab
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

Sys_013_FFYDGameHallPrefab = basefunc.class()
local C = Sys_013_FFYDGameHallPrefab
C.name = "Sys_013_FFYDGameHallPrefab"
local M = Sys_013_FFYDManager
local start_pos = -165.3
local end_pos = 169

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
    self.lister["ExitScene"] = basefunc.handler(self, self.OnExitScene)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	if self.main_timer then
		self.main_timer:Stop()
	end
	self:RemoveListener()
	destroy(self.gameObject)
end

local life_time = 8
function C:ctor(parent)
	local parent = parent or GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	self.transform.localPosition = Vector3.New(144,76,0)
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	self.main_timer = Timer.New(function ()
		self:CreateItem()
	end,(5/18) * life_time,-1)
	self.main_timer:Start()
end

function C:InitUI()
	self:MyRefresh()
end

function C:MyRefresh()
end

function C:CreateItem()
	if M.GetWaitData() then
		local b = GameObject.Instantiate(self.item,self.Mask)
		local txt = b.transform:Find("@info_txt"):GetComponent("Text")
		txt.text = M.GetWaitData().content
		b.gameObject:SetActive(true)
		self:Anim(b)
		M.RemoveWaitData()
	end
end

function C:Anim(obj)
	obj.transform.localPosition = Vector3.New(obj.transform.localPosition.x,start_pos,obj.transform.localPosition.z)
	local img = obj.transform:Find("Image"):GetComponent("Image")
	local txt = obj.transform:Find("@info_txt"):GetComponent("Text")
	local cha = end_pos - start_pos
	local t
	t = Timer.New(function ()
		local speed = cha * 0.02 / life_time
		if IsEquals(obj) then
			obj.transform.localPosition = Vector3.New(obj.transform.localPosition.x,obj.transform.localPosition.y + speed,obj.transform.localPosition.z)
			-- img.color = Color.New(img.color.r,img.color.g,img.color.b,img.color.a - 0.002 * speed)
			-- txt.color = Color.New(txt.color.r,txt.color.g,txt.color.b,txt.color.a - 0.002 * speed)
			if obj.transform.localPosition.y > end_pos then
				destroy(obj.gameObject)
			end
		else
			t:Stop()
			t = nil
		end
	end,0.02,-1)
	t:Start()
end

function C:OnExitScene()
	self:MyExit()
end