-- 创建时间:2020-11-06
local basefunc = require "Game/Common/basefunc"
WZQGuideManager = {}

local Model = WZQGuideModel
WZQGuideManager.key = "wuziqi_guide"

local lister = {}
local this

GameButtonManager.ExtLoadLua(WZQGuideManager.key, "WZQGuideConfig")
GameButtonManager.ExtLoadLua(WZQGuideManager.key, "WZQGuideModel")
GameButtonManager.ExtLoadLua(WZQGuideManager.key, "WZQGuidePanel")

local function MakeLister()
    lister = {}
    lister["OnLoginResponse"] = this.OnLoginResponse
    lister["ReConnecteServerSucceed"] = this.OnReConnecteServerSucceed
    lister["global_hint_state_set_msg"] = this.on_global_hint_state_set_msg
    lister["EnterScene"] = this.On_EnterScene
    lister["WZQGuide_Check"] = this.On_WZQGuide_Check
end

local function AddLister()
    for msg, cbk in pairs(lister) do
        Event.AddListener(msg, cbk)
    end
end

local function RemoveLister()
    if lister then
        for msg, cbk in pairs(lister) do
            Event.RemoveListener(msg, cbk)
        end
    end
    lister = nil
end

function WZQGuideManager.Init()
    this = WZQGuideManager
    Model = WZQGuideModel
    WZQGuideManager.Exit()
    WZQGuideManager.m_data = {}
    MakeLister()
    AddLister()
    Model.Init()
    return this
end

function WZQGuideManager.Exit()
    if WZQGuideManager then
        RemoveLister()
        --WZQGuideManager.m_data = nil
    end
end

--检测引导
function WZQGuideManager.CheckGuide(_data)
    --this.RunGuide()
    --do return end
    dump(_data,"<color=red> ---------CheckGuide------------</color>")
    if Model.IsCanGuide() == false then return end

    if _data.guide == Model.data.cur_guide and _data.guide_step == Model.data.cur_guide_step then
        this.RunGuide()
    else
        dump(_data, "<color=white>此检测引导步骤非当前引导步骤!!!</color>")
        dump(Model.data.cur_guide, "<color=white>Model.data.cur_guide</color>")
        dump(Model.data.cur_guide_step, "<color=white>Model.data.cur_guide_step</color>")
    end
end

--执行引导
function WZQGuideManager.RunGuide()
    local cur_guide = Model.data.cur_guide
    local cur_guide_step = Model.data.cur_guide_step
    dump(cur_guide,"<color=white>>>>>>Run cur_guide<<<<<</color> ")
    dump(cur_guide_step,"<color=white>>>>>>Run cur_guide_step<<<<<</color> ")

    WZQGuidePanel.Show(cur_guide, cur_guide_step)
end

--下一步
function WZQGuideManager.NextStep()
    --dump("<color=white>WZQGuideManager.NextStep</color>")
    --dump(Model.IsCurStepAutoNext(),"<color=white>WZQGuideManager.IsCurStepAutoNext</color>")

    if Model.IsCurStepAutoNext() then
        Model.GuideStepNext()
        this.RunGuide()
    else
        Model.GuideStepNext()
    end
end

--跳过引导
function WZQGuideManager.SkipGuide()
    Model.SetGuideFinsh()
end


---------------普通消息---------------
function WZQGuideManager.OnLoginResponse()

end

function WZQGuideManager.OnReConnecteServerSucceed()

end

function WZQGuideManager.on_global_hint_state_set_msg()
end

---------------引导消息---------------
--发送格式：Event.Brocast("WZQGuide_Check",{guide = 1 ,guide_step =1})

function WZQGuideManager.On_WZQGuide_Check(_data)

    if _data.guide ==3 and _data.guide_step ==1 
    and Model.data.cur_guide == 2 and Model.data.cur_guide_step ==1 then
        Model.SetToTreeGuide()
    end
    coroutine.start(function()
        Yield(0)
        this.CheckGuide(_data)
    end)
end

