-- 创建时间:2019-06-24
-- Panel:ShareActivityPanel
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

ShareActivityPanel = basefunc.class()
local C = ShareActivityPanel
C.name = "ShareActivityPanel"
local config = GameActivityManager.shareactivitycfg

function C.Create()
	if config.model[1].testmodel==0 then
		local time_start=config.timecfg[1].showtime_begin
		local time_end=config.timecfg[1].showtime_end
		if os.time()>time_end or os.time()<time_start then 
			HintPanel.Create(1, "不在活动时间内")
			return 
		end
    end
	return C.New()
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
	self.lister = {}
	self.lister["model_query_one_task_data_response"] = basefunc.handler(self, self.handle_one_task_data_response)
    self.lister["query_everyday_share_base_info_response"]=basefunc.handler(self,self.on_query_everyday_share_base_info_response)
    self.lister["query_everyday_share_award_log_response"]=basefunc.handler(self,self.on_query_everyday_share_award_log_response)
	self.lister["EnterBackGround"] = basefunc.handler(self, self.MyExit)
	self.lister["ExitScene"] = basefunc.handler(self, self.MyExit)
end

--请求分享人数信息
function C:on_query_everyday_share_base_info_response(_,data)
	if not IsEquals(self.gameObject) then 
		return 
	end
	--dump(data,"测试")
	if data and data.now_player_num and data.is_get_award  then 
	   if data.is_get_award ==1 then 
		  self.HBMask.gameObject:SetActive(true)
		  self.HBima.gameObject:SetActive(false)
	   else
		  self.HBMask.gameObject:SetActive(false)
		  self.HBima.gameObject:SetActive(true)
	   end      --1是领过
	   self.HBimaText.text="当前人数："..data.now_player_num
	   self.HBMaskText.text="当前人数："..data.now_player_num
	else		
		if data.result~=nil then
			--HintPanel.Create(1, error_code[data.result])	
		end
	end
end
--请求分享列表
function  C:on_query_everyday_share_award_log_response(_,data)
	if not IsEquals(self.gameObject) then 
		return 
	end
	if data and  data.result==0  and data.logs~= nil then 
	   --求分享列表
	   for i = 1, #data.logs do
		  local p=newObject("ShareActivityInfoPrefab", self.Node)
		  p.transform:Find("Text"):GetComponent("Text").text="["..data.logs[i].player_name.."]".."获得"..data.logs[1].award_name
	      self.logs[#self.logs+1]=p
		end
		if #self.logs>20 then 
			self.slowUp:Start()
		end 
	end 
end


--每日分享  //4个奖励信息
function C:handle_one_task_data_response(data)
	if not IsEquals(self.gameObject) then 
		return 
	end
	if data and data.id==106 then 
		dump(data,"<color=red>------</color>")
		local b
		b  =basefunc.decode_task_award_status(data.award_get_status)
		b  = basefunc.decode_all_task_award_status(b,data,1)
		if b[1]==0    then 
			self.share_red.gameObject:SetActive(true)
		else
		    self.share_red.gameObject:SetActive(false)
		end
		if os.time()>config.timecfg[1].time_end  then
		    self.share_red.gameObject:SetActive(false)
		end  
	end
	if data and data.id== 107 then
		local b
		b  = basefunc.decode_task_award_status(data.award_get_status)
		b  = basefunc.decode_all_task_award_status(b,data,4)
		--dump(b,"<color=red>-------107-----</color>")
		for i = 1, #b do
			if b[i]==0 then 
				self.AwardChilds[i].transform:Find("Mask").gameObject:SetActive(false)
				self.AwardChilds[i].transform:Find("Button"):GetComponent("Image").sprite=GetTexture("gy_37_15")
				self.AwardChilds[i].transform:Find("Button"):GetComponent("Button").enabled=false
			end
			if b[i]==1 then 
				self.AwardChilds[i].transform:Find("Mask").gameObject:SetActive(false)
				self.AwardChilds[i].transform:Find("Button"):GetComponent("Image").sprite=GetTexture("gy_37_14")
				self.AwardChilds[i].transform:Find("Button"):GetComponent("Button").enabled=true
			end
			if b[i]==2 then 
				self.AwardChilds[i].transform:Find("Mask").gameObject:SetActive(true)
				self.AwardChilds[i].transform:Find("Button"):GetComponent("Image").sprite=GetTexture("gy_35_7_activity_sys_qmfx")
				self.AwardChilds[i].transform:Find("Button"):GetComponent("Button").enabled=false
		   	end     
		end
		if os.time()<config.timecfg[1].time_end then
		 	self.transform:Find("CurrentShareTimes"):GetComponent("Text").text="当前分享:"..data.now_total_process.."次"
		else
			self.transform:Find("CurrentShareTimes"):GetComponent("Text").text="分享活动已结束"
		end

		self.now_total_process=data.now_total_process
			
	end  
end
function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	if self.heart then
		self.heart:Stop()
	end
	if self.Show  then
		self.Show:Stop()
	end 
	if self.slowUp  then
		self.slowUp:Stop()
	end 
	self:RemoveListener()
	destroy(self.gameObject)

	 
end

function C:ctor()

	ExtPanel.ExtMsg(self)

	local parent = GameObject.Find("Canvas/LayerLv3").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	self.logs={}
	LuaHelper.GeneratingVar(self.transform, self)
	self.close_btn.onClick:AddListener(function ()
        self:MyExit()
	end)
	self.hdsj_txt.text="活动时间:"..os.date("%Y.%m.%d", config.timecfg[1].time_begin).."—"..os.date("%Y.%m.%d", config.timecfg[1].time_end)
    self.AwardChilds={}
    for i = 1, 4 do
		self.AwardChilds[#self.AwardChilds+1]=self.transform:Find("Award"..i)
	end
	self.HBMask=self.transform:Find("HBMask")
	self.HBMaskText=self.HBMask.transform:Find("Text"):GetComponent("Text")
	self.HBima=self.transform:Find("HBima")
    self.HBimaText=self.HBima.transform:Find("Text"):GetComponent("Text")
	self.awardbutton1=self.transform:Find("Award1/Button")
	self.awardbutton1:GetComponent("Button").onClick:AddListener(
		function ()
			self:lingjiang(1)			
		end
	)
	self.awardbutton2=self.transform:Find("Award2/Button")
	self.awardbutton2:GetComponent("Button").onClick:AddListener(
		function ()
			self:lingjiang(2)	
		end
	)
	self.awardbutton3=self.transform:Find("Award3/Button")
	self.awardbutton3:GetComponent("Button").onClick:AddListener(
		function ()
			self:lingjiang(3)	
		end
	)
	self.awardbutton4=self.transform:Find("Award4/Button")
	self.awardbutton4:GetComponent("Button").onClick:AddListener(
		function ()
			self:lingjiang(4)	
		end
	)

	self.hdsm_button=self.transform:Find("banner/Describe"):GetComponent("Button")
	self.hdsm_button.onClick:AddListener(
		function ()
			self:showHelp()
		end
	)
	
	self.sharebutton=self.transform:Find("ShareButton"):GetComponent("Button")
	self.sharebutton.onClick:AddListener(
		function ()
			self:goshare()
		end
	)

	self.transform:Find("showinfo/CloseButton"):GetComponent("Button").onClick:AddListener(
		function ()
			self:showinfo_close()
		end
	)
	
	self.LQXQbutton=self.transform:Find("LQXQ")
	self.LQXQbutton:GetComponent("Button").onClick:AddListener(
		function ()
			for i = 1, #self.logs do
				GameObject.Destroy(self.logs[i])
			end
			self.logs={}
			self.transform:Find("showinfo").gameObject:SetActive(true)
			Network.SendRequest("query_everyday_share_award_log",nil,"")
			self:heartShowInfo()			
		end
	)	

	self.chaibutton=self.transform:Find("HBima/chai"):GetComponent("Button")
	self.chaibutton.onClick:AddListener(
		function ()
			self:Chai()
		end
	)
	self.RedPoint=self.transform:Find("ShareButton/Red")
	self.Node=self.transform:Find("showinfo/BG2/Viewport/TaskNode")
	self:slowUpAnim()
	self:MakeLister() 
	self:AddMsgListener()
	if  config.model[1].testmodel==0 then
		if os.time()>config.timecfg[1].time_end then
			self:Heart()   
			self.LQXQbutton.gameObject:SetActive(true)
		else
		    self.LQXQbutton.gameObject:SetActive(false)     
		end
	else
		self.LQXQbutton.gameObject:SetActive(true)
	    self:Heart() 
	end
	self:heartShowInfo()
	Network.SendRequest("query_one_task_data", {task_id = 106})
	Network.SendRequest("query_one_task_data", {task_id = 107})
	Network.SendRequest("query_everyday_share_base_info")
			
end

function C:Heart()
	self.heart =Timer.New(function ()
	     Network.SendRequest("query_everyday_share_base_info")  --请求人数	   
   	end,5,-1,nil,true)
	self.heart:Start()
end
function C:goshare()
	GameManager.GotoUI({gotoui = "share_hall"})
end
function C:showHelp()
	self.introduce=self.transform:Find("Introduce"):GetComponent("Text")
	local  str=
	        "1,达到分享条件即可领取奖励，分享次数可累计;"
	.."\n".."2,仅统计每日首次分享;"
	.."\n".."3,完成12次分享任务即可获得瓜分8888福卡的资格;"
	.."\n".."4,福卡瓜分日期为7月30日12点-7月31日24点;"
	.."\n".."5,本公司保留在法律规定范围内对上述规则解释的权利。"
	self.introduce.text=str
	IllustratePanel.Create({self.introduce}, GameObject.Find("Canvas/LayerLv5").transform)
end
function  C:lingjiang(index) 
	Network.SendRequest("get_task_award_new", {id = 107,award_progress_lv=index})
end

function C:slowUpAnim()
    --dump(self.Node,"---------")
    self.slowUp = Timer.New(
    function()
        self.Node.transform.localPosition = Vector3.New(
		self.Node.transform.localPosition.x,
		self.Node.transform.localPosition.y+1,
		self.Node.transform.localPosition.z);
	end, 0.016, -1,nil,true
	)	
end
function C:heartShowInfo()
	if self.Show  then
		self.Show:Stop()
	end
	self.Show=nil
	self.Show=Timer.New(function ()
			Network.SendRequest("query_everyday_share_award_log")
			self:heartShowInfo()	
	    end
	,12*24*60*60,-1,nil,true)
	self.Show:Start()	
end
function  C:showinfo_close()
	self.transform:Find("showinfo").gameObject:SetActive(false)
	for i = 1, #self.logs do
		GameObject.Destroy(self.logs[i])
	end
	if self.slowUp then 
		self.slowUp:Stop()
	end
	if self.Show then 
		self.Show:Stop()
	end 
	
end
function  C:Chai()
	if self.now_total_process==nil then 
	   return 
	end 
	if self.now_total_process>=12 then  --config.model[1].testmodel==1 then
		local time_start=config.timecfg[1].time_end 
		local time_end=config.timecfg[1].showtime_end
		if os.time()>time_end or os.time()<time_start then 
			if config.model[1].testmodel==0 then 
				HintPanel.Create(1, "恭喜您获得瓜分资格,"..os.date("%m月%d日 %H点",time_start).."后可拆福卡哦!")
				return 
			end 
		end
		--发送Chai福卡请求
		Network.SendRequest("query_everyday_share_award",nil,"正在拆福卡",
			function(data)
				dump(data,"<color=red>--------------</color>")
				if data and data.result==0 then 
				   Network.SendRequest("query_everyday_share_base_info")
				   print("领取成功")
				else 
				   HintPanel.ErrorMsg(data.result)
				end 				
			end)
	else
	    HintPanel.Create(1,"您还差"..(12-self.now_total_process).."次分享可瓜分福卡!")
	end
end
