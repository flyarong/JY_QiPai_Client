local basefunc = require "Game.Common.basefunc"

RectJH = basefunc.class()

local jhTags = {}

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


--[[
	创建一个矩形区域的菊花，返回一个实例，需要手动删除
	可以使用tag标记，同一个tag的菊花不会多次创建
	删除的时候可以使用tag进行删除

	参数除了parent其他全部可以不填
]]
function RectJH.Create(parent,tag,offsetPos,scale)
	if tag then
	    RectJH.RemoveByTag(tag)
	end
    return RectJH.New(parent,tag,nil,offsetPos,scale)
end


function RectJH.CreateBySize(parent,tag,size,offsetPos,scale)
	if tag then
	    RectJH.RemoveByTag(tag)
	end
    return RectJH.New(parent,tag,size,offsetPos,scale)
end


function RectJH.RemoveByTag(tag)
    local jh = jhTags[tag]
    if chkJhIsValid(jh) then
    	jh:Remove()
    end
end

function RectJH.RemoveAll()
    for tag,jh in pairs(jhTags) do
    	if chkJhIsValid(jh) then
	    	jh:Remove()
	    end
    end
end

local jhScale=0.8
function RectJH:ctor(parent,tag,size,offsetPos,scale)
	self.tag = tag

	offsetPos = offsetPos or {x=0,y=0}
	scale = scale or jhScale

	self.UIEntity = newObject("RectJHPrefab", parent.transform.parent)
	local pos = parent.transform.localPosition
	self.UIEntity.transform.localPosition=Vector3.New(pos.x+offsetPos.x,pos.y+offsetPos.y,pos.z)

	local sz
	if size then
		sz = size
	else

		local sizeDelta = parent:GetComponent("RectTransform").sizeDelta
		sz = {width=sizeDelta.x,height=sizeDelta.y}

	end


	local bgRect = self.UIEntity.transform:Find("BG")
											:GetComponent("Image")
											:GetComponent("RectTransform")
	bgRect.sizeDelta = Vector2.New(sz.width,sz.height)


	local imgRect = self.UIEntity.transform:Find("Image")
											:GetComponent("Image")
											:GetComponent("RectTransform")
	local imgSz = {width=imgRect.sizeDelta.x,height=imgRect.sizeDelta.y}
	local minWidth = math.min(sz.width*scale,sz.height*scale)
	imgSz.width = minWidth
	imgSz.height = minWidth

	imgRect.sizeDelta = Vector2.New(imgSz.width,imgSz.height)

	if self.tag then
		jhTags[self.tag] = self
	end

end


--移除
function RectJH:Remove()
	GameObject.Destroy(self.UIEntity)
	if self.tag then
		jhTags[self.tag] = nil
	end 
end


