-- 创建时间:2018-06-20

local basefunc = require "Game.Common.basefunc"

MjXlGangsRect = basefunc.class()

MjXlGangsRect.name = "MjXlGangsRect3D"


-- 自己的对象节点，玩家的UI位置
function MjXlGangsRect.Create(panelSelf, data, call)
	if MjXlGangsRect.instance then
		MjXlGangsRect.Close()
	end
	MjXlGangsRect.instance = MjXlGangsRect.New(panelSelf, data, call)
	return MjXlGangsRect.instance
end
-- 关闭
function MjXlGangsRect.Close()
	if MjXlGangsRect.instance then
		MjXlGangsRect.instance:OnBackClick()
	end
end

function MjXlGangsRect:ctor(panelSelf, data, call)
	self.panelSelf = panelSelf
	self.data = data
	self.call = call

	local obj = newObject(MjXlGangsRect.name, panelSelf.transform)
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
function MjXlGangsRect:InitUI()
	for i,v in ipairs(self.data) do
		dump(v)
		MjCard.Create(self.MJNode, MjXlModel.PaiType.sp, v.pai, function(selfCard)
			self:OnClickPai(selfCard)
		end)
	end
end
function MjXlGangsRect:OnClickPai(selfCard)
	local act={type="gang", pai=selfCard.card}
	if self.call then
		self.call(act)
	end
	self:OnBackClick()
end
function MjXlGangsRect:OnBackClick()
	GameObject.Destroy(self.gameObject)
end

