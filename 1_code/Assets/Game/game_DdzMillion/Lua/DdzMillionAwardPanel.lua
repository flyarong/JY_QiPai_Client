--ganshuangfeng 比赛场等待界面
--2018-04-17
local basefunc = require "Game.Common.basefunc"

DdzMillionAwardPanel = basefunc.class()

DdzMillionAwardPanel.name = "DdzMillionAwardPanel"
local lister
local have_Jh
local instance
function DdzMillionAwardPanel.Create()
    SysInteractivePlayerManager.Close()
    SysInteractiveChatManager.Hide()

	instance=DdzMillionAwardPanel.New()
	return createPanel(instance,DdzMillionAwardPanel.name)
end
function DdzMillionAwardPanel.Bind()
	local _in=instance
	instance=nil
	return _in
end

function DdzMillionAwardPanel:Awake()
	LuaHelper.GeneratingVar(self.transform, self)
	self:MyInit()
end

function DdzMillionAwardPanel:Start()
	if DdzMillionModel.data then
		local fianlResult = DdzMillionModel.data.dbwg_final_result
		local matchInfo = DdzMillionModel.data.match_info
		if not fianlResult or not matchInfo then 
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
			if matchInfo.issue then
				self.issue_txt.text = "恭喜你获得第" .. matchInfo.issue .. "期大奖赛奖励"
			end
			if matchInfo.bonus then
				self.gold_txt.text = "￥" .. math.floor(matchInfo.bonus / 100)
			else
				self.gold_txt.text = "￥0"
			end
		end
	end
end

function DdzMillionAwardPanel:OnDestroy()
	lister = nil
end

--[[初始化功能，创建好panel后在Award中调用，只做一次]]
function DdzMillionAwardPanel:MyInit()
	EventTriggerListener.Get(self.close_btn.gameObject).onClick=basefunc.handler(self,self.OnClickClose)
end

--[[刷新功能，供Logic和model调用，重复性操作]]
function DdzMillionAwardPanel:MyRefresh()

end

--[[退出功能，供logic和model调用，只做一次]]
function DdzMillionAwardPanel:MyExit()
	--closePanel(DdzMillionAwardPanel.name)
end
function DdzMillionAwardPanel:MyClose()
    self:MyExit()
    closePanel(DdzMillionAwardPanel.name)
end


function DdzMillionAwardPanel:OnClickClose()
	if Network.SendRequest("dbwg_quit_game") then
		DdzMillionModel.ClearMatchData()
	else
		
    end
	
end