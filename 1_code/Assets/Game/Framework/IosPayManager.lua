local basefunc = require "Game.Common.basefunc"


IosPayManager={}

local intervalTime={
	[0]=0,
	[1]=8,
	[2]=10,
	[3]=30,
	[4]=30,
	[5]=60,
	[6]=60,
	[7]=120,
	[8]=240,
}
--获得下次发送的间隔时间
local function getSendIntervalTime(count)
	count=count or 0 
	if count>8 then
		count=8
	end
	local t= intervalTime[count]
	if t then
		return t
	end
	return 240
end
--解析数据
local function parseOrderData(data)

    local code = "return " .. data
    local ok, ret = xpcall(function ()
        local order = loadstring(code)()
        if type(order) ~= 'table' 
        	or type(order.transactionId) ~= "string"
			or type(order.productId) ~= "string"
			or type(order.receipt) ~= "string"
			or type(order.isSandbox) ~= "number" then
	            order = nil
	            print("parseOrderData error ")
        end
        return order
    end
    ,function (err)
        local errStr = "parseOrderData error : "..emailData
        print(errStr)
        print(err)
    end)

    if not ok then
        ret = nil
    end

    return ret
end

function IosPayManager.Init()
	--key transID  v {}
	IosPayManager.order={}

	--检查本地订单缓存
	IosPayManager.iosOrderFilePath = AppDefine.LOCAL_DATA_PATH .. "/ios_order"
	if not Directory.Exists(IosPayManager.iosOrderFilePath) then
        Directory.CreateDirectory(IosPayManager.iosOrderFilePath)
    end
	IosPayManager.LoadOrder()

	Event.AddListener("notify_pay_order_msg", IosPayManager.CloseOrder)
	
	IosPayManager.AutoSendOrderToServer()
	
	IosPayManager.updateTimer = Timer.New(IosPayManager.AutoSendOrderToServer, 5, -1, true, true)
    IosPayManager.updateTimer:Start()
end

function IosPayManager.Exit()
	IosPayManager.updateTimer:Stop()
	Event.RemoveListener("notify_pay_order_msg", IosPayManager.CloseOrder)
end
--加载未close的订单
function IosPayManager.LoadOrder()
	local orderFileNames = Directory.GetFiles(IosPayManager.iosOrderFilePath)
    for i=0,orderFileNames.Length-1 do
        local order = parseOrderData(orderFileNames[i])
		if order then
			IosPayManager.order[order.transactionId] = order
		end
	end
	dump(orderFileNames, "<color=yellow>orderFileNames</color>")
end

--添加一个订单
--[[
	transactionId = "sdfxzgaw" #ios订单号
	productId =  "com.jjddz.zs.diamond6" #产品号
	receipt =  "xzcsadf" #支付后苹果返回给app的票据
	isSandbox =  1 #是否用沙盒支付 0-no  1-yes
]]
--添加一个订单
function IosPayManager.AddOrder(order)
	IosPayManager.order[order.transactionId] = order
	IosPayManager.SendOrderToServer(order)

	local orderFileName = IosPayManager.iosOrderFilePath.."/"..order.transactionId
	if File.Exists(orderFileName) then
		File.Delete(orderFileName)
	end
	local orderStr = basefunc.safe_serialize(order)
	File.WriteAllText(orderFileName, orderStr)
end

--关闭一个订单
function IosPayManager.CloseOrder(proto_name,data)
	dump(data, "<color=green>关闭订单</color>")
	DSM.Pay(data)
	if data.result==0 and data.transaction_id then
		if IosPayManager.order[data.transaction_id] then
			IosPayManager.order[data.transaction_id] = nil

			local orderFileName = IosPayManager.iosOrderFilePath.."/"..data.transaction_id
			if File.Exists(orderFileName) then
				File.Delete(orderFileName)
				LuaHelper.APPSeverConfirmPendingPurchase(data.definition_id)
		    end
		end
	else
		if data.error_info then
			if data.error_info == 21000 then
				LittleTips.Create("App Store不能读取你提供的JSON对象")
			elseif data.error_info == 21002 then
				LittleTips.Create("receipt-data域的数据有问题")
			elseif data.error_info == 21003 then
				LittleTips.Create("receipt无法通过验证")
			elseif data.error_info == 21004 then
				LittleTips.Create("提供的shared secret不匹配你账号中的shared secret")
			elseif data.error_info == 21005 then
				LittleTips.Create("	receipt服务器当前不可用")
			elseif data.error_info == 21006 then
				LittleTips.Create("receipt合法，但是订阅已过期。服务器接收到这个状态码时，receipt数据仍然会解码并一起发送")
			elseif data.error_info == 21007 then
				LittleTips.Create("receipt是Sandbox receipt，但却发送至生产系统的验证服务")
			elseif data.error_info == 21008 then
				LittleTips.Create("receipt是生产receipt，但却发送至Sandbox环境的验证服务")
			end
			if data.transaction_id then
				HintPanel.Create(1,"IOS内购错误 transaction_id:" .. data.transaction_id)
				if IosPayManager.order[data.transaction_id] then
					IosPayManager.order[data.transaction_id] = nil
		
					local orderFileName = IosPayManager.iosOrderFilePath.."/"..data.transaction_id
					if File.Exists(orderFileName) then
						File.Delete(orderFileName)
						LuaHelper.APPSeverConfirmPendingPurchase(data.definition_id)
					end
				end
			end
		end
	end
end

--向服务器发送订单
function IosPayManager.SendOrderToServer(order)
	order.sendCount=order.sendCount or 1
	local time=getSendIntervalTime(order.sendCount)
	
	order.sendCount=order.sendCount+1

	order.nextSendTimes=os.time()+time

	print("[Debug] IOS pay SendOrderToServer")
	--向服务器发送订单
	Network.SendRequest("req_appstorepay_check",{
														product_id=order.productId,
														receipt=order.receipt,
														is_sandbox=order.isSandbox,
														transaction_id=order.transactionId,
														definition_id = order.definition_id,
														convert = order.convert,
													})
end

function IosPayManager.AutoSendOrderToServer()
	local time=os.time()
	-- dump(IosPayManager.order, "<color=yellow>IosPayManager.order</color>")
	for id,v in pairs(IosPayManager.order) do
		v.nextSendTimes=v.nextSendTimes or 0
		if time>=v.nextSendTimes then
			IosPayManager.SendOrderToServer(v)
		end
	end
end

















