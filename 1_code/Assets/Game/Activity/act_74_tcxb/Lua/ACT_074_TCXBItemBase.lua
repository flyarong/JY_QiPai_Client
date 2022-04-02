-- 创建时间:2022-03-09
-- Panel:ACT_074_TCXBItemBase
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

ACT_074_TCXBItemBase = basefunc.class()
local C = ACT_074_TCXBItemBase
C.name = "ACT_074_TCXBItemBase"
local M = ACT_074_TCXBManager
function C.Create(parent,index)
	return C.New(parent,index)
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
    if self.seq then
        self.seq:Kill()
        self.seq = nil
    end
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:OnDestroy()
	self:MyExit()
end

function C:MyClose()
	self:MyExit()
end

function C:ctor(parent,index)
	ExtPanel.ExtMsg(self)
    self.index = index
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
    self.ani = self.transform:GetComponent("Animator")
    self.select_btn.onClick:AddListener(
        function()
            ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
            self:OnSelectClick()
        end
    )
	self:MyRefresh()
end

function C:MyRefresh()
    if M.CheckNew(self.index) then
        Event.Brocast("ACT_074_TCXBItemBase_new_msg",true)
        local index = M.GetAwardIndexByIndex(self.index)
        local config = M.GetConfig().pool[index]
        self.award_img.sprite = GetTexture(config.award_img)
        self.award_txt.text = config.award_desc .. "x" .. StringHelper.ToCash(config.award_num)
        self.ani.enabled = true
        self.seq = DoTweenSequence.Create()
        self.seq:AppendInterval(1)
        self.seq:AppendCallback(function ()
            Event.Brocast("ACT_074_TCXBItemBase_new_msg",false)
            self.back.gameObject:SetActive(false)
            self.font.gameObject:SetActive(true)
            M.ClearNew()
            M.ShowAward()
            M.ShowSWAward()
            if index == 17 then
                Event.Brocast("ACT_074_TCXBItemBase_spring_move_msg",self.transform.position)
            end
            if M.CheckNeedXP() then
                Event.Brocast("ACT_074_TCXB_need_xp_msg")
                Event.Brocast("ACT_074_TCXBItemBase_spring_refresh_msg")
            end
        end)
        self.seq:OnForceKill(function ()
            Event.Brocast("ACT_074_TCXBItemBase_new_msg",false)
            self.back.gameObject:SetActive(false)
            self.font.gameObject:SetActive(true)
            self.back.transform.localRotation = Vector3.zero
            self.font.transform.localRotation = Vector3.zero
            M.ClearNew()
            M.ShowAward()
            M.ShowSWAward()
        end)
    else
        if M.CheckOver(self.index) then
            self.back.gameObject:SetActive(false)
            self.font.gameObject:SetActive(true)
            local index = M.GetAwardIndexByIndex(self.index)
            local config = M.GetConfig().pool[index]
            self.award_img.sprite = GetTexture(config.award_img)
            self.award_txt.text = config.award_desc .. "x" .. StringHelper.ToCash(config.award_num)
        else
            self.back.gameObject:SetActive(true)
            self.font.gameObject:SetActive(false)
        end
    end
end

function C:OnSelectClick()
    if GameItemModel.GetItemCount(M.item_key) >= 200 then
        if true or PlayerPrefs.GetInt(MainModel.UserInfo.user_id .. M.key .. "today_no_tip",0) == tonumber(os.date("%d",os.time())) then
            M.Lottery(2,self.index)
        else
            ACT_074_TCXBTipPanel.Create(1,2,self.index)
        end
    else
        LittleTips.Create("您的" .. GameItemModel.GetItemToKey(M.item_key).name .. "不足!")
    end
end
