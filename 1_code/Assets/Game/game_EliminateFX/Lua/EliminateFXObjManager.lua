local basefunc = require "Game.Common.basefunc"
EliminateFXObjManager = {}
local M = EliminateFXObjManager
package.loaded["Game.game_EliminateFX.Lua.EliminateFXItem"] = nil
require "Game.game_EliminateFX.Lua.EliminateFXItem"
-- package.loaded["Game.game_EliminateFX.Lua.EliminateFXItemBG"] = nil
-- require "Game.game_EliminateFX.Lua.EliminateFXItemBG"
local item_map = {}
local boat_item_map = {}
local bg_map = {}
local score_map = {}

local lister = {}
function M.GetRoot()
    M.root = M.root or GameObject.Find("GameObject")
    if IsEquals(M.root) then
        return M.root.transform
    else
        M.root = GameObject.Find("GameObject")
    end
    return M.root
end

function M.GetItemContent()
    if not M.ItemContent then 
        M.ItemContent = GameObject.Find("ItemContent")
    end
    if IsEquals(M.ItemContent) then
        return M.ItemContent.transform
    end
end

function M.GetScoreContent()
    if not M.ScoreContent then 
        M.ScoreContent = GameObject.Find("ScoreContent")
    end
    if IsEquals(M.ScoreContent) then
        return M.ScoreContent.transform
    end
end

function M.GetAnimContent()
    if not M.AnimContent then 
        M.AnimContent = GameObject.Find("AnimContent")
    end
    if IsEquals(M.AnimContent) then
        return M.AnimContent.transform
    end
end

function M.ClearScoreObj()
    if not table_is_null(score_map) then
        for x, _v in pairs(score_map) do
            for y, v in pairs(_v) do
                if v.obj then
                    destroy(v.obj)
                end
            end
        end
    end
    score_map = {}
end

function M.ClearAnimObj()
    -- dump(M.GetAnimContent().childCount, "<color=white>AAAAAAAAAAAAAAAAAAAAAAAAAAAAA</color>")
    local count = basefunc.deepcopy(M.GetAnimContent().childCount)
    if count > 0 then
        for i = 1, count do
            dump(M.GetAnimContent():GetChild(0).name, "<color=white>bbb</color>")
            destroy(M.GetAnimContent():GetChild(0).gameObject)
        end
    end
    dump(M.GetAnimContent().childCount, "<color=white>cccc</color>")
end

function M.InitScore()
    for i = 1, EliminateFXModel.size.max_x do
        for j = 1, EliminateFXModel.size.max_y do
            score_map[i] = score_map[i] or {}
            local score = {num = 0, ui = {}, obj = nil}
            score_map[i][j] = score
        end
    end
end

-- function M.GetBGContent()
--     if not IsEquals(M.BGContent) then
--         M.BGContent = GameObject.Find("BGContent")
--     end
--     if IsEquals(M.BGContent) then
--         return M.BGContent.transform
--     end
-- end

M.item_obj = {
    EliminateFXItem = newObject("EliminateFXItem", M.GetRoot()),
    -- EliminateFXItemBG = newObject("EliminateFXItemBG", M.GetRoot()),
    xxl_icon_1 = GetTexture("fxgz_icon_tb"),
    xxl_icon_2 = GetTexture("fxgz_icon_yd"),
    xxl_icon_3 = GetTexture("fxgz_icon_jz"),
    xxl_icon_4 = GetTexture("fxgz_icon_yp"),
    xxl_icon_5 = GetTexture("fxgz_icon_ymz"),
    xxl_icon_6 = GetTexture("fxgz_icon_cs1"),
    xxl_icon_7 = GetTexture("fxgz_icon_cs2"),
    xxl_icon_8 = GetTexture("fxgz_icon_cs3"),
    xxl_icon_9 = GetTexture("fxgz_icon_jyb"),
    
    xxl_icon_100 = GetTexture("fxgz_icon_jyb"),
    xxl_icon_101 = GetTexture("fxgz_icon_cs1"),
    xxl_icon_102 = GetTexture("fxgz_icon_cs2"),
    xxl_icon_103 = GetTexture("fxgz_icon_cs3"),

    material_FrontBlur = GetMaterial("FrontBlur"),
}

M.clear_obj = {
    xxl_icon_1 = M.item_obj.xxl_icon_1,
    xxl_icon_2 = M.item_obj.xxl_icon_2,
    xxl_icon_3 = M.item_obj.xxl_icon_3,
    xxl_icon_4 = M.item_obj.xxl_icon_4,
    xxl_icon_5 = M.item_obj.xxl_icon_5,
    xxl_icon_6 = M.item_obj.xxl_icon_6,
    xxl_icon_7 = M.item_obj.xxl_icon_7,
    xxl_icon_8 = M.item_obj.xxl_icon_8,
    xxl_icon_9 = M.item_obj.xxl_icon_9,

    xxl_icon_100 = M.item_obj.xxl_icon_100,
    xxl_icon_101 = M.item_obj.xxl_icon_101,
    xxl_icon_102 = M.item_obj.xxl_icon_102,
    xxl_icon_103 = M.item_obj.xxl_icon_103,
}

function M.InstantiateObj()
    for k, v in pairs(EliminateFXModel.eliminate_enum) do
        local _obj = GameObject.Instantiate(M.item_obj.EliminateFXItem, M.GetRoot())
        local img = _obj.gameObject.transform:Find("@icon_img"):GetComponent("Image")
        img.sprite = M.item_obj["xxl_icon_" .. v]
        M.item_obj["EliminateFXItem" .. v] = _obj

        --[[local _obj_phy = GameObject.Instantiate(M.item_obj.EliminateXYItemPhysics, M.GetRoot())
        _obj_phy.gameObject.transform.localPosition = Vector3.one * 10000
        local img_phy = _obj_phy.gameObject.transform:Find("@icon_img"):GetComponent("Image")
        img_phy.sprite = M.item_obj["xxl_icon_" .. v]
        M.item_obj["EliminateXYItemPhysics" .. v] = _obj_phy
        M.delete_obj["EliminateXYItemPhysics" .. v] = _obj_phy--]]
    end
end

function M.Init()
    M.Exit()
    print("<color=yellow>消消乐obj初始化</color>")
    M.AddListener()
    M.InstantiateObj()
    --M.item_obj.EliminateXYItemPhysics.transform.localPosition = Vector3.one * 10000
end

function M.Exit()
    print("<color=white>objManager退出</color>")
    M.RemoveListener()
    soundMgr:CloseSound()
    M.ExitTimer()
    if not table_is_null(item_map) then
        for x, _v in pairs(item_map) do
            for y, v in pairs(_v) do
                v:Exit()
            end
        end
    end
    item_map = {}
    if not table_is_null(boat_item_map) then
        for x, _v in pairs(boat_item_map) do
            for y, v in pairs(_v) do
                v:Exit()
            end
        end
    end
    boat_item_map = {}
    for x, _v in pairs(bg_map) do
        for y, v in pairs(_v) do
            v:Exit()
        end
    end
    bg_map = {}
    M.root = nil
    M.ItemContent = nil
    -- M.BGContent = nil
end

function M.ExitTimer()
    DOTweenManager.KillAllStopTween()
    DOTweenManager.KillAllExitTween()
    DOTweenManager.CloseAllSequence()
end

function M.AddListener()
    M.MakeLister()
    for proto_name, func in pairs(lister) do
        Event.AddListener(proto_name, func)
    end
end

function M.ExitScene()
    for x, _v in pairs(M.item_obj) do
     M.item_obj[x] = nil
    end
    M.item_obj = {}

    for x, _v in pairs(M.clear_obj) do
        M.clear_obj [x] = nil
    end
    M.clear_obj  = {}
    M.Exit()
end

function M.MakeLister()
    lister = {}
    lister["ExitScene"] = M.ExitScene
    lister["OnLoginResponse"] = M.Exit
    lister["will_kick_reason"] = M.Exit
    lister["DisconnectServerConnect"] = M.Exit
end

function M.RemoveListener()
    for proto_name, func in pairs(lister) do
        Event.RemoveListener(proto_name, func)
    end
end

function M.CreateEliminateItem(data)
    local map = {}
    if data and next(data) then
        for x, _v in pairs(data) do
            for y, v in pairs(_v) do
                map[x] = map[x] or {}
                map[x][y] = v
            end
        end
    end
    M.AddEliminateItem(map,nil)
end

function M.CreateEliminateItemDown(data)
    local map = {}
    for x, _v in pairs(data) do
        for y, v in pairs(_v) do
            map[x] = map[x] or {}
            map[x][y] = v
        end
    end
    M.AddEliminateItem(map, true)
end

function M.ClearEliminateItem()
    for x, _v in pairs(item_map) do
        for y, v in pairs(_v) do
            v:Exit()
        end
    end
    item_map = {}
    for x, _v in pairs(boat_item_map) do
        for y, v in pairs(_v) do
            v:Exit()
        end
    end
    boat_item_map = {}
    for i=M.GetItemContent().transform.childCount - 1,0,-1 do
        destroy(M.GetItemContent().transform:GetChild(i).gameObject)
    end
end

--item下滑
function M.EliminateItemDown(callback)
    local new_item_map = {}
    local tab = {}
    local temp_tab = {}
    local new_y = 1
    local tab_tab = {}

    local _new_item_map = {}
    local index = eliminate_fx_algorithm.get_map_max_index(item_map)
    for x = 1, index.x do
        new_y = 1
        for y = 1, index.y do
            if item_map[x] and item_map[x][y] then
                if item_map[x][y].data.id < 100 then
                    new_item_map[x] = new_item_map[x] or {}
                    new_item_map[x][new_y] = item_map[x][y]

                    _new_item_map[x] = _new_item_map[x] or {}
                    _new_item_map[x][new_y] = item_map[x][y]
                    new_y = new_y + 1
                end
                while (item_map[x][new_y] and item_map[x][new_y].data.id >= 100) do
                    _new_item_map[x] = _new_item_map[x] or {}
                    _new_item_map[x][new_y] = item_map[x][new_y]
                    new_y = new_y + 1
                end
            end
        end
    end
    item_map = _new_item_map
    EliminateFXAnimManager.EliminateItemDown(new_item_map, callback)
end

function M.EliminateItemDownNew(map, callback)
   -- M.PrintItemMap(item_map_hscb, "GGG")
    local new_item_map = {}
    for x, _v in pairs(map) do
        for y, v in pairs(_v) do
            new_item_map[x] = new_item_map[x] or {}
            new_item_map[x][y] = item_map[x][y]
        end
    end
    --M.PrintItemMap(map, "map")
    --M.PrintItemMap(new_item_map, "HHHH")
    local function _callback()
        EliminateFXAnimManager.Spring(new_item_map, EliminateFXModel.GetTime(EliminateFXModel.time.ys_xxldd), callback)
    end
    EliminateFXAnimManager.EliminateItemDown(new_item_map, _callback)
end

function M.AddEliminateItem(data, is_down)
    if table_is_null(data) then
        return
    end
    local add_item_map = {}
    for x, _v in pairs(data) do
        for y, v in pairs(_v) do
            if item_map[x] and item_map[x][y] then
                item_map[x][y]:Exit()
            end
            item_map[x] = item_map[x] or {}
            item_map[x][y] = EliminateFXItem.Create({x = x, y = y, id = v, is_down = is_down,type = "nor"})
            add_item_map[x] = add_item_map[x] or {}
            add_item_map[x][y] = item_map[x][y]
            -- M.RefreshEliminateBG(data)
        end
    end
 
    return add_item_map
end

function M.RemoveEliminateItem(data)
    if table_is_null(data) then
        return
    end
    for x, _v in pairs(data) do
        for y, v in pairs(_v) do
            if item_map[x] and item_map[x][y] then
                item_map[x][y]:Exit()
                item_map[x][y] = nil
            end
        end
    end
end

function M.PrintItemMap(_item_map, kk)
    kk = kk or "nn"
    print("<color=red>PrintItemMap kk=" .. kk .. "</color>")
    local s = "\n"
    for x, _v in pairs(_item_map) do
        for y, v in pairs(_v) do
            s = s .. " ( x = " .. x .. " , y = " .. y .. ")"
        end
        s = s .. "\n"
    end
    print(s)
end

function M.HideEliminateItem(data)
    if table_is_null(data) then
        return
    end
    for x, _v in pairs(data) do
        for y, v in pairs(_v) do
            if item_map[x] and item_map[x][y] then
                item_map[x][y]:SetView(false)
            end
        end
    end
end

function M.GetAllEliminateItem()
    return item_map
end

function M.GetEliminateItem(x, y)
    if item_map[x] then
        return item_map[x][y]
    end
end

-- function M.InitEliminateBG(max_x, max_y)
--     local map = {}
--     for y = 1, max_y do
--         for x = 1, max_x do
--             map[x] = map[x] or {}
--             map[x][y] = 1
--         end
--     end
--     M.AddEliminateBG(map)
-- end

-- function M.AddEliminateBG(data)
--     if table_is_null(data) then
--         return
--     end
--     for x, _v in pairs(data) do
--         for y, v in pairs(_v) do
--             bg_map[x] = bg_map[x] or {}
--             bg_map[x][y] = EliminateFXItemBG.Create({x = x, y = y})
--         end
--     end
-- end

-- function M.RemoveEliminateBG(data)
--     if table_is_null(data) then
--         return
--     end
--     for x, _v in pairs(data) do
--         for y, v in pairs(_v) do
--             if bg_map[x] and bg_map[x][y] then
--                 bg_map[x][y]:Exit(data)
--             end
--         end
--     end
-- end

-- function M.RefreshEliminateBG(data)
--     if table_is_null(data) then
--         return
--     end
--     for x, _v in pairs(data) do
--         for y, v in pairs(_v) do
--             if bg_map[x] and bg_map[x][y] then
--                 bg_map[x][y]:Refresh(data)
--             end
--         end
--     end
-- end

--消除特效的类型和时间
function M.GetParticleDataEliminate(data, cur_del_map, index)
    local xc_c = eliminate_fx_algorithm.get_xc_count(cur_del_map)
    local xc_id = eliminate_fx_algorithm.get_xc_id(cur_del_map)
    local pd = {}
    pd.xc_c = xc_c
    pd.xc_id = xc_id
    return pd
end


function M.PlayParticleEliminate(pd, cur_del_map, cur_rate)
    if table_is_null(cur_del_map) then
        return
    end
    local cru_del_list = eliminate_fx_algorithm.change_map_to_list(cur_del_map)
    local count = pd.xc_c
    local xc_id = tonumber(pd.xc_id)
    if false then
    else
        --普通消除特效
        if count <= 3 then
            EliminateFXPartManager.CreateEliminateNor1(cru_del_list, EliminateFXModel.GetAwardGold(cur_rate))
        elseif count == 4 then
            EliminateFXPartManager.CreateEliminateNor2(cru_del_list, EliminateFXModel.GetAwardGold(cur_rate))
        else
            EliminateFXPartManager.CreateEliminateNor3(cru_del_list, EliminateFXModel.GetAwardGold(cur_rate))
        end
    end
end

function M.PlaySoundByEliminateCount(c)
    if c == 3 then
        --Event.Brocast("open_sys_act_base")
        ExtendSoundManager.PlaySound(audio_config.fxgz.bgm_fxgz_xiao3.audio_name)
    elseif c == 4 then
        --Event.Brocast("open_sys_act_base")
        ExtendSoundManager.PlaySound(audio_config.fxgz.bgm_fxgz_xiao4.audio_name)
    elseif c == 5 then
        --Event.Brocast("open_sys_act_base")
        ExtendSoundManager.PlaySound(audio_config.fxgz.bgm_fxgz_xiao5.audio_name)
    elseif c >= 6 then
        --Event.Brocast("open_sys_act_base")
        ExtendSoundManager.PlaySound(audio_config.fxgz.bgm_fxgz_xiao6.audio_name)
    end
end

-------------------------------外部调用
function M.Lottery(index, callback,is_first)
    if EliminateFXModel.DataDamage() then
        return
    end
    if not EliminateFXModel.data or not EliminateFXModel.data.eliminate_data then return end
    local data = EliminateFXModel.data.eliminate_data.result[index]
    if not data then return end
    EliminateFXModel.data.state = data.state
    print("<color=yellow>索引</color>",index)
    dump(data)

    if EliminateFXModel.data.state == EliminateFXModel.xc_state.big_game then
        -- LittleTips.Create("小游戏_"..(8 - data.free_times + 1))
    end

    local seq = DoTweenSequence.Create()
    M.ShakeBefore(data,seq,index,is_first)
    M.RefreshView(data,seq)
    M.DelList(data, seq)
    M.DelListEnd(data, seq)
    M.BigGame(data, index, seq)
    M.LotteryEnd(data, index, seq, callback)
end

function M.BigGame(data, index, seq)
    if EliminateFXModel.data.state == EliminateFXModel.xc_state.big_game then
        local processList
        EliminateFXModel.UpdateBaseSendRateMap(index)
        if not table_is_null(data.special_list)  then
            -- dump(data, "<color=white>FFFFFFFFFFFFFFFFFFFFFFFFFFFF</color>")
            dump(9 - data.free_times, "<color=white>TTT 福星高照:</color>")
            dump(data.special_list, "<color=white>福星高照:special_list</color>")
            dump(data.map_new, "<color=white>福星高照:map_new</color>")
            seq:AppendCallback(function ()
                M.RefreshAllScore(EliminateFXModel.GetBigGameRateMap(), data.map_new)
            end)
            processList = EliminateFXModel.GetBigGameProcessList(index)
            EliminateFXAnimManager.DoAddRateAnimation(processList, seq)
            seq:AppendCallback(function ()
                EliminateFXModel.PrintRateMap(9 - data.free_times)
            end)
            seq:AppendInterval(0.01)
        end
        seq:AppendCallback(function ()
            for i=1,eliminate_fx_algorithm.wide_max do
                for j=1,eliminate_fx_algorithm.high_max do
                    if data.map_new[i] and data.map_new[i][j] and data.map_new[i][j] >= 100 then
                        local tab = {}
                        tab[i] = {}
                        tab[i][j] = data.map_new[i][j]
                        EliminateFXObjManager.AddBoatEliminateItem(tab)
                    end
                end
            end
            if data.need_refresh then
                M.ClearEliminateItem()
                M.CreateEliminateItem(data.map_new)
            end
        end)

        local curRateMap = EliminateFXModel.GetAllBigGameRateMap(true)
        local nextRateMap = basefunc.deepcopy(curRateMap)
        if not table_is_null(processList) then
            for i = 1, #processList do
                local send = processList[i].send
                local accept = processList[i].accept
                nextRateMap[accept.x][accept.y] = nextRateMap[accept.x][accept.y] + nextRateMap[send.x][send.y]
            end
        end
        if (data.free_times == 1 and index == #EliminateFXModel.data.eliminate_data.result) or EliminateFXModel.IsFullGameRateMap(nextRateMap) then
            EliminateFXAnimManager.DoAddMoneyToJc(seq, nextRateMap, M.GetAnimContent())
        end
    end
end

function M.ShakeBefore(data,seq,index,is_first)
    if is_first or not data.is_scroll then
        return
    end
    if EliminateFXModel.data.state == EliminateFXModel.xc_state.big_game then
        Event.Brocast("free_game_times_change_msg",data.free_times - 1)
    end
    seq:AppendCallback(function(  )
        local item_map = EliminateFXObjManager.GetAllEliminateItem()
        local times = {
            ys_jsgdsj = EliminateFXModel.time.ys_jsgdsj,
            ys_ysgdjg = EliminateFXModel.time.ys_ysgdjg,
            ys_j_sgdsj = EliminateFXModel.time.ys_j_sgdsj,
            ys_jsgdjg = EliminateFXModel.time.ys_jsgdjg
        }
        --M.PrintItemMap(item_map, "JJJJJJJJJJJJ")
        EliminateFXAnimManager.ScrollLottery(item_map, times,true)
        local new_map = EliminateFXModel.data.eliminate_data.result[index].map_base
        local times = {
            ys_j_sgdjg = EliminateFXModel.time.ys_j_sgdjg,
            ys_ysgdsj = EliminateFXModel.time.ys_ysgdsj * 1.5,
            ys_ysgdsj_add = EliminateFXModel.time.ys_ysgdsj_add,
        }
        EliminateFXAnimManager.StopScrollLottery(
            new_map,
            function()
            end,
            times
        )
    end)
    local times = {
        ys_j_sgdsj = EliminateFXModel.time.ys_j_sgdsj,
        ys_j_sgdjg = EliminateFXModel.time.ys_j_sgdjg,
        ys_ysgdsj = EliminateFXModel.time.ys_ysgdsj * 1.5,
    }
    local tt = EliminateFXModel.GetTime(times.ys_ysgdsj) +
    5 * EliminateFXModel.GetTime(times.ys_j_sgdjg) +
    EliminateFXModel.GetTime(times.ys_j_sgdsj) +
    EliminateFXModel.GetTime(times.ys_j_sgdsj / 4)

    seq:AppendInterval(tt + 0.5)
end


function M.RefreshView(data, seq)
    seq:AppendCallback(function(  )
        dump(data, "<color=red>WWWWWWWWWWWWWWWW RefreshView</color>")
        if not table_is_null(data.map_base) then
            if data.state == EliminateFXModel.xc_state.nor then
                EliminateFXObjManager.ClearEliminateItem()
                EliminateFXObjManager.CreateEliminateItem(data.map_base)
            elseif data.state == EliminateFXModel.xc_state.big_game then
                --if not table_is_null(data.special_list) then
                    EliminateFXObjManager.ClearEliminateItem()
                    -- LittleTips.Create("+++++++++++++++++"..data.free_times)
                    EliminateFXObjManager.CreateEliminateItem(data.map_base,data.free_times == 8)
                    --[[local tab1 = {}
                    for i=1,#data.special_list do
                        tab1[data.special_list[i].x] = tab1[data.special_list[i].x] or {}
                        tab1[data.special_list[i].x][data.special_list[i].y] = data.special_list[i].v
                    end
                    for x=1,eliminate_fx_algorithm.wide_max do
                        for y=1,eliminate_fx_algorithm.high_max do
                            if data.map_base[x] and data.map_base[x][y] and data.map_base[x][y] >= 100 and (not tab1[x] or not tab1[x][y]) then
                                local tab = {}
                                tab[x] = {}
                                tab[x][y] = data.map_base[x][y]
                                LittleTips.Create(x.."_"..y)
                                EliminateFXObjManager.AddBoatEliminateItem(tab)
                            end
                        end
                    end
                    --]]
                --end
            end
        end
        -- EliminateFXPartManager.ClearAll()
        --改变元素
        if table_is_null(data.xc_change_data) then
            return
        end
        --M.RemoveEliminateItem(data.xc_change_data)
        --M.AddEliminateItem(data.xc_change_data,nil)
    end)
    seq:AppendInterval(0.1)
end

function M.DelList(data, seq)
    --正常消除
    if table_is_null(data.del_list) then
        return
    end
    for i = 1, #data.del_list do
        local cur_del_map = data.del_list[i]
        local cur_rate = data.del_rate_list[i]
        M.DelListTrigger(data, cur_del_map, cur_rate, seq, i)
    end
end

function M.DelListTrigger(data, cur_del_map, cur_rate, seq, index)
    if table_is_null(cur_del_map) then
        return
    end
    local pd = M.GetParticleDataEliminate(data, cur_del_map, index)
    local cru_del_list = eliminate_fx_algorithm.change_map_to_list(cur_del_map)
    seq:AppendCallback(
        function()
            --消除音效
            M.PlaySoundByEliminateCount(pd.xc_c)
            M.PlayParticleEliminate(pd, cur_del_map, cur_rate)
        end
    )
    seq:AppendInterval(EliminateFXModel.GetTime(EliminateFXModel.time.xc_pt))
    if cur_rate > 0 then
        seq:AppendCallback(
            function()
                --元素消除
                M.RemoveEliminateItem(cur_del_map)
                Event.Brocast("view_lottery_award", {cur_del_map = cur_del_map, cur_rate = cur_rate})
            end
        )
        seq:AppendInterval(EliminateFXModel.GetTime(EliminateFXModel.time.xc_xyz))
    end
end

function M.DelListEnd(data, seq)
    --结束本次消除
    if not table_is_null(data.trigger_list) then
        seq:AppendCallback(function ()
            EliminateFXPartManager.CreateLuckyRight(data.trigger_list,EliminateFXModel.GetTime(EliminateFXModel.time.xc_hf_sg))
            for x,_v in pairs(data.trigger_list) do
                for y,v in pairs(_v) do
                    item_map[x][y]:ShowScore()
                end
            end
        end)
        seq:AppendInterval(EliminateFXModel.GetTime(EliminateFXModel.time.xc_hf_sg))
        seq:AppendCallback(function ()
            EliminateFXPartManager.HFfly(data.trigger_list,function ()
                ExtendSoundManager.PlaySound(audio_config.fxgz.bgm_fxgz_zhuangji.audio_name)
                EliminateFXAnimManager.DOShakePositionCamer(nil,EliminateFXModel.GetTime(1),nil,function ()
                    Event.Brocast("hf_had_fly_finish_msg")
                end)
            end)
        end)
        seq:AppendInterval(EliminateFXModel.GetTime(2))
    end
    
    seq:AppendCallback(
        function()
            M.EliminateItemDown()
        end
    )
    seq:AppendInterval(EliminateFXModel.GetTime(EliminateFXModel.time.ys_jxlh))
    --本局结束有map_add
    dump(data.map_add,"<color=yellow><size=15>++++++++++本局结束有map_add++++++++++</size></color>")
    if data.map_add then
        seq:AppendCallback(
            function()
                --M.PrintItemMap(data.map_add, "data.map_add")
                M.CreateEliminateItemDown(data.map_add)
                M.EliminateItemDownNew(data.map_add,function ()
                    --ExtendSoundManager.PlaySound(audio_config.cbzz.bgm_cbzz_luoxia.audio_name)
                end)
            end
        )
        seq:AppendInterval(EliminateFXModel.GetTime(EliminateFXModel.time.ys_xxlh))
     --新元素下落时间
    end
    seq:AppendCallback(
        function()
            --M.ClearEliminateItem()
            --M.CreateEliminateItem(data.map_new)
            M.EliminateItemMoneyAni(data.map_add)
        end
    )
    --掉落完成开始消除下一屏的元素
    seq:AppendInterval(EliminateFXModel.GetTime(EliminateFXModel.time.xc_xyp))
end

function M.LotteryEnd(data, index, seq, callback)
    --普通开奖结束
    seq:OnKill(
        function()
            if callback and type(callback) == "function" then
                callback()
            end
        end
    )
end

function M.EliminateItemMoneyAni(map_add)
    if table_is_null(item_map) or table_is_null(map_add) then return end
    for x,_v in pairs(map_add) do
        for y,v in pairs(_v) do
            local item = M.GetEliminateItem(x,y)
        end
    end
end

function M.AddBoatEliminateItem(data)
    if table_is_null(data) then
        return
    end
    --dump(boat_item_map)
    --print("<color=red>HHHHHHHHHHHHHHHHHHHH 1</color>")
    --dump(data,"<color=yellow><size=15>++++++++++AddBoatEliminateItem++++++++++</size></color>")
    --dump(boat_item_map,"<color=yellow><size=15>++++++++++boat_item_map++++++++++</size></color>")
    local add_item_map = {}
    for x, _v in pairs(data) do
        for y, v in pairs(_v) do
            --[[if boat_item_map[x] then
                dump(boat_item_map[x][y],"<color=yellow><size=15>++++++++++boat_item_map[x][y]++++++++++</size></color>")
            end--]]
            if boat_item_map[x] and boat_item_map[x][y] then
                if IsEquals(boat_item_map[x][y].ui.transform) then
                    boat_item_map[x][y].ui.transform:SetSiblingIndex(100)
                    boat_item_map[x][y]:SetBG()
                else
                    boat_item_map[x][y]:Exit()
                    boat_item_map[x] = boat_item_map[x] or {}
                    boat_item_map[x][y] = EliminateFXItem.Create({x = x, y = y, id = v, is_down = is_down,type = "hscb"})
                    add_item_map[x] = add_item_map[x] or {}
                    add_item_map[x][y] = boat_item_map[x][y]
                end
            else
                boat_item_map[x] = boat_item_map[x] or {}
                boat_item_map[x][y] = EliminateFXItem.Create({x = x, y = y, id = v, is_down = is_down,type = "hscb"})
                add_item_map[x] = add_item_map[x] or {}
                add_item_map[x][y] = boat_item_map[x][y]
                -- M.RefreshEliminateBG(data)
            end
        end
    end
    --dump(boat_item_map)
    return add_item_map
end

function M.RemoveBoatEliminateItem()
    if (EliminateFXModel.data.state ~= EliminateFXModel.xc_state.big_game) then return end
    --print("<color=red>GGGGGGGGGGGGGGGGGGGGG 3</color>")
    --dump(item_map,"<color=blue><size=15>++++++++++item_map++++++++++</size></color>")
    --dump(boat_item_map)
    local new_map = {}
    for x, _v in pairs(item_map) do
        for y, v in pairs(_v) do
            local index = eliminate_fx_algorithm.get_index_by_pos(v.ui.transform.localPosition.x, v.ui.transform.localPosition.y)
            
            if index.x < 1 or index.x > EliminateFXModel.size.max_x 
                or index.y < 1 or index.y > EliminateFXModel.size.max_y then
                v:Exit()
            else
                if boat_item_map[index.x] and boat_item_map[index.x][index.y] then
                    v:Exit()
                else
                    new_map[index.x] = new_map[index.x] or {}
                    new_map[index.x][index.y] = v
                end
            end
        end
    end
    --M.PrintItemMap(new_map, "AA")
    --M.PrintItemMap(boat_item_map, "BB")
    -- 上层的
    --dump(item_map,"<color=blue><size=15>++++++++++item_map++++++++++</size></color>")
    for x, _v in pairs(boat_item_map) do
        for y, v in pairs(_v) do
            if new_map[x] then
                new_map[x][y] = boat_item_map[x][y]
            end
        end
    end
    --M.PrintItemMap(new_map, "CC")
    
    item_map = new_map

    boat_item_map = {}
end

local font_map = {
    [100] = "fxgz_imgf_szh",
    [101] = "fxgz_imgf_szlan",
    [102] = "fxgz_imgf_szlv",
    [103] = "fxgz_imgf_szz",
}

function M.RefreshAllScore(rateMap, map_new)
    dump(rateMap, "<color=white>刷新倍率显示</color>")
    dump(debug.traceback())
    for i = 1, #map_new do
        for j = 1, #map_new[i] do
		    local id = map_new[i][j]
            if rateMap[i] and rateMap[i][j] and rateMap[i][j] > 0 then
                M.RefreshScore(i, j, map_new[i][j], rateMap[i][j], false, false)
            end
        end
    end
end

function M.RefreshScore(x, y, id, num, isNeedScaleAnim, isPlaySound)
    if not score_map[x][y].obj then
        local pos = eliminate_fx_algorithm.get_pos_by_index(x, y)
        local score_item = {}
        local fontName = font_map[id]
        local obj = newObject("EliminateFXScore", M.GetScoreContent())
        obj.transform.localPosition = Vector3.New(pos.x, pos.y, 0)
        score_map[x][y].obj = obj
        score_map[x][y].ui.num_txt = obj.transform:Find("ScoreTxt"):GetComponent("Text")
        if fontName then
            score_map[x][y].ui.num_txt.font = GetFont(fontName)
        end
    end
    score_map[x][y].ui.num_txt.text = num
    EliminateFXAnimManager.RefreshScore(score_map[x][y].ui.num_txt, isNeedScaleAnim)

    if isPlaySound then
        -- ExtendSoundManager.PlaySound(audio_config.fxgz.bgm_fxgz_caishen.audio_name)
    end
end

function M.HideScore(x, y)
    if score_map[x][y].obj then
        score_map[x][y].obj.gameObject:SetActive(false)
    end
end