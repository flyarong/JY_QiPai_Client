-- 创建时间:2020-05-06
-- Panel:Act_031_WXHHLItemBase
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

Act_031_WXHHLItemBase = basefunc.class()
local C = Act_031_WXHHLItemBase
C.name = "Act_031_WXHHLItemBase"
local M = Act_031_WXHHLManager
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
	self.lister["xgdh_tips_msg"] = basefunc.handler(self,self.on_xgdh_tips_msg)
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
	
	self.item_ani = self.yellow1_btn.transform:GetComponent("Animator")
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	self.xianliang_img.gameObject.transform.localPosition = Vector2.New(-88.5,-3.6)
	self.xianliang_img.gameObject.transform.localScale = Vector2.New(0.70,0.70)
end

function C:InitUI()
	EventTriggerListener.Get(self.yellow1_btn.gameObject).onClick = basefunc.handler(self, self.on_enough_BuyClick)
	EventTriggerListener.Get(self.blue_btn.gameObject).onClick = basefunc.handler(self, self.on_not_enough_BuyClick)
	EventTriggerListener.Get(self.tips_btn.gameObject).onClick = basefunc.handler(self,self.on_tips)

	self.gift_image_img.sprite = GetTexture(self.data.award_image)
	self.gift_image_img:SetNativeSize()
	self.title_txt.text = self.data.award_name
	self.item_cost_text_txt.text = "  "..self.data.item_cost_text
	self.blue_txt.text = "前往"
	self.yellow_txt.text = "兑换"
	self.remain_txt.text = self.data.remain_time == -1 and "无限" or "剩"..self.data.remain_time
	if M.GetItemCount() < tonumber(self.data.item_cost_text) then--道具不足
		if self.data.remain_time > 0 or self.data.remain_time == -1 then--有剩余次数
			self.gray_img.gameObject:SetActive(false)
			self.yellow1_btn.gameObject:SetActive(false)
			self.blue_btn.gameObject:SetActive(true)
		else--没有剩余次数
			self.gray_img.gameObject:SetActive(true)
			self.yellow1_btn.gameObject:SetActive(false)
			self.blue_btn.gameObject:SetActive(false)		
		end
	else--道具足
		if self.data.remain_time > 0 or self.data.remain_time == -1 then
			self.gray_img.gameObject:SetActive(false)
			self.yellow1_btn.gameObject:SetActive(true)
			self.item_ani:Play("blue1_ani",-1,0)
			self.blue_btn.gameObject:SetActive(false)
		else--没有剩余次数
			self.gray_img.gameObject:SetActive(true)
			self.yellow1_btn.gameObject:SetActive(false)
			self.blue_btn.gameObject:SetActive(false)
		end
	end
	if not self.data.tips then
		self.tips_btn.gameObject:SetActive(false)
	end

	if self.data.ID == 4 or self.data.ID == 10 then
		--self.xianliang.gameObject:SetActive(false)
		self.xianliang_img.sprite = GetTexture("xghhl_icon_bxl")
	end	
	self:MyRefresh()
end

function C:MyRefresh()
end



function C:on_enough_BuyClick()
	if os.time() >= PlayerPrefs.GetInt(MainModel.UserInfo.user_id.."XGDH") then
		Event.Brocast("XGDH_toggle_set_true_msg")
		HintPanel.Create(2,"是否兑换"..self.data.award_name,function ()
			Event.Brocast("XGDH_toggle_set_false_msg")
			Network.SendRequest("activity_exchange",{ type = M.type , id = self.data.ID })
			--[[if self.data.type == M.type then
				local string1
				string1="奖品:"..self.data.award_name.."，请联系客服领取奖励\n客服QQ：%s"				
				HintCopyPanel.Create({desc=string1, isQQ=true})
			end--]]
		end,function ()
			Event.Brocast("XGDH_toggle_set_false_msg")
		end)
	else
		Network.SendRequest("activity_exchange",{ type = M.type , id = self.data.ID })
	end
end

function C:on_not_enough_BuyClick()
	GameManager.GotoUI({gotoui="game_MiniGame"})
end

function C:on_tips()
	if self.data.tips then
		if self.tips.gameObject.activeSelf then
			self.tips.gameObject:SetActive(false)
		else	
			self.tips.gameObject:SetActive(true)
			self.tips_txt.text = self.data.tips
			Event.Brocast("xgdh_tips_msg",self.data.ID)
		end
	end
end 

function C:on_LXDH_sw_kfPanel_msg(id)
	if id == self.data.ID then
		if self.data.type == 1 then
			local string1
			string1="奖品:"..self.data.award_name.."，请联系客服领取奖励\n客服QQ：%s"				
			HintCopyPanel.Create({desc=string1, isQQ=true})
		end
	end
end

function C:on_xgdh_tips_msg(id)
	if id == self.data.ID then
		return
	else
		if self.data.tips then
			self.tips.gameObject:SetActive(false)
		end
	end
end