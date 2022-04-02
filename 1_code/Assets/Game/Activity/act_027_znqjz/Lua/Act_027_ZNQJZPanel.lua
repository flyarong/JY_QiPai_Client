-- 创建时间:2020-08-18
-- Panel:Act_027_ZNQJZPanel
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

Act_027_ZNQJZPanel = basefunc.class()
local C = Act_027_ZNQJZPanel
C.name = "Act_027_ZNQJZPanel"
local M = Act_027_ZNQJZManager
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
	self.lister["box_exchange_response"] = basefunc.handler(self,self.on_box_exchange_response)
	self.lister["AssetChange"] = basefunc.handler(self,self.OnAssetChange)
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
	local parent = parent or  GameObject.Find("Canvas/GUIRoot").transform
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
	self.go_btn.onClick:AddListener(
		function()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
			GameManager.CommonGotoScence({gotoui="game_Free"})
		end
	)
	self.duihuan_btn.onClick:AddListener(
		function()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
			if M.IsUseWan() then
				HintPanel.Create(2,"是否使用万能字？",function()
					Network.SendRequest("box_exchange",{id = 59,num = 1})
				end)
			else
				Network.SendRequest("box_exchange",{id = 59,num = 1})
			end
			
		end
	)
	self.buy_btn.onClick:AddListener(
		function()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
			Act_027_ZNQJZLBPanel.Create()
		end
	)
	PointerEventListener.Get(self["wan"].gameObject).onDown = function ()
		GameTipsPrefab.ShowDesc("万能字可替代任意字，兑换时自动使用", UnityEngine.Input.mousePosition)
	end
	PointerEventListener.Get(self["wan"].gameObject).onUp = function ()
		GameTipsPrefab.Hide()
	end
	self:RefreshNum()
	self:MyRefresh()
end

function C:MyRefresh()
	self:RefreshBtn()
end

function C:RefreshNum()
	for i = 1,#M.item_keys do
		self["t"..i.."_txt"].text = GameItemModel.GetItemCount(M.item_keys[i])
	end
end

function C:OnAssetChange(data)
	dump(data,"<color=red>获得得奖励</color>")
	if data and data.change_type == "box_exchange_active_award_59" and next(data.data) then
		Event.Brocast("AssetGet",data)
	end
	self:RefreshBtn()
	self:RefreshNum()
end

function C:on_box_exchange_response(_,data)
	dump(data,"<color=red>开宝箱返回</color>")
end

function C:RefreshBtn()
	if M.IsCanGetAward() then
		self.mask.gameObject:SetActive(false)
	else
		self.mask.gameObject:SetActive(true)
	end
end

function C:OnDestroy()
	self:MyExit()
end