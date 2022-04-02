-- 创建时间:2022-03-02
-- Panel:ACT_073_JDCARDPanel
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

ACT_073_JDCARDPanel = basefunc.class()
local C = ACT_073_JDCARDPanel
C.name = "ACT_073_JDCARDPanel"
local M = ACT_073_JDCARDManager
local DESCRIBE_TEXT = {
    [1] = "1.解锁任务并完成，可领取对应的京东卡奖励",
    [2] = "2.任务每日9点重置，未完成的任务将退还福卡",
    [3] = "3.请妥善保管卡号和卡密，请勿泄露他人，以免造成账号或资金损失",
    [4] = "4.京东卡号和卡密为一次性内容，一旦领取不退不换",
}
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
    self.lister["ExitScene"] = basefunc.handler(self,self.MyExit)
    self.lister["get_jdcard_taskInfo_msg"] = basefunc.handler(self,self.on_get_jdcard_taskInfo_msg)
    self.lister["unlock_jd_card_task_msg"] = basefunc.handler(self,self.on_unlock_jd_card_task_msg)
    self.lister["model_task_change_msg"] = basefunc.handler(self,self.on_model_task_change_msg)
    self.lister["act_073_jdcard_xq_close"] = basefunc.handler(self,self.on_act_073_jdcard_xq_close)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
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

function C:ctor()
	ExtPanel.ExtMsg(self)
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
    self.back_btn.onClick:AddListener(
        function()
            ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
            self:MyExit()
        end
    )
    self.jl_btn.onClick:AddListener(
        function()
            ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
            self:OnJLClick()
        end
    )
    self.gz_btn.onClick:AddListener(
        function()
            ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
            self:OpenHelpPanel()
        end
    )
    self.is_opne_jl = false
    M.QueryJDCardInfo()
end

function C:MyRefresh()
    self.fuka_txt.text = StringHelper.ToRedNum(MainModel.GetHBValue())
    self:CreateItem()
end

function C:OnJLClick()
    ACT_073_JDCARDJLPanel.Create(self)
end

function C:OpenHelpPanel()
    local str = DESCRIBE_TEXT[1]
    for i = 2, #DESCRIBE_TEXT do
        str = str .. "\n" .. DESCRIBE_TEXT[i]
    end
    self.introduce_txt.text = str
    IllustratePanel.Create({ self.introduce_txt.gameObject }, GameObject.Find("Canvas/LayerLv5").transform)
end

local m_sort = function(v1,v2)
    local stateA = GameTaskModel.GetTaskDataByID(v1.task_id).award_status
    local stateB = GameTaskModel.GetTaskDataByID(v2.task_id).award_status
    if stateB == 2 and stateA ~= 2 then
        return true
    elseif stateA == 2 and stateB ~= 2 then
        return false
    elseif v1.id > v2.id then
        return true
    end
    return false
end
function C:CreateItem()
    self:ClearItem()
    local tab = basefunc.deepcopy(M.GetConfig())
    local config = {}
    for i=1,#tab do
        local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key = tab[i].condi_show, is_on_hint = true}, "CheckCondition")
        if a and b then
            config[#config + 1] = tab[i]
        end
    end
    MathExtend.SortListCom(config, m_sort)
    for i=1,#config do
        if M.SpecialUnlockid(config[i].id) then
            local data = GameTaskModel.GetTaskDataByID(config[i].task_id)
            if M.GetJDCardSingleLockNum(config[i].id) == 0 
            or data.award_status == 0 
            or (data.award_status == 1 and not M.IsAwardGet(config[i].id)) then
                local pre = ACT_073_JDCARDItemBase.Create(self.content.transform,config[i])
                self.item_cell[#self.item_cell + 1] = pre
            end
        else
            local pre = ACT_073_JDCARDItemBase.Create(self.content.transform,config[i])
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

function C:on_get_jdcard_taskInfo_msg()
    self:MyRefresh()
end

function C:on_unlock_jd_card_task_msg()
    LittleTips.Create("解锁成功")
    self:MyRefresh()
end

function C:on_model_task_change_msg(data)
    if M.IsCareTask(data.id) then
        self:MyRefresh()
    end
end

function C:on_act_073_jdcard_xq_close()
    if not self.is_opne_jl then
        self:PlayGetAnim()
    end
end

function C:PlayGetAnim()
	self.tx_lizituowei.gameObject:SetActive(true)
    local tx_start_trans = Vector3.New(41, -21, 0)
    local tx_end_trans = Vector3.New(390, 285, 0)
	self.tx_lizituowei.transform.localPosition = tx_start_trans
	local seq = DoTweenSequence.Create({ dotweenLayerKey = "jdcard_tween" })

    local path = {}
    path[1] = tx_start_trans
    path[2] = tx_end_trans
	if IsEquals(self.tx_lizituowei) then
		seq:Append(self.tx_lizituowei.transform:DOLocalPath(path, 1, DG.Tweening.PathType.CatmullRom))
		seq:OnKill(function()
			if IsEquals(self.tx_lizituowei) then
				self.tx_lizituowei.gameObject:SetActive(false)
			else
				self:MyExit()
			end
		end)
	end
end
