-- 创建时间:2020-05-06
-- Panel:Act_012_LMLHItemBase
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

Act_016_LXDHItemBase = basefunc.class()
local C = Act_016_LXDHItemBase
C.name = "Act_016_LXDHItemBase"
local M = Act_016_LXDHManager
function C.Create(parent,data)
	return C.New(parent,data)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["ExitScene"] = basefunc.handler(self,self.MyExit)
    self.lister["LXDH_sw_kfPanel_msg"] = basefunc.handler(self,self.on_LXDH_sw_kfPanel_msg)
end

function C:OnDestroy()
	self:MyExit()
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

function C:ctor(parent,data)
	self.data = data
	local parent = parent or GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self.item_ani = self.blue1_btn.transform:GetComponent("Animator")
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	EventTriggerListener.Get(self.blue1_btn.gameObject).onClick = basefunc.handler(self, self.on_enough_BuyClick)
	EventTriggerListener.Get(self.yellow_btn.gameObject).onClick = basefunc.handler(self, self.on_not_enough_BuyClick)
	EventTriggerListener.Get(self.tips_btn.gameObject).onClick = basefunc.handler(self,self.on_tips)

	self.gift_image_img.sprite = GetTexture(self.data.award_image)
	self.gift_image_img:SetNativeSize()
	self.title_txt.text = self.data.award_name
	self.item_cost_text_txt.text = "  "..self.data.item_cost_text
	self.blue_txt.text = "兑换"
	self.yellow_txt.text = "兑换"

	if M.GetItemCount() < tonumber(self.data.item_cost_text) then--道具不足
		if self.data.remain_time > 0 or self.data.remain_time == -1 then--有剩余次数
			self.gray_img.gameObject:SetActive(false)
			self.blue1_btn.gameObject:SetActive(false)
			self.yellow_btn.gameObject:SetActive(true)
		else--没有剩余次数
			self.gray_img.gameObject:SetActive(true)
			self.blue1_btn.gameObject:SetActive(false)
			self.yellow_btn.gameObject:SetActive(false)		
		end
	else--道具足
		if self.data.remain_time > 0 or self.data.remain_time == -1 then
			self.gray_img.gameObject:SetActive(false)
			self.blue1_btn.gameObject:SetActive(true)
			self.item_ani:Play("blue1_ani",-1,0)
			self.yellow_btn.gameObject:SetActive(false)
		else--没有剩余次数
			self.gray_img.gameObject:SetActive(true)
			self.blue1_btn.gameObject:SetActive(false)
			self.yellow_btn.gameObject:SetActive(false)
		end
	end
	if not self.data.tips then
		self.tips_btn.gameObject:SetActive(false)
	end

	if self.data.ID == 4 then
		self.xianliang.gameObject:SetActive(false)
	end	
	self:MyRefresh()
end

function C:MyRefresh()
end



function C:on_enough_BuyClick()
	HintPanel.Create(2,"是否兑换"..self.data.award_name,function ()
		Network.SendRequest("activity_exchange",{ type = 1 , id = self.data.ID })
		--[[if self.data.type == 1 then
			local string1
			string1="奖品:"..self.data.award_name.."，请联系客服领取奖励\n客服QQ：%s"				
			HintCopyPanel.Create({desc=string1, isQQ=true})
		end--]]
	end)
end

function C:on_not_enough_BuyClick()
	HintPanel.Create(1, "龙虾兑换券不足")
end

function C:on_tips()
	if self.data.tips then
		if self.tips.gameObject.activeSelf then
			self.tips.gameObject:SetActive(false)
		else	
			self.tips.gameObject:SetActive(true)
			self.tips_txt.text = self.data.tips
		end
	end
end

function C:on_LXDH_sw_kfPanel_msg(id)
	dump(self.data,"<color>+++++++++++++self.data+++++++++++</color>")
	dump(id,"<color>+++++++++++++id+++++++++++</color>")
	if id == self.data.ID then
		if self.data.type == 1 then
			local string1
			string1="奖品:"..self.data.award_name.."，请联系客服领取奖励\n客服QQ：%s"				
			HintCopyPanel.Create({desc=string1, isQQ=true})
		end
	end
end