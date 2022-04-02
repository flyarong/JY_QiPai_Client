-- 创建时间:2020-07-10
-- Panel:KPSHBLotteryPrefab
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

KPSHBLotteryPrefab = basefunc.class()
local C = KPSHBLotteryPrefab
C.name = "KPSHBLotteryPrefab"

function C.Create(parent_transform, config, call, panelSelf, index)
	return C.New(parent_transform, config, call, panelSelf, index)
end

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
	self:RemoveListener()
	destroy(self.gameObject)
end
function C:OnDestroy()
	self:MyExit()
end

function C:ctor(parent_transform, config, call, panelSelf, index)
	self.config = config
	self.call = call
	self.panelSelf = panelSelf
	self.index = index
	local nn
	if self.panelSelf.xz_lv == 1 then
		nn = "KPSHBLotteryPrefab1"
	elseif self.panelSelf.xz_lv == 2 then
		nn = "KPSHBLotteryPrefab2"
	else
		nn = "KPSHBLotteryPrefab3"
	end
	local obj = newObject(nn, parent_transform)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)

	self:MakeLister()
	self:AddMsgListener()

	self.back_btn.onClick:AddListener(function ()
		self:OnClick()
	end)
	self:SetBox(false)

	self.fx_chixu = newObject("com_hongbao_chixu_activity_by3d_kpshb", self.fx_node)
	self.fx_chixu.transform.localPosition = Vector3.New(0, 18, 0)
	self.fx_chixu.gameObject:SetActive(false)


	self:InitUI()
end

function C:InitUI()
	self:MyRefresh()
end

function C:MyRefresh()
	self.flq_txt.text = StringHelper.ToRedNum( self.config / 100 )
end

function C:UpdateData(config)
	self.config = config
	self:MyRefresh()
end

function C:OnClick()
	if self.call then
		self.call(self.panelSelf, self.index)
	end
end

function C:SetPos(pos)
	self.transform.localPosition = pos
end

function C:SetFront()
	self.flq_txt.gameObject:SetActive(true)
end

function C:SetBack()
	self.flq_txt.gameObject:SetActive(false)
end

function C:SetBox(b)
	self.back_btn.enabled = b
end

function C:SetSelect()
	-- self.seq = DoTweenSequence.Create()
	-- self.seq:Append(self.transform:DOScale(0.9, 0.1))
	-- self.seq:Append(self.transform:DOScale(1.1, 0.1))
end

