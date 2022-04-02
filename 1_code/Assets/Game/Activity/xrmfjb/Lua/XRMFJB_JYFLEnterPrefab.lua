local basefunc = require "Game/Common/basefunc"
XRMFJB_JYFLEnterPrefab = basefunc.class()
local C = XRMFJB_JYFLEnterPrefab
local TOTAL_NUM = 2
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
    self.lister["model_query_broke_beg_num"] = basefunc.handler(self, self.model_query_broke_beg_num)
    self.lister["xrmfjb_player_new_change_to_old"] = basefunc.handler(self, self.player_new_change_to_old)
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
	local obj = newObject("XRMFJB_JYFLEnterPrefab", parent)
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
	self:MyRefresh()
end

function C:MyRefresh()
	self.broke_beg_num = XRMFJBManager.get_broke_beg_num()
	if not self.broke_beg_num or self.broke_beg_num == 0 then
		self.gameObject:SetActive(false)
		return
	end
	self.gameObject:SetActive(true)
	self.time_txt.text = string.format( "还可领%s次",self.broke_beg_num)
	local process = 1 - self.broke_beg_num / TOTAL_NUM
	if process > 1 then
		process = 1
	end
	self.slider.value = process
	self.slider_txt.text = string.format( "%s/%s",TOTAL_NUM - self.broke_beg_num,TOTAL_NUM)
	local gold = MainModel.UserInfo.jing_bi
	if not gold or gold >= 3000 then
		self.get_img.sprite = GetTexture("com_btn_8")
	else
		self.get_img.sprite = GetTexture("com_btn_5")
	end
end

function C:OnEnterClick()
	self:get_broke_beg()
end
function C:OnGetClick()
	self:get_broke_beg()
end

function C:OnDestroy()
	self:MyExit()
end

function C:get_broke_beg()
	if self.broke_beg_num and self.broke_beg_num == 0 then
		LittleTips.Create("今日已领取完成，请明日再来")
		return
	end
	local gold = MainModel.UserInfo.jing_bi
	if not gold or gold >= 3000 then
		LittleTips.Create("鲸币低于3000时可免费领取")
		return
	end
	XRMFJBManager.broke_beg()
end

function C:on_global_hint_state_change_msg(parm)
	if parm.gotoui == XRMFJBManager.key then
		self:MyRefresh()
	end
end

function C:model_query_broke_beg_num()
	self:MyRefresh()
end

function C:player_new_change_to_old(parm)
	if parm.gotoui == XRMFJBManager.key then
		self:MyExit()
	end
end