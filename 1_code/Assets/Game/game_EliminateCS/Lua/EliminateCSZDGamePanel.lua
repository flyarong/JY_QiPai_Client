-- 创建时间:2019-01-03
local basefunc = require "Game.Common.basefunc"
EliminateCSZDGamePanel = basefunc.class()
local M = EliminateCSZDGamePanel
M.name = "EliminateCSZDGamePanel"
M.save_path = AppDefine.LOCAL_DATA_PATH .. "/" .. MainModel.UserInfo.user_id
M.save_file = "csxxlzd_data"
M.broke_pos = {}
local test_img = {"csxxl_icon_11","csxxl_icon_12","csxxl_icon_13"}
local tx_delay = {1,1,1}
local tx_level = {1,2,3}
local instance
function M.Create(data,backcall)
	if instance then
		M.Close()
	end
	instance = M.New(data,backcall)
end

function M.Close()
	if instance then
		instance:MyExit()
		instance = nil
	end
end

function M.ReSet()
	PlayerPrefs.SetInt("Eliminate_CS_Finsh_ZD_Finish"..MainModel.UserInfo.user_id,1)
end

function M:AddMsgListener(data)
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function M:MakeLister()
	self.lister = {}
	self.lister["view_quit_game"] = basefunc.handler(self, self.MyExit)
    self.lister["view_lottery_start"] = basefunc.handler(self, self.view_lottery_start)
    self.lister["view_lottery_end"] = basefunc.handler(self, self.view_lottery_end)
	self.lister["view_lottery_error"] = basefunc.handler(self, self.view_lottery_error)
	self.lister["view_lottery_sucess"] = basefunc.handler(self, self.view_lottery_sucess)
end

function M:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function M:MyExit()
	if self.out_timer then 
		self.out_timer:Stop()
	end
	if self.random_zd_timer then 
		self.random_zd_timer:Stop()
	end 
	if self.guide_timer then
		self.guide_timer:Stop()
	end
	if self.over_timer then 
		self.over_timer:Stop()
	end  
	if self.tx_level_timer then 
		self.tx_level_timer:Stop()
	end
	if self.tx_delay_timer then 
		self.tx_delay_timer:Stop()
	end
	if self.curSoundKey then
		soundMgr:CloseLoopSound(self.curSoundKey)
		self.curSoundKey = nil
	end
	self:RemoveListener()
	save_lua2json({},M.save_file,M.save_path)
	PlayerPrefs.SetInt("Eliminate_CS_Finsh_ZD_Finish"..MainModel.UserInfo.user_id,1)
	GameObject.Destroy(self.gameObject)
	ExtendSoundManager.PlaySceneBGM(audio_config.csxxl.bgm_csxxl_tiannvsanhuabeijing.audio_name,true)
	instance = nil

	 
end

function M:ctor(data,backcall)

	ExtPanel.ExtMsg(self)

	self.can_show_award = true
	local parent = GameObject.Find("Canvas/LayerLv1").transform
	local obj = newObject(M.name, parent)
	local tran = obj.transform
	local last_open_time = PlayerPrefs.GetInt("Eliminate_CS_Finsh_ZD_Time"..MainModel.UserInfo.user_id,os.time())
	PlayerPrefs.SetInt("Eliminate_CS_Finsh_ZD_Time"..MainModel.UserInfo.user_id,os.time())
	local is_finish = PlayerPrefs.GetInt("Eliminate_CS_Finsh_ZD_Finish"..MainModel.UserInfo.user_id,1) == 1
	PlayerPrefs.SetInt("Eliminate_CS_Finsh_ZD_Finish"..MainModel.UserInfo.user_id,0)
	self.transform = tran
	self.gameObject = obj
	self.data = data.zd_list
	self.backcall = backcall
	self.IS_OVER = false  -- 砸蛋过程是否结束了
	self.IS_Random = false --是否在随机炸弹
	self:MakeLister()
	self:AddMsgListener()
	LuaHelper.GeneratingVar(self.transform, self)
	self.egg_items = {}
	if not EliminateCSModel.data.is_new then
		M.ResetLocalData()		
	end
	M.broke_pos = load_json2lua(M.save_file,M.save_path) or {}
	local temp_ui = {}
	for i= 1, 10 do 
		local b = GameObject.Instantiate(self.egg_item,self["point_"..i].transform)
		b.gameObject:SetActive(true)
		b.transform.localPosition = Vector2.zero
		self.egg_items[i] = b
		LuaHelper.GeneratingVar(b.transform, temp_ui)
		temp_ui.award_img.gameObject:SetActive(false)
		temp_ui.egg_btn.onClick:AddListener(
			function ()
				self:OnEggClick(i)
			end
		)
	end
	if not is_finish then 
		if os.time() - last_open_time > 60 then 
			--开始随机砸
			self:RandomZD()
		else
			self.out_time = os.time() - last_open_time
			self:InitOutTimer()
		end
	else
		self.out_time = 60
		self:InitOutTimer()
	end
	self:MyRefresh()
	--self:AnimStart()

	self:InitUI()
end

function M:MyRefresh()
	local temp_ui = {}
	if self.curSoundKey then
		soundMgr:CloseLoopSound(self.curSoundKey)
		self.curSoundKey = nil
	end	
	for i = 1,#M.broke_pos do 
		LuaHelper.GeneratingVar(self.egg_items[M.broke_pos[i]].transform, temp_ui)
		temp_ui.award_img.gameObject:SetActive(true)
		local ls = 1
		local cur_id = self.data[i] 
		if cur_id == 1 then
			ls = 2
		elseif cur_id == 2 then
			ls = 1.3
		elseif cur_id == 3 then
			ls = 0.8
		end
		temp_ui.award_img.transform.localScale = Vector3.one * ls
		temp_ui.Body.gameObject:SetActive(false)
		temp_ui.Broke_Body.gameObject:SetActive(true)
		if self.data[i] and self.data[i] ~= 0 then 
			temp_ui.award_img.transform:GetComponent("Image").sprite = GetTexture(test_img[self.data[i]])
		end
		temp_ui.egg_btn.onClick:RemoveAllListeners() 
	end
	if #self.data - #M.broke_pos <= 0 then
		if not self.IS_OVER then 
			self:OverAnim()
		end 
	end 
end

function M:OnBackClick()
	self:MyExit()
end

function M:GuideAnim(objs,backcall)
	local finsh_times = 0
	for i=1,#objs do
		self.seq = DoTweenSequence.Create()
		local old_p  = objs[i].transform.parent
		objs[i].parent = self.transform
		local v  = objs[i].transform.localPosition
		self.seq:Append(objs[i]:DOLocalMove(self.mid_pos.transform.localPosition, 1))
		self.seq:AppendInterval(0.5)
		self.seq:Append(objs[i]:DOLocalMove(v, 0.7))
		self.seq:OnKill(function ()
			finsh_times = finsh_times + 1
			if finsh_times == #objs then 
				if backcall then 
					backcall()
				end 
			end 
			objs[i].parent = old_p
			self.seq = nil
		end)
	end
end

function M:AnimStart()
	self.ACT_LOCK = true
	self.guide_timer = Timer.New(function ()
		self:GuideAnim(self.egg_items,function ()
			self.ACT_LOCK = false
		end)
	end,0.2,1)
	self.guide_timer:Start()
end

function M:InitOutTimer()
	if self.out_timer then 
		self.out_timer:Stop()
	end
	self.out_timer = Timer.New(function()
		self.out_time = self.out_time - 1
		--刷新倒计时
		self:RefreshOutTime()
		if self.out_time <= 0  then
			--开始随机砸蛋
			self:RandomZD()
			if self.out_timer then 
				self.out_timer:Stop()
			end
		end
	end,1,-1)
	self.out_timer:Start()
end

function M:RefreshOutTime()
	self.time_out_txt.text = self.out_time.."s"
end

--开始随机砸蛋
function M:RandomZD()
	self.IS_Random = true
	self.time_out_txt.text = "自动砸蛋中..."
	self.djzd_img.gameObject:SetActive(false)
	if self.random_zd_timer then 
		self.random_zd_timer:Stop()
	end
	self.random_zd_timer = Timer.New(function ()
		if #M.broke_pos >= #self.data then 
			return
		end 
		local r_index = self:GetRandomIndex()
		dump(r_index,"<color=red>r_index</color>")
		if r_index and not self.IS_OVER then 
			self:OnEggClick(r_index,true)
		end
	end,1,-1)
	self.random_zd_timer:Start()
end

function M:InitUI()
	ExtendSoundManager.PlaySceneBGM(audio_config.csxxl.bgm_csxxl_zadanbeijing.audio_name,true)
	self.back_btn.onClick:AddListener(
		function ()
			self:OnBackClick()
		end
	)
end

function M:OnEggClick(i,israndom)
	local temp_ui_1 = {}
	local temp_ui_2 = {}
	if self.IS_OVER then return end
	if not self.IS_Random or (israndom and self.IS_Random)  then--如果不处于自动炸弹，则无按钮限制，如果处于自动炸弹，那么只接受系统随机炸弹
		if self:CheakIsHadSameValue(i,M.broke_pos) then return end
		if not self.data[#M.broke_pos + 1] then return end
		M.broke_pos[#M.broke_pos + 1] = i
		save_lua2json(M.broke_pos,M.save_file,M.save_path)
		temp_ui_1 = {}
		LuaHelper.GeneratingVar(self.egg_items[i].transform, temp_ui_1)
		local b = GameObject.Instantiate(self.anim_item,temp_ui_1.anim_node)
		b.name = "anim_item"..i
		temp_ui_1.award_img.transform:GetComponent("Image").sprite = GetTexture(test_img[self.data[#M.broke_pos]])
		local ls = 1
		local cur_id = self.data[#M.broke_pos] 
		if cur_id == 1 then
			ls = 2
		elseif cur_id == 2 then
			ls = 1.3
		elseif cur_id == 3 then
			ls = 0.8
		end
		temp_ui_1.award_img.transform.localScale = Vector3.one * ls

		temp_ui_1.Body.gameObject:SetActive(false)
		temp_ui_1.Broke_Body.gameObject:SetActive(false)
		b.gameObject:SetActive(true)
		b.transform.localPosition = Vector2.zero
		LuaHelper.GeneratingVar(b.transform, temp_ui_2)
		self.tx_level_timer = Timer.New(function()
			temp_ui_2["tx_"..tx_level[self.data[#M.broke_pos]]].gameObject:SetActive(true)
		end,0.5,1)
		self.tx_level_timer:Start()
		self.tx_delay_timer = Timer.New(function()
			local cur_id = self.data[#M.broke_pos] 
			if cur_id == 1 then
				ExtendSoundManager.PlaySound(audio_config.csxxl.bgm_csxxl_jinhua.audio_name)
			elseif cur_id == 2 then
				ExtendSoundManager.PlaySound(audio_config.csxxl.bgm_csxxl_yinhua.audio_name)
			elseif cur_id == 3 then
				ExtendSoundManager.PlaySound(audio_config.csxxl.bgm_csxxl_tonghua.audio_name)
			end
			temp_ui_1.award_img.gameObject:SetActive(true)
			temp_ui_1.award_img:GetComponent("Animator"):Play("cz_zd_showaward")
			self:MyRefresh()
		end ,tx_delay[self.data[#M.broke_pos]],1)
		self.tx_delay_timer:Start()
	end 
end

--在min到max中，随机选择num个数字，组成数组,min 默认是 1
function M:GetRandomList(_num,_max,set_seed_by_sec,_min)
	_min = _min or 1
	if _num > _max or _min >= _max then 
		print("<color=yellow>Error 数据不合法了</color>")
		return 
	end
	local _m = {}
	local _n = {}
	for i=1,_max + 1 - _min  do
		_m[i] = i
	end
	if set_seed_by_sec then
		math.randomseed(os.time())
	end 
	while #_n < _num do
		local x = math.random(1,#_m)
		if _m[x] ~= nil then 
			_n[#_n + 1] = _m[x]
			table.remove(_m,x)
		end 
	end
	if _min  then 
		for i=1,#_n do
			_n[i] = _n[i] + _min - 1
		end
	end 
	return _n
end

function M:CheakIsHadSameValue(v,table)
	for i = 1,#table do 
		if table[i] == v then 
			return true
		end 
	end
	return false
end

function M:GetRandomIndex()
	local random_list = M:GetRandomList(10,10,true)
	dump(random_list,"<color=red>随机砸蛋随机序列</color>")
	dump(M.broke_pos,"<color=red>已经砸蛋的位置</color>")
	for i = 1,#random_list do
		if not M:CheakIsHadSameValue(random_list[i],M.broke_pos) then
			return random_list[i]
		end 
	end
end

function M:OverAnim()
	print("<color=red>砸蛋完成..</color>")
	self.IS_OVER = true
	self.over_timer = Timer.New(function()
		print("<color=red>砸蛋退出..</color>")
		if self.backcall then 
			self.backcall()
		end 
		self:MyExit()
	end,EliminateCSModel.time.xc_zd_xs,1)
	self.over_timer:Start()
	self:CreateZDTNSH()
end

function M:CreateZDTNSH()
	if table_is_null(self.data) then return end
	local luck
	local luck_list = {}
	for i,v in ipairs(self.data) do
		luck_list[v] = luck_list[v] or 0
		luck_list[v] = luck_list[v] + 1
		if luck_list[v] == 3 then
			luck = v
			break
		end
	end
	Event.Brocast("view_xxl_caishen_tnsh_kj",{rate = luck})
	-- luck = 4 - luck --倒个序
	EliminateCSPartManager.CreateZaDanComplete(luck)
end

function M.ResetLocalData()
	save_lua2json({},M.save_file,M.save_path)
end

function M:view_lottery_end(data)
	M.ReSet()
end

function M:view_lottery_start(data)
	M.ReSet()
end

function M:view_lottery_error(data)
	M.ReSet()
end

function M:view_lottery_sucess(data)
	M.ReSet()
end