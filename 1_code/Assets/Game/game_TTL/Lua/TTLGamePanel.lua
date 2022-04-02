-- 创建时间:2020-03-19
-- Panel:TTLGamePanel
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

TTLGamePanel = basefunc.class()
local C = TTLGamePanel
C.name = "TTLGamePanel"
local  vip_limit_config = {
	[7] = 1,
	[8] = 2,
	[9] = 3,
	[10] = 4,
	[11] = 5,
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
    self.lister["AssetChange"] = basefunc.handler(self,self.updateAssetInfoHandler)--监听资产改变
    self.lister["model_all_info_msg"] = basefunc.handler(self,self.on_model_all_info_msg)--监听资产改变


    self.lister["SettlePanel_on_settle_end_TTL"]=basefunc.handler(self,self.on_settle_end)

    self.lister["ItemBase_Award_Die_or_Hit_TTL"]=basefunc.handler(self,self.add_score_txt)--被撞物体加分

    self.lister["SwitchRollPanel_get_Award__TTL"]=basefunc.handler(self,self.add_score_txt)--拉霸加分
    self.lister["BombPanel_add_score_TTL"]=basefunc.handler(self,self.add_score_txt)--闪电加分
    

    self.lister["model_bullet_pause_msg"]=basefunc.handler(self,self.on_bullet_pause_msg)

    self.lister["Bullet_behit_by_bullet_msg"]=basefunc.handler(self,self.on_bullet_behit_by_bullet_msg)
    self.lister["Bullet_behit_by_bullet_msg_fx_finish"]=basefunc.handler(self,self.on_behit_by_bullet_msg_fx_finish) 
    self.lister["TTL_ui_shake_screen_msg"]=basefunc.handler(self,self.on_ui_shake_screen_msg)

    self.lister["model_auto_setfalse_msg"]=basefunc.handler(self,self.auto_setfalse)--断线取消自动发射
end

function C:on_behit_by_bullet_msg_fx_finish(type)
	--dump(self.cur_bullet_pos_count)
	--dump(self.bullet_pos_count)
	if self.cur_bullet_pos_count == self.bullet_pos_count and not self.settlePanel then
		-- 結算
		dump("<color=red>CCCCCCCCCCCCCCCCCCCCCCCCCCCC</color>")
		self.blackBG.gameObject:SetActive(true)
		self.settlePanel=TTLSettlePanel.Create(self.all_money,(self.all_rate/1000)+self.random_award)
	else
		if type then
			self.blackBG.gameObject:SetActive(false)
			Event.Brocast("model_bullet_pause_msg",{type=type,is_pause=true})
		end
	end
end
function C:on_bullet_behit_by_bullet_msg(no)
	self.cur_bullet_pos_count = self.cur_bullet_pos_count + 1
	local cfg = TTLModel.Item_config.obs_data[no]
	self.bullet_pz_map[no] = self.bullet_pz_map[no] or 0
	if not cfg then
		self:on_behit_by_bullet_msg_fx_finish()
		return
	end
	if cfg.type == "bigAward" then
		self.bullet_pz_map[no] = self.bullet_pz_map[no] + 1
		Event.Brocast("Bullet_behit_by_bullet_TTL", no)
	elseif cfg.type == "bomb" then
		self.bullet_pz_map[no] = self.bullet_pz_map[no] + 1
		Event.Brocast("Bullet_behit_by_bullet_TTL", no)
		if self.bullet_pz_map[no] == cfg.complete_time then--满20次了
			self.blackBG.gameObject:SetActive(true)
			TTLBombPanel.Create(Vector3.New(cfg.center.x,cfg.center.y,0))--开始闪电特效
			Event.Brocast("model_bullet_pause_msg",{type="bomb",is_pause=false})
			return
		end
	elseif cfg.type == "switch" then
		-- todo
		Event.Brocast("Bullet_behit_by_bullet_TTL", no)
		if not self.switch and not self.switch_on then
			self.switch_on=0
			self.switch={}
		end
		if  not self.switch[no] then
			self.switch[no]=0
		end
		if self.switch[no]==0 then
			ExtendSoundManager.PlaySound(audio_config.ttl.bgm_ttl_dianhuo.audio_name)
			self.switch[no]=self.switch[no]+1
			self.switch_on=self.switch_on+1
		elseif self.switch[no]==1 then
			self.switch[no]=self.switch[no]-1
			self.switch_on=self.switch_on-1
		end
		if self.switch_on==3 and not self.already_roll then -- 灯全亮
			self.already_roll=true

			self.blackBG_laba.gameObject:SetActive(true)
			self.anim_roll:Play("TTL_TTLRollPanel", -1, 0)
			
			self.seq1 = DoTweenSequence.Create()
			self.seq1:AppendInterval(1.3)
			self.seq1:AppendCallback(function ()
			ExtendSoundManager.PlaySound(audio_config.ttl.bgm_ttl_labafeiqi.audio_name)
			end)

			self.seq1:AppendInterval(1.2)
			self.seq1:AppendCallback(function ()
				self.blackBG_laba.gameObject:SetActive(false)
				self.blackBG.gameObject:SetActive(true)
				TTLSwitchRollPanel.Create(self.random_award,self.cost_txt.text)--开始拉霸
			end)

		
			Event.Brocast("model_switchRoll_TTL")
			Event.Brocast("model_bullet_pause_msg",{type="roll",is_pause=false})
			return
		end
	elseif cfg.type == "normal" then
		self.bullet_pz_map[no] = self.bullet_pz_map[no] + 1
		Event.Brocast("Bullet_behit_by_bullet_TTL", no)
	else
	end
	self:on_behit_by_bullet_msg_fx_finish()
end





function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	if self.update then
		self.update:Stop()
		self.update = nil
	end
	if self.count_time then
		self.count_time:Stop()
		self.count_time = nil
	end
	if self.game_btn_pre then
		self.game_btn_pre:MyExit()
	end

	self.timeSlider_pre:MyExit()
	self.bullet_pre:MyExit()
	self:CloseSpawnPrefab()

	self:StopBKTime()

	self:RemoveListener()
	--destroy(self.gameObject)

	 
end

function C:ctor()

	ExtPanel.ExtMsg(self)


	local parent = GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)

	self:MakeLister()
	self:AddMsgListener()


	self.TTLRollPanel_origin_pos=self.TTLRollPanel.transform.localPosition

    self.bullet_pre = TTLBullet.Create(self.node)
    self.timeSlider_pre = TTLTimeSliderPanel.Create(self.timeSlider_node)

	self.update = Timer.New(function ()
		self.bullet_pre:FrameUpdate(0.02)
	end,0.02,-1,false)
	self.update:Start()



	URLImageManager.UpdateHeadImage(MainModel.UserInfo.head_image, self.userHead_img)	
	self.userName_txt.text = MainModel.UserInfo.name

---------------------------------------------------------------------------------------------------
	--[[self.wealth_txt.font = self.userName_txt.font
	self.wealth_txt.fontSize = 40
	self.wealth_txt.color = Color.New(255/255,231/255,36/255)
	self.wealth_txt.gameObject.transform.localPosition = Vector3.New(135.6,-0.3,0)--]]
----------------------------------------------------------------------------------------------------

	self.wealth_txt.text = StringHelper.ToCash(MainModel.UserInfo.jing_bi)
	self:InitUI()

	local bg = self.transform:Find("BG/TTLBG")
	MainModel.SetGameBGScale(bg)
end


function C:InitUI()

	local btn_map = {}
	btn_map["top"] = {self.hall_btn_top}
	self.game_btn_pre = GameButtonPanel.Create(btn_map, "ttl_config", self.transform)

	EventTriggerListener.Get(self.shoot_btn.gameObject).onDown = basefunc.handler(self, self.on_Shoot_Down)
    EventTriggerListener.Get(self.shoot_btn.gameObject).onUp = basefunc.handler(self, self.on_Shoot_Up)
    EventTriggerListener.Get(self.shoot_OnAuto_btn.gameObject).onClick = basefunc.handler(self, self.on_Auto_Click)
    self.anim_roll = self.TTLRollPanel.transform:GetComponent("Animator")
    self.anim_bk = self.bk_node.transform:GetComponent("Animator")
    self.game_power_id=1
	self.btn_can_use1=true

	self.game_power_id = TTLModel.GetUserBet()--获取初始档位
	self.cost_txt.text=TTLModel.Defines.game_power[self.game_power_id]

    self:SetBK(true)
    self.anim_bk:Play("ttl_bk_anim", -1, 0)

    self.seq2 = DoTweenSequence.Create()
	self.seq2:AppendInterval(3)
	self.seq2:AppendCallback(function ()
		self:SetBK(false)
	    self.bk_time = nil
	end)


--加速快进
	self.quicken_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		if self.quicken_img.gameObject.activeSelf then
			self.quicken_img.gameObject:SetActive(false)
		else
			self.quicken_img.gameObject:SetActive(true)
		end
		self.bullet_pre:changeQuicken(TTLModel.Defines.quicken)
		-- body
	end)

	self.bk_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnBKClick()
	end)

--返回大厅
	self.exit_btn.onClick:AddListener(function ()
		if self.btn_can_use1 then
			ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)

			local callback = function(  )
				Network.SendRequest("tantanle_quit_game", nil, "")
			end
		
			local a,b = GameButtonManager.RunFun({gotoui="cpl_ljyjcfk",callback = callback}, "CheckMiniGame")
			if a and b then
				return
			end
		
			callback()
		end

		-- body
	end)

--帮助界面
	self.help_btn.onClick:AddListener(function ()	
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		TTLHelpPanel.Create()
	end)



--减小炮弹威力
	self.reducePower_btn.onClick:AddListener(function ()
		if self.btn_can_use1 then
			ExtendSoundManager.PlaySound(audio_config.ttl.bgm_ttl_jiajian.audio_name)
			self.game_power_id=self.game_power_id-1
			self:CheakLevel()
			local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key="tantanle_dc_".. self.game_power_id,vip_hint_type = 2, cw_btn_desc = "确定"}, "CheckCondition")
			if a and not b then
				self.game_power_id = self.game_power_id + 1
				self:CheakLevel()
				return
			end
			self.cost_txt.text=TTLModel.Defines.game_power[self.game_power_id]
			Event.Brocast("GamePanel_chang_power_TTL",tonumber(self.cost_txt.text))
		end
	end)
--增大炮弹威力
	self.addPower_btn.onClick:AddListener(function ()
		if self.btn_can_use1 then
			ExtendSoundManager.PlaySound(audio_config.ttl.bgm_ttl_jiajian.audio_name)
			self.game_power_id=self.game_power_id+1
			self:CheakLevel()
			local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key="tantanle_dc_".. self.game_power_id,vip_hint_type = 2, cw_btn_desc = "确定"}, "CheckCondition")
			if a and not b then
				self.game_power_id = self.game_power_id - 1
				self:CheakLevel()
				return
			end
			self.cost_txt.text=TTLModel.Defines.game_power[self.game_power_id]
			Event.Brocast("GamePanel_chang_power_TTL",tonumber(self.cost_txt.text))
		end
	end)

	self:MyRefresh()
end

function C:MyRefresh()
	--dump(self.btn_can_use1,"<color=blue>***********************</color>")
	if not IsEquals(self.gameObject) then
		return
	end
	self.pause_map={}
	self.pause_map=nil
	self.already_roll=false
	self.settlePanel=nil
	self.getJYB_txt.text =0
	self.wealth_txt.text = StringHelper.ToCash(MainModel.UserInfo.jing_bi)--刷新财富显示
	self.switch={}
	self.anim_roll:Play("null", -1, 0)
	self.switch_on=0
	self:spawnPrefab()
	Event.Brocast("GamePanel_chang_power_TTL",tonumber(self.cost_txt.text))
	self.TTLRollPanel.transform.localPosition=self.TTLRollPanel_origin_pos
	self.TTLRollPanel.transform.localScale=Vector3.one
	self.bullet_pre.arrow.transform.localPosition=Vector3.New(0,0,0)
	--dump(self.is_Auto,"<color=red>TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT</color>")
	if self.is_Auto then
		--local t = math.random(0.5,2)
		local  t = 0.5
		self.seq3 = DoTweenSequence.Create()
		self.seq3:AppendInterval(t)
		self.seq3:AppendCallback(function ()
			--dump(TTLModel.Defines.game_power[self.game_power_id],"<color=red>TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT</color>")
			if TTLModel.Defines.game_power[self.game_power_id]>MainModel.UserInfo.jing_bi then
				self.is_Auto = false
				self.shoot_OnMove_btn.gameObject:SetActive(false)
				self.shoot_OnAuto_btn.gameObject:SetActive(false)
				self.shoot_btn.gameObject:SetActive(true)
				Event.Brocast("show_gift_panel")
			else
				self:Shoot()
			end
		end)

	else
		self.shoot_OnMove_btn.gameObject:SetActive(false)
		self.shoot_OnAuto_btn.gameObject:SetActive(false)
		self.shoot_btn.gameObject:SetActive(true)
	end

	Event.Brocast("ttl_refresh_end")
end

function C:blackBG_off()
	self.blackBG.gameObject:SetActive(false)
	-- body
end


--摆放Item预制体
function C:spawnPrefab()
	--依次传入参数“类型”，“父级坐标”，“自身坐标”，“编号”，“有几个角（选填）”
	self:CloseSpawnPrefab()
	for i,v in pairs(TTLModel.Item_config.obs_data) do
		if TTLModel.Item_config.obs_data[i].type ~= "boundary" then
			local pre = TTLItemBase.Create(self.coordinate_node.transform, TTLModel.Item_config.obs_data[i],self.coordinate_node.transform,nil,TTLModel.Item_config.obs_data[i].award)
			if pre then
				self.spawn_cell_list[#self.spawn_cell_list + 1] = pre
			end
		end
	end
	Event.Brocast("GamePanel_chang_power_TTL",tonumber(self.cost_txt.text))
end

function C:CloseSpawnPrefab()
	if self.spawn_cell_list then
		for k,v in ipairs(self.spawn_cell_list) do
			v:MyExit()
		end
	end
	self.spawn_cell_list = {}
end



--结算完成
function C:on_settle_end()
	self:btn_can_use(true)
	self.bullet_pre:MyRefresh()
	self.timeSlider_pre:MyRefresh()
	self.blackBG.gameObject:SetActive(false)
	self:MyRefresh()
end


function C:Shoot()
	if not self.btn_can_use1 then
		return
	end

	local zz = self.bullet_pre:GetCurArrowRotation()
	Event.Brocast("ttl_kaijiang_start")
	Network.SendRequest("tantanle_kaijiang",{angle=zz, game_id=self.game_power_id}, "", function (data)
		dump(data)
		if data.result == 0 then
			self:btn_can_use(false)
			data.path = TTLModel.unzip(data.path)
			-- data.path = {65,55,0,265,255,1,-265,255,0}


			ExtendSoundManager.PlaySound(audio_config.ttl.bgm_ttl_fashe.audio_name)
			self.bullet_pre:RunMove(data.path)

			-- 碰撞
			self.bullet_pz_map = {}
			self.bullet_pos_count = #data.path/3 - 1
			self.cur_bullet_pos_count = 0

			self.all_money=data.all_money--总奖励
			self.all_rate=data.all_rate--总倍数
			self.random_award=data.random_award--随机奖励
			self.bullet_pre.arrow.transform.localPosition=Vector3.New(0,-400,0)
			dump(self.all_money,"<color=green>+++++++++++++++总奖励++++++++++++++++++</color>")
			dump(self.all_rate,"<color=green>++++++++++++++++总倍数+++++++++++++++++</color>")
			dump(self.random_award,"<color=green>++++++++++++++随机奖励++++++++++++++++++++</color>")
			self.wealth_txt.text = StringHelper.ToCash(MainModel.UserInfo.jing_bi)--刷新财富显示
		else
			HintPanel.ErrorMsg(data.result)
			self:MyRefresh()
		end
	end)
end


--按下射击键(shoot_btn)
function C:on_Shoot_Down()
	if self.btn_can_use1 then
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		if  TTLModel.Defines.game_power[self.game_power_id]>MainModel.UserInfo.jing_bi then
			Event.Brocast("show_gift_panel")
			return
		end
		--PlayerPrefs.SetInt(MainModel.UserInfo.user_id.."TTLshoot",os.time())	


		self.seq4 = DoTweenSequence.Create()
		self.seq4:AppendInterval(2)
		self.seq4:AppendCallback(function ()
			self.is_Auto=true
			self.shoot_OnAuto_btn.gameObject:SetActive(true)
			self.shoot_btn.gameObject:SetActive(false)
			self:Shoot()
		end)


	end
end


--松开射击键(shoot_btn)
function C:on_Shoot_Up()
	if self.btn_can_use1 then
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		-- dump(TTLModel.Defines.game_power)
		-- dump(self.game_power_id)

		if  TTLModel.Defines.game_power[self.game_power_id]>MainModel.UserInfo.jing_bi then
			--Event.Brocast("show_gift_panel")
			return
		end
		if self.seq4 then
			self.seq4:Kill()
		end
		if not self.is_Auto then
			self.is_Auto=false
			self.shoot_OnMove_btn.gameObject:SetActive(true)
			self.shoot_btn.gameObject:SetActive(false)
			self:Shoot()
		end
	end
end


--在自动的状态下
function C:on_Auto_Click()
	self.is_Auto=false
	self.shoot_OnAuto_btn.gameObject:SetActive(false)
	self.shoot_OnMove_btn.gameObject:SetActive(true)
	-- body
end


function C:updateAssetInfoHandler(data)
	if data.change_type == "free_broke_subsidy" or data.change_type == "broke_subsidy" then
		self.wealth_txt.text = StringHelper.ToCash(MainModel.UserInfo.jing_bi)
	end
end

function C:on_model_all_info_msg()
	if TTLModel.data.js_data then
		self.blackBG.gameObject:SetActive(true)
		-- 断线重连处理
		local data = TTLModel.data.js_data
		if not data or not data.all_money then
			self.blackBG.gameObject:SetActive(false)
			return
		end
		--data.path = TTLModel.unzip(data.path)
		--dump(data.path)
		self:btn_can_use(false)


		self.seq5 = DoTweenSequence.Create()
		self.seq5:AppendInterval(2)
		self.seq5:AppendCallback(function ()
			self.blackBG.gameObject:SetActive(false)
		end)

		
		self.all_money=data.all_money--总奖励
		self.all_rate=data.all_rate--总倍数
		self.random_award=data.random_award--随机奖励

		TTLSettlePanel.Create(self.all_money,(self.all_rate/1000)+self.random_award)
		dump(self.all_money,"<color=green>+++++++++++++++总奖励++++++++++++++++++</color>")
		dump(self.all_rate,"<color=green>++++++++++++++++总倍数+++++++++++++++++</color>")
		dump(self.random_award,"<color=green>++++++++++++++随机奖励++++++++++++++++++++</color>")
		self.wealth_txt.text = StringHelper.ToCash(MainModel.UserInfo.jing_bi)--刷新财富显示
	end
	--self:MyRefresh()
end

--右上角得分显示
function C:add_score_txt(score)
	--dump(self.getJYB_txt.text)

	self.getJYB_txt.text=tonumber(self.getJYB_txt.text)+score*(TTLModel.Defines.game_power[self.game_power_id])/1000
	-- body
end

function C:get_is_pause()
	if self.pause_map then
		local count = 0
		for k,v in pairs(self.pause_map) do
			--dump(count)
			count = count + self.pause_map[k]
			--dump(count)
		end
		if count>0 then
			return false
		else
			return true
		end
	end
	return true
end

function C:on_bullet_pause_msg(data)
	if self.btn_can_use1 then
		return
	end
	-- type:bomb(闪电) roll(拉霸) timeSlider(结算)  ht(前后台)  wlzt(网络差)    dx
	-- is_pause:true false
	local b1 = self:get_is_pause()

	self.pause_map = self.pause_map or {}
	self.pause_map[data.type] = self.pause_map[data.type] or 0
	if data.is_pause then
		self.pause_map[data.type] = self.pause_map[data.type] - 1 
	else
		if data.type ~= "wlzt" or self.pause_map[data.type] == 0 then
			self.pause_map[data.type] = self.pause_map[data.type] + 1 
		end
	end

	local b2 = self:get_is_pause()


	if b1 and not b2 then
		self.bullet_pre:is_pause(false)
	end
	if not b1 and b2 then
		self.bullet_pre:is_pause(true)
	end
end

function C:OnBKClick()
	local b = not self.bk_node.gameObject.activeSelf
	self:SetBK(b)
end

--边框
function C:SetBK(b)
	self.bk_no.gameObject:SetActive(not b)
	self.bk_yes.gameObject:SetActive(b)
	self.bk_node.gameObject:SetActive(b)
	if b then
	    self.anim_bk:Play("null", -1, 0)
	end
	self:StopBKTime()
end

function C:StopBKTime()
	if self.bk_time then
		self.bk_time:Stop()
		self.bk_time = nil
	end
end



function C:btn_can_use(b)
	self.btn_can_use1 = b
	-- body
end


--震屏
function C:on_ui_shake_screen_msg(t, fd)
    t = t or 1
    fd = fd or 0.3
    local camera = GameObject.Find("Camera"):GetComponent("Camera")
    local seq = DoTweenSequence.Create()
    seq:Append(camera:DOShakePosition(t, Vector3.New(fd, 0, 0), 20))
    seq:OnForceKill(function ()
        if IsEquals(bg_tran) then
            camera.localPosition = Vector3.zero
        end
    end)
end


function C:auto_setfalse()
	if self.is_Auto then
		self.is_Auto = false
		self.shoot_OnMove_btn.gameObject:SetActive(false)
		self.shoot_OnAuto_btn.gameObject:SetActive(false)
		self.shoot_btn.gameObject:SetActive(true)
	end
	-- body
end

function C:CheakLevel()
	if self.game_power_id==0 then 
		self.game_power_id = #TTLModel.Defines.game_power
	end
	if self.game_power_id>#TTLModel.Defines.game_power then 
		self.game_power_id = 1
	end
end