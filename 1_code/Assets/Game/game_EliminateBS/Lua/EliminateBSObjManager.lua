local basefunc = require "Game.Common.basefunc"
EliminateBSObjManager = {}
local M = EliminateBSObjManager
package.loaded["Game.game_EliminateBS.Lua.EliminateBSItem"] = nil
require "Game.game_EliminateBS.Lua.EliminateBSItem"
package.loaded["Game.game_EliminateBS.Lua.EliminateBSItemBG"] = nil
require "Game.game_EliminateBS.Lua.EliminateBSItemBG"
local item_map = {}
local item_map_hscb = {}
local boat_item_map = {}
-- local item_map_ccjj = {}
local bg_map = {}
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
    M.ItemContent = GameObject.Find("ItemContent")
    if IsEquals(M.ItemContent) then
        return M.ItemContent.transform
    end
end

function M.GetBGContent()
    if not IsEquals(M.BGContent) then
        M.BGContent = GameObject.Find("BGContent")
    end
    if IsEquals(M.BGContent) then
        return M.BGContent.transform
    end
end

M.item_obj = {
    EliminateBSItem = newObject("EliminateBSItem", M.GetRoot()),
    
    EliminateBSItemBG = newObject("EliminateBSItemBG", M.GetRoot()),
    
    xxl_icon_1 = GetTexture("bsmz_icon_lanbs"),
    xxl_icon_2 = GetTexture("bsmz_icon_lbs"),
    xxl_icon_3 = GetTexture("bsmz_icon_hongbs"),
    xxl_icon_4 = GetTexture("bsmz_icon_zbs"),
    xxl_icon_5 = GetTexture("bsmz_icon_hbs"),
    xxl_icon_200 = GetTexture(""),
    xxl_icon_201 = GetTexture("bsmz_icon_lanbs"),
    xxl_icon_202 = GetTexture("bsmz_icon_lbs"),
    xxl_icon_203 = GetTexture("bsmz_icon_hongbs"),
    xxl_icon_204 = GetTexture("bsmz_icon_zbs"),
    xxl_icon_205 = GetTexture("bsmz_icon_hbs"),
    xxl_icon_210 = GetTexture(""),
    xxl_icon_211 = GetTexture("bsmz_icon_lanbs"),
    xxl_icon_212 = GetTexture("bsmz_icon_lbs"),
    xxl_icon_213 = GetTexture("bsmz_icon_hongbs"),
    xxl_icon_214 = GetTexture("bsmz_icon_zbs"),
    xxl_icon_215 = GetTexture("bsmz_icon_hbs"),
    xxl_icon_220 = GetTexture(""),
    xxl_icon_221 = GetTexture("bsmz_icon_lanbs"),
    xxl_icon_222 = GetTexture("bsmz_icon_lbs"),
    xxl_icon_223 = GetTexture("bsmz_icon_hongbs"),
    xxl_icon_224 = GetTexture("bsmz_icon_zbs"),
    xxl_icon_225 = GetTexture("bsmz_icon_hbs"),

    
    sdbgj_icon_dj1 = GetTexture("bsmz_icon_lanbs"),
    sdbgj_icon_dj2 = GetTexture("bsmz_icon_lbs"),
    sdbgj_icon_dj3 = GetTexture("bsmz_icon_hongbs"),
    sdbgj_icon_dj4 = GetTexture("bsmz_icon_zbs"),
    sdbgj_icon_dj5 = GetTexture("bsmz_icon_hbs"),
    sdbgj_icon_dj200 = GetTexture(""),
    sdbgj_icon_dj201 = GetTexture("bsmz_icon_lanbs"),
    sdbgj_icon_dj202 = GetTexture("bsmz_icon_lbs"),
    sdbgj_icon_dj203 = GetTexture("bsmz_icon_hongbs"),
    sdbgj_icon_dj204 = GetTexture("bsmz_icon_zbs"),
    sdbgj_icon_dj205 = GetTexture("bsmz_icon_hbs"),
    sdbgj_icon_dj210 = GetTexture(""),
    sdbgj_icon_dj211 = GetTexture("bsmz_icon_lanbs"),
    sdbgj_icon_dj212 = GetTexture("bsmz_icon_lbs"),
    sdbgj_icon_dj213 = GetTexture("bsmz_icon_hongbs"),
    sdbgj_icon_dj214 = GetTexture("bsmz_icon_zbs"),
    sdbgj_icon_dj215 = GetTexture("bsmz_icon_hbs"),
    sdbgj_icon_dj220 = GetTexture(""),
    sdbgj_icon_dj221 = GetTexture("bsmz_icon_lanbs"),
    sdbgj_icon_dj222 = GetTexture("bsmz_icon_lbs"),
    sdbgj_icon_dj223 = GetTexture("bsmz_icon_hongbs"),
    sdbgj_icon_dj224 = GetTexture("bsmz_icon_zbs"),
    sdbgj_icon_dj225 = GetTexture("bsmz_icon_hbs"),
    material_FrontBlur = GetMaterial("FrontBlur"),
}


M.bshj_item_obj = {
    bshj_icon_1 = GetTexture("bsxyx_icon_hong1"),
    bshj_icon_2 = GetTexture("bsxyx_icon_hong2"),
    bshj_icon_3 = GetTexture("bsxyx_icon_hong3"),
    bshj_icon_4 = GetTexture("bsxyx_icon_hong4"),
    bshj_icon_5 = GetTexture("bsxyx_icon_hong5"),

    bshj_icon_6 = GetTexture("bsxyx_icon_huang1"),
    bshj_icon_7 = GetTexture("bsxyx_icon_huang2"),
    bshj_icon_8 = GetTexture("bsxyx_icon_huang3"),
    bshj_icon_9 = GetTexture("bsxyx_icon_huang4"),
    bshj_icon_10 = GetTexture("bsxyx_icon_huang5"),

    bshj_icon_11 = GetTexture("bsxyx_icon_lan1"),
    bshj_icon_12 = GetTexture("bsxyx_icon_lan2"),
    bshj_icon_13 = GetTexture("bsxyx_icon_lan3"),
    bshj_icon_14 = GetTexture("bsxyx_icon_lan4"),
    bshj_icon_15 = GetTexture("bsxyx_icon_lan5"),

    bshj_icon_16 = GetTexture("bsxyx_icon_lv1"),
    bshj_icon_17 = GetTexture("bsxyx_icon_lv2"),
    bshj_icon_18 = GetTexture("bsxyx_icon_lv3"),
    bshj_icon_19 = GetTexture("bsxyx_icon_lv4"),
    bshj_icon_20 = GetTexture("bsxyx_icon_lv5"),

    bshj_icon_21 = GetTexture("bsxyx_icon_zi1"),
    bshj_icon_22 = GetTexture("bsxyx_icon_zi2"),
    bshj_icon_23 = GetTexture("bsxyx_icon_zi3"),
    bshj_icon_24 = GetTexture("bsxyx_icon_zi4"),
    bshj_icon_25 = GetTexture("bsxyx_icon_zi5"),

    bshj_icon_26 = GetTexture("bsxyx_icon_bx2"),
    bshj_icon_27 = GetTexture("bsxyx_icon_bx1"),
    bshj_icon_28 = GetTexture("bsxyx_icon_bx1"),
    bshj_icon_29 = GetTexture("bsxyx_icon_bx1"),
    bshj_icon_30 = GetTexture("bsxyx_icon_bx1"),
    bshj_icon_31 = GetTexture("bsxyx_icon_bx1"),

    bshj_icon_desc = GetTexture("xyx_icon_2"),
}

M.delete_obj = {
    EliminateBSItem = M.item_obj.EliminateBSItem,
    EliminateXYItemPhysics = M.item_obj.EliminateXYItemPhysics,
    EliminateBSItemBG = M.item_obj.EliminateBSItemBG,
}

M.clear_obj = {
    xxl_icon_1 = M.item_obj.xxl_icon_1,
    xxl_icon_2 = M.item_obj.xxl_icon_2,
    xxl_icon_3 = M.item_obj.xxl_icon_3,
    xxl_icon_4 = M.item_obj.xxl_icon_4,
    xxl_icon_5 = M.item_obj.xxl_icon_5,
    xxl_icon_200 = M.item_obj.xxl_icon_200,
    xxl_icon_201 = M.item_obj.xxl_icon_201,
    xxl_icon_202 = M.item_obj.xxl_icon_202,
    xxl_icon_203 = M.item_obj.xxl_icon_203,
    xxl_icon_204 = M.item_obj.xxl_icon_204,
    xxl_icon_205 = M.item_obj.xxl_icon_205,
    xxl_icon_210 = M.item_obj.xxl_icon_210,
    xxl_icon_211 = M.item_obj.xxl_icon_211,
    xxl_icon_212 = M.item_obj.xxl_icon_212,
    xxl_icon_213 = M.item_obj.xxl_icon_213,
    xxl_icon_214 = M.item_obj.xxl_icon_214,
    xxl_icon_215 = M.item_obj.xxl_icon_215,
    xxl_icon_220 = M.item_obj.xxl_icon_220,
    xxl_icon_221 = M.item_obj.xxl_icon_221,
    xxl_icon_222 = M.item_obj.xxl_icon_222,
    xxl_icon_223 = M.item_obj.xxl_icon_223,
    xxl_icon_224 = M.item_obj.xxl_icon_224,
    xxl_icon_225 = M.item_obj.xxl_icon_225,

    sdbgj_icon_dj1 = M.item_obj.sdbgj_icon_dj1,
    sdbgj_icon_dj2 = M.item_obj.sdbgj_icon_dj2,
    sdbgj_icon_dj3 = M.item_obj.sdbgj_icon_dj3,
    sdbgj_icon_dj4 = M.item_obj.sdbgj_icon_dj4,
    sdbgj_icon_dj5 = M.item_obj.sdbgj_icon_dj5,
    sdbgj_icon_dj200 = M.item_obj.sdbgj_icon_dj200,
    sdbgj_icon_dj201 = M.item_obj.sdbgj_icon_dj201,
    sdbgj_icon_dj202 = M.item_obj.sdbgj_icon_dj202,
    sdbgj_icon_dj203 = M.item_obj.sdbgj_icon_dj203,
    sdbgj_icon_dj204 = M.item_obj.sdbgj_icon_dj204,
    sdbgj_icon_dj205 = M.item_obj.sdbgj_icon_dj205,
    sdbgj_icon_dj210 = M.item_obj.sdbgj_icon_dj210,
    sdbgj_icon_dj211 = M.item_obj.sdbgj_icon_dj211,
    sdbgj_icon_dj212 = M.item_obj.sdbgj_icon_dj212,
    sdbgj_icon_dj213 = M.item_obj.sdbgj_icon_dj213,
    sdbgj_icon_dj214 = M.item_obj.sdbgj_icon_dj214,
    sdbgj_icon_dj215 = M.item_obj.sdbgj_icon_dj215,
    sdbgj_icon_dj220 = M.item_obj.sdbgj_icon_dj220,
    sdbgj_icon_dj221 = M.item_obj.sdbgj_icon_dj221,
    sdbgj_icon_dj222 = M.item_obj.sdbgj_icon_dj222,
    sdbgj_icon_dj223 = M.item_obj.sdbgj_icon_dj223,
    sdbgj_icon_dj224 = M.item_obj.sdbgj_icon_dj224,
    sdbgj_icon_dj225 = M.item_obj.sdbgj_icon_dj225,
}

function M.InstantiateObj()
    for k, v in pairs(EliminateBSModel.eliminate_enum) do
        local _obj = GameObject.Instantiate(M.item_obj.EliminateBSItem, M.GetRoot())
        local img = _obj.gameObject.transform:Find("@icon_img"):GetComponent("Image")
        img.sprite = M.item_obj["xxl_icon_" .. v]
        M.item_obj["EliminateBSItem" .. v] = _obj
        M.delete_obj["EliminateBSItem" .. v] = _obj

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
    for x, _v in pairs(bg_map) do
        for y, v in pairs(_v) do
            v:Exit()
        end
    end
    bg_map = {}
    M.root = nil
    M.ItemContent = nil
    M.BGContent = nil
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
    --for x, _v in pairs(M.item_obj) do
    --  M.item_obj[x] = nil
    --end
    --M.item_obj = {}

    for x, _v in pairs(M.clear_obj) do
        M.clear_obj [x] = nil
    end
    M.clear_obj  = {}
    for x, _v in pairs(M.delete_obj) do
        if IsEquals(_v) then
            destroy(_v.gameObject)
        end
        M.delete_obj [x] = nil
    end
    M.delete_obj  = {}
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
end

--item下滑
function M.EliminateItemDown(callback)
    local new_item_map = {}
    local new_special_part_map = {}
    local tab = {}
    local temp_tab = {}
    local new_y = 1
    local tab_tab = {}
    local index = eliminate_bs_algorithm.get_map_max_index(item_map)
    for x = 1, index.x do
        new_y = 1
        for y = 1, index.y do
            if item_map[x] and item_map[x][y] then
                new_item_map[x] = new_item_map[x] or {}
                new_item_map[x][new_y] = item_map[x][y]
                if EliminateBSPartManager.special_map[x] and EliminateBSPartManager.special_map[x][y] then
                    new_special_part_map[x] = new_special_part_map[x] or {}
                    new_special_part_map[x][new_y] = EliminateBSPartManager.special_map[x][y]
                end
                new_y = new_y + 1
            end
        end
    end
    item_map = new_item_map
    EliminateBSPartManager.special_map = new_special_part_map
    EliminateBSAnimManager.EliminateItemDown(new_item_map, new_special_part_map, callback)
end

function M.EliminateItemDownNew(map, callback)
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
        EliminateBSAnimManager.Spring(new_item_map, EliminateBSModel.GetTime(EliminateBSModel.time.ys_xxldd), callback)
    end
    EliminateBSAnimManager.EliminateItemDown(new_item_map,nil, _callback)
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
            if v < 220 then
                item_map[x][y] = EliminateBSItem.Create({x = x, y = y, id = v, is_down = is_down,type = "nor"})
            else
                local temp_num_1 = tostring(v)
                local _id = string.sub(temp_num_1,1,3)
                item_map[x][y] = EliminateBSItem.Create({x = x, y = y, id = tonumber(_id), is_down = is_down,type = "nor"})
            end
            add_item_map[x] = add_item_map[x] or {}
            add_item_map[x][y] = item_map[x][y]
        end
    end
    --M.PrintItemMap(item_map_hscb, "BBBBBBBBBBBBBBBBBB")
    return add_item_map
end

function M.AddEliminateItem_Special(data)
    if table_is_null(data) then
        return
    end
    local x = data.x
    local y = data.y
    local v = data.id
    if item_map[x] and item_map[x][y] then
        item_map[x][y]:Exit()
    end
    item_map[x] = item_map[x] or {}
    if v >= 200 then
        item_map[x][y] = EliminateBSItem.Create({x = x, y = y, id = v, is_down = is_down,type = "nor"})
        EliminateBSPartManager.AddEliminateItem_SpecialTX({x = x,y = y,id = v})
    else
        local temp_num_1 = tostring(v)
        local _id = string.sub(temp_num_1,1,3)
        item_map[x][y] = EliminateBSItem.Create({x = x, y = y, id = tonumber(_id), is_down = is_down,type = "nor"})
    end
end

function M.RemoveEliminateItem(data,callback,special_map)
    if table_is_null(data) then
        return
    end
    local seq = DoTweenSequence.Create()
    local time = 0
    if special_map then
        time = 1.7
    end
    seq:AppendInterval(EliminateBSModel.GetTime(time))
    seq:AppendCallback(function ()
        for x, _v in pairs(data) do
            for y, v in pairs(_v) do
                if item_map[x] and item_map[x][y] then
                    item_map[x][y]:Exit()
                    item_map[x][y] = nil
                    EliminateBSPartManager.RemoveEliminateItem_SpecialTX({x = x,y = y,id = v})
                end
            end
        end
        if callback then
            callback()
        end
    end)
end

function M.AddBoatEliminateItem(data, is_down)
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
            if boat_item_map[x] and boat_item_map[x][y] then
                if IsEquals(boat_item_map[x][y].ui.transform) then
                    boat_item_map[x][y].ui.transform:SetSiblingIndex(100)
                    boat_item_map[x][y]:LitBoat(true)
                else
                    boat_item_map[x][y]:Exit()
                    boat_item_map[x] = boat_item_map[x] or {}
                    boat_item_map[x][y] = EliminateBSItem.Create({x = x, y = y, id = v, is_down = is_down,type = "hscb"})
                    add_item_map[x] = add_item_map[x] or {}
                    add_item_map[x][y] = boat_item_map[x][y]
                end
            else
                boat_item_map[x] = boat_item_map[x] or {}
                boat_item_map[x][y] = EliminateBSItem.Create({x = x, y = y, id = v, is_down = is_down,type = "hscb"})
                add_item_map[x] = add_item_map[x] or {}
                add_item_map[x][y] = boat_item_map[x][y]
                -- M.RefreshEliminateBG(data)
            end
        end
    end
    --dump(boat_item_map)
    return add_item_map
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

function M.InitEliminateBG(max_x, max_y)
    local map = {}
    for y = 1, max_y do
        for x = 1, max_x do
            map[x] = map[x] or {}
            map[x][y] = 1
        end
    end
    M.AddEliminateBG(map)
end

function M.AddEliminateBG(data)
    if table_is_null(data) then
        return
    end
    for x, _v in pairs(data) do
        for y, v in pairs(_v) do
            bg_map[x] = bg_map[x] or {}
            bg_map[x][y] = EliminateBSItemBG.Create({x = x, y = y})
        end
    end
end

function M.RemoveEliminateBG(data)
    if table_is_null(data) then
        return
    end
    for x, _v in pairs(data) do
        for y, v in pairs(_v) do
            if bg_map[x] and bg_map[x][y] then
                bg_map[x][y]:Exit(data)
            end
        end
    end
end

function M.RefreshEliminateBG(data)
    if table_is_null(data) then
        return
    end
    for x, _v in pairs(data) do
        for y, v in pairs(_v) do
            if bg_map[x] and bg_map[x][y] then
                bg_map[x][y]:Refresh(data)
            end
        end
    end
end

--消除特效的类型和时间
function M.GetParticleDataEliminate(data, cur_del_map, index)
    local xc_c = eliminate_bs_algorithm.get_xc_count(cur_del_map)
    local xc_id = eliminate_bs_algorithm.get_xc_id(cur_del_map)
    local pd = {}
    pd.xc_c = xc_c
    pd.xc_id = xc_id
    return pd
end

function M.PlayParticleEliminateNull(cur_rate, hero_index)
    local index_y = hero_index + 2
    local data = {
        {x = 4, y = index_y, v = 6},
        {x = 5, y = index_y, v = 6}
    }
    EliminateBSPartManager.CreateNumGold(data, EliminateBSModel.GetAwardGold(cur_rate))
end

function M.PlayParticleEliminate(pd, cur_del_map, cur_rate)
    if table_is_null(cur_del_map) then
        return
    end
    local cru_del_list = eliminate_bs_algorithm.change_map_to_list(cur_del_map)
    local count = pd.xc_c
    local xc_id = tonumber(pd.xc_id)
    if false then
    else
        --普通消除特效
        if count <= 3 then
            EliminateBSPartManager.CreateEliminateNor1(cru_del_list, EliminateBSModel.GetAwardGold(cur_rate))
        else
            EliminateBSPartManager.CreateEliminateNor2(cru_del_list, 0--[[EliminateBSModel.GetAwardGold(cur_rate)--]])
        end
    end
end

local m_sort = function (v1,v2)
    if v1.x > v2.x then
        return true
    elseif v1.x == v2.x then
        if v1.y > v2.y then
            return true
        end
    end
end

function M.PlayParticleEliminate_2(pd, cur_del_map, cur_special_rate)
    if table_is_null(cur_special_rate) then
        return
    end
    --dump(cur_special_rate,"<color=yellow><size=15>++++++++++cur_special_rate++++++++++</size></color>")
    local cru_del_list = eliminate_bs_algorithm.change_map_to_list(cur_del_map)
    MathExtend.SortListCom(cru_del_list, m_sort)
    local count = pd.xc_c
    local tab1 = {}
    local tab2 = {}
    local tab3 = {}
    for k,v in pairs(cru_del_list) do
        if v.v >= 200 and v.v < 210 then
            tab1[#tab1 + 1] = v
        elseif v.v >= 210 and v.v < 220 then
            tab2[#tab2 + 1] = v
        elseif v.v >= 220 then
            tab3[#tab3 + 1] = v
        end
    end
    --dump(tab1,"<color=green><size=15>////tab1</size></color>")
    --dump(tab2,"<color=green><size=15>////tab2</size></color>")
    --dump(tab3,"<color=green><size=15>////tab3</size></color>")
    local tab = basefunc.deepcopy(cru_del_list)
    local tab1_1 = {}
    local tab2_2 = {}
    local tab3_3 = {}
    local used_map = {}
    --dump(cru_del_list,"<color=yellow><size=15>++++++++++cru_del_list++++++++++</size></color>")
    for k,v in pairs(tab) do
        for kk,vv in pairs(tab3) do
            local temp_num_1 = tostring(vv.v)
            local temp_num_2 = string.sub(temp_num_1,1,3)
            local _id = tonumber(temp_num_2) - 220
            if ((not used_map[v.x]) or (not used_map[v.x][v.y])) and ((vv.v == v.v) or (v.v == _id)) then
                tab3_3[#tab3_3 + 1] = v
                used_map[v.x] = used_map[v.x] or {}
                used_map[v.x][v.y] = v
            end
        end
    end
    local parameter_tab = {-1, 0, 1}
    for k,v in pairs(tab) do
        for kk,vv in pairs(tab2) do
            for i=1,#parameter_tab do
                for j=1,#parameter_tab do
                    local new_x = vv.x + parameter_tab[i]
                    local new_y = vv.y + parameter_tab[j]
                    if ((not used_map[new_x]) or (not used_map[new_x][new_y])) then
                        if v.x == new_x and v.y == new_y then
                            tab2_2[#tab2_2 + 1] = v
                            used_map[v.x] = used_map[v.x] or {}
                            used_map[v.x][v.y] = v
                        end
                    end
                end
            end
        end
    end
    for k,v in pairs(tab) do
        for kk,vv in pairs(tab1) do
            if ((not used_map[v.x]) or (not used_map[v.x][v.y])) and (vv.x == v.x) then
                tab1_1[#tab1_1 + 1] = v
                used_map[v.x] = used_map[v.x] or {}
                used_map[v.x][v.y] = v
            end
        end
    end
    --dump(tab1_1,"<color=red><size=15>////tab1_1</size></color>")
    --dump(tab2_2,"<color=red><size=15>////tab2_2</size></color>")
    --dump(tab3_3,"<color=red><size=15>////tab3_3</size></color>")
    local rate_tab1 = {}
    local rate_tab2 = {}
    local rate_tab3 = {}
    for k,v in pairs(tab1_1) do
        for kk,vv in pairs(cur_special_rate) do
            if eliminate_bs_algorithm.special_rate_map[v.v] and eliminate_bs_algorithm.special_rate_map[v.v] == vv * 10 then
                rate_tab1[#rate_tab1 + 1] = vv
            end
        end
    end
    for k,v in pairs(tab2_2) do
        for kk,vv in pairs(cur_special_rate) do
            if eliminate_bs_algorithm.special_rate_map[v.v] and eliminate_bs_algorithm.special_rate_map[v.v] == vv * 10 then
                rate_tab2[#rate_tab2 + 1] = vv
            end
        end
    end
    for k,v in pairs(tab3_3) do
        for kk,vv in pairs(cur_special_rate) do
            local temp_num_1 = tostring(v.v)
            local temp_num_2 = tonumber(string.sub(temp_num_1,1,3))
            if eliminate_bs_algorithm.special_rate_map[temp_num_2] and eliminate_bs_algorithm.special_rate_map[temp_num_2] == vv * 10 then
                rate_tab3[#rate_tab3 + 1] = vv
            end
        end
    end
    --dump(rate_tab1,"<color=yellow><size=15>++++1111111111+++++</size></color>")
    --dump(rate_tab2,"<color=yellow><size=15>++++2222222222+++++</size></color>")
    --dump(rate_tab3,"<color=yellow><size=15>++++3333333333+++++</size></color>")
    --dump(EliminateBSModel.GetAwardGold_2(rate_tab1),"<color=red><size=15>++++1111111111+++++</size></color>")
    --dump(EliminateBSModel.GetAwardGold_2(rate_tab2),"<color=red><size=15>++++2222222222+++++</size></color>")
    --dump(EliminateBSModel.GetAwardGold_2(rate_tab3),"<color=red><size=15>++++3333333333+++++</size></color>")
    EliminateBSPartManager.CreateEliminateNor1_2(tab1_1, EliminateBSModel.GetAwardGold_2(rate_tab1))
    EliminateBSPartManager.CreateEliminateNor2_2(tab2_2, EliminateBSModel.GetAwardGold_2(rate_tab2))
    EliminateBSPartManager.CreateEliminateNor3_2(tab3_3, EliminateBSModel.GetAwardGold_2(rate_tab3))
end

function M.PlaySoundByEliminateCount(c,cur_rate,cur_del_map)
    if c <= 3 then--三消
        ExtendSoundManager.PlaySound(audio_config.bsmz.bgm_bsmz_xiao3.audio_name)
    else
        if cur_rate then--合成
            ExtendSoundManager.PlaySound(audio_config.bsmz.bgm_bsmz_hecheng.audio_name)
        elseif not table_is_null(cur_del_map) then
            local one = false
            local two = false
            local three = false
            for k,v in pairs(cur_del_map) do
                for kk,vv in pairs(v) do
                    if (vv >= 200) and (vv < 210) then
                    one = true
                    elseif (vv >= 210) and (vv < 220) then
                        two = true
                    elseif (vv >= 220) then
                        three = true
                    end
                end
            end
            if one then--元素4消除
                ExtendSoundManager.PlaySound(audio_config.bsmz.bgm_bsmz_xiao4.audio_name)
            end
            if two then--元素5消除
                ExtendSoundManager.PlaySound(audio_config.bsmz.bgm_bsmz_xiao5.audio_name)
            end
            if three then--元素6消除
                ExtendSoundManager.PlaySound(audio_config.bsmz.bgm_bsmz_xiao6.audio_name)
            end
        end
    end
end

-------------------------------外部调用
function M.Lottery(index, callback,is_first)
    if EliminateBSModel.DataDamage() then
        return
    end
    if not EliminateBSModel.data or not EliminateBSModel.data.eliminate_data then return end
    local data = EliminateBSModel.data.eliminate_data.result[index]
    if not data then return end
    --print("<color=yellow>索引</color>",index)
    --dump(data)
    local seq = DoTweenSequence.Create()
    M.ShakeBefore(data,seq,index,is_first)
    M.RefreshView(data,seq)
    M.DelList(data, seq)
    M.DelListEnd(data, seq)
    M.LotteryEnd(data, index, seq, callback)
end

function M.ShakeBefore(data,seq,index,is_first)
    if is_first or not data.is_scroll then
        return
    end
    seq:AppendCallback(function(  )
        local item_map = EliminateBSObjManager.GetAllEliminateItem()
        local times = {
            ys_jsgdsj = EliminateBSModel.time.ys_jsgdsj,
            ys_ysgdjg = EliminateBSModel.time.ys_ysgdjg,
            ys_j_sgdsj = EliminateBSModel.time.ys_j_sgdsj,
            ys_jsgdjg = EliminateBSModel.time.ys_jsgdjg
        }
        --M.PrintItemMap(item_map, "JJJJJJJJJJJJ")
        EliminateBSAnimManager.ScrollLottery(item_map, times,true)
        local new_map = EliminateBSModel.data.eliminate_data.result[index].map_base
        local times = {
            ys_j_sgdjg = EliminateBSModel.time.ys_j_sgdjg,
            ys_ysgdsj = EliminateBSModel.time.ys_ysgdsj * 1.5,
            ys_ysgdsj_add = EliminateBSModel.time.ys_ysgdsj_add,
        }
        EliminateBSAnimManager.StopScrollLottery(
            new_map,
            function()
            end,
            times
        )
    end)
    local times = {
        ys_j_sgdsj = EliminateBSModel.time.ys_j_sgdsj,
        ys_j_sgdjg = EliminateBSModel.time.ys_j_sgdjg,
        ys_ysgdsj = EliminateBSModel.time.ys_ysgdsj * 1.5,
    }
    local tt = EliminateBSModel.GetTime(times.ys_ysgdsj) +
    5 * EliminateBSModel.GetTime(times.ys_j_sgdjg) +
    EliminateBSModel.GetTime(times.ys_j_sgdsj) +
    EliminateBSModel.GetTime(times.ys_j_sgdsj / 4)

    seq:AppendInterval(tt + 0.1)
end


function M.RefreshView(data, seq)
    seq:AppendCallback(function(  )
        --dump(data, "<color=red>WWWWWWWWWWWWWWWW RefreshView</color>")
        if not table_is_null(data.map_base) then
            EliminateBSObjManager.ClearEliminateItem()
            EliminateBSObjManager.CreateEliminateItem(data.map_base)
        end
        EliminateBSPartManager.ClearAll()
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
        local cur_rate
        if data.del_rate_list then
            cur_rate = data.del_rate_list[i]
        end
        local cur_special_rate
        if data.del_special_rate_list then
            cur_special_rate = data.del_special_rate_list[i]
        end
        local special_map
        if data.special_map then
            special_map = data.special_map[i]
        end
        M.DelListTrigger(data, cur_del_map, cur_rate, cur_special_rate, special_map, seq, i)
    end
end

function M.DelListTrigger(data, cur_del_map, cur_rate, cur_special_rate, special_map, seq, index)
    --dump(cur_del_map,"<color=yellow><size=15>++++++++++cur_del_map++++++++++</size></color>")
    --dump(special_map,"<color=yellow><size=15>++++++++++special_map++++++++++</size></color>")
    --dump(cur_rate,"<color=yellow><size=15>++++++++++cur_rate++++++++++</size></color>")
    --dump(cur_special_rate,"<color=yellow><size=15>++++++++++cur_special_rate++++++++++</size></color>")
    if table_is_null(cur_del_map) then
        return
    end
    local count = 0
    if not table_is_null(cur_special_rate) then
        count = #cur_special_rate
    end
    local pd = M.GetParticleDataEliminate(data, cur_del_map, index)

    seq:AppendCallback(
        --播消除特效
        function()
            --消除音效
            M.PlaySoundByEliminateCount(pd.xc_c,cur_rate,cur_del_map)
            if cur_rate then
                M.PlayParticleEliminate(pd, cur_del_map, cur_rate)
            elseif not table_is_null(cur_special_rate) then
                M.PlayParticleEliminate_2(pd, cur_del_map, cur_special_rate)
            end
        end
    )

    local wait_time = 0
    if not table_is_null(cur_special_rate) then
        wait_time = M.GetShouldWaitTime(cur_del_map)
    else
        if pd.xc_c <= 3 then
            wait_time = EliminateBSModel.GetTime(2)
        else
            wait_time = 0.8
        end
    end
    seq:AppendInterval(wait_time)

    seq:AppendCallback(
        function()
            --元素消除
            M.RemoveEliminateItem(cur_del_map,function ()
                local have_special = false
                local add_slider = false
                local temp_count = 0
                for k,v in pairs(cur_del_map) do
                    for kk,vv in pairs(v) do
                        if vv >= 200 then
                            have_special = true
                        else
                            temp_count = temp_count + 1
                        end
                    end
                end
                if temp_count <= 3 then
                    add_slider = true
                end
                if have_special then
                    for x=1,eliminate_bs_algorithm.wide_max do
                        if cur_del_map[x] then
                            for y=1,eliminate_bs_algorithm.high_max do
                                if cur_del_map[x][y] then
                                    if cur_del_map[x][y] >= 200 then
                                        local value = 0
                                        if (cur_del_map[x][y] >= 200) and (cur_del_map[x][y] < 210) then
                                            --value = eliminate_bs_algorithm.free_game_slider_value_add[200]
                                            value = eliminate_bs_algorithm.free_game_slider_value_add[cur_del_map[x][y]]
                                        elseif (cur_del_map[x][y] >= 210) and (cur_del_map[x][y] < 220) then
                                            --value = eliminate_bs_algorithm.free_game_slider_value_add[210]
                                            value = eliminate_bs_algorithm.free_game_slider_value_add[cur_del_map[x][y]]
                                        elseif cur_del_map[x][y] >= 220 then
                                            local temp_num_1 = tostring(cur_del_map[x][y])
                                            local temp_num_2 = string.sub(temp_num_1,1,3)
                                            --value = eliminate_bs_algorithm.free_game_slider_value_add[220] + (tonumber(temp_num_2) - 6) * 2
                                            value = eliminate_bs_algorithm.free_game_slider_value_add[tonumber(temp_num_2)]
                                        end
                                        Event.Brocast("eliminatebs_slider_change_msg",value)
                                    end
                                end
                            end
                        end
                    end
                end
                if add_slider then
                    for x=1,eliminate_bs_algorithm.wide_max do
                        if cur_del_map[x] then
                            for y=1,eliminate_bs_algorithm.high_max do
                                if cur_del_map[x][y] then
                                    if (not have_special) and (cur_del_map[x][y] < 200) then
                                        local value = eliminate_bs_algorithm.free_game_slider_value_add[cur_del_map[x][y]]
                                        Event.Brocast("eliminatebs_slider_change_msg",value)
                                        return
                                    end
                                end
                            end
                        end
                    end
                end
            end,special_map)
            if cur_rate then
                if pd.xc_c <= 3 then
                    Event.Brocast("view_lottery_award", {cur_del_map = cur_del_map, cur_rate = cur_rate})
                end
            elseif not table_is_null(cur_special_rate) then
                local index = 0
                for x=1,eliminate_bs_algorithm.wide_max do
                    if cur_del_map[x] then
                        for y=1,eliminate_bs_algorithm.high_max do
                            if cur_del_map[x][y] and cur_del_map[x][y] >= 200 then
                                index = index + 1
                                local _id = cur_del_map[x][y]
                                if cur_del_map[x][y] >= 220 then
                                    local temp_num_1 = tostring(cur_del_map[x][y])
                                    local temp_num_2 = string.sub(temp_num_1,1,3)
                                    _id = tonumber(temp_num_2)
                                end
                                local tab = {[x] = {[y] = _id}}
                                Event.Brocast("view_lottery_award", {cur_del_map = tab, cur_rate = cur_special_rate[index]})
                            end
                        end
                    end
                end
            end
        end
    )
    M.RefreshModelSliderValue(cur_del_map)
    if (EliminateBSModel.slider_value >= 100) and (not EliminateBSModel.slider_ani) then
        EliminateBSModel.slider_ani = true
        seq:AppendInterval(3)
        seq:AppendCallback(function () 
            EliminateBSAnimManager.DOShakePositionCamer(nil,EliminateBSModel.GetTime(1),nil,function ()
                Event.Brocast("hf_had_fly_finish_msg")
            end)
        end)
    end
    seq:AppendInterval(EliminateBSModel.GetTime(EliminateBSModel.time.xc_xyz))
    if special_map then
        seq:AppendCallback(
            function ()
                EliminateBSPartManager.CreateSpecialItemPart(special_map,function (_special_map)
                    M.AddEliminateItem_Special(_special_map)
                end)
            end
        )
        --[[M.RefreshModelSliderValue(2,special_map)
        if (EliminateBSModel.slider_value >= 100) and (not EliminateBSModel.slider_ani) then
            EliminateBSModel.slider_ani = true
            seq:AppendInterval(3)
            seq:AppendCallback(function ()   
                EliminateBSAnimManager.DOShakePositionCamer(nil,EliminateBSModel.GetTime(1),nil,function ()
                    Event.Brocast("hf_had_fly_finish_msg")
                end)
            end)
        end--]]
        seq:AppendInterval(EliminateBSModel.GetTime(1.8))
    end  
end

function M.RefreshModelSliderValue(data)
    if table_is_null(data) then return end
    local type = 1
    for k,v in pairs(data) do
        for kk,vv in pairs(v) do
            if vv >= 200 then
                type = 2
            end
        end
    end
    if type == 1 then
        local add_slider = true
        local temp_count = 0
        for k,v in pairs(data) do
            for kk,vv in pairs(v) do
                if vv >= 200 then
                    add_slider = false
                    break
                else
                    temp_count = temp_count + 1
                end
            end
        end
        if temp_count > 3 then
            add_slider = false
        end
        if add_slider then
            for x=1,eliminate_bs_algorithm.wide_max do
                if data[x] then
                    for y=1,eliminate_bs_algorithm.high_max do
                        if data[x][y] and data[x][y] < 200 then
                            local value = eliminate_bs_algorithm.free_game_slider_value_add[data[x][y]]
                            EliminateBSModel.slider_value = EliminateBSModel.slider_value + value
                            return
                        end
                    end
                end
            end
        end
    elseif type == 2 then
        for x=1,eliminate_bs_algorithm.wide_max do
            if data[x] then
                for y=1,eliminate_bs_algorithm.high_max do
                    if data[x][y] then
                        if data[x][y] >= 200 then
                            local value = 0
                            if (data[x][y] >= 200) and (data[x][y] < 210) then
                                --value = eliminate_bs_algorithm.free_game_slider_value_add[200]
                                value = eliminate_bs_algorithm.free_game_slider_value_add[data[x][y]]
                            elseif (data[x][y] >= 210) and (data[x][y] < 220) then
                                --value = eliminate_bs_algorithm.free_game_slider_value_add[210]
                                value = eliminate_bs_algorithm.free_game_slider_value_add[data[x][y]]
                            elseif data[x][y] >= 220 then
                                local temp_num_1 = tostring(data[x][y])
                                local temp_num_2 = string.sub(temp_num_1,1,3)
                                --value = eliminate_bs_algorithm.free_game_slider_value_add[220] + (tonumber(temp_num_2) - 6) * 2
                                value = eliminate_bs_algorithm.free_game_slider_value_add[tonumber(temp_num_2)]
                            end
                            EliminateBSModel.slider_value = EliminateBSModel.slider_value + value
                        end
                    end
                end
            end
        end
    end
end

function M.DelListEnd(data, seq)
    --结束本次消除
    seq:AppendCallback(
        function()
            M.EliminateItemDown()
        end
    )
    seq:AppendInterval(EliminateBSModel.GetTime(EliminateBSModel.time.ys_jxlh))

    --本局结束有map_add
    --dump(data.map_add,"<color=yellow><size=15>++++++++++本局结束有map_add++++++++++</size></color>")
    if data.map_add then
        seq:AppendCallback(
            function()
                --M.PrintItemMap(data.map_add, "data.map_add")
                M.CreateEliminateItemDown(data.map_add)
                M.EliminateItemDownNew(data.map_add,function ()
                    --ExtendSoundManager.PlaySound(audio_config.bsmz.bgm_cbzz_luoxia.audio_name)
                end)
            end
        )
        seq:AppendInterval(EliminateBSModel.GetTime(EliminateBSModel.time.ys_xxlh))
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
    seq:AppendInterval(EliminateBSModel.GetTime(EliminateBSModel.time.xc_xyp))
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

function M.LitEliminateItem(pos)
    if not table_is_null(item_map_hscb) then
        for i=1,#item_map_hscb do
            for j=1,#item_map_hscb[i] do
                if i == pos[1] and j == pos[2] then
                    item_map_hscb[i][j].data.id = 101
                end
            end
        end
        local _map = {}
        local max_x = EliminateBSModel.size.max_x
        local max_y = EliminateBSModel.size.max_y
        for x=1,max_x do
            for y=1,max_y do
                if item_map_hscb[x] and item_map_hscb[x][y] and item_map_hscb[x][y].data.id >= 100 then
                    _map[x] = _map[x] or {}
                    _map[x][y] = item_map_hscb[x][y].data.id
                end
            end
        end
        --EliminateBSObjManager.AddBoatEliminateItem(_map)
    end
end

function M.ClearLitFx()
    for k,v in pairs(item_map_hscb) do
        for _k,_v in pairs(v) do
            _v:LitBoat(false)
        end
    end
end

function M.GetShouldWaitTime(cur_del_map)
    local wait_time = 0
    for k,v in pairs(cur_del_map) do
        for kk,vv in pairs(v) do
            if vv >= 200 and vv < 210 then
                wait_time = math.max(wait_time,1.2)
            elseif vv >= 210 and vv < 220 then
                wait_time = math.max(wait_time,1.2)
            elseif vv >= 220 then
                wait_time = math.max(wait_time,2.2)
            end
        end
    end
    return wait_time
end