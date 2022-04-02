-- 创建时间:2019-12-10
-- Panel:LHDPlayerInfoPrefab
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

LHDPlayerInfoPrefab = basefunc.class()
local C = LHDPlayerInfoPrefab
C.name = "LHDPlayerInfoPrefab"

function C.Create(pinfo, uipos)
	return C.New(pinfo, uipos)
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

function C:adjust_uipos(uipos, w, h)
	uipos = self.transform.worldToLocalMatrix:MultiplyPoint(uipos)

	local width = Screen.width
	local height = Screen.height
	if width / height < 1 then
		width,height = height,width
	end
	local wp = width * 0.5
	local hp = height * 0.5
	if uipos.x > 0 then
		if uipos.y > 0 then
			-- 一象限
			if (uipos.y+h) > hp then
				uipos.y = uipos.y - h
			end
			if (uipos.x+w) > wp then
				uipos.x = uipos.x - w
			end
		else
			-- 四象限
			if (uipos.x+w) > wp then
				uipos.x = uipos.x - w
			end
		end
	else
		if uipos.y > 0 then
			-- 二象限
			if (uipos.y+h) > hp then
				uipos.y = uipos.y - h
			end
		else
			-- 三象限
		end
	end
	return uipos
end

function C:ctor(pinfo, uipos)
	self.pinfo = pinfo
	self.uipos = uipos
	local parent = GameObject.Find("Canvas/LayerLv4").transform
	local obj = newObject("player_info_prefab", parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)

	local camera = GameObject.Find("Canvas/Camera"):GetComponent("Camera")
	local p = camera:ScreenToWorldPoint(self.uipos)
	self.player_node.localPosition = self:adjust_uipos(p, 400, 160)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
    EventTriggerListener.Get(self.top_mybutton.gameObject).onClick = basefunc.handler(self, self.ExitUI)
	self:MyRefresh()
end

function C:MyRefresh()
	if self.pinfo then
		self.nane_txt.text = self.pinfo.name
		URLImageManager.UpdateHeadImage(self.pinfo.head_link, self.head_img)
	end
end

function C:ExitUI()
	self:MyExit()
end