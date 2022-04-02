-- 创建时间:2019-12-28
-- Panel:VipShowQYSPanel
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
 --]]

local basefunc = require "Game/Common/basefunc"

VipShowQYSPanel = basefunc.class()
local C = VipShowQYSPanel
C.name = "VipShowQYSPanel"
local config
function C.Create(parent)
	return C.New(parent)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
	self.lister = {}
	self.lister["model_vip_task_change_msg"] = basefunc.handler(self, self.OnReFreshInfo)
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

function C:ctor(parent)
	local parent = parent or GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	config = VIPManager.GetVIPCfg() 
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	self:OnTask(VIPManager.get_vip_task())
end

function C:OnTask(data)
	if data == nil or not IsEquals(self.gameObject) then return end
	dump(data, "--------------------")
	if data then
		local QYSdata = {}
		for i = 1, 8 do
			QYSdata[i] = data[112 + i]
		end
		self:DoQYS(QYSdata)
	end
end

function C:OnReFreshInfo()
	local data = VIPManager.get_vip_task()
	if data == nil or not IsEquals(self.gameObject) then return end
	dump(data, "--------------------")
	if data then
		local QYSdata = {}
		for i = 1, 8 do
			QYSdata[i] = data[112 + i]
		end
		self:RefreshQYS(QYSdata)
	end
end

function C:InitUI()
	self.AwardChild = self.transform:Find("AwardChild")
	self.QYSpanel = self.transform:Find("QYS")
	self.QYSCText = self.QYSpanel:Find("CText"):GetComponent("Text")
	self.QYSChild = self.transform:Find("QYSChild")
	self.QYSContent = self.QYSpanel:Find("Scroll View/Viewport/Content")
	self.QYSHelp = self.QYSpanel.transform:Find("Help"):GetComponent("Button")
	self.JQSHelpPanel = self.transform:Find("JQSHelpPanel")

	--help text
	local help_txt = self.JQSHelpPanel:Find("Scroll View/Viewport/Content/Text2"):GetComponent("Text")
	help_txt.text = "玩家在参与公益赛-福利大奖赛获得相应名次可领取奖励。"

    self.JQSHelpPanelButton = self.JQSHelpPanel:Find("Button"):GetComponent("Button")
	self.JQSHelpPanelClose = self.JQSHelpPanel:Find("CloseButton"):GetComponent("Button")
	self.QYSHelp.onClick:AddListener(
		function()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
			self.JQSHelpPanel.gameObject:SetActive(true)
		end
	)
	self.JQSHelpPanelClose.onClick:AddListener(
		function()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
			self.JQSHelpPanel.gameObject:SetActive(false)
		end
    )
    self.JQSHelpPanelButton.onClick:AddListener(
		function()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
			self.JQSHelpPanel.gameObject:SetActive(false)
		end
	)
	self.QYSHelp.onClick:AddListener(
		function()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
			self.JQSHelpPanel.gameObject:SetActive(true)
		end
    )
end

function C:DoQYS(data)
    if table_is_null(data) then
        data = {
            [1] = {
                award_get_status = 0,
                award_status = 0,
                end_valid_time = 32503651200,
                id            = 113,
                need_process    = 1,
                now_lv        = 1,
                now_process    = 0,
                now_total_process = 0,
                over_time    = 32503651200,
                start_valid_time = 946677600,
                task_type    = "vip_qys_task",
            },
            [2] = {
                award_get_status = 0,
                award_status = 0,
                end_valid_time = 32503651200,
                id            = 114,
                need_process    = 1,
                now_lv        = 1,
                now_process    = 0,
                now_total_process = 0,
                over_time    = 32503651200,
                start_valid_time = 946677600,
                task_type    = "vip_qys_task",
            },
            [3] = {
                award_get_status = 0,
                award_status = 0,
                end_valid_time = 32503651200,
                id            = 115,
                need_process    = 1,
                now_lv        = 1,
                now_process    = 0,
                now_total_process = 0,
                over_time    = 32503651200,
                start_valid_time = 946677600,
                task_type    = "vip_qys_task",
            },
            [4] = {
                award_get_status = 0,
                award_status = 0,
                end_valid_time = 32503651200,
                id            = 116,
                need_process    = 1,
                now_lv        = 1,
                now_process    = 0,
                now_total_process = 0,
                over_time    = 32503651200,
                start_valid_time = 946677600,
                task_type    = "vip_qys_task",
            },
            [5] = {
                award_get_status = 0,
                award_status = 0,
                end_valid_time = 32503651200,
                id            = 117,
                need_process    = 1,
                now_lv        = 1,
                now_process    = 0,
                now_total_process = 0,
                over_time    = 32503651200,
                start_valid_time = 946677600,
                task_type    = "vip_qys_task",
            },
            [6] = {
                award_get_status = 0,
                award_status = 0,
                end_valid_time = 32503651200,
                id            = 118,
                need_process    = 1,
                now_lv        = 1,
                now_process    = 0,
                now_total_process = 0,
                over_time    = 32503651200,
                start_valid_time = 946677600,
                task_type    = "vip_qys_task",
            },
            [7] = {
                award_get_status = 0,
                award_status = 0,
                end_valid_time = 32503651200,
                id            = 119,
                need_process    = 1,
                now_lv        = 1,
                now_process    = 0,
                now_total_process = 0,
                over_time    = 32503651200,
                start_valid_time = 946677600,
                task_type    = "vip_qys_task",
            },
            [8] = {
                award_get_status = 0,
                award_status = 0,
                end_valid_time = 32503651200,
                id            = 120,
                need_process    = 1,
                now_lv        = 1,
                now_process    = 0,
                now_total_process = 0,
                over_time    = 32503651200,
                start_valid_time = 946677600,
                task_type    = "vip_qys_task",
            },        

        }
    end
    self.QYSChilds = {}
    for i = 1, #data do
        local m = GameObject.Instantiate(self.QYSChild, self.QYSContent)
        m.gameObject:SetActive(true)
        m.gameObject.transform:SetSiblingIndex(0)
        self.QYSChilds[#self.QYSChilds + 1] = m
        m.transform:Find("TopText/Text1"):GetComponent("Text").text = "福利赛大奖获得 "
        m.transform:Find("TopText/Text2"):GetComponent("Text").text = "前" .. config.qys[i].need .. "名"
        m.transform:Find("GOButton").gameObject:GetComponent("Button").onClick:AddListener(
        function()
            ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
            local gotoparm = {gotoui = "match_hall",goto_scene_parm = "gms"}
            GameManager.GotoUI(gotoparm)
        end        
        )
        m.transform:Find("LQButton").gameObject:GetComponent("Button").onClick:AddListener(
        function()
            ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
            Network.SendRequest("get_task_award_new", { id = 112 + i, award_progress_lv = 1 })
        end        
        )
        local content = m.transform:Find("Scroll View/Viewport/Content")
        if type(config.qys[i].image) == "table" then
            for j = 1, #config.qys[i].image do
                local n = GameObject.Instantiate(self.AwardChild, content)
                n.gameObject:SetActive(true)
                n.transform:Find("Image"):GetComponent("Image").sprite = GetTexture(config.qys[i].image[j])
                n.transform:Find("Text"):GetComponent("Text").text = config.qys[i].text[j]
            end
        else
            local n = GameObject.Instantiate(self.AwardChild, content)
            n.gameObject:SetActive(true)
            n.transform:Find("Image"):GetComponent("Image").sprite = GetTexture(config.qys[i].image)
            n.transform:Find("Text"):GetComponent("Text").text = config.qys[i].text
        end
    end
    self:RefreshQYS(data)
end

function C:RefreshQYS(data)
    if table_is_null(data) then return end
    for i = 1, #data do
        if data[i] == nil then
            return
        end
        local b = basefunc.decode_task_award_status(data[i].award_get_status)
        b = basefunc.decode_all_task_award_status(b, data[i], 1)

        if b[1] == 0 then
            self.QYSChilds[i].transform:Find("GOButton").gameObject:SetActive(true)
            self.QYSChilds[i].transform:Find("LQButton").gameObject:SetActive(false)
            self.QYSChilds[i].transform:Find("MASK").gameObject:SetActive(false)
        end
        if b[1] == 1 then
            self.QYSChilds[i].transform:Find("GOButton").gameObject:SetActive(false)
            self.QYSChilds[i].transform:Find("LQButton").gameObject:SetActive(true)
            self.QYSChilds[i].transform:Find("MASK").gameObject:SetActive(false)
        end
        if b[1] == 2 then
            self.QYSChilds[i].transform:Find("GOButton").gameObject:SetActive(false)
            self.QYSChilds[i].transform:Find("LQButton").gameObject:SetActive(false)
            self.QYSChilds[i].transform:Find("MASK").gameObject:SetActive(true)
            self.QYSChilds[i].transform:SetSiblingIndex(#self.QYSChilds)
        end

    end
end
function C:OnDestroy()
	self:MyExit()
end