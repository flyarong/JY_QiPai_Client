-- 创建时间:2022-03-09
-- Panel:ACT_074_TCXBPhaseItemBase
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

ACT_074_TCXBPhaseItemBase = basefunc.class()
local C = ACT_074_TCXBPhaseItemBase
C.name = "ACT_074_TCXBPhaseItemBase"
local M = ACT_074_TCXBManager

function C.Create(parent,config,index,parentTran)
	return C.New(parent,config,index,parentTran)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["ExitScene"] = basefunc.handler(self,self.MyExit)
    self.lister["ACT_074_TCXBItemBase_spring_move_msg"] = basefunc.handler(self,self.on_ACT_074_TCXBItemBase_spring_move_msg)
    self.lister["ACT_074_TCXBItemBase_spring_refresh_msg"] = basefunc.handler(self,self.on_ACT_074_TCXBItemBase_spring_refresh_msg)
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

function C:ctor(parent,config,index,parentTran)
	ExtPanel.ExtMsg(self)
    self.config = config
    self.index = index
    self.parentTran = parentTran
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
	self:MyRefresh()
end

function C:MyRefresh()
    self.need_txt.text = self.config.need_num
    self.num_txt.text = StringHelper.ToCash(self.config.award_num)
    if self.config.need_num ~= M.GetCurSpringNum() then
        self.HD_TC_bkgx.gameObject:SetActive(false)
    else
        self.HD_TC_bkgx.gameObject:SetActive(true)
    end
end

function C:on_ACT_074_TCXBItemBase_spring_move_msg(beginPos)
    if self.config.need_num ~= M.GetCurSpringNum() then
        self.HD_TC_bkgx.gameObject:SetActive(false)
    else
        GameComAnimTool.PlayMoveAndHideFX(self.parentTran,"ACT_074_TCXBSpring",beginPos,self.transform.position,nil,1,function ()
            if IsEquals(self.HD_TC_bkgx) then
                self.HD_TC_bkgx.gameObject:SetActive(true)
            end
        end)
    end
end

function C:on_ACT_074_TCXBItemBase_spring_refresh_msg()
    if self.config.need_num ~= M.GetCurSpringNum() then
        self.HD_TC_bkgx.gameObject:SetActive(false)
    else
        self.HD_TC_bkgx.gameObject:SetActive(true)
    end
end