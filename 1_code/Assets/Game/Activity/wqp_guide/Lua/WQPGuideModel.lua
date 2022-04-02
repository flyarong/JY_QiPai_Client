-- 创建时间:2021-03-09
local basefunc = require "Game/Common/basefunc"
WQPGuideModel = {}

local this
local m_data

local function GetGuideKeyAdrWQP()
    return "WQP_GUIDE" .. MainModel.UserInfo.user_id
end

local function GetGuideStepKeyAdrWQP()
    return "WQP_GUIDE_STEP" .. MainModel.UserInfo.user_id
end

local function SetGuideKeyWQP()
    UnityEngine.PlayerPrefs.SetInt(GetGuideKeyAdrWQP(),m_data.cur_guide)
end

local function SetGuideStepKeyWQP()
    UnityEngine.PlayerPrefs.SetInt(GetGuideStepKeyAdrWQP(),m_data.cur_guide_step)
end


function WQPGuideModel.Init()
    this = WQPGuideModel
    WQPGuideModel.data = {}
    m_data = WQPGuideModel.data
    WQPGuideModel.InitGuideData_WQP()
    return  this
end

function WQPGuideModel.Exit()
    if this then this = nil end
end


function WQPGuideModel.InitGuideData_WQP()
    -- m_data.cur_guide_step = 4
    -- m_data.cur_guide = 3
    -- do return end
    --m_data.cur_guide_step = UnityEngine.PlayerPrefs.GetInt(GetGuideStepKeyAdrWQP(),1)
    m_data.cur_guide_step = 1
    m_data.cur_guide = UnityEngine.PlayerPrefs.GetInt(GetGuideKeyAdrWQP(),1)

    --特殊条件
    --当引导到第三大步的时候退出游戏，此时直接跳过所有引导
    if m_data.cur_guide == 3 then
        WQPGuideModel.SetGuideFinsh()
    end

    WQPGuideModel.SpecialHandleInit()
end

---------------Is---------------


function WQPGuideModel.SpecialHandleInit()
    if MainModel.UserInfo.xsyd_status == 1 and m_data.cur_guide ~= -1 then
        WQPGuideModel.SetGuideToLocal()
    end

    if m_data.cur_guide == -1 and MainModel.UserInfo.xsyd_status == 0 then
        WQPGuideModel.SetGuideToServer()
    end
end

function WQPGuideModel.IsCanGuide()

    if not GameGlobalOnOff.IsOpenGuide then
        return false
    end

    if MainModel.UserInfo.xsyd_status == 1 then
        return false
    end
    if MainModel.myLocation == "game_Hall" and MainModel.Location then 
        return false 
    end
    if m_data.cur_guide == -1 then
        return false
    end

    return true
end

function WQPGuideModel.IsFinishGuide()
    m_data.next_guide = WQPGuideConfig[m_data.cur_guide].next
    if m_data.next_guide == -1 then return true end
    return false
end

function WQPGuideModel.IsCurStepAutoNext()
    local is_auto = false
    local cfg = this.GetCurStepCfg()
    if cfg and cfg.auto and cfg.auto == true then
        is_auto = true
    end
    return is_auto
end

function WQPGuideModel.IsFreeBattle()
    if (MainModel.myLocation ~= "game_DdzFree" and MainModel.myLocation ~= "game_Mj3D") and (MainModel.UserInfo.jing_bi > 30000 or MainModel.UserInfo.jing_bi < 3000) then
        MainModel.UserInfo.xsyd_status = 1 
        print("<color=red><size=20>报名会失败 跳过所有引导</size></color>")
        return false
    end
    if m_data.cur_guide == 3 or m_data.cur_guide == 2 then
        return true
    end
    return false
end

function WQPGuideModel.IsGuideOver()
    if m_data.cur_guide == -1 then
        return true
    end
end

---------------Change---------------

function WQPGuideModel.GuideStepNext()
    m_data.cur_guide_step = m_data.cur_guide_step + 1
    local step_list = this.GetCurStepList() 
    if step_list == nil then dump("Get Current StepList is Null!!!") end
    if step_list ~= nil and m_data.cur_guide_step > #step_list then  --小步骤完成
        this.GuideStepFinish()
    end
end

function WQPGuideModel.GuideStepFinish()
    --m_data.cur_guide = m_data.cur_guide + 1
    if WQPGuideConfig[m_data.cur_guide].next == -1 then
        this.GuideFinish() --所有引导完成
    else
        m_data.cur_guide = WQPGuideConfig[m_data.cur_guide].next 
        SetGuideKeyWQP()
        this.ReSetGuideStep()
    end
end

function WQPGuideModel.GuideFinish()
    this.SetGuideFinsh()
end

function WQPGuideModel.GetCurGuideId()
    if this and m_data and m_data.cur_guide then
        return  m_data.cur_guide
    end
    return 0
end


function WQPGuideModel.GetCurGuideStepId()
    if this and m_data and m_data.cur_guide_step then
        return  m_data.cur_guide_step
    end
    return 0
end

function WQPGuideModel.GetCurStepList()
    local cfg = WQPGuideConfig[m_data.cur_guide]
    if cfg then return cfg.stepList end
end

function WQPGuideModel.GetCurStepCfg()
    local step_list = WQPGuideModel.GetCurStepList()
    if step_list then
        local step = step_list[m_data.cur_guide_step]
        local cfg = WQPGuideStepConfig[step]
        if cfg then return cfg end
    end
end

--重置当前步骤
function WQPGuideModel.ReSetGuideStep()
    m_data.cur_guide_step = 1
    SetGuideStepKeyWQP()
end

function WQPGuideModel.SetGuideFinsh()
    m_data.cur_guide = -1
    m_data.cur_guide_step = -1
    MainModel.UserInfo.xsyd_status = 1
    SetGuideKeyWQP()
    SetGuideStepKeyWQP()
    WQPGuideModel.SetGuideToServer(function ()
        Event.Brocast("newplayer_guide_finish")
    end)
    --Event.Brocast("newplayer_guide_finish")
end

function WQPGuideModel.IsSpecialSkip()
    -- if WQPGuideModel.IsSkipGuideYxhb() then
    --     return true
    -- end
    return false
end


--特殊条件
--当引导到第三大步的时候,3.9之前注册的用户没有新版的迎新红包,此时跳过第三步骤
function WQPGuideModel.IsSkipGuideYxhb()
    if m_data.cur_guide == 3 and not WQPGuideModel.IsYxhbView() then
        return true
    end
end

function WQPGuideModel.IsYxhbView()
    local _permission_key = "actp_own_task_p_new_player_red_bag"
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


function WQPGuideModel.IsYxhbBtnShowing()
    --dump({id= m_data.cur_guide,step = m_data.cur_guide_step},"<color=white>000000000000000000000</color>")
    if m_data.cur_guide == 3 and m_data.cur_guide_step == 2 then
        return true
    end
end

function WQPGuideModel.SetGuideToServer(_call)
    print("<color=red>保存新手引导到服务器 玩棋牌</color>")
    Network.SendRequest("set_xsyd_status", {status = 1, xsyd_type = "xsyd"},function (data)
        dump(data,"<color=yellow>+++++++++set_xsyd_status++++++++</color>")
        if data and data.result == 0 then
            if MainModel.UserInfo.xsyd_status == 0 then
                MainModel.UserInfo.xsyd_status = 1
            end
            if _call then
                _call()
            end
        end
    end)
end


function WQPGuideModel.SetGuideToLocal()
    m_data.cur_guide = -1
    m_data.cur_guide_step = -1
    SetGuideKeyWQP()
    SetGuideStepKeyWQP()
end