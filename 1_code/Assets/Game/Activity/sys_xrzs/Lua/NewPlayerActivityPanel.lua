-- 创建时间:2019-06-04
--[[ *      ┌─┐       ┌─┐
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
local config

NewPlayerActivityPanel = basefunc.class()
local C = NewPlayerActivityPanel
C.name = "NewPlayerActivityPanel"
local instance
function C.Create(parent,types)
    instance=C.New(parent,types)
    return  instance
end
function C:AddMsgListener()
    for proto_name, func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end
function C:MakeLister()
    self.lister = {}
    self.lister["AssetChange"] = basefunc.handler(self, self.OnAssetChange)
    self.lister["EnterBackGround"] = basefunc.handler(self, self.onEnterBackGround)
    self.lister["EnterForeGround"] = basefunc.handler(self, self.ReConnecteServerSucceed)
    self.lister["ReConnecteServerSucceed"] = basefunc.handler(self, self.ReConnecteServerSucceed)
    self.lister["new_player_lottery_base_info_change"] = basefunc.handler(self, self.ReFreshInfo)
    self.lister["query_new_player_lottery_base_info_response"]=basefunc.handler(self,self.ReFreshInfo)
    self.lister["new_player_lottery_kaijiang_response"]=basefunc.handler(self,self.Get_KAIJIANG_info)  
    self.lister["new_player_lottery_get_broadcast_response"]=basefunc.handler(self,self.GetBroadcast)
    self.lister["ExitScene"] = basefunc.handler(self, self.MyExit)
end

function C:ReConnecteServerSucceed()
    Network.SendRequest("query_new_player_lottery_base_info",nil,"")
end

function C:ReFreshInfo(_,data)
    --dump(data,"<color=red>----------62-----------</color>")
    if data==nil or data.now_credits==nil or not IsEquals(self.gameObject)  then 
         return
    end 
    self.JFcurrent=data.now_credits
    self.JFxiaohao=data.need_credits 
    self.current.text = data.now_credits
    self.xiaohao.text=data.need_credits
    self.now_game_num=data.now_game_num
    if  self.Isfrist then 
        self:GetMask()
        self.Isfrist=false
    end
    self.time=data.over_time-os.time()
    if self.update_time then
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
function C:RemoveListener()
    for proto_name, func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end
function C:UpdateTime()
    if self.time<=0 then
        self.time=0
    end 
	local str = StringHelper.formatTimeDHMS(self.time)
	if IsEquals(self.Timetxt) then
		self.Timetxt.text = "活动下架时间: " .. str
	end
	if self.time <= 0 then
		if self.update_time then
			self.update_time:Stop()
		end
        self.update_time = nil
	end
end
function C.CheckActivityState()
    Network.SendRequest("query_new_player_lottery_base_info",nil,"")
end 
function C:MyExit()
    self:choujiang()
    self:CloseAnimSound()
    if self.Show:Stop() then
    self.Show:Stop()
    end
    if self.update_time then
    self.update_time:Stop()
    end
    if self.gonor then
    self.gonor:Stop()
    end
    if self.runnor then  
    self.runnor:Stop()
    end
    if self.CloseSound then
        self.CloseSound:Stop()
	end
    if self.runruning then 
    self.runruning:Stop()
    end
    if self.runend then 
    self.runend:Stop()
    end
    if  self.shan then   
    self.shan:Stop()
    end
    if self.jiasu then
    self.jiasu:Stop()
    end
    if self.slowUp then 
        self.slowUp:Stop()
    end
    self:RemoveListener()
	destroy(self.gameObject)
	for i = 1, #self.ShowFP do
		GameObject.Destroy(self.ShowFP[i])
    end
    local ShowTextLengh=#self.ShowText
    if ShowTextLengh>20 then 
        ShowTextLengh=20
    end
    PlayerPrefs.SetInt("newplayer_lottery",ShowTextLengh)
    for i=ShowTextLengh,1,-1 do
        if  self.ShowText[#self.ShowText + i - ShowTextLengh]~="" then
            PlayerPrefs.SetString("newplayer_lottery"..i,self.ShowText[#self.ShowText + i - ShowTextLengh])  
        end
    end
    self.ShowText={}
	self.ShowFP=nil

	 
end
function C:suijizhongzi(index,sum)
    local result = {}  
    local obj ={}
    --当前抽奖模式的奖品数量
    self.curjiangpinshu=sum
    for i=1,sum do 
        obj[i]=i
    end 
    if type(obj)~="table" then
	   return
	end
    local _result = {}
	local _index = 1
	math.randomseed(MainModel.UserInfo.user_id*index)
    while #obj ~= 0 do
        local ran = math.random(0,#obj)
        if obj[ran] ~= nil then
            _result[_index] = obj[ran]
            table.remove(obj,ran)
            _index = _index + 1
        end
	end
	self.yinshe=_result
	math.randomseed(os.time())
end
function C:ctor(parent,types)

	ExtPanel.ExtMsg(self)

	config = SYSXRZSManager.GetConfig()
    local obj
    if parent~=nil then 
            obj = newObject(C.name,parent)
            self.deng1="xr_deng"
            self.deng2="xr_deng2"
    else
        if types ~=nil then        
            obj= newObject("NewPlayerActivityPanelBIG",GameObject.Find("Canvas/LayerLv5").transform)
            self.deng1="fqj_deng"
            self.deng2="fqj_deng2"
        else
            obj = newObject(C.name,GameObject.Find("Canvas/LayerLv5").transform)
            self.deng1="xr_deng"
            self.deng2="xr_deng2"
        end
    end 

    local tran = obj.transform
    self.Isfrist=true
    self.transform = tran
    self.gameObject = obj
	self.startindex = 1
	self.ShowFP={}  
    self.canStart = true
    self.Lotter="积分"
	self:suijizhongzi(1,#config.JP1)
    self:MakeLister()
    self:AddMsgListener()
    self:slowUpAnim()
    self:InitUI()
	self:RunAnimation(_, "nor")
    self:SuijiShow() 
    self:GetUserName()   
    Network.SendRequest("query_new_player_lottery_base_info",nil, "")
    self.dengAnimator:Play(self.deng2)
    
end
function C:GetUserName()
    self.localname = ""
    local v=basefunc.string.string_to_vec(MainModel.UserInfo.name)
    if v then
        for  i=1,#v do
            if i <= 4 then
                self.localname= self.localname .. v[i]
            else
                break
            end
        end
    end
end
function C:InitUI()
    SYSXRZSManager.SetHintState({gotoui=SYSXRZSManager.key})
    
    self.current = self.transform:Find("RectBG/TitleIma/Current"):GetComponent("Text")
    self.xiaohao = self.transform:Find("RectBG/LotteryBG/StartButton/xiaohao"):GetComponent("Text")
    self.StartButton = self.transform:Find("RectBG/LotteryBG/StartButton"):GetComponent("Button")
    self.CloseButton=self.transform:Find("CloseButton"):GetComponent("Button")
    self.Timetxt=self.transform:Find("Time_txt"):GetComponent("Text")
    self.dengAnimator = self.transform:Find("deng"):GetComponent("Animator")
    self.getawardnum=PlayerPrefs.GetInt("NewPlayer"..MainModel.UserInfo.user_id.."alldone",0)
    PlayerPrefs.SetInt("NewPlayer"..os.date("%Y%m%d", os.time())..MainModel.UserInfo.user_id,1)
    self.CloseButton.onClick:AddListener(
        function ()
            ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
            self:OnCloseLottery()   
        end
    )
    self.StartButton.onClick:AddListener(
        function()
            if self.canStart then
                ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
                self:OnStartLottery()   
            end
        end
        )
   
    self.help_btn=self.transform:Find("help_btn"):GetComponent("Button")
    self.help_btn.onClick:AddListener(function()
            ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
            self:OnHelpClick()
        end)
    self.LotteryChilds = {}
    self.ShowText={}
    for i = 1, self.curjiangpinshu do
        self.LotteryChilds[#self.LotteryChilds+1]= self.transform:Find("RectBG/LotteryBG/lotterys" .. i)
    end
    self.Node=self.transform:Find("RectBG/BG2/Viewport/TaskNode")
    self:ChangeLV(1)
    for i = 1, PlayerPrefs.GetInt("newplayer_lottery",0) do
        if PlayerPrefs.GetString("newplayer_lottery"..i,"")~="" then
            local fp=newObject("CommonlotteryinfoPrefab",self.transform:Find("RectBG/BG2/Viewport/TaskNode"))
            fp.transform:Find("Text"):GetComponent("Text").text=PlayerPrefs.GetString("newplayer_lottery"..i,"")
            self.ShowFP[#self.ShowFP+1]=fp
            self.ShowText[#self.ShowText+1]= PlayerPrefs.GetString("newplayer_lottery"..i,PlayerPrefs.GetString("newplayer_lottery"..i,""))         
        end     
    end
    self.isUP=false
    if  #self.ShowFP>16 then 
        self.isUP=true 
        self.slowUp:Start()
    end
end
function C:ChangeLV(index)
    if  self.canStart==false then
        return
    end 
    if index ==1 then
        self:suijizhongzi(1,#config.JP1)
        self.JPcfg=config.JP1
       -- dump(self.JPcfg,"---------------------")     
        self.JFxiaohao=1 
        self.xiaohao.text=self.JFxiaohao..self.Lotter
        self.kaijiang_level=1  
    end
    if index ==2  then 
        self:suijizhongzi(2,#config.JP2)
        self.JPcfg=config.JP2 
        self.JFxiaohao=10 
        self.xiaohao.text=self.JFxiaohao..self.Lotter
        self.kaijiang_level=2  
    end 
    if index ==3  then 
        self:suijizhongzi(3,#config.JP3)
        self.JPcfg=config.JP3 
        self.JFxiaohao=100
        self.xiaohao.text=self.JFxiaohao..self.Lotter
        self.kaijiang_level=3  
    end
   
    for i = 1, #self.LotteryChilds do    
        self.LotteryChilds[self.yinshe[i]].transform:Find("Text"):GetComponent("Text").text =self:lotteryType2str(self.JPcfg[i].num,self.JPcfg[i].type)
        self.LotteryChilds[self.yinshe[i]].transform:Find("awardimg"):GetComponent("Image").sprite=GetTexture(self.JPcfg[i].img)
        self.LotteryChilds[self.yinshe[i]].transform:Find("awardimg"):GetComponent("Image"):SetNativeSize() 
    end 
    
    
end
function C:lotteryType2str(Num,type)
    if type=="jing_bi" then 
       return  Num.."鲸币"
    elseif type=="jipaiqi" then 
        return Num.."记牌器"
    elseif type=="fish_coin" then 
        return Num.."鱼币"
    elseif  type=="shop_gold_sum" then 
        return Num.."福卡"
    else
        return type
    end
end
function C:OnStartLottery()
    --print("--------1---------")
	if self.JFcurrent==nil or self.JFxiaohao==nil then 
       return 
    end
    if self.now_game_num  and  self.now_game_num>=self.curjiangpinshu then
        HintPanel.Create(1, "所有奖励已经抽到，实物奖励请联系客服，客服QQ:4008882620")
        return 
    end
	if  self.JFcurrent<self.JFxiaohao then
		HintPanel.Create(1,  self.Lotter.."不足")
		return 
    end
    --print("--------2---------")
    Network.SendRequest("new_player_lottery_kaijiang",nil,"")    
end
function C:OnCloseLottery()
    self:OnDestroy()
end
function C:GetBroadcast(_,data)    
    --dump(data,"<color=yellow>--------------------新人抽奖------------------</color>")
	if  IsEquals(self.gameObject) and data.award_id then		
		local fp=newObject("CommonlotteryinfoPrefab",self.transform:Find("RectBG/BG2/Viewport/TaskNode"))
        if data.award_id <#config.JP1+1 then
            fp.transform:Find("Text"):GetComponent("Text").text=data.player_name .."抽中了"..self:lotteryType2str(config.JP1[data.award_id].num,config.JP1[data.award_id].type)
            self.ShowFP[#self.ShowFP+1]=fp
            self.ShowText[#self.ShowText+1]=data.player_name .."抽中了"..self:lotteryType2str(config.JP1[data.award_id].num,config.JP1[data.award_id].type)
        end
        if config.JP2[1]~=nil and data.award_id >#config.JP1 and data.award_id<#config.JP1+#config.JP2+1 then
            fp.transform:Find("Text"):GetComponent("Text").text=data.player_name .."抽中了"..self:lotteryType2str(config.JP2[data.award_id-#config.JP1].num,config.JP2[data.award_id-#config.JP1].type)
            self.ShowFP[#self.ShowFP+1]=fp
            self.ShowText[#self.ShowText+1]=data.player_name .."抽中了"..self:lotteryType2str(config.JP2[data.award_id-#config.JP1].num,config.JP2[data.award_id-#config.JP1].type)
        end
        if config.JP2[1]~=nil and  config.JP3[1]~=nil and  data.award_id >#config.JP1+#config.JP2 then
            fp.transform:Find("Text"):GetComponent("Text").text=data.player_name .."抽中了"..self:lotteryType2str(config.JP3[data.award_id-(#config.JP1+#config.JP2)].num,config.JP3[data.award_id-(#config.JP1+#config.JP2)].type)
            self.ShowFP[#self.ShowFP+1]=fp
            self.ShowText[#self.ShowText+1]=data.player_name .."抽中了"..self:lotteryType2str(config.JP3[data.award_id-(#config.JP1+#config.JP2)].num,config.JP3[data.award_id-(#config.JP1+#config.JP2)].type)
        end
    end
    if  #self.ShowFP>16 then  
        if self.isUP==false then 
           self.slowUp:Start()
        end
    end
end
function C:slowUpAnim()
    --dump(self.Node,"---------")
    self.slowUp = Timer.New(
    function()
        self.Node.transform.localPosition = Vector3.New(
            self.Node.transform.localPosition.x,
            self.Node.transform.localPosition.y+1/5,
            self.Node.transform.localPosition.z);
    end, 0.016, -1
    )
end
--返回开奖信息
function C:Get_KAIJIANG_info(_,data)
    --dump(data,"<color=red>---开奖--</color>")
    if data.result==0 then
        if data.award_id ==nil then 
           return 
        end
        if data.award_id>#config.JP1 and data.award_id<#config.JP1+#config.JP2 then 
           data.award_id=data.award_id-#config.JP1
        end
        if data.award_id>#config.JP1+#config.JP2 then 
            data.award_id=data.award_id-(#config.JP1+#config.JP2)
         end
        self.getawardnum=self.getawardnum+1
        PlayerPrefs.SetInt("NewPlayer"..MainModel.UserInfo.user_id.."alldone",self.getawardnum)
        self:RunAnimation(data.award_id, "running")
        self.award_id=data.award_id
        --dump(data.award_id,"<color=red>---开奖--</color>")
    elseif data.result==1003 then
          HintPanel.Create(1, "所有奖励已经抽到，实物奖励请联系客服，客服QQ:4008882620")
    else
          HintPanel.ErrorMsg(data.result)
    end
end
function C:MyRefresh()	
end
function C:OnHelpClick()
    self.introduce=self.transform:Find("Introduce"):GetComponent("Text")
    local str=config.DESCRIBE_TEXT[1].text
    for i=2,#config.DESCRIBE_TEXT do 
         str=str.."\n"..config.DESCRIBE_TEXT[i].text
    end
    self.introduce.text=str
    IllustratePanel.Create({self.introduce}, GameObject.Find("Canvas/LayerLv5").transform)
end
function C:CloseAnimSound()
    if self.curSoundKey then
        soundMgr:CloseLoopSound(self.curSoundKey)
        self.curSoundKey = nil
    end
end
function C:RunAnimation(endindex, status)
    if  self.canStart==false then
        return
    end 
    self.dengAnimator:Play(self.deng1)
    local start=self.startindex 
    local endstep=0
    if endindex~=nil then
        if endindex<start then
            endstep=self.curjiangpinshu*2+self.yinshe[endindex]-start
        else
            endstep=self.curjiangpinshu+self.yinshe[endindex]-start
        end
    end
    self.paomadeng = {}
    for i = 1, self.curjiangpinshu do
        self.paomadeng[i] = self.LotteryChilds[i].transform:Find("fqj_kuang")
    end
    if self.runnor then
        self.runnor:Stop()
    end
    self.runnor = nil
    self.runnor = Timer.New(function()
        self.gonor:Stop()
        self.runruning:Stop()
        self.runend:Stop()
        self.shan:Stop()
        self.paomadeng[self.startindex].gameObject:SetActive(false)
        self.paomadeng[self.startindex].gameObject:SetActive(true)
        self.startindex = self.startindex + 1
        if self.startindex > self.curjiangpinshu then
            self.startindex = 1
        end
    end, 1.2, -1,nil,true)
    if self.runruning then
        self.runruning:Stop()
	end
	self.runruning = nil
    local runingtime = 0.036
    local allindex = 1
    self.jiasu = Timer.New(function()
        self.runnor:Stop()
        self.canStart = false
        allindex = allindex + 1
        self.paomadeng[self.startindex].gameObject:SetActive(false)
        self.paomadeng[self.startindex].gameObject:SetActive(true)
        self.startindex = self.startindex + 1
        if self.startindex > self.curjiangpinshu then
            self.startindex = 1
        end
        if allindex >= 7 then
            self.jiasu:Stop()
            self.runruning:Start()        
        end
    end, 1.62/7, -1)
    self.runruning = Timer.New(function()
        self.runnor:Stop()
        self.canStart = false
        allindex = allindex + 1
        self.paomadeng[self.startindex].gameObject:SetActive(false)
        self.paomadeng[self.startindex].gameObject:SetActive(true)
        self.startindex = self.startindex + 1
        if self.startindex > self.curjiangpinshu then
            self.startindex = 1
        end
        if allindex >= self.curjiangpinshu*10 then
            self.runruning:Stop()
            self.runend:Start()        
        end
    end, runingtime, -1)
    if self.runend then
        self.runend:Stop()
	end
	self.runend=nil
    self.runend = Timer.New(function()
        self.paomadeng[self.startindex].gameObject:SetActive(false)
        self.paomadeng[self.startindex].gameObject:SetActive(true)
        self.startindex = self.startindex + 1
        if self.startindex > self.curjiangpinshu then
            self.startindex = 1
        end
        allindex = allindex + 1
        if allindex >=self.curjiangpinshu*10+endstep then
                if  self.yinshe[endindex]== self.startindex then           
     
                        self.shan:Start()
                        self.runend:Stop()
                        self.CloseSound:Start()
                end
        end
    end, 1.2/endstep, -1)
    if self.CloseSound then
        self.CloseSound:Stop()
	end
	self.CloseSound=nil
    self.CloseSound=Timer.New(function ()
        self:CloseAnimSound()
    end,0.8,1)

    if self.shan then
        self.shan:Stop()
	end
	self.shan=nil
    self.shan = Timer.New(function()
        self.paomadeng[self.startindex].gameObject:SetActive(false)
        self.paomadeng[self.startindex].gameObject:SetActive(true)
        self.gonor:Start()
    end
    , 0.3, 6)
    if self.gonor then
        self.gonor:Stop()
	end
	self.gonor=nil
    self.gonor = Timer.New(
    function()      
        self.runnor:Start()
        self:choujiang()
    end, 1.4, 1
    )
    if status == "nor"  then
        self.runnor:Start()
    end
    if status == "running" and self.canStart ==true   then
        self.canStart=false
        self.runnor:Stop()
        self.jiasu:Start()
        self:CloseAnimSound()
        self.curSoundKey = ExtendSoundManager.PlaySound(audio_config.game.bgm_duijihongbao.audio_name, 1, function()
            self.curSoundKey = nil
        end)
    end
end
function C:ShowLotteryInfo()
	if   IsEquals(self.gameObject) then
        Network.SendRequest("new_player_lottery_get_broadcast")		
	end
end
function C:OnAssetChange(data)
    dump(data,"<color=red>----奖励类型-----</color>")
	if data.change_type and data.change_type == "new_player_lottery_award" then
		self.cur_award = data
	end
end
function C:GetMask()
    if self.now_game_num>self.curjiangpinshu then
        self.now_game_num=self.curjiangpinshu
    end
   for i = 1, self.now_game_num do
       self.LotteryChilds[self.yinshe[i]].transform:Find("getmask").gameObject:SetActive(true)
   end

end
function C:SuijiShow()
	if self.Show  then
		self.Show:Stop()
	end
	self.Show=nil
	local t=math.random(3,6)
	self.Show=Timer.New(function ()
			self:ShowLotteryInfo()
			self:SuijiShow()	
	    end
	,t,-1)
	self.Show:Start()
end
function C:OnDestroy()
    self:MyExit()
end

function C:choujiang()
    if self.award_id~= nil then
        self.dengAnimator:Play(self.deng2)
        self.runnor:Start()
        Event.Brocast("AssetGet",self.cur_award)
        if self.JPcfg[self.award_id].real ==1 then
            ExtendSoundManager.PlaySound(audio_config.game.bgm_hall_huodewupin.audio_name)
            local string1
            string1="奖品:"..self.JPcfg[self.award_id].type.."，抽到奖励后请联系客服领取奖励\n客服QQ：%s"				
            HintCopyPanel.Create({desc=string1, isQQ=true})
        end
        Network.SendRequest("query_new_player_lottery_base_info")
        local fp=newObject("CommonlotteryinfoPrefab",self.transform:Find("RectBG/BG2/Viewport/TaskNode"))
        fp.transform:Find("Text"):GetComponent("Text").text=self.localname .."抽中了"..self:lotteryType2str(self.JPcfg[self.award_id].num,self.JPcfg[self.award_id].type)
        self.ShowFP[#self.ShowFP+1]=fp
        self.canStart = true
        self:MyRefresh()
        self.award_id=nil
        self.cur_award=nil
        self:GetMask()
    end
end
--页面内部的红点检测
function C:CheckRedPoint()
  
    if self.JFcurrent>=1 then     
        self.Lv1Button.transform:Find("RedPoint").gameObject:SetActive(true)
        if self.JFcurrent>=10 then
            self.Lv2Button.transform:Find("RedPoint").gameObject:SetActive(true)
        else
            self.Lv2Button.transform:Find("RedPoint").gameObject:SetActive(false)
        end
    else
        self.Lv1Button.transform:Find("RedPoint").gameObject:SetActive(false)
        self.Lv2Button.transform:Find("RedPoint").gameObject:SetActive(false)
    end
  
end
function C:onEnterBackGround()
	if self.update_time then
		self.update_time:Stop()
	end
    self.update_time = nil
    
end
