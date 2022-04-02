-- 创建时间:2019-06-12
-- Panel:FishingBagItem
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

FishingBagItem = basefunc.class()
local C = FishingBagItem
C.name = "FishingBagItem"

function C.Create(parent_transform, config, call, panelSelf, style)
	return C.New(parent_transform, config, call, panelSelf, style)
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

function C:MyExit()
	self:RemoveListener()
	destroy(self.transform.gameObject)
end

function C:ctor(parent_transform, config, call, panelSelf, style)
    -- dump(config, "<color=yellow>config</color>")
	self.config = config
	self.call = call
	self.panelSelf = panelSelf
    self.style = style
	local obj = newObject(C.name, parent_transform)
	self.gameObject = obj
	self.transform = obj.transform
	self:MakeLister()
    self:AddMsgListener()
    LuaHelper.GeneratingVar(obj.transform, self)

    PointerEventListener.Get(self.icon_img.gameObject).onDown = basefunc.handler(self, self.OnDown)
    PointerEventListener.Get(self.icon_img.gameObject).onUp = basefunc.handler(self, self.OnUp)

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
    GetTextureExtend(self.icon_img, self.config.image, self.config.is_local_icon)
    if GameItemModel.GetItemType(self.config) == GameItemModel.ItemType.act then
        local texture_name = "byhall_imgf_qsw"
        if self.config.game_id == 1 then
            texture_name = "byhall_imgf_qsw"
        elseif self.config.game_id == 2 then
            texture_name = "byhall_imgf_shxb"
        elseif self.config.game_id == 3 then
            texture_name = "byhall_imgf_ddyj"
        else
            texture_name = "byhall_imgf_tyc"
        end
        self.type_img.sprite = GetTexture(texture_name)
        self.type_img:SetNativeSize()
        self.type_img.transform.localScale = Vector3.New(0.24,0.24,0)
        if self.config.bullet_num then
            self.num_txt.text = self.config.bullet_num > 0 and "x" .. self.config.bullet_num or ""
        else
            self.num_txt.text = ""
        end
        if self.style == FishingBagPanel.TYPE_ENUM.match then
            self.type_img.gameObject:SetActive(false)
        end
    else
        self.icon_img:SetNativeSize()
        self.icon_img.transform.localRotation = Vector3.zero
        self.type_img.gameObject:SetActive(false)
        self.num_txt.text = self.config.num > 0 and "x" .. self.config.num or ""
    end

    if self:CheckIsCurScene(self.config) then
        self.use_btn.gameObject:SetActive(true)
        self.goto_btn.gameObject:SetActive(false)
        self.not_use_img.gameObject:SetActive(false)
        if self:CheckIsCurUse(self.config) then
            -- print("<color=white>当前可以使用道具 ：</color>",self.config.asset_type)
        else
            -- print("<color=white>当前不能使用道具 ：</color>",self.config.asset_type)
        end
    else
        self.use_btn.gameObject:SetActive(false)
        self.goto_btn.gameObject:SetActive(true)
        self.not_use_img.gameObject:SetActive(true)
    end
    self.use_btn.onClick:AddListener(
        function()
            self:OnUseClick()
        end
    )
    self.goto_btn.onClick:AddListener(
        function()
            self:OnGotoClick()
        end
    )
    if not self:CheckGunLevel() and self.config.bullet_index then
        if self.style == FishingBagPanel.TYPE_ENUM.match then
            self.info_txt.text = ""
        else
            local ccc = FishingModel.GetGunCfg(self.config.bullet_index)
            if ccc and ccc.gun_rate then
                self.info_txt.text = "使用" .. ccc.gun_rate .. "等级炮"
            else
            self.info_txt.text = "使用" .. self.config.bullet_index .. "等级炮"
            end
        end
    else
        self.info_txt.text = ""
    end
end

function C:OnUseClick()
    if self.config.bullet_index then
        local _ii = (self.config.bullet_index - 1) % 10 + 1
        local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key="fishing_".. FishingModel.data.game_id .. "_" .. _ii}, "CheckCondition")
        if a and not b then
            return
        end
    end

    if self:CheckIsCurUse(self.config) then
        local use_cb = function()
            if self.style == FishingBagPanel.TYPE_ENUM.match then
                -- 比赛场不提示这个
            else
                if not self:CheckGunLevel() then
                    LittleTips.Create("该物品需要".. self.config.bullet_index .."等级炮，已自动为您调整炮的倍数")
                end
            end
        end

        dump(self.config, "<color=white>使用捕鱼道具:</color>")
        local data = {}
        data.msg_type = "tool"
        if self.config.id then
            data.item_key = self.config.id
        else
            data.item_key = self.config.item_key
        end
        data.call = function ( data )
            self.panelSelf:Close()
            use_cb()
            Event.Brocast("ui_use_skill_call_msg", {item_key=self.config.item_key})
        end
        Event.Brocast("model_use_skill_msg", data)
    else
        LittleTips.Create("当前不能使用该道具")
    end
end

function C:OnGotoClick()
    local is_can, result = FishingManager.CheckCanEnter(self.config.game_id)
    if is_can then
        FishingModel.GotoFishingByID(self.config.game_id)
        self.panelSelf:Close()
    else        
        if result == 1 then
            LittleTips.Create("您的鲸币不足，请购买鲸币")
            PayPanel.Create(GOODS_TYPE.jing_bi)
        elseif result == 2 then
            LittleTips.Create("你的太富有了，请前往对应场")
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

function C:OnDestroy()
	self:MyExit()
	destroy(self.gameObject)
end

function C:CheckIsCurScene(data)
    if data.scene == "matchstyle" then
        return true
    end

    local cur_t = GameItemModel.GetItemType(data)
    if cur_t == GameItemModel.ItemType.skill then
        return true
    elseif cur_t == GameItemModel.ItemType.act or cur_t == GameItemModel.ItemType.cf_skill then
        return FishingModel.data.game_id == data.game_id
    end
end

--当前是否可用
function C:CheckIsCurUse()
    local m_seat = FishingModel.GetPlayerSeat()
    local p = FishingGamePanel.GetPlayerInstance()
    local is_can = false
    local it_type = GameItemModel.GetItemType(self.config)
    if it_type == GameItemModel.ItemType.skill then
        is_can = FishingModel.CheckIsCanUseSkill(self.config.item_key)
    elseif it_type == GameItemModel.ItemType.act then
        is_can = not FishingActivityManager.CheckIsActivityTime(m_seat)
    elseif it_type == GameItemModel.ItemType.cf_skill then
        is_can = true 
    end
    return is_can
end

function C:GetCurGunLevel()
    local p = FishingGamePanel.GetPlayerInstance()
    if p then
        return p:GetCurGunLevel()
    end
end

function C:CheckGunLevel()
    local p = FishingGamePanel.GetPlayerInstance()
    local cur_level
    if p then
        cur_level = p:GetCurGunLevel()
    end
    if self.config.bullet_index then
        if cur_level and cur_level ~= self.config.bullet_index then
            return false
        end
    end
    return true
end