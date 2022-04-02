-- 创建时间:2020-10-19
-- EliminateCJAnimManager 管理器

local basefunc = require "Game/Common/basefunc"
EliminateCJAnimManager = {}
local M = EliminateCJAnimManager
M.AnimKey = "EliminateCJAnimManager"
local Status = EliminateCJEnum.Status
local _LOCK_ = false
function M.Create(items_data)
    _LOCK_ = false
    local temp = EliminateCJItemManager.CreateTempItem(items_data)
    local LotteryScrollAnim = function()
        M.LotteryScrollAnim(items_data)
    end
    return {
        LotteryScrollAnim = LotteryScrollAnim,
    }
end

function M.ExitAnim()
    _LOCK_ = true
end

function M.LotteryScrollAnim(items_data)
    local Finsh_Time = 0
    EliminateCJItemManager.StopShow()
    M.ClearAllTimer()
    local start_audio_key = ExtendSoundManager.PlaySound(audio_config.cjxxl.bgm_cjxxl_start.audio_name)
    for i = 1, 5 do
        local seq = DoTweenSequence.Create({dotweenLayerKey = M.key})
        local items_data_i = items_data[i]
        --seq:AppendInterval((i - 1) * 0.25)
        seq:AppendCallback(function()
            local idol 
            idol = function()
                -- for j = 1,#items_data_i do
                --     items_data_i[j].ui.main_img.material = EliminateCJItemManager.item_obj.material_FrontBlur
                -- end
                M.SpeedIdolAnim(items_data_i,function()
                    if EliminateCJModel.IsGotData() then
                        -- for j = 1,#items_data_i do
                        --     items_data_i[j].ui.main_img.material = nil
                        -- end
                        -- 完成次数：需要五列都完成才算结束
                        -- 前两列带免费游戏的开奖
                        if EliminateCJItemManager.IsHaveFree2() then
                            if i <= 2 then
                                local during_time = 0.8 + (i - 1) * 0.15
                                M.SpeedDownAnim(items_data_i,function()
                                    Finsh_Time = Finsh_Time + 1
                                    EliminateCJItemManager.ShowFreeNormalEffect(Finsh_Time)
                                    if Finsh_Time == 2 then                                     
                                        Event.Brocast("wait_for_free_onoff",1)
                                    end                                   
                                end,during_time,i)
                                M.ThisTimer(
                                    function()
                                        local audio_str = "bgm_cjxxl_stop"..i
                                        ExtendSoundManager.PlaySound(audio_config.cjxxl[audio_str].audio_name)
                                    end
                                ,during_time - 0.15,1):Start()
                            elseif i == 3 then
                                local during_time = 2
                                local down_func = function()
                                    ExtendSoundManager.PlaySound(audio_config.cjxxl.bgm_cjxxl_disanpai_mf.audio_name)                              
                                    M.SpeedDownAnim(items_data_i,function()   
                                        Finsh_Time = Finsh_Time + 1
                                        if Finsh_Time == 3 then
                                            Event.Brocast("wait_for_free_onoff",0)
                                            if EliminateCJItemManager.IsHaveFree3() then
                                                EliminateCJItemManager.ShowFreeWaitEffect(3,true)
                                            else
                                                EliminateCJItemManager.ShowFreeWaitEffect(2,false)
                                            end                                      
                                        end
                                    end,during_time,18)
                                end
                               
                                M.SpeedIdolAnim(items_data_i,down_func,1.2,4)
                                M.ThisTimer(
                                    function()
                                        local audio_str = "bgm_cjxxl_stop"..i
                                        ExtendSoundManager.PlaySound(audio_config.cjxxl[audio_str].audio_name)
                                    end
                                ,during_time + 1.2 - 0.15,1):Start()
                            else
                                local during_time = 2.9 + 0.15 * i  
                                M.SpeedDownAnim(items_data_i,function()
                                    Finsh_Time = Finsh_Time + 1                             
                                    if Finsh_Time == 5 then
                                        M.ThisTimer(
                                            function()
                                                EliminateCJItemManager.ShowBlinkAll(function()
                                                    if EliminateCJItemManager.IsHaveFree3() then                                                
                                                        EliminateCJItemManager.ShowFreeWaitEffect(3,false)
                                                        ExtendSoundManager.PlaySound(audio_config.cjxxl.bgm_cjxxl_freegame.audio_name)
                                                        EliminateCJItemManager.ShowFreeBoomEffect(3,true)
                                                        M.ThisTimer(function()
                                                            EliminateCJItemManager.ShowFreeNormalEffect(3)
                                                        end,0.8,1):Start()
                                                        M.ThisTimer(function()
                                                            EliminateCJFreePanel.Create()
                                                        end,1.5,1):Start()
                                                    else
                                                        EliminateCJItemManager.ShowBlinkOneByOne()
                                                        Event.Brocast("eliminate_cj_anim_finsh_one_roll","eliminate_cj_anim_finsh_one_roll")
                                                    end
                                                end)
                                            end
                                        ,0.5,1):Start()
                                        ExtendSoundManager.CloseSound(start_audio_key)
                                    end
                                end,during_time,10 + i)
                                M.ThisTimer(
                                    function()
                                        local audio_str = "bgm_cjxxl_stop"..i
                                        ExtendSoundManager.PlaySound(audio_config.cjxxl[audio_str].audio_name)
                                    end
                                ,during_time - 0.15,1):Start()
                            end                        
                        else--普通开奖
                            local during_time = 0.8 + (i - 1) * 0.15
                            M.SpeedDownAnim(items_data_i,function()
                                Finsh_Time = Finsh_Time + 1
                                EliminateCJItemManager.ShowFreeNormalEffect(Finsh_Time,true) 
                                if Finsh_Time >= 5 then
                                    --免费游戏中的开奖
                                    if EliminateCJModel.Status == Status.in_free then
                                        EliminateCJItemManager.ShowBlinkAll(function()
                                            Event.Brocast("eliminate_cj_anim_finsh_one_roll","eliminate_cj_anim_finsh_one_roll")
                                        end)
                                    else
                                        EliminateCJItemManager.ShowBlinkAll(function()
                                            Event.Brocast("eliminate_cj_anim_finsh_one_roll","eliminate_cj_anim_finsh_one_roll")
                                            M.ThisTimer(function()
                                                if not EliminateCJModel.IsAuto then
                                                    EliminateCJItemManager.ShowBlinkOneByOne()
                                                end
                                            end,1,1):Start()
                                        end)
                                    end
                                    ExtendSoundManager.CloseSound(start_audio_key)
                                end
                            end,during_time,i)
                            M.ThisTimer(
                                function()
                                    local audio_str = "bgm_cjxxl_stop"..i
                                    ExtendSoundManager.PlaySound(audio_config.cjxxl[audio_str].audio_name)
                                end
                            ,during_time - 0.15 ,1):Start()
                        end
                    else
                        idol()
                    end
                end)
            end
            M.SpeedUpAnim(items_data_i,function()
                idol()
            end)
        end)
    end
    return prefab_list
end

function M.StopScroll()

end

--(预制体；预制体通过luahelper找的UI表);距离;持续时间;动画完成回调;曲线类型;转的轮数发生改变的回调
function M.ScrollClip(items_data,distance,during_t,backcall,QX_Type,rollTimes_ChangeCall)
    local Positions_Y = {}
    local RollTimes = {}
    for i = 1,#items_data do
        Positions_Y[#Positions_Y + 1] = items_data[i].prefab.transform.localPosition.y
        RollTimes[#RollTimes + 1] = 0
    end
    local Start = 0
    local seq = DoTweenSequence.Create({dotweenLayerKey = M.key})
    local DT = DG.Tweening.DOTween.To(
        DG.Tweening.Core.DOGetter_float(
            function(value)
                return Start
            end
        ),
        DG.Tweening.Core.DOSetter_float(
            function(value)
                if _LOCK_ then return end
                for i = 1,#items_data do
                    local data = M.GetRealPos(Positions_Y[i] + value)
                    items_data[i].prefab.transform.localPosition = Vector3.New(items_data[i].prefab.transform.localPosition.x,
                    data.pos,0)
                    if data.times ~= RollTimes[i] then
                        RollTimes[i] = data.times
                        if rollTimes_ChangeCall then
                            rollTimes_ChangeCall(data.times,items_data[i])
                        end
                    end
                end            
            end
        ),
        distance,
        during_t
    ):OnComplete(
        function()
            if _LOCK_ then return end
            if backcall then
                backcall()
            end
        end 
    )
    if QX_Type then
        DT:SetEase(DG.Tweening.Ease[QX_Type])
    else
        DT:SetEase(DG.Tweening.Ease.Linear)
    end
end


function M.GetRealPos(pos)
    local rel = pos
    local index = 0
    while(rel <= - EliminateCJItemManager.S_Y) do 
        rel = rel + 4 * EliminateCJItemManager.S_Y
        index = index + 1
    end
    return {pos = rel,times = index}
end

function M.SpeedUpAnim(items_data,backcall)
    local rollTimes_ChangeCall = function(roll_times,items_data)      
        EliminateCJItemManager.SetRandomImg(items_data)
    end
    M.ScrollClip(items_data,EliminateCJItemManager.S_Y * -4 * 2,0.3,backcall,nil,rollTimes_ChangeCall)
end

function M.SpeedDownAnim(items_data,backcall,during_time,roll_time)
    local exceed_during_time = during_time - 0.4
    local rollTimes_ChangeCall = function(_roll_time,items_data)      
        if _roll_time >= 1 then
            EliminateCJItemManager.SetOverImage(items_data)
        else
            EliminateCJItemManager.SetRandomImg(items_data)
        end
    end

    local down_func = function()
        M.ScrollClip(items_data,EliminateCJItemManager.S_Y * -4,0.4,backcall,"OutQuad",rollTimes_ChangeCall)
    end
    --转一圈用0.15秒，这个时候需要用同等速度拖过 exceed_during_time 的时间
    if exceed_during_time > 0 then
        M.SpeedIdolAnim(items_data,down_func,exceed_during_time,math.ceil(1/0.15 * exceed_during_time))
    else
        down_func()
    end
end

function M.SpeedIdolAnim(items_data,backcall,during_time,roll_time)
    local R_T = roll_time or 4
    local during_time = during_time or 0.6
    local rollTimes_ChangeCall = function(roll_times,items_data)      
        EliminateCJItemManager.SetRandomImg(items_data)
    end
    M.ScrollClip(items_data,EliminateCJItemManager.S_Y * -4 * R_T,during_time,backcall,nil,rollTimes_ChangeCall)
end

local Anim_Times = {}
function M.ThisTimer(backcall,space_t,loop)
    local t = Timer.New(backcall,space_t,loop,nil,true)
    Anim_Times[#Anim_Times + 1] = t
    return t
end

function M.ClearAllTimer()
    for i = 1,#Anim_Times do
        Anim_Times[i]:Stop()
    end
    Anim_Times = {}
end
