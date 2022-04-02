-- 创建时间:2022-03-02
-- Panel:ACT_073_JDCARDXQPanel
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

ACT_073_JDCARDXQPanel = basefunc.class()
local C = ACT_073_JDCARDXQPanel
C.name = "ACT_073_JDCARDXQPanel"
local M = ACT_073_JDCARDManager
function C.Create(unlock_id,index)
	return C.New(unlock_id,index)
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

function C:OnDestroy()
	self:MyExit()
end

function C:MyClose()
	self:MyExit()
end

function C:ctor(unlock_id,index)
	ExtPanel.ExtMsg(self)
    if type(unlock_id) == "number" then
        self.unlock_id = unlock_id
    elseif type(unlock_id) == "table" then
        self.unlock_id = unlock_id.unlock_id
        self.data = unlock_id
    end
    self.index = index
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
    self.config = M.GetConfig()[self.unlock_id]
    if not self.data and self.index then
        self.data = M.GetHistory(self.index)
    end
    self.kh_btn.onClick:AddListener(
        function()
            ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
            self:OnKHClick()
        end
    )
    self.mm_btn.onClick:AddListener(
        function()
            ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
            self:OnMMClick()
        end
    )
    self.close_btn.onClick:AddListener(
        function()
            ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
            Event.Brocast("act_073_jdcard_xq_close")
            self:MyExit()
        end
    )
	self:MyRefresh()
end

function C:MyRefresh()
    self.jdk_img.sprite = GetTexture(self.config.award_img)
    self.desc_txt.text = self.config.award_txt
    self.kh_txt.text = "卡号:" .. self.data.card_number
    self.mm_txt.text = "密码:" .. M.Decrycty(self.data.card_pwd)
end

function C:OnKHClick()
    UniClipboard.SetText(self.data.card_number)
    LittleTips.Create("复制成功~")
end

function C:OnMMClick()
    UniClipboard.SetText(M.Decrycty(self.data.card_pwd))
    LittleTips.Create("复制成功~")
end