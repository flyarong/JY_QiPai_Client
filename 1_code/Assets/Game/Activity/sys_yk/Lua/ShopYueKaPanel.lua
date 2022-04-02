-- 创建时间:2019-07-08
-- Panel:ShopYueKaPanel
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

ShopYueKaPanel = basefunc.class()
local C = ShopYueKaPanel
C.name = "ShopYueKaPanel"
local config
local shopid_list = {10002,10003,10004}
function C.Create(onlogin,backcall,_type,parent)
	return C.New(onlogin,backcall,_type,parent)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
	self.lister = {}
	self.lister["ExitScene"] = basefunc.handler(self, self.MyExit)
	self.lister["EnterBackGround"] = basefunc.handler(self, self.onEnterBackGround)
	
	self.lister["sys_yk_manager_yueka_upgrade_asset"]=basefunc.handler(self,self.GetUpShopLevelAwards)
	self.lister["sys_yk_manager_yueka_base_info"]=basefunc.handler(self,self.onGetInfo)
	self.lister["sys_yk_manager_yueka_base_info"]=basefunc.handler(self,self.onGetInfo)

	self.lister["sys_yk_manager_task_change"] = basefunc.handler(self, self.handle_one_task_data_response)
	self.lister["sys_yk_manager_task_change"]=basefunc.handler(self, self.handle_one_task_data_response)
end

function C:handle_one_task_data_response(data)
	if  not IsEquals(self.gameObject) then 
		return 
	end
	--dump(data,"<color=red>------月卡任务信息-------</color>")
	self.IsGetAward=false
	local b1=false
	local b2=false
	if  not IsEquals(self.gameObject) then 
		return 
	end 
	if data and data.id==65 then 
		local b
		b  = basefunc.decode_task_award_status(data.award_get_status)
		b  = basefunc.decode_all_task_award_status(b,data,1)
		--(b[1])
		if b[1]==2 then 
			b1=true
		end 
	end
	if data and data.id==66 then
		local b
		b  = basefunc.decode_task_award_status(data.award_get_status)
		b  = basefunc.decode_all_task_award_status(b,data,1)
		if b[1]==2 then 
			b2=true
		end  
	end  
	self.IsGetAward=(b1 or b2)
	SYSYKManager.IsLJ = not self.IsGetAward
	--(self.IsGetAward,"<color=red>--这里是83行--</color>")
	self:GetTimes()
	Event.Brocast("JYFLInfoChange")
end

function C:onGetInfo(data)
	dump(data,"<color=red>------月卡數據------</color>")
	if  not IsEquals(self.gameObject) then 
		return 
	end 
	self.data=data
	if data  then 
		self.overtime = 0
		if data.buy_time~=nil and data.task_over_time ~=nil  then
			self.overtime=data.task_over_time
			self.buytime=data.buy_time							
		end 
		if data.server_time~=nil then
			self.servertime=data.server_time		
		else
			self.servertime=os.time()
		end
		self.Chatime=self.servertime-os.time()
		self:InitTimer(data.buy_time+15*24*60*60-self:C2Stime())
		if data.is_buy_yueka1 == 1 and data.is_buy_yueka2 ==1 and  self:C2Stime()<data.task_over_time  then 
			 self:HideAll()
			 self.GetAward2.gameObject:SetActive(true)
			 self.taskID=66
			 if self.onlogin~=nil and self.onlogin=="OnLogin" then 
				self:MyExit()
			 end 
			--显示每日领取2，走任务66
		elseif  data.is_buy_yueka1==1 and data.is_buy_yueka2 ==0 and self:C2Stime()<data.task_over_time then 			
			 self:HideAll()
			 self.GetAward1.gameObject:SetActive(true)
			 --self.transform:Find("GetAward1").gameObject:SetActive(true)
			 self.taskID=65
			 if self.onlogin~=nil and self.onlogin=="OnLogin" then 
				self:MyExit()
			 end 
			--显示每日领取1,走任务65
		elseif  data.is_buy_yueka2==1 and self:C2Stime()>data.task_over_time then 			
			self:HideAll()
			self.XuFei2.gameObject:SetActive(true)
			-- 提示续费等級2
		elseif data.is_buy_yueka1==1 and data.is_buy_yueka2==0 and self:C2Stime()>data.task_over_time then 
			self:HideAll()
			self.XuFei1.gameObject:SetActive(true)
			-- 提示续费登记1
		elseif data.task_over_time==0 then 
			self:HideAll()
			self.XuFei1.gameObject:SetActive(true)
			-- 提示購買等級1
		end
		if data.is_buy_yueka2== 1 then				 
			Network.SendRequest("query_one_task_data", {task_id = 66})
		end
		if data.is_buy_yueka2== 0 and data.is_buy_yueka1 == 1  then 
			Network.SendRequest("query_one_task_data", {task_id = 65})
		end
		if data.is_buy_yueka2==1 then SYSYKManager.IsBuy2=true else SYSYKManager.IsBuy2=false end 
		if data.is_buy_yueka1==1 then SYSYKManager.IsBuy1=true else SYSYKManager.IsBuy1=false end 
		if (data.is_buy_yueka2 + data.is_buy_yueka1 > 0) and self.overtime > self:C2Stime() then SYSYKManager.IsBuy=true else SYSYKManager.IsBuy=false end 
	end 
	Event.Brocast("JYFLInfoChange")
end

function C:C2Stime()

	return os.time()+ (self.Chatime or 0)
end
function C:HideAll()
	self.XuFei1.gameObject:SetActive(false)
	self.XuFei2.gameObject:SetActive(false)
	self.GetAward1.gameObject:SetActive(false)
	self.GetAward2.gameObject:SetActive(false)
	self.UpLevel.gameObject:SetActive(false)
end



function C:InitTimer(Time)
	self.time=Time
	if  self.update_time then
		self.update_time:Stop()
		self.update_time=nil
	end 
    self.update_time = Timer.New(function ()
		self.time = self.time - 1
		self:UpdateTime()
		end, 1, -1, nil, true)
	self.update_time:Start()
	self:UpdateTime()
end



function C:onEnterBackGround()
	if self.update_time then
		self.update_time:Stop()
	end
	self.update_time = nil
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	if self.backcall then 
		self.backcall()
	end 
	if self.update_time then
		self.update_time:Stop()
	end
	self:RemoveListener()
	destroy(self.gameObject)

	 
end

function C:ctor(onlogin,backcall,_type,parent)

	ExtPanel.ExtMsg(self)

	self.type = _type
	config = SYSYKManager.GetConfig()
	local parent = parent or GameObject.Find("Canvas/LayerLv5").transform
	local obj
	if self.type and self.type == "activity" then
		obj = newObject("ShopYueKaActivityPanel",parent)
	else
		obj = newObject(C.name, parent) 
	end
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	self.onlogin=onlogin
	self.backcall=backcall
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	Network.SendRequest("query_yueka_base_info",nil,"")
end

--得到剩余次数
function C:GetTimes()
	if self.overtime==nil or self.buytime==nil or self.Chatime==nil then 
		return 
	end 


	local base_times=basefunc.get_today_id(self.overtime)-basefunc.get_today_id(self:C2Stime()+3)+1
	local num=0
	num=(30-base_times)
	if num > 7 then 
		num=7
	end 
	self.GetAward1.transform:Find("Up/Text"):GetComponent("Text").text= StringHelper.ToCash((base_times)*30000+num*23334) 

	if   self.IsGetAward  then
		 base_times=base_times-1
	end	
	
	self.SYCS1.text = "领取时间： "..os.date("%Y年%m月%d日",self.buytime).."-"..os.date("%Y年%m月%d日",self.overtime).."(".. "剩余"..base_times.."次"..")"
	self.SYCS2.text = "领取时间： "..os.date("%Y年%m月%d日",self.buytime).."-"..os.date("%Y年%m月%d日",self.overtime).."(".. "剩余"..base_times.."次"..")"

	if 	base_times==0 then
		Event.Brocast("global_hint_state_set_msg", {gotoui = SYSYKManager.key})
		SYSYKManager.IsBuy=false
		if  self.data and self.data.is_buy_yueka2==1 then
			self:HideAll()
			self.XuFei2.gameObject:SetActive(true)
			--新月卡上线了，这个不需要了
			self:MyExit()
		else
			self:HideAll()
			self.XuFei1.gameObject:SetActive(true)
			--新月卡上线了，这个不需要了
			self:MyExit()
		end
	end  
	self.GetAward1:Find("GetButtonMask").gameObject:SetActive(self.IsGetAward)
	self.GetAward2:Find("GetButtonMask").gameObject:SetActive(self.IsGetAward)
	PlayerPrefs.SetInt("YueKa_Times",base_times)
	return  base_times
end

function C:InitUI()
	self.UpLevel=self.transform:Find("UpLevel")
	self.XuFei1=self.transform:Find("XuFei1")
	self.XuFei2=self.transform:Find("XuFei2")
	self.GetAward1=self.transform:Find("GetAward1")
	--(self.GetAward1,"-------1111111-----------------------------")
	self.GetAward2=self.transform:Find("GetAward2")

	--添加按钮
	self.CloseButton=self.transform:Find("CloseButton"):GetComponent("Button")
	self.CloseButton.onClick:AddListener(
		function ()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
			self:MyExit()
		end
	)
	self.BuyButton1=self.transform:Find("XuFei1/BuyButton"):GetComponent("Button")
	self.BuyButton1.onClick:AddListener(
		function ()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
			self:InitConfig(shopid_list[1])
		end
	)
	self.BuyButton2=self.transform:Find("GetAward1/BuyButton"):GetComponent("Button")
	self.BuyButton2.onClick:AddListener(
		function ()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
			self:InitConfig(shopid_list[2])
		end
	)
	self.BuyButton3=self.transform:Find("XuFei2/BuyButton"):GetComponent("Button")
	self.BuyButton3.onClick:AddListener(
		function ()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
			self:InitConfig(shopid_list[3])
		end
	)
	self.GetAward1Button=self.transform:Find("GetAward1/GetButton"):GetComponent("Button")
	self.GetAward1Button.onClick:AddListener(
		function ()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
			self:GetAwards()
		end
	)
	self.GetAward2Button=self.transform:Find("GetAward2/GetButton"):GetComponent("Button")
	self.GetAward2Button.onClick:AddListener(
		function ()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
			self:GetAwards()
		end
	)
	self.GoGoldButton=self.XuFei1.transform:Find("GoGoldButton"):GetComponent("Button")
	self.GoGoldButton.onClick:AddListener(
		function ()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
			self:HideAll()
			self.XuFei2.gameObject:SetActive(true)
		end		
	)
	self.GoBackButton=self.transform:Find("XuFei2/GoBackButton"):GetComponent("Button")
	self.GoBackButton.onClick:AddListener(
		function ()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
			self:HideAll()
			self.XuFei1.gameObject:SetActive(true)
			self.GoGoldButton.gameObject:SetActive(true)
		end
	)
    self.GoBackButton.gameObject:SetActive(config.on[1].ison==1)
	self.confirm_btn.onClick:AddListener(
		function ()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
			self.UpLevel.gameObject:SetActive(false)
			self.GetAward2.gameObject:SetActive(true)
		end
	)
	--添加Text
	
	--升级倒计时
    self.SJDJS=self.transform:Find("GetAward1/BuyButton/Text"):GetComponent("Text")
	--领取的剩余次数 
	self.SYCS1=self.transform:Find("GetAward1/GetTimes/Text"):GetComponent("Text")
	self.SYCS2=self.transform:Find("GetAward2/GetTimes/Text"):GetComponent("Text")
	
	--升级补偿
	self.ALL_SJBC=self.transform:Find("UpLevel/Text"):GetComponent("Text")
	self.SJBC=self.transform:Find("UpLevel/Layer7/Text"):GetComponent("Text")
	self.IFZero=self.transform:Find("UpLevel/Layer7/IFZero"):GetComponent("Text")

	self.jika = self.transform:Find("GetAward2/jika")
	self.jika.gameObject:SetActive(Act_004JIKAManager and not Act_004JIKAManager.getIsBuy())

	self.Award1Text = self.GetAward1.transform:Find("Text")
	self.Award1Text.gameObject.transform.anchorMin = Vector2.New(0.5,0.5)
	self.Award1Text.gameObject.transform.anchorMax  = Vector2.New(0.5,0.5)
	self.Award1Text.gameObject.transform.pivot  = Vector2.New(0.5,0.5)
	self.Award1Text.gameObject.transform.localPosition = Vector2.New(385.1,210.4)
end


function C:InitConfig(shopid)
	if shopid==nil then
		return 
	end 
	self.gift_config = MainModel.GetShopingConfig(GOODS_TYPE.gift_bag,shopid)
	self.status = MainModel.GetGiftShopStatusByID(self.gift_config.id)
	if GameGlobalOnOff.PGPay and gameRuntimePlatform == "Ios" then
		GameManager.GotoUI({gotoui = "sys_service_gzh",goto_scene_parm = "panel",desc="请关注“鲸鱼新家园”公众号获取"..self.gift_config.pay_title})
	else
		PayTypePopPrefab.Create(self.gift_config.id, "￥" .. (self.gift_config.price / 100))
	end
end

--领取升级补偿
function C:GetUpShopLevelAwards(data)
	if  data and data.money_value then
		self:HideAll()
		if data.money_value==0 then 
			self.ALL_SJBC.gameObject:SetActive(false)
			self.SJBC.gameObject:SetActive(false)
			self.UpLevel.transform:Find("Layer7/Image").gameObject:SetActive(false)
			self.UpLevel.transform:Find("Layer7/IFZero").gameObject:SetActive(true)
		end 
		dump(self:GetTimes(),"----升级奖励----</color>")
		self.ALL_SJBC.text="剩余"..(self:GetTimes()*30000).."鲸币每天领取！"
		self.SJBC.text="鲸币 X"..data.money_value
		self.IFZero.text="剩余<color=yellow>"..(self:GetTimes()*30000).."</color>鲸币每天领取！"
		self.UpLevel.gameObject:SetActive(true)
	end 
end

function C:MyRefresh()
	Network.SendRequest("query_yueka_base_info")
end

-- 领取每日奖励
function C:GetAwards()
	if self.taskID == nil then
		return 
	end 
	Network.SendRequest("get_task_award", {id = self.taskID},nil,
	 function ()
		Network.SendRequest("query_one_task_data", {task_id = self.taskID})
	 end
	)
	
end
--是否可以升级贵族礼包
function C:CanUplevel()
	if self.buy_time ~=nil then
		if self.buy_time+24*60*60*15 < self:C2Stime() then
			return false
		end
	end 
	return  true
end
--倒计时计时器
function C:UpdateTime()
	self.BuyButtonMask = self.GetAward1.transform:Find("BuyButtonMask")
	self.BuyButtonMask.transform.sizeDelta = {x = 337.65,y = 126}
	self.BuyButtonMask.transform.localPosition = Vector3.New(391,-198,0)
	self.BuyButtonMask.transform.localScale = Vector3.New(0.7554801,0.7554801,0.7554801)
	if self.time<1 then
		self.time=0
		--print("<color=red>----倒计时结束了-----</color>")
		self.BuyButtonMask.gameObject:SetActive(true)
		--旧版月卡取消升级
		self.BuyButtonMask.gameObject:SetActive(false)
		SYSYKManager.CanBuy2 = false
	else
		self.BuyButtonMask.gameObject:SetActive(false)
		SYSYKManager.CanBuy2 = true
	end 
	
	local str = StringHelper.formatTimeDHMS(self.time)
	if IsEquals(self.SJDJS) then
		self.SJDJS.text =  str
	end
	if self.time <= 0 then
		if self.update_time then
			self.update_time:Stop()
		end
		self.update_time = nil
		--刷新界面
	end
end
