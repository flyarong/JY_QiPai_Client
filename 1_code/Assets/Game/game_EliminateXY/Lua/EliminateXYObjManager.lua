local basefunc = require "Game.Common.basefunc"
EliminateXYObjManager = {}
local M = EliminateXYObjManager
package.loaded["Game.game_EliminateXY.Lua.EliminateXYItem"] = nil
require "Game.game_EliminateXY.Lua.EliminateXYItem"
package.loaded["Game.game_EliminateXY.Lua.EliminateXYItemBG"] = nil
require "Game.game_EliminateXY.Lua.EliminateXYItemBG"
local item_map = {}
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
    if not IsEquals(M.ItemContent) then
        M.ItemContent = GameObject.Find("ItemContent")
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
    EliminateXYItem = newObject("EliminateXYItem", M.GetRoot()),
    EliminateXYItemPhysics = newObject("EliminateXYItemPhysics", M.GetRoot()),
    EliminateXYItemBG = newObject("EliminateXYItemBG", M.GetRoot()),
    EliminateXYItemSWK = newObject("EliminateXYItemSWK", M.GetRoot()),
    EliminateXYItemBGJ = newObject("EliminateXYItemBGJ", M.GetRoot()),
    
    xxl_icon_1 = GetTexture("sdbgj_icon_1"),
    xxl_icon_2 = GetTexture("sdbgj_icon_2"),
    xxl_icon_3 = GetTexture("sdbgj_icon_3"),
    xxl_icon_4 = GetTexture("sdbgj_icon_4"),
    xxl_icon_5 = GetTexture("sdbgj_icon_5"),
    xxl_icon_6 = GetTexture("sdbgj_icon_6"),
    xxl_icon_7 = GetTexture("sdbgj_icon_7"),
    xxl_icon_8 = GetTexture("sdbgj_icon_8"),
    xxl_icon_9 = GetTexture("sdbgj_icon_9"),
    xxl_icon_10 = GetTexture("sdbgj_icon_10"),
    xxl_icon_11 = GetTexture("sdbgj_icon_11"),
    xxl_icon_12 = GetTexture("sdbgj_icon_12"),
    xxl_swk_icon_9 = GetTexture("sdbgj_bg_ptkj"),
    xxl_swk_icon_10 = GetTexture("sdbgj_bg_sbjl"),
    xxl_swk_icon_11 = GetTexture("sdbgj_bg_ewjl"),
    xxl_swk_icon_12 = GetTexture("sdbgj_bg_zyyc"),
    sdbgj_icon_dj1 = GetTexture("sdbgj_icon_dj1"),
    sdbgj_icon_dj2 = GetTexture("sdbgj_icon_dj2"),
    sdbgj_icon_dj3 = GetTexture("sdbgj_icon_dj3"),
    sdbgj_icon_dj4 = GetTexture("sdbgj_icon_dj4"),
    sdbgj_icon_dj5 = GetTexture("sdbgj_icon_dj5"),
    sdbgj_icon_dj6 = GetTexture("sdbgj_icon_dj6"),
    sdbgj_icon_dj7 = GetTexture("sdbgj_icon_dj7"),
    sdbgj_icon_dj8 = GetTexture("sdbgj_icon_dj8"),
    sdbgj_icon_dj9 = GetTexture("sdbgj_icon_dj9"),
    sdbgj_icon_dj10 = GetTexture("sdbgj_icon_dj10"),
    sdbgj_icon_dj11 = GetTexture("sdbgj_icon_dj11"),
    sdbgj_icon_dj12 = GetTexture("sdbgj_icon_dj12"),
    material_FrontBlur = GetMaterial("FrontBlur")
}

M.delete_obj = {
	EliminateXYItem = M.item_obj.EliminateXYItem,
	EliminateXYItemPhysics = M.item_obj.EliminateXYItemPhysics,
	EliminateXYItemBG = M.item_obj.EliminateXYItemBG,
	EliminateXYItemSWK = M.item_obj.EliminateXYItemSWK,
	EliminateXYItemBGJ = M.item_obj.EliminateXYItemBGJ
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
    for k, v in pairs(EliminateXYModel.eliminate_enum) do
        local _obj = GameObject.Instantiate(M.item_obj.EliminateXYItem, M.GetRoot())
        local img = _obj.gameObject.transform:Find("@icon_img"):GetComponent("Image")
        img.sprite = M.item_obj["xxl_icon_" .. v]
        M.item_obj["EliminateXYItem" .. v] = _obj
		M.delete_obj["EliminateXYItem" .. v] = _obj

        local _obj_phy = GameObject.Instantiate(M.item_obj.EliminateXYItemPhysics, M.GetRoot())
        _obj_phy.gameObject.transform.localPosition = Vector3.one * 10000
        local img_phy = _obj_phy.gameObject.transform:Find("@icon_img"):GetComponent("Image")
        img_phy.sprite = M.item_obj["xxl_icon_" .. v]
        M.item_obj["EliminateXYItemPhysics" .. v] = _obj_phy
		M.delete_obj["EliminateXYItemPhysics" .. v] = _obj_phy
    end
end

function M.Init()
    M.Exit()
    print("<color=yellow>消消乐obj初始化</color>")
    M.AddListener()
    item_map = {}
    M.InstantiateObj()
    M.item_obj.EliminateXYItemPhysics.transform.localPosition = Vector3.one * 10000
end

function M.Exit()
    print("<color=white>objManager退出</color>")
    M.RemoveListener()
    soundMgr:CloseSound()
    M.ExitTimer()
    for x, _v in pairs(item_map) do
        for y, v in pairs(_v) do
            v:Exit()
        end
    end
    item_map = {}

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
	--	M.item_obj[x] = nil
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

function M.CreateEliminateItem(data,bgj_rate_map)
    local map = {}
    if data and next(data) then
        for x, _v in pairs(data) do
            for y, v in pairs(_v) do
                map[x] = map[x] or {}
                map[x][y] = v
            end
        end
    end
    M.AddEliminateItem(map,nil,bgj_rate_map)
end

function M.CreateEliminateItemDown(data,bgj_rate_map)
    local map = {}
    for x, _v in pairs(data) do
        for y, v in pairs(_v) do
            map[x] = map[x] or {}
            map[x][y] = v
        end
    end
    M.AddEliminateItem(map, true,bgj_rate_map)
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
    local new_y = 1
    local index = eliminate_xy_algorithm.get_map_max_index(item_map)
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
    EliminateXYAnimManager.EliminateItemDown(new_item_map, callback)
end

function M.EliminateItemDownNew(map, callback)
    local new_item_map = {}
    for x, _v in pairs(map) do
        for y, v in pairs(_v) do
            new_item_map[x] = new_item_map[x] or {}
            new_item_map[x][y] = item_map[x][y]
        end
    end
    local function _callback()
        EliminateXYAnimManager.Spring(new_item_map, EliminateXYModel.GetTime(EliminateXYModel.time.ys_xxldd), callback)
    end
    EliminateXYAnimManager.EliminateItemDown(new_item_map, _callback)
end

function M.AddEliminateItem(data, is_down,bgj_rate_map)
    if table_is_null(data) then
        return
    end
    local add_item_map = {}
    for x, _v in pairs(data) do
        for y, v in pairs(_v) do
            if item_map[x] and item_map[x][y] then
                item_map[x][y]:Exit()
            end
            local money
            if v == EliminateXYModel.eliminate_enum.bgj and bgj_rate_map and bgj_rate_map[x] and bgj_rate_map[x][y] then
                --白骨精
                local bgj_rate = bgj_rate_map[x][y]
                money = StringHelper.ToCash(EliminateXYModel.GetAwardGold(bgj_rate))
            end
            item_map[x] = item_map[x] or {}
            item_map[x][y] = EliminateXYItem.Create({x = x, y = y, id = v, is_down = is_down, money = money})
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
            bg_map[x][y] = EliminateXYItemBG.Create({x = x, y = y})
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
    local xc_c = eliminate_xy_algorithm.get_xc_count(cur_del_map)
    local xc_id = eliminate_xy_algorithm.get_xc_id(cur_del_map)
    local pd = {}
    pd.xc_c = xc_c
    pd.xc_id = xc_id
    if index and xc_id == EliminateXYModel.eliminate_enum.swk and data.swk_skill_trigger_index and data.swk_skill_trigger_index == index then
        --孙悟空技能触发
        pd.swk_trigger = true
    end
    if index and xc_id == EliminateXYModel.eliminate_enum.ts and data.ts_skill_trigger_index and data.ts_skill_trigger_index == index then
        --唐僧技能触发
        pd.ts_trigger = true
    end
    if xc_id == EliminateXYModel.eliminate_enum.bgj then
        --白骨精消除
        pd.bgj_rate = data.bgj_rate
        pd.bgj_rate_map = data.bgj_rate_map
        pd.bgj_rate_add_map = data.swk_skill_added_rate_map
        pd.bgj_xc_type = data.swk_skill
    end
    return pd
end

function M.PlayParticleEliminateNull(cur_rate, hero_index)
    local index_y = hero_index + 2
    local data = {
        {x = 4, y = index_y, v = 6},
        {x = 5, y = index_y, v = 6}
    }
    EliminateXYPartManager.CreateNumGold(data, EliminateXYModel.GetAwardGold(cur_rate))
end

function M.PlayParticleEliminate(pd, cur_del_map, cur_rate, swk_skill)
    if table_is_null(cur_del_map) then
        return
    end
    local cru_del_list = eliminate_xy_algorithm.change_map_to_list(cur_del_map)
    local count = pd.xc_c
    local xc_id = tonumber(pd.xc_id)
    if xc_id == EliminateXYModel.eliminate_enum.swk then
        --孙悟空消除特效
        if count <= 4 then
            EliminateXYPartManager.CreateEliminateSWK(cru_del_list, 1)
        elseif count <= 6 and count >= 5 then
            EliminateXYPartManager.CreateEliminateSWK(cru_del_list, 2)
        else
            EliminateXYPartManager.CreateEliminateSWK(cru_del_list, 3)
        end
    elseif xc_id == EliminateXYModel.eliminate_enum.ts then
        --唐僧消除特效
        if count <= 4 then
            EliminateXYPartManager.CreateEliminateTS(cru_del_list,1)
        elseif count <= 6 and count >= 5 then
            EliminateXYPartManager.CreateEliminateTS(cru_del_list,2)
        else
            EliminateXYPartManager.CreateEliminateTS(cru_del_list,3)
        end
    elseif xc_id == EliminateXYModel.eliminate_enum.bgj then
        --白骨精消除特效
        if count == 1 then
            EliminateXYPartManager.CreateEliminateBGJ1(cru_del_list, 1, cur_rate,swk_skill)
            return
        end
        if count <= 4 then
            EliminateXYPartManager.CreateEliminateBGJ(cru_del_list, 1, pd)
        elseif count <= 6 and count >= 5 then
            EliminateXYPartManager.CreateEliminateBGJ(cru_del_list, 2, pd)
        else
            EliminateXYPartManager.CreateEliminateBGJ(cru_del_list, 3, pd)
        end
    else
        --普通消除特效
        if count <= 4 then
            EliminateXYPartManager.CreateEliminateNor1(cru_del_list, EliminateXYModel.GetAwardGold(cur_rate))
        elseif count <= 6 and count >= 5 then
            EliminateXYPartManager.CreateEliminateNor2(cru_del_list, EliminateXYModel.GetAwardGold(cur_rate))
        else
            EliminateXYPartManager.CreateEliminateNor3(cru_del_list, EliminateXYModel.GetAwardGold(cur_rate))
        end
    end
end

function M.PlaySoundByEliminateCount(c)
    if c == 3 then
        ExtendSoundManager.PlaySound(audio_config.sdbgj.bgm_sdbgj_1xiao.audio_name)
    elseif c == 4 then
        ExtendSoundManager.PlaySound(audio_config.sdbgj.bgm_sdbgj_2xiao.audio_name)
    elseif c == 5 then
        ExtendSoundManager.PlaySound(audio_config.sdbgj.bgm_sdbgj_3xiao.audio_name)
    elseif c == 6 then
        ExtendSoundManager.PlaySound(audio_config.sdbgj.bgm_sdbgj_4xiao.audio_name)
    elseif c == 7 then
        ExtendSoundManager.PlaySound(audio_config.sdbgj.bgm_sdbgj_5xiao.audio_name)
    elseif c > 7 then
        ExtendSoundManager.PlaySound(audio_config.sdbgj.bgm_sdbgj_6xiao.audio_name)
    end
end

-------------------------------外部调用
function M.Lottery(index, callback,is_first)
    if EliminateXYModel.DataDamage() then
        return
    end
    print("<color=yellow>索引</color>",index)
    if not EliminateXYModel.data or not EliminateXYModel.data.eliminate_data then return end
    local data = EliminateXYModel.data.eliminate_data.result[index]
    if not data then return end
    EliminateXYModel.data.state = data.state
    local seq = DoTweenSequence.Create()
    M.RefreshView(data,seq)
    M.DelListBefore(data,seq,is_first)
    M.DelList(data, seq)
    M.DelListEnd(data, seq)
    M.TaskSettlement(data,index,seq)
    M.UseSWKSkill(data, seq)
    M.UseTSSkill(data, index, seq, callback)
    M.UseSWKAwardSkill(data,seq)
    M.UseBGJSkill(data, index, seq)
    M.LotteryEnd(data, index, seq, callback)
end

function M.DelListBefore(data,seq,is_first)
    if not data or not is_first then return end
    if true then return end--不需要进行前摇效果
    seq:AppendCallback(
        function()
            EliminateXYPartManager.CreateTSKuang(data)
        end
    )
    seq:AppendInterval(EliminateXYModel.GetTime(EliminateXYModel.time.ts_cxtsk))
end

function M.RefreshView(data)
    if not table_is_null(data.map_base) then
        EliminateXYObjManager.ClearEliminateItem()
        EliminateXYObjManager.CreateEliminateItem(data.map_base,data.bgj_rate_map)
    end
    EliminateXYPartManager.ClearAll()
    --改变元素
    if table_is_null(data.xc_change_data) then
        return
    end
    M.RemoveEliminateItem(data.xc_change_data)
    M.AddEliminateItem(data.xc_change_data,nil,data.bgj_rate_map)
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
    if pd.swk_trigger then
        --孙悟空
        seq:AppendCallback(
            function()
                EliminateXYHeroManager.SWKSkillTrigger(data,cur_del_map)
            end
        )
        seq:AppendInterval(EliminateXYModel.GetTime(EliminateXYModel.time.swk_xc_qy))
    end

    if pd.ts_trigger then
        --唐僧
        seq:AppendCallback(
            function()
                if data.state == "nor" then
                    ExtendSoundManager.PlaySound(audio_config.sdbgj.bgm_sdbgj_ts_xc.audio_name)
                elseif data.state == "free" then
                    ExtendSoundManager.PlaySound(audio_config.sdbgj.bgm_sdbgj_free_ts_xc.audio_name)
                end
                EliminateXYHeroManager.TSXCQY(data,cur_del_map)
            end
        )
        seq:AppendInterval(EliminateXYModel.GetTime(EliminateXYModel.time.ts_xc_qy))
    end

    if pd.bgj_rate then
        --白骨精消除
        cur_rate = pd.bgj_rate
    end

    if data.state == "nor" and cur_rate > 0 then
        --普通消除,累计赢金增加任务进度
        seq:AppendCallback(
            function()
                EliminateXYHeroManager.TaskAdd(data,cur_del_map)
            end
        )
        seq:AppendInterval(EliminateXYModel.GetTime(EliminateXYModel.time.task_add))
    end

    seq:AppendCallback(
        function()
            --消除音效
            M.PlaySoundByEliminateCount(pd.xc_c)
            if pd.swk_trigger then
                ExtendSoundManager.PlaySound(audio_config.sdbgj.bgm_sdbgj_swk_xc.audio_name)
            end
            M.PlayParticleEliminate(pd, cur_del_map, cur_rate)
        end
    )
    seq:AppendInterval(EliminateXYModel.GetTime(EliminateXYModel.time.xc_pt))
    seq:AppendCallback(
        function()
            --元素消除
            M.RemoveEliminateItem(cur_del_map)
            Event.Brocast("view_lottery_award", {cur_del_map = cur_del_map, cur_rate = cur_rate})
        end
    )
    if pd.ts_trigger then
        --唐僧
        seq:AppendInterval(EliminateXYModel.GetTime(EliminateXYModel.time.ts_mfyx_wait))
        seq:AppendCallback(
            function()
                EliminateXYHeroManager.TSXCHY(data,cur_del_map)
            end
        )
        seq:AppendInterval(EliminateXYModel.GetTime(EliminateXYModel.time.ts_mfyx_time))
    end
    seq:AppendInterval(EliminateXYModel.GetTime(EliminateXYModel.time.xc_xyz))
end

function M.DelListEnd(data, seq)
    --结束本次消除
    seq:AppendCallback(
        function()
            M.EliminateItemDown()
        end
    )
    seq:AppendInterval(EliminateXYModel.GetTime(EliminateXYModel.time.ys_jxlh))

    --本局结束有map_add
    if data.map_add then
        seq:AppendCallback(
            function()
                ExtendSoundManager.PlaySound(audio_config.sdbgj.bgm_sdbgj_luoxia.audio_name)
                M.CreateEliminateItemDown(data.map_add,data.bgj_rate_map)
                M.EliminateItemDownNew(data.map_add)
            end
        )
        seq:AppendInterval(EliminateXYModel.GetTime(EliminateXYModel.time.ys_xxlh))
     --新元素下落时间
    end
    seq:AppendCallback(
        function()
            M.ClearEliminateItem()
            M.CreateEliminateItem(data.map_new,data.bgj_rate_map_new)
            M.EliminateItemMoneyAni(data.map_add)
        end
    )
    --掉落完成开始消除下一屏的元素
    seq:AppendInterval(EliminateXYModel.GetTime(EliminateXYModel.time.xc_xyp))
end

--使用孙悟空技能
function M.UseSWKSkill(data, seq)
    if not data.use_swk_skill then
        return
    end

    seq:AppendInterval(EliminateXYModel.GetTime(EliminateXYModel.time.swk_skill_use_wait))
    seq:AppendCallback(
        function()
           EliminateXYHeroManager.SWKSkillUse(data)
        end
    )
    seq:AppendInterval(EliminateXYModel.GetTime(EliminateXYModel.time.swk_skill_use))
    if data.swk_skill == 0 then
        --0控技能
    elseif data.swk_skill == 1 then
        --1翻倍当前屏幕中的白骨精的明面价值
    elseif data.swk_skill == 2 then
        --2屏幕中的白骨精额外奖励技能
    elseif data.swk_skill == 3 then
        --3再摇一次，随机变化一些白骨精出现
        seq:AppendCallback(
            function()
                EliminateXYHeroManager.SWKSkillUse3(data)
            end
        )
        local t = EliminateXYModel.time.swk_hyjj
        for x=1,EliminateXYModel.size.max_x do
            for y=1,EliminateXYModel.size.max_y do
                --加速
                if data.swk_skill_change_xc[x] and data.swk_skill_change_xc[x][y] then
                    t = t + EliminateXYModel.time.swk_skill3_change_up_d * 2
                end
            end
        end
        t = t + EliminateXYModel.time.swk_skill3_change_uni_d + EliminateXYModel.time.swk_skill3_change_down_t

        seq:AppendInterval(EliminateXYModel.GetTime(t))
        seq:AppendCallback(
            function()
                M.RemoveEliminateItem(data.swk_skill_change_xc)
                M.AddEliminateItem(data.swk_skill_change_xc,nil,data.bgj_rate_map)
            end
        )
    end
    --消除白骨精
    local cur_del_map = data.bgj_xc_map
    local cur_rate = data.bgj_rate
    local pd = M.GetParticleDataEliminate(data, cur_del_map)
    ---[[
    --一个一个消除
    local bgj_rate_jc_cur = 0
    if data.bgj_rate_jc_cur and data.bgj_rate then
        bgj_rate_jc_cur = data.bgj_rate_jc_cur - data.bgj_rate
    end
    local b = true
    for x=1,EliminateXYModel.size.max_x do
        for y=1,EliminateXYModel.size.max_y do
            if data.bgj_xc_map[x] and data.bgj_xc_map[x][y] then
                local _pd = {
                    xc_c = 1,
                    xc_id = 7,
                    swk_skill = data.swk_skill
                }
                local _cur_del_map = {}
                _cur_del_map[x] = {}
                _cur_del_map[x][y] = 7
                local _cur_rate = data.bgj_rate_map[x][y]
                if data.swk_skill_added_rate_map and data.swk_skill_added_rate_map[x] and data.swk_skill_added_rate_map[x][y] then
                    _cur_rate = _cur_rate + data.swk_skill_added_rate_map[x][y]
                end
                bgj_rate_jc_cur = bgj_rate_jc_cur + _cur_rate
                seq:AppendCallback(
                    function()
                        --消除音效
                        if b then
                            EliminateXYHeroManager.SWKYJTX()
                            b = false
                        end
                        M.PlaySoundByEliminateCount(_pd.xc_c)
                        ExtendSoundManager.PlaySound(audio_config.sdbgj.bgm_sdbgj_bgj_xc.audio_name)
                        M.PlayParticleEliminate(_pd, _cur_del_map, _cur_rate,data.swk_skill)
                        EliminateXYHeroManager.XCBGJ1(_cur_del_map,bgj_rate_jc_cur,data.swk_skill)
                    end
                )
                seq:AppendInterval(EliminateXYModel.GetTime(EliminateXYModel.time.xc_bgj_jg))
                seq:AppendCallback(
                    function()     
                        --元素消除
                        M.RemoveEliminateItem(_cur_del_map)
                        -- Event.Brocast("view_lottery_award", {cur_del_map = _cur_del_map, cur_rate = _cur_rate})
                    end
                )
                
            end
        end
    end
    seq:AppendCallback(
        function()
            for x=1,EliminateXYModel.size.max_x do
                for y=1,EliminateXYModel.size.max_y do
                    if data.bgj_xc_map[x] and data.bgj_xc_map[x][y] then
                        local _cur_del_map = {}
                        _cur_del_map[x] = {}
                        _cur_del_map[x][y] = 7
                        EliminateXYPartManager.XCBGJ({cur_del_map = eliminate_xy_algorithm.change_map_to_list(_cur_del_map)},Vector3.New(-300,660,0)) 
                    end
                end
            end
        end
    )
    seq:AppendInterval(EliminateXYModel.GetTime(EliminateXYModel.time.bgj_xc + EliminateXYModel.time.bgj_xc_fx))
    seq:AppendCallback(
        function()
            ExtendSoundManager.PlaySound(audio_config.sdbgj.bgm_sdbgj_ts_zj.audio_name)
            EliminateXYAnimManager.DOShakePositionCamer(nil,EliminateXYModel.GetTime(1))
            Event.Brocast("view_lottery_award", {cur_del_map = cur_del_map, cur_rate = cur_rate})
        end
    )
    seq:AppendInterval(EliminateXYModel.GetTime(EliminateXYModel.time.xc_pt))
    --结束本次消除
    seq:AppendCallback(
        function()
            M.EliminateItemDown()
        end
    )
    seq:AppendInterval(EliminateXYModel.GetTime(EliminateXYModel.time.ys_jxlh))

    --本局结束有map_add
    if data.bgj_map_add then
        seq:AppendCallback(
            function()
                ExtendSoundManager.PlaySound(audio_config.sdbgj.bgm_sdbgj_luoxia.audio_name)
                M.CreateEliminateItemDown(data.bgj_map_add,data.bgj_rate_map)
                M.EliminateItemDownNew(data.bgj_map_add)
            end
        )
        seq:AppendInterval(EliminateXYModel.GetTime(EliminateXYModel.time.ys_xxlh))
     --新元素下落时间
    end
    seq:AppendCallback(
        function()
            M.ClearEliminateItem()
            M.CreateEliminateItem(data.bgj_map_new,data.bgj_rate_map_new)
            M.EliminateItemMoneyAni(data.bgj_map_new)
        end
    )

    --掉落完成开始消除下一屏的元素
    seq:AppendInterval(EliminateXYModel.GetTime(EliminateXYModel.time.xc_xyp))
end

function M.TaskSettlement(data,index,seq)
    if data.state ~= "nor" then return end
    if index == 1 and #EliminateXYModel.data.eliminate_data.result == 1 
        and table_is_null(EliminateXYModel.data.eliminate_data.result[1].del_map) then
        return
    end
    if index == #EliminateXYModel.data.eliminate_data.result or data.ts_skill_use then
        --只有普通状态和唐僧使用技能进入免费游戏都进行结算
        seq:AppendInterval(EliminateXYModel.GetTime(EliminateXYModel.time.task_sett_wait))
        seq:AppendCallback(function(  )
            EliminateXYHeroManager.TaskSettlement(data)
        end)
        local cur_lv = 0
        if not data.swk_rate_cur or data.swk_rate_cur == 0 then
            cur_lv = 0
        elseif data.swk_rate_cur > 0 and data.swk_rate_cur < EliminateXYHeroManager.swl_lv1 then
            cur_lv = 1
        elseif data.swk_rate_cur >= EliminateXYHeroManager.swl_lv1 and data.swk_rate_cur < EliminateXYHeroManager.swl_lv2 then
            cur_lv = 2
        elseif data.swk_rate_cur >= EliminateXYHeroManager.swl_lv2 then
            cur_lv = 3
        end
        local t = EliminateXYHeroManager.GetUseTime(EliminateXYModel.GetTaskData())
        t = t or 0
        t = t * 2
        t = t + EliminateXYModel.time.task_sett_bgj_xt
        if cur_lv == 3 then
            t = t + EliminateXYModel.time.task_sett_swkgj
        end
        local ta = EliminateXYModel.GetTaskAward()
        if not table_is_null(ta) then
            t = t + EliminateXYModel.time.task_sett_bgj_bs + EliminateXYModel.time.task_sett_bgj_get_award + EliminateXYModel.time.task_sett_bgj_hby + EliminateXYModel.time.task_sett_bgj_hby_hide
        end
        t = t + EliminateXYModel.time.task_sett_time
        seq:AppendInterval(EliminateXYModel.GetTime(t))
    end
end

--使用唐僧技能
function M.UseTSSkill(data, index, seq, callback)
    if not data.ts_skill_use then
        if data.state == "free" then
            --白骨精计入奖池
            if data.bgj_rate_free_nor ~= 0 then
                local bgj_rate_jc_cur = 0
                if data.bgj_rate_jc_cur and data.bgj_rate then
                    bgj_rate_jc_cur = data.bgj_rate_jc_cur - data.bgj_rate
                end
                for x=1,EliminateXYModel.size.max_x do
                    for y=1,EliminateXYModel.size.max_y do
                        if data.bgj_rate_map_new[x] and data.bgj_rate_map_new[x][y] then
                            local _pd = {
                                xc_c = 1,
                                xc_id = 7,
                            }
                            local _cur_del_map = {}
                            _cur_del_map[x] = {}
                            _cur_del_map[x][y] = 7
                            local _cur_rate = data.bgj_rate_map_new[x][y]
                            bgj_rate_jc_cur = bgj_rate_jc_cur + _cur_rate
                            seq:AppendCallback(
                                function()
                                    EliminateXYHeroManager.NorBGJ(_cur_del_map,bgj_rate_jc_cur)
                                end
                            )
                            seq:AppendInterval(EliminateXYModel.GetTime(EliminateXYModel.time.nor_bgj_jg))
                        end
                    end
                end
            end
        end
        return
    end
    --技能释放
    if data.state == "nor" then
        --进入免费游戏
        seq:AppendInterval(EliminateXYModel.GetTime(EliminateXYModel.time.ts_jrmfyx_wait))
        seq:AppendCallback(function(  )
            EliminateXYHeroManager.TSSkillFreeJoin(data)
            EliminateXYHeroManager.BGJSkillFreeJoin(data)
            EliminateXYHeroManager.SWKSkillFreeJoin(data)
        end)
        seq:AppendInterval(EliminateXYModel.GetTime(EliminateXYModel.time.ts_jrmfyx,1))
    elseif data.state == "free" then
        --白骨精计入奖池
        if data.bgj_rate_free_nor ~= 0 then
            local bgj_rate_jc_cur = 0
            if data.bgj_rate_jc_cur and data.bgj_rate then
                bgj_rate_jc_cur = data.bgj_rate_jc_cur - data.bgj_rate
            end
            for x=1,EliminateXYModel.size.max_x do
                for y=1,EliminateXYModel.size.max_y do
                    if data.bgj_rate_map_new[x] and data.bgj_rate_map_new[x][y] then
                        local _pd = {
                            xc_c = 1,
                            xc_id = 7,
                        }
                        local _cur_del_map = {}
                        _cur_del_map[x] = {}
                        _cur_del_map[x][y] = 7
                        local _cur_rate = data.bgj_rate_map_new[x][y]
                        bgj_rate_jc_cur = bgj_rate_jc_cur + _cur_rate
                        seq:AppendCallback(
                            function()
                                EliminateXYHeroManager.NorBGJ(_cur_del_map,bgj_rate_jc_cur)
                            end
                        )
                        seq:AppendInterval(EliminateXYModel.GetTime(EliminateXYModel.time.nor_bgj_jg))
                    end
                end
            end
        end

        --进入免费游戏
        seq:AppendInterval(EliminateXYModel.GetTime(EliminateXYModel.time.ts_symfyx))
        seq:AppendCallback(function(  )
            EliminateXYHeroManager.TSSkillFreeUse(data)
            EliminateXYHeroManager.BGJFreeChange(data)
        end)
    end
    --唐僧技能开奖结束
    seq:AppendInterval(EliminateXYModel.GetTime(EliminateXYModel.time.ts_mfyxkj))
    seq:OnKill(function(  )
        local item_map = EliminateXYObjManager.GetAllEliminateItem()
        local times = {
            ys_jsgdsj = EliminateXYModel.time.ys_jsgdsj,
            ys_ysgdjg = EliminateXYModel.time.ys_ysgdjg,
            ys_j_sgdsj = EliminateXYModel.time.ys_j_sgdsj,
            ys_jsgdjg = EliminateXYModel.time.ys_jsgdjg
        }
        EliminateXYAnimManager.ScrollLottery(item_map, times,index + 1)
        local new_map = EliminateXYModel.data.eliminate_data.result[index + 1].map_base
        local xc_change_map = EliminateXYModel.data.eliminate_data.result[index + 1].xc_change_data
        local bgj_rate_map = EliminateXYModel.data.eliminate_data.result[index + 1].bgj_rate_map
        local times = {
            ys_j_sgdjg = EliminateXYModel.time.ys_j_sgdjg,
            ys_ysgdsj = EliminateXYModel.time.ys_ysgdsj * 1.5,
            ys_ysgdsj_add = EliminateXYModel.time.ys_ysgdsj_add,
        }
        EliminateXYAnimManager.StopScrollLottery(
            new_map,
            function()
                if callback and type(callback) == "function" then
                    callback(true)
                end
            end,
            times,
            xc_change_map,
            bgj_rate_map
        )
    end)
end

--白骨精技能
function M.UseBGJSkill(data, index, seq)
    local next_data = EliminateXYModel.data.eliminate_data.result[index + 1]
    if table_is_null(next_data) or table_is_null(next_data.xc_change_data) then
        return
    end
    --下一屏有改变的元素这里先摇奖
    seq:AppendInterval(EliminateXYModel.GetTime(EliminateXYModel.time.bgj_sl_dd))
    seq:AppendCallback(
        function()
            EliminateXYHeroManager.BGJSkillUse(next_data,function (  )
                M.RemoveEliminateItem(next_data.xc_change_data)
                M.AddEliminateItem(next_data.xc_change_data,nil,next_data.bgj_rate_map)
            end)
        end
    )
    -- seq:AppendInterval(EliminateXYModel.GetTime(EliminateXYModel.time.bgj_sl))
end

--进入奖池抽奖
function M.UseSWKAwardSkill(data,seq)
    if not data.swk_skill_award then return end
    seq:AppendInterval(EliminateXYModel.GetTime(EliminateXYModel.time.xc_xyp))
    seq:AppendCallback(
        function()
            M.RemoveEliminateItem(data.swk_map_base)
            M.AddEliminateItem(data.swk_map_base,nil,data.bgj_rate_map)
        end
    )
    seq:AppendInterval(EliminateXYModel.GetTime(EliminateXYModel.time.xc_xyp))
end

function M.LotteryEnd(data, index, seq, callback)
    if data.ts_skill_use then
        return
    end
    --普通开奖结束
    seq:OnKill(
        function()
            if callback and type(callback) == "function" then
                callback()
            end
        end
    )
end

function M.LotteryBigGame(index, callback)
    if EliminateXYModel.DataDamage() then
        if callback and type(callback) == "function" then
            callback()
        end
        return
    end
    if not EliminateXYModel.data.eliminate_data then 
        if callback and type(callback) == "function" then
            callback()
        end
        return 
    end
    local data = EliminateXYModel.data.eliminate_data.result[index]
    local seq = DoTweenSequence.Create()
    seq:AppendCallback(function(  )
		EliminateXYHeroManager.BigGameShow(data)
    end)

    if data.swk_skill_award == 1 or data.swk_skill_award == 2 then
        local t = 0
        if data.swk_skill_award == 1 then
            t = EliminateXYModel.time.big_game_time + EliminateXYModel.time.swk_xc_qy
        elseif data.swk_skill_award == 2 then
            t = EliminateXYModel.time.big_game_time + EliminateXYModel.time.ts_jc_bao
        end
        seq:AppendInterval(EliminateXYModel.GetTime(t))
        --获奖励
        seq:AppendCallback(function(  )
            local rate = data.bgj_jc_rate
            local gold = EliminateXYModel.GetAwardGold(rate)
            if gold==0 then return end
            local cur_del_map = {}
            for x=1,EliminateXYModel.size.max_x - 1 do
                for y=1,EliminateXYModel.size.max_y do
                    cur_del_map[x] = cur_del_map[x] or {}
                    cur_del_map[x][y] = 0
                end
            end
            EliminateXYPartManager.CreateNumGoldInPos(Vector3.zero,gold)
        end)
        seq:AppendInterval(EliminateXYModel.GetTime(EliminateXYModel.time.big_game_jl))
        seq:AppendCallback(function (  )
            local cur_rate = data.bgj_jc_rate
            local cur_del_map = {}
            Event.Brocast("view_lottery_award", {cur_del_map = cur_del_map, cur_rate = cur_rate})
        end)
        seq:AppendInterval(EliminateXYModel.GetTime(4))
    else
        local t = EliminateXYModel.time.big_game_time
        seq:AppendInterval(EliminateXYModel.GetTime(t))
    end
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
            if item.data.id == EliminateXYModel.eliminate_enum.bgj then
                if IsEquals(item.ui.bg) then
                    item.ui.bg.gameObject:SetActive(true)
                end
                if IsEquals(item.ui.money_txt) then
                    EliminateXYItem.MoneyPlayAni(item.ui.money_txt,item.data.money)
                end
            end
        end
    end
end