-- 创建时间:2019-12-28
-- Panel:VipShowMZFLPanel
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

VipShowMZFLPanel = basefunc.class()
local C = VipShowMZFLPanel
C.name = "VipShowMZFLPanel"
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

function C:OnDestroy()
	self:MyExit()
end

function C:ctor(parent)

	ExtPanel.ExtMsg(self)

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
	self:OnTask()
end

function C:OnTask()
	local data = VIPManager.get_vip_task()
    if data and IsEquals(self.gameObject)  then
        local WeeKdata = {}
        for i=1, 2 do
            WeeKdata[21015 + i] = data[21015 + i]
        end
        WeeKdata[21314] = data[21314]
        self:DoVIPMZFL(WeeKdata)
    end
end

function C:OnReFreshInfo()
	local data = VIPManager.get_vip_task()
    if data and IsEquals(self.gameObject)  then
        local WeeKdata = {}
        for i=1, 2 do
            WeeKdata[21015 + i] = data[21015 + i]
        end
        WeeKdata[21314] = data[21314]
        self:RefreshVIPMZFL(WeeKdata)
    end
end


function C:InitUI()
	self.VIPMZFLChild = self.transform:Find("VIPMZFLChild")
	self.VIPMZFLPanel = self.transform:Find("VIPMZFLPanel")
    self.VIPMZFLCText = self.VIPMZFLPanel.transform:Find("CText"):GetComponent("Text")
    self.VIPMZFLHelpButton = self.VIPMZFLPanel.transform:Find("Help"):GetComponent("Button")
    self.VIPMZFLContent = self.VIPMZFLPanel:Find("Scroll View/Viewport/Content")
    self.VIPMZFLHelpPanel = self.transform:Find("VIPMZFLHelpPanel")
    self.VIPMZFLHelpPanelButton = self.VIPMZFLHelpPanel:Find("Button"):GetComponent("Button")
    self.VIPMZFLHelpPanelClose = self.VIPMZFLHelpPanel:Find("CloseButton"):GetComponent("Button")
	self.VIPMZFLHelp = self.VIPMZFLPanel.transform:Find("Help"):GetComponent("Button")
    self.AwardChild = self.transform:Find("AwardChild")
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
    Event.Brocast("vip_show_mzfl_panel_create", self)
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
                local n_text = n.transform:Find("Text"):GetComponent("Text")
                n_text.text = config.vipmzfl[i].text[j]
                n_text.resizeTextForBestFit = true
                n_text.resizeTextMinSize = 16
                n_text.resizeTextMaxSize = 26
                if config.vipmzfl[i].image[j] == "zpg_icon_yg" then
                    PointerEventListener.Get(n.transform:Find("Image").gameObject).onDown = function ()
                        GameTipsPrefab.ShowDesc("可在小游戏苹果大战中使用", UnityEngine.Input.mousePosition)
                    end
                    PointerEventListener.Get(n.transform:Find("Image").gameObject).onUp = function ()
                        GameTipsPrefab.Hide()
                    end
                end
            end
        else
            local n = GameObject.Instantiate(self.AwardChild, content)
            n.gameObject:SetActive(true)
            n.transform:Find("Image"):GetComponent("Image").sprite = GetTexture(config.vipmzfl[i].image)
            n.transform:Find("Text"):GetComponent("Text").text = config.vipmzfl[i].text
        end
        m.transform:Find("GOButton").gameObject:SetActive(false)
        m.transform:Find("LQButton").gameObject:SetActive(true)
        m.transform:Find("MASK").gameObject:SetActive(false)
        m.transform:Find("GOButton"):GetComponent("Button").onClick:AddListener(
            function ()
                PayPanel.Create(GOODS_TYPE.jing_bi, "normal")
            end
        )
        m.transform:Find("LQButton"):GetComponent("Button").onClick:AddListener(
            function ()
                -- local task_id = 21015 + i
                -- if not data or not data[task_id] or data[task_id].award_status == 0 then
                --     if task_id == 21016 then
                --         HintPanel.Create(1, "成为VIP3即可领取更丰厚的每周福利！", function ()
                --             PayPanel.Create(GOODS_TYPE.jing_bi, "normal")
                --             Event.Brocast("TRY_VIP_SHOW_TASK_COLSE")
                --         end)
                --     else
                --         HintPanel.Create(1, "成为VIP6即可领取更丰厚的每周福利！", function ()
                --             PayPanel.Create(GOODS_TYPE.jing_bi, "normal")
                --             Event.Brocast("TRY_VIP_SHOW_TASK_COLSE")
                --         end)
                --     end
                -- else
                --     if os.date("%w", os.time()) == "0"  then
                --         Network.SendRequest("get_task_award_new", { id = task_id, award_progress_lv = 1 })
                --     else
                --         HintPanel.Create(1,"请在周日的0点到24点期间领取奖励！")
                --     end 
                -- end
                if i == 1 then
                    if not data or not data[21314] or data[21314].award_status == 0 then
                        HintPanel.Create(1, "成为VIP2即可领取更丰厚的每周福利！", function ()
                            PayPanel.Create(GOODS_TYPE.jing_bi, "normal")
                            Event.Brocast("TRY_VIP_SHOW_TASK_COLSE")
                        end)
                    else
                        if os.date("%w", os.time()) == "0"  then
                            Network.SendRequest("get_task_award_new", { id = 21314, award_progress_lv = 1 })
                        else
                            HintPanel.Create(1,"请在周日的0点到24点期间领取奖励！")
                        end 
                    end 
                elseif i == 2 then
                    if not data or not data[21016] or data[21016].award_status == 0 then
                        HintPanel.Create(1, "成为VIP3即可领取更丰厚的每周福利！", function ()
                            PayPanel.Create(GOODS_TYPE.jing_bi, "normal")
                            Event.Brocast("TRY_VIP_SHOW_TASK_COLSE")
                        end)
                    else
                        if os.date("%w", os.time()) == "0"  then
                            Network.SendRequest("get_task_award_new", { id = 21016, award_progress_lv = 1 })
                        else
                            HintPanel.Create(1,"请在周日的0点到24点期间领取奖励！")
                        end 
                    end 
                elseif i == 3 then
                    if not data or not data[21017] or data[21017].award_status == 0 then
                        HintPanel.Create(1, "成为VIP6即可领取更丰厚的每周福利！", function ()
                            PayPanel.Create(GOODS_TYPE.jing_bi, "normal")
                            Event.Brocast("TRY_VIP_SHOW_TASK_COLSE")
                        end)
                    else
                        if os.date("%w", os.time()) == "0"  then
                            Network.SendRequest("get_task_award_new", { id = 21017, award_progress_lv = 1 })
                        else
                            HintPanel.Create(1,"请在周日的0点到24点期间领取奖励！")
                        end 
                    end 
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
    local vd = VIPManager.get_vip_data()
    if data then 
        if data[21016] then 
            if data[21016].award_status == 0 then 
                self.VIPMZFLChilds[2].transform:Find("GOButton").gameObject:SetActive(false)
                self.VIPMZFLChilds[2].transform:Find("LQButton").gameObject:SetActive(true)
                self.VIPMZFLChilds[2].transform:Find("MASK").gameObject:SetActive(false)
            elseif data[21016].award_status == 1 then 
                self.VIPMZFLChilds[2].transform:Find("LQButton").gameObject:SetActive(true)
                self.VIPMZFLChilds[2].transform:Find("GOButton").gameObject:SetActive(false)
                self.VIPMZFLChilds[2].transform:Find("MASK").gameObject:SetActive(false)
            elseif data[21016].award_status == 2 then
                self.VIPMZFLChilds[2].transform:Find("MASK").gameObject:SetActive(true)
                self.VIPMZFLChilds[2].transform:Find("GOButton").gameObject:SetActive(false)
                self.VIPMZFLChilds[2].transform:Find("LQButton").gameObject:SetActive(false)
                self.VIPMZFLChilds[2]:SetSiblingIndex(3)
            end 
        end 
        if data[21017] then 
            if data[21017].award_status == 0 then 
                self.VIPMZFLChilds[1].transform:Find("GOButton").gameObject:SetActive(false)
                self.VIPMZFLChilds[1].transform:Find("LQButton").gameObject:SetActive(true)
                self.VIPMZFLChilds[1].transform:Find("MASK").gameObject:SetActive(false)
            elseif data[21017].award_status == 1 then 
                self.VIPMZFLChilds[1].transform:Find("LQButton").gameObject:SetActive(true)
                self.VIPMZFLChilds[1].transform:Find("GOButton").gameObject:SetActive(false)
                self.VIPMZFLChilds[1].transform:Find("MASK").gameObject:SetActive(false)
            elseif data[21017].award_status == 2 then
                self.VIPMZFLChilds[1].transform:Find("MASK").gameObject:SetActive(true)
                self.VIPMZFLChilds[1].transform:Find("GOButton").gameObject:SetActive(false)
                self.VIPMZFLChilds[1].transform:Find("LQButton").gameObject:SetActive(false)
                self.VIPMZFLChilds[1]:SetSiblingIndex(3)
            end 
        end 
        if data[21314] then 
            if data[21314].award_status == 0 then 
                self.VIPMZFLChilds[1].transform:Find("GOButton").gameObject:SetActive(false)
                self.VIPMZFLChilds[1].transform:Find("LQButton").gameObject:SetActive(true)
                self.VIPMZFLChilds[1].transform:Find("MASK").gameObject:SetActive(false)
            elseif data[21314].award_status == 1 then 
                self.VIPMZFLChilds[1].transform:Find("LQButton").gameObject:SetActive(true)
                self.VIPMZFLChilds[1].transform:Find("GOButton").gameObject:SetActive(false)
                self.VIPMZFLChilds[1].transform:Find("MASK").gameObject:SetActive(false)
            elseif data[21314].award_status == 2 then
                self.VIPMZFLChilds[1].transform:Find("MASK").gameObject:SetActive(true)
                self.VIPMZFLChilds[1].transform:Find("GOButton").gameObject:SetActive(false)
                self.VIPMZFLChilds[1].transform:Find("LQButton").gameObject:SetActive(false)
                self.VIPMZFLChilds[1]:SetSiblingIndex(3)
            end 
        elseif vd and vd.vip_level >= 2 then 
            self.VIPMZFLChilds[1].gameObject:SetActive(false)
        end 
    end
    if vd and vd.vip_level >= 6 then
        self.VIPMZFLChilds[2].gameObject:SetActive(false)
    end 
    if vd and vd.vip_level > 2 then
        self.VIPMZFLChilds[1].gameObject:SetActive(false)
	end 
	self.VIPMZFLCText.text =  vd and vd.vip_level or 0
end
