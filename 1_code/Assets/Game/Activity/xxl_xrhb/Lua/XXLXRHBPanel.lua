local basefunc = require "Game/Common/basefunc"

XXLXRHBPanel = basefunc.class()
local C = XXLXRHBPanel
C.name = "XXLXRHBPanel"

local is_instance
local instance
function C.Create(parent, _task_id)
	if is_instance then
		return
	end
	is_instance = true
	instance = C.New(parent, _task_id)
	return instance
end

function C.Close()
	if instance then
		instance:MyExit()
	end
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["eliminate_quit_game"] = basefunc.handler(self, self.MyExit)
    self.lister["model_task_change_msg"] = basefunc.handler(self, self.on_task_change_msg)
	self.lister["eliminate_bet_change"] = basefunc.handler(self, self.on_eliminate_bet_change)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	if self.update_time then
		self.update_time:Stop()
	end
	self.update_time = nil
	self:RemoveListener()
	destroy(self.gameObject)
	instance = nil
	is_instance = false

	 
end

function C:ctor(parent, _task_id)

	ExtPanel.ExtMsg(self)

	self._task_id = _task_id
	self.data = XXLXRHBManager.GetTaskData(_task_id)
	dump(self.data, "<color=red>XXLXRHBPanel data</color>")

	parent = parent or GameObject.Find("Canvas/LayerLv3").transform
	self.parent = parent
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self.confirm_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        self:OnSXClick()
    end)
    self.hint_close_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        self:OnCloseHintClick()
    end)
    self.hint_confirm_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        self:OnCloseHintClick()
    end)
    self.get_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        self:OnGetClick()
    end)
    self.slider = self.HBSlider:GetComponent("Slider")
    self.need_txt.text = ""
    self.anim = self.Rect:GetComponent("Animator")
	self.anim.enabled = false

	if EliminateModel then
		self.bet = EliminateModel.GetBet()[1] * 5		
	end
	if not self.bet then
		self.bet = 0
	end
	dump(self.bet,"<color=white>奖励？？？？/</color>")
	self:InitUI()
end

function C:InitUI()
	self:MyRefresh()
end

function C:MyRefresh()
	if self.update_time then
		self.update_time:Stop()
	end
    self.down_time = self.data.over_time - os.time()
    if self.down_time > 0 and self.data.now_process < self.data.need_process then
	    self.update_time = Timer.New(function ()
	    	self:UpdateTime()
	    end, 1, -1)
	    self.update_time:Start()
	    self:UpdateTime()
	else
		self.countdown_txt.text = "00:00:00"
	end

	self.MB.gameObject:SetActive(false)
	self.UI1.gameObject:SetActive(false)
	self.UI2.gameObject:SetActive(false)
	self.UI3.gameObject:SetActive(false)
	local state = PlayerPrefs.GetInt("XXLXRHBPanel" .. MainModel.UserInfo.user_id .. "task" .. self._task_id, 0)

	local cfg = XXLXRHBManager.UIConfig.cfg_list[1]
	self.hb_value = cfg.red_val
	self.hb_txt.text = self.hb_value .. "元"
	self.zshb_txt.text = math.floor(self.hb_value / 2) .. " 福卡"
	self.hint_info_hb_txt.text = math.floor(self.hb_value / 2) .. " 福卡赠礼已存入新手福卡中~"
	self.hint_info_txt.text = "游戏过程中，消除可以提高福卡金额，福卡金额<color=#FFE086FF>满 " .. self.hb_value .. " 可领取</color>。\n消除的倍数越高，福卡金额积攒越快，任务<color=#FFE086FF>时间有限</color>，请抓紧完成哟~"
	if state == 0 then
		self.MB.gameObject:SetActive(true)
		self.UI1.gameObject:SetActive(true)
	else
		self.MB.gameObject:SetActive(false)
		self.UI3.gameObject:SetActive(true)
	end
	self:RefreshJD()
end

function C:RefreshJD()
	local process = self.data.now_process / self.data.need_process
	if process > 1 then
		process = 1
	end
	local vv = process * self.hb_value
	self.slider_txt.text = StringHelper.GetPreciseDecimal(vv, 2) .. "/" .. self.hb_value
	self.slider_num_txt.text = StringHelper.GetPreciseDecimal(vv, 2) .. "/" .. self.hb_value
    self.slider.value = process

	local num = math.ceil( (self.data.need_process - self.data.now_process) / self.bet )
	if self.data.need_process <= self.data.now_process then
		self.need_txt.text = "可领取"
		self.anim.enabled = true
	else
		self.need_txt.text = string.format("再消%s次", num)		
	end
end
function C:UpdateTime(b)
	if not b then
		if self.down_time then
			self.down_time = self.down_time - 1
		end
	end
	if not self.down_time or self.down_time <= 0 then
		self.countdown_txt.text = "00:00:00"
		if self.update_time then
			self.update_time:Stop()
		end
		self.update_time = nil
	else
		local hh = math.floor(self.down_time / 3600)
		local ff = math.floor((self.down_time % 3600) / 60)
		local mm = self.down_time % 60
		self.countdown_txt.text = string.format("%02d:%02d:%02d", hh, ff, mm)
	end
end

function C:on_eliminate_bet_change(bet)
	self.bet = bet[1] * 5
	self:RefreshJD()
end

function C:on_task_change_msg(data)
	if data.id == self._task_id then
		if XXLXRHBManager.is_show(data) then
			self.data = data
	        GameTaskModel.task_process_int_convent_string(self.data)
			if self.data.now_process >= self.data.need_process then
				self.countdown_txt.text = "00:00:00"
				if self.update_time then
					self.update_time:Stop()
				end
				self.update_time = nil
			end
			self:RefreshJD()
    	else
    		self:MyExit()
    	end
	end
end

-- 收下赠礼
function C:OnSXClick()
	PlayerPrefs.SetInt("XXLXRHBPanel" .. MainModel.UserInfo.user_id .. "task" .. self._task_id, 1)
	self.MB.gameObject:SetActive(true)
	self.UI1.gameObject:SetActive(false)
	self.UI2.gameObject:SetActive(true)
	self.sx = true
end
-- 关闭说明
function C:OnCloseHintClick()
	if self.sx then
		EliminateAnimManager.PlayNewPlayerRedTaskAppear(self.parent, Vector3.zero, self.Rect.transform.position, function ()
			ExtendSoundManager.PlaySound(audio_config.game.bgm_by_tiaozhanrenxianshi_game.audio_name)
			self.UI3.gameObject:SetActive(true)
		end)
	end
	self.MB.gameObject:SetActive(false)
	self.UI2.gameObject:SetActive(false)
	self.sx = false
end
-- 领取
function C:OnGetClick()
	if self.data.now_process >= self.data.need_process then
		Network.SendRequest("get_task_award", {id = self._task_id}, "领取")
	else
		self.MB.gameObject:SetActive(true)
		self.UI2.gameObject:SetActive(true)
	end
end

