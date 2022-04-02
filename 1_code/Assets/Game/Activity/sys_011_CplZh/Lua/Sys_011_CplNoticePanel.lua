-- Panel:Sys_011_CplNoticePanel
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

Sys_011_CplNoticePanel = basefunc.class()
local C = Sys_011_CplNoticePanel
C.name = "Sys_011_CplNoticePanel"

function C.Create(desc,yes_backcall,no_backcall)
	return C.New(desc,yes_backcall,no_backcall)
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
	if Sys_011_CplZhManager.WqpCpl2Jy() then
		SYSACTBASEManager.CreateHallAct(nil,nil,{ID = 128})
	elseif Sys_011_CplZhManager.JyCpl2Wqp() then
		SYSACTBASEManager.CreateHallAct(nil,nil,{ID = 127})
	end
	self:RemoveListener()
	destroy(self.gameObject)
	PlayerPrefs.SetInt("cpl_not_show_notice_one_day".. MainModel.UserInfo.user_id,1)
end

function C:ctor(desc,yes_backcall,no_backcall)
	local parent = GameObject.Find("Canvas/LayerLv5").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	self.yes_backcall = yes_backcall
	self.no_backcall = no_backcall
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	self.hint_info_txt.text = desc
end

function C:InitUI()
	self.close_btn.onClick:AddListener(
		function()
			self:MyExit()
		end
	)
	self.yes_btn.onClick:AddListener(function()
		if self.yes_backcall then
			self.yes_backcall()
		end
		self:MyExit()
	end)
	self.no_btn.onClick:AddListener(function()
		if self.no_backcall then
			self.no_backcall()
		end
		self:MyExit()
	end)
	self:MyRefresh()
end

function C:MyRefresh()

end

function C:SetButtonText(left,right)
	if left then
		self.no_txt.text = left 
	end
	if right then
		self.yes_txt.text = right
	end
end

function C:SetTitleImage(title_img_str)
	self.title_img.sprite = GetTexture(title_img_str)
	self.title_img:SetNativeSize()
end
