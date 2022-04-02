-- 创建时间:2018-06-20

local basefunc = require "Game.Common.basefunc"

MjXzFKGangsRect = basefunc.class()

MjXzFKGangsRect.name = "MjXzFKGangsRect3D"


-- 自己的对象节点，玩家的UI位置
function MjXzFKGangsRect.Create(panelSelf, data, call)
	if MjXzFKGangsRect.instance then
		MjXzFKGangsRect.Close()
	end
	MjXzFKGangsRect.instance = MjXzFKGangsRect.New(panelSelf, data, call)
	return MjXzFKGangsRect.instance
end
-- 关闭
function MjXzFKGangsRect.Close()
	if MjXzFKGangsRect.instance then
		MjXzFKGangsRect.instance:OnBackClick()
	end
end

function MjXzFKGangsRect:ctor(panelSelf, data, call)
	self.panelSelf = panelSelf
	self.data = data
	self.call = call

	local obj = newObject(MjXzFKGangsRect.name, panelSelf.transform)
	self.gameObject = obj
	self.transform = obj.transform
	local tran = self.transform

	self.BackButton = tran:GetComponent("Button")
	self.MJNode = tran:Find("TPNode/TPRect/mjList")
	self.BackButton.onClick:AddListener(function ()
    	self:OnBackClick()
	end)
	self:InitUI()
end
function MjXzFKGangsRect:InitUI()
	for i,v in ipairs(self.data) do
		dump(v)
		MjCard.Create(self.MJNode, MjXzFKModel.PaiType.sp, v.pai, function(selfCard)
			self:OnClickPai(selfCard)
		end)
	end
end
function MjXzFKGangsRect:OnClickPai(selfCard)
	local act={type="gang", pai=selfCard.card}
	if self.call then
		self.call(act)
	end
	self:OnBackClick()
end
function MjXzFKGangsRect:OnBackClick()
	GameObject.Destroy(self.gameObject)
end

