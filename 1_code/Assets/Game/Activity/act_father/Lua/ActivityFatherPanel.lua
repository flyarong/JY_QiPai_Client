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
local config = HotUpdateConfig("Game.CommonPrefab.Lua.father_activity_config")
ActivityFatherPanel = basefunc.class()
local C = ActivityFatherPanel
C.name = "ActivityFatherPanel"
function C.Create()
    --local time_start=1
    local time_start=1560387600
    local time_end=1560959999
    --dump(os.time(),"<color=red>----------9999999999999999999999999999999-----</color>")
    if os.time()>time_end or os.time()<time_start then 
        HintPanel.Create(1, "活动结束啦")
        return 
    end
    return C.New(C.name)
end

function C:AddMsgListener()
    for proto_name, func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["AssetChange"] = basefunc.handler(self, self.OnAssetChange)
    self.lister["dafuhao_base_info_change"] = basefunc.handler(self, self.ReFreshInfo)
    self.lister["query_dafuhao_base_info_response"] = basefunc.handler(self, self.on_query_dafuhao_base_info )
	self.lister["dafuhao_game_kaijiang_response"] = basefunc.handler(self, self.dafuhao_game_kaijiang_response )
    self.lister["dafuhao_get_broadcast_response"] = basefunc.handler(self, self.dafuhao_get_broadcast_response ) 
end

function C:RemoveListener()
    for proto_name, func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end
function C:on_query_dafuhao_base_info(_, data)
    --dump(data,"<color=red>-----------------12312313--------------</color>")
    if data ==nil or data.need_credits==nil or data.now_credits==nil then
       return 
    end
	self.JFcurrent=data.now_credits
    self.JFxiaohao=data.need_credits
    if IsEquals(self.current) then
        self.current.text = data.now_credits
    end
    if IsEquals(self.xiaohao) then
        self.xiaohao.text = data.need_credits .. "积分"
    end
end
function C:ReFreshInfo()
	
end
function C:MyExit()
    self:choujiang()
    self:CloseAnimSound()
    if self.Show:Stop() then
    self.Show:Stop()
    end
    if self.gonor then
    self.gonor:Stop()
    end
    if self.runnor then  
    self.runnor:Stop()
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
    self:RemoveListener()
	destroy(self.gameObject)
	for i = 1, #self.ShowFP do
		GameObject.Destroy(self.ShowFP[i])
    end
    local ShowTextLengh=#self.ShowText
    if ShowTextLengh>12 then 
        ShowTextLengh=12
    end
    PlayerPrefs.SetInt("father_activity",ShowTextLengh)
    for i=ShowTextLengh,1,-1 do
        if self.ShowText[i]~="" then
        PlayerPrefs.SetString("father_activity"..i,self.ShowText[i])  
        --dump(self.ShowText[i],"<color=red>-------------本地存储--------------</color>")
        end
    end
    self.ShowText={}
	self.ShowFP=nil

	 
end
function C:suijizhongzi()
    local result = {}  -- 接收排序后的table
    local obj = {1,2,3,4,5,6,7,8,9,10} -- 需要进行排序的table
-- 排序方法 参数为要排序的table
    -- 判断如果不为table则直接返回
    if type(obj)~="table" then
	   return
	end
    local _result = {}
	local _index = 1
	math.randomseed(MainModel.UserInfo.user_id)
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
	--dump(_result,"<color=red>----------------------随机种子-----------</color>")
	--return _result
end
function C:ctor()

	ExtPanel.ExtMsg(self)


    local obj = newObject(C.name, GameObject.Find("Canvas/LayerLv5").transform)
    local tran = obj.transform
    ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
    self.transform = tran
    self.gameObject = obj
    LuaHelper.GeneratingVar(obj.transform, self)
	self.startindex = 1
	self.ShowFP={}
    self.StartButton = self.transform:Find("RectBG/LotteryBG/StartButton"):GetComponent("Button")
    self.canStart = true
    self.getawardnum=PlayerPrefs.GetInt("father"..MainModel.UserInfo.user_id.."alldone",0)
	self:suijizhongzi()
    self.StartButton.onClick:AddListener(
    function()
        if self.canStart then
            ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
            self:OnStartLottery() 
            Network.SendRequest("query_dafuhao_base_info")   
        end
    end
    )
    self.CloseButton = self.transform:Find("CloseButton"):GetComponent("Button")
    self.CloseButton.onClick:AddListener(
    function()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
        self:OnCloseLottery()        
    end
    )
    self.help_btn.onClick:AddListener(function()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
        self:OnHelpClick()
    end)
    self.current = self.transform:Find("RectBG/TitleIma/Current"):GetComponent("Text")
    self.xiaohao = self.transform:Find("RectBG/LotteryBG/StartButton/xiaohao"):GetComponent("Text")
    Network.SendRequest("query_dafuhao_base_info", nil, "")
    self.dengAnimator = self.transform:Find("RectBG/LotteryBG/deng"):GetComponent("Animator")
    self:MakeLister()
    self:AddMsgListener()
    self:InitUI()
    self:dengAnimation("nor")
	self:RunAnimation(_, "nor")
	self:SuijiShow()
	if self.yanchi then
	   self.yanchi:Stop()
    end
   -- MainModel.UserInfo.name="牛逼"
    local v=basefunc.string.string_to_vec(MainModel.UserInfo.name)
    
   -- dump(v,"<color=red>-------本地名字---------</color>")
    self.localname = ""
    if v then
        for  i=1,#v do
            if i <= 4 then
                self.localname= self.localname .. v[i]
            else
                break
            end
        end
    end
	
	dump(self.localname,"<color=red>-------本地名字---------</color>")
	-- self.yanchi=nil
	-- -- self.yanchi=Timer.New(function ()
	-- -- 	Network.SendRequest("dafuhao_get_broadcast")
	-- -- end ,0.1,10)
    -- self.yanchi:Start()
	--self:ShowLotteryInfo()
    --Event.Brocast("dafuhao_base_info_change", "dafuhao_base_info_change", { need_credits = 50, now_credits = 1200 })

end
function C:InitUI()
    --读取预制体位置
    self.LotteryChilds = {}
    self.ShowText={}
    for i = 1, 10 do
        self.LotteryChilds[#self.LotteryChilds+1]= self.transform:Find("RectBG/LotteryBG/lotterys" .. i)
    end
    --dump(#self.LotteryChilds, "<color=red>--------用户信息-------</color>")
   -- PlayerPrefs.SetString("PlayID", MainModel.UserInfo.user_id)
    for i = 1, #config.Awardcfg do
        self.LotteryChilds[self.yinshe[i]].transform:Find("Text"):GetComponent("Text").text = config.Awardcfg[i].award
		local iamge = self.LotteryChilds[self.yinshe[i]].transform:Find("awardimg"):GetComponent("Image")
		if   PlayerPrefs.GetInt(self.LotteryChilds[self.yinshe[i]].transform:Find("Text"):GetComponent("Text").text.."father"..MainModel.UserInfo.user_id,0)==1 then
			 self.LotteryChilds[self.yinshe[i]].transform:Find("getmask").gameObject:SetActive(true)
		end
        if config.Awardcfg[i].award == "手机支架" then
            iamge.sprite = GetTexture("gy_33_17")
            iamge:SetNativeSize()
        elseif config.Awardcfg[i].award == "U型按摩枕" then
            iamge.sprite = GetTexture("gy_33_15")
            iamge:SetNativeSize()
        elseif    config.Awardcfg[i].award == "鳄鱼腰带" then
            iamge.sprite = GetTexture("gy_33_14")
            iamge:SetNativeSize()
        elseif config.Awardcfg[i].award == "飞科剃须刀" then
            iamge.sprite = GetTexture("gy_33_16")
            iamge:SetNativeSize()     
        elseif config.Awardcfg[i].award == "3000鲸币" then
            iamge.sprite = GetTexture("com_pc_icon_jb1_activity_act_father")
            iamge:SetNativeSize()      
        else
            iamge.sprite = GetTexture("bbsc_icon_hb")
            iamge:SetNativeSize()
        end
    end
    for i = 1, PlayerPrefs.GetInt("father_activity",0) do
        if PlayerPrefs.GetString("father_activity"..i,"")~="" then
        local fp=newObject("Activity88infoPrefab",self.transform:Find("RectBG/BG2/Viewport/TaskNode"))
            fp.transform:Find("Text"):GetComponent("Text").text=PlayerPrefs.GetString("father_activity"..i,"")
            --dump(PlayerPrefs.GetString("father_activity"..i,""),"<color=red>-------------本地存储开始--------------</color>")
            self.ShowFP[#self.ShowFP+1]=fp
            self.ShowText[#self.ShowText+1]= PlayerPrefs.GetString("father_activity"..i,PlayerPrefs.GetString("father_activity"..i,""))         
        end
      
    end
end
function C:OnStartLottery()
    if self.JFcurrent==nil or self.JFxiaohao==nil then 
       return 
    end
	if  self.JFcurrent<self.JFxiaohao then
		HintPanel.Create(1, "积分不足")
		return 
	end
	Network.SendRequest("dafuhao_game_kaijiang", nil, "")
end
function C:OnCloseLottery()
    self:OnDestroy()
end
function C:dafuhao_get_broadcast_response(_,data)
	--dump(data,"<color=red>----------游客名字------</color>")
	if  IsEquals(self.gameObject) and data.award_id   then		
		local fp=newObject("Activity88infoPrefab",self.transform:Find("RectBG/BG2/Viewport/TaskNode"))
		fp.transform:Find("Text"):GetComponent("Text").text=data.player_name .."抽中了"..config.Awardcfg[data.award_id].award
        self.ShowFP[#self.ShowFP+1]=fp
        self.ShowText[#self.ShowText+1]=data.player_name .."抽中了"..config.Awardcfg[data.award_id].award
	end
end
function C:dafuhao_game_kaijiang_response(_,data)
--	dump(data,"<color=red>----------dafuhao_game_kaijiang_response------------</color>")
    if data.result==0 then
       if data.award_id ==nil then 
          return 
       end
        if data.award_id<1 or data.award_id>10 then
          return  
       end	 
       self.getawardnum=self.getawardnum+1
       self:dengAnimation("runing")
       PlayerPrefs.SetInt("father"..MainModel.UserInfo.user_id.."alldone",self.getawardnum)
	   PlayerPrefs.SetInt(config.Awardcfg[data.award_id].award.."father"..MainModel.UserInfo.user_id,1)
       self:RunAnimation(data.award_id, "running")
       self.award_id=data.award_id
	elseif data.result==1003 then
        HintPanel.Create(1, "所有奖励已经抽到，实物奖励请联系客服，客服QQ:4008882620")
        self.getawardnum=self.getawardnum+1
        PlayerPrefs.SetInt("father"..MainModel.UserInfo.user_id.."alldone",self.getawardnum)
    else
        HintPanel.Create(1, "抽奖错误")
    end
end
function C:MyRefresh()
	for i = 1, #config.Awardcfg do
		if   PlayerPrefs.GetInt(self.LotteryChilds[self.yinshe[i]].transform:Find("Text"):GetComponent("Text").text.."father"..MainModel.UserInfo.user_id,0)==1 then
			 self.LotteryChilds[self.yinshe[i]].transform:Find("getmask").gameObject:SetActive(true)
		end  
    end
end
function C:OnHelpClick()
    IllustratePanel.Create({ self.introduce_txt }, GameObject.Find("Canvas/LayerLv5").transform)
end


function C:dengAnimation(state)
    if state == "nor" then
        if IsEquals(self.dengAnimator) then
            self.dengAnimator:Play("fqj_deng2")
        end
    end
    if state == "runing" then
        if IsEquals(self.dengAnimator) then
            self.dengAnimator:Play("fqj_deng")
        end
    end
end
function C:CloseAnimSound()
    if self.curSoundKey and self.curSoundKey ~= "" then
        soundMgr:CloseLoopSound(self.curSoundKey)
        self.curSoundKey = nil
    end
end
function C:RunAnimation(endindex, status)
    if  self.canStart==false then
    return
    end 
    self.paomadeng = {}
    for i = 1, 10 do
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
        -- dump(#self.paomadeng,"<color=red>----------动画开始了---------- </COLOR>")
        self.paomadeng[self.startindex].gameObject:SetActive(false)
        self.paomadeng[self.startindex].gameObject:SetActive(true)
        self.startindex = self.startindex + 1
        if self.startindex > 10 then
            self.startindex = 1
        end
    end, 1.2, -1)
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
        if self.startindex > 10 then
            self.startindex = 1
        end
        if allindex >= 6 then
            self.jiasu:Stop()
            self.runruning:Start()        
        end
    end, 0.4, -1)
    self.runruning = Timer.New(function()
        self.runnor:Stop()
        self.canStart = false
        allindex = allindex + 1
        self.paomadeng[self.startindex].gameObject:SetActive(false)
        self.paomadeng[self.startindex].gameObject:SetActive(true)
        self.startindex = self.startindex + 1
        if self.startindex > 10 then
            self.startindex = 1
        end
        if allindex >= 60 then
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
        if self.startindex > 10 then
            self.startindex = 1
        end
        allindex = allindex + 1
        if allindex >= 63 then
		if  self.LotteryChilds[self.startindex].transform:Find("Text"):GetComponent("Text").text==config.Awardcfg[endindex].award then
                -- dump(self.startindex,"<color=red>-------self.startindex---------</color>")
                -- dump(endindex,"<color=red>-------endindex---------</color>")
                self:CloseAnimSound()
                self.shan:Start()
                self.runend:Stop()
            end
        end
    end, 0.1, -1)
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
    end, 3, 1
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
	--dump(data,"<color=red>----------游客名字343------</color>")
	if  self.gameObject then
    Network.SendRequest("dafuhao_get_broadcast")		
	end
end
function C:OnAssetChange(data)
	dump(data,"<color=red>父亲节OnAssetChange</color>")
	if data.change_type and data.change_type == "dafuhao_game_award" then
		self.cur_award = data
	end
end
function C:SuijiShow()
	if self.Show  then
		self.Show:Stop()
	end
	self.Show=nil
	local t=math.random(2,6)
	self.Show=Timer.New(function ()
			self:ShowLotteryInfo()
			self:SuijiShow()	
	    end
	,t,-1)
	self.Show:Start()
end
function C:OnDestroy()
    self:MyExit()
    destroy(self.gameObject)
end
function C:choujiang()
    if self.award_id~= nil then
    self.runnor:Start()
   -- Event.Brocast("AssetGet",self.cur_award)
    if   config.Awardcfg[self.award_id].isgoods==true then
        ExtendSoundManager.PlaySound(audio_config.game.bgm_hall_huodewupin.audio_name)
			local string1
			string1="奖品:"..config.Awardcfg[self.award_id].award.."，抽到奖励后请联系客服领取奖励\n客服QQ：%s"				
			HintCopyPanel.Create({desc=string1})
    end
    Network.SendRequest("query_dafuhao_base_info")
	local fp=newObject("Activity88infoPrefab",self.transform:Find("RectBG/BG2/Viewport/TaskNode"))
	fp.transform:Find("Text"):GetComponent("Text").text=self.localname .."抽中了"..config.Awardcfg[self.award_id].award
	self.ShowFP[#self.ShowFP+1]=fp
    self:dengAnimation("nor")
	self.canStart = true
	self:MyRefresh()
    self.award_id=nil
    self.cur_award=nil
    end
end