-- 创建时间:2018-07-23
GuideLogic = {}
local this -- 单例
local guideModel

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
end

function GuideLogic.Init()
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
    GuideLogic.Exit()
    this = GuideLogic
    MakeLister()
    AddLister()
    return this
end
function GuideLogic.Exit()
	if this then
		if guideModel then
            guideModel.Exit()
        end
        GuidePanel.Exit()
		guideModel = nil
		RemoveLister()
		this = nil
	end
end

function GuideLogic.on_network_error_msg(proto_name, data)
    GuidePanel.Exit()
end

--断线重连后登录成功
function GuideLogic.OnReConnecteServerSucceed(result)
    coroutine.start(function ( )
        Yield(0)
        dump(guideModel, "<color=green>断线重连后登录成功</color>")
        if guideModel then
            guideModel.Exit()
        end
        guideModel = GuideModel.Init()
        GuideLogic.RunGuide()
    end)
end

function GuideLogic.on_will_kick_reason(proto_name, data)
    if data.reason == "relogin" then
        -- 挤号关闭引导界面
        GuidePanel.Exit()
    end
end

--正常登录成功
function GuideLogic.OnLoginResponse(result)
    if result ~= 0 then return end
    coroutine.start(function ( )
        Yield(0)
        print("<color=red>GuideLogic:正常登录成功</color>")
        if result==0 then
            if guideModel then
                guideModel.Exit()
            end
            guideModel = GuideModel.Init()
        else
        end    
    end)
end

-- 进入场景
function GuideLogic.OnEnterScene()
end
-- 退出场景
function GuideLogic.OnExitScene()
end

function GuideLogic.CheckRunGuide(uiname, call)
    coroutine.start(function() --检测延迟一帧
		Yield(0)
        -- dump({id = GuideModel.data.currGuideId , step = GuideModel.data.currGuideStep},"<color=red>----Data-------</color>")
        -- dump(uiname,"<color=red>----uiname-------</color>")
        local b = false
        if GuideModel.data and GameGlobalOnOff.IsOpenGuide and GuideModel.data.currGuideId and GuideModel.data.currGuideId > 0 then
            if GuideModel.IsMeetCondition() then
                GuideModel.Trigger(uiname)
                local vv = GuideModel.GetStepConfig(GuideModel.data.currGuideId, GuideModel.data.currGuideStep)
                if vv and vv.uiName == uiname then
                    GuideLogic.RunGuide()
                    b = true
                else
                    -- local stepList = GuideModel.GetStepList(GuideModel.data.currGuideId)
                    -- for i = 1, #stepList do
                    --     if GuideStepConfig[stepList[i]] and GuideStepConfig[stepList[i]].uiName == uiname then
                    --         GuideModel.data.currGuideStep = i
                    --         GuideLogic.RunGuide()
                    --         b = true
                    --         break
                    --     end
                    -- end
                    print("<color=red>新手引导 id = " .. GuideModel.data.currGuideId .. "</color>")
                    print("<color=red>新手引导 uiname = " .. uiname .. "</color>")
                end

            else
                print("<color=red>未满足 新手引导 uiname = " .. uiname .. "</color>")
            end
        else
            print("<color=red>新手引导 uiname = " .. uiname .. "</color>")
        end
        if not b and call then
            call()
        end
    end)
end

-- 执行引导(判断是否有引导，引导的步骤) isAuto-一个引导的连续执行
function GuideLogic.RunGuide(isAuto)
    --dump("<color=white>------RunGuide------</color>")
    local b = false
	if GameGlobalOnOff.IsOpenGuide then
        if GuideModel.data.currGuideId > 0 then
            if GuideModel.IsMeetCondition() then
                local vv = GuideModel.GetStepConfig(GuideModel.data.currGuideId, GuideModel.data.currGuideStep)               
                if not isAuto or (isAuto and vv.auto) then
                    GuideLogic.is_guide_ing = true
                    b = true
                    print("<color=red>新手引导 guideID = " .. GuideModel.data.currGuideId .. " step = " .. GuideModel.data.currGuideStep .. "</color>")
                    GuidePanel.Show(GuideModel.data.currGuideId, GuideModel.data.currGuideStep)
                end
            else
                print("<color=red>条件不满足 status=" .. MainModel.UserInfo.xsyd_status .. "</color>")
            end
        end
    else
        print("<color=red>新手引导开关 = 关闭</color>")
	end
    if not b then
        GuideLogic.is_guide_ing = false
    end
end
function GuideLogic.StepFinish()
    guideModel.StepFinish()
    GuideLogic.RunGuide(true)
end

function GuideLogic.GuideSkip()
    guideModel.GuideFinishOrSkip()
    GuideLogic.RunGuide(true)
end

function GuideLogic.GuideAllFinish()
    guideModel.GuideAllFinish()
end

-- 是否是比赛场的特定引导
function GuideLogic.IsMatchNewButton()
    if GameGlobalOnOff.IsOpenGuide and GuideModel.IsMeetCondition() and GuideModel.data.currGuideId == 1 and GuideModel.data.currGuideStep == 2 then
        return true
    end
end
-- 是否是匹配场的特定引导
function GuideLogic.IsFreeBattle()
    if GameGlobalOnOff.IsOpenGuide and GuideModel.IsMeetCondition() and (GuideModel.data.currGuideId == 2 or GuideModel.data.currGuideId == 3) then
        return true
    end
end

-- 是否有新手引导
function GuideLogic.IsHaveGuide(uiname)
    if not MainModel.UserInfo or MainModel.UserInfo.xsyd_status == 0 then
        return true
    end
    if uiname then
        local b = false
        if GuideModel.data and GameGlobalOnOff.IsOpenGuide and GuideModel.data.currGuideId and GuideModel.data.currGuideId > 0 then
            if GuideModel.IsMeetCondition() then
                local vv = GuideModel.GetStepConfig(GuideModel.data.currGuideId, GuideModel.data.currGuideStep)
                if vv and vv.uiName == uiname then
                    b = true
                else
                    -- local stepList = GuideModel.GetStepList(GuideModel.data.currGuideId)
                    -- for i = 1, #stepList do
                    --     if GuideStepConfig[stepList[i]] and GuideStepConfig[stepList[i]].uiName == uiname then
                    --         b = true
                    --         break
                    --     end
                    -- end
                end
            end
        end
        return b
    else
        return GuideLogic.is_guide_ing
    end
end
