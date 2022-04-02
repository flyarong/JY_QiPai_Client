local basefunc = require "Game.Common.basefunc"
EliminateSGObjManager = {}
local M = EliminateSGObjManager
package.loaded["Game.game_EliminateSG.Lua.EliminateSGItem"] = nil
require "Game.game_EliminateSG.Lua.EliminateSGItem"
package.loaded["Game.game_EliminateSG.Lua.EliminateSGItemBG"] = nil
require "Game.game_EliminateSG.Lua.EliminateSGItemBG"
local item_map = {}
local item_map_hscb = {}
local boat_item_map = {}
local item_map_ccjj = {}
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
    if (EliminateSGModel.data.state == EliminateSGModel.xc_state.nor) or (EliminateSGModel.data.state == EliminateSGModel.xc_state.null) or (EliminateSGModel.data.state == EliminateSGModel.xc_state.select) then
        M.ItemContent = GameObject.Find("ItemContent")
    elseif (EliminateSGModel.data.state == EliminateSGModel.xc_state.hscb_2) or (EliminateSGModel.data.state == EliminateSGModel.xc_state.hscb_1) then
        M.ItemContent = GameObject.Find("ItemContent_hscb")
    elseif EliminateSGModel.data.state == EliminateSGModel.xc_state.ccjj_2 or (EliminateSGModel.data.state == EliminateSGModel.xc_state.ccjj_cs)then
        M.ItemContent = GameObject.Find("ItemContent_ccjj")
    end 
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
    EliminateSGItem = newObject("EliminateSGItem", M.GetRoot()),
    
    EliminateSGItemBG = newObject("EliminateSGItemBG", M.GetRoot()),
    
    xxl_icon_1 = GetTexture("img_lc"),
    xxl_icon_2 = GetTexture("img_yd"),
    xxl_icon_3 = GetTexture("img_tk"),
    xxl_icon_4 = GetTexture("img_kj"),
    xxl_icon_5 = GetTexture("img_zm"),
    xxl_icon_6 = GetTexture("img_hf"),
    xxl_icon_7 = GetTexture("img_chuan"),
    xxl_icon_hscb_1 = GetTexture("img_l_hscb"),
    xxl_icon_hscb_2 = GetTexture("img_yd_hscb"),
    xxl_icon_hscb_3 = GetTexture("img_tk_hscb"),
    xxl_icon_hscb_4 = GetTexture("img_kj_hscb"),
    xxl_icon_hscb_5 = GetTexture("img_zm_hscb"),
    xxl_icon_hscb_7 = GetTexture("img_chuan_hscb"),
    xxl_icon_hscb_100 = GetTexture("img_chuan_hscb"),
    xxl_icon_hscb_101 = GetTexture("img_chuan_hscb"),
    xxl_icon_hscb_102 = GetTexture("img_chuan_hscb"),
    xxl_icon_ccjj_1 = GetTexture("img_l_hscb"),
    xxl_icon_ccjj_2 = GetTexture("img_yd_hscb"),
    xxl_icon_ccjj_3 = GetTexture("img_tk_hscb"),
    xxl_icon_ccjj_4 = GetTexture("img_kj_hscb"),
    xxl_icon_ccjj_5 = GetTexture("img_zm_hscb"),
    xxl_icon_ccjj_8 = GetTexture("img_cc_ccjj"),
    xxl_icon_ccjj_9 = GetTexture("img_j_1_ccjj"),
    xxl_icon_ccjj_10 = GetTexture("img_j_2_ccjj"),
    xxl_icon_ccjj_11 = GetTexture("img_j_3_ccjj"),
    xxl_icon_ccjj_12 = GetTexture("img_j_4_ccjj"),
    xxl_swk_icon_10 = GetTexture("sdbgj_bg_sbjl"),
    xxl_swk_icon_11 = GetTexture("sdbgj_bg_ewjl"),
    xxl_swk_icon_12 = GetTexture("sdbgj_bg_zyyc"),
    sdbgj_icon_dj1 = GetTexture("img_lc"),
    sdbgj_icon_dj2 = GetTexture("img_yd"),
    sdbgj_icon_dj3 = GetTexture("img_tk"),
    sdbgj_icon_dj4 = GetTexture("img_kj"),
    sdbgj_icon_dj5 = GetTexture("img_zm"),
    sdbgj_icon_dj6 = GetTexture("img_hf"),
    sdbgj_icon_dj7 = GetTexture("img_lc_1"),
    sdbgj_icon_dj8 = GetTexture("img_yd_1"),
    sdbgj_icon_dj9 = GetTexture("img_tk_1"),
    sdbgj_icon_dj10 = GetTexture("img_kj_1"),
    sdbgj_icon_dj11 = GetTexture("img_zm_1"),
    sdbgj_icon_dj12 = GetTexture("img_hf_1"),
    material_FrontBlur = GetMaterial("FrontBlur"),
    xxl_icon_100 = GetTexture("cgxxl_btn_gz"),
    xxl_icon_101 = GetTexture("cgxxl_btn_gz"),
    xxl_icon_102 = GetTexture("cgxxl_btn_gz"),
}

M.delete_obj = {
    EliminateSGItem = M.item_obj.EliminateSGItem,
    EliminateXYItemPhysics = M.item_obj.EliminateXYItemPhysics,
    EliminateSGItemBG = M.item_obj.EliminateSGItemBG,
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
    xxl_icon_10 = M.item_obj.xxl_icon_10,
    xxl_icon_11 = M.item_obj.xxl_icon_11,
    xxl_icon_12 = M.item_obj.xxl_icon_12,
    xxl_swk_icon_9 = M.item_obj.xxl_swk_icon_9,
    xxl_swk_icon_10 = M.item_obj.xxl_swk_icon_10,
    xxl_swk_icon_11 = M.item_obj.xxl_swk_icon_11,
    xxl_swk_icon_12 = M.item_obj.xxl_swk_icon_12,
    sdbgj_icon_dj1 = M.item_obj.sdbgj_icon_dj1,
    sdbgj_icon_dj2 = M.item_obj.sdbgj_icon_dj2,
    sdbgj_icon_dj3 = M.item_obj.sdbgj_icon_dj3,
    sdbgj_icon_dj4 = M.item_obj.sdbgj_icon_dj4,
    sdbgj_icon_dj5 = M.item_obj.sdbgj_icon_dj5,
    sdbgj_icon_dj6 = M.item_obj.sdbgj_icon_dj6,
    sdbgj_icon_dj7 = M.item_obj.sdbgj_icon_dj7,
    sdbgj_icon_dj8 = M.item_obj.sdbgj_icon_dj8,
    sdbgj_icon_dj9 = M.item_obj.sdbgj_icon_dj9,
    sdbgj_icon_dj10 = M.item_obj.sdbgj_icon_dj10,
    sdbgj_icon_dj11 = M.item_obj.sdbgj_icon_dj11,
    sdbgj_icon_dj12 = M.item_obj.sdbgj_icon_dj12
}

function M.InstantiateObj()
    for k, v in pairs(EliminateSGModel.eliminate_enum) do
        local _obj = GameObject.Instantiate(M.item_obj.EliminateSGItem, M.GetRoot())
        local img = _obj.gameObject.transform:Find("@icon_img"):GetComponent("Image")
        img.sprite = M.item_obj["xxl_icon_" .. v]
        M.item_obj["EliminateSGItem" .. v] = _obj
        M.delete_obj["EliminateSGItem" .. v] = _obj

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
    if not table_is_null(item_map_hscb) then
        for x, _v in pairs(item_map_hscb) do
            for y, v in pairs(_v) do
                v:Exit()
            end
        end
    end
    item_map_hscb = {}
    if not table_is_null(boat_item_map) then
        for x, _v in pairs(boat_item_map) do
            for y, v in pairs(_v) do
                v:Exit()
            end
        end
    end
    boat_item_map = {}
    if not table_is_null(item_map_ccjj) then
        for x, _v in pairs(item_map_ccjj) do
            for y, v in pairs(_v) do
                v:Exit()
            end
        end
    end
    item_map_ccjj = {}
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

function M.Exit_hscb()
    if not table_is_null(item_map_hscb) then
        for x, _v in pairs(item_map_hscb) do
            for y, v in pairs(_v) do
                v:Exit()
            end
        end
    end
    item_map_hscb = {}
    if not table_is_null(boat_item_map) then
        for x, _v in pairs(boat_item_map) do
            for y, v in pairs(_v) do
                v:Exit()
            end
        end
    end
    boat_item_map = {}
end

function M.Exit_ccjj()
    if not table_is_null(item_map_ccjj) then
        for x, _v in pairs(item_map_ccjj) do
            for y, v in pairs(_v) do
                v:Exit()
            end
        end
    end
    item_map_ccjj = {}
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
    if (EliminateSGModel.data.state == EliminateSGModel.xc_state.nor) or (EliminateSGModel.data.state == EliminateSGModel.xc_state.null) or (EliminateSGModel.data.state == EliminateSGModel.xc_state.select) then
        for x, _v in pairs(item_map) do
            for y, v in pairs(_v) do
                v:Exit()
            end
        end
        item_map = {}
    elseif (EliminateSGModel.data.state == EliminateSGModel.xc_state.hscb_2) or (EliminateSGModel.data.state == EliminateSGModel.xc_state.hscb_1) then
        for x, _v in pairs(item_map_hscb) do
            for y, v in pairs(_v) do
                v:Exit()
            end
        end
        item_map_hscb = {}
    elseif (EliminateSGModel.data.state == EliminateSGModel.xc_state.ccjj_2) or (EliminateSGModel.data.state == EliminateSGModel.xc_state.ccjj_cs)then
        for x, _v in pairs(item_map_ccjj) do
            for y, v in pairs(_v) do
                v:Exit()
            end
        end
        item_map_ccjj = {}
    end
end

--item下滑
function M.EliminateItemDown(callback)
    local new_item_map = {}
    local tab = {}
    local temp_tab = {}
    local new_y = 1
    local tab_tab = {}
    if (EliminateSGModel.data.state == EliminateSGModel.xc_state.nor) or (EliminateSGModel.data.state == EliminateSGModel.xc_state.null) or (EliminateSGModel.data.state == EliminateSGModel.xc_state.select) then
        local index = eliminate_sg_algorithm.get_map_max_index(item_map)
        for x = 1, index.x do
            new_y = 1
            for y = 1, index.y do
                if item_map[x] and item_map[x][y] then
                    new_item_map[x] = new_item_map[x] or {}
                    new_item_map[x][new_y] = item_map[x][y]
                    new_y = new_y + 1
                end
            end
        end
        item_map = new_item_map
    elseif (EliminateSGModel.data.state == EliminateSGModel.xc_state.hscb_2) or (EliminateSGModel.data.state == EliminateSGModel.xc_state.hscb_1) then
        local _new_item_map = {}
        local index = eliminate_sg_algorithm.get_map_max_index(item_map_hscb)
        for x = 1, index.x do
            new_y = 1
            for y = 1, index.y do
                if item_map_hscb[x] and item_map_hscb[x][y] then
                    if item_map_hscb[x][y].data.id < 100 then
                        new_item_map[x] = new_item_map[x] or {}
                        new_item_map[x][new_y] = item_map_hscb[x][y]

                        _new_item_map[x] = _new_item_map[x] or {}
                        _new_item_map[x][new_y] = item_map_hscb[x][y]
                        new_y = new_y + 1
                    end
                    while (item_map_hscb[x][new_y] and item_map_hscb[x][new_y].data.id >= 100) do
                        _new_item_map[x] = _new_item_map[x] or {}
                        _new_item_map[x][new_y] = item_map_hscb[x][new_y]
                        new_y = new_y + 1
                    end
                end
            end
        end
        item_map_hscb = _new_item_map
    elseif (EliminateSGModel.data.state == EliminateSGModel.xc_state.ccjj_2) or (EliminateSGModel.data.state == EliminateSGModel.xc_state.ccjj_cs) then
        local index = eliminate_sg_algorithm.get_map_max_index(item_map_ccjj)
        for x = 1, index.x do
            new_y = 1
            for y = 1, index.y do
                if item_map_ccjj[x] and item_map_ccjj[x][y] then
                    new_item_map[x] = new_item_map[x] or {}
                    new_item_map[x][new_y] = item_map_ccjj[x][y]
                    new_y = new_y + 1
                end
            end
        end
        item_map_ccjj = new_item_map
    end 
    EliminateSGAnimManager.EliminateItemDown(new_item_map, callback)
end

function M.EliminateItemDownNew(map, callback)
   -- M.PrintItemMap(item_map_hscb, "GGG")
    local new_item_map = {}
    for x, _v in pairs(map) do
        for y, v in pairs(_v) do
            new_item_map[x] = new_item_map[x] or {}
            if (EliminateSGModel.data.state == EliminateSGModel.xc_state.nor) or (EliminateSGModel.data.state == EliminateSGModel.xc_state.null) or (EliminateSGModel.data.state == EliminateSGModel.xc_state.select) then
                new_item_map[x][y] = item_map[x][y]
            elseif (EliminateSGModel.data.state == EliminateSGModel.xc_state.hscb_2) or (EliminateSGModel.data.state == EliminateSGModel.xc_state.hscb_1) then
                new_item_map[x][y] = item_map_hscb[x][y]
            elseif (EliminateSGModel.data.state == EliminateSGModel.xc_state.ccjj_2) or (EliminateSGModel.data.state == EliminateSGModel.xc_state.ccjj_cs) then
                new_item_map[x][y] = item_map_ccjj[x][y]
            end
        end
    end
    --M.PrintItemMap(map, "map")
    --M.PrintItemMap(new_item_map, "HHHH")
    local function _callback()
        EliminateSGAnimManager.Spring(new_item_map, EliminateSGModel.GetTime(EliminateSGModel.time.ys_xxldd), callback)
    end
    EliminateSGAnimManager.EliminateItemDown(new_item_map, _callback)
end

function M.AddEliminateItem(data, is_down)
    if table_is_null(data) then
        return
    end
    local add_item_map = {}
    for x, _v in pairs(data) do
        for y, v in pairs(_v) do
            if (EliminateSGModel.data.state == EliminateSGModel.xc_state.nor) or (EliminateSGModel.data.state == EliminateSGModel.xc_state.null) or (EliminateSGModel.data.state == EliminateSGModel.xc_state.select) then
                if item_map[x] and item_map[x][y] then
                    item_map[x][y]:Exit()
                end
                item_map[x] = item_map[x] or {}
                item_map[x][y] = EliminateSGItem.Create({x = x, y = y, id = v, is_down = is_down,type = "nor"})
                add_item_map[x] = add_item_map[x] or {}
                add_item_map[x][y] = item_map[x][y]
            elseif EliminateSGModel.data.state == EliminateSGModel.xc_state.hscb_2 or (EliminateSGModel.data.state == EliminateSGModel.xc_state.hscb_1) then
                if item_map_hscb[x] and item_map_hscb[x][y] then
                    item_map_hscb[x][y]:Exit()
                end
                item_map_hscb[x] = item_map_hscb[x] or {}
                item_map_hscb[x][y] = EliminateSGItem.Create({x = x, y = y, id = v, is_down = is_down,type = "hscb"})
                add_item_map[x] = add_item_map[x] or {}
                add_item_map[x][y] = item_map_hscb[x][y]
            elseif (EliminateSGModel.data.state == EliminateSGModel.xc_state.ccjj_2) or (EliminateSGModel.data.state == EliminateSGModel.xc_state.ccjj_cs)  then
                if item_map_ccjj[x] and item_map_ccjj[x][y] then
                    item_map_ccjj[x][y]:Exit()
                end
                item_map_ccjj[x] = item_map_ccjj[x] or {}
                item_map_ccjj[x][y] = EliminateSGItem.Create({x = x, y = y, id = v, is_down = is_down,type = "ccjj"})
                add_item_map[x] = add_item_map[x] or {}
                add_item_map[x][y] = item_map_ccjj[x][y]
            end
            -- M.RefreshEliminateBG(data)
        end
    end
    --M.PrintItemMap(item_map_hscb, "BBBBBBBBBBBBBBBBBB")
    return add_item_map
end

function M.RemoveEliminateItem(data)
    if table_is_null(data) then
        return
    end
    for x, _v in pairs(data) do
        for y, v in pairs(_v) do
            if (EliminateSGModel.data.state == EliminateSGModel.xc_state.nor) or (EliminateSGModel.data.state == EliminateSGModel.xc_state.null) or (EliminateSGModel.data.state == EliminateSGModel.xc_state.select) then
                if item_map[x] and item_map[x][y] then
                    item_map[x][y]:Exit()
                    item_map[x][y] = nil
                end
            elseif (EliminateSGModel.data.state == EliminateSGModel.xc_state.hscb_2) or (EliminateSGModel.data.state == EliminateSGModel.xc_state.hscb_1) then
                if item_map_hscb[x] and item_map_hscb[x][y] then
                    item_map_hscb[x][y]:Exit()
                    item_map_hscb[x][y] = nil
                end
            elseif (EliminateSGModel.data.state == EliminateSGModel.xc_state.ccjj_2) or (EliminateSGModel.data.state == EliminateSGModel.xc_state.ccjj_cs)then
                if item_map_ccjj[x] and item_map_ccjj[x][y] then
                    item_map_ccjj[x][y]:Exit()
                    item_map_ccjj[x][y] = nil
                end
            end
        end
    end
end

function M.AddBoatEliminateItem(data, is_down)
    if table_is_null(data) then
        return
    end
    --dump(boat_item_map)
    --print("<color=red>HHHHHHHHHHHHHHHHHHHH 1</color>")
    dump(data,"<color=yellow><size=15>++++++++++AddBoatEliminateItem++++++++++</size></color>")
    dump(boat_item_map,"<color=yellow><size=15>++++++++++boat_item_map++++++++++</size></color>")
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
                    boat_item_map[x][y] = EliminateSGItem.Create({x = x, y = y, id = v, is_down = is_down,type = "hscb"})
                    add_item_map[x] = add_item_map[x] or {}
                    add_item_map[x][y] = boat_item_map[x][y]
                end
            else
                boat_item_map[x] = boat_item_map[x] or {}
                boat_item_map[x][y] = EliminateSGItem.Create({x = x, y = y, id = v, is_down = is_down,type = "hscb"})
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
function M.RemoveBoatEliminateItem()
    if (EliminateSGModel.data.state ~= EliminateSGModel.xc_state.hscb_2) and (EliminateSGModel.data.state ~= EliminateSGModel.xc_state.hscb_1) then return end
    --print("<color=red>GGGGGGGGGGGGGGGGGGGGG 3</color>")
    --dump(boat_item_map)
    local new_map = {}
    for x, _v in pairs(item_map_hscb) do
        for y, v in pairs(_v) do
            local index = eliminate_sg_algorithm.get_index_by_pos(v.ui.transform.localPosition.x, v.ui.transform.localPosition.y)
            
            if index.x < 1 or index.x > EliminateSGModel.size.max_x 
                or index.y < 1 or index.y > EliminateSGModel.size.max_y then
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
    for x, _v in pairs(boat_item_map) do
        for y, v in pairs(_v) do
            if new_map[x] then
                new_map[x][y] = boat_item_map[x][y]
            end
        end
    end
    --M.PrintItemMap(new_map, "CC")
    
    item_map_hscb = new_map
    --M.PrintItemMap(item_map_hscb, "BBBBBBBB")
    boat_item_map = {}
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
    if (EliminateSGModel.data.state == EliminateSGModel.xc_state.nor) or (EliminateSGModel.data.state == EliminateSGModel.xc_state.null) or (EliminateSGModel.data.state == EliminateSGModel.xc_state.select) then
        return item_map
    elseif (EliminateSGModel.data.state == EliminateSGModel.xc_state.hscb_2) or (EliminateSGModel.data.state == EliminateSGModel.xc_state.hscb_1) then
        return item_map_hscb
    elseif (EliminateSGModel.data.state == EliminateSGModel.xc_state.ccjj_2) or (EliminateSGModel.data.state == EliminateSGModel.xc_state.ccjj_cs) then
        return item_map_ccjj
    end
end

function M.GetEliminateItem(x, y)
    if (EliminateSGModel.data.state == EliminateSGModel.xc_state.nor) or (EliminateSGModel.data.state == EliminateSGModel.xc_state.null) or (EliminateSGModel.data.state == EliminateSGModel.xc_state.select) then
        if item_map[x] then
            return item_map[x][y]
        end
    elseif (EliminateSGModel.data.state == EliminateSGModel.xc_state.hscb_2) or (EliminateSGModel.data.state == EliminateSGModel.xc_state.hscb_1) then
        if item_map_hscb[x] then
            return item_map_hscb[x][y]
        end
    elseif (EliminateSGModel.data.state == EliminateSGModel.xc_state.ccjj_2) or (EliminateSGModel.data.state == EliminateSGModel.xc_state.ccjj_cs) then
        if item_map_ccjj[x] then
            return item_map_ccjj[x][y]
        end
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
            bg_map[x][y] = EliminateSGItemBG.Create({x = x, y = y})
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
    local xc_c = eliminate_sg_algorithm.get_xc_count(cur_del_map)
    local xc_id = eliminate_sg_algorithm.get_xc_id(cur_del_map)
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
    EliminateSGPartManager.CreateNumGold(data, EliminateSGModel.GetAwardGold(cur_rate))
end

function M.PlayParticleEliminate(pd, cur_del_map, cur_rate)
    if table_is_null(cur_del_map) then
        return
    end
    local cru_del_list = eliminate_sg_algorithm.change_map_to_list(cur_del_map)
    local count = pd.xc_c
    local xc_id = tonumber(pd.xc_id)
    if false then
    else
        --普通消除特效
        if count <= 4 then
            EliminateSGPartManager.CreateEliminateNor1(cru_del_list, EliminateSGModel.GetAwardGold(cur_rate))
        elseif count <= 6 and count >= 5 then
            EliminateSGPartManager.CreateEliminateNor2(cru_del_list, EliminateSGModel.GetAwardGold(cur_rate))
        else
            EliminateSGPartManager.CreateEliminateNor3(cru_del_list, EliminateSGModel.GetAwardGold(cur_rate))
        end
    end
end

function M.PlaySoundByEliminateCount(c)
    if c == 3 then
        ExtendSoundManager.PlaySound(audio_config.cbzz.bgm_cbzz_1xiao.audio_name)
    elseif c == 4 then
        ExtendSoundManager.PlaySound(audio_config.cbzz.bgm_cbzz_2xiao.audio_name)
    elseif c == 5 then
        ExtendSoundManager.PlaySound(audio_config.cbzz.bgm_cbzz_3xiao.audio_name)
    elseif c == 6 then
        ExtendSoundManager.PlaySound(audio_config.cbzz.bgm_cbzz_4xiao.audio_name)
    elseif c == 7 then
        ExtendSoundManager.PlaySound(audio_config.cbzz.bgm_cbzz_5xiao.audio_name)
    elseif c > 7 then
        ExtendSoundManager.PlaySound(audio_config.cbzz.bgm_cbzz_6xiao.audio_name)
    end
end

-------------------------------外部调用
function M.Lottery(index, callback,is_first)
    if EliminateSGModel.DataDamage() then
        return
    end
    if not EliminateSGModel.data or not EliminateSGModel.data.eliminate_data then return end
    local data = EliminateSGModel.data.eliminate_data.result[index]
    if not data then return end
    EliminateSGModel.data.state = data.state
    print("<color=yellow>索引</color>",index)
    dump(data)
    local seq = DoTweenSequence.Create()
    M.ShakeBefore(data,seq,index,is_first)
    M.RefreshView(data,seq)
    M.DelList(data, seq)
    M.DelListEnd(data, seq)
    M.BigGame(data,seq)
    M.LotteryEnd(data, index, seq, callback)
end
function M.BigGame(data,seq)
    if (EliminateSGModel.data.state == EliminateSGModel.xc_state.hscb_2) or (EliminateSGModel.data.state == EliminateSGModel.xc_state.hscb_1) then
        M.LitBoat_Spread(data, seq)
        M.LitBoat_Wind(data,seq)
        seq:AppendCallback(function ()
            Event.Brocast("refresh_boat_nums_change_mag",data.map_new)
            if data.need_refresh then
                M.ClearEliminateItem()
                M.CreateEliminateItem(data.map_new)
            end
        end)
    elseif (EliminateSGModel.data.state == EliminateSGModel.xc_state.ccjj_cs) or (EliminateSGModel.data.state == EliminateSGModel.xc_state.ccjj_2) then
        dump(data,"<color=yellow><size=15>++++++++++BigGame++++++++++</size></color>")
        Event.Brocast("eliminate_ccjj_biggame_msg", {arrow_fly_list = data.arrow_fly_list,boat_fly_list = data.boat_fly_list,seq = seq})
        --[[seq:AppendCallback(function ()
            EliminateSGObjManager.ClearEliminateItem()
            EliminateSGObjManager.CreateEliminateItem(data.map_new)
        end)--]]
        seq:AppendCallback(
            function()
                --Event.Brocast("refresh_collect_arrows_nums_change_mag",data.map_new)
                if data.need_refresh then
                    M.ClearEliminateItem()
                    M.CreateEliminateItem(data.map_new)
                end
            end
        )
    end
end
function M.ShakeBefore(data,seq,index,is_first)
    if is_first or not data.is_scroll then
        return
    end
    if (EliminateSGModel.data.state == EliminateSGModel.xc_state.hscb_2) or (EliminateSGModel.data.state == EliminateSGModel.xc_state.hscb_1) then
        Event.Brocast("free_game_times_change_msg",data.free_times - 1)
    end
    seq:AppendCallback(function(  )
        local item_map = EliminateSGObjManager.GetAllEliminateItem()
        local times = {
            ys_jsgdsj = EliminateSGModel.time.ys_jsgdsj,
            ys_ysgdjg = EliminateSGModel.time.ys_ysgdjg,
            ys_j_sgdsj = EliminateSGModel.time.ys_j_sgdsj,
            ys_jsgdjg = EliminateSGModel.time.ys_jsgdjg
        }
        --M.PrintItemMap(item_map, "JJJJJJJJJJJJ")
        EliminateSGAnimManager.ScrollLottery(item_map, times,true)
        local new_map = EliminateSGModel.data.eliminate_data.result[index].map_base
        local times = {
            ys_j_sgdjg = EliminateSGModel.time.ys_j_sgdjg,
            ys_ysgdsj = EliminateSGModel.time.ys_ysgdsj * 1.5,
            ys_ysgdsj_add = EliminateSGModel.time.ys_ysgdsj_add,
        }
        EliminateSGAnimManager.StopScrollLottery(
            new_map,
            function()
            end,
            times
        )
    end)
    local times = {
        ys_j_sgdsj = EliminateSGModel.time.ys_j_sgdsj,
        ys_j_sgdjg = EliminateSGModel.time.ys_j_sgdjg,
        ys_ysgdsj = EliminateSGModel.time.ys_ysgdsj * 1.5,
    }
    local tt = EliminateSGModel.GetTime(times.ys_ysgdsj) +
    5 * EliminateSGModel.GetTime(times.ys_j_sgdjg) +
    EliminateSGModel.GetTime(times.ys_j_sgdsj) +
    EliminateSGModel.GetTime(times.ys_j_sgdsj / 4)

    seq:AppendInterval(tt + 0.1)
end


function M.RefreshView(data, seq)
    seq:AppendCallback(function(  )
        dump(data, "<color=red>WWWWWWWWWWWWWWWW RefreshView</color>")
        if not table_is_null(data.map_base) then
            if (data.state == EliminateSGModel.xc_state.nor) or (data.state == EliminateSGModel.xc_state.null) or (data.state == EliminateSGModel.xc_state.select)
                or (data.state == EliminateSGModel.xc_state.ccjj_2) or (data.state == EliminateSGModel.xc_state.ccjj_cs) then
                    EliminateSGObjManager.ClearEliminateItem()
                    EliminateSGObjManager.CreateEliminateItem(data.map_base)
            end
        end
        EliminateSGPartManager.ClearAll()
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
    local cru_del_list = eliminate_sg_algorithm.change_map_to_list(cur_del_map)
    --消除虎符加入等待特效
    if cru_del_list and cru_del_list[1].v == eliminate_sg_algorithm.eliminate_id[6] and cur_rate == 0 then
        seq:AppendCallback(function ()
            ExtendSoundManager.PlaySound(audio_config.cbzz.bgm_cbzz_hufu.audio_name)
            EliminateSGPartManager.CreateLuckyRight(cur_del_map,EliminateSGModel.GetTime(EliminateSGModel.time.xc_hf_sg))
        end)
        seq:AppendInterval(EliminateSGModel.GetTime(EliminateSGModel.time.xc_hf_sg))
        seq:AppendCallback(function ()
            M.PlayParticleEliminate(pd, cur_del_map, cur_rate)
        end)
    else
        seq:AppendCallback(
            function()
                --消除音效
                M.PlaySoundByEliminateCount(pd.xc_c)
                M.PlayParticleEliminate(pd, cur_del_map, cur_rate)
            end
        )
        seq:AppendInterval(EliminateSGModel.GetTime(EliminateSGModel.time.xc_pt))
    end

    if (data.state == EliminateSGModel.xc_state.nor) or (data.state == EliminateSGModel.xc_state.null) or (data.state == EliminateSGModel.xc_state.select) then
        if cur_rate > 0 then
            seq:AppendCallback(
                function()
                    --元素消除
                    M.RemoveEliminateItem(cur_del_map)
                    Event.Brocast("view_lottery_award", {cur_del_map = cur_del_map, cur_rate = cur_rate})
                end
            )
            seq:AppendInterval(EliminateSGModel.GetTime(EliminateSGModel.time.xc_xyz))
        elseif cru_del_list and cru_del_list[1].v == eliminate_sg_algorithm.eliminate_id[6] and cur_rate == 0 then
            seq:AppendCallback(
                function ()
                    M.RemoveEliminateItem(cur_del_map)
                    --第一次虎符不计入普通消,需要特殊处理
                    EliminateSGPartManager.HFfly(cur_del_map,function ()
                        ExtendSoundManager.PlaySound(audio_config.cbzz.bgm_cbzz_zj.audio_name)
                        EliminateSGAnimManager.DOShakePositionCamer(nil,EliminateSGModel.GetTime(1),nil,function ()
                            Event.Brocast("hf_had_fly_finish_msg")
                        end)
                    end)
                end
            )
            seq:AppendInterval(EliminateSGModel.GetTime(2))
        end
    elseif (data.state == EliminateSGModel.xc_state.hscb_2) or (data.state == EliminateSGModel.xc_state.hscb_1) then
        seq:AppendCallback(
            function()
                --元素消除
                M.RemoveEliminateItem(cur_del_map)
                Event.Brocast("view_lottery_award", {cur_del_map = cur_del_map, cur_rate = cur_rate})
            end
        )
        seq:AppendInterval(EliminateSGModel.GetTime(EliminateSGModel.time.xc_xyz))
    elseif (data.state == EliminateSGModel.xc_state.ccjj_2) or (data.state == EliminateSGModel.xc_state.ccjj_cs) then
        seq:AppendCallback(
            function()
                --元素消除
                M.RemoveEliminateItem(cur_del_map)
                Event.Brocast("view_lottery_award", {cur_del_map = cur_del_map, cur_rate = cur_rate})
            end
        )
        seq:AppendInterval(EliminateSGModel.GetTime(EliminateSGModel.time.xc_xyz))
    end
end

function M.DelListEnd(data, seq)
    --结束本次消除
    seq:AppendCallback(
        function()
            M.EliminateItemDown()
        end
    )
    seq:AppendInterval(EliminateSGModel.GetTime(EliminateSGModel.time.ys_jxlh))

    --本局结束有map_add
    dump(data.map_add,"<color=yellow><size=15>++++++++++本局结束有map_add++++++++++</size></color>")
    if data.map_add then
        seq:AppendCallback(
            function()
                --M.PrintItemMap(data.map_add, "data.map_add")
                M.CreateEliminateItemDown(data.map_add)
                M.EliminateItemDownNew(data.map_add,function ()
                    ExtendSoundManager.PlaySound(audio_config.cbzz.bgm_cbzz_luoxia.audio_name)
                end)
            end
        )
        seq:AppendInterval(EliminateSGModel.GetTime(EliminateSGModel.time.ys_xxlh))
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
    seq:AppendInterval(EliminateSGModel.GetTime(EliminateSGModel.time.xc_xyp))
end

--蔓延式
function M.LitBoat_Spread(data, seq)
    if data.is_fire then
        --蔓延式点燃船只
        if not table_is_null(data.hslh_map) then
            local t = 0.8
            dump(data.hslh_map,"<color=yellow><size=15>++++++++++蔓延式++++++++++</size></color>")

            for k,v in pairs(data.hslh_map) do
                local need_play = false
                for kk,vv in pairs(v) do
                    if item_map_hscb[vv.x] and item_map_hscb[vv.x][vv.y] and not item_map_hscb[vv.x][vv.y]:IsAlreadyLit() then
                        need_play = true
                        break
                    end
                end
                if need_play then
                    seq:AppendInterval(EliminateSGModel.GetTime(t))
                    seq:AppendCallback(function ()
                        ExtendSoundManager.PlaySound(audio_config.cbzz.bgm_cbzz_hscb_ranshao.audio_name)
                    end)
                end
                for kk, vv in ipairs(v) do
                    if item_map_hscb[vv.x] and item_map_hscb[vv.x][vv.y] and not item_map_hscb[vv.x][vv.y]:IsAlreadyLit() then
                        seq:AppendCallback(function ()
                            local tab = {}
                            tab[vv.x] = {}
                            tab[vv.x][vv.y] = 101
                            local tab2 = { x = vv.x , y = vv.y}
                            EliminateSGPartManager.PlaySpread(tab2,function ()
                                EliminateSGObjManager.AddBoatEliminateItem(tab)
                            end)
                        end)
                    end
                end
            end
            seq:AppendInterval(EliminateSGModel.GetTime(EliminateSGModel.time.ys_jxlh))
            seq:AppendCallback(
                function() 

                end
            )
            seq:AppendInterval(EliminateSGModel.GetTime(EliminateSGModel.time.ys_jxlh))   
        end
    end
end


--东风式
function M.LitBoat_Wind(data,seq)
    if data.is_fire then
        --东风式点燃船只
        if not table_is_null(data.lit_list) then
            dump(data.lit_list,"<color=yellow><size=15>++++++++++东风式++++++++++</size></color>")
            EliminateSGPartManager.PlayWind(1,nil,nil)
            seq:AppendInterval(0.4)
            --[[seq:AppendCallback(
                function()
                    M.ClearEliminateItem()
                    M.CreateEliminateItem(data.map_new)
                end
            )--]]
        else
            --[[seq:AppendCallback(
                function()
                    M.ClearEliminateItem()
                    M.CreateEliminateItem(data.map_new)
                end
            )--]]
        end
    end
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
    if (EliminateSGModel.data.state == EliminateSGModel.xc_state.nor) or (EliminateSGModel.data.state == EliminateSGModel.xc_state.null) or (EliminateSGModel.data.state == EliminateSGModel.xc_state.select) then
        if table_is_null(item_map) or table_is_null(map_add) then return end
        for x,_v in pairs(map_add) do
            for y,v in pairs(_v) do
                local item = M.GetEliminateItem(x,y)
            end
        end
    elseif (EliminateSGModel.data.state == EliminateSGModel.xc_state.hscb_2) or (EliminateSGModel.data.state == EliminateSGModel.xc_state.hscb_1) then
        if table_is_null(item_map_hscb) or table_is_null(map_add) then return end
        for x,_v in pairs(map_add) do
            for y,v in pairs(_v) do
                local item = M.GetEliminateItem(x,y)
            end
        end
    elseif (EliminateSGModel.data.state == EliminateSGModel.xc_state.ccjj_2) or (EliminateSGModel.data.state == EliminateSGModel.xc_state.ccjj_cs) then
        if table_is_null(item_map_ccjj) or table_is_null(map_add) then return end
        for x,_v in pairs(map_add) do
            for y,v in pairs(_v) do
                local item = M.GetEliminateItem(x,y)
            end
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
        local max_x = EliminateSGModel.size.max_x
        local max_y = EliminateSGModel.size.max_y
        for x=1,max_x do
            for y=1,max_y do
                if item_map_hscb[x] and item_map_hscb[x][y] and item_map_hscb[x][y].data.id >= 100 then
                    _map[x] = _map[x] or {}
                    _map[x][y] = item_map_hscb[x][y].data.id
                end
            end
        end
        EliminateSGObjManager.AddBoatEliminateItem(_map)
    end
end

function M.ClearLitFx()
    for k,v in pairs(item_map_hscb) do
        for _k,_v in pairs(v) do
            _v:LitBoat(false)
        end
    end
end