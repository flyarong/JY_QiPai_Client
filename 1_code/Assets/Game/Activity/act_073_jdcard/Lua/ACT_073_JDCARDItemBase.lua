-- 创建时间:2022-03-02
-- Panel:ACT_073_JDCARDItemBase
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

ACT_073_JDCARDItemBase = basefunc.class()
local C = ACT_073_JDCARDItemBase
C.name = "ACT_073_JDCARDItemBase"
local M = ACT_073_JDCARDManager
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
    self.unlock_btn.onClick:AddListener(
        function()
            ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
            self:OnUnlockClick()
        end
    )
    self.goto_btn.onClick:AddListener(
        function()
            ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
            self:OnGotoClick()
        end
    )
    self.get_btn.onClick:AddListener(
        function()
            ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
            self:OnGetClick()
        end
    )
	self:MyRefresh()
end

function C:MyRefresh()
    self.award_img.sprite = GetTexture(self.config.award_img)
    self.tag_img.sprite = GetTexture("xsjdk_icon_bq1")
    self.tag_txt.text = "vip" .. self.config.exchange_vip
    self.award_txt.text = self.config.award_txt
    if self:SpecialUnlockid() then
        self.task_txt.text = ""
        self.pro_txt.text = ""
    else
        local data = GameTaskModel.GetTaskDataByID(self.config.task_id)
        self.pro_txt.text = data.now_process .. "/" .. data.need_process
        self.task_txt.text = self.config.task_txt
    end
    if M.CheckCurUnlock(self.config.id) then
        self.t2_txt.text = "已解锁"
    else
        if self:SpecialUnlockid() then
            self.t2_txt.text = ""
        else
            self.t2_txt.text = "剩余" .. M.GetJDCardAllLockRemainNum(self.config.id) .. "份"
        end
    end 
    self.t1_txt.text = self.config.limit_txt
    self.cost_txt.text = "消耗" .. self.config.cost .. "福卡"
    self:RefreshBtn()
end

function C:RefreshBtn()
    local data = GameTaskModel.GetTaskDataByID(self.config.task_id)
    if M.CheckCurUnlock(self.config.id) then
        if data.award_status == 1 then
            self.get_btn.gameObject:SetActive(true)
            self.finish.gameObject:SetActive(false)
            self.goto_btn.gameObject:SetActive(false)
            self.unlock_btn.gameObject:SetActive(false)
            self.t2_txt.text = "已解锁"
            self.cost_txt.gameObject:SetActive(false)
        elseif data.award_status == 2 then
            if (not self:SpecialUnlockid() and M.GetJDCardAllLockRemainNum(self.config.id) > 0 and M.GetJDCardSingleLockNum(self.config.id) < tonumber(string.sub(self.config.limit_txt,7,7))) or (self:SpecialUnlockid() and M.GetJDCardSingleLockNum(self.config.id) == 0) then
                self.get_btn.gameObject:SetActive(false)
                self.finish.gameObject:SetActive(false)
                self.goto_btn.gameObject:SetActive(false)
                self.unlock_btn.gameObject:SetActive(true)
                self.cost_txt.gameObject:SetActive(true)
            else
                self.get_btn.gameObject:SetActive(false)
                self.finish.gameObject:SetActive(true)
                self.goto_btn.gameObject:SetActive(false)
                self.unlock_btn.gameObject:SetActive(false)
                self.t2_txt.text = "已解锁"
                self.cost_txt.gameObject:SetActive(false)
            end
        else
            self.get_btn.gameObject:SetActive(false)
            self.finish.gameObject:SetActive(false)
            self.goto_btn.gameObject:SetActive(true)
            self.unlock_btn.gameObject:SetActive(false)
            self.t2_txt.text = "已解锁"
            self.cost_txt.gameObject:SetActive(false)
        end
        if self:SpecialUnlockid() then
        else
            if M.GetJDCardAllLockRemainNum(self.config.id) == 0 and data.award_status == 2 then
                self.finish_txt.text = "明日可领"
            end
        end
    else
        self.cost_txt.gameObject:SetActive(true)
        self.unlock_btn.gameObject:SetActive(true)
        self.goto_btn.gameObject:SetActive(false)
        self.finish.gameObject:SetActive(false)
        self.get_btn.gameObject:SetActive(false)
    end
end

function C:OnUnlockClick()
    local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key = self.config.condi_exchange, is_on_hint = true}, "CheckCondition")
    if a and b then
        if tonumber(StringHelper.ToRedNum(MainModel.GetHBValue())) >= self.config.cost then
            if self:SpecialUnlockid() then
                if M.GetJDCardSingleLockNum(self.config.id) == 0 then
                    M.UnLock(self.config.id)
                else
                    LittleTips.Create("此任务已完成,终身1次")
                end
            else
                if M.GetJDCardAllLockRemainNum(self.config.id) > 0 then
                    M.UnLock(self.config.id)
                else
                    LittleTips.Create("任务已被抢光，明日9点刷新")
                end
            end
        else
            LittleTips.Create("福卡不足")
        end
    else
        LittleTips.Create("VIP等级不足")
    end
end

function C:OnGotoClick()
    GameManager.GotoUI({gotoui = "game_MiniGame"})
end

function C:OnGetClick()
    if M.CheckTime(self.config.id) then
        Network.SendRequest("get_task_award",{id = self.config.task_id},"")
    else
        LittleTips.Create("京东卡暂时没货了")
    end
end

function C:SpecialUnlockid()
    return M.SpecialUnlockid(self.config.id)
end