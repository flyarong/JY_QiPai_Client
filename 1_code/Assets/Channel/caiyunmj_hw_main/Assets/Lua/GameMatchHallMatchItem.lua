-- 创建时间:2018-12-04

local basefunc = require "Game.Common.basefunc"

MatchHallMatchItem = basefunc.class()

local C = MatchHallMatchItem

C.name = "MatchHallMatchItem"

function C.Create(parent_transform, config)
	return C.New(parent_transform, config)
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

function C:ctor(parent_transform, config)
	self.config = config
	local obj = newObject(C.name, parent_transform)
	self.gameObject = obj
    self.transform = obj.transform
	self:MakeLister()
    self:AddMsgListener()
    LuaHelper.GeneratingVar(obj.transform, self)
    if config.is_local_icon == 1 then
        self.award_img.sprite = GetTexture(config.game_icon)
    else
        URLImageManager.UpdateWebImage(config.game_icon, self.award_img)
    end
    self.enter_hint_txt.text = "立刻参赛"
    self.title_txt.text = config.game_name
    self.award_txt.text = config.award or ""
    self.game_type_txt.text = config.game_type_name or ""
    if MainModel.GetLocalType(config.game_type) == "ddz" then
        self.game_type_img.sprite = GetTexture("match_icon_pai")
        self.game_type_txt.color = Color.New(178 / 255, 63 / 255, 14 / 255)
    else
        self.game_type_img.sprite = GetTexture("match_icon_mj")
        self.game_type_txt.color = Color.New(153 / 255, 96 / 255, 54 / 255)
    end
    self.game_type_img:SetNativeSize()
    self.game_type_img.gameObject:SetActive(true)

    self.type_btn.onClick:AddListener(function()
        self:OnClick()
    end)
    self.EnterGold_btn.onClick:AddListener(function()
        self:OnSignupClick()
    end)
    self.player_num_txt.text = 0
    self.player_number.gameObject:SetActive(false)

    if self.config.game_type == MatchModel.GameType.game_DdzMatch or 
         self.config.game_type == MatchModel.GameType.game_DdzPDKMatch or 
        self.config.game_type == MatchModel.GameType.game_MjXzMatch3D then
        --福卡赛特殊设置
        self:SetHBSUI()
    elseif self.config.game_type == MatchModel.GameType.game_DdzMatchNaming or 
        self.config.game_type == MatchModel.GameType.game_MjMatchNaming then
        --冠名赛特殊设置
        self:SetGMSUI()
    end
    -- self:RandomReqSignupNum()
    if not GameGlobalOnOff.IOSTS then
        Event.Brocast("MatchHallMatchItemCreate",self)
    end
    Event.Brocast("global_sysqx_uichange_msg", {key="match_hall", panelSelf=self})

    -- 屏蔽1元免费福卡赛
    local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key="drt_block_free_match_game", is_on_hint = true}, "CheckCondition")
    if self.config.game_id == 10 and a and b then
        self.gameObject:SetActive(false)
    end
end

function C:PlayAnim(t)
    self.UINode.transform.localPosition = Vector3.New(1600, 0, 0)
    local seq = DG.Tweening.DOTween.Sequence()
    local tweenKey = DOTweenManager.AddTweenToStop(seq)
    seq:AppendInterval(t)
    seq:Append(self.UINode.transform:DOLocalMoveX(0, 0.2):SetEase(DG.Tweening.Ease.Linear))--OutBack

    seq:OnKill(
        function()
            DOTweenManager.RemoveStopTween(tweenKey)
            if IsEquals(self.UINode) then
                self.UINode.transform.localPosition = Vector3.New(0, 0, 0)
            end
        end
    )
end

function C:PlayAnimOut(t)
    if not IsEquals(self.UINode) then
        return
    end
    self.UINode.transform.localPosition = Vector3.New(0, 0, 0)
    local seq = DG.Tweening.DOTween.Sequence()
    local tweenKey = DOTweenManager.AddTweenToStop(seq)
    seq:AppendInterval(t)
    seq:Append(self.UINode.transform:DOLocalMoveX(1600, 0.2):SetEase(DG.Tweening.Ease.Linear))--OutBack

    seq:OnComplete(
        function()
            if IsEquals(self.UINode) then
                self.UINode.transform.localPosition = Vector3.New(1600, 0, 0)
                self:OnDestroy()
            end
        end
    )

    seq:OnKill(
        function()
            DOTweenManager.RemoveStopTween(tweenKey)
            if IsEquals(self.UINode) then
                self.UINode.transform.localPosition = Vector3.New(1600, 0, 0)
                self:OnDestroy()
            end
        end
    )

end

-- 设置gameObject名字
function C:SetObjName(name)
	self.gameObject.name = name
end

-- 随机间隔时间请求
function C:RandomReqSignupNum()
    -- 比赛场不是新手引导
    -- 不用定时请求报名人数
    if self.config.game_id ~= 1 then
        if self.timerUpdate then
            self.timerUpdate:Stop()
        end
        local t = math.random(200, 400) * 0.01
        self.timerUpdate = Timer.New(function ()
            self:ReqSignupNum()
        end, t, 1, true)
        self.timerUpdate:Start()
    end
end

-- 请求报名人数
function C:ReqSignupNum()
    Network.SendRequest("nor_mg_query_match_active_player_num", {id = self.config.game_id})
end

-- 返回报名人数消息
function C:nor_mg_req_specified_signup_num_response(_, data)
    if data.result == 0 then
        if data.id == self.config.game_id then
            self.player_num_txt.text = data.num
        end
    end
    -- self:RandomReqSignupNum()
end

-- 点击
function C:OnClick()
    DSM.PushAct({button = "match_btn"})
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    MatchHallPanel.ShowMatch(self.config)
end

-- 点击报名
function C:OnSignupClick()
    DSM.PushAct({button = "signup_btn"})
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    MatchHallPanel.SignupMatch(self.config)
end

function C:MyExit()
    if self.timerUpdate then
        self.timerUpdate:Stop()
    end
    self.timerUpdate = nil
    self:RemoveListener()
end

function C:OnDestroy()
	self:MyExit()
	destroy(self.gameObject)
end

function C:SetHBSUI(  )
    local item_key, item_count = MatchModel.GetMatchCanUseTool(self.config.enter_condi_itemkey, self.config.enter_condi_item_count)
    if item_key then
        local item = GameItemModel.GetItemToKey(item_key)
        GetTextureExtend(self.enter_icon_img, item.image, item.is_local_icon)
        self.enter_num_txt.text = StringHelper.ToCash(item_count)
    else
        self.enter_icon_img.sprite = GetTexture(self.config.enter_image)
        if self.config.enter_condi_count then
            self.enter_num_txt.text = self.config.enter_condi_count == 0 and "免费" or StringHelper.ToCash(self.config.enter_condi_count)
        else
            self.enter_num_txt.text = "免费"
        end
    end

    if self.config.game_id == 10 then
        --一元免费福卡赛
        Network.SendRequest("query_everyday_shared_award", {type="one_yuan_match"}, "查询请求", function (data)
            data.status = 0
            if data.result == 0 and data.status > 0 then
                self.enter_hint_txt.text = ""
                local _img = self.EnterGold_btn.transform:GetComponent("Image")
                if _img then
                    _img.sprite = GetTexture("match_btn_mf")
                end
                self.enter_icon_img.gameObject:SetActive(false)
                self.enter_num_txt.gameObject:SetActive(false)
            end
        end)          
    end
    self.match_info_txt.text = self.config.enter_num
end

function C:SetGMSUI()
    local WeekToTable = {
        [0] = "天",
        [1] = "一",
        [2] = "二",
        [3] = "三",
        [4] = "四",
        [5] = "五",
        [6] = "六",
    }
    
    local function CheckStartTime(time)
        print("<color=green>time</color>",time)
        local cur_w_time = os.date("%W",os.time())
        local w_time = os.date("%W",time)
        local week_day = os.date("%w",time)
        if week_day then
            if cur_w_time - w_time > 1 then
                return os.date("%m/%d %H:%M",time) .. "开赛"
            elseif cur_w_time - w_time == 1 then
                return "上周" .. WeekToTable[tonumber(week_day)] .. " " .. os.date("%H:%M",time) .. "开赛"
            elseif cur_w_time == w_time then
                return "本周"  .. WeekToTable[tonumber(week_day)] .. " " .. os.date("%H:%M",time) .. "开赛"
            elseif cur_w_time - w_time == -1 then
                return "下周"  .. WeekToTable[tonumber(week_day)] .. " " .. os.date("%H:%M",time) .. "开赛"
            elseif cur_w_time - w_time < -1 then
                return os.date("%m/%d %H:%M",time) .. "开赛"
            end
        end
    end

    local item_key, item_count = MatchModel.GetMatchCanUseTool(self.config.enter_condi_itemkey, self.config.enter_condi_item_count)
    if item_key then
        local item = GameItemModel.GetItemToKey(item_key)
        GetTextureExtend(self.enter_icon_img, item.image, item.is_local_icon)
        self.enter_num_txt.text = StringHelper.ToCash(item_count)
        GetTextureExtend(self.disable_icon_img, item.image, item.is_local_icon)
        self.disable_num_txt.text = StringHelper.ToCash(item_count)
    elseif self.config.enter_condi_count then
        self.enter_icon_img.sprite = GetTexture("com_award_icon_jingbi")
        self.enter_num_txt.text = self.config.enter_condi_count == 0 and "免费" or StringHelper.ToCash(self.config.enter_condi_count)
        self.disable_icon_img.sprite = GetTexture("com_award_icon_jingbi")
        self.disable_num_txt.text = self.config.enter_condi_count == 0 and "免费" or StringHelper.ToCash(self.config.enter_condi_count)
    else
        item_key = GameItemModel.GetTimeUnlimitedItemKey(self.config.enter_condi_itemkey)
        local item = GameItemModel.GetItemToKey(item_key)
        if item then
            local cost = GameItemModel.GetUseToolCount(item_key, self.config.enter_condi_itemkey, self.config.enter_condi_item_count)
            GetTextureExtend(self.enter_icon_img, item.image, item.is_local_icon)
            self.enter_num_txt.text = cost > 0 and cost or "免费"
            GetTextureExtend(self.disable_icon_img, item.image, item.is_local_icon)
            self.disable_num_txt.text = cost > 0 and cost or "免费"
        end
    end

    self.match_info_txt.text = CheckStartTime(self.config.over_time)
    self.match_num_txt.text = self.config.enter_num
    self.match_number.gameObject:SetActive(true)

    local week1 = os.date("%W", os.time())
    local week2 = os.date("%W", self.config.start_time)
    local prefix = ""
    if week1 > week2 then
        prefix = "上"
    elseif week1 < week2 then
        prefix = "下"
    end
    self.begin_time_txt.text = prefix .. "周" .. os.date("%w", self.config.start_time) .. "报名"

    if not self.config.latestOne or self.config.latestOne == 1 then
        self.EnterGold_btn.gameObject:SetActive(true)
        self.Disabled_btn.gameObject:SetActive(false)
    else
        self.EnterGold_btn.gameObject:SetActive(false)
        self.Disabled_btn.gameObject:SetActive(true)
        self.Disabled_btn.gameObject:GetComponent("Button").enabled = false
    end
end