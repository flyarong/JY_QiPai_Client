-- 创建时间:2020-11-02
-- Panel:Act_051_YBWLLeftPage
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

Act_051_YBWLLeftPage = basefunc.class()
local C = Act_051_YBWLLeftPage
C.name = "Act_051_YBWLLeftPage"
local M = Act_051_YBWLManager
function C.Create(panelSelf,parent,index,config)
	return C.New(panelSelf,parent,index,config)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["ExitScene"]=basefunc.handler(self,self.MyExit)
    self.lister["ybwl_task_has_change_msg"] = basefunc.handler(self,self.on_ybwl_task_has_change_msg)
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

function C:ctor(panelSelf,parent,index,config)
	self.panelSelf = panelSelf
	self.index = index
	self.config = config
	local parent = parent or GameObject.Find("Canvas/GUIRoot").transform
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
	self.page_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self.panelSelf:Selet(self.index)
	end)
	self.btn_txt.text = self.config.page_name
	self.img_txt.text = self.config.page_name
	self:MyRefresh()
end

function C:MyRefresh()
	if M.CheckGiftWasBought(self.config.gift_id) then--买了
		local task_data = GameTaskModel.GetTaskDataByID(self.config.task_id)
		if task_data then
			if task_data.award_status == 1 then
				self.hd.gameObject:SetActive(true)
				return
			end
		end
	else
	end
	self.hd.gameObject:SetActive(false)
end

function C:RefreshSelet(index)
	self.page_img.gameObject:SetActive(index == self.index)
	self.page_btn.gameObject:SetActive(index ~= self.index)
end

function C:on_ybwl_task_has_change_msg()
	self:MyRefresh()
end