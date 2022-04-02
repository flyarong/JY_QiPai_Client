-- 创建时间:2020-05-21
-- Panel:VowMoreAwardPanel
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

VowMoreAwardPanel = basefunc.class()
local C = VowMoreAwardPanel
C.name = "VowMoreAwardPanel"
local base_data = {
	[1] = {
		left_award_txt = "100万鲸币",
		right_award_txt = "200万～500万鲸币",
		right_btn_txt = "98元领取",
		left_item = "item1",
		right_item = "item2",
		award_id = {1,}
	},
	[2] = {
		left_award_txt = "888888鲸币",
		right_award_txt = "178万～500万鲸币",
		right_btn_txt = "88元领取",
		left_item = "item1",
		right_item = "item2",
		award_id = {2,}
	},
	[3] = {
		left_award_txt = "588888鲸币",
		right_award_txt = "118万～500万鲸币",
		right_btn_txt = "58元领取",
		left_item = "item1",
		right_item = "item2",
		award_id = {3,}

	},
	[4] = {
		left_award_txt = "388888鲸币",
		right_award_txt = "78万～500万鲸币",
		right_btn_txt = "38元领取",
		left_item = "item1",
		right_item = "item2",
		award_id = {4,}

	},
	[5] = {
		left_award_txt = "288888鲸币",
		right_award_txt = "58万～500万鲸币",
		right_btn_txt = "28元领取",
		left_item = "item1",
		right_item = "item2",
		award_id = {5,}

	},
	[6] = {
		left_award_txt = "188888鲸币",
		right_award_txt = "38万～500万鲸币",
		right_btn_txt = "18元领取",
		left_item = "item1",
		right_item = "item2",
		award_id = {6,}

	},
	[7] = {
		left_award_txt = "10万鲸币",
		right_award_txt = "20万～500万鲸币",
		right_btn_txt = "10元领取",
		left_item = "item1",
		right_item = "item2",
		award_id = {7,}

	},
	[8] = {
		left_award_txt = "5万鲸币",
		right_award_txt = "10万～500万鲸币",
		right_btn_txt = "5元领取",
		left_item = "item1",
		right_item = "item2",
		award_id = {8,}
	},
	[9] = {
		right_btn_txt = "6元领取",
		left_award_txt = "6万~20万鲸币",
		left_item = "item3",
		right_item = "item4",
		award_id = {9,10,11,12,13,14,15,16,17,18,19,}
	},
}
--索引是award_id
local more_award_info = {
	[9] = {text = "1088鲸币",image = "pay_icon_gold6"},
	[10] = {text = "1588鱼币",image = "com_award_icon_yb1"},
	[11] = {text = "5188鲸币",image = "pay_icon_gold6"},
	[12] = {text = "5888鱼币",image = "com_award_icon_yb2"},
	[13] = {text = "51888鲸币",image = "pay_icon_gold6"},
	[14] = {text = "0.05福卡劵",image = "bbsc_icon_hb"},
	[15] = {text = "0.5福卡劵",image = "bbsc_icon_hb"},
	[16] = {text = "捕鱼锁定*3",image = "by_btn_sd"},
	[17] = {text = "记牌器*1",image = "com_award_icon_jipaiqi"},
	[18] = {text = "免费子弹*20",image = "bygame_icon_danmf2"},
	[19] = {text = "超级火力*20",image = "bygame_icon_cjhl"},
	
}
function C.Create(award_id,shop_id)
	return C.New(award_id,shop_id)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
	self.lister = {}
	self.lister["AssetsGetPanelConfirmCallback"] = basefunc.handler(self,self.AssetsGetPanelConfirmCallback)
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

function C:ctor(award_id,shop_id)
	local parent = GameObject.Find("Canvas/LayerLv5").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	self.award_id = award_id
	self.shop_id = shop_id
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	local ui_data = self:GetUIData(self.award_id)
	if ui_data then
		local lb = GameObject.Instantiate(self[ui_data.left_item],self.left_node)
		local rb = GameObject.Instantiate(self[ui_data.right_item],self.right_node)
		lb.gameObject:SetActive(true)
		rb.gameObject:SetActive(true)
		self.right_btn_txt.text = ui_data.right_btn_txt
		if ui_data.right_item == "item4" then
			local temp_ui = {}
			LuaHelper.GeneratingVar(self.left_node, temp_ui)
			LuaHelper.GeneratingVar(self.right_node, temp_ui)
			temp_ui.award1_img.sprite = GetTexture(more_award_info[self.award_id].image)
			temp_ui.award2_img.sprite = GetTexture(more_award_info[self.award_id].image)
			temp_ui.award1_img:SetNativeSize()
			temp_ui.award2_img:SetNativeSize()
			self.left_award_txt.text = more_award_info[self.award_id].text
			self.right_award_txt.text = more_award_info[self.award_id].text .."+"..ui_data.left_award_txt
		else		
			self.left_award_txt.text = ui_data.left_award_txt
			self.right_award_txt.text = ui_data.right_award_txt
		end
	end
	self.right_btn.onClick:AddListener(function ()
		self:BuyShop(self.shop_id)
	end)
	self.left_btn.onClick:AddListener(function ()
		Network.SendRequest("xuyuanchi_get_award",nil,"")
	end)
	self:MyRefresh()
end

function C:MyRefresh()
end

function C:GetUIData(award_id)
	for k , v in pairs(base_data) do
		for k1,v1 in pairs(v.award_id) do
			if v1 == award_id then
				return v
			end
		end
	end
end

function C:BuyShop(shopid)
    local gb =  MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, shopid)
    if not gb then return end
	local price = gb.price
	if  GameGlobalOnOff.PGPay and gameRuntimePlatform == "Ios" then
		ServiceGzhPrefab.Create({desc="请前往公众号获取"})
	else
		PayTypePopPrefab.Create(shopid, "￥" .. (price / 100))
	end
end

function C:AssetsGetPanelConfirmCallback( )
	self:MyExit()
end