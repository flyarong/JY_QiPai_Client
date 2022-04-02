-- 创建时间:2018-12-11

local basefunc = require "Game.Common.basefunc"

BagItem = basefunc.class()

local C = BagItem

C.name = "BagItem"

function C.Create(parent_transform, config, call, panelSelf)
	return C.New(parent_transform, config, call, panelSelf)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:ctor(parent_transform, config, call, panelSelf)
	self.config = config
	self.call = call
	self.panelSelf = panelSelf
	local obj = newObject(C.name, parent_transform)
	self.gameObject = obj
	self.transform = obj.transform
	self:MakeLister()
    self:AddMsgListener()

    LuaHelper.GeneratingVar(obj.transform, self)

   
    self.type_txt.text = self.config.name
    local date = ""
    if self.config.date then
        if self.config.date >= 24 then
            if self.config.date >= 50 * 24 * 365 then
                date = "永久"
            else
                date = "有效期 剩" .. math.ceil(self.config.date/24) .. "天"
            end
        else
            date = "有效期 剩" .. self.config.date .. "小时"
        end
    end
    self.date_txt.text =  date
    -- if  self.config.item_key == "prop_box" then
    --     self:InitBoxTimer()
    -- end 
    if GameItemModel.GetItemType(self.config) == GameItemModel.ItemType.act then
        local texture_name = "byhall_imgf_qsw_activity_sys_bag"
        if self.config.game_id == 1 then
            texture_name = "byhall_imgf_qsw_activity_sys_bag"
        elseif self.config.game_id == 2 then
            texture_name = "byhall_imgf_shxb_activity_sys_bag"
        elseif self.config.game_id == 3 then
            texture_name = "byhall_imgf_ddyj_activity_sys_bag"
        else
            texture_name = "byhall_imgf_tyc_activity_sys_bag"
        end
        self.fishing_type_img.sprite = GetTexture(texture_name)
        self.fishing_type_img:SetNativeSize()
        self.fishing_type_img.transform.localScale = Vector3.New(0.24,0.24,0)
        self.fishing_type_img.gameObject:SetActive(true)
        GetTextureExtend(self.fishing_icon_img, self.config.image, self.config.is_local_icon)
        self.fishing_icon_img.gameObject:SetActive(true)
        self.icon_img.gameObject:SetActive(false)
        self.num_txt.text = tonumber(self.config.bullet_num) > 0 and "x" .. self.config.bullet_num or ""
        PointerEventListener.Get(self.fishing_icon_img.gameObject).onDown = basefunc.handler(self, self.OnDown)
        PointerEventListener.Get(self.fishing_icon_img.gameObject).onUp = basefunc.handler(self, self.OnUp)
    else
        GetTextureExtend(self.icon_img, self.config.image, self.config.is_local_icon)
        PointerEventListener.Get(self.icon_img.gameObject).onDown = basefunc.handler(self, self.OnDown)
        PointerEventListener.Get(self.icon_img.gameObject).onUp = basefunc.handler(self, self.OnUp)
    
        self.icon_img.gameObject:SetActive(true)
        self.fishing_icon_img.gameObject:SetActive(false)
        self.fishing_type_img.gameObject:SetActive(false)
        self.num_txt.text = self.config.num > 0 and "x" .. self.config.num or ""
    end

    if self.config.use_parm then
    	self.use_btn.gameObject:SetActive(true)
        self.use_btn.onClick:AddListener(function()
            self:OnClick()
        end)
        self.use_txt.text = self.config.use_btn_txt or "去使用"
    else
	    self.use_btn.gameObject:SetActive(false)
    end
end

function C:OnClick()
	if self.config.use_parm then
        if (not self.config.beginTime or self.config.beginTime <= os.time()) or (not self.config.endTime or self.config.endTime >= os.time()) then
            GameManager.GotoUI({gotoui=self.config.use_parm[1], goto_scene_parm=self.config.use_parm[2], data=self.config.use_parm[3], call=function ()
                self.panelSelf:Close()
            end,enter_scene_call=function()
                if FishingManager then
                    FishingManager.SignFishing(self.config)
                end
            end})
        else
            HintPanel.Create(1, self.config.desc)
        end
	end
end
function C:OnDown()
    local pos = UnityEngine.Input.mousePosition
    GameTipsPrefab.ShowItem(self.config.item_key, pos, GameTipsPrefab.TipsShowStyle.TSS_34)
end
function C:OnUp()
    GameTipsPrefab.Hide()
end
function C:InitBoxTimer()
    local EndTime = PropBoxManager.GetEndTime()
    local MidTime = PropBoxManager.GetStartTime()
    if self.box_timer then self.box_timer:Stop() end  
    if  EndTime > os.time()   then
        if os.time() >=  MidTime then
            if IsEquals(self.gameObject) then 
                self.date_txt.text = "有效期: 剩"..StringHelper.formatTimeDHMS2(EndTime - os.time())
            end
        else
            if IsEquals(self.gameObject) then 
                self.date_txt.text = "距离开启: "..StringHelper.formatTimeDHMS2(MidTime - os.time()) 
            end
        end  
    end 
    self.box_timer = Timer.New(function ()
        if  EndTime > os.time() then
            if os.time() >=  MidTime then
                if IsEquals(self.gameObject) then 
                    self.date_txt.text = "有效期: 剩"..StringHelper.formatTimeDHMS2(EndTime - os.time())
                end
            else
                if IsEquals(self.gameObject) then 
                    self.date_txt.text = "距离开启: "..StringHelper.formatTimeDHMS2(MidTime - os.time()) 
                end
            end 
        end 
    end,1,-1)
    self.box_timer:Start()
end