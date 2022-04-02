-- 创建时间:2020-10-26
-- Panel:EliminateCJGamePanel
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

EliminateCJGamePanel = basefunc.class()
local C = EliminateCJGamePanel
C.name = "EliminateCJGamePanel"
local Model = EliminateCJModel
local Status =  EliminateCJEnum.Status
local DT_Table = {}
C.instance = nil
function C.Create()
	if C.instance then
		return C.instance
	else
		C.instance = C.New()
	end
	return C.instance
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
	self.lister = {}
	self.lister["finish_gift_shop"] = basefunc.handler(self,self.on_finish_gift_shop)
	self.lister["eliminate_cj_can_aoto"] = basefunc.handler(self,self.on_eliminate_cj_can_aoto)
	self.lister["eliminate_cj_add_money"] = basefunc.handler(self,self.on_eliminate_cj_add_money)
	self.lister["eliminate_cj_into_free_game"] = basefunc.handler(self,self.on_eliminate_cj_into_free_game)
	self.lister["eliminate_cj_game_over"] = basefunc.handler(self,self.on_eliminate_cj_game_over)
	self.lister["eliminate_cj_go_next_roll"] = basefunc.handler(self,self.on_eliminate_cj_go_next_roll)
	self.lister["wait_for_free_onoff"] = basefunc.handler(self,self.on_wait_for_free_onoff)
	self.lister["model_cjxxl_had_reconnect_data"] = basefunc.handler(self,self.on_model_cjxxl_had_reconnect_data)
    self.lister["stop_auto_lotttery"] = basefunc.handler(self,self.stop_auto_lotttery)

end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyRefresh()

end

function C:MyExit()
	if self.Auto_Delta_Timer then
		self.Auto_Delta_Timer:Stop()
	end
	if self.game_btn_pre then
		self.game_btn_pre:MyExit()
	end
	for i = 1,#DT_Table do
		if DT_Table[i] then
			DT_Table[i]:Kill()
		end
	end
	DT_Table = {}
	self.clearpanel:MyExit()
	self:RemoveListener()
end

function C:ctor()
	DT_Table = {}
	local parent = GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	self.now_bet_index = self:GetUserBet()
	self:RefreshBetText()
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	local btn_map = {}
	btn_map["left_top"] = {self.left_top_node}
	btn_map["left_down"] = {self.left_down_node}
	self.game_btn_pre = GameButtonPanel.Create(btn_map, "xxlcj_game")
	self.clearpanel = EliminateCJClearPanel.Create()
	self.curr_win = 0
	self.button_down_count = 0
	self.start_btn_img = self.start_btn.gameObject.transform:GetComponent("Image")
	ExtendSoundManager.PlaySceneBGM(audio_config.cjxxl.bgm_cjxxl_beijing.audio_name)
end

function C:InitUI()
	self.help_btn.onClick:AddListener(function() EliminateCJHelpPanel.Create()  end)
	self.back_btn.onClick:AddListener(
		function()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
			local callback = function()
				Network.SendRequest("lxxxl_quit_game")
			end
			local a,b = GameButtonManager.RunFun({gotoui="cpl_ljyjcfk",callback = callback}, "CheckMiniGame")
			if a and b then
				return
			end
			callback()
		end
	)
	self:RefreshGold()
	URLImageManager.UpdateHeadImage(MainModel.UserInfo.head_image, self.head_img)
	self.playername_txt.text = MainModel.UserInfo.name
	local items_data = EliminateCJItemManager.Init(self.startpos,Model.Str2Table("a321ba654ba987b"))
	self.anim_manager = EliminateCJAnimManager.Create(items_data)
	EventTriggerListener.Get(self.start_btn.gameObject).onDown = basefunc.handler(self, self.StartButtonDown)
	EventTriggerListener.Get(self.start_btn.gameObject).onUp = basefunc.handler(self, self.StartButtonUp)
	EventTriggerListener.Get(self.yxcard_btn.gameObject).onUp = basefunc.handler(self, self.OnClickYXCard)
	self.yxcard_img = self.yxcard_btn.transform:GetComponent("Image")
	self:InitBetNode()
	self:RefreshYXCard(0)
end

function C:InitBetNode()
	self.up_btn.onClick:AddListener(
		function()
			ExtendSoundManager.PlaySound(audio_config.cjxxl.bgm_cjxxl_jiajianzhu.audio_name)
			self:BetUp()
		end
	)
	self.down_btn.onClick:AddListener(
		function()
			ExtendSoundManager.PlaySound(audio_config.cjxxl.bgm_cjxxl_jiajianzhu.audio_name)
			self:BetDown()
		end
	)	
end

function C:BetUp()
	if Model.Status == Status.over and Model.IsAuto == false then
		self.now_bet_index = self.now_bet_index + 1
		local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key="cjxxl_bet_".. self.now_bet_index,vip_hint_type = 2, cw_btn_desc = "确定"}, "CheckCondition")
		if a and not b then
			self.now_bet_index = self.now_bet_index - 1
			return
		end
		self:ReSetBetIndex()
		local bet = Model.xiaoxiaole_defen_cfg.yazhu[self.now_bet_index].jb
		if MainModel.UserInfo.jing_bi < bet then
			PayPanel.Create(GOODS_TYPE.jing_bi)
			self.now_bet_index = self.now_bet_index - 1
			return
		end
		self:RefreshBetText()
	end
end

function C:BetDown()
	if Model.Status == Status.over and Model.IsAuto == false then
		self.now_bet_index = self.now_bet_index - 1
		self:ReSetBetIndex()
		self:RefreshBetText()
	end
end

function C:on_model_cjxxl_had_reconnect_data(data)
	self:ReConnectToClear(data)
end

--断线重连直接走结算
function C:ReConnectToClear(data)
	self.luck_txt.text = data.all_money
	local rate = data.all_rate
	if rate >= 200 and rate <= 600 then
		ExtendSoundManager.PauseSceneBGM()
		Event.Brocast("eliminate_cj_show_clearpanel",{1,data.all_money})
	elseif rate > 600 then
		ExtendSoundManager.PauseSceneBGM()
		Event.Brocast("eliminate_cj_show_clearpanel",{2,data.all_money})
	end
	EliminateCJItemManager.ForceToRefreshImg(Model.Str2Table(data.map_string[#data.map_string]))
end

function C:RefreshBetText(bet_index)
	self.now_bet_index = bet_index or self.now_bet_index
	self:ReSetBetIndex()
	local bet = Model.xiaoxiaole_defen_cfg.yazhu[self.now_bet_index].jb
	Model.SetBet(bet)
	self.bet_txt.text = bet
end

function C:RefreshGold()
	self.now_gold_txt.text = StringHelper.ToCash(MainModel.UserInfo.jing_bi)
	self.vip_txt.text = "VIP"..VIPManager.get_vip_level()
end

function C:on_wait_for_free_onoff(data)
	self.wait_for_free.gameObject:SetActive(data == 1)
end

function C:on_eliminate_cj_go_next_roll()
	if Model.Status == Status.in_free then
		self:ButtonStatusSet(2)
	end
	self.anim_manager.LotteryScrollAnim()
end

function C:ReSetBetIndex()
	if self.now_bet_index > #Model.xiaoxiaole_defen_cfg.yazhu then
		self.now_bet_index = 1
	elseif self.now_bet_index < 1 then
		self.now_bet_index = #Model.xiaoxiaole_defen_cfg.yazhu
	end
	local Is_Max = self.now_bet_index == #Model.xiaoxiaole_defen_cfg.yazhu
	local Is_Min = self.now_bet_index == 1
	self.down_btn.gameObject:SetActive(not Is_Min)
	self.down_mask.gameObject:SetActive(Is_Min)
	self.up_btn.gameObject:SetActive(not Is_Max)
	self.up_mask.gameObject:SetActive(Is_Max)
end

function C:ReSetStatus()
	if Model.IsAuto == false then
		self:ButtonStatusSet(1)
	else
		self:ButtonStatusSet(3)
	end
	dump(self.curr_win,"<color=red>当前赢金++++++++++++++++++++++++++</color>")
	if self.curr_win == 0 then
		self.luck_txt.text = 0
	end
	self.curr_win = 0
end

function C:on_eliminate_cj_game_over()
	print("<color=red>一轮游戏结束</color>")
	self:ReSetStatus()
	self:GoClear()
	self:RefreshGold()
	local open, yxcard, game_level  = GameButtonManager.RunFun({gotoui = "act_060_yxcard",card_type = Model.yxcard_type}, "GetCurGameCard")
	if open then
		if self.primiBet then
			Model.SetBet(self.primiBet)
			self:RefreshMyYazhu(self.primiBet)
			self.primiBet = nil
		end
	end
end	
--去结算
function C:GoClear()
	local rate = Model.GetCurrRate()
	local win_money = Model.GetCurrWin()
	if rate then
		if rate >= 200 and rate <= 600 then
			ExtendSoundManager.PauseSceneBGM()
			Event.Brocast("eliminate_cj_show_clearpanel",{1,win_money})
		elseif rate > 600 then
			ExtendSoundManager.PauseSceneBGM()
			Event.Brocast("eliminate_cj_show_clearpanel",{2,win_money})
		else
			ExtendSoundManager.PlaySceneBGM(audio_config.cjxxl.bgm_cjxxl_beijing.audio_name)
			if Model.IsAuto then
				if self.Auto_Delta_Timer then
					self.Auto_Delta_Timer:Stop()
				end
				self.Auto_Delta_Timer = Timer.New(
					function()
						self:GoLottery()
					end,0.5,1
				)
				self.Auto_Delta_Timer:Start()
			end
		end
	end
end

function C:on_eliminate_cj_into_free_game()
	self:ButtonStatusSet(2)
end

function C:on_eliminate_cj_add_money(money)
	self:ToAddMoney(money)
end

function C:ToAddMoney(money)
	local start = 0
    local DT = DG.Tweening.DOTween.To(
        DG.Tweening.Core.DOGetter_float(
            function(value)
                return start
            end
        ),
        DG.Tweening.Core.DOSetter_float(
			function(value)
				if IsEquals(self.gameObject) then
					self.luck_txt.text = self.curr_win + math.floor(value)
				end
            end
        ),
        money,
        0.4
    ):OnComplete(
		function()
			if IsEquals(self.gameObject) then
				ExtendSoundManager.PlaySound(audio_config.cjxxl.bgm_cjxxl_ying.audio_name)
				self.curr_win = self.curr_win + money
			end
        end 
	)
	DT_Table[#DT_Table + 1] = DT
end

function C:StartButtonDown()
	if Model.IsAuto == false and Model.Status == Status.over then
		self:ButtonStatusSet(4)
	end
	if self.Button_Down_Timer then
		self.Button_Down_Timer:Stop()
	end
	self.Button_Down_Timer = nil
	self.button_down_count = 0
	self.Button_Down_Timer = Timer.New(function()
		self.button_down_count = self.button_down_count + 0.1
		if self.button_down_count > 1 then
			self:ButtonStatusSet(3)
		end
	end,0.1,-1)
	self.Button_Down_Timer:Start()
end

function C:StartButtonUp()
	if self.Button_Down_Timer then
		self.Button_Down_Timer:Stop()
	end
	self.Button_Down_Timer = nil
	--非自动模式下，只有在游戏结束的时候才播放音效，自动模式播放音效
	if (Model.IsAuto == false and Model.Status == Status.over) or Model.IsAuto == true then
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	end
	if self.button_down_count > 1 then
		print("<color=red>自动开始</color>")
		if Model.IsAuto == false then
			self:ButtonStatusSet(3)
			Model.IsAuto = true
			self.start_btn_img.sprite = GetTexture("cjxxl_btn_ks2")
			self:GoLottery()
		end
	else
		if Model.Status ~= Status.in_free then 
			Model.IsAuto = false
			self:ButtonStatusSet(1)
			self:GoLottery()
		end
	end
end

function C:GoLottery(_card_type)
	if 	EliminateCJModel.Status == Status.over and EliminateCJModel.AllInfoRight then
		self:RefreshGold()
		EliminateCJItemManager.StopShow()
		if Model.GetBet() <= MainModel.UserInfo.jing_bi then
			EliminateCJModel.Status = Status.rolling
			self.now_gold_txt.text = StringHelper.ToCash(MainModel.UserInfo.jing_bi - Model.GetBet())
			self.luck_txt.text = " "
			if not _card_type then
				Network.SendRequest("lxxxl_kaijiang",{bet_money = Model.GetBet(), id = 1})
			else
				Network.SendRequest("lxxxl_kaijiang",{card_type = _card_type, bet_money = Model.GetBet(), id = 1})
			end
			self.anim_manager.LotteryScrollAnim()
			self.yxcard_btn.gameObject:SetActive(false)
		else
			self:ButtonStatusSet(1)
			Model.IsAuto = false
			self:OpenShop()
		end
	end
end

function C:OpenShop()
	PayPanel.Create(GOODS_TYPE.jing_bi)
	self.now_bet_index = self:GetUserBet()
	self:RefreshBetText()
end


function C:on_finish_gift_shop()
	self:RefreshGold()
end

function C:MyClose()
	self:MyExit()
end

function C:on_eliminate_cj_can_aoto()
	ExtendSoundManager.PlaySceneBGM(audio_config.cjxxl.bgm_cjxxl_beijing.audio_name)
	if Model.IsAuto then 
		self:ReSetStatus()
		if self.Auto_Delta_Timer then
			self.Auto_Delta_Timer:Stop()
		end
		self.Auto_Delta_Timer = Timer.New(
			function()
				self:GoLottery()
			end,0.5,1
		)
		self.Auto_Delta_Timer:Start()
	end
end
--普通1，免费2，自动3,普通按下4
function C:ButtonStatusSet(index)
	local hide_all = function()
		self.auto.gameObject:SetActive(false)
		self.normal.gameObject:SetActive(false)
		self.free.gameObject:SetActive(false)
		self.normal_down.gameObject:SetActive(false)
	end
	local funcs = {
		[1] = function()
			hide_all()
			self.normal.gameObject:SetActive(true)
			self.start_btn_img.sprite = GetTexture("cjxxl_btn_ks")
			self.b_tip_txt.text = "长按自动开始"
		end,
		[2] = function()
			hide_all()
			self.free.gameObject:SetActive(true)
			self.start_btn_img.sprite = GetTexture("cjxxl_btn_ks2")
			self.b_tip_txt.text = "免费"..(Model.GetCurrDataIndex() - 1).."/10次"
		end,
		[3] = function()
			hide_all()
			self.auto.gameObject:SetActive(true)
			self.start_btn_img.sprite = GetTexture("cjxxl_btn_ks2")
			self.b_tip_txt.text = "点击取消自动"
		end,
		[4] = function()
			hide_all()
			self.normal_down.gameObject:SetActive(true)
			self.start_btn_img.sprite = GetTexture("cjxxl_btn_ks3")
			self.b_tip_txt.text = "长按自动开始"
		end,
	}
	funcs[index]()
	self:RefreshYXCard(index)
end

function C:RefreshYXCard(index)
	local open, yxcard, game_level, qp_image = GameButtonManager.RunFun({gotoui = "act_060_yxcard",card_type = Model.yxcard_type}, "GetCurGameCard")
	dump({
        yxcard = yxcard,
        index = index,
        auto = Model.IsAuto
    }, "<color=red>【游戏卡状态刷新】</color>")
	if open then
		if not Model.IsAuto 
		and yxcard 
		and index ~= 3 
		and Model.Status == Status.over  
		then
			self.yxcard_btn.gameObject:SetActive(true)
            self.yxcard_img.sprite = GetTexture(qp_image)
		else
			self.yxcard_btn.gameObject:SetActive(false)
		end
	end
end

function C:GetUserBet()
	local data = Model.xiaoxiaole_defen_cfg.auto
	local qx_max = self.MaxIndex
    for i=#data,1,-1 do
        local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key="cjxxl_bet_".. i, is_on_hint=true,vip_hint_type = 2, cw_btn_desc = "确定"}, "CheckCondition")
        if not a or b then
            qx_max = i
            break
        end 
	end
	dump(qx_max,"<color=red>权限允许的最高等级</color>")
    for i = qx_max,1,-1 do
        if not data[i].min or MainModel.UserInfo.jing_bi >= data[i].min then 
            return i
        end 
    end
    return 1
end

--停止自动游戏
function C:stop_auto_lotttery()
	if Model.IsAuto then
		Model.IsAuto = false
		self:ButtonStatusSet(1)
	end
end

function C:OnClickYXCard()
	if Model.Status ~= Status.over then
		return
	end
	local open, yxcard, game_level = GameButtonManager.RunFun({gotoui = "act_060_yxcard",card_type = Model.yxcard_type}, "GetCurGameCard")
	if open then
		dump({yxcard = yxcard, game_level = game_level}, "<color=white>【使用游戏卡】</color>")
		if game_level ~= Model.xiaoxiaole_defen_cfg.yazhu[self.now_bet_index].jb then
			self.primiBet = basefunc.deepcopy(Model.xiaoxiaole_defen_cfg.yazhu[self.now_bet_index].jb)
			Model.SetBet(game_level)
			self:RefreshMyYazhu(game_level)
		end
		self:GoLottery(yxcard)
	end
end
--jbNum:鲸币总基数
function C:RefreshMyYazhu(jbNum)
	for k,v in ipairs(Model.xiaoxiaole_defen_cfg.yazhu) do
		if v.jb == jbNum then
			self.now_bet_index = k
		end
	end
	self.bet_txt.text = Model.xiaoxiaole_defen_cfg.yazhu[self.now_bet_index].jb
end