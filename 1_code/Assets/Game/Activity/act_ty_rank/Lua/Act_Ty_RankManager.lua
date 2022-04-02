-- 创建时间:2020-12-28
-- Act_Ty_RankManager 管理器

local basefunc = require "Game/Common/basefunc"
Act_Ty_RankManager = {}
local M = Act_Ty_RankManager

M.key = "act_ty_rank"
GameButtonManager.ExtLoadLua(M.key, "Act_Ty_RankPanel")
GameButtonManager.ExtLoadLua(M.key, "Act_Ty_RankPanel_Xxl")
GameButtonManager.ExtLoadLua(M.key, "Act_Ty_RankPanel_Ea")
GameButtonManager.ExtLoadLua(M.key, "Act_Ty_RankTips")
GameButtonManager.ExtLoadLua(M.key, "Act_Ty_RankHint")

local config = GameButtonManager.ExtLoadLua(M.key,"act_ty_rank_config")
local email_config = GameButtonManager.ExtLoadLua(M.key, "act_ty_rank_email_config")

local this
local lister

local cur_rank_key

-- 是否有活动
function M.IsActive()
    -- 活动的开始与结束时间
    local s_time 
    local e_time 
    if (e_time and os.time() > e_time) or (s_time and os.time() < s_time) then
        return false
    end

    -- 对应权限的key
    local _permission_key 
    if _permission_key then
        local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key=_permission_key, is_on_hint = true}, "CheckCondition")
        if a and not b then
            return false
        end
        return true
    else
        return true
    end
end
-- 创建入口按钮时调用
function M.CheckIsShow(parm)

    if not M.IsActive() then
        return false
    end

    if not M.IsRankActive(parm.goto_type) then
        cur_rank_key = nil
        return false
    else
        cur_rank_key = parm.goto_type
    end

    return true
end
-- 活动面板调用
function M.CheckIsShowInActivity()
    return M.IsActive()
end

-- 所有可以外部创建的UI
function M.GotoUI(parm)
    if not M.CheckIsShow(parm) then
        return
    end
    if parm.goto_scene_parm == "panel" then
        local cfg = M.GetRankCfg(parm.goto_type)
        if cfg.type == 1 then       --普通排行榜
            return Act_Ty_RankPanel.Create(parm.parent, parm.goto_type)
        elseif cfg.type == 2 then   --消消乐排行榜
            return Act_Ty_RankPanel_Xxl.Create(parm.parent, parm.goto_type)
        elseif cfg.type == 3 then   --有额外奖励的排行榜
            return Act_Ty_RankPanel_Ea.Create(parm.parent, parm.goto_type)
        end
    end
end
-- 活动的提示状态
function M.GetHintState(parm)
	return ACTIVITY_HINT_STATUS_ENUM.AT_Nor
end
function M.on_global_hint_state_set_msg(parm)
	if parm.gotoui == M.key then
		M.SetHintState()
	end
end
-- 更新活动的提示状态(针对那种 打开界面就需要修改状态的需求)
function M.SetHintState()
    Event.Brocast("global_hint_state_change_msg", { gotoui = M.key })
end


local function AddLister()
    for msg,cbk in pairs(lister) do
        Event.AddListener(msg, cbk)
    end
end

local function RemoveLister()
    if lister then
        for msg,cbk in pairs(lister) do
            Event.RemoveListener(msg, cbk)
        end
    end
    lister=nil
end
local function MakeLister()
    lister = {}
    lister["OnLoginResponse"] = this.OnLoginResponse
    lister["ReConnecteServerSucceed"] = this.OnReConnecteServerSucceed
    lister["global_hint_state_set_msg"] = this.on_global_hint_state_set_msg

    lister["query_rank_base_info_response"] = this.query_rank_base_info_response
    lister["query_rank_data_response"] = this.query_rank_data_response
    lister["year_btn_created"] = this.on_year_btn_created
    lister["ActivityYearPanelBack"] = this.OnActivityYearPanelBack
end

function M.Init()
	M.Exit()
    this = Act_Ty_RankManager
    
    this.m_data = {}
    this.m_data.rank_cfg = {}
    this.m_data.rank_data = {}
    this.m_data.rank_base_data = {}

	MakeLister()
    AddLister()

    M.InitRankCfg()
    -- dump(this.m_data.rank_cfg , "<color=red>Rank_Cfg</color>")
    M.SetRankEmail()
    M.QueryAllRankData()
end
function M.Exit()
	if this then
		RemoveLister()
		this = nil
	end
end
function M.InitUIConfig()
    this.UIConfig = {}
end

function M.OnLoginResponse(result)
	if result == 0 then
        -- 数据初始化
	end
end

function M.OnReConnecteServerSucceed()
end

--初始化排行榜数据
function M.InitRankCfg()
    this.m_data.rank_cfg = {}
    for i = 1, #config.ranks do
        local cur_cfg = config.ranks[i]
        if cur_cfg.isOnOff == 1 then
            this.m_data.rank_cfg[cur_cfg.act_rank_key] = config.ranks[i]
        end
    end
end

function M.GetRankCfg(rank_key)
    if this.m_data.rank_cfg[rank_key] then
        return this.m_data.rank_cfg[rank_key]
    end
end

function M.GetRankData(rank_key)
    if this.m_data.rank_data[rank_key] then
        return this.m_data.rank_data[rank_key]
    end
end

function M.GetRankBaseData(rank_key)
    if this.m_data.rank_base_data[rank_key] then
        return this.m_data.rank_base_data[rank_key]
    end
end

--获取前3的皇冠图标
function M.GetWinIcon(_index)
    if _index > 0 and _index <=3 then
        return config.others.rank_win_icon.cfg[_index]
    end
end

--获取奖励
function M.GetAward(_index)
    if config.others.award.cfg[_index] then
        return config.others.award.cfg[_index]
    end
end
--获取基础奖励（有额外奖励时）
function M.GetBaseAward(_index)
    if config.ext_award_cfg[_index] then
        return config.ext_award_cfg[_index].base_award
    end
end

--获取额外奖励（有额外奖励时）
function M.GetExtAwardCfg(index)
    if config.ext_award_cfg[index] then
        return config.ext_award_cfg[index]
    end
end

function M.GetExtAwardCondi(index)
    if config.ext_award_cfg[index] then
        return config.ext_award_cfg[index].ext_award_condi
    end
end

function M.GetExtCfg()
    return config.ext_award_cfg
end

local percents = {0.1, 0.3, 0.5}

function M.GetRankGiftAddRate(_gift_key)
    local rate = 0
	local a, b = GameButtonManager.RunFun({gotoui = "act_ty_gifts",gift_key = _gift_key}, "GetBuyGiftsNumEx")
	if a then
		if b > 0 then
			rate = percents[b]
		end
	end
    return rate
end

function M.TransformScore(score_data, item_type)
    local score = score_data
    if item_type == 2 then     --倍数类、积分类
        score = score_data / 100
    elseif item_type == 3 then 
        score = score_data / 10000 - (score_data / 10000) % 0.01
    else                                --收集类
        score = score_data
    end
    return tonumber(score)
end

function M.IsRankActive(rank_key)
    if not M.GetRankCfg(rank_key) then
        return false
    end
    if not M.IsRankInTime(rank_key)then
        return false
    end
    return true
end

--是否在开启时间内
function M.IsRankInTime(rank_key)
    if M.GetRankCfg(rank_key) then
        local cfg = M.GetRankCfg(rank_key)
        return MathExtend.isTimeValidity(cfg.start_time, cfg.end_time)
    end
    return false
end

--设置邮件
function M.SetRankEmail()

    local add_show = function (rank_type)
        local check_func = function(type)
            if type == rank_type .. "_email_award" then
                return true
            end
        end
        MainModel.AddShow(check_func)
    end

    local set_email = function(rank_type, act_name)
        EmailModel.AddRankType(rank_type .. "_email", act_name)
    end

    local set_ext_email = function(rank_type, act_name)
        EmailModel.AddRankBaseType(rank_type .. "_email", act_name)
        EmailModel.AddRankEaType(rank_type .. "_ext_email", act_name)
    end

   for i = 1, #email_config do
        set_ext_email(email_config[i].rank_type, email_config[i].name)
        add_show(email_config[i].rank_type)
    end
end

--请求排行榜数据，要及时关闭不需要开的排行榜
function M.QueryAllRankData()
    for k, v in pairs(this.m_data.rank_cfg) do
        if M.IsRankInTime(v.act_rank_key) then
            M.QueryRankData(v.rank_type)
            M.QueryRankBaseData(v.rank_type)
        end
    end
end

function M.QueryRankData(_rank_type)
    Network.SendRequest("query_rank_data", { page_index = 1, rank_type = _rank_type })
end

function M.QueryRankBaseData(_rank_type)
    Network.SendRequest("query_rank_base_info", { rank_type = _rank_type })
end

function M.GetKeyFromRankType(_rank_type)
    for k, v in pairs(this.m_data.rank_cfg) do
        if v.rank_type == _rank_type then
            return k
        end
    end
end

function M.UpdateRankData(rank_key, _data)
    this.m_data.rank_data[rank_key] = _data
end

function M.UpdateRankBaseData(rank_key, _data)
    this.m_data.rank_base_data[rank_key] = _data
end

function M.query_rank_base_info_response(_, data)
    dump(data, "<color=red><size=15>排行榜数据Rank_Base</size></color>")
    if data and data.result == 0 then
        local rank_key = M.GetKeyFromRankType(data.rank_type)
        if rank_key then
            M.UpdateRankBaseData(rank_key, data)
            Event.Brocast("act_ty_rank_base_info_get",{rank_type = data.rank_type})
        end
    end
end

function M.query_rank_data_response(_, data)
    dump(data, "<color=red><size=15>排行榜数据Rank</size></color>")
    if data and data.result == 0 then
        local rank_key = M.GetKeyFromRankType(data.rank_type)
        if rank_key then
            M.UpdateRankData(rank_key, data.rank_data)
            Event.Brocast("act_ty_rank_info_get",{rank_type = data.rank_type})
        end
    end
end

function M.CheckRemindWindow()
    
end

function M.OnActivityYearPanelBack()
    -- 打开
    -- do return end
    if not cur_rank_key then
        return
    end
    local lastDay = PlayerPrefs.GetInt(M.key .. "_" .. MainModel.UserInfo.user_id .. "_Rank_Hint", 0)
    local curDay = tonumber(os.date("%Y%m%d",os.time()))
    if lastDay ~= 0 and curDay <= lastDay then
        return
    end
    local cfg = M.GetRankCfg(cur_rank_key)
    Network.SendRequest("query_rank_base_info", {rank_type = cfg.rank_type }, "", function(data)
        dump(data, "<color=red><size=15>排行榜数据RankBase</size></color>")
        if data and data.result == 0 then
            local rank_key = M.GetKeyFromRankType(data.rank_type)
            if rank_key then
                M.UpdateRankBaseData(rank_key, data)
                local baseData = M.GetRankBaseData(cur_rank_key)
                local rank = tonumber(baseData.rank)                            --当前排明
                if rank < 2 or rank > 20 then
                    return
                end
                local rankData = M.GetRankData(cur_rank_key)

                if not cfg.gift_key or not Act_Ty_GiftsManager then
                    return
                end

                local lastRank = rank - 1

                if not rankData[lastRank] then
                    return
                end

                local actName = cfg.act_rank_name                                                --活动名称
                local diffValue = M.TransformScore(rankData[lastRank].score - baseData.score, cfg.item_type)       --与前一名相差的积分
                
                if tonumber(diffValue) < 0 then
                    return
                end

                local endTime = StringHelper.formatTimeDHMS(cfg.end_time - os.time())               --剩余时间
                local gift_name = Act_Ty_GiftsManager.GetGiftCfg(cfg.gift_key).act_gift_name
                local showTxt = {
                    remain_time =  "剩余时间:" .. endTime,
                    rank = "您当前在（<color=#C95602>" .. actName .. "</color>）中排名<color=#FF0000>第" .. rank .. "</color>",
                    diff = "距离前一名还差<color=#2C84FD>" .. diffValue .. "</color>" .. cfg.item_name,
                    buff_gift = "购买(<color=#FF6C00>" .. gift_name .. "</color>)可获得" .. cfg.item_name .."<color=#FF6C00>加成特权！</color>",
                }
                Act_Ty_RankHint.Create({txt = showTxt, gift_key = cfg.gift_key})
                PlayerPrefs.SetInt(M.key .. "_" .. MainModel.UserInfo.user_id .. "_Rank_Hint", os.date("%Y%m%d",os.time()))
            end
        end
    end)
end