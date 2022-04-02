-- 创建时间:2021-01-15
-- Panel:Act_047_WFSHLPanel
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

Act_047_WFSHLPanel = basefunc.class()
local C = Act_047_WFSHLPanel
local M = Act_047_WFSHLManager
C.name = "Act_047_WFSHLPanel"


local btn_state = {
	goto_ui = 1,
	exchange = 2,
	exchange_all = 3,
}

local fx_duration = {0.8,0.8}

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
	self.lister["box_exchange_response"] = basefunc.handler(self, self.on_box_exchange_response)
	self.lister["box_all_exchange_response"] = basefunc.handler(self,self.on_box_all_exchange_response)
	self.lister["AssetChange"] = basefunc.handler(self,self.on_asset_change)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	if self.timer_remian then
		self.timer_remian:Stop()
	end
	self:ImmediateCloseFx()

	LTTipsPrefab.Hide()
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:OnDestroy()
	self:MyExit()
end

function C:MyClose()
	self:MyExit()
end

function C:ctor(parent)
	ExtPanel.ExtMsg(self)
	local parent = parent or GameObject.Find("Canvas/LayerLv4").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()

	self:InitCfg()
	self:RefreshData()

	self:InitUI()
	self:MyRefresh()
end

function C:InitCfg()
	self.cur_reward_index = 1
	self.is_exchange_all = false
	self.cfg = M.GetCfg()
end

function C:RefreshData()
	self.data = M.GetData()
end

function C:InitUI()
	self.rewards_ui = self:InitListUI(self.rewards.transform)
	self.items_ui= self:InitListUI(self.items.transform)

	self.rule_btn.onClick:AddListener(function ()
		self:OpenRulePanel()
	end)
	self.exchange_btn.onClick:AddListener(function ()
		self:Exchange()
	end)
	self.exchange_goto_btn.onClick:AddListener(function ()
		self:GotoGame()
	end)

	self:InitRewardUI()
	self:InitItemUI()
	self:InitRemainTimeUI()

	self:InitFx()

	self.exchange_all_tog = self.transform:Find("exchange_all"):GetComponent("Toggle")
	self.exchange_all_tog.onValueChanged:AddListener(function(val)
		self.is_exchange_all = val
		if val then
			HintPanel.Create(1,"一键兑换功能会根据道具组合从多到少自动匹配兑换")
		end
		self:RefreshBtnUI()
	end)

end

function C:InitListUI(items_trans)
	local re_list = {}
	for i = 1, items_trans.childCount do
		local child = items_trans:GetChild(i - 1)
		re_list[#re_list + 1] = child
	end
	return re_list
end


function C:InitRewardUI()
	for i = 1, #self.rewards_ui do
		local cur_rd_obj = self.rewards_ui[i]
		local cur_rd_ui = {}
		LuaHelper.GeneratingVar(cur_rd_obj.transform, cur_rd_ui)
		cur_rd_ui.rd_icon_img.sprite = GetTexture(self.cfg[i].icon)
		cur_rd_ui.reward_txt.text = self.cfg[i].content
		local btn = cur_rd_obj:GetComponent("Button")
		EventTriggerListener.Get(cur_rd_obj.gameObject).onDown = function()
			self:ImmediateCloseFx()
			self.press_time = 0
			self.timer_reward_press = Timer.New(function ()
					self.press_time = self.press_time + 1
					if self.press_time > 12 then
						LTTipsPrefab.Show2(cur_rd_obj.transform,self.cfg[i].tips[1],self.cfg[i].tips[2])
						self.timer_reward_press:Stop()
					end
				end,0.02,-1)
			self.timer_reward_press:Start()
			self:ChangeReward(i)
		end
		EventTriggerListener.Get(cur_rd_obj.gameObject).onUp = function()
			if self.press_time <= 12 then
				self.timer_reward_press:Stop()
				self.press_time = 0
			end 
		end
	end
end

function C:InitItemUI()
	for i = 1, #self.items_ui do
		local cur_item_obj = self.items_ui[i]
		local cure_item_icon = cur_item_obj.transform:Find("item_icon"):GetComponent("Image")
		cure_item_icon.sprite = M.GetTexture(i)
	end
end

function C:InitRemainTimeUI()
	local end_time = M.GetEndTime()
	local update_remain_ui = function ()
		local diff_time = end_time - os.time()
		if diff_time <= 0 then
			self:MyExit()
		end
		if IsEquals(self.remain_time_txt) then
			self.remain_time_txt.text = "剩余时间:" .. StringHelper.formatTimeDHMS(diff_time)
		end
	end
	update_remain_ui()
	self.timer_remian = Timer.New(function ()
		update_remain_ui()
	end,1,-1)
	self.timer_remian:Start()
end
-------------------------refresh-------------------------

function C:MyRefresh()
	self:RefreshData()
	self:RefreshUI()
end

function C:RefreshUI()
	self:RefreshRewardUI()
	self:RefreshItemUI()
	self:RefreshBtnUI()
	self:RefreshCurRewardUI()
end

function C:RefreshCurRewardUI()
	self.cur_reward_icon_img.sprite = GetTexture(self.cfg[self.cur_reward_index].icon)
	self.cur_reward_txt.text = self.cfg[self.cur_reward_index].content
	local buff_desc = ""
	if M.GetFQBuff() ~= 0 then
		local buff_num = self.cfg[self.cur_reward_index].lucky_buff * M.GetFQBuff()
		buff_num = basefunc.math.round(tonumber(buff_num))
		buff_desc = "<color=red>+" .. buff_num .."</color>"
	end
	local tip_desc = "必得" ..self.cfg[self.cur_reward_index].lucky_buff ..buff_desc.."福气"
	self.cur_reward_tip_txt.text = tip_desc
	self.cur_reward_tip_txt.fontSize = 24
end

function C:RefreshItemUI()
	local need_list  = self.cfg[self.cur_reward_index].consume_num
	for i = 1, #self.items_ui do
		local cur_item_obj = self.items_ui[i]
		local cure_item_txt = cur_item_obj.transform:Find("item_txt"):GetComponent("Text")
		cure_item_txt.text =  self.data[i].."/"..need_list[i]
		local cur_item_tip = cur_item_obj.transform:Find("tip_btn"):GetComponent("Button")
		cur_item_tip.onClick:AddListener(function ()
			local _show = M.GetItemTip(i)
			LTTipsPrefab.Show2(cur_item_obj.transform,_show[1],_show[2])
		end)
	end
end

function C:RefreshRewardUI()
	if self.last_rward_index ~= self.cur_reward_index then
		local change_state = function (obj,enable)
			obj:Find("rd_bg/rd_bg_out").gameObject:SetActive(enable)
		end
		if self.last_rward_index then
			change_state(self.rewards_ui[self.last_rward_index].transform , false)
		end
		change_state(self.rewards_ui[self.cur_reward_index].transform , true)
		self.last_rward_index = self.cur_reward_index
	end
	for i = 1, #self.rewards_ui do
		local cur_rd_obj = self.rewards_ui[i]
		local cur_rd_ui = {}
		LuaHelper.GeneratingVar(cur_rd_obj.transform, cur_rd_ui)
		if M.CheckIsExchange(i) then
			--有可领取的奖励
		end
	end
end

function C:RefreshBtnUI()
	if M.CheckIsExchange(self.cur_reward_index) then
		if self.is_exchange_all then
			self:ChangeBtnState(btn_state.exchange_all)
		else
			self:ChangeBtnState(btn_state.exchange)
		end
	else
		self:ChangeBtnState(btn_state.goto_ui)
	end
end

function C:ChangeReward(reward_index)
	
	if reward_index == self.cur_reward_index then
		return 
	end
	self.cur_reward_index = reward_index
	self:RefreshUI()
end

function C:ChangeBtnState(state)
	self.exchange_btn.gameObject:SetActive(false)
	self.exchange_goto_btn.gameObject:SetActive(false)
	if state == btn_state.exchange or state == btn_state.exchange_all then
		self.exchange_btn.gameObject:SetActive(true)
	else
		self.exchange_goto_btn.gameObject:SetActive(true)
	end
end

function C:Exchange()
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	if self.is_exchange_all then
		HintPanel.Create(2,"确认全部兑换吗？",function()
			Network.SendRequest("box_all_exchange",{name = "wfhhl_2_2" })
		end)
	else
		local _id = self.cfg[self.cur_reward_index].exchange_id
		Network.SendRequest("box_exchange", { id = _id, num = 1 })
	end
end

function C:OpenRulePanel()
	self.introduce_txt.text = M.GetHelpInfo()
	IllustratePanel.Create({ self.introduce_txt.gameObject }, GameObject.Find("Canvas/LayerLv5").transform)
end

function C:GotoGame()
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	GameManager.GotoUI({gotoui = "game_MiniGame"})
end

function C:on_box_exchange_response(_, data)
	if data and data.result ~= 0 then
		LittleTips.Create(errorCode[data.result] or "错误：" .. data.result)
	end
end

function C:on_box_all_exchange_response(_,data)
	if data and data.result ~= 0 then
		LittleTips.Create(errorCode[data.result] or "错误：" .. data.result)
	end
end

function C:on_asset_change(data)
	--dump(data,"<color=red>DDDDDDDDDDDDDDDDData</color>")
	if not data then
		return 
	end
	local check_func = function (type)
		for i = 1, #self.cfg do
			if "box_exchange_active_award_" .. self.cfg[i].exchange_id == type then
				return true
			end
		end
		return false
	end
	if check_func(data.change_type) and #data.data > 0  then
		self.show_get_award = data
		--Event.Brocast("AssetGet", data)
		self:PlayFx_1()
		M.UpdateData()
		Event.Brocast("global_hint_state_change_msg",{gotoui = M.key})
		self:MyRefresh()
	end
end

---------------------------特效播放-----------------------------

function C:InitFx()
	self.fx_lis = {}
	for i = 1, self.guang.childCount do
		local child = self.guang:GetChild(i - 1)
		self.fx_lis[#self.fx_lis + 1] = child
	end
end

function C:FxGaungShow(is_show)
	local consums = self.cfg[self.cur_reward_index].consume_num
	for i = 1, #consums do
		if consums[i] > 0  then
			self.fx_lis[i].gameObject:SetActive(is_show)
		end
	end
end

function C:PlayFx_1()
	self:FxGaungShow(true)
	self.timer_fx_guang = Timer.New(function ()
		self:FxGaungShow(false)
		self:PlayFx_2()
	end,fx_duration[1],1)
	self.timer_fx_guang:Start()
end

function C:PlayFx_2()
	self.zhongjiang.gameObject:SetActive(true)
	self.timer_fx_zhongjiang = Timer.New(function ()
		self.zhongjiang.gameObject:SetActive(false)
		if self.show_get_award then
			Event.Brocast("AssetGet", self.show_get_award)
			self.show_get_award = nil
		end
	end,fx_duration[2],1)
	self.timer_fx_zhongjiang:Start()
end

function C:ImmediateCloseFx()
	if self.timer_fx_guang then
		self.timer_fx_guang:Stop()
	end

	if self.timer_fx_zhongjiang then
		self.timer_fx_zhongjiang:Stop()
	end
	
	if self.show_get_award then
		Event.Brocast("AssetGet", self.show_get_award)
		self.show_get_award = nil
	end
end