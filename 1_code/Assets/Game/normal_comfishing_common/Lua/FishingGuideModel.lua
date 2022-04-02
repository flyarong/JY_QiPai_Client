-- 创建时间:2018-07-23

FishingGuideModel = {}
local M = FishingGuideModel
local this
local m_data
local lister
local function AddLister()
    lister={}
    for msg,cbk in pairs(lister) do
        Event.AddListener(msg, cbk)
    end
end

local function RemoveLister()
    for msg,cbk in pairs(lister) do
        Event.RemoveListener(msg, cbk)
    end
    lister=nil
end
local function MakeLister()
    lister={}
end

-- 初始化Data
local function InitMatchData()
    M.data={}
    m_data = M.data
end

function M.Init()
    if not GameGlobalOnOff.IsOpenFishingGuide then
        return
    end
    this = M
    InitMatchData()
    MakeLister()
    AddLister()
    this.LoadGuide()

    m_data.currGuideId = this.GetRunGuideID()
    m_data.currGuideStep = 1
    return this
end
function M.Exit()
    if this then
        RemoveLister()
        lister=nil
        this=nil
    end
end

-- 获取路径
local function getGuidePath()
    local path = AppDefine.LOCAL_DATA_PATH .. "/" .. MainModel.UserInfo.user_id
    return path
end
-- 获取路径
local function getGuideDescPath()
    local path = getGuidePath() .. "/fishing_guide.txt"
    return path
end
-- 保存ID列表
local function SaveGuide()
    local descPath = getGuideDescPath()
    local idstr = ""
    for i,v in ipairs(m_data.GuideIDs) do
        idstr = idstr .. v
        if i < #m_data.GuideIDs then
            idstr = idstr .. ","
        end
    end
    print("<color=red>保存新手引导</color>")
    print(idstr)
    File.WriteAllText(descPath, idstr)
end
-- 加载本地引导进度
function M.LoadGuide()
    m_data.GuideIDs = {}
    local path = getGuidePath()
    if not Directory.Exists(path) then
        Directory.CreateDirectory(path)
    end
    local descPath = getGuideDescPath()
    if not File.Exists(descPath) then
        return
    end
    local data = File.ReadAllText(descPath)
    if not data or data == "" then
        return
    end
    local ns = StringHelper.Split(data, ",")
    for _,v in ipairs(ns) do
        m_data.GuideIDs[#m_data.GuideIDs + 1] = tonumber(v)
    end
end

-- 第一个引导的ID
local OneGuideId = 1
function M.GetRunGuideID()
    local id = OneGuideId
    local map = {}
    for k,v in ipairs(m_data.GuideIDs) do
        map[v] = 1
    end
    for k,v in pairs(map) do
        if FishingGuideConfig[k] then
            local ii = FishingGuideConfig[k].next
            if not map[ii] then
                return ii
            end
        end
    end
    return id
end

-- 同一个引导 可能有多种步骤 比如VIP引导 在有VIP和没有VIP不一样，但是他们是一个引导，只做一次
function M.GetStepList(id)
    local cfg = FishingGuideConfig[id]
    if cfg then
        if cfg.hallstepList and MainModel.myLocation == "game_Hall" then
            return cfg.hallstepList
        else
            return cfg.stepList
        end
    end
end
function M.GetStepConfig(id, stepIndex)
    local cfg = FishingGuideConfig[id]
    if cfg then
        local list = M.GetStepList(id)
        if list[stepIndex] then
            return GuideStepConfig[list[stepIndex]]
        else
            return GuideStepConfig[list[1]]
        end
    end
end

-- 引导完成或点击跳过
function M.GuideFinishOrSkip()
    m_data.GuideIDs[#m_data.GuideIDs + 1] = m_data.currGuideId
    m_data.currGuideId = FishingGuideConfig[m_data.currGuideId].next
    m_data.currGuideStep = 1
    SaveGuide()
    Event.Brocast("fishing_guide_step")
end

function M.StepFinish()
    local cfg = M.GetStepConfig(m_data.currGuideId, m_data.currGuideStep)
    if m_data.currGuideId == 5 and cfg and cfg.isSave then
        MainModel.UserInfo.xsyd_status = 1
    end
    m_data.currGuideStep = m_data.currGuideStep + 1
    print("<color=red>点击完成，下一个m_data.currGuideStep = " .. m_data.currGuideStep .. "</color>")
    local stepList = M.GetStepList(m_data.currGuideId)
    if m_data.currGuideId > 0 and FishingGuideConfig[m_data.currGuideId] and m_data.currGuideStep > #stepList then
        M.GuideFinishOrSkip()
    end
end

-- 条件是否满足
function M.CheckCondition(id, stepIndex)
    -- 登录到大厅提示在某某游戏中，屏蔽引导
    if MainModel.myLocation == "game_Hall" and MainModel.Location then
        return false
    end

    if MainModel.UserInfo.xsyd_status ~= 0 then
        return false
    else
        if id >= 1 and id <= 2 then
            if m_data and m_data.GuideIDs[id] then
                return false
            else
                return true
            end
        else
            return false
        end
    end
end
-- 条件是否满足
function M.IsMeetCondition()
    if not m_data then return end
    return M.CheckCondition(m_data.currGuideId, m_data.currGuideStep)
end
