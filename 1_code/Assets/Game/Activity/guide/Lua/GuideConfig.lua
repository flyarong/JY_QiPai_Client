-- 创建时间:2018-07-24

-- 顺序引导(暂时不支持非顺序引导)
-- isSkip 是否可以点击跳过
GuideConfig = {
	-- [1] = { stepList = { 1 }, next = 2, isSkip = 0 },
	-- [2] = { stepList = { 2, 11 }, next = 3, isSkip = 0 },
	-- [3] = { stepList = { 16, 13, 14, 15 }, next = 4, isSkip = 0 },
	-- [4] = { stepList = { 17, 18, 19 }, next = -1, isSkip = 0 },

	[1] = { stepList = { { step = { 1 }, cfPos = "guide_select" } }, next = 2, isSkip = 0 },
	[2] = { stepList = { { step = { 2, 11 }, cfPos = "hall" } }, next = 3, isSkip = 0 },
	[3] = { stepList = { { step = { 20, 13, 14, 15 }, cfPos = "hall" }, { step = { 16, 13, 14, 15,22,23 }, cfPos = "free_js" } } , next = 4, isSkip = 0 },
	[4] = { stepList = { { step = { 10 }, cfPos = "hall" }, {step = { 10 }, cfPos = "free_js" } }, next = -1, isSkip = 0 },

	--[3] = {stepList={3,5,12,13,}, next=4, isSkip=0},
	--[4] = {stepList={12,13,}, next=5, isSkip=0},
	--[4] = {stepList={14,15,10}, next=-1, isSkip=0}
}

--[[
1、选择游戏
2、大厅匹配场按钮，匹配场第一个场次
3、结算界面兑换按钮，确认兑换按钮
4、匹配场大厅返回按钮
5、大厅是兑换商城按钮

1、选择游戏
2、大厅匹配场按钮，匹配场第一个场次
3、结算界面兑换按钮，确认兑换按钮
2021.10.12以前
4、大厅的福卡任务按钮（XRHB1EnterPrefab）,匹配场对局任务的领取按钮（xrhb_btn_21126），获得界面的确认按钮（@confirm_btn），大厅是兑换商城按钮
2021.10.12之后
4、大厅的新人好礼按钮（Act_068_XRHLEnter）,匹配场对局任务的领取按钮（xrhl_btn_100035），获得界面的确认按钮（@confirm_btn），大厅是兑换商城按钮
--]]

--[[
type= char对话 button按钮点击 GuideStyle1选择一块区域(功能描述引导)
name=内容
auto=是否连续执行，点击可直接执行下一步，不检测
isHideBG=是否隐藏黑色背景
descPos=描述的位置
headPos=手指的偏移值
uiName=步骤所在UI的名字
topsizeDelta=区域大小
--]]


--[[ Style
button:将按钮显示在最高层，点击按钮执行按钮点击事件和进入下一步
GuideStyle1:高亮组件可不是按钮，点击进入下一步（即使有按钮也不触发按钮的点击）
GuideStyle2:不改变层级，高亮区域由配置决定
unforce:非强制引导，无高亮和非高亮之分，满足进入条件和在当前大步骤时可进
--]]


GuideStepConfig = {
	[1] = {
		id = 1,
		type="button",
		name="@guiderect",
		isHideBG=true, 
		auto=false, 
		isSave=true,
		desc="",
		descPos={x=40, y=-154, z=0},
		headPos={x=0, y=0},
		uiName="guide_select",
		isHideSZ = true,
	},
	[2] = {
		id = 2,
		type="button", 
		name="@PE", 
		isHideBG=false,
		auto=true, 
		isSave=false,
		desc="点击这里快速游戏",
		descPos={x=-5, y=264, z=0},
		descRot={x=180, y=0, z=0},
		headPos={x=0, y=0},
		uiName="hall",
		szPos={x=-236, y=-160, z=0},
		csPos={x=-963, y=-306, z=0},
		bsdsmName = "click_xsyd_pp",
	},
	[3] = {
		id = 3,
		type="button", 
		name="BackButton", 
		isHideBG=false,
		auto=false, 
		isSave=false,
		desc="返回匹配场大厅",
		descPos={x=100, y=-126, z=0},
		szPos={x=-152, y=-286, z=0},
		headPos={x=0, y=0},
		uiName="free_js",
	},
	[4] = {
		id = 4,
		type="GuideStyle1", 
		name="ScrollViewLeft",
		isHideBG=false,
		auto=false, 
		isSave=false,
		desc="在这里，更丰富的游戏由您来\n体验",
		descPos={x=0, y=486, z=0},
		descRot={x=180, y=0, z=0},
		headPos={x=0, y=0},
		uiName="free_hall",
		szPos={x=-134, y=-345, z=0},
		csPos={x=549, y=-129, z=0},
		isHideSZ = true,
	},
	[5] = {
		id = 5,
		type="button", 
		name="BackButton",
		isHideBG=false,
		auto=false, 
		isSave=false,
		desc="点这里，带你去领福卡！",
		descPos={x=190, y=-4, z=0},
		descRot={x=180, y=0, z=0},
		headPos={x=0, y=0},
		uiName="free_hall",
		szPos={x=-184, y=-277, z=0},
		csPos={x=536, y=-666, z=0},
	},
	[6] = {
		id = 6,
		type="button", 
		name="ExchangeNode",
		isHideBG=false,
		auto=false, 
		isSave=true,
		desc="你真是太幸运了！胜利后有概率可兑换福卡\n点击这里兑换",
		descPos={x=79, y=100, z=0},
		descRot={x=180, y=0, z=0},
		headPos={x=0, y=0},
		uiName="free_js",
		szPos={x=-37, y=-313, z=0},
	},
	[7] = {
		id = 7,
		type="button", 
		name="confirm_btn",
		isHideBG=false,
		auto=true, 
		isSave=true,
		desc="点击这里将赢得的鲸币兑换成福卡",
		descPos={x=54, y=113, z=0},
		descRot={x=180, y=0, z=0},
		headPos={x=0, y=0},
		uiName="free_js",
		szPos={x=-100, y=-290, z=0},
	},
	[8] = {
		id = 8,
		type="GuideStyle2", 
		name="@AwardNode",
		isHideBG=false,
		auto=false, 
		isSave=true,
		desc="福卡可在商城兑换各种商品，大厅的右下角兑奖按钮\n可进入到兑换商城，点击继续",
		descPos={x=-63, y=198, z=0},
		descRot={x=180, y=0, z=0},
		headPos={x=0, y=0},
		uiName="get_award",
		szPos={x=-88, y=-356, z=0},
		topsizeDelta = {x=300, y=300},
	},
	[10] = {
		id = 10,
		type="button", 
		name="@duihuan_btn",
		isHideBG=false,
		auto=true, 
		isSave=true,
		desc="点击这里，兑换商品",
		descPos={x=-370, y=140, z=0},
		descRot={x=180, y=0, z=0},
		headPos={x=0, y=0},
		uiName="hall",
		szPos={x=-490, y=-248, z=0},
	},
	[11] = {
		id = 11,
		type="button", 
		name="free_hall_game_1",
		isHideBG=false,
		auto=false, 
		isSave=true,
		desc="",
		descPos={x=56, y=-126, z=0},
		headPos={x=0, y=0},
		uiName="free_hall",
		szPos={x=-92, y=-266, z=0},
		bsdsmName = "click_xsyd_free_hall_game",
	},

	[12] = {
		id = 12,
		type="button", 
		name="Act_068_XRHLEnter",
		isHideBG=false,
		auto=false, 
		isSave=false,
		desc="",
		descPos={x=56, y=-126, z=0},
		headPos={x=0, y=0},
		uiName="hall",
		szPos={x=-204, y=-266, z=0},
	},
	[13] = {
		id = 13,
		type="button", 
		name="xrhl_btn_100035",
		isHideBG=false,
		auto=false, 
		isSave=false,
		desc="",
		descPos={x=56, y=-126, z=0},
		headPos={x=0, y=0},
		uiName="xrhl_panel",
		szPos={x=-92, y=-266, z=0},
		bsdsmName = "click_xsyd_fkrw_get_award",
	},
	[14] = {
		id = 14,
		type="button", 
		name="@confirm_btn",
		isHideBG=false,
		auto=false,
		isSave = true,
		desc="",
		descPos={x=56, y=-126, z=0},
		headPos={x=0, y=0},
		uiName="get_award",
		szPos={x=-92, y=-266, z=0},
	},
	[15] = {
		id = 15,
		type="button", 
		name="xrhl_btn_back",
		isHideBG=false,
		auto= true,
		isSave=false,
		desc="",
		descPos={x=56, y=-126, z=0},
		headPos={x=0, y=0},
		uiName="get_award",
		szPos={x=-206, y=-300, z=0},
		
	},
	[16] = {
		id = 16,
		type="button", 
		name="Act_068_XRHLEnter_1",
		isHideBG = false,
		auto = true,
		isSave = false,
		uiName="free_js",
		szPos={x=-221, y=-284, z=0},
		headPos={x=0, y=0},
		bsdsmName = "click_xsyd_fkrw_enter",
	},
	[17] = {
		id = 17,
		type="button", 
		name="Act_042_XSHBEnterPrefab",
		isHideBG = false,
		auto = true,
		isSave= false,
		desc="",
		uiName="free_js",
		szPos={x=-92, y=-266, z=0},
		headPos={x=0, y=0},
		bsdsmName = "click_xsyd_xshb_enter",
	},
	[18] = {
		id = 18,
		type="button", 
		name="xshb_21578_unlock_btn",
		isHideBG = false,
		auto = false,
		isSave= false,
		desc="",
		uiName="xshb_panel",
		szPos={x=-92, y=-266, z=0},
		headPos={x=0, y=0},
		bsdsmName = "click_xsyd_xshb_unlock",
	},
	[19] = {
		id = 19,
		type="unforce", 
		name="xshb_21578_get_btn",
		isHideBG = false,
		auto = false,
		isSave=false,
		desc="",
		uiName="xshb_panel",
		szPos={x=-92, y=-266, z=0},
		--headPos={x=0, y=0},
		bsdsmName = "click_xsyd_xshb_get_award",
	},
	[20] = {
		id = 20,
		type="button", 
		name="Act_068_XRHLEnter",
		isHideBG = false,
		auto = false,
		isSave=true,
		desc="",
		uiName="hall",
		szPos={x=-212, y=-312, z=0},
		headPos={x=0, y=0},
		bsdsmName = "click_xsyd_fkrw_enter",
	},
	[21] = {
		id = 21,
		type="button", 
		name="Act_042_XSHBEnterPrefab",
		isHideBG = false,
		auto = true,
		isSave= false,
		desc="",
		uiName="hall",
		szPos={x=-212, y=-312, z=0},
		headPos={x=0, y=0},
		bsdsmName = "click_xsyd_xshb_enter",
	},
	[22] = {
		id = 22,
		type="button", 
		name="BackButton", 
		isHideBG=false,
		auto=false, 
		isSave=false,
		desc="返回匹配场大厅",
		descPos={x=100, y=-126, z=0},
		szPos={x=-152, y=-286, z=0},
		headPos={x=0, y=0},
		uiName="xrhl_panel_exit",
	},
	[23] = {
		id = 23,
		type="button", 
		name="BackButton", 
		isHideBG=false,
		auto=false, 
		isSave=false,
		desc="返回游戏大厅",
		descPos={x=100, y=-126, z=0},
		szPos={x=-152, y=-286, z=0},
		headPos={x=0, y=0},
		uiName="free_js_exit",
	},
}