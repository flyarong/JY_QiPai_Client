-- 创建时间:2020-05-12
-- Panel:Act_056_WYFLBeforeBuyPanel
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

Act_056_WYFLBeforeBuyPanel = basefunc.class()
local C = Act_056_WYFLBeforeBuyPanel
C.name = "Act_056_WYFLBeforeBuyPanel"
M = Act_056_WYFLManager
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
	self.lister["ExitScene"] = basefunc.handler(self,self.MyExit)
	self.lister["model_wyfl_qfxl_num_change_msg"] = basefunc.handler(self,self.on_model_wyfl_qfxl_num_change_msg)
end

function C:RemoveListener()
	for proto_name,func in pairs(self.lister) do
		Event.RemoveListener(proto_name, func)
	end
	self.lister = {}
end

function C:MyExit()
	if self.seq then
		self.seq:Kill()
		self.seq = nil
	end
	M.update_time_QFXL(false)
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:ctor(parent)
	local parent = parent or GameObject.Find("Canvas/GUIRoot").transform
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
	EventTriggerListener.Get(self.buy_btn.gameObject).onClick = basefunc.handler(self, self.OnBuyClick)
	if M.GetQFXLNum() > 0 then
		self.seq = DoTweenSequence.Create()
		self.on_Sale.transform.localPosition = Vector3.New(206,90,0)
		self.seq:Append(self.on_Sale.transform:DOLocalMove(Vector3.New(160,56),0.6):SetEase(DG.Tweening.Ease.Linear))
		self.seq:Append(self.on_Sale.transform:DOLocalMove(Vector3.New(206,90,0),0.6):SetEase(DG.Tweening.Ease.Linear))
		self.seq:SetLoops(-1, DG.Tweening.LoopType.Yoyo)
	end
	M.update_time_QFXL(true)
	self:on_model_wyfl_qfxl_num_change_msg()
	self.transform:Find("TXT/Text (3)"):GetComponent("Text").text = "每日登录可领4万鲸币,共计<color=#e33628><size=44>968万</size></color>鲸币"
end

function C:MyRefresh()
end


function C:on_model_wyfl_qfxl_num_change_msg()
	if M.GetQFXLNum() <= 0 then
		self.on_Sale.gameObject:SetActive(false)
		self.price_txt.text = "1298元领取"
		self.qfxl_num_txt.gameObject:SetActive(false)
	else
		self.on_Sale.gameObject:SetActive(true)
		self.price_txt.text = "648元领取"
		self.qfxl_num_txt.text = "限时折扣,再售<color=#e33628>"..M.GetQFXLNum().."</color>份,恢复1298元"
	end
end

function C:OnBuyClick()
	if M.GetQFXLNum() <= 0 then
		self:BuyShop(M.shopid2)
	else
		self:BuyShop(M.shopid1)
	end
end

function C:BuyShop(shopid)
	dump(shopid)
	local price = MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, shopid).price
	dump(MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, shopid))
	if  GameGlobalOnOff.PGPay and gameRuntimePlatform == "Ios" then
		ServiceGzhPrefab.Create({desc="请前往公众号获取"})
	else
		PayTypePopPrefab.Create(shopid, "￥" .. (price / 100))
	end
end