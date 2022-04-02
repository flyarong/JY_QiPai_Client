-- 创建时间:2019-05-08
-- 比赛场公用结算界面

local basefunc = require "Game.Common.basefunc"

FishingMatchComRankPanel = basefunc.class()
local C = FishingMatchComRankPanel
C.name = "FishingMatchComRankPanel"

local instance

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["fsmg_quit_game_response"] = basefunc.handler(self, self.on_fsmg_quit_game_response)
    self.lister["screen_shot_end"] = basefunc.handler(self, self.screen_shot_end)
    self.lister["screen_shot_begin"] = basefunc.handler(self, self.screen_shot_begin)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
    destroy(self.gameObject)
    self:RemoveListener()
    instance = nil
end
function C:MyClose()
    self:RemoveListener()
    C.Close()
end
--退出游戏
function C:on_fsmg_quit_game_response(_, data)
    dump(data, "<color=yellow>on_fsmg_quit_game_response</color>")
    if data.result == 0 then
        MainLogic.ExitGame()
        GameManager.GotoUI({gotoui="game_FishingHall"})
    else
        HintPanel.ErrorMsg(data.result)
    end
end

function C.Create(parm, ClearMatchData)
    ExtendSoundManager.PlaySound(audio_config.by.bgm_bisai_jieshu_normal_fishing_common.audio_name)
    if not instance then
        instance = C.New(parm, ClearMatchData)
    end
    return instance
end

function C:ctor(parm, ClearMatchData)

	ExtPanel.ExtMsg(self)

    dump(parm, "<color=white>FishingMatchComRankPanel parm</color>")
    if not parm then return end
    self.parm = parm
    self.config = FishingManager.GetGameIDToConfig(self.parm.game_id)
    self.ClearMatchData = ClearMatchData
    self.gameExitTime = os.time()
    if self.parm.is_old_rank then
        self.parent = GameObject.Find("Canvas/LayerLv5").transform
    else
        self.parent = GameObject.Find("Canvas/LayerLv3").transform
    end
    local obj = newObject(C.name, self.parent)

    self:MakeLister()
    self:AddMsgListener()

    self.transform = obj.transform
    self.gameObject = obj
    LuaHelper.GeneratingVar(self.transform, self)


    self:SetNamingCopyWXBtn()
    self.AwardCellList = {}
    self.camera = GameObject.Find("Canvas/Camera"):GetComponent("Camera")

    self.confirm_img = self.goto_fishing_btn.transform:GetComponent("Image")
    EventTriggerListener.Get(self.close_btn.gameObject).onClick = basefunc.handler(self, self.OnClickClose)
    EventTriggerListener.Get(self.goto_fishing_btn.gameObject).onClick = basefunc.handler(self, self.OnConfirmClick)
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
    self.share_btn.gameObject:SetActive(true)

    if not GameGlobalOnOff.ShowOff then
        self.share_btn.gameObject:SetActive(false)
        local pos = self.goto_fishing_btn.transform.localPosition
        self.goto_fishing_btn.transform.localPosition = Vector3.New(0, pos.y, 0)
    end
    -- 上期排名打开界面不显示前往捕鱼按钮
    if self.parm.is_old_rank then
        self.goto_fishing_btn.gameObject:SetActive(false)
    end

    self:InitUI()

    DOTweenManager.OpenPopupUIAnim(self.transform)
end

function C:MyRefresh()
end

function C:InitUI()
    self.win_root.gameObject:SetActive(true)
    self.lose_root.gameObject:SetActive(false)
    self.close_btn.gameObject:SetActive(false)

    URLImageManager.UpdateHeadImage(MainModel.UserInfo.head_image, self.HeadImage_img, function ()
        self.loadHeadFinish = true
    end, "share_head_url_nnn")
    self.NameText_txt.text = MainModel.UserInfo.name
    self.game_exit_time_txt.text = os.date("%Y.%m.%d %H:%M", self.gameExitTime)
    PersonalInfoManager.SetHeadFarme(self.HeadFrameImage_img)
    VIPManager.set_vip_text(self.head_vip_txt)

    self.yingfen_txt.text = StringHelper.ToCash(self.parm.grades or 0)
    if self.parm.fianlResult then
        self.close_btn.gameObject:SetActive(true)
        -- 注意这里的判断 reward的第一个是额外奖励，如果有固定奖励就还有第二个值
        local reward = self.parm.fianlResult.reward
        if reward and #reward > 0 and (reward[1].value > 0 or (reward[2] and reward[2].value > 0)) then
            ExtendSoundManager.PlaySound(audio_config.game.sod_game_win.audio_name)
            self:RefreshWin()
        else
            ExtendSoundManager.PlaySound(audio_config.game.sod_game_lose.audio_name)
            self:RefreshLose()
        end
    end
    self:InitShare()
    HandleLoadChannelLua(C.name, self)
end

function C:OnConfirmClick()
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    self:OnClickGotoBY()
end

function C:OnClickGotoBY()
    print("<color=yellow>跳转捕鱼</color>")
    local quit_game = function(data)
        MainLogic.ExitGame()
        GameManager.GotoUI({gotoui="game_FishingHall"})
    end
    if self.parm.is_old_rank then
        quit_game()
    else
        if Network.SendRequest("fsmg_quit_game",nil,"退出报名",quit_game) then
            self.ClearMatchData(self.parm.game_id)
        else
            MjAnimation.Hint(2, Vector3.New(0, -350, 0), Vector3.New(0, 0, 0))
        end    
    end
end
function C:ShowBack(b)
    self.close_btn.gameObject:SetActive(b)
    self.Share2Wx_btn.gameObject:SetActive(b)
    self.Share2Pyq_btn.gameObject:SetActive(false)
    if b then
        self:SetNamingCopyWXBtn()
    else
        self.CopyWX_btn.gameObject:SetActive(false)
    end

    self.ShareRect.gameObject:SetActive(not b)
end
function C:OnClickShare()
    self.is_shareing = true
    self.Share2Wx_btn.gameObject:SetActive(true)
    self.Share2Wx_btn.transform.localPosition = Vector3.New(0, -455, 0)
    self.Share2Pyq_btn.gameObject:SetActive(false)
    self.share_btn.gameObject:SetActive(false)
    self.confirm_hint_txt.gameObject:SetActive(false)
    if not self.parm.is_old_rank then
        self.goto_fishing_btn.gameObject:SetActive(false)
    end
end
function C:WeChatShareImage(isCircleOfFriends)
    self.share_cfg.isCircleOfFriends = isCircleOfFriends
    GameManager.GotoUI({gotoui = "sys_fx",goto_scene_parm = "image",share_cfg = self.share_cfg})
end

function C.Close()
    if instance then
        instance:MyExit()
    end
end

function C:OnClickClose()
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    if self.is_shareing then
        self.is_shareing = false

        self.share_btn.gameObject:SetActive(true)
        self.Share2Wx_btn.gameObject:SetActive(false)
        self.Share2Pyq_btn.gameObject:SetActive(false)
        self.confirm_hint_txt.gameObject:SetActive(true)
        if not self.parm.is_old_rank then
            self.goto_fishing_btn.gameObject:SetActive(true)
        end
    else
        if self.parm.is_old_rank then
            C.Close()
        else
            FishingMatchLogic.quit_game()
            self.ClearMatchData(self.parm.game_id)
        end
    end
end

function C:RefreshLose()
    self.win_root.gameObject:SetActive(false)
    self.lose_root.gameObject:SetActive(true)
    self.losehint4_txt.text = self.parm.fianlResult.rank
end

function C:RefreshWin()
    self.win_root.gameObject:SetActive(true)
    self.lose_root.gameObject:SetActive(false)

    self.my_rank_txt.text = self.parm.fianlResult.rank

    self:CloseAwardCell()
    --根据当前名次显示对应信息
    local award_desc, award_icon, is_local_icons = FishingManager.GetAwardByRank(self.parm.game_id, self.parm.fianlResult.rank)
    if not award_desc then
        award_desc = {}
        award_icon = {}
    end
    local ey_award_desc = {}
    local ey_award_icon = {}
    if self.parm.fianlResult.reward and #self.parm.fianlResult.reward > 0 then
        -- 第一个是额外奖励
        local v = self.parm.fianlResult.reward[1]
        if v.value and v.value > 0 then
            ey_award_desc[#ey_award_desc + 1] = "奖池福卡x" .. StringHelper.ToRedNum(v.value/100)
            ey_award_icon[#ey_award_icon + 1] = "matchpop_icon_3"
        end
    end
    if award_desc and next(award_desc) then
        for i = 1, #award_desc do
            if award_desc[i] ~= "" then
                local v = {}
                v.desc = award_desc[i]
                v.icon = award_icon[i]
                if is_local_icons then
                    v.is_local_icon = is_local_icons[i]
                end
                self.AwardCellList[#self.AwardCellList + 1] = self:CreateItem(v)
            end
        end
    end
    if ey_award_desc and next(ey_award_desc) then
        for i = 1, #ey_award_desc do
            if ey_award_desc[i] ~= "" then
                local v = {}
                v.desc = ey_award_desc[i]
                v.icon = ey_award_icon[i]
                if is_local_icons then
                    v.is_local_icon = is_local_icons[i]
                end
                self.AwardCellList[#self.AwardCellList + 1] = self:CreateItem(v)
            end
        end
    end

    if self.parm.fianlResult.rank < 4 then
        self:OnClickShare()
    end
end

function C:CloseAwardCell()
    for i, v in ipairs(self.AwardCellList) do
        destroy(v.gameObject)
    end
    self.AwardCellList = {}
end
function C:CreateItem(data)
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

function C:SetNamingCopyWXBtn()
    if self.parm and self.parm.fianlResult and self.parm.fianlResult.rank < 4 then
        self.CopyWX_btn.gameObject:SetActive(true)
    else
        self.CopyWX_btn.gameObject:SetActive(false)
    end
end

function C:InitShare()
    self.share_cfg = basefunc.deepcopy(share_link_config.img_match_fishing)
    self.qr_code_img = self.EWMImage_img
    self.head_img = self.IconImage_img
    self.logo_img = self.LogoImage:GetComponent("Image")
    self.invite_txt = self.invite_txt
    ShareHelper.RefreshQRCode(self.qr_code_img,self.share_cfg)
    ShareHelper.RefreshImage(self.head_img,self.logo_img,self.invite_txt)
    -- self:ShowBack(true)
end

function C:screen_shot_begin(  )
    AddCanvasAndSetSort(self.gameObject, 100)
    self:ShowBack(false)
end

function C:screen_shot_end(  )
    RemoveCanvas(self.gameObject)
    self:ShowBack(true)
end
