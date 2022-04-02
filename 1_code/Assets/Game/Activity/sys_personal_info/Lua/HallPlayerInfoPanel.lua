-- 创建时间:2018-11-08
local basefunc = require "Game.Common.basefunc"

HallPlayerInfoPanel = basefunc.class()

HallPlayerInfoPanel.name = "HallPlayerInfoPanel"

local instance
function HallPlayerInfoPanel.Create(parent, parm)
    instance = HallPlayerInfoPanel.New(parent, parm)
    return instance
end
function HallPlayerInfoPanel.Exit()
    if instance then
        instance:MyExit()
    end
    instance = nil
end

function HallPlayerInfoPanel:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function HallPlayerInfoPanel:MakeLister()
    self.lister = {}
    self.lister["AssetChange"] = basefunc.handler(self, self.RefreshMoney)
    self.lister["update_verifide"] = basefunc.handler(self, self.UpdateVerifide)
    self.lister["update_playerinfo_match"] = basefunc.handler(self, self.UpdateMatch)
    self.lister["update_playerinfo_win"] = basefunc.handler(self, self.UpdateWinRate)
    self.lister["update_query_bind_phone"] = basefunc.handler(self, self.UpdateBindPhone)
    self.lister["set_player_name"] = basefunc.handler(self, self.set_player_name)
    self.lister["set_head_image"] = basefunc.handler(self, self.set_head_image)

    self.lister["SYSChangeHeadAndNameManager_Change_Name_Success_msg"] = basefunc.handler(self,self.on_SYSChangeHeadAndNameManager_Change_Name_Success_msg)
    self.lister["SYSChangeHeadAndNameManager_Change_Head_Success_msg"] = basefunc.handler(self,self.on_SYSChangeHeadAndNameManager_Change_Head_Success_msg)
end

function HallPlayerInfoPanel:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function HallPlayerInfoPanel:ctor(parent, parm)

	ExtPanel.ExtMsg(self)

    local obj = newObject(HallPlayerInfoPanel.name, parent)
    local tran = obj.transform
    self.transform = tran
    self.gameObject = obj
    LuaHelper.GeneratingVar(self.transform, self)

    EventTriggerListener.Get(self.certified_btn.gameObject).onClick = basefunc.handler(self, self.OnClickCertified)
    EventTriggerListener.Get(self.binding_btn.gameObject).onClick = basefunc.handler(self, self.OnClickBindingPhone)
    EventTriggerListener.Get(self.change_binding_btn.gameObject).onClick = basefunc.handler(self, self.OnClickBindingPhone)
    self:RefreshMoney()

    --[[local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key="drt_block_binding_phone_num", is_on_hint = true}, "CheckCondition")
    local bindphone = (not a or (a and not b)) and GameGlobalOnOff.BindingPhone
    self.Binding.gameObject:SetActive(bindphone)
    local Certified = tran:Find("Certified")--]]
    if IsEquals(Certified) then
        local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key="drt_block_real_name_verify", is_on_hint = true}, "CheckCondition")
        if (a and b) or not GameGlobalOnOff.Certification then
            Certified.gameObject:SetActive(false)
        end
    end

    if gameMgr:getMarketChannel() == "hw_cymj" then
        local position = self.certified_btn.transform.position
        self.binding_btn.transform.position = position
        self.change_binding_btn.transform.position = position
	self.certified_btn.gameObject:SetActive(false)
    end

    self.imgsex_man = tran:Find("ImgCenter/Btn_Sex_Man/imgsex_man").gameObject
    self.imgsex_Woman = tran:Find("ImgCenter/Btn_Sex_Woman/imgsex_Woman").gameObject

    self.Btn_Sex_Man = tran:Find("ImgCenter/Btn_Sex_Man"):GetComponent("Button")
    self.Btn_Sex_Woman = tran:Find("ImgCenter/Btn_Sex_Woman"):GetComponent("Button")
    self.Btn_Sex_Man.onClick:AddListener(function ()
        self:SetNan()
    end)
    self.Btn_Sex_Woman.onClick:AddListener(function ()
        self:SetNv()
    end)
    self:MakeLister()
    self:AddMsgListener()

    PersonalInfo.Init()

    self:InitUI()
    PersonalInfo.ReqPersonalInfo()

    --[[local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key="drt_block_binding_phone_num", is_on_hint = true}, "CheckCondition")
    if (not a or (a and not b)) and GameGlobalOnOff.BindingPhone and parm and parm.open_award then
        if not MainModel.UserInfo.phoneData or not MainModel.UserInfo.phoneData.phone_no then
            print("<color=red>？？？？？？22222</color>")
            GameManager.GotoUI({gotoui = "sys_binding_phone",goto_scene_parm = "panel"})
        end
    end--]]
    if not MainModel.UserInfo.phoneData or not MainModel.UserInfo.phoneData.phone_no then
        print("<color=red>？？？？？？22222</color>")
        GameManager.GotoUI({gotoui = "sys_binding_phone",goto_scene_parm = "panel"})
    end

-----------------------------------------------------------------👇
--创建修改昵称和设置头像的按钮
    Event.Brocast("NewPersonPanel_to_SYSChangeHeadAndNameManager_msg",{head_node = self.SYSChangeHead_node.transform, name_node = self.SYSChangeName_node.transform})
-----------------------------------------------------------------👆
    
    if not GameGlobalOnOff.Exchange then
        self.transform:Find("ImgCenter/Imgshop").gameObject:SetActive(false)
    end
end

function HallPlayerInfoPanel:RefreshMoney()
end

function HallPlayerInfoPanel:MyRefresh()
	
end

--初始化UI
function HallPlayerInfoPanel:InitUI()
    self.player_name_txt.text = MainModel.UserInfo.name
    self.player_id_txt.text = MainModel.UserInfo.user_id
    URLImageManager.UpdateHeadImage(MainModel.UserInfo.head_image, self.player_head_img)
    if PersonalInfoManager then
        PersonalInfoManager.SetHeadFarme(self.player_headframe_img)
    end
    VIPManager.set_vip_text(self.head_vip_txt)

    self:UpdateWinRate()
    self:UpdateMatch()
    self:UpdateVerifide()
    self:UpdateNanNv()
    self:UpdateBindPhone()

    self.shop_txt.text = StringHelper.ToRedNum(MainModel.GetHBValue())
    self.gold_txt.text = StringHelper.ToCash(MainModel.UserInfo.jing_bi)
    self.diamond_txt.text = StringHelper.ToCash(MainModel.UserInfo.diamond)

    self:SetHonor()
    GameManager.GotoUI({gotoui = "sys_open_install_binding",goto_scene_parm = "player_info"})
    GameManager.GotoUI({gotoui = "sys_change_head_and_name",goto_scene_parm = "player_info"})
end
function HallPlayerInfoPanel:UpdateVerifide()
    if not IsEquals(self.certified_btn) then
        return
    end
    local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key="drt_block_real_name_verify", is_on_hint = true}, "CheckCondition")
    if (a and b) or not GameGlobalOnOff.Certification then
        self.certified_btn.gameObject:SetActive(false)
        return
    end

    if MainModel.UserInfo.verifyData and MainModel.UserInfo.verifyData.status then
        local status = MainModel.UserInfo.verifyData.status == 4
        if IsEquals(self.certified_btn) then
            self.certified_btn.gameObject:SetActive(not status)
        end
        if IsEquals(self.certified_end_img) then
            self.certified_end_img.gameObject:SetActive(status)
        end
    else
        local status = false
        if IsEquals(self.certified_btn) then
            self.certified_btn.gameObject:SetActive(not status)
        end
        if IsEquals(self.certified_end_img) then
            self.certified_end_img.gameObject:SetActive(status)
        end
    end
end
function HallPlayerInfoPanel:UpdateMatch(data)
    
    if data then
        self.first_num_txt.text = "x"..data.first
        self.second_num_txt.text = "x"..data.second
        self.third_num_txt.text = "x"..data.third
    else
        self.first_num_txt.text = "x0"
        self.second_num_txt.text = "x0"
        self.third_num_txt.text = "x0"
    end
    
end

function HallPlayerInfoPanel:UpdateWinRate(data)
    if data then
        self.game_count_txt.text = data.all_count
        local rate = 0
        if data.all_count > 0 then
            rate = data.win_count / data.all_count
        end
        rate = rate * 100
        self.win_rate_txt.text = string.format("%.2f", rate) .. "%"


	if MainModel.UserInfo and MainModel.UserInfo.glory_data then
		Event.Brocast("trace_level_fight_msg", {level = MainModel.UserInfo.glory_data.level, fight_value = rate})
	end
    else
        self.game_count_txt.text = "--"
        self.win_rate_txt.text = "--"
    end
end
function HallPlayerInfoPanel:UpdateBindPhone()
	if GameGlobalOnOff.BindingPhone then
		if MainModel.UserInfo.phoneData and MainModel.UserInfo.phoneData.phone_no then
			self.binding_btn.gameObject:SetActive(false)
			self.binding_end_img.gameObject:SetActive(true)
		else
			self.binding_btn.gameObject:SetActive(true)
			self.binding_end_img.gameObject:SetActive(false)
		end
	else
		self.binding_btn.gameObject:SetActive(false)
		self.binding_end_img.gameObject:SetActive(false)
	end
end

function HallPlayerInfoPanel:UpdateNanNv()
    if MainModel.UserInfo.sex == 1 then
        self.imgsex_man:SetActive(true)
        self.imgsex_Woman:SetActive(false)
    else
        self.imgsex_man:SetActive(false)
        self.imgsex_Woman:SetActive(true)
    end
end

function HallPlayerInfoPanel:MyClose()
	self:MyExit()
end

function HallPlayerInfoPanel:MyExit()
    PersonalInfo.Exit()
    self:RemoveListener()
    destroy(self.gameObject)
end

function HallPlayerInfoPanel:SetNan()
    Network.SendRequest("set_sex", {sex = 1}, "设置性别", function (data)
        if data.result == 0 then
            MainModel.UserInfo.sex = 1
            self:UpdateNanNv()
        else
            HintPanel.ErrorMsg(data.result)
        end
    end)
end
function HallPlayerInfoPanel:SetNv()
    Network.SendRequest("set_sex", {sex = 0}, "设置性别", function (data)
        if data.result == 0 then
            MainModel.UserInfo.sex = 0
            self:UpdateNanNv()
        else
            HintPanel.ErrorMsg(data.result)
        end
    end)
end

--[[点击实名认证]]
function HallPlayerInfoPanel:OnClickCertified(go)
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    GameManager.GotoUI({gotoui = "sys_binding_verifide",goto_scene_parm = "panel"})
end

--绑定手机
function HallPlayerInfoPanel:OnClickBindingPhone(go)
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    GameManager.GotoUI({gotoui = "sys_binding_phone",goto_scene_parm = "panel"})
end

--荣誉
function HallPlayerInfoPanel:SetHonor()
    if not GameHonorModel then return end
    EventTriggerListener.Get(self.honor_btn.gameObject).onClick = basefunc.handler(self, self.OnClickHonor)
    local cur_honor_data = GameHonorModel.GetCurHonorData()
    local prev_honor_data = GameHonorModel.GetHonorDataByID(cur_honor_data.level - 1)
    local honor_config = GameHonorModel.GetHonorDataByID()
    dump(honor_config, "<color=yellow>honor_config</color>")

    local cur_honor_val = GameHonorModel.GetCurHonorValue()
    self.slider = self.honor.transform:Find("Slider"):GetComponent("Slider")
    if cur_honor_data then
        self.honor_txt.text = string.format( "%s",cur_honor_data.level_name)
        if cur_honor_data.level == honor_config[#honor_config].level then
            self.slider.value = 1
            self.progress_txt.text = "已到达最高等级"
        else
            local now_process = cur_honor_val - cur_honor_data.min_val
            local need_process = 0
            if prev_honor_data then
                need_process = cur_honor_data.max_val - prev_honor_data.max_val
            else
                need_process = cur_honor_data.max_val - 0
            end
            
            self.progress_txt.text = now_process .. "/" .. need_process
        
            local process = now_process / need_process
            if process > 1 then
                process = 1
            end
            self.slider.value = process == 0 and 0 or 0.95 * process + 0.05 
        end
    end
    if GameGlobalOnOff.Honor == false then
        self.honor.gameObject:SetActive(false)
    end
end

function HallPlayerInfoPanel:OnClickHonor(obj)
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    --荣誉等级
    HallDotRulePanel.Create()
end

function HallPlayerInfoPanel:set_player_name(  )
    self.player_name_txt.text = MainModel.UserInfo.name
end

function HallPlayerInfoPanel:set_head_image(  )
    URLImageManager.UpdateHeadImage(MainModel.UserInfo.head_image, self.player_head_img)
end

--修改昵称成功,刷新昵称显示
function HallPlayerInfoPanel:on_SYSChangeHeadAndNameManager_Change_Name_Success_msg()
    self.player_name_txt.text = MainModel.UserInfo.name
end

--设置头像成功,刷新头像显示
function HallPlayerInfoPanel:on_SYSChangeHeadAndNameManager_Change_Head_Success_msg()
    URLImageManager.UpdateHeadImage(MainModel.UserInfo.head_image, self.player_head_img)
end