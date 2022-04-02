-- 创建时间:2018-07-09

-- 动画管理 Sequence
DOTweenManager = {}

local autoSequenceKey = 1
local AutoIndexMax = 1000000000

-- 在退出场景或者刷新游戏时Kill
local TweenMapExitKill = {}
-- 在游戏暂停时Kill
local TweenMapStopKill = {}
-- 在游戏界面退出Kill
local TweenMapLayerKill = {}

local autoTweenKey = 1


-- 清除所有的动画 (方法保留)
local function CloseAllSequence ()
    autoSequenceKey = 1
end

function DOTweenManager.Init()
    TweenMapExitKill = {}
    TweenMapStopKill = {}
    TweenMapLayerKill = {}
    autoTweenKey = 1
    autoSequenceKey = 1
    
    -- Sequence 的 HashCode
    DOTweenManager.HashCodeMap = {}
    DOTweenManager.total_create_count = 0
    DOTweenManager.total_error_count = 0
end


local function GetKeyToTween (key)
    if key then
        if TweenMapStopKill[key] then
            return TweenMapStopKill[key]
        end
        if TweenMapExitKill[key] then
            return TweenMapExitKill[key]
        end
        for k,v in pairs(TweenMapLayerKill) do
            if v[key] then
                return v[key]
            end
        end
    end
    return nil
end
local function AddTweenToExit (tween)
    local key = "AutoTweenKey_" .. autoTweenKey
    autoTweenKey = autoTweenKey + 1
    if autoTweenKey > AutoIndexMax then
        autoTweenKey = 1
    end
    TweenMapExitKill[key] = tween
    return key
end

local function AddTweenToStop (tween)
    local key = "AutoTweenKey_" .. autoTweenKey
    autoTweenKey = autoTweenKey + 1
    if autoTweenKey > AutoIndexMax then
        autoTweenKey = 1
    end
    TweenMapStopKill[key] = tween
    return key
end

local function AddTweenToLayer (tween, groupKey)
    local key = "AutoTweenKey_" .. autoTweenKey
    autoTweenKey = autoTweenKey + 1
    if autoTweenKey > AutoIndexMax then
        autoTweenKey = 1
    end
    if not TweenMapLayerKill[groupKey] then
        TweenMapLayerKill[groupKey] = {}
    end
    TweenMapLayerKill[groupKey][key] = tween
    return key
end

local function RemoveExitTween(key)
    if not key then
        TweenMapExitKill = {}
        return
    end
    TweenMapExitKill[key] = nil
end
local function RemoveStopTween(key)
    if not key then
        TweenMapStopKill = {}
        return
    end
    TweenMapStopKill[key] = nil
end
local function RemoveLayerTween(key)
    if not key then
        TweenMapLayerKill = {}
        return
    end
    for k,v in pairs(TweenMapLayerKill) do
        if v[key] then
            TweenMapLayerKill[k][key] = nil
            break
        end
    end
end

--- add by wss
local function KillAndRemoveTween(key)
    local tween = GetKeyToTween (key)
    if tween then
        tween:Kill()
    end
    RemoveExitTween(key)
    RemoveStopTween(key)
    RemoveLayerTween(key)
end

local function KillAllStopTween ()
    print("<color=red>KillAllStopTween</color>")
    if TweenMapStopKill then
        local list = {}
        for k,v in pairs(TweenMapStopKill) do
            list[#list + 1] = v
        end
        for k,v in ipairs(list) do
            v:Kill()
        end
    end
    TweenMapStopKill = {}
end
local function KillAllExitTween ()
    print("<color=red>KillAllExitTween</color>")
    if TweenMapExitKill then
        local list = {}
        for k,v in pairs(TweenMapExitKill) do
            list[#list + 1] = v
        end
        for k,v in ipairs(list) do
            v:Kill()
        end
    end
    TweenMapExitKill = {}
end

local function KillLayerKeyTween (groupKey)
    if TweenMapLayerKill then
        local list = {}
        if TweenMapLayerKill[groupKey] then
            for k1,v1 in pairs(TweenMapLayerKill[groupKey]) do
                list[#list + 1] = v1
            end
        end
        for k,v in ipairs(list) do
            v:Kill()
        end
        TweenMapLayerKill[groupKey] = nil
    end    
end

local function KillAllLayerTween ()
    print("<color=red>KillAllLayerTween</color>")
    if TweenMapLayerKill then
        local list = {}
        for k,v in pairs(TweenMapLayerKill) do
            for k1,v1 in pairs(v) do
                list[#list + 1] = v1
            end
        end
        for k,v in ipairs(list) do
            v:Kill()
        end
    end
    TweenMapLayerKill = {}
end


DOTweenManager.CloseAllSequence = CloseAllSequence
DOTweenManager.GetKeyToTween = GetKeyToTween
DOTweenManager.AddTweenToExit = AddTweenToExit
DOTweenManager.AddTweenToStop = AddTweenToStop
DOTweenManager.AddTweenToLayer = AddTweenToLayer
DOTweenManager.RemoveExitTween = RemoveExitTween
DOTweenManager.RemoveStopTween = RemoveStopTween
DOTweenManager.RemoveLayerTween = RemoveLayerTween
DOTweenManager.KillAllStopTween = KillAllStopTween
DOTweenManager.KillAllExitTween = KillAllExitTween
DOTweenManager.KillAllLayerTween = KillAllLayerTween
DOTweenManager.KillLayerKeyTween = KillLayerKeyTween


DOTweenManager.KillAndRemoveTween = KillAndRemoveTween

-- 二级弹出界面表现
local function OpenPopupUIAnim (tran, call)
    if GuideLogic and GuideLogic.IsHaveGuide() then
       if call then
            call()
        end
        return 
    end
    if IsEquals(tran) then
        tran.localScale = Vector3.New(0.4, 0.4, 0.4)
        local seq = DoTweenSequence.Create()
        seq:Append(tran:DOScale(Vector3.New(1.2, 1.2, 1.2), 0.2))
        seq:Append(tran:DOScale(Vector3.New(0.9, 0.9, 0.9), 0.1))
        seq:Append(tran:DOScale(Vector3.New(1, 1, 1), 0.05))
        seq:OnKill(function ()
            if IsEquals(tran) then
                tran.localScale = Vector3.New(1, 1, 1)
                if call then
                    call()
                    call = nil
                end
            end
        end)
        seq:OnForceKill(function ()
            if IsEquals(tran) then
                tran.localScale = Vector3.New(1, 1, 1)
                if call then
                    call()
                    call = nil
                end
            end
        end)
    end
end
-- 结算界面弹出表现
local function OpenClearUIAnim (tran, call)
    if GuideLogic and GuideLogic.IsHaveGuide() then
       if call then
            call()
            call = nil
        end
        return 
    end
    if IsEquals(tran) then
        tran.localScale = Vector3.New(0.2, 0.2, 0.2)
        local seq = DoTweenSequence.Create()
        seq:Append(tran:DOScale(Vector3.New(1, 1, 1), 0.2))
        seq:OnKill(function ()
            if IsEquals(tran) then
                tran.localScale = Vector3.New(1, 1, 1)
            end
            if call then
                call()
                call = nil
            end
        end)
        seq:OnForceKill(function ()
            if IsEquals(tran) then
                tran.localScale = Vector3.New(1, 1, 1)
            end
            if call then
                call()
                call = nil
            end
        end)
    end
end

DOTweenManager.OpenPopupUIAnim = OpenPopupUIAnim
DOTweenManager.OpenClearUIAnim = OpenClearUIAnim


function DOTweenManager.IsHaveHashCode(code)
    if DOTweenManager.HashCodeMap[code] then
        return true
    else
        return false
    end
end
function DOTweenManager.AddSequenceHashCode (code)
    DOTweenManager.HashCodeMap[code] = 1
end
function DOTweenManager.DelSequenceHashCode (code)
    DOTweenManager.HashCodeMap[code] = nil
end
