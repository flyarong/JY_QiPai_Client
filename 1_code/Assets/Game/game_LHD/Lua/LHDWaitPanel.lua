-- 创建时间:2019-12-18
-- Panel:LHDWaitPanel
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

LHDWaitPanel = basefunc.class()
local C = LHDWaitPanel
C.name = "LHDWaitPanel"

function C.Create(parm)
	return C.New(parm)
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
	self:StopTime()
	self:RemoveListener()
	destroy(self.gameObject)

	 
end

function C:ctor(parm)

	ExtPanel.ExtMsg(self)

	self.parm = parm or {}
	local parent = GameObject.Find("Canvas/LayerLv1").transform
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
	self.back_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        self:OnBackClick()
    end)
    local fkpzz = GameObject.Instantiate(GetPrefab("@LHD_fkpzz"), self.center).gameObject
    fkpzz.transform.localPosition = Vector3.New(0, 40, 0)
	self:MyRefresh()
end

function C:MyRefresh()
	self:StopTime()
	if self.parm.countdown > 0 then
		self.no.gameObject:SetActive(true)
		self.back_btn.gameObject:SetActive(false)
		self.cd_time = Timer.New(basefunc.handler(self, self.UpdateTime), 1, -1, true)
		self.cd_time:Start()
		self:UpdateTime(true)
	else
		self.no.gameObject:SetActive(false)
		self.back_btn.gameObject:SetActive(true)
	end
end

function C:UpdateTime(b)
	if not b then
		self.parm.countdown = self.parm.countdown - 1
	end
	self.cd_txt.text = self.parm.countdown .. "秒后可返回"
	if self.parm.countdown <= 0 then
		self:MyRefresh()
	end
end
function C:StopTime()
	if self.cd_time then
		self.cd_time:Stop()
		self.cd_time = nil
	end
end

function C:OnBackClick()
    Network.SendRequest("fg_quit_game", nil, "请求退出")
end
