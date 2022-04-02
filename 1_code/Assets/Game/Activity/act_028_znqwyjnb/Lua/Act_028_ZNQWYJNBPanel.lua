local basefunc = require "Game/Common/basefunc"

Act_028_ZNQWYJNBPanel = basefunc.class()
local C = Act_028_ZNQWYJNBPanel
C.name = "Act_028_ZNQWYJNBPanel"
local Mgr = Act_028_ZNQWYJNBManager
local instance
function C.Create(parm)
    if instance then
        instance:MyExit()
    end
    instance = C.New(parm)
	return instance
end

function C.Close()
    if instance then
        instance:MyExit()
    end
    instance = nil
end

function C:AddMsgListener()
	for proto_name,func in pairs(self.lister) do
		Event.AddListener(proto_name, func)
	end
end

function C:MakeLister()
	self.lister = {}
	self.lister["model_task_change_msg"] = basefunc.handler(self,self.on_model_task_change_msg)
	self.lister["model_query_one_task_data_response"] = basefunc.handler(self,self.on_model_query_one_task_data_response)
	self.lister["activity_task_item_refresh_end"] = basefunc.handler(self,self.activity_task_item_refresh_end)
end

function C:RemoveListener()
	for proto_name,func in pairs(self.lister) do
		Event.RemoveListener(proto_name, func)
	end
	self.lister = {}
end

function C:MyExit()
    if self.update_timer then
        self.update_timer:Stop()
    end
    self.update_timer = nil
	self:RemoveListener()
    destroy(self.gameObject)
    instance = nil
end

function C:ctor(parm)
    ExtPanel.ExtMsg(self)
    self:ChangeTaskUI(parm)
	local parent = parent or GameObject.Find("ActivityYearPanel_2").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	self:MakeLister()
	self:AddMsgListener()
    self:InitUI()
    parm = nil
end

function C:InitUI()
    self.reset_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        if self.cd > 0  then
            LittleTips.Create(self.cd .. "秒后可重置")
            return
        end
        local set_func = function(index)
            PlayerPrefs.SetInt(MainModel.UserInfo.user_id.. Mgr.key.."reset"..os.date("%Y%m%d",os.time()),index)
        end
        if PlayerPrefs.GetInt(MainModel.UserInfo.user_id.. Mgr.key.."reset"..os.date("%Y%m%d",os.time()),0) == 0 then
            local b = HintPanel.Create(2,"任务重置后,所有任务将重新开始，是否重置？",function ()
                if Mgr.task_id_reset then
                    Network.SendRequest("get_task_award", {id = Mgr.task_id_reset})
                    self.cd = 5
                end
            end)
            -- b:ChangeTitleImg("zjf_imgf_czrw")
            b:ChangeTitleImg("com_imgf_sm")
            b:ShowGou()
            b:SetGouCall(function()
                set_func(1)
            end,function()
                set_func(0)
            end)
            b = nil
        else
            if Mgr.task_id_reset then
                Network.SendRequest("get_task_award", {id = Mgr.task_id_reset})
                self.cd = 5
            end
        end
    end)
    self.rank_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        ActivityYearPanel_2.instance:SetSelectByName("积分达人榜")
    end)
    self:MyRefresh()
    self.cd = 0
    self.update_timer = Timer.New(function(  )
        self:RefreshCD()
        self.cd = self.cd - 1
    end,1,-1,nil,true)
    self.update_timer:Start()
end

function C:MyRefresh()
    if Act_028_JFDRBManager and Act_028_JFDRBManager.GetCurScore and type(Act_028_JFDRBManager.GetCurScore) == "function" then
        self.cur_score_txt.text = Act_028_JFDRBManager.GetCurScore()
    else
        self.cur_score_txt.text = "--"
    end
    self:RefreshCD()
end

function C:OnDestroy()
	self:MyExit()
end

function C:on_model_task_change_msg(task_data)
    if not (Mgr.task_id_hash[task_data.id] or Mgr.task_id_reset == task_data.id) then return end 
    self:MyRefresh()
end

function C:on_model_query_one_task_data_response(task_data)
    if not (Mgr.task_id_hash[task_data.id] or Mgr.task_id_reset == task_data.id) then return end 
    self:MyRefresh()
end

function C:activity_task_item_refresh_end(data)
    if data.task_data.id ~= 21472 then return end
    if data.task_data.award_status == 2 then
        data.item.gameObject:SetActive(false)
    end
end

function C:ChangeTaskUI(parm)
    if not parm or not parm.panelSelf or not IsEquals(parm.panelSelf.gameObject) then return end
    local tp = parm.panelSelf.gameObject
    tp = tp.transform
    local ui = tp:Find("Top/@icon_img")
    ui.gameObject:SetActive(false)
    ui = tp:Find("@help_btn")
    ui.gameObject:SetActive(false)
    ui = tp:Find("@Center/@sv_item(Clone)"):GetComponent("RectTransform")
    ui.anchoredPosition = Vector2.New(0,-226)
    ui.sizeDelta = Vector2.New(1092,600)
    ui = nil
    tp = nil
    self:RefreshFishingDown(parm)
end

function C:RefreshFishingDown(parm)
    local td = GameTaskModel.GetTaskDataByID(21472)
    if not td then return end
    if td.award_status ~= 2 then return end
    parm.panelSelf.items[21472][1].gameObject:SetActive(false)
end

function C:RefreshCD()
    if self.cd and self.cd > 0 then
        self.reset_txt.text = self.cd
    else
        local rc = Mgr.GetFreeResetCount()
        if rc > 0 then
            self.reset_txt.text = "免费" .. rc .. "/3次"
        else
            self.reset_txt.text = "消耗1000鲸币"
        end    
    end
end

--[[
    GetTexture("znqd_bg_2_activity_act_028_znqwyjnb")
    GetTexture("zjf_imgf_czrw")
]]