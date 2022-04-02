return {
	base=
	{
		[1]=
		{
			index = 1,
			icon = "activity_bg_pic8",
			name = "纪念币获取",
			is_info = 1,
			tool_desc = "我的纪念币：%s",
			goto_desc = "前往兑换",
			goto_ui = {"game_activity_year",2},
			tool_key = "prop_jinianbi",
		},
	},
	tge=
	{
		tge1=
		{
			tge = "tge1",
			name = "纪念币获取",
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
			task = 21002,
			total = 1,
			task_name = "分享一次游戏",
			level = 1,
			item = {"prop_jinianbi",},
			count = {10,},
			gotoUI = {"share_hall",},
		},
		[2]=
		{
			id = 2,
			task = 21003,
			total = 5,
			task_name = "匹配场任意模式游戏5局",
			level = 1,
			item = {"prop_jinianbi",},
			count = {20,},
			gotoUI = {"free_hall",},
		},
		[3]=
		{
			id = 3,
			task = 21004,
			total = 1,
			task_name = "成功购买1次限时福利礼包",
			level = 1,
			item = {"prop_jinianbi",},
			count = {50,},
			gotoUI = {"year_xsfl",},
		},
		[4]=
		{
			id = 4,
			task = 21005,
			total = 10000,
			task_name = "街机捕鱼累计赢金1万",
			level = 1,
			item = {"prop_jinianbi",},
			count = {10,},
			gotoUI = {"game_FishingHall",},
		},
		[5]=
		{
			id = 5,
			task = 21005,
			total = 100000,
			task_name = "街机捕鱼累计赢金10万",
			level = 2,
			item = {"prop_jinianbi",},
			count = {20,},
			gotoUI = {"game_FishingHall",},
		},
		[6]=
		{
			id = 6,
			task = 21005,
			total = 1000000,
			task_name = "街机捕鱼累计赢金100万",
			level = 3,
			item = {"prop_jinianbi",},
			count = {50,},
			gotoUI = {"game_FishingHall",},
		},
		[7]=
		{
			id = 7,
			task = 21005,
			total = 2000000,
			task_name = "街机捕鱼累计赢金200万",
			level = 4,
			item = {"prop_jinianbi",},
			count = {50,},
			gotoUI = {"game_FishingHall",},
		},
		[8]=
		{
			id = 8,
			task = 21005,
			total = 5000000,
			task_name = "街机捕鱼累计赢金500万",
			level = 5,
			item = {"prop_jinianbi",},
			count = {150,},
			gotoUI = {"game_FishingHall",},
		},
		[9]=
		{
			id = 9,
			task = 21005,
			total = 10000000,
			task_name = "街机捕鱼累计赢金1000万",
			level = 6,
			item = {"prop_jinianbi",},
			count = {300,},
			gotoUI = {"game_FishingHall",},
		},
		[10]=
		{
			id = 10,
			task = 21005,
			total = 20000000,
			task_name = "街机捕鱼累计赢金2000万",
			level = 7,
			item = {"prop_jinianbi",},
			count = {500,},
			gotoUI = {"game_FishingHall",},
		},
		[11]=
		{
			id = 11,
			task = 21005,
			total = 50000000,
			task_name = "街机捕鱼累计赢金5000万",
			level = 8,
			item = {"prop_jinianbi",},
			count = {1500,},
			gotoUI = {"game_FishingHall",},
		},
		[12]=
		{
			id = 12,
			task = 21005,
			total = 100000000,
			task_name = "街机捕鱼累计赢金1亿",
			level = 9,
			item = {"prop_jinianbi",},
			count = {3000,},
			gotoUI = {"game_FishingHall",},
		},
	},
}