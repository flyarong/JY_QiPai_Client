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
			task = 21150,
			total = 10,
			task_name = "浅水湾及以上场次捕获10条鱼",
			level = 1,
			item = {"jing_bi",},
			count = {800,},
			gotoUI = { "game_MiniGame",},
		},
		[2]=
		{
			id = 2,
			task = 21151,
			total = 50,
			task_name = "浅水湾及以上场次捕获50条鱼",
			level = 1,
			item = {"jing_bi",},
			count = {1500,},
			gotoUI = { "game_MiniGame",},
		},
		[3]=
		{
			id = 3,
			task = 21152,
			total = 100,
			task_name = "浅水湾及以上场次捕获100条鱼",
			level = 1,
			item = {"jing_bi",},
			count = {3000,},
			gotoUI = { "game_MiniGame",},
		},
	},
	helpinfo=
	{
	},
}