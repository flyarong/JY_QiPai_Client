-- 创建时间:2020-09-28
-- Panel:JjcyXxlbdPanel
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
 -- 取消按钮音效
 -- ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
 -- 确认按钮音效
 -- ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
 --]]
local basefunc = require "Game/Common/basefunc"

Act_045_XXLBDPanel = basefunc.class()
local C = Act_045_XXLBDPanel
C.name = "Act_045_XXLBDPanel"

local M = Act_045_XXLBDManger

local type_color = {
    sgxxl = Color.New(228 / 255, 253 / 255, 255 / 255), --水果消消乐
    sgxxl_outline = Color.New(73 / 255, 91 / 255, 201 / 255),
    shxxl = Color.New(250 / 255, 237 / 255, 255 / 255), --水浒消消乐
    shxxl_outline = Color.New(201 / 255, 73 / 255, 199 / 255),
    csxxl = Color.New(255 / 255, 237 / 255, 237 / 255), --财神消消乐
    csxxl_outline = Color.New(201 / 255, 63 / 255, 15 / 255),
    xyxxl = Color.New(255 / 255, 255 / 255, 255 / 255), --西游消消乐
    xyxxl_outline = Color.New(73 / 255, 201 / 255, 94 / 255),
}

local DESCRIBE_TEXT = {
    [1] = "1.活动时间：1月5日7:30~1月11日23:59:59",
    [2] = "2.活动期间，分别统计所有消消乐游戏中3万及以上档次且倍数≥5的倍数，参与排行榜",
    [3] = "3.倍数总和越大排名越靠前，倍数相同时上榜时间越早排名越靠前",
    [4] = "4.活动结束后，排行榜奖励通过邮件发放，请注意查收",
}

function C.Create(parent)
    return C.New(parent)
end

function C:AddMsgListener()
    for proto_name, func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["act_045_xxlbd_base_info_get"] = basefunc.handler(self, self.on_act_045_xxlbd_base_info_get)
    self.lister["act_045_xxlbd_rank_info_get"] = basefunc.handler(self, self.on_act_045_xxlbd_rank_info_get)
    self.lister["ExitScene"] = basefunc.handler(self, self.MyExit)
end

function C:RemoveListener()
    for proto_name, func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
    self:RemoveListener()
    destroy(self.gameObject)
end

function C:ctor(parent)
    ExtPanel.ExtMsg(self)
    local parent = parent or GameObject.Find("Canvas/LayerLv4").transform
    local obj = newObject(C.name, parent)
    local tran = obj.transform
    self.transform = tran
    self.gameObject = obj
    LuaHelper.GeneratingVar(self.transform, self)
    dump(self)
    self:MakeLister()
    self:AddMsgListener()
    self:InitUI()
end

function C:InitUI()

    --self:InitRankUser()
    --self:InitRanklis()

    self.rule_btn.onClick:AddListener(function()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        self:OpenHelpPanel()
    end)

    M.GetBaseDataFromNet()
    M.GetRankDataFromNet()
    self:MyRefresh()

end

function C:MyRefresh()

end

function C:InitRanklis()
    local lis = M.GetRankData()
    self:AddToRankLis(lis)
end

function C:AddToRankLis(_add_rank_data)
    for i = 1, #_add_rank_data do
        local b = GameObject.Instantiate(self.rank_lis_item, self.Content)
        b.gameObject:SetActive(true)
        local temp_ui = {}
        LuaHelper.GeneratingVar(b.transform, temp_ui)
        if _add_rank_data[i].ranking_num <= 3 then
            temp_ui.ranking_img.gameObject:SetActive(true)
            temp_ui.ranking_txt.gameObject:SetActive(false)
            temp_ui.ranking_img.transform:GetComponent("Image").sprite = GetTexture(M.GetHGList(_add_rank_data[i].ranking_num))
            temp_ui.rank_gogame_btn.gameObject:SetActive(true)
        else
            temp_ui.ranking_img.gameObject:SetActive(false)
            temp_ui.ranking_txt.gameObject:SetActive(true)
            temp_ui.ranking_txt.text = _add_rank_data[i].ranking_num
            temp_ui.rank_gogame_btn.gameObject:SetActive(false)
        end
        temp_ui.rank_name_txt.text = _add_rank_data[i].name

        if _add_rank_data[i].rank_game == "xiaoxiaole_award_rate" then
            temp_ui.rank_game_txt.text = "水果消消乐"
            temp_ui.rank_game_txt.color = type_color["sgxxl"]
            temp_ui.rank_game_txt.transform:GetComponent("Outline").effectColor = type_color["sgxxl_outline"]
        elseif _add_rank_data[i].rank_game == "xiaoxiaole_shuihu_award_rate" then
            temp_ui.rank_game_txt.text = "水浒消消乐"
            temp_ui.rank_game_txt.color = type_color["shxxl"]
            temp_ui.rank_game_txt.transform:GetComponent("Outline").effectColor = type_color["shxxl_outline"]
        elseif _add_rank_data[i].rank_game == "xiaoxiaole_caishen_award_rate" then
            temp_ui.rank_game_txt.text = "财神消消乐"
            temp_ui.rank_game_txt.color = type_color["csxxl"]
            temp_ui.rank_game_txt.transform:GetComponent("Outline").effectColor = type_color["csxxl_outline"]
        elseif _add_rank_data[i].rank_game == "xiaoxiaole_xiyou_award_rate" then
            temp_ui.rank_game_txt.text = "西游消消乐"
            temp_ui.rank_game_txt.color = type_color["xyxxl"]
            temp_ui.rank_game_txt.transform:GetComponent("Outline").effectColor = type_color["xyxxl_outline"]
        end
		temp_ui.rank_lis_mybg.gameObject:SetActive(false)
		
		if _add_rank_data[i].player_id == MainModel.UserInfo.user_id then
			temp_ui.rank_lis_mybg.gameObject:SetActive(true)
        else
			if i % 2 == 0 then
                temp_ui.rank_lis_bg.gameObject:SetActive(false)
            else
                temp_ui.rank_lis_bg.gameObject:SetActive(true)
            end
        end

        temp_ui.rank_mult_txt.text = _add_rank_data[i].rank_mult .. "倍"

        if _add_rank_data[i].rank_award == nil then
            temp_ui.rank_award_txt.text = "- -"
        else
            temp_ui.rank_award_txt.text = _add_rank_data[i].rank_award
        end
        temp_ui.rank_gogame_btn.onClick:RemoveAllListeners()
        temp_ui.rank_gogame_btn.onClick:AddListener(
        function()
            self:GotoGameUI(_add_rank_data[i].rank_game)
        end)

    end
end



function C:GotoGameUI(_game_tpe)

    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    if _game_tpe == "xiaoxiaole_award_rate" then
        GameManager.CommonGotoScence({ gotoui = "game_Eliminate" })
    elseif _game_tpe == "xiaoxiaole_shuihu_award_rate" then
        GameManager.CommonGotoScence({ gotoui = "game_EliminateSH" })
    elseif _game_tpe == "xiaoxiaole_caishen_award_rate" then
        GameManager.CommonGotoScence({ gotoui = "game_EliminateCS" })
    elseif _game_tpe == "xiaoxiaole_xiyou_award_rate" then
        GameManager.CommonGotoScence({ gotoui = "game_EliminateXY" })
    end
end

function C:InitRankUser()
    -- body
    local user_dataUI = M.GetUserRankData()

    local user_rankNum_imgUI = self.user_ranking_img
    if user_dataUI.ranking_num <= 3 and user_dataUI.ranking_num ~= -1 then
        user_rankNum_imgUI.gameObject:SetActive(true)
        self.user_rank_num_txt.gameObject:SetActive(false)
        user_rankNum_imgUI.transform:GetComponent("Image").sprite = GetTexture(M.GetHGList(user_dataUI.ranking_num))
    else
        user_rankNum_imgUI.gameObject:SetActive(false)
        self.user_rank_num_txt.gameObject:SetActive(true)
        if user_dataUI.ranking_num == -1 then
            self.user_rank_num_txt.text = "未上榜"
        else
            self.user_rank_num_txt.text = user_dataUI.ranking_num
        end
    end
    self.user_name_txt.text = user_dataUI.name
    --self.user_rank_game_txt.text=user_dataUI.rank_game
    if user_dataUI.rank_game == "xiaoxiaole_award_rate" then
        self.user_rank_game_txt.text = "水果消消乐"
        self.user_rank_game_txt.color = type_color["sgxxl"]
        self.user_rank_game_txt.transform:GetComponent("Outline").effectColor = type_color["sgxxl_outline"]
    elseif user_dataUI.rank_game == "xiaoxiaole_shuihu_award_rate" then
        self.user_rank_game_txt.text = "水浒消消乐"
        self.user_rank_game_txt.color = type_color["shxxl"]
        self.user_rank_game_txt.transform:GetComponent("Outline").effectColor = type_color["shxxl_outline"]
    elseif user_dataUI.rank_game == "xiaoxiaole_caishen_award_rate" then
        self.user_rank_game_txt.text = "财神消消乐"
        self.user_rank_game_txt.color = type_color["csxxl"]
        self.user_rank_game_txt.transform:GetComponent("Outline").effectColor = type_color["csxxl_outline"]
    elseif user_dataUI.rank_game == "xiaoxiaole_xiyou_award_rate" then
        self.user_rank_game_txt.text = "西游消消乐"
        self.user_rank_game_txt.color = type_color["xyxxl"]
        self.user_rank_game_txt.transform:GetComponent("Outline").effectColor = type_color["xyxxl_outline"]
    else
        self.user_rank_game_txt.text = ""
    end

    self.user_rank_mult_txt.text = user_dataUI.rank_mult .. "倍"
    if user_dataUI.rank_award == nil then
        self.user_rank_award_txt.text = "- -"
    else
        self.user_rank_award_txt.text = user_dataUI.rank_award
    end
    user_dataUI = {}
end

function C:on_act_045_xxlbd_base_info_get(_)
    self:InitRankUser()
end

function C:on_act_045_xxlbd_rank_info_get(_)
    self:InitRanklis()
end


function C:OpenHelpPanel()
    local str = DESCRIBE_TEXT[1]
    for i = 2, #DESCRIBE_TEXT do
        str = str .. "\n" .. DESCRIBE_TEXT[i]
        if i == 2 and M.IsPlatformOfWZQ()  then
            str = str .. "（不记录超级消消乐）"
        end
    end
    self.introduce_txt.text = str
    IllustratePanel.Create({ self.introduce_txt.gameObject }, GameObject.Find("Canvas/LayerLv5").transform)
end

function C:OnDestroy()
    self:MyExit()
end