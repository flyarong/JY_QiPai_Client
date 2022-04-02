-- 创建时间:2019-01-03

local basefunc = require "Game.Common.basefunc"

OperatorActivityCSPanel = basefunc.class()

local C = OperatorActivityCSPanel

C.name = "OperatorActivityCSPanel"
C.data = {}
local m_data = C.data
local GameStyle = {
	ddz = "ddz",
	mj = "mj"
}
local instance
function C.Create(parm)
	instance = C.New(parm)
	return instance
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
	self.lister = {}
	self.lister["ExitScene"] = basefunc.handler(self, self.OnExitScene)
	self.lister["activity_cs_share_close"] = basefunc.handler(self, self.activity_cs_share_close)
	--活动数据
	self.lister["activity_refresh_data_msg"] = basefunc.handler(self, self.activity_refresh_data_msg)
	--模式
	self.lister["logic_activity_fg_all_info"] = basefunc.handler(self, self.activity_fg_all_info)
	self.lister["logic_activity_fg_enter_room_msg"] = basefunc.handler(self, self.activity_fg_enter_room_msg)
	self.lister["logic_activity_fg_join_msg"] = basefunc.handler(self, self.activity_fg_join_msg)
	self.lister["logic_activity_fg_leave_msg"] = basefunc.handler(self, self.activity_fg_leave_msg)
	self.lister["logic_activity_fg_ready_msg"] = basefunc.handler(self, self.activity_fg_ready_msg)
	self.lister["logic_activity_fg_gameover_msg"] = basefunc.handler(self, self.activity_fg_gameover_msg)
	--玩法
	self.lister["logic_activity_nor_begin_msg"] = basefunc.handler(self, self.activity_nor_begin_msg)
	self.lister["logic_activity_nor_fa_pai_msg"] = basefunc.handler(self, self.activity_nor_fa_pai_msg)
	self.lister["logic_activity_nor_dizhu_msg"] = basefunc.handler(self, self.activity_nor_dizhu_msg)
	self.lister["logic_activity_nor_dizhu_pai_msg"] = basefunc.handler(self, self.activity_nor_dizhu_pai_msg)
	self.lister["logic_activity_nor_settlement_msg"] = basefunc.handler(self, self.activity_nor_settlement_msg)
	self.lister["logic_activity_nor_da_piao_msg"] = basefunc.handler(self, self.activity_nor_da_piao_msg)
	self.lister["logic_activity_nor_dingque_result_msg"] = basefunc.handler(self, self.activity_nor_dingque_result_msg)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyClose()
	self:MyExit()
end

function C:MyExit()
	self:ShowCSSharePanel()
	self.m_fg_leave = nil
	self.playedCSD = nil
	if self.curSoundKey then
		soundMgr:CloseLoopSound(self.curSoundKey)
		self.curSoundKey = nil
	end
	if self.curSoundKey then
		soundMgr:CloseLoopSound(self.curSoundKey)
	end
	if self.timers then
		for i,v in ipairs(self.timers) do
			v:Stop()
		end
		self.timers = nil
	end
	self.curSoundKey = nil
	if self.ComFlyAnim_timer then
		for i,v in ipairs(self.ComFlyAnim_timer) do
			if v then
				v:Stop()
				v = nil
			end
		end
		self.ComFlyAnim_timer = nil
	end

	if self.item_fly_anim_timer then
		self.item_fly_anim_timer:Stop()
		self.item_fly_anim_timer = nil
	end
	if self.cs_share_panel then
		self.cs_share_panel = nil
	end
	self.cs_share_close = nil
	m_data = nil
	self:RemoveListener()
	self:Reduction()

	self:UnbindParticles()

	destroy(self.gameObject)
end

function C:ctor(parm)

	ExtPanel.ExtMsg(self)

	self.parm = parm
	m_data = OperatorActivityLogic.GetData()
	local parent = GameObject.Find("Canvas/LayerLv4").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj

	self:MakeLister()
	self:AddMsgListener()
	LuaHelper.GeneratingVar(self.transform, self)
	self.clearing_close_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		Event.Brocast("close_operator_activity","cs")
	end)
	self.playedCSD = false
	
	--self.csd_particles = self.csd_cs:GetComponentsInChildren(typeof(UnityEngine.ParticleSystem), true)
	--self.cs_clearing_particles = self.csd_clearing_cs:GetComponentsInChildren(typeof(UnityEngine.ParticleSystem), true)
	self:BindParticles()

	self:MyRefresh()
end

function C:IsBigUI()
	if IsEquals(self.gameObject) and self.gameObject.activeSelf then
		return true
	end
	return false
end

function C:MyRefresh()
	self:RefreshData()
	self:RefreshCSPlayerInfo()
	self:RefreshCSAwardPlayerInfo()
	-- self:PlayCSAward()
end

function C:BindParticles()
	self.csd_particle_inst = GameObject.Instantiate(GetPrefab("caishen_CX"), self.csd_cs)
	self.csd_particle_inst.transform.localPosition = Vector3.zero
	self.csd_particles = self.csd_particle_inst.transform:GetComponentsInChildren(typeof(UnityEngine.ParticleSystem), true)

	local ddz_head_particle_tmpl = GetPrefab("caishen_XZ_DZ")
	local ddz_head_tbl = { self.ddz_match_playerself_info_ui, self.ddz_match_playerright_info_ui, self.ddz_match_playerleft_info_ui }
	self.csd_ddz_head_particles = {}
	for k, v in pairs(ddz_head_tbl) do
		local parentNode = v.transform:Find("@head_img")
		local inst = GameObject.Instantiate(ddz_head_particle_tmpl, parentNode)
		inst.transform.localPosition = Vector3.zero
		self.csd_ddz_head_particles[k] = inst
	end

	local mj_head_particle_tmpl = GetPrefab("caishen_XZ_MJ")
	local mj_head_tbl = { self.PlayerDownRect, self.PlayerTopRect, self.PlayerRightRect, self.PlayerLeftRect }
	self.csd_mj_head_particles = {}
	for k, v in pairs(mj_head_tbl) do
		local parentNode = v.transform:Find("@head_img")
		local inst = GameObject.Instantiate(mj_head_particle_tmpl, parentNode)
		inst.transform.localPosition = Vector3.zero
		self.csd_mj_head_particles[k] = inst
	end

	self.csd_clearing_particle_inst = GameObject.Instantiate(GetPrefab("caishen_glow"), self.csd_clearing_cs)
	self.csd_clearing_particle_inst.transform.localPosition = Vector3.zero
	self.cs_clearing_particles = self.csd_clearing_particle_inst:GetComponentsInChildren(typeof(UnityEngine.ParticleSystem), true)
end

function C:UnbindParticles()
	if self.csd_particle_inst then
		destroy(self.csd_particle_inst.gameObject)
		self.csd_particle_inst = nil
	end

	if self.csd_clearing_particle_inst then
		destroy(self.csd_clearing_particle_inst.gameObject)
		self.csd_clearing_particle_inst = nil
	end

	for k, v in pairs(self.csd_ddz_head_particles) do
		destroy(v.gameObject)
	end
	self.csd_ddz_head_particles = {}

	for k, v in pairs(self.csd_mj_head_particles) do
		destroy(v.gameObject)
	end
	self.csd_mj_head_particles = {}
end
-------------------------event
--活动数据
function C:activity_refresh_data_msg(data)
	dump(data, "<color=green>activity_refresh_data_msg:</color>")
	if data and data.activity_data then
		m_data.activity_data = m_data.activity_data or {}
		m_data.activity_data = data.activity_data
		self:RefreshData()
	end
end

--玩法
function C:activity_nor_begin_msg()
	dump(m_data, "<color=green>activity_nor_begin_msg:</color>")
	self:MyRefresh()
	--财神到特效
	self:PlayCSD()
end

function C:activity_nor_fa_pai_msg()
	dump(m_data, "<color=green>activity_nor_fa_pai_msg:</color>")
	self:MyRefresh()
end

function C:activity_nor_dizhu_msg()
	dump(m_data, "<color=green>activity_nor_dizhu_msg:</color>")
	self:MyRefresh()
end

function C:activity_nor_dizhu_pai_msg()
	dump(m_data, "<color=green>activity_nor_dizhu_pai_msg:</color>")
	self:MyRefresh()
end

function C:activity_nor_settlement_msg()
	dump(m_data, "<color=green>activity_nor_settlement_msg:</color>")
	self:MyRefresh()
end

function C:activity_nor_dingque_result_msg()
	dump(m_data, "<color=green>activity_nor_dingque_result_msg:</color>")
	self:MyRefresh()
end

function C:activity_nor_da_piao_msg()
	dump(m_data, "<color=green>activity_nor_da_piao_msg:</color>")
	self:MyRefresh()
end

--模式
function C:activity_fg_all_info()
	dump(m_data, "<color=green>activity_fg_all_info:</color>")
	self:MyRefresh()
end

function C:activity_fg_enter_room_msg()
	dump(m_data, "<color=green>activity_fg_enter_room_msg:</color>")
	self:MyRefresh()
end

function C:activity_fg_join_msg()
	dump(m_data, "<color=green>activity_fg_join_msg:</color>")
	self:MyRefresh()
end

function C:activity_fg_leave_msg(seat_num)
	dump(seat_num, "<color=green>seat_num>>>>>>>>>>>>>>></color>")
	if not m_data.game_model then
		self.m_fg_leave = true
		Event.Brocast("close_operator_activity","cs")
		return
	end
	local game_data = m_data.game_model.data
	if game_data and seat_num ~= game_data.seat_num then
		self:MyRefresh()
	else
		self.m_fg_leave = true
		Event.Brocast("close_operator_activity","cs")
	end
end

function C:activity_fg_ready_msg()
	dump(m_data, "<color=green>activity_fg_ready_msg:</color>")
	self:MyRefresh()
end

function C:activity_fg_gameover_msg()
	dump(m_data, "<color=green>activity_fg_gameover_msg:</color>")
	self:MyRefresh()
	self:PlayCSAward()
end

function C:OnExitScene()
	dump(m_data, "<color=green>OnExitScene</color>")
	Event.Brocast("close_operator_activity","cs")
end

function C:activity_cs_share_close()
	self.cs_share_close = true
	self.cs_share_panel = nil
end

----------------------refresh
function C:RefreshData()
	dump(m_data, "<color=green>天降财神：m_data</color>")
	if m_data and m_data.activity_data then
		for i,v in pairs(m_data.activity_data) do
			if is_asset(v.key) then
				m_data.cs_award_type = v.key
				m_data.cs_award_count = v.value
				if m_data.cs_award_type == "shop_gold_sum" then
					m_data.cs_award_count = m_data.cs_award_count / 100
				end
			elseif string.match(v.key,"spec_award_") then
				local key = string.sub(v.key,12)
				m_data.caishen_win_asset_type = key
				m_data.caishen_win_asset_value = v.value
			else
				if v.key == "activity_id" then m_data.activity_id = v.value end
				if v.key == "cs_seat" then m_data.cs_seat = v.value end
				if v.key == "cs_is_win" then m_data.cs_is_win = v.value end
				if v.key == "seat_1" then m_data.seat_1 = v.value end
				if v.key == "seat_2" then m_data.seat_2 = v.value end
				if v.key == "seat_3" then m_data.seat_3 = v.value end
				if v.key == "seat_4" then m_data.seat_4 = v.value end
			end
		end
		if not m_data.cs_seat then return end --没有财神
		if m_data.game_type == "nor_ddz_nor" or m_data.game_type == "nor_ddz_er" or m_data.game_type == "nor_ddz_lz" or m_data.game_type == "nor_pdk_nor" then
			if m_data.game_type == "nor_pdk_nor" then
				m_data.game_model = DdzPDKModel
			else
				m_data.game_model = DdzFreeModel
			end
			m_data.game_style = GameStyle.ddz
			self.cs_ui_seat = m_data.game_model.GetSeatnoToPos(m_data.cs_seat)
			if self.cs_ui_seat == 1 then
				self.cs_ui = self.ddz_match_playerself_info_ui
			elseif self.cs_ui_seat == 2 then
				self.cs_ui = self.ddz_match_playerright_info_ui
			elseif self.cs_ui_seat == 3 then
				self.cs_ui = self.ddz_match_playerleft_info_ui
			end			
		elseif m_data.game_type == "nor_mj_xzdd" or m_data.game_type == "nor_mj_xzdd_er_7" then
			m_data.game_model = MjXzModel
			m_data.game_style = GameStyle.mj
			self.cs_ui_seat = m_data.game_model.GetSeatnoToPos(m_data.cs_seat)
			if self.cs_ui_seat == 1 then
				self.cs_ui = self.PlayerDownRect
			elseif self.cs_ui_seat == 2 then
				self.cs_ui = self.PlayerRightRect
			elseif self.cs_ui_seat == 3 then
				self.cs_ui = self.PlayerTopRect
			elseif self.cs_ui_seat == 4 then
				self.cs_ui = self.PlayerLeftRect
			end
		end
		if self.cs_ui then
			local ui_table = {}
			LuaHelper.GeneratingVar(self.cs_ui, ui_table)
			dump(ui_table, "<color=white>》》》》》》》》》》》》》》》》</color>")
			self.head_img = ui_table.head_img
			self.head_frame_img = ui_table.head_frame_img
			self.cs_ui_spine_node = ui_table.spine_node
			if m_data.game_style == GameStyle.mj then
				self.scoreBg = ui_table.scoreBg
			end
		end
	end
end

function C:PlayCSD()
	if self:IsHaveCS() and not self.playedCSD then
		self.playedCSD = true
		self:PlayCSDBGM()
		self:PlayCSDFlyToPlayer()
	end
end

function C:PlayCSDBGM()
	if self:IsHaveCS() then
		-- if self.curSoundKey then
		-- 	soundMgr:CloseLoopSound(self.curSoundKey)
		-- 	self.curSoundKey = nil
		-- end
		-- self.curSoundKey = ExtendSoundManager.PlaySound(audio_config.game.bgm_duijihongbao.audio_name, 1, function ()
		-- 	self.curSoundKey = nil
		-- end)
		ExtendSoundManager.PlaySound(audio_config.game.bgm_caishenchuxian.audio_name, 1)
	end
end

function C:PlayCSDFlyToPlayer()
	if self:IsHaveCS() then
		self.csd_gameing_node.gameObject:SetActive(true)
		self.csd_node.transform.gameObject:SetActive(true)
		self.head_frame_img.gameObject:SetActive(false)
		self.cs_ui_spine_node.gameObject:SetActive(false)
		self.head_img.gameObject:SetActive(false)
		self:SetHeadUIView(true)
		local t_pos = self.head_frame_img.transform.position
		local ani_kill_callback = function ()
			self:RefreshCSPlayerInfo()
			self.csd_cs.transform.localPosition = Vector3.zero
			for i = 0, self.csd_particles.Length - 1 do
				local csd_particles = self.csd_particles[i]
				csd_particles.transform.localScale = Vector3.one
			end
		end
		local tween =
			self.csd_cs.transform:DOMove(t_pos, 0.5):OnStart(
			function()
				for i = 0, self.csd_particles.Length - 1 do
					local csd_particles = self.csd_particles[i]
					csd_particles.transform:DOScale(Vector3.zero, 0.5)
				end
			end
		):OnComplete(function()
			if m_data and m_data.game_model.data then
				local dizhu = m_data.game_model.data.dizhu
				if dizhu == nil or dizhu <= 0 then
					self.head_img.gameObject:SetActive(true)
				end
			end
		end)
		local seq = DG.Tweening.DOTween.Sequence()
		local tweenKey = DOTweenManager.AddTweenToStop(seq)
		seq:AppendInterval(5):Append(tween):AppendInterval(2.2):OnKill(ani_kill_callback)
	end
end

function C:RefreshCSPlayerInfo()
	if self:IsHaveCS() then
		local game_model_data = m_data.game_model.data
		--头像
		self.head_img.gameObject:SetActive(false)
		self.head_frame_img.gameObject:SetActive(false)
		self.cs_ui_spine_node.gameObject:SetActive(false)
		local p_info
		if m_data.game_style == GameStyle.ddz then
			p_info = game_model_data.players_info[m_data.cs_seat]
		elseif m_data.game_style == GameStyle.mj then
			if game_model_data.playerInfo then
				p_info = game_model_data.playerInfo[m_data.cs_seat]
			end
		end
		if p_info then
			if m_data.game_style == GameStyle.ddz then
				local dizhu = game_model_data.dizhu
				
				if dizhu ~= nil and dizhu > 0 then
					self:SetHeadUIViewInDDZ(false)
					self:SetGameSpineInDDZ(false)
					self.head_frame_img.gameObject:SetActive(false)
					self.cs_ui_spine_node.gameObject:SetActive(true)
				else
					if game_model_data.model_status ~= m_data.game_model.Model_Status.wait_table then
						self:SetHeadUIViewInDDZ(false)
						self:SetGameSpineInDDZ(false)
						self.head_frame_img.gameObject:SetActive(true)
					else
						self.head_frame_img.gameObject:SetActive(false)
					end
				end
			elseif m_data.game_style == GameStyle.mj then
				local piaoNum = p_info.piaoNum
				local lackColor = p_info.lackColor
				--直接显示财神
				if true or piaoNum ~= -1 or lackColor ~= -2 then
					--麻将spine
					self:SetHeadUIViewInMJ(false)
					self.head_frame_img.gameObject:SetActive(false)
					self.cs_ui_spine_node.gameObject:SetActive(true)

					if p_info.base then
						if self.scoreBg and IsEquals(self.scoreBg) then
							self.scoreBg.gameObject:SetActive(true)
						end
					else
						if self.scoreBg and IsEquals(self.scoreBg) then
							self.scoreBg.gameObject:SetActive(false)
						end
					end
				else
					if p_info.base then
						self.head_frame_img.gameObject:SetActive(true)
					else
						self.head_frame_img.gameObject:SetActive(false)
					end
					self.cs_ui_spine_node.gameObject:SetActive(false)
				end
			end
		end
		if game_model_data.model_status == m_data.game_model.Model_Status.gaming then
			self.csd_gameing_node.gameObject:SetActive(true)
		else
			if game_model_data.model_status == m_data.game_model.Model_Status.gameover then
				self:Reduction()
			end
			self.csd_gameing_node.gameObject:SetActive(false)
		end
		self.csd_node.transform.gameObject:SetActive(false)
	end
end

function C:PlayCSAward()
	if self:IsHaveCS() then
		ExtendSoundManager.PlaySound(audio_config.game.bgm_caishenfajiang.audio_name, 1)
		self:RefreshCSAwardPlayerInfo()
		if self.cs_share_panel then
			if IsEquals(self.cs_share_panel.gameObject) then
				self.cs_share_panel.gameObject:SetActive(false)
			else
				self.cs_share_panel = nil
			end
		end
		local p_info = self:GetPlayerInfo()
 		if p_info then
			--先把奖励设为零
			for i,v in pairs(p_info) do
				local p_obj = self["player_info_tmpl" .. i]
				local p_ui = {}
				LuaHelper.GeneratingVar(p_obj.transform, p_ui)
				if IsEquals(p_ui.award_txt) then
					p_ui.award_txt.text = 0
				end

				if IsEquals(p_ui.other_award_icon_img) then
					p_ui.other_award_icon_img.gameObject:SetActive(false)
				end
				if IsEquals(p_ui.other_award_txt) then
					p_ui.other_award_txt.gameObject:SetActive(false)
				end
			end
			local ani_kill_callback = function ()
				if not IsEquals(self.csd_clearing_cs) then return end
				self.csd_clearing_cs.transform.localPosition = Vector3.zero
				for i = 0, self.cs_clearing_particles.Length - 1 do
					self.cs_clearing_particles[i].transform.localScale = Vector3.one
				end
				for i,v in pairs(p_info) do
					if self:MeCanGetAward(v.seat_num) then
						local p_obj = self["player_info_tmpl" .. i]
						local p_ui = {}
						LuaHelper.GeneratingVar(p_obj.transform, p_ui)
						local t_pos = p_ui.award_icon_img.transform.position
						local o_pos = Vector3.New(-146,228,0) -- self.csd_clearing_cs.transform.position
			
						local award_count = m_data.cs_award_count
						local all_count = 0
						local d_count = award_count / 100
						local function set_award_txt(num)
							if m_data.cs_award_type == "jing_bi" then
								if IsEquals(p_ui.award_txt) then
									p_ui.award_txt.text = num
								end
							elseif m_data.cs_award_type == "shop_gold_sum" then
								if IsEquals(p_ui.award_txt) then
									p_ui.award_txt.text = StringHelper.ToRedNum(num)
								end
							end
						end
						set_award_txt(all_count)
						local is_p = self:check_p(v.seat_num)
						if is_p then
							self.timers = self.timers or {}
							local m_timer = Timer.New(function( )
								all_count = all_count + d_count
								set_award_txt(all_count)
							end,0.02,100 , false, false)
							self.timers[#self.timers + 1] = m_timer
							m_timer:Start()
							ComFlyAnim.Create(3,o_pos,t_pos,m_data.cs_award_type,award_count,function()
								self.ComFlyAnim_timer = self.ComFlyAnim_timer or {}
								self.ComFlyAnim_timer[#self.ComFlyAnim_timer + 1] = Timer.New(function()
									if m_timer then
										m_timer:Stop()
									end
									if m_data then
										set_award_txt(m_data.cs_award_count)
									end
									if v.seat_num == m_data.cs_seat and  m_data.caishen_win_asset_type then
										local o_t_pos = p_ui.other_award_icon_img.transform.position
										local item_obj = ComFlyAnim.Create(4,o_pos,o_t_pos,m_data.caishen_win_asset_type,m_data.caishen_win_asset_value,function()
											if self.item_fly_anim_timer then
												self.item_fly_anim_timer:Stop()
											end
											self.item_fly_anim_timer = Timer.New(function(  )
												self:ShowCSSharePanel()
											end,1.5,1)
											if IsEquals(p_ui.other_award_icon_img) then
												p_ui.other_award_icon_img.gameObject:SetActive(true)
											end
											if IsEquals(p_ui.other_award_txt) then
												p_ui.other_award_txt.gameObject:SetActive(true)
											end
											self.item_fly_anim_timer:Start()
										end,p_obj,true)
										local m_parent = item_obj.transform:Find("1")
										m_parent.transform.rotation = Vector3.zero
										local _parent = item_obj.transform:Find("1/Icon")
										newObject("ItemParticleSystem",_parent.transform)
									else
										self:ShowCSSharePanel()
									end
								end,1.5,1)
								self.ComFlyAnim_timer[#self.ComFlyAnim_timer]:Start()
							end,p_obj)
						end
					end
				end
			end
			local cs_o_pos = self.head_frame_img.transform.position
			local cs_t_pos = self.csd_clearing_cs.transform.position
			self.csd_clearing_cs.transform.position = cs_o_pos
			for i = 0, self.cs_clearing_particles.Length - 1 do
				self.cs_clearing_particles[i].transform.localScale = Vector3.zero
			end
			local tween =
				self.csd_clearing_cs.transform:DOMove(cs_t_pos, 0.5):OnStart(
				function()
					for i = 0, self.cs_clearing_particles.Length - 1 do
						self.cs_clearing_particles[i].transform:DOScale(Vector3.one, 0.5)
					end
				end
			)
			local seq = DG.Tweening.DOTween.Sequence()
			local tweenKey = DOTweenManager.AddTweenToStop(seq)
			seq:Append(tween):AppendInterval(0.2):OnKill(ani_kill_callback)
		end
	end
end

function C:RefreshCSAwardPlayerInfo()
	if self:IsHaveCS() then
		local game_model_data = m_data.game_model.data
		if (m_data.game_style == GameStyle.ddz and game_model_data.status == m_data.game_model.Status.gameover and  game_model_data.model_status == m_data.game_model.Model_Status.gameover) or
			(m_data.game_style == GameStyle.mj and (game_model_data.status == m_data.game_model.Status.settlement or game_model_data.status == m_data.game_model.Status.gameover) and  game_model_data.model_status == m_data.game_model.Model_Status.gameover) then
			local p_info = self:GetPlayerInfo()			
			if p_info then
				for k,v in pairs(p_info) do
					self["player_info_tmpl" .. k].gameObject:SetActive(false)
				end
				for i,v in pairs(p_info) do
					local p_obj = self["player_info_tmpl" .. i]
					local p_ui = {}
					LuaHelper.GeneratingVar(p_obj.transform, p_ui)
					URLImageManager.UpdateHeadImage(v.head_link, p_ui.head_img)
					p_ui.name_txt.text = v.name
					--根据活动奖励刷新
					if m_data.cs_award_type == "jing_bi" then
						p_ui.award_icon_img.sprite = GetTexture("com_icon_gold")
						if self:MeCanGetAward(v.seat_num) then
							p_ui.award_txt.text = m_data.cs_award_count
						else
							p_ui.award_txt.text = 0
						end
					elseif m_data.cs_award_type == "shop_gold_sum" then
						p_ui.award_icon_img.sprite = GetTexture("com_icon_hb")
						if self:MeCanGetAward(v.seat_num) then
							p_ui.award_txt.text = StringHelper.ToRedNum(m_data.cs_award_count)
						else
							p_ui.award_txt.text = 0
						end
					end
					local is_p = self:check_p(v.seat_num)
					p_ui.award_txt.gameObject:SetActive(is_p)
					p_ui.award_icon_img.gameObject:SetActive(is_p)
					--其它奖励
					dump(m_data.caishen_win_asset_type, "<color=white>其他奖励：：：：</color>")
					if v.seat_num == m_data.cs_seat and  m_data.caishen_win_asset_type then
						local tt = AwardManager.GetAwardImage(m_data.caishen_win_asset_type)
						GetTextureExtend(p_ui.other_award_icon_img, tt.image, tt.is_local_icon)
						local name = AwardManager.GetAwardName(m_data.caishen_win_asset_type)
						p_ui.other_award_txt.text = string.format( "%s x %s",name,m_data.caishen_win_asset_value)
						p_ui.other_award_txt.gameObject:SetActive(is_p)
						p_ui.other_award_icon_img.gameObject:SetActive(is_p)
					end
					p_obj.gameObject:SetActive(true)
				end
			end
			self:ShowCSSharePanel()
			self.csd_clearing_node.gameObject:SetActive(true)
		else
			self.csd_clearing_node.gameObject:SetActive(false)
		end
	end
end

function C:Reduction()
	dump(m_data, "<color=green>还原>>>>>>>>>>>>>>>>>>>>></color>")
	if IsEquals(self.game_spine) then
		self.game_spine.gameObject:SetActive(true)
	end
	if IsEquals(self.HeadIconFram) then
		self.HeadIconFram.enabled = true
	end
	if IsEquals(self.HeadIcon) then
		self.HeadIcon.enabled = true
	end
	if IsEquals(self.HeadFrameImage) then
		self.HeadFrameImage.enabled = true
	end
	if IsEquals(self.ParticleHeadLiuGuang) then
		self.ParticleHeadLiuGuang.enabled = true
	end
end

function C:MeCanGetAward(seat_num)
	if self:IsHaveCS() then
		if m_data.cs_is_win == 0 then
			return true
		elseif m_data.cs_is_win == 1 then
			if seat_num == m_data.cs_seat then
				return true
			else
				return false
			end
		end
	end
end

function C:IsHaveCS()
	if m_data and m_data.activity_id == ActivityType.TianJiangCaiShen and m_data.cs_seat and m_data.game_model and m_data.game_model.data then
		return true
	end
	return false
end

function C:FindHeadUIInMJ()
	if m_data.game_style == GameStyle.mj then
		local ui_p_name
		if self.cs_ui_seat == 1 then
			ui_p_name = "PlayerDownRect"
		elseif self.cs_ui_seat == 2 then
			ui_p_name = "PlayerRightRect"
		elseif self.cs_ui_seat == 3 then
			ui_p_name = "PlayerTopRect"
		elseif self.cs_ui_seat == 4 then
			ui_p_name = "PlayerLeftRect"
		end
	
		if not self.HeadIconFram or not IsEquals(self.HeadIconFram) then
			self.HeadIconFram = GameObject.Find("MjXzGamePanel3D").transform:Find(ui_p_name .. "/HeadRect/HeadIconFram"):GetComponent("Image")
		end
		if not self.HeadIcon or not IsEquals(self.HeadIcon) then
			self.HeadIcon = GameObject.Find("MjXzGamePanel3D").transform:Find(ui_p_name .. "/HeadRect/HeadIcon"):GetComponent("Image")
		end
		if not self.HeadFrameImage or not IsEquals(self.HeadFrameImage) then
			self.HeadFrameImage = GameObject.Find("MjXzGamePanel3D").transform:Find(ui_p_name .. "/HeadRect/HeadFrameImage"):GetComponent("Image")
		end
		if not self.ParticleHeadLiuGuang or not IsEquals(self.ParticleHeadLiuGuang) then
			self.ParticleHeadLiuGuang = GameObject.Find("MjXzGamePanel3D").transform:Find(ui_p_name .. "/HeadRect/HeadLiuGuangNode/ParticleHeadLiuGuang"):GetComponent("Image")
		end
	end
end

function C:SetHeadUIViewInMJ(view)
	if m_data.game_style == GameStyle.mj then
		view = view or false
		self:FindHeadUIInMJ()
		if IsEquals(self.HeadIconFram) then
			self.HeadIconFram.enabled = view
		end
		if IsEquals(self.HeadIcon) then
			self.HeadIcon.enabled = view
		end
		if IsEquals(self.HeadFrameImage) then
			self.HeadFrameImage.enabled = view
		end
		if IsEquals(self.ParticleHeadLiuGuang) then
			self.ParticleHeadLiuGuang.enabled = view
		end
	end
end

function C:FindGameSpineInDDZ()
	if m_data.game_style == GameStyle.ddz then
		local ui_p_name
		if self.cs_ui_seat == 1 then
			ui_p_name = "@ddz_match_playerself_info_ui"
		elseif self.cs_ui_seat == 2 then
			ui_p_name = "@ddz_match_playerright_info_ui"
		elseif self.cs_ui_seat == 3 then
			ui_p_name = "@ddz_match_playerleft_info_ui"
		end

		local pan = "DdzFreeGamePanel"
		if m_data.game_type == "nor_pdk_nor" then
			pan = "DdzPDKGamePanel"
		end

		if not self.game_spine or not IsEquals(self.game_spine) then
			self.game_spine = GameObject.Find(pan.."/" .. ui_p_name .. "/@spine_node")
		end
	end
end

function C:SetGameSpineInDDZ(view)
	if m_data.game_style == GameStyle.ddz then
		view = view or false
		self:FindGameSpineInDDZ()
		if IsEquals(self.game_spine) then
			self.game_spine.gameObject:SetActive(view)
		end
	end
end

function C:FindHeadUIInDDZ()
	if m_data.game_style == GameStyle.ddz then
		local ui_p_name
		if self.cs_ui_seat == 1 then
			ui_p_name = "@ddz_match_playerself_info_ui"
		elseif self.cs_ui_seat == 2 then
			ui_p_name = "@ddz_match_playerright_info_ui"
		elseif self.cs_ui_seat == 3 then
			ui_p_name = "@ddz_match_playerleft_info_ui"
		end

		local pan = "DdzFreeGamePanel"
		if m_data.game_type == "nor_pdk_nor" then
			pan = "DdzPDKGamePanel"
		end

		if not self.game_spine or not IsEquals(self.game_spine) then
			self.game_spine = GameObject.Find(pan.."/" .. ui_p_name .. "/@spine_node")
		end
		if not self.HeadIconFram or not IsEquals(self.HeadIconFram) then
			self.HeadIconFram = GameObject.Find(pan.."/" .. ui_p_name .. "/@cust_head_icon_img"):GetComponent("Image")
		end
		if not self.HeadIcon or not IsEquals(self.HeadIcon) then
			self.HeadIcon = GameObject.Find(pan.."/" .. ui_p_name .. "/@cust_head_img"):GetComponent("Image")
		end
	end
end

function C:SetHeadUIViewInDDZ(view)
	if m_data.game_style == GameStyle.ddz then
		view = view or false
		self:FindHeadUIInDDZ()
		if IsEquals(self.HeadIconFram) then
			self.HeadIconFram.enabled = view
		end
		if IsEquals(self.HeadIcon) then
			self.HeadIcon.enabled = view
		end
	end
end

function C:SetHeadUIView(view)
	self:SetHeadUIViewInDDZ(view)
	self:SetHeadUIViewInMJ(view)
end

function C:ShowCSSharePanel()
	-- print("<color=white>财神分享》》》》》》》》》》》》》》》</color>",self.cs_share_close,self.cs_share_panel)
	-- print( debug.traceback())
	if self.m_fg_leave then return end
	if not self:IsHaveCS() then return	end
	if self.cs_share_close and self.cs_share_close == true then return end
	if not self.cs_share_panel then
		--天降财神分享
		self.cs_share_panel = OperatorActivityCSSharePanel.Create()
		if IsEquals(self.cs_share_panel.gameObject) then
			self.cs_share_panel.gameObject:SetActive(true)
		end
	else
		if IsEquals(self.cs_share_panel.gameObject) then
			self.cs_share_panel.gameObject:SetActive(true)
		else
			self.cs_share_panel = OperatorActivityCSSharePanel.Create()
			if IsEquals(self.cs_share_panel.gameObject) then
				self.cs_share_panel.gameObject:SetActive(true)
			end
		end
	end
end

function C:GetPlayerInfo()
	local p_info = {}
	if m_data.game_style == GameStyle.ddz then
		if m_data.game_model.data.settlement_players_info then
			for i,v in pairs(m_data.game_model.data.settlement_players_info) do
				p_info[v.seat_num] = v
			end
		end
		if not next(p_info) and m_data.game_model.data.players_info then
			for i,v in pairs(m_data.game_model.data.players_info) do
				p_info[v.seat_num] = v
			end
		end
	elseif m_data.game_style == GameStyle.mj then
		if m_data.game_model.data.game_players_info then
			for i,v in pairs(m_data.game_model.data.game_players_info) do
			p_info[v.seat_num] = v
			end
		end
		if not next(p_info) and m_data.game_model.data.playerInfo then
			for i,v in pairs(m_data.game_model.data.playerInfo) do
				if v.base then
					p_info[v.base.seat_num] = v.base
				end
			end
		end
	end
	dump(p_info, "<color=white>玩家》》》》》》》》》》》》》》》》</color>")
	return p_info
end

function C:check_p( seat_num )
	local s_v = m_data["seat_" .. seat_num]
	return s_v and s_v == 1
end