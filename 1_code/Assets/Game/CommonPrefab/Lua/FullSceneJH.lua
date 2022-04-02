local basefunc = require "Game.Common.basefunc"

FullSceneJH = basefunc.class()

local jhTags={}

-- 是否同时只有一个菊花
local is_one_jh = true

--检测菊花是否有效 里面会清理无效的菊花
local function chkJhIsValid(jh)
    if jh and jh.UIEntity and not jh.UIEntity:Equals(nil) then
    	return true
    end

    if jh and jh.tag then
    	jhTags[jh.tag] = nil
    end

    return false
end

--[[创建一个全屏菊花，返回一个实例，需要手动删除
	可以使用tag标记，同一个tag的菊花不会多次创建
	删除的时候可以使用tag进行删除
]]
function FullSceneJH.Create(msg,tag, parent)
	if tag then
	    local jh = jhTags[tag]
	    if chkJhIsValid(jh) then
	    	return jh
	    end
	end
    return FullSceneJH.New(msg, tag, parent)
end

function FullSceneJH.RemoveByTag(tag)
    local jh = jhTags[tag]
    if chkJhIsValid(jh) then
    	jh:Remove()
    end
end


--移除所有菊花
function FullSceneJH.RemoveAll()
    
    for tag,jh in pairs(jhTags) do
    	if chkJhIsValid(jh) then
	    	jh:Remove()
	    end
    end

end


function FullSceneJH:ctor(msg,tag, parent)
	self.tag = tag
	if not parent then
		parent = GameObject.Find("Canvas/LayerLv50")
		if not parent then
			parent = GameObject.Find("Canvas/LayerLv5")
		end
	end

	self.UIEntity = newObject("FullSceneJHPrefab", parent.transform)
	local descText = self.UIEntity.transform:Find("MBBG/Text"):GetComponent("Text")
	self.jhImage = self.UIEntity.transform:Find("MBBG").gameObject
	descText.text = msg

	if self.tag then
		jhTags[self.tag] = self
	end
	self.jhImage:SetActive(false)
    self.updateTimer = Timer.New(function ()
    	if self.jhImage and not self.jhImage:Equals(nil) then
			self.jhImage:SetActive(true)
	    end
    end, 1)
    self.updateTimer:Start()
end


--移除
function FullSceneJH:Remove()
	self.updateTimer:Stop()
	GameObject.Destroy(self.UIEntity)
	if self.tag then
		jhTags[self.tag] = nil
	end 
end






--[[

-- GameObject
local fullJHPrefab
local descText

--菊花状态 nil-无  0-隐藏中  1-显示中
local jhStatus

-- 显示全屏JH
-- showType
local ShowJH = function ( showType, desc)

	if not jhStatus then
		local parent = GameObject.Find("Canvas/LayerLv4")
		fullJHPrefab = newObject("FullSceneJHPrefab", parent.transform)
		fullJHPrefab.transform:SetParent(parent.transform)
		descText = fullJHPrefab.transform:Find("Text"):GetComponent("Text")
		descText.text = desc
		fullJHPrefab:SetActive(true)
		jhStatus = 1
	elseif jhStatus == 0 then
		local parent = GameObject.Find("Canvas/LayerLv4")
		fullJHPrefab.transform:SetParent(parent.transform)
		descText.text = desc
		fullJHPrefab:SetActive(true)
		jhStatus = 1
	elseif jhStatus == 1 then
		return
	end

end

-- 隐藏全屏JH
local HideJH  = function ( )

	if jhStatus == 1 then

		fullJHPrefab:SetActive(false)
		local parent = GameObject.Find("GameManager").transform
		fullJHPrefab.transform:SetParent(parent)
		jhStatus = 0

	end

end

FullSceneJH.ShowJH = ShowJH
FullSceneJH.HideJH = HideJH

]]