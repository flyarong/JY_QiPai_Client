local basefunc = require "Game.Common.basefunc"

local ICON_HEIGHT = 120


ShatterGoldenEggPanel = basefunc.class()
ShatterGoldenEggPanel.name = "ShatterGoldenEggPanel"

SG_Config = {
	EnableAutoHit = false,	--自动砸蛋
	OpenShopOnCloseSale = not false,  --不够卖礼包，关闭界面后弹出商城
	AutoSelHammerOnEnter = not false,  --进入界面自动选择锤子
	Enable2EggMode = not false,
}

local instance = nil

local CS = {
	Show = 1,
	Hide = 2,
	ShowToHide = 3,
	HideToShow = 4
}

local lister = {}
function ShatterGoldenEggPanel:MakeLister()
	lister = {}
	lister["view_sge_hammer"] = basefunc.handler(self, self.handle_sge_hammer)
	lister["view_sge_spawn"] = basefunc.handler(self, self.handle_sge_spawn)
	lister["view_sge_hit"] = basefunc.handler(self, self.handle_sge_hit)
	lister["view_sge_hit_nomoney"] = basefunc.handler(self, self.handle_sge_hit_nomoney)
	lister["view_sge_exception"] = basefunc.handler(self, self.handle_sge_exception)

	lister["AssetChange"] = basefunc.handler(self, self.handle_asset_change)

	lister["PayPanelClosed"] = basefunc.handler(self, self.handle_update_money)
	lister["ReceivePayOrderMsg"] = basefunc.handler(self, self.OnReceivePayOrderMsg)

	lister["model_task_change_msg"] = basefunc.handler(self, self.handle_task_change)
	lister["view_sge_event_begin"] = basefunc.handler(self, self.handle_sge_event_begin)
	lister["view_sge_event_end"] = basefunc.handler(self, self.handle_sge_event_end)
	lister["view_sge_event_over"] = basefunc.handler(self, self.handle_sge_event_over)
	lister["view_sge_sale_close"] = basefunc.handler(self, self.handle_sge_sale_close)
	lister["view_sge_sale_countdown"] = basefunc.handler(self, self.handle_sge_sale_countdown)
	--lister["view_sge_show_sale"] = basefunc.handler(self, self.handle_sge_show_sale)
	lister["view_sge_hide_sale"] = basefunc.handler(self, self.handle_sge_hide_sale)
	lister["model_sge_exception"] = basefunc.handler(self, self.on_model_sge_exception)
	lister["2egg_bet_change"]=basefunc.handler(self, self.bet2eggchange)
    lister["ReConnecteServerSucceed"] = basefunc.handler(self, self.ReConnecteServerSucceed)
end

function ShatterGoldenEggPanel:bet2eggchange(data)
	--基础的押注index
	self.base2eggindex=data
	local b=ShatterGoldenEggModel.getConfig().extra2eggs[self.base2eggindex].base_money
	self.egg_2bet_txt.text= StringHelper.ToCash(b)
end

function ShatterGoldenEggPanel.Create(param)
	if not instance then
		instance = ShatterGoldenEggPanel.New(param)
	end
	return instance
end

function ShatterGoldenEggPanel:ctor(param)
	local parent = GameObject.Find("Canvas/LayerLv1").transform
	local obj = newObject(ShatterGoldenEggPanel.name, parent)
	self.transform = obj.transform
	LuaHelper.GeneratingVar(self.transform, self)

	self:MakeLister()
	ShatterGoldenEggLogic.setViewMsgRegister(lister, ShatterGoldenEggPanel.name)

	self.goto2EggMode = param == "mode_cs"
	self.ItemRoundParentList = {}
	self.ItemRoundList = {}
	self.ItemButtonList = {}
	self.locked = false
	self.timerParams = {}

	self.EffectMap = {}
	self.EffectMap["_P_"] = {}
	
	self.EffectMap["_I_"] = {}

	local DACHUI_TBL = {"DaChui_YwdJ", "BigHammer", "ZJD_Title"}
	for _, v in pairs(DACHUI_TBL) do
		local hammer = self:CreateItem(parent, GetPrefab(v))
		hammer.gameObject:SetActive(false)
		self.EffectMap["_I_"][v] = hammer
	end

	self:InitRect()

	local btn_map = {}
	btn_map["right_top"] = {self.rt_btn_1, self.rt_btn_2}
	self.game_btn_pre = GameButtonPanel.Create(btn_map, "qql_game")

	--DOTweenManager.OpenPopupUIAnim(self.transform)
	Event.Brocast("qql_panel_created",{panelSelf = self})
end

function ShatterGoldenEggPanel:Awake()
	ExtendSoundManager.PlaySceneBGM(audio_config.qql.bgm_zajindanbeijing.audio_name)
end

function ShatterGoldenEggPanel.Close()
	if instance then
		instance:StopAutoHitTask()
		instance:StopTween()
		if instance.game_btn_pre then
			instance.game_btn_pre:MyExit()
			instance.game_btn_pre = nil
		end

		instance:StopComboHit19()

		ShatterGoldenEggModel.IsInited = false
		ShatterGoldenEggLogic.clearViewMsgRegister(ShatterGoldenEggPanel.name)
		instance:ClearAll()
		--[[if IsEquals(instance.transform) and IsEquals(instance.transform.gameObject) then
			GameObject.Destroy(instance.transform.gameObject)
		end
		instance = nil]]--
		Event.Brocast("view_sge_close")
		ExtendSoundManager.PlaySceneBGM(audio_config.game.bgm_main_hall.audio_name)
	end
end

function ShatterGoldenEggPanel:InitRect()
	local transform = self.transform

	local curtain = transform:Find("Curtain")
	curtain.gameObject:SetActive(true)

	self.back_btn.onClick:AddListener(function()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		--Network.SendRequest("zjd_exit_game")

		local callback = function(  )
			local hint = HintPanel.Create(4, "好运马上就来，您确定现在离开么？", function ()
				Event.Brocast("ZJDQuit")
				Network.SendRequest("zajindan_quit_game")
			end)
			hint:SetBtnTitle("确  定", "取  消")
		end
	
		local a,b = GameButtonManager.RunFun({gotoui="cpl_ljyjcfk",callback = callback}, "CheckMiniGame")
		if a and b then
			return
		end
	
		callback()
	end)

	self.spawn_btn.onClick:AddListener(function()
		ExtendSoundManager.PlaySound(audio_config.qql.bgm_huanyipi.audio_name)
		local hammer_idx = ShatterGoldenEggLogic.GetHammer()
		self:SpawnEggs(hammer_idx)
	end)
	self.spawn_btn.interactable = true
	self.egg_2bet_btn=self.transform:Find("BottomRect/egg_2bet_btn"):GetComponent("Button")
	self.egg_2bet_btn.gameObject:SetActive(false)
	self.egg_2bet_txt=self.egg_2bet_btn.gameObject.transform:Find("@egg_2bet_txt"):GetComponent("Text")
	self.ranking_btn.gameObject:SetActive(false)
	self.ranking_btn.onClick:AddListener(function()
		HintPanel.Create(1, "暂未开放", nil, nil, self.popLayer)
		--ShatterGoldenEggRanking.Create(self.ranking_btn.transform)
	end)

	self.award_btn.onClick:AddListener(function()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		if ShatterGoldenEggAward.IsShow() then
			ShatterGoldenEggAward.Close()
		else
			ShatterGoldenEggAward.Create(self.award_point.transform)
		end
	end)

	self.gold_btn.onClick:AddListener(function()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:OpenShop()
	end)

	self.help_btn.onClick:AddListener(function()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		if ShatterGoldenEggHelp.IsShow() then
			ShatterGoldenEggHelp.Close()
		else
			ShatterGoldenEggHelp.Create(self.popLayer)
		end
	end)

	self.event_node.gameObject:SetActive(false)
	self.sale_node.gameObject:SetActive(false)
	if GameGlobalOnOff.ZJD_EVE then
		self.event_btn.onClick:AddListener(function()
			if self.is2EggMode then
				ShatterGoldenEvent2Egg.Create(self.ShopNode)
			else
				ShatterGoldenEvent.Create(self.ShopNode)
			end
		end)
		local event_active = ShatterGoldenEggModel.GetActivityState("normal")
		if event_active > 0 then
			self.event_node.gameObject:SetActive(true)
			if event_active == 1 then
				self.showNormalEvent = true
				ShatterGoldenEvent.Create(self.ShopNode)
			end
		end
		self.sale_btn.onClick:AddListener(function()
			local hammer_idx = ShatterGoldenEggLogic.GetHammer()
			local logic = ShatterGoldenEggModel.getLogicConfig(hammer_idx)
			if logic and logic.sale then
				GameManager.GotoUI({gotoui = "gift_shatter_golden_sale",goto_scene_parm = "panel",parm1 = self.ShopNode, parm2 = hammer_idx, parm3 = basefunc.handler(self, self.OnCloseSaleBox)})
			end
		end)
		self.sale_btn.gameObject:SetActive(GameGlobalOnOff.LIBAO)
	end

	local logics = ShatterGoldenEggModel.getLogicConfig(-1)
	if not logics then
		print("[SGE] InitRect logics is invalid")
		return
	end

	--show btns
	for k, v in ipairs(logics) do
		self.timerParams[k] = {}
		self.timerParams[k].interval = -1

		local btn = self:CreateItem(self.list_button, GetPrefab(v.button))
		self:ChangeButtonSkin(btn, v.button_icon)

		local btnComponent = btn.transform:Find("up_btn"):GetComponent("Button")
		local config_idx = k
		btnComponent.onClick:AddListener(function()
			if not self.enableAutoHitEgg and self:CanSwitchHammer(config_idx, not self.is2EggMode) then
				ExtendSoundManager.PlaySound(audio_config.qql.bgm_huanchuizi.audio_name)

				local hammer_idx = config_idx
				if self.is2EggMode then
					ShatterGoldenEggModel.setExtra2EggsData("mode_hammer", config_idx)
				else
					ShatterGoldenEggModel.setExtra2EggsData("mode_hammer", 0)
				end
				
				self:ShowCurtain(function()					
					if self.is2EggMode then
						self.event_node.gameObject:SetActive(ShatterGoldenEggModel.GetActivityState("caishen") > 0)
						self:CheckShowEvent()
					end
					ShatterGoldenEggLogic.SendHammer(hammer_idx)

					--hide sale countdown
					ShatterGoldenEggLogic.SetHammerData(ShatterGoldenEggLogic.GetHammer(), "sale_countdown", 0)
					self.sale_node.gameObject:SetActive(false)
				end)
			end
		end)

		self.ItemButtonList[#self.ItemButtonList + 1] = btn
	end

	self.spawnTimer = Timer.New(function ()
		local hammer_idx = ShatterGoldenEggLogic.GetHammer()
		if self.is2EggMode then
			hammer_idx = ShatterGoldenEggModel.getExtra2EggsData("mode_hammer") or hammer_idx
		end

		for k, v in pairs(self.timerParams) do
			local interval = v.interval or -1
			if interval >= 0 then
				interval = interval - 0.1

				if interval <= 0 then
					interval = -1

					local force_spawn = v.force_spawn or false
					if k == hammer_idx then
						if force_spawn or not ShatterGoldenEggLogic.CheckStates(hammer_idx) then
							self:ShowCurtain(function()
								self:SendSpawnEggs(k)
							end)
						end
					end
					v.force_spawn = false
				end
				v.interval = interval
			end
		end
	end, 0.1, -1)
	self.spawnTimer:Start()

	self:InitEggNodeList()

	self.curtainState = CS.Show
	self.totalMoney = MainModel.UserInfo.jing_bi or 0
	self.flyingMoney = 0

	ShatterGoldenEggLogic.SendStatus()

	--newbie
	local SGE_ID = "_SGE_COUNT_"
	if not PlayerPrefs.HasKey(SGE_ID) then
		PlayerPrefs.SetInt(SGE_ID, 1)

		LittleTips.Create("每一局最多可以砸6个金蛋", nil, {bg = "com_bg_notice"})
	else
		local sge_count = PlayerPrefs.GetInt(SGE_ID)
		sge_count = sge_count + 1
		PlayerPrefs.SetInt(SGE_ID, sge_count)
	end

	EventTriggerListener.Get(self.skip_btn.gameObject).onClick = basefunc.handler(self, self.SkipAnimation)
	self:InitAutoHitEgg()
	self.lights.gameObject:SetActive(false)
	self.mode_btn.gameObject:SetActive(SG_Config.Enable2EggMode)
	self.mode_idx_btn.gameObject:SetActive(false)
	self.ZJD_dengguang.gameObject:SetActive(false)
	ShatterGoldenEggLogic.SetPlayMode(0)
	self.is2EggMode = false
	if not self.is2EggMode then
		DSM.PushAct({panel = "QQLPanel"})
	end
	self.enableAction = true
	self.mode_btn.onClick:AddListener(basefunc.handler(self, self.OnSwitchMode))
	self.mode_idx_btn.onClick:AddListener(function()
		-- ExtendSoundManager.PlaySound(audio_config.qql.bgm_huanyipi.audio_name)

		-- if not self:CanAction() or not self.enableAction then return end

		-- local mode_idx = ShatterGoldenEggModel.getExtra2EggsData("mode_idx") or 0
		-- mode_idx = (mode_idx + 1) % 2
		-- ShatterGoldenEggModel.setExtra2EggsData("mode_idx", mode_idx)

		-- --[[local img = self.mode_idx_btn.transform:GetComponent("Image")
		-- if mode_idx == 1 then
		-- 	img.sprite = GetTexture("zjd_btn_hdc1")
		-- else
		-- 	img.sprite = GetTexture("zjd_btn_hdc")
		-- end]]--

		-- local hammer_idx = self:SelectBestHammer(false)
		-- ShatterGoldenEggModel.setExtra2EggsData("mode_hammer", hammer_idx)

		-- --Event.Brocast("view_sge_hammer", hammer_idx)
		-- ShatterGoldenEggLogic.SendHammer(hammer_idx)
		if self:CanAction() then
			ShatterGolden2EggsBetPanel.Create(self.transform)
		end 

	end)

	ShatterGoldenEggModel.SetHitEggCount(6)
	HandleLoadChannelLua("ShatterGoldenEggPanel",self)
end

function ShatterGoldenEggPanel:SpawnEggs(hammer_idx)
	if not self.is2EggMode then
		local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key="zajindan_lv_"..hammer_idx,vip_hint_type = 2, cw_btn_desc = "确定"}, "CheckCondition")
	    if a and not b then
	    	return
	    end
	end
	if not self.enableAutoHitEgg then
		if self:CanSpawnEggs(hammer_idx) then
			self:PushTimer(hammer_idx, 0)
			self.timerParams[hammer_idx].force_spawn = true
			self:SpawnNotice(hammer_idx)
		end
	end
end

function ShatterGoldenEggPanel:OnSwitchMode(idx)
	if not IsEquals(self.transform.gameObject) then
		Event.Brocast("ZJDQuit")
		return
	end

	if self.enableAutoHitEgg then
		LittleTips.Create("请先关闭自动砸蛋！", nil, {bg = "com_bg_notice"})
	elseif self:CanAction() and self.enableAction then
		local playMode = ShatterGoldenEggLogic.GetPlayMode()
		playMode = (playMode + 1) % 2
		ShatterGoldenEggLogic.SetPlayMode(playMode)

		local hammerId = idx or ShatterGoldenEggLogic.GetHammer()
		self.is2EggMode = not self.is2EggMode
		if not self.is2EggMode then
			DSM.PopAct()
			DSM.PushAct({panel = "QQLPanel"})
		else
			DSM.PopAct()
			DSM.PushAct({panel = "QQLCSPanel"})
		end
		self.spawn_btn.gameObject:SetActive(not self.is2EggMode)
		self.table.gameObject:SetActive(not self.is2EggMode)
		self.table_2Egg.gameObject:SetActive(self.is2EggMode)
		self.points.gameObject:SetActive(not self.is2EggMode)
		self.points_cs.gameObject:SetActive(self.is2EggMode)
		self.QQL_animator.gameObject:SetActive(not self.is2EggMode)
		self.Title_cs.gameObject:SetActive(self.is2EggMode)
		self.ZJD_dengguang.gameObject:SetActive(self.is2EggMode)
		self.modebtn_vfx.gameObject:SetActive(not self.is2EggMode)
		-- GetTexture("zjd_btn_ptms2")
		-- GetTexture("zjd_icon12_1")
		-- GetTexture("zjd_btn_ptms")
		-- GetTexture("zjd_btn_csms")
		
		self.modeIcon_img.sprite = GetTexture(self.is2EggMode and "zjd_btn_ptms2" or "zjd_icon12_1")
		self.modebtn_img.sprite = GetTexture(self.is2EggMode and "zjd_btn_ptms" or "zjd_btn_csms")
		self.mode_idx_btn.gameObject:SetActive(self.is2EggMode)
		ShatterGoldenEggModel.SetHitEggCount(self.is2EggMode and 1 or 6)
		self:InitEggNodeList()

		local btnLast = #self.ItemButtonList
		if self.is2EggMode then
			self.list_button.gameObject:SetActive(false)
			self.egg_2bet_btn.gameObject:SetActive(true)
			ExtendSoundManager.PlaySound(audio_config.qql.bgm_huanyipi.audio_name)
			self.is2EggModeBestBet= ShatterGoldenEggModel.getConfig().extra2eggs[ShatterGolden2EggsBetPanel.GetBestBet()].base_money 			
			self.base2eggindex=ShatterGolden2EggsBetPanel.GetBestBet()
			self.egg_2bet_txt.text=StringHelper.ToCash(self.is2EggModeBestBet)
			self.ItemButtonList[btnLast].gameObject:SetActive(false)
			local mode_hammer = self:SelectBestHammer(false)
			ShatterGoldenEggModel.setExtra2EggsData("mode_hammer", mode_hammer)

			ShatterGoldenEggLogic.SendHammer(mode_hammer)

			--[[if mode_hammer ~= hammerId then
				ShatterGoldenEggLogic.SendHammer(mode_hammer)
			else
				--self:SpawnEggs(mode_hammer)
				Event.Brocast("view_sge_hammer", mode_hammer)
			end]]--
			
			--[[local mode_hammer = ShatterGoldenEggModel.getExtra2EggsData("mode_hammer") or hammerId
			if mode_hammer ~= hammerId then
				ShatterGoldenEggLogic.SendHammer(hammerId)
				return
			end
			self:SpawnEggs(hammerId)]]--
		else
			ExtendSoundManager.PlaySound(audio_config.qql.bgm_huanyipi.audio_name)
			self.list_button.gameObject:SetActive(true)
			self.egg_2bet_btn.gameObject:SetActive(false)
			self.ItemButtonList[btnLast].gameObject:SetActive(true)
			ShatterGoldenEggModel.RecoveryData(-1)

			ShatterGoldenEggModel.setExtra2EggsData("mode_hammer", 0)
			local mode_hammer = self:SelectBestHammer(true)
			--if mode_hammer ~= hammerId then
			ShatterGoldenEggLogic.SendHammer(mode_hammer)
			--end

			--[[local mode_idx = ShatterGoldenEggModel.getExtra2EggsData("mode_idx") or 0
			if mode_idx == 1 and hammerId ~= 3 then
				ShatterGoldenEggLogic.SendHammer(3)
				return
			else
				ShatterGoldenEggLogic.SendHammer(hammerId)
			end]]--
		end

		self:UpdateHammerButton()
		self:UpdateReplaceMoney()
		self:CheckShowEvent()
		self:SwitchHammerButton()
	else
		LittleTips.Create("点击过快，请稍后尝试......", nil, {bg = "com_bg_notice"})
	end
end
function ShatterGoldenEggPanel:CheckShowEvent()
	local eventState = ShatterGoldenEggModel.GetActivityState(self.is2EggMode and "caishen" or "normal")
	self.event_node.gameObject:SetActive(eventState > 0)
	if eventState == 1 then
		if self.is2EggMode and not self.show2EggEvent then
			--self.show2EggEvent = true
			ShatterGoldenEvent2Egg.Create(self.ShopNode)
		elseif not self.is2EggMode and not self.showNormalEvent then
			self.showNormalEvent = true
			ShatterGoldenEvent.Create(self.ShopNode)
		end
	end
end
--[[function ShatterGoldenEggPanel:SaveHammerData(idx)
	local hammerId = idx or ShatterGoldenEggLogic.GetHammer()
	local stats = ShatterGoldenEggModel.getStates(hammerId)
	local awards = ShatterGoldenEggModel.getAward(hammerId)
	if stats and #stats == 12 then
		self.normalModelStates = stats
	end
	if awards and #awards == 12 then
		self.normalModelAwards = awards
	end
	dump(self.normalModelStates, "<color=green>Save normalModelStates:" .. hammerId .. "</color>")
	dump(self.normalModelAwards, "<color=green>Save normalModelAwards:" .. hammerId .. "</color>")
end
function ShatterGoldenEggPanel:RecoverHammerData(idx)
	local hammerId = idx or ShatterGoldenEggLogic.GetHammer()
	if self.normalModelStates then
		dump(self.normalModelStates, "<color=green>Recover normalModelStates:" .. hammerId .. "</color>")
		ShatterGoldenEggModel.setStates(hammerId, self.normalModelStates)
		self.normalModelStates = nil
	end
	if self.normalModelAwards then
		dump(self.normalModelAwards, "<color=green>Recover normalModelAwards:" .. hammerId .. "</color>")
		ShatterGoldenEggModel.SetAward(hammerId, self.normalModelAwards)
		self.normalModelAwards = nil
	end
end]]--

function ShatterGoldenEggPanel:InitEggNodeList()
	local table_transform = self.is2EggMode and self.table_2Egg or self.table
	local count = table_transform.childCount

	if self.ItemRoundParentList and #self.ItemRoundParentList > 0 then
		for i = 1, #self.ItemRoundParentList do
			self.ItemRoundParentList[i] = nil
		end
	end

	self.ItemRoundParentList = {}
	for i = 1, count, 1 do
		local point_transform = table_transform:Find("point_" .. i)
		self.ItemRoundParentList[i] = point_transform
	end
end

function ShatterGoldenEggPanel:Refresh()
	self:ClearItemList(self.ItemRoundList)
	self.ItemRoundList = {}

	local hammer_idx = ShatterGoldenEggLogic.GetHammer()
	local logic = ShatterGoldenEggModel.getLogicConfig(hammer_idx)
	if not logic then
		print("[SGE] Refresh getLogicConfig failed:" .. hammer_idx)
		return
	end

	local state = ShatterGoldenEggModel.getStates(hammer_idx)
	if not state then
		print("[SGE] Refresh getStates failed:" .. hammer_idx)
		return
	end

	local stateConfig = ShatterGoldenEggModel.getStateConfig()
	local count = #state
	local eggConfig = logic.egg
	for i = 1, count, 1 do
		local egg = self:CreateItem(self.ItemRoundParentList[i], GetPrefab(eggConfig.prefab))
		egg.gameObject.name = i
		self.ItemRoundList[i] = egg

		local stamp = 1
		local current_state = state[i]
		if current_state == stateConfig.STAND then
			stamp = 0	--math.random(0, 100) * 0.01
		elseif current_state > stateConfig.DMG_MAX then
			current_state = stateConfig.DMG_MAX
		end
		local action = eggConfig.action[tostring(current_state)]
		if not action then
			print(string.format("[SGE] Refresh hammer(%d) egg(%d) action(%d) failed", hammer_idx, i, current_state))
			return
		end
		self:PlayAnimation(egg, action, stamp)

		--[[EventTriggerListener.Get(egg.gameObject).onClick = basefunc.handler(egg, function()
			if not self:CanAction() then return end
			local egg_state = state[i]
			if egg_state == stateConfig.BROKEN then
				print(string.format("[Debug] SGE Refresh hammer(%d) egg(%d) is broken", hammer_idx, i))
				return
			end

			self:HammerHit(i)
		end)]]
		EventTriggerListener.Get(egg.gameObject).onClick = function ()
			if not self.enableAutoHitEgg then
				self:HitEgg(egg)
			end
		end
	end

	self.totalMoney = MainModel.UserInfo.jing_bi or 0
	self.flyingMoney = 0

	self:UpdateReplaceMoney()
	self:UpdateHammerButton()
	self:UpdateGold()
	self:UpdateEggTotal()
	self:RefreshTask()
end

function ShatterGoldenEggPanel:IsMoneyEnough()
	local hammer_idx = ShatterGoldenEggLogic.GetHammer()
	if self.is2EggMode then 
		hammer_idx=self.base2eggindex
	end 
	local hammerPrice = ShatterGoldenEggModel.getBaseMoney(hammer_idx, self.is2EggMode)
	return MainModel.GetItemCount("jing_bi") >= hammerPrice
end

function ShatterGoldenEggPanel:RecoverAutoHitState()
	self:SwitchAutoHitEgg(self:IsMoneyEnough())
end

function ShatterGoldenEggPanel:OpenShop()
	local cb = self.enableAutoHitEgg and basefunc.handler(self, self.RecoverAutoHitState) or nil
	Event.Brocast("show_gift_panel",{pay_cb = cb})
	if not self:IsMoneyEnough() then
		self:SwitchAutoHitEgg(false)
	end
end

local CountAnim = {"", ".", "..", "..."} --, "....", ".....", "......"}
function ShatterGoldenEggPanel:UpdateAutoHitTip()
	self.TipAnimCount = self.TipAnimCount and self.TipAnimCount + 1 or 2
	self.autoHitTip_txt.text = "自动砸蛋中" .. CountAnim[self.TipAnimCount]
	if self.TipAnimCount == #CountAnim then
		self.TipAnimCount = 1
	end
end

function ShatterGoldenEggPanel:InitAutoHitEgg()
	if not SG_Config.EnableAutoHit then
		self.autoHit_btn.gameObject:SetActive(false)
		return
	end

	self.autoHitEggTask = Timer.New(basefunc.handler(self, self.AutoHitEgg), 1, -1, false)
	self.updateAutoHitTip = Timer.New(basefunc.handler(self, self.UpdateAutoHitTip), 1, -1, false)
	self:SwitchAutoHitEgg(false)
	self.enableAutoHitEgg = false
	EventTriggerListener.Get(self.autoHit_btn.gameObject).onClick = function()
		self:SwitchAutoHitEgg()
	end
	EventTriggerListener.Get(self.autoHit_btn.gameObject).onDown = function ()
		self.automatic_glow.transform.localPosition = self.autoHitPressed.transform.localPosition
	end
	EventTriggerListener.Get(self.autoHit_btn.gameObject).onUp = function ()
		self.automatic_glow.transform.localPosition = self.autoHitReleased.transform.localPosition
	end
	EventTriggerListener.Get(self.autoHit_btn.gameObject).onExit = function ()
		self.automatic_glow.transform.localPosition = self.autoHitReleased.transform.localPosition
	end
end

function ShatterGoldenEggPanel:StopAutoHitTask()
	if self.autoHitEggTask and self.updateAutoHitTip then
		self:SwitchAutoHitEgg(false)
		self.autoHitEggTask = nil
		self.updateAutoHitTip = nil
	end
end

function ShatterGoldenEggPanel:SwitchAutoHitEgg(enable)
	if not SG_Config.EnableAutoHit then
		return
	end

	if enable ~= nil then
		self.enableAutoHitEgg = enable
	else
		self.enableAutoHitEgg = not self.enableAutoHitEgg
	end

	if self.enableAutoHitEgg then
		self.TipAnimCount = 1
		self.autoHitTip_txt.text = "自动砸蛋中"
		self.autoHitEggTask:Start()
		self.updateAutoHitTip:Start()
		self.autoHitTip.gameObject:SetActive(true)
	else
		self.autoHitEggTask:Stop()
		self.updateAutoHitTip:Stop()
		self.autoHitTip.gameObject:SetActive(false)
	end
	self.enableAuto.gameObject:SetActive(not self.enableAutoHitEgg)
	self.disableAuto.gameObject:SetActive(self.enableAutoHitEgg)
	self.autoHitTip.gameObject:SetActive(self.enableAutoHitEgg)
	self.spawn_btn.enabled = not self.enableAutoHitEgg
	--self.mode_btn.enabled = not self.enableAutoHitEgg

	for i, btn in ipairs(self.ItemButtonList) do
		btn.transform:Find("up_btn"):GetComponent("Button").enabled = not self.enableAutoHitEgg
	end
end

function ShatterGoldenEggPanel:OnCloseSaleBox(isBoughtGiftBox)
	if SG_Config.OpenShopOnCloseSale and not isBoughtGiftBox then
		Event.Brocast("show_gift_panel",{isduring_xsth = true})
	elseif self.enableAutoHitEgg then
		self:RecoverAutoHitState()
	end
end

function ShatterGoldenEggPanel:HitEgg(egg)
	if not self:CanAction() then return end

	local idx = tonumber(egg.gameObject.name)
	local hammer_idx = ShatterGoldenEggLogic.GetHammer()
	local state = ShatterGoldenEggModel.getStates(hammer_idx)
	if not state then return end
	local stateConfig = ShatterGoldenEggModel.getStateConfig()
	local egg_state = state[idx]
	if egg_state == stateConfig.BROKEN then
		print(string.format("[Debug] SGE Refresh hammer(%d) egg(%d) is broken", hammer_idx, idx))
		return
	end

	--[[local baseMoney = ShatterGoldenEggModel.getBaseMoney(hammer_idx, self.is2EggMode)
	local myMoney = ShatterGoldenEggModel.getHammerCount(hammer_idx) * ShatterGoldenEggModel.getBaseMoney(hammer_idx) + (MainModel.UserInfo.jing_bi or 0)
	if self.is2EggMode and myMoney < baseMoney then
		self:OpenShop()
		return
	end]]--
	if self.is2EggMode then
		local baseMoney = ShatterGoldenEggModel.getBaseMoney(self.base2eggindex, true)
		local myMoney =  MainModel.UserInfo.jing_bi or 0
		if myMoney < baseMoney then
			self:OpenShop()
			return
		end
	end
	dump(idx,"<color=red>	self:HammerHit(idx)-------------</color>")
	if self.is2EggMode then
		local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key="zajindan_cs_bet_"..self.base2eggindex,vip_hint_type = 2, cw_btn_desc = "确定"}, "CheckCondition")
	    if a and not b then
	    	return
	    end
	else
		local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key="zajindan_lv_"..hammer_idx,vip_hint_type = 2, cw_btn_desc = "确定"}, "CheckCondition")
	    if a and not b then
	    	return
	    end
	end
	self:HammerHit(idx)
end

function ShatterGoldenEggPanel:GetRandomNum(maxNum)
	if not self.randSeed then
		self.randSeed = os.time()%10000
	else
		self.randSeed = math.floor((self.randSeed + os.time()%10000)/math.random(1, 9))
	end
	math.randomseed(self.randSeed)
	return math.max(1, math.floor(math.random() * maxNum))
end

function ShatterGoldenEggPanel:FilterBrokenEggs()
	local eggs = {}
	for i = 1, #self.ItemRoundList do
		local isBroken = false
		if self.brokenEggs then
			for j, idx in ipairs(self.brokenEggs) do
				if i == idx then
					isBroken = true
					break
				end
			end
		end

		if not isBroken then
			eggs[#eggs + 1] = i
		end
	end

	return eggs
end

function ShatterGoldenEggPanel:UpdateBrokenEggList()
	local hammer_idx = ShatterGoldenEggLogic.GetHammer()
	local state = ShatterGoldenEggModel.getStates(hammer_idx)
	local stateConfig = ShatterGoldenEggModel.getStateConfig()

	self.brokenEggs = {}
	for i, s in ipairs(state) do
		if s == stateConfig.BROKEN then
			self.brokenEggs[#self.brokenEggs + 1] = i
			if self.autoHitEggIdx == i then
				self.autoHitEggIdx = nil
			end
		end
	end
	--dump(self.brokenEggs, "<color=yellow>--->>>Init broken egg list:</color>")
end

function ShatterGoldenEggPanel:IsPopUp()
	return PayPanel.GetInstance() or GameManager.GotoUI({gotoui = "gift_shatter_golden_sale",goto_scene_parm = "is_show"})
end

function ShatterGoldenEggPanel:AutoHitEgg()
	if not self.playAwardAnim and self:CanAction() and self.ItemRoundList and #self.ItemRoundList > 0 and not self:IsPopUp() then
		if self.is2EggMode then
			self.autoHitEggIdx = self:GetRandomNum(2)
		else
			self:UpdateBrokenEggList()

			if not self.autoHitEggIdx then
				local eggs = self:FilterBrokenEggs()
				self.autoHitEggIdx = eggs[self:GetRandomNum(#eggs)]
				--log("<color=yellow>--->>> Choose egg:" .. self.autoHitEggIdx .. "</color>")
			end 
		end

		if self.autoHitEggIdx and self.ItemRoundList[self.autoHitEggIdx] then
			--log("<color=yellow>--->>> Hit egg:" .. self.autoHitEggIdx .. "</color>")
			self:HitEgg(self.ItemRoundList[self.autoHitEggIdx])
		end
	end
end

function ShatterGoldenEggPanel:SetShowSkipBtn(visible)
	if IsEquals(self.skip_btn) then
		self.skip_btn.gameObject:SetActive(visible)
	end
end

function ShatterGoldenEggPanel:SkipAnimation()
	if self.curtainState == CS.HideToShow or self.curtainState == CS.ShowToHide then
		self:AccCurtainAnim(100)
	end

	self:StopTween()
end

function ShatterGoldenEggPanel:AddTweenKey(key)
	if not self.tweenKey then
		self.tweenKey = {}
	end

	self.tweenKey[#self.tweenKey + 1] = key
end

function ShatterGoldenEggPanel:StopTween()
	if self.tweenKey then
		for i, key in ipairs(self.tweenKey) do
			DOTweenManager.KillAndRemoveTween(key)
		end
		self.tweenKey = nil
	end
end

function ShatterGoldenEggPanel:AccCurtainAnim(timeScale)
	if not IsEquals(self.transform) then return end

	local curtain = self.transform:Find("Curtain")
	local objs = curtain:GetComponentsInChildren(typeof(Spine.Unity.SkeletonAnimation), true)
	for i = 0, objs.Length - 1 do
		local obj = objs[i]
		obj.timeScale = timeScale
	end
end

function ShatterGoldenEggPanel:PlayCurtain(action, peroid, callback)
	local animation_time = 1.667

	local transform = self.transform
	if not IsEquals(transform) then return end

	local curtain = transform:Find("Curtain")
	local objs = curtain:GetComponentsInChildren(typeof(Spine.Unity.SkeletonAnimation), true)
	for i = 0, objs.Length - 1 do
		local obj = objs[i]
		obj.AnimationName = action
	end

	local callbacks = {
		{
			stamp = peroid,
			mathod = function()
				--delay
			end
		}
	}
	local tweenKey = ShatterGoldenEggLogic.TweenDelay(callbacks, function()
		if IsEquals(curtain) then
			for i = 0, objs.Length - 1 do
				local obj = objs[i]
				obj.AnimationName = action
			end
		end
		self:SetShowSkipBtn(false)
		self:AccCurtainAnim(1)
		if callback then callback() end
	end)

	self:AddTweenKey(tweenKey)
	self:SetShowSkipBtn(true)
end

function ShatterGoldenEggPanel:ShowCurtain(callback)
	local transform = self.transform
	if not IsEquals(transform) then return end

	if self.curtainState == CS.Show or self.curtainState == CS.HideToShow then
		if self.curtainState == CS.Show then
			if callback then callback() end
		end

		return
	end

	self.locked = true
	self.curtainState = CS.HideToShow

	self:PlayCurtain("off", 0.8, function()
		self.locked = false
		self.curtainState = CS.Show

		if callback then callback() end
	end)
end

function ShatterGoldenEggPanel:HideCurtain(callback)
	local transform = self.transform
	if not IsEquals(transform) then return end

	if self.curtainState == CS.Hide or self.curtainState == CS.ShowToHide then
		if self.curtainState == CS.Hide then
			if callback then callback() end
		end
		return
	end
	
	self.locked = true
	self.curtainState = CS.ShowToHide

	self:PlayCurtain("on", 1.0, function()
		self.locked = false
		self.curtainState = CS.Hide

		if callback then callback() end
	end)
end

--[[function ShatterGoldenEggPanel:ShowCurtain(callback)
	local transform = self.transform
	if not IsEquals(transform) then return end

	if self.curtainState == CS.Show or self.curtainState == CS.HideToShow then
		if self.curtainState == CS.Show then
			if callback then callback() end
		end

		return
	end

	local fg = transform:Find("FG")
	local fgl = fg:Find("FGL")
	local fgr = fg:Find("FGR")

	local offsetX = 1200
	local function local_callback()
		self.locked = false
		self.curtainState = CS.Show

		if IsEquals(fg) then
			fg.gameObject:SetActive(true)
		end
		if callback then callback() end
	end
	
	self.locked = true
	self.curtainState = CS.HideToShow

	fg.gameObject:SetActive(true)
	ShatterGoldenEggLogic.TweenLocalMove (fgl, -offsetX, true, 1, local_callback)
	ShatterGoldenEggLogic.TweenLocalMove (fgr, offsetX, true, 1, nil)
end
function ShatterGoldenEggPanel:HideCurtain(callback)
	local transform = self.transform
	if not IsEquals(transform) then return end

	if self.curtainState == CS.Hide or self.curtainState == CS.ShowToHide then
		if self.curtainState == CS.Hide then
			if callback then callback() end
		end
		return
	end

	local fg = transform:Find("FG")
	local fgl = fg:Find("FGL")
	local fgr = fg:Find("FGR")

	local offsetX = 1200
	local function local_callback()
		self.locked = false
		self.curtainState = CS.Hide

		if IsEquals(fg) then
			fg.gameObject:SetActive(false)
		end
		if callback then callback() end
	end

	self.locked = true
	self.curtainState = CS.ShowToHide

	fg.gameObject:SetActive(true)
	ShatterGoldenEggLogic.TweenLocalMove (fgl, -offsetX, false, 1, local_callback)
	ShatterGoldenEggLogic.TweenLocalMove (fgr, offsetX, false, 1, nil)
end]]--

function ShatterGoldenEggPanel:StandEggs()
	for k, v in ipairs(self.ItemRoundList) do
		self:PlayAnimation(v, "stand", 0)
	end
end

function ShatterGoldenEggPanel:PushTimer(config_idx, interval)
	local transform = self.transform
	if not IsEquals(transform) then return end

	local params = self.timerParams[config_idx] or {}
	if interval < 0 then
		params.interval = math.abs(interval)
	else
		params.interval = math.max(params.interval, interval) or 0
	end
	self.timerParams[config_idx] = params

	print("[Debug] SGE PushTimer:" .. config_idx .. ":" .. interval)
end

function ShatterGoldenEggPanel:SendSpawnEggs(config_idx)
	print("[Debug] SGE SendSpawnEggs:" .. config_idx)

	if IsEquals(self.spawn_btn) then
		self.spawn_btn.interactable = false
	end

	local stats = ShatterGoldenEggModel.getStates(config_idx)
	if self.is2EggMode and stats and #stats > 0 then
		self:SimulateSpawn2Egg(config_idx, true)
	else
		ShatterGoldenEggLogic.SendSpawn(config_idx)
	end
end

function ShatterGoldenEggPanel:OnEggAnimEnd(callback)
	if self.playEggAnim then
		local eggTbl = self.ItemRoundList
		self.locked = false
		self.playEggAnim = false

		for k, v in ipairs(eggTbl) do
			if IsEquals(v) then
				v.transform.localPosition = Vector3.zero
				local icon = v.transform:Find("Icon")
				local image = icon.transform:GetComponent("Image")
				image.color = Color.white
				self:PlayAnimation(v, "stand", 0)
				--self:PlayAnimation(v, "shake", math.random(0, 100) * 0.01)
			end
		end

		if callback then callback() end
	end
end

function ShatterGoldenEggPanel:MixingAll(callback)
	self.playEggAnim = true
	self.locked = true
	self:SetShowSkipBtn(true)

	local function finally()
		self:SetShowSkipBtn(false)
		self:OnEggAnimEnd(callback)
		self.enableAction = true
	end

	self:MixingAwards(finally, function()
		if self.playEggAnim then
			self:MixingEggs(finally, function()
				if finally then finally() end
			end)
		end
	end)
end

--rnd award
local function mix_table_index(tbl)
	local count = #tbl
	local idx_tbl = {}

	if count <= 0 then
		return idx_tbl
	end

	local trace_tbl = {}
	local loop_count = 1000
	while loop_count > 0 do
		loop_count = loop_count - 1
		local idx = math.random(1, 65535) % count
		if idx == 0 then idx = count end
		if not trace_tbl[idx] then
			trace_tbl[idx] = true
			idx_tbl[#idx_tbl + 1] = idx
			if #idx_tbl >= count then break end
		end
	end

	if #idx_tbl < count then
		for idx = 1, count, 1 do
			if not trace_tbl[idx] then
				idx_tbl[#idx_tbl + 1] = idx
			end
		end
	end

	trace_tbl = {}

	return idx_tbl
end
function ShatterGoldenEggPanel:MixingAwards(finally_callback, callback)
	local hammer_idx = ShatterGoldenEggLogic.GetHammer()

	local award = ShatterGoldenEggModel.getAward(hammer_idx)
	if not award or #award <= 0 then
		print("[SGE] MixingAwards getAward is invalid:" .. hammer_idx)
		if finally_callback then finally_callback() end

		return
	end

	local eggTbl = self.ItemRoundList
	--assert
	if #award ~= #eggTbl then
		print(string.format("[SGE] MixingAwards exception: count(%d ~= %d)", #award, #eggTbl))
		if finally_callback then finally_callback() end

		return
	end

	local config = ShatterGoldenEggModel.getAwardConfig()

	local amply_tbl = {}
	local index_tbl = mix_table_index(award)
	local iconTbl = {}
	for k, v in ipairs(index_tbl) do
		if IsEquals(eggTbl[k].transform) then
			local icon = eggTbl[k].transform:Find("Icon")
			local image = icon.transform:GetComponent("Image")
			local value = award[v]

			if ShatterGoldenEggLogic.GetPlayMode()==0 and config[value].image_normal then
				image.sprite = GetTexture(config[value].image_normal)
			else
				image.sprite = GetTexture(config[value].image)
			end

			image:SetNativeSize()
			iconTbl[k] = icon

			icon.gameObject:SetActive(true)
			if self.is2EggMode then
				local myScal = icon.transform.localScale
				local nodeScale = eggTbl[k].transform.parent and eggTbl[k].transform.parent.localScale or Vector3.New(1.6, 1.6, 1)
				icon.transform.localPosition = Vector3.New(0, 90/nodeScale.y, 0)
				image.transform.localScale = Vector3.New(myScal.x/nodeScale.x, myScal.x/nodeScale.y, 1)
				if config[value].image=="zjd_icon20" then
					Event.Brocast("act_ns_sprite_change",{sprite = image})
				end 
			else
				icon.transform.localPosition = Vector3.New(0, 90, 0)
			end

			if value == 1 then
				amply_tbl[#amply_tbl + 1] = k
			end
		end
	end

	for k, v in ipairs(amply_tbl) do
		self:ToTop(eggTbl[v])
	end

	local seq = DG.Tweening.DOTween.Sequence()
	local tweenKey = DOTweenManager.AddTweenToStop(seq)
	local isOK = false
	seq:OnKill(function()
		DOTweenManager.RemoveStopTween(tweenKey)

		for k, v in ipairs(iconTbl) do
			if IsEquals(v) then
				v.transform.localPosition = Vector3.zero
				v.gameObject:SetActive(false)
			end
		end

		for k, v in ipairs(amply_tbl) do
			self:ToNormal(eggTbl[v])
		end

		if not isOK then
			if finally_callback then finally_callback() end
		end
	end):OnComplete(function()
		isOK = true
		if callback then callback() end
	end)

	seq:AppendInterval(2):AppendCallback(function()
		--delay
	end)

	for k, v in ipairs(iconTbl) do
		local image = v.transform:GetComponent("Image")
		local tween1 = v.transform:DOLocalMove(Vector3.zero, 0.4):OnComplete(function()
			v.gameObject:SetActive(false)
		end)
		local tween2 = image:DOFade(0.5, 0.35)
		--seq:Append(tween1):Join(tween2)
		seq:Join(tween1):Join(tween2)
	end

	self:AddTweenKey(tweenKey)
end

function ShatterGoldenEggPanel:MixingEggs(finally_callback, callback)
	local eggTbl = self.ItemRoundList
	local center = self.is2EggMode and self.list_center_2Egg.transform.position or self.list_center.transform.position

	local seq = DG.Tweening.DOTween.Sequence()
	local tweenKey = DOTweenManager.AddTweenToStop(seq)
	local isOK = false
	seq:OnKill(function()
		DOTweenManager.RemoveStopTween(tweenKey)

		for k, v in ipairs(eggTbl) do
			if IsEquals(v) then
				v.transform.localPosition = Vector3.zero
			end
		end

		if not isOK then
			if finally_callback then finally_callback() end
		end
	end):OnComplete(function()
		isOK = true
		if callback then callback() end
	end)

	for k, v in ipairs(eggTbl) do
		if IsEquals(v) and IsEquals(v.transform.parent) then
			local local_center = v.transform.parent.transform:InverseTransformPoint(center)
			local tween = v.transform:DOLocalMove(local_center, 0.5)
			seq:Join(tween)
		end
	end
	
	seq:AppendInterval(0.4):AppendCallback(function()
		--delay
	end)

	for k, v in ipairs(eggTbl) do
		local tween = v.transform:DOLocalMove(Vector3.zero, 0.5)
		seq:Join(tween)
	end

	self:AddTweenKey(tweenKey)
end

function ShatterGoldenEggPanel:CanAction()
	if self.locked then
		print("[Debug] SGE CanAction: self locked")
		return false
	end

	if ShatterGoldenEggLogic.is_locked() then
		print("[Debug] SGE CanAction: logic locked")
		return false
	end

	return true
end

function ShatterGoldenEggPanel:SpawnNotice(idx)
	local transform = self.transform
	if not IsEquals(transform) then return end

	local stamp = self.SpawnNoticeStamp or 0
	if self.timerParams[idx].force_spawn or not ShatterGoldenEggLogic.CheckStates(idx) then
		local currentStamp = os.time()
		local diffStamp = currentStamp - stamp
		if diffStamp > 4 then
			LittleTips.Create("本轮结束，正在进入下一轮，请稍后...")
			stamp = currentStamp
		end
	end
	self.SpawnNoticeStamp = stamp
end

function ShatterGoldenEggPanel:CooldownNotice(idx)
	LittleTips.Create("点击过快，请稍后尝试......", nil, {bg = "com_bg_notice"})
	--[[
	if self.timerParams[idx] and self.timerParams[idx].force_spawn or not ShatterGoldenEggLogic.CheckStates(idx) then
		LittleTips.Create("点击过快，请稍后尝试......", nil, {bg = "com_bg_notice"})
	else
		LittleTips.Create("点击过快，请稍后尝试......", nil, {bg = "com_bg_notice"})
	end
	]]--
end

function ShatterGoldenEggPanel:ShowEgg2Hint(idx, text)
	local btn = self.ItemButtonList[idx]
	if not IsEquals(btn) then return end

	local hintNode = nil

	local hammer_idx = ShatterGoldenEggModel.getExtra2EggsData("mode_hammer") or ShatterGoldenEggLogic.GetHammer()
	if hammer_idx == idx then
		hintNode = btn.transform:Find("down_img/egg2/hint_node")
	else
		hintNode = btn.transform:Find("up_btn/egg2/hint_node")
	end
	if not hintNode then return end

	local textNode = hintNode:Find("Image/hint_txt"):GetComponent("Text")
	if textNode then
		textNode.text = text
	end

	hintNode.gameObject:SetActive(true)
	local hintImage = hintNode:Find("Image"):GetComponent("Image")

	local callbacks = {
		{
			stamp = 2,
			method = function()
				if not IsEquals(hintImage) then return end
				ShatterGoldenEggLogic.TweenFade(hintImage, 0.1, false, 0.6, function()
				end)
			end
		},
		{
			stamp = 1,
			method = function() end
		}
	}
	ShatterGoldenEggLogic.TweenDelay(callbacks, function()
		if IsEquals(hintNode) then
			hintNode.gameObject:SetActive(false)
			hintImage.color = Color.white
		end
	end)
end

function ShatterGoldenEggPanel:CanSpawnEggs(idx)
	if not self:CanAction() then
		self:CooldownNotice(idx)
		print("[Debug] SGE CanSpawnEggs can't action:" .. idx)
		return false
	end

	local params = self.timerParams[idx] or {}
	if params and params.interval >= 0 then
		self:CooldownNotice(idx)
		print("[SGE] CanSpawnEggs spawning:" .. idx .. ":" .. params.interval)
		return false
	end

	if not ShatterGoldenEggLogic.CheckReplaceMoney(idx) and not self.is2EggMode then
		--LittleTips.Create("您鲸币不足，请购买足够鲸币", nil, {bg = "com_bg_notice"})
		self:OpenShop()
		print("[SGE] CanSpawnEggs CheckReplaceMoney failed:" .. idx)
		return false
	end

	return true
end

function ShatterGoldenEggPanel:CanSwitchHammer(idx, check_repeat)
	local hammer_idx = ShatterGoldenEggLogic.GetHammer()
	if check_repeat and hammer_idx == idx then
		print("[Debug] SGE CanSwitchHammer repeat select:" .. idx)
		return false
	end

	if not self:CanAction() then
		self:CooldownNotice(hammer_idx)
		print("[Debug] SGE CanSwitchHammer can't action")
		return false
	end

	local params = self.timerParams[hammer_idx] or {}
	if  params and params.interval >= 0 then
		self:CooldownNotice(hammer_idx)
		print("[SGE] CanSwitchHammer spawning :" .. params.interval)
		return false
	end

	return true
end

function ShatterGoldenEggPanel:SwitchHammer(idx)
	print("SwitchHammer: " .. idx)

	if not self:CanAction() then
		print("[Debug] SGE SwitchHammer can't action")
		return false
	end

	local logic = ShatterGoldenEggModel.getLogicConfig(idx)
	if not logic then
		print("[SGE] SwitchHammer getLogicConfig failed:" .. idx)
		return false
	end

	--ShatterGoldenEggLogic.SetHammer(idx)

	if self.hammer then
		GameObject.Destroy(self.hammer.gameObject)
		self.hammer = nil
	end

	self.hammer = self:CreateItem(self.hammerNode, GetPrefab(logic.hammer), {image = logic.icon})
	self.hammer.gameObject:SetActive(false)

	if self.is2EggMode then
		self:ChangeHammerSkin("zjd_icon17")
	end

	self:Refresh()

	return true
end

function ShatterGoldenEggPanel:ChangeHammerSkin(iconName)
	if not IsEquals(self.hammer) then
		return
	end

	local sprite = GetTexture(iconName)
	if not sprite then return end

	local icon = self.hammer.transform:Find("Offset/Body/chuizi"):GetComponentInChildren(typeof(UnityEngine.UI.Image), true)
	if icon then
		icon.sprite = sprite
	end

	local dummy = self.hammer.transform:Find("Dummy")
	if not dummy then return end
	local icons = dummy:GetComponentsInChildren(typeof(UnityEngine.UI.Image), true)
	for i = 0, icons.Length - 1 do
		icons[i].sprite = sprite
	end
end

function ShatterGoldenEggPanel:ResetHammer(hammer)
	if IsEquals(hammer) then
		hammer.transform.position = self.hammerNode.transform.position
		self:PlayAnimation(hammer, "idle", 0)
		hammer.gameObject:SetActive(false)
	end
end

function ShatterGoldenEggPanel:HammerHit(idx)
	if not self.hammer then
		print("[SGE] HammerHit hammer is invalid")
		return
	end

	local egg = self.ItemRoundList[idx]
	if not egg then
		print("[SGE] HammerHit egg is invalid:" .. idx)
		return
	end

	local hammer_idx = ShatterGoldenEggLogic.GetHammer()

	if not ShatterGoldenEggLogic.CheckStates(hammer_idx) then
		print("[SGE] HammerHit CheckStates failed:" .. hammer_idx)
		return
	end

	if not ShatterGoldenEggLogic.CheckHammer(hammer_idx) then
		print("[SGE] HammerHit CheckHammer failed:" .. hammer_idx)
		--[todo]
		--use gold coin
		--return
	end

	--[[if ShatterGoldenEggModel.getHammerCount(hammer_idx) <= 0 then
		if not ShatterGoldenEggLogic.CheckBaseMoney(hammer_idx) then
			PayPanel.Create(GOODS_TYPE.jing_bi, "normal")
			print("[SGE] HammerHit CheckBaseMoney failed:" .. hammer_idx)
			return false
		end
	end]]--

	self.locked = true

	local hammer = self.hammer
	hammer.transform.position = egg.transform.position
	hammer.gameObject:SetActive(true)

	if not self.is2EggMode then
		hammer.transform:Find("Offset/Body/chuizi_Za").gameObject:SetActive(true)
	end

	local callbacks = {
		{
			stamp = 0.3,
			method = function()
				--delay
			end
		}
	}
	self:PlayAnimation(hammer, "hit", 0, callbacks, function()
		local egg_idx = idx
		if self.is2EggMode then
			--egg_idx = ShatterGoldenEggLogic.ConvertEgg2IDFromC2S(hammer_idx, idx)			
			--egg_idx = 100 + idx	 		
			egg_idx=100 + (self.base2eggindex-1) * 2 + idx
		end

		print("<color=yellow>[Debug] SGE HammerHit send hit:</color>", hammer_idx, egg_idx)

		ShatterGoldenEggLogic.SendHit(hammer_idx, egg_idx)
	end)
	if self.is2EggMode then
		ExtendSoundManager.PlaySound(audio_config.qql.bgm_zayixia1.audio_name)
	else
		ExtendSoundManager.PlaySound(audio_config.qql.bgm_zayixia.audio_name)
	end
end

function ShatterGoldenEggPanel:CreateItem(parent, tmpl, data)
	local obj = GameObject.Instantiate(tmpl)
	obj.transform:SetParent(parent)
	obj.transform.localPosition = Vector3.zero
	obj.transform.localScale = Vector3.one

	if data and data.image then
		local icon = obj.transform:GetComponentInChildren(typeof(UnityEngine.UI.Image))
		icon.sprite = GetTexture(data.image)		
	end

	if data and data.text then
		local text = obj.transform:GetComponentInChildren(typeof(UnityEngine.UI.Text))
		text.text = data.text
	end

	obj.gameObject:SetActive(true)

	return obj
end

function ShatterGoldenEggPanel:ClearItemList(list)
	for i,v in pairs(list) do
		if IsEquals(v) then
			GameObject.Destroy(v.gameObject)
		end
	end
end

function ShatterGoldenEggPanel:ClearAll()
	self.ItemRoundParentList = {}
	self:ClearItemList(self.ItemRoundList)
	self.ItemRoundList = {}
	self:ClearItemList(self.ItemButtonList)
	self.ItemButtonList = {}

	for k, v in pairs(self.EffectMap) do
		self:ClearItemList(v)
	end
	self.EffectMap = {}

	if self.hammer then
		GameObject.Destroy(self.hammer.gameObject)
		self.hammer = nil
	end

	self.locked = false
	ShatterGoldenEggLogic.unlock()

	if self.spawnTimer then
		self.spawnTimer:Stop()
		self.spawnTimer = nil
	end
	
	self.timerParams = {}
	local logics = ShatterGoldenEggModel.getLogicConfig(-1)
	for k, v in ipairs(logics) do
		self.timerParams[k] = {}
		self.timerParams[k].interval = -1
	end

	ClearUserData(self)
end

function ShatterGoldenEggPanel:handle_sge_hammer(config_idx)
	print("[Debug] SGEP handle_sge_hammer:" .. config_idx)

	local awards = ShatterGoldenEggModel.getAward(config_idx)
	if not ShatterGoldenEggAward.IsShow() and awards and #awards > 0 then
		ShatterGoldenEggAward.Create(self.award_point.transform)
	end

	if ShatterGoldenEggLogic.CheckStates(config_idx) then
		print("[Debug] SGEP handle_sge_hammer:" .. config_idx .. " is already")
		if self.goto2EggMode then
			log("<color=yellow>handle_sge_hammer--->>>goto2EggMode</color>")
			self.goto2EggMode = false
			self:OnSwitchMode(config_idx)
		else
			if self:SwitchHammer(config_idx) then
				if self.is2EggMode then
					self:SpawnEggs(config_idx)
				else
					self:HideCurtain(function()end)
				end

				--[[self:HideCurtain(function()
					if self.is2EggMode then
						--self:SimulateSpawn2Egg(config_idx, false)
						self:SpawnEggs(config_idx)
					end
				end)]]--
				
			end
		end
	else
		print("[Debug] SGEP handle_sge_hammer:" .. config_idx .. " empty states")

		self:PushTimer(config_idx, 0)
	end
	self:SwitchHammerButton()
end

function ShatterGoldenEggPanel:SimulateSpawn2Egg(config_idx, upd_hammer)
	Event.Brocast("zjd_replace_eggs_response", "zjd_replace_eggs_response", {award_list = math.random(1) < 0.5 and {1, 13} or {13, 1}, level = config_idx, replace_money = ShatterGoldenEggModel.getReplaceMoney(config_idx), result = 0})
	--if upd_hammer then
		Event.Brocast("view_sge_hammer", config_idx)
	--end
end

function ShatterGoldenEggPanel:handle_sge_spawn(config_idx)
	print("[Debug] SGEP handle_sge_spawn:" .. config_idx)

	--[[if (not self.lockSpawnTimer or (os.time() - self.lockSpawnTimer) > 1) then
		--fuck what's this!
		self.lockSpawnTimer = os.time()
		if self.is2EggMode then
			self:SimulateSpawn2Egg(config_idx)
		else
			--self:SaveHammerData(config_idx)
		end
	end]]--

	if self.is2EggMode then
		local stateConfig = ShatterGoldenEggModel.getStateConfig()
		ShatterGoldenEggModel.SetAward(config_idx, math.random(1) < 0.5 and {1, 13} or {13, 1})
		ShatterGoldenEggModel.setStates(config_idx, {stateConfig.STAND, stateConfig.STAND})
	end

	if self.goto2EggMode then
		log("<color=yellow>handle_sge_spawn--->>>goto2EggMode</color>")
		self.goto2EggMode = false
		self:OnSwitchMode(config_idx)
		return
	end

	if IsEquals(self.spawn_btn) then
		self.spawn_btn.interactable = true
	end

	if self:SwitchHammer(config_idx) then
		self:StandEggs()
		self:HideCurtain(function()
			self:MixingAll()
		end)
	end

	self.totalMoney = MainModel.UserInfo.jing_bi
	self.flyingMoney = 0
	self:UpdateGold()

	self:UpdateReplaceMoney()
	self:UpdateEggTotal()

	Event.Brocast("view_sge_refresh")
end

function ShatterGoldenEggPanel:handle_sge_hit(result)
	local config_idx = result.level
	local slot_idx = result.egg_no
	local state = result.egg_status
	local is_spend_hammer = result.is_spend_hammer
	local kaijiang = result.kaijiang or {}
	local status = result.status or 0
	local dikou_money = result.dikou_money or 0

	print(string.format("[Debug] SGEP handle_sge_hit(%d, %d, %d)", config_idx, slot_idx, state))
	self.locked = false

	if self.is2EggMode then
		self.enableAction = false
	end
	local hammer_idx = ShatterGoldenEggLogic.GetHammer()
	if config_idx ~= hammer_idx then
		print(string.format("[SGE] handle_sge_hit failed: config(%d ~= %d)", config_idx, hammer_idx))
		return
	end

	--1是用锤子 / 0是用钱
	if is_spend_hammer == 0 then
		if result.use_money then
			self.totalMoney = self.totalMoney - result.use_money
		else
			if  self.is2EggMode then 
				hammer_idx=self.base2eggindex
			end 
			self.totalMoney = self.totalMoney - ShatterGoldenEggModel.getBaseMoney(hammer_idx, self.is2EggMode)
		end
		if self.totalMoney < 0 then self.totalMoney = 0 end
		self:UpdateGold()
	end

	self:ResetHammer(self.hammer)

	self:UpdateReplaceMoney()
	self:UpdateHammerButton()

	if self.is2EggMode and dikou_money > 0 then
		local mode_hammer = ShatterGoldenEggModel.getExtra2EggsData("mode_hammer") or hammer_idx
		self:ShowEgg2Hint(mode_hammer, string.format("已扣除锤子为您抵扣%d鲸币", dikou_money))
	end

	print("<color=yellow>status:" .. status .. "</color>")

	--[[if false then
		local list = {
			{egg_no = 1, award = 1, award_value = 12},
			--{egg_no = 2, award = 2, award_value = 2},
			--{egg_no = 3, award = 3, award_value = 2},
			--{egg_no = 4, award = 4, award_value = 2},
			--{egg_no = 5, award = 5, award_value = 2},
			--{egg_no = 6, award = 6, award_value = 2},
			{egg_no = 7, award = 7, award_value = 8},
			--{egg_no = 8, award = 8, award_value = 2},
			--{egg_no = 9, award = 9, award_value = 2},
			--{egg_no = 10, award = 10, award_value = 2},
			--{egg_no = 11, award = 13, award_value = 0},
			--{egg_no = 12, award = 13, award_value = 0}
		}

		--self:CatchAllAtOnce(slot_idx, list)
		--self:ContinuousHit(slot_idx, list)
		--self:FairiesSpreadingFlowers(slot_idx, list)
		--self:BigHammer(slot_idx, list)

		return
	end]]--

	self:PlayFirework(kaijiang)

	--[[status = 0
	state = -1
	kaijiang = {
			{egg_no = 1, award = 1, award_value = 18},
	}]]--


	if status <= 0 then
		local stateConfig = ShatterGoldenEggModel.getStateConfig()
		if state > stateConfig.DMG_MAX then
			state = stateConfig.DMG_MAX
		end

		if state == stateConfig.BROKEN then
			self.locked = true

			local total = self:CalculateAward(kaijiang)
			local total_count = 0
			local logic = ShatterGoldenEggModel.getLogicConfig(hammer_idx)

			for _, v in pairs(kaijiang) do
				local egg = self.ItemRoundList[v.egg_no]
				local egg_position = Vector3.zero
				if IsEquals(egg) then
					egg_position = egg.transform.position
				end

				self:ShowAward(config_idx, v.egg_no, v.award, function()
					self.locked = false

					self:SpawnNotice(hammer_idx)

					--self:PlayBrokenSound(kaijiang, false, true)
					self:FlyMoney(kaijiang, v.egg_no)
				end, nil, nil, nil, function()
					if total >= 12 and total_count == 0 then
						total_count = total_count + 1
						self:PlayParticle(self.EffectMap["_P_"], "jinbi_glow_H", egg_position, 3)
					end
				end)

				if v.award_value >= 12 then
					self:PlayAnimation(egg, "blast", 0)
				else
					self:PlayAnimation(egg, "broken", 0)
				end
			end
			if total >= 12 then
				self:PushTimer(hammer_idx, 7)
			else
				self:PushTimer(hammer_idx, 4)
			end
			self:PlayBrokenSound(kaijiang, true, true)
			self:UpdateEggTotal()
		else
			local logic = ShatterGoldenEggModel.getLogicConfig(config_idx)
			if not logic then
				print("[SGE] handle_sge_hit getLogicConfig failed:" .. config_idx)
				return
			end
			local action = logic.egg.action[tostring(state)]
			local egg = self.ItemRoundList[slot_idx]
			self:PlayAnimation(egg, action, 0)
		end
	else
		dump(kaijiang, "<color=red>kaijiang+++++++++++++++++++++++++++++++kaijiang</color>")

		if status == 1 then
			self:CatchAllAtOnce(slot_idx, kaijiang)
		elseif status == 2 then
			self:FairiesSpreadingFlowers(slot_idx, kaijiang)
		elseif status == 3 then
			self:BigHammer(slot_idx, kaijiang)
		elseif status == 4 then
			self:ContinuousHit(slot_idx, kaijiang)
		end
	end
end

function ShatterGoldenEggPanel:handle_sge_hit_nomoney(showType)
	print("[SGE] handle_sge_hit_nomoney showType:" .. showType)

	self.locked = false

	self:ResetHammer(self.hammer)

	if GameGlobalOnOff.LIBAO then
		if showType == 1 then
			local hammer_idx = ShatterGoldenEggLogic.GetHammer()
			Event.Brocast("ui_game_pc_msg", {tag="qql", node=self.ShopNode, idx=hammer_idx, is_pc=true, call=basefunc.handler(self, self.OnCloseSaleBox)})
			-- local hammer_idx = ShatterGoldenEggLogic.GetHammer()
			-- ShatterGoldenSale.Create(self.ShopNode, hammer_idx, basefunc.handler(self, self.OnCloseSaleBox))
		elseif showType == 2 then
			Event.Brocast("show_gift_panel")
		end
	else
		self:OpenShop()
	end

	--[[local hammer_idx = ShatterGoldenEggLogic.GetHammer()
	local logic = ShatterGoldenEggModel.getLogicConfig(hammer_idx)
	if logic and logic.sale then
		if self:UpdateSaleUIToday(hammer_idx) then return end
	end

	PayPanel.Create(GOODS_TYPE.jing_bi, "normal")]]--
end

function ShatterGoldenEggPanel:handle_sge_exception(code)
	print("[SGE] handle_sge_exception exception:" .. code)

	self.locked = false
	self:ResetHammer(self.hammer)
end

function ShatterGoldenEggPanel:handle_asset_change(data)
	self:UpdateHammerButton()

	if self.flyingMoney == 0 then
		local change_type = data.change_type or ""
		if change_type ~= "egg_game_spend" and change_type ~= "egg_game_award" then
			self.totalMoney = MainModel.UserInfo.jing_bi
			self:UpdateGold()
		end
	end
end

function ShatterGoldenEggPanel:handle_update_money()
	self.totalMoney = MainModel.UserInfo.jing_bi
	self.flyingMoney = 0
	self:UpdateGold()
end

function ShatterGoldenEggPanel:ShowAward(config_idx, slot_idx, award, callback, forceFile, forcePeriod, forceOffsetTime, offset_callback)
	local awardConfig = ShatterGoldenEggModel.getAwardConfig()
	local effect = awardConfig[award]
	if not effect then
		print(string.format("[SGE] ShowAward(%d, %d) awardConfig's effect(%d) is nil", config_idx, slot_idx, award))
		if callback then callback() end
		return
	end

	local egg = self.ItemRoundList[slot_idx]
	if not IsEquals(egg) then
		print(string.format("[SGE] ShowAward(%d, %d) egg is nil", config_idx, slot_idx))
		if callback then callback() end
		return
	end

	local container = self.EffectMap[slot_idx] or {}
	self.EffectMap[slot_idx] = container
	local particleConfig = effect.particle or {}
	local particleFile = forceFile or particleConfig[1]
	local particlePeriod = forcePeriod or particleConfig[2]
	local callbackOffsetTime = forceOffsetTime or particleConfig[3]

	self:PlayParticle(container, particleFile, egg.transform.position, particlePeriod, function()
	end, callbackOffsetTime, function()
		if IsEquals(egg) then
			if award == 1 then
				self:ToTop(egg)
			end

			local icon = egg.transform:Find("Icon")
			local image = icon.transform:GetComponent("Image")
			local iconScale = icon.localScale
			local offH = ICON_HEIGHT

			if ShatterGoldenEggLogic.GetPlayMode()==0 and effect.image_normal then
				image.sprite = GetTexture(effect.image_normal)
			else
				image.sprite = GetTexture(effect.image)
			end

			if self.is2EggMode then
				local nodeScale = egg.transform.parent.localScale
				offH = offH/nodeScale.y
				if effect.image=="zjd_icon20" then
					Event.Brocast("act_ns_sprite_change",{sprite = image})
				end 
			end			
			image:SetNativeSize()
			icon.gameObject:SetActive(true)
			ShatterGoldenEggLogic.TweenLocalMove(icon, offH, false, effect.show_time or 1, function()
				if IsEquals(icon) then
					icon.localPosition = Vector3.New(0, offH, 0)
				end
				ShatterGoldenEggLogic.TweenFade(image, 0, false, effect.fade_time or 0.3, function()
					if IsEquals(icon) then
						image.color = Color.white
						icon.localPosition = Vector3.zero
						icon.gameObject:SetActive(false)
					end
					if callback then callback() end
				end)
			end, "y", 0.1)

			if offset_callback then offset_callback() end
		end
	end)
end

function ShatterGoldenEggPanel:PlayParticle(container, particleFile, position, particlePeriod, finally_callback, callbackOffsetTime, callback)
	local transform = self.transform
	if not IsEquals(transform) then return end

	if not particleFile then
		if callback then callback() end
		if finally_callback then finally_callback() end
		return
	end

	local go = GameObject.Instantiate(GetPrefab(particleFile))
	if not go then
		print("[SGE] PlayParticle failed. particle is nil:" .. particleFile)
		if callback then callback() end
		if finally_callback then finally_callback() end
		return
	end
	go.transform.position = position

	table.insert(container, go)

	local callbacks = {
		{
			stamp = callbackOffsetTime or 0,
			method = callback
		},
		{
			stamp = particlePeriod or 0,
			method = function()
				--delay
			end
		}
	}
	ShatterGoldenEggLogic.TweenDelay(callbacks, function()
		if IsEquals(go) then
			GameObject.Destroy(go.gameObject)
		end
		for k, v in pairs(container) do
			if v == go then
				container[k] = nil
				break;
			end
		end

		if finally_callback then finally_callback() end
	end)
end

function ShatterGoldenEggPanel:OnReceivePayOrderMsg(msg)
	if msg.result == 0 then
		local hammer_idx = ShatterGoldenEggLogic.getHammerBySaleID(msg.goods_id or 0)
		if hammer_idx <= 0 then
			print("[Debug] SGE OnReceivePayOrderMsg can't find item_id:" .. msg.goods_id or 0)
			return
		end
		local config_idx = ShatterGoldenEggLogic.GetHammer()
		if config_idx ~= hammer_idx then return end

		--UIPaySuccess.Create()
		ShatterGoldenEggLogic.SetHammerData(hammer_idx, "sale_countdown", 0)
	else
		HintPanel.ErrorMsg(msg.result)
	end
end

function ShatterGoldenEggPanel:StopComboHit19()
	if self.combo19Hit then
		self.combo19Hit:Stop()
		self.combo19Hit = nil
	end
end

function ShatterGoldenEggPanel:PlayComboHit(object, callbacks, finally_callback)
	if not IsEquals(object) then return end

	local animator = object.transform:GetComponentInChildren(typeof(UnityEngine.Animator))
	if not animator then
		print("[SGE] PlayComboHit failed, animator is invalid:" .. name)
		return
	end
	local dummy = object.transform:Find("Dummy")
	if not dummy then return end

	local MAX_DUMMY = 4
	local mt = {}
	for i = 1, MAX_DUMMY do
		local go = dummy:Find("Offset"..i)
		mt[i] = {go.transform.position, go.transform.rotation}
	end

	local point = object.transform.position
	local tmpl = GetPrefab("HammerFX")

	local index = 0

	self:StopComboHit19()
	local container = {}

	object.gameObject:SetActive(false)
	self.combo19Hit = Timer.New(function()
		if not IsEquals(self.transform) then return end

		local idx = index % MAX_DUMMY + 1
		index = index + 1

		local go = GameObject.Instantiate(tmpl, self.transform)
		go.transform.localPosition = Vector3.zero
		go.transform.position = point
		local offset = go.transform:Find("Offset")
		offset.transform.position = mt[idx][1]
		offset.transform.rotation = mt[idx][2]
		local goAnimator = go.transform:GetComponentInChildren(typeof(UnityEngine.Animator))
		goAnimator:Play("hitting", 0, 0)
		table.insert(container, go)

		if index >= 18 then
			object.gameObject:SetActive(true)
			object.transform:Find("Offset/Body/chuizi_Za").gameObject:SetActive(false)
			animator:Play("hit_combo", 0, 0)
			local fxcallbacks = {
				{
					stamp = 2.5,
					method = function()
						--delay
					end
				}
			}
			ShatterGoldenEggLogic.TweenDelay(fxcallbacks, function()
				if not IsEquals(object) then return end
				object.transform:Find("Offset/Body/chuizi_Za").gameObject:SetActive(true)
			end)
		end
	end, 0.1, 18)
	self.combo19Hit:Start()

	callbacks = callbacks or {}
	if #callbacks <= 0 then return end
	callbacks[1].stamp = 4.5

	ShatterGoldenEggLogic.TweenDelay(callbacks, function()
		self:StopComboHit19()
		for k, v in pairs(container) do
			if IsEquals(v) then
				GameObject.Destroy(v.gameObject)
			end
		end
		container = {}

		if finally_callback then finally_callback() end
	end)
end

function ShatterGoldenEggPanel:PlayAnimation(object, name, percent, callbacks, finally_callback)
	if not IsEquals(object) then return end

	if self.is2EggMode and name == "hit" then
		self:PlayComboHit(object, callbacks, finally_callback)
		return
	end

	local animator = object.transform:GetComponentInChildren(typeof(UnityEngine.Animator))
	if not animator then
		print("[SGE] PlayAnimation failed, animator is invalid:" .. name)
		return
	end
	animator:Play(name, 0, percent)

	callbacks = callbacks or {}
	if #callbacks <= 0 then return end

	ShatterGoldenEggLogic.TweenDelay(callbacks, finally_callback)
end

function ShatterGoldenEggPanel:UpdateReplaceMoney()
	if not IsEquals(self.money_txt) then return end

	local hammer_idx = ShatterGoldenEggLogic.GetHammer()

	local money_value = ShatterGoldenEggModel.getReplaceMoney(hammer_idx)
	self.money_txt.text = StringHelper.ToCash(money_value)
end

function ShatterGoldenEggPanel:UpdateGold()
	if not IsEquals(self.gold_txt) then return end

	self.gold_txt.text = StringHelper.ToCash(self.totalMoney)
end

function ShatterGoldenEggPanel:UpdateEggTotal()
	if not IsEquals(self.total_txt) then return end

	local hammer_idx = ShatterGoldenEggLogic.GetHammer()

	local logic = ShatterGoldenEggModel.getLogicConfig(hammer_idx)
	if not logic then
		print("[SGE] UpdateEggTotal failed, getLogicConfig is invalid:" .. hammer_idx)
		return
	end
	local broken_count = ShatterGoldenEggLogic.GetBrokenCount(hammer_idx)
	--local new_text = string.format("%d/%d", broken_count, logic.respawn)
	local new_text = string.format("%d 个", Mathf.Clamp(logic.respawn - broken_count, 0, logic.respawn))
	if self.total_txt.text ~= new_text then
		self.total_txt.text = new_text
		Event.Brocast("view_sge_refresh")
	end
end

function ShatterGoldenEggPanel:SwitchHammerImage(btn, normal)
	local down_img = btn.transform:Find("down_img/hammer_img")
	local down_egg2 = btn.transform:Find("down_img/egg2")
	local up_img = btn.transform:Find("up_btn/hammer_img")
	local up_egg2 = btn.transform:Find("up_btn/egg2")

	down_img.gameObject:SetActive(normal)
	up_img.gameObject:SetActive(normal)

	down_egg2.gameObject:SetActive(not normal)
	up_egg2.gameObject:SetActive(not normal)
end


function ShatterGoldenEggPanel:SwitchHammerButton()
	local logics = ShatterGoldenEggModel.getLogicConfig(-1)
	dump(logics,"<color=red>--------logics-------</color>")
	for k, v in ipairs(self.ItemButtonList) do
		if IsEquals(v) then
			self:SwitchHammerImage(v, not self.is2EggMode)
		end
	end

	if self.is2EggMode then
		self:ChangeHammerSkin(logics[4].icon)
	else
		local hammer_idx = ShatterGoldenEggLogic.GetHammer()
		self:ChangeHammerSkin(logics[hammer_idx].icon)
	end

	--[[local mode_idx = ShatterGoldenEggModel.getExtra2EggsData("mode_idx") or 0
	if self.is2EggMode and mode_idx == 1 then
		local button_icon = logics[3].button_icon
		for k, v in ipairs(self.ItemButtonList) do
			if IsEquals(v) then
				self:ChangeButtonSkin(v, button_icon)
			end
		end
		self:ChangeHammerSkin(logics[3].icon)
	else
		for k, v in ipairs(self.ItemButtonList) do
			if IsEquals(v) then
				self:ChangeButtonSkin(v, logics[k].button_icon)
			end
		end
		local hammer_idx = ShatterGoldenEggLogic.GetHammer()
		self:ChangeHammerSkin(logics[hammer_idx].icon)
	end]]--
end

function ShatterGoldenEggPanel:SelectBestHammer(normal)
	local jingbi = MainModel.GetItemCount("jing_bi")

	if normal then
		local config = ShatterGoldenEggModel.getHammerNormalConfig()
		for idx = 1, #config do
			if jingbi < config[idx].auto_select_max_money or config[idx].auto_select_max_money == -1 then
				return idx
			end
		end
		return 1
	else
		local config = ShatterGoldenEggModel.getHammer2EggConfig()

		local mode_idx = ShatterGoldenEggModel.getExtra2EggsData("mode_idx") or 0
		if mode_idx == 1 then
			for idx = 4, 6 do
				if jingbi < config[idx].auto_select_max_money or config[idx].auto_select_max_money == -1 then
					return idx - 3
				end
			end
		else
			for idx = 1, 3 do
				if jingbi < config[idx].auto_select_max_money or config[idx].auto_select_max_money == -1 then
					return idx
				end
			end
			if jingbi >= config[3].auto_select_max_money then return 3 end
		end

		return 1
	end
end

function ShatterGoldenEggPanel:UpdateHammerButton()
	local hammer_idx = ShatterGoldenEggLogic.GetHammer()

	if self.is2EggMode then
		hammer_idx = ShatterGoldenEggModel.getExtra2EggsData("mode_hammer") or hammer_idx
		--local mode_idx = ShatterGoldenEggModel.getExtra2EggsData("mode_idx") or 0
		--if mode_idx == 1 then
		--	hammer_idx = ShatterGoldenEggModel.getExtra2EggsData("mode_hammer") or hammer_idx
		--end
	end

	for k, v in ipairs(self.ItemButtonList) do
		if IsEquals(v) then
			local icon_up = v.transform:Find("up_btn")
			local icon_down = v.transform:Find("down_img")
			if hammer_idx == k then
				icon_up.gameObject:SetActive(false)
				icon_down.gameObject:SetActive(true)
			else
				icon_up.gameObject:SetActive(true)
				icon_down.gameObject:SetActive(false)
			end

			local hammer_count = ShatterGoldenEggModel.getHammerCount(k)
			local time_count = v.transform:Find("count/time_count")
			local jingbi_count = v.transform:Find("count/jingbi_count")
			if not self.is2EggMode and hammer_count > 0 then
				time_count.gameObject:SetActive(true)
				jingbi_count.gameObject:SetActive(false)
				local times_txt = v.transform:Find("count/time_count/count_txt"):GetComponent("Text")
				times_txt.text = hammer_count
			else
				time_count.gameObject:SetActive(false)
				jingbi_count.gameObject:SetActive(true)
				local times_txt = v.transform:Find("count/jingbi_count/count_txt"):GetComponent("Text")
				local money = ShatterGoldenEggModel.getBaseMoney(k, self.is2EggMode)
				times_txt.text = StringHelper.ToCash(money)
			end
		end
	end
end

function ShatterGoldenEggPanel:ChangeButtonSkin(btn, iconName)
	local sprite = GetTexture(iconName)
	if not sprite then
		print("[SGEP] ChangeButtonSkin failed, sprite invalid:" .. iconName)
		return
	end

	local icon_up = btn.transform:Find("up_btn/hammer_img"):GetComponent("Image")
	icon_up.sprite = sprite
	local icon_down = btn.transform:Find("down_img/hammer_img"):GetComponent("Image")
	icon_down.sprite = sprite
end

--effects
function ShatterGoldenEggPanel:ToTop(obj)
	if not IsEquals(obj) then return end

	local icon = obj.transform:Find("Icon")
	local canvas = icon:GetComponent("Canvas")
	canvas.sortingOrder = 6
end

function ShatterGoldenEggPanel:ToNormal(obj)
	if not IsEquals(obj) then return end

	local icon = obj.transform:Find("Icon")
	local canvas = icon:GetComponent("Canvas")
	canvas.sortingOrder = 5
end

function ShatterGoldenEggPanel:CalculateAward(list, idx)
	idx = idx or -1

	local total = 0

	if idx <= 0 then
		for k, v in pairs(list) do
			total = total + v.award_value
		end
	else
		for k, v in pairs(list) do
			if idx == v.egg_no then
				total = v.award_value
				break
			end
		end
	end

	return total
end

function ShatterGoldenEggPanel:CalculateAwardLevel(award)
	if award <= 0 then
		return 0
	elseif award < 4 then
		return 1
	elseif award < 12 then
		return 2
	else
		return 3
	end
end

function ShatterGoldenEggPanel:PlayFirework(list, callback)
	if list then
		local total = self:CalculateAward(list)
		if total > 0 then
			local hammer_idx = ShatterGoldenEggLogic.GetHammer()
			local jingbi = total * ShatterGoldenEggModel.getBaseMoney(hammer_idx, self.is2EggMode)
			if self.is2EggMode then 
				 jingbi = total * ShatterGoldenEggModel.getBaseMoney(self.base2eggindex, self.is2EggMode)
			end 
			self.flyingMoney = self.flyingMoney + jingbi
		end

		if total < 12 then return end
	end

	self:PlayParticle(self.EffectMap["_P_"], "Zajindan_Cj", Vector3.zero, 6, callback)
end

function ShatterGoldenEggPanel:PlayCover(list, name, period, finally_callback, callbackOffsetTime, callback)
	local transform = self.transform
	if self.is2EggMode or not IsEquals(transform) then return end

	local eggTbl = self.ItemRoundList
	local finally_count = 0
	local count = 0
	for _, v in pairs(list) do
		local container = self.EffectMap[v] or {}
		self.EffectMap[v] = container

		if IsEquals(eggTbl[v]) then
			self:PlayParticle(container, name, eggTbl[v].transform.position, period, function()
				finally_count = finally_count + 1

				if finally_count >= #list then
					if finally_callback then finally_callback() end
				end
			end, callbackOffsetTime, function()
				count = count + 1
				if count >= #list then
					if callback then callback() end
				end
			end)
		end
	end
end

function ShatterGoldenEggPanel:PlayTitle(name)
	if not self.EffectMap["_I_"] then return end

	local NTBL = {
		["YWDJ"] = {
			"zjd_imgf_05",
			"zjd_imgf_06",
			"zjd_imgf_07",
			"zjd_imgf_08"
		},
		["TNSH"] = {
			"zjd_imgf_01",
			"zjd_imgf_02",
			"zjd_imgf_03",
			"zjd_imgf_04"
		},
		["YCDY"] = {
			"zjd_imgf_09",
			"zjd_imgf_10",
			"zjd_imgf_11",
			"zjd_imgf_12"
		},
		["ZLNC"] = {
			"zjd_imgf_13",
			"zjd_imgf_14",
			"zjd_imgf_15",
			"zjd_imgf_16"
		},
	}

	local ziti = self.EffectMap["_I_"]["ZJD_Title"]
	if not IsEquals(ziti) then return end

	local tbl = NTBL[name]
	if not tbl then
		print("[SGE] PlayTitle failed, tbl is invalid:" .. name)
		return
	end

	local transform = ziti.transform
	for idx = 1, 4, 1 do
		local image = transform:Find("Offset/Zjd_ZiTi/Image_" .. idx):GetComponent("Image")
		image.sprite = GetTexture(tbl[idx])
	end

	local callbacks = {
		{
			stamp = 2,
			method = function()
				--delay
			end
		}
	}

	ziti.gameObject:SetActive(true)
	self:PlayAnimation(ziti, "play", 0, callbacks, function()
		if not IsEquals(ziti) then return end
		self:PlayAnimation(ziti, "idle", 0)
		ziti.gameObject:SetActive(false)
	end)
end

function ShatterGoldenEggPanel:PlayBrokenSound(list, normal, bgm)
	local total = self:CalculateAward(list)
	if total == 0 then
		--if normal then ExtendSoundManager.PlaySound(audio_config.qql.bgm_kongdan.audio_name) end
	elseif total < 4 then
		if normal then ExtendSoundManager.PlaySound(audio_config.qql.bgm_1bei.audio_name) end
	elseif total < 12 then
		if normal then ExtendSoundManager.PlaySound(audio_config.qql.bgm_4bei.audio_name) end
	else
		if bgm then ExtendSoundManager.PlaySceneBGM(audio_config.qql.bgm_7bei.audio_name,true) end
	end
end

function ShatterGoldenEggPanel:FlyMoney(list, slot_idx)
	if not IsEquals(self.gold_txt) then return end

	local total = self:CalculateAward(list)
	if total <= 0 then return end

	local self_award = 0
	slot_idx = slot_idx or -1
	if slot_idx > 0 then
		self_award = self:CalculateAward(list, slot_idx)
		if self_award <= 0 then return end
	end

	local hammer_idx = ShatterGoldenEggLogic.GetHammer()

	local jingbi = total * ShatterGoldenEggModel.getBaseMoney(hammer_idx, self.is2EggMode)
	if self.is2EggMode then 
		 jingbi = total * ShatterGoldenEggModel.getBaseMoney(self.base2eggindex, self.is2EggMode)
	end 
	--self.totalMoney = self.totalMoney + jingbi
	--如果是財神模式，不再是38倍的奖励，而是2倍，所以38/19=2
	if self.is2EggMode then 
		jingbi=jingbi/19
		dump(jingbi,"<color=red>000000000000000000000000000000000000</color>")
	end 

	local piaojinbi_sound = audio_config.game.bgm_dapiaojinbi.audio_name
	if total < 4 then
		piaojinbi_sound = audio_config.game.bgm_xiaopiaojinbi.audio_name
	elseif total < 12 then
		piaojinbi_sound = audio_config.game.bgm_zhongpiaojinbi.audio_name
	end

	local parent = GameObject.Find("Canvas/LayerLv5").transform
	local target = self.gold_txt.transform.position

	local execute_count = 0

	local function play_fire(egg, money, level)
		if not IsEquals(egg) then return end
		local icon = egg.transform:Find("Icon")
		local point = icon.position + Vector3.New(0, ICON_HEIGHT + 64, 0)
		ExtendSoundManager.PlaySound(audio_config.game.bgm_jinbichuchang.audio_name)

		ComFlyAnim.Create(level, point, target, "jing_bi", money, function()
			self.totalMoney = self.totalMoney + jingbi
			self.flyingMoney = Mathf.Clamp(self.flyingMoney - (money or 0), 0, self.flyingMoney)
			if self.flyingMoney == 0 then
				self.totalMoney = MainModel.UserInfo.jing_bi
			end
			self:UpdateGold()
			ExtendSoundManager.PlaySound(piaojinbi_sound)
		end, parent)
	end

	local play_function = function(money)
		local transform = self.transform
		if not IsEquals(transform) then return end

		if execute_count > 0 then return end
		execute_count = execute_count + 1

		if slot_idx <= 0 then
			local award_count = 0
			for k, v in pairs(list) do
				if v.award_value > 0 then
					award_count = award_count + 1
				end
			end
			for k, v in pairs(list) do
				if v.award_value > 0 then
					award_count = award_count - 1
					if award_count > 0 then
						play_fire(self.ItemRoundList[v.egg_no], nil, self:CalculateAwardLevel(v.award_value))
					else
						play_fire(self.ItemRoundList[v.egg_no], money, self:CalculateAwardLevel(v.award_value))
					end
				end
			end
		else
			play_fire(self.ItemRoundList[slot_idx], money, self:CalculateAwardLevel(self_award))			
		end
		self:PushTimer(hammer_idx, 1)
	end

	if total >= 12 then
		local waitTime = 10
		local tween_key = nil
		self:PushTimer(hammer_idx, waitTime)
		self.playAwardAnim = true
		
		local callbacks = {
			{
				stamp = 0.5,
				method = function()
					ShatterGoldenRewardPanel.Create({money = jingbi, callback = function()
						self:PushTimer(hammer_idx, -1)
						ExtendSoundManager.PlaySceneBGM(audio_config.qql.bgm_zajindanbeijing.audio_name, true)
						play_function(jingbi)

						if tween_key then
							DOTweenManager.KillAndRemoveTween(tween_key)
							self.playAwardAnim = false
						end
					end, parent = self.popLayer})
				end
			},
			{
				stamp = waitTime - 0.5,
				method = function()
				end
			}
		}
		tween_key = ShatterGoldenEggLogic.TweenDelay(callbacks, function()
			if tween_key then
				Event.Brocast("view_sge_reward_close")
				ExtendSoundManager.PlaySceneBGM(audio_config.qql.bgm_zajindanbeijing.audio_name, true)
				play_function(jingbi)
				self.playAwardAnim = false
			end
		end)
	else
		play_function(jingbi)
	end
end

function ShatterGoldenEggPanel:CatchAllAtOnce(focus_idx, list)
	local hammer_idx = ShatterGoldenEggLogic.GetHammer()
	local stateConfig = ShatterGoldenEggModel.getStateConfig()

	self.locked = true

	local total = self:CalculateAward(list)
	local total_count = 0

	ExtendSoundManager.PlaySound(audio_config.qql.bgm_jinzhangshike.audio_name)
	self:PlayCover({focus_idx}, "jindan_glow_H", 2, function()
	end, 2, function()
		local transform = self.transform
		if not IsEquals(transform) then return end

		self:PlayTitle("YWDJ")
		local hammer = self.EffectMap["_I_"]["DaChui_YwdJ"]
		if not hammer then
			self.locked = false

			print("[SGE] CatchAllAtOnce failed, hammer is invalid")
			return
		end
		hammer.gameObject:SetActive(true)

		local callbacks = {
			{
				stamp = 3.9,
				method = function()
					local transform = self.transform
					if not IsEquals(transform) then return end

					local lcount = 0
					for _, v in pairs(list) do
						ShatterGoldenEggModel.setState(hammer_idx, v.egg_no, stateConfig.BROKEN)
						self:ShowAward(hammer_idx, v.egg_no, v.award, function()
							self:SpawnNotice(hammer_idx)

							lcount = lcount + 1
							if lcount >= #list then
								self:FlyMoney(list)
							end
						end, "jindan_Particle_M", 2.25, 0.15, function()
							if total >= 12 and total_count == 0 then
								total_count = total_count + 1
								self:PlayParticle(self.EffectMap["_P_"], "jinbi_glow_H", Vector3.zero, 3)
							end
						end)
						local egg = self.ItemRoundList[v.egg_no]
						if IsEquals(egg) then
							self:PlayAnimation(egg, "broken", 0)
						end
					end
					self:PushTimer(hammer_idx, 4)
				end
			},
			{
				stamp = 1,
				method = function()
					--delay
				end
			}
		}

		ExtendSoundManager.PlaySound(audio_config.qql.bgm_yiwangdajin.audio_name)
		self:PlayAnimation(hammer, "hit", 0, callbacks, function()
			self.locked = false

			if IsEquals(hammer) then
				hammer.gameObject:SetActive(false)
			end

			self:UpdateGold()
			self:UpdateEggTotal()
			self:PlayBrokenSound(list, true, true)
		end)
	end)

	self:PushTimer(hammer_idx, 10)
end

function ShatterGoldenEggPanel:ContinuousHit(focus_idx, list)
	local hammer_idx = ShatterGoldenEggLogic.GetHammer()
	local stateConfig = ShatterGoldenEggModel.getStateConfig()

	local state = ShatterGoldenEggModel.getStates(hammer_idx)
	if not state then
		print("[SGE] ContinuousHit getStates failed:" .. hammer_idx .. ": " .. focus_idx)
		return
	end
	local state_count = #state
	local focus_award = 0

	local egg_tbl = {}
	for k, v in pairs(list) do
		if focus_idx ~= v.egg_no then
			egg_tbl[v.egg_no] = v
		else
			focus_award = v.award
		end
	end
	if focus_award == 0 then
		print("[SGE] ContinuousHit focus_award failed:" .. hammer_idx .. ": " .. focus_idx)
		return
	end

	local total = self:CalculateAward(list)
	local total_count = 0

	local period = 1
	local hit_total = #list - 1
	local hit_count = 0

	local broken_focus = function()
		local transform = self.transform
		if not IsEquals(transform) then return end

		ShatterGoldenEggModel.setState(hammer_idx, focus_idx, stateConfig.BROKEN)

		self:UpdateGold()
		self:UpdateEggTotal()
		self:PlayBrokenSound(list, true, true)

		self:ShowAward(hammer_idx, focus_idx, focus_award, function()
			self.locked = false
			self:SpawnNotice(hammer_idx)
			self:FlyMoney(list)
		end, "jindan_Particle_M", 2.25, 0.15, function()
			if total >= 12 and total_count == 0 then
				total_count = total_count + 1
				self:PlayParticle(self.EffectMap["_P_"], "jinbi_glow_H", Vector3.zero, 3)
			end
		end)
		self:PushTimer(hammer_idx, 4)
		local egg = self.ItemRoundList[focus_idx]
		if IsEquals(egg) then
			self:PlayAnimation(egg, "broken", 0)
		end
	end

	local next_idx = function(idx)
		local new_idx = (idx % state_count) + 1
		while new_idx ~= focus_idx and state[new_idx] == stateConfig.BROKEN do
			new_idx = (new_idx % state_count) + 1
		end
		return new_idx
	end

	local LOOP_NUM = 3
	local loop_count = 0
	local sound_key = ""

	local recursion
	recursion = function(egg_idx)
		local transform = self.transform
		if not IsEquals(transform) then return end

		local period = 0.15
		local effect_name = "jindan_glow_L"
		if egg_idx == focus_idx and loop_count == 0 then
			effect_name = "jindan_glow_H"
			period = 1.5
			ExtendSoundManager.PlaySound(audio_config.qql.bgm_jinzhangshike.audio_name)
		end

		self:PlayCover({egg_idx}, effect_name, period, function()
			local transform = self.transform
			if not IsEquals(transform) then return end

			if egg_idx == focus_idx then
				if loop_count == 0 then
					sound_key = ExtendSoundManager.PlaySound(audio_config.qql.bgm_zailaiyici.audio_name, 2)
				end
				loop_count = loop_count + 1

				if hit_count <= 0 then
					self:PlayTitle("ZLNC")
				end
			end

			if egg_tbl[egg_idx] and loop_count >= LOOP_NUM then
				hit_count = hit_count + 1
				loop_count = 0

				if sound_key ~= "" and sound_key ~= nil then
					soundMgr:Pause(sound_key)
				else
					print("[SGE] ContinuousHit PlaySound failed:" .. audio_config.qql.bgm_zailaiyici.audio_name)
				end

				ShatterGoldenEggModel.setState(hammer_idx, egg_idx, stateConfig.BROKEN)
				self:ShowAward(hammer_idx, egg_idx, egg_tbl[egg_idx].award, function()
					if hit_count < hit_total then
						recursion(focus_idx)
					else
						broken_focus()
					end
				end, "jindan_Particle_M", 2.25,0.15)
				self:PushTimer(hammer_idx, 4)
				self:UpdateEggTotal()

				local egg = self.ItemRoundList[egg_idx]
				if IsEquals(egg) then
					self:PlayAnimation(egg, "broken", 0)
				end
				ExtendSoundManager.PlaySound(audio_config.qql.bgm_zailaiyicidanbao.audio_name)

				egg_tbl[egg_idx] = nil
			else
				recursion(next_idx(egg_idx))
				self:PushTimer(hammer_idx, period + period)
			end

		end)
	end

	self.locked = true
	recursion(focus_idx)

	self:PushTimer(hammer_idx, 10)
end

function ShatterGoldenEggPanel:FairiesSpreadingFlowers(focus_idx, list)
	local hammer_idx = ShatterGoldenEggLogic.GetHammer()
	local stateConfig = ShatterGoldenEggModel.getStateConfig()

	local total = self:CalculateAward(list)
	local total_count = 0

	local period = 1
	local list_count = #list
	local unbroken_tbl = ShatterGoldenEggLogic.GetUnBrokenList(hammer_idx)
	local unbroken_count = #unbroken_tbl

	local G_NUM = 6

	local group = {}
	if unbroken_count > list_count then
		local RND_NUM = G_NUM - 1

		local cnt = math.floor(unbroken_count / list_count)
		while #group < RND_NUM do
			local rnd_tbl = mix_table_index(unbroken_tbl)
			for idx = 1, cnt, 1 do
				local g = {}
				for jdx = 1, list_count, 1 do
					g[jdx] = unbroken_tbl[rnd_tbl[(idx - 1) * list_count + jdx]]
				end
				table.insert(group, g)

				if #group >= RND_NUM then break end
			end
		end
	end

	local result = {}
	for k, v in pairs(list) do
		result[k] = v.egg_no
	end
	table.insert(group, result)

	local recursion
	recursion = function(group_idx)
		local transform = self.transform
		if not IsEquals(transform) then return end

		self:PlayCover(group[group_idx], "jindan_glow_L", period, function()
			local transform = self.transform
			if not IsEquals(transform) then return end

			if group_idx >= #group then
				local lcount = 0
				for k, v in pairs(group[group_idx]) do
					ShatterGoldenEggModel.setState(hammer_idx, v, stateConfig.BROKEN)
					self:ShowAward(hammer_idx, v, list[k].award, function()
						self.locked = false
						self:SpawnNotice(hammer_idx)

						lcount = lcount + 1
						if lcount >= #list then
							self:FlyMoney(list)
						end
					end, "jindan_Particle_M", 2.25, 0.15, function()
						if total >= 12 and total_count == 0 then
							total_count = total_count + 1
							self:PlayParticle(self.EffectMap["_P_"], "jinbi_glow_H", Vector3.zero, 3)
						end
					end)

					local egg = self.ItemRoundList[v]
					if IsEquals(egg) then
						self:PlayAnimation(egg, "broken", 0)
					end
				end
				self:PushTimer(hammer_idx, 4)

				self:UpdateGold()
				self:UpdateEggTotal()
				self:PlayBrokenSound(list, true, true)
			else
				recursion(group_idx + 1)
				self:PushTimer(hammer_idx, period + period)
			end
		end)
	end

	self.locked = true

	ExtendSoundManager.PlaySound(audio_config.qql.bgm_jinzhangshike.audio_name)
	self:PlayCover({focus_idx}, "jindan_glow_H", 2, function()
		local transform = self.transform
		if not IsEquals(transform) then return end

		self:PlayTitle("TNSH")
		ExtendSoundManager.PlaySound(audio_config.qql.bgm_tiannvsanhua.audio_name)
		recursion(1)
	end)
	self:PushTimer(hammer_idx, 10)
end

function ShatterGoldenEggPanel:BigHammer(focus_idx, list)
	local hammer_idx = ShatterGoldenEggLogic.GetHammer()
	local stateConfig = ShatterGoldenEggModel.getStateConfig()

	local period = 1
	local list_count = #list

	self.locked = true

	local total = self:CalculateAward(list)
	local total_count = 0

	ExtendSoundManager.PlaySound(audio_config.qql.bgm_jinzhangshike.audio_name)
	self:PlayCover({focus_idx}, "jindan_glow_H", 1, function()
	end, 2, function()
		local transform = self.transform
		if not IsEquals(transform) then return end

		local egg = self.ItemRoundList[focus_idx]
		if not IsEquals(egg) then
			self.locked = false

			print("[SGE] BigHammer failed, egg is invalid:" .. focus_idx)
			return
		end

		local hammer = self.EffectMap["_I_"]["BigHammer"]
		if not hammer then
			self.locked = false

			print("[SGE] BigHammer failed, hammer is invalid")
			return
		end
		hammer.gameObject:SetActive(true)
		hammer.transform.position = egg.transform.position

		local callbacks = {
			{
				stamp = 3.6,
				method = function()
					local transform = self.transform
					if not IsEquals(transform) then return end

					local lcount = 0
					for k, v in pairs(list) do
						ShatterGoldenEggModel.setState(hammer_idx, v.egg_no, stateConfig.BROKEN)
						self:ShowAward(hammer_idx, v.egg_no, v.award, function()
							self:SpawnNotice(hammer_idx)

							lcount = lcount + 1
							if lcount >= #list then
								self:FlyMoney(list)
							end
						end, "jindan_Particle_M", 2.25, 0.15, function()
							if total >= 12 and total_count == 0 then
								total_count = total_count + 1
								self:PlayParticle(self.EffectMap["_P_"], "jinbi_glow_H", Vector3.zero, 3)
							end
						end)
						local egg = self.ItemRoundList[v.egg_no]
						if IsEquals(egg) then
							self:PlayAnimation(egg, "broken", 0)
						end
					end
					self:PushTimer(hammer_idx, 4)
				end
			},
			{
				stamp = 0.5,
				method = function()
					--delay
				end
			}
		}

		self:PlayTitle("YCDY")
		ExtendSoundManager.PlaySound(audio_config.qql.bgm_yichuidingyin.audio_name)
		self:PlayAnimation(hammer, "hit", 0, callbacks, function()
			self.locked = false

			if IsEquals(hammer) then
				hammer.gameObject:SetActive(false)
			end

			self:UpdateGold()
			self:UpdateEggTotal()
			self:PlayBrokenSound(list, true, true)
		end)
	end)

	self:PushTimer(hammer_idx, 10)
end

--[[function ShatterGoldenEggPanel:ContinuousHit(focus_idx, list)
	local hammer_idx = ShatterGoldenEggLogic.GetHammer()
	local state = ShatterGoldenEggModel.getStates(hammer_idx)
	if not state then
		print("[SGE] ContinuousHit getStates failed:" .. hammer_idx)
		return
	end
	local state_count = #state
	local egg_tbl = {}
	for k, v in pairs(list) do
		egg_tbl[v.egg_no] = v
	end
	local period = 1
	local hit_total = #list
	local hit_count = 0
	local stateConfig = ShatterGoldenEggModel.getStateConfig()
	local next_idx = function(idx)
		local new_idx = (idx % state_count) + 1
		while state[new_idx] == stateConfig.BROKEN do
			new_idx = (new_idx % state_count) + 1
		end
		return new_idx
	end
	local recursion
	recursion = function(egg_idx)
		local transform = self.transform
		if not IsEquals(transform) then return end
		local period = 0.15
		local effect_name = "jindan_glow_L"
		if egg_idx == focus_idx then
			effect_name = "jindan_glow_H"
			period = 0.25
		end
		self:PlayCover({egg_idx}, effect_name, period, function()
			local transform = self.transform
			if not IsEquals(transform) then return end
			if egg_tbl[egg_idx] then
				hit_count = hit_count + 1
				ShatterGoldenEggModel.setState(hammer_idx, egg_idx, stateConfig.BROKEN)
				self:ShowAward(hammer_idx, egg_idx, egg_tbl[egg_idx].award, function()
					if hit_count < hit_total then
						recursion(focus_idx)
					else
						self.locked = false
					end
				end, "jindan_Particle_M", 2.25,0.15)
				self:PushTimer(hammer_idx, 4)
				local egg = self.ItemRoundList[egg_idx]
				if IsEquals(egg) then
					self:PlayAnimation(egg, "broken", 0)
					--if v == 1 then
					--	self:PlayAnimation(egg, "blast", 0)
					--else
					--	self:PlayAnimation(egg, "broken", 0)
					--end
				end
				egg_tbl[egg_idx] = nil
			else
				recursion(next_idx(egg_idx))
				self:PushTimer(hammer_idx, period + period)
			end
		end)
	end
	self.locked = true
	recursion(focus_idx)
	self:PushTimer(hammer_idx, hit_total)
end]]--
local TASK_ID = 100
function ShatterGoldenEggPanel.handle_task_change(_, data)
	if not instance then return end
	if data.id ~= TASK_ID then return end
	instance:RefreshTask(data)
end
function ShatterGoldenEggPanel:RefreshTask(data)
	if not GameGlobalOnOff.ZJD_EVE then return end
	local task_data = data
	if task_data == nil then
		task_data = GameTaskModel.GetTaskDataByID(TASK_ID)
	end
	if task_data == nil then return end
	--local event_active = ShatterGoldenEvent.CheckActive()
	local event_active = task_data.award_status
	if event_active == 1 then
		instance.red_img.gameObject:SetActive(true)
		instance:PlayAnimation(instance.event_node, "jumping", 0)
	else
		if instance and instance.red_img and IsEquals(instance.red_img) then
			instance.red_img.gameObject:SetActive(false)
		end
		instance:PlayAnimation(instance.event_node, "idle", 0)
	end
end
function ShatterGoldenEggPanel:handle_sge_event_begin()
	if not IsEquals(self.event_node) then return end
	self.event_node.gameObject:SetActive(true)
	local parent = GameObject.Find("Canvas/LayerLv5").transform
	ShatterGoldenEvent.Create(parent)
	--print("begin ...")
end
function ShatterGoldenEggPanel:handle_sge_event_end()
	if not IsEquals(self.event_node) then return end
	self.event_node.gameObject:SetActive(true)
	--print("end......")
end
function ShatterGoldenEggPanel:handle_sge_event_over()
	if not IsEquals(self.event_node) then return end
	self.event_node.gameObject:SetActive(false)
	if ShatterGoldenEvent.IsShow() then
		ShatterGoldenEvent.Close()
	end
	--print("over.....")
end
function ShatterGoldenEggPanel:handle_sge_sale_close(hammer_idx)
	if not IsEquals(self.sale_fly_icon) then return end

	local countdown = ShatterGoldenEggLogic.GetHammerData(hammer_idx, "sale_countdown") or 0
	if countdown <= 0 then return end

	local targetNode = self.sale_fly_icon.transform
	local targetPoint = targetNode.position
	local targetScale = 1

	targetNode.position = Vector3.zero
	targetNode.gameObject:SetActive(true)

	ShatterGoldenEggLogic.FlyingToTarget(targetNode, targetPoint, targetScale, 0.3, function()
		if not IsEquals(targetNode) then return end
		targetNode.gameObject:SetActive(false)
	end)
end

function ShatterGoldenEggPanel:handle_sge_sale_countdown(data)
	if not IsEquals(self.timer_txt) then return end

	local hammer_idx = data.hammer_idx
	local txt = data.timer

	self.timer_txt.text = txt
	if txt == "00:00:00" then
		if self.sale_node.gameObject.activeSelf then
			self.sale_node.gameObject:SetActive(false)
		end
	else
		if not self.sale_node.gameObject.activeSelf then
			self.sale_node.gameObject:SetActive(true)
		end

		--self:ShowSaleUI(hammer_idx)
	end
end

--function ShatterGoldenEggPanel:handle_sge_show_sale(hammer_idx)
--	self:ShowSaleUI(hammer_idx)
--end

function ShatterGoldenEggPanel:handle_sge_hide_sale(hammer_idx)
	if not IsEquals(self.sale_node) then return end

	if self.sale_node.gameObject.activeSelf then
		self.sale_node.gameObject:SetActive(false)
	end
end

local PREF_KEY = "SGE_SALE_DAY_"
function ShatterGoldenEggPanel:UpdateSaleUIToday(hammer_idx)
	local key = PREF_KEY .. tostring(hammer_idx)

	local last_day = PlayerPrefs.GetInt(key) or 0
	local curr_day = tonumber(os.date("%d", os.time()))
	if last_day == curr_day then return false end
	PlayerPrefs.SetInt(key, curr_day)

	return true
end

function ShatterGoldenEggPanel:ShowSaleUI(hammer_idx)
	if not IsEquals(self.ShopNode) then return false end

	if GameManager.GotoUI({gotoui = "gift_shatter_golden_sale",goto_scene_parm = "is_show"}) then return true end
	if not self:UpdateSaleUIToday(hammer_idx) then return false end

	GameManager.GotoUI({gotoui = "gift_shatter_golden_sale",goto_scene_parm = "panel",parm1 = self.ShopNode, parm2 = hammer_idx, parm3 = basefunc.handler(self, self.OnCloseSaleBox)})
	return true
end

function ShatterGoldenEggPanel:on_model_sge_exception(result)
	if result == 1003 then	--数据不合法
		self:SwitchAutoHitEgg(false)
	end
end

function ShatterGoldenEggPanel.get_base2eggindex()
	if instance then
		return instance.base2eggindex
	end
end

function ShatterGoldenEggPanel:ReConnecteServerSucceed()
	Network.SendRequest("zajindan_get_all_info")
	print("<color=red>砸金蛋断线重连00000000</color>")
end


--[[
	GetTexture("Hammer")
]]