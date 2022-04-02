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
		if data.vip_level==10 then 
			self.MaxHintText.gameObject:SetActive(true)
			self.JDT.sizeDelta={x=self.JDTlen,y=self.JDT.rect.height}
			self.MoneyRect.gameObject:SetActive(false)
			self.BFBText.text="MAX"
		else 
			self.MaxHintText.gameObject:SetActive(false)
			self.MoneyText.text=(config.dangci[self.showlevel+1].total*100-data.now_charge_sum)/100
			self.JDT.sizeDelta={x=(data.now_charge_sum /(config.dangci[self.showlevel+1].total*100) )*self.JDTlen,y=self.JDT.rect.height}
			self.BFBText.text=StringHelper.ToCash(data.now_charge_sum/100) .."/"..StringHelper.ToCash(config.dangci[self.showlevel+1].total)		
		end 
		if self.showlevel >= 10 then
			self:SetIndex(self.showlevel)
		else
			self:SetIndex(self.showlevel + 1)
		end
		for i = self.showlevel+2, #config.dangci do
			if i>=7 then
				self.Childs[i].transform:Find("Text"):GetComponent("Text").text="累计充值".."***".."元即可获得以下特权"
			end 
		end

	end 
end

--矫正动画
function C:SetRightAnim()
	if self.index==1 then
		self.LeftButton.gameObject:SetActive(false)
	end
	if self.index==10  then
		self.RightButton.gameObject:SetActive(false)
	end
	if   1 <self.index and  self.index < 10  then
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
	if  self.index<=9 then 
		self.canMove=false
		local seq = DG.Tweening.DOTween.Sequence()
		local tweenKey = DOTweenManager.AddTweenToStop(seq)
		seq:Append(self.Content.transform:DOLocalMoveX(-self.ChildSize.x*(self.index), 0.2):SetEase(DG.Tweening.Ease.Linear))--OutBack
		seq:OnKill(     
        	function()--这里报过异常
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
        	function()--这里报过异常
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
			PayPanel.Create(GOODS_TYPE.jing_bi, "normal")
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
	for i = 1, #config.dangci do
		local b= GameObject.Instantiate(self.ChildPrefab,self.Content)
		b.gameObject:SetActive(true)
		b.transform:Find("Text"):GetComponent("Text").text="累计充值"..config.dangci[i].total.."元即可获得以下特权"
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
	        GameTipsPrefab.ShowDesc("1.游戏内带有超值标签的礼包不计入vip累计金额;\n2.福利券超出容量后会自动转换为鲸币。", UnityEngine.Input.mousePosition)
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
					GameManager.GotoUI({gotoui=cc.gotoUI[1], goto_scene_parm=cc.gotoUI[2]}, function()
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
	for i = 1, #config.dangci do
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