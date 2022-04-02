-- 创建时间:2018-09-07

local basefunc = require "Game.Common.basefunc"

GameTipsDescPrefab = basefunc.class()

GameTipsDescPrefab.name = "GameTipsDescPrefab"

GameTipsDescPrefab.instance = nil

local Create = function ()
	GameTipsDescPrefab.instance = GameTipsDescPrefab.New()
	return GameTipsDescPrefab.instance
end

-- 关闭
function GameTipsDescPrefab.Close()
	if GameTipsDescPrefab.instance then
		GameObject.Destroy(GameTipsDescPrefab.instance.transform.gameObject)
	end
	GameTipsDescPrefab.instance = nil
end
function GameTipsDescPrefab.Show(desc,pos)
	if not GameTipsDescPrefab.instance then
		Create()
	end
	GameTipsDescPrefab.instance:ShowUI(desc,pos)
end
function GameTipsDescPrefab.Hide()
	if GameTipsDescPrefab.instance then
		GameTipsDescPrefab.instance:HideUI()
	end
end

function GameTipsDescPrefab:ctor()
	local parent = GameObject.Find("Canvas/LayerLv4").transform
	GameTipsDescPrefab.HideParent = GameObject.Find("GameManager").transform

	local obj = newObject(GameTipsDescPrefab.name, parent)
	tran = obj.transform
	self.transform = tran

	self.Node = tran:Find("Image")
	self.DescText = tran:Find("Image/DescText"):GetComponent("Text")
end

-- 显示
function GameTipsDescPrefab:ShowUI(desc,pos)

	local parent = GameObject.Find("Canvas/LayerLv4").transform
	self.transform:SetParent(parent)
	self.DescText.text = "" .. desc

	local camera = GameObject.Find("Canvas/Camera"):GetComponent("Camera")
	local p = camera:ScreenToWorldPoint(pos)
	self.Node.position = Vector3.New(p.x, p.y + 60, 0)
	self.Node.gameObject:SetActive(false)
	self.Node.gameObject:SetActive(true)
	-- nmg todo 位置适应界面
end

-- 隐藏
function GameTipsDescPrefab:HideUI()
	self.transform:SetParent(GameTipsDescPrefab.HideParent)
end


