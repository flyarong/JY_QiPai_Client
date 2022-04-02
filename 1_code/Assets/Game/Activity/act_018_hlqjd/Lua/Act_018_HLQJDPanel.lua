-- 创建时间:2020-06-16
-- Panel:Act_018_HLQJDPanel
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

Act_018_HLQJDPanel = basefunc.class()
local C = Act_018_HLQJDPanel
C.name = "Act_018_HLQJDPanel"
local M = Act_018_HLQJDManager
local qd_anim_time = 1.2
local tx_time = {
	[1] = 1.2,
	[2] = 1.5,
	[3] = 6,
}

function C.Create(parent,backcall)
	return C.New(parent,backcall)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
	self.lister = {}
	self.lister["shop_info_get"] = basefunc.handler(self,self.shop_info_get)
	self.lister["AssetsGetPanelConfirmCallback"] = basefunc.handler(self,self.AssetsGetPanelConfirmCallback)
	self.lister["AssetChange"] = basefunc.handler(self,self.OnAssetChange)
	self.lister["get_task_award_new_response"] = basefunc.handler(self,self.get_task_award_new_response)
	self.lister["ExitScene"] = basefunc.handler(self,self.MyExit)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	if self.backcall then
		self.backcall()
	end
	self.timer_click=true
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:ctor(parent,backcall)
	local parent = parent or GameObject.Find("Canvas/LayerLv5").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	self.backcall = backcall
	LuaHelper.GeneratingVar(self.transform, self)
	

	self:MakeLister()
	self:AddMsgListener()

	self.timer_click=true

	self:InitUI()
	self:InitShopUI()
	self:RefreshCzNum()
	if M.GetShopIDs() then
		Network.SendRequest("query_gift_bag_status_by_ids",{gift_bag_ids = M.GetShopIDs()})
	end
	local chuizi_str = {
		"铜","银","金"
	}
	for i = 1,3 do
		self["lottery"..i.."_btn"].onClick:AddListener(
			function ()
				if not self.timer_click then return end
				if M.GetCzNum(self.chuizi_level) > 0 then
					self:GetAward(i)
					self:SetTxTime()
				else
					HintPanel.Create(1,chuizi_str[self.chuizi_level].."锤数量不足！")
				end
			end
		)
	end
	self:RefreshEggs()
	-- local TaskIDs = M.GetTaskIDs()
	-- for i = 1,#TaskIDs do
	-- 	Network.SendRequest("query_one_task_data", {task_id = TaskIDs[i]})
	-- end
end

function C:InitUI()
	for i = 1,3 do
		self["change"..i.."_btn"].onClick:AddListener(function ()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
			self:SwitchBtn(i)
		end)
		self["yhd"..i].gameObject:SetActive(self:HasGetAward(i))
	end
	self.close_btn.onClick:AddListener(
		function ()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
			self:MyExit()
		end
	)
	self:MyRefresh()
	self:SwitchBtn(self:GetBestIndes())
end

function C:MyRefresh()
end
--更改
function C:SwitchBtn(index)
	--如果正在播放动画就return掉
	if not self.timer_click then return end
	self.chuizi_level = index
	for i = 1,3 do
		self["guan"..i].gameObject:SetActive(false)
		self["change"..i.."_btn"].enabled = true
		self["yhd"..i].gameObject:SetActive(self:HasGetAward(i))
	end
	self["change"..index.."_btn"].enabled = false
	self["guan"..index].gameObject:SetActive(true)
	self:RefreshLeftUI()
	self:RefreshEggs()
end

local title_img = {"hlqjd_imgf_tcjl","hlqjd_imgf_ycjl","hlqjd_imgf_jcjl"}
function C:RefreshLeftUI()
	local data = M.GetBaseData()
	self.jiangli_img.sprite = GetTexture(title_img[self.chuizi_level])
	for i = 1,3 do
		-- dump(data,"data=")
		-- dump(i,"i=")
		-- dump(self.chuizi_level,"self.chuizi_level=")

		--dump(data[self.chuizi_level][i].image)
		self["award"..i.."_img"].sprite = GetTexture(data[self.chuizi_level][i].image)
		self["award"..i.."_txt"].text = data[self.chuizi_level][i].text
	end
end

function C:HasGetAward(index)
	local task_id = M.GetTaskIDs()[self.chuizi_level]
	if task_id then
		local data = GameTaskModel.GetTaskDataByID(task_id)
		if data and data.other_data_str then
			local first_had = tonumber(data.other_data_str)
			local b = basefunc.decode_task_award_status(data.award_get_status)
			b = basefunc.decode_all_task_award_status2(b, data, 3)
			local sum = 0
			for i = 1,#b do
				sum = sum + (b[i] == 2 and 1 or 0)
			end
			if sum == 0 then
				return false
			elseif sum == 1 then
				if index == first_had then
					return true
				else
					return false
				end
			elseif sum == 2 then
				if index <= 2 then
					return true
				else
					return false
				end
			else
				return true
			end	
		end
	end
	return false
end

function C:RefreshCzNum()
	for i = 1,3 do
		self["c"..i.."_txt"].text = M.GetCzNum(i)
	end
end

function C:InitShopUI()
	self.shop_ui = {}
	for i = 1,#M.GetShopIDs() do
		local temp_ui = {}
		local gift_config = MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, M.GetShopIDs()[i])

		local b = GameObject.Instantiate(self.libaochild,self.libaonode)
		b.gameObject:SetActive(true)
		LuaHelper.GeneratingVar(b.transform,temp_ui)
		temp_ui.award_1_1_img.sprite = GetTexture(M.GetShopImg()[i][1])
		temp_ui.award_1_2_img.sprite = GetTexture(M.GetShopImg()[i][2])
		temp_ui.award_1_1_txt.text = gift_config.buy_asset_count[1]
		temp_ui.award_1_2_txt.text = gift_config.buy_asset_count[2]
		self.shop_ui[M.GetShopIDs()[i]] = b
		temp_ui.buy_btn.onClick:AddListener(
			function ()
				ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
				self:BuyShop(M.GetShopIDs()[i])
			end
		)
		temp_ui.btn_txt.text = (gift_config.price/100).."元领取"
	end
end

function C:BuyShop(shopid)
    local gb =  MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, shopid)
    if not gb then return end
	local price = gb.price
	if  GameGlobalOnOff.PGPay and gameRuntimePlatform == "Ios" then
		ServiceGzhPrefab.Create({desc="请前往公众号获取"})
	else
		PayTypePopPrefab.Create(shopid, "￥" .. (price / 100))
	end
end

function C:shop_info_get()
	for i = 1,#M.GetShopIDs() do
		if self.shop_ui[M.GetShopIDs()[i]] and IsEquals(self.shop_ui[M.GetShopIDs()[i]]) then
			local temp_ui = {}
			LuaHelper.GeneratingVar(self.shop_ui[M.GetShopIDs()[i]].transform,temp_ui)
			temp_ui.num_txt.text = MainModel.GetRemainTimeByShopID(M.GetShopIDs()[i])
			if MainModel.GetRemainTimeByShopID(M.GetShopIDs()[i]) > 0 then
				temp_ui.buy_mask.gameObject:SetActive(false)
			else	
				temp_ui.buy_mask.gameObject:SetActive(true)
			end
		end
	end
	Event.Brocast("global_hint_state_change_msg", { gotoui = M.key })
end

function C:AssetsGetPanelConfirmCallback()
	if M.GetShopIDs() then
		Network.SendRequest("query_gift_bag_status_by_ids",{gift_bag_ids = M.GetShopIDs()})
	end
	for i = 1,3 do
		self["yhd"..i].gameObject:SetActive(self:HasGetAward(i))
	end
end

function C:PlayQQLAnim(index)
	self.Animtion_Finsh = false
	local temp_ui = {}
	local b = GameObject.Instantiate(self.anim_item,self["anim_node"..index])
	b.gameObject:SetActive(true)
	b.transform.localPosition = Vector3.New(0,0,0)
	b.transform.localScale = Vector3.New(1.24,1.24,1.24)
	LuaHelper.GeneratingVar(self["egg_item"..index].transform, temp_ui)
	temp_ui["good"..index].gameObject:SetActive(false)
	temp_ui.anim_qd.gameObject:SetActive(true)
	temp_ui.animator = temp_ui.anim_qd.gameObject.transform:GetComponent("Animator")
	temp_ui.animator:Play("Dachui_Pt_H",-1,0)
	if self.PlayQQLAnim_Timer then 
		self.PlayQQLAnim_Timer:Stop()
	end 
	self.PlayQQLAnim_Timer = Timer.New(      
		function ()
			temp_ui.anim_qd.gameObject:SetActive(false)
			temp_ui["bad"..index].gameObject:SetActive(true)
			self:PlayQQLTX(index)
		end
	,qd_anim_time,1)
	self.PlayQQLAnim_Timer:Start()
end

function C:PlayQQLTX(index)
	local temp_ui = {}
	LuaHelper.GeneratingVar(self["egg_item"..index].transform, temp_ui)
	temp_ui["good"..index].gameObject:SetActive(false)
	temp_ui.anim_qd.gameObject:SetActive(false)
	temp_ui["tx_"..self.tx_level].gameObject:SetActive(true)
	if self.PlayQQLTX_Timer then 
		self.PlayQQLTX_Timer:Stop()
	end 
	self.PlayQQLTX_Timer = Timer.New(      
		function ()
			temp_ui["tx_"..self.tx_level].gameObject:SetActive(false)
			self.Animtion_Finsh = true
			self:TryToShow()
		end
	,tx_time[self.tx_level],1)
	self.PlayQQLTX_Timer:Start()
end

function C:OnAssetChange(data)
    dump(data, "<color=red>----奖励类型-----</color>")
	if data and data.change_type == "task_p_hammer" then
		self.award_data = data
		if self.timer_click then
			self.timer_click = false
		end
		self:PlayQQLAnim(self.curr_index)
		self:RefreshLeftUI()
	end
	self:RefreshCzNum()
end

function C:RefreshEggs()
	local data = GameTaskModel.GetTaskDataByID(M.GetTaskIDs()[self.chuizi_level])
	dump(data,"<color=red>任务</color>")
	if data == nil then return end
	local b = basefunc.decode_task_award_status(data.award_get_status)
	b = basefunc.decode_all_task_award_status2(b, data, 3)
	for i = 1,3 do
		if b[i] == 2 then
			self["bad"..i].gameObject:SetActive(true)
			self["good"..i].gameObject:SetActive(false)
		else
			self["bad"..i].gameObject:SetActive(false)
			self["good"..i].gameObject:SetActive(true)
		end
	end
	self.timer_click = true
end

function C:GetAward(index)
	self.curr_index = index

	Network.SendRequest("get_task_award_new",{id = M.GetTaskIDs()[self.chuizi_level],award_progress_lv = index})
end

function C:get_task_award_new_response(_,data)
	dump(data,"<color=red>成功砸蛋</color>")
end

function C:GetBestIndes()
	local best_index = 3
	for i = 3,1,-1 do
		if M.GetCzNum(i) > 0 then
			best_index = i
			break
		end
	end
	return best_index
end

function C:TryToShow()
	if self.award_data then
		Event.Brocast("AssetGet", self.award_data)
		self.award_data = nil
		self:RefreshEggs()
	end
end

function C:SetTxTime()
	local data = GameTaskModel.GetTaskDataByID(M.GetTaskIDs()[self.chuizi_level])
	--dump(data,"<color=red>dataaaaaaaaaaaaaaaaaaaaaa</color>")
	if data then
		local b = basefunc.decode_task_award_status(data.award_get_status)
		b = basefunc.decode_all_task_award_status2(b, data, 3)
		local had_zd = 0
		for i = 1,#b do
			if b[i] == 2 then
				had_zd = had_zd + 1
			end
		end
		if had_zd >= 2 then
			self.tx_level = 2
		else
			self.tx_level = 1
		end
	end
end

--[[
	GetTexture("hlqjd_imgf_tcjl")
	GetTexture("hlqjd_imgf_ycjl")
]]