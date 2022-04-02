-- 创建时间:2018-12-12
local basefunc = require "Game.Common.basefunc"
ActivityXRHB1Panel = basefunc.class()
local C = ActivityXRHB1Panel
C.name = "ActivityXRHB1Panel"

function C.Create(parent, backcall)
    return C.New(parent, backcall)
end

function C:AddMsgListener()
    for proto_name, func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["model_query_stepstep_money_big_step_data"] = basefunc.handler(self, self.on_query_stepstep_money_big_step_data)
    self.lister["ExitScene"] = basefunc.handler(self, self.ExitScene)
    self.lister["model_get_stepstep_money_task_award_response"] = basefunc.handler(self, self.on_model_get_stepstep_money_task_award_response)
    self.lister["model_stepstep_money_task_change_msg"] = basefunc.handler(self, self.on_model_stepstep_money_task_change_msg)
    self.lister["model_task_finished"] = basefunc.handler(self, self.MyExit)
	self.lister["all_seven_day_task_completed"] = basefunc.handler(self, self.OnBackClick)
	self.lister["finish_gift_shop"] = basefunc.handler(self, self.on_finish_gift_shop)
	self.lister["client_system_variant_data_change_msg"] = basefunc.handler(self, self.client_system_variant_data_change_msg)
end

function C:RemoveListener()
    for proto_name, func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:ctor(parent, backcall)
    ExtPanel.ExtMsg(self)
    self.backcall = backcall
    local parent = parent or GameObject.Find("Canvas/LayerLv4").transform
    local obj = newObject(C.name, parent)
    self.gameObject = obj
    self.transform = obj.transform
    self:MakeLister()
    self:AddMsgListener()
    self.gameObject:SetActive(false)
    LuaHelper.GeneratingVar(obj.transform, self)
    self.activity_config = ActivityXRHB1Model.GetActivity()
    self.back_btn.onClick:AddListener(
        function()
            ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
            self:OnBackClick()
        end
	)
	self.jhlb_btn.onClick:AddListener(
        function()
            ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
            self:OnBuyClick()
        end
	)
	
	self.help_btn.onClick:AddListener(
        function()
            ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
            self:OnHelpClick()
        end
    )

    self.back_btn.gameObject.name = "xrhb1_btn_back"
    self:InitUI()
    self.timer =
        Timer.New(
        function()
            self:Update()
        end,
        1,
        -1,
        nil,
        true
    )
    self.timer:Start()
end

function C:Update()
    if ActivityXRHB1Model and ActivityXRHB1Model.data and ActivityXRHB1Model.data.over_time then
        self.countdown = ActivityXRHB1Model.data.over_time - os.time()
        self.over_time_txt.text = StringHelper.formatTimeDHMS(self.countdown)
    end
end

function C:InitUI()
    local rectTrans = self.UINode:GetComponent("RectTransform")
    if IsEquals(rectTrans) then
        rectTrans.anchoredPosition = Vector2.New(0,0)
        rectTrans.sizeDelta = Vector2.New(1920,1080)
        rectTrans.anchorMin = Vector2.New(0.5,0.5);
        rectTrans.anchorMax = Vector2.New(0.5,0.5);
    end
    self.selectDay = 1
    ActivityXRHB1Model.ReqCurrTaskData()
end

function C:RefreshVIP()
    local is_show = ActivityXRHB1Model.IsShowVIPLevel()
    self.level_img.gameObject:SetActive(is_show)
end

function C:MyExit()
    if self.timer then
        self.timer:Stop()
        self.timer = nil
    end
    self:RemoveListener()
    self:ClearTaskCellList()
    GameObject.Destroy(self.gameObject)
    if self.backcall then
        self.backcall()
    end
	Event.Brocast("sys_023_exxsyd_panel_close")

	 
end

function C:on_query_stepstep_money_big_step_data(day)
    self.selectDay = day
    self:UpdateTask()
    self:RefreshUI()
    if not IsEquals(self.gameObject) then return end
    self.gameObject:SetActive(true)

    GuideLogic.CheckRunGuide("xrhb1_panel")
end

function C:RefreshUI()
    if not IsEquals(self.gameObject) then return end 
	self.total_hb_txt.text = string.format("%.1f元", ActivityXRHB1Model.data.total_hongbao_num / 100)
    self.now_get_hb_txt.text = string.format("已领取    <color=#c02d1fff><size=44>%.2f</size></color>    福卡", ActivityXRHB1Model.data.now_get_hongbao_num / 100)
    self.countdown = ActivityXRHB1Model.data.over_time - os.time()
    self.over_time_txt.text = StringHelper.formatTimeDHMS(self.countdown)
    local show_jhlb = ActivityXRHB1Model.GetJHLBStatus() == 2
    self.over_time_txt.gameObject:SetActive(not show_jhlb)
    self.total_hb_txt.gameObject:SetActive(not show_jhlb)
	self.jhlb_node.gameObject:SetActive(show_jhlb)
end

local callSort = function(v1, v2)
    local task1 = ActivityXRHB1Model.GetTaskToID(v1[1])
    local task2 = ActivityXRHB1Model.GetTaskToID(v2[1])
    if task1 and task2 then
        if task1.award_status == 1 and task2.award_status ~= 1 then
            return false
        elseif task1.award_status ~= 1 and task2.award_status == 1 then
            return true
        else
            if task1.award_status == 2 and task2.award_status ~= 2 then
                return true
            else
                return false
            end
        end
    end
end

function C:UpdateTask()
    -- self:RefreshVIP()
    self:ClearTaskCellList()
    if not self.activity_config or not self.activity_config[self.selectDay] then
        return
    end
    self.task_list = self.activity_config[self.selectDay].task_list

    local tl = {}
    for i,_v in ipairs(self.task_list) do
        for j,v in ipairs(_v) do
            local t = ActivityXRHB1Model.GetTaskToID(v)
            if t then
                tl[i] = tl[i] or {}
                table.insert(tl[i],v)
            end 
        end
    end
    local _tl = {}
    for k,v in pairs(tl) do
        table.insert(_tl,v)
    end
    self.task_list = _tl
    MathExtend.SortListCom(self.task_list, callSort)
    local i_name = 1
    for k, v in ipairs(self.task_list) do
        if IsEquals(self.TaskNode) then
            local pre = ActivityXRHB1TaskPrefab.Create(self.TaskNode.transform, v, nil, nil)
            self.TaskCellList[#self.TaskCellList + 1] = pre
            pre.gameObject.name = "ActivityXRHB1TaskPrefab" .. i_name
            i_name = i_name + 1
        end
    end
    if GuideLogic and GuideLogic.IsHaveGuide("xrhb1_panel") then
    else
        if self.TaskCellList and next(self.TaskCellList) then
            local i = 0
            local tt = 0.1
            for k, v in ipairs(self.TaskCellList) do
                v:PlayAnimIn(tt * i)
                i = i + 1
            end
        end
    end
	local cur_state = ActivityXRHB1Model.GetJHLBStatus()
	if cur_state == 2 then
		for k,v in pairs(self.TaskCellList) do
			v.goto_btn.gameObject:SetActive(false)
			v.get_btn.gameObject:SetActive(false)
			v.over.gameObject:SetActive(false)
			v.not_on_btn.gameObject:SetActive(true)
			local txt = v.not_on_btn.transform:Find("Text"):GetComponent("Text")
			txt.text = "待激活"
		end
	end
    -- self.day_txt.text = self.activity_config[self.selectDay].desc
end

function C:ClearTaskCellList()
    if self.TaskCellList then
        for k, v in ipairs(self.TaskCellList) do
            v:OnDestroy()
        end
    end
    self.TaskCellList = {}
end

function C:OnBackClick()
    self:MyExit()
end

function C:OnBuyClick()
	self.shopid = ActivityXRHB1Model.xrhb1_jblb_id
	self.gift_config = MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, self.shopid)
	self.status = MainModel.GetGiftShopStatusByID(self.gift_config.id)

    local b1 = MathExtend.isTimeValidity(self.gift_config.start_time, self.gift_config.end_time)

    if b1 then
    	if self.gift_config.buy_limt == 0 then
            if status == 0 then
				HintPanel.Create(1, "您已购买过此礼包了")
                return
            end
        elseif self.gift_config.buy_limt == 1 then
            if status == 0 then
				local s1 = os.date("%m月%d日%H点", self.gift_config.start_time)
				local e1 = os.date("%m月%d日%H点", self.gift_config.end_time)
				HintPanel.Create(1, string.format( "您今日已购买过了，请明日再来购买。\n(%s-%s每天可购买1次)",s1,e1))
                return
            end
        end
    else
		HintPanel.Create(1, "抱歉，此商品不在售卖时间内")
		return
    end
    
	if GameGlobalOnOff.PGPay and gameRuntimePlatform == "Ios" then
		GameManager.GotoUI({gotoui = "sys_service_gzh",goto_scene_parm = "panel",desc="请前往公众号获取"})
	else
		PayTypePopPrefab.Create(self.gift_config.id, "￥" .. (self.gift_config.price / 100))
	end
end

function C:OnHelpClick()
	self.introduce_txt.text = "1.活动仅限新用户，新用户第一次登录后开始计时，7天后活动结束；\n\n2.玩家购买“激活礼包”后，活动时间重置，7天后活动结束；\n\n3.捕鱼中的累计赢金数据只记录一半；\n\n4.请及时领取您的奖励，活动结束后未领取的奖励视为自动放弃；\n\n5本活动的最终解释权归本公司所有。"
	IllustratePanel.Create({ self.introduce_txt }, GameObject.Find("Canvas/LayerLv5").transform)
end

function C:on_finish_gift_shop(id)
	if id == self.shopid then
		self:UpdateTask()
		self:RefreshUI()
	end
end

function C:client_system_variant_data_change_msg(id)
	self:UpdateTask()
	self:RefreshUI()
end

function C:ExitScene()
    self:MyExit()
end

function C:on_model_get_stepstep_money_task_award_response(_, now_get_hongbao_num)
    dump(now_get_hongbao_num, "<color=green>on_model_get_stepstep_money_task_award_response</color>")
    self.now_get_hb_txt.text = string.format("已领取 <color=#c02d1fff><size=35>%.2f</size></color> 福卡", ActivityXRHB1Model.data.now_get_hongbao_num / 100)
end

function C:on_model_stepstep_money_task_change_msg(_, id)
    dump(id, "<color=green>on_model_get_stepstep_money_task_award_response</color>")
    if not IsEquals(self.transform) then
        return
    end
    self:UpdateTask()
end
