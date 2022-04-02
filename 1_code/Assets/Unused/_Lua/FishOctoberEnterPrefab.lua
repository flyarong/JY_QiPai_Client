-- 创建时间:2019-10-09
-- Panel:FishOctoberEnterPrefab
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

FishOctoberEnterPrefab = basefunc.class()
local C = FishOctoberEnterPrefab
C.name = "FishOctoberEnterPrefab"

function C.Create(parent, cfg)
	return C.New(parent, cfg)
end

function C.CheckIsShow(cfg)
	if not cfg.is_on_off or cfg.is_on_off == 0 then
		return
	end
	if cfg.start_time > os.time() or cfg.end_time < os.time()  or MainModel.UserInfo.ui_config_id ~= 1
 	then
		return
	end
	return true
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
	self.lister = {}
	self.lister["query_activity_exchange_score_response"] = basefunc.handler(self, self.onInfoChange)
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


function C:ctor(parent, cfg)
	self.config = cfg

	local obj = newObject(self.config.prefab, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()

	

	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	self:MyRefresh()
	self.transform:GetComponent("Button").onClick:AddListener(function ()
    	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnEnterClick()
	end)
end

function C:OnEnterClick()
	FishOctoberPanel.Create()
end

function C:MyRefresh()
	Network.SendRequest("query_activity_exchange_score",{ type = "duanwujie_fishgame_zongzi" },"",function (data)
		self:onInfoChange(_,data)
    end)
end

function C:onInfoChange(_,data)
	if IsEquals(self.gameObject) and  data and data.result == 0  then 
		if data.score >= 50 then
			self.LFL.gameObject:SetActive(true)
		else
			self.LFL.gameObject:SetActive(false)
		end      
	end 
end
