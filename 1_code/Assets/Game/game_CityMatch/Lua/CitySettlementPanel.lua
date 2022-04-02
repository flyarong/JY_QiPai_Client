-- 创建时间:2018-09-04
local basefunc = require "Game.Common.basefunc"

local instance
CitySettlementPanel = basefunc.class()
CitySettlementPanel.name = "CitySettlementPanel"

--matchType:1，海选赛 2，复赛 3，决赛
function CitySettlementPanel.Create(data, OKCall)
    SysInteractivePlayerManager.Close()
    SysInteractiveChatManager.Hide()

    local parm = {}
    if data then
        parm = CitySettlementPanel.InitData(data.rank,data.match_type,data.reward)
    else
        HintPanel.Create(1,"城市杯结算数据异常")
    end
    if not instance then
        instance = CitySettlementPanel.New(parm, OKCall)
    end
    return instance
end

function CitySettlementPanel:MyExit()
    self.OKCall = nil
    self.parm = nil
    destroy(self.gameObject)
end

function CitySettlementPanel.Close()
    if instance then
        instance:MyExit()
        instance = nil
    end
end

function CitySettlementPanel:ctor(parm, OKCall)

	ExtPanel.ExtMsg(self)

    self.OKCall = OKCall
    self.parm = parm
    self.gameObject = newObject(CitySettlementPanel.name, GameObject.Find("Canvas/LayerLv3").transform)
    LuaHelper.GeneratingVar(self.gameObject.transform, self)
    self.OK_btn.onClick:AddListener(
        function()
            ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
            if self.OKCall then
                self.OKCall()
            end
            self:OnOKClick()
        end
    )
    self:InitUI()
end

function CitySettlementPanel.InitData(rank,matchType,awards)
    local config_txt = CityMatchModel.GetDdzMacthUIConfigTxt()
    local hint_txt = matchType == 1 and config_txt.rematch_hint or config_txt.finals_hint

    local isWing = true
    local config = CityMatchModel.GetDdzMacthUIConfigNum()
    if matchType == 1 then
        isWing = rank <= config.sea_advance_num
    elseif matchType == 2 then
        isWing = rank <= config.rematch_advance_num
    end
    local myAwards = {}
    for i,v in ipairs(awards) do
        local cfg = GameItemModel.GetItemToKey(v.asset_type)
        myAwards[#myAwards+1] = {
            icon = cfg.image,
            name = cfg.name,
            num = v.value,
            type_name = v.asset_type
        }

    end
    local parm = {
        matchType = matchType,
        rank = rank,
        is_wing = isWing,
        hint = hint_txt,
        awards = myAwards
    }
    return parm
end

function CitySettlementPanel:GetCurState(call)
    local func_get_state_data = function ( state_data )
        local city_state = state_data
        if
            city_state == MainModel.CityMatchState.CMS_MatchStage_Wait1 or
            city_state == MainModel.CityMatchState.CMS_MatchStage_Two_Singup or
                city_state == MainModel.CityMatchState.CMS_MatchStage_Two
         then
            call(RankType.sea)
            return
        elseif
            city_state == MainModel.CityMatchState.CMS_MatchStage_Wait2 or
                city_state == MainModel.CityMatchState.CMS_MatchStage_Three
         then
            call(RankType.rematch)
            return
        elseif city_state == MainModel.CityMatchState.CMS_MatchStage_End then
            call(RankType.finals)
            return
        else
            call(nil)
            return
        end
    end
    CityMatchModel.GetGameStateData(func_get_state_data)
end

function CitySettlementPanel:InitUI()
    if self.parm.matchType == 1 then
        --海选
        self.sea_election.gameObject:SetActive(true)
    elseif self.parm.matchType == 2 then
        --复赛
        self.rematch_title_txt.text = self.parm.rank
        self.rematch_title_txt.gameObject:SetActive(true)
    elseif self.parm.matchType == 3 then
        --决赛
    end

    if self.parm.is_wing then
        self.win.gameObject:SetActive(true)
    else
        self.lose.gameObject:SetActive(true)
        self.OK_btn.transform.localPosition = Vector3.New(219, -330, 0)
    end

    self.hint_txt.text = self.parm.hint

    for k, v in pairs(self.parm.awards) do
        local award_item = newObject("CitySettlementItem", self.award_content.transform)
        local award_table = {}
        LuaHelper.GeneratingVar(award_item.transform, award_table)
        award_table.award_icon_img.sprite = GetTexture(v.icon)
        if v.type_name == "shop_gold_sum" then
            v.num =StringHelper.ToRedNum(v.num / 100)
        end
        award_table.award_name_txt.text = v.name .. " x" .. v.num
        award_table = nil
    end
end

function CitySettlementPanel:OnOKClick()
    if Network.SendRequest("citymg_quit_game") then
        CitySettlementPanel.Close()
        CityMatchModel.ClearMatchData()
    else
        DDZAnimation.Hint(2, Vector3.New(0, -350, 0), Vector3.New(0, 0, 0))
    end
end