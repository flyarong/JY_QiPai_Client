-- 创建时间:2018-12-04
local basefunc = require "Game.Common.basefunc"
MatchHallMatchItem = basefunc.class()
local M = MatchHallMatchItem
M.name = "MatchHallMatchItem"

local state = {
    wait = "wait",
    show = "show",
    hide = "hide",
}

function M.Create(parent_transform, config)
	return M.New(parent_transform, config)
end

function M:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function M:MakeLister()
    self.lister = {}
    self.lister["query_send_list_fishing_msg"] = basefunc.handler(self, self.query_send_list_fishing_msg)
    self.lister["model_nor_mg_req_specified_signup_num"] = basefunc.handler(self, self.nor_mg_req_specified_signup_num)
    self.lister["model_vip_upgrade_change_msg"] = basefunc.handler(self, self.vip_upgrade_change_msg)
    self.lister["ExitScene"] = basefunc.handler(self, self.MyExit)
end

function M:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function M:vip_upgrade_change_msg(data)
    MatchModel.QuerySignupData(self.config)
end

function M:nor_mg_req_specified_signup_num(data)
    if data.id ~= self.config.game_id then return end
    MatchModel.RandomReqSignupNum(self.config.game_id)
end

function M:query_send_list_fishing_msg(tag)
    if tag ~= self.net_tag then return end
    self:Update()
end

function M:ctor(parent_transform, config)
    self.config = config
    self.net_tag = "match_model_" .. self.config.game_id 
    local prefab_name = M.name
    if self.config.hall_type == MatchModel.HallType.djs then
        prefab_name = prefab_name .. "_1"
    end
	local obj = newObject(prefab_name, parent_transform)
	self.gameObject = obj
    self.transform = obj.transform
    LuaHelper.GeneratingVar(obj.transform, self)
    self:MakeLister()
    self:AddMsgListener()
    self:Init(config)
end

function M:Init(config)
    MatchModel.QuerySignupData(config)
    self.NodeCanvasGroup = self.transform:GetComponent("CanvasGroup")
    self.detail_btn = self.bg_img:GetComponent("Button")
    self.gameObject.name = self.config.game_id
    self.bg_img.sprite = GetTexture(self.config.ui_match_bg)
    self.icon_img.sprite = GetTexture(self.config.ui_match_icon)
    self.match_name_txt_shadow = self.match_name_txt:GetComponent("Shadow")
    self.match_name_txt_outline = self.match_name_txt.gameObject:AddComponent(typeof(UnityEngine.UI.Outline))
    if self.config.ui_match_bg == "jbsdt_btn_bs1" then
        self.match_name_txt_shadow.effectColor = Color.New(199/255,118/255,22/255,1)
        self.match_name_txt_outline.effectColor = Color.New(199/255,118/255,22/255,1)
    elseif self.config.ui_match_bg == "jbsdt_btn_bs2" then
        self.match_name_txt_shadow.effectColor = Color.New(199/255,93/255,22/255,1)
        self.match_name_txt_outline.effectColor = Color.New(199/255,93/255,22/255,1)
    elseif self.config.ui_match_bg == "jbsdt_btn_bs3" then
        self.match_name_txt_shadow.effectColor = Color.New(199/255,68/255,22/255,1)
        self.match_name_txt_outline.effectColor = Color.New(199/255,68/255,22/255,1)
    elseif self.config.ui_match_bg == "jbsdt_btn_bs4" then
        self.match_name_txt_shadow.effectColor = Color.New(131/255,72/255,183/255,1)
        self.match_name_txt_outline.effectColor = Color.New(131/255,72/255,183/255,1)
    end
    self.match_name_txt.text = config.ui_match_name
    self.signup_hint_txt.text = self.config.ui_signup_hint or ""
    self.signup_btn_img = self.signup_btn.transform:GetComponent("Image")
    self.signup_item_txt_outline = self.signup_item_txt.transform:GetComponent("Outline")
    self.detail_btn.onClick:AddListener(function()
        self:OnDetailClick()
    end)
    self.signup_btn.onClick:AddListener(function()
        self:OnSignupClick()
    end)
    
    Event.Brocast("MatchHallMatchItemCreate",self)
    Event.Brocast("global_sysqx_uichange_msg", {key="match_hall", panelSelf=self})
    self.timerUpdate = Timer.New(function ()
        self:Update()
    end, 1, -1, true)
    self.timerUpdate:Start()
    self:Update()

    if self.config.ui_match_bg == "qysdt_btn_qys" then
        self.img_node1.gameObject:SetActive(true)
    end
end

function M:SetSignupItem(state)
    --报名方式 优惠>道具>视频>分享>鲸币
    --优惠
    if not table_is_null(state.discount_data) and not table_is_null(state.discount_data.list) then
        -- discount_condition 0 : string    # jing_bi 可用金币进入 vip_1_share VIP1以上需要分享  free_share  free_ad
        -- discount_count 1 : integer        # 值
        local condition = state.discount_data.list[1].discount_condition
        local count = state.discount_data.list[1].discount_count
        -- dump({condition,count},"<color=yellow>优惠条件</color>")
        if condition == "jing_bi" then
            --鲸币优惠
            self.signup_num_txt.text = "鲸币优惠参赛"
            GetTextureExtend(self.signup_item_img, "com_award_icon_jingbi")
            self.signup_item_txt.text = StringHelper.ToCash(count)
            self.signup_item_node.gameObject:SetActive(true)
            self.ad_img.gameObject:SetActive(false)
            return
        elseif condition == "free_ad" then
            --广告优惠
            if gameRuntimePlatform ~= "Ios" and self.config.is_ad and self.config.is_ad == 1 and state.ad_count and state.ad_count > 0 then
                self.signup_num_txt.text = "广告免费参赛" .. state.ad_count .. "次"
                self.signup_txt.text = "      广告报名"
                self.ad_img.gameObject:SetActive(true)
                self.signup_item_txt.text = ""
                self.signup_item_node.gameObject:SetActive(false)
                return
            end
        elseif condition == "free_share" then
            --分享优惠
            if self.config.is_share and self.config.is_share == 1 and state.share_count and state.share_count > 0 then
                self.signup_num_txt.text =  "分享免费参赛" .. state.share_count .. "次"
                self.signup_txt.text = "分享报名"
                self.signup_item_txt.text = ""
                self.signup_item_node.gameObject:SetActive(false)
                self.ad_img.gameObject:SetActive(false)
                return
            end
        else
            local str_arr = string.split(condition,"_")
            local s1,s2,s3 = str_arr[1],str_arr[2],str_arr[3]
            if s3 == "share" then
                if self.config.is_share and self.config.is_share == 1 and state.share_count and state.share_count > 0 then
                    self.signup_num_txt.text = s1 .. s2 .. "免费参赛"
                    self.signup_txt.text = "分享报名"
                    self.ad_img.gameObject:SetActive(false)
                    self.signup_item_txt.text = ""
                    self.signup_item_node.gameObject:SetActive(false)
                    return
                end
            elseif s3 == "ad" then
                if gameRuntimePlatform ~= "Ios" and self.config.is_ad and self.config.is_ad == 1 and state.ad_count and state.ad_count > 0 then
                    self.signup_num_txt.text = s1 .. s2 .. "免费参赛"
                    self.signup_txt.text = "      广告报名"
                    self.ad_img.gameObject:SetActive(true)
                    self.signup_item_txt.text = ""
                    self.signup_item_node.gameObject:SetActive(false)
                    return
                end
            else
                if s1 == "vip" then
                    if count ~= 0 then
                        self.signup_num_txt.text = s1 .. s2 .. "免费参赛"
                        self.signup_txt.text = "免费报名"
                        self.ad_img.gameObject:SetActive(false)
                        self.signup_item_txt.text = ""
                        self.signup_item_node.gameObject:SetActive(false)
                        return
                    else
                        self.signup_num_txt.text = s1 .. s2 .. "优惠参赛"
                        self.signup_txt.text = "鲸币报名"
                        GetTextureExtend(self.signup_item_img, "com_award_icon_jingbi")
                        self.signup_item_txt.text = StringHelper.ToCash(count)
                        self.signup_item_node.gameObject:SetActive(true)
                        self.ad_img.gameObject:SetActive(false)
                        return
                    end
                else
                    if count == 0 then
                        self.signup_num_txt.text = s1 .. s2 .. "免费参赛"
                        self.signup_txt.text = "免费报名"
                        self.ad_img.gameObject:SetActive(false)
                        self.signup_item_txt.text = ""
                        self.signup_item_node.gameObject:SetActive(false)
                        return
                    else
                        self.signup_num_txt.text = s1 .. s2 .. "优惠参赛"
                        self.signup_txt.text = "鲸币报名"
                        GetTextureExtend(self.signup_item_img, "com_award_icon_jingbi")
                        self.signup_item_txt.text = StringHelper.ToCash(count)
                        self.signup_item_node.gameObject:SetActive(true)
                        self.ad_img.gameObject:SetActive(false)
                        return
                    end
                end
            end
        end
    end
    
    self.signup_item,self.signup_item_count = MatchModel.GetSignupItem(self.config.game_id)
    if not table_is_null(self.signup_item) and #self.signup_item > 1 and not table_is_null(self.signup_item_count) and #self.signup_item_count > 1 then
        --道具
        local item_key = self.signup_item[1]
        local item_count = self.signup_item_count[1]
        local item = GameItemModel.GetItemToKey(item_key)
        self.signup_num_txt.text = ""
        GetTextureExtend(self.signup_item_img, item.image)
        self.signup_item_txt.text = StringHelper.ToCash(item_count)
        self.signup_item_node.gameObject:SetActive(true)
        self.ad_img.gameObject:SetActive(false)
        return
    end
    if gameRuntimePlatform ~= "Ios" and self.config.is_ad and self.config.is_ad == 1 and state.ad_count and state.ad_count > 0 then
        --还有看广告次数
        self.signup_num_txt.text = state.ad_count .. "/" .. self.config.ad_count
        self.signup_txt.text = "      广告报名"
        self.ad_img.gameObject:SetActive(true)
        self.signup_item_txt.text = ""
        self.signup_item_node.gameObject:SetActive(false)
        return
    end
    if self.config.is_share and self.config.is_share == 1 and state.share_count and state.share_count > 0 then
        --还有分享次数
        self.signup_num_txt.text = state.share_count .. "/" .. self.config.share_count
        self.signup_txt.text = "分享报名"
        self.signup_item_txt.text = ""
        self.signup_item_node.gameObject:SetActive(false)
        self.ad_img.gameObject:SetActive(false)
        return
    end
    if not table_is_null(self.signup_item) and not table_is_null(self.signup_item_count) then
        --鲸币报名
        local item_key = self.signup_item[#self.signup_item]
        local item_count = self.signup_item_count[#self.signup_item_count]
        local item = GameItemModel.GetItemToKey(item_key)
        self.signup_num_txt.text = ""
        GetTextureExtend(self.signup_item_img, item.image)
        self.signup_item_txt.text = StringHelper.ToCash(item_count)
        self.signup_item_node.gameObject:SetActive(true)
        self.ad_img.gameObject:SetActive(false)
        return
    end
    
    --报名条件
    local signup_item = self.config.signup_item
    local signup_item_count = self.config.signup_item_count
    if table_is_null(signup_item) then
        --没有报名条件
        self.signup_num_txt.text = ""
        self.signup_txt.text = "免费报名"
        self.signup_item_node.gameObject:SetActive(false)
        self.ad_img.gameObject:SetActive(false)
    elseif #signup_item == 1 and signup_item[1] == "jing_bi" and signup_item_count[1] == 0 then
        --报名鲸币为0，即为免费报名
        self.signup_num_txt.text = ""
        self.signup_txt.text = "免费报名"
        self.signup_item_node.gameObject:SetActive(false)
        self.ad_img.gameObject:SetActive(false)
    else
        --报名需要道具
        local item_key = signup_item[1]
        local item_count = signup_item_count[1]
        for i,v in ipairs(signup_item) do
            if v == "jing_bi" then
                item_key = signup_item[i]
                item_count = signup_item_count[i]
            end
        end
        local item = GameItemModel.GetItemToKey(item_key)
        self.signup_num_txt.text = ""
        GetTextureExtend(self.signup_item_img, item.image)
        self.signup_item_txt.text = StringHelper.ToCash(item_count)
        self.signup_item_node.gameObject:SetActive(true)
        self.ad_img.gameObject:SetActive(false)
    end
end

function M:Update()
    local state = MatchLogic.GetMatchState(self.config)
    self.state = state
    -- if self.config.game_id == 13 then
        -- dump({state = state,cfg = self.config},"<color=white>state????????</color>")
    -- end
    if state.state == MatchLogic.State.wait_show then
        self.signup_num_txt.text = ""
        self.signup_txt.text = "即将开启"
        self.signup_item_txt.text = ""
        self.signup_item_node.gameObject:SetActive(false)
        self.signup_player_txt.text = 0
        self.signup_txt.color = Color.New(88/255,59/255,56/255,1)
        self.signup_btn_img.sprite = GetTexture("jbsdt_btn_3")
        self.signup_btn_img.raycastTarget = false
        self.ad_img.gameObject:SetActive(false)
        if state.signup_cd < 900 then
            self.signup_time_txt.text = "<size=26>开始报名-倒计时</size>\n" .. StringHelper.formatTimeDHMS5(state.signup_cd)
        elseif state.signup_cd < 3600 then
            self.signup_time_txt.text = "<size=26>报名时间</size>\n" .. os.date("%H:%M",state.signup_t)
        else
            if state.start_cd > 86400 or state.start_t - state.td_t > 86400 then
                self.signup_time_txt.text = "<size=26>开赛时间</size>\n" .. os.date("%m/%d %H:%M",state.start_t)
            else
                self.signup_time_txt.text = "<size=26>开赛时间</size>\n" .. os.date("%H:%M",state.start_t)
            end
        end
    elseif state.state == MatchLogic.State.wait_on then
        self.signup_num_txt.text = ""
        self.signup_txt.text = "即将开启"
        self.signup_item_txt.text = ""
        self.signup_item_node.gameObject:SetActive(false)
        self.signup_player_txt.text = 0
        self.signup_txt.color = Color.New(88/255,59/255,56/255,1)
        self.signup_btn_img.sprite = GetTexture("jbsdt_btn_3")
        self.signup_btn_img.raycastTarget = false
        self.ad_img.gameObject:SetActive(false)
        if state.signup_cd < 900 then
            self.signup_time_txt.text = "<size=26>开始报名-倒计时</size>\n" .. StringHelper.formatTimeDHMS5(state.signup_cd)
        elseif state.signup_cd < 3600 then
            self.signup_time_txt.text = "<size=26>报名时间</size>\n" .. os.date("%H:%M",state.signup_t)
        else
            if state.start_cd > 86400 or state.start_t - state.td_t > 86400 then
                self.signup_time_txt.text = "<size=26>开赛时间</size>\n" .. os.date("%m/%d %H:%M",state.start_t)
            else
                self.signup_time_txt.text = "<size=26>开赛时间</size>\n" .. os.date("%H:%M",state.start_t)
            end
        end
    elseif state.state == MatchLogic.State.wait_signup then
        self.signup_num_txt.text = ""
        self.signup_txt.text = "即将开启"
        self.signup_item_txt.text = ""
        self.signup_item_node.gameObject:SetActive(false)
        self.signup_player_txt.text = 0
        self.signup_txt.color = Color.New(88/255,59/255,56/255,1)
        self.signup_btn_img.sprite = GetTexture("jbsdt_btn_3")
        self.signup_btn_img.raycastTarget = false
        self.ad_img.gameObject:SetActive(false)
        if state.signup_cd < 900 then
            self.signup_time_txt.text = "<size=26>开始报名-倒计时</size>\n" ..StringHelper.formatTimeDHMS5(state.signup_cd)
        elseif state.signup_cd < 3600 then
            self.signup_time_txt.text = "<size=26>报名时间</size>\n" .. os.date("%H:%M",state.signup_t)
        else
            if state.start_cd > 86400 or state.start_t - state.td_t > 86400 then
                self.signup_time_txt.text = "<size=26>开赛时间</size>\n" .. os.date("%m/%d %H:%M",state.start_t)
            else
                self.signup_time_txt.text = "<size=26>开赛时间</size>\n" .. os.date("%H:%M",state.start_t)
            end
        end
    elseif state.state == MatchLogic.State.signup then
        self.signup_num_txt.text = ""
        self.signup_txt.text = "报名"
        self.signup_item_txt.text = ""
        self.signup_player_txt.text = state.signup_num
        if state.max_people then
            self.signup_txt.text = "报名人数已满"
            -- self.signup_btn_img.sprite = GetTexture("jbsdt_btn_2")
            -- self.signup_txt.color = Color.New(30/255,78/255,139/255,1)
            -- self.signup_item_txt_outline.effectColor = Color.New(33/255,33/255,154/255,1)
            self.signup_txt.color = Color.New(88/255,59/255,56/255,1)
            self.signup_btn_img.sprite = GetTexture("jbsdt_btn_3")

            self.signup_btn_img.raycastTarget = false
            self.ad_img.gameObject:SetActive(false)
            if self.config.start_type == 1 or self.config.start_type == 5 then
                --人满即开
                self.signup_time_txt.text = "<size=26>开始报名-倒计时</size>\n" .. StringHelper.formatTimeDHMS5(state.start_cd)
            else
                self.signup_time_txt.text = "<size=26>即将开赛-倒计时</size>\n" .. StringHelper.formatTimeDHMS5(state.start_cd)
            end
        else
            self.signup_btn_img.sprite = GetTexture("jbsdt_btn_1")
            self.signup_txt.color = Color.New(164/255,21/255,0/255,1)
            self.signup_item_txt_outline.effectColor = Color.New(175/255,107/255,55/255,1)
            self.signup_btn_img.raycastTarget = true

            if self.config.start_type == 1 or self.config.start_type == 5 then
                if self.config.max_people then
                    self.signup_time_txt.text = string.format("满%s人开赛",self.config.max_people)
                else
                    self.signup_time_txt.text = "人满即开"
                end
            else
                self.signup_time_txt.text = "<size=26>即将开赛-倒计时</size>\n" .. StringHelper.formatTimeDHMS5(state.start_cd)
            end
        end

        self:SetSignupItem(state)
    elseif state.state == MatchLogic.State.match then
        self.signup_num_txt.text = ""
        self.signup_txt.text = "正在比赛"
        self.signup_item_txt.text = ""
        self.signup_item_node.gameObject:SetActive(false)
        self.signup_txt.color = Color.New(88/255,59/255,56/255,1)
        self.signup_btn_img.sprite = GetTexture("jbsdt_btn_3")
        self.signup_btn_img.raycastTarget = false
        self.ad_img.gameObject:SetActive(false)
        self.signup_player_txt.text = self.config.max_people or 0
        self.signup_time_txt.text = ""
        if self.config.start_type == 2 then
            self.signup_time_txt.text = "比赛进行中"
        else
            if state.signup_cd < 900 then
                self.signup_time_txt.text = "<size=26>开始报名-倒计时</size>\n" ..StringHelper.formatTimeDHMS5(state.signup_cd)
            elseif state.signup_cd < 3600 then
                self.signup_time_txt.text = "<size=26>报名时间</size>\n" .. os.date("%H:%M",state.signup_t)
            else
                if state.start_cd > 86400 or state.start_t - state.td_t > 86400 then
                    self.signup_time_txt.text = "<size=26>开赛时间</size>\n" .. os.date("%m/%d %H:%M",state.start_t)
                else
                    self.signup_time_txt.text = "<size=26>开赛时间</size>\n" .. os.date("%H:%M",state.start_t)
                end
            end
        end
    elseif state.state == MatchLogic.State.match_over then
        self.signup_num_txt.text = ""
        self.signup_txt.text = "比赛结束"
        self.signup_item_txt.text = ""
        self.signup_item_node.gameObject:SetActive(false)
        self.signup_txt.color = Color.New(88/255,59/255,56/255,1)
        self.signup_btn_img.sprite = GetTexture("jbsdt_btn_3")
        self.signup_btn_img.raycastTarget = false
        self.ad_img.gameObject:SetActive(false)
        self.signup_player_txt.text = self.config.max_people or 0
        self.signup_time_txt.text = ""
        if self.config.start_type == 2 then
            self.signup_time_txt.text = "比赛已结束"
        else
            if state.signup_cd < 900 then
                self.signup_time_txt.text = "<size=26>开始报名-倒计时</size>\n" ..StringHelper.formatTimeDHMS5(state.signup_cd)
            elseif state.signup_cd < 3600 then
                self.signup_time_txt.text = "<size=26>报名时间</size>\n" .. os.date("%H:%M",state.signup_t)
            else
                if state.start_cd > 86400 or state.start_t - state.td_t > 86400 then
                    self.signup_time_txt.text = "<size=26>开赛时间</size>\n" .. os.date("%m/%d %H:%M",state.start_t)
                else
                    self.signup_time_txt.text = "<size=26>开赛时间</size>\n" .. os.date("%H:%M",state.start_t)
                end
            end
        end
    elseif state.state == MatchLogic.State.wait_off then
        self.signup_num_txt.text = ""
        self.signup_txt.text = "即将关闭"
        self.signup_item_txt.text = ""
        self.signup_item_node.gameObject:SetActive(false)
        self.signup_txt.color = Color.New(88/255,59/255,56/255,1)
        self.signup_btn_img.sprite = GetTexture("jbsdt_btn_3")
        self.signup_btn_img.raycastTarget = false
        self.ad_img.gameObject:SetActive(false)
        self.signup_player_txt.text = 0
        self.signup_time_txt.text = ""
    elseif state.state == MatchLogic.State.wait_hide then
        self.signup_num_txt.text = ""
        self.signup_txt.text = "即将开启"
        self.signup_item_txt.text = ""
        self.signup_item_node.gameObject:SetActive(false)
        self.signup_txt.color = Color.New(88/255,59/255,56/255,1)
        self.signup_btn_img.sprite = GetTexture("jbsdt_btn_3")
        self.signup_btn_img.raycastTarget = false
        self.ad_img.gameObject:SetActive(false)
        self.signup_player_txt.text = 0
        if state.signup_cd < 900 then
            self.signup_time_txt.text = "<size=26>开始报名-倒计时</size>\n" ..StringHelper.formatTimeDHMS5(state.signup_cd)
        elseif state.signup_cd < 3600 then
            self.signup_time_txt.text = "<size=26>报名时间</size>\n" .. os.date("%H:%M",state.signup_t)
        else
            if state.start_cd > 86400 or state.start_t - state.td_t > 86400 then
                self.signup_time_txt.text = "<size=26>开赛时间</size>\n" .. os.date("%m/%d %H:%M",state.start_t)
            else
                self.signup_time_txt.text = "<size=26>开赛时间</size>\n" .. os.date("%H:%M",state.start_t)
            end
        end
    elseif state.state == MatchLogic.State.hide then
        self.signup_num_txt.text = ""
        self.signup_txt.text = "隐藏"
        self.signup_item_txt.text = ""
        self.signup_item_node.gameObject:SetActive(false)
        self.signup_txt.color = Color.New(88/255,59/255,56/255,1)
        self.signup_btn_img.sprite = GetTexture("jbsdt_btn_3")
        self.signup_btn_img.raycastTarget = false
        self.ad_img.gameObject:SetActive(false)
        self.signup_player_txt.text = 0
        self.signup_time_txt.text = ""
        --隐藏
        self:MyExit()
    end

    if state.other_match then
        self.signup_txt.text = "已报名其它比赛"
    elseif state.now_match then
        self.signup_txt.text = "重回比赛"
    end
end

-- 设置gameObject名字
function M:SetObjName(name)
    if IsEquals(self.gameObject) then
        self.gameObject.name = name
    end
end

-- 点击
function M:OnDetailClick()
    DSM.PushAct({button = "match_btn"})
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    MatchHallDetailPanel.Create(self.config)
end

-- 点击报名
function M:OnSignupClick()
    DSM.PushAct({button = "signup_btn"})
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    MatchLogic.SignupMatch(self.config)
end

function M:MyExit()
    if self.timerUpdate then
        self.timerUpdate:Stop()
    end
    self.timerUpdate = nil

    self:RemoveListener()
    destroy(self.gameObject)
    self.gameObject = nil
end

function M:OnDestroy()
	self:MyExit()
end

function M:PlayAnim(t)
    local scale = 0.75
    if self.selectIndex == self.index then
        scale = 1
    end
    self.transform.localScale = Vector3.New(0.7*scale, 0.7*scale, 0.7*scale)
    self.NodeCanvasGroup.alpha = 0.01

    self.openseq = DG.Tweening.DOTween.Sequence()
    local tweenKey = DOTweenManager.AddTweenToStop(self.openseq)
    self.openseq:AppendInterval(t)
    self.openseq:Append(self.transform:DOScale(1*scale, 0.5):SetEase(DG.Tweening.Ease.OutBack))--OutBack
    self.openseq:Join(self.NodeCanvasGroup:DOFade(1, 0.5):SetEase(DG.Tweening.Ease.OutBack))
    self.openseq:OnKill(function()
        DOTweenManager.RemoveStopTween(tweenKey)
        if IsEquals(self.NodeCanvasGroup) then
            self.NodeCanvasGroup.alpha = 1
            local us = 0.75
            if self.selectIndex == self.index then
                us = 1
            end
            self.transform.localScale = Vector3.New(us, us, 1)
        end
        self.openseq = nil
    end)
end

--[[
    GetTexture("jbsdt_btn_bs1")
    GetTexture("jbsdt_btn_bs2")
    GetTexture("jbsdt_btn_bs3")
    GetTexture("jbsdt_btn_bs4")
    GetTexture("jbsdt_btn_bs5")
    GetTexture("jbsdt_icon_fk1")
    GetTexture("jbsdt_icon_fk2")
    GetTexture("jbsdt_icon_fk3")
    GetTexture("jbsdt_icon_hf1")
    GetTexture("jbsdt_icon_hf2")
    GetTexture("jbsdt_icon_hf3")
    GetTexture("jbsdt_icon_jd1")
    GetTexture("jbsdt_icon_jdd2")
    GetTexture("qysdt_btn_jdk")
    GetTexture("qysdt_btn_qys")
    GetTexture("qysdt_icon_hg")
]]