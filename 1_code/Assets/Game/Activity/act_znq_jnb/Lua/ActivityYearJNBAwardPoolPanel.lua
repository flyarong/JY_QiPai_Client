-- 创建时间:2019-08-22
-- Panel:ActivityYearJNBAwardPoolPanel
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

ActivityYearJNBAwardPoolPanel = basefunc.class()
local C = ActivityYearJNBAwardPoolPanel
C.name = "ActivityYearJNBAwardPoolPanel"

function C.Create()
	return C.New()
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

function C:ctor()

	ExtPanel.ExtMsg(self)

	local parent = GameObject.Find("Canvas/LayerLv5").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()

	ActivityYearModel.GetJNBData()
	self.cfg_parm = ActivityYearModel.UIConfig.jnb_config_parm
	self.cfg_pool = ActivityYearModel.UIConfig.jnb_config_award

	self.cell_data = {}
	for k,v in ipairs(self.cfg_parm.award_pool) do
		local cc = self.cfg_pool[v]
		local d = {}
		d.icon = cc.icon
		d.name = cc.name
		self.cell_data[#self.cell_data + 1] = d
	end

	self.close_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnCloseClick()
	end)
	self.qd_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnCloseClick()
	end)
	self.hint_txt.text = "奖品份数越多，开奖中奖的概率越高！"

	self:InitUI()
end

function C:InitUI()
	self:MyRefresh()
end

function C:MyRefresh()
	self:ClearCellList()
	for k,v in ipairs(self.cell_data) do
		local pre = AwardPrefab.Create(self.content, v)
		self.CellList[#self.CellList + 1] = pre
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

function C:OnCloseClick()
	self:MyExit()
end
