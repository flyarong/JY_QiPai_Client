local basefunc = require "Game/Common/basefunc"

Act_028_WQP_MFCFKEnterPrefab = basefunc.class()
local C = Act_028_WQP_MFCFKEnterPrefab
C.name = "Act_028_WQP_MFCFKEnterPrefab"
C.now_game_id = nil
local M = Act_028_WQP_MFCFKManager
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
	self.lister["ExitScene"] = basefunc.handler(self,self.MyExit)
	self.lister["act_028_wqp_btn_refresh"] = basefunc.handler(self,self.on_act_028_wqp_btn_refresh)
	self.lister["activity_fg_all_info"] = basefunc.handler(self,self.on_activity_fg_all_info)
	self.lister["Act_028_WQP_MFCFK_refresh"] = basefunc.handler(self,self.on_Act_028_WQP_MFCFK_refresh)
	self.lister["model_fg_all_info"] = basefunc.handler(self,self.on_model_fg_all_info) --比赛房间内的数据

end

function C:RemoveListener()
	for proto_name,func in pairs(self.lister) do
		Event.RemoveListener(proto_name, func)
	end
	self.lister = {}
end

function C:MyExit()
	C.now_game_id = nil
	self.huxi.Stop()
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:OnDestroy()
	self:MyExit()
end

function C:ctor(parent)
	ExtPanel.ExtMsg(self)
	local parent = parent or GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject("Act_028_WQP_MFCFKEnterPrefab", parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	self.parent = parent
	LuaHelper.GeneratingVar(self.transform, self)
	--self.hongbaoAnimator = self.transform:Find("hongbao"):GetComponent("Animator")
	self.hongbao = self.transform:Find("hongbao")
	self:MakeLister()
	self:AddMsgListener()
	self.huxi = CommonHuxiAnim.Go(self.LFL.gameObject,1)
	--self.gameObject:SetActive(false)
	
	--只有在结算界面才会在创建的时候直接展示气泡
	----self.hongbaoAnimator.enabled = false

	self:InitUI()
	self:on_act_028_wqp_btn_refresh()
end

function C:InitUI()
	self.b_btn.onClick:AddListener(function()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		PlayerPrefs.SetString(M.key .. MainModel.UserInfo.user_id, os.time())
		self:OnEnterClick()
		self:MyRefresh()
	end)
	self:MyRefresh()
end

function C:MyRefresh()
	if not IsEquals(self.gameObject) then return end
	local st = M.GetHintState()
	self.huxi.Stop()
	self.LFL.gameObject:SetActive(false)
	self.Red.gameObject:SetActive(false)
	if st == ACTIVITY_HINT_STATUS_ENUM.AT_Red then
		self.Red.gameObject:SetActive(true)
	elseif st == ACTIVITY_HINT_STATUS_ENUM.AT_Get then
		self.LFL.gameObject:SetActive(true)
		self.huxi.Start()
		
		--if M.IsFirstGetAward() then
			--self.dianji_anim.gameObject:SetActive(true)
			--Event.Brocast("ddzgameclearing_into_finish")
		--end
	end
	self:RefreshAct()

	if MainModel.myLocation == "game_DdzFree" then
		self.icon_img.gameObject:SetActive(false)
		self.icon_txt.text=self:ReGameNumber()
	else
		self.icon_img.gameObject:SetActive(true)
		self.icon_txt.text=""
	end
	
end

function C:InitUI_Tips()
	
end

function C:OnEnterClick()
	Act_028_WQP_MFCFKPanel.Create(self:GetBestIndex())
end

function C:on_Act_028_WQP_MFCFK_refresh()
	self:MyRefresh()
end

function C:on_activity_fg_all_info(data)
	dump(data,"<color=red>CPL免费抽福卡按钮数据</color>")
	self:RefreshAct(data.game_id)
end


function C:RefreshAct(id)
	id = id or C.now_game_id
	dump(id)
	if id then
		C.now_game_id = id
		local game_ids = {
			[1] = {1,33,5,21,37,17,13},
			[2] = {2,34,6,22,38,18,14},
			[3] = {3,35,7,23,39,19,15},
			[4] = {4,36,8,24,40,20,16},
		}
		local now_level = 1
		for i = 1,#game_ids do
			for j = 1,#game_ids[i] do
				if game_ids[i][j] == id then
					now_level = i
					break
				end
			end
		end
		self.now_level = now_level
		local data = M.GetData(now_level)
		if data then
			--当目前的任务没有全部完成
			if data.award_status ~= 2 then
				if IsEquals(self.gameObject) then
					self.black.gameObject:SetActive(false)
				end
			else
				local all_finsh = true
				for i = 1,4 do
					local data = M.GetData(i)
					if data and data.award_status ~= 2 then
						all_finsh = false
						break
					end
				end
				self.black.gameObject:SetActive(true)
				if all_finsh then
					self.num_txt.text = "明日再来"
				--确认过，即使玩家在最高场也这么显示
				else
					self.num_txt.text = "更高场可领"
				end
			end
		end
	end
end

function C:GetGameIndexByGameID()
	local gameCfg = GameFreeModel.GetGameIDToConfig(DdzFreeModel.baseData.game_id)
	if table_is_null(gameCfg) then return end
	local gameMap = GameFreeModel.GetGameConfig(gameCfg.game_type)
	local gameList = {}
	for k,v in pairs(gameMap) do
		gameList[#gameList + 1] = v
	end
	gameList = MathExtend.SortList(gameList, "game_id", true)
	for i,v in ipairs(gameList) do
		if v.game_id == DdzFreeModel.baseData.game_id then
			return i
		end
	end
end

function C:ReGameNumber()
	local re_str=""
	local game_index = self:GetGameIndexByGameID()
	if game_index ~= nil then
		re_str=M.GetWinTimes(game_index).."/"..M.GetRightSum(game_index)
	end
	return re_str
end

function C:GetBestIndex()
	local index = nil
	for i = 1,4 do
		local data = M.GetData(i)
		if data and data.award_status == 1 then
			index = i
			break
		end
	end
	return index or self.now_level or 1
end

function C:on_act_028_wqp_btn_refresh()
	if IsEquals(self.gameObject) then
		if Act_028_WQP_MFCFKManager.IsCanShowBtn() then
			self.gameObject:SetActive(true)
		else
			self.gameObject:SetActive(false)
		end
	end
end

function C:on_model_fg_all_info()
	self:MyRefresh()
end