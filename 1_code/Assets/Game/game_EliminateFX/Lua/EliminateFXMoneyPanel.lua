-- 创建时间:2019-05-16
-- Panel:New Lua
local basefunc = require "Game/Common/basefunc"
EliminateFXMoneyPanel = basefunc.class()
local C = EliminateFXMoneyPanel
C.name = "EliminateFXMoneyPanel"
local instance

function C:MakeLister()
    self.lister = {}
    self.lister["view_lottery_start"] = basefunc.handler(self, self.eliminate_lottery_start)
    self.lister["view_lottery_end"] = basefunc.handler(self, self.eliminate_lottery_end)
    self.lister["view_lottery_error"] = basefunc.handler(self, self.view_lottery_error)
    self.lister["view_lottery_sucess"] = basefunc.handler(self, self.view_lottery_sucess)
	self.lister["ExitScene"] = basefunc.handler(self, self.MyExit)
	self.lister["AssetChange"] = basefunc.handler(self, self.AssetChange)
	self.lister["PayPanelClosed"] = basefunc.handler(self, self.OnClosePayPanel)
    self.lister["hf_had_fly_finish_msg"] = basefunc.handler(self,self.on_hf_had_fly_finish_msg)
	self.lister["view_lottery_start_yxcard"] = basefunc.handler(self, self.view_lottery_start_yxcard)
	self.lister["model_xxl_fxgz_bet_change"] = basefunc.handler(self, self.on_model_xxl_fxgz_bet_change)
    self.lister["free_game_times_change_msg"] = basefunc.handler(self, self.on_free_game_times_change_msg)
    self.lister["eliminatefx_change_money_title_msg"] = basefunc.handler(self, self.on_eliminatefx_change_money_title_msg)
end

function C:AddMsgListener()
    for proto_name, func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:RemoveListener()
    for proto_name, func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C.Create()
    if not instance then
        instance = C.New()
    end
    return instance
end

function C:ctor()

	ExtPanel.ExtMsg(self)

    local parent = GameObject.Find("Canvas/LayerLv1").transform
    local obj = newObject(C.name, parent)
    local tran = obj.transform
    self.transform = tran
    self.gameObject = obj
    self.jiaqian = {}
    self:InitBetList()
    self.MaxIndex = #self.jiaqian
    self.index = self:GetUserBet()
    if self.index >= self.MaxIndex then 
        self.index = self.MaxIndex
    end 
    LuaHelper.GeneratingVar(self.transform, self)
    self:MakeLister()
    self:AddMsgListener()
    self:InitUI()
    self:InitChildButton()
    self:RefreshGoldText()
    self:CheakButtonStatus()
end

function C:MyExit()
    dump("<color=yellow><size=15>+++++money+++++MyExit++++++++++</size></color>")
    print(debug.traceback())
    self:RemoveListener()

	-- self.TRImg.sprite = nil
    -- self.SXImg.sprite = nil
    destroy(self.gameObject)
end

function C:Close()
    self:MyExit()
end

--根据用户的鲸币数量获得一个初始档位
function C:GetUserBet()
    local data=EliminateFXModel.xiaoxiaole_fx_defen_cfg.auto
    local qx_max = self.MaxIndex
    for i=#data,1,-1 do
        local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key="xy_xxl_bet_".. i, is_on_hint=true}, "CheckCondition")
        if not a or b then
            qx_max = i
            break
        end 
    end
    for i = qx_max,1,-1 do
        if not data[i].min or MainModel.UserInfo.jing_bi >= data[i].min then 
            return i
        end 
    end
    return 1
end

--初始化押注的档次表
function C:InitBetList()
    for key, value in pairs(EliminateFXModel.xiaoxiaole_fx_defen_cfg.yazhu) do
        self.jiaqian[value.dw] = value.jb
    end
end

function C:InitUI()
    local betdata = EliminateFXModel.GetBet()
    self.Content = self.transform:Find("Viewport/Mask/layoutgroup")
    self.GoldText = self.gameObject.transform:Find("Txt/MoneyTxt"):GetComponent("Text")
    self.jiaqianText = self.gameObject.transform:Find("Txt/CurBetTxt"):GetComponent("Text")
    self.ps = self.gameObject.transform:Find("Txt/shanguang/UI_touru_sg/sg"):GetComponent("ParticleSystem")
    self.Addbutton = self.gameObject.transform:Find("Btn/AddBetBtn"):GetComponent("Button")
    self.Redubutton = self.gameObject.transform:Find("Btn/ReduceBetBtn"):GetComponent("Button")
    self.PayBtn = self.gameObject.transform:Find("Btn/AddMoneyBtn"):GetComponent("Button")
    self.jiaqianText.text = StringHelper.ToCash(self.jiaqian[self.index])
    EventTriggerListener.Get(self.Addbutton.gameObject).onClick = basefunc.handler(self, self.OnAddOnClick)
    EventTriggerListener.Get(self.Redubutton.gameObject).onClick = basefunc.handler(self, self.OnReduOnClick)
    EventTriggerListener.Get(self.PayBtn.gameObject).onClick = basefunc.handler(self, self.OpenPayPanel)
end

function C:RefreshGoldText()
    print(debug.traceback())
    dump(MainModel.UserInfo.jing_bi,"<color=red>福星高照:刷新金币显示</color>")
    local showGold = StringHelper.ToCash(MainModel.UserInfo.jing_bi)
    self.GoldText.text = showGold --刷新金币显示
    if string.len(showGold) > 8 then
        self.GoldText.transform.localScale = Vector3.New(0.88, 0.88, 0.88)
    end
    self.title_img.sprite = GetTexture("fxgz_imgf_qxztr")
    self.title_img:SetNativeSize()
    self.num_txt.gameObject:SetActive(false)
end

--增加押注
function C:OnAddOnClick()
 
    if self.index < self.MaxIndex then
        --Event.Brocast("open_sys_act_base")
        ExtendSoundManager.PlaySound(audio_config.fxgz.bgm_fxgz_yazhu.audio_name)
        self.index = self.index + 1
        self.Redubutton.gameObject:SetActive(true)

        local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key="xy_xxl_bet_".. self.index}, "CheckCondition")
        if a and not b then
            self.index = self.index - 1
            return
        end
        self.yazhu = self.jiaqian[self.index]
        if MainModel.UserInfo.jing_bi < self.yazhu then
            self.index = self.index - 1
            C:OpenPayPanel()
            return
        end
        self:SetChildBet()
        self:PlayParticle()
    end
    if self.index == self.MaxIndex then
        self.Addbutton.gameObject:SetActive(false)
    end
end

--初始化子按钮
function C:InitChildButton()
    self.childs = {}
    for i = 1, 5 do
        local child = EliminateFXButtonPrefab.Create(i, self.jiaqian[self.index] / 5, self.Content)
        self.childs[i] = child
    end
end

--播放特效
function C:PlayParticle()
    self.ps:Stop()
    self.ps:Play()
end

--减少押注
function C:OnReduOnClick()
    if self.index - 1 == 1 then
        self.Redubutton.gameObject:SetActive(false)
    end
    if (self.index - 1) > 0 then
        --Event.Brocast("open_sys_act_base")
        ExtendSoundManager.PlaySound(audio_config.fxgz.bgm_fxgz_yazhu.audio_name)
        self.Addbutton.gameObject:SetActive(true)
        self.index = self.index - 1
        self.yazhu = self.jiaqian[self.index]

        self:SetChildBet()
        self:PlayParticle()
    end
end

function C:AssetChange(data)
	if table_is_null(EliminateFXModel.data) or
		EliminateFXModel.data.status_lottery == EliminateFXModel.status_lottery.run then 
		return
	end
    if data.change_type and data.change_type ~= "xxl_fuxing_game_award" then
        self:RefreshGoldText()
    end
end

--开奖状态下禁止按钮
function C:eliminate_lottery_start()
    self.Addbutton.gameObject:SetActive(false)
	self.Redubutton.gameObject:SetActive(false)
	self.PayBtn.gameObject:SetActive(false)
end

--开奖结束恢复按钮
function C:eliminate_lottery_end()
	self:RefreshGoldText()
    if not EliminateFXModel.GetAuto() then
        self.Addbutton.gameObject:SetActive(true)
		self.Redubutton.gameObject:SetActive(true)
		self.PayBtn.gameObject:SetActive(true)
    else
        self.yazhu = self.jiaqian[self.index]
        if self.yazhu > MainModel.UserInfo.jing_bi then
        end
    end
    self:CheakButtonStatus()
    local open, yxcard, game_level  = GameButtonManager.RunFun({gotoui = "act_060_yxcard",card_type = EliminateFXModel.yxcard_type}, "GetCurGameCard")
	if open then
		if self.primiBet then
			EliminateFXModel.SetBet(self.primiBet)
			self:RefreshMyYazhu()
            self:CheakButtonStatus()
			self.primiBet = nil
		end
	end
end

--开奖成功
function C:view_lottery_sucess()
	--self:RefreshGoldText()
end

--开奖错误
function C:view_lottery_error()
	self:RefreshGoldText()
    self.Addbutton.gameObject:SetActive(true)
	self.Redubutton.gameObject:SetActive(true)
	self.PayBtn.gameObject:SetActive(true)
    self.yazhu = self.jiaqian[self.index]
    if self.index < 1 then
        self.index = 1
    end
    self.yazhu = self.jiaqian[self.index]
    self:SetChildBet()
    self:CheakButtonStatus()
    self.GoldText.text = StringHelper.ToCash(MainModel.UserInfo.jing_bi)--刷新金币显示
end

--打开商城
function C:OpenPayPanel()
    PayPanel.Create(GOODS_TYPE.jing_bi, "normal")
end

--当商城关闭时候
function C:OnClosePayPanel()
    self:RefreshGoldText()
end

function C:SetChildBet()
    self.jiaqianText.text = StringHelper.ToCash(self.jiaqian[self.index])
    for i = 1, 5 do
        self.childs[i]:SetBet(self.jiaqian[self.index] / 5)
    end
    Event.Brocast("elimiante_fx_money_msg",self.jiaqian[self.index])
end

--检查按钮的状态
function C:CheakButtonStatus()
    self.jiaqianText.text = StringHelper.ToCash(self.jiaqian[self.index])
    if self.index == 1 then
        self.Redubutton.gameObject:SetActive(false)
    end
    if self.index == self.MaxIndex then
        self.Addbutton.gameObject:SetActive(false)
    end
end

--开奖状态下禁止按钮
-- function C:view_xxl_xiyou_tnsh_kj(data)
--     if data then
--         self.tnsh_rate = data.rate
--         if self.tnsh_rate == 1 then
--             self.tnsh_num = 16
--         elseif self.tnsh_rate == 2 then
--             self.tnsh_num = 8
--         elseif self.tnsh_rate == 3 then
--             self.tnsh_num = 4
--         end
--     else
--         self.tnsh_num = self.tnsh_num or 0
--         self.tnsh_num = self.tnsh_num - 1
--     end
--     if not self.tnsh_num or self.tnsh_num < 0 then
--         self.tnsh_num = 0
--     end
--     if IsEquals(self.TRImg) then
--         self.TRImg.gameObject:SetActive(false)
--     end
    
--     if IsEquals(self.SXImg) then
--         self.SXImg.gameObject:SetActive(true)
--     end
    
--     if IsEquals(self.SXTxt) then
--         self.SXTxt.text = self.tnsh_num
--     end
-- end

function C:on_hf_had_fly_finish_msg()
    self.title_img.sprite = GetTexture("fxgz_imgf_jjmfyx")
    self.title_img:SetNativeSize()
    self.num_txt.gameObject:SetActive(false)
end

function C:view_lottery_start_yxcard(_game_level)
    if _game_level ~= EliminateFXModel.data.bet then
		self.primiBet = basefunc.deepcopy(EliminateFXModel.data.bet) 
	end
    EliminateFXModel.SetBet({_game_level/5, _game_level/5, _game_level/5, _game_level/5, _game_level/5})
    self:RefreshMyYazhu()
end

function C:on_model_xxl_fxgz_bet_change()
    self:RefreshMyYazhu()
end

function C:RefreshMyYazhu()
    local jiaqian_card = EliminateFXModel.data.bet[1] * 5
	if self.jiaqian[self.index] ~= jiaqian_card then
		for k,v in ipairs(self.jiaqian) do
			if v == jiaqian_card then
				self.index = k
			end
		end
	end
	self:SetChildBet()
end

function C:on_free_game_times_change_msg(num)
    self.num_txt.text = num
    --Event.Brocast("open_sys_act_base")
    --ExtendSoundManager.PlaySound(audio_config.fxgz.bgm_fxgz_zhuangji.audio_name)
end

function C:on_eliminatefx_change_money_title_msg()
    self.num_txt.text = 8
    --Event.Brocast("open_sys_act_base")
    --ExtendSoundManager.PlaySound(audio_config.fxgz.bgm_fxgz_zhuangji.audio_name)
    self.title_img.sprite = GetTexture("fxgz_imgf_mfyx")
    self.title_img:SetNativeSize()
    self.num_txt.gameObject:SetActive(true)
end