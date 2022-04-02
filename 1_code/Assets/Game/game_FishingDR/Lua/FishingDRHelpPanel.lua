-- 创建时间:2019-07-30
-- Panel:New Lua
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

FishingDRHelpPanel = basefunc.class()
local C = FishingDRHelpPanel
C.name = "FishingDRHelpPanel"

function C.Create()
	return C.New()
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

function C:ctor()

	ExtPanel.ExtMsg(self)

	local parent = GameObject.Find("Canvas/LayerLv4").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	self.CloseButton=self.transform:Find("CloseButton"):GetComponent("Button").onClick:AddListener(
		function ()
			self:MyExit()
		end
	)
	local str={"随机出现在水池中，当鱼触碰后，移动速度降低50%，持续1.5秒",
	"随机出现在水池中，当鱼触碰后，击杀可获得高倍奖励",
	"当某条鱼被捕获时，有几率释放出闪电，击杀其他的鱼",
	"当某条鱼被捕获时，有几率出现炮台升级，释放出强烈激光",
	"超级大奖，将购买的鲸币全额返还",
	}


	for i = 1, 5 do
		local b=  self.transform:Find("Scroll View/Viewport/Content/SJSM/LayOut/Child"..i)
		PointerEventListener.Get(b.gameObject).onDown = function ()
			GameTipsPrefab.ShowDesc(str[i], UnityEngine.Input.mousePosition)
		end
		PointerEventListener.Get(b.gameObject).onUp = function ()
			GameTipsPrefab.Hide()
		end
	end



	self:MyRefresh()
end

function C:MyRefresh()
end
