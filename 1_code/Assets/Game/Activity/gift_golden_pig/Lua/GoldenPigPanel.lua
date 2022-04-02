-- 创建时间:2018-10-15
local basefunc = require "Game.Common.basefunc"

GoldenPigPanel = basefunc.class()

GoldenPigPanel.name = "GoldenPigPanel"

local this
local data

function GoldenPigPanel.Create(parent, backcall)
    if not this then
        this = GoldenPigPanel.New(parent, backcall)
    end
    return this
end

function GoldenPigPanel.Close()
    print("<color=red>GoldenPigPanel.Close()</color>")
    if this then
        this:MyExit()
    end
    this = nil
end

function GoldenPigPanel:ctor(parent, backcall)

	ExtPanel.ExtMsg(self)

    self.backcall = backcall
    self.config = GoldenPigModel.GetConfigDataByType()
    self:MakeLister()
    self:AddMsgListener()
    local parent = parent or GameObject.Find("Canvas/LayerLv4").transform
    local obj = newObject(GoldenPigPanel.name, parent)
    local tran = obj.transform
    self.transform = tran
    self.gameObject = obj
    LuaHelper.GeneratingVar(self.transform, self)
    EventTriggerListener.Get(self.close_btn.gameObject).onClick = basefunc.handler(self, self.OnClickClose)

    self.hint_panel.gameObject:SetActive(false)
    self.hint_close_btn.onClick:AddListener(
        function()
            ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
            self.hint_panel.gameObject:SetActive(false)
        end
    )

    self:MyInit()
end

function GoldenPigPanel:MyInit()
    self.gift_status = MainModel.GetItemStatus(GOODS_TYPE.gift_bag, 12)
    self.pig1_status = MainModel.GetItemStatus(GOODS_TYPE.gift_bag, 30)
    self.pig2_status = MainModel.GetItemStatus(GOODS_TYPE.gift_bag, 32)
    self:PayUI()
    self:InitNotPayUI()
    self:MyRefresh()
end

function GoldenPigPanel:MyRefresh()
    if self.pig1_status == -1 then
        self.gameObject:SetActive(false)
        Timer.New(function()
            GoldenPigPanel.Close()
        end, 0.1, 1, false):Start()
        return
    end

    if self.gift_status ~= 0 and self.pig1_status == 1 then
        self.pay_root.gameObject:SetActive(false)
        self.not_pay_root.gameObject:SetActive(true)
    else
        self.pay_root.gameObject:SetActive(true)
        self.not_pay_root.gameObject:SetActive(false)
        GoldenPigModel.ReqTaskData()
        GoldenPigModel.ReqTaskRemain()
        GoldenPigModel.QueryGoldenPig2DayData()
    end
end

function GoldenPigPanel:InitShow()
    log("<color=yellow>status pig_30:" .. self.pig1_status .. ", pig_32:" .. self.pig2_status .. "</color>")
    dump(GoldenPigModel.data, "<color=yellow>GoldPigModel.data:</color>")
    local pig1 = MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, 30)
    local pig11 = MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, 31)
    local pig2 = MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, 32)
    local pig21 = MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, 33)

    self["XG199_txt"]:GetComponent("Text").text = pig1 and StringHelper.ToCash(pig11.price/100) .. "元购买" or ""
    self["Buy499_txt"]:GetComponent("Text").text = pig2 and StringHelper.ToCash(pig2.price/100) .. "元购买" or ""
    self["XG499_txt"]:GetComponent("Text").text = pig21 and StringHelper.ToCash(pig21.price/100) .. "元购买" or ""
    self["Dec_199_txt"]:GetComponent("Text").text = pig11 and string.format("%.2f", pig11.price/pig1.price) * 10 .. "折续购" or ""
    self["Dec_499_txt"]:GetComponent("Text").text = pig21 and string.format("%.2f", pig21.price/pig2.price) * 10 .. "折续购" or ""

    self["Task"].gameObject:SetActive(GoldenPigModel.data.remain_num >= 0)
    self["XuGou_199"].gameObject:SetActive(GoldenPigModel.data.remain_num < 0)
    self["Giftbox_499"].gameObject:SetActive(GoldenPigModel.data.pig2_num <= 0)
    self.Buy499_btn.gameObject:SetActive(self.pig2_status == 1)
    self.XG499_btn.gameObject:SetActive(self.pig2_status == 0)
    self.desc_img.gameObject:SetActive(self.pig2_status == 1)
    self["Bought_499"].gameObject:SetActive(GoldenPigModel.data.pig2_num > 0)
    self.finished_img.gameObject:SetActive(GoldenPigModel.data.pig2_day_left and GoldenPigModel.data.pig2_day_left <= 0)
    self.unfinished_img.gameObject:SetActive(GoldenPigModel.data.pig2_day_left and GoldenPigModel.data.pig2_day_left > 0)

    self.xh_499_title_txt.text = string.format("鲸币续航<size=32>（剩<color=#ed8813ff>%d</color>次可领）</size>", GoldenPigModel.data.pig2_num)
end

function GoldenPigPanel:MyExit()
    if this then
        self:RemoveListener()
        destroy(self.gameObject)
        this = nil
        if self.backcall then
            self.backcall()
        end
    end

	 
end

function GoldenPigPanel:MakeLister()
    self.lister = {}
    self.lister["model_query_goldpig_task_data_response"] = basefunc.handler(self, self.on_task_req_data_response)
    self.lister["model_get_goldpig_task_award_response"] = basefunc.handler(self, self.on_get_goldpig_task_award_response)
    self.lister["model_goldpig_task_change_msg"] = basefunc.handler(self, self.on_goldpig_task_change_msg)

    self.lister["model_query_goldpig_task_remain_response"] = basefunc.handler(self, self.model_query_goldpig_task_remain_response)
    self.lister["model_goldpig_task_remain_change_msg"] = basefunc.handler(self, self.model_goldpig_task_remain_change_msg)
    self.lister["model_query_goldpig2_task_remain_msg"] = basefunc.handler(self, self.model_query_goldpig2_task_remain_msg)
    self.lister["model_query_goldpig2_task_today_data_msg"] = basefunc.handler(self, self.model_query_goldpig2_task_today_data_msg)

    --金猪礼包改变
	self.lister["model_finish_gift_shop"] = basefunc.handler(self, self.on_model_finish_gift_shop)
	--金猪礼包购买失败
    self.lister["model_receive_pay_order"] = basefunc.handler(self, self.on_model_receive_pay_order)
    self.lister["goldpig2_task_remain_change_msg"] = basefunc.handler(self, self.RefreshGoldenPigCount)
end

function GoldenPigPanel:AddMsgListener()
    for proto_name, func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function GoldenPigPanel:RemoveListener()
    for proto_name, func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function GoldenPigPanel:on_task_req_data_response()
    local task_id = self.config.config.config.task_id
    if GoldenPigModel.IsNewPig1TaskExist() then
        task_id = self.config.config.config_t51.task_id
    end
    self:RefreshTaskUI(task_id)
    
    if GoldenPigModel.IsNewPig1TaskExist() then
        self:SetTask(self.config.config.config_t51)
    else
        self:SetTask(self.config.config.config)
    end
end

function GoldenPigPanel:on_get_goldpig_task_award_response(data)
    if data.id == 7 or data.id == 51 then
        self:RefreshTaskUI(data.id)
        local config = self.config.config.config
        if GoldenPigModel.IsNewPig1TaskExist() then
            config = self.config.config.config_t51
        end
        local tips = string.format( "%s元奖金",config.task_award / 100)
        LittleTips.Create(tips)
        Event.Brocast("close_golden_pig")
        GameMoneyCenterPanel.Create("tgjj")
        
    end
end

function GoldenPigPanel:on_goldpig_task_change_msg(data)
    if data.id == 7 or data.id == 51 then
        self:RefreshTaskUI(data.id)
    end
end

function GoldenPigPanel:model_query_goldpig_task_remain_response()
    self:RefreshTaskRemain()
    GoldenPigModel.QueryGoldenPig2Progress()
end

function GoldenPigPanel:model_goldpig_task_remain_change_msg()
    self:RefreshTaskRemain()
end

--************方法
--未购买
function GoldenPigPanel:InitNotPayUI()
    local data = self.config.pig_199
    for k, v in pairs(data) do
        self:SetPrivilegeItem(v)
    end

    self.pay_btn.onClick:AddListener(
        function()
            ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
            --购买vip
            self:CreateUIPayType()
        end
    )
    self.not_pay_help_btn.onClick:AddListener(
        function()
            self:OnClickHelp()
        end
    )
end

function GoldenPigPanel:SetPrivilegeItem(config)
    if config then
        local item = self["AwardPrefab_" .. config.id]
        local ui_table = {}
        ui_table.transform = item.transform
        ui_table.gameObject = item.transform.gameObject
        LuaHelper.GeneratingVar(item.transform, ui_table)
        --ui_table.icon_img.sprite = GetTexture(config.icon)
        --ui_table.icon_img:SetNativeSize()
        --ui_table.desc_txt.text = config.desc or ""
        ui_table.icon_btn = ui_table.icon_img.transform:GetComponent("Button")
        
        PointerEventListener.Get(ui_table.icon_btn.gameObject).onDown = function()
            local pos = UnityEngine.Input.mousePosition
            local tips = config.tips
            GameTipsPrefab.ShowDesc(tips, pos)
        end
        PointerEventListener.Get(ui_table.icon_btn.gameObject).onUp = function()
            GameTipsPrefab.Hide()
        end
        ui_table.gameObject:SetActive(config.is_show == 1)
    end
end

function GoldenPigPanel:BuyGiftBox(goodsId)
    if GameGlobalOnOff.PGPay and gameRuntimePlatform == "Ios" then
        GameManager.GotoUI({gotoui = "sys_service_gzh",goto_scene_parm = "panel",desc="请关注“%s”公众号领取金猪大礼包"})
    else
        local goodsData = MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, goodsId)
        dump(goodsData, "<color=yellow>goodsData:>>>></color>")
        local price = "￥" .. (tonumber(goodsData.price) / 100)
        PayTypePopPrefab.Create(goodsData.id, price)
    end
end

--购买--------------------------
function GoldenPigPanel:CreateUIPayType()
    self:BuyGiftBox(GoldenPigModel.GetGiftBagGoodsID())
end

function GoldenPigPanel:CreateUIPaySuccess()
    --UIPaySuccess.Create()
end

function GoldenPigPanel:on_model_finish_gift_shop(id)
    self:CreateUIPaySuccess()
    self:MyInit()
end

function GoldenPigPanel:on_model_receive_pay_order(msg)
    dump(msg, "<color=green>on_model_receive_pay_order</color>")
	if msg.result == 0 then
		print("<color=green>购买礼包成功</color>")
	else
		HintPanel.ErrorMsg(msg.result)
	end
end

--已购买
function GoldenPigPanel:PayUI()
    local pay_config = self.config.config.config
    self.help_btn.onClick:AddListener(
        function()
           self:OnClickHelp()
        end
    )

    if GoldenPigModel.IsNewPig1TaskExist() then
        self:SetTask(self.config.config.config_t51)
    else
        self:SetTask(self.config.config.config)
    end
    self.gzh_txt.text = pay_config.gzh
    self.wx_copy_btn.onClick:AddListener(
        function()
            self:OnClickCoypWeChat(pay_config.gzh)
        end
    )
    
    self.xh_499_title_txt.text = ""--string.format("鲸币续航<size=32>（剩<color=#ed8813ff>%d</color>次可领）</size>", 25)
    self.xh_499_desc_txt.text = "每日首次登录游戏自动领取20万鲸币,每日只能领1次"
    
    EventTriggerListener.Get(self.XG199_btn.gameObject).onClick = function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        GoldenPigModel.ResetTaskData()
        self:BuyGiftBox(31)
    end
    EventTriggerListener.Get(self.Buy499_btn.gameObject).onClick = function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        self:BuyGiftBox(32)
    end
    EventTriggerListener.Get(self.XG499_btn.gameObject).onClick = function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        self:BuyGiftBox(33)
    end
    EventTriggerListener.Get(self.PartnerDetail_btn.gameObject).onClick = function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        Event.Brocast("open_game_money_center")
        GoldenPigPanel.Close()
    end

    if not self.InitRewardList then
        self.InitRewardList = true
        self:InitPig1()
        self:InitPig2()
    end
end

function GoldenPigPanel:AddTouchEvent(obj, tip, press)
    if press then
        EventTriggerListener.Get(obj).onDown = function ()
            GameTipsPrefab.ShowDesc(tip, UnityEngine.Input.mousePosition)
        end
    else
        EventTriggerListener.Get(obj).onUp = function ()
            GameTipsPrefab.Hide()
        end
    end
end

function GoldenPigPanel:InitPig1()
    local data = self.config.pig_199
    local list = self["RewardList_199"]:Find("Viewport/Content")
    self:InitPigRewardList(data, list)
end

function GoldenPigPanel:InitPig2()
    local data = self.config.pig_499
    local list = self["RewardList_499"]:Find("Viewport/Content")
    self:InitPigRewardList(data, list)
end

function GoldenPigPanel:InitPigRewardList(data, parent)
    for i, v in ipairs(data) do
        self.TmplIcon_img.sprite = GetTexture(v.icon)
        self.TmplDesc_txt.text = v.desc
        local item = GameObject.Instantiate(self["AwardTmpl"], parent)
        local btn = item.transform:Find("Tmpl_btn").gameObject
        item.gameObject:SetActive(true)
        self:AddTouchEvent(btn, v.tips, true)
        self:AddTouchEvent(btn)
    end
end

function GoldenPigPanel:SetTask(config)
    if config == nil then return end
    self:SetTaskUI(config)
end

function GoldenPigPanel:SetTaskUI(config)
    --<size=42><color=yellow>6.66</color></size>元
    self.task_money_txt.text = string.format( "%.2f",config.task_award / 100)
    self.task_info_txt.text = string.format( "<color=#ED8813FF>%s</color>微信福卡任务",config.task_price / 100)

    PointerEventListener.Get(self.remain_over_btn.gameObject).onDown = function()
        local pos = UnityEngine.Input.mousePosition
        local tips = "您已领满了40次奖励，邀请好友还可以领奖金哦！"
        GameTipsPrefab.ShowDesc(tips, pos)
    end
    PointerEventListener.Get(self.remain_over_btn.gameObject).onUp = function()
        GameTipsPrefab.Hide()
    end

    PointerEventListener.Get(self.over_btn.gameObject).onDown = function()
        local pos = UnityEngine.Input.mousePosition
        local tips = "您当日奖励已领取，请明日6点再来(游戏大厅左下角点击赚钱按钮可查看奖金)"
        GameTipsPrefab.ShowDesc(tips, pos)
    end
    PointerEventListener.Get(self.over_btn.gameObject).onUp = function()
        GameTipsPrefab.Hide()
    end

    self.get_btn.onClick:RemoveAllListeners()
    self.get_btn.onClick:AddListener(
        function()
            Network.SendRequest("get_goldpig_task_award", {id = config.task_id})
        end
    )

    self.goto_btn.onClick:RemoveAllListeners()
    self.goto_btn.onClick:AddListener(
        function()
            ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
            -- GameManager.GotoUI({gotoui="free_hall", call=function ()
            --     GoldenPigPanel.Close()
            -- end})
            GameFreeModel.RapidBeginGameLevel(2)
        end
    )
    self.slider = self.Slider:GetComponent("Slider")
end

function GoldenPigPanel:RefreshTaskUI(id)
    local data = GoldenPigModel.GetTaskDataByID(id)
    dump(data, "<color=yellow>GoldenPigPanel:RefreshTaskUI->id:" .. id .. ", data:</color>")
    if data then
        local now_process = data.now_process
        local need_process = data.need_process
        self.progress_txt.text = now_process .. "/" .. need_process
       
        local process = now_process / need_process
        if process > 1 then
            process = 1
        end
        self.slider.value = process == 0 and 0 or 0.95 * process + 0.05

        self.over_btn.gameObject:SetActive(false)
        self.get_btn.gameObject:SetActive(false)
        self.goto_btn.gameObject:SetActive(false)
        if data.award_status == 2 then
            self.over_btn.gameObject:SetActive(true)
        elseif data.award_status == 1 then
            self.get_btn.gameObject:SetActive(true)
        elseif data.award_status == 0 then
            self.goto_btn.gameObject:SetActive(true)
        end
    end
end

function GoldenPigPanel:RefreshTaskRemain()
    local remain = GoldenPigModel.GetTaskRemain()
    if remain and remain > 0 then 
        self.get_num_txt.text = string.format( "（还可领%s次）",remain)
    elseif remain and remain == 0 then
        self.get_num_txt.text = string.format( "（已领完）")
        self.slider.value = 1
        self.progress_txt.text = "已完成"
        self.get_btn.gameObject:SetActive(false)
        self.goto_btn.gameObject:SetActive(false)
        self.over_btn.gameObject:SetActive(true)
    end
    
    if remain == 0 then
        self.remain_over_btn.gameObject:SetActive(true)
    else
        self.remain_over_btn.gameObject:SetActive(false)
    end
end

--OnClick**********************************
function GoldenPigPanel:OnClickClose(go)
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    Event.Brocast("close_golden_pig")
end

function GoldenPigPanel:OnClickHelp()
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    self.hint_panel.gameObject:SetActive(true)
end

function GoldenPigPanel:OnClickCoypWeChat(gzh)
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    LittleTips.Create("已复制微信号请前往微信进行添加")
    UniClipboard.SetText(gzh)
end

function GoldenPigPanel:model_query_goldpig2_task_remain_msg()
    self:InitShow()
end

function GoldenPigPanel:model_query_goldpig2_task_today_data_msg()
    self.finished_img.gameObject:SetActive(GoldenPigModel.data.pig2_day_left <= 0)
    self.unfinished_img.gameObject:SetActive(GoldenPigModel.data.pig2_day_left > 0)
end

function GoldenPigPanel:RefreshGoldenPigCount(pName, data)
    if data.task_remain then
        GoldenPigModel.data.pig2_num = data.task_remain
        self.xh_499_title_txt.text = string.format("鲸币续航<size=32>（剩<color=#ed8813ff>%d</color>次可领）</size>", GoldenPigModel.data.pig2_num)
    end
end