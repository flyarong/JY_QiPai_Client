-- 创建时间:2018-12-20

local basefunc = require "Game.Common.basefunc"

MoneyCenterTGLBPrefab = basefunc.class()

local C = MoneyCenterTGLBPrefab
C.name = "MoneyCenterTGLBPrefab"

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
    --vip
    self.lister["model_query_vip_lb_base_info_response"] = basefunc.handler(self, self.MyRefresh)
    self.lister["model_vip_lb_base_info_change_msg"] = basefunc.handler(self, self.MyRefresh)
    self.lister["model_query_one_task_data_response_vip_gift"] = basefunc.handler(self, self.MyRefresh)
    self.lister["model_task_change_msg_vip_gift"] = basefunc.handler(self, self.MyRefresh)
	--金猪
    self.lister["model_query_goldpig_task_data_response"] = basefunc.handler(self, self.MyRefresh)
    self.lister["model_get_goldpig_task_award_response"] = basefunc.handler(self, self.MyRefresh)
    self.lister["model_goldpig_task_change_msg"] = basefunc.handler(self, self.MyRefresh)
    self.lister["model_query_goldpig_task_remain_response"] = basefunc.handler(self, self.MyRefresh)
    self.lister["model_goldpig_task_remain_change_msg"] = basefunc.handler(self, self.MyRefresh)
    self.lister["model_query_goldpig2_task_remain_msg"] = basefunc.handler(self, self.MyRefresh)
    self.lister["model_query_goldpig2_task_today_data_msg"] = basefunc.handler(self, self.MyRefresh)
    self.lister["goldpig2_task_remain_change_msg"] = basefunc.handler(self, self.MyRefresh)

	self.lister["model_finish_gift_shop"] = basefunc.handler(self, self.on_model_finish_gift_shop)
    self.lister["model_receive_pay_order"] = basefunc.handler(self, self.on_model_receive_pay_order)
    self.lister["main_model_query_all_gift_bag_status"] = basefunc.handler(self, self.MyRefresh)
end

function C:on_model_receive_pay_order(msg)
    dump(msg, "<color=green>on_model_receive_pay_order</color>")
	if msg.result == 0 then
		print("<color=green>购买礼包成功</color>")
	else
		HintPanel.ErrorMsg(msg.result)
	end
end

function C:on_model_finish_gift_shop(id)
    UIPaySuccess.Create()
    if id == self.config.good_id then
        self:MyRefresh()
    end
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:OnDestroy()
	GameObject.Destroy(self.gameObject)
	self:MyExit()
end

function C:MyExit()
    self:RemoveListener()
    if self.countdown then
        self.countdown:Stop()
    end
end

function C:ctor(parent_transform, config, call, panelSelf)
	self.config = config
	self.call = call
	self.panelSelf = panelSelf
	local obj = newObject(C.name, parent_transform)
	local tran = obj.transform
	self.transform = tran
    self.gameObject = obj
    self.gameObject.name = self.config.name

	self:MakeLister()
	self:AddMsgListener()
    LuaHelper.GeneratingVar(self.transform, self)
    
    self:InitUI()
end

function C:InitUI()
    self.desc_txt.text = self.config.desc
    self.price_txt.text  = self.config.price / 100 .. "元"
    self.icon_img.sprite = GetTexture(self.config.icon)
    self.icon_img:SetNativeSize()
	self.pay_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
        self:BuyGiftBox(self.config.good_id)
    end)

    self.task_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
        self:OnClickTask()
    end)

    self.slider = self.Slider:GetComponent("Slider")
    
    if C.CheckGiftTypeByGiftID(self.config.good_id) == "vip" then
        local bd = VIPGiftModel.GetTaskBaseDataByID(self.config.task_id)
        self.countdown = Timer.New(function (  )
            self:UpdateCountdown()
        end,1,-1,false,false)
        self.countdown:Start()
    elseif C.CheckGiftTypeByGiftID(self.config.good_id) == "pig"  then

    end
    self:MyRefresh()
end

function C:MyRefresh()
    local is_buy = false
    local is_show = false
    if C.CheckGiftTypeByGiftID(self.config.good_id) == "vip" then
        is_buy = VIPGiftModel.CheckIsBuy()
        is_show = is_buy
        if not is_buy then
            is_show = self.config.not_buy_show and self.config.not_buy_show == 1
        end
        local is_running, status = VIPGiftModel.GetVIPStatusByTaskID(self.config.task_id)
        if is_show then
            is_show = is_running
        end
    elseif C.CheckGiftTypeByGiftID(self.config.good_id) == "pig"  then
        is_show, is_buy =GoldenPigModel.CheckGiftIsShow(self.config.good_id) 
        if is_show then
            is_show = GoldenPigModel.CheckTaskIsShow(self.config.task_id)
        end
    end
    self.gameObject:SetActive(is_show)
    self.pay_btn.gameObject:SetActive(not is_buy)
    self.task_btn.gameObject:SetActive(is_buy)

    local set_ui = function(data)
        if data then
            local now_process = data.now_process
            local need_process = data.need_process
            self.progress_txt.text = now_process .. "/" .. need_process
            local process = now_process / need_process
            if process > 1 then
                process = 1
            end
            self.slider.value = process == 0 and 0 or 0.95 * process + 0.05
    
            self.over_img.gameObject:SetActive(false)
            self.get_img.gameObject:SetActive(false)
            self.goto_img.gameObject:SetActive(false)
            if data.award_status == 2 then
                self.over_img.gameObject:SetActive(true)
            elseif data.award_status == 1 then
                self.get_img.gameObject:SetActive(true)
            elseif data.award_status == 0 then
                self.goto_img.gameObject:SetActive(true)
            end
        end 
    end

    if C.CheckGiftTypeByGiftID(self.config.good_id) == "pig" then
        local data = GoldenPigModel.GetTaskDataByID(self.config.task_id)
        set_ui(data)
        local remain = 40
        if self.config.good_id == 12 or self.config.good_id == 30 or self.config.good_id == 31 then
            remain = GoldenPigModel.GetTaskRemain()
        elseif self.config.good_id == 32 or self.config.good_id == 33 then
            remain = GoldenPigModel.GetPig2RemainNum()
        else
            print("<color=red>是不是又加金猪礼包了？？？</color>")
        end
        local remain_str
        if remain and remain > 0 then
            remain_str = string.format( "还可领%s次",remain)
        elseif remain and remain == 0 then
            remain_str = string.format( "已完成")
            self.slider.value = 1
            self.get_img.gameObject:SetActive(false)
            self.goto_img.gameObject:SetActive(false)
            self.over_img.gameObject:SetActive(true)
            if self.config.good_id == 32 or self.config.good_id == 33 then 
                self.gameObject:SetActive(false) --金猪礼包2，除开已经购买的玩家且未完成任务的，其余玩家不展示
            end
        end
        self.task_info_txt.text = string.format(self.config.title,self.config.price / 100,remain_str)
        self.slider.gameObject:SetActive(true)

        self.rem_num_txt.text =  string.format(remain_str)
        self.rem_num_txt.gameObject:SetActive(true)
    elseif C.CheckGiftTypeByGiftID(self.config.good_id) == "vip" then
        local data = VIPGiftModel.GetTaskDataByID(self.config.task_id)
        set_ui(data)
        if data then
            if self.config.task_id == 55 then
                self.task_info_txt.text = string.format(self.config.title)
            elseif self.config.task_id == 56 then
                self.task_info_txt.text = string.format(self.config.title,StringHelper.ToCash(data.need_process),StringHelper.ToCash(data.now_process))
            end
        end
        local bd = VIPGiftModel.GetTaskBaseDataByID(self.config.task_id)
        if bd then
            self.rem_num_txt.text = string.format(self.config.remain,bd.get_num,bd.max_num)
            self.rem_num_txt.gameObject:SetActive(true)
        end
        local _bd = VIPGiftModel.GetTaskBaseDataByID()
        if _bd then
            self.rem_txt.text =  string.format( "剩余数量：%s份",_bd.remain)
            self.rem_txt.gameObject:SetActive(true)
            if _bd.task_overdue_time then
                local countdown = _bd.task_overdue_time - os.time()
                if countdown > 0 then 
                    self.task_time_txt.text = string.format("任务有效时间：%s", StringHelper.formatTimeDHMS(countdown))
                end
                self.task_time_txt.gameObject:SetActive(true)
            end
        end
    end
    self.task_desc_txt.text = string.format(self.config.award)
end

--购买
function C:BuyGiftBox(goodsId)
    if GameGlobalOnOff.PGPay and gameRuntimePlatform == "Ios" then
        GameManager.GotoUI({gotoui = "sys_service_gzh",goto_scene_parm = "panel",desc="请关注“%s”公众号领取金猪大礼包"})
    else
        local goodsData = MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, goodsId)
        dump(goodsData, "<color=yellow>goodsData:>>>></color>")
        local price = "￥" .. (tonumber(goodsData.price) / 100)
        PayTypePopPrefab.Create(goodsData.id, price)
    end
end

function C:OnClickTask()
    local function click(data)
        if data then
            if data.award_status == 2 then
                LittleTips.Create(self.config.get_end_tips)
            elseif data.award_status == 1 then
                Network.SendRequest("get_task_award", {id = self.config.task_id})
            elseif data.award_status == 0 then
                if self.config.gotoUI[1] == "free_hall" then
                    GameFreeModel.RapidBeginGameLevel(2)
                else
                    GameManager.GotoUI({gotoui=self.config.gotoUI[1], goto_scene_parm=self.config.gotoUI[2], call=function ()
                        self:OnDestroy()
                        Event.Brocast("close_game_money_center_panel")
                    end})
                end
            end
        end
    end
    if C.CheckGiftTypeByGiftID(self.config.good_id) == "pig" then
        local remain = GoldenPigModel.GetTaskRemain()
        if remain and remain == 0 then
            LittleTips.Create(self.config.over_tips)
            return
        end
        local data = GoldenPigModel.GetTaskDataByID(self.config.task_id)
        dump(data, "<color=yellow>GoldenPigPanel:RefreshTaskUI->id:" .. self.config.task_id .. ", data:</color>")
        click(data)
    elseif C.CheckGiftTypeByGiftID(self.config.good_id) == "vip" then
        local bd = VIPGiftModel.GetTaskBaseDataByID(self.config.task_id)
        if bd and bd.get_num == bd.max_num then
            LittleTips.Create(self.config.over_tips)
            return
        end
        local data = VIPGiftModel.GetTaskDataByID(self.config.task_id)
        dump(data, "<color=yellow>GoldenPigPanel:RefreshTaskUI->id:" .. self.config.task_id .. ", data:</color>")
        click(data)
    end
end

function C.CheckGiftTypeByGiftID(id)
    if id then
        if id == 12 or id == 30 or id == 31 or id == 32 or id == 33 then
            return "pig"
        elseif  id == 43 then
            return "vip"
        end
    end
end

function C.CheckGiftTypeByTaskID(id)
    if id then
        if id == 7 or id == 51 then
            return "pig"
        elseif  id == 55 or id == 56 then
            return "vip"
        end
    end
end

function C:UpdateCountdown()
    local bd = VIPGiftModel.GetTaskBaseDataByID()
    if not bd then return end
    local countdown = bd.task_overdue_time - os.time()
    if countdown < 0 then return end
    self.task_time_txt.text = string.format("任务有效时间：%s", StringHelper.formatTimeDHMS(countdown))
end