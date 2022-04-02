-- 创建时间:2018-09-04
local basefunc = require "Game.Common.basefunc"
--奖励配置表
local award_config = require "Game.game_CityMatch.lua.city_match_award_ui"
local my_award_config = {}

local instance
local RankType = {
    sea = "sea",
    rematch = "rematch",
    finals = "finals"
}

CityAwardPanel = basefunc.class()
CityAwardPanel.name = "CityAwardPanel"

function CityAwardPanel.Create( )
    --显示当前阶段的排名
    -- parm = CityAwardPanel.GetTestData()
    if not instance then
        instance = CityAwardPanel.New()
    end
    return instance
end

function CityAwardPanel:MyExit()
    destroy(self.gameObject)
end

function CityAwardPanel.Close()
    if instance then
        instance:MyExit()
        instance = nil
    end
end

function CityAwardPanel:ctor()

	ExtPanel.ExtMsg(self)

    local func = function(state)
        self.cur_state = state
        self:InitData()
        self:InitUI()
    end
    self:GetCurState(func)
end

function CityAwardPanel:GetCurState(call)
    local func_get_state_data =
        function(state_data)
        local city_state = state_data.state
        if
            city_state == MainModel.CityMatchState.CMS_MatchStage_One or
                city_state == MainModel.CityMatchState.CMS_MatchStage_Wait1
         then
            call(RankType.sea)
            return
        elseif
            city_state == MainModel.CityMatchState.CMS_MatchStage_Two_Singup or
            city_state == MainModel.CityMatchState.CMS_MatchStage_Two or
            city_state == MainModel.CityMatchState.CMS_MatchStage_Wait2
         then
            call(RankType.rematch)
            return
        elseif 
            city_state == MainModel.CityMatchState.CMS_MatchStage_Three or
            city_state == MainModel.CityMatchState.CMS_MatchStage_End then
            call(RankType.finals)
            return
        else
            call(nil)
            return
        end
    end
    CityMatchModel.GetGameStateData(func_get_state_data)
end

function CityAwardPanel:InitData()
    local c_data = award_config.match_award_config
    local sea_confg = {}
    local rematch_confg ={}
    local finals_confg = {}
    for i,v in ipairs(c_data) do
        local v_rank = v.rank
        if string.find(v.rank,"~") then
            local arr = split(v.rank,"~")
            v_rank = tonumber(arr[1])
            if arr[1] == arr[2] then
                v.rank = tonumber(arr[1])
            end
        end
        if v.award_config_id == 1 then
            if not sea_confg[v_rank] then
                v_rank = #sea_confg + 1
            end
            sea_confg[v_rank] = sea_confg[v_rank] or {}
            sea_confg[v_rank]["award"] = sea_confg[v_rank]["award"] or {}
            sea_confg[v_rank]["award"][#sea_confg[v_rank]["award"] + 1] = {a_t = v.asset_type,a_c = v.asset_count}
            if v_rank == 1 then
                sea_confg[v_rank]["rank"] = v.rank
            else
                sea_confg[v_rank]["rank"] = "参与"
            end
        elseif v.award_config_id == 2 then
            self:InitRankData(rematch_confg,v)
        elseif v.award_config_id == 3 then
            self:InitRankData(finals_confg,v)
        end
    end
    my_award_config = {sea = sea_confg,rematch = rematch_confg,finals = finals_confg}
end

function CityAwardPanel:InitRankData(config,v)
    local index =  #config
    config[index] = config[index] or {}
    if config[index].rank and config[index].rank ~= v.rank then
        index =  #config + 1
    end

    config[index] = config[index] or {}
    config[index]["rank"] = v.rank
    config[index]["award"] = config[index]["award"] or {}
    config[index]["award"][#config[index]["award"] + 1] = {a_t = v.asset_type,a_c = v.asset_count}
    return config
end

function CityAwardPanel:InitUI()
    self.gameObject = newObject(CityAwardPanel.name, GameObject.Find("Canvas/LayerLv3").transform)
    LuaHelper.GeneratingVar(self.gameObject.transform, self)
    self.sea_sr = self.sea_sv:GetComponent("ScrollRect")
    self.rematch_sr = self.rematch_sv:GetComponent("ScrollRect")
    self.finals_sr = self.finals_sv:GetComponent("ScrollRect")

    self.rank_bg_btn.onClick:AddListener(
        function()
            ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
            if self.closeCall then
                self.closeCall()
            end
            self:OnCloseClick()
        end
    )
    self.rank_back_btn.onClick:AddListener(
        function()
            ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
            if self.closeCall then
                self.closeCall()
            end
            self:OnCloseClick()
        end
    )

    self.sea_election_tge.onValueChanged:AddListener(
        function(val)
            ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
            if val then
                self.rank_txt.gameObject:SetActive(false)
                self.advance_txt.gameObject:SetActive(true)
                self.sea_sv.gameObject:SetActive(true)
                self.rematch_sv.gameObject:SetActive(false)
                self.finals_sv.gameObject:SetActive(false)
                self:UpdateSea()
            end
        end
    )
    self.rematch_tge.onValueChanged:AddListener(
        function(val)
            ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
            if val then
                self.rank_txt.gameObject:SetActive(true)
                self.advance_txt.gameObject:SetActive(false)
                self.sea_sv.gameObject:SetActive(false)
                self.rematch_sv.gameObject:SetActive(true)
                self.finals_sv.gameObject:SetActive(false)
                self:UpdateRematch()
            end
        end
    )
    self.finals_tge.onValueChanged:AddListener(
        function(val)
            ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
            if val then
                self.rank_txt.gameObject:SetActive(true)
                self.advance_txt.gameObject:SetActive(false)
                self.sea_sv.gameObject:SetActive(false)
                self.rematch_sv.gameObject:SetActive(false)
                self.finals_sv.gameObject:SetActive(true)
                self:UpdateFinals()
            end
        end
    )

    if self.cur_state == RankType.sea then
        self.sea_election_tge.isOn = true
    elseif self.cur_state == RankType.rematch then
        self.rematch_tge.isOn = true
    elseif self.cur_state == RankType.finals then
        self.finals_tge.isOn = true
    else
        self.sea_election_tge.isOn = true
    end
end

function CityAwardPanel:OnCloseClick()
    CityAwardPanel.Close()
end

function CityAwardPanel:UpdateSea()
    self.rank_txt.gameObject:SetActive(false)
    self.advance_txt.gameObject:SetActive(true)

    local data = my_award_config.sea
    if self.sea_content.childCount == 0 then
        self:UpdateAllRank(RankType.sea, data)
    end
    self.sea_content.transform.localPosition = Vector3.New(0, 0, 0)
end

function CityAwardPanel:UpdateRematch()
    self.rank_txt.gameObject:SetActive(true)
    self.advance_txt.gameObject:SetActive(false)
    local data = my_award_config.rematch

    if self.rematch_content.childCount == 0 then
        self:UpdateAllRank(RankType.rematch, data)
    end
    self.rematch_content.transform.localPosition = Vector3.New(0, 0, 0)
end

function CityAwardPanel:UpdateFinals()
    self.rank_txt.gameObject:SetActive(true)
    self.advance_txt.gameObject:SetActive(false)
    local data = my_award_config.finals

    if self.finals_content.childCount == 0 then
        self:UpdateAllRank(RankType.finals, data)
    end

    self.finals_content.transform.localPosition = Vector3.New(0, 0, 0)
end


--[[
    --@rank_type:排行榜类型 sea：海选， rematch：复赛， finals：决赛
	--@rank:排名数据
]]
function CityAwardPanel:UpdateAllRank(rank_type, rank)
    local parent = self.sea_content
    if rank_type == RankType.sea then
        parent = self.sea_content
    elseif rank_type == RankType.rematch then
        parent = self.rematch_content
    elseif rank_type == RankType.finals then
        parent = self.finals_content
    end

    dump(rank, "<color=green>排名奖励</color>")
    for k=0,#rank do
        local v = rank[k]
        if v then 
            -- print("<color=green>k</color>",k)
            local r_obj = newObject("CityAwardItem", parent)
            r_obj.transform:SetAsLastSibling()
            local r_table = {}
            LuaHelper.GeneratingVar(r_obj.transform, r_table)
            if rank_type == RankType.sea and v.rank == 1 then
                r_table.sea_election_txt.text = "晋级"
                --v.rank
                r_table.sea_election_txt.gameObject:SetActive(true)
            else
                self:SetOneRank(
                    v.rank,
                    r_table.ranking_img,
                    r_table.ranking_txt
                )
            end
            local award = ""
            for i=1,#v.award do
                local a_t = v.award[i].a_t
                local a_c = v.award[i].a_c
                if a_t == "shop_gold_sum" then
                    a_c =StringHelper.ToRedNum(a_c / 100)
                elseif a_t == "jing_bi" then
                    a_c = StringHelper.ToCash(a_c)
                end
                if rank_type == RankType.sea or rank_type == RankType.rematch then
                    local cfg = GameItemModel.GetItemToKey(a_t)
                    if i ~= #v.award then
                        award = award .. cfg.name .."x".. a_c .. "、"
                    else
                        award = award .. cfg.name .."x".. a_c
                    end
                else
                    award = award .. a_t
                end
            end
            -- award.substring("、", award.length() -1 )
            r_table.name_txt.text = award
        end
    end
end

function CityAwardPanel:SetOneRank(rank, ranking_img, ranking_txt)
    if rank <= 3 then
        ranking_img.sprite = GetTexture("localpop_icon_" .. rank)
        ranking_img.gameObject:SetActive(true)
    else
        ranking_txt.text = rank
        ranking_txt.gameObject:SetActive(true)
    end
end