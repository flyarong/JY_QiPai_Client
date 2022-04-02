-- 创建时间:2018-07-23
require "Game.normal_comfishing_common.Lua.FishingGuideModel"
require "Game.normal_comfishing_common.Lua.FishingGuidePanel"
require "Game.normal_comfishing_common.Lua.FishingGuideConfig"

require "Game.normal_comfishing_common.Lua.FishingGuideStep1Panel"
require "Game.normal_comfishing_common.Lua.FishingGuideStep2Panel"

FishingGuideLogic = {}
local M = FishingGuideLogic
local this -- 单例
local MModel

local lister
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
    lister["EnterScene"] = this.OnEnterScene
    lister["ExitScene"] = this.OnExitScene
    lister["ReConnecteServerSucceed"] = this.OnReConnecteServerSucceed
    lister["OnLoginResponse"] = this.OnLoginResponse
    lister["will_kick_reason"] = this.on_will_kick_reason
    lister["DisconnectServerConnect"] = this.on_network_error_msg

    lister["fishing_guide_step"] = this.fishing_guide_step

end

function M.Init()
    if not GameGlobalOnOff.IsOpenFishingGuide then
        return
    end
    
    --玩棋牌的新手引导默认完成新手引导 9.8日玩棋牌修改
    local _permission_key = "drt_close_xsyd"
    if _permission_key then
        local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key=_permission_key, is_on_hint = true}, "CheckCondition")
        if a and not b then

        else
            return
        end
    end

    M.Exit()
    this = M
    MakeLister()
    AddLister()

    if MModel then
        FishingGuideModel.Exit()
    end
    MModel = FishingGuideModel.Init()
    return this
end
function M.Exit()
	if this then
		FishingGuideModel.Exit()
        FishingGuidePanel.Exit()
		MModel = nil
		RemoveLister()
		this = nil
	end
end

function M.on_network_error_msg(proto_name, data)
    FishingGuidePanel.Exit()
end

--断线重连后登录成功
function M.OnReConnecteServerSucceed(result)
    coroutine.start(function ( )
        Yield(0)
        dump(MModel, "<color=green>断线重连后登录成功</color>")
        if MModel then
            FishingGuideModel.Exit()
        end
        MModel = FishingGuideModel.Init()
        M.RunGuide()
    end)
end

function M.on_will_kick_reason(proto_name, data)
    if data.reason == "relogin" then
        -- 挤号关闭引导界面
        FishingGuidePanel.Exit()
    end
end

--正常登录成功
function M.OnLoginResponse(result)
    if result ~= 0 then return end
    coroutine.start(function ( )
        Yield(0)
        print("<color=red>M:正常登录成功</color>")
        if result==0 then
            if MModel then
                FishingGuideModel.Exit()
            end
            MModel = FishingGuideModel.Init()
        else
        end    
    end)
end

-- 进入场景
function M.OnEnterScene()
end
-- 退出场景
function M.OnExitScene()
end

-- 存在新手引导
function M.IsExistGuide(uiname)
    if GameGlobalOnOff.IsOpenFishingGuide and MModel.data.currGuideId > 0 then
        if FishingGuideModel.IsMeetCondition() then
            local vv = FishingGuideModel.GetStepConfig(MModel.data.currGuideId, MModel.data.currGuideStep)
            if vv.uiName == uiname then
                return true
            else
                local stepList = FishingGuideModel.GetStepList(MModel.data.currGuideId)
                for i = 1, #stepList do
                    if GuideStepConfig[stepList[i]].uiName == uiname then
                        return true
                    end
                end
            end
        end
    end
end

function M.CheckRunGuide(uiname)
    if GameGlobalOnOff.IsOpenFishingGuide and MModel.data.currGuideId > 0 then
        if FishingGuideModel.IsMeetCondition() then
            local vv = FishingGuideModel.GetStepConfig(MModel.data.currGuideId, MModel.data.currGuideStep)
            if vv.uiName == uiname then
                M.RunGuide()
            else
                local stepList = FishingGuideModel.GetStepList(MModel.data.currGuideId)
                for i = 1, #stepList do
                    if GuideStepConfig[stepList[i]].uiName == uiname then
                        MModel.data.currGuideStep = i
                        M.RunGuide()
                        break
                    end
                end
                print("<color=red>新手引导 id = " .. MModel.data.currGuideId .. "</color>")
                print("<color=red>新手引导 uiname = " .. uiname .. "</color>")
            end
        else
            print("<color=red>新手引导 uiname = " .. uiname .. "</color>")
        end
    else
        print("<color=red>新手引导 uiname = " .. uiname .. "</color>")
    end
end

-- 执行引导(判断是否有引导，引导的步骤) isAuto-一个引导的连续执行
function M.RunGuide(isAuto)
	if GameGlobalOnOff.IsOpenFishingGuide then
        if MModel.data.currGuideId > 0 then
            if FishingGuideModel.IsMeetCondition() then
                local vv = FishingGuideModel.GetStepConfig(MModel.data.currGuideId, MModel.data.currGuideStep)
                if not isAuto or (isAuto and vv.auto) then
                    print("<color=red>新手引导 guideID = " .. MModel.data.currGuideId .. " step = " .. MModel.data.currGuideStep .. "</color>")
                    FishingGuidePanel.Show(MModel.data.currGuideId, MModel.data.currGuideStep)
                end
            else
                print("<color=red>条件不满足 status=" .. MainModel.UserInfo.xsyd_status .. "</color>")
            end
        end
    else
        print("<color=red>新手引导开关 = 关闭</color>")
	end
end
function M.StepFinish()
    FishingGuideModel.StepFinish()
    M.RunGuide(true)
end

function M.GuideSkip()
    FishingGuideModel.GuideFinishOrSkip()
    M.RunGuide(true)
end

-- 是否是比赛场的特定引导
function M.IsMatchNewButton()
    if GameGlobalOnOff.IsOpenFishingGuide and FishingGuideModel.IsMeetCondition() and MModel.data.currGuideId == 1 and MModel.data.currGuideStep == 2 then
        return true
    end
end
-- 是否是匹配场的特定引导
function M.IsFreeBattle()
    if GameGlobalOnOff.IsOpenFishingGuide and FishingGuideModel.IsMeetCondition() and MModel.data.currGuideId == 2 and MModel.data.currGuideStep == 1 then
        return true
    end
end

-- 是否有新手引导
function M.IsHaveGuide()
    if GameGlobalOnOff.IsOpenFishingGuide and FishingGuideModel.IsMeetCondition() then
        return true
    end
end

-- 进入场景
function M.fishing_guide_step(data)
    if not M.IsHaveGuide() then
        if data and data.not_call and type(data.not_call) == "functon" then
            data.not_call()
        end
        Event.Brocast("fishing_guide_finish")
    else
        dump(MModel.data.currGuideId , "<color=yellow>新手引导》》》》》》》》》》》》</color>")
        if MModel.data.currGuideId == 1 then
            FishingGuideStep1Panel.Create()
        elseif MModel.data.currGuideId == 2 then
            FishingGuideStep2Panel.Create()
        end
    end
end