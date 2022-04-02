-- 创建时间:2021-08-13
-- Panel:Act_Ty_RankTips
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

Act_Ty_RankTips = basefunc.class()
local C = Act_Ty_RankTips
C.name = "Act_Ty_RankTips"
local M = Act_Ty_RankManager

function C.Create(parentPos, other_data, score, cfg, name)
	return C.New(parentPos, other_data, score, cfg, name)
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

function C:OnDestroy()
	self:MyExit()
end

function C:MyClose()
	self:MyExit()
end


function C:ctor(parentPos, other_data, score, cfg, name)
	ExtPanel.ExtMsg(self)
	local parent = GameObject.Find("Canvas/LayerLv50").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	self.transform.position = parentPos
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()

	self.user_name_txt.text = name
	self.all_score_txt.text = cfg.item_name .. "总和:" .. score
	self.buff_score_txt.text = "加成" .. cfg.item_name .. ":" .. M.TransformScore(other_data.extra_score, cfg.item_type)
	self.buff_txt.text = "今日加成:" .. other_data.extra_today_percent .. "%"
end

function C:InitUI()
	self.exit_btn.onClick:AddListener(function()
		self:MyExit()
	end)

	
	self:MyRefresh()
end

function C:MyRefresh()
end
