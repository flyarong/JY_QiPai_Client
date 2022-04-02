-- 创建时间:2018-06-20

local basefunc = require "Game.Common.basefunc"

MjXzGangsRect = basefunc.class()

MjXzGangsRect.name = "MjXzMatchERGangsRect3D"


-- 自己的对象节点，玩家的UI位置
function MjXzGangsRect.Create(panelSelf, data, call)
	if MjXzGangsRect.instance then
		MjXzGangsRect.Close()
	end
	MjXzGangsRect.instance = MjXzGangsRect.New(panelSelf, data, call)
	return MjXzGangsRect.instance
end
-- 关闭
function MjXzGangsRect.Close()
	if MjXzGangsRect.instance then
		MjXzGangsRect.instance:OnBackClick()
	end
end

function MjXzGangsRect:ctor(panelSelf, data, call)
	self.panelSelf = panelSelf
	self.data = data
	self.call = call

	local obj = newObject(MjXzGangsRect.name, panelSelf.transform)
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
function MjXzGangsRect:InitUI()
	for i,v in ipairs(self.data) do
		dump(v)
		MjCard.Create(self.MJNode, MjXzModel.PaiType.sp, v.pai, function(selfCard)
			self:OnClickPai(selfCard)
		end)
	end
end
function MjXzGangsRect:OnClickPai(selfCard)
	local act={type="gang", pai=selfCard.card}
	if self.call then
		self.call(act)
	end
	self:OnBackClick()
end
function MjXzGangsRect:OnBackClick()
	GameObject.Destroy(self.gameObject)
end

