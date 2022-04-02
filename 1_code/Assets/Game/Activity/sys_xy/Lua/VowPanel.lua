-- 创建时间:2019-07-18
-- Panel:VowPanel
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
local button_status={
	[1]="许愿",
	[2]="不可领取",
	[3]="免费领取",
	[4]="付费领取",	
}
local time_during=14
VowPanel = basefunc.class()
VowPanel.vow_data={}
local C = VowPanel
C.name = "VowPanel"

function C.Create(islogin,backcall)	
	return  C.New(islogin,backcall)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
	self.lister = {}
	self.lister["AssetsGetPanelConfirmCallback"] = basefunc.handler(self, self.AssetsGetPanelConfirmCallback)
	self.lister["AssetChange"] = basefunc.handler(self, self.OnAssetChange)
    self.lister["EnterBackGround"] = basefunc.handler(self, self.onEnterBackGround)
    self.lister["EnterForeGround"] = basefunc.handler(self, self.ReConnecteServerSucceed)
    self.lister["ReConnecteServerSucceed"] = basefunc.handler(self, self.ReConnecteServerSucceed)
	self.lister["xuyuanchi_base_info_change"]=basefunc.handler(self,self.OnGetInfo)
	self.lister["xuyuanchi_query_qiang_info_response"]=basefunc.handler(self,self.OnWall)
	self.lister["query_xuyuanchi_base_info_response"]=basefunc.handler(self,self.OnGetInfo)
	self.lister["query_now_xuyuan_player_num_response"]=basefunc.handler(self,self.onGetPlayerNum)
	self.lister["xuyuanchi_get_award_response"]=basefunc.handler(self,self.onGetAward)
	self.lister["xuyuanchi_free_vow_response"]=basefunc.handler(self,self.onFreeVow)
	self.lister["xuyuanchi_try_get_award_response"] = basefunc.handler(self,self.xuyuanchi_try_get_award_response)
end
function C:OnAssetChange(data)
	dump(data,"<color=red>----奖励类型-----</color>")
	if data.change_type and data.change_type == "xuyuanchi_get_award_spend" then
		VowExtGetPanel.Create(data)
	end
end
function C:onFreeVow(_,data)
	dump(data,"---")
	if data and data.result and data.result ~=0 and IsEquals(self.gameObject)  then
		print("")
		HintPanel.ErrorMsg(data.result)
	end
end

--
function C:OnHelpClick()
	self.introduce=self.transform:Find("Introduce"):GetComponent("Text")
	local str=self.config.DESCRIBE_TEXT[1].text
	for i=2,#self.config.DESCRIBE_TEXT do 
		 str=str.."\n"..self.config.DESCRIBE_TEXT[i].text
	end
	self.introduce.text=str
	IllustratePanel.Create({self.introduce}, GameObject.Find("Canvas/LayerLv5").transform)
end

function C:onGetAward(_,data)
	dump(data,"<color=red>许愿池的领奖返回</color>")
	if data and data.result and data.result ~=0 and IsEquals(self.gameObject)  then
		HintPanel.ErrorMsg(data.result)
	end
	Event.Brocast("JYFLInfoChange")
end

--重新请求数据
function C:ReConnecteServerSucceed()
	Network.SendRequest("query_xuyuanchi_base_info")
end
function C:OnWall(_,data)
	if data and data.result==0 and data.award_data and IsEquals(self.gameObject)    then		
			self:ShowLotteryInfo(self.GunDong_Node,data.award_data.name,data.award_data.award_name)
	end 
	--dump(data,"<color=red>许愿墙--------------------</color>")
end

function C:onGetPlayerNum(_,data)
	if data and data.result ==0 and IsEquals(self.gameObject)  then 
		self:SetTodayPeoPle(data.now_num)
	end 	
end
--暂停所有计时器
function C:onEnterBackGround()
	if self.update_timer then
		self.update_timer:Stop()
	end
	if self.slowUp_timer then 
		self.slowUp_timer:Stop()
	end 
	if self.heartNum_timer then 
		self.heartNum_timer:Stop()
	end
	if self.heartVowWall_timer then 
		self.heartVowWall_timer:Stop()
	end
	destroyChildren(self.GuDing_Node)
end

function C:OnGetInfo(_,data)
	dump(data,"<color=red>许愿池--------------</color>")
	if data and IsEquals(self.gameObject)  then
		VowPanel.vow_data=data
		self.data=data
		if data.is_vow==1 and data.overtime_count ~=nil  then 
			self:InitTimer(data.overtime_count)
			--如果登录时，已经许愿果了 就不弹出
			if self.login and self.login=="OnLogin" and self.backcall then 
				self:MyExit()
				return 
			end 
		elseif data.is_vow==0 then	
			self.Timer.gameObject:SetActive(false)
			self.b_status= button_status[1]
			self.Button.gameObject.transform:GetComponent("Image").sprite=GetTexture("gy_46_9")
		end 
		if data.best_award_logs then
			for i = 1, #data.best_award_logs do	
				self.GuDing_Child=self.GuDing_Child+1
				if self.GuDing_Child<=3 then
					self:ShowLotteryInfo(self.GuDing_Node,data.best_award_logs[i].name,data.best_award_logs[i].award_name)			
				end 
			end
		end 
		if data.cache_award_logs  then
			for i = 1, #data.cache_award_logs  do
				self:ShowLotteryInfo(self.GunDong_Node,data.cache_award_logs[i].name,data.cache_award_logs[i].award_name)
			end
		end 
		self.gameObject:SetActive(true)
		if data.result and  data.result~=0 then
		 	HintPanel.ErrorMsg(data.result)
		end 
	end 
	Event.Brocast("JYFLInfoChange")
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
	self.lister = {}
end

function C:MyExit()
	if self.update_timer then 
		self.update_timer:Stop()
	end 
	if self.slowUp_timer then 
		self.slowUp_timer:Stop()
	end
	if self.heartVowWall_timer then 
		self.heartVowWall_timer:Stop()
	end
	if self.heartNum_timer then 
		self.heartNum_timer:Stop()
	end
	--dump(self.backcall,"self.backcall")
	if self.backcall then 		
		self.backcall()
	end 
	GameTipsPrefab.Hide()
	self:RemoveListener()
	destroy(self.gameObject)

	 
end

function C:ctor(login,backcall)

	ExtPanel.ExtMsg(self)

	local parent = GameObject.Find("Canvas/LayerLv4").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj	
	self.ShowItemsLen=0
	self.login=login
	self.backcall=backcall
	self.b_status= button_status[1]
	self.GuDing_Child=0
	self:MakeLister()   
	self:AddMsgListener()
	
	self.config = SYSXYManager.UIConfig.config

	self:InitUI()
end
function C:InitUI()
	self.gameObject:SetActive(false)
	self.Content=self.transform:Find("BG/GiftList/BG/Content")
	self.Timer=self.transform:Find("Timer")
	self.TimerText=self.Timer.transform:Find("Text"):GetComponent("Text")
	self.CloseButton=self.transform:Find("CloseButton"):GetComponent("Button")
	self.TodayText=self.transform:Find("Today/Text"):GetComponent("Text")
	self.Button=self.transform:Find("Button"):GetComponent("Button")
	self.Sitem=self.transform:Find("showinfoitem")
	self.GunDong_Node=self.transform:Find("VowWall/GunDong/View/content")
	self.GuDing_Node=self.transform:Find("VowWall/GuDing")
	self.UseMoneyPanel=self.transform:Find("UseMoney")
	self.LQButton=self.UseMoneyPanel:Find("LQbutton"):GetComponent("Button")
	self.FQButton=self.UseMoneyPanel:Find("FQbutton"):GetComponent("Button")
	self.CloseUseMoneyButton=self.UseMoneyPanel:Find("CloseButton"):GetComponent("Button")
	self.HelpButton=self.transform:Find("HelpButton"):GetComponent("Button")
	self.introduce=self.transform:Find("Introduce"):GetComponent("Text")
	self.texiao=self.transform:Find("by_tx_xuyuanci")
	self.texiao.gameObject:SetActive(false)
	self:SlowUpAnim()
	--事件注册
	self.CloseButton.onClick:AddListener(
		function ()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
			self:MyExit()
		end
	)
	self.CloseUseMoneyButton.onClick:AddListener(
		function ()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
			self.UseMoneyPanel.gameObject:SetActive(false)
		end
	)
	self.FQButton.onClick:AddListener(
		function ()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
			Network.SendRequest("xuyuanchi_give_up_award")
			self.UseMoneyPanel.gameObject:SetActive(false)
		end
	)
	--dump(MainModel.UserInfo.jing_bi,"---0000000---")
	self.LQButton.onClick:AddListener(
		function () 
			ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
			dump(MainModel.UserInfo.jing_bi,"------")
			--老版本的需要10000鲸币才能领取奖励
			if MainModel.UserInfo.jing_bi>=0 then 			
				-- Network.SendRequest("xuyuanchi_get_award",nil,"")
				Network.SendRequest("xuyuanchi_try_get_award")
				dump(MainModel.UserInfo.jing_bi,"---1---")
				self.UseMoneyPanel.gameObject:SetActive(false)
			else				
				local h=HintPanel.Create(3,"鲸币不足，是否充值?",
				function ()
					PayPanel.Create(GOODS_TYPE.jing_bi, "normal",function ()
						self.UseMoneyPanel.gameObject:SetActive(false)
					end)
				end,nil,GameObject.Find("Canvas/LayerLv5").transform
				, "鲸币不足")
				h:SetPayBtnTitle("充 值")	
				dump(MainModel.UserInfo.jing_bi,"---2---")
			end
		end
	)
	self.Button.onClick:AddListener(
		function ()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
			if self.b_status==button_status[1] then 
				self.texiao.gameObject:SetActive(false)
				self.texiao.gameObject:SetActive(true)
				Network.SendRequest("xuyuanchi_free_vow",nil,"")
			elseif self.b_status==button_status[3] then
				--Network.SendRequest("xuyuanchi_get_award",nil,"")
				Network.SendRequest("xuyuanchi_try_get_award")
			elseif self.b_status==button_status[4] then
				self.UseMoneyPanel.gameObject:SetActive(true)			
			end 
			self.login=nil
		end
	)
	self.HelpButton.onClick:AddListener(
		function ()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
			self:OnHelpClick()
		end
	)
	self:ShowGiftList()	
	self:InitNumHeart()
	self:InitVowWallHeart()
	Network.SendRequest("query_xuyuanchi_base_info",nil,"")
end

--展示奖励列表
function C:ShowGiftList()
	self.GiftItems={}
	for i=1, #self.config.JP1-1 do 
		local b=newObject("VowGiftItem",self.Content)
		PointerEventListener.Get(b).onDown = function ()
	        GameTipsPrefab.ShowDesc(self.config.JP1[i].tips, UnityEngine.Input.mousePosition)
	    end
	    PointerEventListener.Get(b).onUp = function ()
	        GameTipsPrefab.Hide()
		end
		--装图片
		b.transform:Find("Image"):GetComponent("Image").sprite=GetTexture(self.config.JP1[i].img)
		b.transform:Find("Image"):GetComponent("Image"):SetNativeSize()
		if self.config.JP1[i].img=="bygame_icon_danmf2" or self.config.JP1[i].img=="bygame_icon_cjhl" then
			b.transform:Find("Image").transform.localEulerAngles=Vector3.New(0,0,-30)
		end 
		--写文字
		b.transform:Find("Text"):GetComponent("Text").text=self.config.JP1[i].num
	end 
	--惊喜大奖
	self.JXDJ=self.transform:Find("BG/GiftList/BG/Content/JXDJ").gameObject
	PointerEventListener.Get(self.JXDJ).onDown = function ()
		GameTipsPrefab.ShowDesc(self.config.JP1[#self.config.JP1].tips, UnityEngine.Input.mousePosition)
	end
	PointerEventListener.Get(self.JXDJ).onUp = function ()
		GameTipsPrefab.Hide()
	end
end

function C:OnHelpClick()
    IllustratePanel.Create({self.introduce}, GameObject.Find("Canvas/LayerLv5").transform)
end


function C:SetTodayPeoPle(data)
	if not IsEquals(self.TodayText.text) then return end 
	self.TodayText.text  =string.format( "%08d",data )
end
 
--倒计时
function C:UpdateTime()
	local str =StringHelper.formatTimeDHMS2(self.time-3600*time_during) --os.date("%d:%H:%M:%S",self.time+60*60*16 )--	
	if IsEquals(self.Timer) then
		--self.TimerText.text =  str		
		self.TimerText.text =  "每日8点-22点免费领"
		while self.time<0 do
			self.time=self.time+86400
		end
		self:ChangeStatus(self.time)
	end
end
function C:InitTimer(Time)
	self.time=Time 
	while self.time<0 do
		self.time=self.time+86400
	end
	self:ChangeStatus(self.time)
	if  self.update_timer then
		self.update_timer:Stop()
		self.update_timer=nil
	end 
    self.update_timer = Timer.New(function ()
		self.time = self.time - 1
		self:UpdateTime()		
		end, 1, -1, nil, true)
	self.update_timer:Start()
	self:UpdateTime()
end


--向上滑的动画
function C:SlowUpAnim()
    self.slowUp_timer = Timer.New(
	function()
		if IsEquals(self.GunDong_Node) then
			self.GunDong_Node.transform:Translate(Vector3.up * 10 * 0.016)
		end 
    end, 0.016,-1)
end



--展示开奖信息
function C:ShowLotteryInfo(parent,name,award_name)
	if   IsEquals(self.GunDong_Node) and IsEquals(self.GuDing_Node) then 
		if parent==nil then 
			parent=self.GunDong_Node
		elseif parent==self.GunDong_Node then 
			self.ShowItemsLen=self.ShowItemsLen+1
		end
		if  self.ShowItemsLen >5  then
			dump(self.ShowItemsLen)
			self.slowUp_timer:Start()
		end 
		local s = self:data2str(name,award_name)
		if s then
			local b =newObject("showinfoitem",parent)
			b.transform:GetComponent("Text").text=s
		end
	end 
end


--改变状态
function C:ChangeStatus(time)
	if time then
		if time>time_during * 3600 and self.b_status~= button_status[2] and self.data and self.data.is_vow==1 then 
			self.b_status=button_status[2]
			self.Button.gameObject.transform:GetComponent("Image").sprite=GetTexture("gy_46_15")
			self.Button.enabled=false
			self.b_status= button_status[2]
			self.Timer.gameObject:SetActive(true)
			--不可领取状态
		elseif time >0 and time <=time_during * 3600 and  self.b_status~= button_status[3] and self.data and self.data.is_vow==1 then
			self.Button.gameObject.transform:GetComponent("Image").sprite=GetTexture("gy_46_14")
			self.Button.enabled=true
			self.b_status= button_status[3]
			self.Timer.gameObject:SetActive(false)
			--免费领取状态
		elseif time <=0 and  self.b_status~= button_status[4] and self.data and self.data.is_vow==1  then 
			self.Button.gameObject.transform:GetComponent("Image").sprite=GetTexture("gy_46_16")
			self.Button.enabled=true
			self.b_status= button_status[4]
			self.Timer.gameObject:SetActive(false)
			--付费领取状态
		end  
	end 
end

--将奖励信息数据转为字符串
function C:data2str(name,award_name)
	--return name.."获得了"..self.config.Info[award_id].info-- body
	if name and award_name then
		return name.."获得了"..award_name-- body
	end
end
--初始化发送请求人数
function C:InitNumHeart()
	Network.SendRequest("query_now_xuyuan_player_num")
	self.heartNum_timer=Timer.New(function ()
		Network.SendRequest("query_now_xuyuan_player_num")
	end,5,-1)
	self.heartNum_timer:Start()
end
--初始化发送许愿墙滚动
function C:InitVowWallHeart()
	Network.SendRequest("xuyuanchi_query_qiang_info")
	self.heartVowWall_timer=Timer.New(function ()
		Network.SendRequest("xuyuanchi_query_qiang_info")
	end,3,-1)
	self.heartVowWall_timer:Start()
end

function C:xuyuanchi_try_get_award_response(_,data)
	dump(data,"<color=red>尝试领取的返回</color>")
	if data and data.result == 0 then
		self.try_shop_id = data.buy_gift_id
		VowMoreAwardPanel.Create(data.common_award_id,data.buy_gift_id)
	end
end

--如果是购买许愿礼包奖励和普通奖励分开发的话，那么奖励也分开弹出
function C:AssetsGetPanelConfirmCallback(data)
	-- if self.award_data and self.try_shop_id and data and data.change_type == "buy_gift_bag_"..self.try_shop_id then
	-- 	Event.Brocast("AssetGet", self.cur_award)
	-- 	self.award_data = nil
	-- 	self.try_shop_id = nil
	-- end
end