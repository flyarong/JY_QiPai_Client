-- 创建时间:2018-12-05

local basefunc = require "Game.Common.basefunc"

GameFreeLeftItemPrefab = basefunc.class()

local C = GameFreeLeftItemPrefab

C.name = "GameFreeLeftItemPrefab"

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

function C:ctor(parent_transform, config, call, panelSelf)
	self.config = config
	self.call = call
	self.panelSelf = panelSelf
	local obj = newObject(C.name, parent_transform)
	self.gameObject = obj
	self.transform = obj.transform

	self:MakeLister()
    self:AddMsgListener()

    LuaHelper.GeneratingVar(obj.transform, self)

	self.SelectButton_btn.onClick:AddListener(function ()
		self:OnClick()
	end)

	self:MyRefresh()
end
function C:MyRefresh()
	local data = GameFreeModel.UIConfig.game[self.config.id]

	self.Image1_img.sprite = GetTexture(data.noimage)
	self.Image2_img.sprite = GetTexture(data.hiimage)
	self.Image1_img:SetNativeSize()
	self.Image2_img:SetNativeSize()

	self.SelectButton_btn.gameObject:SetActive(true)
	self.HiImage.gameObject:SetActive(false)
	if self.config.isOpen then
		self.HintNode.gameObject:SetActive(false)
	else
		self.HintNode.gameObject:SetActive(true)
	end
	if data.tag_image and data.tag_image ~= "" then
		self.TagRect.gameObject:SetActive(true)
		self.Tag_img.sprite = GetTexture(data.tag_image)
	else
		self.TagRect.gameObject:SetActive(false)
	end

	self:UpdateDownHint()
end

-- 设置gameObject名字
function C:SetObjName(name)
	self.gameObject.name = name
end

-- 刷新下载状态
function C:UpdateDownHint()
	local data = GameFreeModel.UIConfig.game[self.config.id]
	if GameSceneCfg[data.sceneID] then
		local state = gameMgr:CheckUpdate(GameSceneCfg[data.sceneID].SceneName)
		if self.config.isOpen and (state == "Install" or state == "Update") then
			self.DownHintNode.gameObject:SetActive(true)
		else
			self.DownHintNode.gameObject:SetActive(false)
		end
	else
		self.DownHintNode.gameObject:SetActive(false)
	end
end

-- 设置选中状态
function C:SetSelect(b)
	self.SelectButton_btn.gameObject:SetActive(not b)
	self.HiImage.gameObject:SetActive(b)
end

-- 点击
function C:OnClick()
	self.call(self.panelSelf, self.gameObject)
end

function C:MyExit()
    self:RemoveListener()
end

function C:OnDestroy()
	self:MyExit()
	GameObject.Destroy(self.gameObject)
end


