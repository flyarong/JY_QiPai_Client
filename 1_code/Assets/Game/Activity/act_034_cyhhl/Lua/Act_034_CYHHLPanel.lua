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

Act_034_CYHHLPanel = basefunc.class()
local C = Act_034_CYHHLPanel
C.name = "Act_034_CYHHLPanel"
local M = Act_034_CYHHLManager
C.instance = nil

local help_info1 = {
	"1.活动时间：10月20日7:30~10月26日23:59:59",
	"2.玩小游戏（不包含金蛋大乱斗）不论输赢，都有机会获得菊花道具",
	"3.请及时使用菊花道具，活动结束后所有未使用的菊花道具全部清除",
	"4.游戏档次越高，获得菊花道具的机会越大",
	
}

local help_info2 = {
	"1.活动时间：9月29日7:30~10月5日23:59:59",
	"2.活动结束后，所有的星星道具将统一清除，请及时进行奖励兑换",
}

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
	self.lister["ExitScene"] = basefunc.handler(self,self.MyExit)
	self.lister["AssetChange"] = basefunc.handler(self,self.MyRefresh)
	self.lister["model_lxdh_data_change_msg"] = basefunc.handler(self,self.MyRefresh)
	self.lister["XGDH_toggle_set_true_msg"] = basefunc.handler(self,self.on_XGDH_toggle_set_true_msg)
	self.lister["XGDH_toggle_set_false_msg"] = basefunc.handler(self,self.on_XGDH_toggle_set_false_msg)
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
	
	if self.xgdh_timer then
		self.xgdh_timer:Stop()
		self.xgdh_timer = nil
	end
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
	self:MyRefresh()
end

function C:InitUI()
	EventTriggerListener.Get(self.gain_item_btn.gameObject).onClick = basefunc.handler(self, self.gain_item)
	EventTriggerListener.Get(self.help_btn.gameObject).onClick = basefunc.handler(self, self.help)
	M.Query_data_timer(true)
	M.QueryGiftData()
end

function C:MyRefresh()
	dump(M.GetItemCount(),"<color=yellow>+++++++++++++++++++++++++</color>")
	self.user_has_item_txt.text = M.GetItemCount() or 0
	self.cur_data = M.GetCurData()
	dump(self.cur_data,"<color=yellow>+++++++++++++++++++++++++</color>")
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
		local pre = Act_034_CYHHLItemBase.Create(self.Content.transform,self.cur_data[i])
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
	GameManager.GotoUI({gotoui="game_MiniGame"})
end

function C:help()
	self:OpenHelpPanel()
end

function C:OpenHelpPanel()
	local str
	str = help_info1[1]
		for i = 2, #help_info1 do
			str = str .. "\n" .. help_info1[i]
		end
	self.introduce_txt.text = str
	IllustratePanel.Create({ self.introduce_txt.gameObject }, GameObject.Find("Canvas/LayerLv5").transform)
end



function C:on_XGDH_toggle_set_true_msg()
	self.xgdh_timer = Timer.New(function ()
		self.Toggle_tge.gameObject:SetActive(true)
	end,0.1,1,true)
	self.xgdh_timer:Start()
end

function C:on_XGDH_toggle_set_false_msg()
	if self.Toggle_tge.isOn then
		local d = os.date("%Y/%m/%d", now)
		local strs = {}
		string.gsub(d, "[^-/]+", function(s)
			strs[#strs + 1] = s
		end)
		local et = os.time({year = strs[1], month = strs[2], day = strs[3], hour = "23", min = "59", sec = "59"})
		et = et + 1
		PlayerPrefs.SetInt(MainModel.UserInfo.user_id.."XGDH",et)
	end
	self.Toggle_tge.gameObject:SetActive(false)
end