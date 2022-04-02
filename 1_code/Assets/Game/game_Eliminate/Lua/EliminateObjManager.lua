local basefunc = require "Game.Common.basefunc"
local basefunc = require "Game.Common.basefunc"
EliminateObjManager = {}
local M = EliminateObjManager
package.loaded["Game.game_Eliminate.Lua.EliminateFruitItem"] = nil
require "Game.game_Eliminate.Lua.EliminateFruitItem"
package.loaded["Game.game_Eliminate.Lua.EliminateFruitBG"] = nil
require "Game.game_Eliminate.Lua.EliminateFruitBG"
local item_map = {}
local bg_map = {}
local lister = {}
function M.GetRoot()
    M.root = M.root or GameObject.Find("GameObject")
    if IsEquals(M.root) then 
        return M.root.transform
    else
        
    end
    return M.root
end

M.item_obj = {
    EliminateFruitItem = newObject("EliminateFruitItem",M.GetRoot()),
    EliminateFruitItemPhysics = newObject("EliminateFruitItemPhysics",M.GetRoot()),
    EliminateFruitBG = newObject("EliminateFruitBG",M.GetRoot()),
    xxl_icon_1 = GetTexture("xxl_icon_1_off"),
    xxl_icon_2 = GetTexture("xxl_icon_2_off"),
    xxl_icon_3 = GetTexture("xxl_icon_3_off"),
    xxl_icon_4 = GetTexture("xxl_icon_4_off"),
    xxl_icon_5 = GetTexture("xxl_icon_5_off"),
    xxl_icon_6 = GetTexture("xxl_icon_6"),
    material_FrontBlur = GetMaterial("FrontBlur"),
}

M.Audio = {}

function M.InstantiateObj()
    for k,v in pairs(EliminateModel.fruit_enum) do
        local _obj = GameObject.Instantiate(M.item_obj.EliminateFruitItem,M.GetRoot())
        local img = _obj.gameObject.transform:Find("@icon_img"):GetComponent("Image")
        img.sprite = M.item_obj["xxl_icon_" .. v]
        M.item_obj["EliminateFruitItem" .. v] =_obj

        local _obj_phy = GameObject.Instantiate(M.item_obj.EliminateFruitItemPhysics,M.GetRoot())
        _obj_phy.gameObject.transform.localPosition = Vector3.one * 10000
        local img_phy = _obj_phy.gameObject.transform:Find("@icon_img"):GetComponent("Image")
        img_phy.sprite = M.item_obj["xxl_icon_" .. v]
        M.item_obj["EliminateFruitItemPhysics" .. v] =_obj_phy
    end
end

function M.Init()
    print("<color=yellow>消消乐obj初始化</color>")
    M.AddListener()
    item_map = {}
    M.InstantiateObj()
    M.item_obj.EliminateFruitItemPhysics.transform.localPosition = Vector3.one * 10000
end

function M.Exit()
    print("<color=white>objManager退出</color>")
    M.RemoveListener()
    M.ExitTimer()
    for x,_v in pairs(item_map) do
        for y,v in pairs(_v) do
            v:Exit()
        end
    end
    item_map = {}

	--for x,_v in pairs(M.item_obj) do
	--	M.item_obj[x] = nil
	--end
	--M.item_obj = {}

    for x,_v in pairs(bg_map) do
        for y,v in pairs(_v) do
            v:Exit()
        end
    end
    bg_map = {}
end

function M.ExitTimer()
    print("<color=white>objManager timer退出</color>")
    if M.change_lucky_timer  then M.change_lucky_timer:Stop() end
    if M.play_fruit_part_timer  then M.play_fruit_part_timer:Stop() end
    if M.eliminate_next_arr_timer  then M.eliminate_next_arr_timer:Stop() end
    if M.eliminate_next_scr_timer  then M.eliminate_next_scr_timer:Stop() end
    if M.lucky_change_timer  then M.lucky_change_timer:Stop() end
    if M.lucky_change_t_timer  then M.lucky_change_t_timer:Stop() end
    if M.fruit_shake_timer  then M.fruit_shake_timer:Stop() end
    if M.del_clear_right_timer  then M.del_clear_right_timer:Stop() end
    if M.del_all_type_right_timer  then M.del_all_type_right_timer:Stop() end
    if M.del_type_mask_timer  then M.del_type_mask_timer:Stop() end
    if M.del_type_lottery_timer  then M.del_type_lottery_timer:Stop() end
    if M.win_lucky_ll_right_timer  then M.win_lucky_ll_right_timer:Stop() end
    if M.del_clear_timer  then M.del_clear_timer:Stop() end
    if M.win_lucky_right_timer  then M.win_lucky_right_timer:Stop() end
    if M.del_clear_pz_timer  then M.del_clear_pz_timer:Stop() end
    if M.fic_del_timer then M.fic_del_timer:Stop() end

    soundMgr:CloseSound()
    M.Audio = {}
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
    if data and next(data) then
        for x,_v in pairs(data) do
            for y,v in pairs(_v) do
                M.AddEliminateItem({x = x,y = y,id = v})
            end
        end
    end
end

function M.CreateEliminateItemDown(data)
    for x,_v in pairs(data) do
        for y,v in pairs(_v) do
            M.AddEliminateItem({x = x,y = y,id = v, is_down = true})
        end
    end
end

function M.ClearEliminateItem()
    EliminatePartManager.ClearFxItemMap()
    for x,_v in pairs(item_map) do
        for y,v in pairs(_v) do
            v:Exit()
        end
    end
    item_map = {}
end

--根据自身的item_map表进行更新
function M.RefreshEliminateItemByItemMap(  )
    local new_map ={}
    for x,_v in pairs(item_map) do
        for y,v in pairs(_v) do
            new_map[x] = new_map[x] or {}
            new_map[x][y] = v.data.id
        end
    end
    EliminateObjManager.ClearEliminateItem()
    EliminateObjManager.CreateEliminateItem(new_map)
end

--直接改变元素，不会下落
function M.ChangeEliminateItem(map,max_x,max_y)
    if not map or not next(map) then return end
    for x,_v in pairs(item_map) do
        for y,v in pairs(_v) do
            if map and map[x] and map[x][y] then
                M.RefreshEliminateItem({x = x,y = y,id = map[x][y]})
            end
        end
    end
end

--刷新元素到消除后的指定位置，会下落
function M.RefreshAllEliminateItem(map,max_x,max_y)
    local new_item_map = {}
    local new_y = 1
    for x=1,max_x do
        new_y = 1
        for y=1,max_y do
            if item_map[x] and item_map[x][y] then
                new_item_map[x] = new_item_map[x] or {}
                new_item_map[x][new_y] = item_map[x][y]
                new_y = new_y + 1
            end
        end
    end
    item_map = new_item_map
    for x,_v in pairs(item_map) do
        for y,v in pairs(_v) do
            v:Refresh(v)
        end
    end
end

--item下滑
function M.EliminateItemDown(callback)
    local new_item_map = {}
    local new_y = 1
    local index = eliminate_algorithm.get_map_max_index(item_map)
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
    EliminateAnimManager.EliminateItemDown(new_item_map,callback)
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
        EliminateAnimManager.Spring(new_item_map,EliminateModel.GetTime(EliminateModel.cfg.time.spring_t),callback)
    end
    EliminateAnimManager.EliminateItemDown(new_item_map,_callback)
end

function M.AddEliminateItem(data)
    item_map[data.x] = item_map[data.x] or {}
    item_map[data.x][data.y] = EliminateFruitItem.Create(data)
    M.RefreshEliminateBG(data)
    return item_map[data.x][data.y] 
end

function M.RemoveEliminateItem(data)
    if item_map[data.x] and item_map[data.x][data.y] then
        item_map[data.x][data.y]:Exit()
        item_map[data.x][data.y] = nil
    end
end

function M.RefreshEliminateItem(data)
    if item_map[data.x] and item_map[data.x][data.y] then
        item_map[data.x][data.y]:Refresh(data)
    end
end

function M.ExchangeEliminateItem(data1,data2)
    local temp = {}
    temp = data1
    if item_map[data1.x] and item_map[data1.x][data1.y] then
        item_map[data1.x][data1.y]:Refresh(data2)
    end
    if item_map[data2.x] and item_map[data2.x][data2.y] then
        item_map[data2.x][data2.y]:Refresh(temp)
    end
    temp = nil
end

function M.GetAllEliminateItem()
    return item_map
end

function M.InitEliminateBG(max_x,max_y)
    for y=1,max_y do
        for x=1,max_x do
            M.AddEliminateBG({x = x,y = y})
        end
    end
end

function M.AddEliminateBG(data)
    bg_map[data.x] = bg_map[data.x] or {}
    bg_map[data.x][data.y] = EliminateFruitBG.Create(data)
end

function M.RemoveEliminateBG(data)
    if bg_map[data.x] and bg_map[data.x][data.y] then
        bg_map[data.x][data.y]:Exit()
        bg_map[data.x][data.y] = nil
    end
end

function M.RefreshEliminateBG(data)
    if bg_map[data.x] and bg_map[data.x][data.y] then
        bg_map[data.x][data.y]:Refresh(data)
    end
end

function M.GetEliminateBG(data)
    if bg_map[data.x] and bg_map[data.x][data.y] then
        return bg_map[data.x][data.y]
    end
    return nil
end

function M.GetEliminateBGPos(data)
    if bg_map[data.x] and bg_map[data.x][data.y] then
        return bg_map[data.x][data.y]:GetPos()
    end
    return nil
end

function M.CreateEliminateFuritParticle(cur_del_list,cur_result)
    if cur_result.current_type == EliminateModel.lottery_type.nor then
        EliminatePartManager.CreateEliminateNor(cur_del_list)
    elseif cur_result.current_type == EliminateModel.lottery_type.lucky then
        if not cur_result.win_lucky then
            EliminatePartManager.CreateEliminateLuckyNor(cur_del_list)
        else
            local max_win_count = cur_result.win_lucky.max_win_count
            if max_win_count == EliminateModel.eliminate_enum.nor then
                EliminatePartManager.CreateEliminateLuckyNor(cur_del_list)
            elseif max_win_count == EliminateModel.eliminate_enum.del_type then
                ExtendSoundManager.PlaySound(audio_config.xxl.bgm_xxl_lucky4xiaohou.audio_name)
                EliminatePartManager.CreateEliminateLuckyType(cur_del_list,cur_result.win_lucky)
            elseif max_win_count >= EliminateModel.eliminate_enum.clear_all then
                EliminatePartManager.CreateEliminateLuckyClear(cur_del_list,cur_result.win_lucky)
                EliminateAnimManager.DOShakePositionCamer(nil,EliminateModel.GetTime(EliminateModel.cfg.time.camer_shake_t))
                EliminatePartManager.CreateAllBlom(item_map)
            end
        end
    end
end

-------------------------------外部调用
function M.Lottery(cur_result,callback)
    if not cur_result.del_list or not cur_result.del_list[1] then
        --当前屏幕中没有消除元素，开始下一屏幕元素消除
        if cur_result.win_lucky and cur_result.win_lucky.over and cur_result.win_lucky.max_win_count >= 4 then
            callback()
            return
        end
        M.EliminateItemDown(function()
            local _callback = function(  )
                 --掉落完成开始消除下一屏的元素
                 if M.eliminate_next_scr_timer  then M.eliminate_next_scr_timer:Stop() end
                 M.eliminate_next_scr_timer = Timer.New(function()
                 if callback and type(callback) == "function" then
                     callback()
                 end
                 end,EliminateModel.GetTime(EliminateModel.cfg.time.eliminate_next_scr_d),1)
                 M.eliminate_next_scr_timer:Start()
            end
            --本局结束没有new_map
            if cur_result.new_map then
                ExtendSoundManager.PlaySound(audio_config.xxl.bgm_xxl_luoxia.audio_name)
                M.CreateEliminateItemDown(cur_result.new_map)
                M.EliminateItemDownNew(cur_result.new_map,function ()
                    --掉落完成开始消除下一屏的元素
                    M.ClearEliminateItem()
                    M.CreateEliminateItem(cur_result.map)
                    _callback()
                end)
            else
                M.ClearEliminateItem()
                M.CreateEliminateItem(cur_result.map)
                _callback()
            end
        end)
        return
    end

    local cur_del_list = basefunc.deepcopy(cur_result.del_list[1])
    table.remove( cur_result.del_list,1)

    local function _lottery(del_type)
        M.CreateEliminateFuritParticle(cur_del_list,cur_result)
        if M.play_fruit_part_timer  then M.play_fruit_part_timer:Stop() end
        M.play_fruit_part_timer = Timer.New(function()
            local cur_del_count = #cur_del_list
            if cur_del_count == 3 then
                ExtendSoundManager.PlaySound(audio_config.xxl.bgm_xxl_1xiao.audio_name)
            elseif cur_del_count == 4 then
                ExtendSoundManager.PlaySound(audio_config.xxl.bgm_xxl_2xiao.audio_name)
            elseif cur_del_count == 5 then
                ExtendSoundManager.PlaySound(audio_config.xxl.bgm_xxl_3xiao.audio_name)
            elseif cur_del_count == 6 then
                ExtendSoundManager.PlaySound(audio_config.xxl.bgm_xxl_4xiao.audio_name)
            elseif cur_del_count == 7 then
                ExtendSoundManager.PlaySound(audio_config.xxl.bgm_xxl_5xiao.audio_name)
            elseif cur_del_count > 7 then
                ExtendSoundManager.PlaySound(audio_config.xxl.bgm_xxl_6xiao.audio_name)
            end
            for i,v in ipairs(cur_del_list) do
                M.RemoveEliminateItem(v)
            end
            local eliminate_type = EliminateModel.eliminate_enum.nor
            local change_id = 0
            if del_type == EliminateModel.eliminate_enum.del_type or del_type == EliminateModel.eliminate_enum.clear_all then
                if cur_result.win_lucky and cur_result.win_lucky.over then
                    if cur_result.win_lucky.max_win_count == EliminateModel.eliminate_enum.del_type then
                        eliminate_type = EliminateModel.eliminate_enum.del_type
                        change_id = cur_del_list[1].id
                    elseif cur_result.win_lucky.max_win_count == EliminateModel.eliminate_enum.clear_all then
                        eliminate_type = EliminateModel.eliminate_enum.clear_all
                        change_id = cur_result.win_lucky.win_list[1][1].id
                        for i,v in ipairs(cur_del_list) do
                            v.id = change_id
                        end
                    end
                end
            end
            --通知其他地方做出相应变化
            Event.Brocast("eliminate_lottery_award_one","eliminate_lottery_award_one",{cur_del_list = cur_del_list,type = eliminate_type,id = change_id})
            --消除同屏中的下一组
            if M.eliminate_next_arr_timer  then M.eliminate_next_arr_timer:Stop() end
            M.eliminate_next_arr_timer = Timer.New(function()
                M.Lottery(cur_result,callback)
            end,EliminateModel.GetTime(EliminateModel.cfg.time.eliminate_next_arr_d),1)
            M.eliminate_next_arr_timer:Start()
        end,EliminateModel.GetTime(EliminateModel.cfg.time.play_fruit_part_d),1)
        M.play_fruit_part_timer:Start()
    end

    if cur_result.win_lucky then
        if cur_result.win_lucky.over then
            --lucky中奖强制结束
            if cur_result.win_lucky.max_win_count == EliminateModel.eliminate_enum.del_type then
                --消除同类
                if cur_result.del_type_list then
                    local del_type_list = basefunc.deepcopy(cur_result.del_type_list)
                    ExtendSoundManager.PlaySound(audio_config.xxl.bgm_xxl_lucky4xiao.audio_name)
                    for i,_v in ipairs(cur_result.win_lucky.win_list) do
                        for j,v in ipairs(_v) do
                            EliminatePartManager.CreateFruitRight(item_map[v.x][v.y],EliminateModel.GetTime(EliminateModel.cfg.time.del_all_type_right_t * 2))
                        end
                    end
                    if M.del_all_type_right_timer  then M.del_all_type_right_timer:Stop() end
                    M.del_all_type_right_timer = Timer.New(function(  )
                        if M.del_type_mask_timer  then M.del_type_mask_timer:Stop() end
                        M.del_type_mask_timer = Timer.New(function(  )
                            EliminatePartManager.CreateLucky4(cur_del_list,3)
                            if M.del_type_lottery_timer  then M.del_type_lottery_timer:Stop() end
                            M.del_type_lottery_timer = Timer.New(function(  )
                                _lottery(EliminateModel.eliminate_enum.del_type)
                            end,3,1)
                            M.del_type_lottery_timer:Start()
                        end,1,1)
                        M.del_type_mask_timer:Start()
                    end,EliminateModel.GetTime(EliminateModel.cfg.time.del_all_type_right_t),1)
                    M.del_all_type_right_timer:Start()
                    cur_result.del_type_list = nil
                else
                    _lottery()
                end
            elseif cur_result.win_lucky.max_win_count >= EliminateModel.eliminate_enum.clear_all then
                ExtendSoundManager.PlaySound(audio_config.xxl.bgm_xxl_lucky4xiao.audio_name)
                --消除全屏
                local max_x = EliminateModel.cfg.size.max_x
                local max_y = EliminateModel.cfg.size.max_y
                local change_id = cur_result.win_lucky.win_list[1][1].id
                for i,_v in ipairs(cur_result.win_lucky.win_list) do
                    for j,v in ipairs(_v) do
                        EliminatePartManager.CreateFruitRight(item_map[v.x][v.y],EliminateModel.GetTime(EliminateModel.cfg.time.del_all_type_right_t * 2))
                    end
                end

                if M.win_lucky_ll_right_timer  then M.win_lucky_ll_right_timer:Stop() end
                M.win_lucky_ll_right_timer = Timer.New(function()
                    EliminatePartManager.CreateQPBJ(EliminateModel.GetTime(EliminateModel.cfg.time.del_clear_pz_d))
                    if M.del_clear_pz_timer  then M.del_clear_pz_timer:Stop() end
                    M.del_clear_pz_timer = Timer.New(function()
                        --一列一列变换
                        local x  = 1
                        if M.del_clear_right_timer  then M.del_clear_right_timer:Stop() end
                        M.del_clear_right_timer = Timer.New(function()
                            local change_map = {}
                            local change_list = {}
                            for y=1,max_y do
                                change_map[x] = change_map[x] or {}
                                change_map[x][y] = change_id
                                table.insert( change_list,{x = x, y = y, id = change_id})
                            end
                            ExtendSoundManager.PlaySound(audio_config.xxl.bgm_xxl_lucky5xiao.audio_name)
                            EliminatePartManager.CreateQPSG(change_list)
                            for y=1,max_y do
                                EliminatePartManager.CreateLuckyChange(change_list[y],EliminateModel.GetTime(EliminateModel.cfg.time.del_clear_lucky_change_fruit_t))
                                M.RemoveEliminateItem({x = x , y = y})
                                M.AddEliminateItem({x = x, y = y, id = change_id})
                                EliminatePartManager.CreateFruitBlow({x = x, y = y})
                            end
                            x = x + 1
                            if x == max_x + 1 then
                                EliminateAnimManager.DOShakePositionObjs(item_map,EliminateModel.GetTime(EliminateModel.cfg.time.fruit_shake_t))
                                if M.del_clear_timer  then M.del_clear_timer:Stop() end
                                M.del_clear_timer = Timer.New(function()
                                    ExtendSoundManager.PlaySound(audio_config.xxl.bgm_xxl_lucky5xiaohou.audio_name)
                                    _lottery(EliminateModel.eliminate_enum.clear_all)
                                end,EliminateModel.GetTime(EliminateModel.cfg.time.fruit_shake_t / 2),1)
                                M.del_clear_timer:Start()
                            end
                        end,EliminateModel.GetTime(EliminateModel.cfg.time.del_clear_right_t),max_x)
                        M.del_clear_right_timer:Start()
                    end,EliminateModel.GetTime(EliminateModel.cfg.time.del_clear_pz_d),1)
                    M.del_clear_pz_timer:Start()
                end,EliminateModel.GetTime(EliminateModel.cfg.time.win_lucky_ll_t),1)
                M.win_lucky_ll_right_timer:Start()
            end
            return
        else
            --摇中3个开奖
            _lottery()
        end
    end
    --正常开奖
    _lottery()
end

function M.change_lucky(cur_result,callback)
    local lucky_item_map = {}
    if cur_result.del_map_lucky then
        for x,_v in pairs(cur_result.del_map_lucky) do
            for y,v in pairs(_v) do
                lucky_item_map[x] = lucky_item_map[x] or {}
                lucky_item_map[x][y] = item_map[x][y]
            end
        end
    end

    local function _change_lucky()
        if M.change_lucky_timer  then M.change_lucky_timer:Stop() end
        M.change_lucky_timer = Timer.New(function()
            if cur_result.del_map_lucky then
                EliminateAnimManager.ScrollLuckyChangeToFiurt(lucky_item_map,cur_result,callback)
            else
                callback()
            end
        end,EliminateModel.GetTime(EliminateModel.cfg.time.change_lucky_t),1)
        M.change_lucky_timer:Start()
    end
    if cur_result.win_lucky then
        --lucky中奖闪光效果
        ExtendSoundManager.PlaySound(audio_config.xxl.bgm_xxl_lucky.audio_name)
        if cur_result.del_map_lucky then
            for x,_v in pairs(lucky_item_map) do
                for y,v in pairs(_v) do
                    EliminatePartManager.CreateLuckyRight(item_map[x][y],EliminateModel.GetTime(EliminateModel.cfg.time.win_lucky_right_t))
                end
            end
        end
        if M.win_lucky_right_timer  then M.win_lucky_right_timer:Stop() end
        M.win_lucky_right_timer = Timer.New(function(  )
            _change_lucky()
        end,EliminateModel.GetTime(EliminateModel.cfg.time.win_lucky_right_t),1)
        M.win_lucky_right_timer:Start()
    else
        _change_lucky()
    end
end

function M.LotteryFix(callback)
    if table_is_null(EliminateModel.data.fix_xiaochu_map) or
       table_is_null(EliminateModel.data.fix_xiaochu_map.del_list) then 
        if callback then callback() end
        return 
    end
    local all_del_list = {}
    ExtendSoundManager.PlaySound(audio_config.xxl.bgm_xxl_fix.audio_name)
    EliminateModel.ConvertAndAddFixDelList(all_del_list)
    EliminatePartManager.CreateFix(all_del_list[1])
    if M.fic_del_timer  then M.fic_del_timer:Stop() end
    M.fic_del_timer = Timer.New(function(  )
        if callback then callback() end
    end,3,1)
    M.fic_del_timer:Start()
end