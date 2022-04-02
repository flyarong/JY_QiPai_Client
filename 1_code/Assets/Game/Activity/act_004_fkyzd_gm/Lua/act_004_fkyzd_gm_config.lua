return {
	base=
	{
		[1]=
		{
			index = 1,
			icon = "fkyzd_bg_2",
			name = "购买神灯",
		},
	},
	tge=
	{
		tge1=
		{
			tge = "tge1",
			name = "购买神灯",
			on_off = 1,
			is_show = 1,
			order = 2,
		},
	},
	tge1=
	{
		[1]=
		{
			id = 1,
			goods_type = "prop_fish_summon_fish",
			goods_id = 19,
			discount = "7折",
			remarks = "限购一次",
			task_name = "使用7万鲸币可领取10个神灯",
			sort = 3,
			item = {"prop_fish_summon_fish",},
			count = {10,},
			gotoUI = {"shop_bay","jing_bi",},
		},
		[2]=
		{
			id = 2,
			goods_type = "prop_fish_summon_fish",
			goods_id = 20,
			discount = "6折",
			remarks = "限购一次",
			task_name = "使用18万鲸币即可领取30个神灯",
			sort = 2,
			item = {"prop_fish_summon_fish",},
			count = {30,},
			gotoUI = {"shop_bay","jing_bi",},
		},
		[3]=
		{
			id = 3,
			goods_type = "prop_fish_summon_fish",
			goods_id = 21,
			discount = "3折",
			remarks = "限购一次",
			task_name = "使用15福卡可领取50个神灯",
			sort = 1,
			item = {"prop_fish_summon_fish",},
			count = {50,},
			gotoUI = {"shop_bay","jing_bi",},
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
			text = "2. 活动期间，在充值商城中累计充值达到指定的金额可获得对应的奖励；",
		},
		[3]=
		{
			index = 3,
			text = "3.活动结束后未领取的奖励视为自动放弃;",
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