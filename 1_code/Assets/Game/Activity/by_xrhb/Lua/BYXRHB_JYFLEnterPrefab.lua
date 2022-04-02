-- 创建时间:2019-11-11
-- Panel:BYXRHB_JYFLEnterPrefab
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

BYXRHB_JYFLEnterPrefab = basefunc.class()
local C = BYXRHB_JYFLEnterPrefab

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
    self.lister["global_hint_state_change_msg"] = basefunc.handler(self, self.on_global_hint_state_change_msg)
    self.lister["model_by_xrhb_jyfl_msg"] = basefunc.handler(self, self.on_model_by_xrhb_jyfl_msg)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	if self.down then
		self.down:Stop()
		self.down = nil
	end
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:ctor(parent)
	ExtPanel.ExtMsg(self)
	local obj = newObject("BYXRHB_JYFLEnterPrefab", parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	self.get_img = self.get_btn.transform:GetComponent("Image")

	self:MakeLister()
	self:AddMsgListener()
	self.slider = self.HBSlider:GetComponent("Slider")

	self:InitUI()
end

function C:InitUI()
	self.BG_btn.onClick:AddListener(function ()
    	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnEnterClick()
	end)
	self.get_btn.onClick:AddListener(function ()
    	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnGetClick()
	end)
	self.info_txt.text = "完成任务即得"
	self:MyRefresh()
end

function C:MyRefresh()
	self.task_id = FishingXRHBManager.GetJYFLShowId()
	if not self.task_id then
		self.gameObject:SetActive(false)
	else
		self.task_data = FishingXRHBManager.GetTaskData(self.task_id)
		self.gameObject:SetActive(true)
		if self.task_id == 68 then
			self.title_txt.text = "10免费福卡"
			self.title1_txt.text = "10"
		elseif self.task_id == 76 then
			self.title_txt.text = "50免费福卡"
			self.title1_txt.text = "50"
		else
			self.title_txt.text = "200免费福卡"
			self.title1_txt.text = "200"
		end
		if not self.task_data then
			self.rate_no.gameObject:SetActive(true)
			self.rate.gameObject:SetActive(false)
	        self.get_txt.text = "去 开 启"
		else
			self.rate_no.gameObject:SetActive(false)
			self.rate.gameObject:SetActive(true)
			if self.task_data.now_process >= self.task_data.need_process then
				self.get_txt.text = "去 领 取"
				self.rate_txt.text = "100%"
			else
				self.get_txt.text = "去 完 成"
				self.rate_txt.text = "" .. StringHelper.GetPreciseDecimal(100 * self.task_data.now_process / self.task_data.need_process, 2) .. "%"
			end

			self.down_time_value = self.task_data.over_time - os.time()
			if self.down_time_value < 0 then
				self.down_time_value = 0
			end
			local process = self.task_data.now_process / self.task_data.need_process
			if process > 1 then
				process = 1
			end
			local vv = process * 10
			self.slider_txt.text = StringHelper.GetPreciseDecimal(vv, 2) .. "/10"
		    self.slider.value = process

			self:RefreshDownTime()
		end
        self.get_img.sprite = GetTexture("com_btn_5")
	end
end
function C:RefreshDownTime()
	if self.down then
		self.down:Stop()
		self.down = nil
	end
	if self.down_time_value and self.down_time_value > 0 then
		self.down = Timer.New(function ()
			self.down_time_value = self.down_time_value - 1
			self:UpdateUI()
		end, 1, -1)
		self.down:Start()
		self:UpdateUI()
	end
end
function C:UpdateUI()
	if self.down_time_value > 0 then
		local hh = math.floor(self.down_time_value / 3600)
		local ff = math.floor((self.down_time_value % 3600) / 60)
		local mm = self.down_time_value % 60
		self.time_txt.text = string.format("(倒计时：%02d:%02d:%02d)", hh, ff, mm)
	else
		if self.down then
			self.down:Stop()
			self.down = nil
		end
		self.time_txt.text = "00:00:00"
	end
end

function C:OnEnterClick()
	GameManager.GotoUI({gotoui = "game_FishingHall"})
end
function C:OnGetClick()
	GameManager.GotoUI({gotoui = "game_FishingHall"})
end

function C:OnDestroy()
	self:MyExit()
end

function C:on_global_hint_state_change_msg(parm)
	if parm.gotoui == FishingXRHBManager.key then
		self:MyRefresh()
	end
end

function C:on_model_by_xrhb_jyfl_msg()
	self:MyRefresh()
end

