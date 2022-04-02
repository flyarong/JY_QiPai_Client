local basefunc = require "Game/Common/basefunc"
BY3DKPSHBManager = {}
local M = BY3DKPSHBManager
M.key = "by3d_kpshb"

GameButtonManager.ExtLoadLua(M.key, "by3d_kpshbPrefabPanel")
GameButtonManager.ExtLoadLua(M.key, "by3d_ksshb_hallprefab")
GameButtonManager.ExtLoadLua(M.key, "BY3DKPSHBEnterPanel")
GameButtonManager.ExtLoadLua(M.key, "KPSHBPrefabPanel")
GameButtonManager.ExtLoadLua(M.key, "KPSHBSMPrefabPanel")
GameButtonManager.ExtLoadLua(M.key, "KPSHBTCPanel")
GameButtonManager.ExtLoadLua(M.key, "KPSHBLotteryPanel")
GameButtonManager.ExtLoadLua(M.key, "KPSHBLotteryPrefab")
GameButtonManager.ExtLoadLua(M.key, "KPSHBLotteryTopPrefab")
GameButtonManager.ExtLoadLua(M.key, "KPSHBLotteryGotoPanel")

local config = GameButtonManager.ExtLoadLua(M.key, "fishing3d_kpshb_config")
local this
local lister

-- 捕鱼大厅
local byhall_rect
local byhall_index

-- 是否有活动
function M.IsActive()
    -- 活动的开始与结束时间
    local e_time
    local s_time
    if (e_time and os.time() > e_time) or (s_time and os.time() < s_time) then
        return false
    end

    -- 对应权限的key
    local _permission_key = "actp_own_task_p_wqp_buyu_hongbao"
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
    if tonumber(parm.goto_scene_parm) then
        return M.IsActive()
    end

    -- 目前只有体验场没有
    if MainModel.myLocation == "game_Fishing" and FishingModel and not this.UIConfig.game_task_map[FishingModel.game_id] then
        return false
    end
    -- 没有任务数据或者没有玩家数据
    if not GameTaskModel.GetTaskDataByID(M.GetCurrTaskID()) or not FishingModel.GetPlayerData() or not this.m_data.crr_level then
        return false
    end

    return M.IsActive()
end

-- 活动面板调用
function M.CheckIsShowInActivity()
    return M.IsActive()
end

-- 所有可以外部创建的UI
function M.GotoUI(parm)
    if parm.goto_scene_parm == "game" then
        return BY3DKPSHBEnterPanel.Create(parm)
    elseif tonumber(parm.goto_scene_parm) then
        return by3d_kpshbPrefabPanel.Create(parm)
    elseif parm.goto_scene_parm == "cj" then
        if MainModel.myLocation == "game_Fishing" then
            return KPSHBLotteryPanel.Create(parm, parm.parent)
        else
            return KPSHBLotteryGotoPanel.Create(parm, parm.parent)
        end
    elseif parm.goto_scene_parm == "bytop_area" then
        return BY3DKPSHBEnterPanel.Create(parm)
    else
        dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>") 
    end
end
-- 活动的提示状态
function M.GetHintState(parm)
    if M.GetCurTaskFinishLv() > 0 then
        return ACTIVITY_HINT_STATUS_ENUM.AT_Get
    end
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
    lister["EnterScene"] = this.OnEnterScene
    lister["ExitScene"] = this.OnExitScene

    lister["model_task_change_msg"] = this.model_task_change_msg
    lister["refresh_gun"] = this.on_refresh_gun
    lister["fishing_ready_finish"] = this.on_fishing_ready_finish
    lister["ui_byhall_select_msg"] = this.on_ui_byhall_select_msg
end

function M.Init()
    M.Exit()

    this = BY3DKPSHBManager
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
    this.UIConfig.game_task_map = {}
    this.UIConfig.task_award_map = {}

    for k,v in ipairs(config.config) do
        this.UIConfig.task_award_map[v.task_ids] = v.hb
        this.UIConfig.game_task_map[v.game_id] = v

        local hb_lv = {}
        local hb_show = v.hb_show
        local s1 = StringHelper.Split(hb_show, "#")
        for k1,v1 in ipairs(s1) do
            hb_lv[k1] = {}
            local s2 = StringHelper.Split(v1, ";")
            for k2,v2 in ipairs(s2) do
                hb_lv[k1][k2] = tonumber(v2)
            end
        end
        this.UIConfig.game_task_map[v.game_id].hb_lv = hb_lv
    end
end

function M.OnLoginResponse(result)
    if result == 0 then
        -- 数据初始化
    end
end
function M.OnReConnecteServerSucceed()
end

function M.OnEnterScene()
    if MainModel.myLocation == "game_Hall" then
        -- by3d_ksshb_hallprefab.Create() -- 去掉哦
    end
    if MainModel.myLocation == "game_Fishing" then
        this.m_data.is_one_enter = true
    end
end

function M.OnExitScene()
    byhall_rect = {}
    byhall_index = nil
end
function M.OnEnterScene()
    if not M.IsActive() then
        return
    end
    if MainModel.myLocation == "game_Hall" then
        by3d_ksshb_hallprefab.Create()
    end
    if MainModel.myLocation == "game_Fishing" then
        this.m_data.is_one_enter = true
    end

    if MainModel.myLocation == "game_FishingHall" then
        local old_obj = GameObject.Find("Canvas/LayerLv1/kpshb_byhall_hintobj")
        if IsEquals(old_obj) then
            destroy(old_obj)
        end
        byhall_rect = {}
        local parent = GameObject.Find("Canvas/LayerLv1").transform
        local obj = newObject("kpshb_byhall_hintobj", parent)
        LuaHelper.GeneratingVar(obj.transform, byhall_rect)

        for k=1,3 do
            byhall_rect["rect" .. k].gameObject:SetActive(true)
        end
        M.on_ui_byhall_select_msg(byhall_index)
    end
end

local function set_ui(obj, b, index)
    local img1 = obj.transform:Find("byxrhb_hongbao/qipao/qipao"):GetComponent("Image")
    local img2 = obj.transform:Find("byxrhb_hongbao/qipao/Image1"):GetComponent("Image")
    local img3 = obj.transform:Find("byxrhb_hongbao/qipao/hongbao"):GetComponent("Image")
    local txt1 = obj.transform:Find("byxrhb_hongbao/qipao/hongbao/Text"):GetComponent("Text")

    local cfg = M.GetConfigByGameID(index)
    if cfg then
        txt1.text = StringHelper.ToCash(cfg.show_hb/100)
    else
        txt1.text = "--"
    end

    local c = 1
    if b then
        c = 1
    else
        c = 0.7
    end
    img1.color = Color.New(c, c, c, 1)
    img2.color = Color.New(c, c, c, 1)
    img3.color = Color.New(c, c, c, 1)
end
function M.on_ui_byhall_select_msg(i)
    if not i then
        return
    end
    byhall_index = i
    print("<color=red>EEE on_ui_byhall_select_msg</color>")
    if byhall_rect then
        for k = 1, 3 do
            local key = "rect" .. k
            if byhall_rect[key] and IsEquals(byhall_rect[key]) then
                if i == k then
                    byhall_rect[key].transform.localScale = Vector3.one
                    set_ui(byhall_rect[key], true, k)
                else
                    byhall_rect[key].transform.localScale = Vector3.New(0.8, 0.8, 0.8)
                    set_ui(byhall_rect[key], false, k)
                end
            end
        end
    end
end

-- 任务改变
function M.model_task_change_msg(data)
   if M.IsCareTaskID(data.id) then
        -- 阶段改变点
        if data.now_lv ~= this.m_data.crr_level then
            this.m_data.crr_level = data.now_lv
            Event.Brocast("crr_level_state_change_msg")
            Event.Brocast("global_hint_state_change_msg", { gotoui = M.key })
        end
        Event.Brocast("kpshb_model_task_change_msg")
   end
end

function M.on_fishing_ready_finish()
    if M.IsGameingAndExistTask() then
        local task = GameTaskModel.GetTaskDataByID( M.GetCurrTaskID() )
        if not task then
            return
        end
        this.m_data.crr_level = task.now_lv

        local user = FishingModel.GetPlayerData()
        local gun_config = FishingModel.GetGunCfg(user.index)
        local g_data = {seat_num = FishingModel.GetPlayerSeat(), gun_rate = gun_config.gun_rate}
        this.m_data.g_data = g_data

        Event.Brocast("ui_button_state_change_msg")
    end
    if this.m_data.is_one_enter and M.IsGameingAndExistTask() and MainModel.UserInfo.ui_config_id == 2 then
        if PlayerPrefs.GetInt("by3dkp"..MainModel.UserInfo.user_id, 0) + 1800 < os.time() then
            KPSHBSMPrefabPanel.Create()
            PlayerPrefs.SetInt("by3dkp"..MainModel.UserInfo.user_id, os.time())
        end        
    end
    this.m_data.is_one_enter = false
end

--判断是否是自己关心的任务
function M.IsCareTaskID(id)
    if this.UIConfig.task_award_map[id] then
        return true 
    end
end
-- 是否在游戏并且当前场次存在任务
function M.IsGameingAndExistTask()
    if MainModel.myLocation == "game_Fishing" and FishingModel and FishingModel.data and this.UIConfig.game_task_map[FishingModel.game_id] then
        return true
    end
end

function M.GetTaskID(game_id)
    return this.UIConfig.game_task_map[ game_id ].task_ids
end
function M.GetCurrTaskID()
    if M.IsGameingAndExistTask() then
        return M.GetTaskID(FishingModel.game_id)
    end  
end

function M.GetTaskDataByID(task_ids)
    return GameTaskModel.GetTaskDataByID( task_ids )
end

function M.QuiteCreate()
    if M.IsActive() and M.IsGameingAndExistTask() then
        KPSHBTCPanel.Create()
    else 
       FishingLogic.quit_game()
   end   
end

function M.on_refresh_gun(g_data)
    if g_data.seat_num == FishingModel.GetPlayerSeat() then
        this.m_data.g_data = g_data
        Event.Brocast("by3d_kpshb_refresh_gun")
    end
end

-- 
function M.GetConfigByGameID(game_id)
    return this.UIConfig.game_task_map[ game_id ]
end
-- 当前任务所在的阶段(等级)
function M.GetCurTaskLv()
    return this.m_data.crr_level
end
-- 当前任务完成的阶段(等级)
function M.GetCurTaskFinishLv()
    local wc_lv
    local lv = M.GetCurTaskLv()
    if not lv then
        return 0
    end
    if lv == 1 then
        wc_lv = 0
    elseif lv == 2 then
        wc_lv = 1
    else
        local task = GameTaskModel.GetTaskDataByID( M.GetCurrTaskID() )
        if task.now_process >= task.need_process then
            wc_lv = 3
        else
            wc_lv = 2
        end
    end
    return wc_lv
end

    
-- 
function M.GetTaskMaxNumByLv(lv)
    local cfg = M.GetConfigByGameID(FishingModel.game_id)
    return cfg.hb[#cfg.hb]
end
function M.GetGunData()
    return this.m_data.g_data
end
-- 是否可以抽奖
function M.IsCanGetAward()
    if this.m_data.crr_level and this.m_data.crr_level > 1 then
        return true
    end
end
-- 获取任务某阶段的剩余炮数
function M.GetGunRateSurNum(i)
    local cfg = M.GetConfigByGameID(FishingModel.game_id)
    local jd = cfg.jd[i] or 0
    local num
    local task_data = GameTaskModel.GetTaskDataByID(M.GetCurrTaskID())
    if this.m_data.g_data and this.m_data.g_data.gun_rate and task_data then
        local re = basefunc.parse_activity_data(task_data.other_data_str)
        if tonumber(re.is_first_game) == 1 and task_data.now_lv == 1 and FishingModel.game_id == 1 then   
            num = math.ceil((jd - task_data.now_process) / (this.m_data.g_data.gun_rate*100))
            return  num
        else 
            num = math.ceil((jd - task_data.now_process) / this.m_data.g_data.gun_rate)
            return num
        end
    end    
end

function M.GetHBRateConfigByIDIndex(game_id, i)
    return this.UIConfig.game_task_map[game_id].hb_lv[i]
end

function M.GetFishCoinAndJingBi()
    if MainModel.UserInfo.jing_bi and MainModel.UserInfo.fish_coin then
        return MainModel.UserInfo.jing_bi + MainModel.UserInfo.fish_coin
    end
    return MainModel.UserInfo.jing_bi
end

-- 领取的红包券是否达到上限
function M.IsRedGetReachMax( game_id )
    local task = M.GetTaskDataByID( M.GetTaskID(game_id) )
    if task and task.other_data_str then
        local re = basefunc.parse_activity_data(task.other_data_str)
        dump(re, "<color=red>other_data_str  IsRedGetReachMax </color>")
        if re.can_award_total and re.now_award and tonumber(re.can_award_total) <= tonumber(re.now_award) then
            return true
        end
    end
end

-- 推荐前往场次逻辑 引导玩家到高级场
function M.GuidePlayerGoGJC(is_havd)
    if FishingModel.data and FishingModel.data.is_close_goto then
        if is_havd then
            LittleTips.Create("积分赛中不可前往其他场景，请先完成比赛！")
        end
        return
    end
    -- 红包达到上限
    if M.IsRedGetReachMax(FishingModel.game_id) then
        local pre = HintPanel.Create(2, "本场次今日开炮获得福卡已达到上限，前往高倍场<color=#EC4B13>继续赚更多福卡吧！</color>", function ()
            local jb = M.GetFishCoinAndJingBi()
            if jb < 100000 then
                local pre1 = HintPanel.Create(2, "金币不足啦！<color=#EC4B13>赶紧前往商城补充吧！</color>", function ()
                    Event.Brocast("show_gift_panel")
                end, function ()
                    -- 点关闭显示上一个界面(达到上限的提示)
                    M.GuidePlayerGoGJC()
                end)
                pre1:SetButtonText(nil, "前 往")
            else
                M.GotoGJC(true)
            end
        end)
        pre:SetButtonText(nil, "赚更多福卡")
    else
        M.GotoGJC()
    end
end

function M.GotoGJC(is_zj_goto)
    -- 推荐高级场
    local id = FishingModel.GetCanEnterID()

    -- 特殊逻辑 (策划：身上金额不足以去3、4、5号场时，点击前往按钮后固定前往3号场)
    if is_zj_goto and id <= FishingModel.game_id then
        id = 3
    end
    
    dump(id, "<color=red>EEEEEE GotoGJC id</color>")
    if id > FishingModel.game_id then
        local user = FishingModel.GetPlayerData()
        user.is_auto = false
        Event.Brocast("set_gun_auto_state", { seat_num=user.base.seat_num })
        if is_zj_goto then
            FishingModel.GotoFishingByID(id)
        else
            local cfg = GameFishing3DManager.GetGameCfg(id)
            local cc = BY3DKPSHBManager.GetConfigByGameID(id)
            local pre = HintPanel.Create(2, "您可以进入" .. cfg.name .. "进行游戏哦!\n爆率更高超爽体验开炮最高可获得<color=#FF0000>" .. cc.show_hb .. "</color>福卡!", function ()
                FishingModel.GotoFishingByID(id)
            end)
            pre:SetButtonText(nil, "立即前往")
        end
    end
end
