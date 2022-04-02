local basefunc = require "Game/Common/basefunc"
HQYDManager = {}
local M = HQYDManager
M.key = "act_hqyd"
M.lottery_type = "celebrate_new_day" 
GameButtonManager.ExtLoadLua(M.key, "ActHQYDPanel")
GameButtonManager.ExtLoadLua(M.key, "HQYDListPanel")
GameButtonManager.ExtLoadLua(M.key, "HQYD_EnterPrefab")
local person_str_data = {
    kuai =  {num = 0, img = "hqyd_imgf_1",not_img = "hqyd_imgf_16"},
    le = {num = 0, img = "hqyd_imgf_2",not_img = "hqyd_imgf_14"},
    dan = {num = 0, img = "hqyd_imgf_9",not_img = "hqyd_imgf_17"},
    nian = {num = 0, img = "hqyd_imgf_6",not_img = "hqyd_imgf_13"},
    cai = {num = 0, img = "hqyd_imgf_5",not_img = "hqyd_imgf_11"},
    xin = {num = 0, img = "hqyd_imgf_3",not_img = "hqyd_imgf_12"},
    shu = {num = 0, img = "hqyd_imgf_4",not_img = "hqyd_imgf_15"},
    yuan = {num = 0, img = "hqyd_imgf_7",not_img = "hqyd_imgf_18"},
    fa = {num = 0, img = "hqyd_imgf_8",not_img = "hqyd_imgf_10"},
} 

local s_time = 1577835000
local e_time = 1578326399  
local lister
local m_data
local type_info = {
    type = M.lottery_type,
    start_time = s_time,
    end_time = e_time,
}

local bao_level_limit_type = {
    [1] = {person_str_data.xin,person_str_data.nian,person_str_data.kuai,person_str_data.le,},
    [2] = {person_str_data.shu,person_str_data.nian,person_str_data.kuai,person_str_data.le,},
    [3] = {person_str_data.yuan,person_str_data.dan,person_str_data.kuai,person_str_data.le,},
    [4] = {person_str_data.fa,person_str_data.cai,person_str_data.xin,person_str_data.nian,},
}
local bao_level_limit_num = {
    [1] = {1,1,1,1},
    [2] = {1,1,1,1},
    [3] = {1,1,1,1},
    [4] = {1,1,1,1},
}

function M.CheckIsShow()
    if MainModel.UserInfo.ui_config_id == 1 and M.IsActive() and os.time() > s_time and os.time() < e_time then 
        return true
    end 
end

function M.GotoUI(parm)
    if parm.goto_scene_parm == "enter" then
		return HQYD_EnterPrefab.Create(parm.parent)
    elseif parm.goto_scene_parm == "panel" then
        if M.IsActive() then 
            return ActHQYDPanel.Create(parm.parent,parm.backcall)
        end 
    else
        dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
    end
end

local function AddLister()
    for msg, cbk in pairs(lister) do
        Event.AddListener(msg, cbk)
    end
end

local function RemoveLister()
    if lister then
        for msg, cbk in pairs(lister) do
            Event.RemoveListener(msg, cbk)
        end
    end
    lister = nil
end
local function MakeLister()
    lister = {}
    lister["get_one_common_lottery_info"] = M.SetData
    lister["AssetChange"] = M.SetData
    lister["OnLoginResponse"] = M.OnLoginResponse
end

function M.Init()
    M.Exit()
    m_data = {}
    MakeLister()
    AddLister()
    LotteryBaseManager.AddQuery(type_info)
end

function M.Exit()
    if M then
        RemoveLister()
    end
end

function M.OnLoginResponse(result)
    if result ~= 0 then return end
    M.SetData()
end

function M.SetData()
    person_str_data.kuai.num = GameItemModel.GetItemCount("prop_new_year_word_kuai")
    person_str_data.yuan.num = GameItemModel.GetItemCount("prop_new_year_word_yuan")
    person_str_data.le.num = GameItemModel.GetItemCount("prop_new_year_word_le")
    person_str_data.cai.num = GameItemModel.GetItemCount("prop_new_year_word_cai")
    person_str_data.xin.num = GameItemModel.GetItemCount("prop_new_year_word_xin")
    person_str_data.fa.num = GameItemModel.GetItemCount("prop_new_year_word_fa")
    person_str_data.shu.num = GameItemModel.GetItemCount("prop_new_year_word_shu")
    person_str_data.dan.num = GameItemModel.GetItemCount("prop_new_year_word_dan")
    person_str_data.nian.num = GameItemModel.GetItemCount("prop_new_year_word_nian")
    Event.Brocast("global_hint_state_change_msg",{gotoui = M.key})
end

function M.GetData()
    return person_str_data
end

function M.GetJF()
    if LotteryBaseManager.GetData(M.lottery_type) then 
        return LotteryBaseManager.GetData(M.lottery_type).ticket_num
    end
    return 0  
end

function M.GetHintState(parm)
    if M.GetJF() >= 50 or M.IsCanOpenBox(1) or M.IsCanOpenBox(2) or M.IsCanOpenBox(3) or M.IsCanOpenBox(4) then
        return ACTIVITY_HINT_STATUS_ENUM.AT_Get
    else
        return ACTIVITY_HINT_STATUS_ENUM.AT_Nor
    end 
end

function M.IsCanOpenBox(box_level)
    for i=1,#bao_level_limit_type[box_level] do
        if bao_level_limit_type[box_level][i].num < bao_level_limit_num[box_level][i] then 
            return false
        end 
    end
    return true    
end

function M.GetLimitType()
    return bao_level_limit_type
end

function M.GetLimitNum()
    return bao_level_limit_num
end

function M.IsActive()
    local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key="actp_common_lottery_ceremony_lottery", is_on_hint = true}, "CheckCondition")
    if a and not b then
        return false
    end
    return true
end