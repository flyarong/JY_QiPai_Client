-- 创建时间:2020-05-20
-- Panel:Sys_013_FFYDGuidePanel
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

Sys_013_FFYDGuidePanel = basefunc.class()
local C = Sys_013_FFYDGuidePanel
C.name = "Sys_013_FFYDGuidePanel"

local base_data = {
	[1] = {--街机捕鱼
		img = "xyxyd_icon_8",
		text = "这款游戏才是你的最爱！",
		go = "go_by"
	},
	[2] = {--水果消消乐
		img = "xyxyd_icon_9",
		text = "98%的人都在玩！",
		go = "go_xxl"
	},
	[3] = {--苹果大战
		img = "xyxyd_icon_6_activity_sys_013_ffyd",
		text = "3秒收益翻倍，快感翻倍！",
		go = "go_zpg"
	},
	[4] = {--敲敲乐
		img = "xyxyd_icon_5",
		text = "这款游戏很符合您的品味！",
		go = "go_qql"
	},
}

function C.Create(left,right)
	return C.New(left,right)
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
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:ctor(left,right)
	ExtPanel.ExtMsg(self)
	local parent = GameObject.Find("Canvas/LayerLv5").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	self.left = left
	self.right = right
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	self.close_btn.onClick:AddListener(
		function ()
			self:MyExit()
		end
	)
	self.more_btn.onClick:AddListener(
		function ()		
			GameManager.GotoUI({gotoui = "game_MiniGame"})
		end
	)
	self.dating_btn.onClick:AddListener(
		function ()
			self:MyExit()
		end
	)

	self:MyRefresh()
	self.game1_img.sprite = GetTexture(base_data[self.left].img)
	self.game2_img.sprite = GetTexture(base_data[self.right].img)
	self.guide1_txt.text = base_data[self.left].text
	self.guide2_txt.text = base_data[self.right].text
	self.go1_btn.onClick:AddListener(function ()
		self[base_data[self.left].go](self)
	end)
	self.go2_btn.onClick:AddListener(function ()
		self[base_data[self.right].go](self)
	end)
end

function C:MyRefresh()

end

function C:go_by()
	GameManager.GotoUI({gotoui = "game_FishingHall"})
end

function C:go_xxl()
	GameManager.CommonGotoScence({gotoui="game_Eliminate"})
end

function C:go_zpg()
	local CheckZPGPermission = function()
		local _permission_key = "drt_guess_apple_play"
		if _permission_key then
			local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key=_permission_key, is_on_hint = true}, "CheckCondition")
			if a and not b then
				return false
			end
			return true
		else
			return true
		end
	end
	if CheckZPGPermission() then
		GameManager.GotoUI({gotoui = "game_ZPG",goto_scene_parm =true})
	else 
		HintPanel.Create(1,"只有vip1及以上用户可以进入",function()
			Event.Brocast("show_gift_panel")
		end)
	end
end

function C:go_qql()
	GameManager.GotoUI({gotoui = "game_Zjd"})
end

function C:OnExitScene()
	self:MyExit()
end