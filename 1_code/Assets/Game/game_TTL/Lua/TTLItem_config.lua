-- 创建时间:2020-03-25
return{
	 obs_data={
				[30] = {
					shape = "segment",
					type="boundary",
					s_point = tls.p(-815,0+24),
					e_point = tls.p(815,0+24),
					award = 0,
					complete_time = 1,
					obs_no = 30,
					obs_usetime = -1,
				},
				[31] = {
					shape = "segment",
					type="boundary",
					s_point = tls.p(-815,0+24),
					e_point = tls.p(-920,85+24),
					award = 0,
					complete_time = 1,
					obs_no = 31,
					obs_usetime = -1,
				},
				[32] = {
					shape = "segment",
					type="boundary",
					s_point = tls.p(-920,85+24),
					e_point = tls.p(-877,722+24),
					award = 0,
					complete_time = 1,
					obs_no = 32,
					obs_usetime = -1,
				},
				[33] = {
					shape = "segment",
					type="boundary",
					s_point = tls.p(-877,722+24),
					e_point = tls.p(-590,945+24),
					award = 0,
					complete_time = 1,
					obs_no = 33,
					obs_usetime = -1,
				},
				[34] = {
					shape = "segment",
					type="boundary",
					s_point = tls.p(-590,945+24),
					e_point = tls.p(590,945+24),
					award = 0,
					complete_time = 1,
					obs_no = 34,
					obs_usetime = -1,
				},
				[35] = {
					shape = "segment",
					type="boundary",
					s_point = tls.p(590,945+24),
					e_point = tls.p(877,722+24),
					award = 0,
					complete_time = 1,
					obs_no = 35,
					obs_usetime = -1,
				},
				[36] = {
					shape = "segment",
					type="boundary",
					s_point = tls.p(877,722+24),
					e_point = tls.p(920,85+24),
					award = 0,
					complete_time = 1,
					obs_no = 36,
					obs_usetime = -1,
				},
				[37] = {
					shape = "segment",
					type="boundary",
					e_point = tls.p(920,85+24),
					s_point = tls.p(815,0+24),
					award = 0,
					complete_time = 1,
					obs_no = 37,
					obs_usetime = -1,
				},

				[8] = {
					shape = "circle",
					type="bigAward",
					center = tls.p(-692,476+24),
					radius = 82 ,
					award = 2000,
					complete_time = 16,
					obs_no = 8,
					obs_usetime = 1,
				},
				[12] = {
					shape = "circle",
					type="bigAward",
					center = tls.p(692,476+24),
					radius = 82 ,
					award = 2000,
					complete_time = 16,
					obs_no = 12,
					obs_usetime = 1,
				},

				[13] = {
					shape = "circle",
					type="bigAward",
					center = tls.p(-538,722+24),
					radius = 65 ,
					award = 500,
					complete_time = 8,
					obs_no = 13,
					obs_usetime = 1,
				},
				[16] = {
					shape = "circle",
					type="bigAward",
					center = tls.p(538,722+24),
					radius = 65 ,
					award = 500,
					complete_time = 8,
					obs_no = 16,
					obs_usetime = 1,
				},


				[10] = {
					shape = "circle",
					type="bomb",
					center = tls.p(0,555+24),
					radius = 101 ,
					complete_time = 20,
					obs_no = 10,
					obs_usetime = 1,
				},


				[18] = {
					shape = "circle",
					type="switch",
					center = tls.p(-188,844+24),
					radius = 46 ,
					switch=false,
					brother_no_list={18,19,20},
					complete_time = 1,
					award_min=10000,
					award_max=99000,
					obs_no = 18,
					obs_usetime = 1,
				},
				[19] = {
					shape = "circle",
					type="switch",
					center = tls.p(0,770+24),
					radius = 46 ,
					switch=false,
					brother_no_list={18,19,20},
					complete_time = 1,
					award_min=10000,
					award_max=99000,
					obs_no = 19,
					obs_usetime = 1,
				},
				[20] = {
					shape = "circle",
					type="switch",
					center = tls.p(188,844+24),
					radius = 46 ,
					switch=false,
					brother_no_list={18,19,20},
					complete_time = 1,
					award_min=10000,
					award_max=99000,
					obs_no = 20,
					obs_usetime = 1,
				},



				[38] = {
					shape = "circle",
					type="boundary",
					center = tls.p(0,1067+24),
					radius = 297 ,
					award = 0,
					complete_time = 1,
					obs_no = 38,
					obs_usetime = -1,
				},

				[1] = {
					shape = "circle",
					type="normal",
					center = tls.p(-684,196+24),
					radius = 65 ,
					award = 2,
					complete_time = 1,
					obs_no = 1,
					obs_usetime = -1,
				},
				[2] = {
					shape = "circle",
					type="normal",
					center = tls.p(-246,182+24),
					radius = 38 ,
					award = 2,
					complete_time = 1,
					obs_no = 2,
					obs_usetime = -1,
				},
				[3] = {
					shape = "circle",
					type="normal",
					center = tls.p(235,192+24),
					radius = 38 ,
					award = 2,
					complete_time = 1,
					obs_no = 3,
					obs_usetime = -1,
				},
				[4] = {
					shape = "circle",
					type="normal",
					center = tls.p(684,196+24),
					radius = 65 ,
					award = 2,
					complete_time = 1,
					obs_no = 4,
					obs_usetime = -1,
				},
				[5] = {
					shape = "circle",
					type="normal",
					center = tls.p(-432,358+24),
					radius = 38 ,
					award = 2,
					complete_time = 1,
					obs_no = 5,
					obs_usetime = -1,
				},
				[6] = {
					shape = "circle",
					type="normal",
					center = tls.p(-0,300+24),
					radius = 38 ,
					award = 2,
					complete_time = 1,
					obs_no = 6,
					obs_usetime = -1,
				},
				[7] = {
					shape = "circle",
					type="normal",
					center = tls.p(432,359+24),
					radius = 38 ,
					award = 2,
					complete_time = 1,
					obs_no = 7,
					obs_usetime = -1,
				},
				[9] = {
					shape = "circle",
					type="normal",
					center = tls.p(-434,544+24),
					radius = 38 ,
					award = 2,
					complete_time = 1,
					obs_no = 9,
					obs_usetime = -1,
				},
				[11] = {
					shape = "circle",
					type="normal",
					center = tls.p(434,544+24),
					radius = 38 ,
					award = 2,
					complete_time = 1,
					obs_no = 11,
					obs_usetime = -1,
				},
				[14] = {
					shape = "circle",
					type="normal",
					center = tls.p(-254,646+24),
					radius = 38 ,
					award = 2,
					complete_time = 1,
					obs_no = 14,
					obs_usetime = -1,
				},
				[15] = {
					shape = "circle",
					type="normal",
					center = tls.p(267,638+24),
					radius = 38 ,
					award = 2,
					complete_time = 1,
					obs_no = 15,
					obs_usetime = -1,
				},
				[17] = {
					shape = "circle",
					type="normal",
					center = tls.p(-356,838+24),
					radius = 38 ,
					award = 2,
					complete_time = 1,
					obs_no = 17,
					obs_usetime = -1,
				},
				[21] = {
					shape = "circle",
					type="normal",
					center = tls.p(363,838+24),
					radius = 38 ,
					award = 2,
					complete_time = 1,
					obs_no = 21,
					obs_usetime = -1,
				},

			}

		}