-- 创建时间:2018-09-04
local basefunc = require "Game.Common.basefunc"

local instance
local RankType = {
    sea = "sea",
    rematch = "rematch",
    finals = "finals"
}
local data_sea_rank = {}
local data_rematch_rank = {}
local data_finals_rank = {}
local request_count = 10

CityRankPanel = basefunc.class()
CityRankPanel.name = "CityRankPanel"

function CityRankPanel.Create(parm, closeCall)
    --显示当前阶段的排名
    -- parm = CityRankPanel.GetTestData()
    parm = {sea = {}, rematch = {}, finals = {}}
    if not instance then
        instance = CityRankPanel.New(parm, closeCall)
    end
    return instance
end

function CityRankPanel:MyExit()
    self.closeCall = nil
    self.parm = nil
    self.updataRankItems = false
    self.sea_point = nil
    self.rematch_point = nil
    self.finals_point = nil
    self.cur_state = nil
    destroy(self.gameObject)
end

function CityRankPanel.Close()
    if instance then
        instance:MyExit()
        instance = nil
    end
end

function CityRankPanel:ctor(parm, closeCall)

	ExtPanel.ExtMsg(self)

    self.closeCall = closeCall
    self.parm = parm
    self.updataRankItems = false
    self.sea_point = 1
    self.rematch_point = 1
    self.finals_point = 1
    local func = function(state)
        self.cur_state = state
        self:InitUI()
    end
    self:GetCurState(func)
    -- EventTriggerListener.Get(self.finals_sr.gameObject).onEndDrag = basefunc.handler(self, self.FinalsOnEndDrag)
    -- EventTriggerListener.Get(self.finals_sr.gameObject).onDrag = basefunc.handler(self, self.FinalsOnDrag)
    -- EventTriggerListener.Get(self.finals_sr.gameObject).onBeginDrag = basefunc.handler(self, self.FinalsOnBeginDrag)
end

function CityRankPanel:GetCurState(call)
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

function CityRankPanel:RequestSeaRankData(callback)
    Network.SendRequest(
        "citymg_get_rank_hx_list",
        {rank_point = self.sea_point},
        "正在请求城市杯排行榜",
        function(data)
            if data.result == 0 then
                dump(data, "<color=yellow>城市杯海选赛排行榜数据</color>")
                if data.rank_list then
                    self.parm.sea.rank = data.rank_list
                    for i, v in ipairs(data.rank_list) do
                        data_sea_rank[#data_sea_rank + 1] = v
                    end
                    self:UpdateAllRank(RankType.sea, self.parm.sea.rank)
                else
                    self.sea_point = self.sea_point - request_count
                    if self.sea_point < 1 then
                        self.sea_point = 1
                    end
                end
            else
                HintPanel.ErrorMsg(data.result)
            end
            if callback then
                callback()
            end
        end
    )
end

function CityRankPanel:RequestRematchRankData(callback)
    Network.SendRequest(
        "citymg_get_rank_fs_list",
        {rank_point = self.rematch_point},
        "正在请求城市杯排行榜",
        function(data)
            if data.result == 0 then
                dump(data, "<color=yellow>城市杯复赛排行榜数据</color>")
                if data.rank_list then
                    self.parm.rematch.rank = data.rank_list
                    for i, v in ipairs(data.rank_list) do
                        data_rematch_rank[#data_rematch_rank + 1] = v
                    end
                    self:UpdateAllRank(RankType.rematch, self.parm.rematch.rank)
                else
                    self.rematch_point = self.rematch_point - request_count
                    if self.rematch_point < 1 then
                        self.rematch_point = 1
                    end
                end
            else
                HintPanel.ErrorMsg(data.result)
            end
            if callback then
                callback()
            end
        end
    )
end

function CityRankPanel:RequestFinalsRankData()
    local data = CityMatchModel.GetDdzMacthUIConfigFinalsRank()
    if data.rank_list then
        self.parm.finals.rank = data.rank_list
        for i, v in ipairs(data.rank_list) do
            data_finals_rank[#data_finals_rank + 1] = v
        end
        self:UpdateAllRank(RankType.finals, self.parm.finals.rank)
    end
end

function CityRankPanel:SeaOnEndDrag()
    if self.updataRankItems then
        local VNP = self.sea_sr.verticalNormalizedPosition
        if VNP <= 0 then
            --向下刷新排行榜
            self.sea_point = self.sea_point + request_count
            self:RequestSeaRankData()
        end
    end
end

function CityRankPanel:SeaOnDrag()
    if self.sea_sr.verticalNormalizedPosition <= 0 then
        self.updataRankItems = true
    end
end

function CityRankPanel:SeaOnBeginDrag()
    -- print("<color=yellow>OnBeginDrag</color>")
end

function CityRankPanel:RematchOnEndDrag()
    if self.updataRankItems then
        local VNP = self.rematch_sr.verticalNormalizedPosition
        if VNP <= 0 then
            --向下刷新排行榜
            self.rematch_point = self.rematch_point + request_count
            self:RequestRematchRankData()
        end
    end
end

function CityRankPanel:RematchOnDrag()
    if self.rematch_sr.verticalNormalizedPosition <= 0 then
        self.updataRankItems = true
    end
end

function CityRankPanel:RematchOnBeginDrag()
    -- print("<color=yellow>OnBeginDrag</color>")
end

function CityRankPanel:FinalsOnEndDrag()
    if self.updataRankItems then
        local VNP = self.finals_sr.verticalNormalizedPosition
        if VNP <= 0 then
            --向下刷新排行榜
            self.finals_point = self.finals_point + request_count
            self:RequestFinalsRankData()
        end
    end
end

function CityRankPanel:FinalsOnDrag()
    if self.finals_sr.verticalNormalizedPosition <= 0 then
        self.updataRankItems = true
    end
end

function CityRankPanel:FinalsOnBeginDrag()
    -- print("<color=yellow>OnBeginDrag</color>")
end

function CityRankPanel:InitUI()
    self.gameObject = newObject(CityRankPanel.name, GameObject.Find("Canvas/LayerLv3").transform)
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
                print("<color=yellow>self.cur_state</color>",self.cur_state)
                if self.cur_state == nil then
                    self.sea_not_rank.gameObject:SetActive(true)
                    self:UpdateMeRank(RankType.sea)
                else
                    self.sea_not_rank.gameObject:SetActive(false)
                    self:UpdateSea()
                end
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
                print("<color=yellow>self.cur_state</color>",self.cur_state)

                if self.cur_state == nil or self.cur_state == RankType.sea then
                    self.rematch_not_rank.gameObject:SetActive(true)
                    self:UpdateMeRank(RankType.rematch)
                else
                    self.rematch_not_rank.gameObject:SetActive(false)
                    self:UpdateRematch()
                end
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
                if self.cur_state == nil or self.cur_state == RankType.sea or self.cur_state == RankType.rematch then
                    self.finals_not_rank.gameObject:SetActive(true)
                    self:UpdateMeRank(RankType.finals)
                elseif self.cur_state == RankType.finals then
                    if GameGlobalOnOff.CityFinalRank then
                        self.finals_not_rank.gameObject:SetActive(false)
                        self:UpdateFinals()
                    else
                        self.finals_not_rank.gameObject:SetActive(true)
                        self:UpdateMeRank(RankType.finals)
                    end
                end
            end
        end
    )

    --滑动
    EventTriggerListener.Get(self.sea_sr.gameObject).onEndDrag = basefunc.handler(self, self.SeaOnEndDrag)
    EventTriggerListener.Get(self.sea_sr.gameObject).onDrag = basefunc.handler(self, self.SeaOnDrag)
    EventTriggerListener.Get(self.sea_sr.gameObject).onBeginDrag = basefunc.handler(self, self.SeaOnBeginDrag)

    EventTriggerListener.Get(self.rematch_sr.gameObject).onEndDrag = basefunc.handler(self, self.RematchOnEndDrag)
    EventTriggerListener.Get(self.rematch_sr.gameObject).onDrag = basefunc.handler(self, self.RematchOnDrag)
    EventTriggerListener.Get(self.rematch_sr.gameObject).onBeginDrag = basefunc.handler(self, self.RematchOnBeginDrag)

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

function CityRankPanel:OnCloseClick()
    CityRankPanel.Close()
end

function CityRankPanel:UpdateSea()
    self.rank_txt.gameObject:SetActive(false)
    self.advance_txt.gameObject:SetActive(true)

    if self.sea_content.childCount == 0 then
        self:RequestSeaRankData(
            function()
                Network.SendRequest(
                    "citymg_get_my_rank_hx",
                    {},
                    "正在请求城市杯排行榜",
                    function(data)
                        if data.result == 0 then
                            dump(data, "<color=yellow>城市杯海选赛自己的排行榜数据</color>")
                            if data.rank then
                                self.parm.sea.my_rank = data.rank
                            end
                            self:UpdateMeRank(RankType.sea, self.parm.sea.my_rank)
                        else
                            HintPanel.ErrorMsg(data.result)
                        end
                    end
                )
            end
        )
    else
        self:UpdateMeRank(RankType.sea, self.parm.sea.my_rank)
    end
    self.sea_content.transform.localPosition = Vector3.New(0, 0, 0)
end

function CityRankPanel:UpdateRematch()
    self.rank_txt.gameObject:SetActive(true)
    self.advance_txt.gameObject:SetActive(false)

    if self.rematch_content.childCount == 0 then
        self:RequestRematchRankData(
            function()
                Network.SendRequest(
                    "citymg_get_my_rank_fs",
                    {},
                    "正在请求城市杯排行榜",
                    function(data)
                        if data.result == 0 then
                            dump(data, "<color=yellow>城市杯复赛自己的排行榜数据</color>")
                            if data.rank then
                                self.parm.rematch.my_rank = data.rank
                            end
                            self:UpdateMeRank(RankType.rematch, self.parm.rematch.my_rank)
                        else
                            HintPanel.ErrorMsg(data.result)
                        end
                    end
                )
            end
        )
    else
        self:UpdateMeRank(RankType.rematch, self.parm.rematch.my_rank)
    end
    self.rematch_content.transform.localPosition = Vector3.New(0, 0, 0)
end

function CityRankPanel:UpdateFinals()
    self.rank_txt.gameObject:SetActive(true)
    self.advance_txt.gameObject:SetActive(false)
    local data = CityMatchModel.GetDdzMacthUIConfigFinalsRank()
    if data.my_rank then
        self.parm.finals.my_rank = data.my_rank
    end
    self:UpdateMeRank(RankType.finals, self.parm.finals.my_rank)
    if self.finals_content.childCount == 0 then
        self:RequestFinalsRankData()
    end

    self.finals_content.transform.localPosition = Vector3.New(0, 0, 0)
end

function CityRankPanel:UpdateMeRank(rank_type, my_rank)
    dump(my_rank, "<color=yellow>my_rank:</color>")
    print("<color=yellow>rank_type</color>",rank_type)
    self.ImgMe.gameObject:SetActive(rank_type ~= RankType.finals)
    if my_rank then
        local name = my_rank.name or ""
        local rank = my_rank.rank
        local award = my_rank.award or ""
        if rank then
            if rank_type == RankType.sea then
                self.name_me_txt.text = name
                self.award_me_txt.text = award
                self.ranking_me_txt.text = ""
                self.sea_election_me_txt.text = "晋级"
                self.sea_election_me_txt.gameObject:SetActive(true)
                self.ranking_me_img.gameObject:SetActive(false)
            elseif rank_type == RankType.rematch then
                self.name_me_txt.text = name
                self.award_me_txt.text = award
                self.sea_election_me_txt.gameObject:SetActive(false)
                self:SetOneRank(
                    rank,
                    self.ranking_me_img,
                    self.ranking_me_txt
                )
            elseif rank_type == RankType.finals then
                self.name_me_txt.text = ""
                self.award_me_txt.text = ""
                self.ranking_me_txt.text = ""
                self.sea_election_me_txt.gameObject:SetActive(false)
                self.ranking_me_img.gameObject:SetActive(false)
            end
        else
            if rank_type == RankType.sea or rank_type == RankType.rematch then
                self.sea_election_me_txt.text = "未上榜"
                self.sea_election_me_txt.gameObject:SetActive(true)
                self.ranking_me_txt.text = ""
                self.award_me_txt.text = ""
                self.ranking_me_img.gameObject:SetActive(false)
            elseif rank_type == RankType.finals then
                self.name_me_txt.text = ""
                self.award_me_txt.text = ""
                self.ranking_me_txt.text = ""
                self.sea_election_me_txt.gameObject:SetActive(false)
                self.ranking_me_img.gameObject:SetActive(false)
            end
        end
    else
        self.name_me_txt.text = (rank_type == RankType.sea or rank_type == RankType.rematch) and MainModel.UserInfo.name or ""
        self.sea_election_me_txt.text = (rank_type == RankType.sea or rank_type == RankType.rematch) and "未上榜" or ""
        self.sea_election_me_txt.gameObject:SetActive(true)
        self.award_me_txt.text = ""
        self.ranking_me_txt.text = ""
        self.ranking_me_img.gameObject:SetActive(false)
    end
end

--[[
    --@rank_type:排行榜类型 sea：海选， rematch：复赛， finals：决赛
	--@rank:排名数据
]]
function CityRankPanel:UpdateAllRank(rank_type, rank)
    local parent = self.sea_content
    if rank_type == RankType.sea then
        parent = self.sea_content
    elseif rank_type == RankType.rematch then
        parent = self.rematch_content
    elseif rank_type == RankType.finals then
        parent = self.finals_content
    end
    for i, v in ipairs(rank) do
        local r_obj = newObject("CityRankItem", parent)
        r_obj.transform:SetAsLastSibling()
        local r_table = {}
        LuaHelper.GeneratingVar(r_obj.transform, r_table)
        if rank_type == RankType.sea then
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
        r_table.name_txt.text = v.name
        r_table.award_txt.text = v.award
        r_obj = nil
        r_table = nil
    end
end

function CityRankPanel:SetOneRank(rank, ranking_img, ranking_txt)
    if rank <= 3 and rank >= 1 then
        ranking_img.sprite = GetTexture("localpop_icon_" .. rank)
        ranking_img.gameObject:SetActive(true)
    elseif rank >= 4 then
        ranking_txt.text = rank
        ranking_txt.gameObject:SetActive(true)
    else
        print("<color=red>排名数据错误</color>")
    end
end

function CityRankPanel.GetTestData()
    return {
        cur_state = "sea",
        sea = {
            icon = "localpop_icon_jp123",
            title_icon = "localpop_icon_juesai",
            my_rank = {
                rank = "晋级",
                name = "我自己"
            },
            rank = {
                [1] = {rank = "晋级", name = "张三", award = "一亿"},
                [2] = {rank = "晋级", name = "李四", award = "五千万"},
                [3] = {rank = "晋级", name = "王二狗", award = "一千万"},
                [4] = {rank = "晋级", name = "王三狗", award = "一白万"},
                [5] = {rank = "晋级", name = "王四狗", award = "四十万"},
                [6] = {rank = "晋级", name = "王五狗", award = "十万"},
                [7] = {rank = "晋级", name = "王二狗", award = "一千万"},
                [8] = {rank = "晋级", name = "王三狗", award = "一白万"},
                [9] = {rank = "晋级", name = "王四狗", award = "四十万"},
                [10] = {rank = "晋级", name = "王五狗", award = "十万"}
            }
        },
        rematch = {
            icon = "localpop_icon_jp123",
            title_icon = "localpop_icon_juesai",
            my_rank = {
                rank = 2,
                name = "我自己"
            },
            rank = {
                [1] = {rank = 1, name = "张三晋级赛", award = "一亿"},
                [2] = {rank = 2, name = "李四晋级赛", award = "五千万"},
                [3] = {rank = 3, name = "王二狗晋级赛", award = "一千万"},
                [4] = {rank = 4, name = "王三狗晋级赛", award = "一白万"},
                [5] = {rank = 5, name = "王四狗晋级赛", award = "四十万"},
                [6] = {rank = 6, name = "王五狗晋级赛", award = "十万"},
                [7] = {rank = "晋级", name = "王二狗", award = "一千万"},
                [8] = {rank = "晋级", name = "王三狗", award = "一白万"},
                [9] = {rank = "晋级", name = "王四狗", award = "四十万"},
                [10] = {rank = "晋级", name = "王五狗", award = "十万"}
            }
        },
        finals = {
            icon = "localpop_icon_jp123",
            title_icon = "localpop_icon_juesai",
            my_rank = {
                rank = nil,
                name = "我自己"
            },
            rank = {
                [1] = {rank = 1, name = "张三决赛", award = "一亿"},
                [2] = {rank = 2, name = "李四决赛", award = "五千万"},
                [3] = {rank = 3, name = "王二狗决赛", award = "一千万"},
                [4] = {rank = 4, name = "王三狗决赛", award = "一白万"},
                [5] = {rank = 5, name = "王四狗决赛", award = "四十万"},
                [6] = {rank = 6, name = "王五狗决赛", award = "十万"},
                [7] = {rank = "晋级", name = "王二狗", award = "一千万"},
                [8] = {rank = "晋级", name = "王三狗", award = "一白万"},
                [9] = {rank = "晋级", name = "王四狗", award = "四十万"},
                [10] = {rank = "晋级", name = "王五狗", award = "十万"}
            }
        }
    }
end
