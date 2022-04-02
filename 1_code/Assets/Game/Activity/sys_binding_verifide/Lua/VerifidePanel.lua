--ganshuangfeng 实名认证
--2018-05-09

local basefunc = require "Game.Common.basefunc"

VerifidePanel = basefunc.class()

VerifidePanel.name = "VerifidePanel"
local M = SysBinddingVerifideManager
local instance
function VerifidePanel.Create(backcall)
    instance = VerifidePanel.New(backcall)
    return instance
end

function VerifidePanel:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function VerifidePanel:MakeLister()
    self.lister = {}
    self.lister["exit_verifide_panel_msg"] = basefunc.handler(self, self.MyExit)
end

function VerifidePanel:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function VerifidePanel:ctor(backcall)

	ExtPanel.ExtMsg(self)

    local parent = GameObject.Find("Canvas/LayerLv5").transform
    local obj = newObject(VerifidePanel.name, parent)
    local tran = obj.transform
    self.transform = tran
    self.gameObject = obj
    LuaHelper.GeneratingVar(self.transform, self)

    self:MakeLister()
    self:AddMsgListener()

    self.name_ipf = self.name_ipf.transform:GetComponent("InputField")
    self.id_number_ipf = self.id_number_ipf.transform:GetComponent("InputField")
    self.name_ipf.onValueChanged:AddListener(function (val)
    end)
    self.id_number_ipf.onValueChanged:AddListener(function (val)
    end)

    self.name_ipf.characterLimit = 20

    EventTriggerListener.Get(self.close_btn.gameObject).onClick = basefunc.handler(self, self.OnCloseClick)
    EventTriggerListener.Get(self.sure_verifide_btn.gameObject).onClick = basefunc.handler(self, self.OnClickSureVerifide)
    self.backcall = backcall


    self.info1Txt = self.transform:Find("ImgCenter/Text_info/Text_info1"):GetComponent("Text")
    self.info1Txt.text = "*依据国家新闻出版署《关于未成年人防沉迷网络游戏通知》为保证您的个人权益，请使用有效身份证件进行实名认证。"
    self.info2Txt = self.transform:Find("ImgCenter/Text_info/Text_info2"):GetComponent("Text")
    self.info2Txt.text = "*实名认证<color=#FFF226>仅用于国家防沉迷认证，游戏内容提供方无法获得您的详细信息</color>。成功进行实名认证后<color=#FFF226>可领取实名认证大礼包。</color>"
    HandleLoadChannelLua("VerifidePanel", self)

    self.close_btn.gameObject:SetActive(false)

    self.gameObject:SetActive(false)
    MainModel.GetVerifyStatus(function ()
        if not MainModel.UserInfo.verifyData or M.IsVerify() then
            self:MyExit()
        else
        self.gameObject:SetActive(true)
            self:InitUI()
        end
    end)
end

function VerifidePanel:InitUI()
    Event.Brocast("global_game_panel_open_msg", {ui="VerifidePanel"})
    self:RefreshStatus()
    local award
    award = self.transform:Find("ImgCenter/Image/Image (1)/Text"):GetComponent("Text")
    award.text = "鲸币*1000"
    award = self.transform:Find("ImgCenter/Image/Image (2)/Text"):GetComponent("Text")
    award.text = "鱼币*1000"    
    award = self.transform:Find("ImgCenter/Image/Image (3)/Text"):GetComponent("Text")
    award.text = "记牌器*1"

    -- 隐藏鱼币
    self.transform:Find("ImgCenter/Image/Image (1)").localPosition = Vector3.New(-146, -10, 0)
    self.transform:Find("ImgCenter/Image/Image (2)").gameObject:SetActive(false)
    self.transform:Find("ImgCenter/Image/Image (3)").localPosition = Vector3.New(146, -10, 0)
end

--[[退出实名认证，到个人中心]]
function VerifidePanel:OnCloseClick(go)
    ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
    self:CallCloseClick()
end

function VerifidePanel:MyExit()
    self:RemoveListener()
    
    Event.Brocast("global_game_panel_close_msg", {ui="VerifidePanel"})
    if self.backcall then
        self.backcall()
    end
    destroy(self.gameObject)
end
function VerifidePanel:CallCloseClick()
    self:MyExit()
end

--[[确认绑定]]
function VerifidePanel:OnClickSureVerifide(go)
    local id_number = self.id_number_ipf.text
    local cnt = string.utf8len(id_number)
    local name = self.name_txt.text
    if  #name < 2 then
        HintPanel.Create(1, "名字长度不正确")
        return
    end
    if not name or name == "" then
        HintPanel.Create(1, "名字不能为空")
        return
    end
    -- local ss = StringHelper.filter_spec_chars(name)
    -- if ss ~= name then
    --     HintPanel.Create(1, "名字不能有特殊字符")
    --     return
    -- end

    if cnt ~= 18 then
        --输入的身份证号不是18位
        HintPanel.Create(1, "输入的身份证号不是18位")
        return
    elseif not verifyIDCard(id_number) then
        --输入的身份证格式不正确
        HintPanel.Create(1, "输入的身份证格式不正确")
        return
    else

    end

    self:proceed_real_name_authentication()
end

function VerifidePanel:view_sure_verifide_btn(isActive)
    self.sure_verifide_btn.interactable = isActive
end

function VerifidePanel:RefreshStatus()
    self.status_txt.text = M.status_code[MainModel.UserInfo.verifyData.status]
    self.verifide_gray.gameObject:SetActive(MainModel.UserInfo.verifyData.status == 2)

    if MainModel.UserInfo.verifyData.status == 3 then
        self.verifide_btn_txt.text = "重新认证"
    else
        self.verifide_btn_txt.text = "提交认证"
    end
end

function VerifidePanel:proceed_real_name_authentication()
    local proceed_real_name_authentication = {}
    proceed_real_name_authentication.name = self.name_txt.text
    proceed_real_name_authentication.identity_number = self.id_number_txt.text
    Network.SendRequest("proceed_real_name_authentication", proceed_real_name_authentication, "请求实名认证", function (data)
        --dump(data, "<color=red>+++++进行实名proceed_real_name_authentication++++</color>")
        if data.result == 0 then
            LittleTips.Create("提交成功")
            MainModel.UserInfo.verifyData = {}
            -- MainModel.UserInfo.verifyData.identity_number = data.identity_number
            -- MainModel.UserInfo.verifyData.name = data.name
            MainModel.SetVerifyStatus(data.status)
            Event.Brocast("update_verifide")
            self:RefreshStatus()
            self:CallCloseClick()
        else
            HintPanel.ErrorMsg(data.result)
        end
    end)
end
