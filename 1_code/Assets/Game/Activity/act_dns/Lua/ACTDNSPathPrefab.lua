-- 创建时间:2021-05-17
-- Panel:ACTDNSPathPrefab
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

ACTDNSPathPrefab = basefunc.class()
local C = ACTDNSPathPrefab
C.name = "ACTDNSPathPrefab"
local M = ACTDNSManager

function C.Create(parent, i, data)
	return C.New(parent, i, data)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["ExitScene"]=basefunc.handler(self,self.MyExit)
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

function C:MyClose()
	self:MyExit()
end

function C:ctor(parent, i, data)
	self.index = i
	self.data = data
	self.parent = parent
	self.style_type = self.data.style[1]

	local obj
	if self.style_type == 1 then
		obj = newObject("pre_dns_begin", parent)
	elseif self.style_type == 2 then
		obj = newObject("pre_dns_floor", parent)
	elseif self.style_type == 3 then
		obj = newObject("pre_dns_jc", parent)
	else
		obj = newObject("pre_dns_floor", parent)
	end
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	self:MyRefresh()
end

function C:MyRefresh()
	if self.style_type == 1 then
		
	elseif self.style_type == 2 then
		self.icon_img.sprite = GetTexture(self.data.style[2])
		if self.data.style[4] == "shop_gold_sum" then
			self.award_txt.text = "x" .. StringHelper.ToCash(self.data.style[3]/100)
		else
			self.award_txt.text = "x" .. StringHelper.ToCash(self.data.style[3])
		end
	elseif self.style_type == 3 then
		self.jc_txt.text = StringHelper.ToCash(self.data.style[3])
		self.jc_tip_txt.text = StringHelper.ToCash(self.data.style[3])
		self.isTipShow = false
		self.jc_btn.onClick:AddListener(function()
			self.jc_tip.gameObject:SetActive(not self.isTipShow)
			self.isTipShow = not self.isTipShow	
		end)
	else
		self.award_node.gameObject:SetActive(false)
	end
end

function C:SetSelect(b)
	if self.style_type == 1 then
		
	elseif self.style_type == 2 then
		--self.DBObj.gameObject:SetActive(not b)
		--self.XZObj.gameObject:SetActive(b)
		self.award_node.gameObject:SetActive(not b)
	elseif self.style_type == 3 then
		self.award_node.gameObject:SetActive(not b)
	else

	end
end
function C:GetPos()
	return self.parent.transform.localPosition
end

function C:GetImg()
	return self.data.style[2]
end

function C:GetTxt()
	if self.data.style[4] == "shop_gold_sum" then
		return "x" .. StringHelper.ToCash(self.data.style[3]/100)
	else
		return "x" .. StringHelper.ToCash(self.data.style[3])
	end
end

function C:GetValue()
	return self.data.style[3]
end

function C:GetKey()
	return self.data.style[4]
end