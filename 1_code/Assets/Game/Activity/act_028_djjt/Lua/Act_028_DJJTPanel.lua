-- 创建时间:2020-08-21
-- Panel:Act_028_DJJTPanel
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

Act_028_DJJTPanel = basefunc.class()
local C = Act_028_DJJTPanel
C.name = "Act_028_DJJTPanel"
local M = Act_028_DJJTManager

local DESCRIBE_TEXT = {
	[1] = "1.新手场每对局5局，随机掉落1个图",
	[2] = "2.三星场每对局4局，随机掉落1个图",
	[3] = "3.四星场每对局3局，随机掉落1个图",
	[4] = "4.五星场每对局1局，随机掉落1个图",	
}

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
	self.lister["AssetChange"] = basefunc.handler(self,self.OnAssetChange)
	self.lister["box_exchange_response"] = basefunc.handler(self,self.on_box_exchange_response)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	if self.huxi then
		self.huxi.Stop()
	end
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
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	self.huxi = CommonHuxiAnim.Go(self.yes,1,1,1.2)
	self.huxi.Start()
end

function C:InitUI()
	self.duihuan_btn.onClick:AddListener(
		function()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
			if M.IsUseWan() then
				HintPanel.Create(2,"是否使用万能图？",function()
					Network.SendRequest("box_exchange",{id = 65,num = 1})
				end)
			else
				Network.SendRequest("box_exchange",{id = 65,num = 1})
			end
			
		end
	)
	self.buy_btn.onClick:AddListener(
		function()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
			Act_028_DJJTLBPanel.Create()
		end
	)
	self.help_btn.onClick:AddListener(
		function()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
			self:OpenHelpPanel()
		end
	)
	self.go_btn.onClick:AddListener(
		function()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
			GameManager.CommonGotoScence({gotoui="game_Free"},function()
				self:MyExit()
			end)
		end
	)
	self:MyRefresh()
end

function C:MyRefresh()
	if M.IsCanGetAward() then
		for i = 1,5 do
			if i < 5 then
				self["m"..i].gameObject:SetActive(true)
			end
			local num = GameItemModel.GetItemCount(M.item_keys[i])
			self["t"..i.."_txt"].text = "x"..num
		end
	else
		for i = 1,5 do
			local num = GameItemModel.GetItemCount(M.item_keys[i])
			self["t"..i.."_txt"].text = "x"..num
			if i < 5 then
				if num <= 0 then
					self["m"..i].gameObject:SetActive(false)
				else
					self["m"..i].gameObject:SetActive(true)
				end
			end
		end
	end

	self.duihuan_btn.gameObject:SetActive(M.IsCanGetAward())
	self.no.gameObject:SetActive(not M.IsCanGetAward())
	self.yes.gameObject:SetActive(M.IsCanGetAward())
end

function C:OnAssetChange(data)
	if data and data.change_type == "box_exchange_active_award_65" and next(data.data) then
		Event.Brocast("AssetGet",data)
	end
	self:MyRefresh()
end

function C:on_box_exchange_response(_,data)
	dump(data,"<color=red>开宝箱的返回</color>")
end

function C:OpenHelpPanel()
	local str = DESCRIBE_TEXT[1]
	for i = 2, #DESCRIBE_TEXT do
		str = str .. "\n" .. DESCRIBE_TEXT[i]
	end
	self.introduce_txt.text = str
	IllustratePanel.Create({ self.introduce_txt.gameObject }, GameObject.Find("Canvas/LayerLv5").transform)
end

function C:OnDestroy()
	self:MyExit()
end