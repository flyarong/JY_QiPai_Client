--[[
NoticeType: 提示类型
  1.每次登陆
  2.每天第一次登陆
  3.只提示一次

Condition: 提示条件
  MaxCnt: 最大次数. -1无限制
  StartStamp: 起始时间
  EndStamp: 截止时间
  IntervalStamp: 间隔时间(秒)
]]--

MaxNoticeType = 3
NoticeEverytime = 1
NoticeEveryday = 2
NoticeOnce = 3

NoticeConfig = {
	NoticeType = 1,
	Condition = {
		MaxCnt = -1,
		StartStamp = 0,
		EndStamp = 0,
		IntervalStamp = 0
	}
}
LoginNoticeText=[[　　　　　　　　　鲸鱼斗地主 | 不删档内测公告

亲爱的玩家朋友们：
       【鲸鱼斗地主】版本已升级，开启第2阶段不删档内测，安卓和IOS版本手机皆可参与游戏，新版本福利high到爆，登录游戏可领：
        福利1：福卡任务人人可领92.6福卡！
        福利2：金猪礼包福利，每天玩游戏领5元微信福卡！
　　　　　　　　　　　　　　　　　　　　《鲸鱼斗地主》运营团队
　　　　　　　　　　　　　　　　　　　　　　2019年4月15日]]
