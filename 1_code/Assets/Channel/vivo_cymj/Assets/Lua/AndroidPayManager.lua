local basefunc = require "Game.Common.basefunc"


AndroidPayManager={}

local orders = {}
local current = nil
local timer = nil
function AndroidPayManager.Init()
	orders = {}
	current = nil
	
	sdkMgr:SetPayCallback(AndroidPayManager.PayCallback)
	timer = Timer.New(function()
		if #orders > 0 and current == nil then
			current = orders[1]
			table.remove(orders, 1)
			AndroidPayManager.DealOrder(current, function(_data)
				current = nil
			end)
		end
	end, 1, -1, true, true)
    timer:Start()
end

function AndroidPayManager.Exit()
	if timer then
		timer:Stop()
		timer = nil
	end

	sdkMgr:SetPayCallback(nil)
	orders = {}
	current = nil
end

function AndroidPayManager.PayCallback(json_data)
	local lua_tbl = json2lua(json_data)
	if not lua_tbl then
		print("[PAY] tracepay: PayCallback exception: json_data invalid")
		return
	end

	-- if lua_tbl.result == 0 and lua_tbl.isLegacy then
		dump(lua_tbl, "[PAY] tracepay: PayCallback result")

		table.insert(orders, lua_tbl)
	-- else

	-- 	AndroidPayManager.DealOrder(lua_tbl, function(_data)
	-- 		if _data.result ~= 0 and _data.result ~= 1 then
	-- 			HintPanel.Create(1, "支付失败：" .. lua_tbl.result .. " : " .. _data.result)
	-- 		end
	-- 	end)
		
		--[[if lua_tbl.in_app_purchase_data then
			local tbl = json2lua(lua_tbl.in_app_purchase_data)
			if tbl then
				lua_tbl.order_id = tbl.developerPayload
			end
		end

		local raw_in_app_purchase_data = lua_tbl.in_app_purchase_data
		if lua_tbl.result ~= 0 then
			lua_tbl.in_app_purchase_data = nil
		end

		dump(lua_tbl, "[PAY] tracepay: normal PayCallback result")

		Network.SendRequest("vivo_wqp_pay_info", lua_tbl, function(_ret)
			dump(_ret, "[PAY] tracepay: vivo_wqp_pay_info")

			--if _ret.result == 0 or _ret.result == 1 then
			if true then
				lua_tbl.in_app_purchase_data = raw_in_app_purchase_data
				sdkMgr:PostPay(lua2json(lua_tbl), function(jd)
					print("[PAY] tracepay: post pay over:" + jd)
				end)
			else
				HintPanel.Create(1, "支付失败：" .. lua_tbl.result)
			end
		end)]]--
	-- end
end

--[[function AndroidPayManager.DoOrder(order)
	if order.in_app_purchase_data then
		local tbl = json2lua(order.in_app_purchase_data)
		if tbl then
			order.order_id = tbl.developerPayload
		end
	end

	dump(order, "[PAY] tracepay: deal with order begin")

	Network.SendRequest("vivo_wqp_pay_info", order, function(_data)
		dump(_data, "[PAY] tracepay: vivo_wqp_pay_info")

		--if _data.result == 0 then
		if true then
			sdkMgr:PostPay(lua2json(order), function(json_data)
				dump(current, "[PAY] tracepay: deal with order finish")
				current = nil
			end)
		end
	end)
end]]--

function AndroidPayManager.ConvertVIVOPay(order)
	if not order.cpOrderNumber then return false end
	if not order.transNo then return false end
	if not order.productPrice then return false end

	order.order_id = order.cpOrderNumber
	order.transNo = order.transNo
	order.productPrice = order.productPrice


	return true, order
end

function AndroidPayManager.DealOrder(order, callback)
	local needPostPay, order_tbl = AndroidPayManager.ConvertVIVOPay(order)
	if not order_tbl then
		dump(order, "[PAY] ConvertVIVOPay failed")
		print("[PAY] ConvertVIVOPay failed, order_tbl is null")
		return
	end

	dump(order_tbl, "[PAY] tracepay: DealOrder begin")
	print("[PAY] tracepay: needPostPay: ", needPostPay)

	Network.SendRequest("vivo_pay_info", order_tbl, function(_data)
		dump(_data, "[PAY] tracepay: vivo_pay_info")

		-- if needPostPay then
		-- 	sdkMgr:PostPay(lua2json(order_tbl), function(json_data)
		-- 		dump(order_tbl, "[PAY] tracepay: deal with order postpay finish:" .. json_data)
		-- 		if callback then callback(_data) end
		-- 	end)
		-- else
			print("[PAY] tracepay: deal with order no postpay finish")
			if callback then callback(_data) end
		--end
	end)
end
