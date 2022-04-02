-- 创建时间:2020-03-05
local basefunc = require "Game.Common.basefunc"

Fishing3DBKPanel = basefunc.class()
local C = Fishing3DBKPanel
C.name = "Fishing3DBKPanel"
require "Game.normal_fishing3d_common.Lua.Fishing3DBKItem"
require "Game.normal_fishing3d_common.Lua.Fishing3DBKTipsPanel"

local fish_map_config =HotUpdateConfig("Game.normal_fishing3d_common.Lua.fish3d_map_config")

local tag_list = {
	[1] = {
		tag = 3,
		name = "活动鱼",
	},
	[2] = {
		tag = 2,
		name = "彩金鱼",
	},
	[3] = {
		tag = 1,
		name = "普通鱼",
	},
}
function C.Create()
	return C.New()
end
function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["ExitScene"] = basefunc.handler(self, self.onExitScene)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:ctor()

	ExtPanel.ExtMsg(self)

    local parent = GameObject.Find("Canvas/LayerLv4")
    local obj = newObject(C.name, parent.transform)
    self.transform = obj.transform
    self.gameObject = obj.gameObject
    LuaHelper.GeneratingVar(self.transform, self)
    self:MakeLister()
    self:AddMsgListener()

    self.back_btn.onClick:AddListener(function()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
        self:OnBackClick()
    end)
    self.by3d_bk_fgx_prefab = GetPrefab("by3d_bk_fgx_prefab")
    self.by3d_bk_yu_group_prefab = GetPrefab("by3d_bk_yu_group_prefab")
    self.by3d_bk_yu_prefab = GetPrefab("by3d_bk_yu_prefab")
    self:InitUI()
end

function C:MyExit()
    self:RemoveListener()
end
function C:onExitScene()
    self:MyExit()
end

function C:InitUI()
    self:InitFishAllMap(fish_map_config.config)

    self:CloseCell()
    for k,v in ipairs(tag_list) do
    	local cfg = self.bk_config_map[v.tag]
    	if cfg and #cfg > 0 then
	    	local fgx_obj = GameObject.Instantiate(self.by3d_bk_fgx_prefab, self.content)
	    	local fgx_ui = {}
	    	LuaHelper.GeneratingVar(self.transform, fgx_ui)
	    	fgx_ui.name_txt.text = v.name

	    	local group_obj = GameObject.Instantiate(self.by3d_bk_yu_group_prefab, self.content)
	    	group_obj.gameObject.name = v.tag
	    	local pp_tran = group_obj.transform
	    	for kk, vv in ipairs(cfg) do
	    		Fishing3DBKItem.Create(pp_tran, vv, self.OnEnterClick, self)
	    	end
    	end
    end
end
function C:CloseCell()
	if self.CellList then
		for k,v in ipairs(self.CellList) do
			v:OnDestroy()
		end
	end
	self.CellList = {}
end

function C:InitFishAllMap(cfg)
    if not cfg then return end
    table.sort(cfg, function(a, b)
        return a.order < b.order
    end)
    self.bk_config_map = {}

    for i,v in ipairs(cfg) do
    	self.bk_config_map[v.tag] = self.bk_config_map[v.tag] or {}
    	self.bk_config_map[v.tag][#self.bk_config_map[v.tag] + 1] = v
    end
end

function C:OnBackClick()
    self:MyExit()
    destroy(self.gameObject)
end

function C:OnEnterClick(cfg)
	if cfg then
		Fishing3DBKTipsPanel.Create(cfg)
	end
end
