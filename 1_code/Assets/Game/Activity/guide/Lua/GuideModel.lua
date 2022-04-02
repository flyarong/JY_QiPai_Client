-- 创建时间:2018-07-23

GuideModel = {}

local this
local m_data
local lister

GuideModel.trigger_pos = nil
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
    GuideModel.data={}
    m_data = GuideModel.data
end

function GuideModel.Init()
    --玩棋牌的新手引导默认完成新手引导 9.8日玩棋牌修改
    -- local _permission_key = "drt_close_xsyd"
    -- if _permission_key then
    --     local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key=_permission_key, is_on_hint = true}, "CheckCondition")
    --     dump({a,b},"<color=white>玩棋牌的新手引导默认完成新手引导 9.8日玩棋牌修改</color>")
    --     if a and not b then

    --     else
    --         MainModel.UserInfo.xsyd_status = 1 
    --     end
    -- end
    if not GameGlobalOnOff.IsOpenGuide then
        return
    end
    this = GuideModel
    InitMatchData()
    MakeLister()
    AddLister()
    this.LoadGuide()
    --this.CompareGuideLocalAndServer()
    m_data.currGuideId = this.GetRunGuideID()
    m_data.currGuideStep = 1
    this.SpecialHandleInit()
    dump(m_data.GuideIDs,"<color=white>CCCCCCCCCCC3333333CCCCCCCCCCC1111</color>")
    return this
end
function GuideModel.Exit()
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
    local path = getGuidePath() .. "/guide.txt"
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
    print("<color=red>保存新手引导到本地</color>")
    print(idstr)
    File.WriteAllText(descPath, idstr)
end
-- 加载本地引导进度
function GuideModel.LoadGuide()
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

-- 同步本地与服务器引导步骤
function GuideModel.CompareGuideLocalAndServer()
    local map = {}
    for k,v in ipairs(GuideConfig) do
        local b = GuideModel.CheckGuideFinish(k)
        if b then
            map[k] = 1
        end
    end
    for k,v in ipairs(m_data.GuideIDs) do
        map[v] = 1
    end
    -- 新手引导未完成
    if MainModel.UserInfo.xsyd_status == 0 and not MainModel.Location then
        map[2] = nil
    end

    m_data.GuideIDs = {}
    for k,v in pairs(map) do
        m_data.GuideIDs[#m_data.GuideIDs + 1] = tonumber(k)
    end
    SaveGuide()
end

function GuideModel.SpecialHandleInit()
    --本地已完成但是服务器未同步
    if m_data.currGuideId == -1 and MainModel.UserInfo.xsyd_status == 0 then
        this.GuideAllFinish()
    end

    --服务器已完成但是本地未同步
    if MainModel.UserInfo.xsyd_status ~= 0 and m_data.currGuideId ~= -1 then
        this.SetGuideToLocal()
    end

    --特殊处理:有一些老号的xsyd为2
    if MainModel.UserInfo.xsyd_status == 2 then
        MainModel.UserInfo.xsyd_status = 1
    end

    
end

-- 检测时候的特殊情况
function GuideModel.SpecialHandleCheck()
    if gameMgr:getMarketPlatform() == "normal" then

        -- 报名会失败
        if m_data.currGuideId == 2 then
            if (MainModel.myLocation ~= "game_DdzFree" and MainModel.myLocation ~= "game_Mj3D") and (MainModel.UserInfo.jing_bi > 30000 or MainModel.UserInfo.jing_bi < 3000) then
                print("<color=red><size=20>报名会失败 跳过所有引导</size></color>")
                return true
            end
        end

        if m_data.currGuideId == 3 then
            local isHaveFunc,result =  GameButtonManager.RunFun({gotoui = "act_068_xrhl"},"CheckIsShow") --新人好礼未开启
            if isHaveFunc and not result then
                dump("<color=red>新人好礼未开启</color>")
                return true
            end

            if m_data.currGuideStep <= 2 then
                --新人好礼已经领取
                local task_data = GameTaskModel.GetTaskDataByID(100035)
                dump(task_data, "<color=white>AAAAAAAAAAAAAAAAAAAAAAAAAA</color>")
                if task_data and task_data.award_status == 2 then
                    dump("<color=red>新人好礼已领取</color>")
                    return true
                end
            end
        end

        if m_data.currGuideId == 4 then
            local isHaveFunc,result =  GameButtonManager.RunFun({gotoui = "act_042_xshb"},"CheckIsShow") --限时红包未开启
            if isHaveFunc and not result then
                dump("<color=red>限时红包未开启</color>")
                return true
            end
            local task_data = GameTaskModel.GetTaskDataByID(21578) --限时红包已解锁

            if not task_data then
                return true
            end
            if task_data.other_data_str and basefunc.parse_activity_data(task_data.other_data_str).is_unlock == 1 then
                dump(task_data,"<color=red>限时红包已解锁</color>")
                return true
            end
        end
    end
    return false
end

-- 第一个引导的ID
local OneGuideId = 1
function GuideModel.GetRunGuideID()
    local id = OneGuideId
    local map = {}
    for k,v in ipairs(m_data.GuideIDs) do
        map[v] = 1
    end
    for k,v in pairs(map) do
        if GuideConfig[k] then
            local ii = GuideConfig[k].next
            if not map[ii] then
                return ii
            end
        end
    end
    return id
end

function GuideModel.Trigger( cfPos)
    if GuideConfig[GuideModel.data.currGuideId] and GuideModel.data.currGuideStep == 1 then
        for k,v in ipairs(GuideConfig[GuideModel.data.currGuideId].stepList) do
            if v.cfPos == cfPos then
                GuideModel.trigger_pos = k
                return true
            end
        end
    end
end

function GuideModel.GetStepList(id)
    local cfg = GuideConfig[id]
    if cfg and cfg.stepList and cfg.stepList[GuideModel.trigger_pos] and cfg.stepList[GuideModel.trigger_pos].step then
        return cfg.stepList[GuideModel.trigger_pos].step
    end
end

function GuideModel.GetStepConfig(id, stepIndex)
    local cfg = GuideConfig[id]
    if cfg and cfg.stepList and cfg.stepList[GuideModel.trigger_pos] and cfg.stepList[GuideModel.trigger_pos].step then
        local index = cfg.stepList[GuideModel.trigger_pos].step[GuideModel.data.currGuideStep]
        return GuideStepConfig[index]
    end
end

-- 引导完成或点击跳过
function GuideModel.GuideFinishOrSkip()
    m_data.GuideIDs[#m_data.GuideIDs + 1] = m_data.currGuideId
    m_data.currGuideId = GuideConfig[m_data.currGuideId].next
    if m_data.currGuideId == -1 then
        GuideModel.GuideAllFinish()
    end 
    m_data.currGuideStep = 1
    SaveGuide()
end

function GuideModel.StepFinish()
    local cfg = GuideModel.GetStepConfig(m_data.currGuideId, m_data.currGuideStep)
    m_data.currGuideStep = m_data.currGuideStep + 1
    print("<color=red>点击完成，下一个m_data.currGuideStep = " .. m_data.currGuideStep .. "</color>")
    local stepList = GuideModel.GetStepList(m_data.currGuideId)
    if m_data.currGuideId > 0 and GuideConfig[m_data.currGuideId] and m_data.currGuideStep > #stepList then
        GuideModel.GuideFinishOrSkip()
    elseif cfg and cfg.isSave then --提前保存数据（非大步骤的最后一个小步）
        m_data.GuideIDs[#m_data.GuideIDs + 1] = m_data.currGuideId
        SaveGuide()
        m_data.GuideIDs[#m_data.GuideIDs] = nil
    end
end

function GuideModel.GuideAllFinish()
    --dump(debug.traceback())
    dump("<color=white>1111111111111111111111111111111111</color>")
    MainModel.UserInfo.xsyd_status = 1
    GuideModel.SetGuideToServer(function ()
        Event.Brocast("newplayer_guide_finish")
    end)
end

function GuideModel.CheckGuideFinish(id)
    if MainModel.UserInfo.xsyd_status == 0 then
        return false
    else
        return true
    end  
end
-- 条件是否满足
function GuideModel.CheckCondition(id, stepIndex)
    -- 登录到大厅提示在某某游戏中，屏蔽引导
    if MainModel.myLocation == "game_Hall" and MainModel.Location then
        return false
    end
    dump(MainModel.UserInfo.xsyd_status,"<color=white>MainModel.UserInfo.xsyd_status</color>")
    dump(m_data.GuideIDs,"<color=white>m_data.GuideIDs</color>")
    if MainModel.UserInfo.xsyd_status == 0 then
        if m_data.GuideIDs[id] then
            return false
        else
            return true
        end
    end
end
-- 条件是否满足
function GuideModel.IsMeetCondition()

    dump(this.SpecialHandleCheck() , "<color=white>新手引导:是否满足特殊判断条件</color>")
    dump(m_data.currGuideId, "<color=white>m_data.currGuideId</color>")
    dump( m_data.currGuideStep, "<color=white>m_data.currGuideStep</color>")
    if this.SpecialHandleCheck() then
        this.GuideAllFinish()
        return false
    end

    dump(GuideModel.CheckCondition(m_data.currGuideId, m_data.currGuideStep) , "<color=white>新手引导:是否满足普通判断条件</color>")

    return GuideModel.CheckCondition(m_data.currGuideId, m_data.currGuideStep)
end

function GuideModel.SetGuideToServer(_call)
    print("<color=red>保存新手引导到服务器</color>")
    Network.SendRequest("set_xsyd_status", {status = 1, xsyd_type = "xsyd"},function (data)
        dump(data,"<color=yellow>+++++++++set_xsyd_status++++++++</color>")
        if data and data.result == 0 then
            if MainModel.UserInfo.xsyd_status == 0 then
                MainModel.UserInfo.xsyd_status = 1
                this.SetGuideToLocal()
            end
            if _call then
                _call()
            end
        end
    end)
end


function GuideModel.SetGuideToLocal()
    m_data.currGuideId = -1
    local map = {}
    for i = 1 ,#GuideConfig do
        m_data.GuideIDs[i] = i
    end
    SaveGuide()
end