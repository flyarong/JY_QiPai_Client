-- 创建时间:2020-10-19
-- EliminateCJItemManager 管理器

local basefunc = require "Game/Common/basefunc"
EliminateCJItemManager = {}
local M = EliminateCJItemManager
--物体的宽和高
local item_width = 200
local item_height = 200
--物体的间隙
local x_space = 4
local y_space = 4
local S_X = item_width + x_space
local S_Y = item_height + y_space
local PARENT = nil
M.item_width = item_width
M.x_space = x_space
M.item_height = item_height
M.y_space = y_space
M.S_X = S_X
M.S_Y = S_Y
M.Items_Data = {}
math.randomseed(tostring(os.time()):reverse():sub(1, 6))

function M.GetRoot()
    M.root = M.root or GameObject.Find("GameObject")
    if IsEquals(M.root) then 
        return M.root.transform
    else
        
    end
    return M.root
end


M.item_obj = {
    ParmItem = newObject("EliminateCJItem",M.GetRoot()),
    xxl_icon_1 = GetTexture("cjxxl_icon_1"),
    xxl_icon_2 = GetTexture("cjxxl_icon_2"),
    xxl_icon_3 = GetTexture("cjxxl_icon_3"),
    xxl_icon_4 = GetTexture("cjxxl_icon_4"),
    xxl_icon_5 = GetTexture("cjxxl_icon_5"),
    xxl_icon_6 = GetTexture("cjxxl_icon_6"),
    xxl_icon_7 = GetTexture("cjxxl_icon_7"),
    xxl_icon_8 = GetTexture("cjxxl_icon_8"),
    xxl_icon_9 = GetTexture("cjxxl_icon_9"),
    xxl_icon_10 = GetTexture("cjxxl_icon_10"),
    xxl_icon_11 = GetTexture("cjxxl_icon_11"),

    material_FrontBlur = GetMaterial("FrontBlur"),
}


function M.Init(parent,map)
    if Line_Blink_Timer then
        Line_Blink_Timer:Stop()
    end
    PARENT = parent
    M.Items_Data = {}
    local items_data = {}
    for i = 1,3 do
        for j = 1,5 do
            local temp = {}
            local b = EliminateCJItem.Create(parent)
            b.transform.localPosition = Vector3.New((j - 1) * S_X,(i - 1) * S_Y, 0)
            b.gameObject.name = j .. "_" .. i
            b:SetIndex(M.Two2One(j,i))
            if map then
                b:ChangeItem(map[M.Two2One(j,i)])
            end
            LuaHelper.GeneratingVar(b.transform, temp)
            items_data[j] =  items_data[j] or {}
            items_data[j][i] = {prefab = b,ui = temp}
        end
    end
    M.Items_Data = items_data
    return items_data
end

function M.ForceToRefreshImg(map)
    for i = 1,3 do
        for j = 1,5 do
            local b = M.Items_Data[j][i].prefab
            if map then
                b:ChangeItem(map[M.Two2One(j,i)])
            end
        end
    end
end

--创建临时的物体，用作动画,map是图
function M.CreateTempItem(items_data)
    for j = 1,5 do
        local temp = {}
        local b = EliminateCJItem.Create(PARENT)
        b.transform.localPosition = Vector3.New((j - 1) * S_X,3 * S_Y, 0)
        b.gameObject.name = j .. "_" .. 4
        b:SetIndex((4 - 1) * 5 + j)
        LuaHelper.GeneratingVar(b.transform, temp)
        items_data[j] =  items_data[j] or {}
        items_data[j][4] = {prefab = b,ui = temp}
    end
    return {
        Destroy = function()
            for j = 1,5 do
                destroy(items_data[j][4].prefab)
                items_data[j][4] = nil
            end
        end
    }
end

function M.GetOverMap()
    return EliminateCJModel.GetCurrData()
end

function M.SetRandomImg(item_data)
    local r = math.random(1,11)
    item_data.prefab:ChangeItem(r)
end

function M.SetOverImage(item_data)
    local index = item_data.prefab:GetIndex()
    local overmap = M.GetOverMap()
    if index <= 15 then
        item_data.prefab:ChangeItem(overmap[index])
    end
end

--将表上下颠倒
function M.tool_reversal(map)
    return {
        map[11],map[12],map[13],map[14],map[15],
        map[6],map[7],map[8],map[9],map[10],
        map[1],map[2],map[3],map[4],map[5],
    }

end

function M.GetWinLines()
    local l2str = {
        [2] = "link_2",[3] = "link_3",[4] = "link_4",[5] = "link_5",
    }
    local result = {}
    local map = M.GetOverMap()
    if map == nil then
        return {}
    end
    local beishu_cfg = EliminateCJModel.xiaoxiaole_defen_cfg.beishu
    local line_cfg = EliminateCJModel.xiaoxiaole_line_cfg.base
    local wild = 11
    local seven = 9
    for i = 1,#line_cfg do
        local cfg = line_cfg[i].line
        --dump(cfg,"cfg")
        local link_index = 0
        local last_item = nil
        local lottery = {}
        local beishu = 0
        local wild_to = nil
        for j = 1,#cfg do
            local index = cfg[j]
            local curr_item = map[index]
            if curr_item ~= wild then
                wild_to = curr_item
                break
            end
        end
        
        for j = 1,#cfg do
            local index = cfg[j]
            local curr_item = map[index]                        
            if curr_item == wild and wild_to ~= seven then
                curr_item = wild_to
            end
            if (curr_item == last_item or last_item == nil) then
                link_index = link_index + 1
                lottery[#lottery + 1] = index
                last_item = curr_item              
            else
                break
            end
        end
        --dump(last_item,"<color=red>last_item</color>")
        --dump(beishu_cfg[last_item],"<color=red>beishu_cfg[last_item]</color>")
        --dump(link_index,"<color=red>link_index</color>")
        if last_item and beishu_cfg[last_item] and beishu_cfg[last_item][l2str[link_index]] then
            beishu = beishu_cfg[last_item][l2str[link_index]]
            local data = {beishu = beishu,lottery = lottery,item = last_item}
            result[#result + 1] = data
        end
    end
    return result
end

function M.GetWinItems()
    local re = M.GetWinLines()
    dump(re,"<color=red>xian______</color>")
    local temp = {}
    local beishu = 0
    for i = 1,#re do
        beishu = beishu + re[i].beishu
        for j = 1,#re[i].lottery do
            temp[re[i].lottery[j]] = re[i]
        end
    end
    local result = {}
    result.items = {}
    result.beishu = beishu
    for k,v in pairs(temp) do
        result.items[#result.items + 1] = k
    end
    return result
end

local Line_Blink_Timer = nil
function M.ShowBlinkOneByOne()
    if Line_Blink_Timer then
        Line_Blink_Timer:Stop()
    end
    local Line_Data = M.GetWinLines()
    dump(Line_Data,"<color=red>Line_Data</color>")

    if table_is_null(Line_Data) then return end
    local now_index = 1
    Line_Blink_Timer = Timer.New(
        function()
            if now_index > #Line_Data then
                now_index = 1
            end
            --ExtendSoundManager.PlaySceneBGM(audio_config.cjxxl.bgm_cjxxl_1bei.audio_name)
            for i = 1,#Line_Data[now_index].lottery do
                local X_Y = M.One2Two(Line_Data[now_index].lottery[i])
                local X = X_Y.X
                local Y = X_Y.Y
                M.Items_Data[X][Y].prefab:Blink()
            end
            now_index = now_index + 1
        end,
    1,-1,nil,true)
    Line_Blink_Timer:Start()
end

local All_Blink_Timer = nil
function M.ShowBlinkAll(backcall)
    if All_Blink_Timer then
        All_Blink_Timer:Stop()
    end
    local All_Data = M.GetWinItems()
    --dump(All_Data,"<color=red>All_Data</color>")
    if table_is_null(All_Data) or table_is_null(All_Data.items) then 
        All_Blink_Timer = Timer.New(
            function()
                if backcall then
                    backcall()
                end
            end,
        0.5,1)
        All_Blink_Timer:Start()
        return 
    end
    for i = 1,#All_Data.items do
        local X_Y = M.One2Two(All_Data.items[i])
        local X = X_Y.X
        local Y = X_Y.Y
        M.Items_Data[X][Y].prefab:Blink(1.2)
    end
    Event.Brocast("eliminate_cj_add_money",All_Data.beishu * EliminateCJModel.GetBet() / 25)
    All_Blink_Timer = Timer.New(
        function()
            if backcall then
                backcall()
            end
        end,
    1.2,1,nil,true)
    All_Blink_Timer:Start()
end

--二维转一维
function M.Two2One(X,Y)
    return (Y - 1) * 5 + X
end

--一维转二维
function M.One2Two(Index)
    local Y = 1
    local index = Index
    while(index > 5) do
        index = index - 5
        Y = Y + 1
    end
    return {X = index,Y = Y}
end

function M.StopShow()
    if Line_Blink_Timer then
        Line_Blink_Timer:Stop()
    end
    if All_Blink_Timer then
        All_Blink_Timer:Stop()
    end
    for i = 1,3 do
        for j = 1,5 do
            M.Items_Data[j][i].prefab:HideAllAffect()
        end
    end
end
--前col列的免费元素燃火,index 是列数
function M.ShowFreeWaitEffect(col,onoff)
    local data = M.GetHaveFree3()
    for i = 1,col do
        for j = 1,#data[i] do
            local index = data[i][j]
            local x_y = M.One2Two(index)
            M.Items_Data[x_y.X][x_y.Y].prefab:ShowWaitEffect(onoff)
        end
    end
end

--前col列的免费元素普通特效,col 是列数,isthis 是否只有当前列
function M.ShowFreeNormalEffect(col,isthis)
    local data = M.GetHaveFree3()
    local curr = isthis and col or 1
    for i = curr,col do
        for j = 1,#data[i] do
            local index = data[i][j]
            local x_y = M.One2Two(index)
            M.Items_Data[x_y.X][x_y.Y].prefab:ShowNormalEffect()
        end
    end
end

-- 前col列钻石元素普通特效 col 是列数,isthis 是否只有当前列
function M.ShowWildNormalEffect(col,isthis)
    local data = M.GetHaveFree3(11)
    local curr = isthis and col or 1
    for i = curr,col do
        for j = 1,#data[i] do
            local index = data[i][j]
            local x_y = M.One2Two(index)
            M.Items_Data[x_y.X][x_y.Y].prefab:ShowNormalEffect()
        end
    end
end

--前col列的免费元素爆发,index 是列数
function M.ShowFreeBoomEffect(col,onoff)
    local data = M.GetHaveFree3()
    for i = 1,col do
        for j = 1,#data[i] do
            local index = data[i][j]
            local x_y = M.One2Two(index)
            M.Items_Data[x_y.X][x_y.Y].prefab:ShowBoomEffect(onoff)
        end
    end
end

--获取在前三列有某元素，默认是检查是否有免费元素
function M.GetHaveFree3(item)
    item = item or 10
    local data = M.GetOverMap() 
    local cheak_table = {
        [1] = {1,6,11},
        [2] = {2,7,12},
        [3] = {3,8,13},
        [4] = {4,9,14},
        [5] = {5,10,15},
    }
    local col_1 = {}
    local col_2 = {}
    local col_3 = {}
    local col_4 = {}
    local col_5 = {}
    if data then
       for i = 1,#cheak_table do
            for j = 1,#cheak_table[i] do
                if data[cheak_table[i][j]] == item then
                    if i == 1 then 
                        col_1[#col_1 + 1] = M.Two2One(i,j)
                    end
                    if i == 2 then 
                        col_2[#col_2 + 1] = M.Two2One(i,j)
                    end
                    if i == 3 then 
                        col_3[#col_3 + 1] = M.Two2One(i,j)
                    end
                    if i == 4 then 
                        col_4[#col_4 + 1] = M.Two2One(i,j)
                    end
                    if i == 5 then 
                        col_5[#col_5 + 1] = M.Two2One(i,j)
                    end
                end
            end
       end
    end
    return {col_1,col_2,col_3,col_4,col_5}
end

function M.IsHaveFree2()
    local data = M.GetHaveFree3()
    --dump(data,"<color=red>前两列的免费元素</color>")
    if table_is_null(data[1]) or table_is_null(data[2]) then

    else
        return true
    end
end

function M.IsHaveFree3()
    local data = M.GetHaveFree3()
    --dump(data,"<color=red>前三列的免费元素</color>")
    if table_is_null(data[1]) or table_is_null(data[2]) or table_is_null(data[3]) then

    else
        return true
    end
end