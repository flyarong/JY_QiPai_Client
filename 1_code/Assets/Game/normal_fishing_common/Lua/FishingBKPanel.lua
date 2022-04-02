-- 捕鱼百科

local basefunc = require "Game.Common.basefunc"
FishingBKPanel = basefunc.class()

local M = FishingBKPanel
require "Game.normal_fishing_common.Lua.FishBKItem"
local fish_map_config =HotUpdateConfig("Game.normal_fishing_common.Lua.fish_map_config")

M.name = "FishingBKPanel"
M.item_name = "FishBKItem"

local instance
function M.Close()
    if instance then
        instance:OnBackClick()
    end
end

function M:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function M:MakeLister()
    self.lister = {}
    self.lister["ExitScene"] = basefunc.handler(self, self.onExitScene)
end

function M:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function M:ctor(IsMatch)

	ExtPanel.ExtMsg(self)

    instance = self
    self.parent = GameObject.Find("Canvas/LayerLv4")
    self.UIEntity = newObject(M.name, self.parent.transform)
    self.transform = self.UIEntity.transform
    self.gameObject = self.UIEntity
    self.IsMatch=IsMatch
    LuaHelper.GeneratingVar(self.UIEntity.transform, self)
    self:MakeLister()
    self:AddMsgListener()

    self.close_btn.onClick:AddListener(function()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
        self:OnBackClick()
    end)
    self:InitUI()
    DOTweenManager.OpenPopupUIAnim(self.transform)
end

function M:MyExit()
    instance = nil
    self:RemoveListener()

	destroy(self.gameObject)
end
function M:onExitScene()
    self:MyExit()
end

function M:InitUI()
    dump(fish_map_config, "<color=yellow>百科配置</color>")
    if  self.IsMatch~= nil and self.IsMatch == true then 
        self:InitFishAllMap(fish_map_config.config_match)
    else 
        self:InitFishAllMap(fish_map_config.config)
    end 
end

function M:InitFishAllMap(cfg)
    if not cfg then return end
    table.sort(cfg, function(a, b)
        return a.order < b.order
    end )
    for i,v in ipairs(cfg) do
        self:InitFishMap(v)
    end
end

function M:InitFishMap(data)
    if not data then return end
    local fish_item = FishBKItem.Create(self["content" .. data.tag], data, nil, self)
    return fish_item
end

function M:OnBackClick()
    self:MyExit()
end