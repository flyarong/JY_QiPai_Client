-- 创建时间:2019-05-13
-- Panel:New Lua
local basefunc = require "Game/Common/basefunc"

EliminateInfoPanel = basefunc.class()
local M = EliminateInfoPanel
local Des=EliminateDesPrefab
M.name = "EliminateInfoPanel" 
local instance_Info
--得分表--
local scoretabel=
{
	[1]={
     	[3]=0.1,
	    [4]=0.2,
	    [5]=0.5,
	    [6]=1,
	    [7]=1.5,
	    [8]=5
	},
	[2]={
		[3]=0.2,
		[4]=0.5,
		[5]=1,
		[6]=3,
		[7]=6,
		[8]=10	
	},
	[3]={
		[3]=0.5,
		[4]=1,
		[5]=2,
		[6]=5,
		[7]=10,
		[8]=20	
	},
	[4]={
		[3]=1,
		[4]=3,
		[5]=6,
		[6]=12,
		[7]=25,
		[8]=50	
	},
	[5]={
		[3]=4,
		[4]=10,
		[5]=30,
		[6]=60,
		[7]=80,
		[8]=150	
	}
	
}
local isdoublespeed=0
local lister
local AllInfoList={}
function M.Create()
	instance_Info = M.New()
    return instance_Info
end

function M:MakeLister()
	self.lister={}
	self.lister["eliminate_change_speed_response"]=basefunc.handler(self,self.eliminate_change_speed_response)
	self.lister["eliminate_lottery_award_one"]= basefunc.handler(self,self.eliminate_lottery_award_one)
	self.lister["eliminate_lottery_award_all"]=basefunc.handler(self,self.eliminate_lottery_award_all)
	self.lister["eliminate_refresh_yazhu"]=basefunc.handler(self,self.eliminate_refresh_yazhu)
	self.lister["eliminate_quit_game"]=basefunc.handler(self,self.Close)
	self.lister["view_lottery_start"]=basefunc.handler(self,self.FreshList)
	self.lister["view_lottery_end"]= basefunc.handler(self,self.ShowClear)
	self.lister["view_lottery_end_lucky"]=basefunc.handler(self,self.ShowClear)
	self.lister["model_lottery_error"]=basefunc.handler(self,self.eliminate_model_lottery_error)
 end    
function M:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end
--开奖错误
function M:eliminate_model_lottery_error()
    self:FreshList()
end
--一个一个消灭
function  M:eliminate_lottery_award_one(_,data)
	self.Isdxcl=false
	self:DesPrefabInto(data,0)
	self.kuang2:Stop()
	self.kuang:Stop()
	self.xing:Stop()
	self.glow:Stop()
	self.kuang2:Play()
	self.xing:Play()
	self.glow:Play()
	self.kuang:Play()
end

--速度改变
function M:eliminate_change_speed_response(_,data)
	Event.Brocast("eliminate_change_speed_response", "eliminate_change_speed_response", data)
end
--断线重连获取数据
function M:eliminate_lottery_award_all(_,data)
	--dump(data,"<color=red>------断线重连数据-------</color>")
	self.Isdxcl=true
	self:FreshList()	
	for i = 1, #data  do
		self:DesPrefabInto(data[i],1)
	end
	self.gold= EliminateModel.GetAwardMoney()
	self.goldtext.text=StringHelper.ToCash(EliminateModel.GetAwardMoney()) 
end
--展示结算界面
function M:ShowClear() 
	self.goldtext.text=StringHelper.ToCash(EliminateModel.GetAwardMoney()) 
	self.kuang:Stop()
	self.zhegai.gameObject:SetActive(true)
	local score=self:ChooseClearPanel() 
	--dump(EliminateModel.GetAwardMoney(),"<color=red>-------------结算界面data-----------</color>")
	-- print("<color=red>-----yes hit me---------</color>")
	--    dump(EliminateModel.GetAwardRate(),"-----------------------")
	--    dump(self.Allbeishu,"-----------------------")
	--score=4

	if score<5 then
		ExtendSoundManager.PlaySceneBGM(audio_config.xxl.bgm_xxl_beijing.audio_name)
	end
    if self.haveLucky5==true and score>2  then
	   
		if self.waitanimtion~=nil then
		   self.waitanimtion:Stop()
		end
		self.waitanimtion=nil
	    self.waitanimtion=Timer.New(function ()
		Event.Brocast("eliminate_show_clearpanel","eliminate_show_clearpanel",{[1]=score,[2]=EliminateModel.GetAwardMoney()})
		Event.Brocast("eliminate_Refresh_UserInfoGoldText","eliminate_Refresh_UserInfoGoldText")
		self.zhegai.gameObject:SetActive(false)
		end, EliminateModel.GetTime(EliminateModel.cfg.time.eliminate_clear_wait_time), 1)
		self.waitanimtion:Start()
	elseif self.Isdxcl~=true then
		local time=1.4
		if EliminateModel.GetAuto() then
		    time=1.85     
		end	 
        if self.waitanimtion2~=nil then
			self.waitanimtion2:Stop()
		 end
		 self.waitanimtion2=nil
		 self.waitanimtion2=Timer.New(function ()
		 Event.Brocast("eliminate_show_clearpanel","eliminate_show_clearpanel",{[1]=score,[2]=EliminateModel.GetAwardMoney()})
		 Event.Brocast("eliminate_Refresh_UserInfoGoldText","eliminate_Refresh_UserInfoGoldText")
		 self.zhegai.gameObject:SetActive(false)
		 end,time, 1)
		 self.waitanimtion2:Start()
	else
		self.zhegai.gameObject:SetActive(false)
		Event.Brocast("eliminate_show_clearpanel","eliminate_show_clearpanel",{[1]=score,[2]=EliminateModel.GetAwardMoney()})
		Event.Brocast("eliminate_Refresh_UserInfoGoldText","eliminate_Refresh_UserInfoGoldText")	
	end
	Network.SendRequest("query_one_task_data", {task_id = 102})
end
-- --返回一个动画时间
-- function M.ChooseClear()
-- 	if instance_Info then
-- 		local x= instance_Info:ChooseClearPanel()
-- 		if x<3 then
-- 		return 2
-- 		else
-- 		return 4			
-- 		end
-- 	end
-- end
function M:ChooseClearPanel()
	
	local x=EliminateModel.GetAwardRate()
	if      EliminateModel.xiaoxiaole_defen_cfg.dangci[4].min<=x and x<EliminateModel.xiaoxiaole_defen_cfg.dangci[4].max then
		   return 4
	elseif  EliminateModel.xiaoxiaole_defen_cfg.dangci[3].min<=x and x<EliminateModel.xiaoxiaole_defen_cfg.dangci[3].max then
		   return 3 
	elseif  EliminateModel.xiaoxiaole_defen_cfg.dangci[2].min<=x and x<EliminateModel.xiaoxiaole_defen_cfg.dangci[2].max then
		   return 2 
	elseif   EliminateModel.xiaoxiaole_defen_cfg.dangci[1].min<=x and x<EliminateModel.xiaoxiaole_defen_cfg.dangci[1].max then	
		   return 1	 
	else
		   return 1
   end
end

function M.ReturnAward(List)
	if instance_Info then
		return  instance_Info:DesPrefabInto(List,2)
	end
	return 0
end
--返回每次开奖后的所有信息
function  M.SetAllAwardData(eliminate_data)
	dump(eliminate_data,"<color=red>----获取开奖后的所有信息------- </color>")
	instance_Info.haveLucky=false
	instance_Info.haveLucky5=false
	local award_data = {}
	award_data.all_del_list = {}
	award_data.win_lucky = {}
	if eliminate_data.result then
		for k,cur_result in pairs(eliminate_data.result) do
			if cur_result.del_list then
				for j,cur_del_list in ipairs(cur_result.del_list) do
					table.insert( award_data.all_del_list, cur_del_list)
				end
			end
			if cur_result.win_lucky then
				award_data.win_lucky = cur_result.win_lucky
			end
		end
	end
	--dump(award_data, "<color=yellow>award_data>>>>>>>>>>>>>>>>>>>></color>")
	local data = award_data
	instance_Info.AllInfoList={}
	instance_Info.AllInfoList.info={}
	--dump(data,"<color=red>----测试----</color>")
	if data.win_lucky.win_list~=nil and  #data.win_lucky.win_list==1 and  #data.win_lucky.win_list[1]>3 then
	   --是否有4个或以上的lucky
		instance_Info.haveLucky=true
		dump(instance_Info.haveLucky,"----------------")
	   --是否有5个lucky
		if #data.win_lucky.win_list[1]>4 then
		   instance_Info.haveLucky5=true
	   end
	   
	print("<color=red>------有4个或以上lucky---------</color>")
	end
   for i = 1, #data.all_del_list do
		
		local one={
			id=0,
			num=0,
			jb=0,
			bs=0,
			islucky=0}
		one.id=data.all_del_list[i][1].id
		one.num=#data.all_del_list[i]
		one.jb=instance_Info:DesPrefabInto(data.all_del_list[i],2)
		one.bs=instance_Info:DesPrefabInto(data.all_del_list[i],3)
		--dump(instance_Info:DesPrefabInto(data.all_del_list[i],3),"--------------------")
		one.islucky=instance_Info:IsLuckyList(data.win_lucky.win_list,data.all_del_list[i])
		table.insert(instance_Info.AllInfoList.info,one) 
	end	
	dump(instance_Info.AllInfoList,"<color=red>-----整理后的数据------</color>")
	return  instance_Info.AllInfoList
end
--是否是lucky
function M:IsLuckyList(luckymap,isluckymap)
	-- dump(luckymap,"------luckymap----")
	-- dump(isluckymap,"------isluckymap----")
	if not luckymap then return 0 end
	  for j = 1 ,  #luckymap do
		  for i = 1, #isluckymap do
			  if luckymap[j][1].x==isluckymap[i].x and luckymap[j][1].y==isluckymap[i].y then
				  return 1
			  end
		  end
	  end
	return 0
end
--整理数据并且创建消灭后的小物体
function M:DesPrefabInto(_data,index)
	--index=0单个物体创建
	--index=1所有物体创建
	--index=2返回单个金币
	--index=3返回单个倍率
	--改过一次拆分数据的方式，所以可以不用再次整理数据了，整理数据已经在model完成
	--dump(_data,"data>>>>>>>>>>>>>>>>>>>>>>>ZLSJ0>>>>>>>>>>>>>>>>>>>>>>>>>>>>>")
	local data = {}
	if _data.cur_del_list then
	   data=_data.cur_del_list
	else
		data = _data
	end
	--dump(data,"data>>>>>>>>>>>>>>>>>>>>>>>ZLSJ>>>>>>>>>>>>>>>>>>>>>>>>>>>>>")
	if data[1].id==nil then	
	return
	end 
	local Score=0
	local Beilv=0
	--dump(data,"<color=red>--------------小物体信息-------------</color>")
	local redata={} 
	self.scoretabel = self.scoretabel or {}
	for  i = 1, #self.scoretabel do
         redata[i]=0
	end
	for i = 1, #self.scoretabel do
	   for j=1, #data do		    
			if data[j].id==i then
               redata[i]=redata[i]+1
		    end
	   end	
	end	

	for i = 1, #redata do	
		if  redata[i]~=0 then
			--dump(_data.type,"<color=red>------data.type1--------</color>")
			if index==0 or index ==1 then
				--dump(_data.type,"<color=red>------data.type2--------</color>")
			if  _data.type then
				--(_data.type,"<color=red>------data.type3--------</color>")
				if _data.type==EliminateModel.eliminate_enum.nor then	
				local des=Des.Create(i,"x"..redata[i],index)
				self.profablist[#self.profablist+1]=des	
				elseif _data.type==EliminateModel.eliminate_enum.del_type then
				local des=Des.Create(_data.id,"同类暴击",index)   
				self.profablist[#self.profablist+1]=des	
				elseif _data.type==EliminateModel.eliminate_enum.clear_all then				
				local des=Des.Create(_data.id,"全屏暴击",index) 
				self.profablist[#self.profablist+1]=des	  
			    end						
			end
			end
			local x=redata[i]
			if redata[i]>8 then
			      x=8
			end
			--self.goldtext.text=StringHelper.ToCash(EliminateModel.GetAwardMoney()) 
			--暂时先自己算断线重连的钱  true then--
			if   index==0  then-- index==0 then		
				if instance_Info.haveLucky then
					for i = 1, #instance_Info.AllInfoList.info do
						 if instance_Info.AllInfoList.info[i].islucky==0 then 
						     self.normal=self.normal+instance_Info.AllInfoList.info[i].jb 
						 else
						    self.luckindex=i
						 end						 
					end		
					if EliminateModel.GetAwardMoney() then
						self.luck=EliminateModel.GetAwardMoney()-self.normal
					end			
				end	
				if self.luckindex==#self.profablist and  instance_Info.haveLucky  then
					self:AddGold(self.luck)	
				else
					--dump(self.yazhu[i]*self.scoretabel[i][x],"<color=red>................qian.............</color>")							  				
				    self:AddGold(self.yazhu[i]*self.scoretabel[i][x])	
				    self.Allbeishu=self.Allbeishu+self.scoretabel[i][x]	
				end  		
			end
            if   index==1 then
				  self.Allbeishu=self.Allbeishu+self.scoretabel[i][x]		
			end
			if  index==2 then
			Score=Score+self.yazhu[i]*self.scoretabel[i][x]
			end
			if  index==3  then 
			Beilv=Beilv+self.scoretabel[i][x]
            end  
		end
	end
	if index==2 then
	   return  Score
	end
	if index==3 then
       return  Beilv
	end
end
function M:AddGold(S)
	if self.gold~=nil then 
	   self.gold=self.gold+S
	   if  self.gold>=EliminateModel.GetAwardMoney() then	  
		    self.gold=EliminateModel.GetAwardMoney()
	   end
	    self.goldtext.text=StringHelper.ToCash(self.gold)    	   
	end
end

--清空列表
function  M:FreshList()
	print("清空列表")
	for i = 1, #self.profablist do
		--GameObject.Destroy(self.profablist[i].gameObject)
		self.profablist[i].Close()
		GameObject.Destroy(self.profablist[i].gameObject)
	end
	self.profablist = {}
	self.gold=0
	self.Allbeishu=0
	self.goldtext.text=0
	self.normal=0
	self.luck=0
    self.luckindex=0	
end

function  M:OnTest2Click()
	
	Des.Create(3,5,1)
	Des.Create(2,2,1)
	Des.Create(4,21,1)
	Des.Create(5,2,1)
	Des.Create(3,6,1)

end
function  M:OnTestClick()
	
    Des.Create(3,1,0)

end
function M:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function M:MyExit()
	if self.waitanimtion2~=nil then
		self.waitanimtion2:Stop()
	end
	self:RemoveListener()
    destroy(self.gameObject)
end

function M:Close()
	self:MyExit()
end
function M:ctor()

	ExtPanel.ExtMsg(self)

	self.profablist={}
	self.gold=0
	self.yazhu={
		[1]=0,
		[2]=0,
		[3]=0,
		[4]=0,
		[5]=0,		
	}
	self.Allbeishu=0
	self.scoretabel=scoretabel
	self.parent = GameObject.Find("Canvas/GUIRoot").transform
	self.gameObject = newObject(M.name, self.parent)
	self.gold=0
	self.haveLucky=false
	self.haveLucky5=false
	self.AllInfoList={
	}
	self.goldtext=GameObject.Find("Canvas/GUIRoot/EliminateInfoPanel/bgs/GoldInfo/GoldText"):GetComponent("Text")
	self.kuang2=self.gameObject.transform:Find("kuang/kuang2"):GetComponent("ParticleSystem")
	self.kuang=self.gameObject.transform:Find("kuang/kuang"):GetComponent("ParticleSystem")
	self.xing=self.gameObject.transform:Find("kuang/xing"):GetComponent("ParticleSystem")
	self.glow=self.gameObject.transform:Find("kuang/glow"):GetComponent("ParticleSystem")
	self.zhegai=self.gameObject.transform:Find("zhegai")
	self.zhegai.gameObject:SetActive(false)
	self:MakeLister()
	self:AddMsgListener()
	----
	--[[local button1 =self.gameObject.transform:Find("Test"):GetComponent("Button")
	EventTriggerListener.Get(button1.gameObject).onClick = basefunc.handler(self, self.OnTestClick)
	local button2 =self.gameObject.transform:Find("Test2"):GetComponent("Button")
	EventTriggerListener.Get(button2.gameObject).onClick = basefunc.handler(self, self.OnTest2Click)--]]
	
	--帮助界面创建
	EliminateHelpPanel.Create()	
	self.gameObject.transform:Find("Help"):GetComponent("Button").onClick:AddListener(function ()
		EliminateHelpPanel.ShowPanel()	
	end)
 
	self:InitUI()
	self:InitDeFenBiao()
	Network.SendRequest("query_one_task_data", {task_id = 102})
end

function M:InitUI()
	EliminateMoneyPanel.Create()
end
function M:InitDeFenBiao()
	self.scoretabel={}
	for key,value in pairs(EliminateModel.xiaoxiaole_defen_cfg.defenbiao) do
	    self.scoretabel[value.ys]={}
	end
	for key, value in pairs(EliminateModel.xiaoxiaole_defen_cfg.defenbiao) do  
		--self.scoretabel[value.ys]={}
		self.scoretabel[value.ys][value.lj]=value.bl	
	end 
	dump(self.scoretabel,"<color=red>--------得分表--------------</color>")
end
function M:eliminate_refresh_yazhu(_,data)
	self.yazhu[data[1]]=data[2]		
	EliminateModel.SetBet(self.yazhu)
end



