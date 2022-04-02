return {
	base=
	{
		[1]=
		{
			index = 1,
			icon = "activity_bg_pic16",
			name = "备战双十一",
		},
	},
	tge=
	{
		tge1=
		{
			tge = "tge1",
			name = "备战双十一",
			on_off = 1,
			is_show = 1,
			order = 1,
		},
	},
	tge1=
	{
		[1]=
		{
			id = 1,
			task = 21018,
			total = 1,
			task_name = "分享一次游戏",
			level = 1,
			item = {"jing_bi",},
			count = {1000,},
			gotoUI = {"share_hall",},
		},
		[2]=
		{
			id = 2,
			task = 21019,
			total = 500000,
			task_name = "任意游戏累计赢金50万",
			level = 1,
			item = {"jing_bi",},
			count = {5000,},
			gotoUI = {"game_MiniGame",},
		},
		[3]=
		{
			id = 3,
			task = 21019,
			total = 1000000,
			task_name = "任意游戏累计赢金100万",
			level = 2,
			item = {"jing_bi","prop_box",},
			count = {5000,1,},
			gotoUI = {"game_MiniGame",},
		},
		[4]=
		{
			id = 4,
			task = 21019,
			total = 5000000,
			task_name = "任意游戏累计赢金500万",
			level = 3,
			item = {"jing_bi","prop_box",},
			count = {8000,2,},
			gotoUI = {"game_MiniGame",},
		},
		[5]=
		{
			id = 5,
			task = 21019,
			total = 20000000,
			task_name = "任意游戏累计赢金2000万",
			level = 4,
			item = {"jing_bi","prop_box",},
			count = {50000,3,},
			gotoUI = {"game_MiniGame",},
		},
		[6]=
		{
			id = 6,
			task = 21019,
			total = 100000000,
			task_name = "任意游戏累计赢金1亿",
			level = 5,
			item = {"shop_gold_sum","prop_box",},
			count = {10,5,},
			gotoUI = {"game_MiniGame",},
		},
		[7]=
		{
			id = 7,
			task = 21019,
			total = 500000000,
			task_name = "任意游戏累计赢金5亿",
			level = 6,
			item = {"activity_icon_gift3","prop_box",},
			count = {"鲸鱼抱枕",10,},
			real_img = {"activity_icon_gift3",},
			real_txt = {"鲸鱼抱枕",},
			gotoUI = {"game_MiniGame",},
			isreal = 1,
			is_hint = 1,
			hint_item = {"prop_box"},
			hint_desc = {"(1)宝箱可随机开出1000-15万鲸币\n(2)2019年11月5日7:30可使用"},
		},
	},
	helpinfo=
	{
		[1]=
		{
			index = 1,
			text = "1. 活动时间：10月29日7:30 — 11月4日23:59:59；",
			button_image = "activity_bg_pic16_1",
		},
		[2]=
		{
			index = 2,
			text = "2. 活动期间内完成任务，可领取对应的奖励；",
		},
		[3]=
		{
			index = 3,
			text = "3.统计所有游戏的累计赢金数据，捕鱼游戏的累计赢金数据只统计50%；",
		},
		[4]=
		{
			index = 4,
			text = "4.实物奖励，请在11月10日前联系客服QQ：4008882620领取，否则视为自动放弃奖励；",
		},
		[5]=
		{
			index = 5,
			text = "5.实物奖励将在活动结束后7天内统一发放。",
		},
	},
}