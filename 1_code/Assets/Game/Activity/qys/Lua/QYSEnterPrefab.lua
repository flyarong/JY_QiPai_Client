-- 创建时间:2019-09-20
-- Panel:QYSEnterPrefab
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

QYSEnterPrefab = basefunc.class()
local C = QYSEnterPrefab
C.name = "QYSEnterPrefab"

function C.CheckIsShow(cfg)
	return true
end
function C.GotoUI(parm)
	return C.Create(parm.parent, parm.cfg)
end

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

function C:ctor(parent, cfg)
	self.config = cfg

	local obj = newObject("match_qys_btn", parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()

	self.transform.localPosition = Vector3.zero

	self:InitUI()
end

function C:InitUI()
	self.enter_btn = self.transform:GetComponent("Button")
	self.enter_btn.onClick:AddListener(function ()
    	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnGiftClick()
	end)
	if self.config.icon then
		self.gift_img.sprite = GetTexture(self.config.icon)
	end

	self:MyRefresh()
end

function C:MyRefresh()
	local gameCfg = MatchModel.GetConfigByType(MatchModel.MatchType.gms)
	local b = false
	local tip = ""
	local now = os.time()
	local d = os.date("%Y/%m/%d", now)
	local strs = {}

	string.gsub(d, "[^-/]+", function(s)
		strs[#strs + 1] = s
	end)

	local st = os.time({year = strs[1], month = strs[2], day = strs[3], hour = "0", min = "0", sec = "0"})
	local et = os.time({year = strs[1], month = strs[2], day = strs[3], hour = "23", min = "59", sec = "59"})
	for _, data in pairs(gameCfg) do
		if data.over_time > st and data.over_time < et and data.over_time > now then
			tip = "今日" .. os.date("%H", data.over_time) .. "点千元赛等您哦!"
			b = true
			break
		end
	end

	self.qys_tips_img.gameObject:SetActive(b)
	self.Particle_jiangbei.gameObject:SetActive(b)
end

function C:OnGiftClick()
	local parm = {hall_type = MatchModel.HallType.djs}
	GameManager.GotoSceneID(GameConfigToSceneCfg.game_MatchHall.ID,parm)
end

function C:OnDestroy()
	self:MyExit()
end
