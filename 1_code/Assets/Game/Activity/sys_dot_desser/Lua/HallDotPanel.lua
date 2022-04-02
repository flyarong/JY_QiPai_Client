-- 创建时间:2018-11-08

local basefunc = require "Game.Common.basefunc"

HallDotPanel = basefunc.class()

HallDotPanel.name = "HallDotPanel"

local ddz_need_change = false
local mj_need_change = false

local instance
function HallDotPanel.Create(parent)
	instance = HallDotPanel.New(parent)
	return instance
end

function HallDotPanel:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function HallDotPanel:MakeLister()
    self.lister = {}
end

function HallDotPanel:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function HallDotPanel:MyClose()
    self:MyExit()
    instance = nil
end

function HallDotPanel:MyExit()
    self:RemoveListener()
    if self.update_timer then
        self.update_timer:Stop()
        self.update_timer = nil
    end
    destroy(self.gameObject)
end

function HallDotPanel:ctor(parent)

	ExtPanel.ExtMsg(self)

    self.game_honor_config = GameHonorModel.GetHonorDataByID()
    self.game_cur_ddz_honor_data = GameHonorModel.GetCurHonorData(GameHonorModel.HonorType.ddz)
    self.game_cur_mj_honor_data = GameHonorModel.GetCurHonorData(GameHonorModel.HonorType.mj)
	local obj = newObject(HallDotPanel.name, parent)
    local tran = obj.transform
    self.parent = parent
	self.transform = tran
	self.gameObject = obj
    LuaHelper.GeneratingVar(self.transform,self)

	self:MakeLister()
	self:AddMsgListener()

    self:InitUI()
    self:MyUpdate()
end
function HallDotPanel:InitUI()
    self.rule_btn.onClick:AddListener(
        function()
            ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
            HallDotRulePanel.Create(self.transform,self.honor_type)
        end
    )

    self.ddz_honor_tge.onValueChanged:AddListener(
        function(val)
            ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
            self.ddz_mark_label.gameObject:SetActive(val)
            self.ddz_label.gameObject:SetActive(not val)
            if val then
                self.honor_type = GameHonorModel.HonorType.ddz
                self.ddz_honor.gameObject:SetActive(true)
                self.mj_honor.gameObject:SetActive(false)
                self:UpdateDDZUI()
            end
        end
    )

    self.mj_honor_tge.onValueChanged:AddListener(
        function(val)
            ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
            self.mj_mark_label.gameObject:SetActive(val)
            self.mj_label.gameObject:SetActive(not val)
            if val then
                self.honor_type = GameHonorModel.HonorType.mj
                self.ddz_honor.gameObject:SetActive(false)
                self.mj_honor.gameObject:SetActive(true)
                self:UpdateMJUI()
            end
        end
    )

    self:InitDDZHonor()
    self:InitMJHonor()
    self.ddz_honor_tge.isOn = true
end

function HallDotPanel:MyRefresh()
end

function HallDotPanel.ChangeTge(type)
    if instance then
        if type == GameHonorModel.HonorType.ddz then
            instance.ddz_honor_tge.isOn = true
        elseif type == GameHonorModel.HonorType.mj then
            instance.mj_honor_tge.isOn = true
        end
    end
end

function HallDotPanel:MyUpdate()
    self.update_timer = Timer.New(function ()
        for k,v in pairs(self.DDZLevelItem) do
            if v.icon_img.transform.position.x <= 400 or v.icon_img.transform.position.x >= -400 then
                local OffsetY = v.icon_img.transform.position.x - 0
                OffsetY = math.abs(OffsetY)
                local type_lerp = Mathf.Lerp(1, 0.64, OffsetY / 400)
                v.icon_img_rt.sizeDelta = {x = self.sizeDelta.x * type_lerp , y = self.sizeDelta.y * type_lerp}
            end
        end

        if ddz_need_change then
            if math.abs(self.DDZHonorLevelSV.velocity.x) <= 50 then
                self.ddz_cur_id = self:GetDDZItemMaxSizeID()
                self:UpdateDDZUI()
                self:SetCurDDZHonorItemToGenter(self.ddz_cur_id)
                ddz_need_change = false
            end
        end


        for k,v in pairs(self.MJLevelItem) do
            if v.icon_img.transform.position.x <= 400 or v.icon_img.transform.position.x >= -400 then
                local OffsetY = v.icon_img.transform.position.x - 0
                OffsetY = math.abs(OffsetY)
                local type_lerp = Mathf.Lerp(1, 0.64, OffsetY / 400)
                v.icon_img_rt.sizeDelta = {x = self.sizeDelta.x * type_lerp , y = self.sizeDelta.y * type_lerp}
            end
        end

        if mj_need_change then
            if math.abs(self.MJHonorLevelSV.velocity.x) <= 50 then
                self.mj_cur_id = self:GetMJItemMaxSizeID()
                self:UpdateMJUI()
                self:SetCurMJHonorItemToGenter(self.mj_cur_id)
                mj_need_change = false
            end
        end

    end,0.02,-1)

    self.update_timer:Start()
end

function HallDotPanel:OnDDZBeginDrag()
    print("<color=yellow>OnBeginDrag</color>")
end

function HallDotPanel:OnDDZDrag()

end

function HallDotPanel:OnDDZEndDrag()
    print("<color=yellow>OnEndDrag</color>")
    ddz_need_change = true
end

function HallDotPanel:InitDDZHonor()
    self.ddz_left_btn.onClick:AddListener(
        function()
            ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
            self.ddz_cur_id = self.ddz_cur_id - 1
            if self.ddz_cur_id < 1 then
                self.ddz_cur_id = 1
            else
                self:UpdateDDZUI()
                self:SetCurDDZHonorItemToGenter(self.ddz_cur_id)
            end
        end
    )

    self.ddz_right_btn.onClick:AddListener(
        function()
            ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
            self.ddz_cur_id = self.ddz_cur_id + 1
            if self.ddz_cur_id > #self.game_honor_config then
                self.ddz_cur_id = #self.game_honor_config
            else
                self:UpdateDDZUI()
                self:SetCurDDZHonorItemToGenter(self.ddz_cur_id)
            end
        end
    )

    self.DDZHonorLevelSV = self.ddz_honor.transform:Find("DDZHonorLevelSV"):GetComponent("ScrollRect")
    EventTriggerListener.Get(self.DDZHonorLevelSV.gameObject).onEndDrag = basefunc.handler(self, self.OnDDZEndDrag)
    EventTriggerListener.Get(self.DDZHonorLevelSV.gameObject).onDrag = basefunc.handler(self, self.OnDDZDrag)
    EventTriggerListener.Get(self.DDZHonorLevelSV.gameObject).onBeginDrag = basefunc.handler(self, self.OnDDZBeginDrag)

    for i,v in ipairs(self.game_honor_config) do
        self:SetDDZHonorLevelItem(v)
    end
    self.ddz_cur_id = self.game_cur_ddz_honor_data.id

    self:UpdateDDZUI()
    self:SetCurDDZHonorItemToGenter(self.ddz_cur_id)

    self:InitDDZSilder()
end

function HallDotPanel:InitDDZSilder()
    local slider = self.ddz_slider.transform:GetComponent("Slider")
    local cur_honor_value = GameHonorModel.GetCurHonorValue(GameHonorModel.HonorType.ddz)
    local max_val = self.game_cur_ddz_honor_data.max_val
    if max_val > 0 then
        local process = cur_honor_value / max_val
        if process > 1 then
            process = 1
        end
        slider.value = process == 0 and 0 or 0.95 * process + 0.05
        self.ddz_slider_txt.text = cur_honor_value .. "/" .. max_val
    else
        slider.value = 1
        self.ddz_slider_txt.text = cur_honor_value
    end
end

function HallDotPanel:SetCurDDZHonorItemToGenter(cur_id)
    local cur_item = self.DDZLevelItem[cur_id]
    local move_dis = self.DDZLevelPosTable[cur_id] -- cur_item.transform.position.x - self.ddz_honor_content.parent.transform.position.x
    local seq = DG.Tweening.DOTween.Sequence()
    local tweenKey = DOTweenManager.AddTweenToStop(seq)
    seq:Append(self.ddz_honor_content.transform:DOLocalMoveX(move_dis,0.2))
    seq:OnComplete(
        function()
            self.ddz_honor_content.transform.localPosition = Vector2.New(move_dis,0)
        end
    )
    seq:OnKill(
        function()
            DOTweenManager.RemoveStopTween(tweenKey)
            self.ddz_honor_content.transform.localPosition = Vector2.New(move_dis,0)
        end
    )
end
    
function HallDotPanel:SetDDZHonorLevelItem(data)
    self.DDZLevelItem = self.DDZLevelItem or {}
    self.DDZLevelPosTable = self.DDZLevelPosTable or {}
    local item = newObject("HonorLevelItem",self.ddz_honor_content)
    local item_table = {}
    item_table.transform = item.transform
    item_table.rect_transform = item.transform:GetComponent("RectTransform")
    LuaHelper.GeneratingVar(item.transform,item_table)
    item_table.icon_img_rt =item_table.icon_img:GetComponent("RectTransform")
    item_table.icon_btn = item_table.icon_img:GetComponent("Button")
    self.DDZLevelItem[data.id] = item_table
    self.DDZLevelPosTable[data.id] =  -(data.id - 1) * item_table.rect_transform.sizeDelta.x
    if data then
        item_table.icon_img.sprite = GetTexture(data.ddz_level_icon)
        item_table.icon_img:SetNativeSize()
        self.sizeDelta = item_table.icon_img_rt.sizeDelta
        item_table.name_txt.text = data.ddz_name .. (data.level_name_num and data.level_name_num or "")
    end
    item_table.icon_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        self.ddz_cur_id = data.id
        self:UpdateDDZUI()
        self:SetCurDDZHonorItemToGenter(self.ddz_cur_id)
    end)
end

function HallDotPanel:UpdateDDZUI()
    self:UpdateDDZAward()
    self:UpdateDDZSilder()
end

function HallDotPanel:GetDDZItemMaxSizeID()
    local max_size = 0
    local max_id = 0
    local size = 0
    local target_posX = self.ddz_honor_content.parent.position.x
    for i,v in ipairs(self.DDZLevelItem) do
        size = v.icon_img_rt.sizeDelta.x
        if math.abs(size) > math.abs(max_size) then
            max_size = size
            max_id = i
        end
    end
    return max_id
end

function HallDotPanel:UpdateDDZAward()
    destroyChildren(self.ddz_award_content)
    local cur_awards_config = GameHonorModel.GetHonorDataByID(self.ddz_cur_id)
    if cur_awards_config.item_key then
        for i,v in ipairs(cur_awards_config.item_key) do
            local item = newObject("HonorGetAwardItem",self.ddz_award_content)
            local item_table =  {}
            LuaHelper.GeneratingVar(item.transform,item_table)
            item_table.award_img.sprite = GetTexture(item_desc_config[v].image)
            item_table.award_img:SetNativeSize()
            item_table.award_txt.text = item_desc_config[v].name .. "x" .. cur_awards_config.item_val[i]
            local is_geted = cur_awards_config.max_val < self.game_cur_ddz_honor_data.max_val
            item_table.yhd_img.gameObject:SetActive(is_geted)
    
            EventTriggerListener.Get(item_table.award_img.gameObject).onDown = function()
                local key = v
                local pos = UnityEngine.Input.mousePosition
                local tips = cur_awards_config.item_tips[i]
                GameTipsPrefab.Show(key, pos,tips)
            end
            EventTriggerListener.Get(item_table.award_img.gameObject).onUp = function()
                GameTipsPrefab.Hide()
            end
        end
    end
end

function HallDotPanel:UpdateDDZSilder()
    if self.game_cur_ddz_honor_data.id == self.ddz_cur_id then
        self.ddz_slider.gameObject:SetActive(true)
    else
        self.ddz_slider.gameObject:SetActive(false)
    end
end

--麻将
function HallDotPanel:OnMJBeginDrag()
    print("<color=yellow>OnBeginDrag</color>")
end

function HallDotPanel:OnMJDrag()

end

function HallDotPanel:OnMJEndDrag()
    print("<color=yellow>OnEndDrag</color>")
    mj_need_change = true
end

function HallDotPanel:InitMJHonor()
    self.mj_left_btn.onClick:AddListener(
        function()
            ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
            self.mj_cur_id = self.mj_cur_id - 1
            if self.mj_cur_id < 1 then
                self.mj_cur_id = 1
            else
                self:UpdateMJUI()
                self:SetCurMJHonorItemToGenter(self.mj_cur_id)
            end
        end
    )

    self.mj_right_btn.onClick:AddListener(
        function()
            ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
            self.mj_cur_id = self.mj_cur_id + 1
            if self.mj_cur_id > #self.game_honor_config then
                self.mj_cur_id = #self.game_honor_config
            else
                self:UpdateMJUI()
                self:SetCurMJHonorItemToGenter(self.mj_cur_id)
            end
        end
    )

    self.MJHonorLevelSV = self.mj_honor.transform:Find("MJHonorLevelSV"):GetComponent("ScrollRect")
    EventTriggerListener.Get(self.MJHonorLevelSV.gameObject).onEndDrag = basefunc.handler(self, self.OnMJEndDrag)
    EventTriggerListener.Get(self.MJHonorLevelSV.gameObject).onDrag = basefunc.handler(self, self.OnMJDrag)
    EventTriggerListener.Get(self.MJHonorLevelSV.gameObject).onBeginDrag = basefunc.handler(self, self.OnMJBeginDrag)

    for i,v in ipairs(self.game_honor_config) do
        self:SetMJHonorLevelItem(v)
    end
    self.mj_cur_id = self.game_cur_mj_honor_data.id

    self:UpdateMJUI()
    self:SetCurMJHonorItemToGenter(self.mj_cur_id)

    self:InitMJSilder()
end

function HallDotPanel:InitMJSilder()
    local slider = self.mj_slider.transform:GetComponent("Slider")
    local cur_honor_value = GameHonorModel.GetCurHonorValue(GameHonorModel.HonorType.mj)

    local max_val = self.game_cur_mj_honor_data.max_val
    if max_val > 0 then
        local process = cur_honor_value / max_val
        if process > 1 then
            process = 1
        end
        slider.value = process == 0 and 0 or 0.95 * process + 0.05
        self.mj_slider_txt.text = cur_honor_value .. "/" .. max_val
    else
        slider.value = 1
        self.mj_slider_txt.text = cur_honor_value .. ""
    end
end

function HallDotPanel:SetCurMJHonorItemToGenter(cur_id)
    local cur_item = self.MJLevelItem[cur_id]
    local move_dis = self.MJLevelPosTable[cur_id] -- cur_item.transform.position.x - self.mj_honor_content.parent.transform.position.x
    local seq = DG.Tweening.DOTween.Sequence()
    local tweenKey = DOTweenManager.AddTweenToStop(seq)
    seq:Append(self.mj_honor_content.transform:DOLocalMoveX(move_dis,0.2))
    seq:OnComplete(
        function()
            self.mj_honor_content.transform.localPosition = Vector2.New(move_dis,0)
        end
    )
    seq:OnKill(
        function()
            DOTweenManager.RemoveStopTween(tweenKey)
            self.mj_honor_content.transform.localPosition = Vector2.New(move_dis,0)
        end
    )
end
    
function HallDotPanel:SetMJHonorLevelItem(data)
    self.MJLevelItem = self.MJLevelItem or {}
    self.MJLevelPosTable = self.MJLevelPosTable or {}
    local item = newObject("HonorLevelItem",self.mj_honor_content)
    local item_table = {}
    item_table.transform = item.transform
    item_table.rect_transform = item.transform:GetComponent("RectTransform")
    LuaHelper.GeneratingVar(item.transform,item_table)
    item_table.icon_img_rt =item_table.icon_img:GetComponent("RectTransform")
    item_table.icon_btn =item_table.icon_img:GetComponent("Button")
    self.MJLevelItem[data.id] = item_table
    self.MJLevelPosTable[data.id] =  -(data.id - 1) * item_table.rect_transform.sizeDelta.x
    if data then
        item_table.icon_img.sprite = GetTexture(data.mj_level_icon)
        item_table.icon_img:SetNativeSize()
        self.sizeDelta = item_table.icon_img_rt.sizeDelta
        item_table.name_txt.text = data.mj_name .. (data.level_name_num and data.level_name_num or "")
    end

    item_table.icon_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        self.mj_cur_id = data.id
        self:UpdateMJUI()
        self:SetCurMJHonorItemToGenter(self.mj_cur_id)
    end)
end

function HallDotPanel:UpdateMJUI()
    self:UpdateMJAward()
    self:UpdateMJSilder()
end

function HallDotPanel:GetMJItemMaxSizeID()
    local max_size = 0
    local max_id = 0
    local size = 0
    local target_posX = self.mj_honor_content.parent.position.x
    for i,v in ipairs(self.MJLevelItem) do
        size = v.icon_img_rt.sizeDelta.x
        if math.abs(size) > math.abs(max_size) then
            max_size = size
            max_id = i
        end
    end
    return max_id
end

function HallDotPanel:UpdateMJAward()
    destroyChildren(self.mj_award_content)
    local cur_awards_config = GameHonorModel.GetHonorDataByID(self.mj_cur_id)
    if cur_awards_config.item_key then
        for i,v in ipairs(cur_awards_config.item_key) do
            local item = newObject("HonorGetAwardItem",self.mj_award_content)
            local item_table =  {}
            LuaHelper.GeneratingVar(item.transform,item_table)
            item_table.award_img.sprite = GetTexture(item_desc_config[v].image)
            item_table.award_img:SetNativeSize()
            item_table.award_txt.text = item_desc_config[v].name .. "x" .. cur_awards_config.item_val[i]
            local is_geted = cur_awards_config.max_val < self.game_cur_mj_honor_data.max_val
            item_table.yhd_img.gameObject:SetActive(is_geted)
    
            EventTriggerListener.Get(item_table.award_img.gameObject).onDown = function()
                local key = v
                local pos = UnityEngine.Input.mousePosition
                GameTipsPrefab.Show(key, pos)
            end
            EventTriggerListener.Get(item_table.award_img.gameObject).onUp = function()
                GameTipsPrefab.Hide()
            end
        end
    end
end

function HallDotPanel:UpdateMJSilder()
    if self.game_cur_mj_honor_data.id == self.mj_cur_id then
        self.mj_slider.gameObject:SetActive(true)
    else
        self.mj_slider.gameObject:SetActive(false)
    end
end