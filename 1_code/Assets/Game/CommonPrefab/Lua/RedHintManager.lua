-- 创建时间:2018-09-05

RedHintManager = {}

RedHintManager.RedHintKey = 
{
	RHK_Email = "RHT_Email",--大厅邮件红点
	RHK_EmailHint = "RHK_EmailHint",-- 大厅邮件有可领取的附件
	RHK_Head = "RHK_Head",-- 大厅个人中心
	RHK_Bag = "RHK_Bag",-- 大厅背包
	RHK_Share = "RHK_Share",-- 大厅分享
	RHK_Activity = "RHK_Activity",-- 大厅活动
	RHK_Money = "RHK_Money",-- 大厅钱包
	RHK_Task = "RHK_Task",-- 大厅任务
	RHK_Task_Accurate = "RHK_Task_Accurate",-- 大厅任务
	RHK_BBSC_Task = "RHK_BBSC_Task",-- 新人福卡任务
	RHK_Golded_Pig = "RHK_Golded_Pig",-- 金猪礼包
	RHK_VIP_Gift = "RHK_VIP_Gift",-- 金猪礼包
	RHK_GD = "RHK_GD",-- 大厅更多
	RHK_Weekly_Card = "RHK_Weekly_Card",-- 周卡
	RHK_XYCJ = "RHK_XYCJ",-- 幸运抽奖
	--RHK_ActivityShare="RHK_ActivityShare",--大厅分享活动
	RHK_ActivitySharePanel="RHK_ActivitySharePanel", --分享活动面板内红点
	RHK_Money_Center="RHK_Money_Center",--推广系统大厅红点
	RHK_PhoneAward="RHK_PhoneAward",--绑定手机号有奖
	RHK_VIP2="RHK_VIP2",--VIP2
	RHK_Activity_GET = "RHK_Activity_GET", -- 活动领取提示

	RHK_Activity_Year = "RHK_Activity_Year", -- 周年活动
	RHK_Activity_Year_Get = "RHK_Activity_Year_Get", -- 周年活动领取提示

	RHK_Fuli = "RHK_Fuli",
	RHK_Fuli_GET = "RHK_Fuli_GET",
}
-- 红点提示数据
local RedHintDict = {}
-- 是否显示红点
local RedHintBool = {}

-- 更新红点提示的内容 true false
RedHintManager.UpdateRedHint = function (key)
	local isRed = RedHintManager.IsKeyRed(key)
	RedHintBool[key] = isRed
	RedHintManager.RefreshRedHint(key)
end

-- 刷新红点提示
RedHintManager.RefreshRedHint = function (key, redObj)
	local b = RedHintBool[key]
	if not b then
		b = false
	end
	if redObj then
		redObj:SetActive(b)
	else
		if RedHintDict[key] then
			for k,v in ipairs(RedHintDict[key]) do
				if IsEquals(v) then
				v:SetActive(b)
				end
			end
		end
	end
end

-- 添加红点
RedHintManager.AddRed = function (key, redObj)
	if RedHintDict[key] then
		RedHintDict[key][#RedHintDict[key] + 1] = redObj
	else
		local d = {[1] = redObj}
		RedHintDict[key] = d
	end
	RedHintManager.RefreshRedHint(key, redObj)
end

-- 移除红点
RedHintManager.RemoveRed = function (key, redObj)
	if RedHintDict[key] then
		if IsEquals(redObj) then
			for k,v in ipairs(RedHintDict[key]) do
				if v == redObj then
					table.remove (RedHintDict[key], k)
					break
				end
			end
		else
			RedHintDict[key] = nil
		end
	end
end

-- 清除所有红点
RedHintManager.CloseAllRed = function ()
	RedHintDict = {}
end

--------------------------------------------------

RedHintManager.IsKeyRed = function (key)
	if key == RedHintManager.RedHintKey.RHK_Email then
		return RedHintManager.IsRedEmailNew()
	elseif key == RedHintManager.RedHintKey.RHK_EmailHint then
		return RedHintManager.IsRedEmailGet()
	elseif key == RedHintManager.RedHintKey.RHK_Head then
		return RedHintManager.IsRedHallHero()
	elseif key == RedHintManager.RedHintKey.RHK_Bag then
		return RedHintManager.IsRedHallBag()
	elseif key == RedHintManager.RedHintKey.RHK_Share then
		return RedHintManager.IsRedHallShare()
	elseif key == RedHintManager.RedHintKey.RHK_Activity then
		return RedHintManager.IsRedHallActivity()
	elseif key == RedHintManager.RedHintKey.RHK_Money then
		return RedHintManager.IsRedHallMoney()
	elseif key == RedHintManager.RedHintKey.RHK_Task then
		return RedHintManager.IsRedHallTask()
	elseif key == RedHintManager.RedHintKey.RHK_Task_Accurate then
		return RedHintManager.IsRedHallTaskAccurate()
	elseif key == RedHintManager.RedHintKey.RHK_GD then
		return RedHintManager.IsRedHallGD()
	elseif key == RedHintManager.RedHintKey.RHK_BBSC_Task then
		return RedHintManager.IsRedBBSCHallTask()
	elseif key == RedHintManager.RedHintKey.RHK_Golded_Pig then
		return RedHintManager.IsRedGoldedPigHallTask()
	elseif key == RedHintManager.RedHintKey.RHK_VIP_Gift then
		return RedHintManager.IsRedVIPGiftHallTask()
	elseif key == RedHintManager.RedHintKey.RHK_Weekly_Card then
		return RedHintManager.IsRedWeeklyCardHallTask()
	elseif key == RedHintManager.RedHintKey.RHK_XYCJ then
		return RedHintManager.IsRedXYCJHallTask()
	elseif key == RedHintManager.RedHintKey.RHK_ActivityShare then 
		return RedHintManager.IsRedHallActivityShare()	
	elseif key == RedHintManager.RedHintKey.RHK_Money_Center then
		return RedHintManager.IsMoneyCenter()
	elseif key == RedHintManager.RedHintKey.RHK_PhoneAward then
		return RedHintManager.IsRedPhoneAward()
	elseif key == RedHintManager.RedHintKey.RHK_VIP2 then
		return RedHintManager.IsRedVIP2()
	elseif key == RedHintManager.RedHintKey.RHK_Activity_GET then
		return RedHintManager.IsRedHallActivityGet()
	elseif key == RedHintManager.RedHintKey.RHK_Activity_Year then
		return RedHintManager.IsRedActivityYear()
	elseif key == RedHintManager.RedHintKey.RHK_Activity_Year_Get then
		return RedHintManager.IsRedActivityYearGet()
	elseif key == RedHintManager.RedHintKey.RHK_Fuli_GET then 
		return RedHintManager.IsRedFuliGet()
	else		
		return false
	end
end
--------------------------------------------------
-- 新邮件
RedHintManager.IsRedEmailNew = function ()
	local ss = GameManager.GetHintState({gotoui="sys_email"})
	if ss == ACTIVITY_HINT_STATUS_ENUM.AT_Nor then
		return false
	else
		return true
	end
end
--赚钱红点
RedHintManager.IsMoneyCenter = function ()
	if GameMoneyCenterModel.data.is_activate_xj_profit3 == nil or  GameMoneyCenterModel.data.my_all_son_count ==nil then 
	   return false
	end 
	if  GameMoneyCenterModel.data.is_activate_xj_profit2 == 0 and GameMoneyCenterModel.data.is_activate_xj_profit == 1 then 
		return  ( GameMoneyCenterModel.data.my_all_son_count>=10)
	elseif   GameMoneyCenterModel.data.is_activate_xj_profit3 == 0 then 
		--return   (GameMoneyCenterModel.data.my_all_son_count>=20)
		return 	false
	else
		return  false
	end
end
-- 邮件附件
RedHintManager.IsRedEmailGet = function ()
	local ss = GameManager.GetHintState({gotoui="sys_email"})
	if ss == ACTIVITY_HINT_STATUS_ENUM.AT_Get then
		return true
	else
		return false
	end

	return EmailModel.IsGetHint()
end
-- 大厅头像
RedHintManager.IsRedHallHero = function ()
    if MainModel.UserInfo.phoneData and MainModel.UserInfo.verifyData then
        if MainModel.UserInfo.phoneData and
		MainModel.UserInfo.phoneData.phone_no and 
		(MainModel.UserInfo.verifyData.status == 4 or MainModel.UserInfo.verifyData.status == 2) then
            return false
        else
            return true
        end
    else
        return true
    end
end

-- 大厅绑定有奖
RedHintManager.IsRedPhoneAward = function ()
    if MainModel.UserInfo.phoneData and MainModel.UserInfo.phoneData.phone_no then
        return false
    else
        return true
    end
end

-- 背包新物品
RedHintManager.IsRedHallBag = function ()
    local tt1 = PlayerPrefs.GetString(MainModel.RecentlyOpenBagTime, "0")
    local tt2 = PlayerPrefs.GetString(MainModel.RecentlyGetNewItemTime, "0")
    if tonumber(tt1) < tonumber(tt2) then
        return true
    else
        return false
    end
end
-- 大厅分享
RedHintManager.IsRedHallShare = function ()
	if (MainModel.UserInfo.sharePYQStatus and MainModel.UserInfo.sharePYQStatus == 1) or
        (MainModel.UserInfo.shareHYStatus and MainModel.UserInfo.shareHYStatus == 1) then
        return true
    else
        return false
    end
end
--大厅活动分享
RedHintManager.IsRedHallActivityShare = function ()
	if (MainModel.UserInfo.sharePYQStatus and MainModel.UserInfo.sharePYQStatus == 0) or
        (MainModel.UserInfo.shareHYStatus and MainModel.UserInfo.shareHYStatus == 0) then
        return false
    else
        return true
    end
end
-- 大厅活动
RedHintManager.IsRedHallActivity = function ()
    local parm = {gotoui = "sys_act_base", goto_type = "normal"}
    local a,b = GameButtonManager.RunFunExt(parm.gotoui, "GetHintState", nil, parm)
    if a and b ~= ACTIVITY_HINT_STATUS_ENUM.AT_Nor then
        return true
    else
        return false
    end
end
-- 大厅活动领取
RedHintManager.IsRedHallActivityGet = function ()
	local parm = {gotoui = "sys_act_base", goto_type = "normal"}
    local a,b = GameButtonManager.RunFunExt(parm.gotoui, "GetHintState", nil, parm)
    if a and b == ACTIVITY_HINT_STATUS_ENUM.AT_Get then
        return true
    else
        return false
    end
end
-- 大厅钱包
RedHintManager.IsRedHallMoney = function ()
    if MainModel.UserInfo.cash and MainModel.UserInfo.cash >= 1 then
        return true
    else
        return false
    end
end

-- 大厅任务
RedHintManager.IsRedHallTask = function ()
	-- dump(GameTaskModel.ChangeStatus, "<color=yellow>任务进度改变</color>")
	-- dump(GameTaskModel.CanGetStatus, "<color=yellow>任务可领取</color>")
	if 
		--有任务进度改变
		GameTaskModel.ChangeStatus.game ~= 0 or GameTaskModel.ChangeStatus.vip ~= 0 or GameTaskModel.ChangeStatus.day ~= 0
		--有任务可领取
		or GameTaskModel.CanGetStatus.game == true or GameTaskModel.CanGetStatus.vip == true or GameTaskModel.CanGetStatus.day == true
		then
        return true
    else
        return false
    end
end

-- 大厅任务
RedHintManager.IsRedHallTaskAccurate = function ()
	if 
		--有任务可领取
		SYSXYJLManager and SYSXYJLManager.CheckTaskAccurateCanGet() == true
		then
        return true
    else
        return false
    end
end


-- 大厅更多
RedHintManager.IsRedHallGD = function ()
	--local b1 = RedHintManager.IsRedHallBag()
	--为什么更多的红点会和背包挂钩？
	--所以应该干掉
	--return b1
    return false
end

-- 新人福卡
RedHintManager.IsRedBBSCHallTask = function ()
	-- dump(ActivitySevenDayModel.CanGetStatus, "<color=yellow>新人福卡可领取</color>")
	if ActivitySevenDayModel then
		if  ActivitySevenDayModel.CanGetStatus == true	then
			return true
		else
			return false
		end
	elseif ActivityXRHB1Model then
		if  ActivityXRHB1Model.CanGetStatus == true	then
			return true
		else
			return false
		end		
	end
end

--金猪礼包
RedHintManager.IsRedGoldedPigHallTask = function ()
	-- dump(GoldenPigModel.CanGetStatus.gloden_pig, "<color=yellow>金猪礼包可领取</color>")
	if  GoldenPigModel.CanGetStatus.gloden_pig == true	then
        return true
    else
        return false
    end
end

--VIP礼包
RedHintManager.IsRedVIPGiftHallTask = function ()
	if  VIPGiftModel.CanGetStatus.vip_gift == true	then
        return true
    else
        return false
    end
end

-- 周卡
RedHintManager.IsRedWeeklyCardHallTask = function ()
	if not ActivityShop20Panel then return end
	local has_award53 = ActivityShop20Panel.CheckTaskActivity(53)
	local has_award54 = ActivityShop20Panel.CheckTaskActivity(54)

	if has_award53 then return true end
	if has_award54 then
		if HallPanel.GetQYSZhouKaRemain and type(HallPanel.GetQYSZhouKaRemain) == "function" and HallPanel.GetQYSZhouKaRemain() == 0 then return true end
	end

	return false
end

RedHintManager.IsRedXYCJHallTask = function ()
	return GameManager.GetHintState({gotoui="xycj"})
end

RedHintManager.IsRedVIP2 = function ()
	return VIPManager.CanGetStatus.vip2
end

-- 大厅活动
RedHintManager.IsRedActivityYear = function ()
	return GameManager.GetHintState({gotoui="sys_act_base"})
end
-- 大厅活动领取
RedHintManager.IsRedActivityYearGet = function ()
	return GameManager.GetHintState({gotoui="sys_act_base"})
end

--大厅福利
RedHintManager.IsRedFuliGet = function ()
	if JYFLManager.GetHintState() == ACTIVITY_HINT_STATUS_ENUM.AT_Get then 
		return true
	else
		return false
	end
end
