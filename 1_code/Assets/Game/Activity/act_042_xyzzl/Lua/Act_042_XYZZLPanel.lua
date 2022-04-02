-- 创建时间:2020-12-08
-- Panel:Act_042_XYZZLPanel
--[[ *      ┌─┐       ┌─┐
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
 -- 取消按钮音效
 -- ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
 -- 确认按钮音效
 -- ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
 --]]
local basefunc = require "Game/Common/basefunc"

Act_042_XYZZLPanel = basefunc.class()
local C = Act_042_XYZZLPanel
C.name = "Act_042_XYZZLPanel"
local M = Act_042_XYZZLManager

local instance

local award_pos = {
    [1] = { x = 162, y = 170, z = 0 },
    [2] = { x = 248, y = 0, z = 0 },
    [3] = { x = 162, y = -152, z = 0 },
    [4] = { x = 0, y = -210, z = 0 },
    [5] = { x = -161, y = -143, z = 0 },
    [6] = { x = -232, y = 0, z = 0 },
    [7] = { x = -164, y = 174, z = 0 },
    [8] = { x = 0, y = 240, z = 0 },
}

function C.Create()
    if not instance then
        instance = C.New()
    end
    return instance
end

function C:AddMsgListener()
    for proto_name, func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["ExitScene"] = basefunc.handler(self, self.MyExit)
    self.lister["AssetChange"] = basefunc.handler(self, self.OnAssetChange)
    self.lister["model_task_change_msg"] = basefunc.handler(self,self.on_task_change_msg)  
    self.lister["box_exchange_response"] = basefunc.handler(self, self.on_box_exchange_response)
    self.lister["shop_info_get"] = basefunc.handler(self, self.on_shop_info_get)
    self.lister["EnterBackGround"] = basefunc.handler(self, self.MyExit)
end

function C:RemoveListener()
    for proto_name, func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()

    if self.cur_award then
        Event.Brocast("AssetGet", self.cur_award)
        self.cur_award = nil
    end
    M.SetHintState()

    instance = nil
    self:RemoveListener()
    destroy(self.gameObject)
end

function C:ctor(parent, backcall)
    ExtPanel.ExtMsg(self)
    local parent = parent or GameObject.Find("Canvas/LayerLv4").transform
    local obj = newObject(C.name, parent)
    local tran = obj.transform
    self.transform = tran
    self.gameObject = obj
    LuaHelper.GeneratingVar(self.transform, self)

    self:MakeLister()
    self:AddMsgListener()
    self:InitUI()
end

function C:InitUI()

    self.zhizhenAnim = self.zhizhen.transform:GetComponent("Animator")
    self.zhizhenAnim.speed = 0

    self:InitGiftsUI()
    self:InitLotteryUI()
    self:RefreshCJQ()

    self.close_btn.onClick:AddListener(function()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        self:MyExit()
    end)
    self.rule_btn.onClick:AddListener(function()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        self:OpenHelpPanel()
    end)

    self.cj1_btn.onClick:AddListener(function()
        self:OnLotteryOnce()
    end)

    self.cj10_btn.onClick:AddListener(function()
        self:OnLotteryTen()
    end)

    if PlayerPrefs.GetInt(M.key ..MainModel.UserInfo.user_id.. "_award_index", 0) ~= 0 then
        local index = PlayerPrefs.GetInt(M.key ..MainModel.UserInfo.user_id.. "_award_index")
        self.zhizhen.localRotation = Quaternion:SetEuler( 0, 0, - 45 * index)
    end
end

function C:MyRefresh()
    self:RefreshLottery()
    self:RefreshGifts()
    --M.SetHintState()
end

function C:InitGiftsUI()
    self.gifts_cfg = M.GetAllGifts()
    self.gift_item.gameObject:SetActive(true)
    self:LoadGiftItem(self.gift_item, self.gifts_cfg[1])
    for i = 2, #self.gifts_cfg do
        local b = GameObject.Instantiate(self.gift_item, self.gift_content)
        self:LoadGiftItem(b, self.gifts_cfg[i])
    end
end

function C:LoadGiftItem(item, item_cfg)
	local temp_ui = {}
    LuaHelper.GeneratingVar(item.transform, temp_ui)
    temp_ui.jingbi_icon_img.sprite = GetTexture(item_cfg.gift_jingbi_icon)
    temp_ui.cjq_icon_img.sprite = GetTexture(item_cfg.gift_cjq_icon)
    temp_ui.jingbi_txt.text = "鲸币*" .. item_cfg.gift_jingbi
    temp_ui.cjq_txt.text = "抽奖券*" .. item_cfg.gift_cjq
    temp_ui.gift_price_txt.text = item_cfg.gift_price
    temp_ui.cannot_get.gameObject:SetActive(MainModel.GetRemainTimeByShopID(item_cfg.gift_id) == 0)
    temp_ui.get_btn.onClick:RemoveAllListeners()
    temp_ui.get_btn.onClick:AddListener(function()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        self:BuyShop(item_cfg.gift_id)
    end)
end

function C:InitLotteryUI()
    local awards_cfg = M.GetAllAwards()

    self.award_item.gameObject:SetActive(true)
    self.award_item.transform.localPosition = award_pos[1]
    self:LoadAwardItem(self.award_item, awards_cfg[1])

    for i = 2, #awards_cfg do
        local b = GameObject.Instantiate(self.award_item, self.awards)
        b.transform.localPosition = award_pos[i]
        self:LoadAwardItem(b, awards_cfg[i])
    end
end

function C:LoadAwardItem(item, item_cfg)
	local temp_ui = {}
    LuaHelper.GeneratingVar(item.transform, temp_ui)
    temp_ui.award_icon_img.sprite = GetTexture(item_cfg.award_icon)
    temp_ui.award_txt.text = item_cfg.award_content
end

function C:RefreshGiftsUI()
    if self.gift_content.transform.childCount ~= #M.GetAllGifts() then return end
    for i = 1, self.gift_content.transform.childCount do
        local g_item = self.gift_content.transform:GetChild(i - 1)
        self:LoadGiftItem(g_item, M.GetCurGift(i))
    end
end

function C:RefreshCJQ()
	--dump(MainModel.GetItemCount(M.cjq_key),"<color=white>抽奖券数量</color>")
    self.cjq_num_txt.text = MainModel.GetItemCount(M.cjq_key)
end

function C:BuyShop(shopid)
    local gb = MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, shopid)
    if not gb then return end
    local price = gb.price
    if GameGlobalOnOff.PGPay and gameRuntimePlatform == "Ios" then
        ServiceGzhPrefab.Create({ desc = "请前往公众号获取" })
    else
        PayTypePopPrefab.Create(shopid, "￥" .. (price / 100))
    end
end

function C:OnLotteryOnce()
    self:OnLottery(1)
end

function C:OnLotteryTen()
    self:OnLottery(10)
end

function C:OnLottery(time)
    if self.is_during_anim then
        LittleTips.Create("正在抽奖...")
        return
    end
    if MainModel.GetItemCount(M.cjq_key) >= time then
        --self:AnimaStart(1)
        Network.SendRequest("box_exchange", { id = M.change_id, num = time })
    else
        LittleTips.Create("抽奖券不足")
    end
end

function C:OpenHelpPanel()
    local str = M.help_info[1]
    for i = 2, #M.help_info do
        str = str .. "\n" .. M.help_info[i]
    end
    self.introduce_txt.text = str
    IllustratePanel.Create({ self.introduce_txt.gameObject }, GameObject.Find("Canvas/LayerLv5").transform)
end

function C:AnimaStart(index)

    if not self.is_during_anim then
        self.curSoundKey = ExtendSoundManager.PlaySound(audio_config.game.bgm_duijihongbao.audio_name, 1, function()
            self.curSoundKey = nil
        end)
        self.is_during_anim = true
        self.zhizhenAnim:Play("act_004JIKAPanel_zhizhen", -1,0);
        self.zhizhenAnim.speed = 0
        self.zhizhen.gameObject:SetActive(true)
        local rota = -360 * 16 - 45 * index 
        local seq = DoTweenSequence.Create()
        seq:Append(self.zhizhen:DORotate(Vector3.New(0, 0, rota), 6, DG.Tweening.RotateMode.FastBeyond360):SetEase(DG.Tweening.Ease.InOutCubic))
        seq:OnKill(function()
            if IsEquals(self.gameObject) then
                self.zhizhen.localRotation = Quaternion:SetEuler(0, 0, rota)
                self:CloseAnimSound()
                self:AnimaEnd()
            end
        end)
    else
        LittleTips.Create("正在抽奖...")
    end
end

function C:AnimaEnd()
    self.zhizhenAnim.speed = 1
    self.de_timer = Timer.New(function()
        self.zhizhenAnim:Play("act_004JIKAPanel_zhizhen", -1,0);
        self.zhizhenAnim:Update(0)
        self.zhizhenAnim.speed = 0
        if self.cur_award then
            Event.Brocast("AssetGet", self.cur_award)
            self.cur_award = nil
        end
        self.is_during_anim = false
    end, 1.4, 1)
    self.de_timer:Start()
end

function C:CloseAnimSound()
    if self.curSoundKey then
        soundMgr:CloseLoopSound(self.curSoundKey)
        self.curSoundKey = nil
    end
end

function C:on_box_exchange_response(_, data)
    dump(data, "<color=red>----------抽奖数据-----------</color>")
    if data and data.result == 0 and data.id == M.change_id then
        local index = M.GetAwardIndex(data.award_id[1])
        --Event.Brocast("AssetGet", self.cur_award)
        if index then
            PlayerPrefs.SetInt(M.key ..MainModel.UserInfo.user_id.. "_award_index", index)
            self:AnimaStart(index)
        end
    else
        LittleTips.Create(errorCode[data.result] or "错误：" .. data.result)
    end
end

function C:OnAssetChange(data)
    dump(data, "<color=red>-----奖励类型-----</color>")
    if data.change_type and data.change_type == "box_exchange_active_award_121" then
        self.cur_award = data
        self.cur_award.data  = M.MultAwardTab(data.data)
    end
	self:RefreshGiftsUI()
    self:RefreshCJQ()
    
end

function C:on_shop_info_get()
    self:RefreshGiftsUI()
end

function C:on_task_change_msg(data)
	--self:RefreshGiftsUI()
end