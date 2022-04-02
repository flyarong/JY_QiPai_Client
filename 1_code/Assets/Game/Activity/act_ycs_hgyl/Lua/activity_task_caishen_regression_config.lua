return {
	base=
	{
		[1]=
		{
			index = 1,
			icon = "hgyl_bg_1",
			name = "年末盛典",
		},
	},
	tge=
	{
		tge1=
		{
			tge = "tge1",
			name = "回归好礼",
			on_off = 1,
			is_show = 3,
			order = 1,
		},
	},
	tge1=
	{
		[1]=
		{
			id = 1,
			task = 21122,
			total = 1,
			task_name = "老用户回归，登陆游戏",
			level = 1,
			item = {"prop_2",},
			count = {1,},
		},
		[2]=
		{
			id = 2,
			task = 21123,
			total = 1,
			task_name = "活动期间，任意一场千元赛进入前96名",
			level = 1,
			item = {"shop_gold_sum",},
			count = {10,},
			gotoUI = {"match_hall","gms",},
		},
		[3]=
		{
			id = 3,
			total = 1,
			task_name = "购买回归礼包（6元）",
			level = 1,
			item = {"jing_bi","jing_bi","shop_gold_sum",},
			count = {60000,20000,1,},
			shop_id = 10102,
		},
		[4]=
		{
			id = 4,
			task = 21124,
			total = 10,
			task_name = "跑得快任意场次游戏10局",
			level = 1,
			item = {"jing_bi",},
			count = {3000,},
			gotoUI = { "free_hall","nor_pdk_nor",},
		},
	},
	helpinfo=
	{
	},
}