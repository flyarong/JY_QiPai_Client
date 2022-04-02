-- 创建时间:2019-12-27
-- Panel:SNYJCJPrefab
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

SNYJCJPrefab = basefunc.class()
local C = SNYJCJPrefab
C.name = "SNYJCJPrefab"

function C.Create(parent_transform, ui_pos, call, panelSelf)
	return C.New(parent_transform, ui_pos, call, panelSelf)
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

function C:ctor(parent_transform, ui_pos, call, panelSelf)
	self.ui_pos = ui_pos
	self.call = call
	self.panelSelf = panelSelf
	local obj = newObject("snyjcj_prefab", parent_transform)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	PointerEventListener.Get(self.bm.gameObject).onDown = function ()
		if self.call then
			self.call(self.panelSelf, self.ui_pos, self.index)
		end
	end
	self:MyRefresh()
end

function C:MyRefresh()
	if SNYJCJManager.GetData() then 
		self.m_data = SNYJCJManager.GetData().at_data
	else
		self.m_data = nil
	end
	self.config = SNYJCJManager.config

	if self.m_data then
		if self.index then
			self.zm.gameObject:SetActive(true)
			self.bm.gameObject:SetActive(false)
			self.icon_img.sprite = GetTexture(self.config.Award[self.index].award_image)
			self.name_txt.text = self.config.Award[self.index].award_text
		else
			self.zm.gameObject:SetActive(false)
			self.bm.gameObject:SetActive(true)
		end
	else
		self.zm.gameObject:SetActive(false)
		self.bm.gameObject:SetActive(true)
	end
end
function C:SetIndex(index)
	self.index = index
	if self.index then
		self.icon_img.sprite = GetTexture(self.config.Award[self.index].award_image)
		self.name_txt.text = self.config.Award[self.index].award_text
	end
end

function C:SetPos(pos)
	self.transform.localPosition = pos
end

function C:RunOpenAnim(call)

	self.seq = DoTweenSequence.Create()
	self.seq:Append(self.transform:DORotate(Vector3.New(0, 90.0, 0), 0.2, DG.Tweening.RotateMode.FastBeyond360))
	self.seq:AppendCallback(function ()
		self.zm.gameObject:SetActive(true)
		self.bm.gameObject:SetActive(false)
	end)
	self.seq:Append(self.transform:DORotate(Vector3.New(0, 0, 0), 0.2, DG.Tweening.RotateMode.FastBeyond360))
	self.seq:AppendInterval(0.4)
	self.seq:OnKill(function ()
		if call then
			call()
		end
	end)
end
