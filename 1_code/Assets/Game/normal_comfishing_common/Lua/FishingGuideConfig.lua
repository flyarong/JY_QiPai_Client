-- 创建时间:2018-07-24

-- 顺序引导(暂时不支持非顺序引导)
-- isSkip 是否可以点击跳过
FishingGuideConfig = {
	[1] = {stepList={1}, next=2, isSkip=0},
	[2] = {stepList={2}, next=3, isSkip=0},
}


--[[
type= char对话 button按钮点击 GuideStyle1 选择一块区域(功能描述引导)
name=内容
auto=是否连续执行
isHideBG=是否隐藏黑色背景
descPos=描述的位置
headPos=手指的偏移值
uiName=步骤所在UI的名字
--]]
GuideStepConfig = {
	[1] = {
		type="button",
		name="@guiderect1",
		isHideBG=true, 
		auto=false, 
		isSave=true,
		desc="",
		descPos={x=40, y=-154, z=0},
		headPos={x=0, y=0},
		uiName="guide_step1_panel",
		szPos={x=32, y=-383, z=0},
		-- isHideSZ = true,
	},
	[2] = {
		type="button",
		name="@guiderect2",
		isHideBG=true, 
		auto=false, 
		isSave=true,
		desc="",
		descPos={x=40, y=-154, z=0},
		headPos={x=0, y=0},
		uiName="guide_step2_panel",
		szPos={x=32, y=-383, z=0},
	},
}