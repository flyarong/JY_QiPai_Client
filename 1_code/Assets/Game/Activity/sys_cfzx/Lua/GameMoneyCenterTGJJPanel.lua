-- 创建时间:2018-12-20

local basefunc = require "Game.Common.basefunc"

GameMoneyCenterTGJJPanel = basefunc.class()

local C = GameMoneyCenterTGJJPanel

C.name = "GameMoneyCenterTGJJPanel"

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
	self.lister["AssetChange"] = basefunc.handler(self, self.RefreshMoney)
	self.lister["model_goldpig_profit_cache_change"] = basefunc.handler(self, self.model_goldpig_profit_cache_change)
	self.lister["model_on_sczd_activate_change_msg"] = basefunc.handler(self, self.InitRewardList)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyClose()
	self:ClearCellList()
	self:MyExit()
end

function C:MyExit()
	self:RemoveListener()
	self.MoneyCenterShowPrefab:MyExit()
	GameMoneyCenterIncomeSpendingPanel.Close()
	destroy(self.gameObject)
end

function C:ctor(parent)

	ExtPanel.ExtMsg(self)

	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj

	self:MakeLister()
	self:AddMsgListener()
	LuaHelper.GeneratingVar(self.transform, self)

    self.moneyinfo_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
        self:OnMoneyInfoClick()
    end)
	self.TX_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
        self:OnTXClick()
	end)
	
	self.goldpig_cache_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
        self:OnGoldPigCacheClick()
	end)
	
	self.CopyWX_btn.onClick:AddListener(
		function()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
			LittleTips.Create("已复制微信号请前往微信进行添加")
			UniClipboard.SetText(self.WXCode_txt.text)
		    Application.OpenURL("weixin://");			
		end
	)
 --    self.PRdsj_btn.onClick:AddListener(
	-- 	function()
	-- 		self:PREnough()
	-- 	end
	-- )
	self:InitUI()
end

function C:InitUI()
	self:RefreshMoney()
	self:UpdateUI()
	self:InitRewardList()
	self:AddShowTipListener()

	self.GiftReward_btn.gameObject:SetActive(GameGlobalOnOff.LIBAO)
	self.PlayerReward_btn.gameObject:SetActive(GameGlobalOnOff.LIBAO)
end

function C:InitRewardList()
	self.enablePlayerReward = GameMoneyCenterModel.data.is_activate_xj_profit == 1
	self.enablePlayerReward2 = GameMoneyCenterModel.data.is_activate_xj_profit2 == 1
	self.enablePlayerReward3 = GameMoneyCenterModel.data.is_activate_xj_profit3 == 1
	self.enableGiftReward = GameMoneyCenterModel.data.is_active_tglb1_profit == 1
	self.enableMatchReward = GameMoneyCenterModel.data.is_activate_bisai_profit == 1
	self.enableTeamReward = GameMoneyCenterModel.data.is_activate_gjhhr == 1
	self.buyItem199 = MainModel.GetItemStatus(GOODS_TYPE.gift_bag, 12) == 0 or MainModel.GetItemStatus(GOODS_TYPE.gift_bag, 30) == 0
	self.buyItem499 = MainModel.GetItemStatus(GOODS_TYPE.gift_bag, 32) == 0 and (MainModel.GetItemStatus(GOODS_TYPE.gift_bag, 33) == 1 or GoldenPigModel.GetPig2RemainNum() > 0)

	--[[if not self.enablePlayerReward or (self.enablePlayerReward and self.buyItem199 and self.buyItem499) then
		self.PRTip_txt.text = "推广一位有效玩家奖励1元" .. 
							"\n自购金猪199后推广一位有效玩家奖励提升为3元" .. 
							"\n自购金猪499后推广一位有效玩家奖励提升为5元" .. 
							"\n（完成第二天生财任务视为有效玩家）"
	else
		self.PRTip_txt.text = "推广一位有效玩家奖励1元" ..
							"\n自购金猪199后推广一位有效玩家奖励提升为3元" .. (self.buyItem199 and "" or "（未开启）") .. 
							"\n自购金猪499后推广一位有效玩家奖励提升为5元" .. (self.buyItem499 and "" or "（未开启）") ..
							"\n（完成第二天生财任务视为有效玩家）"
	end
	self.GRTip_txt.text = "推广的玩家购买金猪199奖励50元，购买金猪499奖励100元。"
	self.TRTip_txt.text = "享受团队奖金。"]]
	self.PRTip_txt.text = "好友总数≤3人，奖励1元/人" ..
							"\n好友总数＞3人且≤10人，奖励2元/人" ..
							"\n好友总数＞10人且≤20人，奖励3元/人（购买金猪199，直接享受此奖励）" ..
							"\n好友总数＞20人，奖励5元/人（购买金猪499，直接享受此奖励）" ..
							"\n好友完成第2天生财任务立即奖励"
	self.GRTip_txt.text = "好友购买金猪199立即奖励50元；\n购买金猪499立即奖励100元；\n好友购买全返礼包立即奖励50元"
	self.MRTip_txt.text = "好友参与千元赛并取得名次，\n立即奖励3元/人"
	self.TRTip_txt.text = "享受团队奖励"
	self.PRDisabled_img.gameObject:SetActive(not self.enablePlayerReward)
	self.GRDisabled_img.gameObject:SetActive(not self.enableGiftReward)
	self.MRDisabled_img.gameObject:SetActive(not self.enableMatchReward)
	self.TRDisabled_img.gameObject:SetActive(not self.enableTeamReward)
	self.PREnabled_img.gameObject:SetActive(self.enablePlayerReward)
	self.GREnabled_img.gameObject:SetActive(self.enableGiftReward)
	self.MREnabled_img.gameObject:SetActive(self.enableMatchReward)
	self.TREnabled_img.gameObject:SetActive(self.enableTeamReward)

	self.PRdsj_btn.gameObject:SetActive(false)
	-- self.PRdsj_btn.gameObject:SetActive(self:IsShow())
	-- self.PlayerReward_btn.onClick:AddListener(
	-- 	function ()
	-- 	     self:PREnough()
	-- 	end
	-- )
	-- dump(self.enablePlayerReward,"<color=red>-----玩家好友-------</color>")
	-- self.PlayerReward_btn.enabled=self:IsShow()
	--self.Goto_btn.gameObject:SetActive(self.enablePlayerReward and not self.buyItem199)
end

function C:PREnough()
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	local name=MainModel.UserInfo.name
	local str="["..name .."],".."恭喜您获得开通高级权限资\n格，加微信开通送66666鲸币" 
	HintCopyPanel.Create({desc=str, gzh="JY400888",title="升级邀请",gowx=true})	
end
function C:AddShowTipListener()
	----详细信息：浮窗模式
	-- EventTriggerListener.Get(self.PlayerReward_btn.gameObject).onDown = basefunc.handler(self, self.OnPlayerRewardPressed)
	-- EventTriggerListener.Get(self.GiftReward_btn.gameObject).onDown = basefunc.handler(self, self.OnGiftRewardPressed)
	-- EventTriggerListener.Get(self.MatchReward_btn.gameObject).onDown = basefunc.handler(self, self.OnMatchRewardPressed)
	-- EventTriggerListener.Get(self.TeamReward_btn.gameObject).onDown = basefunc.handler(self, self.OnTeamRewardPressed)
	-- EventTriggerListener.Get(self.PlayerReward_btn.gameObject).onUp = basefunc.handler(self, self.OnPlayerRewardReleaseed)
	-- EventTriggerListener.Get(self.GiftReward_btn.gameObject).onUp = basefunc.handler(self, self.OnGiftRewardReleaseed)
	-- EventTriggerListener.Get(self.MatchReward_btn.gameObject).onUp = basefunc.handler(self, self.OnMatchRewardReleased)
	-- EventTriggerListener.Get(self.TeamReward_btn.gameObject).onUp = basefunc.handler(self, self.OnTeamRewardReleaseed)
	-- EventTriggerListener.Get(self.Goto_btn.gameObject).onClick = basefunc.handler(self, self.OnGotoClicked)
    ----详细信息：弹窗模式
    self.MoneyCenterShowPrefab=MoneyCenterShowPrefab.Create()
	self.GRxq_btn.onClick:AddListener(
		function ()
			self.MoneyCenterShowPrefab:ShowGR()
		end
	)
	self.GiftReward_btn.onClick:AddListener(
		function ()
			self.MoneyCenterShowPrefab:ShowGR()
		end
	)
	self.PRxq_btn.onClick:AddListener(
		function ()
			self.MoneyCenterShowPrefab:ShowPR()
		end
	)
	self.PlayerReward_btn.onClick:AddListener(
		function ()
			self.MoneyCenterShowPrefab:ShowPR()
		end
	)
	self.MRxq_btn.onClick:AddListener(
		function ()
			self.MoneyCenterShowPrefab:ShowMR()
		end
	)
	self.MatchReward_btn.onClick:AddListener(
		function ()
			self.MoneyCenterShowPrefab:ShowMR()
		end
	)
	-- if self:IsShow() and GameMoneyCenterPanel.ReturnIsPopTips()  then 
	-- 	self:PREnough()
	-- end 
end
function C:RefreshMoney()
	dump(MainModel.UserInfo, "<color=yellow>MainModel.UserInfo:::</color>")
	local cash = MainModel.UserInfo.cash or 0
	self.redpacket_txt.text = StringHelper.ToRedNum(cash/100)
end

function C:IsShow()
	dump(GameMoneyCenterModel.data,"<color=red>赚钱-------------</color>")
	if GameMoneyCenterModel.data.is_activate_xj_profit2==nil or  GameMoneyCenterModel.data.my_all_son_count==nil then 
	   return false
	end 
	if  GameMoneyCenterModel.data.is_activate_xj_profit2 == 0 and GameMoneyCenterModel.data.is_activate_xj_profit == 1 then 
		return  ( GameMoneyCenterModel.data.my_all_son_count>=10)
	elseif   GameMoneyCenterModel.data.is_activate_xj_profit3 == 0 then 
		--return   (GameMoneyCenterModel.data.my_all_son_count>=20)
		return 	false
	else
		return  false
	end
end
function C:UpdateUI()
	self:ClearCellList()
	self.data = GameMoneyCenterModel.GetTgjjData()
	for k,v in ipairs(self.data) do
		local pre = nil
		if k == 3 then
			pre = MoneyCenterTGJJGoldPigPrefab.Create(self.Content.transform, v)
		else
			pre = MoneyCenterTGJJPrefab.Create(self.Content.transform, v)
		end
		self.CellList[#self.CellList + 1] = pre
	end
	self:UpdateGoldPigProfitCache()
end

function C:ClearCellList()
	if self.CellList then
		for k,v in ipairs(self.CellList) do
			v:OnDestroy()
		end
	end
	self.CellList = {}
end

function C:MyRefresh()
	self:UpdateUI()
end

function C:OnMoneyInfoClick()
	GameMoneyCenterIncomeSpendingPanel.Create()
end

function C:OnTXClick()
	MainLogic.Withdraw(self:RefreshMoney())
end

function C:UpdateGoldPigProfitCache()
	local profit_cache = GameMoneyCenterModel.GetGoldPigCacheData()
	if profit_cache and profit_cache ~= 0 then
		self.goldpig_cache_txt.text = StringHelper.ToRedNum(profit_cache / 100)
		self.goldpig_cache = profit_cache
		self.goldpig_cache_btn.gameObject:SetActive(true)
	else
		self.goldpig_cache_btn.gameObject:SetActive(false)
		self.goldpig_cache_txt.text = 0
		self.goldpig_cache = 0
	end
end

function C:OnGoldPigCacheClick()
	local goldpig_cache = self.goldpig_cache and self.goldpig_cache or 0
	local str = string.format( "购买金猪礼包后可领取%s元奖金，是否立刻前往购买",StringHelper.ToRedNum(goldpig_cache / 100))
	HintPanel.Create(2,str,function(  )
		Event.Brocast("open_golden_pig")
	end)
end

function C:model_goldpig_profit_cache_change()
	self:UpdateGoldPigProfitCache()
end

function C:OnPlayerRewardPressed()
	self.PRTip_img.gameObject:SetActive(true)
end

function C:OnGiftRewardPressed()
	self.GRTip_img.gameObject:SetActive(true)
end

function C:OnTeamRewardPressed()
	self.TRTip_img.gameObject:SetActive(true)
end

function C:OnPlayerRewardReleaseed()
	self.PRTip_img.gameObject:SetActive(false)
end

function C:OnGiftRewardReleaseed()
	self.GRTip_img.gameObject:SetActive(false)
end

function C:OnTeamRewardReleaseed()
	self.TRTip_img.gameObject:SetActive(false)
end

function C:OnMatchRewardPressed()
	self.MRTip_img.gameObject:SetActive(true)
end

function C:OnMatchRewardReleased()
	self.MRTip_img.gameObject:SetActive(false)
end

function C:OnGotoClicked()
	Event.Brocast("open_golden_pig")
end