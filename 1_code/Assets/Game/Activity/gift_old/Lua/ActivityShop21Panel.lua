
local basefunc = require "Game/Common/basefunc"

local TICKET_TBL = {
	[1] = {
		id = 71,
		price = 100,
		image = {"gy_26_1","gy_26_2"}
	},
	[2] = {
		id = 70,
		price = 100,
		image = {"gy_26_3","gy_26_4"}
	},
	[3] = {
		id = 69,
		price = 100,
		image = {"gy_26_5","gy_26_6"}
	}
}

local SHARE_TBL = {
	[1] = {
		icon = "gy_26_13",
		title = "x1000",
		image = {"gy_26_7","gy_26_8"}
	},
	[2] = {
		icon = "gy_26_14",
		title = "x2000",
		image = {"gy_26_7","gy_26_8"}
	},
	[3] = {
		icon = "gy_26_15",
		title = "x5000",
		image = {"gy_26_7","gy_26_8"}
	},
	[4] = {
		icon = "gy_26_16",
		title = "x1",
		image = {"gy_26_7","gy_26_8"}
	},
	[5] = {
		icon = "gy_26_17",
		title = "x1",
		image = {"gy_26_7","gy_26_8"}
	}
}

local COUNTDONW_TIME = 1559221200


local function bit_or(a,b)
    local p,c=1,0
    while a+b>0 do
        local ra,rb=a%2,b%2
        if ra+rb>0 then c=c+p end
        a,b,p=(a-ra)/2,(b-rb)/2,p*2
    end
    return c
end

local function bit_xor(a,b)
    local p,c=1,0
    while a+b>0 do
        local ra,rb=a%2,b%2
        if ra+rb==1 then c=c+p end
        a,b,p=(a-ra)/2,(b-rb)/2,p*2
    end
    return c
end

local function bit_not(n)
    local p,c=1,0
    while n>0 do
        local r=n%2
        if r<1 then c=c+p end
        n,p=(n-r)/2,p*2
    end
    return c
end

local function bit_and(a,b)
    local p,c=1,0
    while a>0 and b>0 do
        local ra,rb=a%2,b%2
        if ra+rb>1 then c=c+p end
        a,b,p=(a-ra)/2,(b-rb)/2,p*2
    end
    return c
end

local function bit_get_place_value(_number,_n)
  local m = 2^(_n-1)
  if bit_and(_number,m) > 0 then
    return 1
  end
  return 0
end

local function CheckBit(v, bit)
	local m = 2^(bit-1)
	if bit_and(v,m) > 0 then
		return 1
	end
	return 0
end

local function SetBit(v, bit)
	v = v or 0
	local m = 2^(bit-1)

	return bit_or(v,m)
end

ActivityShop21Panel = basefunc.class()
local C = ActivityShop21Panel
C.name = "ActivityShop21Panel"

local instance
function C.Create(parent, backcall)
	if not instance then
		instance = C.New(parent, backcall)
	else
		instance:MyRefresh()
	end
	return instance
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
	self.lister = {}
	self.lister["ExitScene"] = basefunc.handler(self, self.OnExitScene)
	self.lister["ReConnecteServerSucceed"] = basefunc.handler(self, self.ReConnecteServerSucceed)
	self.lister["ReceivePayOrderMsg"] = basefunc.handler(self, self.OnReceivePayOrderMsg)
	self.lister["finish_gift_shop"] = basefunc.handler(self, self.OnFinishGiftShop)
end

function C:RemoveListener()
	for proto_name,func in pairs(self.lister) do
		Event.RemoveListener(proto_name, func)
	end
	self.lister = {}
end

function C:MyExit()
	destroy(self.gameObject)

	if IsEquals(self.gameObject) then
		return
	end
	self:RemoveListener()

	for k, v in pairs(self.tickets) do
		destroy(v.gameObject)
	end
	self.tickets = {}

	for k, v in pairs(self.shares) do
		destroy(v.gameObject)
	end
	self.shares = {}

	if self.cooldownTime then
		self.cooldownTime:Stop()
		self.cooldownTime = nil
	end

	instance=nil
end

function C:ctor(parent, backcall)

	ExtPanel.ExtMsg(self)

	self.backcall = backcall
	local parent = parent or GameObject.Find("Canvas/LayerLv4").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj

	self:MakeLister()
	self:AddMsgListener()

	self:InitUI()
end

function C:InitUI()
	local tran = self.transform

	self.BackButton = tran:Find("BackButton"):GetComponent("Button")
	self.BackButton.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:OnBackClick()
	end)

	self.cooldown = tran:Find("Top/header/cooldown"):GetComponent("Text")
	self.ticketsNode = tran:Find("Center/ticketsNode")
	self.ticketTmpl = tran:Find("Center/ticket_tmpl")

	self.sharesNode = tran:Find("Bottom/sharesNode")
	self.shareTmpl = tran:Find("Bottom/share_tmpl")

	local hintPanel = tran:Find("hint_panel")
	local hintClose = hintPanel:Find("hint_close_btn"):GetComponent("Button")
	hintClose.onClick:AddListener(function ()
		hintPanel.gameObject:SetActive(false)
	end)
	self.help = tran:Find("Top/help"):GetComponent("Image")
	EventTriggerListener.Get(self.help.gameObject).onClick = function ()
		hintPanel.gameObject:SetActive(true)
	end

	local node = nil

	self.tickets = {}
	for k, v in ipairs(TICKET_TBL) do
		local ticket = GameObject.Instantiate(self.ticketTmpl, self.ticketsNode)
		local gift_config = MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, v.id)
		
		node = ticket.transform:Find("buy/btn/title"):GetComponent("Text")
		node.text = string.format("%d元购买", gift_config.price / 100)

		node = ticket.transform:Find("buy/btn/price"):GetComponent("Text")
		node.text = string.format("原价%d元", v.price)
		node = ticket.transform:Find("buy/btn/image"):GetComponent("Image")
		node.sprite = GetTexture(v.image[1])

		node = ticket.transform:Find("get/mask/title"):GetComponent("Text")
		node.text = string.format("%d元购买", gift_config.price / 100)
		node = ticket.transform:Find("get/mask/price"):GetComponent("Text")
		node.text = string.format("原价%d元", v.price)
		node = ticket.transform:Find("get/mask/image"):GetComponent("Image")
		node.sprite = GetTexture(v.image[2])

		local btn = ticket.transform:Find("buy/btn"):GetComponent("Button")
		btn.onClick:AddListener(function ()
			local currentTime = os.time()
			local config = MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, TICKET_TBL[k].id)
			if config.start_time > 0 and currentTime <= config.start_time then
				HintPanel.Create(1, "5月30号开启购买")
				return
			end
			if config.end_time > 0 and currentTime >= config.end_time then
				HintPanel.Create(1, "礼包购买时间已过，请下次参与")
				return
			end

			if GameGlobalOnOff.PGPay and gameRuntimePlatform == "Ios" then
				GameManager.GotoUI({gotoui = "sys_service_gzh",goto_scene_parm = "panel",desc="请关注“%s”公众号领取万元赛分享奖励"})
			else
				PayTypePopPrefab.Create(gift_config.id, "￥" .. (gift_config.price / 100), function (result)
					if result == 0 then
					end
				end)
			end
		end)

		ticket.gameObject:SetActive(true)
		self.tickets[#self.tickets + 1] = ticket
	end
	
	self.shares = {}
	for k, v in ipairs(SHARE_TBL) do
		local share = GameObject.Instantiate(self.shareTmpl, self.sharesNode)

		node = share.transform:Find("icon"):GetComponent("Image")
		node.sprite = GetTexture(v.icon)
		node = share.transform:Find("title"):GetComponent("Text")
		node.text = v.title

		local btn = share.transform:Find("lqbtn"):GetComponent("Button")
		btn.onClick:AddListener(function ()
			local state = MainModel.UserInfo.shareARGtatus or 0
			if state == 1 then
				--MainModel.UserInfo.shareARGtatus = 0
				--MainModel.UserInfo.shareARGvalue = SetBit(MainModel.UserInfo.shareARGvalue, k)
				--self:RefreshShares()

				self:DoShare(k)
			elseif state == 0 then
				HintPanel.Create(1,"每日只能分享一次\n")
			else
				HintPanel.ErrorMsg(state)
			end
		end)

		share.gameObject:SetActive(false)
		self.shares[#self.shares + 1] = share
	end

	self:RefreshTickets()

	self.cooldown.text = ""
	local deltaTime = COUNTDONW_TIME - os.time()
	if deltaTime > 0 then
		local stamp = os.date("!*t", deltaTime)
		self.cooldown.text = string.format("开赛倒计时：%02d天%02d时%02d分", stamp.day - 1, stamp.hour, stamp.min)
		self.cooldownTime = Timer.New(function()
			deltaTime = deltaTime - 1
			if deltaTime <= 0 then
				self:OnBackClick()
			else
				stamp = os.date("!*t", deltaTime)
				self.cooldown.text = string.format("开赛倒计时：%02d天%02d时%02d分", stamp.day - 1, stamp.hour, stamp.min)
			end
		end, 1, -1)
		self.cooldownTime:Start()
	end
end

function C:MyRefresh()
	self:RefreshTickets()
	self:RefreshShares()
end

function C:RefreshShares()
	local mask = MainModel.UserInfo.shareARGvalue
	if mask == nil then
		print("RefreshShares invalid value,", debug.traceback())
		return
	end

	local btn, img
	for k, v in ipairs(self.shares) do
		btn = v.transform:Find("lqbtn")
		img = v.transform:Find("getimg")

		if CheckBit(mask, k) == 0 then
			btn.gameObject:SetActive(true)
			img.gameObject:SetActive(false)
		else
			btn.gameObject:SetActive(false)
			img.gameObject:SetActive(true)
		end
		v.gameObject:SetActive(true)
	end
end

function C:RefreshTickets()
	--local currentTime = os.time()

	local btn, img
	for k, v in ipairs(self.tickets) do
		btn = v.transform:Find("buy")
		img = v.transform:Find("get")
		if MainModel.GetItemStatus(GOODS_TYPE.gift_bag, TICKET_TBL[k].id) == 1 then
			btn.gameObject:SetActive(true)
			img.gameObject:SetActive(false)
		else
			btn.gameObject:SetActive(false)
			img.gameObject:SetActive(true)
		end
	end
end

function C:OnBackClick()
	self:MyExit()
	if self.backcall then
		self.backcall()
	end
end

function C:ReConnecteServerSucceed()
	self:MyRefresh()
end

function C:OnReceivePayOrderMsg(msg)
	if msg.result == 0 then
		UIPaySuccess.Create()
	else
		HintPanel.ErrorMsg(msg.result)
	end
end

function C:OnFinishGiftShop(id)
	self:MyRefresh()
end

function C:OnExitScene()
	self:MyExit()
end

function C:DoShare(idx)
	
end
