-- 创建时间:2020-10-26
-- Panel:New Lua
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

EliminateCJItem = basefunc.class()
local C = EliminateCJItem
C.name = "EliminateCJItem"

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
	ExtPanel.ExtMsg(self)
	local parent = parent or GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	self.free_normal_anim = self.transform:GetComponent("Animator")
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	self.curr_item = 1
end

function C:InitUI()
	self:MyRefresh()
end

function C:MyRefresh()

end

function C:Blink(time)
	local seq = DoTweenSequence.Create({dotweenLayerKey = C.name})
	self.blink_nornal.gameObject:SetActive(true)
	seq:AppendInterval(time or 0.6)
	seq:AppendCallback(
		function ()
			self.blink_nornal.gameObject:SetActive(false)
		end
	)

	if self.curr_item == 11 then
		self:ShowNormalEffect()
	end
end

function C:HideAllAffect()
	DOTweenManager.KillLayerKeyTween(C.name)
	self.free_normal_anim.enabled = false
	self.blink_nornal.gameObject:SetActive(false)
	self.free_wait.gameObject:SetActive(false)
	self.free_boom.gameObject:SetActive(false)
	Event.Brocast("wait_for_free_onoff",0)
	self.main_img.color = Color.New(1,1,1,1)
end


function C:ChangeItem(index)
	self.curr_item = index
	self.main_img.sprite = EliminateCJItemManager.item_obj["xxl_icon_"..index]
end

function C:ShowWaitEffect(onoff)
	self.free_wait.gameObject:SetActive(onoff == true)
end

function C:ShowNormalEffect()
	local seq = DoTweenSequence.Create({dotweenLayerKey = C.name})
	seq:Append(self.transform:DOScale(Vector3.New(1.25,1.25,0.4), 0.3))
	seq:Append(self.transform:DOScale(Vector3.New(1,1,0.4), 0.3))
	seq:AppendCallback(
		function ()
			if call then
				call()
			end
		end
	)
end

function C:HideAndBlink()
	local seq2 = DoTweenSequence.Create({dotweenLayerKey = C.name})
	seq2:Append(self.main_img:DOFade(0,0.2))
	seq2:Append(self.main_img:DOFade(1,0.2))
	seq2:Append(self.main_img:DOFade(0,0.2))
	seq2:Append(self.main_img:DOFade(1,0.2))
	-- seq2:AppendCallback(
	-- 	function ()
	-- 		self.main_img.gameObject:SetActive(false)
	-- 	end
	-- )
	-- seq2:AppendInterval(0.2)
	-- seq2:AppendCallback(
	-- 	function ()
	-- 		self.main_img.gameObject:SetActive(true)
	-- 	end
	-- )
end

function C:ShowBoomEffect(onoff)
	self.free_boom.gameObject:SetActive(onoff == true)
end

function C:SetIndex(index)
	self.index = index
end

function C:GetIndex()
	return self.index
end
