-- 创建时间:2019-11-26
-- Panel:ActivityXQDZZPanel
--[[
 *      ┌─┐       ┌─┐
 *   ┌──┘ ┴───────┘ ┴──┐
 *   │                 │
 *   │       ───       │
 *   │  ─┬┘       └┬─  │
 *   │                 │
 *   │       ─┴─       │
 *   │                 │
 *   └───┐         ┌───┘
 *       │         │
 *       │         │
 *       │         │
 *       │         └──────────────┐
 *       │                        │
 *       │                        ├─┐
 *       │                        ┌─┘
 *       │                        │
 *       └─┐  ┐  ┌───────┬──┐  ┌──┘
 *         │ ─┤ ─┤       │ ─┤ ─┤
 *         └──┴──┘       └──┴──┘
 *                神兽保佑
 *               代码无BUG!
 --]]
--【雪球大作战】
local basefunc = require "Game/Common/basefunc"

ActivityXQDZZPanel = basefunc.class()
local C = ActivityXQDZZPanel
C.name = "ActivityXQDZZPanel"
C.key = "snowball_battle"
local config = XQDZZManager.config
function C.Create(parent, cfg, backcall)
	return C.New(parent, cfg, backcall)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
	self.lister = {}
	self.lister["get_one_common_lottery_info"] = basefunc.handler(self, self.Refresh_Award_UI)
	self.lister["total_lottery_num_get"] = basefunc.handler(self, self.Refresh_Award_UI)
	self.lister["AssetChange"] = basefunc.handler(self, self.OnAssetChange)
	self.lister["common_lottery_kaijaing_response"] = basefunc.handler(self, self.Get_KAIJIANG_info)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	if self.heart_timer then 
		self.heart_timer:Stop()
		self.heart_timer = nil
	end
	if self.backcall then 
		self.backcall()
		self.backcall = nil 
	end 
	self:RemoveListener()
	destroy(self.gameObject)

	 
end

function C:ctor(parent, cfg, backcall)

	ExtPanel.ExtMsg(self)

	local parent = parent or GameObject.Find("Canvas/LayerLv3").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	self.backcall = backcall
	LuaHelper.GeneratingVar(self.transform, self)	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	self:HeartToGetTotalNum()
	Network.SendRequest("common_lottery_get_round_lottery_num", {lottery_type = C.key})
	Network.SendRequest("query_common_lottery_base_info", {lottery_type = C.key})
end

function C:InitUI()
	self.help_btn.onClick:AddListener(
		function ()
			self:OpenHelpPanel()
		end
	)
	self.close_btn.onClick:AddListener(
		function ()
			self:MyExit()
		end
	)
	self:Init_Award_UI()
	self:Refresh_Award_UI()
end

function C:Init_Award_UI()
	self.UI_TABLE = {}
	local temp_ui = {}
	for i=1,#config.Award do
		local b = GameObject.Instantiate(self.AwardItem,self.AwardNodes)
		b.gameObject:SetActive(true)
		LuaHelper.GeneratingVar(b.transform, temp_ui)
		temp_ui.award_txt.text = config.Award[i].award_text
		temp_ui.need_txt.text = config.Award[i].award_need.."雪球"
		temp_ui.award_img.sprite = GetTexture(config.Award[i].award_image) 
		temp_ui.award_img:SetNativeSize() 
		temp_ui.award_get_btn.onClick:AddListener(
			function ()
				self:OnClickGetAward(i)
			end
		)
		self.UI_TABLE[#self.UI_TABLE + 1] = b
	end
end

function C:Refresh_Award_UI()
	local data = LotteryBaseManager.GetData(C.key)
	local total_num = LotteryBaseManager.GetTotalNum(C.key)
	local my_num = LotteryBaseManager.GetPresonNum(C.key)
	local temp_ui = {}
	if data then 
		self.curr_jf_txt.text =  "我的雪球："..data.ticket_num 
	end
	if total_num and total_num.lottery_num then 
		for i=1,#total_num.lottery_num do
			LuaHelper.GeneratingVar(self.UI_TABLE[i].transform, temp_ui)
			local re = config.Award[i].award_total - total_num.lottery_num[i]
			if re > 0 then 
				temp_ui.remain_txt.text = "剩"..re
			else
				temp_ui.remain_txt.text = "已兑完"
			end 		
		end
	end
	if my_num and my_num.lottery_num then 
		for i=1,#my_num.lottery_num do
			LuaHelper.GeneratingVar(self.UI_TABLE[i].transform, temp_ui)
			local re = config.Award[i].person_total - my_num.lottery_num[i]
			if re > 0 then 

			else

			end
			--dump(re,"--------------个人剩余次数---------------------") 		
		end
	end 
end

function C:OnAssetChange(data)
    dump(data, "<color=red>----奖励类型-----</color>")
    if data.change_type and data.change_type == "common_lottery_" .. C.key then
        Event.Brocast("AssetGet", data)
    end
end

function C:OpenHelpPanel()
    local str = config.DESCRIBE_TEXT[1].text
    for i = 2, #config.DESCRIBE_TEXT do
        str = str .. "\n" .. config.DESCRIBE_TEXT[i].text
    end
    self.introduce_txt.text = str
    IllustratePanel.Create({ self.introduce_txt.gameObject }, GameObject.Find("Canvas/LayerLv5").transform)
end

function C:OnClickGetAward(index)
	local data = LotteryBaseManager.GetData(C.key)
	local total_num = LotteryBaseManager.GetTotalNum(C.key)
	local my_num = LotteryBaseManager.GetPresonNum(C.key)
	if data then 
		if data.ticket_num >= config.Award[index].award_need then
			if  total_num.lottery_num[index] >= config.Award[index].award_total then 
				HintPanel.Create(1,"此商品已兑换完，请明日再来！")
			elseif my_num.lottery_num[index] >= config.Award[index].person_total then 
				HintPanel.Create(1,"今日次数已用尽，请明日再来！")
			else
				if config.Award[index].real == 0 then 
					Network.SendRequest("common_lottery_kaijaing", {lottery_type = C.key,lottery_game_num = index - 1}) -- 服务器是从0开始计数
				elseif config.Award[index].real == 1 then
					Network.SendRequest("common_lottery_kaijaing", {lottery_type = C.key,lottery_game_num = index - 1}) -- 服务器是从0开始计数 
					self.real = {image = config.Award[index].award_image ,text = config.Award[index].award_text}
				end 
			end 
		else
			local b = HintPanel.Create(2,"雪球不足，快去玩小游戏获得雪球吧！",function ()
				GameManager.CommonGotoScence({gotoui="game_MiniGame"}, function ()
					self:MyExit()
				end)
			end
			)
			b:SetButtonText(nil,"前 往")
		end 
	end
	Network.SendRequest("common_lottery_get_round_lottery_num", {lottery_type = C.key})
end

function C:HeartToGetTotalNum()
	if self.heart_timer then 
		self.heart_timer:Stop()
	end
	self.heart_timer = Timer.New(function ()
		Network.SendRequest("common_lottery_get_round_lottery_num", {lottery_type = C.key})
	end,6,-1,nil,true)
	self.heart_timer:Start()
end

function C:Get_KAIJIANG_info(_,data)
	if data and data.result == 0 then 
		if self.real then 
			RealAwardPanel.Create(self.real)
		end 
		self.real = nil
	end 
end