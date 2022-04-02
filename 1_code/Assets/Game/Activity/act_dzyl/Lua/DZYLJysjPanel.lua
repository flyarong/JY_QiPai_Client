-- 创建时间:2019-12-26
-- Panel:DZYLJysjPanel
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

DZYLJysjPanel = basefunc.class()
local C = DZYLJysjPanel
C.name = "DZYLJysjPanel"
local M = DZYLManager

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
    self.lister["click_like_activity_collect_advise_response"] = basefunc.handler(self, self.on_advise_response)
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
	
	self.jy_ipf = self.jy.transform:GetComponent("InputField")
	self.jy_ipf.characterLimit = 50
	self.jy_ipf.onValueChanged:AddListener(function (val)
		
	end)

	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	self.tj_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
        self:OnTJClick()
	end)
	self.back_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
        self:MyExit()
	end)
	
	self:MyRefresh()
end

function C:MyRefresh()
	local jy = M.GetOldJY() or ""
	self.jy_txt.text = jy
	self.jy_ipf.text = jy
end

function C:OnTJClick()
	if self.jy_ipf.text and self.jy_ipf.text ~= "" then
		print(self.jy_ipf.text)
		Network.SendRequest("click_like_activity_collect_advise", {advise=self.jy_ipf.text}, "提交建议")
	else
		LittleTips.Create("建议不能为空")
	end
end

function C:on_advise_response(_, data)
	if data.result == 0 then
		M.SetOldJY(self.jy_ipf.text)
		self:MyExit()
		LittleTips.Create("提交成功")
	else
		HintPanel.ErrorMsg(data.result)
	end
end
