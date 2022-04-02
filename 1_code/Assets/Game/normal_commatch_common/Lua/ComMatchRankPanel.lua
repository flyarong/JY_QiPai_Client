-- 创建时间:2019-05-08
-- 比赛场公用结算界面

local basefunc = require "Game.Common.basefunc"

ComMatchRankPanel = basefunc.class()
local M = ComMatchRankPanel
M.name = "ComMatchRankPanel"

local instance

function M:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function M:MakeLister()
    self.lister = {}
    self.lister["screen_shot_end"] = basefunc.handler(self, self.screen_shot_end)
    self.lister["screen_shot_begin"] = basefunc.handler(self, self.screen_shot_begin)
    self.lister["ExitScene"] = basefunc.handler(self,self.MyExit)
end

function M:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function M:MyExit()
    if self.timerSignup then
        self.timerSignup:Stop()
    end
    self.timerSignup = nil
    if self.game_btn_pre then
        self.game_btn_pre:MyExit()
        self.game_btn_pre = nil
    end
	self.confirm_img.sprite = nil
    self:RemoveListener()
    destroy(self.gameObject)
    ComMatchReservationPanel.Close()
    instance = nil	 
end
function M:MyClose()
    M.Close()
end

-- fianlResult={rank,award} game_id
function M.Create(parm, ClearMatchData)
    ExtendSoundManager.PlaySound(audio_config.match.bgm_bisai_jieshu.audio_name)
    if SysInteractivePlayerManager then
        SysInteractivePlayerManager.Close()
    end
    if SysInteractiveChatManager then
        SysInteractiveChatManager.Hide()
    end
    if not instance then
        instance = M.New(parm, ClearMatchData)
    end
    return instance
end

function M:ctor(parm, ClearMatchData)

	ExtPanel.ExtMsg(self)

    dump(parm, "<color=white>ComMatchRankPanel parm</color>")
    self.parm = parm
    self.config = MatchModel.GetGameCfg(self.parm.game_id)
    self.ClearMatchData = ClearMatchData
    self.gameExitTime = os.time()
    self.parent = GameObject.Find("Canvas/LayerLv3").transform
    local obj = newObject(M.name, self.parent)

    self:MakeLister()
    self:AddMsgListener()
    
    self.transform = obj.transform
    self.gameObject = obj
    LuaHelper.GeneratingVar(self.transform, self)

    self:SetNamingCopyWXBtn()
    self.AwardCellList = {}
    self.camera = GameObject.Find("Canvas/Camera"):GetComponent("Camera")
    self.confirm_img = self.win_one_more_btn.transform:GetComponent("Image")
    EventTriggerListener.Get(self.close_btn.gameObject).onClick = basefunc.handler(self, self.OnClickClose)
    EventTriggerListener.Get(self.win_one_more_btn.gameObject).onClick = basefunc.handler(self, self.OnConfirmClick)
    EventTriggerListener.Get(self.share_btn.gameObject).onClick = basefunc.handler(self, self.OnClickShare)
    EventTriggerListener.Get(self.Share2Wx_btn.gameObject).onClick = function ()
        self:WeChatShareImage(false)
    end
    EventTriggerListener.Get(self.Share2Pyq_btn.gameObject).onClick = function ()
        self:WeChatShareImage(true)
    end
    self.CopyWX_btn.onClick:AddListener(
        function()
            ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
            LittleTips.Create("已复制QQ号请前往QQ进行添加")
            UniClipboard.SetText("4008882620")
        end
    )
    self.confirm_parm = "nor"
    self.share_btn.gameObject:SetActive(true)
    self.right_top.gameObject:SetActive(true)
    if not GameGlobalOnOff.ShowOff then
        self.share_btn.gameObject:SetActive(false)
        local pos = self.win_one_more_btn.transform.localPosition
        self.win_one_more_btn.transform.localPosition = Vector3.New(0, pos.y, 0)
    end

    self:InitUI()
    URLImageManager.UpdateHeadImage(MainModel.UserInfo.head_image, self.HeadImage_img)
    local btn_map = {}
	btn_map["right_top"] = {self.right_top}
    self.game_btn_pre = GameButtonPanel.Create(btn_map, "match_com_rank")
    Event.Brocast("global_sysqx_uichange_msg", {key="match_js", panelSelf=self})

    MatchModel.QuerySignupData(self.config)
end

function M:MyRefresh()
end
--[[刷新功能，供Logic和model调用，重复性操作]]
function M:InitUI()
    self:ReqSignupNum()
    self:RandomReqSignupNum()
    self.win_root.gameObject:SetActive(true)
    self.lose_root.gameObject:SetActive(false)
    self.close_btn.gameObject:SetActive(false)
    self.win_one_more_btn.gameObject:SetActive(true)
    
    self.NameText_txt.text = MainModel.UserInfo.name
    self.game_exit_time_txt.text = os.date("%Y.%m.%d %H:%M", self.gameExitTime)
    PersonalInfoManager.SetHeadFarme(self.HeadFrameImage_img)
    VIPManager.set_vip_text(self.head_vip_txt)

    if not self.parm.fianlResult then
    else
        self.close_btn.gameObject:SetActive(true)
        if self.parm.fianlResult.reward ~= nil then
            ExtendSoundManager.PlaySound(audio_config.game.sod_game_win.audio_name)
            self:RefreshWin()
        else
            ExtendSoundManager.PlaySound(audio_config.game.sod_game_lose.audio_name)
            self:RefreshWin()
        end
    end

    self:InitShare()
    HandleLoadChannelLua(M.name, self)

    --京东赛决赛预约报名
    ComMatchReservationPanel.ShowJDKZDSJS(self.config,self.parm)
end

function M:OnConfirmClick()
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    if not self.confirm_parm or self.confirm_parm == "nor" then
        self:OnClickGotoMatch()
    elseif self.confirm_parm == "next" then
        self:OnClickOneMore()
    elseif self.confirm_parm == "by" then
        self:OnClickGotoBY()
    elseif self.confirm_parm == "dh" then
        MainModel.OpenDH()
    end
end

function M:OnClickGotoBY()
    print("<color=yellow>跳转捕鱼</color>")
    local quit_game = function(data)
        if data.result == 0 then
            MainLogic.ExitGame()
            GameManager.GotoUI({gotoui="game_FishingHall"})
        else
            HintPanel.ErrorMsg(data.result)
        end
    end
    Network.SendRequest("nor_mg_quit_game",nil,"退出报名",quit_game)    
end
function M:OnClickGotoMatch()
    print("<color=yellow>跳转比赛场大厅</color>")
    local quit_game = function(data)
        if data.result == 0 then
            MainLogic.ExitGame()
            MatchModel.SetCurHallType(self.config.hall_type)
            GameManager.GotoUI({gotoui="match_hall"})
        else
            HintPanel.ErrorMsg(data.result)
        end
    end
    Network.SendRequest("nor_mg_quit_game",nil,"退出报名",quit_game)
end

function M:OnClickOneMore()
    local config = MatchModel.GetGameCfg(self.parm.game_id)
    -- 重新开始比赛
    MatchLogic.ReplayMatch(config)
end

function M:ShowBack(b)
    if not IsEquals(self.gameObject) then return end
    self.close_btn.gameObject:SetActive(b)
    self.Share2Wx_btn.gameObject:SetActive(b)
    self.Share2Pyq_btn.gameObject:SetActive(b)
    if b then
        self:SetNamingCopyWXBtn()
    else
        self.CopyWX_btn.gameObject:SetActive(false)
    end

    self.ShareRect.gameObject:SetActive(not b)
    self.right_top.gameObject:SetActive(b)
end
function M:OnClickShare()
    self.is_shareing = true
    self.Share2Wx_btn.gameObject:SetActive(true)
    self.Share2Pyq_btn.gameObject:SetActive(true)
    self.win_one_more_btn.gameObject:SetActive(false)
    self.share_btn.gameObject:SetActive(false)
    -- self.right_top.gameObject:SetActive(false)
    self.confirm_hint_txt.gameObject:SetActive(false)
end

function M:WeChatShareImage(isCircleOfFriends)
    self.share_cfg.isCircleOfFriends = isCircleOfFriends
    GameManager.GotoUI({gotoui = "sys_fx",goto_scene_parm = "image",share_cfg = self.share_cfg})
end

function M.Close()
    if instance and IsEquals(instance.transform) then
        instance:MyExit()
    end
end

function M:OnClickClose()
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    if self.is_shareing then
        self.is_shareing = false
        self.win_one_more_btn.gameObject:SetActive(true)
        self.share_btn.gameObject:SetActive(true)
        self.right_top.gameObject:SetActive(true)
        self.Share2Wx_btn.gameObject:SetActive(false)
        self.Share2Pyq_btn.gameObject:SetActive(false)
        self.confirm_hint_txt.gameObject:SetActive(true)
    else
        Network.SendRequest("nor_mg_quit_game", nil, "退出比赛")
    end
end

function M:RefreshWin()
    self.win_root.gameObject:SetActive(true)
    self.lose_root.gameObject:SetActive(false)

    self.my_rank_txt.text = "第" .. self.parm.fianlResult.rank .. "名"
    self.tophint_txt.text = "恭喜  " .. MainModel.UserInfo.name .. "\n" .. "在【" .. self.parm.game_name .. "】中获得"
    self.my_rank_times_txt.gameObject:SetActive(false)

    local start_type = self.config.start_type
    dump(start_type, "<color=white>start_type>>>></color>")
    if start_type == 1 then
        dump(self.parm.fianlResult.detailRanknum,"<color=red>锦标赛结束----------------</color>")
        if self.parm.fianlResult.detailRanknum then 
            for i=1,#self.parm.fianlResult.detailRanknum do  
                if i == self.parm.fianlResult.rank then
                    self.my_rank_times_txt.text=self.parm.fianlResult.detailRanknum[i].."次"
                    self.my_rank_times_txt.gameObject:SetActive(true)
                end 
            end 
        end
    else
        if self.parm.fianlResult.qys_top_rank then
            self.my_rank_times_txt.text= string.format( "历史最高第%s名",self.parm.fianlResult.qys_top_rank)
            self.my_rank_times_txt.gameObject:SetActive(true)
        end
    end

    self:CloseAwardCell()
    --根据当前名次显示对应信息
    local award_desc, award_icon, is_local_icons = MatchModel.GetAwardByRank(self.parm.game_id, self.parm.fianlResult.rank)
    if (self.parm.fianlResult.reward and next(self.parm.fianlResult.reward)) or (award_desc and #award_desc > 0) then
        self.my_rank_txt.transform.localPosition = Vector3.New(0, 312, 0)
        if award_desc and next(award_desc) then
            for i = 1, #award_desc do
                local v = {}
                v.desc = award_desc[i]
                v.icon = award_icon[i]
                if is_local_icons then
                    v.is_local_icon = is_local_icons[i]
                end
                self.AwardCellList[#self.AwardCellList + 1] = self:CreateItem(v)
            end
        else
            self.my_rank_txt.transform.localPosition = Vector3.New(0, 0, 0)
        end
    else
        self.my_rank_txt.transform.localPosition = Vector3.New(0, 0, 0)
    end

    if self.parm.fianlResult.rank < 4 then
        self:OnClickShare()
    end

    -- 实物赛需要的逻辑处理
    self.confirm_hint_txt.gameObject:SetActive(false)
    self.confirm_hint_txt.text = ""

    if false and self.parm.fianlResult.reward then
        local data = AwardManager.GetAwardList(self.parm.fianlResult.reward)
        local is_yb = false -- 是否有奖励鱼币
        local is_hb = false -- 是否有奖励福卡
        local hb_value = 0 -- 奖励福卡数量
        for k,v in ipairs(data) do
            if v.type == "fish_coin" then
                is_yb = true
            end
            if v.type == "shop_gold_sum" then
                is_hb = true
                hb_value = v.value
            end
        end
        if is_yb and is_hb then
            self.confirm_parm = "nor"
            self.confirm_img.sprite = GetTexture("settlement_btn_gdbs")
            print("<color=red>奖励同时存在鱼币和福卡</color>")
        else
            if is_yb then
                self.confirm_parm = "by"
                self.confirm_img.sprite = GetTexture("settlement_btn_qwby_normal_commatch_common")
                self.confirm_hint_txt.text =""-- "街机捕鱼专属道具，可转化为大量鲸币"
                self.confirm_hint_txt.gameObject:SetActive(true)
            elseif is_hb then
                self.confirm_parm = "dh"
                self.confirm_img.sprite = GetTexture("settlement_btn_qwdh")
                self.confirm_hint_txt.text =""-- "恭喜您获得" .. hb_value .. "话费，已为您转换成等价值福卡"
                self.confirm_hint_txt.gameObject:SetActive(true)
            else
                if self.config.hall_type == MatchModel.HallType.fks then
                    --进行下一场报名
                    self.confirm_parm = "next"
                    self.confirm_img.sprite = GetTexture("settlement_btn_next_normal_commatch_common")          
                else
                    self.confirm_parm = "nor"
                    self.confirm_img.sprite = GetTexture("settlement_btn_gdbs")
                end
                print("<color=red>奖励同时不存在鱼币和福卡</color>")
            end
        end
    else
        if self.config.hall_type == MatchModel.HallType.fks then
            --进行下一场报名
            self.confirm_parm = "next"
            self.confirm_img.sprite = GetTexture("settlement_btn_next_normal_commatch_common")          
        else
            self.confirm_parm = "nor"
            self.confirm_img.sprite = GetTexture("settlement_btn_gdbs")
        end
    end
end

function M:CloseAwardCell()
    for i, v in ipairs(self.AwardCellList) do
        GameObject.Destroy(v.gameObject)
    end
    self.AwardCellList = {}
end
function M:CreateItem(data)
    local obj = GameObject.Instantiate(self.AwardPrefab)
    obj.transform:SetParent(self.AwardNode)
    obj.transform.localScale = Vector3.one
    local DescText = obj.transform:Find("DescText"):GetComponent("Text")
    DescText.text = data.desc
    local NameText = obj.transform:Find("AwardIcon/NameText"):GetComponent("Text")
    NameText.text = ""
    obj.gameObject:SetActive(true)
    local AwardIcon = obj.transform:Find("AwardIcon"):GetComponent("Image")
    GetTextureExtend(AwardIcon, data.icon, data.is_local_icon)
        
    return obj
end

function M:SetNamingCopyWXBtn()
    local award_desc, award_icon, is_local_icons = MatchModel.GetAwardByRank(self.parm.game_id, self.parm.fianlResult.rank)
    if not (self.parm.fianlResult.reward and next(self.parm.fianlResult.reward)) and (award_desc and #award_desc > 0) then
        self.CopyWX_btn.gameObject:SetActive(true)
    else
        self.CopyWX_btn.gameObject:SetActive(false)
    end
end

-- 请求报名人数
function M:ReqSignupNum()
    Network.SendRequest("nor_mg_req_specified_signup_num", {id = self.config.game_id})
end

-- 返回报名人数消息
function M:model_nor_mg_req_specified_signup_num(data)
    if data.result == 0 then
        if data.id == self.config.game_id then
            self.signup_num = data.signup_num
        end
    end
    self:RandomReqSignupNum()
end

-- 随机间隔时间请求
function M:RandomReqSignupNum()
    if self.timerSignup then
        self.timerSignup:Stop()
    end
    local t = math.random(200, 400) * 0.01
    self.timerSignup = Timer.New(function ()
        self:ReqSignupNum()
    end, t, 1, true)
    self.timerSignup:Start()
end

function M:InitShare()
    if self.config.match_type == MatchModel.MatchType.qydjs then
        self.share_cfg = basefunc.deepcopy(share_link_config.img_match_ddz_qydjs)
    else
        self.share_cfg = basefunc.deepcopy(share_link_config.img_match_ddz_hbs)
    end
    self.qr_code_img = self.EWMImage_img
    self.head_img = self.IconImage_img
    self.logo_img = self.LogoImage:GetComponent("Image")
    ShareHelper.RefreshQRCode(self.qr_code_img,self.share_cfg)
    ShareHelper.RefreshImage(self.head_img,self.logo_img,self.invite_txt)
    -- self:ShowBack(true)
end

function M:screen_shot_begin(  )
    AddCanvasAndSetSort(self.gameObject, 100)
    self:ShowBack(false)
end

function M:screen_shot_end(  )
    RemoveCanvas(self.gameObject)
    self:ShowBack(true)
end