-- 创建时间:2021-02-22
-- Panel:RXCQHelpPanel
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

RXCQHelpPanel = basefunc.class()
local cur_path = "Game.game_RXCQ.Lua."
local C = RXCQHelpPanel
C.name = "RXCQHelpPanel"
C.config = rxcq_main_config

local btn = {
	"GuaiWu_btn","JiNeng_btn"
}
local mask = {
	"GuaiWuMask","JiNengMask"
}
local panel = {
	"GuaiWu","JiNeng"
}

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

function C:OnDestroy()
	self:MyExit()
end

function C:MyClose()
	self:MyExit()
end

function C:ctor()
	ExtPanel.ExtMsg(self)
	local parent = GameObject.Find("Canvas/LayerLv5").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	self.close_btn.onClick:AddListener(
		function()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
			self:MyExit()
		end
	)
	for i = 1,#btn do
		self[btn[i]].onClick:AddListener(
			function()
				self:ButtonChange(i)
			end
		)
	end
	self:InitGuaiWu()
	self:InitJiNeng()
	self:MyRefresh()
end

function C:ButtonChange(Index)
	for i = 1,#mask do
		self[mask[i]].gameObject:SetActive(i == Index)
		self[panel[i]].gameObject:SetActive(i == Index)
	end
end

function C:InitGuaiWu()
	local temp_ui = {}
	for i = 1,#C.config.guaiwu do
		local b = GameObject.Instantiate(self.GuaiWuItem,self.GuaiWuNode)
		b.gameObject:SetActive(true)
		LuaHelper.GeneratingVar(b.transform,temp_ui)
		temp_ui.guaiwu_img.sprite = GetTexture(C.config.guaiwu[i].image)
		temp_ui.guaiwu_name_txt.text = C.config.guaiwu[i].name
		temp_ui.guaiwu_level_txt.text = C.config.guaiwu[i].level
		temp_ui.guaiwu_txt.text = C.config.guaiwu[i].desc
	end
end

function C:InitJiNeng()
	local temp_ui = {}
	for i = 1,#C.config.jineng do
		local b = GameObject.Instantiate(self.JiNengItem,self.JiNengNode)
		b.gameObject:SetActive(true)
		LuaHelper.GeneratingVar(b.transform,temp_ui)
		temp_ui.jineng_name_txt.text = C.config.jineng[i].name
		temp_ui.jineng_txt.text = C.config.jineng[i].desc
	end
end


function C:MyRefresh()
end
