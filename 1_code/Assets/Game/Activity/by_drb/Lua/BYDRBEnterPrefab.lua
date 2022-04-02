-- 创建时间:2019-09-25
-- Panel:BYDRBEnterPrefab
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

BYDRBEnterPrefab = basefunc.class()
local M = BYDRBEnterPrefab
M.name = "BYDRBEnterPrefab"

function M.Create(parent, cfg)
	return M.New(parent, cfg)
end

function M:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function M:MakeLister()
    self.lister = {}
end

function M:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function M:MyExit()
	self:RemoveListener()
	destroy(self.gameObject)
end

function M:ctor(parent, cfg)
	ExtPanel.ExtMsg(self)

	self.config = cfg

	local obj = newObject("BYDRBEnterPrefab", parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()

	self.transform.localPosition = Vector3.zero

	self:InitUI()
end

function M:OnDestroy(  )
	self:MyExit()
end

function M:InitUI()
	local cur_scene = MainLogic.GetCurSceneName() --根据场景进行不同设置
	self.enter_btn = self.transform:GetComponent("Button")
	self.enter_btn.onClick:AddListener(function ()
		self:OnEnterClick()
	end)
	--self:CheckShowFishRank(cur_scene)
	self:MyRefresh()
end

function M:MyRefresh()
	
end

function M:OnEnterClick()
	ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
	FishingActivityRankPanel.Create()
end

function M:OnDestroy()
	self:MyExit()
end

function M:CheckShowFishRank(s_n)
	--2021.7.6 deprecation
	-- if s_n ~= GameConfigToSceneCfg.game_FishingHall.SceneName and s_n ~= GameConfigToSceneCfg.game_Fishing.SceneName then
	-- 	return
	-- end
	-- local opent = PlayerPrefs.GetInt("fish_rank" .. MainModel.UserInfo.user_id, 0)
	-- local is_show_hit = false
	-- if opent == 0 then
	-- 	is_show_hit = true
	-- else
	-- 	local newtime = tonumber(os.date("%Y%m%d", os.time()))
	-- 	local oldtime = tonumber(os.date("%Y%m%d", opent))
	-- 	if oldtime ~= newtime then
	-- 		is_show_hit = true
	-- 	end
	-- end
	-- if not is_show_hit then return end
	-- Network.SendRequest("query_buyu_rank_base_info", nil,"请求数据",function (data)
	-- 	if data.result == 0 then
	-- 		if data.rank < 100 then
	-- 			FishingActivityRankPanel.Create()
	-- 		end
	-- 	end
	-- end)
end