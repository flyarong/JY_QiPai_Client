local basefunc = require "Game.Common.basefunc"
MatchHallDetailPanel = basefunc.class()
local M = MatchHallDetailPanel

local instance
function M.Create(cfg, parent)
    if not instance then
        instance = M.New(cfg, parent)
    end
    return instance
end

-- isOpenType 打开方式 normal正常打开 其余是货币不足打开
function M:ctor(cfg, parent)
	ExtPanel.ExtMsg(self)
    self.config = cfg
    self.net_tag = "match_model_" .. self.config.game_id 
    self.game_id = self.config.game_id
    self.award = self.config.award
    self.parent = parent or GameObject.Find("Canvas/LayerLv3")
    self.gameObject = newObject("MatchHallDetailPanel", self.parent.transform)
    self.transform = self.gameObject.transform
    LuaHelper.GeneratingVar(self.transform, self)
    self.rankItem = GetPrefab("MatchHallRankAwardItem")
    self.signup_img = self.signup_btn.transform:GetComponent("Image")
    self:Init()
    self:MakeLister()
    self:AddMsgListener()

    self.update_timer =Timer.New(function()
        self:Update()
    end,1,-1)
    self.update_timer:Start()
    self:Update()
    DOTweenManager.OpenPopupUIAnim(self.transform)
end

function M:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function M:MakeLister()
    self.lister = {}
    self.lister["query_send_list_fishing_msg"] = basefunc.handler(self, self.query_send_list_fishing_msg)
end

function M:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function M:query_send_list_fishing_msg(tag)
    if tag ~= self.net_tag then return end
    self:Update()
end

function M:MyExit()
    if instance then
        self:RemoveListener()
        if self.update_timer then
            self.update_timer:Stop()
            self.update_timer = nil
        end
        for k, v in ipairs(self.rankTop3) do
            v:Close()
        end
        self.rankTop3 = nil
        self.rankItem = nil
        destroy(self.gameObject)
        instance = nil
    end	 
end

-- 关闭
function MatchHallDetailPanel.Close()
    if instance then
        instance:MyExit()
    end
end

function M:Init()
    self.signup_btn_img = self.signup_btn.transform:GetComponent("Image")
    self.signup_item_txt_outline = self.signup_item_txt.transform:GetComponent("Outline")
    EventTriggerListener.Get(self.close_btn.gameObject).onClick = basefunc.handler(self, self.OnClickDetailsBack)
    EventTriggerListener.Get(self.signup_btn.gameObject).onClick = basefunc.handler(self, self.OnClickSignup)
    EventTriggerListener.Get(self.rank_btn.gameObject).onClick = basefunc.handler(self, self.OnClickRank)
    EventTriggerListener.Get(self.details_rule_btn.gameObject).onClick = basefunc.handler(self, self.OnClickRule)
    self:RefreshRankAward()
    self.title_img.sprite = GetTexture("jbs_imgf_bsxq")
    self.title_img:SetNativeSize()
    self.max_people_txt.text = self.config.max_people or ""
    self.match_name_txt.text = self.config.ui_match_name or ""
    self.time_txt.text = self.config.ui_match_time or "开始时间"
    self.money_txt.text = self.config.ui_match_money or "开赛费用"
    if self.config.ui_match_number then
        self.people_txt.text = self.config.ui_match_number
    end

    if self.config.ui_match_type_name then
        self.play_txt.text = self.config.ui_match_type_name
    end

    if self.config.match_type == MatchModel.MatchType.hbs then
        self.rank_btn.gameObject:SetActive(false)
    end
end

function M:RefreshRankAward(  )
    if self.award then
        destroyChildren(self.rank_content.transform)
        for i, v in ipairs(self.award) do
            local go = GameObject.Instantiate(self.rankItem, self.rank_content)
            go.name = v.rank
            self:SetMatchRankItem(go, v)
        end
    else
        destroyChildren(self.rank_content.transform)
    end
    
    local rank
    if self.award then
        for i=1, 3 do
            if i <= #self.award then
                rank = "rank" .. i
                self[rank].gameObject:SetActive(true)
                local icon = ComMatchRankRewardItemIcon.Create(self.award[i], self[rank])
                self.rankTop3 = self.rankTop3 or {}
                self.rankTop3[#self.rankTop3 + 1] = icon
            else
                self[rank].gameObject:SetActive(false)
            end
        end
    end
end

function M:SetMatchRankItem(item, data)
    local childs = {}
    LuaHelper.GeneratingVar(item.transform, childs)
    childs.rank_item_bg_img.gameObject:SetActive(false)
    childs.rank_txt.text = data.rank
    local award_desc = ""
    for i,v in ipairs(data.award_desc) do
        if i ~= 1 then
            award_desc = award_desc .. "+"
        end
        award_desc = award_desc .. v
    end
    childs.award_txt.text = award_desc
    local index = item.transform:GetSiblingIndex()
    if index % 2 == 0 then
        childs.rank_item_bg_img.gameObject:SetActive(true)
    end
end

function M:OnClickDetailsBack(go)
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    self:MyExit()
end

--[[报名]]
function M:OnClickSignup(go)
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    local state = MatchLogic.GetMatchState(self.config)
    if state.state == MatchLogic.State.signup then
        MatchLogic.SignupMatch(self.config)
        return
    end
    LittleTips.Create("当前不在报名状态")
end

function M:OnClickRank(go)
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    MatchLogic.QueryRank(self.config)
end

function M:OnClickRule(go)
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    MatchHallRulePanel.Create(self.config)
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
    -- dump({state = state,cfg = self.config},"<color=white>state????????</color>")
    if state.state == MatchLogic.State.wait_show then
        self.signup_num_txt.text = ""
        self.signup_txt.text = "即将开启"
        self.signup_item_txt.text = ""
        self.signup_item_node.gameObject:SetActive(false)
        self.signup_player_txt.text = 0
        self.signup_txt.color = Color.New(88/255,59/255,56/255,1)
        self.signup_btn_img.sprite = GetTexture("jbsdt_btn_3")
        self.signup_btn_img.raycastTarget = false
        if state.signup_cd < 900 then
            self.signup_time_txt.text = "<size=26>开始报名-倒计时</size>\n" .. StringHelper.formatTimeDHMS5( state.signup_cd)
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
        if state.signup_cd < 900 then
            self.signup_time_txt.text = "<size=26>开始报名-倒计时</size>\n" .. StringHelper.formatTimeDHMS5( state.signup_cd)
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
        if state.signup_cd < 900 then
            self.signup_time_txt.text = "<size=26>开始报名-倒计时</size>\n" .. StringHelper.formatTimeDHMS5( state.signup_cd)
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
                --人满即开不显示------------------------>
                self.signup_time_txt.text = ""
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
        self.signup_player_txt.text = self.config.max_people or 0
        self.signup_time_txt.text = ""
        if self.config.start_type == 2 then
            self.signup_time_txt.text = "比赛即将结束"
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
        self.signup_player_txt.text = 0
        self.signup_time_txt.text = ""
    elseif state.state == MatchLogic.State.wait_hide then
        self.signup_num_txt.text = ""
        self.signup_txt.text = "已关闭"
        self.signup_item_txt.text = ""
        self.signup_item_node.gameObject:SetActive(false)
        self.signup_txt.color = Color.New(88/255,59/255,56/255,1)
        self.signup_btn_img.sprite = GetTexture("jbsdt_btn_3")
        self.signup_btn_img.raycastTarget = false
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