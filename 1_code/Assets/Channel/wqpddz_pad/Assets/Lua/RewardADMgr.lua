RewardADMgr = {}
local M = RewardADMgr
--配置
local ad_cfg = ""

--奖励
local reward_tbl = nil

--接口
function M.RewardVideoAdListener(ad_id,result)
	dump({ad_id = ad_id,result = result}, "<color=white>[ad] RewardVideoAdListener</color>")
end

function M.OnError(ad_id,errorCode,message)
	local data = {ad_id = ad_id,errorCode = errorCode,message = message}
	dump(data, "<color=white>[ad] OnError</color>")
	Event.Brocast("sdk_ad_msg", "OnError", data)
end

function M.OnRewardVideoAdLoad(ad_id,result)
	dump({ad_id = ad_id,result = result}, "<color=white>[ad] OnRewardVideoAdLoad</color>")
	sdkMgr:PlayAD(ad_id, function(id, plyRet)
		print("[AD] play result:" .. id .. ", " .. plyRet)
		if plyRet == 0 then
			print("<color=white>播放成功</color>")
		else
			print("<color=white>播放失败</color>")
		end
	end)
end

function M.OnRewardVideoCached(ad_id,result)
	dump({ad_id = ad_id,result = result}, "<color=white>[ad] OnRewardVideoCached</color>")
end

function M.RewardAdInteractionListener(ad_id,result)
	dump({ad_id = ad_id,result = result}, "<color=white>[ad] RewardAdInteractionListener</color>")
end

function M.OnAdShow(ad_id,result)
	local data = {ad_id = ad_id,result = result}
	dump(data, "<color=white>[ad] OnAdShow</color>")
	Event.Brocast("sdk_ad_msg", "OnAdShow", data)
end

function M.OnAdVideoBarClick(ad_id,result)
	local data = {ad_id = ad_id,result = result}
	dump(data, "<color=white>[ad] OnAdVideoBarClick</color>")
	Event.Brocast("sdk_ad_msg", "OnAdVideoBarClick", data)
end

function M.OnAdClose(ad_id,result)
	local data = {ad_id = ad_id,result = result}
	dump(data, "<color=white>[ad] OnAdClose</color>")
	sdkMgr:ClearAD(ad_id)
	Event.Brocast("sdk_ad_msg", "OnAdClose", data)
end

function M.OnVideoComplete(ad_id,result)
	local data = {ad_id = ad_id,result = result}
	dump(data, "<color=white>[ad] OnVideoComplete</color>")
	Event.Brocast("sdk_ad_msg", "OnVideoComplete", data)
end

function M.OnVideoError(ad_id,result)
	local data = {ad_id = ad_id,result = result}
	dump(data, "<color=white>[ad] OnVideoError</color>")
	Event.Brocast("sdk_ad_msg", "OnVideoError", data)
end

function M.OnRewardVerify(ad_id,result,rewardVerify,rewardAmount,rewardName)
	if not reward_tbl then
		print("[AD] OnRewardVerify but reward_tbl invalid. ad_id:" .. ad_id)
	end

	--local data = {ad_id = ad_id,result = result,rewardVerify = rewardVerify,rewardAmount = rewardAmount,rewardName = rewardName}
	local data = {ad_id = ad_id,result = result,rewardVerify = rewardVerify,rewardAmount = reward_tbl.amount or 0,rewardName = reward_tbl.name or ""}

	dump(data, "<color=white>[ad] OnRewardVerify</color>")
	Event.Brocast("sdk_ad_msg", "OnRewardVerify", data)
end

function M.SetupAD()
	local ad_tbl = {}

	ad_tbl.appId = 5060726
	ad_tbl.appName = "玩棋牌斗地主"

	ad_tbl.isDebug = false
	sdkMgr:SetupAD(lua2json(ad_tbl),function(data)
		dump(data, "<color=white>SetupAD>>>>>>>>>>>>>>>>>>>>>>>></color>")
		sdkMgr:RemoveRewardVideoAdListener()
		sdkMgr:RemoveRewardAdInteractionListener()
		sdkMgr:AddRewardVideoAdListener(M.RewardVideoAdListener,
			M.OnError,
			M.OnRewardVideoAdLoad,
			M.OnRewardVideoCached)
		sdkMgr:AddRewardAdInteractionListener(M.RewardAdInteractionListener, 
			M.OnAdShow,
			M.OnAdVideoBarClick,
			M.OnAdClose,
			M.OnVideoComplete,
			M.OnVideoError,
			M.OnRewardVerify)
	end)
	print("<color=red>ad setup ad</color>")
end

function M.PrepareAD(codeID, rewardName, rewardAmount, userID, extraData, width, height, callback)
	print("<color=white>[AD] PrepareAD</color>")
	reward_tbl = {}
	reward_tbl.name = rewardName
	reward_tbl.amount = rewardAmount
	reward_tbl.userid = userID

	sdkMgr:PrepareAD(codeID, rewardName, rewardAmount, userID, extraData, width, height, callback)
end

--初始化广告
RewardADMgr.SetupAD()