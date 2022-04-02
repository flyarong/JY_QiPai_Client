-- 创建时间:2020-05-06
-- Panel:Act_012_LMLHPanel
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

Act_012_LMLHPanel = basefunc.class()
local C = Act_012_LMLHPanel
C.name = "Act_012_LMLHPanel"
local M = Act_012_LMLHManager
C.instance = nil
function C.Create(parent)
	if C.instance then
		C.instance:MyRefresh()
		return
	end
	C.instance = C.New(parent)
	return C.instance
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
	-- 数据的初始化和修改
    self.lister["model_lmlh_data_change_msg"] = basefunc.handler(self,self.MyRefresh)
    self.lister["ExitScene"] = basefunc.handler(self,self.MyExit)

end

function C:OnDestroy()
	self:MyExit()
end


function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	self:CloseItemPrefab()
	self:RemoveListener()
	C.instance = nil
	destroy(self.gameObject)
end

function C:ctor(parent)
	local parent = parent or GameObject.Find("Canvas/LayerLv4").transform
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
	self.bg_img.sprite = GetTexture("lmlh_bg_lmhl")
	EventTriggerListener.Get(self.help_btn.gameObject).onClick = basefunc.handler(self, self.help)
	EventTriggerListener.Get(self.gain_item_btn.gameObject).onClick = basefunc.handler(self, self.gain_item)



	M.QueryGiftData()
end

function C:MyRefresh()
	dump(M.GetItemCount(),"<color=yellow>+++++++++++++++++++++++++</color>")
	self.user_has_item_txt.text = M.GetItemCount() or 0
	self.cur_data = M.GetCurData()
	if self.cur_data then
		self:CreateItemPrefab()
	end
end

local m_sort = function(v1,v2)
	local item = M.GetItemCount()
	if v1.remain_time <= 0 and  v2.remain_time > 0 then--前无次数后有次数
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
		if item >= tonumber(v1.Icon_cost) and item >= tonumber(v2.Icon_cost) then--都够买
			if tonumber(v1.Icon_cost) > tonumber(v2.Icon_cost) then--前面更贵
				return false
			else
				return true
			end
		elseif item >= tonumber(v1.Icon_cost) and item < tonumber(v2.Icon_cost) then--前够买后不够买
			return false
		elseif item >= tonumber(v1.Icon_cost) and item < tonumber(v2.Icon_cost) then--前不够买后够买
			return true
		elseif item < tonumber(v1.Icon_cost) and item < tonumber(v2.Icon_cost) then--都不够买
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
	self:CloseItemPrefab()
	for i=1,#self.cur_data do
		local pre = Act_012_LMLHItemBase.Create(self.Content.transform,self.cur_data[i])
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

local help_info = {
"1.活动时间：5月19日7:30-5月25日23:59:59",
"2.玩小游戏（不包含苹果大战）不论输赢，都有机会获得爱心，充值商城中购买部分档次可得爱心",
"3.每个浪漫礼盒每天可开启的数量有限，请及时使用您的爱心，活动结束后所有爱心清零",
"4.游戏场次越高，获得爱心的概率越高",
}

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


function C:gain_item()
	if MainModel.myLocation == "game_Hall" then
		GameManager.GotoUI({gotoui = "game_MiniGame"})
		self:MyExit()
	end
end