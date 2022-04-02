-- 创建时间:2019-01-23

local basefunc = require "Game.Common.basefunc"

GameExitHintPanel = basefunc.class()

local C = GameExitHintPanel

function C.Create(title, desc, leftcall, rightcall)
    return C.New(title, desc, leftcall, rightcall)
end
function C:ctor(title, desc, leftcall, rightcall)

	ExtPanel.ExtMsg(self)

    self.parent = GameObject.Find("Canvas/LayerLv5")
    self.gameObject = newObject("GameExitHintPanel", self.parent.transform)
    self.transform = self.gameObject.transform

    LuaHelper.GeneratingVar(self.transform, self)
    DOTweenManager.OpenPopupUIAnim(self.UINode.transform)
    self.title = title
    self.desc = desc
    self.leftcall = leftcall
    self.rightcall = rightcall

    self.yes_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        if self.leftcall then
            self.leftcall()
        end
        self:MyExit()
    end)
    self.no_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        if self.rightcall then
            self.rightcall()
        end
        self:MyExit()
    end)

    self:InitUI()
end

function C:InitUI()
	self.title_txt.text = self.title
	self.hint_txt.text = self.desc
end

function C:MyExit()
    destroy(self.gameObject)
end
