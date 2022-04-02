-- 创建时间:2020-08-14
-- Panel:Act_065_BeginLookBackPanel
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
 -- 取消按钮音效
 -- ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
 -- 确认按钮音效
 -- ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
 --]]

local basefunc = require "Game/Common/basefunc"

Act_065_BeginLookBackPanel = basefunc.class()
local C = Act_065_BeginLookBackPanel
C.name = "Act_065_BeginLookBackPanel"
local M = Act_065_ZNFKManager

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
	local parent = GameObject.Find("Canvas/LayerLv5").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	self.name_txt.text = MainModel.UserInfo.name.."："
	self:MakeLister()
	self:AddMsgListener()
	self.str = gameMgr:getMarketPlatform() == "wqp" and "玩棋牌斗地主" or "彩云麻将"
	self:InitUI()
end

function C:InitUI()
	self.t1_txt.text = "<color=#CB0A0A>" .. self.str .. "</color>".."3周岁啦!"
	self.t2_txt.text = "《<color=#CB0A0A>"..self.str.."</color>》运营团队"
	self.t3_txt.text = "天里，<color=#CB0A0A>" .. self.str .. "</color>有你，真好"
	self.go_btn.onClick:AddListener(
		function()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
			self.node1.gameObject:SetActive(false)
			self.node2.gameObject:SetActive(true)
		end
	)
	self.go2_btn.onClick:AddListener(
		function()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
			self:MyExit()
			Act_065_ZNFKLookBackPanel.Create()
		end
	)
	local data = M.GetData()
	self.day_txt.text = math.floor(((os.time() - data.first_login_time) / 86400))
	self:MyRefresh()
end

function C:MyRefresh()
end
