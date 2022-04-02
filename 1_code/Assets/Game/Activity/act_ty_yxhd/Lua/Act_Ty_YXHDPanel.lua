-- 创建时间:2021-01-25
-- Panel:Act_Ty_YXHDPanel
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

Act_Ty_YXHDPanel = basefunc.class()
local C = Act_Ty_YXHDPanel
C.name = "Act_Ty_YXHDPanel"
local M = Act_Ty_YXHDManager
function C.Create(parent)
	return C.New(parent)
end
local str 
function C:AddMsgListener()
	for proto_name,func in pairs(self.lister) do
		Event.AddListener(proto_name, func)
	end
end

function C:MakeLister()
	self.lister = {}
	self.lister["new_game_gift_get_cdk_response"] = basefunc.handler(self,self.on_new_game_gift_get_cdk_response)
	self.lister["AssetChange"] = basefunc.handler(self,self.MyRefresh)
	self.lister["new_game_gift_query_cdk_changed"] = basefunc.handler(self,self.new_game_gift_query_cdk_changed)
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

function C:OnDestroy()
	self:MyExit()
end

function C:OnDestroy()
	self:MyExit()
end

function C:MyClose()
	self:MyExit()
end

function C:ctor(parent)
	ExtPanel.ExtMsg(self)
	local parent = parent or GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	str = GameItemModel.GetItemToKey(M.curr_config.use_item).name
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	CommonTimeManager.GetCutDownTimer(M.curr_config.end_time,self.cut_down_txt)
	self.cdk_txt.text = M.cdk
	self.main1_img.sprite = GetTexture(Act_Ty_YXHDManager.curr_config.bg_1)
	self.main2_img.sprite = GetTexture(Act_Ty_YXHDManager.curr_config.bg_2)
	self.prop_txt.text = StringHelper.ToCash(GameItemModel.GetItemCount(M.curr_config.use_item)) 
	Network.SendRequest("new_game_gift_query_cdk")
end

function C:InitUI()
	self.exchange_btn.onClick:AddListener(
		function()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
			if GameItemModel.GetItemCount(M.curr_config.use_item) >= M.curr_config.use_num then
				Network.SendRequest("new_game_gift_get_cdk")
			else
				LittleTips.Create(str.."不足~")
			end
		end
	)
	self.copy_btn.onClick:AddListener(
		function()
			LittleTips.Create("已复制礼包码")
			UniClipboard.SetText(M.cdk)
		end
	)
	self.down_btn.onClick:AddListener(
		function()
			if gameRuntimePlatform ~= "Ios" then
				UnityEngine.Application.OpenURL(Act_Ty_YXHDManager.curr_config.andriod_download_url)
			else
				UnityEngine.Application.OpenURL(Act_Ty_YXHDManager.curr_config.ios_download_url)
			end
		end
	)
	self:MyRefresh()
end

function C:MyRefresh()
	self:RefreshNode()
end

function C:new_game_gift_query_cdk_changed()
	self:RefreshNode()
end

function C:RefreshNode()
	if M.cdk then
		self["1_node"].gameObject:SetActive(false)
		self["2_node"].gameObject:SetActive(true)
	else
		self["1_node"].gameObject:SetActive(true)
		self["2_node"].gameObject:SetActive(false)
	end
	self.cdk_txt.text = M.cdk
	self.prop_txt.text = "x" .. StringHelper.ToCash(GameItemModel.GetItemCount(M.curr_config.use_item)) 
	self.item_d_img.sprite = GetTexture(GameItemModel.GetItemToKey(M.curr_config.use_item).image)
	self.item_x_img.sprite = GetTexture(GameItemModel.GetItemToKey(M.curr_config.use_item).image)
end

function C:on_new_game_gift_get_cdk_response(_,data)
	if data and data.result == 0 then
		Act_Ty_YXHDHintPanel.Create()
	end
end