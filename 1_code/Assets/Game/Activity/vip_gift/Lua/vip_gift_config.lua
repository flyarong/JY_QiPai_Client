return {
	not_pay=
	{
		[1]=
		{
			index = 1,
			good_id = 43,
			gzh = "JY400888",
			price = 9900,
			desc = "99元购买10张千元赛门票，购买后开启2个VIP任务。\n任务1：成功参与1次千元大奖赛无论输赢均奖励10福卡，共奖励10次。\n任务2：捕鱼游戏当日累计赢金200万鲸币奖励5福卡，共奖励20次。",
			icon_1 = "com_award_icon_qys",
			title_1 = "购买立即获得：",
			desc_1 = "千元大奖赛x10",
			icon_2 = "com_award_icon_moeny2",
			title_2 = "购买后开启VIP任务可获得：",
			desc_2 = "200福卡",
		},
	},
	pay=
	{
		qys_cfg=
		{
			task_type = "qys_cfg",
			task_id = 55,
			icon = "com_award_icon_moeny2",
			title = "成功参与一次千元大奖赛",
			award = "奖励：10福卡",
			remain = "剩余领取次数:%s/%s",
			gotoUI = {"match_hall","gms",},
			get_end_tips = "你今日的千元赛任务的奖励已经领取",
			over_tips = "你的千元赛任务的奖励都领取完了",
		},
		fishing_cfg=
		{
			task_type = "fishing_cfg",
			task_id = 56,
			icon = "com_award_icon_moeny2",
			title = "捕鱼当日累计赢金%s鲸币<size=26>(今日已累计赢金%s)</size>",
			award = "奖励：5福卡",
			remain = "剩余领取次数:%s/%s",
			gotoUI = {"game_FishingHall",},
			get_end_tips = "你今日的捕鱼任务的奖励已经领取",
			over_tips = "你的捕鱼任务的奖励都领取完了",
		},
	},
}