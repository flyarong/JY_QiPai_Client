return {
	info=
	{
		---------------------
		-- 鲸鱼斗地主(彩云麻将)
		---------------------
		normal=
		{
			platform = "normal",
			url = "http://cdnjydown.jyhd919.cn/jydown/Version2020/Install/V2/Android/jyddz.apk",
			ios_url="itms-services://?action=download-manifest&url=https://cdndownload.jyhd919.cn/install/ios/qiye/cymj/normal_normal.plist",
		},
		pceggs=
		{
			platform = "normal",
			url = "http://cdnjydown.jyhd919.cn/jydown/Version2020/Install/V2/Android/jyddz_pceggs.apk",
			ios_url="itms-services://?action=download-manifest&url=https://cdndownload.jyhd919.cn/install/ios/qiye/cymj/normal_pceggs.plist",
		},
		xianwan=
		{
			platform = "normal",
			url = "http://cdnjydown.jyhd919.cn/jydown/Version2020/Install/V2/Android/jyddz_xianwan.apk",
			ios_url="itms-services://?action=download-manifest&url=https://cdndownload.jyhd919.cn/install/ios/qiye/cymj/normal_xianwan.plist",
		},
		aibianxian=
		{
			platform = "normal",
			ios_url="itms-services://?action=download-manifest&url=https://cdndownload.jyhd919.cn/install/ios/qiye/cymj/normal_aibianxian.plist",
		},
		duoliang=
		{
			platform = "normal",
			url = "http://cdnjydown.jyhd919.cn/jydown/Version2020/Install/V2/Android/jyddz_duoliang.apk",
		},

		---------------------
		-- 玩棋牌(玩棋牌斗地主)
		---------------------
		wqp=
		{
			platform = "wqp",
			url = "http://cdnjydown.jyhd919.cn/jydown/Version2020/Install/V2/Android/wqpddz.apk",
			ios_url="itms-services://?action=download-manifest&url=https://cdndownload.jyhd919.cn/install/ios/qiye/wqpddz/wqp_wqp.plist",
		},
		wqp_pceggs=
		{
			platform = "wqp",
			url = "http://cdnjydown.jyhd919.cn/jydown/Version2020/Install/V2/Android/wqpddz_pceggs.apk",
			--ios_url="itms-services://?action=download-manifest&url=https://cdndownload.jyhd919.cn/install/ios/qiye/wqpddz/wqp_wqp_pceggs.plist",
			ios_url="itms-services://?action=download-manifest&url=https://cdndownload.jyhd919.cn/install/ios/qiye/wqpddz/wqp_wqp.plist",
		},
		wqp_xianwan=
		{
			platform = "wqp",
			url = "http://cdnjydown.jyhd919.cn/jydown/Version2020/Install/V2/Android/wqpddz_xianwan.apk",
			ios_url="itms-services://?action=download-manifest&url=https://cdndownload.jyhd919.cn/install/ios/qiye/wqpddz/wqp_wqp_xianwan.plist",
		},
		wqp_aibianxian = 
		{
			platform = "wqp",
			ios_url="itms-services://?action=download-manifest&url=https://download.jyhd919.cn/install/ios/qiye/wqpddz/wqp_wqp_aibianxian.plist",
		},
		wqp_zhuanke = 
		{
			platform = "wqp",
			url = "http://cdnjydown.jyhd919.cn/jydown/Version2020/Install/V2/Android/wqpddz_zhuanke.apk",
			ios_url="itms-services://?action=download-manifest&url=https://download.jyhd919.cn/install/ios/qiye/wqpddz/wqp_wqp_zhuanke.plist",
		},

		---------------------
		-- 五子棋
		---------------------
		wuziqi=
		{
			platform = "wuziqi",
			url = "http://cdnjydown.jyhd919.cn/jydown/Version2020/Install/V2/Android/wuziqi.apk",
		},
		wuziqi_pceggs=
		{
			platform = "wuziqi",
			url = "http://cdnjydown.jyhd919.cn/jydown/Version2020/Install/V2/Android/wuziqi_pceggs.apk",
		},
		wuziqi_juxiang=
		{
			platform = "wuziqi",
			url = "http://cdnjydown.jyhd919.cn/jydown/Version2020/Install/V2/Android/wuziqi_juxiang.apk",
		},
		wuziqi_xianwan=
		{
			platform = "wuziqi",
			url = "http://cdnjydown.jyhd919.cn/jydown/Version2020/Install/V2/Android/wuziqi_xianwan.apk",
		},
		wuziqi_zhuankebao=
		{
			platform = "wuziqi",
			url = "http://cdnjydown.jyhd919.cn/jydown/Version2020/Install/V2/Android/wuziqi_zhuankebao.apk",
		},
	},

	---------------------
	-- 默认配置，如果渠道找不到就按平台的官方url下载
	---------------------
	platform_info={
		normal={
			url = "http://cdnjydown.jyhd919.cn/jydown/Version2020/Install/V2/Android/jyddz.apk",
			ios_url="itms-services://?action=download-manifest&url=https://cdndownload.jyhd919.cn/install/ios/qiye/cymj/normal_normal.plist",
		},
		wqp={
			url = "http://cdnjydown.jyhd919.cn/jydown/Version2020/Install/V2/Android/wqpddz.apk",
			ios_url="itms-services://?action=download-manifest&url=https://cdndownload.jyhd919.cn/install/ios/qiye/wqpddz/wqp_wqp.plist",
		},
		wuziqi={
			--wuziqi.apk还没有对外发布，所以选一个渠道包
			url = "http://cdnjydown.jyhd919.cn/jydown/Version2020/Install/V2/Android/wuziqi_pceggs.apk",
			--没有IOS选normal
			ios_url="itms-services://?action=download-manifest&url=https://cdndownload.jyhd919.cn/install/ios/qiye/cymj/normal_normal.plist",
		},
	},

	-------------------
	-- 落地页
	-------------------
	landing_page={
		normal="http://cwww.jyhd919.cn/webpages/commonDownload.html?platform=normal&market_channel=normal&pageType=normal&category=1",
		wqp="http://cwww.jyhd919.cn/webpages/commonDownload.html?platform=wqp&market_channel=wqp&pageType=wanqipai&category=1",
	}
}