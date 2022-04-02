-- 创建时间:2020-09-02
-- Panel:LWZBGunPrefab
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

LWZBGunPrefab = basefunc.class()
local C = LWZBGunPrefab
C.name = "LWZBGunPrefab"

function C.Create(parent,index)
	return C.New(parent,index)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
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

function C:MyClose()
	self:MyExit()
end

function C:ctor(parent,index)
	local obj = newObject("LWZBGunPrefab"..index, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	self.transform.localPosition = Vector3.zero
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	self.gun = self.transform:Find("Gun").transform

	self.gun_open = self.transform:Find("Gun/GunOpen").transform
	
    self.shootAnim = self.gun:GetComponent("Animator")
    self.shootAnim:Play("gun_zz", -1, 0)

	self:MyRefresh()
end

function C:MyRefresh()
end

function C:Shoot(data)
	local endPos = data.pos

    local p = endPos - self.gun.transform.position
    local len = LWZBModel.Vec2DLength(p)
    p = p.normalized
    local r = LWZBModel.Vec2DAngle(p)
    self.gun.rotation = Quaternion.Euler(0, 0, r - 90)

	local beginPos = self.gun_open.transform.position

	if data.xz_type == "jz" then
		Event.Brocast("lwzb_play_FX_msg",data.index)
		ExtendSoundManager.PlaySound(audio_config.lwzb.bgm_lwzb_jiguang.audio_name)
		LWZBAnimManager.PlayLinesFX(self.gun, 0.4, data.index, function ()
			print("精准下注.............")
		end)
	else
		self.shootAnim:Play("gun_kp", -1, 0)
		ExtendSoundManager.PlaySound(audio_config.lwzb.bgm_lwzb_kaipao.audio_name)
		LWZBAnimManager.PlayBullet(self.transform, beginPos, endPos, 1, function ()
			print("普通下注.............")
			Event.Brocast("lwzb_play_net_msg",data.index)
		end)
	end
end

function C:ContinueBetShoot(data)
	local endPos = data.pos

    local p = endPos - self.gun.transform.position
    local len = LWZBModel.Vec2DLength(p)
    p = p.normalized
    local r = LWZBModel.Vec2DAngle(p)
    self.gun.rotation = Quaternion.Euler(0, 0, r - 90)

	local beginPos = self.gun_open.transform.position

	self.shootAnim:Play("gun_kp", -1, 0)
	LWZBAnimManager.PlayBullet(self.transform, beginPos, endPos, 1, function ()
		print("普通下注.............")
		Event.Brocast("lwzb_play_net_msg",data.index)
	end)
end