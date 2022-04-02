-- 创建时间:2019-05-30
-- Panel:New Lua
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
--
--  【注意，在配置表achievement_tg_config中，在奖品信息列，默认第一个奖品是虚拟物品，如有第二个奖励，则为实物奖励】
--
AchievementTGCenterPanel = basefunc.class()
local C = AchievementTGCenterPanel
C.name = "AchievementTGCenterPanel"
local Max_Process_Length = 771
local tge_img = {
    {"sczd_imgf_thxy","sczd_imgf_1"},
	{"sczd_imgf_dqcj1","sczd_imgf_dqcj"},
}
local RealGoods = nil
local Progress_Mod = true
local curr_panel = "tgxy"
local instance
function C.Create()
    if not instance then
        instance = C.New()
    else
        instance:MyRefresh()
    end
    return instance
end

function C:AddMsgListener()
    for proto_name, func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["view_quit_game"] = basefunc.handler(self, self.Close)
    self.lister["AssetsGetPanelConfirmCallback"] = basefunc.handler(self, self.AssetsGetPanelConfirmCallback)
    self.lister["get_task_award_new_response"] = basefunc.handler(self,self.on_get_task_award_response) 
    self.lister["Refresh_TG_Achievement_Btn"] = basefunc.handler(self, self.on_refresh_TG_achievement_btn)
end

function C:RemoveListener()
    for proto_name, func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end
function C:Close()
    self:MyExit()
end

function C:MyExit() 
    self:RemoveListener()
    instance = nil
    GameObject.Destroy(self.gameObject)

	 
end

function C:ctor()

	ExtPanel.ExtMsg(self)

    local parent = GameObject.Find("Canvas/LayerLv5").transform
    local obj = newObject(C.name, parent)
    local tran = obj.transform
    self.transform = tran
    self.gameObject = obj
    curr_panel = "tgxy"
    LuaHelper.GeneratingVar(self.transform, self)
    self.ui = {}
    self:MakeLister()
    self:AddMsgListener()
    self:InitUI()
    self:OnChoose(1)
    self:ReFreshButtonStages()
end

function C:on_refresh_TG_achievement_btn()
    if not IsEquals(self.gameObject) then return end
    self:InitDQCJ_UI()
    self:ReFreshButtonStages()
    self:InitNextAwardRect_UI()
end


function C:InitUI()
    for i = 1, 2 do
        self["tgeItem" .. i .. "_tge"].onValueChanged:AddListener(
        function(val)
            ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
            self:OnToggleClick(val, i)
        end
        )
    end
    self.mc_back_btn.onClick:AddListener(
        function ()
            ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
            if curr_panel == "tgxy" then
                self:MyExit()
                GameMoneyCenterPanel.Create()
            elseif curr_panel == "dqcj" then 
                self.tgeItem1_tge.gameObject:SetActive(true)
                self.tgeItem2_tge.gameObject:SetActive(false)
                curr_panel = "tgxy"
                self:OnChoose(1)              
            end 
        end
    )
    self.gotest_btn.onClick:AddListener(
        function ()
            ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
            AchievementTGTestPanel.Create()
        end
    )
    self.show_award_btn.onClick:AddListener(
        function ()
            ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
            self.ShowAwardPanel.gameObject:SetActive(true)
        end
    )
    self.close_show_btn.onClick:AddListener(
        function ()
            ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
            self.ShowAwardPanel.gameObject:SetActive(false)
        end
    )
    self.show2_award_btn.onClick:AddListener(
        function ()
            ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
            self.ShowAwardPanel.gameObject:SetActive(true)
        end
    )
    self.get_award_btn.onClick:AddListener(
        function ()
            ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
            self:GoGetAward()
        end
    )
    self.show_tips_btn.onClick:AddListener(
        function ()
            ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
            HintPanel.Create(1,"有效定义：好友完成新人福卡第2天任务")
        end
    )
    self.way_share_btn.onClick:AddListener(
        function () 
            ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
            self:MyExit() 
            GameMoneyCenterPanel.Create("tgewm")
        end
    )
    self.share_info_btn.onClick:AddListener(
        function ()
            ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
            AchievementTGInvitePanel.Create()
        end
    )
    self.godqcj_btn.onClick:AddListener(
        function ()
            ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
            self.tgeItem1_tge.gameObject:SetActive(false)
            self.tgeItem2_tge.gameObject:SetActive(true)
            self:OnChoose(2)
            curr_panel = "dqcj"
        end
    )
    self:InitTGXY_UI()
    self:InitDQCJ_UI()
    self:InitNextAwardRect_UI()
end

function C:MyRefresh()
end

-- 当选择中一个
function C:OnChoose(index)
    self["tgeItem" .. index .. "_tge"].isOn = true
    self:HideAll()
	self["sv" .. index].gameObject:SetActive(true)
	local s = self["tgeItem" .. index .. "_tge"].gameObject.transform:Find("tge_img"):GetComponent("Image")
	s.sprite = GetTexture(tge_img[index][2])
	s:SetNativeSize() 
end


function C:HideAll()
    for i = 1, 2 do
		self["sv" .. i].gameObject:SetActive(false)
		local s = self["tgeItem" .. i .. "_tge"].gameObject.transform:Find("tge_img"):GetComponent("Image")
		s.sprite = GetTexture(tge_img[i][1])
		s:SetNativeSize() 
    end
end

function C:OnToggleClick(val, i)
    if val then
		self:OnChoose(i)		
	end
end
--TGXY = 推广学院
function C:InitTGXY_UI()
    local temp_ui = {}
    LuaHelper.GeneratingVar(self.TGPX, temp_ui)
    local data = self:InitTGXY_Model()
    for i = 1, #data do
        local temp_ui_1 = {}
        local b  = GameObject.Instantiate(temp_ui.Item,temp_ui.Content)
        b.gameObject:SetActive(true)
        LuaHelper.GeneratingVar(b.transform,temp_ui_1)
        temp_ui_1.question_txt.text = i..". "..data[i].question  
        temp_ui_1.question_txt.gameObject.transform.sizeDelta = {
            x = 800,
            y = 50,
        }
        for j=1,#data[i].answer do
            local b = GameObject.Instantiate(temp_ui_1.answer_txt,b.transform)
            b.gameObject:SetActive(true)          
            if j == 1 then
                b.transform:GetComponent("Text").text = "  答："..data[i].answer[j]
            else    
                b.transform:GetComponent("Text").text = "        "..data[i].answer[j]
            end
            b.transform.sizeDelta = {
                x = 2400,
                y = 50,
            }
        end
       
    end
end

function C:InitTGXY_Model()
    local _data = {}
    local config = AchievementTGManager.InitCfg()
    for i = 1, #config.learn do
        _data[i]= {question = config.learn[i].ask,answer =  config.learn[i].answer }
    end
    return _data 
end
--DQCJ = 当前成就
function C:InitDQCJ_UI()
    local _data = self:InitDQCJ_Model()
    local config = AchievementTGManager.InitCfg()
    URLImageManager.UpdateHeadImage(_data.head_img,self.head_img)
    self.Curr_Level.gameObject:SetActive(true)
    self.curr_level_txt.text =  _data.curr_title or self.Curr_Level.gameObject:SetActive(false)
    self.next_level_txt.text =  _data.next_title
    self.process_txt.text = _data.pro_text
    self.name_txt.text = _data.name
    self.progress_img.gameObject.transform.sizeDelta = {
        x = _data.pro_length,
        y = 32,
    }
    if _data.currlevel == #config.level then
        self.Next_Level.gameObject:SetActive(false)
    end 
end

function C:InitDQCJ_Model()
    local _data = {}
    local config = AchievementTGManager.InitCfg()
    config.level[0] = {}
    local maxlevel = #config.level
    local currlevel = AchievementTGManager.GetCurrLevel()
    local nextlevel = currlevel + 1 > maxlevel and  maxlevel or currlevel + 1
    local _point = AchievementTGManager.GetCurrPoint()
    if AchievementTGManager.GetCurrPoint() == config.level[nextlevel].need then 
        currlevel = currlevel + 1 > maxlevel and  maxlevel or currlevel + 1
        nextlevel = currlevel + 1 > maxlevel and  maxlevel or currlevel + 1
    end
    _data = {curr_title = config.level[currlevel].title,
            next_title = config.level[nextlevel].title,
            head_img = MainModel.UserInfo.head_image,
            name = MainModel.UserInfo.name,
            point = _point,
            currlevel = currlevel,
            pro_length = self:GetProcessLength(currlevel,nextlevel),
            pro_text = Mathf.Clamp((Progress_Mod and AchievementTGManager.GetCurrPoint() or AchievementTGManager.GetCurrPoint() - config.level[currlevel].need),
            0 ,(Progress_Mod and  config.level[nextlevel].need or config.level[nextlevel].need - config.level[currlevel].need)).."/"..(Progress_Mod and  config.level[nextlevel].need or config.level[nextlevel].need - config.level[currlevel].need)
            }
    return _data 
end

function C:GetProcessLength(currlevel,nextlevel)
    local config = AchievementTGManager.InitCfg()
    local x = (Progress_Mod and AchievementTGManager.GetCurrPoint() or AchievementTGManager.GetCurrPoint() - config.level[currlevel].need)
    local y = (Progress_Mod and  config.level[nextlevel].need or config.level[nextlevel].need - config.level[currlevel].need)
    local length = Mathf.Clamp( x / y  * Max_Process_Length, 0 , Max_Process_Length)
    return length
end

function C:AssetsGetPanelConfirmCallback(data)
    dump(data,"<color=red>- AssetsGetPanelConfirmCallback  - </color>")
    if data then
        if data.change_type == "sczd_achievement_sys_award" and RealGoods then 
            -- local b = RealAwardPanel.Create(RealGoods)
            -- b:SetButtonTitle("复制微信")
            -- b:SetQQtext("请联系鲸小哥微信提供收货地址领取!")
            -- RealGoods = nil 
        end
    end 
end

function C:InitNextAwardRect_UI()
    local data = self:InitNextAwardRect_Model()
    self.be_next_award_txt.text = data.title_text
    if #data.award_info> 1 then 
        self.BigAwardItem.gameObject:SetActive(false)
        self.TwoAwardItem.gameObject:SetActive(true)
        for i = 1, #data.award_info do
            self["T"..i.."_img"].sprite = GetTexture(data.award_info[i].image)
            self["T"..i.."_img"]:SetNativeSize()
            self["T"..i.."_txt"].text = data.award_info[i].text
        end
        self.T1_img1.transform:GetComponent("Image").sprite =  GetTexture(data.award_info[1].image)
        self.T2_img2.transform:GetComponent("Image").sprite =  GetTexture(data.award_info[2].image)
        self.T1_img1.transform:GetComponent("Image"):SetNativeSize()
        self.T2_img2.transform:GetComponent("Image"):SetNativeSize()
    else
        self.BigAwardItem.gameObject:SetActive(true)    
        self.TwoAwardItem.gameObject:SetActive(false)
        self.B_img.sprite = GetTexture(data.award_info[1].image)
        self.B_img:SetNativeSize()
        self.B_txt.text = data.award_info[1].text
        self.B_img_1.transform:GetComponent("Image").sprite =  GetTexture(data.award_info[1].image)
        self.B_img_1.transform:GetComponent("Image"):SetNativeSize()
    end 
end

function C:InitNextAwardRect_Model()
    local data = self:Get_Curr_Award_Data()
    return data 
end

function C:Get_Curr_Award_Data()
    local config = AchievementTGManager.InitCfg()
    local _data = {}
    local _level =  self:Get_Curr_Award_Level_AND_InitonClick() or 1
    local _award_info = {}
    for i = 1, #config.level[_level].award_name do
        _award_info[i] = {
            text =  config.level[_level].award_name[i],
            image = config.level[_level].award_img[i],
        }
    end
    _data = {
        title_text = "成为"..config.level[_level].title.."奖励",
        award_info = _award_info
    }
    return _data
end

function C:Get_Curr_Award_Level_AND_InitonClick()
    local data = AchievementTGManager.GetAwardStatusTable()
    if data == nil then return  end 
    for i=1,#data do
        if data[i] == 1 then
            self.get_award_btn.onClick:RemoveAllListeners() 
            self.get_award_btn.gameObject.transform:GetComponent("Image").sprite = GetTexture("com_btn_5")
            self.get_award_btn.enabled = true
            self.get_award_btn.onClick:AddListener(
                function ()
                    Network.SendRequest("get_task_award_new", {id = 69, award_progress_lv = i})
                    local config = AchievementTGManager.InitCfg()
                    if #config.level[i].award_name > 1 then 
                        RealGoods = {image = config.level[i].award_img[2],text = config.level[i].award_name[2]} 
                        MixAwardPopManager.Create(RealGoods,nil,2,{wx = "JY400888"})  
                    end             
                end
            )
            return i
        end
    end
    for i=1,#data do
        if data[i] == 0 then
            self.get_award_btn.onClick:RemoveAllListeners()
            self.get_award_btn.gameObject.transform:GetComponent("Image").sprite = GetTexture("com_btn_8")
            self.get_award_btn.enabled = false
            return i
        end
    end
    self.get_award_btn.onClick:RemoveAllListeners()
    self.get_award_btn.gameObject.transform:GetComponent("Image").sprite = GetTexture("com_btn_8")
    self.get_award_txt.text = "已领取"
    self.get_award_btn.enabled = false
    return #data
end

function C:GoGetAward()
    
end

function C:on_get_task_award_response(_,data)
    dump(data,"<color>任务完成时候的奖励</color>")
end

function C:ReFreshButtonStages()
    if AchievementTGManager.GetGiftStatus() == 0 then
        self.way_libao_btn.gameObject.transform:GetComponent("Image").sprite = GetTexture("com_btn_5")
        self.way_libao_txt.text = "前 往"
        self.way_libao_btn.onClick:RemoveAllListeners()
        self.way_libao_btn.onClick:AddListener(
        function () 
            ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
            self:MyExit() 
            GameMoneyCenterPanel.Create("tglb")
        end
        )
    elseif  AchievementTGManager.GetGiftStatus() == 1 then 
        self.way_libao_btn.gameObject.transform:GetComponent("Image").sprite = GetTexture("com_btn_5")
        self.way_libao_txt.text = "领 取"
        self.way_libao_btn.onClick:RemoveAllListeners()
        self.way_libao_btn.onClick:AddListener(
            function ()
                Network.SendRequest("get_task_award", {id = 72})
            end
        )
    elseif  AchievementTGManager.GetGiftStatus() == 2 then 
        self.way_libao_btn.gameObject.transform:GetComponent("Image").sprite = GetTexture("com_btn_8")
        self.way_libao_txt.text = "已领取"
        self.way_libao_btn.onClick:RemoveAllListeners()
        self.way_libao_btn.onClick:AddListener(
            function () 
                ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
                self:MyExit() 
                GameMoneyCenterPanel.Create("tglb")
            end
        )         
    end
    --------------------------------------------------
    if AchievementTGManager.GetMatchStatus() == 0 then
        self.way_bisai_btn.gameObject.transform:GetComponent("Image").sprite = GetTexture("com_btn_5")
        self.way_bisai_txt.text = "前 往"
        self.way_bisai_btn.onClick:RemoveAllListeners()
        self.way_bisai_btn.onClick:AddListener(
        function ()        
            ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
            LittleTips.Create("已复制微信号请前往微信进行添加")
			UniClipboard.SetText("JY400888")
            local b = HintPanel.Create(1,"提供游戏ID给鲸小哥免费开通比赛奖,鲸小哥微信已复制",function ()
                Application.OpenURL("weixin://")
            end)
            b:SetButtonText(nil,"前往微信")			                         
        end
    )
    elseif  AchievementTGManager.GetMatchStatus() == 1 then 
        self.way_bisai_btn.gameObject.transform:GetComponent("Image").sprite = GetTexture("com_btn_5")
        self.way_bisai_txt.text = "领 取"
        self.way_bisai_btn.onClick:RemoveAllListeners()
        self.way_bisai_btn.onClick:AddListener(
            function ()
                Network.SendRequest("get_task_award", {id = 71})
            end
        )
    elseif  AchievementTGManager.GetMatchStatus() == 2 then 
        self.way_bisai_btn.gameObject.transform:GetComponent("Image").sprite = GetTexture("com_btn_8")
        self.way_bisai_txt.text = "已领取"
        self.way_bisai_btn.onClick:RemoveAllListeners()
        self.way_bisai_btn.onClick:AddListener(
        function ()        
            ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
            LittleTips.Create("已复制微信号请前往微信进行添加")
			UniClipboard.SetText("JY400888")
            local b = HintPanel.Create(1,"提供游戏ID给鲸小哥免费开通比赛奖,鲸小哥微信已复制",function ()
                Application.OpenURL("weixin://")
            end)
            b:SetButtonText(nil,"前往微信")			    	                         
        end
    )
    end 
    --------------------------------------------------
    if AchievementTGManager.GetFAQStatus() == 0 then
        self.way_dati_btn.gameObject.transform:GetComponent("Image").sprite = GetTexture("com_btn_5")
        self.way_dati_txt.text = "前 往"
        self.way_dati_btn.onClick:RemoveAllListeners()
        self.way_dati_btn.onClick:AddListener(
            function () 
                ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
                AchievementTGTestPanel.Create()
            end
        )
    elseif  AchievementTGManager.GetFAQStatus() == 1 then 
        self.way_dati_btn.gameObject.transform:GetComponent("Image").sprite = GetTexture("com_btn_5")
        self.way_dati_txt.text = "领 取"
        self.way_dati_btn.onClick:RemoveAllListeners()
        self.way_dati_btn.onClick:AddListener(
            function ()
                Network.SendRequest("get_task_award", {id = 73})
            end
        )
    elseif  AchievementTGManager.GetFAQStatus() == 2 then 
        self.way_dati_btn.gameObject.transform:GetComponent("Image").sprite = GetTexture("com_btn_8")
        self.way_dati_txt.text = "已领取"
        self.way_dati_btn.onClick:RemoveAllListeners()
        self.way_dati_btn.onClick:AddListener(
            function () 
                ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
                AchievementTGTestPanel.Create()
            end
        )
    end 
end
