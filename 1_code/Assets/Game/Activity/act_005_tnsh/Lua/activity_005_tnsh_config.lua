return {
	base=
	{
		[1]=
		{
			index = 1,
			icon = "tnshlfl_bg_tnsh",
			name = "月末返利",
		},
	},
	tge=
	{
		tge1=
		{
			tge = "tge1",
			name = "天女散花",
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
			task = 21204,
			total = 1,
			task_name = "财神消消乐中出现1次天女散花",
			level = 1,
			item = {"jing_bi",},
			count = {1000,},
			gotoUI = {"game_MiniGame",},
		},
		[2]=
		{
			id = 2,
			task = 21204,
			total = 3,
			task_name = "财神消消乐中出现3次天女散花",
			level = 2,
			item = {"jing_bi",},
			count = {2000,},
			gotoUI = {"game_MiniGame",},
		},
		[3]=
		{
			id = 3,
			task = 21204,
			total = 5,
			task_name = "财神消消乐中出现5次天女散花",
			level = 3,
			item = {"jing_bi",},
			count = {3000,},
			gotoUI = {"game_MiniGame",},
		},
	},
	helpinfo=
	{
	},
}