local basefunc = require "Game/Common/basefunc"

Act_018_MFCDJEnterPrefab = basefunc.class()
local C = Act_018_MFCDJEnterPrefab
C.name = "Act_018_MFCDJEnterPrefab"
local M = Act_018_MFCDJManager
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
	--self.lister["Sys_Guide_3_tips_msg"] = basefunc.handler(self,self.InitUI_Tips)
	self.lister["act_018_mfcd_refresh"] = basefunc.handler(self,self.MyRefresh)
	self.lister["activity_fg_all_info"] = basefunc.handler(self,self.on_activity_fg_all_info)
	self.lister["global_hint_state_change_msg"] = basefunc.handler(self,self.on_global_hint_state_change_msg)
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
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:ctor(parent)
	ExtPanel.ExtMsg(self)
	local parent = parent or GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject("Act_018_MFCDJEnterPrefab", parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	self.parent = parent
	LuaHelper.GeneratingVar(self.transform, self)
	--self.hongbaoAnimator = self.transform:Find("hongbao"):GetComponent("Animator")
	self.hongbao = self.transform:Find("hongbao")
	self:MakeLister()
	self:AddMsgListener()
	self.gameObject:SetActive(false)
	
	--只有在结算界面才会在创建的时候直接展示气泡
	----self.hongbaoAnimator.enabled = false
	if self.parent.gameObject.name == "@right_node" then
		self:InitUI_Tips()
	end
	self:RefreshAct()
	self:InitUI()
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
	local data = M.GetData()
	self.black.gameObject:SetActive(true)
	if data then
		self.num_txt.text = data.now_total_process.."/"..M.GetRightSum()
		self.pro_txt.text = data.now_total_process.."/"..M.GetRightSum()
		self.pro.transform.sizeDelta = {
			x = math.max(0,math.min(1,data.now_total_process/M.GetRightSum())) * 265.12,
			y = 42.23
		}
		local now_max_level = M.CanGetNowLevel()
		if now_max_level <= 15 then
			local level_need = M.all_ju_func(now_max_level) - M.all_ju_func(now_max_level - 1)
			local total = data.now_total_process - M.all_ju_func(now_max_level - 1)
			self.num2_txt.text = "再赢"..level_need - total .."局可领取"
			  
		end
		if data.award_status ~= 1 then
			self.hongbao.transform.localPosition = Vector2.New(0,-50)
			self.hongbao.transform.localScale = Vector2.New(1,1)
			--self.hongbaoAnimator.enabled = false
			self.lizi.gameObject:SetActive(false)
		else
			--self.hongbaoAnimator.enabled = true
			--self.hongbaoAnimator:Play("Act_018_hongbao")
			self.lizi.gameObject:SetActive(true)
			self.num2_txt.text = "可以抽奖了！"
		end
	end
	if M.GetFinshTimes() >= 15 then
		self.num_txt.text = "明日领取"
	end
	if M.IsNextBeOldPlayer() and M.GetFinshTimes() >= 15 then
		self.gameObject:SetActive(false)
	end
end

function C:InitUI_Tips()
	if M.GetFinshTimes() >= 15 	then
		return
	end
	if IsEquals(self.gameObject) then
		self.seq = DoTweenSequence.Create()
		self.seq:AppendInterval(1)
		self.seq:AppendCallback(function ()
			if IsEquals(self.black) then
				self.black.gameObject:SetActive(false)
			end
		end)
		self.seq:Append(self.move_node.transform:DOLocalMoveX(0,0.6))
		self.seq:AppendInterval(2)
		self.seq:Append(self.move_node.transform:DOLocalMoveX(203,0.6))
		self.seq:AppendCallback(
			function ()
				self.black.gameObject:SetActive(true)
			end
		)
		self.seq:OnKill(function ()
			
		end)
	end
end

function C:OnEnterClick()
	Act_018_MFCDJPanel.Create()
end

function C:on_global_hint_state_change_msg(parm)
	if parm.gotoui == M.key then 
		self:MyRefresh()
	end 
end

function C:on_activity_fg_all_info()
	self:RefreshAct()
end

function C:RefreshAct()
	if DdzFreeModel and DdzFreeModel.baseData and DdzFreeModel.baseData.game_id then
		local Show_IDs = {1,2,3,4,33,34,35,36,21,22,23,24}
		local check_func = function(id)
			for i = 1,#Show_IDs do
				if Show_IDs[i] == id then
					return true 
				end
			end
			return false
		end
		if check_func(DdzFreeModel.baseData.game_id) then
			self.gameObject:SetActive(true)
		end
	end
end