-- 创建时间:2019-08-20
-- Panel:YearXSFLpanel
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

YearXSFLpanel = basefunc.class()
local config
local C = YearXSFLpanel
C.name = "YearXSFLpanel"
local shopids = {10016,10017,10018,10019,10020,10021,10022,10023,10024}
YearXSFLpanel.IsGoodsHave=true
function C.Create(parent,backcall)
	return C.New(parent,backcall)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
	self.lister = {}
	self.lister["ReceivePayOrderMsg"]=basefunc.handler(self,self.OnReceivePayOrderMsg)
	self.lister["EnterBackGround"] = basefunc.handler(self, self.onEnterBackGround)
	self.lister["EnterForeGround"] = basefunc.handler(self, self.onEnterForeGround)
	self.lister["gift_bag_status_change_msg"]=basefunc.handler(self,self.RefreshNum)
	for i=1,#shopids  do
		self.lister["model_query_gift_bag_num_shopid_"..shopids[i]]=basefunc.handler(self,self.OnGetGiftNum)
	end
end

function C:onEnterBackGround()
	self:StopAlltimer()
end


function C:StopAlltimer()
	if self.heart then 
		self.heart:Stop()
	end 
	if self.MainTimer then 
		self.MainTimer:Stop()
	end 
end

function C:onEnterForeGround()
	if self.heart then 
		self.heart:Start()
	end 
	if self.MainTimer then 
		self.MainTimer:Start()
	end 
end


function C:OnGetGiftNum(data)
	if not  IsEquals(self.gameObject) then 
		return 
	end 
	--dump(data,"<color=red>礼包=========================================================</color>")
	self.NumData[data.shopid]=data.count
	--dump(self.NumData,"<color=red>礼包=========================================================</color>")
	self:RefreshNum()
end

function C:OnReceivePayOrderMsg(data)
	if not  IsEquals(self.gameObject) then 
		return 
	end 
	if data and  data.goods_id then 
		Network.SendRequest("query_gift_bag_num",{gift_bag_id=data.goods_id})
	end 
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
	self:StopAlltimer()
	self:RemoveListener()
	destroy(self.gameObject)

	 
end

function C:ctor(parent,backcall)

	ExtPanel.ExtMsg(self)

	config = SYSXSFLManager.GetConfig()
	local parent = parent or GameObject.Find("Canvas/LayerLv4").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	dump(config,"<color=red>配置-------------</color>")
	self.start_time=config.time[#config.time].starttime
	self.end_time=config.time[#config.time].endtime
	self.text2="距离开抢:"
	self.StatusIndex=1
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	self.jing_bi=self.transform:Find("jing_bi")
	self.jn_bi=self.transform:Find("jn_bi")
	self.fish_bi=self.transform:Find("fish_bi")
	self.qys_bi=self.transform:Find("qys_bi")
	self.chan_zi = self.transform:Find("chan_zi")
	self.backcall = backcall
	self.initIndex=0
	self.NumData={}
	self.Time_text=self.transform:Find("Timer"):GetComponent("Text")	
	self:GetTexts()
	self:GetCount(self:GetShopIds(self.StatusIndex))
	self:SpawnGiftByShopids(self:GetShopIds(self.StatusIndex))
	--self:GO2SHOP(10016)
	self:InitTimer()
	self:InitHeart()
	YearXSFLpanel.IsGoodsHave=false
end

function C:InitUI()
	self.CloseButton = self.transform:Find("CloseButton"):GetComponent("Button")
	self.CloseButton.onClick:AddListener(
		function ()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
			self:MyExit()
		end
	)
	self.Childs={}
	for i=1,3 do
		self.Childs[#self.Childs+1]=self.transform:Find("Child"..i)
	end
	self:MyRefresh()
end

function C:MyRefresh()

end


function C:GO2SHOP(shopid)
	local price = MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, shopid).price
	if price == 0 then 
		self:Pay4Free(shopid)
	else
		self:BuyShop(shopid)
	end 
end


function C:BuyShop(shopid)
	local price = MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, shopid).price
	if  GameGlobalOnOff.PGPay and gameRuntimePlatform == "Ios" then
		GameManager.GotoUI({gotoui = "sys_service_gzh",goto_scene_parm = "panel",desc="请前往公众号获取"})
	else
		PayTypePopPrefab.Create(shopid, "￥" .. (price / 100))
	end
end
 

function C:IsDuring()
	if os.time()>self.end_time or os.time() < self.start_time then 
		print("不在活动时间内")
		return  false
	end 
	for i = 1, #config.time-1 do
		if os.time() < self:GetDurTime(config.time[i].endtime) and os.time() > self:GetDurTime(config.time[i].starttime) then
			return i
		end 
	end
	return  false
end

function C:GetDurTime(x)
	local t=os.time() + 8*60*60
	local f=math.floor(t/86400)
	return f*86400 + x -8*60*60
end


function C:Pay4Free(goodsid)
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

--拼接字符串,抛出一个当前的礼包选择
function C:GetTexts()
	local isduring=self:IsDuring()
	if isduring then 
		--dump(self:GetDurTime(config.time[isduring].endtime),"<color=red>99999999999999</color>")
	end
	if isduring then
		self.text="距本轮结束:"..os.date("%H时%M分%S秒",self:GetDurTime(config.time[isduring].endtime)-os.time()+16*3600)
		self.StatusIndex=isduring	--
	elseif os.time() > config.time[#config.time].endtime-7200 then --如果是最后一天就隐藏
			self.text="活动已经结束啦~"
			self.text2 ="活动已经结束,敬请期待下次限时福利~"
			self.StatusIndex=3
	else
		for i = 1, #config.time -1  do
			if  i == 1  and os.time() <=self:GetDurTime(config.time[i].starttime)  then --如果是小于8点
				self.text="距下轮开启:"..os.date("%H时%M分%S秒",self:GetDurTime(config.time[i].starttime)-os.time()+16*3600)
				self.text2="距离开抢:"..StringHelper.formatTimeDHMS(self:GetDurTime(config.time[i].starttime)-os.time())
				self.StatusIndex=1
			end
			--
			if i>=2 and  os.time() <=self:GetDurTime(config.time[i].starttime) and os.time() >=self:GetDurTime(config.time[i-1].endtime)  then
				self.text="距下轮开启:"..os.date("%H时%M分%S秒",self:GetDurTime(config.time[i].starttime)-os.time()+16*3600)
				self.text2="距离开抢:"..StringHelper.formatTimeDHMS(self:GetDurTime(config.time[i].starttime)-os.time())			
				self.StatusIndex=i
			end
			--当天时间大于22点 
			if os.time() >= self:GetDurTime(config.time[#config.time -1].endtime) then
				self.text="距下轮开启:"..os.date("%H时%M分%S秒",self:GetDurTime(config.time[1].starttime)+86400-os.time()+3600*16)
				self.text2="距离开抢:"..StringHelper.formatTimeDHMS(self:GetDurTime(config.time[1].starttime)+86400-os.time())
				self.StatusIndex=1
			end
		end 
	end
	self.Time_text.text = self.text
	self:OnIndexChange()
end

function C:InitTimer()
	self.MainTimer=Timer.New(
	function ( )
		self:DoAt1s()
	end
	,1,-1)
	self.MainTimer:Start()
end

function C:DoAt1s( )
	self:GetTexts()
end

function C:GetShopIds(StatusIndex)
	local ids={}
	for i = 1+(StatusIndex-1)*3, 3+(StatusIndex-1)*3 do
		ids[#ids+1]=shopids[i]
	end
	return ids
end


function C:SpawnGiftByShopids(ids)
	for i = 1, #ids do
		local c = MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, ids[i])	
		--dump(c,"---------------------99999999999")		
		self.Childs[i].transform:Find("SY"):GetComponent("Text").text="剩余"..c.count.."份"
		self.Childs[i].transform:Find("Money"):GetComponent("Text").text=(c.price/100).."元"
		self.Childs[i].transform:Find("Button"):GetComponent("Button").onClick:RemoveAllListeners()
		self.Childs[i].transform:Find("Button"):GetComponent("Button").onClick:AddListener(
			function ()
				if self:IsDuring() then 
					self:GO2SHOP(ids[i])
				else
					HintPanel.Create(1,self.text2.." 敬请期待！")
				end 
			end
		)
		destroyChildren(self.Childs[i].transform:Find("AwardNode"))
		for j = 1, #c.buy_asset_type do
			if     c.buy_asset_type[j]=="jing_bi" then
				local b = 	GameObject.Instantiate(self.jing_bi,self.Childs[i].transform:Find("AwardNode"))
				b.transform:Find("Text"):GetComponent("Text").text="x "..StringHelper.ToCash(c.buy_asset_count[j])
				b.gameObject:SetActive(true)
			elseif c.buy_asset_type[j]=="prop_jinianbi" then 
				local b = 	GameObject.Instantiate(self.jn_bi,self.Childs[i].transform:Find("AwardNode"))
				b.transform:Find("Text"):GetComponent("Text").text="x "..StringHelper.ToCash(c.buy_asset_count[j])
				b.gameObject:SetActive(true)
			elseif  c.buy_asset_type[j]=="fish_coin" or  c.buy_asset_type[j] == "discount_fish_coin" then 
				local b = 	GameObject.Instantiate(self.fish_bi,self.Childs[i].transform:Find("AwardNode"))
				b.transform:Find("Text"):GetComponent("Text").text="x "..StringHelper.ToCash(c.buy_asset_count[j])
				b.gameObject:SetActive(true)
			elseif c.buy_asset_type[j]=="prop_2" then 
				local b = 	GameObject.Instantiate(self.qys_bi,self.Childs[i].transform:Find("AwardNode"))
				b.transform:Find("Text"):GetComponent("Text").text="x "..StringHelper.ToCash(c.buy_asset_count[j])
				b.gameObject:SetActive(true)
			elseif c.buy_asset_type[j]=="prop_shovel" then 
				local b = 	GameObject.Instantiate(self.chan_zi,self.Childs[i].transform:Find("AwardNode"))
				b.transform:Find("Text"):GetComponent("Text").text="x "..StringHelper.ToCash(c.buy_asset_count[j])
				b.gameObject:SetActive(true)
			else			
				print("物品的类型不存在")
			end 
		end
	end
	self:RefreshNum()
end


function C:OnIndexChange()
	if self.initIndex == self.StatusIndex then 
		return 
	else
		print("<color=red>------------状态改变-----------</color>")
		self:ChooseGiftToShow(self.StatusIndex)
		self.initIndex = self.StatusIndex
	end 
end


function C:ChooseGiftToShow(StatusIndex)
	local ids=self:GetShopIds(StatusIndex)
	--dump(ids,"-----------------------")
	self:GetCount(ids)
	self:SpawnGiftByShopids(ids)
end

--得到礼包数量
function C:GetCount(ids)
	-- Network.SendRequest("query_gift_bag_num",{gift_bag_id=ids[1]},nil,
	-- function ()
	-- 	print("<color=red>回调第一次-------</color>")
	-- 	Network.SendRequest("query_gift_bag_num",{gift_bag_id=ids[2]},nil,
	-- 	function ()
	-- 		print("<color=red>回调第二次-----</color>")
	-- 		Network.SendRequest("query_gift_bag_num",{gift_bag_id=ids[3]})
	-- 	end
	-- 	)
	-- end
	-- )
	if not self:IsDuring() then 
		return 
	end 	
	Network.SendRequest("query_gift_bag_num",{gift_bag_id=ids[1]})
	Network.SendRequest("query_gift_bag_num",{gift_bag_id=ids[2]})
	Network.SendRequest("query_gift_bag_num",{gift_bag_id=ids[3]})
	--Network.SendRequest(name,args,JHData,callback)
end


function C:InitHeart()
	if self.heart then 
		self.heart:Stop()
	end
	self.heart=Timer.New(
		function ()
			self:GetCount(self:GetShopIds(self.StatusIndex))
		end
	,5,-1, nil, true)
	self.heart:Start()
end

function C:RefreshNum()
	--print("<color=red>-----刷新礼包数量------</color>")
	local ids=self:GetShopIds(self.StatusIndex)
	for i=1,#ids do
		dump(self.NumData,"<color=red>===================</color>")
		if self.NumData[ids[i]]~=nil then 
			--dump(self.NumData[ids[i]],"<color=red>===================</color>")
			if  self:IsDuring() then
				if self.NumData[ids[i]]<=0 then self.NumData[ids[i]]=0 else	YearXSFLpanel.IsGoodsHave = true end
				self.Childs[i].transform:Find("SY"):GetComponent("Text").text="剩余"..self.NumData[ids[i]].."份"
				if  MainModel.GetGiftShopStatusByID(ids[i]) == 0  then 
					self.Childs[i].transform:Find("ButtonMask").gameObject:SetActive(true)
				elseif MainModel.GetGiftShopStatusByID(ids[i]) == 1 then 
					self.Childs[i].transform:Find("ButtonMask").gameObject:SetActive(false)
				end  
			else
				local c = MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, ids[i])			
				self.Childs[i].transform:Find("SY"):GetComponent("Text").text="剩余"..c.count.."份"
				self.Childs[i].transform:Find("ButtonMask").gameObject:SetActive(false)
			end
			if self.NumData[ids[i]]<=0  and  self:IsDuring() then 
				self.Childs[i].transform:Find("Button"):GetComponent("Image").sprite=GetTexture("gy_56_3")
				self.Childs[i].transform:Find("Button"):GetComponent("Button").enabled=false
			else
				local price = MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, ids[i]).price
				if i == 1 and price == 0 then 
					self.Childs[i].transform:Find("Button"):GetComponent("Image").sprite=GetTexture("gy_56_2")
					self.Childs[i].transform:Find("Button"):GetComponent("Button").enabled=true
				else			
					self.Childs[i].transform:Find("Button"):GetComponent("Image").sprite=GetTexture("gy_56_2")
					self.Childs[i].transform:Find("Button"):GetComponent("Button").enabled=true
				end

			end 
		else
			self.Childs[i].transform:Find("ButtonMask").gameObject:SetActive(false)
			local price = MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, ids[i]).price
			if i>1 and price >0 then 
				self.Childs[i].transform:Find("Button"):GetComponent("Image").sprite=GetTexture("gy_56_2")
				self.Childs[i].transform:Find("Button"):GetComponent("Button").enabled=true
			else
				self.Childs[i].transform:Find("Button"):GetComponent("Image").sprite=GetTexture("gy_56_2")
				self.Childs[i].transform:Find("Button"):GetComponent("Button").enabled=true
			end 
		end 
	end
end

