-- 创建时间:2021-08-16
-- Panel:ACT_065_ZNCFKPanel
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

ACT_065_ZNCFKPanel = basefunc.class()
local C = ACT_065_ZNCFKPanel
C.name = "ACT_065_ZNCFKPanel"
local M = ACT_065_ZNCFKManager

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
    self.lister["ExitScene"]=basefunc.handler(self,self.MyExit)
    self.lister["act_065_zncfk_task_data_is_change_msg"] = basefunc.handler(self,self.on_act_065_zncfk_task_data_is_change_msg)
    self.lister["query_fake_data_response"] = basefunc.handler(self, self.AddPMD)
    self.lister["get_task_award_response"] = basefunc.handler(self,self.on_get_task_award_response) 
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
    if self.update_pmd then
        self.update_pmd:Stop()
    end
    self:ClosePre()
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
	
    self.ani = self.get_btn.transform:GetComponent("Animator")

	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
    local config = M.GetCfg()
    CommonTimeManager.GetCutDownTimer(config.base_info.end_t,self.time_txt)
    self.pmd_cont = CommonPMDManager.Create({ parent = self.pmd_node, speed = 18, space_time = 10, start_pos = 1000 })
    self:UpdatePMD()
    EventTriggerListener.Get(self.back_btn.gameObject).onClick = basefunc.handler(self, self.OnBackClick)
    EventTriggerListener.Get(self.get_btn.gameObject).onClick = basefunc.handler(self, self.OnGetClick)
	self:MyRefresh()
end

function C:MyRefresh()
    local config = M.GetCfg().base_info
    local data = GameTaskModel.GetTaskDataByID(config.task_id)
    dump(data,"<color=yellow><size=15>+++++左++++</size></color>")
    if data then
        self.jindu_img.fillAmount = data.now_process / data.need_process
        self.remain_txt.text = "可拆" ..  (6 - data.task_round) .. "次"
        if data.award_status == 1 then
            self.get_img.gameObject:SetActive(false)
            self.ani:Play("zncfk_chai_huxi")
        else
            self.get_img.gameObject:SetActive(true)
            self.ani:Play("null")
        end
    end
    self:CreatePre() 
end

function C:OnBackClick()
    self:MyExit() 
end

function C:OnGetClick()
    local config = M.GetCfg().base_info
    local data = GameTaskModel.GetTaskDataByID(config.task_id)
    if data then
        if data.award_status == 1 then
            Network.SendRequest("get_task_award", {id = config.task_id})
        end
    end
end

local m_sort = function(v1,v2)
    local data1 = GameTaskModel.GetTaskDataByID(v1.task_id)
    local data2 = GameTaskModel.GetTaskDataByID(v2.task_id)
    if data1.award_status == 2 and data2.award_status == 2 then
        if v1.index < v2.index then
            return false
        else
            return true
        end
    elseif data1.award_status == 1 and data2.award_status == 1 then
        if v1.index < v2.index then
            return false
        else
            return true
        end
    elseif data1.award_status == 0 and data2.award_status == 0 then
        if v1.index < v2.index then
            return false
        else
            return true
        end
    elseif  data1.award_status == 1 and data2.award_status == 2 then
        return false
    elseif  data1.award_status == 2 and data2.award_status == 1 then
        return true
    elseif  data1.award_status == 1 and data2.award_status == 0 then
        return false
    elseif  data1.award_status == 0 and data2.award_status == 1 then
        return true
    elseif  data1.award_status == 0 and data2.award_status == 2 then
        return false
    elseif  data1.award_status == 2 and data2.award_status == 0 then
        return true
    end  
end

function C:CreatePre()
    self:ClosePre()
    local tab = basefunc.deepcopy(M.GetCfg().task_info)
    MathExtend.SortListCom(tab, m_sort)
    for i=1,#tab do
        local pre = ACT_065_ZNCFKItemBase.Create(self.Content.transform,tab[i])
        self.pre_cell[#self.pre_cell + 1] = pre
    end
end

function C:ClosePre()
    if self.pre_cell then
        for k,v in pairs(self.pre_cell) do
            v:MyExit()
        end
    end
    self.pre_cell = {}
end

function C:on_act_065_zncfk_task_data_is_change_msg()
    self:MyRefresh()
end

function C:AddPMD(_, data)
    dump(data, "<color=red>PMD</color>")
    if not IsEquals(self.gameObject) then return end
    if data and data.result == 0 then
        local b = GameObject.Instantiate(self.pmd_item, self.pmd_node)
        b.gameObject:SetActive(true)
        local temp_ui = {}
        LuaHelper.GeneratingVar(b.transform, temp_ui)
        temp_ui.t1_txt.text = "恭喜玩家<color=#00A0FF>" .. data.player_name .. "</color>获得<color=#FF0000>" .. data.award_data .. "</color>!"
        UnityEngine.UI.LayoutRebuilder.ForceRebuildLayoutImmediate(b.transform)
        self.pmd_cont:AddObj(b)
    end
end

function C:UpdatePMD()
    if self.update_pmd then
        self.update_pmd:Stop()
    end
    
    Network.SendRequest("query_fake_data", { data_type = "default" })
    self.update_pmd = Timer.New(
        function()
            Network.SendRequest("query_fake_data", { data_type = "default" })
        end
    , 20, -1)
    self.update_pmd:Start()
end

function C:on_get_task_award_response(_,data)
    local config = M.GetCfg().base_info
    if data and data.result == 0 then 
        if data.id == config.task_id then
            local tab = {}
            tab.award_data = (data.award_list[1].asset_value / 100) .. "福卡"
            tab.player_name = MainModel.UserInfo.name
            tab.result = 0
            self:AddPMD("",tab)
        end
    end
end