-- 创建时间:2019-08-02
-- Panel:New Lua
--[[ *      ┌─┐       ┌─┐
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

VipShowTaskPanel = basefunc.class()
local C = VipShowTaskPanel
C.name = "VipShowTaskPanel"
local config
function C.Create(parm)
    return C.New(parm)
end

function C:AddMsgListener()
    for proto_name, func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["model_vip_upgrade_change_msg"] = basefunc.handler(self, self.OnGetInfo)
    self.lister["model_vip_task_change_msg"] = basefunc.handler(self, self.OnReFreshInfo)
    self.lister["EnterBackGround"] = basefunc.handler(self, self.MyExit)
    self.lister["ExitScene"] = basefunc.handler(self, self.MyExit)
end

function C:OnReFreshInfo()
    local data = VIPManager.get_vip_task()
    if data and IsEquals(self.gameObject)  then
        self:RefreshLB(data[111])
        self:RefreshYJTZ(data[112])
        local QYSdata = {}
        for i = 1, 8 do
            QYSdata[i] = data[112 + i]
        end
        self:RefreshQYS(QYSdata)
        local WeeKdata = {}
        for i=1, 2 do
            WeeKdata[21015 + i] = data[21015 + i]
        end
        self:RefreshVIPMZFL(WeeKdata)
    end
end

function C:OnGetInfo(data)
    if data == nil or not IsEquals(self.gameObject) then return end
    if IsEquals(self.gameObject) then
        if data and data.vip_level then
            self.QYSCText.text = data.vip_level
            self.YJTZCText.text = data.vip_level
            self.LBCText.text = data.vip_level
            self.VIPMZFLCText.text = data.vip_level
        end
    end
end
function C:OnTask(_, data)
    if data == nil or not IsEquals(self.gameObject) then return end
    dump(data, "--------------------")
    if data then
        self:DoLB(data[111])
        self:DoYJTZ(data[112])
        local QYSdata = {}
        for i = 1, 8 do
            QYSdata[i] = data[112 + i]
        end
        self:DoQYS(QYSdata)
        local WeeKdata = {}
        for i=1, 2 do
            WeeKdata[21015 + i] = data[21015 + i]
        end
        self:DoVIPMZFL(WeeKdata)
    end
end

function C:RemoveListener()
    for proto_name, func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
    if self.parm and self.parm.backcall then
        self.parm.backcall()
    end
    self:RemoveListener()
    destroy(self.gameObject)
    VipShowInfoPanel.Close()

	 
end

function C:ctor(parm)

	ExtPanel.ExtMsg(self)

    self.parm = parm
    config = VIPManager.GetVIPCfg()
    local parent = GameObject.Find("Canvas/LayerLv5").transform
    local obj = newObject(C.name, parent)
    local tran = obj.transform
    self.transform = tran
    self.gameObject = obj
    self:MakeLister()
    self:AddMsgListener()
    self:InitUI()
    self:GetEvent()
    if self.parm and self.parm.goto_scene_parm1 == "mxb" then
        self:OnClick(5)
    elseif self.parm and self.parm.goto_scene_parm1 == "tq" then
        self:OnClick(6)
    else
        self:OnClick(6)
    end
end

function C:InitUI()
    self.LBButton = self.transform:Find("SVSwitch/Viewport/@switch_content/Button1/Image"):GetComponent("Button")
    self.YJTZButton = self.transform:Find("SVSwitch/Viewport/@switch_content/Button2/Image"):GetComponent("Button")
    self.QYSButton = self.transform:Find("SVSwitch/Viewport/@switch_content/Button3/Image"):GetComponent("Button")
    self.VIPMZFLButton = self.transform:Find("SVSwitch/Viewport/@switch_content/Button4/Image"):GetComponent("Button")
    self.CloseButton = self.transform:Find("CloseButton"):GetComponent("Button")
    self.LBButton2 = self.transform:Find("SVSwitch/Viewport/@switch_content/Button1/Image2")
    self.YJTZButton2 = self.transform:Find("SVSwitch/Viewport/@switch_content/Button2/Image2")
    self.QYSButton2 = self.transform:Find("SVSwitch/Viewport/@switch_content/Button3/Image2")
    self.VIPMZFLButton2 = self.transform:Find("SVSwitch/Viewport/@switch_content/Button4/Image2")
    self.LBpanel = self.transform:Find("LB")
    self.LBCText = self.LBpanel:Find("CText"):GetComponent("Text")
    self.YJTZpanel = self.transform:Find("YJTZ")
    self.YJTZCText = self.YJTZpanel:Find("CText"):GetComponent("Text")
    self.QYSpanel = self.transform:Find("QYS")
    self.QYSCText = self.QYSpanel:Find("CText"):GetComponent("Text")
    self.LBChild = self.transform:Find("LBChild")
    self.YJTZChild = self.transform:Find("YJTZChild")
    self.QYSChild = self.transform:Find("QYSChild")
    self.AwardChild = self.transform:Find("AwardChild")
    self.VIPMZFLChild = self.transform:Find("VIPMZFLChild")
    self.QYSContent = self.QYSpanel:Find("Scroll View/Viewport/Content")
    self.YJTZContent = self.YJTZpanel:Find("Scroll View/Viewport/Content")
    self.LBContent = self.LBpanel:Find("Scroll View/Viewport/Content")
    self.JDTlen = self.YJTZChild:Find("Progress_bg").rect.width
    self.JDT = self.YJTZChild:Find("Progress_bg/progress_mask").transform
    self.YJTZHelpPanel = self.transform:Find("YJTZHelpPanel")
    self.YJTZHelpPanelButton = self.YJTZHelpPanel:Find("Button"):GetComponent("Button")
    self.YJTZHelpPanelClose = self.YJTZHelpPanel:Find("CloseButton"):GetComponent("Button")
    self.JQSHelpPanel = self.transform:Find("JQSHelpPanel")
    self.JQSHelpPanelButton = self.JQSHelpPanel:Find("Button"):GetComponent("Button")
    self.JQSHelpPanelClose = self.JQSHelpPanel:Find("CloseButton"):GetComponent("Button")
    self.YJTZHelp = self.YJTZpanel.transform:Find("Help"):GetComponent("Button")
    self.QYSHelp = self.QYSpanel.transform:Find("Help"):GetComponent("Button")
    self.VIPMZFLPanel = self.transform:Find("VIPMZFLPanel")
    self.VIPMZFLCText = self.VIPMZFLPanel.transform:Find("CText"):GetComponent("Text")
    self.VIPMZFLHelpButton = self.VIPMZFLPanel.transform:Find("Help"):GetComponent("Button")
    self.VIPMZFLContent = self.VIPMZFLPanel:Find("Scroll View/Viewport/Content")
    self.VIPMZFLHelpPanel = self.transform:Find("VIPMZFLHelpPanel")
    self.VIPMZFLHelpPanelButton = self.VIPMZFLHelpPanel:Find("Button"):GetComponent("Button")
    self.VIPMZFLHelpPanelClose = self.VIPMZFLHelpPanel:Find("CloseButton"):GetComponent("Button")
    self.VIPMZFLHelp = self.VIPMZFLPanel.transform:Find("Help"):GetComponent("Button")
    self.Red1 = self.transform:Find("SVSwitch/Viewport/@switch_content/Button1/Red")
    self.Red2 = self.transform:Find("SVSwitch/Viewport/@switch_content/Button2/Red")
    self.Red3 = self.transform:Find("SVSwitch/Viewport/@switch_content/Button3/Red")
    self.Red4 = self.transform:Find("SVSwitch/Viewport/@switch_content/Button4/Red")

    --明星杯设置
    self:InitMXB()
    self:InitVIPTQ()
end

function C:GetEvent()
    self.LBButton.onClick:AddListener(
    function()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
        self:OnClick(1)
    end
    )
    self.YJTZButton.onClick:AddListener(
    function()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
        self:OnClick(2)
    end
    )
    self.QYSButton.onClick:AddListener(
    function()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
        self:OnClick(3)
    end
    )
    self.VIPMZFLButton.onClick:AddListener(
        function()
            ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
            self:OnClick(4)
        end
    ) 
    self.CloseButton.onClick:AddListener(
    function()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
        self:MyExit()
    end
    )
    self.QYSHelp.onClick:AddListener(
    function()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
        self.JQSHelpPanel.gameObject:SetActive(true)
    end
    )
    self.YJTZHelp.onClick:AddListener(
    function()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
        self.YJTZHelpPanel.gameObject:SetActive(true)
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
    self.YJTZHelpPanelClose.onClick:AddListener(
    function()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
        self.YJTZHelpPanel.gameObject:SetActive(false)
    end
    )
    self.YJTZHelpPanelButton.onClick:AddListener(
    function()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
        self.YJTZHelpPanel.gameObject:SetActive(false)
    end
    )
    self.VIPMZFLHelpPanelClose.onClick:AddListener(
    function()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
        self.VIPMZFLHelpPanel.gameObject:SetActive(false)
    end
    )
    self.VIPMZFLHelpPanelButton.onClick:AddListener(
    function()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
        self.VIPMZFLHelpPanel.gameObject:SetActive(false)
    end
    )
    self.VIPMZFLHelp.onClick:AddListener(
    function()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
        self.VIPMZFLHelpPanel.gameObject:SetActive(true)
    end
    )
    self:OnGetInfo(VIPManager.get_vip_data())
    self:OnTask("", VIPManager.get_vip_task())
end


function C:DoLB(data)
    if data == nil then return end
    local b = basefunc.decode_task_award_status(data.award_get_status)
    b = basefunc.decode_all_task_award_status(b, data, #config.lb)
    --dump(b,"------礼包-------")
    self.LBChilds = {}
    for i = 1, #b do
        local m    = GameObject.Instantiate(self.LBChild, self.LBContent)
        self.LBChilds[#self.LBChilds + 1] = m
        m.gameObject:SetActive(true)
        local content = m.transform:Find("Scroll View/Viewport/Content")
        m.transform:Find("CZButton").gameObject:GetComponent("Button").onClick:AddListener(
        function()
            self:MyExit()
            ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
            PayPanel.Create(GOODS_TYPE.jing_bi, "normal")
        end        
        )
        m.transform:Find("LQButton").gameObject:GetComponent("Button").onClick:AddListener(
        function()
            ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
            Network.SendRequest("get_task_award_new", { id = 111, award_progress_lv = i })
        end        
        )
        m.transform:Find("TopText/Text1"):GetComponent("Text").text = "VIP等级达到"
        m.transform:Find("TopText/Text2"):GetComponent("Text").text = i .. "级"
        m.transform:Find("TopText/Text3"):GetComponent("Text").text = "时领取"
        for j = 1, #config.lb[i].image do
            local n = GameObject.Instantiate(self.AwardChild, content)
            n.gameObject:SetActive(true)
            n.transform:Find("Image"):GetComponent("Image").sprite = GetTexture(config.lb[i].image[j])
            n.transform:Find("Text"):GetComponent("Text").text = config.lb[i].text[j]
        end
    end
    self:RefreshLB(data)
end
function C:RefreshLB(data)
    if data == nil then return end
    local vip_data = VIPManager.get_vip_data()
    local b = basefunc.decode_task_award_status(data.award_get_status)
    b = basefunc.decode_all_task_award_status(b, data, #config.lb)
    self.Red1.gameObject:SetActive(false)
    for i = 1, #self.LBChilds do
        if b[i] == 0 then
            self.LBChilds[i].transform:Find("CZButton").gameObject:SetActive(true)
            self.LBChilds[i].transform:Find("LQButton").gameObject:SetActive(false)
			self.LBChilds[i].transform:Find("MASK").gameObject:SetActive(false)
			local temp = StringHelper.ToCash(config.dangci[i].total)
			self.LBChilds[i].transform:Find("BFBText"):GetComponent("Text").text = StringHelper.ToCash(vip_data.now_charge_sum/100) .."/"..temp
			self.LBChilds[i]:Find("Progress_bg/progress_mask").sizeDelta = {
				x = self.JDTlen * (vip_data.now_charge_sum/100 / config.dangci[i].total),
				y = self.LBChilds[i]:Find("Progress_bg/progress_mask").rect.height
			}
        end
        if b[i] == 1 then
            self.Red1.gameObject:SetActive(true)
            self.LBChilds[i].transform:Find("CZButton").gameObject:SetActive(false)
            self.LBChilds[i].transform:Find("LQButton").gameObject:SetActive(true)
			self.LBChilds[i].transform:Find("MASK").gameObject:SetActive(false)
			local temp = StringHelper.ToCash(config.dangci[i].total)
			self.LBChilds[i].transform:Find("BFBText"):GetComponent("Text").text = temp.."/"..temp
			self.LBChilds[i]:Find("Progress_bg/progress_mask").sizeDelta = {
				x = self.JDTlen,
				y = self.LBChilds[i]:Find("Progress_bg/progress_mask").rect.height
			}
        end
        if b[i] == 2 then
            self.LBChilds[i].transform:Find("CZButton").gameObject:SetActive(false)
            self.LBChilds[i].transform:Find("LQButton").gameObject:SetActive(false)
            self.LBChilds[i].transform:Find("MASK").gameObject:SetActive(true)
			self.LBChilds[i].transform:SetSiblingIndex(#self.LBChilds)
			local temp = StringHelper.ToCash(config.dangci[i].total)
			self.LBChilds[i].transform:Find("BFBText"):GetComponent("Text").text = temp.."/"..temp
			self.LBChilds[i]:Find("Progress_bg/progress_mask").sizeDelta = {
				x = self.JDTlen,
				y = self.LBChilds[i]:Find("Progress_bg/progress_mask").rect.height
			}
        end
	end
	for i = vip_data.vip_level+2, #config.dangci do
		if i>=7 then
			self.LBChilds[i].transform:Find("Progress_bg").gameObject:SetActive(false)
			self.LBChilds[i].transform:Find("BFBText").gameObject:SetActive(false)
		end 
	end
end


function C:DoYJTZ(data)
    if data == nil then
        data = {
            award_get_status = 0,
            award_status    = 0,
            end_valid_time = 32503651200,
            id            = 112,
            need_process    = 1000000,
            now_lv    = 1,
            now_process    = 0,
            now_total_process = 0,
            over_time    = 32503651200,
            start_valid_time = 946677600,
            task_round    = 1,
            task_type    = "vip_game_award_task",
        }
    end
    dump(data.award_get_status, ">>>>>")
    local b = basefunc.decode_task_award_status(data.award_get_status)
    dump(b, ">>>>>")
    b = basefunc.decode_all_task_award_status2(b, data, #config.yjtz)
    dump(b, "-------赢金挑战------")
    self.YJTZChilds = {}
    for i = 1, #b do
        local m    = GameObject.Instantiate(self.YJTZChild, self.YJTZContent)
        self.YJTZChilds[#self.YJTZChilds + 1] = m
        m.gameObject:SetActive(true)
        local content = m.transform:Find("Scroll View/Viewport/Content")
        m.transform:Find("GOButton").gameObject:GetComponent("Button").onClick:AddListener(
        function()
            ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
            if MainModel.myLocation == "game_Hall" then
                self:MyExit()
            else
                local gotoparm = {gotoui = "game_Hall"}
                GameManager.GotoUI(gotoparm)
            end            
        end        
        )
        m.transform:Find("LQButton").gameObject:GetComponent("Button").onClick:AddListener(
        function()
            ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
            if config.yjtz[i].isreal == 1 then
                local string1
                string1 = "奖品:" .. config.yjtz[i].text .. "，抽到奖励后请联系客服领取奖励\n客服QQ：%s"            
                HintCopyPanel.Create({ desc = string1, isQQ = true })
                Network.SendRequest("get_task_award_new", { id = 112, award_progress_lv = i })
            else
                Network.SendRequest("get_task_award_new", { id = 112, award_progress_lv = i })
            end            
        end        
        )
        m.transform:Find("SWLQButton").gameObject:GetComponent("Button").onClick:AddListener(
        function()
            ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
            if config.yjtz[i].isreal == 1 then
                local string1
                string1 = "奖品:" .. config.yjtz[i].text .. "，抽到奖励后请联系客服领取奖励\n客服QQ：%s"            
                HintCopyPanel.Create({ desc = string1, isQQ = true })
            end            
        end        
        )
        m.transform:Find("TopText/Text1"):GetComponent("Text").text = "所有游戏累计赢金"
        m.transform:Find("TopText/Text2"):GetComponent("Text").text = StringHelper.ToCash(config.yjtz[i].need)
        if type(config.yjtz[i].image) == "table" then
            for j = 1, #config.yjtz[i].image do
                local n = GameObject.Instantiate(self.AwardChild, content)
                n.gameObject:SetActive(true)
                n.transform:Find("Image"):GetComponent("Image").sprite = GetTexture(config.yjtz[i].image[j])
                n.transform:Find("Text"):GetComponent("Text").text = config.yjtz[i].text[j]
            end
        else
            local n = GameObject.Instantiate(self.AwardChild, content)
            n.gameObject:SetActive(true)
            n.transform:Find("Image"):GetComponent("Image").sprite = GetTexture(config.yjtz[i].image)
            n.transform:Find("Text"):GetComponent("Text").text = config.yjtz[i].text
        end


    end
    self:RefreshYJTZ(data)
end
function C:RefreshYJTZ(data)
    if data == nil then return end
    local b = basefunc.decode_task_award_status(data.award_get_status)
    b = basefunc.decode_all_task_award_status2(b, data, #config.yjtz)
    for i = 1, data.now_lv - 1 do
        self.YJTZChilds[i]:Find("Progress_bg/progress_mask").sizeDelta = {
            x = self.JDTlen * 1,
            y = self.YJTZChilds[i]:Find("Progress_bg/progress_mask").rect.height
        }
        self.YJTZChilds[i]:Find("BFBText"):GetComponent("Text").text = StringHelper.ToCash(config.yjtz[i].need) .. "/" .. StringHelper.ToCash(config.yjtz[i].need)
    end
    self.YJTZChilds[data.now_lv]:Find("Progress_bg/progress_mask").sizeDelta = {
        x = self.JDTlen * (data.now_total_process / config.yjtz[data.now_lv].need),
        y = self.YJTZChilds[data.now_lv]:Find("Progress_bg/progress_mask").rect.height
    }
    self.YJTZChilds[data.now_lv]:Find("BFBText"):GetComponent("Text").text = StringHelper.ToCash(data.now_total_process) .. "/" .. StringHelper.ToCash(config.yjtz[data.now_lv].need)
    for i = data.now_lv + 1, #config.yjtz do
        self.YJTZChilds[i]:Find("Progress_bg/progress_mask").sizeDelta = {
            x = self.JDTlen * (data.now_total_process / config.yjtz[i].need),
            y = self.YJTZChilds[i]:Find("Progress_bg/progress_mask").rect.height
        }
        self.YJTZChilds[i]:Find("BFBText"):GetComponent("Text").text = StringHelper.ToCash(data.now_total_process) .. "/" .. StringHelper.ToCash(config.yjtz[i].need)
    end
    self.Red2.gameObject:SetActive(false)
    local sibling_index = 0
    for i = 1, #self.YJTZChilds do
        if b[i] == 0 then
            self.YJTZChilds[i].transform:Find("GOButton").gameObject:SetActive(true)
            self.YJTZChilds[i].transform:Find("LQButton").gameObject:SetActive(false)
            self.YJTZChilds[i].transform:Find("MASK").gameObject:SetActive(false)
        end
        if b[i] == 1 then
            self.Red2.gameObject:SetActive(true)
            self.YJTZChilds[i].transform:Find("GOButton").gameObject:SetActive(false)
            self.YJTZChilds[i].transform:Find("LQButton").gameObject:SetActive(true)
            self.YJTZChilds[i].transform:Find("MASK").gameObject:SetActive(false)
        end
        if b[i] == 2 then        
            self.YJTZChilds[i].transform:Find("GOButton").gameObject:SetActive(false)
            self.YJTZChilds[i].transform:Find("LQButton").gameObject:SetActive(false)
            self.YJTZChilds[i].transform:Find("MASK").gameObject:SetActive(true)
            self.YJTZChilds[i].transform:SetSiblingIndex(#self.YJTZChilds)
            self.YJTZChilds[i]:Find("Progress_bg").gameObject:SetActive(false)
            self.YJTZChilds[i]:Find("BFBText").gameObject:SetActive(false)
            if config.yjtz[i].isreal == 1 then
                self.YJTZChilds[i].transform:Find("SWLQButton").gameObject:SetActive(true)
                self.YJTZChilds[i].transform:Find("MASK").gameObject:SetActive(false)
                --self.YJTZChilds[i].transform:SetSiblingIndex(#self.YJTZChilds-sibling_index)
            else
                sibling_index = sibling_index + 1
                self.YJTZChilds[i].transform:Find("SWLQButton").gameObject:SetActive(false)
            end
        end
    end
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
        m.transform:Find("TopText/Text1"):GetComponent("Text").text = "千元赛大奖获得 "
        m.transform:Find("TopText/Text2"):GetComponent("Text").text = "前" .. config.qys[i].need .. "名"
        m.transform:Find("GOButton").gameObject:GetComponent("Button").onClick:AddListener(
        function()
            ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
            local gotoparm = {gotoui = "match_hall",goto_scene_parm = "gms"}
            GameManager.GotoUI(gotoparm, function ()
                self:MyExit()            
            end)
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
    self.Red3.gameObject:SetActive(false)
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
            self.Red3.gameObject:SetActive(true)
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

function C:DoVIPMZFL(data)
    self.VIPMZFLChilds = {}
    for i=1,#config.vipmzfl do
        local m = GameObject.Instantiate(self.VIPMZFLChild,self.VIPMZFLContent)
        m.gameObject:SetActive(true)
        local t = m.transform:Find("Text"):GetComponent("Text")
        local content = m.transform:Find("Scroll View/Viewport/Content")
        t.text =  config.vipmzfl[i].title
        if type(config.vipmzfl[i].image) == "table" then
            for j = 1, #config.vipmzfl[i].image do
                local n = GameObject.Instantiate(self.AwardChild, content)
                n.gameObject:SetActive(true)
                n.transform:Find("Image"):GetComponent("Image").sprite = GetTexture(config.vipmzfl[i].image[j])
                n.transform:Find("Text"):GetComponent("Text").text = config.vipmzfl[i].text[j]
            end
        else
            local n = GameObject.Instantiate(self.AwardChild, content)
            n.gameObject:SetActive(true)
            n.transform:Find("Image"):GetComponent("Image").sprite = GetTexture(config.vipmzfl[i].image)
            n.transform:Find("Text"):GetComponent("Text").text = config.vipmzfl[i].text
        end
        m.transform:Find("GOButton").gameObject:SetActive(true)
        m.transform:Find("LQButton").gameObject:SetActive(false)
        m.transform:Find("MASK").gameObject:SetActive(false)
        m.transform:Find("GOButton"):GetComponent("Button").onClick:AddListener(
            function ()
                self:MyExit()
                PayPanel.Create(GOODS_TYPE.jing_bi, "normal")
            end
        )
        m.transform:Find("LQButton"):GetComponent("Button").onClick:AddListener(
            function ()
                if os.date("%w", os.time()) == "0"  then
                    Network.SendRequest("get_task_award_new", { id = 21015 + i, award_progress_lv = 1 })
                else
                    HintPanel.Create(1,"请在周日的0点到24点期间领取奖励！")
                end 
            end
        )
        self.VIPMZFLChilds[i] = m
    end
    self:RefreshVIPMZFL(data)
end

function C:RefreshVIPMZFL(data)
    --无法知道服务器那边的数据有无，例如21017有，但是21016没有，有可能会导致排序错乱，所以没有用表的形式
    dump(data,"<color=red> RefreshVIPMZFL </color>")
    self.Red4.gameObject:SetActive(false)
    if data then 
        if data[21016] then 
            if data[21016].award_status == 0 then 
                self.VIPMZFLChilds[1].transform:Find("GOButton").gameObject:SetActive(true)
                self.VIPMZFLChilds[1].transform:Find("LQButton").gameObject:SetActive(false)
                self.VIPMZFLChilds[1].transform:Find("MASK").gameObject:SetActive(false)
            elseif data[21016].award_status == 1 then 
                self.VIPMZFLChilds[1].transform:Find("LQButton").gameObject:SetActive(true)
                self.VIPMZFLChilds[1].transform:Find("GOButton").gameObject:SetActive(false)
                self.VIPMZFLChilds[1].transform:Find("MASK").gameObject:SetActive(false)
                self.Red4.gameObject:SetActive(true)
            elseif data[21016].award_status == 2 then
                self.VIPMZFLChilds[1].transform:Find("MASK").gameObject:SetActive(true)
                self.VIPMZFLChilds[1].transform:Find("GOButton").gameObject:SetActive(false)
                self.VIPMZFLChilds[1].transform:Find("LQButton").gameObject:SetActive(false)
                self.VIPMZFLChilds[1]:SetSiblingIndex(2)
            end 
        end 
        if data[21017] then 
            if data[21017].award_status == 0 then 
                self.VIPMZFLChilds[2].transform:Find("GOButton").gameObject:SetActive(true)
                self.VIPMZFLChilds[2].transform:Find("LQButton").gameObject:SetActive(false)
                self.VIPMZFLChilds[2].transform:Find("MASK").gameObject:SetActive(false)
            elseif data[21017].award_status == 1 then 
                self.VIPMZFLChilds[2].transform:Find("LQButton").gameObject:SetActive(true)
                self.VIPMZFLChilds[2].transform:Find("GOButton").gameObject:SetActive(false)
                self.VIPMZFLChilds[2].transform:Find("MASK").gameObject:SetActive(false)
                self.Red4.gameObject:SetActive(true)
            elseif data[21017].award_status == 2 then
                self.VIPMZFLChilds[2].transform:Find("MASK").gameObject:SetActive(true)
                self.VIPMZFLChilds[2].transform:Find("GOButton").gameObject:SetActive(false)
                self.VIPMZFLChilds[2].transform:Find("LQButton").gameObject:SetActive(false)
                self.VIPMZFLChilds[2]:SetSiblingIndex(2)
            end 
        end 
    end
    if VIPManager.get_vip_data().vip_level >= 6 then
        self.VIPMZFLChilds[1].gameObject:SetActive(false)
    end  
end

function C:OnClick(index)
    self:HideAllButton()
    if index == 1 then
        self.LBButton2.gameObject:SetActive(true)
        self.LBpanel.gameObject:SetActive(true)
    end
    if index == 2 then
        self.YJTZButton2.gameObject:SetActive(true)
        self.YJTZpanel.gameObject:SetActive(true)
    end
    if index == 3 then
        self.QYSButton2.gameObject:SetActive(true)
        self.QYSpanel.gameObject:SetActive(true)
    end
    if index == 4 then
        self.VIPMZFLButton2.gameObject:SetActive(true)
        self.VIPMZFLPanel.gameObject:SetActive(true)
    end
    if index == 5 then
        self.MXBButton2.gameObject:SetActive(true)
        self.MXBPanel.gameObject:SetActive(true)
    end
    if index == 6 then
        self.TQButton2.gameObject:SetActive(true)
        self.TQPanel.gameObject:SetActive(true)
    end
end

function C:HideAllButton()
    self.LBButton2.gameObject:SetActive(false)
    self.YJTZButton2.gameObject:SetActive(false)
    self.QYSButton2.gameObject:SetActive(false)
    self.VIPMZFLButton2.gameObject:SetActive(false)
    self.MXBButton2.gameObject:SetActive(false)
    self.TQButton2.gameObject:SetActive(false)
    
    self.LBpanel.gameObject:SetActive(false)
    self.YJTZpanel.gameObject:SetActive(false)
    self.QYSpanel.gameObject:SetActive(false)
    self.VIPMZFLPanel.gameObject:SetActive(false)
    self.MXBPanel.gameObject:SetActive(false)
    self.TQPanel.gameObject:SetActive(false)
end

function C:InitMXB()
    --VIP4回馈赛
    self.MXBPanel = self.transform:Find("MXB")
    self.MXBButton = self.transform:Find("SVSwitch/Viewport/@switch_content/Button5/Image"):GetComponent("Button")
    self.MXBButton2 = self.transform:Find("SVSwitch/Viewport/@switch_content/Button5/Image2")
    self.Red5 = self.transform:Find("SVSwitch/Viewport/@switch_content/Button5/Red")
    self.MXBWait = self.transform:Find("MXB/Wait")
    self.MXBRuning = self.transform:Find("MXB/Runing")
    self.MXBBtnGoto = self.transform:Find("MXB/GotoButton"):GetComponent("Button")
    self.MXBTxtTime = self.transform:Find("MXB/Wait/TimeText"):GetComponent("Text")
    self.MXBVIPText = self.transform:Find("MXB/Wait/TimeText"):GetComponent("Text")
    
    self.MXBButton.onClick:AddListener(
        function()
            ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
            self:OnClick(5)
        end
    )
    self.MXBBtnGoto.onClick:AddListener(
        function()
            ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
            local gotoparm = {gotoui = "match_hall",goto_scene_parm = "mxb"}
            GameManager.GotoUI(gotoparm)
        end
    )

    self:RefreshMXB()
end

function C:RefreshMXB(  )
    local cfg = MatchModel.GetRecentlyCFGByType("mxb")
    local is_have = MatchModel.IsTodayHaveMatchByType("mxb")
    --筛选本月的比赛
    if is_have then
        self.MXBWait.gameObject:SetActive(false)
        self.MXBRuning.gameObject:SetActive(true)
        self.Red5.gameObject:SetActive(true)
    else
        self.MXBWait.gameObject:SetActive(true)
        self.MXBRuning.gameObject:SetActive(false)
        self.Red5.gameObject:SetActive(false)
        local y = tonumber(os.date("%m", cfg.start_time))
        local r = tonumber(os.date("%d", cfg.start_time))
        if y and r then
            self.MXBVIPText.text = string.format( "%s月%s日晚上8点开赛",y,r)
        end
    end
end

function C:InitVIPTQ()
    self.TQPanel = self.transform:Find("TQ")
    self.TQButton = self.transform:Find("SVSwitch/Viewport/@switch_content/Button6/Image"):GetComponent("Button")
    self.TQButton2 = self.transform:Find("SVSwitch/Viewport/@switch_content/Button6/Image2")
    self.Red6 = self.transform:Find("SVSwitch/Viewport/@switch_content/Button6/Red")
    self.TQButton.onClick:AddListener(
        function()
            ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
            self:OnClick(6)
        end
    )
    VipShowInfoPanel.Create({tag = "mini", panel = "VipShowInfoMiniPanel",parent = self.TQPanel,callback = function (  )
        self:MyExit()
    end})
end

function C:RefreshVIPTQ()
    
end