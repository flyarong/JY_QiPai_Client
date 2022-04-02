-- 创建时间:2020-03-05

local basefunc = require "Game.Common.basefunc"

Fishing3DBKItem = basefunc.class()

local C = Fishing3DBKItem

C.name = "Fishing3DBKItem"

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
	local obj = newObject("by3d_bk_yu_prefab", parent_transform)
	self.gameObject = obj
	self.transform = obj.transform
	self:MakeLister()
    self:AddMsgListener()
    LuaHelper.GeneratingVar(obj.transform, self)

    self.enter_btn.onClick:AddListener(function()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        if self.call then
        	self.call(self.panelSelf, self.config)
        end
    end)
	self:MyRefresh()
end
function C:MyRefresh()
    self.name_txt.text = self.config.name or ""
    local ol = self.bs_txt.transform:GetComponent("Outline")
    if ol then
        if self.config.tag == 2 or self.config.tag == 3 then
            ol.effectColor = Color.New(165/255,0/155,27/255,1)
        else
            ol.effectColor = Color.New(22/255,86/255,158/255,1)
        end
    end
    if self.config.tag == 2 or self.config.tag == 3 then
	    self.db_img.sprite = GetTexture("3dby_bg_ybk5")
    else
	    self.db_img.sprite = GetTexture("3dby_bg_ybk6")
    end
    self.bs_txt.text = self.config.rate or ""
    self.icon_img.sprite = GetTexture(self.config.icon)
    self.icon_img:SetNativeSize()
    self.gameObject.transform:SetAsLastSibling()
end

