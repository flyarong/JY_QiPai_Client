-- 创建时间:2020-07-30
-- Panel:Act_023_DDZFBKPrefab
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
 -- 取消按钮音效
 -- ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
 -- 确认按钮音效
 -- ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
 --]]

local basefunc = require "Game/Common/basefunc"

Act_023_DDZFBKPrefab = basefunc.class()
local C = Act_023_DDZFBKPrefab
C.name = "Act_023_DDZFBKPrefab"

function C.Create(parent,ddzclearpanel)
	return C.New(parent,ddzclearpanel)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
	self.lister = {}
	self.lister["ExitScene"] = basefunc.handler(self, self.ExitScene)
	self.lister["AssetChange"] = basefunc.handler(self, self.OnAssetChange)
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

function C:ctor(parent,ddzclearpanel)
	ExtPanel.ExtMsg(self)
	local parent = parent or GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	self.ddzClearPanel = ddzclearpanel	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	self.shop_btn.gameObject:SetActive(true)
	self.afterbuy.gameObject:SetActive(false)
	self.shop_btn.onClick:AddListener(
		function ()
			dump(self.ddzClearPanel,"<color=red>PPPPPPPPPPPPPPPPPPPPPPPPPPPPP</color>")
			ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
			self:OpenPanel()
		end
	)
	self:MyRefresh()
	if tonumber(self.ddzClearPanel.self_loose_score_txt.text) then
		self.score_txt.text = 2 * tonumber(self.ddzClearPanel.self_loose_score_txt.text)
	end
end

function C:MyRefresh()

end

function C:OnAssetChange(data)
	dump()
	if data and data.change_type == "freestyle_fanbeika_award" and IsEquals(self.gameObject) then
		self.gameObject:SetActive(true)
		self.shop_btn.gameObject:SetActive(false)
		self.afterbuy.gameObject:SetActive(true)
		self.ddzClearPanel.self_loose_score_txt.transform.localScale = Vector2.New(0.8,0.8)
		--Event.Brocast("AssetGet", data)
	end
end

function C:OpenPanel()
	local b = Act_023_DDZFBKLBPanel.Create()
	local now = tonumber(self.ddzClearPanel.self_loose_score_txt.text)
	if now then
		b:SetText(now,2*now)
		self.ddzClearPanel.self_BPF_btn.transform.localPosition = Vector2.New(817.3,0)
	end
end

function C:ExitScene()
	self:MyExit()
end