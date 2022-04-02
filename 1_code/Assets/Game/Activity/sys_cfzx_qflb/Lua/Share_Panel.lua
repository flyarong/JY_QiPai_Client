-- 创建时间:2020-03-02
-- Panel:Share_Panel
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
 --]]

local basefunc = require "Game/Common/basefunc"

Share_Panel = basefunc.class()
local C = Share_Panel
C.name = "Share_Panel"
local title = {{"qflb_imgf_bt1","qflb_imgf_bt2",},{"qflb_imgf_bt3","qflb_imgf_bt2",},{"qflb_imgf_bt1","qflb_imgf_bt2",},}
local talk = {{"干得漂亮！\n恭喜您已成功领取<color=#ff0000><size=60><b>1元</b></size></color>！",},{"太棒了！\n恭喜您已成功领取<color=#ff0000><size=60><b>10元</b></size></color>！","恭喜您领完<color=#ff0000><size=60><b>100元</b></size></color>，续购<size=72>再领<color=#ff0000><b>100元</b></color></size>！",},{"真了不起！\n恭喜您已成功领取<color=#ff0000><size=60><b>5元</b></size></color>！","恭喜您领完<color=#ff0000><size=60><b>100元</b></size></color>，\n续购<size=72>再领<color=#ff0000><b>100元</b></color></size>！",},}
local fx_tips = {{"邀好友购买您得3元/人",},{"邀好友购买您得30元/人",},{"邀好友购买您得100元/人",},}
function C.Create(index)
	return C.New(index)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["ExitScene"] = basefunc.handler(self,self.MyExit)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	if self.backcall then 
		self.backcall()
	end
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:ctor(index)
	self.index = index
	local parent = GameObject.Find("Canvas/LayerLv5").transform
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
	self.share_btn.onClick:AddListener(
		function ()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
			local share_cfg = basefunc.deepcopy(share_link_config.img_qflb)
			GameManager.GotoUI({gotoui = "sys_fx",goto_scene_parm = "panel",share_cfg = share_cfg})
		end	
	)
	self.exit_btn.onClick:AddListener(
		function ()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
			self:MyExit()
		end	
	)
	self.no_see_no_run_btn.onClick:AddListener(
		function ()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
			self:MyExit()
		end	
	)
	self.buy_again_btn.onClick:AddListener(
		function ()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
			self:BuyAgain()
			self:MyExit()
		end	
	)
	self.data = MoneyCenterQFLBManager.get_data_all_return_lb_info()
	self.cfg = MoneyCenterQFLBManager.get_cfg()
	local i = "all_return_lb_"..self.index
	if self.data[i].is_buy == 1 then
		if i == "all_return_lb_1" then
			self:InitUI_LB1(i)
		elseif i == "all_return_lb_2" then
			self:InitUI_LB2(i)
		elseif i == "all_return_lb_3" then
			self:InitUI_LB3(i)
		end
	end


	self:MyRefresh()
end

function C:MyRefresh()
end


--全返礼包1
function C:InitUI_LB1(i)
	if 7 - self.data[i].remain_num <= 6 then--前6次
		self.title_img.sprite = GetTexture(title[self.index][1])
		self.talk_txt.text = talk[self.index][1]
		self.fx_tips_txt.text = fx_tips[self.index][1]
		self.no_see_no_run_btn.gameObject:SetActive(true)
		self.share_btn.gameObject:SetActive(true)
	else--第7次(最后一次)
		self.title_img.sprite = GetTexture(title[self.index][2])
		self.talk_txt.text = talk[self.index][1]
		self.fx_tips_txt.text = fx_tips[self.index][1]
		self.no_see_no_run_btn.gameObject:SetActive(false)
		self.share_btn.gameObject:SetActive(true)
		self.share_btn.transform.localPosition = Vector3.New(0,self.share_btn.transform.localPosition.y,0)
	end
end

--全返礼包2
function C:InitUI_LB2(i)
	if 10 - self.data[i].remain_num <= 9 then--前9次
		self.title_img.sprite = GetTexture(title[self.index][1])
		self.talk_txt.text = talk[self.index][1]
		self.fx_tips_txt.text = fx_tips[self.index][1]
		self.no_see_no_run_btn.gameObject:SetActive(true)
		self.share_btn.gameObject:SetActive(true)
	else--第10次(最后一次)
		self.title_img.sprite = GetTexture(title[self.index][2])
		self.talk_txt.text = talk[self.index][2]
		self.fx_tips_txt.text = fx_tips[self.index][1]
		self.no_see_no_run_btn.gameObject:SetActive(false)
		self.share_btn.gameObject:SetActive(true)
		self.buy_again_btn.gameObject:SetActive(true)
	end
end

--全返礼包3
function C:InitUI_LB3(i)
	if 20 - self.data[i].remain_num <= 19 then--前19次
		self.title_img.sprite = GetTexture(title[self.index][1])
		self.talk_txt.text = talk[self.index][1]
		self.fx_tips_txt.text = fx_tips[self.index][1]
		self.no_see_no_run_btn.gameObject:SetActive(true)
		self.share_btn.gameObject:SetActive(true)
	else--第20次(最后一次)
		self.title_img.sprite = GetTexture(title[self.index][2])
		self.talk_txt.text = talk[self.index][2]
		self.fx_tips_txt.text = fx_tips[self.index][1]
		self.no_see_no_run_btn.gameObject:SetActive(false)
		self.share_btn.gameObject:SetActive(true)
		self.buy_again_btn.gameObject:SetActive(true)
	end
end

--续购
function C:BuyAgain()
	id = self.cfg.qflb[self.index].good_id
	local a,b
	if id == self.cfg.qflb[1].good_id then
		a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key="actp_buy_gift_bag_" .. id, is_on_hint = true}, "CheckCondition")
		if a and not b then 
			QFLBSharePanel.Create(nil,{title = "",tips = "全返礼包I仅限新人购买哦！\n<size=40>邀请好友购买立赚<color=#ea1e1e>3元。</color></size>"})
			return
		end
		if not a then
			LittleTips.Create("发生未知错误")
			return
		end
	end

	local gift_config = MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, id)
	local status = MainModel.GetGiftShopStatusByID(gift_config.id)
    local b1 = MathExtend.isTimeValidity(gift_config.start_time, gift_config.end_time)
    if b1 then
		if status ~= 1 then
			LittleTips.Create("请重新登录后购买")
			return
		end
    else
		LittleTips.Create("抱歉，此商品不在售卖时间内")
		return
    end
    
	if GameGlobalOnOff.PGPay and gameRuntimePlatform == "Ios" then
		GameManager.GotoUI({gotoui = "sys_service_gzh",goto_scene_parm = "panel",desc="请前往公众号获取"})
	else
		PayTypePopPrefab.Create(gift_config.id, "￥" .. (gift_config.price / 100))
	end
end

--[[
	GetTexture("qflb_imgf_bt2")
	GetTexture("qflb_imgf_bt3")
	GetTexture("qflb_btn_2")
	GetTexture("qflb_btn_3")
	GetTexture("qflb_btn_99")
	GetTexture("qflb_btn_99-1")
	GetTexture("qflb_btn_199")
	GetTexture("qflb_btn_199-1")
	GetTexture("qflb_btn_499")
	GetTexture("qflb_btn_499-1")
	GetTexture("qflb_imgf_qf2")
	GetTexture("qflb_imgf_qf3")
]]