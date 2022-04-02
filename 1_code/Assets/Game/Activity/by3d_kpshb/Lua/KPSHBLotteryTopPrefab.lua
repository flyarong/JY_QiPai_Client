-- 创建时间:2020-07-10
-- Panel:KPSHBLotteryTopPrefab
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

KPSHBLotteryTopPrefab = basefunc.class()
local C = KPSHBLotteryTopPrefab
C.name = "KPSHBLotteryTopPrefab"

function C.Create(parent_transform, config, call, panelSelf)
	return C.New(parent_transform, config, call, panelSelf)
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

function C:MyClose()
	self:MyExit()
end

function C:ctor(parent_transform, config, call, panelSelf)
	self.config = config
	self.call = call
	self.panelSelf = panelSelf

	local obj = newObject(C.name, parent_transform)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	self.dj_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		if self.call then
			self.call(self.panelSelf, self.config)
		end
	end)
	self:MyRefresh()
end

function C:MyRefresh()
	self.name1_txt.text = self.config.name
	self.name2_txt.text = self.config.name
	self.name3_txt.text = self.config.name

	if self.config.hint then
		self.hint_img.gameObject:SetActive(true)
		self.hint_txt.text = self.config.hint
		self.hint_img.sprite = GetTexture(self.config.hint_img)
	else
		self.hint_img.gameObject:SetActive(false)
	end
end

function C:SetDJState(b)
	self.dj_node.gameObject:SetActive(b)
	self.no_node.gameObject:SetActive(not b)
end

function C:SetSelect(b)
	self.dj_node.gameObject:SetActive(not b)
	self.xz_node.gameObject:SetActive(b)	
end
