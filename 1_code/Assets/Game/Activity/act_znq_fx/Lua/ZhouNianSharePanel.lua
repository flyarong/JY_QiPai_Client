-- 创建时间:2019-08-15
-- Panel:ZhouNianSharePanel
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

ZhouNianSharePanel = basefunc.class()
local C = ZhouNianSharePanel
C.name = "ZhouNianSharePanel"
C.EndTime=1567602000
C.BeginTime= 1566862200
local  shopid=10011
local  taskid=131
local  shareid=130
local  awardid=132
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
	self.lister["model_task_change_msg"] = basefunc.handler(self, self.handle_task_change)
	self.lister["model_query_one_task_data_response"] = basefunc.handler(self, self.handle_one_task_data_response)
	self.lister["gift_bag_status_change_msg"]=basefunc.handler(self,self.RefreshStages)
end


function C:RefreshStages()
	if not IsEquals(self.gameObject) then 
		return 
	end 
	if self.gift_config then self.status = MainModel.GetGiftShopStatusByID(self.gift_config.id) 
		if  self.status ~= 1 then 
			self.BuyButton.gameObject:SetActive(false)
		end 
	end 	
end



function C:handle_task_change(data)
	if not IsEquals(self.gameObject) then 
		return 
	end 
	if data and data.id == taskid  then
		self:onTaskChange(data)
	end
	if   data and data.id == shareid  then		
		self:onShareChange(data)
	end 
	if   data and data.id == awardid  then
		self:onAwardChange(data)
	end 	
end

function C:onShareChange(data)
	if data and data.award_status ==2 then 
		self.share_red.gameObject:SetActive(false)
	else
		self.share_red.gameObject:SetActive(true)
	end 
	if os.time()>ZhouNianSharePanel.EndTime or os.time()<ZhouNianSharePanel.BeginTime then 
		self.share_red.gameObject:SetActive(false)
	end 
end

function C:onAwardChange(data)
	if data and data.award_status==1 then 
		self.canGetAward=true
		self.MF_red.gameObject:SetActive(true)
	elseif data and  data.award_status ==2 then 
		self.MFButton.gameObject:SetActive(false)
	else
		self.MF_red.gameObject:SetActive(false)
	end 		
end

function C:handle_one_task_data_response(data)
	if not IsEquals(self.gameObject) then 
		return 
	end 
	if data and data.id == taskid  then
		self:onTaskChange(data)
	end
	if   data and data.id == shareid  then
		self:onShareChange(data)
	end 
	if   data and data.id == awardid  then
		self:onAwardChange(data)
	end 
	dump(data,"<color=red>任务ID       </color>"..data.id)
end


function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	self:RemoveListener()
	destroy(self.gameObject)

	 
end

function C:ctor()

	ExtPanel.ExtMsg(self)

	local parent = GameObject.Find("Canvas/LayerLv4").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)	
	self.gift_config = MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, shopid)
	self.canGetAward=false  
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	self:InitAwards()
	self:AddButtonClick()
	if self.gift_config then self.status = MainModel.GetGiftShopStatusByID(self.gift_config.id) 
		if  self.status ~= 1 then 
			self.BuyButton.gameObject:SetActive(false)
		end 
	end 
	Network.SendRequest("query_one_task_data",{task_id = shareid})
	Network.SendRequest("query_one_task_data",{task_id = taskid})
	Network.SendRequest("query_one_task_data",{task_id = awardid})
	-- dump(C,"CCCCCCCCCCCCCCCCCCCCCCCC")
	-- dump(self,"selfselfselfselfselfselfself")
	-- C:InitAwards()
end

function C:InitUI()
	--找面板
	self.LKYQPanel=self.transform:Find("LKYQPanel")
	--找按钮
	self.ShareButton=self.transform:Find("ShareButton"):GetComponent("Button")
	self.BuyButton=self.transform:Find("BuyButton"):GetComponent("Button")
	self.MFButton=self.transform:Find("MFButton"):GetComponent("Button")
	self.HelpButton=self.transform:Find("DescribeButton"):GetComponent("Button")
	self.CloseButton=self.transform:Find("CloseButton"):GetComponent("Button")
	self.LKYQPanel_closebtn=self.LKYQPanel:Find("close_btn"):GetComponent("Button")
	self.LKYQPanel_confirmbtn=self.LKYQPanel:Find("confirm_btn"):GetComponent("Button")
	--找文本
	self.FXtimesText=self.transform:Find("ShareTimesText"):GetComponent("Text")
	self.introduce=self.transform:Find("Introduce"):GetComponent("Text")
end

function C:AddButtonClick()
	self.LKYQPanel_confirmbtn.onClick:AddListener(
		function ()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		end
	)
	self.MFButton.onClick:AddListener(
		function ()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
			if self.canGetAward then 
				Network.SendRequest("get_task_award_new", {id = awardid,award_progress_lv=1})
			else
				self.LKYQPanel.gameObject:SetActive(true)				
			end 
			
		end
	)
	self.LKYQPanel_closebtn.onClick:AddListener(
		function ()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
			self.LKYQPanel.gameObject:SetActive(false)
		end
	)
	self.CloseButton.onClick:AddListener(
		function ()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
			self:MyExit()
		end
	)
	self.BuyButton.onClick:AddListener(
		function ()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
			self:BuyShop()
		end
		
	)
	self.ShareButton.onClick:AddListener(
		function ()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		end
		
	)
	self.HelpButton.onClick:AddListener(
		function ()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
			self:HelpOnClick()
		end
	)
	for i = 1, 3 do
		self.AwardsChild[i].transform:Find("ButtonLQ"):GetComponent("Button").onClick:AddListener(
			function ()
				ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
				Network.SendRequest("get_task_award_new", {id = taskid,award_progress_lv=i})
			end
		)
	end
end

--礼包
function C:BuyShop()
	if  self.gift_config==nil then 
		return 		
		print("<color=red>------------礼包不存在--------</color>")
	end 
	local b1 = MathExtend.isTimeValidity(self.gift_config.start_time, self.gift_config.end_time)
    if b1 then
		if self.status ~= 1 then
			local gift_config = MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, shopid)
			local s1 = os.date("%m月%d日%H点", self.gift_config.start_time)
			local e1 = os.date("%m月%d日%H点", self.gift_config.end_time)
			HintPanel.Create(1, string.format( "您今日已购买过了，请明日再来购买。\n(%s-%s每天可购买1次)",s1,e1))
			return
		end
    else
		HintPanel.Create(1, "抱歉，此商品不在售卖时间内")
		return
    end
 
	if  GameGlobalOnOff.PGPay and gameRuntimePlatform == "Ios" then
		GameManager.GotoUI({gotoui = "sys_service_gzh",goto_scene_parm = "panel",desc="请前往公众号获取"})
	else
		PayTypePopPrefab.Create(self.gift_config.id, "￥" .. (self.gift_config.price / 100))
	end
end

function C:HelpOnClick()
	local  str=
	        "1.鲸鱼万元大奖赛，参与100%有福卡，第一名奖1万元;"
	.."\n".."2.比赛9月4日晚20:30开始报名，21点准时开赛;"
	.."\n".."3.每日首次分享可得1000鲸币，累计分享天数达一定条件还可获得额外奖励，最高可得千元赛门票1张;"
	.."\n".."4.万元赛门票免费拿，活动期间邀请1名新玩家并指导其完成新人福卡第1天任务即可获得免费万元赛门票1张;"
	.."\n".."5.万元赛门票用来参与万元大奖赛报名及预赛复活，门票越多越有机会获得更好名次，赢得万元大奖;"
	self.introduce.text=str
	IllustratePanel.Create({self.introduce}, GameObject.Find("Canvas/LayerLv5").transform)
end


function C:InitAwards()
	--dump(self,"------InitAwards-------")
	self.AwardsChild={}
	for i=1,3 do
		local b=self.transform:Find("Award"..i)
		self.AwardsChild[#self.AwardsChild+1]=b
	end
end


function C:onTaskChange(data)
	if data==nil and data.id~= taskid then return  end 
	local b
	b  = basefunc.decode_task_award_status(data.award_get_status)
	b  = basefunc.decode_all_task_award_status(b,data,3)		
	for i = 1, #b do
		self:ShowButton(self.AwardsChild[i],b[i])
	end
	if data.now_total_process then 
		self.FXtimesText.text="当前已分享："..data.now_total_process.."天"
	end 
end

function C:ShowButton(obj,index)
	if index == 0 then 
		obj.transform:Find("ButtonYLQ").gameObject:SetActive(false)
		obj.transform:Find("ButtonMask").gameObject:SetActive(true)
		obj.transform:Find("ButtonLQ").gameObject:SetActive(false)
	end
	if index == 1 then 
		obj.transform:Find("ButtonYLQ").gameObject:SetActive(false)
		obj.transform:Find("ButtonMask").gameObject:SetActive(false)
		obj.transform:Find("ButtonLQ").gameObject:SetActive(true)
	end  
	if index == 2 then  
		obj.transform:Find("ButtonYLQ").gameObject:SetActive(true)
		obj.transform:Find("ButtonMask").gameObject:SetActive(false)
		obj.transform:Find("ButtonLQ").gameObject:SetActive(false) 	
	end 
end




