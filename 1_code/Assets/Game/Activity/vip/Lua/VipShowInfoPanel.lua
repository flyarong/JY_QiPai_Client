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

VipShowInfoPanel = basefunc.class()
local C = VipShowInfoPanel
C.name = "VipShowInfoPanel"
local ExtM = VIPExtManager
local config
local instance
local Tdata={
	vip_level  =3,
	now_cahrge_value=90,
	now_charge_sum =100,
}

local HGImagelist={
	"vip_tq_icon_hz1",
	"vip_tq_icon_hz2",
	"vip_tq_icon_hz3",
	"vip_tq_icon_hz4",
	"vip_tq_icon_hz5",
	"vip_tq_icon_hz6",
	"vip_tq_icon_hz7",
	"vip_tq_icon_hz8",
	"vip_tq_icon_hz9",
	"vip_tq_icon_hz10",
	"vip_tq_icon_hz11",--new*|
	"vip_tq_icon_hz12",--new*|
}
--
local qudao_tips = {
	[11] = "\n4.成为VIP11立即获得30次至尊礼包领取资格，每日可领1次;\n5.每获得4点财富值增加1次至尊礼包领取资格，上限100次。",
	[12] = "\n4.成为VIP12立即获得30次至尊礼包领取资格，每日可领1次;\n5.每获得5点财富值增加1次至尊礼包领取资格，上限100次。"
}
local normal_tips = {
	[11] = "\n4.成为VIP11立即获得30次至尊礼包领取资格，每日可领1次;\n5.每获得2点财富值增加1次至尊礼包领取资格，上限100次。",
	[12] = "\n4.成为VIP12立即获得30次至尊礼包领取资格，每日可领1次;\n5.每获得3点财富值增加1次至尊礼包领取资格，上限100次。"
}


function C.Create(parm)
	if instance then 
		return instance
	else
		instance = C.New(parm)
		return instance
	end
end

function C.Close()
	if instance then
		instance:MyExit()
	end
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
	self.lister = {}
	self.lister["model_query_vip_base_info_response"]=basefunc.handler(self,self.OnGetInfo)
	self.lister["model_vip_upgrade_change_msg"]=basefunc.handler(self,self.OnRefreshGetInfo)
	self.lister["EnterBackGround"]=basefunc.handler(self,self.MyExit)
	self.lister["EnterScene"]=basefunc.handler(self,self.MyExit)
	self.lister["ExitScene"]=basefunc.handler(self,self.MyExit)
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
	Event.Brocast("TRY_VIP_SHOW_TASK_COLSE")
	destroy(self.gameObject)
	instance = nil

	 
end

function C:ctor(parm)

	ExtPanel.ExtMsg(self)

	self.parm = parm
	config = VIPManager.GetVIPCfg()
	local obj
	local tran
	if self.parm and self.parm.tag == "mini" then
		obj = newObject(self.parm.panel, self.parm.parent)
		tran = obj.transform
	else
		local parent = GameObject.Find("Canvas/LayerLv5").transform
		obj = newObject(C.name, parent)
		tran = obj.transform
	end
	
	self.transform = tran
	self.tips_txt = self.transform:Find("tips_txt"):GetComponent("Text")
	self.gameObject = obj
	self.canMove=true
	self.index=1
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C.Show()
	
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

function C:OnRefreshGetInfo()
	self:OnGetInfo(nil,VIPManager.get_vip_data())
end

function C:OnGetInfo(_,data)
	if IsEquals(self.gameObject)  and data then 	
		self.showlevel=data.vip_level
		if self.showlevel == 0  then 
			self.HGImage.sprite=GetTexture(HGImagelist[1])

		else
			self.HGImage.sprite=GetTexture(HGImagelist[self.showlevel])
		end
		self.HGImage:SetNativeSize()
		self.CurVIPText.text = self.showlevel
		if data.vip_level >= ExtM.GetUserMaxVipLevel() then 
			self.MaxHintText.gameObject:SetActive(true)
			self.JDT.sizeDelta={x=self.JDTlen,y=self.JDT.rect.height}
			self.MoneyRect.gameObject:SetActive(false)
			self.BFBText.text="MAX"
			self.tips_txt.text = ""
		else 
			local now_p
			local total_p
			if config.dangci[self.showlevel+1].total then
				now_p = data.now_charge_sum / 100
				total_p = config.dangci[self.showlevel+1].total
				self.tips_txt.text = ""
			else
				now_p = data.treasure_value 
				total_p = config.dangci[self.showlevel+1].cfz
				self.tips_txt.text = "每赢金100万加1点财富值"
				self.MoneyRect.gameObject:SetActive(false)
			end
			self.MaxHintText.gameObject:SetActive(false)
			self.MoneyText.text=(total_p-now_p)
			self.JDT.sizeDelta={x=(now_p / total_p)*self.JDTlen,y=self.JDT.rect.height}
			self.BFBText.text=StringHelper.ToCash(now_p) .."/"..StringHelper.ToCash(total_p)		
		end
		
		if self.showlevel >= ExtM.GetUserMaxVipLevel() then
			self:SetIndex(self.showlevel)
		else
			self:SetIndex(self.showlevel + 1)
		end
		for i = self.showlevel+2, #self.Childs do
			if i>=7 and i <= 10 then
				self.Childs[i].transform:Find("Text"):GetComponent("Text").text="累计充值".."***".."元即可获得以下特权"
			end
			if i > 10 and self.showlevel < 10 then
				self.Childs[i].transform:Find("Text"):GetComponent("Text").text=""
			end
		end
		

	end 
end

--矫正动画
function C:SetRightAnim()
	if self.index==1 then
		self.LeftButton.gameObject:SetActive(false)
	end
	if self.index == ExtM.GetUserMaxVipLevel()  then --new*|(self.index==10)
		self.RightButton.gameObject:SetActive(false)
	end
	if   1 < self.index and self.index < ExtM.GetUserMaxVipLevel()  then --new*|(self.index<10)
		self.LeftButton.gameObject:SetActive(true)
		self.RightButton.gameObject:SetActive(true)
	end 
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
	if  self.index < ExtM.GetUserMaxVipLevel() then --new*|(self.index<=9)
		self.canMove=false
		local seq = DG.Tweening.DOTween.Sequence()
		local tweenKey = DOTweenManager.AddTweenToStop(seq)
		seq:Append(self.Content.transform:DOLocalMoveX(-self.ChildSize.x*(self.index), 0.2):SetEase(DG.Tweening.Ease.Linear))--OutBack
		seq:OnKill(     
        	function()--这里报过异常
			DOTweenManager.RemoveStopTween(tweenKey) 
			self.canMove=true
			if IsEquals(self.Content) then
				SafaSetTransformPeoperty(self.Content.transform, "localPosition" ,Vector3.New(-self.ChildSize.x*(self.index),self.Content.transform.localPosition.y,self.Content.transform.localPosition.z)) 
        	end
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
        	function()--这里报过异常
			DOTweenManager.RemoveStopTween(tweenKey) 
			self.canMove=true
			if IsEquals(self.Content) then
				SafaSetTransformPeoperty(self.Content.transform, "localPosition" ,Vector3.New(-self.ChildSize.x*(self.index-2),self.Content.transform.localPosition.y,self.Content.transform.localPosition.z)) 
        	end
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
function C:InitUI()
	--self.Now_text=self.transform:Find(""):GetComponent("Text")
	self.CellPre=self.transform:Find("CellPre")
	self.ChildPrefab=self.transform:Find("ChildPrefab")
	self.ChildSize={
		x=self.ChildPrefab.rect.width,
		y=self.ChildPrefab.rect.height,
	}
	self.Content=self.transform:Find("Scroll View/Viewport/Content")
	 EventTriggerListener.Get(self.Content.parent.parent.gameObject).onDown = basefunc.handler(self, self.OnBeginDrag)
	 EventTriggerListener.Get(self.Content.parent.parent.gameObject).onUp = basefunc.handler(self, self.OnEndDrag)
	--  EventTriggerListener.Get(self.Content.gameObject).onDrag = basefunc.handler(self, self.OnBeginDrag)
	-- PointerEventListener.Get(self.Content.gameObject).onDown = function ()
	-- 	self.canMove=false
	-- 	print("按下")
	-- end
	-- PointerEventListener.Get(self.Content.gameObject).onUp = function ()
	-- 	self.canMove=true
	-- 	print("抬起")
	-- end
	if not self.parm or self.parm.tag ~= "mini" then
		self.CloseButton=self.transform:Find("CloseButton"):GetComponent("Button")
		self.CloseButton.onClick:AddListener(
			function ()
				ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
				self:MyExit()
			end
		)
	end
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
	self.UpLevelButton=self.transform:Find("BGTitle/UpLevelButton"):GetComponent("Button")
	self.UpLevelButton.onClick:AddListener(
		function ()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
			-- if self.parm and self.parm.callback then
			-- 	self.parm.callback()
			-- end
			self:MyExit()
			if VIPManager.get_vip_level() < 10 then
				PayPanel.Create(GOODS_TYPE.jing_bi, "normal")
			else
				local gotoparm = {gotoui = "game_MiniGame"}
				GameManager.GotoUI(gotoparm)
			end
		end
	)
	self.JDTlen=self.transform:Find("BGTitle/Progress_bg/progress_mask").rect.width
	self.JDT=self.transform:Find("BGTitle/Progress_bg/progress_mask").transform
	self.MoneyRect=self.transform:Find("BGTitle/Node/Rect")
	self.MaxHintText=self.transform:Find("BGTitle/Node/MaxHintText"):GetComponent("Text")
	self.MoneyText=self.transform:Find("BGTitle/Node/Rect/MoneyText"):GetComponent("Text")
	self.BFBText=self.transform:Find("BGTitle/BFBText"):GetComponent("Text")
	self.HGImage=self.transform:Find("BGTitle/VIPIconBG/Image"):GetComponent("Image")
	self.CurVIPText=self.transform:Find("BGTitle/VIPIconBG/VIPText"):GetComponent("Text")
	self:InitChild()
	self:InitTimer()
	dump(VIPManager.get_vip_data())
	self:OnGetInfo(nil,VIPManager.get_vip_data())
end


--生成子物体
function C:InitChild()
	self.Childs={}
	dump(config.dangci,"<color=red>/////////////////////////</color>")
	for i = 1, ExtM.GetUserMaxVipLevel() do
		local b= GameObject.Instantiate(self.ChildPrefab,self.Content)
		b.gameObject:SetActive(true)
		if config.dangci[i].total then
			b.transform:Find("Text"):GetComponent("Text").text="累计充值"..config.dangci[i].total.."元即可获得以下特权"
		elseif config.dangci[i].cfz then
			b.transform:Find("Text"):GetComponent("Text").text="累计"..config.dangci[i].cfz.."点财富值可获得以下特权"
		end
		b.transform:Find("Text2"):GetComponent("Text").text="VIP"..i
		local content = b.transform:Find("ScrollView/Viewport/Content")
		if not self.parm or self.parm.tag ~= "mini" then
			b.transform:Find("ZXButton"):GetComponent("Button").onClick:AddListener(
				function ()
					ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
					self:MyExit()
					VipShowTaskPanel2.Create()
				end
			)
		end
		
		local tip = b.transform:Find("TipsButton")
		PointerEventListener.Get(tip.gameObject).onDown = function ()
			local str = config.dangci[i].help
			dump(VIPManager.IsQuDaoChannel(),"<color=red>是否渠道</color>")
			dump(normal_tips[i],"官方额外")
			dump(qudao_tips[i],"渠道额外")
			if qudao_tips[i] then
				str = str..(VIPManager.IsQuDaoChannel() and qudao_tips[i] or normal_tips[i])
			end
	        GameTipsPrefab.ShowDesc(str, UnityEngine.Input.mousePosition)
	    end
	    PointerEventListener.Get(tip.gameObject).onUp = function ()
	        GameTipsPrefab.Hide()
		end
		for j = 1, #config.dangci[i].info do
			local cc = config.dangci[i].info[j]
			local bb = GameObject.Instantiate(self.CellPre, content.transform)
			bb.gameObject:SetActive(true)
			bb.transform:Find("Text"):GetComponent("Text").text = cc.desc
			local qw = bb.transform:Find("Text/QWButton"):GetComponent("Button")
			if cc.gotoUI and #cc.gotoUI > 0 then
				qw.gameObject:SetActive(true)
				qw.onClick:AddListener(function ()
					ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
					GameManager.GotoUI({gotoui=cc.gotoUI[1], goto_scene_parm=cc.gotoUI[2]}, function ()
						self:MyExit()
					end)
				end)
			else
				qw.gameObject:SetActive(false)
			end
		end
		self.Childs[#self.Childs+1]=b
	end
end



--获取最近的节点
function C:GetNearNode()
	if self.canMove ==false then 
		return 
	end 
	for i = 1, ExtM.GetUserMaxVipLevel() do
		if math.abs(-self.ChildSize.x*(i-1)-self.Content.transform.localPosition.x)<20 then 
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