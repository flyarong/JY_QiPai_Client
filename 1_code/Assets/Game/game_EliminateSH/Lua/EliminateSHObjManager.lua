local basefunc = require "Game.Common.basefunc"
EliminateSHObjManager = {}
local M = EliminateSHObjManager
package.loaded["Game.game_EliminateSH.Lua.EliminateSHItem"] = nil
require "Game.game_EliminateSH.Lua.EliminateSHItem"
package.loaded["Game.game_EliminateSH.Lua.EliminateSHItemBG"] = nil
require "Game.game_EliminateSH.Lua.EliminateSHItemBG"
package.loaded["Game.game_EliminateSH.Lua.EliminateSHHeroItem"] = nil
require "Game.game_EliminateSH.Lua.EliminateSHHeroItem"
package.loaded["Game.game_EliminateSH.Lua.EliminateSHHeroBG"] = nil
require "Game.game_EliminateSH.Lua.EliminateSHHeroBG"
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
    EliminateSHItem = newObject("EliminateSHItem",M.GetRoot()),
    EliminateSHHeroItem = newObject("EliminateSHHeroItem",M.GetRoot()),
    EliminateSHItemPhysics = newObject("EliminateSHItemPhysics",M.GetRoot()),
    EliminateSHItemBG = newObject("EliminateSHItemBG",M.GetRoot()),
    EliminateSHHeroBG = newObject("EliminateSHHeroBG",M.GetRoot()),
    xxl_icon_1 = GetTexture("shxxl_icon_1"),
    xxl_icon_2 = GetTexture("shxxl_icon_2"),
    xxl_icon_3 = GetTexture("shxxl_icon_3"),
    xxl_icon_4 = GetTexture("shxxl_icon_4"),
    xxl_icon_5 = GetTexture("shxxl_icon_5"),
    xxl_icon_6 = GetTexture("shxxl_icon_6"),
    xxl_icon_hero_1 = GetTexture("shxxl_icon_hero_1"),
    xxl_icon_hero_2 = GetTexture("shxxl_icon_hero_2"),
    xxl_icon_hero_3 = GetTexture("shxxl_icon_hero_3"),
    xxl_icon_hero_4 = GetTexture("shxxl_icon_hero_4"),
    material_FrontBlur = GetMaterial("FrontBlur"),
}

function M.InstantiateObj()
    for k,v in pairs(EliminateSHModel.eliminate_enum) do
        local _obj = GameObject.Instantiate(M.item_obj.EliminateSHItem,M.GetRoot())
        local img = _obj.gameObject.transform:Find("@icon_img"):GetComponent("Image")
        img.sprite = M.item_obj["xxl_icon_" .. v]
        M.item_obj["EliminateSHItem" .. v] =_obj

        local _obj_phy = GameObject.Instantiate(M.item_obj.EliminateSHItemPhysics,M.GetRoot())
        _obj_phy.gameObject.transform.localPosition = Vector3.one * 10000
        local img_phy = _obj_phy.gameObject.transform:Find("@icon_img"):GetComponent("Image")
        img_phy.sprite = M.item_obj["xxl_icon_" .. v]
        M.item_obj["EliminateSHItemPhysics" .. v] =_obj_phy
    end

    for i=1,4 do
        local _obj = GameObject.Instantiate(M.item_obj.EliminateSHHeroItem,M.GetRoot())
        local img = _obj.gameObject.transform:Find("@icon_img"):GetComponent("Image")
        img.sprite = M.item_obj["xxl_icon_hero_" .. i]
        M.item_obj["EliminateSHHeroItem" .. i] =_obj
    end
end

function M.Init()
    M.Exit()
    print("<color=yellow>消消乐obj初始化</color>")
    M.AddListener()
    item_map = {}
    M.InstantiateObj()
    M.item_obj.EliminateSHItemPhysics.transform.localPosition = Vector3.one * 10000
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
    local index = eliminate_sh_algorithm.get_map_max_index(item_map)
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
    EliminateSHAnimManager.EliminateItemDown(new_item_map,callback)
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
        EliminateSHAnimManager.Spring(new_item_map,EliminateSHModel.GetTime(EliminateSHModel.time.ys_xxldd),callback)
    end
    EliminateSHAnimManager.EliminateItemDown(new_item_map,_callback)
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
            item_map[x][y] = EliminateSHItem.Create({x = x,y = y,id = v,is_down = is_down})
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

function M.GetAllEliminateItem()
    return item_map
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
            bg_map[x][y] = EliminateSHItemBG.Create({x = x,y = y})    
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

function M.AddHeroItem(data)
    if table_is_null(data) then return end
    for x,_v in pairs(data) do
        for y,v in pairs(_v) do
            hero_map[x] = hero_map[x] or {}
            hero_map[x][y] = EliminateSHHeroItem.Create({x = x,y = y,id = v})
        end
    end
end

function M.RemoveHeroItem(data)
    if table_is_null(data) then return end
    for x,_v in pairs(data) do
        for y,v in pairs(_v) do
            if hero_map[x] and hero_map[x][y] then
                hero_map[x][y]:Exit()
                hero_map[x][y] = nil
            end
        end
    end
end

function M.GetHeroMap()
    return hero_map
end

function M.SetHeroItemGray(data)
    if table_is_null(data) then return end
    for x,_v in pairs(data) do
        for y,v in pairs(_v) do
            if hero_map[x] and hero_map[x][y] then
                hero_map[x][y]:SetHeroItemGray()
            end
        end
    end
end

function M.InitHeroBG(max_x,max_y)
    local map = {}
    for y=1,max_y do
        for x=1,max_x do
            map[x] = map[x] or {}
            map[x][y] = 1
        end
    end
    M.AddHeroBG(map)
end

function M.AddHeroBG(data)
    if table_is_null(data) then return end
    for x,_v in pairs(data) do
        for y,v in pairs(_v) do
            bg_hero_map[x] = bg_hero_map[x] or {}
            bg_hero_map[x][y] = EliminateSHHeroBG.Create({x = x,y = y})    
        end
    end
end

function M.RemoveHeroBG(data)
    if table_is_null(data) then return end
    for x,_v in pairs(data) do
        for y,v in pairs(_v) do
            if bg_hero_map[x] and bg_hero_map[x][y] then
                bg_hero_map[x][y]:Exit(data)
            end     
        end
    end
end

function M.RefreshHeroBG(data)
    if table_is_null(data) then return end
    for x,_v in pairs(data) do
        for y,v in pairs(_v) do
            if bg_hero_map[x] and bg_hero_map[x][y] then
                bg_hero_map[x][y]:Refresh(data)
            end     
        end
    end
end

--消除特效的类型和时间
function M.GetParticleDataEliminate(cur_result,cur_del_list)
    local xc_c = eliminate_sh_algorithm.get_xc_count(cur_del_list)
    local xc_id = eliminate_sh_algorithm.get_xc_id(cur_del_list)
    local is_hero1 = eliminate_sh_algorithm.check_cur_result_is_hero1(cur_result)
    local is_lucky = false
    local time = EliminateSHModel.GetTime(EliminateSHModel.time.xc_pt)

    if xc_id == 6 and xc_c > 3 and not table_is_null(cur_result.hero_add_list) then
        is_lucky = true
        time = EliminateSHModel.GetTime(EliminateSHModel.time.xc_lp)
    end

    local data = {}
    data.is_lucky = is_lucky
    data.is_hero1 = is_hero1
    data.time = time
    return data
end

function M.PlayParticleEliminateNull(cur_rate,hero_index)
    local index_y = hero_index + 2
    local data = {
        {x = 4,y = index_y,v = 6},
        {x = 5,y = index_y,v = 6},
    }
    EliminateSHPartManager.CreateNumGold(data,EliminateSHModel.GetAwardGold(cur_rate))       
end

function M.PlayParticleEliminate(particle_data,cur_del_list,cur_rate)
    if table_is_null(cur_del_list) then return end
    local data = eliminate_sh_algorithm.change_map_to_list(cur_del_list)
    local count = eliminate_sh_algorithm.get_xc_count(cur_del_list)
    if particle_data.is_hero1 == false then
        if count <= 4 then 
            EliminateSHPartManager.CreateEliminateNor1(data,EliminateSHModel.GetAwardGold(cur_rate))       
        elseif count <= 6 and count >= 5 then 
            EliminateSHPartManager.CreateEliminateNor2(data,EliminateSHModel.GetAwardGold(cur_rate))  
        else    
            EliminateSHPartManager.CreateEliminateNor3(data,EliminateSHModel.GetAwardGold(cur_rate))  
        end
    else    
        if count <= 4 then 
            EliminateSHPartManager.CreateEliminateWS1(data,EliminateSHModel.GetAwardGold(cur_rate))       
        elseif count <= 6 and count >= 5 then 
            EliminateSHPartManager.CreateEliminateWS2(data,EliminateSHModel.GetAwardGold(cur_rate))  
        else    
            EliminateSHPartManager.CreateEliminateWS3(data,EliminateSHModel.GetAwardGold(cur_rate))  
        end  
    end
end

function M.PlaySoundByEliminateCount(c)
    if c ==3 then
        ExtendSoundManager.PlaySound(audio_config.shxxl.bgm_shxxl_1xiao.audio_name)
    elseif c == 4 then
        ExtendSoundManager.PlaySound(audio_config.shxxl.bgm_shxxl_2xiao.audio_name)
    elseif c == 5 then
        ExtendSoundManager.PlaySound(audio_config.shxxl.bgm_shxxl_3xiao.audio_name)
    elseif c == 6 then
        ExtendSoundManager.PlaySound(audio_config.shxxl.bgm_shxxl_4xiao.audio_name)
    elseif c == 7 then
        ExtendSoundManager.PlaySound(audio_config.shxxl.bgm_shxxl_5xiao.audio_name)
    elseif c > 7 then
        ExtendSoundManager.PlaySound(audio_config.shxxl.bgm_shxxl_6xiao.audio_name)
    end
end

-------------------------------外部调用
function M.Lottery(cur_result,next_result,callback)
    if not EliminateSHModel.data then return end
    local seq = DoTweenSequence.Create()
    if not table_is_null(cur_result.del_list) then
        for i=1,#cur_result.del_list do
            local cur_del_list = basefunc.deepcopy(cur_result.del_list[1])
            table.remove(cur_result.del_list,1)
            local cur_rate = cur_result.del_rate_list[1]
            table.remove(cur_result.del_rate_list,1)
            M.DelListTrigger(cur_result,cur_del_list,nil,cur_rate,seq)
        end
    end

    M.HeroSkillTrigger(cur_result,next_result,callback,seq)
end

--手动开奖
function M.LotteryManuallyEnd()
    M.ManuallyStart = nil
    M.cur_result = nil
    M.next_result = nil
    M.callback = nil
end

function M.LotteryManually(cur_result,next_result,callback)
    if not EliminateSHModel.data then return end
    M.ManuallyStart = true
    M.cur_result = cur_result
    M.next_result = next_result
    M.callback = callback

    --自动消除令牌
    M.AutoLotteryLucky()
end

function M.AutoLotteryLucky()
    --检查点击是否可以消除
    if not EliminateSHModel.data or not M.ManuallyStart then return end
    local cur_result = M.cur_result
    local next_result = M.next_result
    local callback = M.callback
    if table_is_null(cur_result) then return end --没有开奖结果
    local seq = DoTweenSequence.Create()
    --优先自动消除出英雄的令牌
    if not table_is_null(cur_result.del_list) then
        for i=1,#cur_result.del_list do
            local cur_del_list = basefunc.deepcopy(cur_result.del_list[i])
            local cur_rate = cur_result.del_rate_list[i]
            --英雄
            local hero_list = EliminateSHHeroManager.GetHeroShowList(cur_result,cur_del_list,nil,true)
            if hero_list then
                M.ManuallyStart = false
                table.remove(cur_result.del_list,i)
                table.remove(cur_result.del_rate_list,i)
                M.DelListTrigger(cur_result,cur_del_list,nil,cur_rate,seq)
            end
        end
    end

    M.HeroSkillTrigger(cur_result,next_result,callback,seq)
end

function M.OnClickLotteryManually(data)
    --检查点击是否可以消除
    if not EliminateSHModel.data or not M.ManuallyStart then return end
    local cur_result = M.cur_result
    local next_result = M.next_result
    local callback = M.callback
    if table_is_null(cur_result) or table_is_null(cur_result.del_list) then return end --没有开奖结果
    local seq = DoTweenSequence.Create()
    if not table_is_null(cur_result.del_list) then
        local cur_del_list
        local cur_rate
        local cur_del_index 
        for i=1,#cur_result.del_list do
            if cur_result.del_list[i][data.x] and cur_result.del_list[i][data.x][data.y] and cur_result.del_list[i][data.x][data.y] == data.id then
                cur_del_list = basefunc.deepcopy(cur_result.del_list[i])
                cur_del_index = i
                cur_rate = cur_result.del_rate_list[i]
                table.remove(cur_result.del_list,i)
                table.remove(cur_result.del_rate_list,i)
                break
            end
        end
        if table_is_null(cur_del_list) then
            LittleTips.Create("注意观察哪里可以消除")
            return
        end
        M.DelListTrigger(cur_result,cur_del_list,cur_del_index,cur_rate,seq)
    end

    --消除结束英雄技能触发
    M.HeroSkillTrigger(cur_result,next_result,callback,seq)
end

function M.DelListTrigger(cur_result,cur_del_list,cur_del_index,cur_rate,seq)
    if not table_is_null(cur_del_list) then
        --点击到可消除的元素
        local particle_data = M.GetParticleDataEliminate(cur_result,cur_del_list)
        if particle_data.is_lucky then
            seq:AppendCallback(function ()
                --令牌特效
                ExtendSoundManager.PlaySound(audio_config.shxxl.bgm_shxxl_lingpai.audio_name)
                EliminateSHPartManager.CreateLuckyRight(cur_del_list,EliminateSHModel.GetTime(EliminateSHModel.time.xc_lp_sg))
            end)
            seq:AppendInterval(EliminateSHModel.GetTime(EliminateSHModel.time.xc_lp_sg))
        end
        seq:AppendCallback(function ()
            --消除音效
            local xc_count = eliminate_sh_algorithm.get_xc_count(cur_del_list)
            M.PlaySoundByEliminateCount(xc_count)
            local _rate = cur_rate
            --消除特效
            if EliminateSHModel.CheckHeroIsCreateInAllResult() and not particle_data.is_hero1 then
                _rate = _rate / 2
            end
            M.PlayParticleEliminate(particle_data,cur_del_list,_rate)
        end)
        local hero1 = EliminateSHHeroManager.GetHeroSkillTrigger(cur_result,1,cur_rate)
        if hero1 then
            hero1.cur_del_list = cur_del_list
            seq:AppendCallback(function ()
                EliminateSHHeroManager.HeroSkillTrigger(hero1,cur_result)
            end)
            seq:AppendInterval(EliminateSHModel.GetTime(hero1.skill_time))
        end
        seq:AppendInterval(EliminateSHModel.GetTime(particle_data.time))

        seq:AppendCallback(function ()
            M.RemoveEliminateItem(cur_del_list)
            local view_cur_rate = cur_rate
            if EliminateSHModel.CheckIsHero1(cur_result) then
                view_cur_rate = view_cur_rate / 2
            end
            if particle_data.is_lucky then
                --令牌出英雄
                Event.Brocast("view_lottery_award",{cur_del_list = nil,cur_rate = view_cur_rate})
            else
                --令牌不出英雄
                Event.Brocast("view_lottery_award",{cur_del_list = cur_del_list,cur_rate = view_cur_rate})
            end
        end)

        --英雄
        local hero_list = EliminateSHHeroManager.GetHeroShowList(cur_result,cur_del_list,cur_del_index)
        if hero_list then
            --所有出英雄的门特效
            seq:AppendCallback(function ()
                M.ManuallyStart = false
                EliminateSHHeroManager.HeroShow(hero_list,cur_result.hero)
            end)
            seq:AppendInterval(EliminateSHModel.GetTime(EliminateSHModel.time.yx_km))
            seq:AppendCallback(function ()
                --门震动效果
                EliminateSHAnimManager.DOShakePositionCamer(nil,EliminateSHModel.GetTime(EliminateSHModel.time.yx_km_zd))
            end)
            seq:AppendInterval(EliminateSHModel.GetTime(EliminateSHModel.time.yx_km_wc))
            --每个英雄出现就使用的技能
            for i,v in ipairs(hero_list) do
                seq:AppendCallback(function ()
                    EliminateSHHeroManager.HeroSkillContinued(v,cur_result)
                end)
                seq:AppendInterval(EliminateSHModel.GetTime(v.show_time))--英雄技能时间根据每个英雄不同
            end
        end
        seq:AppendCallback(function ()
            M.ManuallyStart = true
        end)
        seq:AppendInterval(EliminateSHModel.GetTime(EliminateSHModel.time.xc_xyz))
    end
end

function M.HeroSkillTrigger(cur_result,next_result,callback,seq)
    if table_is_null(cur_result.del_list) then
        --英雄2技能
        local hero2 = EliminateSHHeroManager.GetHeroSkillTrigger(cur_result,2)
        if hero2 then
            seq:AppendCallback(function ()
                M.ManuallyStart = false
                EliminateSHHeroManager.HeroSkillTrigger(hero2,cur_result)
            end)
            seq:AppendInterval(EliminateSHModel.GetTime(hero2.skill_time))
            -- seq:AppendInterval(EliminateSHModel.GetTime(EliminateSHModel.time.yx_xyg))
        end
        --英雄3技能
        local hero3 = EliminateSHHeroManager.GetHeroSkillTrigger(cur_result,3)
        if hero3 then
            seq:AppendCallback(function ()
                M.ManuallyStart = false
                EliminateSHHeroManager.HeroSkillTrigger(hero3,cur_result)
            end)
            seq:AppendInterval(EliminateSHModel.GetTime(hero3.skill_time))
            -- seq:AppendInterval(EliminateSHModel.GetTime(EliminateSHModel.time.yx_xyg))
        end

        --结束本次消除
        seq:AppendCallback(function ()
            M.ManuallyStart = false
            M.EliminateItemDown()
        end)
        seq:AppendInterval(EliminateSHModel.GetTime(EliminateSHModel.time.ys_jxlh))

        --本局结束有map_add
        if cur_result.map_add then
            seq:AppendCallback(function ()
                M.ManuallyStart = false
                ExtendSoundManager.PlaySound(audio_config.shxxl.bgm_shxxl_luoxia.audio_name)
                M.CreateEliminateItemDown(cur_result.map_add)
                M.EliminateItemDownNew(cur_result.map_add)
            end)
            seq:AppendInterval(EliminateSHModel.GetTime(EliminateSHModel.time.ys_xxlh))--新元素下落时间
        end

        seq:AppendCallback(function ()
            M.ManuallyStart = false
            M.ClearEliminateItem()
            M.CreateEliminateItem(cur_result.map_new)
        end)

        --英雄4技能
        local hero4 = EliminateSHHeroManager.GetHeroSkillTrigger(cur_result,4)
        if hero4 then
            seq:AppendCallback(function ()
                M.ManuallyStart = false
                EliminateSHHeroManager.HeroSkillTrigger(hero4,cur_result,next_result)
            end)
            seq:AppendInterval(EliminateSHModel.GetTime(hero4.skill_time))
        end

        --掉落完成开始消除下一屏的元素
        seq:AppendInterval(EliminateSHModel.GetTime(EliminateSHModel.time.xc_xyp))

        seq:OnKill(function ()
            M.ManuallyStart = true
            if callback and type(callback) == "function" then
                callback()
            end
        end)
    end
end