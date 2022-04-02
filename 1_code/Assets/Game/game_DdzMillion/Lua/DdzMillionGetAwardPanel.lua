--ganshuangfeng 比赛场等待界面
--2018-04-17
local basefunc = require "Game.Common.basefunc"

DdzMillionGetAwardPanel = basefunc.class()

DdzMillionGetAwardPanel.name = "DdzMillionGetAwardPanel"
local lister
local have_Jh
local instance
function DdzMillionGetAwardPanel.Create()
	instance=DdzMillionGetAwardPanel.New()
	return createPanel(instance,DdzMillionGetAwardPanel.name)
end
function DdzMillionGetAwardPanel.Bind()
	local _in=instance
	instance=nil
	return _in
end

function DdzMillionGetAwardPanel:Awake()
	LuaHelper.GeneratingVar(self.transform, self)
	self:MyInit()
end

function DdzMillionGetAwardPanel:Start()
	self:MyRefresh()
end


function DdzMillionGetAwardPanel:OnDestroy()
	lister = nil
end

--[[初始化功能，创建好panel后在Award中调用，只做一次]]
function DdzMillionGetAwardPanel:MyInit()

end

--[[刷新功能，供Logic和model调用，重复性操作]]
function DdzMillionGetAwardPanel:MyRefresh()
	if DdzMillionModel.dbwg_match_list then
		local matchList = DdzMillionModel.dbwg_match_list
		if not matchList then 
			--没有数据 网络请求
			if not have_Jh then
				have_Jh="ddz_match_hall_jh"
				FullSceneJH.Create("正在请求数据",have_Jh)
			end
		else
			if have_Jh then
				FullSceneJH.RemoveByTag(have_Jh)
				have_Jh=nil
			end
			if matchList.issue then
				self.issue_txt.text = "恭喜你获得第" .. matchList.issue .. "期大奖赛奖励"
			end
			if matchList.bonus then
				self.gold_txt.text = "￥" .. math.floor(matchList.bonus / 100)
			else
				self.gold_txt.text = "￥0"
			end
		end
	end
end

--[[退出功能，供logic和model调用，只做一次]]
function DdzMillionGetAwardPanel:MyExit()
	--closePanel(DdzMillionGetAwardPanel.name)
end
function DdzMillionGetAwardPanel:MyClose()
    self:MyExit()
    closePanel(DdzMillionGetAwardPanel.name)
end
