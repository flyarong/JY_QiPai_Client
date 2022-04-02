-- 创建时间:2020-08-26
-- Panel:LWZBGamePanel
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

LWZBGamePanel = basefunc.class()
local C = LWZBGamePanel
C.name = "LWZBGamePanel"
local M = LWZBModel

local help_info = {
"                                                    <color=#FFFF00><size=40>基本规则</size></color>",
"1：游戏采用一龙四神兽百人参与的方式。龙王和四兽分别进行比牌，参与者选择四神兽进行充能，可以同时充能多个神兽。",
"2：游戏使用一副牌（不含大小王）共52张牌进行游戏。J、Q、K都是10点，其它按照牌面的点数计算。",
"3：无龙：没有任意三张牌能加起来成为10的倍数。" ,
"4：有龙：从龙一到龙九。任意三张牌相加是10的倍数，剩余两张牌相加不是10的倍数，然后取个位数，个位数是几，就是龙几。",
"5：神兽：任意三张牌相加是10的倍数，剩余两张牌相加也是10的倍数。",
"6：四方神兽：五张牌中有四张一样的牌即为四方神兽，此时不需要有兽。",
"7：五爪金龙：手上五张牌全部是J、Q、K组成的特殊神兽牌型为五彩神兽",
"8：充能结束后进行发牌，开牌后龙王和四兽进行牌型比较，牌大的赢。四兽不进行相互比较",
"                                                    <color=#FFFF00><size=40>大小规则</size></color>",
"1：单张大小：从大到小排序为：K > Q > J >10 > 9 > 8 > 7 > 6 > 5 > 4 > 3 > 2 > 1",
"2：牌型大小：从大到小排序为：五爪金龙> 四方神兽 > 神龙 > 有龙 > 没龙。",
"3：有龙大小：当都为有龙时，从大到小排序为：龙九 > 龙八 > 龙七 > 龙六 > 龙五 > 龙四 > 龙三 > 龙二 > 龙一。",
"4：牌型相同：龙王和神兽相同牌型时，挑出最大的一张牌进行比较，如果最大的牌点数一样，则龙王获胜。（特例：当有多个四方神兽时，比较四张相同的牌的点数大小）",
"                                                    <color=#FFFF00><size=40>赔率规则</size></color>",
"1：无龙、龙一：1倍。",
"2：龙二到龙九的赔率依次为：2倍、3倍、4倍、5倍、6倍、7倍、8倍、9倍",
"3：神龙、四方神兽、五爪金龙均为10倍",
"                                                    <color=#FFFF00><size=40>财神大奖</size></color>",
"1：房间内会随机触发财神赐福，在房间放出财神大奖，发放巨奖",
"2：对当前房间内的所有玩家随机抽取，幸运星、富豪NO1、龙王获得的概率略高于其他玩家（系统神龙除外）",
"3：玩家赢金的5%进入奖池",
"                                                    <color=#FFFF00><size=40>上座规则</size></color>",
"1：幸运星为上局净盈利最高的玩家（龙王除外）",
"2：富豪榜按近10局充能总量排名（龙王和幸运星除外）",
"3：每局结算后，刷新幸运星与富豪榜",
"4：幸运星、富豪榜1-5可于场上就座",
"5：每个玩家只能有一个座位，获得幸运星则当局不进入富豪榜",
"6：幸运星充能的神兽，增加星星标记",
"                                                    <color=#FFFF00><size=40>其他规则</size></color>",
"1：为了游戏公平，如果玩家在一局游戏失败后，按照游戏规则应输100金币，但是他身上只有50金币，那么赢家只能从该玩家身上得到50金币，如果有多个赢家，则赢家按照各自倍数分别按比例分配这50金币。",
"2：基于上一条，玩家在一局游戏胜利后，赢得的金币总额不会超过身上携带的金币，如某玩家按照游戏规则计算应该赢100金币，但是因为他身上只携带了50金币，所以本局该玩家只能赢取50金币。输家按照对应比例相应减少所输的金币。",
"3：龙王剩余金币≤成为龙王条件的50%，将被屠龙",
"4：玩家个人充能的总金币不能高于龙王的金币并且不能超过自身携带金币的30%",
"5：玩家个人充能的总金币根据VIP等级不同，可充能的上限值不同",
}

function C.Create()
	return C.New()
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["ExitScene"] = basefunc.handler(self,self.MyExit)
    self.lister["lwzb_xz_msg"] = basefunc.handler(self, self.on_lwzb_xz_msg)
    self.lister["lwzb_lw_fp_finish_msg"] = basefunc.handler(self,self.on_lwzb_lw_fp_finish_msg)
    self.lister["lwzb_ss_fp_finish_msg"] = basefunc.handler(self, self.on_lwzb_ss_fp_finish_msg)
    self.lister["model_lwzb_begin_bp"] = basefunc.handler(self, self.on_model_begin_bp)
    self.lister["model_lwzb_show_all_bp"] = basefunc.handler(self,self.on_model_show_all_bp)

    self.lister["model_lwzb_all_info_msg"] = basefunc.handler(self,self.on_model_lwzb_all_info_msg)
    self.lister["model_lwzb_all_info_reconnecte_msg"] = basefunc.handler(self,self.on_model_lwzb_all_info_reconnecte_msg)
    self.lister["model_lwzb_status_change_msg"] = basefunc.handler(self,self.on_model_lwzb_status_change_msg)
    self.lister["model_lwzb_total_bet_tb_msg"] = basefunc.handler(self,self.on_model_lwzb_total_bet_tb_msg)
    self.lister["model_lwzb_bet_response"] = basefunc.handler(self,self.on_model_lwzb_bet_response)

    self.lister["model_lwzb_auto_bet_response"] = basefunc.handler(self,self.on_model_lwzb_auto_bet_response)
    self.lister["model_lwzb_cancel_auto_bet_response"] = basefunc.handler(self,self.on_model_lwzb_cancel_auto_bet_response)
    self.lister["model_lwzb_continue_bet_success_mag"] = basefunc.handler(self,self.on_model_lwzb_continue_bet_success_mag)
    self.lister["model_lwzb_auto_bet_data_msg"] = basefunc.handler(self,self.on_model_lwzb_auto_bet_data_msg)
    self.lister["lwzb_jb_fly_to_player_btn_msg"] = basefunc.handler(self,self.on_lwzb_jb_fly_to_player_btn_msg)
    self.lister["model_bet_type_has_change_msg"] = basefunc.handler(self,self.on_model_bet_type_has_change_msg)
    self.lister["model_lwzb_auto_bet_change_msg"] = basefunc.handler(self,self.on_model_lwzb_auto_bet_change_msg)
    self.lister["model_on_lwzb_cancel_bet_response"] = basefunc.handler(self,self.on_model_on_lwzb_cancel_bet_response)

    self.lister["model_vip_upgrade_change_msg"] = basefunc.handler(self,self.on_model_vip_upgrade_change_msg)
    self.lister["AssetChange"] = basefunc.handler(self, self.on_AssetChange)
    self.lister["model_zdlw_dragon_list_change_msg"] = basefunc.handler(self,self.on_model_zdlw_dragon_list_change_msg)
    self.lister["model_on_lwzb_qlcf_kaijiang_msg"] = basefunc.handler(self,self.on_model_on_lwzb_qlcf_kaijiang_msg)
    self.lister["model_lwzb_query_make_dragon_list_msg"] = basefunc.handler(self,self.on_model_lwzb_query_make_dragon_list_msg)

    self.lister["com_guide_step"] = basefunc.handler(self,self.on_com_guide_step)
    self.lister["LwzbGuide_my_money_change_msg"] = basefunc.handler(self,self.on_LwzbGuide_my_money_change_msg)
    self.lister["lwzb_gaming_anim_msg"] = basefunc.handler(self,self.on_lwzb_gaming_anim_msg)
    self.lister["lwzb_out_gaming_anim_init_msg"] = basefunc.handler(self,self.on_lwzb_out_gaming_anim_init_msg)
    --self.lister["EnterForeGround"] = basefunc.handler(self,self.on_EnterForeGround)
    self.lister["EnterBackGround"] = basefunc.handler(self,self.on_EnterBackGround)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	self:DeletBetTimer()
	self:DeletGameTimer()
	self:StopTimerToSettle()
	if self.lwzb_guide_pre then
		self.lwzb_guide_pre:MyExit()
	end
	if self.game_btn_pre then
		self.game_btn_pre:MyExit()
	end
	self:StopAutoBetOpenTimer()
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:OnDestroy()
	self:MyExit()
end

function C:MyClose()
	self:MyExit()
end

function C:ctor()
	local parent = GameObject.Find("Canvas/GUIRoot").transform
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
	local btn_map = {}
	btn_map["left_top"] = {self.hall_btn_top}
	self.game_btn_pre = GameButtonPanel.Create(btn_map, "lwzb_game", self.transform)

	self.cur_index = 1

	self.back_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:OnBackClick()
	end)
	self.help_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:OnHelpClick()
	end)
	self.record_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:OnRecordClick()
	end)
	self.lwzd_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:OnLWZDClick()
	end)
	self.add_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:OnChangeGunClick(1)
	end)
	self.dec_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:OnChangeGunClick(-1)
	end)
	self.gun1_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:OnChangeGunGunClick(1)
		if LWZBManager.GetLwzbGuideOnOff() and not self.onoff1 then
			self.onoff1 = true
			Event.Brocast("lwzb_guide_check")
		end
	end)
	self.gun2_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:OnChangeGunGunClick(2)
	end)
	self.gun3_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:OnChangeGunGunClick(3)
	end)
	self.gun4_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:OnChangeGunGunClick(4)
	end)
	self.cant1_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:OnCantChoseClick(1)
	end)
	self.cant2_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:OnCantChoseClick(2)
	end)
	self.cant3_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:OnCantChoseClick(3)
	end)
	self.cant4_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:OnCantChoseClick(4)
	end)
	EventTriggerListener.Get(self.lxcn_btn.gameObject).onDown = basefunc.handler(self, self.on_lxcn_Down)
    EventTriggerListener.Get(self.lxcn_btn.gameObject).onUp = basefunc.handler(self, self.on_lxcn_Up)
	self.lxcn_hui_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		if LWZBManager.CheckMoneyIsEnoughOnSettle() then
			self:OnContinueBetHuiClick()
		else
			M.CreateHint()
		end
	end)
	self.auto_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		M.CancelAutoBet()
		--[[if LWZBManager.CheckMoneyIsEnoughOnSettle() then
			self:OnAutoClick()
		else
			HintPanel.Create(2,"您的金币已低于本场次入场下限,是否前往购买?",function ()
	            PayPanel.Create(GOODS_TYPE.jing_bi, "normal")
	        end,function ()
	            --LWZBLogic.quit_game()
	        end)
		end--]]
	end)
	self.cancel_bet_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:OnCancelBetClick()
	end)
	self.look_px_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:OnLookPXClick()
	end)
	self.paypanel_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:OnPayPanelClick()
	end)


	--龙王
	self.lw_pre = LWZBLWPrefab.Create(self.lw_node.transform,self)
	-- 下注区
	self.ss_pre_list = {}
	for i = 1, 4 do
		self.ss_pre_list[#self.ss_pre_list + 1] = LWZBSSPrefab.Create(self["tg_node" .. i], i,self)
	end
	-- 左右头像 	
	self.lrhead_list = {}
	for i = 1, 6 do
		if i == 6 then
			self.lrhead_list[#self.lrhead_list + 1] = LWZBHeadPrefab.Create(self["head_node_xyx"], i)
		else
			self.lrhead_list[#self.lrhead_list + 1] = LWZBHeadPrefab.Create(self["head_node"..i], i)
		end
	end

	self.gun_pre = LWZBGunPrefab.Create(self.gun_node,1)
	if LWZBManager.GetCurGame_id() == 1 then
		self.lwzd_btn.gameObject:SetActive(false)
	else
		self.lwzd_btn.gameObject:SetActive(true)
		self.qlcf_pre = LWZBCSDJEnterPrefab.Create(self.qlcf_node)
	end
	
	self.pmd_cont = CommonPMDManager.Create(self,self.CreatePMD,{actvity_mode=1,start_pos = 1800,end_pos = -1800})
	self:MyRefresh()
	LWZBLoadingPanel.Create()
	self:RefreshGunGun()
	self:RefreshMyGun()
	if LWZBManager.GetLwzbGuideOnOff() then
		self.lwzb_guide_pre = LWZBGuidePanel.Create(self)
		M.GetGuideData("bet")
	end
end

function C:MyRefresh()
	self:RefreshMyBaseInfo()
	self:RefreshGunText()
end

--正常处理
function C:RefreshModelStatus()
	local all_info = M.GetAllInfo()
	dump(all_info.status_data.time_out,"<color=red>88888888888888888888888</color>")
	self:QLCFEterRefreshUI()--刷新麒麟赐福入口奖池数值
	
	self:RefreshLRHead()--刷新屏幕左右富豪和幸运星的头像
	self:SetAutoBetBtn()--刷新自动充能是否开启的
	self:SetButtonActive()
	self:RefreshMakeDragonBtn()--刷新争夺龙王的入口按钮
	self:RefreshLWInfo()--刷新龙王的信息
	self:IsShouldShowMyCN()--非比牌阶段不显示我的充能
	self:HideLWAndMoveUpSSAtBetting()--充能阶段隐藏龙王,四个神兽位置上移
	dump(M.GetCurStatus(),"<color=green>+++++++++++++++++++++++++</color>")
	if M.GetCurStatus() == M.Model_Status.bet then
		self:RefreshRealyMoney()--刷新我身上的金币(真实金币)
		self:ForceExitQLCFTJorSettlePanle()--强制关闭结算界面或麒麟赐福头奖界面
		self:RefreshAllBet()--刷新四个神兽身上显示的总充能数
		self:SetActiveInit()--将龙王和四个神兽身上的牌,牌型,胜负设为false
		self:RefreshLuckyStar(true)--依据数据刷新幸运星的下注位置以作显示
		self:RefreshHistorySF(true)--显示历史6局胜负记录(小圆点)
		self:IsShouldShowHint(true)--开启四个神兽的"点击充能","总充能","我的充能"的提示

		self:CerateBetTimer("Normal")--充能阶段倒计时显示
		self:RefreshMyBet()--刷新我在四个神兽身上显示的充能数
		self:CheckIsAutoBet()--检查是否开启自动下注,如果是,就请求自动下注数据(服务器帮我下注)
	elseif M.GetCurStatus() == M.Model_Status.game then
		--LWZBCountDownPrefab_game.Create(self.countdown_node.transform,all_info.status_data.time_out,"ReConnencte")--充能阶段倒计时显示
		ExtendSoundManager.PlaySound(audio_config.lwzb.bgm_lwzb_bipaibg.audio_name)
		self:ForceExitPointer()--强制关闭精准下注的指针
		if LWZBManager.GetLwzbGuideOnOff() then
			--self:TimerToSettle(true)
		end
		self:RefreshZhu()
		self:InitSSBtnStatus()--重置神兽充能按钮状态(因为自动下注或连续下注后不能下注,这里要重置到可以下注(只考虑这个条件的情况下))
		self:ForceExit_bet_CountDownPre()--强制关闭充能阶段倒计时显示
		self:RefreshLuckyStar(false)--强制关闭幸运星的下注位置显示
		self:RefreshHistorySF(false)--显示历史6局胜负记录(小圆点)
		self:IsShouldShowHint(false)--关闭四个神兽的"点击充能","总充能","我的充能"的提示
		self:RefreshLwAndSSRate()--刷新龙王和四个神兽的倍率
		self:RefreshPai()--刷新龙王和四个神兽的牌
		self:RefreshPaiType()--刷新龙王和四个神兽的牌型
		self:RefreshIsWin()--刷新四个神兽胜败的图标
		--Event.Brocast("model_lwzb_begin_bp")--开始播放比牌阶段的动画
	elseif M.GetCurStatus() == M.Model_Status.settle then
		self:RefreshRealyMoney()--刷新我身上的金币(真实金币)
		local fun
		--判断是否是麒麟赐福
		if M.CheckIsQLCF() then
			fun = function ()
				--播放麒麟赐福动画
				LWZBCSKJPanel.Create()
			end
		else
			fun = nil
		end
		LWZBSettlePanel.Create(fun)--创建结算界面
	end
end

--断线重连处理
function C:RefreshModelStatus_ReConnecte()
	local all_info = M.GetAllInfo()
	self:QLCFEterRefreshUI()--刷新麒麟赐福入口奖池数值
	
	self:RefreshLRHead()--刷新屏幕左右富豪和幸运星的头像
	self:SetAutoBetBtn()--刷新自动充能是否开启的
	self:SetButtonActive()
	self:RefreshMakeDragonBtn()--刷新争夺龙王的入口按钮
	self:RefreshLWInfo()--刷新龙王的信息
	self:IsShouldShowMyCN()--非比牌阶段不显示我的充能
	self:HideLWAndMoveUpSSAtBetting()--充能阶段隐藏龙王,四个神兽位置上移
	if M.GetCurStatus() == M.Model_Status.bet then
		self:RefreshRealyMoney()--刷新我身上的金币(真实金币)
		self:ForceExitQLCFTJorSettlePanle()--强制关闭结算界面或麒麟赐福头奖界面
		self:RefreshAllBet_ReConnecte()--刷新四个神兽身上显示的总充能数
		self:SetActiveInit()--将龙王和四个神兽身上的牌,牌型,胜负设为false
		self:RefreshLuckyStar_ReConnecte(true)--依据数据刷新幸运星的下注位置以作显示
		self:RefreshHistorySF(true)--显示历史6局胜负记录(小圆点)
		self:IsShouldShowHint(true)--开启四个神兽的"点击充能","总充能","我的充能"的提示
		self:CerateBetTimer("ReConnencte")--充能阶段倒计时显示

		self:RefreshMyBet_ReConnecte()--刷新我在四个神兽身上显示的充能数
		self:CheckIsAutoBet()--检查是否开启自动下注,如果是,就请求自动下注数据(服务器帮我下注)(切后台时,model会请求取消自动下注,以免玩家重复切回前台而引起重复请求自动下注)
	elseif M.GetCurStatus() == M.Model_Status.game then
		self:RefreshMyBet_ReConnecte()--刷新我在四个神兽身上显示的充能数
		self:ForceExitPointer()--强制关闭精准下注的指针
		
		self:CerateGameTimer("ReConnencte")--充能阶段倒计时显示
		self:InitSSBtnStatus()--重置神兽充能按钮状态(因为自动下注或连续下注后不能下注,这里要重置到可以下注(只考虑这个条件的情况下))
		self:ForceExit_bet_CountDownPre()--强制关闭充能阶段倒计时显示
		self:RefreshLuckyStar_ReConnecte(false)--强制关闭幸运星的下注位置显示
		self:RefreshHistorySF(false)--显示历史6局胜负记录(小圆点)
		self:IsShouldShowHint(false)--关闭四个神兽的"点击充能","总充能","我的充能"的提示
		self:RefreshLwAndSSRate()--刷新龙王和四个神兽的倍率
		self:RefreshPai()--刷新龙王和四个神兽的牌
		self:RefreshPaiType()--刷新龙王和四个神兽的牌型
		self:RefreshIsWin()--刷新四个神兽胜败的图标
		--Event.Brocast("model_lwzb_show_all_bp")--直接显示比牌阶段所有信息(重连不做动画)
	elseif M.GetCurStatus() == M.Model_Status.settle then
		self:RefreshRealyMoney()--刷新我身上的金币(真实金币)
		self:ForceExit_game_CountDownPre()--强制关闭比牌阶段倒计时显示
		local fun
		local all_info = M.GetAllInfo()
		local Phase_time_config = M.GetPhase_timeConfig()
		--判断是否是麒麟赐福
		if M.CheckIsQLCF() then
			fun = function (time)
				--播放麒麟赐福动画
				LWZBCSKJPanel.Create(time)
			end
			dump(all_info.status_data.time_out,"<color=red>88888888888888888888888</color>")
			local remain_time = all_info.status_data.time_out - (Phase_time_config["settle_qlcf"].time - Phase_time_config["settle"].time)
			dump(remain_time,"<color=red>9999999999999999999</color>")
			if remain_time > 0 then--麒麟赐福的15秒完整,结算的5秒不完整
				LWZBSettlePanel.Create(fun,remain_time)--创建结算界面
			else--麒麟赐福的15秒也不完整
				LWZBCSDJTJPanel.Create()--麒麟赐福头奖界面
			end
		else
			fun = nil
			LWZBSettlePanel.Create(fun)--创建结算界面
		end
	end
end

--刷新富豪榜和幸运星的头像信息
function C:RefreshLRHead()
	local all_info = M.GetAllInfo()
	local fh = all_info.fuhao_rank
	local xyx = all_info.lucky_star
	local index = 0
	if not table_is_null(fh) then
		for i=1,#fh do
			self.lrhead_list[i]:RefreshData(fh[i],"fh")
			index = i
		end
	end
	if not table_is_null(xyx) then
		self.lrhead_list[#self.lrhead_list]:RefreshData(xyx,"xyx")
	end
end

function C:RefreshGunText()
	local list = M.GetCurYZConfig()
	dump(self.cur_index)
	self.gun_rate_txt.text = list[self.cur_index]
end

function C:OnBackClick()
	if LWZBManager.GetLwzbGuideOnOff() then
		
	else
		if M.IsIBetSomeOne() then
			LittleTips.Create("您当局有充能,暂时不能退出")
		elseif self:CheckLWIsI() then
			LWZBSnatchPanel.Create()
			LittleTips.Create("您当前正在龙王争霸，不能退出")
		else
			LWZBLogic.quit_game()
		end
	end
end

function C:OnHelpClick()
	print("OnHelpClick")
	local str = help_info[1]
	for i = 2, #help_info do
		str = str .. "\n" .. help_info[i]
	end
	self.introduce_txt.text = str
	LWZBHelpPanel.Create(self.introduce_txt.text)
end

function C:OnRecordClick()
	LWZBJLPanel.Create()
	print("OnRecordClick")
end

function C:OnPlayerClick()
	print("OnPlayerClick")
end

function C:OnPayPanelClick()
	if M.GetCurStatus() == M.Model_Status.bet then
	  PayPanel.Create(GOODS_TYPE.jing_bi, "normal")
	else
	  LittleTips.Create("当前状态不可充值,请在充能阶段进行充值")
	end
end

function C:OnChangeGunClick(cha)
	self.cur_index = M.GetChangeGunIndex(self.cur_index, cha)
	self:RefreshMyGun()
	self:RefreshGunText()
end

function C:OnChangeGunGunClick(index)
	self.chose1.gameObject:SetActive(index == 1)
	self.chose2.gameObject:SetActive(index == 2)
	self.chose3.gameObject:SetActive(index == 3)
	self.chose4.gameObject:SetActive(index == 4)
	local cur = M.GetCurRateIndex()
	local cha = index - cur
	self.cur_index = M.GetChangeGunIndex(self.cur_index, cha)
	self:RefreshMyGun()
	self:RefreshGunText()
end

function C:OnCantChoseClick(index)
	local tab = M.GetCurYZConfig()
	local need_money = tab[index]
	if need_money <= MainModel.UserInfo.jing_bi then --超过30%
		LittleTips.Create("当前金币不足，不可以使用这个炮台")
	else--钱不够
		LittleTips.Create("当前金币不足，不可以使用这个炮台")
	end
end

function C:OnContinueBetClick()
	if M.GetCurStatus() == M.Model_Status.bet then
		M.ContinueBet()
	else
		LittleTips.Create("等候下一局充能")
	end
end

function C:OnContinueBetHuiClick()
	if M.GetCurStatus() == M.Model_Status.bet then
		LittleTips.Create("已经充能")
	else
		LittleTips.Create("等候下一局充能")
	end
end

--[[function C:OnAutoClick()
	M.SetAutoBet()
end--]]

function C:OnCancelBetClick()
	if M.GetCurStatus() ~= M.Model_Status.bet then
		LittleTips.Create("当前不在充能阶段,不可取消充能")
	else
		local all_info = M.GetAllInfo()
		local my_bet_data = all_info.bet_data.my_bet_data
		for i=1,#my_bet_data do
			if my_bet_data[i] > 0 then
				M.CancelBet()
				return
			end
		end
		LittleTips.Create("您当前还未充能")
	end
end

function C:OnLookPXClick()
	LWZBCardTypePanel.Create()
end

function C:on_lwzb_xz_msg(data)
	dump(data, "<color=red>on_lwzb_xz_msg</color>")
	if data.is_my and M.GetCurStatus() == M.Model_Status.bet then
		self.gun_pre:Shoot(data)
	else
	end
end

function C:on_model_begin_bp(data)
	-- 先展示龙王
	self.lw_pre:PlayBP()
end

function C:on_lwzb_lw_fp_finish_msg()
	-- 展示第一个神兽
	self.ss_pre_list[1]:PlayBP()
end

function C:on_lwzb_ss_fp_finish_msg(data)
	local index = data.index

	local is_win = data.is_win
	--ExtendSoundManager.PlaySound(audio_config.lwzb.bgm_lwzb_shouji.audio_name)
	if is_win == 1 then
		GameComAnimTool.PlayShowAndHideAndCall(self.transform, "LWZB_shouji", self.lw_pre:GetSJPos(), 1)
	elseif is_win == 0 then
		GameComAnimTool.PlayShowAndHideAndCall(self.transform, "LWZB_shouji", self.ss_pre_list[index]:GetSJPos(), 1)
	end
	local seq = DoTweenSequence.Create()
	seq:AppendInterval(1)
	seq:OnKill(function ()
		if index < 4 then
			self.ss_pre_list[index + 1]:PlayBP()
		else
			-- 播放分发金币的动画
			Event.Brocast("ss_is_win_do_fly_jb_msg")
			if LWZBManager.GetLwzbGuideOnOff() then
				M.GetGuideData("settle")
			end
		end
	end)
end

function C:OnLWZDClick()
	LWZBSnatchPanel.Create()
end

function C:RefreshMakeDragonBtn()
	if M.CheckIisInLWZDList() then
		self.zi_img.sprite = GetTexture("lwzb_imgf_tczd")
	else
		self.zi_img.sprite = GetTexture("lwzb_imgf_lwzd")
	end
end

function C:RefreshMyBaseInfo()
	VIPManager.set_vip_text(self.my_vip_txt)
	URLImageManager.UpdateHeadImage(MainModel.UserInfo.head_image, self.my_head_img)
	--self.my_frame_img	 
	self.my_name_txt.text = MainModel.UserInfo.name
	self.my_money_txt.text = StringHelper.ToCash(MainModel.UserInfo.jing_bi)
end

--刷新为真正持有金币数
function C:RefreshRealyMoney()
	if LWZBManager.GetLwzbGuideOnOff() then
		if self.cost then
			self.my_money_txt.text = StringHelper.ToCash(MainModel.UserInfo.jing_bi - self.cost)
		else
			self.my_money_txt.text = StringHelper.ToCash(MainModel.UserInfo.jing_bi)
		end
	else
		self.my_money_txt.text = StringHelper.ToCash(MainModel.UserInfo.jing_bi)
	end
	self:CheckMyBetRate()
end

function C:on_model_lwzb_all_info_msg()
	self.cur_index = M.GetTJIndex()
	self:RefreshGunGun()
	self:RefreshMyGun()
	self:RefreshGunText()
	self:RefreshModelStatus()
	self.lw_pre:MyRefresh()
	for i=1,#self.ss_pre_list do
		self.ss_pre_list[i]:MyRefresh()
	end
end

function C:on_model_lwzb_all_info_reconnecte_msg()
	self.cur_index = M.GetTJIndex()
	self:RefreshGunGun()
	self:RefreshMyGun()
	self:RefreshGunText()
	self:RefreshModelStatus_ReConnecte()
	self.lw_pre:MyRefresh()
	for i=1,#self.ss_pre_list do
		self.ss_pre_list[i]:MyRefresh()
	end
end

function C:on_model_lwzb_status_change_msg()
	self:RefreshModelStatus()
end

--刷新我的下注(无脑播动画就不传tab,要判断我的下注是否增长来决定播不播动画就要传tab,比如{1,1,0,1},1表示有增长的神兽,0表示没有)
function C:RefreshMyBet(tab)
	local all_info = M.GetAllInfo()
	local data = all_info.bet_data.my_bet_data
	for i=1,#self.ss_pre_list do
		self.ss_pre_list[i]:RefreshMyBet(data[i])
		if tab then
			if data[i] > 0 and tab[i] == 1 then
				--充能大于0的神兽才被飞金币
				--LWZBManager.PlayTYJBFly(self.transform, "lwzb_jb_fly_prefab", self.jb.transform.position, self.ss_pre_list[i].transform.position, {type = 1})
			end
		else
			if data[i] > 0 then
				--充能大于0的神兽才被飞金币
				--LWZBManager.PlayTYJBFly(self.transform, "lwzb_jb_fly_prefab", self.jb.transform.position, self.ss_pre_list[i].transform.position, {type = 1})
			end
		end
	end
end

--刷新总下注(无脑播动画就不传tab,要判断总下注是否增长来决定播不播动画就要传tab,比如{1,1,0,1},1表示有增长的神兽,0表示没有)
function C:RefreshAllBet(tab)
	local all_info = M.GetAllInfo()
	local data = all_info.bet_data.total_bet_data
	for i=1,#self.ss_pre_list do
		self.ss_pre_list[i]:RefreshAllBet(data[i])
		if tab then
			if data[i] > 0 and tab[i] == 1 then
				--充能大于0的神兽才被飞金币
				ExtendSoundManager.PlaySound(audio_config.lwzb.bgm_lwzb_yazhu.audio_name)
				LWZBManager.PlayTYJBFly(self.transform, "lwzb_jb_fly_prefab", self.player_img.transform.position, self.ss_pre_list[i].transform.position, {type = 1})
			end
		else
			if data[i] > 0 then
				--充能大于0的神兽才被飞金币
				ExtendSoundManager.PlaySound(audio_config.lwzb.bgm_lwzb_yazhu.audio_name)
				LWZBManager.PlayTYJBFly(self.transform, "lwzb_jb_fly_prefab", self.player_img.transform.position, self.ss_pre_list[i].transform.position, {type = 1})
			end
		end
	end
end

--刷新牌
function C:RefreshPai()
	local all_info = M.GetAllInfo()
	local ss_data = all_info.game_data.monster_pai
	dump(ss_data,"<color>////////////////////////</color>")
	for i=1,#self.ss_pre_list do
		self.ss_pre_list[i]:RefreshPai(ss_data[i].pai_data)
	end
	local lw_data = all_info.game_data.long_wang_pai.pai_data
	self.lw_pre:RefreshPai(lw_data)
end

--刷新牌类型
function C:RefreshPaiType()
	local all_info = M.GetAllInfo()
	local ss_data = all_info.game_data.monster_pai
	for i=1,#self.ss_pre_list do
		self.ss_pre_list[i]:RefreshPaiType(ss_data[i].pai_type)
	end
	local lw_data = all_info.game_data.long_wang_pai.pai_type
	self.lw_pre:RefreshPaiType(lw_data)
end

--刷新比牌胜负
function C:RefreshIsWin()
	local all_info = M.GetAllInfo()
	local ss_data = all_info.game_data.monster_pai
	for i=1,#self.ss_pre_list do
		self.ss_pre_list[i]:RefreshIsWin(ss_data[i].is_win)
	end
end

--刷新幸运星位置(true为依据数据开或关,false为强制关闭)
function C:RefreshLuckyStar(bool)
	if bool then
		local all_info = M.GetAllInfo()
		local xyx_data = all_info.bet_data.lucky_star_bet_pos
		for i=1,#self.ss_pre_list do
			if xyx_data and xyx_data[i] and xyx_data[i] == 1 then
				if not self.ss_pre_list[i]:GetLuckStarStatus() then
					LWZBManager.LuckyStarFlytoSS(self.transform,"lwzb_luckystar_prefab",self.head_node_xyx.transform.position,self.ss_pre_list[i]:GetLuckStarPos(),function ()
						self.ss_pre_list[i]:OnLuckyStar()
					end)
				else
					self.ss_pre_list[i]:OnLuckyStar()
				end
			else
				self.ss_pre_list[i]:OffLuckyStar()
			end
		end
	else
		for i=1,#self.ss_pre_list do
			self.ss_pre_list[i]:OffLuckyStar()
		end
	end
end

--是否显示四个神兽的充能提示
function C:IsShouldShowHint(bool)
	for i=1,#self.ss_pre_list do
		self.ss_pre_list[i]:IsShouldShowHint(bool)
	end
end

--刷新龙王信息
function C:RefreshLWInfo()
	local all_info = M.GetAllInfo()
	local lw_data = all_info.dragon_info
	self.lw_pre:RefreshLWInfo(lw_data)
end

function C:on_model_lwzb_total_bet_tb_msg(tab)
	self:RefreshAllBet(tab)
	self:RefreshLuckyStar(true)--依据数据刷新幸运星的下注位置以作显示
end

function C:on_model_lwzb_bet_response(tab)
	self:RefreshMyBet(tab)
	self:RefreshRealyMoney()
end


function C:on_model_lwzb_auto_bet_response()
	self:SetAutoBetBtn()
	self:SetButtonActive()
end

function C:on_model_lwzb_cancel_auto_bet_response()
	self:SetAutoBetBtn()
	self:SetButtonActive()
end

function C:on_model_lwzb_auto_bet_change_msg()
	self:SetAutoBetBtn()
	self:SetButtonActive()
end

function C:SetAutoBetBtn()
	local all_info = M.GetAllInfo()
	local is_auto_bet = all_info.bet_data.is_auto_bet
	self.gou_node.gameObject:SetActive(is_auto_bet == 1)
end

function C:on_model_lwzb_continue_bet_success_mag()
	self:SetButtonActive()
	self:RefreshMyBet()
	self:RefreshRealyMoney()
	local all_info = M.GetAllInfo()
	for i=1,#self.ss_pre_list do
		if all_info.bet_data.my_bet_data[i] ~= 0 then
			self.gun_pre:ContinueBetShoot({is_my = true, pos=self.ss_pre_list[i].transform.position })
		end
	end
end

function C:CheckIsAutoBet()
	M.QueryAutoBetDataIfBeAuto()
end

function C:on_model_lwzb_auto_bet_data_msg()
	self:RefreshMyBet()
	self:RefreshRealyMoney()
	local all_info = M.GetAllInfo()
	for i=1,#self.ss_pre_list do
		if all_info.bet_data.my_bet_data[i] ~= 0 then
			self.gun_pre:ContinueBetShoot({is_my = true, pos=self.ss_pre_list[i].transform.position})
		end
	end
end

--强制退出充能阶段倒计时
function C:ForceExit_bet_CountDownPre()
	Event.Brocast("lwzb_force_exit_bet_countdown_msg")
end

--将龙王和四个神兽身上的牌,牌型,胜负设为false
function C:SetActiveInit()
	for i=1,#self.ss_pre_list do
		self.ss_pre_list[i]:SetActiveInit()
	end
	self.lw_pre:SetActiveInit()
end

--历史6局胜负记录(小圆点)
function C:RefreshHistorySF(bool)
	for i=1,#self.ss_pre_list do
		self.ss_pre_list[i]:RefreshHistorySF(bool)
	end
end

--播放"龙王(如果本轮有胜场)"和"胜利的神兽"身上的金币往右上角人头飞的动画
function C:on_lwzb_jb_fly_to_player_btn_msg(begin_Pos,index)
	LWZBManager.PlayTYJBFly(self.transform, "lwzb_jb_fly_prefab", begin_Pos, self.player_img.transform.position, {type = 2,num = 1})
	if M.CheckIIsBetSS(index) then
		LWZBManager.PlayTYJBFly(self.transform, "lwzb_jb_fly_prefab", begin_Pos, self.my_head_img.transform.position, {type = 2,num = 1})
	end
end


function C:on_model_bet_type_has_change_msg()
	for i=1,#self.ss_pre_list do
		self.ss_pre_list[i]:SetBtnStatus()
	end
end

function C:InitSSBtnStatus()
	for i=1,#self.ss_pre_list do
		self.ss_pre_list[i]:InitSSBtnStatus()
	end
end

--取消下注
function C:on_model_on_lwzb_cancel_bet_response()
	self:RefreshRealyMoney()
	self:RefreshMyBet()
end

--商城购物或购买活动礼包,vip等级提升需要刷新vip显示
function C:on_model_vip_upgrade_change_msg()
	VIPManager.set_vip_text(self.my_vip_txt)
end

--商城购物或购买活动礼包,金币数量改变需要刷新金币显示
function C:on_AssetChange(data)
	if data.change_type ~= "lwzb_game_settle" then
		self:RefreshRealyMoney()
	end
	if M.CheckIisLW() then
		Event.Brocast("lwzb_refresh_lw_jb_msg")
	end
end

--刷新幸运星位置(true为依据数据开或关,false为强制关闭)
function C:RefreshLuckyStar_ReConnecte(bool)
	if bool then
		local all_info = M.GetAllInfo()
		local xyx_data = all_info.bet_data.lucky_star_bet_pos
		for i=1,#self.ss_pre_list do
			if xyx_data[i] == 1 then
				self.ss_pre_list[i]:OnLuckyStar()
			else
				self.ss_pre_list[i]:OffLuckyStar()
			end
		end
	else
		for i=1,#self.ss_pre_list do
			self.ss_pre_list[i]:OffLuckyStar()
		end
	end
end

--刷新我的下注
function C:RefreshMyBet_ReConnecte()
	local all_info = M.GetAllInfo()
	local data = all_info.bet_data.my_bet_data
	for i=1,#self.ss_pre_list do
		self.ss_pre_list[i]:RefreshMyBet(data[i])
	end
end

--直接展示比牌阶段所有信息(不做动画)
function C:on_model_show_all_bp()
	self.lw_pre:BP_ReConnencte()
	for i=1,#self.ss_pre_list do
		self.ss_pre_list[i]:BP_ReConnencte()
	end
end

--强制退出比牌阶段倒计时
function C:ForceExit_game_CountDownPre()
	Event.Brocast("lwzb_force_exit_game_countdown_msg")
end

--刷新四个神兽身上显示的总充能数
function C:RefreshAllBet_ReConnecte()
	local all_info = M.GetAllInfo()
	local data = all_info.bet_data.total_bet_data
	for i=1,#self.ss_pre_list do
		self.ss_pre_list[i]:RefreshAllBet(data[i])
	end
end

function C:ForceExitPointer()
	Event.Brocast("lwzb_force_exit_pointer_msg")
end

--刷新麒麟赐福入口和麒麟赐福界面
function C:QLCFEterRefreshUI()
	Event.Brocast("lwzb_refresh_qlcf_enter_and_panel_msg")
end

function C:on_model_zdlw_dragon_list_change_msg()
	self:RefreshLWInfo()
	self:RefreshMakeDragonBtn()
end

function C:ForceExitQLCFTJorSettlePanle()
	Event.Brocast("lwzb_force_exit_qlcf_or_settel_msg")
end


function C:on_model_on_lwzb_qlcf_kaijiang_msg()
	local all_info = M.GetAllInfo()
	local data = all_info.settle_data.qlcf_big_award
	dump(data,"<color=red>+++++++++++AddPMDData++++++++++++++++</color>")
	self.pmd_cont:AddPMDData(data)
	self:QLCFEterRefreshUI()
end

function C:on_model_lwzb_query_make_dragon_list_msg()
	self:RefreshMakeDragonBtn()
end

function C:IsShouldShowMyCN()
	for i=1,#self.ss_pre_list do
		self.ss_pre_list[i]:IsShouldShowMyCN()
	end
end

function C:RefreshLwAndSSRate()
	local all_info = M.GetAllInfo()
	local ss_data = all_info.game_data.monster_pai
	dump(ss_data,"<color>////////////////////////</color>")
	for i=1,#self.ss_pre_list do
		self.ss_pre_list[i]:RefreshRate(ss_data[i].rate)
	end
	local lw_data = all_info.game_data.long_wang_pai.pai_rate
	self.lw_pre:RefreshRate(lw_data)
end

function C:CreatePMD(data)
	dump(data,"<color=red>+++++++++++CreatePMD++++++++++++++++</color>")
	if data then
		local obj = GameObject.Instantiate(self.pmd_item, self.pmd_node.transform)
		local text = obj.transform:Find("@t1_txt"):GetComponent("Text")
		text.text = "恭喜玩家<color=#ff0000>"..data.player_info.player_name.."</color>在财神大奖中获得<color=#fcf137>"..data.award_value.."</color>金币"
		obj.gameObject:SetActive(true)
		return obj
	end
end

function C:AutoBetOpenTimer(b)
    self:StopAutoBetOpenTimer()
    if b then
        self.auto_bet_timer = Timer.New(function ()
        	M.SetAutoBet()
            self.auto_bet = true
        end,1.5,1)
        self.auto_bet_timer:Start()
    end
end

function C:StopAutoBetOpenTimer()
    if self.auto_bet_timer then
        self.auto_bet_timer:Stop()
        self.auto_bet_timer = nil
    end
end

function C:on_lxcn_Down()
	ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
	if LWZBManager.CheckMoneyIsEnoughOnSettle() then
		self:AutoBetOpenTimer(true)
	else
		M.CreateHint()
	end
end

function C:on_lxcn_Up()
	self:StopAutoBetOpenTimer()
	if self.auto_bet then
		--自动下注开启
		self.auto_bet = false
	else
		if M.GetCurBetType() then
			if M.GetCurStatus() == M.Model_Status.bet then
				LittleTips.Create("已经充能")
			else
				LittleTips.Create("等候下一局充能")
			end
		else
			self:OnContinueBetClick()
		end
	end
end

function C:SetButtonActive()
	local all_info = M.GetAllInfo()
	local is_auto = all_info.bet_data.is_auto_bet
	self.lxcn_btn.gameObject:SetActive(is_auto ~= 1)
	self.auto_btn.gameObject:SetActive(is_auto == 1)
end

function C:RefreshGunGun()
	local tab = M.GetCurYZConfig()
	for i=1,#tab do
		self["gun"..i.."_txt"].text = StringHelper.ToCash(tab[i])
		if M.GetTJIndex() == i then
			self["chose"..i].gameObject:SetActive(true)
		else
			self["chose"..i].gameObject:SetActive(false)
		end
	end
end

--寻找最适合自己的下注倍率,不适合的要置灰
function C:CheckMyBetRate()
	local index = M.FindMyCanBiggestBet()
	if M.GetCurRateIndex() > index then
		self:OnChangeGunGunClick(index)
	else
	end
	self:RefreshGunGunImage()
end

--不适合的档位置灰
function C:RefreshGunGunImage()
	local index = M.FindMyCanBiggestBet()
	for i=1,4 do
		if i <= index then
			self["gun"..i.."_btn"].gameObject:SetActive(true)
			self["bg"..i.."_img"].material = GetMaterial("")
			self["cant"..i.."_btn"].gameObject:SetActive(false)
		else
			self["gun"..i.."_btn"].gameObject:SetActive(false)
			self["bg"..i.."_img"].material = GetMaterial("imageGrey")
			self["cant"..i.."_btn"].gameObject:SetActive(true)
		end
	end
end

function C:RefreshMyGun()
	self.gun_pre:MyExit()
	local index = M.GetCurRateIndex()
	self.gun_pre = LWZBGunPrefab.Create(self.gun_node,index)
end

function C:TimerToSettle(b)
	self:StopTimerToSettle()
	if b then
		local all_info = M.GetAllInfo()
		self.ToSettle_timer = Timer.New(function ()
			M.GetGuideData("settle")
			--Event.Brocast("lwzb_guide_check")
		end,all_info.status_data.time_out,1,false)
		self.ToSettle_timer:Start()
	end
end

function C:StopTimerToSettle()
	if self.ToSettle_timer then
		self.ToSettle_timer:Stop()
		self.ToSettle_timer = nil
	end
end

function C:on_com_guide_step(data)
	if data and data.key == "skip" then
		if LWZBManager.GetLwzbGuideOnOff() then
			GameManager.GotoSceneName("game_LWZBHall")	
			Network.SendRequest("set_xsyd_status", {status = 1, xsyd_type="xsyd_lwzb"},function (data)
				dump(data,"<color=yellow>+++++++++++++++++</color>")
				if data and data.result == 0 then
					MainModel.UserInfo.xsyd_status = 1
				end
			end)
		end
	end
end

function C:on_LwzbGuide_my_money_change_msg()
	self.cost = 100
	self:RefreshRealyMoney()
end

--检查我自己是不是龙王
function C:CheckLWIsI()
	local dragon_list = M.GetDragonList()
	if dragon_list and dragon_list[1] and dragon_list[1].player_info and dragon_list[1].player_info.player_id and dragon_list[1].player_info.player_id == MainModel.UserInfo.user_id then
		return true
	else
		return false
	end
end

--充能阶段隐藏龙王,四个神兽位置布局改变
function C:HideLWAndMoveUpSSAtBetting()
	if M.GetCurStatus() == M.Model_Status.bet then
		self.lw_node.gameObject:SetActive(false)
		--self.pool.transform.localPosition = Vector3.New(0,300,0)
		--local pos_tab = {Vector3.New(400,400,0),Vector3.New(600,400,0),Vector3.New(-600,20,0),Vector3.New(-370,20,0)}
		--[[for i=1,#self.ss_pre_list do
			self.ss_pre_list[i].transform.localPosition = pos_tab[i]
		end--]]
	else
		self.lw_node.gameObject:SetActive(true)
		--self.pool.transform.localPosition = Vector3.New(0,0,0)
		for i=1,#self.ss_pre_list do
			self.ss_pre_list[i].transform.localPosition = Vector3.New(0,0,0)
		end
	end
end

function C:GetLWPos()
	return self.lw_pre.transform.position
end

function C:GetSSPos(index)
	return self.ss_pre_list[index].transform.position
end

function C:GetSSWin(index)
	local all_info = M.GetAllInfo()
	local ss_data = all_info.game_data.monster_pai
	return ss_data[index].is_win
end

function C:CountDie(index)
	self.countdie = self.countdie or 0
	self.countdie = self.countdie + 1
	if self.countdie == 4 then
		self.lw_pre:IsEnd()
		self.lw_pre.LWZB_LW_dun.gameObject:SetActive(false)
		self.lw_pre.LWZB_LW_dun_po.gameObject:SetActive(false)
	end
end

function C:on_lwzb_out_gaming_anim_init_msg()
	self:InitCountDie()
end

function C:InitCountDie()
	self.countdie = nil
end

function C:LWIsDie()
	for i=1,#self.ss_pre_list do
		self.ss_pre_list[i]:LWIsDie()
	end
end

function C:LWFaJiang()
	self.lw_pre:LWFaJiang()
end

function C:on_lwzb_gaming_anim_msg()
	local state = M.GetStageStatusOrder()
	if state and state.Status == "Tips" then
		GameComAnimTool.PlayShowAndHideAndCall(self.transform,"LWZBStageTip"..state.Stage,Vector3.zero,1.5,1.5,function ()
			
		end)
		if state.Stage == 1 then
			GameComAnimTool.PlayShowAndHideAndCall(self.transform,"lwzb_qiepin",Vector3.zero,2,1.5,function ()
				
			end)
		end
	end
end

function C:ReCreateLwAndSs()
	--龙王
	dump("<color=yellow><size=15>++++++++++on_model_lwzb_all_info_msg++++++++++</size></color>")
	if self.lw_pre then
		self.lw_pre:MyExit()
	end
	self.lw_pre = LWZBLWPrefab.Create(self.lw_node.transform,self)
	-- 下注区
	for i = 1,#self.ss_pre_list do
		if self.ss_pre_list[i] then
			self.ss_pre_list[i]:MyExit()
		end
	end
	self.ss_pre_list = {}
	for i=1,4 do
		self.ss_pre_list[#self.ss_pre_list + 1] = LWZBSSPrefab.Create(self["tg_node" .. i], i,self)
	end
end

function C:on_EnterBackGround()
	self:ReCreateLwAndSs()
	--[[if self.lw_pre then
		self.lw_pre:MyExit()
	end
	for i = 1,#self.ss_pre_list do
		if self.ss_pre_list[i] then
			self.ss_pre_list[i]:MyExit()
		end
	end--]]
end


function C:RefreshZhu()
	for i=1,#self.ss_pre_list do
		self.ss_pre_list[i]:RefreshZhu()
	end
end


function C:CerateBetTimer(type_)
	self:DeletBetTimer()
	local all_info = M.GetAllInfo()
	self.bet_timer_pre = LWZBCountDownPrefab_bet.Create(self.countdown_node.transform,all_info.status_data.time_out,type_)
end

function C:DeletBetTimer()
	if self.bet_timer_pre then
		self.bet_timer_pre:MyExit()
		self.bet_timer_pre = nil
	end
end

function C:CerateGameTimer(type_)
	self:DeletGameTimer()
	local all_info = M.GetAllInfo()
	self.game_timer_pre = LWZBCountDownPrefab_game.Create(self.countdown_node.transform,all_info.status_data.time_out,type_)
end

function C:DeletGameTimer()
	if self.game_timer_pre then
		self.game_timer_pre:MyExit()
		self.game_timer_pre = nil
	end
end

function C:GetCurMyMoney()
	return self.my_money_txt.text
end