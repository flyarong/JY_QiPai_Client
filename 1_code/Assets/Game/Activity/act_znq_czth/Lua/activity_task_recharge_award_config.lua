return {
	base=
	{
		[1]=
		{
			index = 1,
			icon = "activity_bg_pic13",
			name = "充值特惠",
		},
	},
	tge=
	{
		tge1=
		{
			tge = "tge1",
			name = "充值特惠",
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
			task = 21015,
			total = 5000,
			is_money = 1,
			task_name = "累计充值50元",
			level = 1,
			item = {"jing_bi",},
			count = {10000,},
			gotoUI = {"shop_bay","jing_bi",},
		},
		[2]=
		{
			id = 2,
			task = 21015,
			total = 10000,
			is_money = 1,
			task_name = "累计充值100元",
			level = 2,
			item = {"jing_bi",},
			count = {20000,},
			gotoUI = {"shop_bay","jing_bi",},
		},
		[3]=
		{
			id = 3,
			task = 21015,
			total = 20000,
			is_money = 1,
			task_name = "累计充值200元",
			level = 3,
			item = {"jing_bi","shop_gold_sum"},
			count = {30000,1,},
			gotoUI = {"shop_bay","jing_bi",},
		},
		[4]=
		{
			id = 4,
			task = 21015,
			total = 50000,
			is_money = 1,
			task_name = "累计充值500元",
			level = 4,
			item = {"jing_bi","shop_gold_sum"},
			count = {80000,3,},
			gotoUI = {"shop_bay","jing_bi",},
		},
		[5]=
		{
			id = 5,
			task = 21015,
			total = 100000,
			is_money = 1,
			task_name = "累计充值1000元",
			level = 5,
			item = {"jing_bi","shop_gold_sum"},
			count = {150000,5,},
			gotoUI = {"shop_bay","jing_bi",},
		},
		[6]=
		{
			id = 6,
			task = 21015,
			total = 300000,
			is_money = 1,
			task_name = "累计充值3000元",
			level = 6,
			item = {"jing_bi","shop_gold_sum"},
			count = {500000,18,},
			gotoUI = {"shop_bay","jing_bi",},
		},
		[7]=
		{
			id = 7,
			task = 21015,
			total = 800000,
			is_money = 1,
			task_name = "累计充值8000元",
			level = 7,
			item = {"jing_bi","shop_gold_sum"},
			count = {1500000,28,},
			gotoUI = {"shop_bay","jing_bi",},
		},
		[8]=
		{
			id = 8,
			task = 21015,
			total = 2000000,
			is_money = 1,
			task_name = "累计充值20000元",
			level = 8,
			item = {"jing_bi","shop_gold_sum"},
			count = {3000000,88,},
			gotoUI = {"shop_bay","jing_bi",},
		},
	},
}