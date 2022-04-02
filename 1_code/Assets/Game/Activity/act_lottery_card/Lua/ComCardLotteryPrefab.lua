-- 创建时间:2019-06-19
-- Panel:ComCardLotteryPrefab
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

ComCardLotteryPrefab = basefunc.class()
local C = ComCardLotteryPrefab
C.name = "ComCardLotteryPrefab"

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

function C:ctor(parent_transform, config, call, panelSelf, index)
	self.config = config
	self.call = call
	self.panelSelf = panelSelf
	self.index = index
	local obj = newObject(C.name, parent_transform)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)

	self.back.gameObject:SetActive(true)
	self.front.gameObject:SetActive(false)
	self.hint_award.gameObject:SetActive(false)

	self:MakeLister()
	self:AddMsgListener()

	self.back_btn.onClick:AddListener(function ()
		self:OnClick()
	end)
	self:SetBox(false)

	self:InitUI()
end

function C:InitUI()
	self:MyRefresh()
end

function C:MyRefresh()
	local item_config = GameItemModel.GetItemToKey(self.config.asset_type)
	self.award_txt.text = StringHelper.ToRedNum(self.config.value / 100)
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
	self.back.gameObject:SetActive(false)
	self.front.gameObject:SetActive(true)
end

function C:SetBack()
	self.back.gameObject:SetActive(true)
	self.front.gameObject:SetActive(false)
	self.transform.rotation = Quaternion:SetEuler(0, 0, 0)
end

function C:SetBox(b)
	self.back_btn.enabled = b
end

function C:SetSelect()
	self.seq = DoTweenSequence.Create()
	self.seq:Append(self.transform:DOScale(0.9, 0.1))
	self.seq:Append(self.transform:DOScale(1.1, 0.1))
end
function C:AnimShowAward(scale)
	scale = scale or 1
	self.seq = DoTweenSequence.Create()
	self.seq:Append(self.transform:DORotate(Vector3.New(0, 90.0, 0), 0.3, DG.Tweening.RotateMode.FastBeyond360))
	self.seq:AppendCallback(function ()
		self:SetFront()
	end)
	self.seq:Append(self.transform:DORotate(Vector3.New(0, 0, 0), 0.3, DG.Tweening.RotateMode.FastBeyond360))
	self.seq:Join(self.transform:DOScale(Vector3.New(scale, scale, scale), 0.3))
end
function C:SetParent(parent)
	self.transform:SetParent(parent)
end

