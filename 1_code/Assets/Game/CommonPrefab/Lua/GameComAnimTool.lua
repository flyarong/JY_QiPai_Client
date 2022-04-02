-- 创建时间:2020-06-16
-- 公用的动画组件

GameComAnimTool = {}

-- 数字变动动画
function GameComAnimTool.stop_number_change_anim(tab)
    if tab and type(tab) == "table" then
        if IsEquals(tab.gold_txt) and tab.end_num then
            tab.gold_txt.text = tab.end_num
        end
        if tab.update_time then
            tab.update_time:Stop()
            tab.update_time = nil
        end
        if tab.seq then
            tab.seq:Kill()
        end
    end
end
function GameComAnimTool.play_number_change_anim(gold_txt, begin_num, end_num, t, finish_call, force_kill_call)
    local tab = {}
    tab.gold_txt = gold_txt
    tab.begin_num = begin_num
    tab.end_num = end_num
    tab.t = t
    tab.finish_call = finish_call

    local cur_m = begin_num
    local spt = 0.04
    local money = end_num - begin_num
    local spm = math.max(1, math.ceil(money / (t * 1 / spt)))

    local function close_timer()
        if tab.update_time then
            tab.update_time:Stop()
            tab.update_time = nil
        end
        if IsEquals(tab.gold_txt) and tab.end_num then
            tab.gold_txt.text = tab.end_num
        end
        tab.gold_txt = nil
    end
    local function set_money(value)
        if IsEquals(gold_txt) then
            gold_txt.text = value
        else
            close_timer()
        end
    end
    tab.update_time = Timer.New(function ()
        cur_m = cur_m + spm
        if cur_m > end_num then
            cur_m = end_num
            close_timer()
        end
        set_money(cur_m)
    end, spt, -1, nil, true)
    tab.update_time:Start()
    set_money(cur_m)

    tab.seq = DoTweenSequence.Create()
    tab.seq:AppendInterval(t)
    tab.seq:OnKill(function ()
        if finish_call then
            finish_call()
        end
    end)
    tab.seq:OnForceKill(function (force_kill)
        tab.seq = nil
        close_timer()
        if force_kill and force_kill_call then
            force_kill_call()
        end
    end)

    return tab
end


-- 一个固定位置的特效 显示一段时间消失
-- 支持回调方法在中间位置出现
function GameComAnimTool.PlayShowAndHideAndCall(parent, fx_name, beginPos, keepTime, call_time, finish_call, call, seq_parm, kill_call,force_kill_call)
    local obj = GameObject.Instantiate(GetPrefab(fx_name), parent).gameObject
    obj.transform.position = beginPos
    if call then -- 修改预制体的内容
        call(obj)
    end

    local seq = DoTweenSequence.Create(seq_parm)
    if call_time then
        seq:AppendInterval(call_time)
        seq:AppendCallback(function ()
            if finish_call then
                finish_call()
            end
            finish_call = nil
        end)
        keepTime = keepTime - call_time
        if keepTime <= 0 then
            keepTime = nil
        end
    end

    if keepTime and keepTime > 0.001 then
        seq:AppendInterval(keepTime)
    end
    seq:OnKill(function ()
        if finish_call then
            finish_call()
        end
        finish_call = nil

        if kill_call then
            kill_call()
        end
        kill_call = nil
    end)
    seq:OnForceKill(function ()
        if force_kill_call then
            force_kill_call()
        end
        destroy(obj)
    end)
    
    return seq
end

-- 通用飞行特效 
function GameComAnimTool.PlayMoveAndHideFX(parent, fx_name, beginPos, endPos, keepTime, moveTime, finish_call, endTime, seq_parm)
    local obj = GameObject.Instantiate(GetPrefab(fx_name), parent).gameObject
    obj.transform.position = beginPos

    local seq = DoTweenSequence.Create(seq_parm)

    if keepTime and keepTime > 0.001 then
        seq:AppendInterval(keepTime)
    end
    seq:Append(obj.transform:DOMove(endPos, moveTime):SetEase(DG.Tweening.Ease.InQuint))
    if endTime then
        seq:AppendInterval(endTime)
    end
    seq:OnKill(function ()
        if finish_call then
            finish_call()
        end
        finish_call = nil
    end)
    seq:OnForceKill(function ()
        destroy(obj)
    end) 
    return seq     
end

--数字转动动画
function GameComAnimTool.ScrollLuckyChangeToFiurt(item_list, data_list, jgt, callback)
    local max_num = #item_list
    local item_map = {}--数据转换
    for x=1,#item_list do
        item_map[x] = item_map[x] or {}
        item_map[x][1] = {}
        item_map[x][1].data = {id=data_list[x], x=x, y=1}
        item_map[x][1].ui = {}
        item_map[x][1].ui.gameObject = item_list[x]
        item_map[x][1].ui.transform = item_map[x][1].ui.gameObject.transform
        LuaHelper.GeneratingVar(item_map[x][1].ui.transform, item_map[x][1].ui)
        item_map[x][1].ui.num_txt.text = item_map[x][1].data.id
    end

    local change_up_t = 0.2 --加速时间
    local change_uni_t = 0.02 --每一次滚动时间
    local change_down_t = 0.2 --减速时间
    local change_uni_d = 2 --匀速滚动时长
    local change_up_d = jgt or 0.04 --滚动加速间隔

    local speed_status = {
        speed_up = "speed_up",
        speed_uniform = "speed_uniform",
        speed_down = "speed_down",
        speed_end = "speed_end",
    }
    local material_FrontBlur = GetMaterial("FrontBlur")
    local spacing = 65 + 0
    local add_y_count = 3
    local down_count = 0
    local all_count = 0
    local all_fruit_map = {}
    for x,_v in pairs(item_map) do
        for y,v in pairs(_v) do
            all_count = all_count + 1
        end
    end
    all_count = all_count * add_y_count

    local speed_uniform
    local speed_up
    local speed_down

    local function get_pos_by_index(x,y,size_x,size_y,spac_x,spac_y)
        size_x = size_x or 46
        size_y = size_y or 65
        spac_x = spac_x or 0
        spac_y = spac_y or 0
        local pos = {x = 0,y = 0}
        pos.x = (x - 1) * (size_x + spac_x)
        pos.y = (y - 1) * (size_y + spac_y)
        return pos
    end

    local function get_index_by_pos(x,y,size_x,size_y,spac_x,spac_y)
        size_x = size_x or 46
        size_y = size_y or 65
        spac_x = spac_x or 0
        spac_y = spac_y or 0
        local index = {x = 1,y = 1}
        index.x = math.floor(x / (size_x + spac_x)) + 1
        index.y = math.floor(y / (size_y + spac_y)) + 1
        return index
    end

    local function create_obj(data)
        local _obj = {}
        _obj.ui = {}
        _obj.data = data
        local parent = _obj.data.parent
        if not parent then return end
        _obj.ui.gameObject = GameObject.Instantiate(data.obj, parent)
        _obj.ui.transform = _obj.ui.gameObject.transform
        _obj.ui.transform.localPosition = get_pos_by_index(_obj.data.x,_obj.data.y)
        _obj.ui.gameObject.name = _obj.data.x .. "_" .. _obj.data.y
        LuaHelper.GeneratingVar(_obj.ui.transform, _obj.ui)
        _obj.ui.num_txt.text = data.id
        return _obj
    end

    local function call(v)
        if not v.obj.ui or not v.obj.ui.transform or not IsEquals(v.obj.ui.transform) then return end
        if v.status == speed_status.speed_up or v.status == speed_status.speed_uniform or v.status == speed_status.speed_down then
            if v.status == speed_status.speed_up then
                v.obj.ui.num_txt.material = material_FrontBlur
            elseif v.status == speed_status.speed_down then
                v.obj.ui.num_txt.material = nil
            end
            if v.obj.ui.transform.localPosition.y < -spacing then
                v.obj.ui.transform.localPosition = get_pos_by_index(1,2)
                v.obj.ui.num_txt.text = math.random( 0,9)
            end
        elseif v.status == speed_status.speed_end then
            down_count = down_count + 1
            if down_count == all_count then
                for x,_v in pairs(item_map) do
                    for y,v in pairs(_v) do
                        v.ui.num_txt.gameObject:SetActive(true)
                    end
                end
                for x1,_v1 in pairs(all_fruit_map) do
                    for y1,v1 in pairs(_v1) do
                        for x2,_v2 in pairs(v1) do
                            for y2,v2 in pairs(_v2) do
                                Destroy(v2.obj.ui.gameObject)
                            end
                        end
                    end
                end
                all_fruit_map = {}
                if callback and type(callback) == "function" then
                    callback()
                end
            end
        end
        if v.status == speed_status.speed_up then
            v.status = speed_status.speed_uniform --加速完成进入匀速状态
        end
        if v.status == speed_status.speed_uniform then
            speed_uniform(v)
        elseif v.status == speed_status.speed_up then
            speed_up(v)
        elseif v.status == speed_status.speed_down then
            speed_down(v)
        end
    end

    speed_up = function  (v)
        v.status = speed_status.speed_up
        local seq = DoTweenSequence.Create()
        local t_y = v.obj.ui.transform.localPosition.y - spacing
        seq:Append(v.obj.ui.transform:DOLocalMoveY(t_y, change_up_t))
        seq:SetEase(DG.Tweening.Ease.InCirc)
        seq:OnForceKill(function ()
            call(v)
        end)
    end

    speed_uniform = function (v)
        v.status = speed_status.speed_uniform
        local seq = DoTweenSequence.Create()
        local t_y = v.obj.ui.transform.localPosition.y - spacing
        seq:Append(v.obj.ui.transform:DOLocalMoveY(t_y, change_uni_t))
        seq:SetEase(DG.Tweening.Ease.Linear)
        seq:OnForceKill(function ()
            call(v)
        end)
    end

    speed_down = function (v)
        v.status = speed_status.speed_down
        local index = get_index_by_pos(v.obj.ui.transform.localPosition.x,v.obj.ui.transform.localPosition.y)
        if index.y == 2 then
            local id = item_map[v.real_x][v.real_y].data.id
            v.obj.ui.num_txt.text = id
        end
        local seq = DoTweenSequence.Create()
        local t_y = v.obj.ui.transform.localPosition.y - spacing
        seq:Append(v.obj.ui.transform:DOLocalMoveY(t_y, change_down_t))
        seq:SetEase(DG.Tweening.Ease.OutCirc)
        seq:OnForceKill(function ()
            v.status = speed_status.speed_end
            call(v)
        end)
    end

    local function lucky_chang_to_fruit(v_obj,index_x)
        if not IsEquals(item_map[index_x][1].ui.gameObject) then
            return
        end
        local fruit_map = {}
        local id
        local ins_obj = GameObject.Instantiate(item_map[index_x][1].ui.gameObject)
        for y=1,add_y_count do
            if y == 1 then
                id = v_obj.data.id
            else
                id = math.random(0,9)
            end
            fruit_map[1] = fruit_map[1] or {}
            fruit_map[1][y] ={obj = create_obj({obj = ins_obj,x = 1,y = y,id = id ,parent = v_obj.ui.transform}),status = speed_status.speed_up,real_x = v_obj.data.x,real_y = v_obj.data.y}
            local v = fruit_map[1][y]
            if v.obj.ui.transform.localPosition.y < -spacing then
                v.obj.ui.transform.localPosition = get_pos_by_index(1,2)
                v.obj.ui.num_txt.text = math.random(0,9)
            end
            speed_up(fruit_map[1][y])
        end
        --隐藏自己
        v_obj.ui.num_txt.gameObject:SetActive(false)
        Destroy(ins_obj)
        return fruit_map
    end

    --一列一列加速改变
    local x = 1
    local change_up_timer
    if change_up_timer then change_up_timer:Stop() end
    change_up_timer = Timer.New(function()
        if item_map[x] then
            for y=1,max_num do
                local v = item_map[x][y]
                if v then
                    all_fruit_map[x] = all_fruit_map[x] or {}
                    all_fruit_map[x][y] = lucky_chang_to_fruit(v,x)
                end
            end
        end
        x = x + 1
        if x == max_num then
            local m_callback = function(  )
                for x,_v in pairs(all_fruit_map) do
                    for y,v in pairs(_v) do
                        for x1,v1 in pairs(v) do
                            for y1,v2 in pairs(v1) do
                                v2.status = speed_status.speed_down
                            end
                        end
                    end
                end
            end
            local change_uni_timer = Timer.New(function ()
                m_callback()
            end,change_uni_d,1)
            change_uni_timer:Start()
        end
    end,change_up_d,max_num)
    change_up_timer:Start()
end

--通用飞行  bizer 曲线
function GameComAnimTool.PlayMoveAndHideFXBZ(parent, prefab_name, beginPos, endPos, keepTime, moveTime, finish_call, endTime, seq_parm)
    local obj = GameObject.Instantiate(GetPrefab(prefab_name), parent).gameObject
    local path = {}
    local a = beginPos
    local b = endPos
    obj.transform.position = beginPos
    path[0] = a
    path[1] = Vector3.New((a.x > b.x and math.random(a.x,b.x) or math.random(b.x,a.x)) + 60,(a.y > b.y and math.random(a.y,b.y) or math.random(b.y,a.y)) + 60,0)
    path[2] = Vector3.New(b.x,b.y,0)
    local seq = DoTweenSequence.Create()
    seq:Append(obj.transform:DOPath(path,0.5,DG.Tweening.PathType.CatmullRom))
    seq:OnKill(function ()
        if finish_call and type(finish_call) == "function" then
            finish_call()
        end
    end)
    seq:OnForceKill(function ()
        destroy(obj)
    end)
end





