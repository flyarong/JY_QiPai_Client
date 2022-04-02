-- 创建时间:2019-07-03
-- Panel:FishingDROverPanel
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

FishingDROverPanel = basefunc.class()
local C = FishingDROverPanel
C.name = "FishingDROverPanel"
local instance
local defaultTimeout=5
--鱼的图
local spriteList={
	[1] ="bydr_game_icon_y8",
	[2] ="bydr_game_icon_y9",
	[3] ="bydr_game_icon_y10",
	[4] ="bydr_game_icon_y11",
	[5] ="bydr_game_icon_y12",
	[6] ="bydr_game_icon_y13",
	[7] ="bydr_game_icon_y14",
}


--皇冠的图
local HGList={
	[1] ="localpop_icon_1",
	[2] ="localpop_icon_2",
	[3] ="localpop_icon_3",
}
--特效延迟时间
local TeXiaoTime={
	[1]=1.8,
	[2]=3,
	[3]=3,
}
--
function C.Create()
	if not instance then
		instance = C.New()
	end
	return instance
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
    -- self.lister["fishing_dr_quit_room_response"] = basefunc.handler(self, self.on_fsmg_quit_game)
end

function C:on_fsmg_quit_game()
	self:MyExit()
end 

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end
function C:MyClose()
	self:MyExit()
	destroy(self.gameObject)
end
function C:MyExit()
	self:RemoveListener()
	self:StopAllTimer()
	destroy(self.gameObject)
	instance=nil
end

function C:ctor()

	ExtPanel.ExtMsg(self)

	local parent = GameObject.Find("Canvas/LayerLv3").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	self.backcall=nil
	self:MakeLister()
	self:AddMsgListener()
	self.transform:Find("BackButton"):GetComponent("Button").onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        self:OnBackClick()
    end)
	self:InitUI()
	self:Hide()
end

function C:InitUI()
	self.WaitTimer=self.transform:Find("WaitTimer/Text"):GetComponent("Text")
	self.MyChild=self.transform:Find("AwardChild")
	self.MyContent=self.transform:Find("BuHuo/BG/View/Content")
	self.PHBChild=self.transform:Find("PHBChild")	
	self.PHBContent=self.transform:Find("PHB/View/Content")
	self.MyAwardText=self.transform:Find("BJJJ/Node/Text"):GetComponent("Text")
	self.SX=self.transform:Find("BJJJ/by_over")
	self.MyAwardText2=self.transform:Find("BJJJ/Node/Text2/Text2"):GetComponent("Text")
	self.texiaoChild={}
	for i=1, 3 do 
		local str="OrderCanvas/"..i
		self.texiaoChild[#self.texiaoChild+1]=self.transform:Find(str)		
	end 
end

function C:MyRefresh()

end
function C:OnBackClick()
	self:Hide()
	if self.backcall then 
		self.backcall()
	end
	self.backcall=nil 	
end
function C.Show(data,backcall,timeout)
	dump(data,"<color=red>----结算的数据----</color>")
	if data==nil then 
		print("<color=red>----------结算的数据为空-------</color>")
		return 
	end 
	destroyChildren(instance.MyContent)
	destroyChildren(instance.PHBContent)
	instance.SX.gameObject:SetActive(false)
	instance.gameObject:SetActive(true)
	instance.backcall=backcall
	instance:DoGameOverInfo(data)
	instance:InitTimer(timeout)
end

function C.MyHide()
	if not instance then return end
	instance:Hide()
end

function C:InitTimer(timeout)
	self.timeout=timeout
	dump(timeout,"<color=red>----时间的数据----</color>")
	self.timeout=self.timeout or defaultTimeout
	self.WaitTimer.text="等待下一局:"..self.timeout.."s"	
	if self.out_Timer then
		self.out_Timer:Stop()
		self.out_Timer=nil
	end 
	self.out_Timer=Timer.New(function ()
		self.timeout=self.timeout-1
		--dump(self.timeout,"--------")
		self.WaitTimer.text="等待下一局:"..self.timeout.."s"		
		if  self.timeout <= 0 then 											
			if self.out_Timer then
				self.out_Timer:Stop()
			end 
			self:StopAllTimer()
			--self:Hide()
			if self.backcall then 
				self.backcall()
			end 
			
	    end 		
	end,1,-1)	
	self.out_Timer:Start()
end

function C:Hide()
	if not IsEquals(self.gameObject) then return end
	destroyChildren(self.MyContent)
	destroyChildren(self.PHBContent)
	self:StopAllTimer()
	self.gameObject:SetActive(false)
end

--处理游戏结束的相关信息
function C:DoGameOverInfo(data)
	self.MyContent.transform:Translate(Vector3.right * 200)
	self:DoPHB(data.rank)
	self:SetChild(data.fish,data.fj_award)
end

function C:StopAllTimer()
	if self.out_Timer then 
		self.out_Timer:Stop()
	end 
	if self.Delay_timer then
		self.Delay_timer:Stop()
	end
end

--将相关数据回归初始
function C:InitShow()
	self.MyAwardText.text=0
	self.MyAwardText2.text=""
	for i=1,3 do 
		self.texiaoChild[i].transform:Find("Text"):GetComponent("Text").text=0
	end
	self:HideAlltexiao()
	self.MyAwardText2.gameObject.transform.parent.gameObject:SetActive(false)
end

--处理顶端奖励的图片和文字
function C:SetChild(data,fj_award)	
	self:InitShow()
	local award=0
	for i = 1, #data do
		if data[i].count ~= nil and data[i].count ~= 0  then
			for j=1 , data[i].count	do 	 
				local child= GameObject.Instantiate(self.MyChild,self.MyContent.transform)
				child.gameObject:SetActive(true)
				child.transform:Find("Fish"):GetComponent("Image").sprite=GetTexture(spriteList[data[i].id])
				child.transform:Find("Fish"):GetComponent("Image"):SetNativeSize()		
				--child.transform:Find("Bet/Text"):GetComponent("Text").text=data[i].multiple.."倍"
				child.transform:Find("BeShu"):GetComponent("Image").sprite=GetTexture(self:GetMLImage(data[i].id))
				child.transform:Find("BeShu"):GetComponent("Image"):SetNativeSize()			
			end 
			award=award+data[i].award
		end		
	end	
	--dump(award,"---------1---------")
	if award ~= 0 or  fj_award ~= 0 then  
		--dump(award,"---------2---------")
		for i=1,3 do 
			self.texiaoChild[i].transform:Find("Text"):GetComponent("Text").text=award
		end 
		local index= self:GetMax2(self:GetMax1(data))
		--index=3
		--dump(index,"-----------texiao--------")
		self:ShowAnim(index)
		self:DelayShow(index,award,fj_award)
	end 
end
--在特效结束后展示获得的鲸币
function C:DelayShow(index,award,fj_award)
	if self.Delay_timer then
		self.Delay_timer:Stop()
	end
	self.Delay_timer=Timer.New(function ()
		if fj_award ~=nil and fj_award ~=0  then 
			self.MyAwardText2.text=	StringHelper.ToCash(fj_award)
			self.MyAwardText2.gameObject.transform.parent.gameObject:SetActive(true)
		end 
		self:ShwoSG()
		self.MyAwardText.text=StringHelper.ToCash(award)
	end,TeXiaoTime[index],1)
	self.Delay_timer:Start()
end

--
function C:ShwoSG()
	self.SX.gameObject:SetActive(false)
	self.SX.gameObject:SetActive(true)
end
--处理排行榜
function C:DoPHB(data)
	if data ==nil then
		data={}
	end 
	for i = 1, #data do
		local child=GameObject.Instantiate(self.PHBChild,self.PHBContent.transform)
		child.gameObject:SetActive(true)
		if HGList[i]~=nil then
			child.transform:Find("HG"):GetComponent("Image").sprite=GetTexture(HGList[data[i].rank])
		else
			child.transform:Find("HG").gameObject:SetActive(false)
		end
		if data[i].player_id == MainModel.UserInfo.user_id then
			child.transform:Find("BG").gameObject:SetActive(true)
			child.transform:Find("PlayerName"):GetComponent("Text").color=Color.New(1,239/255,127/255,1)
			child.transform:Find("AwardText"):GetComponent("Text").color=Color.New(1,239/255,127/255,1)
		else
			child.transform:Find("BG").gameObject:SetActive(false)
			child.transform:Find("PlayerName"):GetComponent("Text").color=Color.New(1,1,1,1)
			child.transform:Find("AwardText"):GetComponent("Text").color=Color.New(1,1,1,1)
			--child.transform:Find("AwardImage").transform.localScale=Vector3.New(0.8,0.8,0.8)
		end 		
		child.transform:Find("PlayerName"):GetComponent("Text").text=data[i].name
		child.transform:Find("AwardText"):GetComponent("Text").text=StringHelper.ToCash(data[i].award)
	end
end

--阶段动画
function C:ShowAnim(index)
	self:HideAlltexiao()
	self.texiaoChild[index].gameObject:SetActive(true)
end

--HideAlltexiao
function C:HideAlltexiao()
	for i=1, 3 do 
		self.texiaoChild[i].gameObject:SetActive(false)
	end 
end 

--判断使用哪个结算特效
function C:GetMax1(data)
	local b =  MathExtend.SortList(data,"id",false)
	--dump(b,"111111111111111111111111")
	for i=1,#b do
		if b[i].count > 0 and b[i].award > 0 then 
			--dump(b[i].id,"-----------123---------")
			return  b[i].id
		end 
	end
end

function C:GetMax2(n)
	if n ==nil then
		return 1
	end 
	if  n >= 7 then
		return 3
	end 
	if  n == 6 then
		return 2
	end 
	if  n == 5 then
		return 2
	end 
	if  n == 4 then
		return 2
	end 
	if  n == 3 then
		return 1
	end 
	if  n == 2 then
		return 1
	end 
	if  n == 1 then
		return 1
	end
end 

--通过倍率获得图片名字
function  C:GetMLImage(id)
	if id == 1 then
		return   "bydr_game_imgf_2b"
	end 
	if id == 2 then
		return  "bydr_game_imgf_4b"
	end 
	if id == 3 then
		return  "bydr_game_imgf_6b"
	end 
	if id == 4 then
		return  "bydr_game_imgf_8b"
	end 
	if id == 5 then
		return  "bydr_game_imgf_12b"
	end 
	if id == 6 then
		return  "bydr_game_imgf_18b"
	end 
	if id == 7 then
		return  "bydr_game_imgf_88b"
	end 
end
