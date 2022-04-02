-- 创建时间:2022-01-11
-- Panel:Act_072_CDMItemBase
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

Act_072_CDMItemBase = basefunc.class()
local C = Act_072_CDMItemBase
C.name = "Act_072_CDMItemBase"
local M = Act_072_CDMManager
function C.Create(parent,config,panelSelf)
	return C.New(parent,config,panelSelf)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["ExitScene"]=basefunc.handler(self,self.MyExit)
    self.lister["model_task_change_msg"] = basefunc.handler(self,self.on_model_task_change_msg)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
    if self.comhuxi then
        CommonHuxiAnim.Stop(self.comhuxi)   
        self.comhuxi = nil
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

function C:ctor(parent,config,panelSelf)
	ExtPanel.ExtMsg(self)
    self.config = config
    self.panelSelf = panelSelf
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
    self.desc1_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        self:OnDescClick(1)
    end)
    self.desc2_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        self:OnDescClick(2)
    end)

    self.bgbg1_img.sprite = GetTexture(self.config.bgbg1_img)
    self.bg2_txt.text = self.config.bg2_txt
    self.bg3_txt.text = self.config.bg3_txt
    self.desc2_txt.text = self.config.desc .. "可猜"
    self.award_img.sprite = GetTexture(self.config.award_img)
    self.award_txt.text = self.config.award_txt
	self:MyRefresh()
end

function C:MyRefresh()
    local data = GameTaskModel.GetTaskDataByID(self.config.task1)
    if data then
        if data.award_status == 2 then
            self.bg1_img.gameObject:SetActive(false)
            self.bg2_img.gameObject:SetActive(false)
            self.bg3_img.gameObject:SetActive(true)
            self.desc1_img.gameObject:SetActive(false)
            self.desc2_btn.gameObject:SetActive(false)
            self.desc2_img.gameObject:SetActive(false)
            self.ylq.gameObject:SetActive(true)
            if self.comhuxi then
                CommonHuxiAnim.Stop(self.comhuxi)   
                self.comhuxi = nil
            end
        else
            local data2 = GameTaskModel.GetTaskDataByID(self.config.task2)
            if data2.award_status == 1 then
                self.bg1_img.gameObject:SetActive(false)
                self.bg2_img.gameObject:SetActive(true)
                self.desc1_btn.gameObject:SetActive(false)
                self.desc1_img.gameObject:SetActive(false)
                self.desc2_btn.gameObject:SetActive(true)
                self.desc2_img.gameObject:SetActive(true)
                self.desc2_txt.text = "猜"
                if self.comhuxi then
                    CommonHuxiAnim.Stop(self.comhuxi)   
                    self.comhuxi = nil
                end
                self.comhuxi = CommonHuxiAnim.Start(self.desc2_img.gameObject,1)
            end
        end
    end
end

function C:OnDescClick(type)
    if type == 1 then
        local data = GameTaskModel.GetTaskDataByID(self.config.task2)
        if data.award_status == 1 then
            self.desc2_txt.text = "猜"
            if self.comhuxi then
                CommonHuxiAnim.Stop(self.comhuxi)   
                self.comhuxi = nil
            end
            self.comhuxi = CommonHuxiAnim.Start(self.desc2_img.gameObject,1)
        end
        self.bg1_img.gameObject:SetActive(false)
        self.bg2_img.gameObject:SetActive(true)
        self.desc1_btn.gameObject:SetActive(false)
        self.desc1_img.gameObject:SetActive(false)
        self.desc2_btn.gameObject:SetActive(true)
        self.desc2_img.gameObject:SetActive(true)
    elseif type == 2 then
        local data = GameTaskModel.GetTaskDataByID(self.config.task2)
        if data then
            if data.award_status == 1 then
                Act_072_CDMInputPanel.Create(self.panelSelf.node.transform,self.config)
            elseif data.award_status == 0 then
                local str = self.config.desc .. "可猜"
                local data2 = GameTaskModel.GetTaskDataByID(self.config.task2)
                if self.config.task2 == 21910 then
                    str = str
                elseif self.config.task2 == 21912 then
                    str = str .. ",当前打鱼" .. data2.now_process
                elseif self.config.task2 == 21914 then
                    str = str .. ",当前赢金" .. data2.now_process
                elseif self.config.task2 == 21916 then
                    str = str .. ",当前充值" .. data2.now_process/100 .. "元"
                elseif self.config.task2 == 21918 then
                    str = str .. ",当前充值" .. data2.now_process/100 .. "元"
                end
                LittleTips.Create(str)
            end
        end
    end
end

function C:on_model_task_change_msg(data)
    if data.id == self.config.task1 or data.id == self.config.task2 then
        self:MyRefresh()
    end
end