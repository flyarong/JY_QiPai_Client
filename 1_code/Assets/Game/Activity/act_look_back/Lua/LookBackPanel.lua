-- 创建时间:2019-08-02
-- Panel:New Lua
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

 LookBackPanel = basefunc.class()
 local C = LookBackPanel
 C.name = "LookBackPanel"
 
 local config = VIPManager.GetVIPCfg() --  HotUpdateConfig("Game.CommonPrefab.Lua.vip_showinfo_cfg")
 local instance
 
 function C.Create(callback)
	 if  instance then 
		 return instance
	 else
		 return C.New(callback)
	 end 
	 
 end
 
 function C:AddMsgListener()
	 for proto_name,func in pairs(self.lister) do
		 Event.AddListener(proto_name, func)
	 end
 end
 
 function C:MakeLister()
	 self.lister = {}
	 self.lister["znq_look_back_kaijiang_response"]=basefunc.handler(self,self.OnGetInfo)
	 self.lister["query_znq_look_back_kaijiang_base_info_response"]=basefunc.handler(self,self.OnGetInfo)
 end
 
 function C:RemoveListener()
	 for proto_name,func in pairs(self.lister) do
		 Event.RemoveListener(proto_name, func)
	 end
	 self.lister = {}
 end
 
 function C:MyExit()
	 self:RemoveListener()
	 if self.Update_Timer then 
		 self.Update_Timer:Stop()
	 end 
	 destroy(self.gameObject)
 end
 
 function C:ctor(callback)

	ExtPanel.ExtMsg(self)

	 local parent = GameObject.Find("Canvas/LayerLv3").transform
	 local obj = newObject(C.name, parent)
	 local tran = obj.transform
	 self.transform = tran
	 self.gameObject = obj
	 self.canMove=true
	 self.index=1
	 self.callback=callback
	 self:MakeLister()
	 self:AddMsgListener()	
	self:InitUI()
	self.CloseButton=self.transform:Find("CloseButton"):GetComponent("Button")
	self.CloseButton.onClick:AddListener(
		function ()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
			if self.callback then 
				self.callback()
			end 
			self:MyExit()			
		end
	)
	DOTweenManager.OpenPopupUIAnim(self.transform)
 end
 

 
 function C:InitTimer()
	 if self.Update_Timer then 
		 self.Update_Timer:Stop()
	 end
	 self.Update_Timer=Timer.New(function ()		
		 self:SetRightAnim()
	 end,0.016,-1,nil,true) 	
	 self.Update_Timer:Start()
 end
 
 --矫正动画
 function C:SetRightAnim()
	 if self.index==1 then
		 self.LeftButton.gameObject:SetActive(false)
		 self.RightButton.gameObject:SetActive(true)
	 end
	 if self.index==2  then
		 self.RightButton.gameObject:SetActive(false)
		 self.LeftButton.gameObject:SetActive(true)
	 end
	--  if   1 <self.index and  self.index < 2  then
	-- 	 self.LeftButton.gameObject:SetActive(true)
	-- 	 self.RightButton.gameObject:SetActive(true)
	--  end 
	 if self.canMove == false then 
		 return 
	 end 
	 local data=self:GetNearNode()
	 self:MoveAnim(data)
 end
 
 function C:SetIndex(index)
	 self.index=index
	 self.Content.transform.localPosition=Vector3.New(-self.ChildSize.x*(self.index-1),self.Content.transform.localPosition.y,self.Content.transform.localPosition.z)
 end
 
 function C:MoveAnim(data)
	 if data==nil then 
		 return 
	 end 
	 if math.abs(-self.Content.transform.localPosition.x-self.ChildSize.x*data.ind)>1 then 
		 if data.direction=="left" then 
			 self.Content.transform:Translate(Vector3.left * 32 )
		 elseif  data.direction=="right" then 
			 self.Content.transform:Translate(Vector3.right * 32 )
		 end 
	 end 
 end
 -- end
 --当前位置是-self.ChildSize.x*(self.index-1)，所以向左就是（self.index-1）-1，向右则是（self.index-1）+1
 function C:GoRightAnim()
	 if  self.index<=9 then 
		 self.canMove=false
		 local seq = DG.Tweening.DOTween.Sequence()
		 local tweenKey = DOTweenManager.AddTweenToStop(seq)
		 seq:Append(self.Content.transform:DOLocalMoveX(-self.ChildSize.x*(self.index), 0.2):SetEase(DG.Tweening.Ease.Linear))--OutBack
		 seq:OnKill(     
			 function()
			 DOTweenManager.RemoveStopTween(tweenKey) 
			 self.canMove=true
			 SafaSetTransformPeoperty(self.Content.transform, "localPosition" ,Vector3.New(-self.ChildSize.x*(self.index),self.Content.transform.localPosition.y,self.Content.transform.localPosition.z)) 
		 end)
	 end 	
 end
 
 function C:GoLeftAnim()
	 if  self.index>=2 then 
		 self.canMove=false
		 local seq = DG.Tweening.DOTween.Sequence()
		 local tweenKey = DOTweenManager.AddTweenToStop(seq)
		 seq:Append(self.Content.transform:DOLocalMoveX(-self.ChildSize.x*(self.index-2), 0.2):SetEase(DG.Tweening.Ease.Linear))--OutBack
		 seq:OnKill(     
			 function()--
			 DOTweenManager.RemoveStopTween(tweenKey) 
			 self.canMove=true
			 SafaSetTransformPeoperty(self.Content.transform, "localPosition" ,Vector3.New(-self.ChildSize.x*(self.index-2),self.Content.transform.localPosition.y,self.Content.transform.localPosition.z)) 
		 end)
	 end 	
 end
 function C:OnBeginDrag()
	 self.canMove=false
	 --print("关闭")
 end
 function C:OnEndDrag()
	 self.canMove=true
	 --print("开启")
 end


 function C:OnGetInfo(_,data)
	dump(data,"<color=#D84017FF>OnGetInfo-------------</color>") 
	self:InitChild()
 end

 function C:InitUI()
	 --self.Now_text=self.transform:Find(""):GetComponent("Text")
	 self.ChildPrefab=self.transform:Find("ChildPrefab")
	 self.ChildSize={
		 x=self.ChildPrefab.rect.width,
		 y=self.ChildPrefab.rect.height,
	 }
	 self.Content=self.transform:Find("Scroll View/Viewport/Content")
	  EventTriggerListener.Get(self.Content.parent.parent.gameObject).onDown = basefunc.handler(self, self.OnBeginDrag)
	  EventTriggerListener.Get(self.Content.parent.parent.gameObject).onUp = basefunc.handler(self, self.OnEndDrag)
	--  self.CloseButton=self.transform:Find("CloseButton"):GetComponent("Button")
	--  self.CloseButton.onClick:AddListener(
	-- 	 function ()
	-- 		 ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
	-- 		 self:MyExit()
	-- 	 end
	--  )
	 self.RightButton=self.transform:Find("RightButton"):GetComponent("Button")
	 self.RightButton.onClick:AddListener(
		 function ()
			 ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
			 self:GoRightAnim()
		 end
	 )
	 self.LeftButton=self.transform:Find("LeftButton"):GetComponent("Button")
	 self.LeftButton.onClick:AddListener(
		 function ()
			 ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
			 self:GoLeftAnim()
		 end
	 )
	 self.ChildPrefab1=self.Content.transform:Find("ChildPrefab1")
	 self.ChildPrefab2=self.Content.transform:Find("ChildPrefab2")
	 self.ChildPrefab3=self.Content.transform:Find("ChildPrefab3")
	 self:InitTimer()
	 self:InitChild()
 end
 
 
 --生成子物体
function C:InitChild()
	if not  IsEquals(self.gameObject) then
		return 
	end 
	self.basedata=ActivityYearModel.GetLookbackBaseData()
	self.kaijiangdata=ActivityYearModel.GetLookbackKaiJiangData()
	dump(self.basedata,"<color=red>-------------------</color>")
	dump(self.kaijiangdata,"<color=red>-------------------</color>")
	if self.basedata==nil or self.kaijiangdata==nil or self.basedata.result ~= 0  then 
		self:MyExit()
		return 
	end
	self.nina_text=self.ChildPrefab1:Find("nian"):GetComponent("Text")
	self.yue_text=self.ChildPrefab1:Find("yue"):GetComponent("Text")
	self.ri_text=self.ChildPrefab1:Find("ri"):GetComponent("Text")
	self.likegame_text=self.ChildPrefab1:Find("Text_2"):GetComponent("Text")
	self.day_text=self.ChildPrefab1:Find("Text_1"):GetComponent("Text")
	self.nina_text.text=os.date("%Y",self.basedata.player_data.first_login_time)
	self.yue_text.text=tonumber(os.date("%m",self.basedata.player_data.first_login_time)) 
	self.ri_text.text=tonumber(os.date("%d",self.basedata.player_data.first_login_time))
	self.day_text.text=self.basedata.player_data.login_day
	self.likegame_text.text=self.basedata.player_data.like_game_name


	-- self.day1_text=self.ChildPrefab2:Find("day1"):GetComponent("Text")
	-- self.day2_text=self.ChildPrefab2:Find("day2"):GetComponent("Text")
	-- self.max_win_game_text=self.ChildPrefab2:Find("Ts/Text2/Text2"):GetComponent("Text")
	-- self.MaxMoney=self.ChildPrefab2:Find("MaxMoney"):GetComponent("Text")
	-- self.WinMoney=self.ChildPrefab2:Find("WinMoney"):GetComponent("Text")
	-- self.once_win_most_win_money_text=self.ChildPrefab2:Find("WinMoney"):GetComponent("Text")
	-- self.day1_text.text="<color=#D84017FF>"..os.date("%Y",self.basedata.player_data.first_login_time).."</color>年".."<color=#D84017FF>"..tonumber(os.date("%m",self.basedata.player_data.first_login_time)).."</color>月"
	-- .."<color=#D84017FF>"..tonumber(os.date("%d",self.basedata.player_data.first_login_time)).."</color>日"
	-- .."\n".."我的最高鲸币数："
	-- self.day2_text.text="<color=#D84017FF>"..os.date("%Y",self.basedata.player_data.once_win_most_time).."</color>年".."<color=#D84017FF>"..tonumber(os.date("%m",self.basedata.player_data.once_win_most_time)).."</color>月"
	-- .."<color=#D84017FF>"..tonumber(os.date("%d",self.basedata.player_data.once_win_most_time)).."</color>日"
	-- self.MaxMoney.text= StringHelper.ToCash(self.basedata.player_data.most_money_time) 
	-- self.max_win_game_text.text=self.basedata.player_data.once_win_most_game_name
	-- self.once_win_most_win_money_text.text=self.basedata.player_data.once_win_most_win_money

	self.LFL=self.transform:Find("RightButton/red")
	self.Money=self.ChildPrefab3:Find("Money")
	self.Mask=self.ChildPrefab3:Find("Mask")
	self.C3Text2=self.ChildPrefab3:Find("Text2")
	self.Money_text=self.Money:Find("MoneyText"):GetComponent("Text")
	self.LFL.gameObject:SetActive(self.kaijiangdata.is_kaijiang==0)
	self.Money.gameObject:SetActive(self.kaijiangdata.is_kaijiang==1)
	self.Mask.gameObject:SetActive(self.kaijiangdata.is_kaijiang==1)
	self.C3Text2.gameObject:SetActive(self.kaijiangdata.is_kaijiang==0)
	self.Money_text.text="鲸币 x"..self.basedata.player_data.award_jingbi
	self.Button=self.ChildPrefab3:Find("Button"):GetComponent("Button")
	self.TeXiao=self.transform:Find("ZNQ_guang_lookback")
	self.Button.onClick:RemoveAllListeners()
	self.Button.onClick:AddListener(
		function ()
			self.TeXiao.gameObject:SetActive(false)
			ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)					
		end
	)
	local parm4,parm5=self:GetImageStr(self.basedata.player_data.like_game_name)
	self.parm={
		self.basedata.player_data.award_jingbi,
		"鲸鱼已陪伴我"..self.basedata.player_data.login_day.."天",
		"曾经单笔赢得",--..--StringHelper.ToCash(self.basedata.player_data.once_win_most_win_money),
		parm4,
		parm5,
		self.basedata.player_data.like_game_name,
	}

	 
end

function C:GetImageStr(game)
	if game=="休闲小游戏" then
		return  "share_12_13","share_12_14"
	elseif game=="麻将" then
		return   "share_12_3","share_12_4"
	elseif game=="斗地主" then
		return   "share_12_1","share_12_2"
	else
		return  "share_12_13","share_12_14"
	end 
end
 
 
 --获取最近的节点
 function C:GetNearNode()
	 if self.canMove ==false then 
		 return 
	 end 
	 for i = 1, #config.dangci do
		 if math.abs(-self.ChildSize.x*(i-1)-self.Content.transform.localPosition.x)<60 then 
			 self.index=i
			 self.Content.transform.localPosition=Vector3.New(-self.ChildSize.x*(self.index-1),self.Content.transform.localPosition.y,self.Content.transform.localPosition.z)
		 end 
 
		 if  self.ChildSize.x*(i-1)< -self.Content.transform.localPosition.x and 
			  -self.Content.transform.localPosition.x<self.ChildSize.x*i then  
				 local b = (self.ChildSize.x*i+ self.Content.transform.localPosition.x)/self.ChildSize.x 
				 if   b <0.49999 and  b >0.02  then				
					 return 	{direction="left",ind=i}   
				 elseif b>0.50001 and b<0.98 then 
					 return  {direction="right",ind=i+1}   					
				 end 				
		 end 
	 end
 
 end