-- 创建时间:2019-03-26
-- 常规技能

local basefunc = require "Game.Common.basefunc"

FishingNorSKillPrefab = basefunc.class()

local C = FishingNorSKillPrefab

C.name = "FishingNorSKillPrefab"

function C.Create(tran, panelSelf)
	return C.New(tran, panelSelf)
end
function C:FrameUpdate(time_elapsed)
    local userdata = FishingMatchModel.GetPlayerData()
    if userdata and userdata.base then
        if self.boom_state ~= "nor" then
            self.boom_cd_img.fillAmount = self.boom_cd / self.max_boom_cd
            self.boom_cd = self.boom_cd - time_elapsed
            if self.boom_cd <= 0 then
                self.boom_state = "nor"
                self.boom_cd_img.gameObject:SetActive(false)
            end
        end
    end
end
function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["model_barbette_info_change_msg"] = basefunc.handler(self, self.on_barbette_info_change_msg)
    self.lister["model_buy_activity_msg"] = basefunc.handler(self, self.on_buy_activity_msg)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:ctor(tran, panelSelf)
	self.panelSelf = panelSelf
	self.gameObject = tran.gameObject
	self.transform = tran

	self:MakeLister()
    self:AddMsgListener()

    LuaHelper.GeneratingVar(self.transform, self)

    self.boom_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        self:OnBoomClick()
    end)
    self.skill_icon = self.boom_btn.transform:GetComponent("Image")
    self.boom_cd_img = self.CDImage.transform:GetComponent("Image")
    self.boom_cd_img.gameObject:SetActive(false)
    self.boom_state = "nor"
    self.kjbag_pre = FishingMatchKJBagPanel.Create(self.transform, panelSelf)

    self:MyRefresh()
end
function C:MyRefresh()
    self.skill_list = FishingMatchModel.GetBuySkillToList()
    local userdata = FishingMatchModel.GetPlayerData()
    if userdata and userdata.base then
        self:RefreshBoom()
    end
    if self.kjbag_pre then
        self.kjbag_pre:MyRefresh()
    end
    if self.skill_list and #self.skill_list > 0 then
        self.boom_btn.gameObject:SetActive(true)
        local cfg = FishingMatchModel.Config.fishmatch_buy_activity_map[self.skill_list[1]]
        local sc = FishingSkillManager.FishDeadAppendMap[cfg.skill_id]
        self.skill_icon.sprite = GetTexture(sc.icon)
    else
        self.boom_btn.gameObject:SetActive(false)
    end
end

function C:RefreshBoom()
    local mm = FishingMatchModel.GetBuySkillToMoney(self.skill_list[1])
    self.boom_txt.text = mm
end

function C:MyExit()
    if self.kjbag_pre then
        self.kjbag_pre:MyExit()
        self.kjbag_pre = nil
    end
    if self.buy_hint_pre then
        self.buy_hint_pre:Close()
        self.buy_hint_pre = nil
    end
    self:RemoveListener()
end

function C:on_barbette_info_change_msg()
    self:RefreshBoom()
end

-- ********************************
--    Button
-- ********************************
function C:OnBoomClick()
    -- 使用炸弹加2秒延迟
    if self.last_use_boom_time and os.time() <= (self.last_use_boom_time + 2) then
        return
    end
    self.last_use_boom_time = os.time()
    local cfg = FishingMatchModel.Config.fishmatch_buy_activity_map[self.skill_list[1]]
    local sc = FishingSkillManager.FishDeadAppendMap[cfg.skill_id]
    local mm = FishingMatchModel.GetBuySkillToMoney(self.skill_list[1])
    local id = cfg.activity_id
    local call = function ()
        local data = {}
        data.msg_type = "buy_activity"
        data.item_key = "obj_fish_super_bomb"
        data.id = id
        Event.Brocast("model_use_skill_msg", data)
    end
    if FishingMatchModel.data.score >= mm then
        call()
    else
        HintPanel.Create(1, "积分不足")
    end
end
function C:on_buy_activity_msg(data)
    local cfg = FishingMatchModel.Config.fishmatch_buy_activity_map[self.skill_list[1]]
    local id = cfg.activity_id
    if data.id == id and data.score then
        FishingMatchModel.data.score = FishingMatchModel.data.score - data.score
        Event.Brocast("model_player_money_msg",{change_type = "buy_activity", seat_num = 1})
        self.boom_cd_img.gameObject:SetActive(true)
        self.boom_state = "cd"
        self.boom_cd = cfg.cd
        self.max_boom_cd = cfg.cd
    end    
end