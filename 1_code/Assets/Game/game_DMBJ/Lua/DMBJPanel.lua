local basefunc = require "Game/Common/basefunc"

DMBJPanel = basefunc.class()
local C = DMBJPanel
C.name = "DMBJPanel"
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
	self.lister["dmbj_clear_closed"] = basefunc.handler(self,self.on_dmbj_clear_closed)
	self.lister["dmbj_mini_game_panel_closed"] = basefunc.handler(self,self.RefreshGold)
	self.lister["AssetChange"] = basefunc.handler(self,self.OnAssetChange)
	self.lister["quit_game_success"] = basefunc.handler(self,self.on_quit_game_success)
	self.lister["PayPanelClosed"] = basefunc.handler(self,self.RefreshGold)
	self.lister["anim_dmbj_exchangepos_finsh"] = basefunc.handler(self,self.on_anim_dmbj_exchangepos_finsh)
	self.lister["first_kaijiang_finsh"] = basefunc.handler(self,self.on_first_kaijiang_finsh)
	self.lister["second_kaijiang_finsh"] = basefunc.handler(self,self.on_second_kaijiang_finsh)
	self.lister["second_kaijiang_finsh_by_system"] = basefunc.handler(self,self.on_second_kaijiang_finsh_by_system)
	self.lister["reconnect_dmbj"] = basefunc.handler(self,self.on_reconnect_dmbj)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:RefreshGold()
	self.curr_money_txt.text = StringHelper.ToCash(MainModel.UserInfo.jing_bi)
end

function C:MyExit()
	self.Timers = self.Timers or {}
	for i = 1,#self.Timers do
		if self.Timers[i] then
			self.Timers[i]:Stop()
			self.Timers[i] = nil
		end
	end
	if self.DMBJAutoTest then
		self.DMBJAutoTest:MyExit()
	end
	if self.game_btn_pre then
		self.game_btn_pre:MyExit()
	end
	self.DMBJTXPrefab:MyExit()
	self.Timers = {}
	self:RemoveListener()
end

function C:ctor()
	local parent = GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	self.AnimManager = DMBJAnimManager.Init(self)
	self.Level1_Click = self.Level1:GetComponent("PolygonClick")
	self.Level2_Click = self.Level2:GetComponent("PolygonClick")
	self.Level3_Click = self.Level3:GetComponent("PolygonClick")
	self.Level4_Click = self.Level4:GetComponent("PolygonClick")
	self.ExChangeTable = nil
	self.send_exchange = {}
	self.BJHDItem = {}
	self:SetBet(self:GetUserBet())
	self:ChooseLevel(1)
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	self:RefreshGold()
	ExtendSoundManager.PlaySceneBGM(audio_config.dmbj.dmbj_beijing.audio_name)
	local btn_map = {}
	btn_map["left_top"] = {self.hall_btn_top}
	self.game_btn_pre = GameButtonPanel.Create(btn_map, "dmbj_game", self.transform)
	--self.DMBJAutoTest = DMBJAutoTest.Create(self)
end

function C:InitUI()
	self.pay_btn.onClick:AddListener(
		function()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
			Event.Brocast("show_gift_panel")
		end	
	)
	self.start_btn.onClick:AddListener(
		function()
			if not self.lock then
				if MainModel.UserInfo.jing_bi >= DMBJModel.Bet then
					self.curr_money_txt.text = StringHelper.ToCash(MainModel.UserInfo.jing_bi - DMBJModel.Bet)
					self.lock = true
					DMBJModel.ReSetData()
					self:ClearBJHDItem()
					self.send_exchange = {}
					self:ReSetExchangeBtn()
					if DMBJModel.IsTest then
						self:DoFirstLottery()
					else
						Network.SendRequest("dmbj_first_kaijiang",{bet_money = DMBJModel.Bet,scene_id = DMBJModel.SceneID},"正在请求数据")
					end
				else
					Event.Brocast("show_gift_panel")
				end
			end
		end
	)
	self.lottery_btn.onClick:AddListener(
		function()
			if DMBJAnimManager.IsInAnim == false and DMBJ_Enum.First == DMBJModel.Status then
				local call = function()
					self.send_exchange = {}
					DMBJModel.SetExchangeID(self.send_exchange)
					self:ReSetExchangeBtn()
					if DMBJModel.IsTest then
						self:DoSecondLottery()
					else
						Network.SendRequest("dmbj_second_kaijiang",{replace_pos = {}})
					end
				end
				local today_key = os.date("%Y%m%d",os.time()).."dmbj"
				if PlayerPrefs.GetInt(today_key,0) == 0 then
					DMBJHintPanel.Create(call,nil,today_key)
				else
					call()
				end
			end
		end
	)
	self.exchange_btn.onClick:AddListener(
		function()
			if self.send_exchange == nil or #self.send_exchange == 0 then
				LittleTips.Create("您还没有选择更换的宝物")
				return
			end
			if not DMBJAnimManager.IsInAnim and DMBJModel.Status == DMBJ_Enum.First then
				self:ReSetExchangeBtn()
				if DMBJModel.IsTest then
					self:DoSecondLottery()
				else
					Network.SendRequest("dmbj_second_kaijiang",{replace_pos = self.send_exchange or {}})
				end
			end
		end
	)
	for i = 1,4 do
		self["Level"..i.."_Click"].PointerClick:AddListener(
			function()
				if not self.lock and DMBJModel.Status ~= DMBJ_Enum.First then
					self:ChooseLevel(i)
				end
			end
		)
	end
	for i = 1,5 do
		self["exchange"..i.."_btn"].onClick:AddListener(
			function()
				if not DMBJAnimManager.IsInAnim and  DMBJModel.Status == DMBJ_Enum.First then
					ExtendSoundManager.PlaySound(audio_config.dmbj.dmbj_genghuan.audio_name)
					self:ChooseExchange(i)
				end
			end
		)
	end
	self.back_btn.onClick:AddListener(
		function()
			print("<color=red>返回+++++</color>")
			ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
			local callback = function()
				Network.SendRequest("dmbj_quit_game")
			end
			callback()
		end
	)
	self.red_btn.onClick:AddListener(
		function()
			if DMBJModel.Status ~= DMBJ_Enum.Start then return end
			ExtendSoundManager.PlaySound(audio_config.dmbj.dmbj_jiazhu.audio_name)
			local target_index = self.Current_Bet_Index - 1
			local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key="dmbj_bet_".. target_index,vip_hint_type = 2, cw_btn_desc = "确定"}, "CheckCondition")
			if a and not b then
				target_index = self.Current_Bet_Index + 1	
				return
			end
			self:SetBet(target_index)
		end
	)
	self.add_btn.onClick:AddListener(
		function()
			if DMBJModel.Status ~= DMBJ_Enum.Start then return end
			ExtendSoundManager.PlaySound(audio_config.dmbj.dmbj_jiazhu.audio_name)
			if self.Current_Bet_Index + 1 <= #DMBJModel.dmbj_base_config.bet then
				if MainModel.UserInfo.jing_bi < DMBJModel.dmbj_base_config.bet[self.Current_Bet_Index + 1].jb then
				Event.Brocast("show_gift_panel")
				return
				end
			end
			local target_index = self.Current_Bet_Index + 1
			local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key="dmbj_bet_".. target_index,vip_hint_type = 2, cw_btn_desc = "确定"}, "CheckCondition")
			if a and not b then
				target_index = self.Current_Bet_Index - 1	
				return
			end
			self:SetBet(target_index)
		end
	)
	self.help_btn.onClick:AddListener(
		function()
			print("<color=red>帮助+++++</color>")
			DMBJHelpPanel.Create()
		end
	)
	self.DMBJTXPrefab = DMBJTXPrefab.Create()
end

function C:InitAwardPanel(data)
	local items = {}
	self:HideSpawnTX()
	for i = 1,#data do
		local glow = self["award_pos"..i].transform:Find("glow_0"..i).gameObject
		glow:SetActive(true)
		local b = DMBJPrefabManager.CreateItem(data[i],i)
		b.transform.parent = self["award_pos"..i]
		b.transform.localPosition = Vector3.New(0,0,0)
		items[#items + 1] = b
	end
	return items
end

function C:HideSpawnTX()
	for i = 1,5 do
		local glow = self["award_pos"..i].transform:Find("glow_0"..i).gameObject
		glow:SetActive(false)
	end
end

function C:DoFirstLottery()
	if self.ui_items then
		for i = 1, #self.ui_items do
			destroy(self.ui_items[i].gameObject)
		end
	end
	local data = DMBJModel.GetFirstLotteryMap()
	self.ui_items = self:InitAwardPanel(data)
	local call = function()
		self:TimerCreator(function()
			ExtendSoundManager.PlaySound(audio_config.dmbj.dmbj_huode.audio_name)
			DMBJAnimManager.DoFirstLottery(data,self.ui_items)
		end,0.3,1):Start()
	end
	local b = DMBJFindPrefab.Create(call,2.5)
	b.transform.parent = self["find_node"..DMBJModel.SceneID]
	b.transform.localPosition = Vector3.zero
end

function C:DoSecondLottery()
	if #self.send_exchange > 0 then
		if self.ui_items then
			for i = 1, #self.ui_items do
				for j = 1,#self.send_exchange do
					if i == self.send_exchange[j] then
						self.ui_items[i].gameObject:SetActive(false)
					end
				end
			end
		end
		local data = DMBJModel.GetSecondLotteryMap()
		ExtendSoundManager.PlaySound(audio_config.dmbj.dmbj_huode.audio_name)
		DMBJAnimManager.DoSecondLottery(data,self.ui_items)
	else
		Event.Brocast("anim_dmbj_exchangepos_finsh")
	end
end

function C:on_reconnect_dmbj()
	local setindexfunc = function()
		local set_index = 1
		for i = 1,#DMBJModel.dmbj_base_config.bet do
			if DMBJModel.dmbj_base_config.bet[i].jb == DMBJModel.Bet then
				set_index = i
				break
			end
		end
		self:SetBet(set_index)
	end
	if self.ui_items then
		for i = 1, #self.ui_items do
			destroy(self.ui_items[i].gameObject)
		end
	end
	if DMBJModel.Status == DMBJ_Enum.Free then
		setindexfunc()
		DMBJMiniGamePanel.Create()
	else
		self.ui_items = {}
		local data = DMBJModel.ReConnect
		if data then
			self:ChooseLevel(DMBJModel.SceneID)
			self:HideSpawnTX()
			setindexfunc()
			for i = 1,#data do 
				local glow = self["award_pos"..i].transform:Find("glow_0"..i).gameObject
				glow:SetActive(true)
				local b = DMBJPrefabManager.CreateItem(data[i],i)
				b:SetIsLiang()
				b.transform.parent = self["show_pos"..i]
				b.transform.localPosition = Vector3.New(0,0,0)
				self.ui_items[#self.ui_items + 1] = b
			end
			DMBJAnimManager.ExchangePos(self.ui_items)
		end
	end
end


function C:ChooseLevel(index)
	DMBJModel.SetSceneID(index)
	for i = 1,4 do
		self["line"..i].gameObject:SetActive(false)
	end
	self["line"..index].gameObject:SetActive(true)
end

function C:on_first_kaijiang_finsh()
	self:DoFirstLottery()
end

function C:on_second_kaijiang_finsh()
	self.tips_txt.gameObject:SetActive(false)
	--self.SetStart.gameObject:SetActive(DMBJModel.Status == DMBJ_Enum.First)
	self:DoSecondLottery()
end

function C:on_second_kaijiang_finsh_by_system()
	self.tips_txt.gameObject:SetActive(false)
	self:ReSetExchangeBtn()
	self.send_exchange = {}
	self:DoSecondLottery()
end

function C:ReSetExchangeBtn()
	for i = 1,5 do
		self["exchangetips"..i].gameObject:SetActive(false)
	end
	self.ExChangeTable = nil
end

function C:SetBet(index)
	self.Current_Bet_Index = index
	if self.Current_Bet_Index <= 1 then
		self.Current_Bet_Index = 1
	elseif self.Current_Bet_Index >= #DMBJModel.dmbj_base_config.bet then
		self.Current_Bet_Index = #DMBJModel.dmbj_base_config.bet
	end
	DMBJModel.SetBetIndex(self.Current_Bet_Index)
	DMBJModel.SetBet(DMBJModel.dmbj_base_config.bet[self.Current_Bet_Index].jb)
	self.bet_txt.text = DMBJModel.Bet
	Event.Brocast("dmbj_bet_changed")
end

function C:GetExchangeNum()
	local Num = 0
	for i = 1,#self.ExChangeTable do
		if self.ExChangeTable[i] then
			Num = Num + 1
		end
	end
	return Num
end


function C:ChooseExchange(index)
	local Can_Exchange_Max = 3
	self.ExChangeTable = self.ExChangeTable or {false,false,false,false,false}
	self.ExChangeTable[index] = not self.ExChangeTable[index]
	if self:GetExchangeNum() > Can_Exchange_Max then
		self.ExChangeTable[index] = not self.ExChangeTable[index]
		LittleTips.Create("最多能交换三个")
		return 
	end
	self.send_exchange = {}
	for i = 1,5 do
		self["exchangetips"..i].gameObject:SetActive(self.ExChangeTable[i])
		if self.ExChangeTable[i] then
			self.send_exchange[#self.send_exchange + 1] = DMBJPrefabManager.Pos2Map[i].index
		end
	end
	dump(self.send_exchange,"<color=red>交换的原始项ID______</color>")
	DMBJModel.SetExchangeID(self.send_exchange)
end

function C:MyRefresh()
	
end

function C:on_quit_game_success()
	self:MyExit()	
end

function C:on_anim_dmbj_exchangepos_finsh()
	print("<color=red>盗墓笔记交换动画完成</color>")
	if DMBJModel.Status == DMBJ_Enum.Sceond then
		self.SetStart.gameObject:SetActive(true)
		self.SetSecond.gameObject:SetActive(false)
		local Final_Data = self:GetSortData()
		local Clear_Data = {}
		for i = 1,#Final_Data do
			for j = 1,Final_Data[i].length do
				Clear_Data[#Clear_Data + 1] = Final_Data[i].parm
			end
		end
		self.lock = true
		self.tx_spawn.gameObject:SetActive(false)
		if DMBJModel.Award ~= 0 then
			self.tx_spawn.gameObject:SetActive(true)
		end
		self:TimerCreator(
			function()
				ExtendSoundManager.PlaySound(audio_config.dmbj.dmbj_fly.audio_name)
			end
		,0.6,1):Start()
		self:TimerCreator(
			function()
				Event.Brocast("dmbj_bet_changed")
			end
		,2,1):Start()
		local delay_t = DMBJModel.Award == 0 and 0.5 or 2.2
		self:TimerCreator(function()
			self.DMBJClearPanel = DMBJClearPanel.Create({award = DMBJModel.Award,show = Clear_Data})
		end,delay_t,1):Start()		
	elseif DMBJModel.Status == DMBJ_Enum.First then
		self.tips_txt.gameObject:SetActive(true)
		self:CutTimer()
		self.SetStart.gameObject:SetActive(false)
		self.SetSecond.gameObject:SetActive(true)
	end
	self:RefreshBJHD()
end

--本局获得
function C:CreateBJHDItem(parm,num)
	local b = GameObject.Instantiate(self.Result_Item,self.Result)
	b.gameObject:SetActive(true)
	local temp_ui = {}
	LuaHelper.GeneratingVar(b.transform,temp_ui)
	temp_ui.re_num_txt.text = num
	temp_ui.re_img.sprite = DMBJPrefabManager.Prefabs["item_"..parm]
	local rate =  DMBJModel.CountRate(parm,num)
	temp_ui.re_rate_txt.text = rate
	return b.gameObject
end

function C:GetSortData()
	local data = {}
	if DMBJModel.Status == DMBJ_Enum.First then
		data = DMBJModel.GetFirstLotteryMap()
	elseif DMBJModel.Status == DMBJ_Enum.Sceond then
		data = DMBJModel.GetSecondLotteryMap()
	end
	local RE = {}
	for i = 1,#data do
		RE[data[i]] = RE[data[i]] and RE[data[i]] + 1 or 1
	end
	local Final_Data = {}
	for k,v in pairs(RE) do
		local data = {parm = k,length = v,rate = DMBJModel.CountRate(k,v)}
	 	Final_Data[#Final_Data + 1] = data
	end
	local sort_function = function(a,b)
		if a.rate == b.rate then
			return a.parm > b.parm
		end
		return a.rate > b.rate
	end
	table.sort(Final_Data, sort_function)
	return Final_Data
end
function C:RefreshBJHD()
	local Final_Data = self:GetSortData()
	self:ClearBJHDItem()
	for i = 1,#Final_Data do
		if Final_Data[i].rate > 0 then
			self.BJHDItem[#self.BJHDItem + 1] = self:CreateBJHDItem(Final_Data[i].parm,Final_Data[i].length)
		end
	end
end

function C:ClearBJHDItem()
	for i = 1,#self.BJHDItem do
		GameObject.Destroy(self.BJHDItem[i])
	end
	self.BJHDItem = {}
end


function C:CutTimer()
	local str = "选择需要替换的物品~"
	local cut = DMBJModel.GetCurrCutDown() < 0 and 0 or DMBJModel.GetCurrCutDown()
	self.tips_txt.text = str .."("..cut.."s)"
	local t = self:TimerCreator(
		function()
			if IsEquals(self.gameObject) then
				if DMBJModel.Status == DMBJ_Enum.First then
					local cut = DMBJModel.GetCurrCutDown() < 0 and 0 or DMBJModel.GetCurrCutDown()
					self.tips_txt.text = str .."("..cut.."s)"
				else
					self.tips_txt.gameObject:SetActive(false)
				end
			end
		end
	,1,-1)
	t:Start()
end

function C:TimerCreator(call,space,loop)
	local t
	t = Timer.New(
		call,space,loop,nil,true
	)
	self.Timers = self.Timers or {}
	self.Timers[#self.Timers + 1] = t
	return t
end

function C:GetUserBet()
	local data = DMBJModel.dmbj_base_config.auto
	local qx_max = self.MaxIndex
    for i=#data,1,-1 do
        local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key="dmbj_bet_".. i, is_on_hint=true,vip_hint_type = 2, cw_btn_desc = "确定"}, "CheckCondition")
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

function C:on_dmbj_clear_closed()
	self:FlyGoldAnim()
	DMBJModel.Status = DMBJ_Enum.Start
	self.lock = false
	self:ClearBJHDItem()
	if self.ui_items then
		for i = 1, #self.ui_items do
			destroy(self.ui_items[i].gameObject)
		end
	end
end

function C:OnAssetChange(data)
	dump(data,"<color=red>kkkkkkkkkkkkk</color>")
end

function C:FlyGoldAnim()
	local x = math.ceil(DMBJModel.Award / 20000)
	local num = x > 8 and 8 or x
	for i = 1,num do
		local v = self:GetRandomVector3()
		local b = newObject("DMBJFlyGlodPrefab", self.fly_gold_node)
		b.transform.localPosition = v
		local seq = DoTweenSequence.Create({dotweenLayerKey = C.name})
		seq:AppendInterval(1)
		seq:Append(b.transform:DOMoveBezier(Vector2.New(632,495), 10 + math.random(-100,100), 0.6))
		seq:AppendCallback(
			function ()
				self:RefreshGold()
				b.gameObject:SetActive(false)
				destroy(b)
			end
		)
	end
	self:TimerCreator(function()
		ExtendSoundManager.PlaySound(audio_config.dmbj.dmbj_xiaoyouxihuojiang.audio_name)
	end,3,1):Start()
end

function C:GetRandomVector3()
	local left_top = {x = -100,y = 100}
	local right_top = {x = 100,y = 100}
	local left_bottom = {x = -100,y = -100}
	local right_bottom = {x = 100,y = -100}
	return Vector3.New(math.random(left_top.x,right_top.x),math.random(left_bottom.y,left_top.y))
end
