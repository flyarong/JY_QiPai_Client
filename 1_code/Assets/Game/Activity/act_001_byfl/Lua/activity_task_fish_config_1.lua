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
			task = 21147,
			total = 10,
			task_name = "任意场次捕鱼10条鱼",
			level = 1,
			item = {"jing_bi",},
			count = {500,},
			gotoUI = { "game_MiniGame",},
		},
		[2]=
		{
			id = 2,
			task = 21148,
			total = 50,
			task_name = "任意场次捕鱼50条鱼",
			level = 1,
			item = {"jing_bi",},
			count = {1000,},
			gotoUI = { "game_MiniGame",},
		},
		[3]=
		{
			id = 3,
			task = 21149,
			total = 100,
			task_name = "任意场次捕鱼100条鱼",
			level = 1,
			item = {"jing_bi",},
			count = {2000,},
			gotoUI = { "game_MiniGame",},
		},
	},
	helpinfo=
	{
	},
}