--ganshuangfeng 比赛场等待界面
--2018-04-17
local basefunc = require "Game.Common.basefunc"
ComMatchWaitStartPanel = basefunc.class()
local M = ComMatchWaitStartPanel
M.name = "ComMatchWaitStartPanel"
local lister
local listerRegisterName = "ComMatchWaitStartPanel"
local is_start = false
local instance
function M.Create(parm)
    DSM.PushAct({panel = M.name})
    SysInteractivePlayerManager.Close()
    SysInteractiveChatManager.Hide()
    if instance then
        instance:MyExit()
    end
    instance = M.New(parm)
    return instance
end

function M.CloseUI()
    if instance then
        instance:MyClose()
    end
end

function M:ctor(parm)
    self.parm = parm
    local parent = GameObject.Find("Canvas/LayerLv1").transform
    self:MakeLister()
    local obj = newObject(M.name, parent)
    local tran = obj.transform
    self.transform = tran
    self.gameObject = obj
    self:MyInit()
    self:MyRefresh()
end

function M:MyInit()
    ExtendSoundManager.PlaySceneBGM(audio_config.match.bgm_bisai_bisaidengdai.audio_name)
    LuaHelper.GeneratingVar(self.transform, self)
    self.back_btn.onClick:AddListener(
        function()
            self:OnClickCloseSignup()
        end
    )
    self.leave_btn.onClick:AddListener(
        function()
            self:OnClickLeave()
        end
    )
    self.parm.logic.setViewMsgRegister(lister, listerRegisterName)
    self.timer = Timer.New(basefunc.handler(self, self.updateCountdown), 1, -1, true)
    self.timer:Start()
    self.allPlayer = 0
    self.curPlayer = 0
    self.countdown = 0
    is_start = false
    self:RefreshSliderAndReward()
    self:refreshAllPlayer(self.parm.model.data.total_players)
    self:refreshCurPlayer(self.parm.model.data.signup_num)
end

function M:RefreshSliderAndReward()
    if MatchModel.data.game_id then
        self.transform:Find("Slider").gameObject:SetActive(true)
        if not self.RankReward then
            local game_cfg = MatchModel.GetGameCfg(MatchModel.data.game_id)
            local parent = self.transform:Find("RankReward")
            self.RankReward = ComMatchRankRewardPanel.Create(game_cfg, game_cfg.award,parent)
            self.RankReward.close_btn.gameObject:SetActive(false)
        end
    else
        self.transform:Find("Slider").gameObject:SetActive(false)
    end
end

function M:updateCountdown()
    if self.countdown and self.countdown > 0 then
        self.countdown = self.countdown - 1
        self:refreshCountDown()
    end
end

function M:refreshCountDown()
    self.close_txt.text = self.countdown .. "秒后可退出比赛"
    if self.countdown <= 0 then
        self.back_btn.interactable = true
        self.back_btn.gameObject:SetActive(true)
        self.leave_btn.interactable = true
        self.leave_btn.gameObject:SetActive(false)
        self.close_txt.gameObject:SetActive(false)
    end
end

function M:refreshAllPlayer(num)
    dump(self.parm.model.data,"<color=green>self.parm.model.data</color>")
    if self.parm.model.data and self.parm.model.data.model_status==self.parm.model.Model_Status.wait_begin  then
        if not num or num == self.allPlayer then
            return
        end
        self.allPlayer = num
        if IsEquals(self.all_player_txt) then
            self.all_player_txt.text = "满" .. num .. "人开赛"
        end
    end
end
function M:refreshCurPlayer(num)
    dump(self.parm.model.data,"<color=green>self.parm.model.data</color>")
    if self.parm.model.data and self.parm.model.data.model_status == self.parm.model.Model_Status.wait_begin then
        if not num or num == self.curPlayer or num == 0 or not self.allPlayer then
            return
        end
        if num > self.allPlayer then num = self.allPlayer end
        if is_start then return end
        if self.curPlayer == self.allPlayer then is_start = true end

        if not self.old_num then
            if num < self.curPlayer then
                self.old_num = num
                return
            end
        else
            if num < self.old_num then
                num,self.old_num = self.old_num,num
            end
        end

        self.curPlayer = num
        self.num_txt.text = num
        if self.allPlayer == 0 then return end
        local startFillAmount = self.fill_img.fillAmount
        local endFillAmount = self.curPlayer / self.allPlayer
        if startFillAmount ~= endFillAmount then
            self.waitTimer = self.parm.ani.ChangeWaitUI(self.fill_img, self.effect, startFillAmount, endFillAmount)
        end
    end
end

function M:refreshCancelSignBtn(isCancelSignup, countdown)
    if isCancelSignup == 0 then
        self.back_btn.gameObject:SetActive(false)
        return
    end

    self.back_btn.gameObject:SetActive(false)
    if not countdown then
        return
    end
    local time = math.ceil(countdown)
    if time ~= self.countdown then
        self.countdown = time
        self.back_btn.interactable = false
        self.back_btn.gameObject:SetActive(false)
        self.close_txt.gameObject:SetActive(true)
    end
    self:refreshCountDown()
end

--[[刷新功能，供Logic和model调用，重复性操作]]
function M:MyRefresh()
    if self.parm.model.data then
        self:refreshAllPlayer(self.parm.model.data.total_players)
        self:refreshCurPlayer(self.parm.model.data.signup_num)
        self:refreshCancelSignBtn(self.parm.model.data.is_cancel_signup, self.parm.model.data.countdown)
        self:RefreshSliderAndReward()
    end
end

--[[退出功能，供logic和model调用，只做一次]]
function M:MyExit()
    DSM.PopAct()
    if self.timer then
        self.timer:Stop()
    end
    if self.waitTimer then
        self.waitTimer:Stop()
    end
    if self.RankReward then
        self.RankReward:Close()
    end
    if self.parm then
        self.parm.logic.clearViewMsgRegister(listerRegisterName)
    end
    is_start = false
    lister = nil
    self.parm = nil
    GameObject.Destroy(self.gameObject)
    instance = nil
end

function M:MyClose()
    self:MyExit()
end

function M:MakeLister()
    lister = {}
    lister["model_nor_mg_req_cur_signup_num_response"] = basefunc.handler(self, self.nor_mg_req_cur_signup_num_response)
    lister["model_nor_mg_cancel_signup_fail_response"] = basefunc.handler(self, self.nor_mg_cancel_signup_fail_response)
end

function M:nor_mg_req_cur_signup_num_response(result)
    if result == 0 then
        self:refreshCurPlayer(self.parm.model.data.signup_num)
    else
        print("<color=red>mg_req_cur_signup_num_response</color>",result)
    end
end

function M:nor_mg_cancel_signup_fail_response(result)
    --错误处理 （弹窗）
    HintPanel.ErrorMsg(result)
end

function M:OnClickCloseSignup()
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    local pre = HintPanel.Create(2,"比赛即将开始，大额奖励等您领取，千万不要错过！",function ()
		Network.SendRequest("nor_mg_cancel_signup", {})
	end)
    pre:SetButtonText(nil, "残忍退出")
    pre:SetMiniHitText("确定要现在退出比赛吗？")
end

function M:OnClickLeave()
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    local pre = HintPanel.Create(2,"比赛即将开始，现在离开可能错过比赛，请记得提前来参赛哦！",function ()
		Network.SendRequest("leave_match_game", {})
	end)
	pre:SetButtonText(nil, "离开一会儿")
end