-- 创建时间:2019-12-11
-- Panel:AssetsGet10Panel
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

AssetsGet10Panel = basefunc.class()
local C = AssetsGet10Panel
C.name = "AssetsGet10Panel"

function C.Create(assets_data, call)
	return C.New(assets_data, call)
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
	self:CloseAwardCell()
	self:RemoveListener()
	destroy(self.gameObject)

	 
end

function C:ctor(assets_data, call)

	ExtPanel.ExtMsg(self)

	ExtendSoundManager.PlaySound(audio_config.game.bgm_hall_huodewupin.audio_name)

	self.assets_data = assets_data
	self.call = call
	self.ui_ceng = 5 -- ui层级
	local parent = GameObject.Find("Canvas/LayerLv5").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	local canvas = self.center.transform:GetComponent("Canvas")
	canvas.sortingOrder = self.ui_ceng + 2

	change_renderer(self.lingqu_GC, self.ui_ceng + 2, true)
	change_renderer(self.lingqu_ZT, self.ui_ceng + 2)
	self.lingqu_GC.gameObject:SetActive(true)
	self.lingqu_ZT.gameObject:SetActive(true)

	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	dump(self.assets_data,"<color>++++++++++++++++++++</color>")
	self.cell_data = self.assets_data
	self.BG_btn.onClick:AddListener(function ()
		self:MyExit()
	end)
	self.confirm_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		if self.call then
			self.call()
		end
		self:OnClick()
		self:MyExit()
	end)
	self.copy_btn.onClick:AddListener(function ()	
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		LittleTips.Create("已复制QQ号请前往QQ进行添加")
		UniClipboard.SetText("4008882620")
		self:MyExit()
	end)

	for i=1,#self.assets_data do
		if self.assets_data[i].asset_type ~= "shop_gold_sum" and self.assets_data[i].asset_type ~= "jing_bi" then
			self.copy_btn.gameObject:SetActive(true)
			break
		end
	end

	self:MyRefresh()
end

function C:MyRefresh()
	self:CloseAwardCell()
	for k,v in ipairs(self.cell_data) do
		local pre = AwardPrefab.Create(self.AwardNode, v)
		pre:RunAnim(k*0.2)
		self.AwardCellList[#self.AwardCellList + 1] = pre
	end

end
function C:CloseAwardCell()
	if self.AwardCellList then
		for i,v in ipairs(self.AwardCellList) do
			v:OnDestroy()
		end
	end
	self.AwardCellList = {}
end

function C:OnClick()
	if self.call then
		self.call()
	end
end

function C:SetCopyButton(b)
	self.copy_btn.gameObject:SetActive(b)
end