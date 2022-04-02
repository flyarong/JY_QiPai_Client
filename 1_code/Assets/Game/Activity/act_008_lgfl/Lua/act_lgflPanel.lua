-- 创建时间:2020-04-07
-- Panel:act_lgflPanel
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

act_lgflPanel = basefunc.class()
local C = act_lgflPanel
C.name = "act_lgflPanel"

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
"1.活动时间：4月14日7:30-4月20日23:59:59",
"2.游戏中固定充值档次，每日累计购买3次，可领取额外奖励",
"3.任务进度每日0点重置，请及时领取您的奖励，未领取的奖励视为自动放弃",
}

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}

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

local ItemMap={

}


function C:ctor()

	ExtPanel.ExtMsg(self)

	local parent = GameObject.Find("Canvas/LayerLv4").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)

	Act_008LGFLManager.InitItemMap()
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
	self:MyRefresh()
end

function C:MyRefresh()
	self:InitItemMap()
	self:CreateItemPrefab()
end

function C:InitItemMap()
	ItemMap = Act_008LGFLManager.ItemMap
end

function C:tableSort()
	local temp_map = {}
	local temp3_map = {}
	for i=1,#ItemMap do
		if ItemMap[i][6] ~= 2 then
			temp_map[#temp_map+1] = ItemMap[i]
		else
			temp3_map[#temp3_map+1] = ItemMap[i]
		end
	end
	table.sort( temp_map, function(a, b) 
		if a[5] > b[5] then
			return true
		elseif a[5] == b[5] then
			if a[1] < b[1] then
				return true
			end
			return false
		end
		return false
	end)
	table.sort( temp3_map, function(a, b) return a[1] < b[1] end )
	ItemMap = temp_map
	for i=1,#temp3_map do
		ItemMap[#ItemMap+1] = temp3_map[i]
	end
end

function C:CreateItemPrefab()
	self:tableSort()
	self:CloseItemPrefab()
	for i=1,#ItemMap do
		dump(ItemMap[i])
		local pre = act_008ItemBase.Create(self.Content.transform,ItemMap[i])
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

function C:back()
	Event.Brocast("Panel_back_2_refreshEnterPre")
	self:MyExit()
end

function C:help()
	self:OpenHelpPanel()
end

function C:on_already_get_award()
	self:MyRefresh()
end

function C:go_Recharge()
	self:MyExit()
end

function C:OpenHelpPanel()
	local str = help_info[1]
	for i = 2, #help_info do
		str = str .. "\n" .. help_info[i]
	end
	self.introduce_txt.text = str
	IllustratePanel.Create({ self.introduce_txt.gameObject }, GameObject.Find("Canvas/LayerLv5").transform)
end

