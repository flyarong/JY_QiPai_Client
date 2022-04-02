-- 创建时间:2018-09-10

GameInformCell = {}

local basefunc = require "Game.Common.basefunc"

GameInformCell = basefunc.class()

GameInformCell.name = "GameInformCell"

local instance = nil

function GameInformCell.Create(key, cell, parent)
	instance = GameInformCell.New(key, cell, parent)
	return instance
end
function GameInformCell.Close()
	if instance then
		instance:CloseUI()
		instance = nil
	end
end

function GameInformCell:ctor(key, cell, parent)
	local data = GameInformManager.InformConfig.config[key]

	local obj = GameObject.Instantiate(cell)
	self.gameObject = obj.gameObject
	self.transform = obj.transform
	obj.transform:SetParent(parent)
	local nowtime = os.time()
	local tt = data.targetTime - nowtime
	local desc = data.desc
	if tt <= 0 then
		tt = 0
	end
	desc = string.format(desc, tostring(math.floor(tt/60)))
	obj.transform:Find("Text"):GetComponent("Text").text = desc
	obj.gameObject:SetActive(true)

	self.time = Timer.New(function ()
		self:CloseUI()
	end, 10, 1, nil, true):Start()
end
function GameInformCell:CloseUI()
	if self.time then
		self.time:Stop()
	end
	self.time = nil
	GameObject.Destroy(self.gameObject)
end

