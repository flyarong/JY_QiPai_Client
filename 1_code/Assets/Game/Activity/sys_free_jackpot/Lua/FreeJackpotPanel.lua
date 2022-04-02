-- 创建时间:2018-11-1
local basefunc = require "Game.Common.basefunc"
FreeJackpotPanel = basefunc.class()

local instance

function FreeJackpotPanel.Create(data, change_money)
    if not instance then
        instance = FreeJackpotPanel.New(data, change_money)
    end
    return instance
end

function FreeJackpotPanel:ctor(data, change_money)

	ExtPanel.ExtMsg(self)

    self.data = data
    self.change_money = change_money
    -- dump(self.data, "<color=yellow>>>>>>>>>>>>>>>>>>>>>>data:</color>")
    local parent = GameObject.Find("Canvas/LayerLv4")
    self.gameObject = newObject("FreeJackpotPanel", parent.transform)
    self.transform = self.gameObject.transform
    LuaHelper.GeneratingVar(self.transform, self)
    EventTriggerListener.Get(self.close_btn.gameObject).onClick = basefunc.handler(self, self.OnBackClick)
    EventTriggerListener.Get(self.title_btn.gameObject).onClick = basefunc.handler(self, self.OnTitleClick)
    EventTriggerListener.Get(self.cur_bonus_btn.gameObject).onClick = basefunc.handler(self, self.OnCurBonusClick)
    EventTriggerListener.Get(self.cur_get_bonus_btn.gameObject).onClick =
        basefunc.handler(self, self.OnCurGetBonusClick)
    EventTriggerListener.Get(self.cur_get_score_btn.gameObject).onClick =
        basefunc.handler(self, self.OnCurGetScoreClick)
    EventTriggerListener.Get(self.rule_btn.gameObject).onClick = basefunc.handler(self, self.OnRuleClick)

    self:InitUI()

    self.update_timer =
        Timer.New(
        function()
            self:UpdateCountdown()
        end,
        8,
        self.change_money,
        nil,
        true
    )
    self.update_timer:Start()

    DOTweenManager.OpenPopupUIAnim(self.transform)
end

function FreeJackpotPanel:UpdateCountdown()
    self.change_money = self.change_money - 1
    local all_info = self.data
    if all_info.last_week_my_award and all_info.last_week_my_award > 0 then
        self.cur_bonus_txt.text = "奖池" .. StringHelper.ToRedNum((all_info.last_week_award - self.change_money) / 100) .. "元"
    else
        self.cur_bonus_txt.text = "奖池" .. StringHelper.ToRedNum((all_info.cur_week_award - self.change_money) / 100) .. "元"
    end
end

function FreeJackpotPanel:InitUI()
    local data = self.data
    -- dump(self.data, "<color=yellow>>>>>>>>>>>>>>>>>>>>>></color>")
    if data.last_week_my_award and data.last_week_my_award > 0 then
        self.cur_bonus_txt.text = "奖池" .. StringHelper.ToRedNum((data.last_week_award - self.change_money) / 100) .. "元"
    else
        self.cur_bonus_txt.text = "奖池" .. StringHelper.ToRedNum((data.cur_week_award - self.change_money) / 100) .. "元"
    end

    local get_note = data.get_note and data.get_note or 0
    self.cur_get_bonus_txt.text =
        "<color=#3a2721FF><size=37>当前瓜分 </size></color><color=#820f0cFF><size=57>" ..
        get_note .. "</size></color><color=#3a2721FF><size=37> 注奖金</size></color>"

    local week_race = data.week_race and data.week_race or 0
    local week_next_target = data.week_next_target and data.week_next_target or 0
    self.slider_txt.text = week_race .. "/" .. week_next_target .. "分"
    self.Slider = self.transform:Find("@cur_get_score_btn/Slider"):GetComponent("Slider")
    local silder_vale = week_race / week_next_target
    if silder_vale > 1 then
        silder_vale = 1
    end
    self.Slider.value = silder_vale == 0 and 0 or 0.95 * silder_vale + 0.1
    week_race = nil
    week_next_target = nil
end

function FreeJackpotPanel:MyExit()
    destroy(self.gameObject)
    if self.update_timer then
        self.update_timer:Stop()
        self.update_timer = nil
    end
end
function FreeJackpotPanel:Close()
    self:MyExit()
    instance = nil
end

function FreeJackpotPanel:OnBackClick()
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    self:Close()
end

function FreeJackpotPanel:OnTitleClick()
    ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
    LittleTips.Create("打匹配场拿现金，来玩就送，每周最高提现5000元！")
end

function FreeJackpotPanel:OnCurBonusClick()
    ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
    LittleTips.Create("本周奖金数额，下周1可提现")
end

function FreeJackpotPanel:OnCurGetBonusClick()
    ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
    LittleTips.Create("本周可瓜分的注数，注数越高提现金额越多")
end

function FreeJackpotPanel:OnCurGetScoreClick()
    ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
    LittleTips.Create("打匹配场任意游戏获得积分，越高级的场获得更多积分，积分满后增加注数")
end

function FreeJackpotPanel:OnRuleClick()
    ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
    FreeJackpotHelpPanel.Create()
end
