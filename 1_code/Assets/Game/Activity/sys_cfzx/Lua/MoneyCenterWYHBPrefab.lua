-- 创建时间:2018-12-20

local basefunc = require "Game.Common.basefunc"

MoneyCenterWYHBPrefab = basefunc.class()

local C = MoneyCenterWYHBPrefab

C.name = "MoneyCenterWYHBPrefab"


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

function C:OnDestroy()
	GameObject.Destroy(self.gameObject)
	self:MyExit()
end

function C:MyExit()
	self:RemoveListener()
end

function C:ctor(parent_transform, config, call, panelSelf)
	self.config = config
	self.call = call
	self.panelSelf = panelSelf
	local obj = newObject(C.name, parent_transform)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj

	self:MakeLister()
	self:AddMsgListener()
    LuaHelper.GeneratingVar(self.transform, self)

    self.BG_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
        self:OnClick()
    end)

    self:InitUI()
end

function C:InitUI()
	self.icon_img.sprite = GetTexture(self.config.icon)
	self.desc_txt.text = self.config.desc
end

function C:MyRefresh()
end

function C:OnClick()
    if self.config.goto_ui then
        local goto_pos = self.config.goto_ui[1]
        local goto_parm  = self.config.goto_ui[2]
        if goto_pos == "free_hall" then
            local game_type = GameFreeModel.GetRapidBeginGameType()
            dump(game_type, "<color=green>game_type:</color>")
            goto_parm = game_type
            GameManager.GotoUI({gotoui=goto_pos, goto_scene_parm=game_type})
        else
            GameManager.GotoUI({gotoui=goto_pos, goto_scene_parm=goto_parm})
        end
    end
end

