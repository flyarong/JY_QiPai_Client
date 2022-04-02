-- 创建时间:2021-06-01
-- Panel:Act_058_JRLBPanel
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
 -- 取消按钮音效
 -- ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
 -- 确认按钮音效
 -- ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
 --]]

local basefunc = require "Game/Common/basefunc"

Act_058_JRLBPanel = basefunc.class()
local C = Act_058_JRLBPanel
local M = Act_058_JRLBManager
C.name = "Act_058_JRLBPanel"
C.item_name = "Act_058_JRLBItem"

function C.Create(parent)
	return C.New(parent)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
	self.lister["gift_bag_status_change_msg"] = basefunc.handler(self,self.on_gift_bag_status_change_msg)
	self.lister["model_task_change_msg"] = basefunc.handler(self, self.on_model_task_change_msg)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	if self.huxiMrlb then
		self.huxiMrlb:Stop()
		self.huxiMrlb = nil
	end
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:OnDestroy()
	self:MyExit()
end

function C:MyClose()
	self:MyExit()
end

function C:ctor(parent)
	ExtPanel.ExtMsg(self)
	local parent = parent or GameObject.Find("Canvas/LayerLv4").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	self.lv = M.GetLv()
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	self:InitItemPrefab()
	self:MyRefresh()
	CommonTimeManager.GetCutDownTimer(M.endTime, self.remain_txt)
	CommonHuxiAnim.Start(self.buy_all_btn.gameObject,1)

	self.mrlb_btn.onClick:AddListener(function()
		Network.SendRequest("get_task_award",{id = M.mrlb_task})
	end)
end

function C:InitItemPrefab()
	self.item_pre = {}
	local b
	for i = 1, 3 do
		b = newObject(C.item_name, self["rect_" .. i])
		self.item_pre[i] = b
	end
	b = nil
end

function C:MyRefresh()
	self.cfg = M.GetCurCfg()
	self:RefreshGiftsUI()
	self:RefreshBuyAllUI()
	self:RefreshMrlb()
end

local function ViewBuyBtn(parm)
	local refresh_buy = function (is_can_buy)
		parm.buy_btn.gameObject:SetActive(is_can_buy and parm.check_buy)
		--parm.no_buy_gray.gameObject:SetActive(not is_can_buy or not parm.check_buy)
		parm.no_buy_gray.gameObject:SetActive(not parm.buy_btn.gameObject.activeSelf)
	end
	local data = MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, parm.gift_id)
	if not data then
		refresh_buy(false)
		return
	end
	local price = data.price / 100
	local data_status = MainModel.GetGiftShopStatusByID(parm.gift_id)
	refresh_buy(data_status == 1)
	parm.buy_txt_obj.text = price .. parm.buy_ex_txt
	if parm.buy_txt_obj_1 then
		parm.buy_txt_obj_1.text = price .. parm.buy_ex_txt
	end
	refresh_buy, data, price, data_status = nil
end

local function BuyGift(gift_id)
	local data = MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, gift_id)
	if not data then
		HintPanel.Create(1, "未获取到商品数据")
		return
	end
	local isInTime = MathExtend.isTimeValidity(data.start_time, data.end_time)
	if not isInTime then
		HintPanel.Create(1, "抱歉，此商品不在售卖时间内")
		return
	end
	local gift_status = MainModel.GetGiftShopStatusByID(gift_id)
	if gift_status ~= 1 then
		local s1 = os.date("%m月%d日%H点", data.start_time)
		local e1 = os.date("%m月%d日%H点", data.end_time)
		HintPanel.Create(1, string.format( "您今日已购买过了，请明日再来购买。", s1, e1))
		s1 ,e1 = nil
		return
	end
	if GameGlobalOnOff.PGPay and gameRuntimePlatform == "Ios" then
		GameManager.GotoUI({gotoui = "sys_service_gzh", goto_scene_parm = "panel", desc = "请前往公众号获取"})
	else
		PayTypePopPrefab.Create(gift_id, "￥" .. (data.price / 100))
	end	
	data, isInTime, gift_status = nil
end

local function CheckCanBuyAll(gift_id_a, gift_id_b, gift_id_c)
	local ids = {gift_id_a, gift_id_b, gift_id_c}
	for i = 1, #ids do
		if MainModel.GetGiftShopStatusByID(ids[i]) ~= 1 then
			ids = nil
			return false
		end
	end
	ids = nil
	return true
end

local function CheckBuySingle(gift_id_all)
	return not (MainModel.GetGiftShopStatusByID(gift_id_all) ~= 1)
end

local BoxTip = {
	[1] = {"稀有宝箱", "周年庆期间开启，最高可得5元福卡！"},
	[2] = {"稀有宝箱", "周年庆期间开启，最高可得5元福卡！"},
	[3] = {"史诗宝箱", "周年庆期间开启，最高可得10元福卡！"},
	[4] = {"传说宝箱", "周年庆期间开启，最高可得20元福卡！"},
}

function C:RefreshGiftsUI()
	for i = 1, #self.item_pre do
		local b_ui = {}
		LuaHelper.GeneratingVar(self.item_pre[i].transform, b_ui)
		local cfg_txt = self.cfg["gift_" .. i .. "_txt"]
		local cfg_icon = self.cfg["gift_" .. i .. "_icon"]
		local cfg_gift_id = self.cfg.gift_ids[i]
		for j = 1, 4 do
			b_ui["award_" .. j .. "_img"].sprite = GetTexture(cfg_icon[j])
			if j == 1 then
				b_ui["award_" .. j .. "_txt"].text = "x" .. StringHelper.ToCash(cfg_txt[j])
			elseif j == 2 then
				--特殊处理
				b_ui["award_" .. j .. "_txt"].text = cfg_txt[j]
				local _trans = b_ui.award_2_tip_btn.transform
				b_ui.award_2_tip_btn.onClick:RemoveAllListeners()
				b_ui.award_2_tip_btn.onClick:AddListener(function()
					local data = GameItemModel.GetItemToKey("prop_xxl_card_chip_1")
					LTTipsPrefab.Show2(_trans, BoxTip[self.lv][1], BoxTip[self.lv][2])
				end)
			else
				b_ui["award_" .. j .. "_txt"].text = cfg_txt[j]
			end
		end
		local _parm = {
			gift_id = cfg_gift_id,
			buy_btn = b_ui.buy_btn,
			no_buy_gray = b_ui.buy_no_img,
			buy_txt_obj = b_ui.buy_txt,
			buy_txt_obj_1 = b_ui.buy_no_txt,
			buy_ex_txt = "元领取",
			check_buy = CheckBuySingle(self.cfg.gift_ids[4]),
		}
		ViewBuyBtn(_parm)
		b_ui.buy_btn.onClick:RemoveAllListeners()
		b_ui.buy_btn.onClick:AddListener(function ()
			BuyGift(self.cfg.gift_ids[i])
		end)
		b_ui, cfg_txt, cfg_icon, cfg_gift_id, _parm= nil
	end
	self.buy_all_give_txt.text = "多送" .. self.cfg.buy_all_give
end

function C:RefreshBuyAllUI()
	local _parm = {
		gift_id = self.cfg.gift_ids[4],
		buy_btn = self.buy_all_btn,
		no_buy_gray = self.buy_all_btn_gray,
		buy_txt_obj = self.buy_all_txt,
		buy_txt_obj_1 = self.buy_all_no_txt,
		buy_ex_txt = "元全购",
		check_buy = CheckCanBuyAll(self.cfg.gift_ids[1], self.cfg.gift_ids[2], self.cfg.gift_ids[3]),
	}
	ViewBuyBtn(_parm)
	self.buy_all_btn.onClick:RemoveAllListeners()
	self.buy_all_btn.onClick:AddListener(function ()
		BuyGift(self.cfg.gift_ids[4])
	end)
	_parm = nil
end

function C:on_gift_bag_status_change_msg(_, data)
	if data.result ~= 0 then
        return
    end
    local gift_ids = M.GetCurCfg()
    for i = 1, #gift_ids do
        if gift_ids[i] == data.gift_bag_id then
            M.InitConfig()
			self:MyRefresh()
            break
        end
    end
end

--明日礼包
function C:RefreshMrlb()
	local taskData = GameTaskModel.GetTaskDataByID(M.mrlb_task)
	if taskData then
		self.mrlb_gray.gameObject:SetActive(taskData.award_status ~= 1)
		self.mrlb_btn.gameObject:SetActive(taskData.award_status == 1)
		if taskData.award_status == 1 then
			self.huxiMrlb = CommonHuxiAnim.Go(self.mrlb_img.gameObject)
			self.huxiMrlb:Start()
		end
		if taskData.award_status ~= 1 and self.huxiMrlb then
			self.huxiMrlb:Stop()
			self.huxiMrlb = nil
		end
	end
end

function C:on_model_task_change_msg(data)
	if data and data.id == M.mrlb_task then
		self:RefreshMrlb()
		Event.Brocast("global_hint_state_change_msg",{gotoui = M.key })
	end
end