-- 创建时间:2020-01-06
-- Panel:sys_cfzx_btn_qys_EnterPrefab
--[[
 *      ┌─┐       ┌─┐
 *   ┌──┘ ┴───────┘ ┴──┐
 *   │                 │
 *   │       ───       │
 *   │  ─┬┘       └┬─  │
 *   │                 │
 *   │       ─┴─       │
 *   │                 │
 *   └───┐         ┌───┘
 *       │         │
 *       │         │
 *       │         │
 *       │         └──────────────┐
 *       │                        │
 *       │                        ├─┐
 *       │                        ┌─┘
 *       │                        │
 *       └─┐  ┐  ┌───────┬──┐  ┌──┘
 *         │ ─┤ ─┤       │ ─┤ ─┤
 *         └──┴──┘       └──┴──┘
 *                神兽保佑
 *               代码无BUG!
 --]]

local basefunc = require "Game/Common/basefunc"

sys_cfzx_btn_qys_EnterPrefab = basefunc.class()
local C = sys_cfzx_btn_qys_EnterPrefab
C.name = "sys_cfzx_btn_qys_EnterPrefab"

function C.Create(parent)
	return C.New(parent)
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

function C:MyExit()
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:ctor(parent)
	local parent = parent or GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	self.Button = self.transform:GetComponent("Button")
	self.Button.onClick:AddListener(
		function ()
			local hint_panel = HintPanel.Create(6,"邀请新好友打千元赛，好友进前<color=#ED8813>96</color>名\n您得<color=#ED8813>5元/人</color>，上不封顶！",function(  )
				--查看详情
				ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
				Event.Brocast("open_game_money_center")
			end,function(  )
				--邀请好友
				ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
				GameManager.GotoUI({gotoui = "share_hall"})
				ShareImage.fix_img_id = 1
			end)
			if IsEquals(hint_panel.confirm_txt) then
				hint_panel.confirm_txt.text = "邀请好友"
			end
			if IsEquals(hint_panel.close_txt) then
				hint_panel.close_txt.text = "查看详情"
			end
		end
	)
	self:MyRefresh()
end

function C:MyRefresh()
end


function C:OnDestroy()
	self:MyExit()
end