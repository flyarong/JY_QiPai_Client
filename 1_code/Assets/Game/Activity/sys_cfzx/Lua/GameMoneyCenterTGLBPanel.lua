-- 创建时间:2018-12-20

local basefunc = require "Game.Common.basefunc"

GameMoneyCenterTGLBPanel = basefunc.class()

local C = GameMoneyCenterTGLBPanel

C.name = "GameMoneyCenterTGLBPanel"

function C.Create(parent)
	return C.New(parent)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["goldpig2_task_remain_change_msg"] = basefunc.handler(self, self.on_goldpig2_task_remain_change_msg)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyClose()
	self:ClearCellList()
	self:MyExit()
end

function C:MyExit()
	destroy(self.gameObject)
	self:RemoveListener()
end

function C:ctor(parent)

	ExtPanel.ExtMsg(self)

	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj

	self:MakeLister()
	self:AddMsgListener()
    LuaHelper.GeneratingVar(self.transform, self)
	Network.SendRequest("query_all_gift_bag_status", nil, "请求礼包数据")
    self:InitUI()
end

function C:InitUI()
	-- self.redpacket_txt.text = StringHelper.ToRedNum(MainModel.GetHBValue())
	self.transform:Find("Text"):GetComponent("Text").text = "注：购买以下任意礼包，可联系鲸小哥开通礼包奖，享最高 130 元 / 人奖励。"
	self:UpdateUI()
end
function C:on_goldpig2_task_remain_change_msg(data)
    Network.SendRequest("query_goldpig2_task_remain")
end
function C:UpdateUI()
	self:ClearCellList()
	self.data = GameMoneyCenterModel.GetTglbData()
	local list = {}
    for k, v in pairs(self.data) do
        list[#list + 1] = v
    end
    table.sort(
        list,
        function(a, b)
            return a.order < b.order
        end
    )
	for k,v in ipairs(list) do
		if v.on_off and v.on_off == 1 then
			local pre = MoneyCenterTGLBPrefab.Create(self.Content.transform, v)
			self.CellList[#self.CellList + 1] = pre	
		end
	end
end

function C:ClearCellList()
	if self.CellList then
		for k,v in ipairs(self.CellList) do
			v:OnDestroy()
		end
	end
	self.CellList = {}
end

function C:MyRefresh()
	self:UpdateUI()
end

function C:OnDHClick()
	MainModel.OpenDH()
end

--[[
	GetTexture("hall_btn_gift4")
	GetTexture("hall_btn_jzlb1")
	GetTexture("hall_btn_jzlb2")
	GetTexture("hall_btn_gift14")
--]]