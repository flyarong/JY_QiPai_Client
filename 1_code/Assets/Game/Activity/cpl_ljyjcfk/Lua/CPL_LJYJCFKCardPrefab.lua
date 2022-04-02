-- 创建时间:2020-06-18
-- Panel:CPL_LJYJCFKCardPrefab
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

CPL_LJYJCFKCardPrefab = basefunc.class()
local C = CPL_LJYJCFKCardPrefab
C.name = "CPL_LJYJCFKCardPrefab"
local M = CPL_LJYJCFKManager
function C.Create(parent,index)
	return C.New(parent,index)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
	self.lister = {}
	self.lister["cpl_ljyjcfk_call_other_card"] = basefunc.handler(self,self.cpl_ljyjcfk_call_other_card)
	self.lister["CPL_LJYJCFK_info_get"] = basefunc.handler(self,self.CPL_LJYJCFK_info_get)
	self.lister["CPL_LJYJCFK_can_click"] = basefunc.handler(self,self.CPL_LJYJCFK_can_click)
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

function C:ctor(parent,index)
	ExtPanel.ExtMsg(self)
	local parent = parent
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	self.index = index
	self.is_click = false
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	self.click_btn.onClick:AddListener(
		function ()
			self:OnBtnClick()
		end
	)
	self:MyRefresh()
end

function C:MyRefresh()

end
--翻转动画
function C:FzAnim()
	self.seq = DoTweenSequence.Create()
	self.seq:Append(self.transform:DORotate(Vector3.New(0, -90.0, 0), 0.5, DG.Tweening.RotateMode.FastBeyond360))
	self.seq:AppendCallback(function ()
		self.bg.gameObject:SetActive(false)
		self.card.gameObject:SetActive(true)
	end)
	self.seq:Append(self.transform:DORotate(Vector3.New(0, -180.0, 0), 0.5))
	self.seq:AppendCallback(function ()
		if self.is_click then
			self:BdAnim()
		else
			print("已经翻转")
			Event.Brocast("CPL_LJYJCFK_can_quit")
		end
	end)
	
end
--变大动画
function C:BdAnim()
	self.seq = DoTweenSequence.Create()
	self.seq:Append(self.transform:DOScale(Vector3.New(1.43,1.43,1.43), 0.3))
	self.seq:AppendInterval(0.2)
	self.seq:AppendCallback(
		function ()
			if self.award_data then
				self.glow_01.gameObject:SetActive(self.is_click)
				if self.award_data.data[1].asset_type == "shop_gold_sum" then
					local pre = GameObject.Instantiate(GetPrefab("AssetsGet_hongbaoyu"),self.transform)
					pre.transform.localPosition = Vector2.New(226,-244)
				end
				ExtendSoundManager.PlaySound(audio_config.game.bgm_hall_huodewupin.audio_name)
				local t = 0
				local timer = Timer.New(function ()
					t = t + 1
					if t == 4 and self.award_data and self.award_data.data[1].asset_type == "shop_gold_sum" then
						if pre and IsEquals(pre.gameObject) then
							pre.gameObject:SetActive(false)
						end
					elseif t == 1 then
						Event.Brocast("cpl_ljyjcfk_call_other_card")
					end
				end,1,4,false)
				timer:Start()
			end
		end
	)
end

function C:SetAwardData()
	if not self.is_click then
		local data =  CPL_LJYJCFKGetAwardPanel.GetFakeAward()
		dump(data,"<color=red>其他奖励数据</color>")
		if data then
			self.award_img.sprite = GetTexture(self:GetImage(data[1]))
			self.award_txt.text = self:GetText(data[1],data[2])
		end
	else
		local type = self.award_data.data[1].asset_type
		local value = self.award_data.data[1].value

		self.award_img.sprite = GetTexture(self:GetImage(type))
		self.award_txt.text = self:GetText(type,value)
	end
end

function C:CPL_LJYJCFK_info_get(data)
	if not IsEquals(self.gameObject) then return end
	dump(data,"<color=red>奖励数据---</color>")
	if self.is_click then
		self.award_data = data.award_data
		self:SetAwardData()
		if self.is_click then
			self:FzAnim()
		end
	else
		self:SetAwardData()
	end
end

function C:OnBtnClick()
	if self.can_click then
		Network.SendRequest("get_task_award_new",{id = M.task_id,award_progress_lv = self.index})
		self.is_click = true
		Event.Brocast("CPL_LJYJCFK_can_click",{can_click = false})
	end
end

function C:GetImage(type)
	if type == "jing_bi" then
		return "com_award_icon_jingbi"
	elseif type == "shop_gold_sum" then
		return  "com_award_icon_money"
	end
end

function C:GetText(type,value)
	if type == "jing_bi" then
		return "鲸币 x"..value
	elseif type == "shop_gold_sum" then
		return  "福卡 x"..(value / 100)
	end
end

function C:cpl_ljyjcfk_call_other_card()
	if not self.is_click then
		self:FzAnim()
	end
end

function C:CPL_LJYJCFK_can_click(data)
	self.can_click = data.can_click
end