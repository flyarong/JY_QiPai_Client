-- 创建时间:2020-04-13
-- Panel:act_009ItemBase
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

act_009ItemBase = basefunc.class()
local C = act_009ItemBase
C.name = "act_009ItemBase"

function C.Create(parent,data)
	return C.New(parent,data)
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

function C:MyExit()
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:ctor(parent,data)
	dump(data,"<color=yellow>++++++++++++++++++++++++++</color>")
	self.data = data
	local parent = parent or GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self.ani_blue = self.blue_btn.transform:GetComponent("Animator")

	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	EventTriggerListener.Get(self.blue_btn.gameObject).onClick = basefunc.handler(self, self.sun_is_enough2buy)
	EventTriggerListener.Get(self.yellow_btn.gameObject).onClick = basefunc.handler(self, self.sun_is_no_enough)

	if self.data[2] == 10191 or self.data[2] == 10196 then
		self.finger.gameObject:SetActive(true)
		self.yellow_btn.gameObject:SetActive(false)
		self.ani_blue:Play("blue_btn_ani",-1,0)
	end

	if  Act_009XYCDManager.GetSunCount() >= tonumber(self.data[6]) then
		self.yellow_btn.gameObject:SetActive(false)
		self.ani_blue:Play("blue_btn_ani",-1,0)
	end
	self.eggs_name_img.sprite = GetTexture(self.data[3])
	self.eggs_award_img.sprite = GetTexture(self.data[4])
	self.eggs_award_img:SetNativeSize()
	self.eggs_image_img.sprite = GetTexture(self.data[5])
	self.sun_cost_text_txt.text = self.data[6]
	self.blue_txt.text = self.data[7]
	self.yellow_txt.text = self.data[7]
	self.eggs_nameBG_img.sprite = GetTexture(self.data[8])
	if self.data[2] ~= 10191 and self.data[2] ~= 10196 then
		if Act_009XYCDManager.GetSunCount() < tonumber(self.data[6]) then
			if self.data[10] > 0 then
				self.blue_btn.gameObject:SetActive(false)
				self.yellow_btn.gameObject:SetActive(true)
			else
				self.blue_btn.gameObject:SetActive(false)
				self.yellow_btn.gameObject:SetActive(false)
			end
		else
			if self.data[10] > 0 then
				self.blue_btn.gameObject:SetActive(true)
				self.ani_blue:Play("blue_btn_ani",-1,0)
				self.yellow_btn.gameObject:SetActive(false)
			else
				self.blue_btn.gameObject:SetActive(false)
				self.yellow_btn.gameObject:SetActive(false)
			end
		end
	end

	self:MyRefresh()
end

function C:MyRefresh()

end

function C:sun_is_no_enough()
	HintPanel.Create(1, "阳光能量不足")
end

function C:sun_is_enough2buy()
	if	self.data[1]==Act_009XYCDManager.config.Info[Act_009XYCDManager.now_level][1].ID then
		self:Type_ID1()
	else
		self:BuyShop(self.data[2])
	end
end

function C:Type_ID1()
	dump(self.data,"体验彩蛋")
	if Act_009XYCDManager.GetSunCount() < tonumber(self.data[6]) then
		local panel = HintPanel.Create(1, "阳光能量不足,请前往小游戏赢金或充值", function()
			self:GotoMiniGame()
		end)
		panel:SetButtonText("前往")
	else
		self:Pay4Free(self.data[2])
	end
end

function C:GotoMiniGame()
	local gotoparm = {gotoui = "game_MiniGame"}
    GameManager.GotoUI(gotoparm)
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

function C:Pay4Free(shopid)
	goodsid = shopid
	local request = {}
    request.goods_id = goodsid
    request.channel_type = "weixin"
    request.geturl = MainModel.pay_url and "n" or "y"
    request.convert = self.convert
    dump(request, "<color=green>创建订单</color>")
    Network.SendRequest(
        "create_pay_order",
        request,
        function(_data)
            dump(_data, "<color=green>返回订单号</color>")
            if _data.result == 0 then
                MainModel.pay_url = _data.url or MainModel.pay_url
                local url = string.gsub(MainModel.pay_url, "@order_id@", _data.order_id)
            else
                HintPanel.ErrorMsg(_data.result)
            end
        end
    )
end

