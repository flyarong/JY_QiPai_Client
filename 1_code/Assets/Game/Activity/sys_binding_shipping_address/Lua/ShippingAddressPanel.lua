--ganshuangfeng 收货地址
--2018-05-10

local basefunc = require "Game.Common.basefunc"

ShippingAddressPanel = basefunc.class()

ShippingAddressPanel.name = "ShippingAddressPanel"

local instance
function ShippingAddressPanel.Create(parent)
    dump(debug.traceback(),"<color=yellow>堆栈？？？？</color>")
    instance = ShippingAddressPanel.New(parent)
    return instance
end
function ShippingAddressPanel:ctor(parent)

	ExtPanel.ExtMsg(self)

    local obj = newObject(ShippingAddressPanel.name, parent)
    local tran = obj.transform
    self.transform = tran
    self.gameObject = obj
    LuaHelper.GeneratingVar(self.transform, self)

    self.StateDropdown = tran:Find("ImgCenter/TextCity/StateBg/StateDropdown"):GetComponent("Dropdown")
    self.CityDropdown = tran:Find("ImgCenter/TextCity/CityBg/CityDropdown"):GetComponent("Dropdown")
    self.AreaDropdown = tran:Find("ImgCenter/TextCity/AreaBg/AreaDropdown"):GetComponent("Dropdown")

    self.StateDropdownLabel = tran:Find("ImgCenter/TextCity/StateBg/StateDropdown/Label"):GetComponent("Text")
    self.CityDropdownLabel = tran:Find("ImgCenter/TextCity/CityBg/CityDropdown/Label"):GetComponent("Text")
    self.AreaDropdownLabel = tran:Find("ImgCenter/TextCity/AreaBg/AreaDropdown/Label"):GetComponent("Text")

    
    self.name_ipf = self.name_ipf.transform:GetComponent("InputField")
    self.phone_ipf = self.phone_ipf.transform:GetComponent("InputField")
    self.address_ipf = self.address_ipf.transform:GetComponent("InputField")
    self.name_ipf.onValueChanged:AddListener(function (val)
    end)
    self.phone_ipf.onValueChanged:AddListener(function (val)
    end)
    self.address_ipf.onValueChanged:AddListener(function (val)
    end)

    self.StateDropdown.onValueChanged:AddListener(function (val)
        self.indexProvince = val
        self.indexCity = 0
        self.indexArea = 0
        self:UpdateCity()
        self:UpdateArea()
    end)
    self.CityDropdown.onValueChanged:AddListener(function (val)
        self.indexCity = val
        self.indexArea = 0
        self:UpdateArea()
    end)
    self.AreaDropdown.onValueChanged:AddListener(function (val)
        self.indexArea = val
    end)
    self:Init()
end

function ShippingAddressPanel:Init()
    EventTriggerListener.Get(self.close_btn.gameObject).onClick = basefunc.handler(self, self.OnCloseClick)
    EventTriggerListener.Get(self.sure_verifide_btn.gameObject).onClick = basefunc.handler(self, self.OnClickSureVerifide)

    self.indexProvince = 0
    self.indexCity = 0
    self.indexArea = 0
    self:SetDefault()
    self:UpdateProvince()
    self:UpdateCity()
    self:UpdateArea()

    self:InitAddress()
end
function ShippingAddressPanel:SetDefault()
    local province = "四川省"
    local city = "成都市"
    local area = ""
    local list = PersonalInfo.ChinaList
    for k,v in ipairs(list) do
        if province == v.name then
            self.indexProvince = k - 1
            break
        end
    end
    list = PersonalInfo.ChinaList[self.indexProvince + 1].list
    for k,v in ipairs(list) do
        if city == v.name then
            self.indexCity = k - 1
            break
        end
    end
end

function ShippingAddressPanel:UpdateProvince()
    self.StateDropdown:ClearOptions()
    local list = PersonalInfo.ChinaList
    for k,v in ipairs(list) do
        local d = OptionData.New()
        d.text = v.name
        self.StateDropdown:AddOptionData(d)
    end
    self.StateDropdownLabel.text = list[self.indexProvince+1].name
    -- if self.StateDropdown.value == self.indexProvince then
    --     self.StateDropdownLabel.text = list[self.indexProvince+1].name
    -- else
    --     self.StateDropdown.value = self.indexProvince
    -- end
end
function ShippingAddressPanel:UpdateCity()
    self.CityDropdown:ClearOptions()
    local list = PersonalInfo.ChinaList[self.indexProvince + 1].list
    for k,v in ipairs(list) do
        local d = OptionData.New()
        d.text = v.name
        self.CityDropdown:AddOptionData(d)
    end
    self.CityDropdownLabel.text = list[self.indexCity+1].name
    -- if self.CityDropdown.value == self.indexCity then
    --     self.CityDropdownLabel.text = list[self.indexCity+1].name
    -- else
    --     self.CityDropdown.value = self.indexCity
    -- end
end
function ShippingAddressPanel:UpdateArea()
    self.AreaDropdown:ClearOptions()
    local list = PersonalInfo.ChinaList[self.indexProvince + 1].list[self.indexCity + 1].list
    for k,v in ipairs(list) do
        local d = OptionData.New()
        d.text = v.name
        self.AreaDropdown:AddOptionData(d)
    end
    self.AreaDropdownLabel.text = list[self.indexArea+1].name
    -- if self.AreaDropdown.value == self.indexArea then
    --     self.AreaDropdownLabel.text = list[self.indexArea+1].name
    -- else
    --     self.AreaDropdown.value = self.indexArea
    -- end
end

function ShippingAddressPanel:MyExit()
    ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
    destroy(self.gameObject)
end

function ShippingAddressPanel:OnExit()
    self:MyExit()
end

--[[退出收获地址，回到玩家中心]]
function ShippingAddressPanel:OnCloseClick(go)
    self:OnExit()
end

--[[确认绑定]]
function ShippingAddressPanel:OnClickSureVerifide(go)
    ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)

    if not self.name_ipf.text or self.name_ipf.text == "" then
        HintPanel.Create(1, "输入的收件人格式错误")
        return
    end

    local phong_number = self.phone_ipf.text
    if not phong_number or phong_number == "" then
        HintPanel.Create(1, "输入的手机号码格式错误")
        return
    end
    local cnt = string.utf8len(phong_number)
    if cnt ~= 11 then
        HintPanel.Create(1, "输入的手机号码格式错误")
        return
    end

    if not self.address_ipf.text or self.address_ipf.text == "" then
        HintPanel.Create(1, "输入的详细地址格式错误")
        return
    end

    self:update_shipping_address()
end

--[[修改收货地址]]
function ShippingAddressPanel:update_shipping_address()
    local update_shipping_address = {}
    update_shipping_address.name = self.name_txt.text
    update_shipping_address.phone_number = self.phone_txt.text
    local val = self.StateDropdownLabel.text .. "#" .. self.CityDropdownLabel.text .. "#" .. self.AreaDropdownLabel.text .. "#" .. self.address_txt.text
    update_shipping_address.address = val
    local function send_callback(data)
        if data.result == 0 then
            if MainModel.UserInfo.shipping_address == nil then
                MainModel.UserInfo.shipping_address = {}
            end
            MainModel.UserInfo.shipping_address.name = update_shipping_address.name
            MainModel.UserInfo.shipping_address.phone_number = update_shipping_address.phone_number
            MainModel.UserInfo.shipping_address.address = update_shipping_address.address

            Event.Brocast("update_shipping_address")
            GameObject.Destroy(self.gameObject)
        else
            logWarn("修改收货地址失败" .. data.result)
        end
    end
    Network.SendRequest("update_shipping_address", update_shipping_address, "发送请求", send_callback)
end

function ShippingAddressPanel:InitAddress()
    local shipping_address = MainModel.UserInfo.shipping_address

    if shipping_address ~= nil then
        self.name_ipf.text = shipping_address.name
        self.phone_ipf.text = shipping_address.phone_number
        local val = MainModel.GetAddress()
        self.address_ipf.text = val[4]

        local list = PersonalInfo.ChinaList
        for k,v in ipairs(list) do
            if v.name == val[1] then
                self.indexProvince = k - 1
                break
            end
        end
        list = PersonalInfo.ChinaList[self.indexProvince + 1].list
        for k,v in ipairs(list) do
            if v.name == val[2] then
                self.indexCity = k - 1
                break
            end
        end
        list = PersonalInfo.ChinaList[self.indexProvince + 1].list[self.indexCity + 1].list
        for k,v in ipairs(list) do
            if v.name == val[3] then
                self.indexArea = k - 1
                break
            end
        end
        self:UpdateProvince()
        self:UpdateCity()
        self:UpdateArea()
    else
        print("<color=red>空的收货地址</color>")
    end
end