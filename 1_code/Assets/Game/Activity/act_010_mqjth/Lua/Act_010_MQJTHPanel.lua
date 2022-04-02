-- 创建时间:2020-04-23
-- Panel:Act_010_MQJTHPanel
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

local basefunc = require "Game/Common/basefunc"

Act_010_MQJTHPanel = basefunc.class()
local C = Act_010_MQJTHPanel
local M = Act_010_MQJTHManager
C.name = "Act_010_MQJTHPanel"
C.instance = nil
function C.Create()
	if C.instance then
		C.instance:MyRefresh()
		return
	end
	C.instance = C.New()
	return C.instance
end

local help_info = {
"1.活动时间：5月5日0:00-5月11日23:59:59",
"2.玩小游戏（不包含苹果大战）不论输赢，都有机会获得康乃馨，充值商城中每日首次购买鲸币必得康乃馨",
"3.每种奖励每天领取的数量有限，请及时使用您的康乃馨，活动结束后所有康乃馨清零",
"4.游戏场次越高，获得康乃馨的概率越高",
"5.实物奖励，请在活动结束后7个工作日内联系客服QQ：4008882620领取，否则视为自动放弃奖励，实物奖励将在活动结束后7个工作日内统一发放",
}

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}

    -- 数据的初始化和修改
    self.lister["model_mqjth_data_change_msg"] = basefunc.handler(self,self.MyRefresh)
    self.lister["ExitScene"] = basefunc.handler(self,self.MyExit)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	M.update_time(false)
	self:CloseItemPrefab()
	self:RemoveListener()
	C.instance = nil
	destroy(self.gameObject)
end

function C:ctor()

	ExtPanel.ExtMsg(self)

	local parent = GameObject.Find("Canvas/LayerLv4").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	self.transform.anchorMin = Vector2.New(0,0)
	self.transform.anchorMax = Vector2.New(1,1)
	self.transform.offsetMax = Vector2.New(0,0)
	self.transform.offsetMin = Vector2.New(0,0)

end

function C:InitUI()
	EventTriggerListener.Get(self.back_btn.gameObject).onClick = basefunc.handler(self, self.back)
	EventTriggerListener.Get(self.help_btn.gameObject).onClick = basefunc.handler(self, self.help)
	EventTriggerListener.Get(self.gain_flower_btn.gameObject).onClick = basefunc.handler(self, self.gain_flower)
	
	Act_010_MQJTHManager.QueryGiftData()
	M.update_time(true)
end

function C:MyRefresh()

	self.user_has_flower_count_txt.text = Act_010_MQJTHManager.GetFlowerCount() or 0
	self.cur_data = Act_010_MQJTHManager.GetCurData()
	if self.cur_data then
		self:CreateItemPrefab()
	end
end

function C:CreateItemPrefab()
	self:CloseItemPrefab()
	for i=1,#self.cur_data do
		local pre = Act_010_MQJTHItemBase.Create(self.Content.transform,self.cur_data[i])
		if pre then
			self.spawn_cell_list[#self.spawn_cell_list + 1] = pre
		end
	end
end

function C:CloseItemPrefab()
	if self.spawn_cell_list then
		for k,v in ipairs(self.spawn_cell_list) do
			v:MyExit()
		end
	end
	self.spawn_cell_list = {}
end

function C:help()
	self:OpenHelpPanel()
end

function C:OpenHelpPanel()
	local str = help_info[1]
	for i = 2, #help_info do
		str = str .. "\n" .. help_info[i]
	end
	self.introduce_txt.text = str
	IllustratePanel.Create({ self.introduce_txt.gameObject }, GameObject.Find("Canvas/LayerLv5").transform)
end


function C:back()
	Event.Brocast("Panel_back_mqjth")
	self:MyExit()
end



function C:gain_flower()
	if MainModel.myLocation == "game_Hall" then
		GameManager.GotoUI({gotoui = "game_MiniGame"})
		self:MyExit()
	end
end