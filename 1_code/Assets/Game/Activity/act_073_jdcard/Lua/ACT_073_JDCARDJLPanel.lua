-- 创建时间:2022-03-02
-- Panel:ACT_073_JDCARDJLPanel
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

ACT_073_JDCARDJLPanel = basefunc.class()
local C = ACT_073_JDCARDJLPanel
C.name = "ACT_073_JDCARDJLPanel"
local M = ACT_073_JDCARDManager
function C.Create(panelSelf)
	return C.New(panelSelf)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["ExitScene"] = basefunc.handler(self,self.MyExit)
    self.lister["get_jdcard_record_msg"] = basefunc.handler(self,self.on_get_jdcard_record_msg)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
    self.panelSelf.is_opne_jl = false
    self:ClearItem()
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:OnDestroy()
	self:MyExit()
end

function C:MyClose()
	self:MyExit()
end

function C:ctor(panelSelf)
	ExtPanel.ExtMsg(self)
    self.panelSelf = panelSelf
	local parent = GameObject.Find("Canvas/LayerLv3").transform
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
    self.panelSelf.is_opne_jl = true
    self.ID_txt.text = "您的ID:" .. MainModel.UserInfo.user_id
    self.close_btn.onClick:AddListener(
        function()
            ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
            self:MyExit()
        end
    )
    M.QueryJDCardHistory()
end

function C:MyRefresh()
    self:CreateItem()
end

function C:CreateItem()
    self:ClearItem()
    local config = basefunc.deepcopy(M.GetConfig())
    local data = basefunc.deepcopy(M.GetHistory())
    if not table_is_null(data) then
        for i=#data,1,-1 do
            local pre = ACT_073_JDCARDJLItemBase.Create(self.Content.transform,data[i],config[data[i].task_index],i)
            self.item_cell[#self.item_cell + 1] = pre
        end
    end
end

function C:ClearItem()
    if self.item_cell then
        for k,v in pairs(self.item_cell) do
            v:MyExit()
        end
    end
    self.item_cell = {}
end

function C:on_get_jdcard_record_msg()
    self:MyRefresh()
end