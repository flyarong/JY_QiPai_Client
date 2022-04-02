-- 创建时间:2019-05-17
-- Panel:EliminateClearPanel
local basefunc = require "Game/Common/basefunc"

EliminateClearPanel = basefunc.class()
local C = EliminateClearPanel
C.name = "EliminateClearPanel"
C.childobjs={}
local hide
local addmoney
local instance
function C.Create()
	instance = C.New()	
	return instance
end
function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
	self.lister = {}
	self.lister["eliminate_quit_game"]=basefunc.handler(self,self.Close)
	self.lister["eliminate_show_clearpanel"]=basefunc.handler(self,self.eliminate_show_clearpanel)
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

function C:Close()
	self:MyExit()
end

function C:ctor()

	ExtPanel.ExtMsg(self)

	local parent = GameObject.Find("Canvas/LayerLv5").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	self.hide=hide
	self.data={}
	self.addmoney=addmoney
	self.childobjs[1]=tran:Find("gongxi")
	self.childobjs[2]=tran:Find("haoyundao")
	self.childobjs[3]=tran:Find("fadacai")
	self.childobjs[4]=tran:Find("chaojidayingjia")
	self.CloseButton=self.gameObject.transform:Find("Button") 
	self.childobjsgoldtext={}
	for i = 1, #self.childobjs do
		self.childobjsgoldtext[i]=self.childobjs[i].gameObject.transform:Find("GoldText/Text"):GetComponent("Text")
	end
	self.CloseButton.gameObject:SetActive(false)       
	for i = 1, #self.childobjs do
		self.childobjs[i].gameObject:SetActive(false)
	end
	self:MakeLister()
	self:AddMsgListener()
	local ClickTimes=1
	self.CloseButton:GetComponent("Button").onClick:AddListener(function ()
		if  ClickTimes==1 and self.data[1]>2 and self.startmoney<self.data[2] then
		    self.startmoney=self.data[2]
		    ClickTimes= 2
		else
			ClickTimes=1	
	     	if self.hide~=nil then
		      self.hide:Stop()		
	     	end
		    if self.addmoney~=nil then
			  self.addmoney:Stop()
	     	end
		    for i = 1, #self.childobjs do
			  self.childobjs[i].gameObject:SetActive(false)
			end  
			 Event.Brocast("eliminate_can_aoto",true)
			self.CloseButton.gameObject:SetActive(false) 
			if self.soundlv3 then
				soundMgr:CloseLoopSound(self.soundlv3)
				self.soundlv3 = nil
				print("<color=red>--關閉音效-----</color>")
			end	
			if self.soundlv4 then
				dump(self.soundlv4, "<color=red>self.soundlv4</color>")
				soundMgr:CloseLoopSound(self.soundlv4)
				self.soundlv4 = nil
				print("<color=red>--關閉音效-----</color>")
			end	
	    end
		
	end)
end
--展示结算界面  data包含一个用int代表的结算类型，一个int代表的得分
function C:eliminate_show_clearpanel(_,data)
	if data[1]==1 then
		self.hidetime=2
		if data[2]==0 then
		self.hidetime=1
		end
		self.soundlv1=ExtendSoundManager.PlaySound(audio_config.xxl.bgm_xxl_jiangli1.audio_name, 1, function ()
			self.soundlv1 = nil
		end)
		
	end
	if data[1]==2 then
		self.hidetime=3
		ExtendSoundManager.PlaySound(audio_config.xxl.bgm_xxl_jiangli2.audio_name)
		

	end
	if data[1]==3 then
		self.hidetime=8
		self.soundlv3 = nil
        self.soundlv3=ExtendSoundManager.PlaySound(audio_config.xxl.bgm_xxl_jiangli3.audio_name, 1, function ()
			self.soundlv3 = nil
		end)
		ExtendSoundManager.PauseSceneBGM()

	end
	if data[1]==4 then
		self.hidetime=8
		self.soundlv4 = nil
		self.soundlv4=ExtendSoundManager.PlaySound(audio_config.xxl.bgm_xxl_jiangli4.audio_name, 1,function(  )
			self.soundlv4 = nil
		end)
		ExtendSoundManager.PauseSceneBGM()

	end
	self.data=data
	self.CloseButton.gameObject:SetActive(true)   
	dump({data[1],data[2]},"<color=red>-------------结算界面data-----------</color>")
	if data[1]==0    then 
		return 
	end	
	if data[2]==nil then
	    data[2]=0
	end
	--self.childobjs[data[1]].gameObject.transform:Find("GoldText"):GetComponent("Animator").speed=1
    self.childobjs[data[1]].gameObject:SetActive(true)
	if self.addmoney then	 
	  self.addmoney:Stop()
	end
	self.addmoney=nil
	--动画间隔时间
	local t=0.03;
	--动画开始时，显示多少金币
	local x=1/4;
	--动画开始时候的金币数量
	self.startmoney = data[2]*x
	--动画持续时间
	local animtime=4
	if  data[1]<3 then
		self.startmoney=data[2]
		self.childobjsgoldtext[data[1]].text= string.format("%.0f", data[2]) 
	end
	--结算时候数字跳动动画
	
	-- self.animspeed=self.childobjs[data[1]].gameObject.transform:Find("GoldText"):GetComponent("Animator")
	-- self.animspeed.speed=0.1
	if self.childobjs[data[1]].gameObject.transform:Find("lamps"):GetComponent("Animator") ~=nil then
	   self.yellowlamp=self.childobjs[data[1]].gameObject.transform:Find("lamps"):GetComponent("Animator")
	   self.yellowlamp.speed=0.1
	else
	   self.yellowlamp.speed=0
	end	
	local index =0


	self.shandiananim=self.transform:Find("chaojidayingjia/GoldText/shandian"):GetComponent("ParticleSystem")
	self.jingbi4=self.transform:Find("chaojidayingjia/chaojiyingjia_xunhuan/xing/jingbi"):GetComponent("ParticleSystem")
	self.jingbi3=self.transform:Find("fadacai/goodluck_xunhuan/xing/jingbi2"):GetComponent("ParticleSystem")
	self.addmoney=Timer.New(
		function ()
		    index=index+1
			if self.startmoney>=data[2]*0.9 or index >=animtime/t then
				if  data[1]==4 then 
					self.shandiananim:Stop()
					self.jingbi4:Stop()
				end
				if data[1]==3 then
					self.jingbi3:Stop() 
				end
				self.addmoney:Stop() 
				self.childobjsgoldtext[data[1]].text=data[2]		
				--self.animspeed.speed=0			
				self.yellowlamp.speed=1.8
				self.CloseButton.gameObject:SetActive(true)						 
				self.childobjs[data[1]].gameObject.transform:Find("GoldText").transform.localScale.x=0.5	
				dump(self.childobjs[data[1]].gameObject.transform:Find("GoldText").transform.localScale.x,"<color=red>--------缩放--------</color>")				
				self.childobjs[data[1]].gameObject.transform:Find("GoldText").transform.localScale.y=0.5	
				return	  
			end
			self.startmoney=(1-x)*data[2]/(animtime/t)+self.startmoney
			if self.yellowlamp.speed>=24 then
				-- self.animspeed.speed=24
				 self.yellowlamp.speed=24
			else	     
			-- self.animspeed.speed=self.animspeed.speed+t*8
			self.yellowlamp.speed=self.yellowlamp.speed+t*8
		    end
			self.childobjsgoldtext[data[1]].text= string.format("%.0f", self.startmoney) 
		end,t,animtime/t)
	self.addmoney:Start()
	if self.hide~=nil then
		self.hide:Stop()
	end
	self.hide=nil
	--自动隐藏面板
	-- self.hidetime=8
	-- if data[1]<3 then
	--    self.hidetime=2
	--    if data[2]==0 then
	--    self.hidetime=1
	--    end
	-- end
    self.hide = Timer.New(function ()
		for i = 1, #self.childobjs do
			self.childobjs[i].gameObject:SetActive(false)
		end
		self.CloseButton.gameObject:SetActive(false)
		Event.Brocast("eliminate_can_aoto",true)
        if self.soundlv3 then
			soundMgr:CloseLoopSound(self.soundlv3)
			self.soundlv3 = nil
		end	
		if self.soundlv4 then
			soundMgr:CloseLoopSound(self.soundlv4)
			self.soundlv4 = nil
		end	
	end ,self.hidetime, 1)
    self.hide:Start()
end
