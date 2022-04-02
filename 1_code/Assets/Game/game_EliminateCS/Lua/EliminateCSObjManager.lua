local basefunc = require "Game.Common.basefunc"
EliminateCSObjManager = {}
local M = EliminateCSObjManager
package.loaded["Game.game_EliminateCS.Lua.EliminateCSItem"] = nil
require "Game.game_EliminateCS.Lua.EliminateCSItem"
package.loaded["Game.game_EliminateCS.Lua.EliminateCSItemBG"] = nil
require "Game.game_EliminateCS.Lua.EliminateCSItemBG"
local item_map = {}
local bg_map = {}
local hero_map = {}
local bg_hero_map = {}
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
    EliminateCSItem = newObject("EliminateCSItem",M.GetRoot()),
    EliminateCSItemPhysics = newObject("EliminateCSItemPhysics",M.GetRoot()),
    EliminateCSItemBG = newObject("EliminateCSItemBG",M.GetRoot()),
    xxl_icon_1 = GetTexture("csxxl_icon_1"),
    xxl_icon_2 = GetTexture("csxxl_icon_2"),
    xxl_icon_3 = GetTexture("csxxl_icon_3"),
    xxl_icon_4 = GetTexture("csxxl_icon_4"),
    xxl_icon_5 = GetTexture("csxxl_icon_5"),
    xxl_icon_6 = GetTexture("csxxl_icon_6"),
    xxl_icon_7 = GetTexture("csxxl_icon_7"),
    xxl_icon_8 = GetTexture("csxxl_icon_8"),
    xxl_icon_9 = GetTexture("csxxl_icon_9"),
    xxl_icon_10 = GetTexture("csxxl_icon_10"),
    material_FrontBlur = GetMaterial("FrontBlur"),
}

function M.InstantiateObj()
    for k,v in pairs(EliminateCSModel.eliminate_enum) do
        local _obj = GameObject.Instantiate(M.item_obj.EliminateCSItem,M.GetRoot())
        local img = _obj.gameObject.transform:Find("@icon_img"):GetComponent("Image")
        img.sprite = M.item_obj["xxl_icon_" .. v]
        M.item_obj["EliminateCSItem" .. v] =_obj

        local _obj_phy = GameObject.Instantiate(M.item_obj.EliminateCSItemPhysics,M.GetRoot())
        _obj_phy.gameObject.transform.localPosition = Vector3.one * 10000
        local img_phy = _obj_phy.gameObject.transform:Find("@icon_img"):GetComponent("Image")
        img_phy.sprite = M.item_obj["xxl_icon_" .. v]
        M.item_obj["EliminateCSItemPhysics" .. v] =_obj_phy
    end
end

function M.Init()
    M.Exit()
    print("<color=yellow>消消乐obj初始化</color>")
    M.AddListener()
    item_map = {}
    M.InstantiateObj()
    M.item_obj.EliminateCSItemPhysics.transform.localPosition = Vector3.one * 10000
end

function M.Exit()
    print("<color=white>objManager退出</color>")
    M.RemoveListener()
    soundMgr:CloseSound()
    M.ExitTimer()
    for x,_v in pairs(item_map) do
        for y,v in pairs(_v) do
            v:Exit()
        end
    end
    item_map = {}
    for x,_v in pairs(bg_map) do
        for y,v in pairs(_v) do
            v:Exit()
        end
    end
	--for x,_v in pairs(M.item_obj) do
	--	M.item_obj[x] = nil
	--end
	--M.item_obj = {}

    bg_map = {}
    for x,_v in pairs(hero_map) do
        for y,v in pairs(_v) do
            v:Exit()
        end
    end
    hero_map = {}
    for x,_v in pairs(bg_hero_map) do
        for y,v in pairs(_v) do
            v:Exit()
        end
    end
    bg_hero_map = {}
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
    for proto_name,func in pairs(lister) do
        Event.AddListener(proto_name, func)
    end
end

function M.MakeLister()
    lister = {}    
	lister["ExitScene"] = M.Exit
	lister["OnLoginResponse"] = M.Exit
	lister["will_kick_reason"] = M.Exit
    lister["DisconnectServerConnect"] = M.Exit
end

function M.RemoveListener()
    for proto_name,func in pairs(lister) do
        Event.RemoveListener(proto_name, func)
    end
end

function M.CreateEliminateItem(data)
    local map = {}
    if data and next(data) then
        for x,_v in pairs(data) do
            for y,v in pairs(_v) do
                map[x] = map[x] or {}
                map[x][y] = v
            end
        end
    end
    M.AddEliminateItem(map)
end

function M.CreateEliminateItemDown(data)
    local map = {}
    for x,_v in pairs(data) do
        for y,v in pairs(_v) do
            map[x] = map[x] or {}
            map[x][y] = v
        end
    end
    M.AddEliminateItem(map,true)
end

function M.ClearEliminateItem()
    for x,_v in pairs(item_map) do
        for y,v in pairs(_v) do
            v:Exit()
        end
    end
    item_map = {}
end

--item下滑
function M.EliminateItemDown(callback)
    local new_item_map = {}
    local new_y = 1
    local index = eliminate_cs_algorithm.get_map_max_index(item_map)
    for x=1,index.x do
        new_y = 1
        for y=1,index.y do
            if item_map[x] and item_map[x][y] then
                new_item_map[x] = new_item_map[x] or {}
                new_item_map[x][new_y] = item_map[x][y]
                new_y = new_y + 1
            end
        end
    end
    item_map = new_item_map
    EliminateCSAnimManager.EliminateItemDown(new_item_map,callback)
end

function M.EliminateItemDownNew(map,callback)
    local new_item_map = {}
    for x,_v in pairs(map) do
        for y,v in pairs(_v) do
            new_item_map[x] = new_item_map[x] or {}
            new_item_map[x][y] = item_map[x][y]
        end
    end
    local function _callback()
        EliminateCSAnimManager.Spring(new_item_map,EliminateCSModel.GetTime(EliminateCSModel.time.ys_xxldd),callback)
    end
    EliminateCSAnimManager.EliminateItemDown(new_item_map,_callback)
end

function M.AddEliminateItem(data,is_down)
    if table_is_null(data) then return end
    local add_item_map = {}
    for x,_v in pairs(data) do
        for y,v in pairs(_v) do
            if item_map[x] and item_map[x][y] then
                item_map[x][y]:Exit() 
            end
            item_map[x] = item_map[x] or {}
            item_map[x][y] = EliminateCSItem.Create({x = x,y = y,id = v,is_down = is_down})
            add_item_map[x] = add_item_map[x] or {}
            add_item_map[x][y] = item_map[x][y]
            -- M.RefreshEliminateBG(data)
        end
    end
    return add_item_map
end

function M.RemoveEliminateItem(data)
    if table_is_null(data) then return end
    for x,_v in pairs(data) do
        for y,v in pairs(_v) do
            if item_map[x] and item_map[x][y] then
                item_map[x][y]:Exit()
                item_map[x][y] = nil
            end
        end
    end
end

function M.HideEliminateItem(data)
    if table_is_null(data) then return end
    for x,_v in pairs(data) do
        for y,v in pairs(_v) do
            if item_map[x] and item_map[x][y] then
                item_map[x][y]:SetView(false)
            end
        end
    end
end

function M.GetAllEliminateItem()
    return item_map
end

function M.GetEliminateItem(x,y)
    if item_map[x] then
        return item_map[x][y]
    end
end

function M.InitEliminateBG(max_x,max_y)
    local map = {}
    for y=1,max_y do
        for x=1,max_x do
            map[x] = map[x] or {}
            map[x][y] = 1
        end
    end
    M.AddEliminateBG(map)
end

function M.AddEliminateBG(data)
    if table_is_null(data) then return end
    for x,_v in pairs(data) do
        for y,v in pairs(_v) do
            bg_map[x] = bg_map[x] or {}
            bg_map[x][y] = EliminateCSItemBG.Create({x = x,y = y})    
        end
    end
end

function M.RemoveEliminateBG(data)
    if table_is_null(data) then return end
    for x,_v in pairs(data) do
        for y,v in pairs(_v) do
            if bg_map[x] and bg_map[x][y] then
                bg_map[x][y]:Exit(data)
            end     
        end
    end
end

function M.RefreshEliminateBG(data)
    if table_is_null(data) then return end
    for x,_v in pairs(data) do
        for y,v in pairs(_v) do
            if bg_map[x] and bg_map[x][y] then
                bg_map[x][y]:Refresh(data)
            end     
        end
    end
end

--消除特效的类型和时间
function M.GetParticleDataEliminate(cur_result,cur_del_list)
    local xc_c = eliminate_cs_algorithm.get_xc_count(cur_del_list)
    local xc_id = eliminate_cs_algorithm.get_xc_id(cur_del_list)
    local is_lucky = false
    local is_lucky_complete = false
    local is_lucky_ready = false
    local is_lucky_geted = false
    local is_lucky_over = false
    local lucky_zi
    local all_jindan_value
    if xc_id == 6 then
        is_lucky = true
        all_jindan_value = cur_result.all_jindan_value_cur
        if not table_is_null(cur_result.all_jindan_value_list) then
            table.remove(cur_result.all_jindan_value_list,1)
            for i,v in ipairs(cur_result.all_jindan_value_list) do
                all_jindan_value = all_jindan_value - v
            end
        end

        local all_tnsh_list_cur 
        if not table_is_null(cur_result.all_tnsh_list_cur) then
            all_tnsh_list_cur = basefunc.deepcopy(cur_result.all_tnsh_list_cur)
        end

        if not table_is_null(cur_result.all_tnsh_list) then
            for i,v in ipairs(cur_result.all_tnsh_list) do
                all_tnsh_list_cur[v] = all_tnsh_list_cur[v] - 1
            end
        end
        lucky_zi = cur_result.all_tnsh_list[1]
        table.remove(cur_result.all_tnsh_list,1)
        if not table_is_null(all_tnsh_list_cur) then
            local c = 0
            for i,v in ipairs(all_tnsh_list_cur) do
                if v > 0 then
                    c = c + 1
                end
            end
            is_lucky_ready = c == 3

            if c == 3 and lucky_zi and all_tnsh_list_cur[lucky_zi] == 0 then
                is_lucky_complete = true
            end

            if all_tnsh_list_cur[lucky_zi] > 0 then
                is_lucky_geted = true
            end

            is_lucky_over = c == 4
        end
    end

    local data = {}
    data.is_lucky_ready = is_lucky_ready
    data.is_lucky_complete = is_lucky_complete
    data.is_lucky_geted = is_lucky_geted
    data.is_lucky_over = is_lucky_over
    data.is_lucky = is_lucky
    data.lucky_zi = lucky_zi
    data.all_jindan_value = all_jindan_value
    return data
end

function M.PlayParticleEliminateNull(cur_rate,hero_index)
    local index_y = hero_index + 2
    local data = {
        {x = 4,y = index_y,v = 6},
        {x = 5,y = index_y,v = 6},
    }
    EliminateCSPartManager.CreateNumGold(data,EliminateCSModel.GetAwardGold(cur_rate))       
end

function M.PlayParticleEliminate(particle_data,cur_del_list,cur_rate)
    if table_is_null(cur_del_list) then return end
    local data = eliminate_cs_algorithm.change_map_to_list(cur_del_list)
    local count = eliminate_cs_algorithm.get_xc_count(cur_del_list)
    if particle_data.is_lucky == false then
        if count <= 4 then 
            EliminateCSPartManager.CreateEliminateNor1(data,EliminateCSModel.GetAwardGold(cur_rate))       
        elseif count <= 6 and count >= 5 then 
            EliminateCSPartManager.CreateEliminateNor2(data,EliminateCSModel.GetAwardGold(cur_rate))  
        else    
            EliminateCSPartManager.CreateEliminateNor3(data,EliminateCSModel.GetAwardGold(cur_rate))  
        end
    else    
        if count <= 4 then 
            EliminateCSPartManager.CreateEliminateJD1(data,EliminateCSModel.GetAwardGold(cur_rate))       
        elseif count <= 6 and count >= 5 then 
            EliminateCSPartManager.CreateEliminateJD2(data,EliminateCSModel.GetAwardGold(cur_rate))  
        else    
            EliminateCSPartManager.CreateEliminateJD3(data,EliminateCSModel.GetAwardGold(cur_rate))  
        end  
    end
end

function M.PlaySoundByEliminateCount(c)
    if c ==3 then
        ExtendSoundManager.PlaySound(audio_config.csxxl.bgm_csxxl_1xiao.audio_name)
    elseif c == 4 then
        ExtendSoundManager.PlaySound(audio_config.csxxl.bgm_csxxl_2xiao.audio_name)
    elseif c == 5 then
        ExtendSoundManager.PlaySound(audio_config.csxxl.bgm_csxxl_3xiao.audio_name)
    elseif c == 6 then
        ExtendSoundManager.PlaySound(audio_config.csxxl.bgm_csxxl_4xiao.audio_name)
    elseif c == 7 then
        ExtendSoundManager.PlaySound(audio_config.csxxl.bgm_csxxl_5xiao.audio_name)
    elseif c > 7 then
        ExtendSoundManager.PlaySound(audio_config.csxxl.bgm_csxxl_6xiao.audio_name)
    end
end

-------------------------------外部调用
function M.Lottery(cur_result,callback,next_result)
    if EliminateCSModel.DataDamage() then return end
    -- dump(cur_result, "<color=white>cur_result??????????????</color>")
    EliminateCSModel.data.state = cur_result.state
    local seq = DoTweenSequence.Create()
    local del_list = function()
        if not table_is_null(cur_result.del_list) then
            --正常消除
            for i=1,#cur_result.del_list do
                local cur_del_list = basefunc.deepcopy(cur_result.del_list[1])
                table.remove(cur_result.del_list,1)
                local cur_rate = cur_result.del_rate_list[1]
                table.remove(cur_result.del_rate_list,1)
                M.DelListTrigger(cur_result,cur_del_list,cur_rate,seq)
            end
        end
        M.DelListEnd(cur_result,callback,seq)
    end

    local lottery_agin = function()
        local _seq = DoTweenSequence.Create()
        _seq:AppendInterval(EliminateCSModel.GetTime(EliminateCSModel.time.xc_zkj))
        _seq:OnKill(function ()
            if not table_is_null(next_result) then
                local item_map = EliminateCSObjManager.GetAllEliminateItem()
                local times = {
                    ys_jsgdsj = EliminateCSModel.time.ys_jsgdsj,
                    ys_ysgdjg = EliminateCSModel.time.ys_ysgdjg,
                    ys_j_sgdsj = EliminateCSModel.time.ys_j_sgdsj,
                    ys_jsgdjg = EliminateCSModel.time.ys_jsgdjg
                }
                EliminateCSAnimManager.ScrollLottery(item_map,times)      

                local new_map = next_result.map_base
                local times = {
                    ys_j_sgdjg = EliminateCSModel.time.ys_j_sgdjg,
                    ys_ysgdsj = EliminateCSModel.time.ys_ysgdsj,
                }
                EliminateCSAnimManager.StopScrollLottery(new_map,function()
                    if callback and type(callback) == "function" then
                        callback()
                        EliminateCSPartManager.CreateTNSH()
                    end
                end,times)
            else
                if callback and type(callback) == "function" then
                    callback()
                end
            end
        end)
    end

    if cur_result.state == EliminateCSModel.xc_state.nor then
        del_list()
        return
    end
    if cur_result.state == EliminateCSModel.xc_state.zd then
        --进入砸蛋
        seq:AppendCallback(function ()
            EliminateCSPartManager.CreateZDJH1()
        end)
        seq:AppendInterval(EliminateCSModel.time.xc_zd1)
        seq:AppendCallback(function ()
            ExtendSoundManager.PlaySound(audio_config.csxxl.bgm_csxxl_tiannvsanhuachufa.audio_name)
            EliminateCSPartManager.CreateZDJH()
        end)
        seq:AppendInterval(EliminateCSModel.time.xc_zd)
        seq:OnKill(function ()
            EliminateCSZDGamePanel.Create(cur_result,function()
                lottery_agin()
            end)
        end)
        return
    end
    if cur_result.state == EliminateCSModel.xc_state.zp then
        --进入转盘
        seq:AppendCallback(function ()
            ExtendSoundManager.PlaySound(audio_config.csxxl.bgm_csxxl_caishendanchufa.audio_name)
            EliminateCSPartManager.CreateZPJH()
        end)
        seq:AppendInterval(EliminateCSModel.time.xc_zp)
        seq:OnKill(function ()
            EliminateCSZPGamePanel.Create(cur_result,EliminateCSModel.xiaoxiaole_cs_defen_cfg.zp,
                function ()
                    lottery_agin()
                end,true)
        end)
        return
    end
    if cur_result.state == EliminateCSModel.xc_state.zd_tnsh or cur_result.state == EliminateCSModel.xc_state.zp_tnsh then
        Event.Brocast("view_xxl_caishen_tnsh_kj")
        M.HBShow(cur_result,seq)
        del_list()
        return
    end
    HintPanel.Create(1,"状态错误",function (  )
        Event.Brocast("model_xxl_caishen_all_info_error")
    end)
end

function M.DelListTrigger(cur_result,cur_del_list,cur_rate,seq)
    if not table_is_null(cur_del_list) then
        --点击到可消除的元素
        local particle_data = M.GetParticleDataEliminate(cur_result,cur_del_list)
        if not particle_data.is_lucky then
            --普通消除
            seq:AppendCallback(function ()
                --消除音效
                local xc_count = eliminate_cs_algorithm.get_xc_count(cur_del_list)
                M.PlaySoundByEliminateCount(xc_count)
                M.PlayParticleEliminate(particle_data,cur_del_list,cur_rate)
            end)
            seq:AppendInterval(EliminateCSModel.GetTime(EliminateCSModel.time.xc_pt))
            seq:AppendCallback(function ()
                --元素消除
                M.RemoveEliminateItem(cur_del_list)
                Event.Brocast("view_lottery_award",{cur_del_list = cur_del_list,cur_rate = cur_rate})
            end)
        else
            if particle_data.is_lucky_ready then
                --集了3个字
                seq:AppendCallback(function ()
                    --隐藏当前消除的元素
                    M.HideEliminateItem(cur_del_list)
                    EliminateCSPartManager.CreateXCZ3(cur_del_list,EliminateCSModel.time.xc_zi3)
                end)
                seq:AppendInterval(EliminateCSModel.GetTime(EliminateCSModel.time.xc_pt))
                seq:AppendCallback(function ()
                    local xc_count = eliminate_cs_algorithm.get_xc_count(cur_del_list)
                    M.PlaySoundByEliminateCount(xc_count)
                end)
                seq:AppendInterval(EliminateCSModel.GetTime(EliminateCSModel.time.xc_zi3 - EliminateCSModel.time.xc_pt))
            else
                --普通消除
                seq:AppendCallback(function ()
                    --消除音效
                    local xc_count = eliminate_cs_algorithm.get_xc_count(cur_del_list)
                    M.PlaySoundByEliminateCount(xc_count)
                    M.PlayParticleEliminate(particle_data,cur_del_list,cur_rate)
                end)
                seq:AppendInterval(EliminateCSModel.GetTime(EliminateCSModel.time.xc_pt))
            end

            --金蛋出字
            seq:AppendCallback(function ()
                local data = eliminate_cs_algorithm.change_map_to_list(cur_del_list)
                if not particle_data.is_lucky_over then
                    EliminateCSPartManager.CreateJDZ(data,particle_data.lucky_zi,particle_data.is_lucky_geted)
                end
                EliminateCSPartManager.CreateJDJDT(data,particle_data.all_jindan_value)
                M.HideEliminateItem(cur_del_list)
                --元素消除
                M.RemoveEliminateItem(cur_del_list)
                Event.Brocast("view_lottery_award",{cur_del_list = cur_del_list,cur_rate = cur_rate})
            end)
            seq:AppendInterval(EliminateCSModel.GetTime(EliminateCSModel.time.xc_chu_zi))

            if particle_data.is_lucky_complete then
                --集了4个字
                seq:AppendCallback(function ()
                    EliminateCSPartManager.CreateZiComplete()
                end)
                seq:AppendInterval(EliminateCSModel.time.xc_zi4_1)
            end
        end   
        seq:AppendInterval(EliminateCSModel.GetTime(EliminateCSModel.time.xc_xyz))
    end
end

function M.DelListEnd(cur_result,callback,seq)
    if table_is_null(cur_result.del_list) then
        --结束本次消除
        seq:AppendCallback(function ()
            M.EliminateItemDown()
        end)
        seq:AppendInterval(EliminateCSModel.GetTime(EliminateCSModel.time.ys_jxlh))

        --本局结束有map_add
        if cur_result.map_add then
            seq:AppendCallback(function ()
                ExtendSoundManager.PlaySound(audio_config.csxxl.bgm_csxxl_luoxia.audio_name)
                M.CreateEliminateItemDown(cur_result.map_add)
                M.EliminateItemDownNew(cur_result.map_add)
            end)
            seq:AppendInterval(EliminateCSModel.GetTime(EliminateCSModel.time.ys_xxlh))--新元素下落时间
        end
        seq:AppendCallback(function ()
            M.ClearEliminateItem()
            M.CreateEliminateItem(cur_result.map_new)
        end)
        --掉落完成开始消除下一屏的元素
        seq:AppendInterval(EliminateCSModel.GetTime(EliminateCSModel.time.xc_xyp))

        seq:OnKill(function ()
            if callback and type(callback) == "function" then
                callback()
            end
        end)
    end
end

--花瓣掉落
function M.HBShow(cur_result,seq)
    if not table_is_null(cur_result.hb_map_change) then
        seq:AppendCallback(function ()
            --花瓣特效
            -- ExtendSoundManager.PlaySound(audio_config.csxxl.bgm_csxxl_lingpai.audio_name)
            EliminateCSPartManager.CreateHBRight(cur_result.hb_map_change,EliminateCSModel.GetTime(EliminateCSModel.time.xc_hb))
        end)
        seq:AppendInterval(EliminateCSModel.GetTime(EliminateCSModel.time.xc_hb))
    end
end