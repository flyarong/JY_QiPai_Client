-- 创建时间:2021-01-25
-- Act_TY_BSYYManager 管理器
--仅支持同一时间一个的比赛预约（服务器那边都用的一条协议。）
local basefunc = require "Game/Common/basefunc"
Act_TY_BSYYManager = {}
local M = Act_TY_BSYYManager
M.key = "act_ty_bsyy"
M.config = GameButtonManager.ExtLoadLua(M.key, "act_ty_bsyy_config").base
M.local_data = nil
M.is_yuyue = false
GameButtonManager.ExtLoadLua(M.key, "Act_TY_BSYYPanel")
GameButtonManager.ExtLoadLua(M.key, "Act_TY_BSYYPanel_Out")
local this
local lister
local start_time = 0 
local end_time = 0
local match_start_time = 0
local match_day_time = 0

function M.IsActive()
    return M.local_data ~= nil
end

function M.CheckIsShow()
    return M.IsActive()
end
-- 活动面板调用
function M.CheckIsShowInActivity()
    return M.IsActive()
end

-- 所有可以外部创建的UI
function M.GotoUI(parm)
    if parm.goto_scene_parm == "panel" then
        return Act_TY_BSYYPanel.Create(parm.parent,M.local_data)
    elseif parm.goto_scene_parm == "panel_out" then
        return Act_TY_BSYYPanel_Out.Create(parm.parent,M.local_data,parm.backcall)
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
	lister["act_match_order_msg_change"] = M.on_act_match_order_msg_change
    lister["query_gns_ticket_response"] = M.SetData
    lister["PPC_Created"] = M.on_PPC_Created
    lister["JBS_Created"] = M.on_JBS_Created
    lister["get_gns_ticket_response"] = M.on_get_gns_ticket_response
    lister["EnterScene"] = M.On_EnterScene
    lister["year_btn_created"] = M.on_year_btn_created
    lister["game_act_left_prefab_created"] = M.on_game_act_left_prefab_created
end

function M.Init()
	M.Exit()
	this = Act_TY_BSYYManager
	MakeLister()
    AddLister()
    --M.UpdateActBaseIndex()
    M.UpdateUIConfig()

    if M.local_data then
        Network.SendRequest("query_gns_ticket")
    end
end

function M.Exit()
	if this then
        RemoveLister()
        M.local_data = nil
		this = nil
	end
end

function M.UpdateUIConfig()
    local now_t = os.time()
    M.local_data = nil
    for i = 1,#M.config do
        if M.config[i].start_time < now_t and M.config[i].end_time > now_t then
            M.local_data = M.config[i]
            start_time = M.local_data.start_time
            end_time = M.local_data.end_time
            match_start_time = M.local_data.match_start_time
            match_day_time = M.local_data.match_day_time
        end
    end
end

function M.OnLoginResponse(result)
	if result == 0 then
        -- 数据初始化
	end
end

function M.OnReConnecteServerSucceed()
    
end

--修改在大活动弹窗中的排序
function M.UpdateActBaseIndex()
    SYSACTBASEManager.ForceToChangeIndex(M.key,8,function()
        if M.is_yuyue then
            return true
        end
    end)
end

--预留支持同一时间多版本共存*(data.type 预留字段)
function M.SetData(_,data)
    dump(data,"<color=red>开年福利赛比赛预约</color>")
    if data and data.result == 0 then 
		if data.status == 1 then 
			M.is_yuyue = true
		else
			M.is_yuyue = false
        end
        M.UpdateActBaseIndex()
        Event.Brocast("model_ty_bsyy_data_update")
        Event.Brocast("global_hint_state_change_msg",{gotoui = M.key})   
    end
end


function M.on_PPC_Created()
    if os.time() > start_time and os.time() < end_time then
        if not M.is_yuyue and MainModel.GetHBValue() >= 1 then 
            local newtime = tonumber(os.date("%Y%m%d", os.time()))
            local oldtime = tonumber(os.date("%Y%m%d", tonumber(PlayerPrefs.GetString(M.key .. MainModel.UserInfo.user_id, 0))))
            if oldtime ~= newtime then
                M.CreatPlanelOut()
                PlayerPrefs.SetString(M.key .. MainModel.UserInfo.user_id, os.time())
            end
        end
    end 
end

function M.on_JBS_Created()
    if os.time() > start_time and os.time() < end_time then
        if not M.is_yuyue and MainModel.GetHBValue() >= 1 then 
            local newtime = tonumber(os.date("%Y%m%d", os.time()))
            local oldtime = tonumber(os.date("%Y%m%d", tonumber(PlayerPrefs.GetString(M.key .. MainModel.UserInfo.user_id.."jbs", 0))))
            if oldtime ~= newtime then
                --Act_044_BSYYPanel_Out.Create()
                M.CreatPlanelOut()
                PlayerPrefs.SetString(M.key .. MainModel.UserInfo.user_id.."jbs", os.time())
            end
        end
    end 
end

function M.CreatPlanelOut()
    --完成了新手引导再弹出

    if GameGlobalOnOff.IsOpenGuide and MainModel.UserInfo.xsyd_status == 0 or not M.IsActive() then
        return 
    end
    --if GameGlobalOnOff.IsOpenGuide and MainModel.UserInfo.xsyd_status == 1 then
        Act_TY_BSYYPanel_Out.Create(nil,M.local_data)
    --end
end

function M.On_EnterScene()
    M.UpdateUIConfig()
    if M.IsYuYue() then
        return
    end
    if os.time() < start_time or os.time() > end_time then
        return
    end
    if not MainModel.UserInfo or (GameGlobalOnOff.IsOpenGuide and MainModel.UserInfo.xsyd_status == 0) then 
        return    
    end
    if MainModel.myLocation == "game_MatchHall" then
        --Act_044_BSYYPanel_Out.Create()
        M.CreatPlanelOut()
    end
    if MainModel.myLocation == "game_Free" then
        --Act_044_BSYYPanel_Out.Create()
        M.CreatPlanelOut()
    end
end

function M.IsYuYue()
    return M.is_yuyue
end

function M.on_get_gns_ticket_response( ... )
    Event.Brocast("global_hint_state_change_msg",{gotoui = M.key})   
end

function M.on_act_match_order_msg_change(data)
    --只在当日做变化
    if os.time() > match_day_time and os.time() < match_start_time then
        --大厅跳转
        if data.goto_parm then
            data.goto_parm.match_type_id = 9
        end
        --大厅界面处理 
        if data.hall_img then
            data.hall_img.sprite = GetTexture("wyfls_imgf_fls")
            data.hall_img:SetNativeSize()
        end
    end
end

function M.GetMatchStartTime()
    return end_time
end

function M.on_year_btn_created(panelSelf)

end

function M.on_game_act_left_prefab_created(panelSelf)
    if panelSelf and panelSelf.config then
        if panelSelf.config.parmData== M.key then
            if os.time() > start_time and os.time() < end_time then
                if M.IsYuYue() then
                    panelSelf.GetImage:GetComponent("Image").sprite = GetTexture("hall_icon_lfl")
                    panelSelf.GetImage:GetComponent("Image"):SetNativeSize()
                    panelSelf.GetImage.gameObject:SetActive(false)            
                else
                    panelSelf.GetImage:GetComponent("Image").sprite = GetTexture("hall_icon_lmp")
                    panelSelf.GetImage:GetComponent("Image"):SetNativeSize()
                    panelSelf.GetImage.gameObject:SetActive(true)                    
                end
            end
        end
    end
end

function M.GetCurrMatchName()
    if M.local_data then
        return M.local_data.name or M.config[#M.config].name
    else
        return M.config[#M.config].name
    end
end
