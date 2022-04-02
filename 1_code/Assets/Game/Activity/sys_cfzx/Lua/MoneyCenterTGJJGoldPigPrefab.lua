-- 创建时间:2018-12-21

local basefunc = require "Game.Common.basefunc"

MoneyCenterTGJJGoldPigPrefab = basefunc.class()

local C = MoneyCenterTGJJGoldPigPrefab

C.name = "MoneyCenterTGJJGoldPigPrefab"

function C.Create(parent_transform, config, call)
	return C.New(parent_transform, config, call)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["model_query_goldpig_task_data_response"] = basefunc.handler(self, self.on_task_req_data_response)
    self.lister["model_get_goldpig_task_award_response"] = basefunc.handler(self, self.on_get_goldpig_task_award_response)
    self.lister["model_goldpig_task_change_msg"] = basefunc.handler(self, self.on_goldpig_task_change_msg)

    self.lister["model_query_goldpig_task_remain_response"] = basefunc.handler(self, self.model_query_goldpig_task_remain_response)
    self.lister["model_goldpig_task_remain_change_msg"] = basefunc.handler(self, self.model_goldpig_task_remain_change_msg)
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
end

function C:ctor(parent_transform, config, call)
    self.config = config
	self.config_pig_task = GoldenPigModel.GetConfigDataByType()
	self.call = call
	local obj = newObject(C.name, parent_transform)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj

	self:MakeLister()
	self:AddMsgListener()
    LuaHelper.GeneratingVar(self.transform, self)
    self:InitUI()
    self:MyRefresh()
end

function C:InitUI()
    self.icon_img.sprite = GetTexture(self.config.icon)
    self.icon_img:SetNativeSize()
    self:SetTask(self.config_pig_task.config.config)
end

function C:MyRefresh()
    GoldenPigModel.ReqTaskData()
    GoldenPigModel.ReqTaskRemain()
end

-----任务
function C:on_task_req_data_response()
    local task_id = self.config_pig_task.config.config.task_id
    self:RefreshTaskUI(task_id)
end

function C:on_get_goldpig_task_award_response(data)
    self:RefreshTaskUI(data.id)
    local config = self.config_pig_task.config.config
    local tips = string.format( "%s元奖金",config.task_award / 100)
    LittleTips.Create(tips)
    self:MyRefresh()
    --刷新我的奖金
end

function C:on_goldpig_task_change_msg(data)
    self:RefreshTaskUI(data.id)
end

function C:model_query_goldpig_task_remain_response()
    self:RefreshTaskRemain()
end

function C:model_goldpig_task_remain_change_msg()
    self:RefreshTaskRemain()
end
-----------------

function C:SetTask(config)
    if config == nil then return end
    self:SetTaskUI(config)
end

function C:SetTaskUI(config)
    self.task_money_txt.text = string.format( "%s",config.task_award / 100)
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
        local tips = "您当日奖励已领取，请明日6点再来"
        GameTipsPrefab.ShowDesc(tips, pos)
    end
    PointerEventListener.Get(self.over_btn.gameObject).onUp = function()
        GameTipsPrefab.Hide()
    end

    self.get_btn.onClick:AddListener(
        function()
            Network.SendRequest("get_goldpig_task_award", {id = config.task_id})
        end
    )

    self.goto_btn.onClick:AddListener(
        function()
            ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
            GameFreeModel.RapidBeginGameLevel(2)
        end
    )

    self.activation_btn.onClick:AddListener(
        function()
            ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
            Event.Brocast("open_golden_pig")
        end
    )
    self.slider =self.Slider:GetComponent("Slider")
end

function C:RefreshTaskUI(id)
    local data = GoldenPigModel.GetTaskDataByID(id)
    if IsEquals(self.activation_btn) then
        self.activation_btn.gameObject:SetActive(false)
    end
    self.over_btn.gameObject:SetActive(false)
    self.get_btn.gameObject:SetActive(false)
    self.goto_btn.gameObject:SetActive(false)
    if data then
        local now_process = data.now_process
        local need_process = data.need_process
        self.progress_txt.text = now_process .. "/" .. need_process
       
        local process = now_process / need_process
        if process > 1 then
            process = 1
        end
        self.slider.value = process == 0 and 0 or 0.95 * process + 0.05

        if data.award_status == 2 then
            self.over_btn.gameObject:SetActive(true)
        elseif data.award_status == 1 then
            self.get_btn.gameObject:SetActive(true)
        elseif data.award_status == 0 then
            self.goto_btn.gameObject:SetActive(true)
        end
    else
        self.activation_btn.gameObject:SetActive(true)
        self.progress_txt.text = "未激活"
        self.slider.value = 0
    end
end

function C:RefreshTaskRemain()
    local remain = GoldenPigModel.GetTaskRemain()
    self.gift_status = MainModel.GetGiftShopStatusByID(GoldenPigModel.GetGiftBagGoodsID())
    if self.gift_status == 1 then
        if IsEquals(self.activation_btn) then
            self.activation_btn.gameObject:SetActive(true)
        end
        self.get_btn.gameObject:SetActive(false)
        self.goto_btn.gameObject:SetActive(false)
        self.over_btn.gameObject:SetActive(false)
        self.remain_over_btn.gameObject:SetActive(false)
    else
        if remain and remain > 0 then 
            if IsEquals(self.get_num_txt) then
                self.get_num_txt.text = string.format( "（还可领%s次）",remain)
            end
        elseif remain and remain == 0 then
            if IsEquals(self.get_num_txt) then
                self.get_num_txt.text = string.format( "（已领完）")
            end
            self.slider.value = 1
            self.progress_txt.text = "已完成"
            self.activation_btn.gameObject:SetActive(false)
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
end