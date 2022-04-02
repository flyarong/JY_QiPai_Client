-- 创建时间:2020-05-18
-- Panel:Act_014_XYCDPanel
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

Act_014_XYCDPanel = basefunc.class()
local C = Act_014_XYCDPanel
C.name = "Act_014_XYCDPanel"
local M = Act_014_XYCDManager
function C.Create()
	if C.instance then
		C.instance:MyRefresh()
		return
	end
	C.instance = C.New()
	return C.instance
end

local help_info = {
"1.活动时间：6月2日7:30-6月8日23:59:59",
"2.玩任意小游戏（不包含苹果大战）不论输赢，都有机会获得阳光能量，充值商城中购买部分档次可获得阳光能量",
"3.每种幸运蛋每天可开启的数量有限，请及时使用您的阳光能量，活动结束后所有阳光能量清零",
"4.游戏场次越高，获得阳光能量的概率越高",
}

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["ExitScene"]=basefunc.handler(self,self.MyExit)
    self.lister["model_xycd_data_change_msg"] = basefunc.handler(self,self.MyRefresh)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	self:RemoveListener()
	C.instance = nil
	destroy(self.gameObject)
end

function C:ctor()
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
	EventTriggerListener.Get(self.gain_sunCount_btn.gameObject).onClick = basefunc.handler(self, self.gain_sunCount)
	Act_014_XYCDManager.QueryGiftData()
	
end

function C:MyRefresh()
	self.user_has_sunCount_txt.text = Act_014_XYCDManager.GetSunCount() or 0
	self.cur_data = Act_014_XYCDManager.GetCurData()
	if self.cur_data then
		self:CreateItemPrefab()
	end
end

local m_sort = function(v1,v2)
	local sun = Act_014_XYCDManager.GetSunCount()
	if v1.remain_time <= 0 and v2.remain_time > 0 then--前无次数后有次数
		return true
	elseif v1.remain_time <= 0 and v2.remain_time <= 0 then--都没次数
		if v1.gift_id < v2.gift_id then
			return false
		else
			return true
		end
	elseif v1.remain_time > 0 and v2.remain_time <= 0 then--前有次数后无次数
		return false
	else--都有次数
		if sun >= tonumber(v1.sun_cost_text) and sun >= tonumber(v2.sun_cost_text) then--都够买
			if tonumber(v1.sun_cost_text) > tonumber(v2.sun_cost_text) then--前面更贵
				return false
			else
				return true
			end
		elseif sun >= tonumber(v1.sun_cost_text) and sun < tonumber(v2.sun_cost_text) then--前够买后不够买
			return false
		elseif sun >= tonumber(v1.sun_cost_text) and sun < tonumber(v2.sun_cost_text) then--前不够买后够买
			return true
		elseif sun < tonumber(v1.sun_cost_text) and sun < tonumber(v2.sun_cost_text) then--都不够买
			if v1.gift_id < v2.gift_id then
				return false
			elseif v1.gift_id > v2.gift_id then
				return true
			end
		end
	end
end

function C:CreateItemPrefab()
	MathExtend.SortListCom(self.cur_data, m_sort)
	dump(self.cur_data)
	self:CloseItemPrefab()
	for i=1,#self.cur_data do
		local pre = Act_014_XYCDItemBase.Create(self.Content.transform,self.cur_data[i])
		self.spawn_cell_list[#self.spawn_cell_list + 1] = pre
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

function C:back()
	Event.Brocast("Panel_back_2_refreshEnterPre_xycd")
	self:MyExit()
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



function C:gain_sunCount()
	if MainModel.myLocation == "game_Hall" then
		GameManager.GotoUI({gotoui = "game_MiniGame"})
		self:MyExit()
	end
end