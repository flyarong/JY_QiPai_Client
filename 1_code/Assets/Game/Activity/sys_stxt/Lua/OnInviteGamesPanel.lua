-- 创建时间:2019-12-07
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

OnInviteGamesPanel = basefunc.class()
local C = OnInviteGamesPanel
C.name = "OnInviteGamesPanel"
local config = SYSSTXTManager.invite_game_config
function C.Create(gametype,data)
	return C.New(gametype,data)
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

function C:ctor(gametype,data)

	ExtPanel.ExtMsg(self)

	local parent = GameObject.Find("Canvas/LayerLv5").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	self.data = data
	dump(data,"---------------------")
	self.gametype = gametype
	self.CC = self:InitConfig()
	LuaHelper.GeneratingVar(self.transform, self)
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	self.message_txt.text = "师父<color=#FF5A00>【"..self.data.player_name.."】</color>邀请你一起玩"..self.CC[gametype].gamename.."，是否接受师父的邀请？"
end

function C:InitUI()
	self.close_btn.onClick:AddListener(
		function ()
			self:MyExit()
		end
	)
	self.confirm_btn.onClick:AddListener(
		function ()
			self:GoToUI(self.CC[self.gametype].gotoui)
		end
	)
	self:MyRefresh()
end

function C:MyRefresh()
end


function C:GoToUI(parm)
	self:MyExit()
	GameManager.GotoUI({gotoui = parm[1],goto_scene_parm = parm[2]})
end


function C:InitConfig()
	local _config = {}
	for i = 1, #config.info do
		if config.info[i].isonoff == 1 then 
			_config[#_config + 1] = config.info[i]
		end 
	end
	_config = MathExtend.SortList(_config,"order", true)
	return _config
end