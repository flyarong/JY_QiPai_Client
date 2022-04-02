-- 创建时间:2019-08-22
-- Panel:ActivityYearJNBAwardPanel
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

ActivityYearJNBAwardPanel = basefunc.class()
local C = ActivityYearJNBAwardPanel
C.name = "ActivityYearJNBAwardPanel"

local instance
function C.Create(data, is_sw)
	instance = C.New(data, is_sw)
	return instance
end
function C.Close()
	if instance then
		instance:MyExit()
	end
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
	instance = nil

	 
end

function C:ctor(data, is_sw)

	ExtPanel.ExtMsg(self)

	self.data = data
	self.is_sw = is_sw
	local parent = GameObject.Find("Canvas/LayerLv5").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()

	self.close_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnCloseClick()
	end)
	self.copy_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnCopyClick()
	end)
	self.hint_txt.text = "抽到实物奖励请联系客服领取奖励！客服QQ：4008882620"
	self.copy_txt.text = "复制QQ"

	if self.is_sw then
		self.copy_btn.gameObject:SetActive(true)
		self.hint_txt.gameObject:SetActive(true)
	else
		self.copy_btn.gameObject:SetActive(false)
		self.hint_txt.gameObject:SetActive(false)
	end
	self:InitUI()
end

function C:InitUI()
	self:MyRefresh()
end

function C:MyRefresh()
	if self.data then
		local content
		if #self.data > 8 then
			content = self.hd_content
		else
			content = self.gd_content
		end
		self:ClearCellList()
		for k,v in ipairs(self.data) do
			local pre = AwardPrefab.Create(content, v)
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

function C:OnCloseClick()
	self:MyExit()
end
function C:OnCopyClick()
	UniClipboard.SetText("4008882620")
	LittleTips.Create("已复制QQ号请前往QQ进行添加")
	self:MyExit()
end
