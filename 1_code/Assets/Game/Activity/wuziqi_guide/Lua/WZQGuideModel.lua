-- 创建时间:2020-11-15

local basefunc = require "Game/Common/basefunc"
WZQGuideModel = {}

local M = WZQGuideModel

local this
local m_data


---------------引导本地数据读存---------------

local function GetGuideKeyAdrWZQ()
    return "WZQ_GUIDE" .. MainModel.UserInfo.user_id
end

local function GetGuideStepKeyAdrWZQ()
    return "WZQ_GUIDE_STEP" .. MainModel.UserInfo.user_id
end

local function SetGuideKeyWZQ()
    UnityEngine.PlayerPrefs.SetInt(GetGuideKeyAdrWZQ(),m_data.cur_guide)
end

local function SetGuideStepKeyWZQ()
    UnityEngine.PlayerPrefs.SetInt(GetGuideStepKeyAdrWZQ(),m_data.cur_guide_step)
end


function M.Init()
    this = WZQGuideModel
    M.data = {}
    m_data = M.data
    M.InitGuideData_WZQ()
    return  this
end

function M.Exit()
    if this then this = nil end
end


function M.InitGuideData_WZQ()
    -- m_data.cur_guide_step = 1
    -- m_data.cur_guide = 2
    -- do return end
    m_data.cur_guide_step = UnityEngine.PlayerPrefs.GetInt(GetGuideStepKeyAdrWZQ(),1)
    m_data.cur_guide = UnityEngine.PlayerPrefs.GetInt(GetGuideKeyAdrWZQ(),1)
end

---------------Is---------------

function M.IsCanGuide()
    if MainModel.myLocation == "game_Hall" and MainModel.Location then return false end
    if m_data.cur_guide ~= -1 then return true end
    return false
end

function M.IsFinishGuide()
    m_data.next_guide = WZQGuideConfig[m_data.cur_guide].next
    if m_data.next_guide == -1 then return true end
    return false
end

function M.IsCurStepAutoNext()
    local is_auto = false
    local cfg = this.GetCurStepCfg()
    if cfg and cfg.auto and cfg.auto == true then
        is_auto = true
    end
    return is_auto
end

---------------Change---------------

function M.GuideStepNext()
    m_data.cur_guide_step = m_data.cur_guide_step + 1
    dump( m_data.cur_guide_step,"<color=red>m_data.cur_guide_step</color>")
    local step_list = this.GetCurStepList() 
    if step_list == nil then dump("Get Current StepList is Null!!!") end
    if step_list ~= nil and m_data.cur_guide_step > #step_list then  --小步骤完成
        this.GuideStepFinish()
    end
end

function M.GuideStepFinish()
    --m_data.cur_guide = m_data.cur_guide + 1

    if WZQGuideConfig[m_data.cur_guide].next == -1 then
        this.GuideFinish() --所有引导完成
    else
        m_data.cur_guide = WZQGuideConfig[m_data.cur_guide].next 
        SetGuideKeyWZQ()
        this.ReSetGuideStep()
    end
end

function M.GuideFinish()
    this.SetGuideFinsh()
end

---------------Get---------------

function M.GetCurStepList()
    local cfg = WZQGuideConfig[m_data.cur_guide]
    if cfg then return cfg.stepList end
end

function M.GetCurStepCfg()
    local step_list = M.GetCurStepList()
    local step = step_list[m_data.cur_guide_step]
    local cfg = WZQGuideStepConfig[step]
    if cfg then return cfg end
end

---------------Set---------------

--重置当前步骤
function M.ReSetGuideStep()
    m_data.cur_guide_step = 1
    SetGuideStepKeyWZQ()
end

function M.SetGuideFinsh()
    m_data.cur_guide = -1
    m_data.cur_guide_step = -1
    SetGuideKeyWZQ()
    SetGuideStepKeyWZQ()
end

function M.SetToTreeGuide()
    m_data.cur_guide = 3
end
