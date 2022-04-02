-- 创建时间:2020-05-06
-- Panel:Act_044_YDLWItemBase
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

Act_044_YDLWItemBase = basefunc.class()
local C = Act_044_YDLWItemBase
C.name = "Act_044_YDLWItemBase"
local M = Act_044_YDLWManager
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
	self.lister["ydlw_sw_kfPanel_msg"] = basefunc.handler(self,self.on_ydlw_sw_kfPanel_msg)
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
	if self.is_tip_showing then
		GameTipsPrefab.Hide()
		self.is_tip_showing = false
	end
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
	self.is_tip_showing = false
	LuaHelper.GeneratingVar(self.transform, self)
	
	self.item_ani = self.yellow1_btn.transform:GetComponent("Animator")
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	EventTriggerListener.Get(self.yellow1_btn.gameObject).onClick = basefunc.handler(self, self.on_enough_BuyClick)
	EventTriggerListener.Get(self.blue_btn.gameObject).onClick = basefunc.handler(self, self.on_not_enough_BuyClick)
	--EventTriggerListener.Get(self.tips_btn.gameObject).onClick = basefunc.handler(self,self.on_tips)

	PointerEventListener.Get(self.tips_btn.gameObject).onDown = function ()
		self.is_tip_showing = true
		self:ViewTipObj()
		--GameTipsPrefab.ShowDesc(self.data.tips, UnityEngine.Input.mousePosition)
	end
	PointerEventListener.Get(self.tips_btn.gameObject).onUp = function ()
		self.is_tip_showing = false
		self:HideTipObj()
		--GameTipsPrefab.Hide()
	end

	self.gift_image_img.sprite = GetTexture(self.data.award_image)
	self.gift_image_img:SetNativeSize()
	self.title_txt.text = self.data.award_name
	self.item_cost_text_txt.text = "  "..self.data.item_cost_text
	self.blue_txt.text = "前往"
	self.yellow_txt.text = "兑换"
	-- if self.data.limit_num ~= 0 then
	-- 	self.xianliang_img.sprite=GetTexture(M.GetLimitIcon(self.data.limit_num))
	-- else
	-- 	self.xianliang_img.gameObject:SetActive(false)
	-- end
	self.remain_txt.text = self.data.limit_num == -1 and "无限" or "剩"..self.data.limit_num
	self.xianliang_img.gameObject:SetActive(false)
	if M.GetItemCount() < tonumber(self.data.item_cost_text) then--道具不足
		if self.data.limit_num > 0 or self.data.limit_num == -1 then--有剩余次数
			self.gray_img.gameObject:SetActive(false)
			self.yellow1_btn.gameObject:SetActive(false)
			self.blue_btn.gameObject:SetActive(true)
		else--没有剩余次数
			self.gray_img.gameObject:SetActive(true)
			self.yellow1_btn.gameObject:SetActive(false)
			self.blue_btn.gameObject:SetActive(false)		
		end
	else--道具足
		if self.data.limit_num > 0 or self.data.limit_num == -1 then
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
	if not self.data.tips_tit then
		self.tips_btn.gameObject:SetActive(false)
	end

	--self.award_txt.text = self.data.award_text
end

function C:MyRefresh()

end

function C:on_enough_BuyClick()
	if os.time() >= PlayerPrefs.GetInt(MainModel.UserInfo.user_id.."ydlw") then
		Event.Brocast("ydlw_toggle_set_true_msg")
		HintPanel.Create(2,"是否兑换"..self.data.award_name,function ()
			Event.Brocast("ydlw_toggle_set_false_msg")
			Network.SendRequest("activity_exchange",{ type = M.type , id = self.data.ID })
			--[[if self.data.type == M.type then
				local string1
				string1="奖品:"..self.data.award_name.."，请联系客服领取奖励\n客服QQ：%s"				
				HintCopyPanel.Create({desc=string1, isQQ=true})
			end--]]
		end
		,function ()
		 	Event.Brocast("ydlw_toggle_tag_close_msg")
		end)
	else
		Network.SendRequest("activity_exchange",{ type = M.type , id = self.data.ID })
	end
end

function C:on_not_enough_BuyClick()
	GameManager.GotoUI({gotoui="game_FishingHall"})
end

function C:on_ydlw_sw_kfPanel_msg(id)
	if id == self.data.ID then
		if self.data.type == 1 then
			local real = {}
			real.text = M.config.Info[self.data.ID].award_name
			real.image = M.config.Info[self.data.ID].award_image
			RealAwardPanel.Create(real)
		end
	end
end

function C:ViewTipObj()
	dump(self.data.tips_tit ,"---------------------")
	if not self.data.tips_tit then return end
	
	self.tip.gameObject:SetActive(true)
	local parent =  GameObject.Find("Canvas/LayerLv5").transform
	self.tip.transform:SetParent(parent)

	self.tips_tit_txt.text = self.data.tips_tit
	self.tips_desc_txt.text = self.data.tips_desc
end

function C:HideTipObj()
	if not self.data.tips_tit then return end
	self.tip.transform:SetParent(self.transform)
	self.tip.gameObject:SetActive(false)
end

