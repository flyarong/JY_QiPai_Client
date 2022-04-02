-- 创建时间:2020-11-18
return {
	base=
	{
		[1]=
		{
			index = 1,
			--icon = "ymfl_bg_11",
            name = "连购返利",
            is_spread = 1,
		},
	},
	tge=
	{
		tge1=
		{
			tge = "tge1",
			name = "连购返利",
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
				task = 21560,
				total = 3,
				task_name = "每天在游戏中累计购买3次98元",
				level = 1,
				item = {"jing_bi",},
				count = {"88888鲸币",},
				gotoUI = {"shop_bay","jing_bi"},
			},
			[2]=
			{
				id = 2,
				task = 21561,
				total = 3,
				task_name = "每天在游戏中累计购买3次50元",
				level = 1,
				item = {"jing_bi",},
				count = {"58888鲸币",},
				gotoUI = {"shop_bay","jing_bi"},
			},
			[3]=
			{
				id = 3,
				task = 21562,
				total = 3,
				task_name = "每天在游戏中累计购买3次30元",
				level = 1,
				item = {"jing_bi",},
				count = {"38888鲸币",},
				gotoUI = {"shop_bay","jing_bi"},
			},
			[4]=
			{
				id = 4,
				task = 21563,
				total = 3,
				task_name = "每天在游戏中累计购买3次15元",
				level = 1,
				item = {"jing_bi",},
				count = {"18888鲸币",},
				gotoUI = {"shop_bay","jing_bi"},
			},
	},
	helpinfo=
	{
	},
}
