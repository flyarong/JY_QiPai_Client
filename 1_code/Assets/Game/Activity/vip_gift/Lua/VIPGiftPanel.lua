-- 创建时间:2018-10-15
local basefunc = require "Game.Common.basefunc"
VIPGiftPanel = basefunc.class()
local M = VIPGiftPanel
M.name = "VIPGiftPanel"

local this
local data

function M.Create(parent, backcall)
    if not this then
        this = M.New(parent, backcall)
    end
    return this
end

function M.Close()
    print("<color=red>M.Close()</color>")
    if this then
        this:MyExit()
    end
    this = nil
end

function M:ctor(parent, backcall)

	ExtPanel.ExtMsg(self)

    self.backcall = backcall
    self:MakeLister()
    self:AddMsgListener()
    local parent = parent or GameObject.Find("Canvas/LayerLv4").transform
    local obj = newObject(M.name, parent)
    local tran = obj.transform
    self.transform = tran
    self.gameObject = obj
    LuaHelper.GeneratingVar(self.transform, self)
    EventTriggerListener.Get(self.close_btn.gameObject).onClick = basefunc.handler(self, self.OnClickClose)
    self.countdown = Timer.New(function (  )
        self:UpdateCountdown()
    end,1,-1,false,false)
    self.countdown:Start()
    self:MyInit()
end

function M:MyInit()
    self:PayUI()
    self:InitNotPayUI()
    Network.SendRequest("query_vip_lb_base_info", nil)
end

function M:MyRefresh()
    if not VIPGiftModel.CheckIsBuy() then
        self.pay_root.gameObject:SetActive(false)
        self.not_pay_root.gameObject:SetActive(true)
    else
        self.pay_root.gameObject:SetActive(true)
        self.not_pay_root.gameObject:SetActive(false)
        VIPGiftModel.ReqTaskData()
    end
    self:RefreshBase(VIPGiftModel.GetTaskBaseDataByID())
end

function M:MyExit()
    if this then
        self:RemoveListener()
        if self.countdown then
            self.countdown:Stop()
            self.countdown = nil
        end
        destroy(self.gameObject)
        this = nil
        if self.backcall then
            self.backcall()
        end
    end

	 
end

function M:MakeLister()
    self.lister = {}
    self.lister["model_query_vip_lb_base_info_response"] = basefunc.handler(self, self.model_query_vip_lb_base_info_response)
    self.lister["model_vip_lb_base_info_change_msg"] = basefunc.handler(self, self.model_vip_lb_base_info_change_msg)
    self.lister["model_query_one_task_data_response_vip_gift"] = basefunc.handler(self, self.model_query_one_task_data_response_vip_gift)
    self.lister["model_task_change_msg_vip_gift"] = basefunc.handler(self, self.model_task_change_msg_vip_gift)
	self.lister["model_finish_gift_shop"] = basefunc.handler(self, self.on_model_finish_gift_shop)
    self.lister["model_receive_pay_order"] = basefunc.handler(self, self.on_model_receive_pay_order)
end

function M:AddMsgListener()
    for proto_name, func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function M:RemoveListener()
    for proto_name, func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function M:model_query_vip_lb_base_info_response()
    dump(data, "<color=green>model_query_vip_lb_base_info_response</color>")
    self:MyRefresh()
end

function M:model_vip_lb_base_info_change_msg()
    dump(data, "<color=green>model_vip_lb_base_info_change_msg</color>")
    self:MyRefresh()
end

function M:model_query_one_task_data_response_vip_gift(data)
    dump(data, "<color=green>model_query_one_task_data_response_vip_gift</color>")
    if data then
        self:RefreshTaskUI(data.task_id)
    end
end

function M:model_task_change_msg_vip_gift(data)
    dump(data, "<color=green>model_task_change_msg_vip_gift</color>")
    if data then
        self:RefreshTaskUI(data.id)
    end
end

--************方法
--未购买
function M:InitNotPayUI()
    local bd = VIPGiftModel.GetTaskBaseDataByID() 
    local cfg = VIPGiftModel.GetConfigDataByType("not_pay")
    if bd and cfg then
        self.pay_txt.text = string.format( "%s元购买",cfg.price / 100)
        self.rem_txt.text =  string.format( "剩余数量：%s份",bd.remain)
        self.vip_gift_txt.text =  string.format(cfg.desc)
        self.fl1_title_txt.text =  string.format(cfg.title_1)
        self.fl1_award_txt.text =  string.format(cfg.desc_1)
        self.fl1_icon_img.sprite = GetTexture(cfg.icon_1)
        self.fl2_title_txt.text =  string.format(cfg.title_2)
        self.fl2_award_txt.text =  string.format(cfg.desc_2)
        self.fl2_icon_img.sprite = GetTexture(cfg.icon_2)
    end
    self.pay_btn.onClick:AddListener(
        function()
            ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
            --购买vip
            self:CreateUIPayType()
        end
    )
end

function M:BuyGiftBox(goodsId)
    if GameGlobalOnOff.PGPay and gameRuntimePlatform == "Ios" then
        GameManager.GotoUI({gotoui = "sys_service_gzh",goto_scene_parm = "panel",desc="请关注“%s”公众号领取VIP礼包"})
    else
        local goodsData = MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, goodsId)
        dump(goodsData, "<color=yellow>goodsData:>>>></color>")
        local price = "￥" .. (tonumber(goodsData.price) / 100)
        PayTypePopPrefab.Create(goodsData.id, price)
    end
end

--购买--------------------------
function M:CreateUIPayType()
    self:BuyGiftBox(VIPGiftModel.GetGiftBagGoodsID())
end

function M:CreateUIPaySuccess()
    UIPaySuccess.Create()
end

function M:on_model_finish_gift_shop(id)
    self:CreateUIPaySuccess()
    self:MyRefresh()
end

function M:on_model_receive_pay_order(msg)
    dump(msg, "<color=green>on_model_receive_pay_order</color>")
	if msg.result == 0 then
		print("<color=green>购买礼包成功</color>")
	else
		HintPanel.ErrorMsg(msg.result)
	end
end

--已购买
function M:PayUI()
    local pay_config = VIPGiftModel.GetConfigDataByType("pay")
    self.qys_obj = {} 
    LuaHelper.GeneratingVar(self.TaskQYS, self.qys_obj)
    self:SetTask(VIPGiftModel.GetTaskConfig(VIPGiftModel.TaskID.qys),VIPGiftModel.GetTaskBaseDataByID(VIPGiftModel.TaskID.qys),self.qys_obj)
    self.fishing_obj = {}
    LuaHelper.GeneratingVar(self.TaskFishing, self.fishing_obj)
    self:SetTask(VIPGiftModel.GetTaskConfig(VIPGiftModel.TaskID.fishing),VIPGiftModel.GetTaskBaseDataByID(VIPGiftModel.TaskID.fishing),self.fishing_obj)
end

function M:SetTask(cfg,data,obj)
    if not cfg or not data or not obj then return end
    self:SetTaskUI(cfg,data,obj)
end

function M:SetTaskUI(cfg,data,obj)
    obj.icon_img.sprite = GetTexture(cfg.icon)
    if cfg.task_id == VIPGiftModel.TaskID.qys then
        obj.title_txt.text = string.format(cfg.title)
    elseif cfg.task_id == VIPGiftModel.TaskID.qys then
        obj.title_txt.text = string.format(cfg.title,0,0)
    end
    obj.award_txt.text = string.format(cfg.award)
    obj.remain_txt.text = string.format( cfg.remain,data.get_num,data.max_num) 

    PointerEventListener.Get(obj.get_end_btn.gameObject).onDown = function()
        GameTipsPrefab.ShowDesc(cfg.get_end_tips,UnityEngine.Input.mousePosition)
    end
    PointerEventListener.Get(obj.get_end_btn.gameObject).onUp = function()
        GameTipsPrefab.Hide()
    end

    PointerEventListener.Get(obj.over_btn.gameObject).onDown = function()
        GameTipsPrefab.ShowDesc(cfg.over_tips,UnityEngine.Input.mousePosition)
    end
    PointerEventListener.Get(obj.over_btn.gameObject).onUp = function()
        GameTipsPrefab.Hide()
    end

    obj.get_btn.onClick:RemoveAllListeners()
    obj.get_btn.onClick:AddListener(
        function()
            Network.SendRequest("get_task_award", {id = cfg.task_id})
        end
    )

    obj.goto_btn.onClick:RemoveAllListeners()
    obj.goto_btn.onClick:AddListener(
        function()
            ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
            GameManager.GotoUI({gotoui=cfg.gotoUI[1], goto_scene_parm=cfg.gotoUI[2], call=function ()
                M.Close()
            end})
        end
    )
end

function M:RefreshTaskUI(id)
    local data = VIPGiftModel.GetTaskDataByID(id)
    local cfg = VIPGiftModel.GetTaskConfig(id)
    local bd = VIPGiftModel.GetTaskBaseDataByID(id)
    local obj = {}
    if id == VIPGiftModel.TaskID.qys then
        obj = self.qys_obj
        if not obj or not next(obj) then
            LuaHelper.GeneratingVar(self.TaskQYS, self.obj)
        end
    elseif id == VIPGiftModel.TaskID.fishing then
        obj = self.fishing_obj
        if not obj or not next(obj) then
            LuaHelper.GeneratingVar(self.TaskFishing, self.obj)
        end
        if data then
            obj.title_txt.text = string.format(cfg.title,StringHelper.ToCash(data.need_process),StringHelper.ToCash(data.now_process))
        end
    end
    dump(data, "<color=yellow>M:RefreshTaskUI->id:" .. id .. ", data:</color>")
    if obj and bd then
        obj.get_end_btn.gameObject:SetActive(false)
        obj.get_btn.gameObject:SetActive(false)
        obj.goto_btn.gameObject:SetActive(false)
        if data then
            if data.award_status == 2 then
                obj.get_end_btn.gameObject:SetActive(true)
            elseif data.award_status == 1 then
                obj.get_btn.gameObject:SetActive(true)
            elseif data.award_status == 0 then
                obj.goto_btn.gameObject:SetActive(true)
            end
        end
        obj.remain_txt.text = string.format(cfg.remain,bd.get_num,bd.max_num)
        obj.over_btn.gameObject:SetActive(bd.get_num == bd.max_num)
    end
end

function M:RefreshBase(bd)
    if not bd then return end
    if bd.task_overdue_time then
        self.task_time_txt.text = string.format("任务有效时间：%s", StringHelper.formatTimeDHMS( bd.task_overdue_time - os.time()))
    end
    self.rem_txt.text =  string.format( "剩余数量：%s份",bd.remain)
    self:RefreshTaskUI(VIPGiftModel.TaskID.qys)
    self:RefreshTaskUI(VIPGiftModel.TaskID.fishing)
end

function M:UpdateCountdown()
    local bd = VIPGiftModel.GetTaskBaseDataByID()
    if not bd then return end
    local countdown = bd.task_overdue_time - os.time()
    if countdown < 0 then return end
    self.task_time_txt.text = string.format("任务有效时间：%s", StringHelper.formatTimeDHMS(countdown))
end

--OnClick**********************************
function M:OnClickClose(go)
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    Event.Brocast("close_vip_gift")
end