-- 创建时间:2019-12-09
-- Panel:LHDDeskPrefab
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

LHDDeskPrefab = basefunc.class()
local C = LHDDeskPrefab
C.name = "LHDDeskPrefab"

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

	local obj = newObject("desk_prefab", parent_transform)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	self.gameObject.name = self.config.room_no
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	self.head1_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnClick(1)
	end)
	self.head2_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnClick(2)
	end)
	self.head3_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnClick(3)
	end)
	self.head4_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnClick(4)
	end)
	self:MyRefresh()
end

function C:MyRefresh()
	self.desk_id_txt.text = self.config.room_no
	for i = 1, 4 do
		self["head_node"..i].gameObject:SetActive(false)
		self["desk"..i].gameObject:SetActive(true)
	end
	if self.config.p_info then
		for k,v in ipairs(self.config.p_info) do
			self["head_node"..v.seat_num].gameObject:SetActive(true)
			self["desk"..v.seat_num].gameObject:SetActive(false)
			URLImageManager.UpdateHeadImage(v.head_link, self["head"..v.seat_num.."_img"])
		end
	end
	if self.config.p_info and #self.config.p_info > 0 then
		self.state_img.gameObject:SetActive(true)
		if self.config.state == 0 then
			self.desk_icon_img.sprite = GetTexture("dld_icon_ddz")
			self.state_img.sprite = GetTexture("dld_imgf_kxz")
		else
			self.desk_icon_img.sprite = GetTexture("dld_icon_zdz")
			self.state_img.sprite = GetTexture("dld_imgf_zdz")
		end
	else
		self.desk_icon_img.sprite = GetTexture("dld_icon_kxz")
		self.state_img.gameObject:SetActive(false)
	end
end

function C:OnClick(index)
	if self.call then
		self.call(self.panelSelf, self.index, index)
	end
end
