-- 创建时间:2022-03-09
-- Panel:ACT_074_TCXBPreviewItemBase
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

ACT_074_TCXBPreviewItemBase = basefunc.class()
local C = ACT_074_TCXBPreviewItemBase
C.name = "ACT_074_TCXBPreviewItemBase"
local M = ACT_074_TCXBManager
function C.Create(parent,config)
	return C.New(parent,config)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["ExitScene"] = basefunc.handler(self,self.MyExit)
    self.lister["ACT_074_TCXBPreviewItemBase_tip_msg"] = basefunc.handler(self,self.on_ACT_074_TCXBPreviewItemBase_tip_msg)
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

function C:ctor(parent,config)
	ExtPanel.ExtMsg(self)
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
    self.tip_btn.onClick:AddListener(
        function()
            ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
            self:OnTipClick()
        end
    )
	self:MyRefresh()
end

function C:MyRefresh()
    self.award_img.sprite = GetTexture(self.config.award_img)
    self.award_txt.text = self.config.award_desc .. "x" .. StringHelper.ToCash(self.config.award_num)
    if self.config.tips then
        self.tip_txt.text = self.config.tips
    else
        self.tip_txt.text = GameItemModel.GetItemToKey(self.config.item_key).desc
    end
    local rt = self.tip_bg.transform:GetComponent("RectTransform")
    local len = string.len(self.tip_txt.text) * 7
    if len < 120 then
        len = 120
    end
    rt.sizeDelta = Vector2.New(len,rt.rect.height)
    if self.config.index % 5 == 0 or self.config.index % 5 == 4 then
        self.tip_bg.transform.localScale = Vector3.New(-1,1,0)
        self.tip_txt.transform.localScale = Vector3.New(-1,1,0)
    else
        self.tip_bg.transform.localScale = Vector3.New(1,1,0)
        self.tip_txt.transform.localScale = Vector3.New(1,1,0)
    end
end
 
function C:OnTipClick()
    Event.Brocast("ACT_074_TCXBPreviewItemBase_tip_msg",self.config.index)
    self.tip.gameObject:SetActive(not self.tip.gameObject.activeSelf)
end

function C:on_ACT_074_TCXBPreviewItemBase_tip_msg(index)
    if index then
        if self.config.index ~= index then
            self.tip.gameObject:SetActive(false)
        end
    else
        self.tip.gameObject:SetActive(false)
    end
end
