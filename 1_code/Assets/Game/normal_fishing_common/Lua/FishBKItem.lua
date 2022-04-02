-- 创建时间:2019-05-13

local basefunc = require "Game.Common.basefunc"

FishBKItem = basefunc.class()

local C = FishBKItem

C.name = "FishBKItem"

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
    self.gameObject:SetActive(true)

	self:MakeLister()
    self:AddMsgListener()

    LuaHelper.GeneratingVar(obj.transform, self)

    if self.config.tips then
	    PointerEventListener.Get(self.bg_img.gameObject).onDown = function ()
	        GameTipsPrefab.ShowDesc(self.config.tips, UnityEngine.Input.mousePosition)
	    end
	    PointerEventListener.Get(self.bg_img.gameObject).onUp = function ()
	        GameTipsPrefab.Hide()
	    end
    end

	self:MyRefresh()
end
function C:MyRefresh()
    self.bg_img.sprite = GetTexture("bk_bg" .. self.config.tag)
    self.name_txt.text = self.config.name or ""
    local ol = self.name_txt.transform:GetComponent("Outline")
    if ol then
        if self.config.tag == 1 then
            ol.effectColor = Color.New(93/255,45/155,12/255,1)
        elseif self.config.tag == 2 then
            ol.effectColor = Color.New(12/255,93/255,27/255,1)
        elseif self.config.tag == 3 then
            ol.effectColor = Color.New(12/255,35/255,93/255,1)
        end
    end
    self.num_txt.text = self.config.rate or ""
    self.icon_img.sprite = GetTexture(self.config.icon)
    self.icon_img:SetNativeSize()
    self.icon_img.transform.localScale = Vector3.one * (self.config.scale or 1)
    self.gameObject.transform:SetAsLastSibling()
end
