-- 创建时间:2020-05-13
-- Panel:ActBy3dSzwgPanel
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

ActBy3dSzwgPanel = basefunc.class()
local C = ActBy3dSzwgPanel
C.name = "ActBy3dSzwgPanel"

local SzwgState = {
	SS_wait = "SS_wait",--等待
	SS_bet = "SS_bet",--下注
	SS_betting = "SS_betting",--下注中
	SS_settlement = "SS_settlement",--结算
	SS_isWin = "SS_isWin",--押赢了
	SS_isLose = "SS_isLose",--押输了
}

local SzwgTalk = {"押注和,奖励可翻<color=#FDA030>6倍</color>哦!","搏一搏,单车变<color=#FDA030>摩托</color>!","买定离手,押中奖励<color=#FDA030>翻倍</color>哦!","不要怂,秒变<color=#FDA030>土豪</color>在此一举!","押错，<color=#FDA030>返还50%押注金</color>"}
function C.Create(score)
	return C.New(score)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["nor_fishing_touzi_stake_response"] = basefunc.handler(self, self.RefreshSettlement)
    self.lister["nor_fishing_touzi_get_score_response"] = basefunc.handler(self, self.on_nor_fishing_touzi_get_score)
    self.lister["ActBySzwg_on_backgroundReturn_msg"] = basefunc.handler(self,self.on_backgroundReturn_msg)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	GameComAnimTool.stop_number_change_anim(self.anim_tab)
	if self.cx_seq then
		self.cx_seq:Kill()
		self.cx_seq = nil
	end
	self:CloseJingBi()
	self:KillSeq()
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:ctor(score)
	self.score = score
	local parent = GameObject.Find("Canvas/LayerLv3").transform
	local obj = newObject("act_by3d_szwg_panel", parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
		
	self.cur_state = SzwgState.SS_wait
	self.guide_index = 1
	self.bet_countdown = 15
	self.win_or_lose = "none"
	self.bet_btn_pos_list = {}
	self.bet_btn_pos_list[#self.bet_btn_pos_list + 1] = self.bet1_btn.transform.localPosition
	self.bet_btn_pos_list[#self.bet_btn_pos_list + 1] = self.bet2_btn.transform.localPosition
	self.bet_btn_pos_list[#self.bet_btn_pos_list + 1] = self.bet3_btn.transform.localPosition
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	self.bet1_btn.onClick:AddListener(function()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        self:OnBetClick(1)
    end)
    self.bet2_btn.onClick:AddListener(function()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        self:OnBetClick(2)
    end)
    self.bet3_btn.onClick:AddListener(function()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        self:OnBetClick(3)
    end)

    self.get_btn.onClick:AddListener(function()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        self:OnGetClick()
    end)
    self.help_btn.onClick:AddListener(function()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        self:OnHelpClick()
    end)
    self.finger_btn.onClick:AddListener(function()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        self:OnBetClick(1)
    end)
    
   	if PlayerPrefs.GetInt(MainModel.UserInfo.user_id.."Szwg") == 0 then
   		PlayerPrefs.SetInt(MainModel.UserInfo.user_id.."Szwg",os.time())
   	end
	self.gny_0022_SZ_prefab = GameObject.Instantiate(GetPrefab("gny_0022_SZ_prefab"), self.root)
	self.gny_0022_SZ_prefab.transform.localPosition = Vector3.New(0,120,-200)
	local sz_tran = self.gny_0022_SZ_prefab.transform
	self.gny_anim = sz_tran:GetComponent("Animator")
	self.saizi_node1 = sz_tran:Find("gny_0022_SZ 1/Bone004/gny_022_UISZW1/gny_022_UISZW")
	self.saizi_node2 = sz_tran:Find("gny_0022_SZ 1/Bone005/gny_022_UISZW2/gny_022_UISZW 1")

	self.root.transform.localScale = Vector3.zero
	self.cx_seq = DoTweenSequence.Create()
	self.cx_seq:Append(self.root.transform:DOScale(1, 1))
	self.cx_seq:OnKill(function ()
		self.cx_seq = nil
		self.gny_anim:Play("start",-1,0)
		self:MyRefresh()
	end)
end

function C:MyRefresh()
	self.myscore_txt.text = self.score
	self:SzwgTalking()
	self:RefreshWait()
end
function C:RefreshWait()
	local cur_s = self.cur_state
	self.cur_state = SzwgState.SS_wait
	self.guidehint1.gameObject:SetActive(false)
	if self.guide_index == 1 and PlayerPrefs.GetInt(MainModel.UserInfo.user_id.."Szwg") == 0 then
		self.guidehint1.gameObject:SetActive(true)
	end
	self.seq = DoTweenSequence.Create()
	if cur_s == SzwgState.SS_settlement then
		self.gny_anim:Play("start",-1,0)
		self.seq:AppendInterval(0.3)
	else
		self.seq:AppendInterval(2)
	end
	self.seq:AppendCallback(function ()
		self.guidehint1.gameObject:SetActive(false)
		self.gny_anim:Play("skill",-1,0)--摇动骰子 1.5s
	end)
	self.seq:AppendInterval(2)
	self.seq:OnKill(function ()
		self.guide_index = self.guide_index + 1
		self.seq = nil
		self:RefreshBet()
	end)
end
function C:RefreshBet()
	self:BetCountDown(true)
	self.cur_state = SzwgState.SS_bet
	dump("<color=white>BBBBBBBBBBBBBBBBBBBBBBBBBet</color>")
	self.bet_hint.gameObject:SetActive(true)
	self.guidehint2.gameObject:SetActive(false)
	if self.guide_index == 2 and PlayerPrefs.GetInt(MainModel.UserInfo.user_id.."Szwg") == 0 then
		self:BetHint(true,nil)
		self.guidehint2.gameObject:SetActive(true)
	else
		self:BetHint(true,1)
		self:Tips(nil,"szwg_imgf_ksyz",1,Vector3.New(0,28.4,-1100))
	end
end
function C:RefreshSettlement(_, data)
	dump(data,"<color>++++++++++++++++++++nor_fishing_touzi_stake_response+++++++++++++++++</color>")
    if data.result ~= 0 then
        HintPanel.ErrorMsg(data.result)
        self:MyExit()
        return
    end

	local is_win
	if data.stake == data.result_stake then
		self.win_or_lose = SzwgState.SS_isWin
		is_win = true
		if data.stake == 2 then
			self.score = self.score * 6
		else
			self.score = self.score * 2
		end
	else
		self.win_or_lose = SzwgState.SS_isLose
		is_win = false
	end
	local sz1
	local sz2
	if data.result_stake == 2 then
		sz1 = math.random(1, 6)
		sz2 = 7 - sz1
	elseif data.result_stake == 1 then
		sz1 = math.random(1, 5)
		sz2 = math.random(1, 6-sz1)
	else
		sz1 = math.random(2, 6)
		sz2 = math.random(8-sz1, 6)
	end

	self.saizi_node1.localRotation = self:get_dot_num_r(sz1)
	self.saizi_node2.localRotation = self:get_dot_num_r(sz2)
	self.cur_state = SzwgState.SS_settlement

	self.gny_anim:Play("end",-1,0)--打开筛盅	
	self.seq = DoTweenSequence.Create()
	self.seq:AppendInterval(1)
	self.seq:AppendCallback(function ()
		self.gny_anim:Play("fly_UI",-1,0)--点数展示
		local text = sz1 + sz2
		if text <= 6 and text >= 2 then
			text = text.."点小"
		elseif text == 7 then
			text = text.."点中"
		elseif text >= 8 and text <= 12 then
			text = text.."点大"
		end
		self:Tips(text,nil,3,Vector3.New(0,-50,-1100))
	end)
	self.seq:AppendInterval(3)
	if self.guide_index == 3 and PlayerPrefs.GetInt(MainModel.UserInfo.user_id.."Szwg") == 0 then
		self.seq:AppendCallback(function ()
			self.gny_anim:Play("end_UI",-1,0)--点数展示结束
			self.guidehint3.gameObject:SetActive(true)
		end)
		self.seq:AppendInterval(2)
	else
		self.seq:AppendCallback(function ()
			self.gny_anim:Play("end_UI",-1,0)--点数展示结束
		end)
		self.seq:AppendInterval(0.5)
	end
	self.seq:OnKill(function ()
		self.guidehint3.gameObject:SetActive(false)
		self.guide_index = self.guide_index + 1
		self.seq = nil
		if is_win then
			self:CreateJingBi("Win",self.bet_btn_pos_list[self.tag],self.myscore_img.transform.localPosition)
			--self:GameWin()
		else
			self:GameLose()
		end
	end)
end

function C:KillSeq()
	if self.seq then
		self.seq:Kill()
		self.seq = nil
	end
	if self.seq1 then
		self.seq1:Kill()
		self.seq1 = nil 
	end
	if self.seq2 then
		self.seq2:Kill()
		self.seq2 = nil
	end
	if self.seq3 then
		self.seq3:Kill()
		self.seq3 = nil
	end
	if self.seq4 then
		self.seq4:Kill()
		self.seq4 = nil
	end	
	if self.seq5 then
		self.seq5:Kill()
		self.seq5 = nil
	end	
	if self.seq6 then
		self.seq6:Kill()
		self.seq6 = nil
	end
	if self.seq7 then
		self.seq7:Kill()
		self.seq7 = nil
	end
end
-- 下注
function C:OnBetClick(tag)
	if self.cur_state == SzwgState.SS_bet then
		self.cur_state = SzwgState.SS_betting
		if self.guidehint2.gameObject.activeSelf then
			self.guidehint2.gameObject:SetActive(false)
			self.guide_index = self.guide_index + 1
		end
		self.tag = tag
		self:BetCountDown(false)
		self.bet_countdown_txt.gameObject:SetActive(false)
		self.bet_countdown = 15
		self:CreateJingBi("Bet",self.myscore_img.transform.localPosition,self.bet_btn_pos_list[self.tag])
		self:BetHint(false,nil)
		self.bet_hint.gameObject:SetActive(false)		
	end
end

function C:get_dot_num_r(dot_num)
	local sz = dot_num
	local r = math.random(1, 4)
	r = r * 90
	if sz == 1 then
		return Quaternion:SetEuler(0, 90, r)
	elseif sz == 2 then
		return Quaternion:SetEuler(r, 0, 90)
	elseif sz == 3 then
		return Quaternion:SetEuler(r, 0, 0)
	elseif sz == 4 then
		return Quaternion:SetEuler(r, 180, 0)
	elseif sz == 5 then
		return Quaternion:SetEuler(r, 0, -90)
	else
		return Quaternion:SetEuler(0, -90, r)
	end
end
function C:GameWin()
	self.seq = DoTweenSequence.Create()
	self.seq:AppendInterval(1)
	self.seq:OnKill(function ()
		self:RefreshWait()
	end)
end
function C:GameLose()
    self:Tips("游戏结束", nil, 1, Vector3.New(0, 28.4, -1100))
    self.seq = DoTweenSequence.Create()
    self.seq:AppendInterval(1)
    self.seq:OnKill(function()
        --FishingAnimManager.PlayBY3D_HDY_FX_MY(self.score * 0.5, 34)
        self:ShowGetAnim(self.score * 0.5)

        self:MyExit()
    end)
end

function C:OnGetClick()
	if self.win_or_lose ~= SzwgState.SS_isLose then
	--and   self.cur_state == SzwgState.SS_bet then
		Network.SendRequest("nor_fishing_touzi_get_score", nil, "")
	end
end

function C:on_nor_fishing_touzi_get_score(_, data)
	dump(data,"<color>+++++++++++++++nor_fishing_touzi_get_score_response++++++++++++++</color>")
	if data.result ~= 0 then
        HintPanel.ErrorMsg(data.result)
        self:MyExit()
        return
	end
	
	self:ShowGetAnim(self.score)
	self:MyExit()
end

function C:ShowGetAnim(_score)
	local parent = FishingLogic.GetPanel().LayerLv2
	local data = { seat_num = 1,score = _score}
	--FishingAnimManager.PlayBY3D_HDY_FX_MY(self.score, 34)
	ExtendSoundManager.PlaySound(audio_config.by.bgm_by_jiangli6.audio_name)
    	FishingAnimManager.PlayMultiplyingPower200(parent, Vector2.zero, Vector2.zero, _score, function ()
    		Event.Brocast("ui_gold_fly_finish_msg", data)
		end,1,nil)
end

--下注倒计时
function C:BetCountDown(b)
	if self.seq1 then
		self.seq1:Kill()
		self.seq1 = nil
	end
	if b then
		self.seq1 = DoTweenSequence.Create()
		self.bet_countdown_txt.transform.localScale = Vector3.New(7,7,1)
		self.seq1:Append(self.bet_countdown_txt.transform:DOScale(Vector3.New(3.5,3.5,1),1))
		self.seq1:AppendCallback(function ()
			if not self.bet_countdown_txt.gameObject.activeSelf and self.bet_countdown <= 11 then
				self.bet_countdown_txt.gameObject:SetActive(true)
			end
			self.bet_countdown = self.bet_countdown - 1
			self.bet_countdown_txt.text = self.bet_countdown
			if self.bet_countdown > 0 then	
				self:BetCountDown(true)
			else
				if PlayerPrefs.GetInt(MainModel.UserInfo.user_id.."Szwg") == 0 then
					self:OnBetClick(1)
				else	
					local r = math.random(1, 3)
					self:OnBetClick(r)	
				end		
			end
		end)
		self.seq1:OnForceKill(function (force_kill)
			if not force_kill then
				print(debug.traceback())
			end
		end)
	end
end


--提示字(text=提示内容(文字形式),img=提示内容(图片形式),second=提示停留的秒数,pos=位置)
function C:Tips(text,img,second,pos)
	self.tips.gameObject:SetActive(true)
	if pos then
		self.tips.transform.localPosition = pos
	end
	if text then
		self.tips_txt.gameObject:SetActive(true)
		self.tips_img.gameObject:SetActive(false)
		self.tips_txt.text = text
	end
	if img then
		self.tips_txt.gameObject:SetActive(false)
		self.tips_img.gameObject:SetActive(true)
		self.tips_img.sprite = GetTexture(img)
	end
	self.seq2 = DoTweenSequence.Create()
	self.seq2:AppendInterval(second)
	self.seq2:AppendCallback(function ()
		self.tips.gameObject:SetActive(false)
		self.seq2:Kill()
		self.seq2 = nil
	end)
end

--创建金币和相应动画(类型为bet时,start_pos为玩家金币UI的位置,end_pos为押注的档位位置;类型为win时,start_pos为押注的档位位置,end_pos为玩家金币UI的位置)
function C:CreateJingBi(type,start_pos,end_pos)
	self.seq3 = DoTweenSequence.Create()
	if type == "Bet" then
		self:CloseJingBi()
		local length_min = end_pos.x - 100 
		local length_max = end_pos.x + 100
		local hight_min = end_pos.y - 100
		local hight_max = end_pos.y + 100
		for i=1,30 do
			local x = math.random(length_min, length_max)
			local y = math.random(hight_min, hight_max)
			local pre = GameObject.Instantiate(self.jingbi_img,self.jingbi_node.transform)
			pre.transform.localPosition = start_pos
			pre.gameObject:SetActive(true)
			self.seq3:Insert(i/30,pre.transform:DOLocalMove(Vector3.New(x,y,0),0.3))
			self.spawn_cell_list[#self.spawn_cell_list + 1] = pre
			self.seq3:AppendCallback(function ()
				if i == 30 then
					self.myscore_txt.text = 0
					Network.SendRequest("nor_fishing_touzi_stake", {stake = self.tag}, "")	
					self.seq3:Kill()
					self.seq3 = nil
				end
			end)
		end
	elseif type == "Win" then
		local fun = function ()
			self:RollingDigit(0.3)
			self.seq4 = DoTweenSequence.Create()
			for i=1,#self.spawn_cell_list do
				self.seq4:Insert(i/50,self.spawn_cell_list[i].transform:DOLocalMove(end_pos,0.3))
				self.seq4:AppendCallback(function ()
					self.spawn_cell_list[i].gameObject:SetActive(false)
					if i == #self.spawn_cell_list then
						self:CloseJingBi()
						self:GameWin()
						self.seq4:Kill()
						self.seq4 = nil
					end 
				end)
			end
		end
		local length_min = start_pos.x - 100 
		local length_max = start_pos.x + 100
		local hight_min = start_pos.y - 100
		local hight_max = start_pos.y + 100
		for i=1,20 do
			local x = math.random(length_min, length_max)
			local y = math.random(hight_min, hight_max)
			local pre = GameObject.Instantiate(self.jingbi_img,self.jingbi_node.transform)
			pre.transform.localPosition = Vector3.New(0,110,0)
			pre.gameObject:SetActive(true)
			self.seq3:Insert(i/20,pre.transform:DOLocalMove(Vector3.New(x,y,0),0.3))
			self.spawn_cell_list[#self.spawn_cell_list + 1] = pre
			self.seq3:AppendCallback(function ()
				if i == 20 then
					fun()
					self.seq3:Kill()
					self.seq3 = nil
				end
			end)
		end
	end
end

function C:CloseJingBi()
	if self.spawn_cell_list then
		for k,v in ipairs(self.spawn_cell_list) do
			Destroy(v.gameObject)
		end
	end
	self.spawn_cell_list = {}
end

--滚动数字效果(延迟second秒开播)
function C:RollingDigit(second)
	GameComAnimTool.stop_number_change_anim(self.anim_tab)
	self.seq5 = DoTweenSequence.Create()
	self.seq5:AppendInterval(second)
	self.seq5:OnKill(function ()
		self.anim_tab = GameComAnimTool.play_number_change_anim(self.myscore_txt, 0, self.score, 1, function ()
		
		end, function ()
			
		end)
	end)
end

function C:OnHelpClick()
	if self.help_panel.gameObject.activeSelf then
		self.help_panel.gameObject:SetActive(false)
	else
		self.help_panel.gameObject:SetActive(true)
	end
end

--三个押注框的闪烁(延迟second后开播)
function C:BetHint(b,second)
	if self.seq6 then
		self.seq6:Kill()
		self.seq6 = nil
	end
	self.bet_hint.transform:GetComponent("CanvasGroup").alpha = 1
	if b then
		self.seq6 = DoTweenSequence.Create()
		if second then
			self.seq6:AppendInterval(second)
		end
		self.seq6:Append(self.bet_hint.transform:GetComponent("CanvasGroup"):DOFade(0,1):SetLoops(15,DG.Tweening.LoopType.Yoyo))
	end
end

function C:on_backgroundReturn_msg()
	self:MyExit()
end

--骰子乌龟说话
function C:SzwgTalking()
	self.seq7 = DoTweenSequence.Create()
	local r = math.random(1,#SzwgTalk)
	while SzwgTalk[r] == self.talk_txt.text do
		r = math.random(1,#SzwgTalk)
	end
	self.talk_txt.text = SzwgTalk[r]
	local r = math.random(8,10)
	self.seq7:AppendInterval(r)
	self.seq7:AppendCallback(function ()
		self:SzwgTalking()
	end)
end
