-- 创建时间:2018-09-07

local basefunc = require "Game.Common.basefunc"

GameTipsPrefab = basefunc.class()

GameTipsPrefab.name = "GameTipsPrefab"

GameTipsPrefab.instance = nil

GameTipsPrefab.TipsShowStyle =
{
	TSS_N = "TSS_N", -- 正常
	TSS_1 = "TSS_1", -- 第一象限
	TSS_2 = "TSS_2", -- 第二象限
	TSS_3 = "TSS_3", -- 第三象限
	TSS_4 = "TSS_4", -- 第四象限
	TSS_34 = "TSS_34", -- 第三四象限
}
local GetStyleIndex = function (style)
	if style == GameTipsPrefab.TipsShowStyle.TSS_1 then
		return 1
	elseif style == GameTipsPrefab.TipsShowStyle.TSS_2 then
		return 2
	elseif style == GameTipsPrefab.TipsShowStyle.TSS_3 then
		return 3
	else
		return 4
	end
end


local Create = function ()
	GameTipsPrefab.instance = GameTipsPrefab.New()
	return GameTipsPrefab.instance
end

-- 关闭
function GameTipsPrefab.Close()
	if GameTipsPrefab.instance then
		GameTipsPrefab.instance:RemoveListener()
		GameObject.Destroy(GameTipsPrefab.instance.transform.gameObject)
	end
	GameTipsPrefab.instance = nil
end

-- 显示道具tips
function GameTipsPrefab.ShowItem(itemkey, pos, style)
	if not GameTipsPrefab.instance then
		Create()
	end
	GameTipsPrefab.instance:ShowItemUI(itemkey, pos, style)
end

-- 显示说明tips
function GameTipsPrefab.ShowDesc(desc, pos, style)
	if not GameTipsPrefab.instance then
		Create()
	end
	GameTipsPrefab.instance:ShowDescUI(desc, pos, style)
end

function GameTipsPrefab.Hide()
	if GameTipsPrefab.instance then
		GameTipsPrefab.instance:HideUI()
	end
end

function GameTipsPrefab:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function GameTipsPrefab:MakeLister()
    self.lister = {}
    self.lister["ExitScene"] = basefunc.handler(self, self.OnExitScene)
end

function GameTipsPrefab:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function GameTipsPrefab:ctor()
	local parent = GameObject.Find("Canvas/LayerLv5").transform
	GameTipsPrefab.HideParent = GameObject.Find("GameManager").transform

	self:MakeLister()
	self:AddMsgListener()
	
	local obj = newObject(GameTipsPrefab.name, parent)
	tran = obj.transform
	self.transform = tran

	self.StyleNode = {}
	for i = 1, 4 do
		self.StyleNode[i] = tran:Find("StyleNode" .. i)
	end
end
function GameTipsPrefab:OnExitScene()
	GameTipsPrefab.Close()
end

-- 显示道具tips
function GameTipsPrefab:ShowItemUI(itemkey, pos, style)
	if not itemkey then
		return
	end
	self:SetStyle(pos, style)

	local parent = GameObject.Find("Canvas/LayerLv5").transform
	self.transform:SetParent(parent)

	local item = GameItemModel.GetItemToKey(itemkey)
	if item then
		self.NameText.text = "" .. item.name
		if desc then
			self.DescText.text = "" .. desc
		else
			self.DescText.text = "" .. item.desc
		end
	else
		self.NameText.text = "" .. itemkey
		self.DescText.text = "" .. itemkey
	end
end

-- 显示描述tips
function GameTipsPrefab:ShowDescUI(desc, pos, style)
	if not desc then
		desc = "nil"
	end
	if not pos then
		pos = UnityEngine.Input.mousePosition
	end
	self:SetStyle(pos, style)
	local parent = GameObject.Find("Canvas/LayerLv5").transform
	self.transform:SetParent(parent)

	self.NameText.gameObject:SetActive(false)
	self.DescText.text = "" .. desc

	local textWidth = self.DescText.preferredWidth
	print("textWidth = " .. textWidth)
	local rect = self.DescText.transform:GetComponent("RectTransform")
	if textWidth > 520 then
		rect.sizeDelta = {x = 520, y = rect.sizeDelta.y}
	else
		rect.sizeDelta = {x = textWidth, y = rect.sizeDelta.y}
	end
end

function GameTipsPrefab:SetStyle(pos, style)
	local camera = GameObject.Find("Canvas/Camera"):GetComponent("Camera")
	local p = camera:ScreenToWorldPoint(pos)

	-- 自适应
	if not style then
		if p.x > 0 and p.y > 0 then
			style = GameTipsPrefab.TipsShowStyle.TSS_1
		elseif p.x < 0 and p.y > 0 then
			style = GameTipsPrefab.TipsShowStyle.TSS_2
		elseif p.x < 0 and p.y < 0 then
			style = GameTipsPrefab.TipsShowStyle.TSS_3
		else
			style = GameTipsPrefab.TipsShowStyle.TSS_4
		end
	elseif style == GameTipsPrefab.TipsShowStyle.TSS_34 then
		if p.x < 0 then
			style = GameTipsPrefab.TipsShowStyle.TSS_3
		else
			style = GameTipsPrefab.TipsShowStyle.TSS_4
		end
	end

	local pyX = 0
	local pyY = 0
	if style == GameTipsPrefab.TipsShowStyle.TSS_1 then
		pyY = -60
	elseif style == GameTipsPrefab.TipsShowStyle.TSS_2 then
		pyY = -60
	elseif style == GameTipsPrefab.TipsShowStyle.TSS_3 then
		pyY = 60
	else
		pyY = 60
	end

	self.transform.position = Vector3.New(p.x + pyX, p.y + pyY, 0)
	self.transform.gameObject:SetActive(false)
	self.transform.gameObject:SetActive(true)

	local index = GetStyleIndex(style)
	local node = self.StyleNode[index]
	local tran = node.transform
	for i = 1, 4 do
		if index ~= i then
			self.StyleNode[i].gameObject:SetActive(false)
		end
	end
	node.gameObject:SetActive(true)
	self.NameText = tran:Find("BG/NameText"):GetComponent("Text")
	self.DescText = tran:Find("BG/DescText"):GetComponent("Text")
end

-- 隐藏
function GameTipsPrefab:HideUI()
	self.transform:SetParent(GameTipsPrefab.HideParent)
end


