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

Act_016_LXDHPanel = basefunc.class()
local C = Act_016_LXDHPanel
C.name = "Act_016_LXDHPanel"
local M = Act_016_LXDHManager
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
    self.lister["model_lxdh_data_change_msg"] = basefunc.handler(self,self.MyRefresh)
    self.lister["ExitScene"] = basefunc.handler(self,self.MyExit)
    self.lister["model_lxdh_data_change_msg"] = basefunc.handler(self,self.MyRefresh)
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
	M.Query_data_timer(false)
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
	EventTriggerListener.Get(self.gain_item_btn.gameObject).onClick = basefunc.handler(self, self.gain_item)
	M.Query_data_timer(true)
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
	if v1.remain_time == 0 and  (v2.remain_time > 0 or v2.remain_time == -1) then--前无次数后有次数
		return true
	elseif v1.remain_time == 0 and v2.remain_time == 0 then--都没次数
		if v1.ID < v2.ID then
			return false
		else
			return true
		end
	elseif (v1.remain_time > 0 or v1.remain_time == -1) and v2.remain_time == 0 then--前有次数后无次数
		return false
	else--都有次数	
		if v1.ID < v2.ID then
			return false
		elseif v1.ID > v2.ID then
			return true
		end
	end
end

function C:CreateItemPrefab()
	MathExtend.SortListCom(self.cur_data, m_sort)
	self:CloseItemPrefab()
	for i=1,#self.cur_data do
		local pre = Act_016_LXDHItemBase.Create(self.Content.transform,self.cur_data[i])
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



function C:gain_item()
	GameManager.GotoUI({gotoui="game_FishingHall"})
end