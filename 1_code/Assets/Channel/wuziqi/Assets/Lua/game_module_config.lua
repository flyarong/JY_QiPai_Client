return {
	config=
	{
		[1]=
		{
			id = 1,
			key = "sys_qx",
			desc = "权限管理",
			lua = "SYSQXManager",
			is_on_off = 1,
			enable = 1,
			state = 1,
		},
		[2]=
		{
			id = 2,
			key = "sys_item_manager",
			desc = "系统：道具",
			lua = "SysItemManager",
			is_on_off = 1,
			enable = 1,
			state = 1,
		},
		[3]=
		{
			id = 3,
			key = "sys_task",
			desc = "系统：任务",
			lua = "SysTaskManager",
			is_on_off = 1,
			enable = 1,
			state = 1,
		},
		[4]=
		{
			id = 4,
			key = "sys_condition",
			desc = "系统：条件管理器",
			lua = "SysConditionManager",
			is_on_off = 1,
			enable = 1,
			state = 1,
		},
		[5]=
		{
			id = 5,
			key = "sys_fishing_manager",
			desc = "系统：捕鱼管理器",
			lua = "SysFishingManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[6]=
		{
			id = 6,
			key = "sys_free_manager",
			desc = "系统：自由场管理器",
			lua = "SysFreeManager",
			is_on_off = 1,
			enable = 1,
			state = 1,
		},
		[7]=
		{
			id = 7,
			key = "sys_match_manager",
			desc = "系统：比赛场管理器",
			lua = "SysMatchManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[8]=
		{
			id = 8,
			key = "sys_lhd_manager",
			desc = "系统：龙虎斗管理器",
			lua = "SysLhdManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[9]=
		{
			id = 9,
			key = "sys_zjf_manager",
			desc = "系统：自建房管理器",
			lua = "SysZjfManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[10]=
		{
			id = 10,
			key = "sys_interactive_player",
			desc = "系统：互动",
			lua = "SysInteractivePlayerManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[11]=
		{
			id = 11,
			key = "sys_interactive_chat",
			desc = "系统：互动聊天",
			lua = "SysInteractiveChatManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[12]=
		{
			id = 12,
			key = "sys_interactive_ani",
			desc = "系统：互动表情",
			lua = "SysInteractiveAniManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[13]=
		{
			id = 13,
			key = "sys_personal_info",
			desc = "系统：玩家中心",
			lua = "SysPersonalInfoManager",
			is_on_off = 1,
			enable = 1,
			state = 1,
		},
		[14]=
		{
			id = 14,
			key = "guide",
			desc = "系统：引导（新手）",
			lua = "GuideManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[15]=
		{
			id = 15,
			key = "guide_to_match",
			desc = "引导：引导到比赛场",
			lua = "GuideToMatchManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[16]=
		{
			id = 16,
			key = "guide_to_mini",
			desc = "引导：引导到小游戏",
			lua = "GuideToMiniGamePanel",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[17]=
		{
			id = 17,
			key = "sys_guide_select_game",
			desc = "系统：引导选择游戏",
			lua = "SysGuideSelectGameManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[18]=
		{
			id = 18,
			key = "act_lottery_base_manager",
			desc = "活动：抽奖基础管理器",
			lua = "ActLotteryBaseManager",
			is_on_off = 1,
			enable = 1,
			state = 1,
		},
		[19]=
		{
			id = 19,
			key = "gift_game_flash_sale_gift_manager",
			desc = "礼包：特惠礼包管理器",
			lua = "GiftGameFlashSaleGiftManager",
			is_on_off = 1,
			enable = 1,
			state = 1,
		},
		[20]=
		{
			id = 20,
			key = "sys_player_go_broke_manager",
			desc = "系统：破产流程管理",
			lua = "SysPlayerGoBrokeManager",
			is_on_off = 1,
			enable = 1,
			state = 1,
		},
		[21]=
		{
			id = 21,
			key = "sys_act_operator",
			desc = "系统活动：运营活动（连胜，累胜）",
			lua = "SysActOperatorManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[22]=
		{
			id = 22,
			key = "sys_bag",
			desc = "系统背包",
			lua = "BagManager",
			is_on_off = 1,
			enable = 1,
			state = 1,
		},
		[23]=
		{
			id = 23,
			key = "sys_setting",
			desc = "系统：设置",
			lua = "SysSettingManager",
			is_on_off = 1,
			enable = 1,
			state = 1,
		},
		[24]=
		{
			id = 24,
			key = "sys_email",
			desc = "邮件",
			lua = "EmailLogic",
			is_on_off = 1,
			enable = 1,
			state = 1,
		},
		[25]=
		{
			id = 25,
			key = "sys_cfzx",
			desc = "财富中心(赚钱)",
			lua = "GameMoneyCenterLogic",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[26]=
		{
			id = 26,
			key = "sys_fx",
			desc = "分享",
			lua = "SYSFXManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[27]=
		{
			id = 27,
			key = "sys_banner",
			desc = "系统banner",
			lua = "BannerManager",
			is_on_off = 1,
			enable = 1,
			state = 1,
		},
		[28]=
		{
			id = 28,
			key = "sys_banner_widget",
			desc = "系统banner_widget",
			lua = "BannerWidgetManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[29]=
		{
			id = 29,
			key = "sys_banner_hall",
			desc = "系统：大厅banner",
			lua = "SysBannerHallManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[30]=
		{
			id = 30,
			key = "sys_banner_act",
			desc = "系统：活动banner",
			lua = "ActivityBannerManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[31]=
		{
			id = 31,
			key = "sys_binding_phone",
			desc = "系统：绑定手机",
			lua = "SysBindingPhoneManager",
			is_on_off = 1,
			enable = 1,
			state = 1,
		},
		[32]=
		{
			id = 32,
			key = "sys_binding_phone_award",
			desc = "系统：绑定手机得奖",
			lua = "SysBindingPhoneAwardManager",
			is_on_off = 1,
			enable = 1,
			state = 1,
		},
		[33]=
		{
			id = 33,
			key = "sys_binding_verifide",
			desc = "系统：绑定实名",
			lua = "SysBinddingVerifideManager",
			is_on_off = 1,
			enable = 1,
			state = 1,
		},
		[34]=
		{
			id = 34,
			key = "sys_binding_zfb",
			desc = "系统：绑定支付宝",
			lua = "SysBindingZFBManager",
			is_on_off = 1,
			enable = 1,
			state = 1,
		},
		[35]=
		{
			id = 35,
			key = "sys_dot_desser",
			desc = "系统：装扮",
			lua = "HallDressPanel",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[36]=
		{
			id = 36,
			key = "sys_dui_huan",
			desc = "系统：兑换",
			lua = "SysDuiHuanManager",
			is_on_off = 1,
			enable = 1,
			state = 1,
		},
		[37]=
		{
			id = 37,
			key = "sys_game_broadcast",
			desc = "系统：游戏广播",
			lua = "SysGameBroadcastManager",
			is_on_off = 1,
			enable = 1,
			state = 1,
		},
		[38]=
		{
			id = 38,
			key = "sys_game_tool",
			desc = "系统：游戏工具",
			lua = "SysGameToolManager",
			is_on_off = 1,
			enable = 1,
			state = 1,
		},
		[39]=
		{
			id = 39,
			key = "sys_game_voice",
			desc = "系统：游戏语音（房卡场使用）",
			lua = "SysGameVoiceManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[40]=
		{
			id = 40,
			key = "sys_head",
			desc = "系统：头像",
			lua = "ComHeadPrefab",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[41]=
		{
			id = 41,
			key = "sys_help",
			desc = "系统：帮助",
			lua = "HelpPanel",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[42]=
		{
			id = 42,
			key = "sys_service",
			desc = "系统：客服",
			lua = "ServicePrefab",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[43]=
		{
			id = 43,
			key = "sys_service_gzh",
			desc = "系统：客服公众号",
			lua = "SysServiceGzhManager",
			is_on_off = 1,
			enable = 1,
			state = 1,
		},
		[44]=
		{
			id = 44,
			key = "sys_total_red",
			desc = "系统：所有福卡",
			lua = "SysTotalRedManager",
			is_on_off = 1,
			enable = 1,
			state = 1,
		},
		[45]=
		{
			id = 45,
			key = "sys_withdraw",
			desc = "系统：提现",
			lua = "WithdrawPanel",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[46]=
		{
			id = 46,
			key = "sys_wyhb",
			desc = "系统：我要福卡",
			lua = "SysWYHBManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[47]=
		{
			id = 47,
			key = "sys_room_card",
			desc = "系统：房卡",
			lua = "SysRoomCardManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[48]=
		{
			id = 48,
			key = "vip",
			desc = "VIP专享(和游戏中的VIP系统有牵连)",
			lua = "VIPManager",
			is_on_off = 1,
			enable = 1,
			state = 1,
		},
		[49]=
		{
			id = 49,
			key = "sys_vip2_up",
			desc = "VIP3直通礼包",
			lua = "SYSVip2UpManager",
			is_on_off = 1,
			enable = 1,
			state = 1,
		},
		[50]=
		{
			id = 50,
			key = "sys_vip3_guide",
			desc = "VIP4引导",
			lua = "SYSVip3GuideManager",
			is_on_off = 1,
			enable = 1,
			state = 1,
		},
		[51]=
		{
			id = 51,
			key = "normal_activity_common",
			desc = "活动公用",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[52]=
		{
			id = 52,
			key = "ty_gift",
			desc = "通用礼包",
			lua = "TYGiftManager",
			is_on_off = 1,
			enable = 1,
			state = 1,
		},
		[53]=
		{
			id = 53,
			key = "sys_stxt",
			desc = "师徒系统",
			lua = "SYSSTXTManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[54]=
		{
			id = 54,
			key = "xycj",
			desc = "幸运抽奖",
			lua = "XYCJActivityManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[55]=
		{
			id = 55,
			key = "xrhb",
			desc = "新人福卡(和游戏的新手引导等有牵连)",
			lua = "ActivitySevenDayLogic",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[56]=
		{
			id = 56,
			key = "qys",
			desc = "千元大奖赛",
			lua = "QYSEnterPrefab",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[57]=
		{
			id = 57,
			key = "sys_sclb",
			desc = "首充礼包（废弃）",
			lua = "SYSSCLBManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[58]=
		{
			id = 58,
			key = "jyfl",
			desc = "鲸鱼福利",
			lua = "JYFLManager",
			is_on_off = 1,
			enable = 1,
			state = 1,
		},
		[59]=
		{
			id = 59,
			key = "sys_xsfl",
			desc = "限时福利",
			lua = "SYSXSFLManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[60]=
		{
			id = 60,
			key = "sys_xyjl",
			desc = "幸运降临",
			lua = "SYSXYJLManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[61]=
		{
			id = 61,
			key = "sys_yk",
			desc = "系统：月卡",
			lua = "SYSYKManager",
			is_on_off = 1,
			enable = 1,
			state = 1,
		},
		[62]=
		{
			id = 62,
			key = "jyzk",
			desc = "鲸鱼周卡",
			lua = "JYZKManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[63]=
		{
			id = 63,
			key = "sys_qd",
			desc = "签到",
			lua = "SYSQDManager",
			is_on_off = 0,
			enable = 1,
			state = 1,
		},
		[64]=
		{
			id = 64,
			key = "sys_xy",
			desc = "许愿池",
			lua = "SYSXYManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[65]=
		{
			id = 65,
			key = "hall_activity",
			desc = "系统：大厅活动",
			lua = "GameActivityManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[66]=
		{
			id = 66,
			key = "sys_act_base",
			desc = "活动Base",
			lua = "SYSACTBASEManager",
			is_on_off = 1,
			enable = 1,
			state = 1,
		},
		[67]=
		{
			id = 67,
			key = "sys_mflhb",
			desc = "免费领福卡",
			lua = "SYSMFLHBManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[68]=
		{
			id = 68,
			key = "sys_sjjbjl",
			desc = "随机金币领取",
			lua = "SYSSJJBJLManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[69]=
		{
			id = 69,
			key = "sys_dttjyxw",
			desc = "大厅推荐游戏位",
			lua = "DTTJYXWManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[70]=
		{
			id = 70,
			key = "sys_gift_exchange",
			desc = "礼包兑换",
			lua = "GiftExchangeManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[71]=
		{
			id = 71,
			key = "sys_shphb",
			desc = "水浒消消乐单笔赢金排行榜",
			lua = "XXLSHPHBManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[72]=
		{
			id = 72,
			key = "sys_btn_csxxl",
			desc = "财神消消乐大厅按钮",
			lua = "HallBtnCsxxlManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[73]=
		{
			id = 73,
			key = "sys_fkrk",
			desc = "房卡场入口",
			lua = "FKRKManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[74]=
		{
			id = 74,
			key = "sys_xtsjyd",
			desc = "系统升级引导",
			lua = "XTSJYDManager",
			is_on_off = 0,
			enable = 1,
			state = 1,
		},
		[75]=
		{
			id = 75,
			key = "sys_smrz",
			desc = "实名认证",
			lua = "SYSSMRZManager",
			is_on_off = 1,
			enable = 1,
			state = 1,
		},
		[76]=
		{
			id = 76,
			key = "sys_qhb",
			desc = "抢福卡",
			lua = "SYSQHBManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[77]=
		{
			id = 77,
			key = "sys_gg",
			desc = "内部广告",
			lua = "SysGGManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[78]=
		{
			id = 78,
			key = "sys_jjj",
			desc = "救济金（鲸鱼福利）",
			lua = "SysJJJManager",
			is_on_off = 1,
			enable = 1,
			state = 1,
		},
		[79]=
		{
			id = 79,
			key = "sys_hcfx",
			desc = "合成分享",
			lua = "SYSHCFXManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[80]=
		{
			id = 80,
			key = "sys_xrzs",
			desc = "系统：新人专属",
			lua = "SYSXRZSManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[81]=
		{
			id = 81,
			key = "sys_hgyl",
			desc = "回归有礼",
			lua = "SYSHGYLManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[82]=
		{
			id = 82,
			key = "sys_ssy_bzssy",
			desc = "备战双十一",
			lua = "SYSSSYBZSSYManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[83]=
		{
			id = 83,
			key = "by_mfhb",
			desc = "捕鱼：免费福卡",
			lua = "BYMFHBManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[84]=
		{
			id = 84,
			key = "by_ljyj",
			desc = "捕鱼：累计赢金",
			lua = "BYLJYJManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[85]=
		{
			id = 85,
			key = "by_drb",
			desc = "捕鱼：达人榜",
			lua = "BYDRBManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[86]=
		{
			id = 86,
			key = "xxlsg_phb",
			desc = "水果消消乐排行榜",
			lua = "XXLSGPHBManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[87]=
		{
			id = 87,
			key = "xxlsh_mrrw",
			desc = "水浒消消乐每日任务",
			lua = "XXLSHMRRWManager",
			is_on_off = 1,
			enable = 1,
			state = 1,
		},
		[88]=
		{
			id = 88,
			key = "xxlsg_mrrw",
			desc = "水果消消乐每日任务",
			lua = "XXLSGMRRWManager",
			is_on_off = 1,
			enable = 1,
			state = 1,
		},
		[89]=
		{
			id = 89,
			key = "qysXts",
			desc = "千元赛提示",
			lua = "QYSXTSManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[90]=
		{
			id = 90,
			key = "bybsXts",
			desc = "捕鱼比赛提示",
			lua = "BYBSXTSManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[91]=
		{
			id = 91,
			key = "vip_gift",
			desc = "VIP礼包",
			lua = "VIPGiftLogic",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[92]=
		{
			id = 92,
			key = "by_xrhb",
			desc = "捕鱼新人福卡",
			lua = "FishingXRHBManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[93]=
		{
			id = 93,
			key = "act_sjjl",
			desc = "版本升级奖励",
			lua = "SJJLManager",
			is_on_off = 0,
			enable = 1,
			state = 1,
		},
		[94]=
		{
			id = 94,
			key = "sys_geyl",
			desc = "感恩有礼",
			lua = "GEYLManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[95]=
		{
			id = 95,
			key = "gegys_yy",
			desc = "感恩公益赛",
			lua = "GEYuyueManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[96]=
		{
			id = 96,
			key = "sys_xqdzz",
			desc = "雪球大作战",
			lua = "XQDZZManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[97]=
		{
			id = 97,
			key = "pdk_activity",
			desc = "跑得快福利",
			lua = "PDKActivityManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[98]=
		{
			id = 98,
			key = "btn_tglb",
			desc = "全返礼包在比赛场大厅的按钮",
			lua = "TGLBManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[99]=
		{
			id = 99,
			key = "act_fksse",
			desc = "疯狂双十二",
			lua = "FKSSEManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[100]=
		{
			id = 100,
			key = "btn_csms",
			desc = "财神模式按钮",
			lua = "CSMSManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[101]=
		{
			id = 101,
			key = "xrhb1",
			desc = "新人福卡任务(VIP福卡任务，和游戏的新手引导等有牵连)",
			lua = "ActivityXRHB1Logic",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[102]=
		{
			id = 102,
			key = "sys_xbyylb",
			desc = "新人一元礼包",
			lua = "NewOneYuanManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[103]=
		{
			id = 103,
			key = "xrmfjb",
			desc = "新人免费鲸币",
			lua = "XRMFJBManager",
			is_on_off = 1,
			enable = 1,
			state = 1,
		},
		[104]=
		{
			id = 104,
			key = "act_sdqql",
			desc = "圣诞敲敲乐",
			lua = "SDQQLManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[105]=
		{
			id = 105,
			key = "sys_cfzx_qflb",
			desc = "财富中心全返礼包",
			lua = "MoneyCenterQFLBManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[106]=
		{
			id = 106,
			key = "act_nmhks",
			desc = "年末回馈赛",
			lua = "NmhksManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[107]=
		{
			id = 107,
			key = "act_nm_hgyl",
			desc = "年末回归有礼",
			lua = "NmhgylManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[108]=
		{
			id = 108,
			key = "act_czsnh",
			desc = "年末充值活动",
			lua = "CzsnhManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[109]=
		{
			id = 109,
			key = "act_nm_yjcdj",
			desc = "年末赢金抽大奖",
			lua = "NmYjcdjManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[110]=
		{
			id = 110,
			key = "act_hqyd",
			desc = "欢庆元旦",
			lua = "HQYDManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[111]=
		{
			id = 111,
			key = "act_cjs_gfjb",
			desc = "瓜分鲸币",
			lua = "CJS_GFJBManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[112]=
		{
			id = 112,
			key = "act_sn_djfl",
			desc = "鼠年_对局福利",
			lua = "SN_DJFLManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[113]=
		{
			id = 113,
			key = "act_sn_shfl",
			desc = "鼠年_水浒福利",
			lua = "SN_SHFLManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[114]=
		{
			id = 114,
			key = "act_sn_yjcj",
			desc = "鼠年_赢金抽大奖",
			lua = "SNYJCJManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[115]=
		{
			id = 115,
			key = "hallbtn_shxxl",
			desc = "大厅水浒图标",
			lua = "HallBtnShxxlManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[116]=
		{
			id = 116,
			key = "act_dzyl",
			desc = "点赞有礼",
			lua = "DZYLManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[117]=
		{
			id = 117,
			key = "act_sn_bzsl",
			desc = "爆竹送礼",
			lua = "SNBZSLManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[118]=
		{
			id = 118,
			key = "act_sn_hby",
			desc = "福卡雨",
			lua = "SNHBYManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[119]=
		{
			id = 119,
			key = "act_ycs_cssl",
			desc = "迎财神_财神送礼",
			lua = "YCS_CSSLManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[120]=
		{
			id = 120,
			key = "act_ycs_hgyl",
			desc = "迎财神_回归有礼",
			lua = "YCS_HGYLManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[121]=
		{
			id = 121,
			key = "act_yx_cdm",
			desc = "元宵_猜灯谜 ",
			lua = "YX_CDMManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[122]=
		{
			id = 122,
			key = "act_yx_ljyj",
			desc = "元宵_累计赢金",
			lua = "YX_LJYJManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[123]=
		{
			id = 123,
			key = "act_cjs_zdfl",
			desc = "辞旧岁-炸弹福利",
			lua = "CJS_ZDFLManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[124]=
		{
			id = 124,
			key = "act_ycs_bsyy",
			desc = "迎财神_比赛预约",
			lua = "YCS_BSYYManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[125]=
		{
			id = 125,
			key = "act_lmqrj",
			desc = "浪漫情人节",
			lua = "LMQRJManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[126]=
		{
			id = 126,
			key = "act_xrqtl",
			desc = "新人七天乐",
			lua = "XRQTLManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[127]=
		{
			id = 127,
			key = "act_fxlx",
			desc = "分享拉新",
			lua = "FXLXManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[128]=
		{
			id = 128,
			key = "act_ltqf",
			desc = "龙腾祈福",
			lua = "LTQFManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[129]=
		{
			id = 129,
			key = "act_001_bsyy",
			desc = "月末福利-比赛预约",
			lua = "ACT_001BSYYManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[130]=
		{
			id = 130,
			key = "act_001_hgyl",
			desc = "月末福利-回归有礼",
			lua = "ACT_001HGYLManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[131]=
		{
			id = 131,
			key = "act_001_byfl",
			desc = "月末福利-捕鱼福利",
			lua = "ACT_001BYFLManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[132]=
		{
			id = 132,
			key = "act_001_yjwd",
			desc = "月末福利-有奖问答",
			lua = "ACT_001YJWDManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[133]=
		{
			id = 133,
			key = "act_002_nscj",
			desc = "女神节-抽奖",
			lua = "Act_002NSCJManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[134]=
		{
			id = 134,
			key = "act_002_nslw",
			desc = "女神节-礼物",
			lua = "Act_002NSLWManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[135]=
		{
			id = 135,
			key = "act_002_UIChange",
			desc = "女神节-财神模式",
			lua = "act_002UIChangeManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[136]=
		{
			id = 136,
			key = "act_002_hfdh",
			desc = "女神节-话费兑换",
			lua = "Act_002HFDHManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[137]=
		{
			id = 137,
			key = "act_003_zshm",
			desc = "植树护苗",
			lua = "Act_003ZSHMManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[138]=
		{
			id = 138,
			key = "act_003_zslw",
			desc = "植树礼物",
			lua = "Act_003ZSLWManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[139]=
		{
			id = 139,
			key = "act_004_fkyzd_cz",
			desc = "疯狂原子弹充值",
			lua = "Act_004FKYZDCZManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[140]=
		{
			id = 140,
			key = "act_004_fkyzd_sj",
			desc = "疯狂原子弹收集",
			lua = "Act_004FKYZDSJManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[141]=
		{
			id = 141,
			key = "act_004_fkyzd_gm",
			desc = "疯狂原子弹购买",
			lua = "Act_004FKYZDGMManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[142]=
		{
			id = 142,
			key = "act_004_jika",
			desc = "季卡",
			lua = "Act_004JIKAManager",
			is_on_off = 1,
			enable = 1,
			state = 1,
		},
		[143]=
		{
			id = 143,
			key = "act_004_lylb",
			desc = "0元礼包",
			lua = "Act_004LYLBManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[144]=
		{
			id = 144,
			key = "by3d_act_xycb",
			desc = "3D捕鱼-幸运彩贝",
			lua = "BY3DActXYCBManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[145]=
		{
			id = 145,
			key = "act_002_hbfx",
			desc = "福卡分享",
			lua = "Act_002HBFXManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[146]=
		{
			id = 146,
			key = "act_005_hgjx",
			desc = "回归惊喜",
			lua = "Act_005_HGJXManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[147]=
		{
			id = 147,
			key = "act_005_bsyy",
			desc = "比赛预约",
			lua = "ACT_005BSYYManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[148]=
		{
			id = 148,
			key = "act_005_tnsh",
			desc = "天女散花",
			lua = "Act_005_TNSHManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[149]=
		{
			id = 149,
			key = "act_005_ymfl",
			desc = "月末福利",
			lua = "Act_005_YMFLManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[150]=
		{
			id = 150,
			key = "act_005_ymfl_hyzh",
			desc = "好友召回",
			lua = "Act_005YMFLHYZHManager",
			is_on_off = 1,
			enable = 1,
			state = 1,
		},
		[151]=
		{
			id = 151,
			key = "act_005_yzqj",
			desc = "一字千金",
			lua = "Act_005YZQJManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[152]=
		{
			id = 152,
			key = "act_006_czfl",
			desc = "充值返利",
			lua = "Act_006CZFLManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[153]=
		{
			id = 153,
			key = "act_006_qflb2",
			desc = "全返礼包Ⅱ",
			lua = "Act_006QFLB2Manager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[154]=
		{
			id = 154,
			key = "act_006_qflb3",
			desc = "全返礼包Ⅲ",
			lua = "Act_006QFLB3Manager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[155]=
		{
			id = 155,
			key = "act_006_xyfl",
			desc = "新游福利",
			lua = "Act_006XYFLManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[156]=
		{
			id = 156,
			key = "act_007_fkfl",
			desc = "疯狂返利",
			lua = "Act_007_FKFLManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[157]=
		{
			id = 157,
			key = "act_007_ckt",
			desc = "抽空调（季卡）",
			lua = "Act_007CKTManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[158]=
		{
			id = 158,
			key = "act_lottery_card",
			desc = "抽奖卡片",
			lua = "LotteryCardManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[159]=
		{
			id = 159,
			key = "act_father",
			desc = "父亲节",
			lua = "ActivityFatherPanel",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[160]=
		{
			id = 160,
			key = "act_lottery",
			desc = "抽奖",
			lua = "CommonLotteryPanel",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[161]=
		{
			id = 161,
			key = "act_product_rating",
			desc = "评论有奖",
			lua = "ProductRatingPanel",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[162]=
		{
			id = 162,
			key = "act_prop_box",
			desc = "活动：开宝箱",
			lua = "PropBoxManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[163]=
		{
			id = 163,
			key = "act_zjb",
			desc = "活动：赚鲸币",
			lua = "GameGatherPanel",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[164]=
		{
			id = 164,
			key = "gift_com_gift",
			desc = "礼包：单个礼包模板",
			lua = "GameComGiftPanel",
			is_on_off = 1,
			enable = 1,
			state = 1,
		},
		[165]=
		{
			id = 165,
			key = "gift_golden_pig",
			desc = "礼包：金猪礼包",
			lua = "GiftGoldenPigManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[166]=
		{
			id = 166,
			key = "gift_one_yuan",
			desc = "礼包：一元礼包",
			lua = "GiftOneYuanManager",
			is_on_off = 1,
			enable = 1,
			state = 1,
		},
		[167]=
		{
			id = 167,
			key = "gift_yycz",
			desc = "礼包：一元超值",
			lua = "GiftBoxPanel",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[168]=
		{
			id = 168,
			key = "gift_sh",
			desc = "礼包：水浒",
			lua = "SH_GiftPanel",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[169]=
		{
			id = 169,
			key = "gift_13",
			desc = "千元赛礼包",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[170]=
		{
			id = 170,
			key = "gift_74",
			desc = "迎新礼包",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[171]=
		{
			id = 171,
			key = "gift_10025",
			desc = "捕鱼特惠礼包",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[172]=
		{
			id = 172,
			key = "gift_10087",
			desc = "每日特惠礼包",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[173]=
		{
			id = 173,
			key = "act_look_back",
			desc = "活动：回顾",
			lua = "LookBackPanel",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[174]=
		{
			id = 174,
			key = "act_yznyy",
			desc = "一周年预约",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[175]=
		{
			id = 175,
			key = "ad",
			desc = "广告图",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[176]=
		{
			id = 176,
			key = "sys_Inform",
			desc = "通知废弃",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[177]=
		{
			id = 177,
			key = "gift_fishing_subsidy",
			desc = "礼包：捕鱼特惠",
			lua = "GiftFishingSubsidyManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[178]=
		{
			id = 178,
			key = "gift_shatter_golden_sale",
			desc = "礼包：限时特惠",
			lua = "GiftShatterGoldenSaleManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[179]=
		{
			id = 179,
			key = "sys_free_jackpot",
			desc = "系统：自由场奖池",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[180]=
		{
			id = 180,
			key = "ad_old",
			desc = "广告图废弃",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[181]=
		{
			id = 181,
			key = "gift_old",
			desc = "礼包废弃",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[182]=
		{
			id = 182,
			key = "act_znq_bhkl",
			desc = "周年庆捕获快乐",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[183]=
		{
			id = 183,
			key = "act_znq_byddj",
			desc = "周年庆捕鱼兑大奖",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[184]=
		{
			id = 184,
			key = "act_znq_czhk",
			desc = "周年庆充值回馈",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[185]=
		{
			id = 185,
			key = "act_znq_czth",
			desc = "周年庆充值特惠",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[186]=
		{
			id = 186,
			key = "act_znq_ges",
			desc = "周年庆感恩赛",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[187]=
		{
			id = 187,
			key = "act_znq_jnb",
			desc = "周年庆纪念币",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[188]=
		{
			id = 188,
			key = "act_znq_kqhy",
			desc = "周年庆开启回忆",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[189]=
		{
			id = 189,
			key = "act_znq_qmby",
			desc = "周年庆全民捕鱼",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[190]=
		{
			id = 190,
			key = "act_znq_task",
			desc = "周年庆任务",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[191]=
		{
			id = 191,
			key = "act_znq_xxldzz",
			desc = "周年庆消消乐大作战",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[192]=
		{
			id = 192,
			key = "act_znq_yjshl",
			desc = "周年庆赢金送豪礼",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[193]=
		{
			id = 193,
			key = "act_znq_yjzb",
			desc = "周年庆赢金争霸",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[194]=
		{
			id = 194,
			key = "act_znq_yy",
			desc = "周年庆预约",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[195]=
		{
			id = 195,
			key = "act_znq_zjdshl",
			desc = "周年庆砸金蛋送好礼",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[196]=
		{
			id = 196,
			key = "act_znq_qdlb",
			desc = "周年庆庆典礼包",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[197]=
		{
			id = 197,
			key = "act_znq_gelb",
			desc = "周年庆感恩礼包",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[198]=
		{
			id = 198,
			key = "act_znq_byzdy",
			desc = "周年庆捕鱼总动员",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[199]=
		{
			id = 199,
			key = "act_000_ttl",
			desc = "活动：弹弹乐",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[200]=
		{
			id = 200,
			key = "act_qlyx",
			desc = "活动：清凉一夏",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[201]=
		{
			id = 201,
			key = "act_qx",
			desc = "活动：七夕",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[202]=
		{
			id = 202,
			key = "act_zz",
			desc = "活动：集粽子",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[203]=
		{
			id = 203,
			key = "by3d_act_6in1",
			desc = "活动：疯狂六选一",
			lua = "BY3DAct6in1Manager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[204]=
		{
			id = 204,
			key = "by3d_act_caijin",
			desc = "活动：彩金抽奖",
			lua = "BY3DActCaijinManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[205]=
		{
			id = 205,
			key = "by3d_act_zhuanpan",
			desc = "活动：转盘抽奖",
			lua = "BY3DActZhuanpanManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[206]=
		{
			id = 206,
			key = "by_ljdh",
			desc = "活动：捕鱼累计兑换",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[207]=
		{
			id = 207,
			key = "cfzx_sytx",
			desc = "系统：财富中心收益提醒",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[208]=
		{
			id = 208,
			key = "qql_csd",
			desc = "活动：敲敲乐财神到",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[209]=
		{
			id = 209,
			key = "qql_ljyj",
			desc = "活动：敲敲乐累计赢金",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[210]=
		{
			id = 210,
			key = "swjl_icon",
			desc = "系统：实物图片",
			is_on_off = 1,
			enable = 1,
			state = 1,
		},
		[211]=
		{
			id = 211,
			key = "sys_banner_act",
			desc = "系统：banner活动",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[212]=
		{
			id = 212,
			key = "sys_binding_shipping_address",
			desc = "系统：绑定地址",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[213]=
		{
			id = 213,
			key = "gift_gqlb",
			desc = "礼包：国庆礼包",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[214]=
		{
			id = 214,
			key = "sys_honor",
			desc = "系统：荣誉系统",
			lua = "SysHonorManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[215]=
		{
			id = 215,
			key = "sys_kxxxl",
			desc = "活动：开心消消乐",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[216]=
		{
			id = 216,
			key = "sys_qmfx",
			desc = "活动：全民分享",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[217]=
		{
			id = 217,
			key = "sys_sqdfs",
			desc = "活动：暑期大放送",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[218]=
		{
			id = 218,
			key = "sys_yjshl",
			desc = "活动：赢金送豪礼",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[219]=
		{
			id = 219,
			key = "sys_yqshxxl",
			desc = "活动：邀请水浒消消乐",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[220]=
		{
			id = 220,
			key = "xxl_xcfn",
			desc = "活动：消除烦恼（水果消消乐）",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[221]=
		{
			id = 221,
			key = "xxlsg_ljyj",
			desc = "活动：累计赢金（水果消消乐）",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[222]=
		{
			id = 222,
			key = "xxlsg_tzrw",
			desc = "活动：挑战任务（水果消消乐）",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[223]=
		{
			id = 223,
			key = "xxlsh_ljyj",
			desc = "活动：累计赢金（水浒消消乐）",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[224]=
		{
			id = 224,
			key = "xxlsh_tzrw",
			desc = "活动：挑战任务（水浒消消乐）",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[225]=
		{
			id = 225,
			key = "sys_sclb1",
			desc = "系统礼包：首充礼包",
			lua = "SYSSCLB1Manager",
			is_on_off = 1,
			enable = 1,
			state = 1,
		},
		[226]=
		{
			id = 226,
			key = "xxl_xrhb",
			desc = "系统消消乐：新人福卡",
			lua = "XXLXRHBManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[227]=
		{
			id = 227,
			key = "act_006_qflb1",
			desc = "全返礼包I",
			lua = "Act_006QFLB1Manager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[228]=
		{
			id = 228,
			key = "act_009_yk_gz",
			desc = "活动：贵族月卡",
			lua = "Act_009_YKGZManager",
			is_on_off = 1,
			enable = 1,
			state = 1,
		},
		[229]=
		{
			id = 229,
			key = "sys_pay_fast",
			desc = "系统：快捷支付",
			lua = "SysPayFastManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[230]=
		{
			id = 230,
			key = "by_act_caijin",
			desc = "街机彩金鱼",
			lua = "BYActCaijinManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[231]=
		{
			id = 231,
			key = "act_008_lgfl",
			desc = "连购返利",
			lua = "Act_008LGFLManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[232]=
		{
			id = 232,
			key = "act_008_mflb",
			desc = "免费礼包",
			lua = "Act_008_MFLBManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[233]=
		{
			id = 233,
			key = "sys_kf",
			desc = "客服-长期",
			lua = "SYSKFManager",
			is_on_off = 1,
			enable = 1,
			state = 1,
		},
		[234]=
		{
			id = 234,
			key = "act_009_xycd",
			desc = "幸运彩蛋",
			lua = "Act_009XYCDManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[235]=
		{
			id = 235,
			key = "act_010_wywb",
			desc = "五一挖宝",
			lua = "Act_010_WYWBManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[236]=
		{
			id = 236,
			key = "act_010_wbgj",
			desc = "挖宝工具",
			lua = "Act_010_WBGJManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[237]=
		{
			id = 237,
			key = "act_010_wysc",
			desc = "五一礼包",
			lua = "Act_010_WYSCManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[238]=
		{
			id = 238,
			key = "act_010_51flsyy",
			desc = "五一福利赛",
			lua = "ACT_010_51FLSYYManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[239]=
		{
			id = 239,
			key = "act_010_mqjth",
			desc = "母亲节特惠",
			lua = "Act_010_MQJTHManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[240]=
		{
			id = 240,
			key = "sys_011_yueka_new",
			desc = "新月卡",
			lua = "Sys_011_YuekaManager",
			is_on_off = 1,
			enable = 1,
			state = 1,
		},
		[241]=
		{
			id = 241,
			key = "sys_011_CplZh",
			desc = "Cpl转换",
			lua = "Sys_011_CplZhManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[242]=
		{
			id = 242,
			key = "act_011_xxlphb",
			desc = "消消乐排行榜",
			lua = "Act_011_XXLPHBManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[243]=
		{
			id = 243,
			key = "act_011_czfl",
			desc = "充值返利",
			lua = "Act_011CZFLManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[244]=
		{
			id = 244,
			key = "act_znq_fx",
			desc = "周年庆万元赛分享",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[245]=
		{
			id = 245,
			key = "sys_cfzx_btn_qys",
			desc = "财富中心千元赛提示",
			lua = "SysCFZXBtnQysManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[246]=
		{
			id = 246,
			key = "hallbtn_sgxxl",
			desc = "水果消消乐按钮",
			lua = "HallBtnSgxxlManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[247]=
		{
			id = 247,
			key = "normal_activity_common_old",
			desc = "活动公用废弃",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[248]=
		{
			id = 248,
			key = "act_012_lmlh",
			desc = "浪漫礼盒",
			lua = "Act_012_LMLHManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[249]=
		{
			id = 249,
			key = "act_012_bblb",
			desc = "表白礼包",
			lua = "Act_012_BBLBManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[250]=
		{
			id = 250,
			key = "act_012_byphb",
			desc = "真爱排行榜",
			lua = "Act_012_BYPHBManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[251]=
		{
			id = 251,
			key = "act_012_czqd",
			desc = "充值签到",
			lua = "Act_012_CZQDManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[252]=
		{
			id = 252,
			key = "act_013_lgfl",
			desc = "连购返利",
			lua = "Act_013LGFLManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[253]=
		{
			id = 253,
			key = "act_013_dlfl",
			desc = "登录福利",
			lua = "Act_013_DLFLManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[254]=
		{
			id = 254,
			key = "sys_open_install_binding",
			desc = "OpenInstall绑定关系",
			lua = "OpenInstallBindingManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[255]=
		{
			id = 255,
			key = "act_013_bsyy",
			desc = "比赛预约",
			lua = "ACT_013BSYYManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[256]=
		{
			id = 256,
			key = "act_013_mflb",
			desc = "免费福卡",
			lua = "Act_013_MFLBManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[257]=
		{
			id = 257,
			key = "sys_vip3_up",
			desc = "VIP2直通礼包 ",
			lua = "SYSVip3UpManager",
			is_on_off = 1,
			enable = 1,
			state = 1,
		},
		[258]=
		{
			id = 258,
			key = "sys_013_sylb",
			desc = "三元礼包",
			lua = "Sys_013_SYLBManager",
			is_on_off = 1,
			enable = 1,
			state = 1,
		},
		[259]=
		{
			id = 259,
			key = "sys_013_ffyd",
			desc = "付费引导",
			lua = "Sys_013_FFYDManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[260]=
		{
			id = 260,
			key = "sys_013_zdkplb",
			desc = "自动开炮礼包",
			lua = "Sys_013_ZDKPLBManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[261]=
		{
			id = 261,
			key = "act_014_xycd",
			desc = "幸运彩蛋",
			lua = "Act_014_XYCDManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[262]=
		{
			id = 262,
			key = "act_014_jhs",
			desc = "聚划算",
			lua = "Act_014_JHSManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[263]=
		{
			id = 263,
			key = "sys_014_ffyd",
			desc = "付费引导二期",
			lua = "Sys_014_FFYDManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[264]=
		{
			id = 264,
			key = "act_015_xxlbd",
			desc = "消消乐榜单",
			lua = "Act_015_XXLBDManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[265]=
		{
			id = 265,
			key = "act_015_yybjsj",
			desc = "赢一局就睡觉",
			lua = "Act_015_YYBJSJManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[266]=
		{
			id = 266,
			key = "act_ty_task",
			desc = "通用活动模板1",
			lua = "ActivityTaskManager",
			is_on_off = 1,
			enable = 1,
			state = 1,
		},
		[267]=
		{
			id = 267,
			key = "act_015_EXczfl",
			desc = "充值返利扩展",
			lua = "Act_015_EXCZFLManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[268]=
		{
			id = 268,
			key = "sys_016_vip1ztlb",
			desc = "VIP1直通礼包 ",
			lua = "Sys_016_VIP1ZTLBManager",
			is_on_off = 1,
			enable = 1,
			state = 1,
		},
		[269]=
		{
			id = 269,
			key = "act_016_xyxcwk",
			desc = "小游戏畅玩卡",
			lua = "Act_016_XYXCWKManager",
			is_on_off = 1,
			enable = 1,
			state = 1,
		},
		[270]=
		{
			id = 270,
			key = "act_016_cplxrqtl",
			desc = "CPL渠道新人七天乐",
			lua = "Act_016_CPLXRQTLManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[271]=
		{
			id = 271,
			key = "act_016_cjlb",
			desc = "抽奖礼包",
			lua = "Act_016_CJLBManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[272]=
		{
			id = 272,
			key = "act_016_lxdh",
			desc = "龙虾兑换",
			lua = "Act_016_LXDHManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[273]=
		{
			id = 273,
			key = "act_016_xlxphb",
			desc = "小龙虾排行榜",
			lua = "Act_016_XLXPHBManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[274]=
		{
			id = 274,
			key = "act_017_hyzh",
			desc = "好友找回",
			lua = "Act_017_HYZHManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[275]=
		{
			id = 275,
			key = "act_017_mdbxppsyy",
			desc = "美的冰箱品牌赛预约",
			lua = "ACT_017_MDBXPPSYYManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[276]=
		{
			id = 276,
			key = "act_017_Exxzhhl",
			desc = "香粽送豪礼(扩展)",
			lua = "Act_017_ExxzhhlManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[277]=
		{
			id = 277,
			key = "act_017_zzyphb",
			desc = "粽子鱼排行榜",
			lua = "Act_017_ZZYPHBManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[278]=
		{
			id = 278,
			key = "act_017_smsd",
			desc = "限时福利",
			lua = "Act_017_SMSDManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[279]=
		{
			id = 279,
			key = "bf_game",
			desc = "边锋合作",
			lua = "BFiconPrefabManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[280]=
		{
			id = 280,
			key = "sys_wqp_gzyl",
			desc = "玩棋牌的关注有礼",
			lua = "Sys_wqp_GZYLManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[281]=
		{
			id = 281,
			key = "act_018_hlqjd",
			desc = "欢乐敲金蛋",
			lua = "Act_018_HLQJDManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[282]=
		{
			id = 282,
			key = "sys_018_vip4ffyd",
			desc = "VIP4付费引导",
			lua = "Sys_018_VIP4FFYDManager",
			is_on_off = 1,
			enable = 1,
			state = 1,
		},
		[283]=
		{
			id = 283,
			key = "act_018_mfcdj",
			desc = "免费抽大奖",
			lua = "Act_018_MFCDJManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[284]=
		{
			id = 284,
			key = "sys_guide_3",
			desc = "匹配场免费赢红包",
			lua = "Sys_Guide_3Manager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[285]=
		{
			id = 285,
			key = "act_019_EXCczfl",
			desc = "充值返利",
			lua = "Act_019_EXCZFLManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[286]=
		{
			id = 286,
			key = "act_019_yybjsj",
			desc = "新版夜间活动",
			lua = "Act_019_YYBJSJManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[287]=
		{
			id = 287,
			key = "act_019_chb",
			desc = "拆红包",
			lua = "Act_019_CHBManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[288]=
		{
			id = 288,
			key = "act_020_jbbx",
			desc = "鲸币宝箱",
			lua = "Act_020_JBBXManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[289]=
		{
			id = 289,
			key = "act_020_xgdh",
			desc = "西瓜兑换",
			lua = "Act_020_XGDHManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[290]=
		{
			id = 290,
			key = "act_020_hbfx",
			desc = "邀请领48元",
			lua = "Act_020HBFXManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[291]=
		{
			id = 291,
			key = "act_020_xgsjb",
			desc = "西瓜收集榜",
			lua = "Act_020_XGSJBManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[292]=
		{
			id = 292,
			key = "act_021_sxlb",
			desc = "盛夏礼包",
			lua = "Act_021_SXLBManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[293]=
		{
			id = 293,
			key = "act_021_sxshl",
			desc = "盛夏送好礼",
			lua = "Act_021_SXSHLManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[294]=
		{
			id = 294,
			key = "act_021_lgfl",
			desc = "连购返利",
			lua = "Act_021_LGFLManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[295]=
		{
			id = 295,
			key = "act_022_jfphb",
			desc = "积分排行榜",
			lua = "Act_022_JFPHBManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[296]=
		{
			id = 296,
			key = "act_022_mdktppsyy",
			desc = "美的空调品牌赛预约",
			lua = "ACT_022_MDKTPPSYYManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[297]=
		{
			id = 297,
			key = "act_022_wyzjf",
			desc = "我要赚积分",
			lua = "Act_022_WYZJFManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[298]=
		{
			id = 298,
			key = "sys_023_exxsyd",
			desc = "扩展新手引导",
			lua = "Sys_023_ExXSYDManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[299]=
		{
			id = 299,
			key = "act_023_lqsfl",
			desc = "立秋送福利",
			lua = "Act_023_LQSFLManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[300]=
		{
			id = 300,
			key = "act_023_ddzfbk",
			desc = "斗地主翻倍卡",
			lua = "Act_023_DDZFBKManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[301]=
		{
			id = 301,
			key = "act_024_bzdh",
			desc = "宝藏兑换",
			lua = "Act_024_BZDHManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[302]=
		{
			id = 302,
			key = "act_024_switch",
			desc = "大切换页面",
			lua = "Act_024_SWITCHManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[303]=
		{
			id = 303,
			key = "act_024_bzlb",
			desc = "宝藏礼包",
			lua = "Act_024_BZLBManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[304]=
		{
			id = 304,
			key = "act_024_czzb",
			desc = "充值争霸",
			lua = "Act_024_CZZBManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[305]=
		{
			id = 305,
			key = "act_025_exsjshl",
			desc = "收集送福利（扩展）",
			lua = "Act_025_ExSJSHManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[306]=
		{
			id = 306,
			key = "act_025_xxlzb",
			desc = "消消乐争霸",
			lua = "Act_025_XXLZBManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[307]=
		{
			id = 307,
			key = "act_025_zblb",
			desc = "争霸礼包",
			lua = "Act_025_ZBLBManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[308]=
		{
			id = 308,
			key = "act_znq_bwhlhk",
			desc = "周年庆福利",
			lua = "BWHLHKManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[309]=
		{
			id = 309,
			key = "sys_change_head_and_name",
			desc = "头像昵称修改",
			lua = "SYSChangeHeadAndNameManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[310]=
		{
			id = 310,
			key = "sys_025_openbox",
			desc = "周年庆开箱子",
			lua = "Sys_025_OpenBoxManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[311]=
		{
			id = 311,
			key = "act_026_qxlb",
			desc = "七夕礼包",
			lua = "Act_026_QXLBManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[312]=
		{
			id = 312,
			key = "act_026_sjyys",
			desc = "华为手机预约赛",
			lua = "Act_026_SJYYSManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[313]=
		{
			id = 313,
			key = "act_026_zabd",
			desc = "真爱榜单",
			lua = "Act_026_ZABDManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[314]=
		{
			id = 314,
			key = "act_026_zqhhl",
			desc = "真情换豪礼",
			lua = "Act_026_ZQHHLManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[315]=
		{
			id = 315,
			key = "sys_fcm",
			desc = "防沉迷",
			lua = "SYSFCMManager",
			is_on_off = 1,
			enable = 1,
			state = 1,
		},
		[316]=
		{
			id = 316,
			key = "act_027_znqlb",
			desc = "周年庆礼包",
			lua = "Act_027_ZNQLBManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[317]=
		{
			id = 317,
			key = "act_027_znfk",
			desc = "周年反馈",
			lua = "Act_027_ZNFKManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[318]=
		{
			id = 318,
			key = "act_027_znqd",
			desc = "周年庆典",
			lua = "Act_027_ZNQDManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[319]=
		{
			id = 319,
			key = "act_027_znqjz",
			desc = "周年庆集字",
			lua = "Act_027_ZNQJZManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[320]=
		{
			id = 320,
			key = "act_027_znqg",
			desc = "周年庆抢购",
			lua = "Act_027_ZNQGManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[321]=
		{
			id = 321,
			key = "act_027_znqcdj",
			desc = "周年庆抽大奖",
			lua = "Act_027_ZNQCDJManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[322]=
		{
			id = 322,
			key = "act_027_znqwyjnb",
			desc = "周年庆我要纪念币",
			lua = "Act_027_ZNQWYJNBManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[323]=
		{
			id = 323,
			key = "act_027_znqjnk",
			desc = "周年庆纪念卡",
			lua = "Act_027_ZNQJNKManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[324]=
		{
			id = 324,
			key = "act_028_wysyy",
			desc = "周年庆万元赛预约",
			lua = "Act_028_WYSYYManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[325]=
		{
			id = 325,
			key = "act_028_zncdj",
			desc = "周年庆抽好礼",
			lua = "Act_028_ZNCDJManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[326]=
		{
			id = 326,
			key = "act_028_jfdrb",
			desc = "周年庆积分达人榜",
			lua = "Act_028_JFDRBManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[327]=
		{
			id = 327,
			key = "act_028_znqwyjnb",
			desc = "周年庆我要纪念币",
			lua = "Act_028_ZNQWYJNBManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[328]=
		{
			id = 328,
			key = "act_028_djjt",
			desc = "周年庆对局集图",
			lua = "Act_028_DJJTManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[329]=
		{
			id = 329,
			key = "by3d_top_qh",
			desc = "捕鱼游戏上方区域",
			lua = "BY3DTopQHManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[330]=
		{
			id = 330,
			key = "by3d_kpshb",
			desc = "开炮送红包",
			lua = "BY3DKPSHBManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[331]=
		{
			id = 331,
			key = "by_task",
			desc = "捕鱼任务系统",
			lua = "BYTaskManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[332]=
		{
			id = 332,
			key = "by3d_ad_mfcj",
			desc = "看广告免费抽奖",
			lua = "BY3DADMFCJManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[333]=
		{
			id = 333,
			key = "act_028_wqp_mfcfk",
			desc = "玩棋牌_对局福卡",
			lua = "Act_028_WQP_MFCFKManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[334]=
		{
			id = 334,
			key = "cpl_ljyjcfk",
			desc = "渠道平台_累计赢金抽福卡",
			lua = "CPL_LJYJCFKManager",
			is_on_off = 1,
			enable = 1,
			state = 1,
		},
		[335]=
		{
			id = 335,
			key = "act_028_djhs",
			desc = "玩棋牌_对局获胜看广告",
			lua = "Act_028_DJHSManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[336]=
		{
			id = 336,
			key = "act_028_djms",
			desc = "玩棋牌_对局免输看广告",
			lua = "Act_028_DJMSManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[337]=
		{
			id = 337,
			key = "act_029_znqwyjnb",
			desc = "周年庆我要纪念币",
			lua = "Act_029_ZNQWYJNBManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[338]=
		{
			id = 338,
			key = "act_029_djgf",
			desc = "周年庆对局瓜分",
			lua = "Act_029_DJGFManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[339]=
		{
			id = 339,
			key = "act_029_hlkbx",
			desc = "周年庆欢乐开宝箱",
			lua = "Act_029_HLKBXManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[340]=
		{
			id = 340,
			key = "act_029_znqcj",
			desc = "周年庆抽奖",
			lua = "Act_029_ZNQCJManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[341]=
		{
			id = 341,
			key = "act_030_cjfblb",
			desc = "彩金翻倍礼包",
			lua = "Act_030_CJFBLBManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[342]=
		{
			id = 342,
			key = "act_030_czcj",
			desc = "充值抽奖",
			lua = "Act030CZCJManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[343]=
		{
			id = 343,
			key = "act_031_gqkl",
			desc = "国庆快乐（特效控制脚本）",
			lua = "Act_031_GQKLManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[344]=
		{
			id = 344,
			key = "act_031_wxhhl",
			desc = "五星换好礼",
			lua = "Act_031_WXHHLManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[345]=
		{
			id = 345,
			key = "act_031_wxsjb",
			desc = "五星收集榜",
			lua = "Act_031_WXSJBManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[346]=
		{
			id = 346,
			key = "act_030_gqfl",
			desc = "国庆福利",
			lua = "Act_030_GQFLManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[347]=
		{
			id = 347,
			key = "act_030_gqfd",
			desc = "国庆福袋",
			lua = "Act_030_GQFDManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[348]=
		{
			id = 348,
			key = "act_032_switch",
			desc = "大切换页面（游戏内按钮）",
			lua = "Act_032_SWITCHManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[349]=
		{
			id = 349,
			key = "act_032_xxldh",
			desc = "消出好礼",
			lua = "Act_032_XXLDHManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[350]=
		{
			id = 350,
			key = "act_032_xxlzb",
			desc = "消消乐排行榜",
			lua = "Act_032_XXLZBManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[351]=
		{
			id = 351,
			key = "act_032_jflb",
			desc = "积分礼包",
			lua = "Act_032_JFLBManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[352]=
		{
			id = 352,
			key = "act_033_bzdh",
			desc = "宝藏兑换",
			lua = "Act_033_BZDHManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[353]=
		{
			id = 353,
			key = "act_033_switch",
			desc = "大切换界面",
			lua = "Act_033_SWITCHManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[354]=
		{
			id = 354,
			key = "act_033_bzlb",
			desc = "宝藏礼包",
			lua = "Act_033_BZLBManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[355]=
		{
			id = 355,
			key = "act_033_bzzb",
			desc = "宝藏争霸",
			lua = "Act_033_BZZBManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[356]=
		{
			id = 356,
			key = "act_033_fkzjd",
			desc = "疯狂砸金蛋",
			lua = "FKZJDManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[357]=
		{
			id = 357,
			key = "act_034_jjcy_xxlbd",
			desc = "消消乐排行榜",
			lua = "Act_034_JjcyXxlbdManger",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[358]=
		{
			id = 358,
			key = "act_034_lpzj",
			desc = "礼品收集",
			lua = "Act_034_LPZJManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[359]=
		{
			id = 359,
			key = "act_034_cyhhl",
			desc = "重阳送豪礼",
			lua = "Act_034_CYHHLManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[360]=
		{
			id = 360,
			key = "act_035_wslb",
			desc = "万圣礼包",
			lua = "Act_035_WSLBManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[361]=
		{
			id = 361,
			key = "act_035_wskh_bsyy",
			desc = "比赛预约",
			lua = "Act_035_WSKHBSYYManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[362]=
		{
			id = 362,
			key = "act_035_jfphb",
			desc = "积分排行榜",
			lua = "Act_035_JFPHBManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[363]=
		{
			id = 363,
			key = "act_035_tghhl",
			desc = "糖果换好礼",
			lua = "Act_035_TGHHLManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[364]=
		{
			id = 364,
			key = "wqp_cpl_yh",
			desc = "玩棋牌CPL优化",
			lua = "WQPCPLYHManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[365]=
		{
			id = 365,
			key = "act_036_bxlb",
			desc = "宝箱礼包",
			lua = "Act_036_BXLBManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[366]=
		{
			id = 366,
			key = "act_036_bzth",
			desc = "备战特惠",
			lua = "Act_036_BZTHManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[367]=
		{
			id = 367,
			key = "act_036_yyssy",
			desc = "预约双十一",
			lua = "Act_036_YYSSYManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[368]=
		{
			id = 368,
			key = "wuziqi_sys_cssl",
			desc = "财神送礼",
			lua = "WUZIQISYSCSSLManager",
			is_on_off = 1,
			enable = 1,
			state = 1,
		},
		[369]=
		{
			id = 369,
			key = "wuziqi_guide",
			desc = "高手五子棋引导",
			lua = "WZQGuideManager",
			is_on_off = 0,
			enable = 1,
			state = 1,
		},
		[370]=
		{
			id = 370,
			key = "act_044_qflb",
			desc = "全返礼包",
			lua = "Act_044_QFLBManager",
			is_on_off = 1,
			enable = 1,
			state = 1,
		},
		[371]=
		{
			id = 371,
			key = "act_044_xnfl",
			desc = "新年福利",
			lua = "Act_044_XNFLManager",
			is_on_off = 1,
			enable = 1,
			state = 1,
		},
		[372]=
		{
			id = 372,
			key = "sys_manager_lwzb",
			desc = "龙王争霸管理器",
			lua = "LWZBManager",
			is_on_off = 1,
			enable = 1,
			state = 1,
		},
		[373]=
		{
			id = 373,
			key = "act_045_xxlbd",
			desc = "消消乐榜单",
			lua = "Act_045_XXLBDManger",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[374]=
		{
			id = 374,
			key = "act_045_cqg",
			desc = "五子棋存钱罐",
			lua = "Act_045_CQGManager",
			is_on_off = 1,
			enable = 1,
			state = 1,
		},
		[375]=
		{
			id = 375,
			key = "act_045_bslb",
			desc = "倍数礼包",
			lua = "Act_045_BSLBManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[376]=
		{
			id = 376,
			key = "act_046_bybk",
			desc = "捕鱼宝库",
			lua = "Act_046_BYBKManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[377]=
		{
			id = 377,
			key = "act_046_khtj",
			desc = "狂欢图鉴",
			lua = "Act_046_KHTJManager",
			is_on_off = 0,
			enable = 0,
			state = 0,
		},
		[378]=
		{
			id = 378,
			key = "act_ty_gifts",
			desc = "狂欢礼包",
			lua = "Act_Ty_GiftsManager",
			is_on_off = 1,
			enable = 1,
			state = 1,
		},
		[379]=
		{
			id = 379,
			key = "act_ty_rank",
			desc = "庆典排行榜",
			lua = "Act_Ty_RankManager",
			is_on_off = 1,
			enable = 1,
			state = 1,
		},
		[380]=
		{
			id = 380,
			key = "act_ty_collect_words",
			desc = "四季礼包",
			lua = "Act_Ty_Collect_WordsManager",
			is_on_off = 1,
			enable = 1,
			state = 1,
		},
		[381]=
		{
			id = 381,
			key = "act_ty_exchange",
			desc = "兑换通用模板",
			lua = "Act_Ty_ExchangeManager",
			is_on_off = 1,
			enable = 1,
			state = 1,
		},
		[382]=
		{
			id = 382,
			key = "sys_act_base_style/sys_act_base_003_weekly",
			desc = "辞旧岁",
			is_on_off = 1,
			enable = 1,
			state = 1,
		},
		[383]=
		{
			id = 383,
			key = "sys_act_base_style/sys_act_base_001_normal",
			desc = "常驻活动",
			is_on_off = 1,
			enable = 1,
			state = 1,
		},
		[384]=
		{
			id = 384,
			key = "act_047_wfshl",
			desc = "五福送好礼",
			lua = "Act_047_WFSHLManager",
			is_on_off = 1,
			enable = 1,
			state = 1,
		},
		[385]=
		{
			id = 385,
			key = "act_047_wqpdl",
			desc = "高手五子棋导流",
			lua = "Act_047_WQPDLManager",
			is_on_off = 1,
			enable = 1,
			state = 1,
		},
	},
}