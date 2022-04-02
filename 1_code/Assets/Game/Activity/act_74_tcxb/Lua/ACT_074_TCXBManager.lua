-- 创建时间:2022-03-09
-- ACT_074_TCXBManager 管理器

local basefunc = require "Game/Common/basefunc"
ACT_074_TCXBManager = {}
local M = ACT_074_TCXBManager
M.key = "act_74_tcxb"
local config = GameButtonManager.ExtLoadLua(M.key, "act_074_tcxb_config")
GameButtonManager.ExtLoadLua(M.key, "ACT_074_TCXBItemBase")
GameButtonManager.ExtLoadLua(M.key, "ACT_074_TCXBPanel")
GameButtonManager.ExtLoadLua(M.key, "ACT_074_TCXBPhaseItemBase")
GameButtonManager.ExtLoadLua(M.key, "ACT_074_TCXBPreviewItemBase")
GameButtonManager.ExtLoadLua(M.key, "ACT_074_TCXBPreviewPanel")
GameButtonManager.ExtLoadLua(M.key, "ACT_074_TCXBTipPanel")
GameButtonManager.ExtLoadLua(M.key, "ACT_074_TCXBHintPanel")

M.item_key = "prop_fish_drop_act_0"
M.act_type = "spring_lottery"
M.end_time = 1648483199

local this
local lister

-- 是否有活动
function M.IsActive()
    -- 活动的开始与结束时间
    local e_time = M.end_time
    local s_time
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
function M.CheckIsShow(parm, type)
    return M.IsActive()
end
-- 活动面板调用
function M.CheckIsShowInActivity()
    return M.IsActive()
end

-- 所有可以外部创建的UI
function M.GotoUI(parm)
    if not M.CheckIsShow(parm) then
        dump(parm, "<color=red>不满足条件</color>")
        return
    end
    if parm.goto_scene_parm == "panel" then
        return ACT_074_TCXBPanel.Create(parm.parent,parm.backcall)
    end
    dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
end
-- 活动的提示状态
function M.GetHintState(parm)
	if parm and parm.gotoui == M.key then 
        if M.IsCanGet() then
            return ACTIVITY_HINT_STATUS_ENUM.AT_Get
        else
            --[[local newtime = tonumber(os.date("%Y%m%d", os.time()))
            local oldtime = tonumber(os.date("%Y%m%d", tonumber(PlayerPrefs.GetString(M.key .. MainModel.UserInfo.user_id, 0))))
            if oldtime ~= newtime then
                return ACTIVITY_HINT_STATUS_ENUM.AT_Red
            end--]]
            return ACTIVITY_HINT_STATUS_ENUM.AT_Nor
        end
    end
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

    lister["spring_activity_lottery_response"] = this.on_spring_activity_lottery_response
    lister["get_spring_activity_data_response"] = this.on_get_spring_activity_data_response
    lister["spring_activity_reset_awards_response"] = this.on_spring_activity_reset_awards_response

    lister["AssetChange"] = this.on_AssetChange
end

function M.Init()
	M.Exit()

	this = ACT_074_TCXBManager
	this.m_data = {}
	MakeLister()
    AddLister()
	M.InitUIConfig()
end
function M.Exit()
	if this then
		RemoveLister()
		this = nil
	end
end
function M.InitUIConfig()
    this.UIConfig = {}
    this.m_data.sw_data = {}
end

function M.OnLoginResponse(result)
	if result == 0 then
        -- 数据初始化
	end
end
function M.OnReConnecteServerSucceed()
end

function M.GetConfig()
    return config
end

function M.IsCanGet()
    local num = GameItemModel.GetItemCount(M.item_key)
    if num >= 200 then
        return true
    end
    return false
end


function M.Lottery(type,select_no)
    Network.SendRequest("spring_activity_lottery",{act_type = M.act_type,lottery_type = type,select_no = select_no},"")
end

function M.on_spring_activity_lottery_response(_,data)
    dump(data,"<color=yellow><size=15>++++++++++on_spring_activity_lottery_response++++++++++</size></color>")
    if data and data.result == 0 then
        this.m_data.new_arr = {}
        local temp_tab = {}
        if not table_is_null(data.pos_arr) then
            if #data.pos_arr == 15 then
                M.SetXP(true)
            end
            for k,v in pairs(data.pos_arr) do
                local need_add = true
                for kk,vv in pairs(this.m_data.pos_arr) do
                    if v == vv then
                        need_add = false
                        break
                    end
                end
                if need_add then
                    this.m_data.new_arr[v] = v
                    temp_tab[k] = k
                end
            end
        end
        if not table_is_null(data.award_arr) then
            local tab = {}
            for k,v in pairs(data.award_arr) do
                local need_add = true
                for kk,vv in pairs(this.m_data.award_arr) do
                    if v == vv and not temp_tab[k] then
                        need_add = false
                        break
                    end
                end
                if need_add then
                    tab[#tab + 1] = v
                end
            end
            for k,v in pairs(tab) do
                if config.pool[v].award_img == "activity_icon_gift319_jlydm" or config.pool[v].award_img == "activity_icon_gift318_jlyy" or config.pool[v].award_img == "activity_icon_gift320_jdm" or config.pool[v].award_img == "activity_icon_gift295_jdm" then
                    this.m_data.sw_data[#this.m_data.sw_data + 1] = {tips = "恭喜您获得" .. config.pool[v].tips .. ",实物奖励请联系客服QQ公众号4008882620领取",img = config.pool[v].award_img}
                end
            end
        end
        this.m_data.pos_arr = data.pos_arr or {}
        this.m_data.award_arr = data.award_arr or {}
        Event.Brocast("on_spring_activity_lottery_msg")
        Event.Brocast("global_hint_state_change_msg", { gotoui = M.key })
    end
end

function M.QueryData()
    Network.SendRequest("get_spring_activity_data",{act_type = M.act_type})
end

function M.on_get_spring_activity_data_response(_,data)
    dump(data,"<color=yellow><size=15>++++++++++on_get_spring_activity_data_response++++++++++</size></color>")
    if data and data.result == 0 then
        this.m_data.pos_arr = data.pos_arr or {}
        this.m_data.award_arr = data.award_arr or {}
        Event.Brocast("on_get_spring_activity_data_msg")
    end
end

function M.Reset()
    Network.SendRequest("spring_activity_reset_awards",{act_type = M.act_type})
end

function M.on_spring_activity_reset_awards_response(_,data)
    dump(data,"<color=yellow><size=15>++++++++++on_spring_activity_reset_awards_response++++++++++</size></color>")
    if data and data.result == 0 then
        M.SetXP(true)
        this.m_data.pos_arr = {}
        this.m_data.award_arr = {}
        Event.Brocast("on_spring_activity_reset_awards_msg")
        Event.Brocast("global_hint_state_change_msg", { gotoui = M.key })
    end
end

function M.GetRemain()
    return 15 - #this.m_data.pos_arr
end

function M.CheckOver(index)
    for k,v in pairs(this.m_data.pos_arr) do
        if v == index then
            return true
        end
    end
    return false
end

function M.GetAwardIndexByIndex(index)
    for i=1,#this.m_data.pos_arr do
        if this.m_data.pos_arr[i] == index then
            return this.m_data.award_arr[i]
        end
    end
end

function M.CheckNew(index)
    if this.m_data.new_arr and this.m_data.new_arr[index] then
        return true
    end
    return false
end

function M.on_AssetChange(data)
    if data then
        if data.change_type and string.sub(data.change_type,1,15) == "spring_lottery_" then
            this.m_data.award_data = data
        end
        if not table_is_null(data.data) then
            for k,v in pairs(data.data) do
                if v.asset_type == "prop_fish_drop_act_0" then
                    Event.Brocast("global_hint_state_change_msg", { gotoui = M.key })
                end
            end
        end
    end
end

function M.ShowAward()
    if this.m_data.award_data and #this.m_data.award_data.data == 2 then
        Event.Brocast("AssetGet",this.m_data.award_data)
        this.m_data.award_data = nil
    end
end

function M.ShowSWAward(fun)
    dump(this.m_data.sw_data,"<color=yellow><size=15>+++++++//+++data++++++++++</size></color>")
    if not table_is_null(this.m_data.sw_data) then
        for i=1,#this.m_data.sw_data do
            if i ~= #this.m_data.sw_data then
                ACT_074_TCXBHintPanel.Create(this.m_data.sw_data[i].tips,this.m_data.sw_data[i].img)
            else
                ACT_074_TCXBHintPanel.Create(this.m_data.sw_data[i].tips,this.m_data.sw_data[i].img,fun)
            end
        end
        this.m_data.sw_data = {}
    end
end

function M.NeedShowSWAward()
    return not table_is_null(this.m_data.sw_data)
end

function M.ClearNew()
    this.m_data.new_arr = {}
end

function M.GetCurSpringNum()
    local num = 0
    for k,v in pairs(this.m_data.award_arr) do
        if v == 17 then
            num = num + 1
        end
    end
    return num
end

function M.CheckNeedXP()
    return this.m_data.need_xp
end

function M.SetXP(b)
    this.m_data.need_xp = b
end

function M.ClearData()
    this.m_data.pos_arr = {}
    this.m_data.award_arr = {}
end