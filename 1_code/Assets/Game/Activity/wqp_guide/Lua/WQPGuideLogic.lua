-- 创建时间:2021-03-09
WQPGuideLogic = {}

local this -- 单例
local guideModel

local Model = WQPGuideModel

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
    lister["WQP_Guide_Check"] = this.on_wqp_guide_check
    lister["hallpanel_open_anim_finish"] = this.on_hallpanel_open_anim_finish
end

function WQPGuideLogic.Init()
    WQPGuideLogic.Exit()
    this = WQPGuideLogic
    Model = WQPGuideModel
    MakeLister()
    AddLister()
    return this
end

function WQPGuideLogic.Exit()
    if this then
		RemoveLister()
		this = nil
	end
end

--检测引导
function WQPGuideLogic.CheckGuide(_data)

    if not Model.IsCanGuide()  then
        return
    end

    dump(_data,"<color=red> ---------CheckGuide------------</color>")
    if _data.guide == Model.data.cur_guide and _data.guide_step == Model.data.cur_guide_step then
        if Model.IsSpecialSkip() then
            Model.SetGuideFinsh()
        else
            this.RunGuide()
        end
    end
end

--执行引导
function WQPGuideLogic.RunGuide()
    local cur_guide = Model.data.cur_guide
    local cur_guide_step = Model.data.cur_guide_step
    dump({_cur_guide = cur_guide ,_cur_guide_step = cur_guide_step},"<color=white>---------RunGuide------------</color> ")
    WQPGuidePanel.Show(cur_guide, cur_guide_step)
end

--下一步
function WQPGuideLogic.NextStep()
    if Model.IsCurStepAutoNext() then
        Model.GuideStepNext()
        this.RunGuide()
    else
        Model.GuideStepNext()
    end
end

--跳过引导
function WQPGuideLogic.SkipGuide()
    Model.SetGuideFinsh()
end

function WQPGuideLogic.on_wqp_guide_check(_data)
    coroutine.start(function()
        Yield(0)
        this.CheckGuide(_data)
    end)
end

function WQPGuideLogic.on_hallpanel_open_anim_finish(_panel_self)
    this.on_wqp_guide_check({ guide= 2, guide_step = 1})
end