-- 创建时间:2020-08-27
-- Panel:LWZBSSPrefab
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

LWZBSSPrefab = basefunc.class()
local C = LWZBSSPrefab
C.name = "LWZBSSPrefab"
local M = LWZBModel

function C.Create(parent, index,panelSelf)
	return C.New(parent, index,panelSelf)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["ExitScene"] = basefunc.handler(self,self.MyExit)
    self.lister["ss_is_win_do_fly_jb_msg"] = basefunc.handler(self,self.on_ss_is_win_do_fly_jb_msg)
    self.lister["lwzb_force_exit_pointer_msg"] = basefunc.handler(self,self.on_lwzb_force_exit_pointer_msg)
    self.lister["lwzb_play_net_msg"] = basefunc.handler(self,self.on_lwzb_play_net_msg)
    self.lister["lwzb_play_FX_msg"] = basefunc.handler(self,self.on_lwzb_play_FX_msg)

    self.lister["lwzb_gaming_anim_msg"] = basefunc.handler(self,self.on_lwzb_gaming_anim_msg)
    self.lister["lwzb_gaming_refresh_msg"] = basefunc.handler(self,self.on_lwzb_gaming_refresh_msg)
    self.lister["lwzb_in_gaming_anim_init_msg"] = basefunc.handler(self,self.on_lwzb_in_gaming_anim_init_msg)
    self.lister["lwzb_out_gaming_anim_init_msg"] = basefunc.handler(self,self.on_lwzb_out_gaming_anim_init_msg)
   	self.lister["lwzb_lw_fight_ss_msg"] = basefunc.handler(self,self.on_lwzb_lw_fight_ss_msg)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	self:HitTweenKill()
	self:KillWinTween()
	self:StopUpdateTimer()
	self:KillBackTween()
	self:KillBumpTween()
	self:StopDotTimer()
	self:KillScaleTween()
	self:KillHint_cnTween()
	self:KillOnLuckyStarTween()
	self:KillTween()
	self:ExitJZPre()
	self:StopDownTime()
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:OnDestroy()
	self:MyExit()
end

function C:MyClose()
	self:MyExit()
end

function C:ctor(parent, index,panelSelf)
	self.index = index
	self.panelSelf = panelSelf
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self.type_bg_canvas = self.type_bg.transform:GetComponent("CanvasGroup")
	self.hint_cn_canvas = self.hint_cn.transform:GetComponent("CanvasGroup")
	self.slider = self.Slider.transform:GetComponent("Slider")

	local pre_name = LWZBManager.GetSSPreName(self.index)
	self.pre = newObject(pre_name, self.icon_img.transform)
	self.anim = self.pre.transform:GetComponent("Animator")
	self.orign_pos = self.icon_and_hp.transform.position

	self.type_new_img_orign_pos = self.type_new_img.transform.position
	for i=1,5 do
		self["pai"..i.."_orign_pos"] = self["pai"..i].transform.position
	end
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
    self.is_down = true
    PointerEventListener.Get(self.down_btn.gameObject).onDown = basefunc.handler(self, self.OnDown)
    PointerEventListener.Get(self.down_btn.gameObject).onUp = basefunc.handler(self, self.OnUp)
    self.pai_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:OnPaiClick()
	end)
	self.type_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:OnTypeClick()
	end)
	self.rate_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:OnRateClick()
	end)
	self:MyRefresh()
	--self:UpdateTimer(true)
end

function C:OnPaiClick()
	if not self.onoff1 then
		self.onoff1 = true
		self.pai_btn.gameObject:SetActive(false)
		Event.Brocast("lwzb_guide_check")
	end
end

function C:OnTypeClick()
	if not self.onoff2 then
		self.onoff2 = true
		self.type_btn.gameObject:SetActive(false)
		Event.Brocast("lwzb_guide_check")
	end
end

function C:OnRateClick()
	self.rate_btn.gameObject:SetActive(false)
	Event.Brocast("lwzb_ss_fp_finish_msg", {index=self.index,is_win = self.is_win})
end

function C:MyRefresh()
	if self.index == 1 then
		self.icon_img.sprite = GetTexture("lwzb_icon_sy")
	elseif self.index == 2 then
		self.icon_img.sprite = GetTexture("lwzb_icon_jchan")
	elseif self.index == 3 then
		self.icon_img.sprite = GetTexture("3dby_icon_bl")
	else
		self.icon_img.sprite = GetTexture("lwzb_icon_ey")
	end
	self.icon_img:SetNativeSize()
	self:RefreshHistorySF()
	self:RefreshZhu()
	self:RefreshLongZ()
	self:RefreshHP_lw()
	self:RefreshHP_self()
	self:RefreshPartycle()
end

function C:StopDownTime()
	if self.down_time then
		self.down_time:Stop()
		self.down_time = nil
	end
end
function C:ExitJZPre()
	if self.jz_pre then
		local b = self.jz_pre:MyExit()
		self.jz_pre = nil
		return b
	end
end

function C:OnDown()
	dump(M.GetCurStatus(),"<color=green>+++++++++++++++++++++++++</color>")
	dump(M.Model_Status.bet,"<color=green>+++++++++++++++++++++++++</color>")
	if not LWZBManager.CheckMoneyIsEnoughOnSettle() then
		M.CreateHint()
		return
	end

	if M.GetCurStatus() ~= M.Model_Status.bet then
		dump("<color=red>111111111111111111111</color>")
		LittleTips.Create("当前状态不可充能,请在充能阶段进行充能")
		return
	end

	if LWZBManager.GetLwzbGuideOnOff() then
		local rate_index = M.GetCurRateIndex()
		M.Bet(self.index,rate_index)
		Event.Brocast("LwzbGuide_my_money_change_msg")
		return
	end

	if M.CheckIisLW() then
		dump("<color=red>2222222222222222222222</color>")
		LittleTips.Create("您当前是龙王,不可参与充能")
		return
	end

	if M.CheckAllBetLimit() then
		dump("<color=red>3333333333333333333333</color>")
		LittleTips.Create("您本局的总充能已达到上限，不可继续充能。")
		return
	end

	if M.CheckSSBetLimit(self.index) then
		dump("<color=red>44444444444444444444</color>")
		LittleTips.Create("您本局在此神兽的充能已达到上限，不可继续充能。")
		return
	end

	if M.CheckAllBetPercentageLimit() then
		dump("<color=red>55555555555555555555</color>")
		LittleTips.Create("充能已达上限，提高vip等级可提高充能上限。")
		return
	end

	--[[if self.is_auto_or_continue then
		dump("<color=red>6666666666666666666</color>")
		LittleTips.Create(self.tip)
		return
	end--]]

	if not self.is_down then
		dump("<color=red>77777777777777777</color>")
		return
	end
	dump("<color=red>8888888888888888888</color>")
	local rate_index = M.GetCurRateIndex()
	M.Bet(self.index,rate_index)
	self.is_down = false
	self:ExitJZPre()
	self:StopDownTime()
	self.down_time = Timer.New(function()
        self:StopDownTime()
        self.jz_pre = LWZBPointerPrefab.Create(self.jz_node.transform)
    end, 1, 1, true)
    self.down_time:Start()
end
function C:OnUp()
	self.is_down = true
	self:StopDownTime()
	if not LWZBManager.CheckMoneyIsEnoughOnSettle() then
		return
	end

	if M.GetCurStatus() ~= M.Model_Status.bet then
		dump("<color=yellow>111111111111111111111</color>")
		return
	end

	if LWZBManager.GetLwzbGuideOnOff() then
		return
	end

	if M.CheckIisLW() then
		dump("<color=yellow>222222222222222222222</color>")
		return
	end

	if M.CheckAllBetLimit() then
		dump("<color=yellow>3333333333333333333333</color>")
		return
	end
	dump("<color=yellow>+++++++++++++++6666666666+++++++++++++++++++</color>")

	if M.CheckSSBetLimit(self.index) then
		dump("<color=yellow>44444444444444444444</color>")
		return
	end

	if M.CheckAllBetPercentageLimit() then
		dump("<color=yellow>5555555555555555555555</color>")
		return
	end

	--[[if self.is_auto_or_continue then
		dump("<color=yellow>666666666666666666</color>")
		return
	end--]]

	dump("<color=yellow>7777777777777777777</color>")
	local b = self:ExitJZPre()
	if b then
		M.JZBet(self.index)
		self:ShowJZTip()
		Event.Brocast("lwzb_xz_msg", {is_my = true, xz_type="jz", pos=self.transform.position ,index = self.index})
	else
		Event.Brocast("lwzb_xz_msg", {is_my = true, xz_type="pt", pos=self.transform.position ,index = self.index})
	end
end

function C:GetSJPos()
	return self.transform.position
end

-- 开始比牌
function C:PlayBP()
	self:RefreshHistorySF()
	ExtendSoundManager.PlaySound(audio_config.lwzb.bgm_lwzb_vs.audio_name)
	GameComAnimTool.PlayShowAndHideAndCall(self.transform, "LWZB_VS", self.transform.position - Vector3.New(30,0,0), 0.8, 0.7, function ()
		ExtendSoundManager.PlaySound(audio_config.lwzb.bgm_lwzb_kaipai.audio_name)
		GameComAnimTool.PlayShowAndHideAndCall(self.transform, "LWZB_pai_fan", self.hint_pai.transform.position, 0.7, 0.3, function ()
			for i=1,5 do
				self["pai"..i].gameObject:SetActive(true)
			end		
		end)
			local seq = DoTweenSequence.Create()
			seq:AppendInterval(0.2)
			seq:OnKill(function ()
				self:ShowPX()
			end)
	end)
end
function C:ShowPX()
	if self.type == 1 or self.type == 2 then
		self.type_txt.gameObject:SetActive(true)
		self.type_img.gameObject:SetActive(false)
	else
		self.type_txt.gameObject:SetActive(false)
		self.type_img.gameObject:SetActive(true)
	end
	self:TypeDotween()
end

--历史6局胜负记录(小圆点)
function C:RefreshHistorySF(bool)
	if bool then
		self.sf_node.gameObject:SetActive(true)
		local data = M.GetHistorySFData(self.index)
		dump(data,"<color>++++++++++++++++++++++</color>")
		if data then
			for i=1,#data do
				self["s"..i].gameObject:SetActive(data[#data - i + 1] == 1)
				self["f"..i].gameObject:SetActive(data[#data - i + 1] == 0)
			end
		end
	else
		self.sf_node.gameObject:SetActive(false)
	end
end

function C:RefreshMyBet(num)
	self.wdcn_txt.text = "我的充能"..num
	self.wdcn1_txt.text = "我的充能"..num
end
function C:RefreshAllBet(num)
	self.zcn_txt.text = "总充能"..num
	local scale = 1 + num / 1000000
	if scale > 1.4 then
		scale = 1.4
	end
	local scale_temp = scale / 30
	self:KillScaleTween()
	self.seq_scale = DoTweenSequence.Create()
	self.seq_scale:Append(self.icon_img.transform:DOScale(Vector3.New(scale + scale_temp,scale + scale_temp,scale + scale_temp),0.4))
	self.seq_scale:Append(self.icon_img.transform:DOScale(Vector3.New(scale,scale,scale),0.2))
end

function C:KillScaleTween()
	if self.seq_scale then
		self.seq_scale:Kill()
		self.seq_scale = nil
	end
end

function C:RefreshPai(tab)
	--[[for i=1,#tab do
		--dump(tab[i],"<color=blue><size=15>++++++++++data++++++++++</size></color>")
		self["pai"..i.."_img"].sprite = GetTexture("lwzb_imgf_"..LWZBManager.TranslatePai(tab[i]))
	end--]]
end

function C:RefreshPaiType(type)
	self.type = type
	if self.type == 1 or self.type == 2 then
		self.type_txt.text = LWZBManager.CheckPaiType(self.type)
	else
		self.type_img.sprite = GetTexture(LWZBManager.CheckPaiType(self.type))
		self.type_img:SetNativeSize()
	end
end

function C:RefreshIsWin(is_win)
	self.is_win = is_win
end


--播放精准下注成功的上浮提示
function C:ShowJZTip()
	local begin_pos = self.transform.position + Vector3.New(0,80,0)
	local end_pos = self.transform.position + Vector3.New(0,140,0)
	GameComAnimTool.PlayMoveAndHideFX(self.transform , "lwzb_jz_success_tip" , begin_pos , end_pos , 1 , 1 )
end

function C:on_ss_is_win_do_fly_jb_msg()
	Event.Brocast("lwzb_do_fly_jb_msg",self.transform.position,self.is_win,self.index)
end

function C:IsShouldShowHint(bool)
	self.hint_cn.gameObject:SetActive(bool)
	self.hint_cnsj.gameObject:SetActive(bool)
	if bool then
		--self:DoTweenHint_cn()
	end
end

function C:IsShouldShowMyCN()
	if M.GetCurStatus() == M.Model_Status.game then
		self.hint_wdcn.gameObject:SetActive(true)
	else
		self.hint_wdcn.gameObject:SetActive(false)
	end
end

function C:SetActiveInit()
	self.win_node.gameObject:SetActive(false)
	self.lose_node.gameObject:SetActive(false)
	for i = 1, 5 do
		self["pai"..i].gameObject:SetActive(false)
	end
	self.rate_txt.gameObject:SetActive(false)
	self.type_txt.gameObject:SetActive(false)
	self.type_img.gameObject:SetActive(false)
	self.type_bg_canvas.alpha = 0
	self.win_node.transform.localScale = Vector3.New(3.4,3.4,1)
	self.lose_node.transform.localScale = Vector3.New(1.4,1.4,1)
end

function C:OnLuckyStar()
	self.hint_xyx.gameObject:SetActive(true)
	self:OnLuckyStarTween()
end

function C:OnLuckyStarTween()
	self:KillOnLuckyStarTween()
	self.seq_star = DoTweenSequence.Create()
	self.seq_star:Append(self.hint_xyx.transform:DOScale(Vector3.New(1.2,1.2,1.2),0.4))
	self.seq_star:Append(self.hint_xyx.transform:DOScale(Vector3.New(1,1,1),0.4))
end

function C:KillOnLuckyStarTween()
	if self.seq_star then
		self.seq_star:Kill()
		self.seq_star = nil
	end
end

function C:OffLuckyStar()
	self.hint_xyx.gameObject:SetActive(false)
end

function C:SetBtnStatus()
	local type = M.GetCurBetType()
	if type then
		if type == "auto" then
			self.tip = "已自动充能"
		elseif type == "continue" then
			self.tip = "已连续充能"
		end
		self.is_auto_or_continue = true
	else
		self.is_auto_or_continue = false
	end
end

function C:InitSSBtnStatus()
	self.is_auto_or_continue = false
end

--展示牌型时的动画
function C:TypeDotween()
	self:KillTween()
	self.seq = DoTweenSequence.Create()
	self.type_bg.transform.localPosition = Vector3.New(172,-42,0)
	self:CheckTypePositionAndScale()
	self.seq:Append(self.type_bg.transform:DOLocalMoveX(-60, 0.6))
	self.seq:Join(self.type_bg_canvas:DOFade(1, 0.4))
	local is_win = self.is_win
	if is_win == 1 then
		--ExtendSoundManager.PlaySound(audio_config.lwzb.bgm_lwzb_shengli.audio_name)
	elseif is_win == 0 then
		--ExtendSoundManager.PlaySound(audio_config.lwzb.bgm_lwzb_shibai.audio_name)
	end
	self.seq:AppendInterval(0.5)
	self.seq:AppendCallback(function ()
		self.win_node.gameObject:SetActive(is_win == 1)
		self.lose_node.gameObject:SetActive(is_win == 0)
		self.rate_txt.gameObject:SetActive(true)
	end)
	if is_win == 1 then
		self.seq:Join(self.win_node.transform:DOScale(Vector3.New(1,1,1),0.4))
	elseif is_win == 0 then
		self.seq:Join(self.lose_node.transform:DOScale(Vector3.New(1,1,1),0.4))
	end
	self.seq:InsertCallback(0.3,function ()
		if LWZBManager.GetLwzbGuideOnOff() and self.index == 3 then
			if not self.onoff3 then
				self.onoff3 = true
				self.pai_btn.gameObject:SetActive(true)
				self.type_btn.gameObject:SetActive(true)
				self.rate_btn.gameObject:SetActive(true)
				Event.Brocast("lwzb_guide_check")
			end
		else
			Event.Brocast("lwzb_ss_fp_finish_msg", {index=self.index,is_win = self.is_win})
		end
	end)
end

function C:KillTween()
	if self.seq then
		self.seq:Kill()
		self.seq = nil
	end
end

function C:CheckTypePositionAndScale()
	--dump({index=self.index,type=self.type},"<color=green>66666666666666666666</color>")
	if self.type > 11 then
		self.type_img.transform.localPosition = Vector3.New(-46,20,0)
		self.type_img.transform.localScale = Vector3.New(0.7,0.7,1)
	elseif self.type == 11 then
		self.type_img.transform.localPosition = Vector3.New(-34,30,0)
		self.type_img.transform.localScale = Vector3.New(1,1,1)
	else
		self.type_img.transform.localPosition = Vector3.New(0,0,0)
		self.type_txt.transform.localPosition = Vector3.New(0,0,0)
		self.type_img.transform.localScale = Vector3.New(1,1,1)
	end
end

function C:GetLuckStarPos()
	return self.hint_xyx.transform.position
end

function C:GetLuckStarStatus()
	return self.hint_xyx.gameObject.activeSelf
end

function C:BP_ReConnencte()
	for i=1,5 do
		self["pai"..i].gameObject:SetActive(true)
	end		
	self.rate_txt.gameObject:SetActive(true)
	if self.type == 1 or self.type == 2 then
		self.type_txt.gameObject:SetActive(true)
		self.type_img.gameObject:SetActive(false)
	else
		self.type_txt.gameObject:SetActive(false)
		self.type_img.gameObject:SetActive(true)
	end
	self.type_bg.transform.localPosition = Vector3.New(172,-42,0)
	self:CheckTypePositionAndScale()
	self.type_bg.transform.localPosition = Vector3.New(-60,self.type_bg.transform.localPosition.y,self.type_bg.transform.localPosition.z)
	self.type_bg_canvas.alpha = 1
	local is_win = self.is_win
	self.win_node.gameObject:SetActive(is_win == 1)
	self.lose_node.gameObject:SetActive(is_win == 0)
	if is_win == 1 then
		self.win_node.transform.localScale = Vector3.New(1,1,1)
	elseif is_win == 0 then
		self.lose_node.transform.localScale = Vector3.New(1,1,1)
	end
end

function C:DoTweenHint_cn()
	self:KillHint_cnTween()
	self.seq_hint_cn = DoTweenSequence.Create()
	self.hint_cn_canvas.alpha = 1
	self.seq_hint_cn:Append(self.hint_cn_canvas:DOFade(0,0.8))
	self.seq_hint_cn:Append(self.hint_cn_canvas:DOFade(1,0.8))
	self.seq_hint_cn:SetLoops(-1, DG.Tweening.LoopType.Yoyo):SetEase(DG.Tweening.Ease.Linear)
end

function C:KillHint_cnTween()
	if self.seq_hint_cn then
		self.seq_hint_cn:Kill()
		self.seq_hint_cn = nil
	end
end

function C:on_lwzb_force_exit_pointer_msg()
	self:ExitJZPre()
end

function C:on_lwzb_play_net_msg(index)
	if self.index == index then
		local rate_index = M.GetCurRateIndex()
		LWZBManager.PlayGunNet(self.transform,rate_index)
		self.anim:Play("hit",-1,0)
	end
end

function C:on_lwzb_play_FX_msg(index)
	if self.index == index then
		self.anim:Play("hit",-1,0)
	end
end

function C:RefreshRate(rate)
	self.rate_txt.text = "x"..math.abs(rate)
	if rate > 0 then
		self.rate_txt.font = GetFont("lwzb_font_hjz2")
	elseif rate < 0 then
		self.rate_txt.font = GetFont("lwzb_font_hjzy")
	end
end

function C:GetOBJ_pai()
	return self.hint_pai.gameObject
end

function C:GetOBJ_type()
	return self.type_bg.gameObject
end

function C:GetOBJ_rate()
	return self.rate_txt.gameObject
end

--状态式表现
function C:on_lwzb_gaming_refresh_msg()
	self:MyRefresh()
end

--初始化显示(进入比牌阶段)
function C:on_lwzb_in_gaming_anim_init_msg()
	self.Slider.gameObject:SetActive(true)
	self.slider.value = 1
end

--初始化显示(结束比牌阶段)
function C:on_lwzb_out_gaming_anim_init_msg()
	self.Slider.gameObject:SetActive(false)
	self.slider.value = 1
	self.LWZB_SS_dun.gameObject:SetActive(false)
	self.icon_and_hp.transform.position = self.orign_pos
	self.icon_and_hp.transform.localScale = Vector3.one
	self.LWZB_SS_dun.transform.localPosition = Vector3.New(0,191,0)
	self.LWZB_SS_dun.transform.localRotation = Quaternion.Euler(0,0,0)
	if IsEquals(self.pre_gray) then
		destroy(self.pre_gray.gameObject)
		self.pre_gray = nil
	end
	self.LWZB_huanrao_01.gameObject:SetActive(false)
	self.LWZB_huanrao_02.gameObject:SetActive(false)
	self.LWZB_huanrao_03.gameObject:SetActive(false)
	self.LWZB_huanrao.gameObject:SetActive(false)
	self.zhu_type_img.gameObject:SetActive(false)
	self.pre.gameObject:SetActive(true)
	self.type_new_img.gameObject:SetActive(false)
	self.type_new_img.transform.localScale = Vector3.one
	self.type_new_img.transform.position = self.type_new_img_orign_pos
	for i=1,5 do
		self["pai"..i].transform.position = self["pai"..i.."_orign_pos"]
	end
end

--战斗判定(第三轮)
function C:FightStandOff()
	if M.GetCurStatus() and M.GetCurStatus() ~= M.Model_Status.game or not M.GetCurStatus() then
		return
	end
	local all_info = M.GetAllInfo()
	local ss_data = all_info.game_data.monster_pai
	local is_win = ss_data[self.index].is_win
	self:KillBumpTween()
	self.seq_bump = DoTweenSequence.Create()
	local target_pos
	local dun_rotate
	local dun_position
	local pre_gray_name
	if self.index == 1 then
		target_pos = self.transform.position + Vector3.New(130,300,0)
		pre_gray_name = "LWZB_shayu_gray"
		dun_rotate = Quaternion.Euler(0,0,-100)
		dun_position = Vector3.New(210,-42,0)
	elseif self.index == 2 then
		target_pos = self.transform.position + Vector3.New(10,-40,0)
		pre_gray_name = "LWZB_jinchan_gray"
		dun_rotate = Quaternion.Euler(0,0,-20)
		dun_position = Vector3.New(20,191,0)
	elseif self.index == 3 then
		target_pos = self.transform.position + Vector3.New(-10,-40,0)
		pre_gray_name = "LWZB_binggui_gray"
		dun_rotate = Quaternion.Euler(0,0,5)
		dun_position = Vector3.New(-20,191,0)
	elseif self.index == 4 then
		target_pos = self.transform.position + Vector3.New(-130,300,0)
		pre_gray_name = "LWZB_eryu_gray"
		dun_rotate = Quaternion.Euler(0,0,100)
		dun_position = Vector3.New(-210,-42,0)
	end
	self.LWZB_SS_dun.transform.localRotation = dun_rotate
	self.LWZB_SS_dun.transform.localPosition = dun_position
	self.seq_bump:Append(self.icon_and_hp.transform:DOMove(target_pos,1):SetEase(DG.Tweening.Ease.InBack)) 
	self.seq_bump:Join(self.icon_and_hp.transform:DOScale(0.6,1))	
	self.seq_bump:AppendCallback(function ()
		self:StopDotTimer()
		self.LWZB_SS_dun.gameObject:SetActive(true)
		local all_info = M.GetAllInfo()
		local ss_pai_type = all_info.game_data.monster_pai[self.index].pai_type
		local lw_pai_type = all_info.game_data.long_wang_pai.pai_type
		self.count = 0
		math.randomseed(self.index*self.index*18978798 + os.time())
		if is_win == 0 then
			self.temp = (self.slider.value + ((lw_pai_type - ss_pai_type)/2 + math.random(0,10))/20) / 250
		else
			if ss_pai_type == lw_pai_type then
				self.temp = (self.slider.value - math.random(0.05,0.15)) / 300
			else
				self.temp = (self.slider.value - (ss_pai_type - lw_pai_type)/20) / 300
			end
		end
		self.dot_timer = Timer.New(function ()
			self.slider.value = self.slider.value - self.temp
			self.count = self.count + 0.01
			if self.count >= 3 or self.slider.value <= 0 then
				if self.slider.value <= 0 or is_win == 0 then
					self.slider.value = 0
					self.panelSelf:CountDie(self.index)
					self.LWZB_SS_dun.gameObject:SetActive(false)
					self.pre_gray = newObject(pre_gray_name, self.icon_img.transform)
					self.pre.gameObject:SetActive(false)
					self.LWZB_huanrao_01.gameObject:SetActive(false)
					self.LWZB_huanrao_02.gameObject:SetActive(false)
					self.LWZB_huanrao_03.gameObject:SetActive(false)
					self.LWZB_huanrao.gameObject:SetActive(false)
					self:KillBackTween()
					self.seq_back = DoTweenSequence.Create()
					self.seq_back:Append(self.icon_and_hp.transform:DOMove(self.orign_pos,1)) 
					self.seq_back:Join(self.icon_and_hp.transform:DOScale(1,1))	
					self.seq_back:AppendCallback(function ()
						self:WinTween()
					end)
				end
				self:StopDotTimer()
			end
		end,0.01,-1,false)
		self.dot_timer:Start()
	end)
end

function C:KillBumpTween()
	if self.seq_bump then
		self.seq_bump:Kill()
		self.seq_bump = nil
	end
end

function C:KillBackTween()
	if self.seq_back then
		self.seq_back:Kill()
		self.seq_back = nil
	end
end

function C:StopDotTimer()
	if self.dot_timer then
		self.dot_timer:Stop()
		self.dot_timer = nil
	end
end

function C:on_lwzb_lw_fight_ss_msg(num,index)
	--dump({num=num,index=index,self=self.index},"<color=yellow><size=15>++++++++++888888888888888888++++++++++</size></color>")
	if self.index == index then
		if num then
			if num == 0 then
				--miss
				GameComAnimTool.PlayMoveAndHideFX(self.transform,"lwzb_miss",self.transform.position,self.transform.position + Vector3.New(0,100,0),0.1,0.2)
			else
				self.slider.value = self.slider.value - num
				self.anim:Play("hit",-1,0)
			end
		end
	end
end

function C:RefreshPartycle()
	if M.GetCurStatus() and M.GetCurStatus() == M.Model_Status.game then
		local all_info = M.GetAllInfo()
		local state = M.GetStageStatusOrder()
		if all_info and state then
			local ss_data = all_info.game_data.monster_pai
			if state.Stage == 2 and state.Order >= self.index then
				if ss_data[self.index].pai_type >= 2 and ss_data[self.index].pai_type <= 9 then
					self.LWZB_huanrao_01.gameObject:SetActive(true)
					self.LWZB_huanrao_02.gameObject:SetActive(false)
				elseif ss_data[self.index].pai_type >= 10 then
					self.LWZB_huanrao_01.gameObject:SetActive(false)
					self.LWZB_huanrao_02.gameObject:SetActive(true)
				else
					self.LWZB_huanrao_01.gameObject:SetActive(false)
					self.LWZB_huanrao_02.gameObject:SetActive(false)
				end
				if state.Status == "Fight" then
					self.LWZB_huanrao_01.gameObject:SetActive(false)
					self.LWZB_huanrao_02.gameObject:SetActive(false)
					self.LWZB_SS_dun.gameObject:SetActive(false)
				end
			end
		end
	else
		self.LWZB_huanrao_01.gameObject:SetActive(false)
		self.LWZB_huanrao_02.gameObject:SetActive(false)
		self.LWZB_SS_dun.gameObject:SetActive(false)
	end
end


function C:RefreshLongZhuRotation()
	--xuli_cx_sanke
	self.zhu1_img.transform.rotation = Quaternion.Euler(0, 0, 0)
	self.zhu2_img.transform.rotation = Quaternion.Euler(0, 0, 0)
	self.zhu3_img.transform.rotation = Quaternion.Euler(0, 0, 0)
	self.zhu4_img.transform.rotation = Quaternion.Euler(0, 0, 0)
	self.zhu5_img.transform.rotation = Quaternion.Euler(0, 0, 0)
end

function C:UpdateTimer(b)
	self:StopUpdateTimer()
	if b then
		self.update_timer = Timer.New(function ()
			self:RefreshLongZhuRotation()
		end,0.06,-1,false)
		self.update_timer:Start()
	end
end

function C:StopUpdateTimer()
	if self.update_timer then
		self.update_timer:Stop()
		self.update_timer = nil
	end
end

function C:WinTween()
	local all_info = M.GetAllInfo()
	if all_info then
		local ss_data = all_info.game_data.monster_pai
		if ss_data then
			local is_win = ss_data[self.index].is_win
			self:KillWinTween()
			self.seq_win = DoTweenSequence.Create()
			self.win_node.gameObject:SetActive(is_win == 1)
			self.lose_node.gameObject:SetActive(is_win == 0)
			self.type_new_img.gameObject:SetActive(false)
			if is_win == 1 then
				self.seq_win:Append(self.win_node.transform:DOScale(Vector3.New(1.4,1.4,1.4),0.4))
				self.seq_win:AppendCallback(function ()
					self.panelSelf:LWFaJiang()
				end)
			elseif is_win == 0 then
				self.seq_win:Append(self.lose_node.transform:DOScale(Vector3.New(1.4,1.4,1.4),0.4))
			end
		end
	end
end

function C:KillWinTween()
	if self.seq_win then
		self.seq_win:Kill()
		self.seq_win = nil
	end
end

function C:LWIsDie()
	self.LWZB_SS_dun.gameObject:SetActive(false)
	self:KillBackTween()
	self.seq_back = DoTweenSequence.Create()
	self.seq_back:Append(self.icon_and_hp.transform:DOMove(self.orign_pos,1)) 
	self.seq_back:Join(self.icon_and_hp.transform:DOScale(1,1))	
	self.seq_back:AppendCallback(function ()
		self.LWZB_huanrao_01.gameObject:SetActive(false)
		self.LWZB_huanrao_02.gameObject:SetActive(false)
		self.LWZB_huanrao_03.gameObject:SetActive(false)
		self.LWZB_huanrao.gameObject:SetActive(false)
		self:WinTween()
	end)
	self:StopDotTimer()
end

--触发式表现_3.0版本需求
function C:on_lwzb_gaming_anim_msg()
	local state = M.GetStageStatusOrder()
	if state.Status ~= "Tips" and state.Order ~= 5 and state.Order ~= self.index then
		return
	end
	local all_info = M.GetAllInfo()
	local ss_data = all_info.game_data.monster_pai
	self.Debugtype_txt.text = ss_data[self.index].pai_type
	if state.Stage == 1 then
		if state.Status == "StoreUpTheStrength" then
			--蓄力然后聚合
			self.lwzb_xuli_bg.gameObject:SetActive(true)
			self.LWZB_huanrao.gameObject:SetActive(true)
			GameComAnimTool.PlayShowAndHideAndCall(self.transform,"LWZB_timer_delay",self.transform.position,1.3,0.85,function ()
				GameComAnimTool.PlayShowAndHideAndCall(self.transform, "LWZB_pai_fan", self.hint_pai.transform.position, 0.7, 0.3, function ()
					for i=2,4 do
						self["pai"..i].gameObject:SetActive(true)
					end
					if LWZBManager.CheckIsMultipleOfTen_New(ss_data[self.index].pai_data,2,4) then
						GameComAnimTool.PlayShowAndHideAndCall(self.transform,"LWZB_timer_delay",self.transform.position,2,0.5,function ()
							GameComAnimTool.PlayShowAndHideAndCall(self.transform,"LWZB_xuli_shanguang",self.transform.position + Vector3.New(0,-130,0),1,0.1,function ()
								self.type_new_img.gameObject:SetActive(true)
								self.type_new_img.sprite = GetTexture("lwzb_iocn_lh")
								self.type_new_img.transform.localScale = Vector3.one * 1.4
								self.type_new_img:SetNativeSize()
								for i=2,4 do
									self["pai"..i].gameObject:SetActive(false)
								end
							end)
						end)
					end
				end)
			end,nil,nil,function ()
				self.lwzb_xuli_bg.gameObject:SetActive(false)
				self.LWZB_huanrao.gameObject:SetActive(false)
			end)
		elseif state.Status == "Fight" then
			self:Fight()
		end
	elseif state.Stage == 2 then
		if state.Status == "StoreUpTheStrength" then
			--蓄力然后聚合
			self.lwzb_xuli_bg.gameObject:SetActive(true)
			self.LWZB_huanrao.gameObject:SetActive(true)
			GameComAnimTool.PlayShowAndHideAndCall(self.transform,"LWZB_timer_delay",self.transform.position,1.8,0.75,function ()
				GameComAnimTool.PlayShowAndHideAndCall(self.transform, "LWZB_pai_fan", self.hint_pai.transform.position, 0.7, 0.3, function ()
					self.pai1.gameObject:SetActive(true)
					self.pai5.gameObject:SetActive(true)
					if LWZBManager.CheckIsMultipleOfTen_New(ss_data[self.index].pai_data,2,4) then
						self.pai1.transform.position = self.pai1_orign_pos + Vector3.New(50,0,0)
						self.pai5.transform.position = self.pai5_orign_pos + Vector3.New(-50,0,0)
					end
					GameComAnimTool.PlayShowAndHideAndCall(self.transform,"LWZB_timer_delay",self.transform.position,2.5,0.6,function ()
						GameComAnimTool.PlayShowAndHideAndCall(self.transform,"LWZB_xuli_shanguang",self.transform.position + Vector3.New(0,-130,0),1,0.3,function ()
							self.type_new_img.gameObject:SetActive(true)
							self.type_new_img.transform.localPosition = Vector3.New(0,6,0)
							self:CheckTypeNewImgPosition()
							self.type_new_img.sprite = GetTexture(LWZBManager.CheckPaiType_New(ss_data[self.index].pai_type))
							self.type_new_img:SetNativeSize()
							for i=1,5 do
								self["pai"..i].gameObject:SetActive(false)
							end

						end)
					end)
				end)
			end,nil,nil,function ()
				self:RefreshPartycle()
				GameComAnimTool.PlayShowAndHideAndCall(self.transform,"LWZB_timer_delay",self.transform.position,1,0.4,function ()
					self.lwzb_xuli_bg.gameObject:SetActive(false)
					self.LWZB_huanrao.gameObject:SetActive(false)
				end)	
			end)
		elseif state.Status == "Fight" then
			self:FightStandOff()
		end
	end
end

--战斗判定_3.0
function C:Fight()
	local state = M.GetStageStatusOrder()
	local all_info = M.GetAllInfo()
	local ss_pai_type = all_info.game_data.monster_pai[self.index].pai_type
	local lw_pai_type = all_info.game_data.long_wang_pai.pai_type
	local ss_data = all_info.game_data.monster_pai
	self:HitTweenKill()
	self.seq_hit = DoTweenSequence.Create()
	if state.Stage == 1 then
		if LWZBManager.CheckIsMultipleOfTen_New(ss_data[self.index].pai_data,2,4) then
			self.LWZB_huanrao_03.gameObject:SetActive(true)
			self.seq_hit:AppendInterval(0.75)
			self.seq_hit:Append(self.type_new_img.transform:DOMove(self.panelSelf:GetLWPos(),0.6):SetEase(DG.Tweening.Ease.InExpo))
			self.seq_hit:Join(self.icon_and_hp.transform:DOMove(self.panelSelf:GetLWPos(),0.6):SetEase(DG.Tweening.Ease.InExpo))
			self.seq_hit:AppendCallback(function ()
				if ss_pai_type < lw_pai_type then
					Event.Brocast("lwzb_ss_fight_lw_msg",0,true)
				elseif ss_pai_type > lw_pai_type then
					Event.Brocast("lwzb_ss_fight_lw_msg",0.2,true)
				else
					math.randomseed(tostring(os.time()):reverse():sub(1, 7))
					local r = math.random(0,100)
					if r < 50 then
						Event.Brocast("lwzb_ss_fight_lw_msg",0,true)
					else
						Event.Brocast("lwzb_ss_fight_lw_msg",0.2,true)
					end
				end
			end)
			self.seq_hit:Append(self.type_new_img.transform:DOMove(self.type_new_img_orign_pos,0.3))
			self.seq_hit:Join(self.icon_and_hp.transform:DOMove(self.orign_pos,0.3))
			self.seq_hit:AppendInterval(0.5)
			self.seq_hit:AppendCallback(function ()
				self.LWZB_huanrao_03.gameObject:SetActive(false)
			end)
		else
			self.seq_hit:AppendInterval(0.75)
			self.seq_hit:Append(self.pai2.transform:DOMove(self.panelSelf:GetLWPos(),0.6):SetEase(DG.Tweening.Ease.InExpo))
			self.seq_hit:Join(self.pai3.transform:DOMove(self.panelSelf:GetLWPos(),0.6):SetEase(DG.Tweening.Ease.InExpo))
			self.seq_hit:Join(self.pai4.transform:DOMove(self.panelSelf:GetLWPos(),0.6):SetEase(DG.Tweening.Ease.InExpo))
			self.seq_hit:Join(self.icon_and_hp.transform:DOMove(self.panelSelf:GetLWPos(),0.6):SetEase(DG.Tweening.Ease.InExpo))
			self.seq_hit:AppendCallback(function ()
				if ss_pai_type < lw_pai_type then
					Event.Brocast("lwzb_ss_fight_lw_msg",0)
				elseif ss_pai_type > lw_pai_type then
					Event.Brocast("lwzb_ss_fight_lw_msg",0.2)
				else
					math.randomseed(tostring(os.time()):reverse():sub(1, 7))
					local r = math.random(0,100)
					if r < 50 then
						Event.Brocast("lwzb_ss_fight_lw_msg",0)
					else
						Event.Brocast("lwzb_ss_fight_lw_msg",0.2)
					end
				end
			end)
			self.seq_hit:Append(self.pai2.transform:DOMove(self.pai2_orign_pos,0.3))
			self.seq_hit:Join(self.pai3.transform:DOMove(self.pai3_orign_pos,0.3))
			self.seq_hit:Join(self.pai4.transform:DOMove(self.pai4_orign_pos,0.3))
			self.seq_hit:Join(self.icon_and_hp.transform:DOMove(self.orign_pos,0.3))
			self.seq_hit:AppendInterval(0.5)
			self.seq_hit:AppendCallback(function ()
				self.LWZB_huanrao_03.gameObject:SetActive(false)
			end)
		end
	end
end

function C:HitTweenKill()
	if self.seq_hit then
		self.seq_hit:Kill()
		self.seq_hit = nil
	end
end

--3.0
function C:RefreshZhu()
	if M.GetCurStatus() and M.GetCurStatus() ~= M.Model_Status.game or not M.GetCurStatus() then
		return
	end
	local all_info = M.GetAllInfo()
	if all_info then
		local ss_data = all_info.game_data.monster_pai
		local num = ss_data[self.index].pai_data
		for i=1,5 do
			self["pai"..i.."_img"].sprite = GetTexture("lwzb_imgf_"..LWZBManager.TranslatePai_New(num[i]))
		end
	end
end

function C:RefreshLongZ()
	if M.GetCurStatus() and M.GetCurStatus() ~= M.Model_Status.game or not M.GetCurStatus() then
		return
	end
	local state = M.GetStageStatusOrder()
	local all_info = M.GetAllInfo()
	if all_info and state then
		local ss_data = all_info.game_data.monster_pai
		if state.Stage == 1 then
			if state.Status == "Tips" then
			elseif state.Status == "StoreUpTheStrength" then
				if state.Order >= self.index then
					if LWZBManager.CheckIsMultipleOfTen_New(ss_data[self.index].pai_data,2,4) then
						self.type_new_img.gameObject:SetActive(true)
						self.type_new_img.sprite = GetTexture("lwzb_iocn_lh")
						self.type_new_img.transform.localScale = Vector3.one * 1.4
						for i=2,4 do
							self["pai"..i].gameObject:SetActive(false)
						end
					else
						self.type_new_img.gameObject:SetActive(false)
						for i=2,4 do
							self["pai"..i].gameObject:SetActive(true)
						end
					end
				else
					self.type_new_img.gameObject:SetActive(false)
					for i=1,5 do
						self["pai"..i].gameObject:SetActive(false)
					end
				end
			elseif state.Status == "Fight" then
				if LWZBManager.CheckIsMultipleOfTen_New(ss_data[self.index].pai_data,2,4) then
					self.type_new_img.gameObject:SetActive(true)
					self.type_new_img.sprite = GetTexture("lwzb_iocn_lh")
					self.type_new_img.transform.localScale = Vector3.one * 1.4
					for i=2,4 do
						self["pai"..i].gameObject:SetActive(false)
					end
				else
					self.type_new_img.gameObject:SetActive(false)
					for i=2,4 do
						self["pai"..i].gameObject:SetActive(true)
					end
				end
			end
		elseif state.Stage == 2 then
			if state.Status == "Tips" then
				if state.Order >= self.index then
					self.type_new_img.gameObject:SetActive(false)
					for i=1,5 do
						self["pai"..i].gameObject:SetActive(false)
					end
				else
					if LWZBManager.CheckIsMultipleOfTen_New(ss_data[self.index].pai_data,2,4) then
						self.type_new_img.gameObject:SetActive(true)
						self.type_new_img.sprite = GetTexture("lwzb_iocn_lh")
						self.type_new_img.transform.localScale = Vector3.one * 1.4
						for i=2,4 do
							self["pai"..i].gameObject:SetActive(false)
						end
					else
						self.type_new_img.gameObject:SetActive(false)
						for i=2,4 do
							self["pai"..i].gameObject:SetActive(true)
						end
					end
				end
			elseif state.Status == "StoreUpTheStrength" then
				dump({order = state.Order,index = self.index},"<color=yellow><size=15>++++++++++7777777777777++++++++++</size></color>")
				if state.Order >= self.index then
					self.type_new_img.gameObject:SetActive(true)
					self.type_new_img.transform.localPosition = Vector3.New(0,6,0)
					self:CheckTypeNewImgPosition()
					self.type_new_img.sprite = GetTexture(LWZBManager.CheckPaiType_New(ss_data[self.index].pai_type))
					self.type_new_img:SetNativeSize()
					for i=1,5 do
						self["pai"..i].gameObject:SetActive(false)
					end
				else
					if LWZBManager.CheckIsMultipleOfTen_New(ss_data[self.index].pai_data,2,4) then
						self.type_new_img.gameObject:SetActive(true)
						self.type_new_img.sprite = GetTexture("lwzb_iocn_lh")
						self.type_new_img.transform.localScale = Vector3.one * 1.4
						for i=2,4 do
							self["pai"..i].gameObject:SetActive(false)
						end
					else
						self.type_new_img.gameObject:SetActive(false)
						for i=2,4 do
							self["pai"..i].gameObject:SetActive(true)
						end
					end
				end
			elseif state.Status == "Fight" then
				self.type_new_img.gameObject:SetActive(false)
				for i=1,5 do
					self["pai"..i].gameObject:SetActive(false)
				end
			end
		end
		self.type_new_img:SetNativeSize()
	end
end

--3.0
function C:RefreshHP_lw()
	--dump(M.GetCurStatus(),"<color=yellow><size=15>++++++++++ M.GetCurStatus()++++++++++</size></color>")
	if M.GetCurStatus() and M.GetCurStatus() ~= M.Model_Status.game or not M.GetCurStatus() then
		return
	end
	local state = M.GetStageStatusOrder()
	if state then
		local all_info = M.GetAllInfo()
		local ss_pai_type = all_info.game_data.monster_pai[self.index].pai_type
		local lw_pai_type = all_info.game_data.long_wang_pai.pai_type
		local is_win = self.panelSelf:GetSSWin(self.index)
		--dump({index = self.index,Status = state.Status,Stage = state.Stage,now_Stage = Stage},"<color=red><size=15>++++++++++RefreshHP++++++++++</size></color>")
		if state.Stage == 1 then
			if state.Status == "Tips" then
			elseif state.Status == "StoreUpTheStrength" then
			elseif state.Status == "Fight" then
				if state.Order >= self.index then
					if ss_pai_type > lw_pai_type then
						Event.Brocast("lwzb_ss_fight_lw_msg",0.2)
					elseif ss_pai_type < lw_pai_type then
						Event.Brocast("lwzb_ss_fight_lw_msg",nil)
					else
						--几率命中
						local r = M.GetRandomInMap(1,self.index + 4)
						if r < 50 then
							Event.Brocast("lwzb_ss_fight_lw_msg",nil)
						else
							Event.Brocast("lwzb_ss_fight_lw_msg",0.2)
						end
					end
				end
			end
		elseif state.Stage == 2 then
			if state.Status == "Tips" then
				if ss_pai_type > lw_pai_type then
					Event.Brocast("lwzb_ss_fight_lw_msg",0.2)
				elseif ss_pai_type < lw_pai_type then
				else
					--几率命中
					local r = M.GetRandomInMap(1,self.index + 4)
					if r < 50 then
					else
						Event.Brocast("lwzb_ss_fight_lw_msg",0.2)
					end
				end
			elseif state.Status == "StoreUpTheStrength" then
				if ss_pai_type > lw_pai_type then
					Event.Brocast("lwzb_ss_fight_lw_msg",0.2)
				elseif ss_pai_type < lw_pai_type then
				else
					--几率命中
					local r = M.GetRandomInMap(1,self.index + 4)
					if r < 50 then
					else
						Event.Brocast("lwzb_ss_fight_lw_msg",0.2)
					end
				end
			end
		end
	end
end

function C:RefreshHP_self()
	if M.GetCurStatus() and M.GetCurStatus() ~= M.Model_Status.game or not M.GetCurStatus() then return end
	local state = M.GetStageStatusOrder()
	local all_info = M.GetAllInfo()
	if state and all_info then
		local ss_pai_type = all_info.game_data.monster_pai[self.index].pai_type
		local lw_pai_type = all_info.game_data.long_wang_pai.pai_type
		local is_win = self.panelSelf:GetSSWin(self.index)
		local pre_gray_name
		if self.index == 1 then
			pre_gray_name = "LWZB_shayu_gray"
		elseif self.index == 2 then
			pre_gray_name = "LWZB_jinchan_gray"
		elseif self.index == 3 then
			pre_gray_name = "LWZB_binggui_gray"
		elseif self.index == 4 then
			pre_gray_name = "LWZB_eryu_gray"
		end
		if state.Stage == 2 and state.Status == "Fight" then
			if is_win == 1 then
				self.pre.gameObject:SetActive(true)
				local x = ss_pai_type - lw_pai_type
				self.slider.value = x / 20 + 0.1
			else
				if IsEquals(self.pre_gray) then
					destroy(self.pre_gray)
				end
				self.pre_gray = newObject(pre_gray_name, self.icon_img.transform)
				self.pre.gameObject:SetActive(false)
				self.slider.value = 0
			end
			self:WinTween()
		end
	end
end


function C:CheckTypeNewImgPosition()
	local all_info = M.GetAllInfo()
	if all_info then
		local ss_data = all_info.game_data.monster_pai
		if ss_data then
			local ss_type =	all_info.game_data.monster_pai[self.index].pai_type
			if ss_type < 11 then
				self.type_new_img.transform.localScale = Vector3.one * 1.5
			else
				self.type_new_img.transform.localScale = Vector3.one
			end
		end
	end
end
