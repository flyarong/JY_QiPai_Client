-- 创建时间:2021-01-04
-- Panel:Act_Ty_Collect_WordsGiftPanel
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

Act_Ty_Collect_WordsGiftPanel = basefunc.class()
local C = Act_Ty_Collect_WordsGiftPanel
C.name = "Act_Ty_Collect_WordsGiftPanel"
local M = Act_Ty_Collect_WordsManager

function C.Create(parent,config)
	return C.New(parent,config)
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

function C:ctor(parent,config)
	self.config = config
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
	EventTriggerListener.Get(self.buy_btn.gameObject).onClick = basefunc.handler(self, self.OnBuyClick)
	self.title_txt.text = self.config.gift_name
	self.buybtn_txt.text = self.config.gift_price .. "元购买"
	self.buyimg_txt.text = "明日再来"
	self.limit_txt.text = self.config.xg_txt
	self:CreateAwardPrefab()
	self:CheckButton()
	self:MyRefresh()
end

function C:MyRefresh()
end

function C:CreateAwardPrefab()
	for i=1, #self.config.award_txt do
		self["award"..i].gameObject:SetActive(true)
		self["award"..i.."_img"].sprite = GetTexture(self.config.award_img[i])
		self["award"..i.."_txt"].text = self.config.award_txt[i]

		local ts = self.config.award_tip[i] ~= ""
		self["tip"..i.."_txt"].text = self.config.award_tip[i]
		self["tips"..i.."_btn"].gameObject:SetActive(ts)
		if ts then--是否提示
			EventTriggerListener.Get(self["tips"..i.."_btn"].gameObject).onDown = function ()
				self["tip"..i].gameObject:SetActive(true)
			end
			EventTriggerListener.Get(self["tips"..i.."_btn"].gameObject).onUp = function ()
				self["tip"..i].gameObject:SetActive(false)
			end
		end
	end
end


function C:CheckButton()
	if MainModel.IsCanBuyGiftByID(self.config.gift_id) then
		self.buy_btn.gameObject:SetActive(true)
		self.buy_img.gameObject:SetActive(false)
	else
		self.buy_btn.gameObject:SetActive(false)
		self.buy_img.gameObject:SetActive(true)
	end
end

function C:OnBuyClick()
	M.BuyGift(self.config.gift_id)
end