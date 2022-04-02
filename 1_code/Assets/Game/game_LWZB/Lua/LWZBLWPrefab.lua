-- 创建时间:2020-08-27
-- Panel:LWZBLWPrefab
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

LWZBLWPrefab = basefunc.class()
local C = LWZBLWPrefab
C.name = "LWZBLWPrefab"
local M = LWZBModel

function C.Create(parent,panelSelf)
	return C.New(parent,panelSelf)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["ExitScene"] = basefunc.handler(self,self.MyExit)
    self.lister["lwzb_do_fly_jb_msg"] = basefunc.handler(self,self.on_lwzb_do_fly_jb_msg)
    self.lister["lwzb_refresh_lw_jb_msg"] = basefunc.handler(self,self.on_lwzb_refresh_lw_jb_msg)

    self.lister["lwzb_gaming_anim_msg"] = basefunc.handler(self,self.on_lwzb_gaming_anim_msg)
    self.lister["lwzb_gaming_refresh_msg"] = basefunc.handler(self,self.on_lwzb_gaming_refresh_msg)
    self.lister["lwzb_in_gaming_anim_init_msg"] = basefunc.handler(self,self.on_lwzb_in_gaming_anim_init_msg)
    self.lister["lwzb_out_gaming_anim_init_msg"] = basefunc.handler(self,self.on_lwzb_out_gaming_anim_init_msg)
    self.lister["lwzb_ss_fight_lw_msg"] = basefunc.handler(self,self.on_lwzb_ss_fight_lw_msg)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	self:StopDotTimer()
	self:KillTween()
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

function C:ctor(parent,panelSelf)
	self.panelSelf = panelSelf
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self.type_bg_canvas = self.type_bg.transform:GetComponent("CanvasGroup")
	self.slider = self.Slider.transform:GetComponent("Slider")
	self.long_ani = self.transform:Find("long").transform:GetComponent("Animator")

	self.dun_dian = self.LWZB_LW_dun.transform:Find("shandian")
	self.img1 = self.transform:Find("long/@icon_img1/img1").transform:GetComponent("Image")
	self.img3 = self.transform:Find("long/@icon_img3/img3").transform:GetComponent("Image")
	self.img5 = self.transform:Find("long/st/img5").transform:GetComponent("Image")
	self.img502 = self.transform:Find("long/st/img5/img5_02").transform:GetComponent("Image")
	self.img6 = self.transform:Find("long/st/tou/img6").transform:GetComponent("Image")
	self.img61 = self.transform:Find("long/st/tou/img6/img6 (1)").transform:GetComponent("Image")
	self.img4 = self.transform:Find("long/@icon_img4/img4").transform:GetComponent("Image")
	self.img41 = self.transform:Find("long/@icon_img4/img4/img4 (1)").transform:GetComponent("Image")
	self.img2 = self.transform:Find("long/@icon_img2/img2").transform:GetComponent("Image")
	self.img21 = self.transform:Find("long/@icon_img2/img2/img2 (1)").transform:GetComponent("Image")

	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
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
end

function C:MyRefresh()
	self:RefreshHP_ss()
	self:RefreshHP_self()
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
	Event.Brocast("lwzb_lw_fp_finish_msg", {index=self.index})
end

function C:StopDownTime()
	if self.down_time then
		self.down_time:Stop()
		self.down_time = nil
	end
end

function C:GetSJPos()
	return self.transform.position
end

-- 开始比牌
function C:PlayBP()
	GameComAnimTool.PlayShowAndHideAndCall(self.transform, "LWZB_pai_fan", self.hint_pai.transform.position, 0.7, 0.3, function ()
		for i=1,5 do
			self["pai"..i].gameObject:SetActive(true)
		end	
		self.rate_txt.gameObject:SetActive(true)
	end)
	local seq = DoTweenSequence.Create()
	seq:AppendInterval(0.2)
	seq:OnKill(function ()
		self:ShowPX()
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

function C:RefreshPai(tab)
	for i=1,#tab do
		self["pai"..i.."_img"].sprite = GetTexture("lwzb_imgf_"..LWZBManager.TranslatePai(tab[i]))
	end
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

--飞金币
function C:on_lwzb_do_fly_jb_msg(ss_Pos,ss_iswin,index)
	if ss_iswin == 1 then--龙王输钱(从"龙王"身上飞出金币到"胜利的神兽"身上)
		LWZBManager.PlayTYJBFly(self.transform, "lwzb_jb_fly_prefab", self.transform.position, ss_Pos, {type = 1},nil,nil,nil,function ()
			Event.Brocast("lwzb_jb_fly_to_player_btn_msg",ss_Pos,index)
		end)
	elseif ss_iswin == 0 then--龙王赢钱(从"失败的神兽"身上飞出金币到"龙王"身上)
		LWZBManager.PlayTYJBFly(self.transform, "lwzb_jb_fly_prefab", ss_Pos, self.transform.position, {type = 2},nil,nil,nil,function ()
			
		end)
	end
end

function C:RefreshLWInfo(data)
	dump(data,"------------------------lw_data------------------------------")
	if data then
		self.lw_round_txt.text = "局数:  "..data.remain_num
		if data.player_info.player_id == "sys_dragon" then
			self.lw_money_txt.text = "保密"
		else
			if M.GetCurStatus() == M.Model_Status.game and self.panelSelf:CheckLWIsI() then
				self.lw_money_txt.text = self.panelSelf:GetCurMyMoney()
			else
				self.lw_money_txt.text = StringHelper.ToCash(data.jing_bi)
			end
		end
		dump(data.player_info.head_image,"------------------------head_image------------------------------")
		URLImageManager.UpdateHeadImage(data.player_info.head_image, self.lw_head_img)
		self.lw_name_txt.text = data.player_info.player_name
		if IsEquals(self.lw_vip_txt) then
			if data.player_info.vip_level then
				self.lw_vip_txt.gameObject:SetActive(true)
				VIPManager.set_vip_text(self.lw_vip_txt,data.player_info.vip_level)
			else
				self.lw_vip_txt.gameObject:SetActive(false)
			end
		end
	end
end

function C:SetActiveInit()
	for i = 1, 5 do
		self["pai"..i].gameObject:SetActive(false)
	end
	self.rate_txt.gameObject:SetActive(false)
	self.type_txt.gameObject:SetActive(false)
	self.type_img.gameObject:SetActive(false)
	self.type_bg_canvas.alpha = 0
end

--展示牌型时的动画
function C:TypeDotween()
	self:KillTween()
	self.seq = DoTweenSequence.Create()
	self.type_bg.transform.localPosition = Vector3.New(172,116,0)
	self:CheckTypePositionAndScale()
	self.seq:Append(self.type_bg.transform:DOLocalMoveX(0, 0.6))
	self.seq:Join(self.type_bg_canvas:DOFade(1, 0.4))
	self.seq:AppendInterval(0.5)
	self.seq:OnKill(function ()
		if LWZBManager.GetLwzbGuideOnOff() then
			if not self.onoff3 then
				self.onoff3 = true
				self.pai_btn.gameObject:SetActive(true)
				self.type_btn.gameObject:SetActive(true)
				self.rate_btn.gameObject:SetActive(true)
				Event.Brocast("lwzb_guide_check")
			end
		else
			Event.Brocast("lwzb_lw_fp_finish_msg", {index=self.index})
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
	if self.type > 11 then
		self.type_img.transform.localPosition = Vector3.New(0,20,0)
		self.type_img.transform.localScale = Vector3.New(0.7,0.7,1)
	elseif self.type == 11 then
		self.type_img.transform.localPosition = Vector3.New(0,26,0)
		self.type_img.transform.localScale = Vector3.New(1,1,1)
	else
		self.type_img.transform.localPosition = Vector3.New(0,0,0)
		self.type_txt.transform.localPosition = Vector3.New(0,0,0)
		self.type_img.transform.localScale = Vector3.New(1,1,1)
	end
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
	self.type_bg.transform.localPosition = Vector3.New(172,116,0)
	self:CheckTypePositionAndScale()
	self.type_bg.transform.localPosition = Vector3.New(0,self.type_bg.transform.localPosition.y,self.type_bg.transform.localPosition.z)
	self.type_bg_canvas.alpha = 1
end

function C:on_lwzb_refresh_lw_jb_msg()
	if M.GetCurStatus() == M.Model_Status.game and self.panelSelf:CheckLWIsI() then
		self.lw_money_txt.text = self.panelSelf:GetCurMyMoney()
	else
		self.lw_money_txt.text = StringHelper.ToCash(MainModel.UserInfo.jing_bi)
	end
end

function C:RefreshRate(rate)
	self.rate_txt.text = "x"..math.abs(rate)
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
	self.LWZB_LW_dun.gameObject:SetActive(false)
	self.LWZB_LW_dun_po.gameObject:SetActive(false)
	self:RefreshGray("live")
	self.longzhu_type_img.gameObject:SetActive(false)
	self.LWZB_huanrao_03.gameObject:SetActive(false)
	self.HP_end_count = 0
	self.fajiang_mark = nil
	self.dun_dian.gameObject:SetActive(false)
end

--战斗判定
function C:Fight()
	local all_info = M.GetAllInfo()
	local lw_pai_type = all_info.game_data.long_wang_pai.pai_type
	for i=1,#all_info.game_data.monster_pai do
		local ss_pai_type = all_info.game_data.monster_pai[i].pai_type
		if ss_pai_type > lw_pai_type then
			Event.Brocast("lwzb_lw_fight_ss_msg",0,i)
		elseif ss_pai_type < lw_pai_type then
			Event.Brocast("lwzb_lw_fight_ss_msg",0.8,i)
		else
			math.randomseed(tonumber(tostring(os.time()):reverse():sub(1, 7)) + i)
			local r = math.random(0,100)
			if r < 50 then
				Event.Brocast("lwzb_lw_fight_ss_msg",0,i)
			else
				Event.Brocast("lwzb_lw_fight_ss_msg",0.8,i)
			end
		end
	end
end

--战斗判定(第三轮)
function C:FightStandOff()
	self:StopDotTimer()
	self.LWZB_LW_dun.gameObject:SetActive(true) --龙王撑盾
	local all_info = M.GetAllInfo()
	local ss_data = all_info.game_data.monster_pai
	local state = M.GetStageStatusOrder()
	if state.Status == "Tips" then return end
	local lw_pai_type = all_info.game_data.long_wang_pai.pai_type
	self.temp = 0.001
	self.count = 0
	local will_die = false
	for i=1,4 do
		if ss_data[i].is_win == 1 then
			will_die = true
			break
		end
	end
	if will_die then
		self.temp = (self.slider.value) / 300
	end
	self.dot_timer = Timer.New(function ()
		self.slider.value = self.slider.value - self.temp
		self.count = self.count + 0.01
		if self.count >= 1.5 and not self.dun_dian.gameObject.activeSelf then
			self.dun_dian.gameObject:SetActive(true)
		end
		if self.count >= 3 or self.slider.value <= 0 then
			if self.slider.value <= 0 then
				self:RefreshGray("die")
				self.LWZB_LW_dun.gameObject:SetActive(false)
				self.LWZB_LW_dun_po.gameObject:SetActive(true)
				self.panelSelf:LWIsDie()
				self.longzhu_type_img.gameObject:SetActive(true)
				self:CheckLongZhuTypeScale()
				self.longzhu_type_img.sprite = GetTexture(LWZBManager.CheckPaiType_New(lw_pai_type))
				self.longzhu_type_img:SetNativeSize()
			end
			self:StopDotTimer()
		end
	end,0.01,-1,false)
	self.dot_timer:Start()
end

function C:IsEnd()
	local all_info = M.GetAllInfo()
	local lw_pai_type = all_info.game_data.long_wang_pai.pai_type
	self.longzhu_type_img.gameObject:SetActive(true)
	self:CheckLongZhuTypeScale()
	self.longzhu_type_img.sprite = GetTexture(LWZBManager.CheckPaiType_New(lw_pai_type))
	self.longzhu_type_img:SetNativeSize()
	self:StopDotTimer()
end

function C:StopDotTimer()
	if self.dot_timer then
		self.dot_timer:Stop()
		self.dot_timer = nil
	end
end


function C:on_lwzb_ss_fight_lw_msg(num,b)
	if num then
		if num == 0 then
			--miss
			GameComAnimTool.PlayMoveAndHideFX(self.transform,"lwzb_miss",self.transform.position,self.transform.position + Vector3.New(0,100,0),0.1,0.2)
		else
			self.slider.value = self.slider.value - num
			self.long_ani:Play("lwzb_long_hit",-1,0)
			if b then
				GameComAnimTool.PlayMoveAndHideFX(self.transform,"lwzb_boom",self.transform.position,self.transform.position + Vector3.New(0,100,0),0.5,0.2)
			end
		end
	end
end

function C:RefreshHP_ss()
	if M.GetCurStatus() and M.GetCurStatus() ~= M.Model_Status.game or not M.GetCurStatus() then
		return
	end
	local state = M.GetStageStatusOrder()
	if state then
		local all_info = M.GetAllInfo()
		local ss_data = all_info.game_data.monster_pai
		local lw_pai_type = all_info.game_data.long_wang_pai.pai_type
		if state.Stage == 1 then
			if state.Status == "Tips" then
			elseif state.Status == "StoreUpTheStrength" then
			elseif state.Status == "Fight" then
				for j=1,#all_info.game_data.monster_pai do
					local ss_pai_type = all_info.game_data.monster_pai[j].pai_type
					if ss_pai_type < lw_pai_type then
						Event.Brocast("lwzb_lw_fight_ss_msg",0.8,j)
					elseif ss_pai_type > lw_pai_type then
						Event.Brocast("lwzb_lw_fight_ss_msg",nil,j)
					else
						--几率命中
						local r = M.GetRandomInMap(1,j)
						if r < 50 then
						else
							Event.Brocast("lwzb_lw_fight_ss_msg",0.8,j)
						end
					end
				end
			end
		elseif state.Stage == 2 then
			if state.Status == "Tips" then
				for j=1,#all_info.game_data.monster_pai do
					local ss_pai_type = all_info.game_data.monster_pai[j].pai_type
					if ss_pai_type < lw_pai_type then
						Event.Brocast("lwzb_lw_fight_ss_msg",0.8,j)
					elseif ss_pai_type > lw_pai_type then
						Event.Brocast("lwzb_lw_fight_ss_msg",nil,j)
					else
						--几率命中
						local r = M.GetRandomInMap(1,j)
						if r < 50 then
						else
							Event.Brocast("lwzb_lw_fight_ss_msg",0.8,j)
						end
					end
				end
			elseif state.Status == "StoreUpTheStrength" then
				for j=1,#all_info.game_data.monster_pai do
					local ss_pai_type = all_info.game_data.monster_pai[j].pai_type
					if ss_pai_type < lw_pai_type then
						Event.Brocast("lwzb_lw_fight_ss_msg",0.8,j)
					elseif ss_pai_type > lw_pai_type then
						Event.Brocast("lwzb_lw_fight_ss_msg",nil,j)
					else
						--几率命中
						local r = M.GetRandomInMap(1,j)
						if r < 50 then
						else
							Event.Brocast("lwzb_lw_fight_ss_msg",0.8,j)
						end
					end
				end
			elseif state.Status == "Fight" then
			end
		end
	end
end

function C:RefreshHP_self()
	if M.GetCurStatus() and M.GetCurStatus() ~= M.Model_Status.game or not M.GetCurStatus() then return end
	local state = M.GetStageStatusOrder()
	local all_info = M.GetAllInfo()
	if state and all_info then
		local lw_pai_type = all_info.game_data.long_wang_pai.pai_type
		local ss_data = all_info.game_data.monster_pai
		if state.Stage == 2 and state.Status == "Fight" then
			local will_die = false
			for i=1,4 do
				if ss_data[i].is_win == 1 then
					will_die = true
					break
				end
			end
			if will_die then
				self:RefreshGray("die")
				self.slider.value = 0
			else
				self.slider.value = 0.2
			end
			self.LWZB_LW_dun.gameObject:SetActive(false)
			self.longzhu_type_img.gameObject:SetActive(true)
			self:CheckLongZhuTypeScale()
			self.longzhu_type_img.sprite = GetTexture(LWZBManager.CheckPaiType_New(lw_pai_type))
			self.longzhu_type_img:SetNativeSize()
		end
	end
end

function C:RefreshGray(status)
	if status == "die" then
		self.img1.sprite = GetTexture("lwzb_long_hth_h")
		self.img3.sprite = GetTexture("lwzb_long_qth_h")
		self.img5.sprite = GetTexture("lwzb_long_st_h")
		self.img502.sprite = GetTexture("lwzb_long_st_h")
		self.img6.sprite = GetTexture("lwzb_long_tou_h")
		self.img61.sprite = GetTexture("lwzb_long_tou_h")
		self.img4.sprite = GetTexture("lwzb_long_qtq_h")
		self.img41.sprite = GetTexture("lwzb_long_qtq_h")
		self.img2.sprite = GetTexture("lwzb_long_htq_h")
		self.img21.sprite = GetTexture("lwzb_long_htq_h")
	elseif status == "live" then
		self.img1.sprite = GetTexture("lwzb_long_hth")
		self.img3.sprite = GetTexture("lwzb_long_qth")
		self.img5.sprite = GetTexture("lwzb_long_st")
		self.img502.sprite = GetTexture("lwzb_long_st")
		self.img6.sprite = GetTexture("lwzb_long_tou")
		self.img61.sprite = GetTexture("lwzb_long_tou")
		self.img4.sprite = GetTexture("lwzb_long_qtq")
		self.img41.sprite = GetTexture("lwzb_long_qtq")
		self.img2.sprite = GetTexture("lwzb_long_htq")
		self.img21.sprite = GetTexture("lwzb_long_htq")
	end
end

function C:LWFaJiang()
	if M.GetCurStatus() and M.GetCurStatus() ~= M.Model_Status.game or not M.GetCurStatus() then return end
	local all_info = M.GetAllInfo()
	local data = all_info.bet_data.my_bet_data
	local lw_pai_type = all_info.game_data.long_wang_pai.pai_type
	self.fajiang_mark = self.fajiang_mark or {true,true,true,true}
	for i=1,4 do
		if self.panelSelf:GetSSWin(i) == 1 then
			local num = (all_info.game_data.monster_pai[i].pai_type) * 2
			LWZBManager.PlayTYJBFly(self.transform, "lwzb_longzhu_fly_prefab", self.transform.position, self.panelSelf:GetSSPos(i), {type = 1,num = num,item_type = "longzhu"},nil,nil,nil,nil,0.6,function ()
				if data[i] > 0 and self.fajiang_mark and self.fajiang_mark[i] then
					self.fajiang_mark[i] = false
					dump(i,"<color=green><size=15>++++++++++iiiiiiiiiiiiiiiiiii++++++++++</size></color>")
					LWZBManager.PlayTYJBFly(self.transform, "lwzb_longzhu_fly_prefab", self.panelSelf:GetSSPos(i), self.panelSelf.jb.transform.position, {type = 2,num = num/2,item_type = "longzhu"},nil,nil,nil,function ()
					end)
				end
			end)
		end
	end	
end

--触发式表现_3.0
function C:on_lwzb_gaming_anim_msg()
	local state = M.GetStageStatusOrder()
	if state.Status ~= "Tips" and state.Order ~= 5 and state.Order ~= 0 then
		return
	end
	local all_info = M.GetAllInfo()
	local lw_data = all_info.game_data.long_wang_pai.pai_data
	self.Debugtype_txt.text = all_info.game_data.long_wang_pai.pai_type
	if state.Stage == 1 then
		if state.Status == "StoreUpTheStrength" then

		elseif state.Status == "Fight" then
			self.LWZB_huanrao_03.gameObject:SetActive(true)
			GameComAnimTool.PlayShowAndHideAndCall(self.transform,"LWZB_LW_gongji",self.transform.position,2,0.8,function ()
				self:Fight()
				self.LWZB_huanrao_03.gameObject:SetActive(false)
			end)
		end
	elseif state.Stage == 2 then
		if state.Status == "StoreUpTheStrength" then
		
		elseif state.Status == "Fight" then
			self:FightStandOff()
		end
	end
end

function C:CheckLongZhuTypeScale()
	local all_info = M.GetAllInfo()
	local lw_type =	all_info.game_data.long_wang_pai.pai_type
	if lw_type < 11 then
		self.longzhu_type_img.transform.localScale = Vector3.one * 1.5
	else
		self.longzhu_type_img.transform.localScale = Vector3.one
	end
end