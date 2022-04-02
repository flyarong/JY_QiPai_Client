return {
	base=
	{
		[1]=
		{
			index = 1,
			icon = "byfl_bg_1",
			name = "月末福利",
		},
	},
	tge=
	{
		tge1=
		{
			tge = "tge1",
			name = "捕鱼福利",
			on_off = 1,
			is_show = 0,
			order = 3,
		},
	},
	tge1=
	{
		[1]=
		{
			id = 1,
			task = 21153,
			total = 1,
			task_name = "浅水湾及以上场次捕获1条财神鱼",
			level = 1,
			item = {"jing_bi",},
			count = {1000,},
			gotoUI = { "game_MiniGame",},
		},
		[2]=
		{
			id = 2,
			task = 21154,
			total = 5,
			task_name = "浅水湾及以上场次捕获5条财神鱼",
			level = 1,
			item = {"jing_bi",},
			count = {3000,},
			gotoUI = { "game_MiniGame",},
		},
		[3]=
		{
			id = 3,
			task = 21155,
			total = 10,
			task_name = "浅水湾及以上场次捕获10条财神鱼",
			level = 1,
			item = {"shop_gold_sum",},
			count = {0.8,},
			gotoUI = { "game_MiniGame",},
		},
	},
	helpinfo=
	{
	},
}