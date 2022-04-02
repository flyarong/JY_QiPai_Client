-- 创建时间:2020-03-19
-- Panel:XXLXRHBEnterPrefab
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

XXLXRHBEnterPrefab = basefunc.class()
local C = XXLXRHBEnterPrefab
C.name = "XXLXRHBEnterPrefab"

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
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:ctor(parent)
	self.cur_scene = MainLogic.GetCurSceneName()
	local parent = parent or GameObject.Find("Canvas/GUIRoot").transform
	local obj
	if self.cur_scene == "game_Hall" and gameMgr:getMarketPlatform() ~= "wqp" then
		obj = newObject("XXLXRHB_HallEnterPrefab", parent)
		local temp_ui = {}
		LuaHelper.GeneratingVar(obj.transform,temp_ui)
		local ca = CommonCellAnim.Create()
		ca:Go(temp_ui.move_node,temp_ui.hongbao,2,4,-1)
	elseif self.cur_scene == "game_MiniGame" then
		obj = newObject("XXLXRHB_MiniHallEnterPrefab", parent)
	elseif self.cur_scene == "game_Hall" then
		obj = newObject("XXLXRHB_wqp_HallEnterPrefab", parent)
		obj.transform.localPosition = Vector3.New(768,-123,0)
		local temp_ui = {}
		LuaHelper.GeneratingVar(obj.transform,temp_ui)
		local ca = CommonCellAnim.Create()
		ca:Go(temp_ui.move_node,temp_ui.hongbao,2,4)
	end
	if not obj then return end
	self.ui = {}
	self.ui.transform = obj.transform
	self.ui.gameObject = obj
	LuaHelper.GeneratingVar(self.ui.transform,self.ui)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	self:MyRefresh()
end

function C:MyRefresh()
end

function C:OnDestroy()
	self:MyRefresh()
end
