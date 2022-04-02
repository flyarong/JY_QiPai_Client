-- 创建时间:2021-08-23
-- Panel:Act_066_JNBJLPanel
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

Act_066_JNBJLPanel = basefunc.class()
local C = Act_066_JNBJLPanel
C.name = "Act_066_JNBJLPanel"

local M = Act_066_JNBJLManager

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
	self.lister["model_jnbjl_task_refresh"] = basefunc.handler(self,self.on_model_jnbjl_task_refresh)
	self.lister["model_jnbjl_vip_task_refresh"] = basefunc.handler(self,self.on_model_jnbjl_vip_task_refresh)
	self.lister["get_task_award_response"] = basefunc.handler(self,self.on_get_task_award_response)
	self.lister["get_task_award_new_response"] = basefunc.handler(self,self.on_get_task_award_new_response)

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

function C:ctor(parent)
	ExtPanel.ExtMsg(self)
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
	self.task_cfg = M.GetTaskCfg()
	self:InitVipTaskItems()
	self:InitProgressPre()
	self:InitTaskItems()
    CommonTimeManager.GetCutDownTimer(M.endTime,self.remian_time_txt)
	self:MyRefresh()

	self.rule_btn.onClick:AddListener(function()
		self:OpenHelpPanel()
	end)
end

function C:MyRefresh()
	self:RefreshPanel()
	self:RefreshVipUI()
end

function C:InitVipTaskItems()
	self.v3TaskPre = {}
	self.v3TaskCfg = M.GetVipCfg(3)
	for i = 1, #self.v3TaskCfg.award_txt do
		local b = GameObject.Instantiate(self.vip_item, self.content_v3.transform)
		b.gameObject:SetActive(true)
		local bUI = LuaHelper.GeneratingVar(b.transform, bUI)
		bUI.icon_img.sprite = GetTexture(self.v3TaskCfg.award_icon[i])
		bUI.award_txt.text = self.v3TaskCfg.award_txt[i]
		self.v3TaskPre[#self.v3TaskPre + 1] = bUI
	end

	self.v6TaskPre = {}
	self.v6TaskCfg = M.GetVipCfg(6)
	for i = 1, #self.v6TaskCfg.award_txt do
		local b = GameObject.Instantiate(self.vip_item, self.content_v6.transform)
		b.gameObject:SetActive(true)
		local bUI = LuaHelper.GeneratingVar(b.transform, bUI)
		bUI.icon_img.sprite = GetTexture(self.v6TaskCfg.award_icon[i])
		bUI.award_txt.text = self.v6TaskCfg.award_txt[i]
		self.v6TaskPre[#self.v6TaskPre + 1] = bUI
	end

	self.v3_get_btn.onClick:AddListener(function()
		Network.SendRequest("get_task_award", { id = M.v3_task_id})
	end)
	self.v6_get_btn.onClick:AddListener(function()
		Network.SendRequest("get_task_award", { id = M.v6_task_id})
	end)
end

function C:InitTaskItems()
	self.content_pre = {}
	for i = 1, #self.task_cfg do
		local b = newObject("Act_066_JNBJLItem", self.content_2.transform)
		local b_ui = {}
		LuaHelper.GeneratingVar(b.transform, b_ui)
		b_ui.award_amount_txt.text = self.task_cfg[i].award_txt
		b_ui.award_icon_img.gameObject:SetActive(true)
		b_ui.award_icon_img.sprite = GetTexture(self.task_cfg[i].award_icon)
		b_ui.award_get_btn.onClick:AddListener(function()
			Network.SendRequest("get_task_award_new", { id = M.task_id, award_progress_lv = i })
		end)
		-- b_ui.award_tip_btn.onClick:AddListener(function()
		-- 	local item_cfg = GameItemModel.GetItemToKey(self.task_cfg[i].item_key)
		-- 	LTTipsPrefab.Show2(b_ui.award_tip_btn.transform, item_cfg.name, item_cfg.desc)
		-- 	item_cfg = nil
		-- end)
		self.content_pre[i] = b
	end

end

function C:InitProgressPre()
	for i = 1, self.d_content.transform.childCount do
		local b = self.d_content.transform:GetChild(i - 1)
		local need_num_txt = b.transform:GetComponent("Text")
		need_num_txt.text = StringHelper.ToCash(self.task_cfg[i].task_level)
	end
end

function C:RefreshPanel()
	self.data = M.GetTaskData()
	self.lv = M.GetTaskLv()
	self:RefreshContentUI()
	self:RefreshProgressUI()
end

function C:RefreshVipUI()
	local isCanGetAwardV3 = M.IsCanGetVIPAward(3)
	self.v3_get_btn.gameObject:SetActive(isCanGetAwardV3)
	for i = 1, #self.v3TaskPre do
		self.v3TaskPre[i].can_get.gameObject:SetActive(isCanGetAwardV3)
	end

	local isCanGetAwardV6 = M.IsCanGetVIPAward(6)
	self.v6_get_btn.gameObject:SetActive(isCanGetAwardV6)
	for i = 1, #self.v6TaskPre do
		self.v6TaskPre[i].can_get.gameObject:SetActive(isCanGetAwardV6)
	end
end

function C:RefreshContentUI()
	self:ReSetZhiZhen()
	local check_value
	if self.lv == 1 then
		self:SetZhiZhen(1)
	else
		-- check_value = self.lv == #self.cfg and self.lv or self.lv - 1
		check_value = self.lv - 1
	end

	for i = 1, #self.task_cfg do
		if not self.content_pre[i] or not self.data.award_status[i] then
			break
		end
		if check_value and i == check_value then
			dump(check_value,"<color=white>check_value</color>")
			self:SetZhiZhen(i)
		end
		local b_ui = {} 
		LuaHelper.GeneratingVar(self.content_pre[i].transform,b_ui)
		b_ui.award_get_btn.gameObject:SetActive(self.data.award_status[i] == 1)
		b_ui.award_tip_btn.gameObject:SetActive(self.data.award_status[i] == 0)
		b_ui.bg_1.gameObject:SetActive(self.data.award_status[i] == 1)
		--b_ui.dian_ji.gameObject:SetActive(self.data.award_status[i] == 1)
		b_ui.award_geted.gameObject:SetActive(self.data.award_status[i] == 2)
	-- 	self:LoadNameOutLine(b_ui.award_name_txt,self.data.award_status[i] == 1)
	-- 	self:LoadNameOutLine(b_ui.award_amount_txt,self.data.award_status[i] == 1)
	end
end

local width_p = 236.2
local width_p_1 = 91.91

function C:RefreshProgressUI()
	for i = 1, self.b_content.transform.childCount do
		local b = self.b_content.transform:GetChild(i - 1)
		local b_rect_trans = b:GetComponent("RectTransform")
		local b_rect = b:GetComponent("RectTransform").rect

		if i > self.lv then
			b_rect_trans.sizeDelta = { x = 0, y = b_rect.height }
		elseif i < self.lv then
			if i == 1 then
				b_rect_trans.sizeDelta = { x = width_p_1, y = b_rect.height }
			else
				b_rect_trans.sizeDelta = { x = width_p, y = b_rect.height }
			end
		else
			if self.lv == 1 then
				local rate = self.data.now_total_process / self.task_cfg[self.lv].task_level
				b_rect_trans.sizeDelta = { x = width_p_1 * rate, y = b_rect.height }
			else
				local rate = (self.data.now_total_process - self.task_cfg[self.lv - 1].task_level) / (self.task_cfg[self.lv].task_level - self.task_cfg[self.lv - 1].task_level)
				rate = rate > 1 and 1 or rate
				b_rect_trans.sizeDelta = { x = width_p * rate, y = b_rect.height }
			end
		end
	end

	for i = 1, self.c_content.transform.childCount do
		local b = self.c_content.transform:GetChild(i - 1)
		b.gameObject:SetActive(i < self.lv)
	end
end

function C:ReSetZhiZhen()
	self.zhizhen.transform:SetParent(self.transform)
	self.zhizhen.transform.localPosition = Vector3.zero
	self.zhizhen.gameObject:SetActive(false)
end

function C:SetZhiZhen(i)
	self.zhizhen.transform:SetParent(self.content_pre[i].transform)
	self.zhizhen.transform.localPosition = Vector3.zero
	self.zhizhen.gameObject:SetActive(true)
	self.num_txt.text = self.data.now_total_process
end

function C:on_model_jnbjl_task_refresh()
	self:RefreshPanel()
end

function C:on_model_jnbjl_vip_task_refresh()
	self:RefreshVipUI()
end

local real_config = {
	["秋千吊椅"] = {img = "activity_icon_gift301_qq"},
	["美的电饭煲"] = {img = "activity_icon_gift167_mddfb"},
	["美的烤箱"] = {img = "activity_icon_gift173_dkx"},
	["荣耀手表"] = {img = "activity_icon_gift300_hwsh"},
}

function C:on_get_task_award_response(_, data)
	dump(data, "<color=yellow>++++on_get_task_award_response+++</color>")
end

function C:on_get_task_award_new_response(_, data)
	dump(data, "<color=yellow>++++on_get_task_award_new_response+++</color>")
	if data and data.id == M.task_id then
		if not table_is_null(data.award_list) then
			for k,v in pairs(data.award_list) do
				if v.award_name and not v.award_type then
					local _image = real_config[v.award_name].img
					local _text = v.award_name
					RealAwardPanel.Create({ image = _image, text = _text })
				end
			end
		end
 	end
end

local help_info = {
	"1.活动时间：9月7日7:30:00~9月13日23:59:59",
	"2.街机捕鱼，所有消消乐、热血传奇、龙王争霸、疯狂捕鱼、敲敲乐、弹弹乐和盗墓笔记游戏中有机会获得纪念币",
	"3.活动结束后所有纪念币将被清除",
	"4.实物奖励请联系客服QQ公众号4008882620领取",
	"5.奖励图片仅供参考，请以实际收到的奖励为准",
}

function C:OpenHelpPanel()
    local str =""
    for i = 1, #help_info do
        str = str .. "\n" .. help_info[i]
    end
    self.introduce_txt.text = str
    IllustratePanel.Create({ self.introduce_txt.gameObject }, GameObject.Find("Canvas/LayerLv5").transform)
end