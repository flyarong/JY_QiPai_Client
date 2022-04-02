-- 创建时间:2020-12-31
-- Panel:Template_NAME
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

Act_050_YXTJBagPanel = basefunc.class()
local C = Act_050_YXTJBagPanel
C.name = "Act_050_YXTJBagPanel"
local M = Act_050_YXTJManager
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
	self.lister["box_all_exchange_response"] = basefunc.handler(self,self.on_box_all_exchange_response)
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

function C:ctor()
	ExtPanel.ExtMsg(self)
	local parent = GameObject.Find("Canvas/LayerLv5").transform
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
	local all_num = 0
	for i = 1,#M.config.books do
		local num = GameItemModel.GetItemCount(M.config.books[i].item_key)
		all_num = all_num + num
		if num > 0 then
			local b = GameObject.Instantiate(self.item,self.Content)
			b.gameObject:SetActive(true)
			local temp = {}
			LuaHelper.GeneratingVar(b.transform,temp)
			temp.item_txt.text = "x"..num
			temp.item_img.sprite = GetTexture(M.config.books[i].icon)
		end
	end
	self.all_num = all_num
	self.t1_txt.text = all_num
	self.t2_txt.text = all_num * 5000
	self.close_btn.onClick:AddListener(
		function()
			self:MyExit()
		end
	)
	self.go_btn.onClick:AddListener(function()
		HintPanel.Create(2,"确认全部兑换吗？",function()
			Network.SendRequest("box_all_exchange",{name = "yxtj_2_23" })
		end)
	end)
	self:MyRefresh()
end

function C:MyRefresh()
end

function C:on_box_all_exchange_response(_,data)
	if data.result == 0 then
		local data = {}
		data.data = {  
			[1] = {
				asset_type = "jing_bi",
				value = self.all_num * 5000
			}
		}
		self:MyExit()
		Event.Brocast("AssetGet", data)
	end
end