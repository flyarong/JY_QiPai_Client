-- 创建时间:2021-03-25
-- RXCQJZSCManager 管理器

RXCQJZSCManager = {}
local M = RXCQJZSCManager
local _self = {}
local panel = {}
local config = {
    [1] = {map = {[1] = {bg = "cq_bg_cm",wodian = 2}},power = 1},
    [2] = {map = {[1] = {bg = "cq_bg_gm",wodian = 2,choose_img = "jglx_bg_jgcm"},[2] = {bg = "cq_bg_dd",wodian = 2,choose_img = "jglx_bg_jgmd"}},power = 2},
    [3] = {map = {[1] = {bg = "cq_bg_hg1",wodian = 2,choose_img = "jglx_bg_hg1"},[2] = {bg = "cq_bg_hg2",wodian = 2,choose_img = "jglx_bg_hg2"}},power = 3},
    [4] = {map = {[1] = {bg = "cq_bg_hgdd",wodian = 1}},power = 2},
}
local Curr_Level = 1
local Curr_Money_Map = {}
local Curr_Npc_Map = {}
function M.Start(__self,_panel)
    _self = __self
    panel = _panel
    Curr_Level = 1
    Curr_Money_Map = M.CreateMoneyMap()
    Curr_Npc_Map = M.CreateNpcNum()
    local Choose_Map_Index = 1
    for j = 1,config[Curr_Level].map[Choose_Map_Index].wodian do
        local num = math.floor(Curr_Npc_Map[Curr_Level] / config[Curr_Level].map[Choose_Map_Index].wodian + 0.5)
        panel:CreateNpc(j,num,config[Curr_Level].map[Choose_Map_Index].wodian)
    end
    panel:SetImg(config[Curr_Level].map[1].bg)
    M.CreateActtack(Choose_Map_Index)
end

function M.CreateActtack(Choose_Map_Index)
    panel:PlayerActtack(Curr_Level)
end

function M.GetMoneyMap(level,step)
    return Curr_Money_Map[level][step]
end

function M.CreateMoneyMap()
    local _re = {}
    local pow_config = {1,1,1,3}
    local pow_max = 0
    for i = 1,#pow_config do
        pow_max = pow_max + pow_config[i]
    end
    --每个场景的数量分布
    local money = RXCQModel.game_data.award
    local temp_sum = 0
    for i = 1,#pow_config do
        local all = math.floor(pow_config[i]/pow_max * money * (math.random(-30,30) + 100) / 100)
        if i == #pow_config then
            _re[i] = money - temp_sum
        else
            temp_sum = temp_sum + all
            _re[i] = all
        end
    end

    local re = {}
    for i = 1,#config do
        re[i] = re[i] or {}
        if config[i].map[1].wodian == 2 then
            local rom = math.random(-30,30)
            for j = 1,2 do
                re[i][1] = math.floor(_re[i] / 2 * (100 + rom)/100 )
                re[i][2] = _re[i] - re[i][1]
            end
        else
            re[i][1] = _re[i]
        end
    end
    dump(re,"<color=red>结果</color>")
    return re
end

function M.GetCurrLevel()
    return Curr_Level
end

function M.CreateNpcNum()
    local npc_max_num = 50
    --每个场景人数分配的权重
    --每个场景分配的“窝点”
    local rate = tonumber(RXCQModel.game_data.rate)
    if rate >= 120 then
        npc_max_num = math.random(60,80)
    elseif rate >= 100 then
        npc_max_num = math.random(50,70)
    elseif rate >= 80 then
        npc_max_num = math.random(30,50)
    else 
        npc_max_num = math.random(90,120)
    end

    --每个场景的数量分布
    local p_x = 0
    for i = 1,#config do
        p_x = p_x + config[i].power
    end
    local re = {}
    for i = 1,#config do
        local data = math.floor(config[i].power/p_x * npc_max_num + 0.5)
        re[#re + 1] = math.floor(data + math.random(-20,20) * data / 100)
    end
    dump(re,"<color=red>每个场景的人数</color>")

    return re
end

function M.CallNextLevel()
    Util.ClearMemory()
    Curr_Level = Curr_Level + 1
    if Curr_Level > #config then
        local b
        RXCQModel.DelayCall(
            function()
                b = newObject("RXCQXBKPanel",GameObject.Find("Canvas/LayerLv1").transform)
            end
        ,3)
        RXCQModel.DelayCall(
            function()
                destroy(b.gameObject)
                panel:MyExit()
                RXCQMiniGameDie.ReSetUI(function()
                    Event.Brocast("rxcq_jzsc_out")
                    Event.Brocast("rxcq_call_next_anim")
                end)
            end,5
        )
        return
    end
    local base_call = function()
        if #config[Curr_Level].map > 1 then
            panel:StopFenWei()
            RXCQJZSCChoosePanel.Create({call1 = function()
                panel:ReSet()
                panel.play.gameObject:SetActive(false)
                local cb = function()
                    M.CreateActtack(Choose_Map_Index)
                end
                RXCQMiniGameDie.ZhuanChang(function()
                    Choose_Map_Index = 1
                    for j = 1,config[Curr_Level].map[Choose_Map_Index].wodian do
                        local num = math.floor(Curr_Npc_Map[Curr_Level] / config[Curr_Level].map[Choose_Map_Index].wodian + 0.5)
                        panel:CreateNpc(j,num,config[Curr_Level].map[Choose_Map_Index].wodian)
                    end
                    panel:SetImg(config[Curr_Level].map[1].bg)
                    RXCQModel.DelayCall(function()
                        panel.play:ShowChuanSong(cb)
                    end,1)
                end)  

            end,call2 = function()
                panel:ReSet()
                panel.play.gameObject:SetActive(false)
                local cb = function()
                    M.CreateActtack(Choose_Map_Index)
                end

                RXCQMiniGameDie.ZhuanChang(function()
                    Choose_Map_Index = 2
                    for j = 1,config[Curr_Level].map[Choose_Map_Index].wodian do
                        local num = math.floor(Curr_Npc_Map[Curr_Level] / config[Curr_Level].map[Choose_Map_Index].wodian + 0.5)
                        panel:CreateNpc(j,num,config[Curr_Level].map[Choose_Map_Index].wodian)
                    end
                    panel:SetImg(config[Curr_Level].map[2].bg)
                    RXCQModel.DelayCall(function()
                        panel.play:ShowChuanSong(cb)
                    end,1)
                end)
            end,img1 = config[Curr_Level].map[1].choose_img,img2 = config[Curr_Level].map[2].choose_img})
        else
            panel:ReSet()
            panel.play.gameObject:SetActive(false)
            local cb = function()
                M.CreateActtack(1)
            end

            RXCQMiniGameDie.ZhuanChang(function()
                Choose_Map_Index = 1
                for j = 1,config[Curr_Level].map[Choose_Map_Index].wodian do
                    local num = math.floor(Curr_Npc_Map[Curr_Level] / config[Curr_Level].map[Choose_Map_Index].wodian + 0.5)
                    panel:CreateNpc(j,num,config[Curr_Level].map[Choose_Map_Index].wodian)
                end
                panel:SetImg(config[Curr_Level].map[1].bg)
                RXCQModel.DelayCall(function()
                    panel.play:ShowChuanSong(cb)
                end,1)
            end) 
        end
    end
    RXCQModel.DelayCall(base_call,2)
end