-- 创建时间:2018-07-31
local basefunc = require "Game.Common.basefunc"

BannerPrefab = basefunc.class()
BannerPrefab.name = "BannerPrefab"

local instance
function BannerPrefab.Bind()
	instance=BannerPrefab.New()
    local _in=instance
    instance=nil
    return _in
end
function BannerPrefab:Awake()
	local tran = self.transform
	self.image = tran:Find("Image"):GetComponent("Image")
	EventTriggerListener.Get(tran.gameObject).onClick = basefunc.handler(self, self.OnClick)
end
function BannerPrefab:Start()
end
function BannerPrefab:ScrollCellIndex(idx)
end
function BannerPrefab:OnClick()
	GameManager.GotoUI({gotoui = "sys_banner",goto_scene_parm="panel_show",id = 1})
end
