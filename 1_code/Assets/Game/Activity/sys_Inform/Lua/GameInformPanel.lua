-- 创建时间:2018-09-10
require "Game.CommonPrefab.Lua.GameInformCell"

local basefunc = require "Game.Common.basefunc"

GameInformPanel = basefunc.class()

GameInformPanel.name = "GameInformPanel"

GameInformPanel.instance = nil

local Create = function()
	GameInformPanel.instance = GameInformPanel.New()
	return GameInformPanel.instance
end
function GameInformPanel.AddInform(key)
	if not GameInformPanel.instance then
		Create()
	end
	GameInformPanel.instance:CreateInform(key)
end

function GameInformPanel:MyExit()
	self:CloseCell()
end

function GameInformPanel.Close()
	if GameInformPanel.instance then
		GameInformPanel.instance:MyExit()
		GameInformPanel.instance = nil
	end
end

function GameInformPanel:ctor()

	ExtPanel.ExtMsg(self)
	local parent = GameObject.Find("Canvas/LayerLv4").transform
	local obj = newObject(GameInformPanel.name, parent)
	local tran = obj.transform
	self.CellList = {}
	self.transform = tran
	self.gameObject = obj
	self.Cell = tran:Find("Cell")
end
function GameInformPanel:CreateInform(key)
	local obj = GameInformCell.Create(key, self.Cell, self.transform)
	self.CellList[#self.CellList + 1] = obj
end
function GameInformPanel:CloseCell()
	for k,v in ipairs(self.CellList) do
		if v then
			v:CloseUI()
		end
	end
	self.CellList = {}	
end
