-- 创建时间:2019-06-18
-- Panel:ActivityYearLeftPrefab
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

ActivityYearLeftPrefab = basefunc.class()
local C = ActivityYearLeftPrefab
C.name = "ActivityYearLeftPrefab"
local M = SYSACTBASEManager

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
    self.lister["UpdateHallActivityYearRedHint"] = basefunc.handler(self, self.RefreshRedHint)
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
	self.gotoUI = {}
	self.style_config = M.GetStyleConfig(self.panelSelf.goto_type)
	SetTempParm(self.gotoUI, self.config.gotoUI, "panel")

	self.prefab_name = "ActivityYearLeftPrefab_" .. self.style_config.style_type
    if not self.style_config.prefab_map[self.prefab_name] or not GetPrefab(self.prefab_name) then
        self.prefab_name = "ActivityYearLeftPrefab"
    end
	local obj = newObject(self.prefab_name, parent_transform)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()

	self.SelectButton_btn.onClick:AddListener(function ()
		self:OnClick()
	end)

	self:InitUI()
	Event.Brocast("game_act_left_prefab_created",{panelSelf = self})
end

function C:InitUI()
	self.HiImage.gameObject:SetActive(false)
	self.gameObject.name = "left_pre" .. self.index
	self.title1_txt.text = self.config.title
	self.title2_txt.text = self.config.title

	self.TagImage_img.gameObject:SetActive(true)
	if self.config.tag == "limit" then
		self.TagImage_img.sprite = GetTexture("activity_icon_2")
	elseif self.config.tag == "new" then
		self.TagImage_img.sprite = GetTexture("activity_icon_3")
	elseif self.config.tag == "hot" then
		self.TagImage_img.sprite = GetTexture("activity_icon_1")
	elseif self.config.tag == "newplayer" then
		self.TagImage_img.sprite = GetTexture("activity_icon_4")
	else
		self.TagImage_img.gameObject:SetActive(false)
	end

	self:MyRefresh()
end

function C:MyRefresh()
	self:RefreshRedHint()
end

function C:SetSelect(b)
	self.SelectButton_btn.gameObject:SetActive(not b)
	self.HiImage.gameObject:SetActive(b)
	if b then
		M.CloseActiveRedHint(self.config.ID)
		self:RefreshRedHint()
	end
end

-- 点击
function C:OnClick()
	if self.call then
		self.call(self.panelSelf, self.index)
	end
	self:RefreshRedHint()
end

function C:RefreshRedHint()
	local isRed = M.IsActiveRedHint(self.config.ID)
	local isGet = M.IsActiveGetHint(self.config.ID)
	self.RedImage.gameObject:SetActive(isRed)
	self.GetImage.gameObject:SetActive(isGet)
end
