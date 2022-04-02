local basefunc = require "Game/Common/basefunc"

CPL_LJYJCFKEnterPrefab = basefunc.class()
local C = CPL_LJYJCFKEnterPrefab
C.name = "CPL_LJYJCFKEnterPrefab"
local M = CPL_LJYJCFKManager
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
	self.lister["cpl_ljyjcfk_refresh"] = basefunc.handler(self,self.MyRefresh)
	self.lister["global_hint_state_change_msg"] = basefunc.handler(self,self.on_global_hint_state_change_msg)

	--消消乐
	self.lister["view_lottery_start"] = basefunc.handler(self,self.LockRefresh)
	self.lister["view_lottery_error"] = basefunc.handler(self,self.UnlockRefresh)
	self.lister["view_lottery_end"] = basefunc.handler(self,self.UnlockRefresh)
	self.lister["eliminate_refresh_end"] = basefunc.handler(self,self.UnlockRefresh)

	--水果消消乐lucky
	self.lister["view_lottery_end_lucky"] = basefunc.handler(self,self.UnlockRefresh)
	--财神消消乐砸蛋
	self.lister["view_lottery_end_nor"] = basefunc.handler(self,self.UnlockRefresh)

	--弹弹乐
	self.lister["ttl_kaijiang_start"] = basefunc.handler(self,self.LockRefresh)
	self.lister["ttl_refresh_end"] = basefunc.handler(self,self.UnlockRefresh)

	self.lister["EnterScene"] = basefunc.handler(self,self.UnlockRefresh)
	self.lister["ExitScene"] = basefunc.handler(self,self.UnlockRefresh)
end

function C:LockRefresh()
	self.lock = true
end

function C:UnlockRefresh()
	self.lock = false
	self:MyRefresh()
end

function C:RemoveListener()
	for proto_name,func in pairs(self.lister) do
		Event.RemoveListener(proto_name, func)
	end
	self.lister = {}
end

function C:MyExit()
	self.lock = nil
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:OnDestroy()
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:ctor(parent)
	ExtPanel.ExtMsg(self)
	local parent = parent or GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject("CPL_LJYJCFKEnterPrefab", parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	self.parent = parent
	LuaHelper.GeneratingVar(self.transform, self)
	self.hongbao = self.transform:Find("hongbao")
	self:MakeLister()
	self:AddMsgListener()
	
	self:InitUI()
	HandleLoadChannelLua(C.name,self)
end

function C:InitUI()
	self.b_btn.onClick:AddListener(function()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		PlayerPrefs.SetString(M.key .. MainModel.UserInfo.user_id, os.date("%Y%m%d",os.time()))
		self:OnEnterClick()
		self:MyRefresh()
	end)
	self:MyRefresh()
end

function C:MyRefresh()
	if self.lock == true then return end
	local data = M.GetData()
	self.black.gameObject:SetActive(true)
	self.LFL.gameObject:SetActive(false)
	if data then
		self:RefreshNumText(data ,M.config.base[1] , M.config.base[2])
		if data.award_status ~= 1 then
			self.hongbao.transform.localPosition = Vector2.New(0,-50)
			self.hongbao.transform.localScale = Vector2.New(1,1)
			self.lizi.gameObject:SetActive(false)
		else
			self.lizi.gameObject:SetActive(true)

			--首次可以获得奖励时小手指提示
			if M.IsFirstGetAward() then
				self.dianji_anim.gameObject:SetActive(true)
			else
				self.dianji_anim.gameObject:SetActive(false)
			end

			Event.Brocast("WZQGuide_Check",{guide = 3 ,guide_step =1})

			if data.award_status == 1 and data.now_total_process == M.config.base[#M.config.base].total then
				self.LFL.gameObject:SetActive(true)
			end
		end
		if data.award_status == 2 and data.now_lv == M.task_c then
			self.num_txt.text = "明日领取"
		end
	end
end

function C:OnEnterClick()
	self.dianji_anim.gameObject:SetActive(false)
	M.SetFirstGetAward()
	CPL_LJYJCFKPanel.Create()
end

function C:on_global_hint_state_change_msg(parm)
	if parm.gotoui == M.key then 
		self:MyRefresh()
	end 
end

function C:RefreshNumText(data,base1,base2)
	self.num_txt.text = StringHelper.ToCash(data.now_total_process) .."/".. StringHelper.ToCash(data.need_process + data.now_total_process - data.now_process)
end