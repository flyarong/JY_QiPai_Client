-- 创建时间:2020-03-09
-- Panel:Act_020HBFXTZListPanel
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

Act_020HBFXTZListPanel = basefunc.class()
local C = Act_020HBFXTZListPanel
C.name = "Act_020HBFXTZListPanel"
local M = Act_020HBFXManager
function C.Create(parent,backcall)
	return C.New(parent,backcall)
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
	if self.backcall then 
		self.backcall()
	end 
	self:RemoveListener()
	destroy(self.gameObject)

	 
end

function C:ctor(parent,backcall)

	ExtPanel.ExtMsg(self)

	local parent = parent or GameObject.Find("Canvas/LayerLv4").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	self.backcall = backcall
	LuaHelper.GeneratingVar(self.transform, self)
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	self.tips2_txt.text = " "
	self.tips4_txt.text = " "
	self.tips7_txt.text = " "
	dump(M.GetmySonData(),"<color=red>5555555555555555555</color>")
	self.tips2_txt.text = #M.GetmySonData().challenge_defeated + #M.GetmySonData().defeated + #M.GetmySonData().succeed
	if M.getMainData() and #M.getMainData().challenging_player_info < 2 then 
		self.tips4_txt.text = "再邀请<color=#FF5A00FF>"..2 - #M.getMainData().challenging_player_info.."人</color>胜利，即可拿"
	else
		self.tips4_txt.text = "每一对玩家完成组队挑战，即可拿"
	end
	if M.getMainData() and #M.getMainData().box_player_info < 5 then 
		self.tips7_txt.text = "再任意邀请<color=#FF5A00FF>"..5 - #M.getMainData().box_player_info.."人</color>胜利，还可抽"
	else
		self.tips7_txt.text = "每邀请5人胜利，还可抽"
	end 
	self.close_btn.onClick:AddListener(
		function ( )
			self:MyExit()
		end
	)
	self.xq_btn.onClick:AddListener(
		function ( )
			ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
			Act_020HBFXHistoryPanel.Create()
		end
	)
	self.yq_btn.onClick:AddListener(
		function ()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
			-- local share_cfg = basefunc.deepcopy(share_link_config.img_yql48)
			-- GameManager.GotoUI({gotoui = "sys_fx",goto_scene_parm = "panel",share_cfg = share_cfg})
			Act_020HBFXManager.Share()
		end
	)
	self:MyRefresh()
end

function C:MyRefresh()

end

