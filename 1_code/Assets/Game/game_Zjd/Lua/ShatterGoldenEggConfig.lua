return {
	awards = {
		[1] = {
			image = "pay_icon_diamond1",
		},
		[2] = {
			image = "pay_icon_diamond2",
		},
		[3] = {
			image = "pay_icon_diamond3",
		},
		[4] = {
			image = "pay_icon_diamond4",
		},
		[5] = {
			image = "pay_icon_diamond5",
		},
		[6] = {
			image = "pay_icon_diamond6",
		},
		[7] = {
			image = "pay_icon_diamond7",
		},
		[8] = {
			image = "pay_icon_diamond8",
		},
		[9] = {
			image = "pay_icon_diamond1",
		},
		[10] = {
			image = "pay_icon_diamond2",
		},
		[11] = {
			image = "pay_icon_diamond3",
		},
		[12] = {
			image = "pay_icon_diamond4",
		}
	},

	logics = {
		[1] = {
			name = "木锤子",
			button = "HammerButton",
			button_icon = "zjd_icon_c1",
			egg = {
				prefab = "Game_jindan",
				action = {
					["-1"] = "broken",
					["0"] = "stand",
					["1"] = "dmg1",
					["2"] = "dmg2",
					["3"] = "dmg3",
					["4"] = "dmg4"
				}
			},
			hammer = "Hammer",
			icon = "zjd_icon14",
			respawn = 6,

			sale = nil
		},
		[2] = {
			name = "铁锤子",
			button = "HammerButton",
			button_icon = "zjd_icon_c2",
			egg = {
				prefab = "Game_jindan",
				action = {
					["-1"] = "broken",
					["0"] = "stand",
					["1"] = "dmg1",
					["2"] = "dmg2",
					["3"] = "dmg3",
					["4"] = "dmg4"
				}
			},
			hammer = "Hammer",
			icon = "zjd_icon15",
			respawn = 6,

			sale = nil
		},
		[3] = {
			name = "铜锤子",
			button = "HammerButton",
			button_icon = "zjd_icon_c3",
			egg = {
				prefab = "Game_jindan",
				action = {
					["-1"] = "broken",
					["0"] = "stand",
					["1"] = "dmg1",
					["2"] = "dmg2",
					["3"] = "dmg3",
					["4"] = "dmg4"
				}
			},
			hammer = "Hammer",
			icon = "zjd_icon16",
			respawn = 6,

			sale = {
				item_id = 36,
				item_title = "银锤 X %d",
				item_btn = "gy_18_1_game_zjd",
				product_id = ""
			}
		},
		[4] = {
			name = "金锤子",
			button = "HammerButton",
			button_icon = "zjd_icon_c4",
			egg = {
				prefab = "Game_jindan",
				action = {
					["-1"] = "broken",
					["0"] = "stand",
					["1"] = "dmg1",
					["2"] = "dmg2",
					["3"] = "dmg3",
					["4"] = "dmg4"
				}
			},
			hammer = "Hammer",
			icon = "zjd_icon17",
			respawn = 6,

			sale = {
				item_id = 37,
				item_title = "金锤 X %d",
				item_btn = "gy_18_2_game_zjd",
				product_id = ""
			}
		}
	},

	state = {
		BROKEN = -1,
		STAND = 0,
		DMG1 = 1,
		DMG2 = 2,
		DMG3 = 3,
		DMG4 = 4,
		DMG_MAX = 4
	},

	extra2eggs = {
		[1] = {
			base_money = 2000,
			auto_select_max_money = 2000 * 10,
		},
		[2] = {
			base_money = 5000,
			auto_select_max_money = 5000 * 10,
		},
		[3] = {
			base_money = 15000,
			auto_select_max_money = 15000 * 10 ,
		},
		[4] = {
			base_money = 30000,
			auto_select_max_money = 30000 * 10,
		},
		[5] = {
			base_money = 60000,
			auto_select_max_money = 60000 * 10,
		},
		[6] = {
			base_money = 120000,
			auto_select_max_money = 120000 * 10,
		},
		[7] = {
			base_money = 240000,
			auto_select_max_money = 240000 * 10,
		},
		[8] = {
			base_money = 480000,
			auto_select_max_money = 480000 * 10,
		},
		[9] = {
			base_money = 960000,
			auto_select_max_money = 960000 * 10 ,
		},
		[10] = {
			base_money = 1920000,
			auto_select_max_money = 1920000 * 10
		},
		-- [11] = {
		-- 	base_money = 4096000,
		-- 	auto_select_max_money = 4096000 * 10,
		-- },
		-- [12] = {
		-- 	base_money = 6880000,
		-- 	auto_select_max_money = 6880000 * 10,
		-- },
	}
}
