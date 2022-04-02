
-- package.path=package.path..";Users/hewei/project/JyQipai_client/1_code/Assets/?.lua"

require "Game.Common.printfunc"
local basefunc = require "Game.Common.basefunc"
---------斗地主出牌
--[[
    协议：
        {
            type 0 : integer,--(出牌类型）
            pai 1 :*integer,--出的牌
        }
    牌类型
        3-17 分别表示
        3 4 5 6 7 8 9 10 J Q K A 2 小王 大王
    出牌类型
    -- 0： 过
    -- 1： 单牌
    -- 2： 对子
    -- 3： 三不带
    -- 4： 三带一    pai[1]代表三张部分 ，p[2]代表被带的牌
    -- 5： 三带一对    pai[1]代表三张部分 ，p[2]代表被带的对子
    -- 6： 顺子     pai[1]代表顺子起点牌，p[2]代表顺子终点牌
    -- 7： 连队         pai[1]代表连队起点牌，p[2]代表连队终点牌
    -- 8： 四带2        pai[1]代表四张部分 ，p[2]p[3]代表被带的牌
    -- 9： 四带两对
    -- 10：飞机带单牌（只能全部带单牌） pai[1]代表飞机起点牌，p[2]代表飞机终点牌，后面依次是要带的牌
    -- 11：飞机带对子（只能全部带对子）
    -- 12：飞机  不带
    -- 13：炸弹
    -- 14：王炸

--]]
local nDdzFunc={}
--key=牌类型  value=此类型的牌的张数，特殊牌（如：顺子）则是最少张数
local pai_type = {
    [0] = 0,
    [1] = 1,
    [2] = 2,
    [3] = 3,
    [4] = 4,
    [5] = 5,
    [6] = 5,
    [7] = 6,
    [8] = 6,
    [9] = 8,
    [10] = 8,
    [11] = 10,
    [12] = 6,
    [13] = 4,
    [14] = 2
}
--16
local other_type = {
    jdz = 100,
    jiabei = 101
}
local pai_map = {
    3,
    3,
    3,
    3,
    4,
    4,
    4,
    4,
    5,
    5,
    5,
    5,
    6,
    6,
    6,
    6,
    7,
    7,
    7,
    7,
    8,
    8,
    8,
    8,
    9,
    9,
    9,
    9,
    10,
    10,
    10,
    10,
    11,
    11,
    11,
    11,
    12,
    12,
    12,
    12,
    13,
    13,
    13,
    13,
    14,
    14,
    14,
    14,
    15,
    15,
    15,
    15,
    16,
    17
}
--
local pai_to_id_map = {
    0,
    0,
    1,
    5,
    9,
    13,
    17,
    21,
    25,
    29,
    33,
    37,
    41,
    45,
    49,
    53,
    54
}

--各类型的牌的起始id
nDdzFunc.pai_to_startId_map = {
    0,
    0,
    1,
    5,
    9,
    13,
    17,
    21,
    25,
    29,
    33,
    37,
    41,
    45,
    49,
    53,
    54,
}
--各类型的牌的结束id
nDdzFunc.pai_to_endId_map = {
    0,
    0,
    4,
    8,
    12,
    16,
    20,
    24,
    28,
    32,
    36,
    40,
    44,
    48,
    52,
    53,
    54,
}

local pai_to_startId_map=nDdzFunc.pai_to_startId_map
local pai_to_endId_map=nDdzFunc.pai_to_endId_map

-- --统计牌的类型
function nDdzFunc.get_pai_typeHash_by_list(_pai_list)
    if type(_pai_list) == "table" then
        local _pai_type_count = {}
        for _, _p_id in ipairs(_pai_list) do
            _pai_type_count[pai_map[_p_id]] = _pai_type_count[pai_map[_p_id]] or 0
            _pai_type_count[pai_map[_p_id]] = _pai_type_count[pai_map[_p_id]] + 1
        end
        return _pai_type_count
    end
    return nil
end
function nDdzFunc.get_pai_typeHash(_pai)
    local _hash = {}
    for _id, _v in pairs(_pai) do
        if _v then
            _hash[pai_map[_id]] = _hash[pai_map[_id]] or 0
            _hash[pai_map[_id]] = _hash[pai_map[_id]] + 1
        end
    end
    return _hash
end
function nDdzFunc.get_pai_list_by_map(_map)
    if _map then
        local list = {}
        for _pai_id, _v in pairs(_map) do
            if _v then
                list[#list + 1] = _pai_id
            end
        end
        return list
    end
    return nil
end


local function choose_paiType_by_num(phash,start,c_num,no_choose)
    --优先选天生符合的
    local p_type
    for type,num in pairs(phash) do
        if not no_choose[type] and type>=start and num==c_num then
            if not p_type then
                p_type=type
            --尽量选小牌
            elseif type<p_type then
                p_type=type
            end
        end
    end
    if p_type then
        return p_type
    end
    if c_num<4 then
        local max_num
        --再其次选比他大的符合的
        for type,num in pairs(phash) do
            if not no_choose[type] and type>=start and num>c_num then
                if not p_type then
                    p_type=type
                    max_num=num
                --尽量选数量少的牌 
                elseif (num<max_num) or (num==max_num and type<p_type) then
                    p_type=type
                end
            end
        end
        if p_type then
            return p_type
        end
    end
    return nil
end
--单牌或者对子
local function get_dpOrDz_combination(phash,start,no_choose,n_num)
    local c_t_1=choose_paiType_by_num(phash,start,n_num,no_choose)
    if c_t_1 then
        return n_num,{c_t_1}
    end
    return nil
end
--三带N 返回值  牌型分解 普通牌使用情况（key=paiTpye,value=num）  癞子牌使用情况key=paiTpye,value=num）   
local function get_3dn_combination(phash,start,no_choose,n_num)
    print("zzzzzzzzz ",start,n_num)
    dump(no_choose)
    dump(phash)
    local c_t_1=choose_paiType_by_num(phash,start,3,no_choose)
    print("xxxxxxxxxxxx ",c_t_1,n_num)
    if c_t_1 then
        if n_num and n_num>0 then
            local c_t_2=choose_paiType_by_num(phash,3,n_num,{[c_t_1]=true})
            print("qqqqqqq",c_t_2)
            if c_t_2 then
                --成功选取到
                return 3+n_num,{c_t_1,c_t_2}
            end
        else
            --3不带
            return 3,{c_t_1}
        end
    end
    return nil
end
local function get_4dn_combination(phash,start,no_choose,n_num)
    local c_t_1=choose_paiType_by_num(phash,start,4,no_choose)
    if c_t_1 then
        local nc={[c_t_1]=true}
        local c_t_2=choose_paiType_by_num(phash,0,n_num,nc)
        if c_t_2 then
            local _phash=basefunc.copy(phash)
            --4带2
            if n_num==1 then
                if _phash[c_t_2] and _phash[c_t_2]>0 then
                    _phash[c_t_2]=_phash[c_t_2]-1
                end
                -- 不能同时选双王
                if c_t_2>15 then
                    nc[16]=true
                    nc[17]=true
                end
            --4带2对    
            else
               nc[c_t_2]=true 
            end
            local c_t_3=choose_paiType_by_num(_phash,0,n_num,nc)
            if c_t_3 then
                return 7+n_num,{c_t_1,c_t_2,c_t_3}
            end
        end
    end
    return nil
end
local function get_lianxu_combination(phash,start,lx_num,count)
    local s=start
    local e=14-lx_num+1
    while s<=e do
        local _num=phash[s] or 0
        if _num>=count then
            local _e=s+lx_num-1
            for i=s,_e do
                _num=phash[i] or 0
                if _num<count then
                    s=s+1
                    break
                end
                --成功匹配
                if i==_e then
                    return {s,_e}
                end 
            end
        else
            s=s+1
        end
    end
    return nil
end
--顺子
local function get_shunzi_combination(phash,start,lx_num)
    local pai=get_lianxu_combination(phash,start,lx_num,1)
    if pai then
        return 6,pai
    end
    return nil
end
--连队
local function get_liandui_combination(phash,start,lx_num)
    local pai=get_lianxu_combination(phash,start,lx_num,2)
    if pai then
        return 7,pai
    end
    return nil
end
--飞机  不带
local function get_feiji_combination(phash,start,lx_num)
    local pai=get_lianxu_combination(phash,start,lx_num,3)
    if pai then
        return 12,pai
    end
    return nil
end
--飞机带对子（只能全部带对子）
local function get_feijid2_combination(phash,start,lx_num)
    local s=start
    local e=14-lx_num+1
    --要考虑所有情况
    while s<=e do 
        local pai=get_lianxu_combination(phash,start,lx_num,3)
        if pai then
            local flag=true
            local nc={}
            for i=pai[1],pai[2] do
                nc[i]=true
            end
            for i=1,lx_num do
                local ptype=choose_paiType_by_num(phash,0,2,nc)
                if ptype then
                    nc[ptype]=true
                    pai[#pai+1]=ptype
                else
                    flag=false
                    break
                end
            end
            if flag then
                --成功
                return 11,pai 
            end 
        else
            return nil
        end
        s=s+1
    end
    return nil
end
--飞机带单牌
local function get_feijid1_combination(phash,start,lx_num)
    local s=start
    local e=14-lx_num+1
    --要考虑所有情况
    while s<=e do 
        local pai=get_lianxu_combination(phash,start,lx_num,3)
        if pai then
            local flag=true
            local nc={}
            for i=pai[1],pai[2] do
                nc[i]=true
            end
            local hash={}
            local _phash=basefunc.copy(phash)
            for i=1,lx_num do
                local ptype=choose_paiType_by_num(_phash,3,1,nc)
                if ptype then
                    hash[ptype]=hash[ptype] or 0
                    hash[ptype]=hash[ptype]+1
                    --双王只能2选一
                    if ptype>15 then
                       nc[16]=true
                       nc[17]=true
                    end
                    --不能有炸弹
                    if hash[ptype]==3 then
                        nc[ptype]=true
                    end
                    --防止变成了 飞机不带
                    if hash[ptype]==2 and ptype==pai[1]-1 and ptype>=3  then
                        nc[ptype]=true
                    end
                    if hash[ptype]==2 and ptype==pai[2]+1 and ptype<15  then
                        nc[ptype]=true
                    end
                    if _phash[ptype] and _phash[ptype]>0 then
                        _phash[ptype]=_phash[ptype]-1
                    end
                    pai[#pai+1]=ptype
                else
                    flag=false
                    break
                end
            end
            if flag then
                --成功
                return 10,pai,use 
            end 
        else
            return nil
        end
        s=s+1
    end
    return nil
end
 --王炸
local function get_realZhadan_combination(phash,start,no_choose)
    local c_t_1=choose_paiType_by_num(phash,start,4,no_choose)
    if c_t_1 then
        --  真炸弹
        return 13,{c_t_1}
    end
    return nil
end
local function get_wazha_combination(phash)
    if phash[16]==1 and phash[17]==1 then
        return 14,{16,17}
    end
    return nil
end

-- --[[
-- {
--  _pai=
--  {
--      {
--      type,
--      amount,
--      }
--  }
--  按 数量从高到低  牌从小到大排好序
-- }
-- --]]
function nDdzFunc.sort_pai_by_amount(_pai_count)
    if type(_pai_count) == "table" then
        local _pai = {}
        for _id, _amount in pairs(_pai_count) do
            _pai[#_pai + 1] = {type = _id, amount = _amount}
        end
        table.sort(
            _pai,
            function(a, b)
                if a.amount ~= b.amount then
                    return a.amount > b.amount
                end
                return a.type < b.type
            end
        )
        if #_pai==0 then
            return nil
        end
        return _pai
    end
    return nil
end
function nDdzFunc.get_pai_type(_pai_list)
    local _pai = nDdzFunc.sort_pai_by_amount(nDdzFunc.get_pai_typeHash_by_list(_pai_list))
    if not _pai then
        return false
    end
    --最大的相同牌数量
    local _max_num = _pai[1].amount
    --牌的种类  忽略花色
    local _type_count = #_pai

    if _type_count == 1 then
        if _max_num == 4 then
            return {type = 13, pai = {_pai[1].type}}
        elseif _max_num < 4 then
            return {type = _max_num, pai = {_pai[1].type}}
        end
    elseif _max_num == 4 then
        if _type_count == 2 then
            --四带二  被带的牌相同情况
            if _pai[2].amount == 2 then
                return {type = 8, pai = {_pai[1].type, _pai[2].type, _pai[2].type}}
            end
        elseif _type_count == 3 then
            --四带二
            if _pai[2].amount == 1 and _pai[3].amount == 1 and (_pai[2].type ~= 16 or _pai[3].type ~= 17) then
                --四带两对
                return {type = 8, pai = {_pai[1].type, _pai[2].type, _pai[3].type}}
            elseif _pai[2].amount == 2 and _pai[3].amount == 2 then
                return {type = 9, pai = {_pai[1].type, _pai[2].type, _pai[3].type}}
            end
        end
    elseif _max_num == 2 then
        if _type_count > 2 then
            local _flag = true
            for _i = 2, _type_count do
                if _pai[_i].amount ~= 2 then
                    _flag = false
                    break
                end
            end
            if _flag and _pai[_type_count].type < 15 and _pai[_type_count].type - _pai[1].type == _type_count - 1 then
                return {type = 7, pai = {_pai[1].type, _pai[_type_count].type}}
            end
        end
    elseif _max_num == 1 then
        if _type_count == 2 then
            --王炸
            if _pai[1].type == 16 and _pai[2].type == 17 then
                return {type = 14, pai = {_pai[1].type, _pai[2].type}}
            end
        elseif _type_count > 4 then
            --顺子
            if _pai[_type_count].type < 15 and _pai[_type_count].type - _pai[1].type == _type_count - 1 then
                return {type = 6, pai = {_pai[1].type, _pai[_type_count].type}}
            end
        end
    elseif _max_num == 3 then
        local _max_len = 1
        local _head = 1
        local _tail = 1

        local _cur_len = 1
        local _cur_head = 1
        local _cur_tail = 1
        for _i = 2, _type_count do
            if _pai[_i].amount == 3 then
                if _pai[_i - 1].type + 1 == _pai[_i].type and _pai[_i].type < 15 then
                    _cur_len = _cur_len + 1
                    _cur_tail = _i
                else
                    _cur_len = 1
                    _cur_head = _i
                    _cur_tail = _i
                end
                if _cur_len > _max_len then
                    _max_len = _cur_len
                    _head = _cur_head
                    _tail = _cur_tail
                end
            else
                break
            end
        end
        if _max_len == _type_count then
            --裸飞机
            return {type = 12, pai = {_pai[1].type, _pai[_type_count].type}}
        else
            local _count = 0
            --是否全部为对子
            local _is_double = true
            --大小王统计
            local _boss_count = 0
            for _i = 1, _type_count do
                if _i < _head or _i > _tail then
                    _count = _count + _pai[_i].amount
                    if _pai[_i].amount ~= 2 then
                        _is_double = false
                    end
                    if _pai[_i].type == 16 or _pai[_i].type == 17 then
                        _boss_count = _boss_count + 1
                    end
                end
            end
            if _count == _max_len and _boss_count < 2 then
                --三带一
                if _max_len == 1 then
                    return {type = 4, pai = {_pai[1].type, _pai[2].type}}
                else
                    --飞机带单牌
                    local _pai_type = {type = 10, pai = {_pai[_head].type, _pai[_tail].type}}
                    for _i = 1, _type_count do
                        if _i < _head or _i > _tail then
                            for _k = 1, _pai[_i].amount do
                                _pai_type.pai[#_pai_type.pai + 1] = _pai[_i].type
                            end
                        end
                    end
                    return _pai_type
                end
            elseif _count == _max_len * 2 and _is_double then
                --三带对
                if _max_len == 1 then
                    return {type = 5, pai = {_pai[1].type, _pai[2].type}}
                else
                    --飞机带对子
                    local _pai_type = {type = 11, pai = {_pai[_head].type, _pai[_tail].type}}
                    for _i = 1, _type_count do
                        if _i < _head or _i > _tail then
                            _pai_type.pai[#_pai_type.pai + 1] = _pai[_i].type
                        end
                    end
                    return _pai_type
                end
            end
        end
    end
    return false
end
--按单牌 ，对子，三不带，炸弹的顺序选择一种牌
function nDdzFunc.auto_choose_by_order(_p_pai)
    local _type = nil
    local _pai = {}
    for _i = 3, 17 do
        if _p_pai[_i] then
            --danpai
            if _p_pai[_i] == 1 then
                if
                    _i < 16 or (_i == 16 and (not _p_pai[17] or _p_pai[17] == 0)) or
                        (_i == 17 and (not _p_pai[16] or _p_pai[16] == 0))
                 then
                    _pai[1] = _i
                    return 1, _pai
                end
            elseif _p_pai[_i] == 2 then
                if not _type or _type > 2 then
                    _type = 2
                    _pai[1] = _i
                end
            elseif _p_pai[_i] == 3 then
                if not _type or _type > 3 then
                    _type = 3
                    _pai[1] = _i
                end
            elseif _p_pai[_i] == 4 then
                if not _type then
                    _type = 13
                    _pai[1] = _i
                end
            end
        end
    end
    if not _type then
        _type = 0
        if _p_pai[16] and _p_pai[17] and _p_pai[16] == 1 and _p_pai[17] == 1 then
            _type = 14
            _pai[1] = 16
            _pai[2] = 17
        end
    end
    return _type, _pai
end

function nDdzFunc.auto_choose_by_type(_type,_pai,_p_pai)

    local _my_type=nil
    local _my_pai={}
    if _type==14 then 
        return 0
    end
    if _type==0 then
        return nDdzFunc.auto_choose_by_order(_p_pai)
    end

    if _type<=3 or _type==13 then
        local _num=_type
        if _type==13 then
            _num=4
        end
        for _i=_pai[1]+1,17 do
            if _p_pai[_i]==_num then 
                _my_type=_type
                _my_pai[1]=_i
                if (_i==16 or _i==17) and _p_pai[16]==1 and _p_pai[17]==1 then
                    _my_type=14
                    _my_pai[1]=16
                    _my_pai[2]=17
                end
                return _my_type,_my_pai
            elseif  _p_pai[_i] and _p_pai[_i]>_num then
                if not _my_type then
                    _my_type=_type
                    _my_pai[1]=_i
                elseif _p_pai[_i]<_p_pai[_my_pai[1]] then
                    _my_type=_type
                    _my_pai[1]=_i
                end
            end
        end
        if _my_type then
            return _my_type,_my_pai
        end
    elseif _type==4 or _type==5 then
        local _f=nil 
        local _s=nil
        for _i=_pai[1]+1,15 do
            if _p_pai[_i] and _p_pai[_i]==3 then 
                _f=_i
                break
            end
        end
        if _f then
            local _num=1
            if _type==5 then
                _num=2
            end
            for _i=3,17 do
                if _p_pai[_i]==_num then 
                    _s=_i
                    if (_i==16 or _i==17) and  _p_pai[16]==1 and _p_pai[17]==1 then
                        _s=nil
                    end
                    break
                end
            end
            if not _s then
                for _i=3,15 do
                    if _p_pai[_i] and _i~=_f and _p_pai[_i]>_num and _p_pai[_i]<4  then 
                        _s=_i
                        break
                    end
                end
            end
        end
        if _f and _s then 
            _my_pai[1]=_f
            _my_pai[2]=_s
            return _type,_my_pai
        end
    elseif _type==6 or _type==7 then 
        local _limit=14-(_pai[2]-_pai[1])
        local _i=_pai[1]+1
        local flag=true
        local _num=1
        if _type==7 then
            _num=2
        end
        while _i<=_limit do 
            flag=true
            for _k=_i,_i+_pai[2]-_pai[1] do
                if not _p_pai[_k] or _p_pai[_k]<_num then
                    flag=false
                    _i=_k
                    break
                end 
            end
            if flag then
                _my_pai[1]=_i
                _my_pai[2]=_i+(_pai[2]-_pai[1]) 
                return _type,_my_pai
            end
            _i=_i+1
        end
    elseif _type==8 or _type==9 then
        for _i=_pai[1]+1,15 do
            if  _p_pai[_i]==4 then
                _my_pai[1]=_i
                break
            end 
        end
            
        if _my_pai[1] then
            local _num=1 
            if _type==9 then
                _num=2
            end
            --先选天然满足条件的牌
            for _i=3,17 do
                if _p_pai[_i]==_num then
                    if _i<16 or _p_pai[16]~=1 or _p_pai[17]~=1 then
                        _my_pai[#_my_pai+1]=_i
                        if #_my_pai-1==2 then
                            break
                        end
                    end
                end
            end
            local _remain=2-(#_my_pai-1)
            if _remain>0 then
                --从小到大尽量使用
                for _i=3,15 do
                    if  _p_pai[_i] and _i~= _my_pai[1] and _p_pai[_i]>_num then
                        if _type==9 then
                            _my_pai[#_my_pai+1]=_i
                            _remain=_remain-1
                        else
                            for _k=1,2 do
                                _my_pai[#_my_pai+1]=_i
                                _remain=_remain-1
                                if _remain==0 then
                                    break
                                end
                            end
                        end
                        if _remain==0 then
                            break
                        end
                    end
                end
            end
            if _remain==0 then
                return _type,_my_pai
            else
                _my_pai={}
            end
        end
    elseif _type==10 or _type==11 or _type==12 then
        local _len=_pai[2]-_pai[1]+1
        local _limit=14-(_pai[2]-_pai[1])
        local _i=_pai[1]+1
        local flag=true
        while _i<=_limit do 
            flag=true
            for _k=_i,_i+_pai[2]-_pai[1] do
                if not _p_pai[_k] or _p_pai[_k]<3 then
                    flag=false
                    _i=_k
                    break
                end 
            end
            if flag then
                _my_pai[1]=_i
                _my_pai[2]=_i+(_pai[2]-_pai[1]) 
                break
            end
            _i=_i+1
        end
        if _my_pai[1] then
            if  _type==12 then
                return  _type,_my_pai
            end
            local _num=1 
            if _type==11 then
                _num=2
            end
            --先选天然满足条件的牌
            for _i=3,17 do
                if _p_pai[_i]==_num then
                    if _i<16 or _p_pai[16]~=1 or _p_pai[17]~=1 then
                        _my_pai[#_my_pai+1]=_i
                        if #_my_pai-2==_len then
                            break
                        end
                    end
                end
            end
            local _remain=_len-(#_my_pai-2)
            if _remain>0 then
                --从小到大尽量使用
                for _i=3,15 do
                    if  _p_pai[_i] and (_i< _my_pai[1] or _i>_my_pai[2]) and _p_pai[_i]>_num then
                        if _type==11 then
                            _my_pai[#_my_pai+1]=_i
                            _remain=_remain-1
                        else
                            for _k=1,_p_pai[_i] do
                                if _k<3 or (_k==3 and _i~=_my_pai[1]-1 and _i~=_my_pai[2]+1 ) then
                                    _my_pai[#_my_pai+1]=_i
                                    _remain=_remain-1
                                    if _remain==0 then
                                        break
                                    end
                                end
                            end
                        end
                        if _remain==0 then
                            break
                        end
                    end
                end
            end
            if _remain==1 and _type==10 and _p_pai[16]==1 and _p_pai[17]==1 then
                _remain=0
                _my_pai[#_my_pai+1]=16
            end 
            if _remain==0 then
                return _type,_my_pai
            else
                _my_pai={}
            end
        end
    end
    if _type~=13 then 
        for _i=1,15 do
            if _p_pai[_i]==4 then
                _my_pai[1]=_i
                return 13,_my_pai
            end
        end 
    end
    if  _p_pai[16]==1 and _p_pai[17]==1 then
            _my_pai[1]=16
            _my_pai[2]=17
            return 14,_my_pai
    end 
    return 0
end
--获得牌的list  牌的类型，数量
function nDdzFunc.get_pai_list_by_type(_pai_map, _type, _num, _list)
    _list = _list or {}
    if type(_num) == "number" and _num > 0 then
        for _i = pai_to_id_map[_type], pai_to_id_map[_type] + 3 do
            if _pai_map[_i] then
                _list[#_list + 1] = _i
                _num = _num - 1
                if _num == 0 then
                    break
                end
            end
        end
        if _num > 0 then
            return false
        end
    end
    return _list
    -- body
end
function nDdzFunc.get_cp_list(_c_hash, _type, _pai)
    if _type == 0 then
        return nil
    end
    local _list = {}

    if _type < 4 then
        nDdzFunc.get_pai_list_by_type(_c_hash, _pai[1], _type, _list)
    elseif _type == 4 then
        nDdzFunc.get_pai_list_by_type(_c_hash, _pai[1], 3, _list)
        nDdzFunc.get_pai_list_by_type(_c_hash, _pai[2], 1, _list)
    elseif _type == 5 then
        nDdzFunc.get_pai_list_by_type(_c_hash, _pai[1], 3, _list)
        nDdzFunc.get_pai_list_by_type(_c_hash, _pai[2], 2, _list)
    elseif _type == 13 then
        nDdzFunc.get_pai_list_by_type(_c_hash, _pai[1], 4, _list)
    elseif _type == 14 then
        _list[1] = 53
        _list[2] = 54
    elseif _type == 6 then
        for _i = _pai[1], _pai[2] do
            nDdzFunc.get_pai_list_by_type(_c_hash, _i, 1, _list)
        end
    elseif _type == 7 then
        for _i = _pai[1], _pai[2] do
            nDdzFunc.get_pai_list_by_type(_c_hash, _i, 2, _list)
        end
    elseif _type == 8 then
        nDdzFunc.get_pai_list_by_type(_c_hash, _pai[1], 4, _list)
        if _pai[2] ~= _pai[3] then
            nDdzFunc.get_pai_list_by_type(_c_hash, _pai[2], 1, _list)
            nDdzFunc.get_pai_list_by_type(_c_hash, _pai[3], 1, _list)
        else
            nDdzFunc.get_pai_list_by_type(_c_hash, _pai[2], 2, _list)
        end
    elseif _type == 9 then
        nDdzFunc.get_pai_list_by_type(_c_hash, _pai[1], 4, _list)
        nDdzFunc.get_pai_list_by_type(_c_hash, _pai[2], 2, _list)
        nDdzFunc.get_pai_list_by_type(_c_hash, _pai[3], 2, _list)
    elseif _type == 10 then
        for _i = _pai[1], _pai[2] do
            nDdzFunc.get_pai_list_by_type(_c_hash, _i, 3, _list)
        end
        local _count = {}
        for _i = 3, 3 + _pai[2] - _pai[1] do
            _count[_pai[_i]] = _count[_pai[_i]] or 0
            _count[_pai[_i]] = _count[_pai[_i]] + 1
        end
        for _id, _num in pairs(_count) do
            nDdzFunc.get_pai_list_by_type(_c_hash, _id, _num, _list)
        end
    elseif _type == 11 then
        for _i = _pai[1], _pai[2] do
            nDdzFunc.get_pai_list_by_type(_c_hash, _i, 3, _list)
        end
        for _i = 3, 3 + _pai[2] - _pai[1] do
            nDdzFunc.get_pai_list_by_type(_c_hash, _pai[_i], 2, _list)
        end
    elseif _type == 12 then
        for _i = _pai[1], _pai[2] do
            nDdzFunc.get_pai_list_by_type(_c_hash, _i, 3, _list)
        end
    end
    return _list
end
function nDdzFunc.list_to_map(_list)
    if _list then
        local _map = {}
        for _, _id in ipairs(_list) do
            _map[_id] = true
        end
        return _map
    end
    return nil
end
--从出牌序列中获得最近出牌的人的位置
function nDdzFunc.get_real_chupai_pos_by_act(_act_list)
    local _pos=#_act_list
    local _limit=_pos-2
    if _limit<0 then 
        _limit=0
    end
    while _pos>_limit do
        if _act_list[_pos].type>0 and _act_list[_pos].type<15 then 
            break
        end
        _pos=_pos-1
    end
    if _pos==_limit then
        return nil
    end
    return _pos
end

--检测出的牌是否合法 他人出的牌  我出的牌
function nDdzFunc.check_chupai_safe(_act_list, _my_pai_list)
    local _my_type = nDdzFunc.get_pai_type(_my_pai_list)
    if not  _my_type then
        return false
    end
    local _is_must=nDdzFunc.is_must_chupai(_act_list)
    if _my_type.type==0 then 
        if _is_must then
            return false
        end
        return true
    end
    if _is_must then 
        return true
    end
    local _pos=nDdzFunc.get_real_chupai_pos_by_act(_act_list)

    local _other_type = nDdzFunc.get_pai_type(_act_list[_pos].cp_list)
    if not _other_type then
        if _my_type then
            return true
        end
        return false
    end
    --上个人出的王炸
    if _other_type.type == 14 then
        return false
    end

    if not _my_type then
        return false
    end

    local _type = _my_type.type
    local _pai = _my_type.pai

    if _other_type.type == 0 or _type == 0 then
        return true
    end

    --必须要和上个人出的牌的类型一致
    if _type == _other_type.type then
        if _type < 6 or _type == 13 or _type == 8 or _type == 9 then
            if _pai[1] > _other_type.pai[1] then
                return true
            end
        else
            local sum = _pai[2] - _pai[1]
            if sum == _other_type.pai[2] - _other_type.pai[1] and _pai[1] > _other_type.pai[1] then
                return true
            end
        end
    else
        --当前人出的是炸弹或王炸
        if _type == 13 or _type == 14 then
            return true
        end
    end
    return false
end
--_other_cp_list:其他玩家的出牌，_my_pai_list:我手里的牌
function nDdzFunc.cp_hint(_other_cp_list, _my_pai_list)
    local _type
    if _other_cp_list then
        _type = nDdzFunc.get_pai_type(_other_cp_list)
    end
    local _my_pai_type = nDdzFunc.get_pai_typeHash_by_list(_my_pai_list)
    if _my_pai_type then
        local _cp_type, _pai_type
        if _type then
            _cp_type, _pai_type = nDdzFunc.auto_choose_by_type(_type.type, _type.pai, _my_pai_type)
        else
            
            _cp_type, _pai_type = nDdzFunc.get_all_combination(_my_pai_list)
            if _cp_type==8 or _cp_type==9 then
                _cp_type=nil
                _pai_type=nil
            end
            
            if not _cp_type then
                _cp_type, _pai_type = nDdzFunc.auto_choose_by_type(0, nil, _my_pai_type)
            end
        end
        return nDdzFunc.get_cp_list(nDdzFunc.list_to_map(_my_pai_list), _cp_type, _pai_type)
    end
    return nil
end

function nDdzFunc.is_must_chupai(_act_list)
    if #_act_list==0  or _act_list[#_act_list].type>=100 or ( #_act_list>1 and  _act_list[#_act_list].type==0 and _act_list[#_act_list-1].type==0) then 
        return true
    end
    return false
end
--各种牌型的关键牌数量
local key_pai_num={1,2,3,3,3,1,2,4,4,3,3,3,4,2,}
--检测自己是否有出牌的能力  0有资格，1没资格，2完全没资格（对方王炸） 对方所出牌的类型，出牌类型类型对应的牌，我的牌的hash
function nDdzFunc.check_cp_capacity_by_pailist(_act_list,_pai_list)
    local _pai_hash=nDdzFunc.get_pai_typeHash_by_list(_pai_list)  
    local _other_type=0
    local _other_pai
    local _pos=nDdzFunc.get_real_chupai_pos_by_act(_act_list)
    if _pos then
        local othertype=nDdzFunc.get_pai_type(_act_list[_pos].cp_list)
        _other_type=othertype.type
        _other_pai=othertype.pai
    end


    if _other_type==0 then 
        return 0
    elseif _other_type==14 then 
        return 2
    else
        --如果我有双王
        if  _pai_hash[16]==1 and _pai_hash[17]==1 then
            return 0
        end
        --拥有各种数量的牌的统计
        local _type_num={0,0,0,0}
        for _k,_v in pairs(_pai_hash) do
            if _v>0 then
                _type_num[_v]=_type_num[_v]+1
            end
        end
        --我有炸弹 且对方没出炸弹
        if _other_type~=13 and _type_num[4]>0 then
            return 0
        end
        local _num=key_pai_num[_other_type]
        --是否有比对方关键牌大的pai
        local is_have_big=false
        for _k,_v in pairs(_pai_hash) do
            if _k>_other_pai[1] and _v>=_num then 
                is_have_big=true
                break
            end 
        end
        if not is_have_big then
            return 1
        end
        if _other_type<4 or _other_type==13 then
            return 0
        elseif _other_type==4 then
            if _type_num[1]+_type_num[2]+_type_num[3]+_type_num[4]>1 then
                return 0
            end
        elseif _other_type==5 then
            if _type_num[2]+_type_num[3]+_type_num[4]>1 then
                return 0
            end
        elseif _other_type==6 or _other_type==7 or _other_type>9 then
            local _s=_other_pai[1]+1
            local _count=_other_pai[2]-_other_pai[1]
            local _e=15-_count
            local _flag=false
            while _s<_e do
                _flag=true
                for _i=_s,_s+_count do
                    if not _pai_hash[_i] or _pai_hash[_i]<_num then
                        _s=_i+1
                        _flag=false
                        break
                    end
                end
                if _flag then
                    break
                end
            end
            if _flag then
                if _other_type==6 or _other_type==7 or _other_type==12 then
                    return 0
                end
                if _other_type==10 then
                    local _total=0
                    --计算是否有紧挨着的三个
                    local _next_san=_s+_count+1
                    if _next_san<15 and _pai_hash[_next_san] and _pai_hash[_next_san]>2 then
                        _type_num[_pai_hash[_next_san]]=_type_num[_pai_hash[_next_san]]-1
                        _total=_total+2
                    end
                    _next_san=_s-1
                    if _next_san>2 and _pai_hash[_next_san] and _pai_hash[_next_san]>2 then
                        _type_num[_pai_hash[_next_san]]=_type_num[_pai_hash[_next_san]]-1
                        _total=_total+2
                    end
                    _total=_total+_type_num[1]+_type_num[2]*2+_type_num[3]*3+_type_num[4]*3-(_count+1)*3
                    if _total>=_count+1 then
                        return 0
                    end

                elseif _other_type==11 then
                    if _type_num[2]+_type_num[3]+_type_num[4]>=(_count+1)*2 then
                        return 0
                    end
                end
            end 
        end
        
        return 1    
    end

end
function nDdzFunc.get_paiType_sound(cp_list)
    local pai_type=nDdzFunc.get_pai_type(cp_list)
    local prefix={
        "sod_game_but_buchu",
        "sod_game_card_",
        "sod_game_card_d",
        "sod_game_card_333",
        "sod_game_card_3d1",
        "sod_game_card_3d2",
        "sod_game_card_straight",
        "sod_game_card_liandui",
        "sod_game_card_4d2",
        "sod_game_card_4d22d",
        "sod_game_card_airplanewings",
        "sod_game_card_airplanewings",
        "sod_game_card_airplane",
        "sod_game_card_bomb",
        "sod_game_card_rockets",
    }
    if not pai_type then
        pai_type={type=0}
    end
    local sound=prefix[pai_type.type+1]
    if pai_type.type==1 or pai_type.type==2 then
        sound=sound..pai_type.pai[1]
    end
    return sound
end
function nDdzFunc.getAllPaiCount()
    return {
        [3]=4,
        [4]=4,
        [5]=4,
        [6]=4,
        [7]=4,
        [8]=4,
        [9]=4,
        [10]=4,
        [11]=4,
        [12]=4,
        [13]=4,
        [14]=4,
        [15]=4,
        [16]=1,
        [17]=1,
    }
end
function nDdzFunc.jipaiqi(cp_list,jipaiqi)
    local pai=nil
    if cp_list then
        local k
        for _,v in ipairs(cp_list) do
            k=pai_map[v]
            jipaiqi[k]=jipaiqi[k]-1
        end
    end
    return jipaiqi
end

function nDdzFunc.get_pai_info(no)
    local type=pai_map[no]
    local start=pai_to_id_map[type]
    --1 红桃 黑桃  梅花  方片
    local color=no-start+1

    return {type=type,color=color}
end
--对牌进行排序得到需要展示的序列
function nDdzFunc.sort_pai_for_show(cp_list,pai_type)
    local list=basefunc.copy(cp_list)
    table.sort(list,function (a,b)
        if a>b then
            return true
        end
        return false
    end)
    if pai_type then
        local flag=false
        local new_list={}
        local beifen_list={}
        if pai_type.type==4 or pai_type.type==5 or pai_type.type==8 or pai_type.type==9 then
            flag=true
            for idx,v in ipairs(list) do
                if pai_map[v]==pai_type.pai[1] then
                    new_list[#new_list+1]=v
                else
                    beifen_list[#beifen_list+1]=v
                end
            end
        elseif pai_type.type==10 or pai_type.type==11 then
            flag=true
             for idx,v in ipairs(list) do
                if pai_map[v]>=pai_type.pai[1] and pai_map[v]<=pai_type.pai[2] then
                    new_list[#new_list+1]=v
                else
                    beifen_list[#beifen_list+1]=v
                end
            end
        end
        if flag then
            for idx,v in ipairs(beifen_list) do
                new_list[#new_list+1]=v
            end
            return new_list
        end
    end
    return list
end

function nDdzFunc.get_all_combination(pai_list,appointType,key_pai)
    --参数不对
    if  not pai_list or type(pai_list)~="table" or #pai_list==0 then
        return nil
    end
    local start_pos=3
    if key_pai and key_pai[1] then
        start_pos=key_pai[1]+1
    end

    local count=#pai_list

    local pai_id_map=nDdzFunc.list_to_map(pai_list)
    local pai_type_map=nDdzFunc.get_pai_typeHash_by_list(pai_list)
    -- dump(pai_list)
    -- dump(pai_id_map)
    -- dump(pai_type_map)

    if count==1 and (not appointType or appointType==1) then
        --单牌
        local type,pai=get_dpOrDz_combination(pai_type_map,start_pos,{},1)
        return type,pai
    elseif count==2 then
        if not appointType or appointType==2 then
            --对子
            local type,pai=get_dpOrDz_combination(pai_type_map,start_pos,{},2)
            if type then
                return type,pai
            end
        end
        --王炸
        local type,pai=get_wazha_combination(pai_type_map)
        if type then
            return type,pai
        end
    elseif count==3 and (not appointType or appointType==3) then
        --只能是三不带
        local type,pai=get_3dn_combination(pai_type_map,start_pos,{})
        if type then
           return type,pai
        end
    elseif count==4 then
        if not appointType or appointType==4 then
            --三带一
            local nc={}
            local type,pai=get_3dn_combination(pai_type_map,start_pos,nc,1)
            if type then
                return type,pai
            end
        end  
        --炸弹
        local _s=start_pos
        if not appointType or (appointType and appointType~=13) then
            _s=3
        end 
        local type,pai=get_realZhadan_combination(pai_type_map,_s,{})
        if type then
            return type,pai
        end
    elseif count>=5 then
        --匹配三带二
        if count==5 and (not appointType or appointType==5) then
            local nc={}
            local type,pai=get_3dn_combination(pai_type_map,start_pos,nc,2)
            if type then
                return type,pai
            end
        end
        --匹配四带二
        if count==6 and (not appointType or appointType==8) then
            local nc={}
            local type,pai=get_4dn_combination(pai_type_map,start_pos,nc,1)
            if type then
                return type,pai
            end
        end
        --匹配四带两对
        if count==8 and (not appointType or appointType==9) then
            local nc={}
            local type,pai=get_4dn_combination(pai_type_map,start_pos,nc,2)
            if type then
                return type,pai
            end
        end

        --匹配顺子
        if count<13 and (not appointType or appointType==6) then
            local nc={}
            local type,pai=get_shunzi_combination(pai_type_map,start_pos,count)
            if type then
                return type,pai
            end
        end
        --匹配所有连队
        if count%2==0 and (not appointType or appointType==7) then
            local _c=count/2
            local type,pai=get_liandui_combination(pai_type_map,start_pos,_c)
            if type then
                return type,pai
            end
        end
        --匹配飞机
        if count>=6 then
            --飞机不带
            if count%3==0 and (not appointType or appointType==12) then
                local _c=count/3
                local type,pai=get_feiji_combination(pai_type_map,start_pos,_c)
                if type then
                    return type,pai
                end
            end
            --飞机带对子
            if count%5==0 and (not appointType or appointType==11) then
                local _c=count/5
                local type,pai=get_feijid2_combination(pai_type_map,start_pos,_c)
                if type then
                    return type,pai
                end
            end
            --飞机带单牌
            if count%4==0 and (not appointType or appointType==10) then
                local _c=count/4
                local type,pai=get_feijid1_combination(pai_type_map,start_pos,_c)
                if type then
                    return type,pai
                end
            end
        end
    end 
    return nil 
end
local function choose_pai_by_mutilated(_cp_list,_my_paiType_map)
    --求出数量最多的牌的数量
    local cp_pai_map={}
    local cp_type_list={}
    local max_num=0
    local max_pai_type=2
    local min_pai_type=18
    --牌的种类计数
    local all_type_count=0
    for _,v in pairs(_cp_list) do
        local pai=pai_map[v]
        cp_pai_map[pai]=cp_pai_map[pai] or 0
        cp_pai_map[pai]=cp_pai_map[pai] + 1
        if cp_pai_map[pai]==1 then
            all_type_count=all_type_count+1
            cp_type_list[#cp_type_list+1]=pai
        end
        if cp_pai_map[pai]>max_num then
            max_num=cp_pai_map[pai]
        end
        if pai>max_pai_type then
            max_pai_type=pai
        end
        if pai<min_pai_type then
            min_pai_type=pai
        end
    end

    --
    local function maybe_3dn()
        local _pai1=cp_type_list[1]
        local _pai2=cp_type_list[2]
        if #_cp_list<5 and all_type_count==2 and _my_paiType_map[_pai1] and _my_paiType_map[_pai2] then
            if (_pai1~=_pai2) and ((_my_paiType_map[_pai1]<3 and _my_paiType_map[_pai2]==3) or (_my_paiType_map[_pai1]==3 and _my_paiType_map[_pai2]<3)) then
                local key={}
                if _my_paiType_map[_pai1]==3 then
                    key[1]=_pai1
                    key[2]=_pai2
                else
                    key[1]=_pai2
                    key[2]=_pai1
                end
                if cp_pai_map[key[2]]==2 then
                    return 5,key
                else
                    return 4,key
                end
                
            end
        end
        return nil
    end
    if #_cp_list==1 then
        local _pai=pai_map[_cp_list[1]]
        if (_pai==16 or _pai==17) and _my_paiType_map[16]==1 and _my_paiType_map[17]==1 then
            return 14,{16,17}
        end
        if _my_paiType_map[_pai] and _my_paiType_map[_pai]>2 then
            if _my_paiType_map[_pai]==2 then
                return 2,{_pai}
            elseif _my_paiType_map[_pai]==3 then
                return 3,{_pai}
            elseif _my_paiType_map[_pai]==4 then
                return 13,{_pai}
            end
        end
    --查看是否可能是顺子
    elseif max_num==1 and max_pai_type<15 and all_type_count>1 then
        local s=min_pai_type
        local e=max_pai_type
        --玩家提供的关键牌 必须连续才能继续往下走 
        for k=s,e do
            if not cp_pai_map[k] then
                return maybe_3dn()  
            end
        end

        s=min_pai_type
        e=min_pai_type+4
        if e<max_pai_type then
            e=max_pai_type
        elseif e>14 then
            e=14
        end

        local flag=false
        if e-s>=4 then
            flag=true
            for k=s,e do
                if not (_my_paiType_map[k] and _my_paiType_map[k]>0) then
                    flag=false
                    break    
                end
            end
        end
        
        if not flag then
            --逆向查找
            s=max_pai_type-4
            e=max_pai_type
            if s>min_pai_type then
                s=min_pai_type
            end
            if s<3 then
                s=3
            end

            if e-s>=4 then
                flag=true
                for k=s,e do
                    if not (_my_paiType_map[k] and _my_paiType_map[k]>0) then
                        flag=false
                        break    
                    end
                end
            end
        end
        if flag then
            local e2=14
            for k=e+1,e2 do
                if _my_paiType_map[k] and _my_paiType_map[k]==1 then
                    e=k
                else
                    break    
                end
            end
            return 6,{s,e}
        end

        return maybe_3dn()
    --查看是否为连队
    elseif max_num==2 and max_pai_type<15 and all_type_count>1 then 
        local s=min_pai_type
        local e=max_pai_type
        --玩家提供的关键牌 必须连续才能继续往下走 
        for k=s,e do
            if not cp_pai_map[k] then
                return  maybe_3dn() 
            end
        end

        s=min_pai_type
        e=min_pai_type+2
        if e<max_pai_type then
            e=max_pai_type
        elseif e>14 then
            e=14
        end

        local flag=false
        if e-s>=2 then
            flag=true
            for k=s,e do
                if not (_my_paiType_map[k] and _my_paiType_map[k]>1) then
                    flag=false
                    break    
                end
            end
        end
        
        if not flag then
            --逆向查找
            s=max_pai_type-2
            e=max_pai_type
            if s>min_pai_type then
                s=min_pai_type
            end
            if s<3 then
                s=3
            end

            if e-s>=2 then
                flag=true
                for k=s,e do
                    if not (_my_paiType_map[k] and _my_paiType_map[k]>1) then
                        flag=false
                        break    
                    end
                end
            end
        end
        if flag then
            
            for k=e+1,14 do
                if _my_paiType_map[k] and _my_paiType_map[k]==2 then
                    e=k
                else
                    break    
                end
            end
            
            return 7,{s,e}
        end
        return maybe_3dn()
    --判断是否为飞机
    elseif max_num<=3 and  max_pai_type<15 then
        local s=min_pai_type
        local e=max_pai_type
        local flag=true
        for k=s,e do
            if not (_my_paiType_map[k] and _my_paiType_map[k]>2) then
                return   
            end
        end
        return  12,{s,e}
        
    end
    return maybe_3dn()
end
local function choose_pai_by_mutilated_by_appointType(_cp_list,_my_paiType_map,appointType,key_pai)
    
    if appointType==4 or appointType==5 then
        --求出数量最多的牌的数量
        local cp_pai_map={}
        local cp_type_list={}
        local max_num=0
        local max_pai_type=2
        local min_pai_type=18
        --牌的种类计数
        local all_type_count=0
        for _,v in pairs(_cp_list) do
            local pai=pai_map[v]
            cp_pai_map[pai]=cp_pai_map[pai] or 0
            cp_pai_map[pai]=cp_pai_map[pai] + 1
            if cp_pai_map[pai]==1 then
                all_type_count=all_type_count+1
                cp_type_list[#cp_type_list+1]=pai
            end
            if cp_pai_map[pai]>max_num then
                max_num=cp_pai_map[pai]
            end
            if pai>max_pai_type then
                max_pai_type=pai
            end
            if pai<min_pai_type then
                min_pai_type=pai
            end
        end
        local function maybe_3dn()
            if #_cp_list<5 and all_type_count==2 then
                local _pai1=cp_type_list[1]
                local _pai2=cp_type_list[2]
                if (_pai1~=_pai2) and ((_my_paiType_map[_pai1]<3 and _my_paiType_map[_pai2]==3) or (_my_paiType_map[_pai1]==3 and _my_paiType_map[_pai2]<3)) then
                    local key={}
                    if _my_paiType_map[_pai1]==3 then
                        key[1]=_pai1
                        key[2]=_pai2
                    else
                        key[1]=_pai2
                        key[2]=_pai1
                    end
                    if key[1]>key_pai[1] then
                        if appointType==4 then
                            return 4,key
                        else
                            if _my_paiType_map[key[2]]>1 then
                                return 5,key
                            end
                        end  
                    end
                end
            end
            return nil
        end
        return maybe_3dn()
    end
    return nil
end

local function replace_pai_to_must(map,must_have)
    for k,v in pairs(must_have) do
        if not map[k]  then
            local s=pai_to_startId_map[pai_map[k]]
            local e=pai_to_endId_map[pai_map[k]]
            --选更好的那个（越靠近要选的牌的牌越好）
            local better=nil
            for pos=s,e do
                if map[pos] and not must_have[pos] then
                    if not better then
                        map[pos]=nil
                        map[k]=true
                        better=pos
                    elseif math.abs(pos-k)<math.abs(better-k) then
                        map[better]=true
                        better=pos
                        map[pos]=nil
                    end
                end
            end
        end
    end
end 
--智能补全
-- _act_list操作序列 _cp_list我的已经选好的牌  _my_pai_list
--[[
算法思路    
        补全种类
            对子
            三个
            飞机  （触发条件：4张牌以上  包含3个 ）
            炸弹
            王炸
            顺子（5个5个的提示 选中的牌在5个以内 提示5个  5-10个以上最多提示10个 超过10个  按最大提示，先按选中牌往左选中，再向右选中）
            连队按最大提示  条件 3个以上  包含对子
--]]
--根据对手出牌类型 选出自己手中所有可能出牌的组合 如果已选牌全部在组合里 那么进行智能补全  
function nDdzFunc.intelligent_completion(_act_list,_cp_list,_my_pai_list,is_frist_tanchu)
    --###_test  暂时先关闭************** 
    -- is_frist_tanchu=false
    -- ************** 

    local _my_paiType_map=nDdzFunc.get_pai_typeHash_by_list(_my_pai_list)
    local _my_pai_map=nDdzFunc.list_to_map(_my_pai_list)
    local _other_type=0
    local _other_pai
    local _pos=nDdzFunc.get_real_chupai_pos_by_act(_act_list)
    if _pos then
        local othertype=nDdzFunc.get_pai_type(_act_list[_pos].cp_list)
        _other_type=othertype.type
        _other_pai=othertype.pai
    end

    local get_cp_list=nDdzFunc.get_cp_list
    --当必须出牌时，只智能补全 炸弹 三带 对子 
    if _cp_list and #_cp_list>0 then
        local ic=basefunc.copy(_cp_list)
        --智能补全中必须要含有的牌的map
        local _must_have_map=nDdzFunc.list_to_map(ic)

        if _other_type==0 then
            local _type,_pai=nDdzFunc.get_all_combination(_my_pai_list)
            if not _type or _type==8 or _type==9 then
                _type=nil
                _pai=nil
                _type,_pai=choose_pai_by_mutilated(_cp_list,_my_paiType_map,_must_have_map)
            end
            if _type then
                local _hint=get_cp_list(_my_pai_map, _type, _pai)
                local reslut=nDdzFunc.list_to_map(_hint)
                replace_pai_to_must(reslut,_must_have_map)
                return reslut
            else
                if is_frist_tanchu then
                    local status,_map=nDdzFunc.intelligent_selection_card(_cp_list,_other_type,_other_pai)
                    if status then
                        return _map
                    end
                end
            end 
        else
            if _other_type>1 then
                local _maybe={}
                local  _pai_type=_other_type
                local  _pai=_other_pai

                local _c_type,_c_pai=choose_pai_by_mutilated_by_appointType(_cp_list,_my_paiType_map,_other_type,_other_pai)
                if _c_type then
                    local _hint=get_cp_list(_my_pai_map, _c_type, _c_pai)
                    local reslut=nDdzFunc.list_to_map(_hint)
                    replace_pai_to_must(reslut,_must_have_map)
                    return reslut
                end
                
                while true do
                    _pai_type, _pai = nDdzFunc.auto_choose_by_type(_pai_type, _pai, _my_paiType_map)
                    local _hint=get_cp_list(_my_pai_map, _pai_type, _pai)
                    if _hint then
                        _maybe[#_maybe+1]=_hint
                    else
                        break
                    end
                end
                for _,_h_list in ipairs(_maybe) do
                    local _hash=nDdzFunc.get_pai_typeHash_by_list(_h_list)
                    for idx,v in ipairs(_cp_list) do
                        if not _hash[pai_map[v]] or _hash[pai_map[v]]==0 then
                            break
                        else
                            _hash[pai_map[v]]=_hash[pai_map[v]]-1
                        end
                        if idx==#_cp_list then
                            local reslut=nDdzFunc.list_to_map(_h_list)
                            replace_pai_to_must(reslut,_must_have_map)
                            return reslut
                        end
                    end
                end
                if is_frist_tanchu then
                    local status,_map=nDdzFunc.intelligent_selection_card(_cp_list,_other_type,_other_pai)
                    if status then
                        return _map
                    end
                end

            end
        end     
    end
    return nil
end

function nDdzFunc.get_action_status(act)
    if act.type<100 then
        return "cp"
    elseif act.type==100 then
        return "jdz"
    elseif act.type==101 then 
        return "jiabei"
    end
end

function nDdzFunc.transform_seat(seatNum,s2cSeatNum,mySeatNum)
    if mySeatNum then
        seatNum[1]=mySeatNum
        s2cSeatNum[mySeatNum]=1
        for i=2,3 do
            mySeatNum=mySeatNum+1
            if mySeatNum>3 then
                mySeatNum=1
            end
            seatNum[i]=mySeatNum
            s2cSeatNum[mySeatNum]=i
        end
    end
end

--检查是否是最后一手牌
function nDdzFunc.check_is_only_last_pai(_act_list,_my_pai_list)

    local _pos=nDdzFunc.get_real_chupai_pos_by_act(_act_list)
    local _other_type=nil
    local _other_pai=nil
    if _pos then
        local othertype=nDdzFunc.get_pai_type(_act_list[_pos].cp_list)
        _other_type=othertype.type
        _other_pai=othertype.pai
    end

    local _type,_pai=nDdzFunc.get_all_combination(_my_pai_list,_other_type,_other_pai)
    --四带二不算
    if not _type or _type==8 or _type==9 then
        return nil
    end
    return true
end
-- hewei test **************
-- local pai_list={24,22,23,32,30}
-- local type,pai=nDdzFunc.get_all_combination(pai_list)
-- dump(type)
-- dump(pai)
-- hewei test **************

function nDdzFunc.GetSettlementDetailedInfo(m_data)
    if m_data and m_data.settlement_info then
        local s=m_data.settlement_info
        local data={}
        data.base=1
        data.chuntian=0
        if s.chuntian~=0 then
            data.chuntian=2
           data.base=data.base*data.chuntian
        end
        data.bomb=0
        if s.bomb_count and s.bomb_count>0 then
           data.bomb=2^s.bomb_count
           data.base=data.base*data.bomb     
        end
        data.jdz=0
        if s.p_jdz then
            for _,v in ipairs(s.p_jdz) do
                if v>data.jdz then
                    data.jdz=v
                end
            end
            if data.jdz>0 then
                data.base=data.base*data.jdz
            end
        end
        data.dizhu=1
        data.nongmin=1
        if s.p_jiabei then
            if s.p_jiabei[m_data.dizhu]==2 then
                data.dizhu=2
            end
            --我是地主
            if m_data.dizhu==m_data.seat_num then
                data.nongmin=2
                for seat_num,v in ipairs(s.p_jiabei) do
                    if v==2 and seat_num~=m_data.dizhu then
                        data.nongmin=data.nongmin+1
                    end
                end
            --我是农民    
            else
                if s.p_jiabei[m_data.seat_num]==2 then 
                    data.nongmin=2
                end
            end
        end
        data.all=data.nongmin*data.dizhu*data.base
        return data
    end
    return nil
end
--智能选牌  玩家一次性选好牌后 把多余智能弹回去  目前只支持连队和顺子
function nDdzFunc.intelligent_selection_card(_cp_list,_other_type,_other_pai)
    --是否包含二或者王
    local is_contain_2w=function (_pai_map)
        for i=15,17 do 
            if _pai_map[i] and _pai_map[i]>0 then
                return true
            end
        end
        return false
    end
    local get_type_count=function (_pai_map)
        local t_count=0
        local min_count=nil
        for k,v in pairs(_pai_map) do 
            if v>0 then
                t_count=t_count+1
            end
            if not min_count or v<min_count then
                min_count=v
            end
        end 
        return t_count,min_count
    end
    --是否可能是连队  
    local is_liandui=function (_pai_map,lz_num,start_point)
        if is_contain_2w(_pai_map) then
            return false
        end
        start_point=start_point or 3
        lz_num=lz_num or 0
        local t_count,min_count=get_type_count(_pai_map)
        if t_count>2 and min_count<3 then
            local _type,_pai=get_liandui_combination(_pai_map,start_point,t_count)
            if _type then
                return true
            end
        end
        return false
    end
    --是否可能是顺子  
    local is_shunzi=function (_pai_map,lz_num,start_point)
        if is_contain_2w(_pai_map) then
            return false
        end
        start_point=start_point or 3
        lz_num=lz_num or 0
        local t_count,min_count=get_type_count(_pai_map)
        if t_count>4 and min_count<2 then
            local _type,_pai=get_shunzi_combination(_pai_map,start_point,t_count)
            if _type then
                return true
            end
        end
        return false
    end
    --将多余的牌剔除
    local tichu_pai=function(_cp_list,count)
        local _pai_map={}
        local _hash={}
        for i,id in ipairs(_cp_list) do
            local _t=pai_map[id]
            _hash[_t]=_hash[_t] or 0
            _hash[_t]=_hash[_t]+1
            if _hash[_t]<=count then
                _pai_map[id]=true
            end 
        end
        return _pai_map
    end

    if _cp_list and next(_cp_list) and #_cp_list>4 then
        local p_map=nDdzFunc.get_pai_typeHash_by_list(_cp_list)
        if _other_type==0 or not _other_type then
            _other_type=nil
            _other_pai =nil
        end
        local start_point
        if _other_pai and _other_pai[1] then
            start_point=_other_pai[1]+1
        end
        local _type,_pai=nDdzFunc.get_all_combination(_cp_list,_other_type,_other_pai)
        if _type then
            return false
        end

        if (not _other_type or _other_type==7) and is_liandui(p_map,nil,start_point) then
            return true,tichu_pai(_cp_list,2)
        end
        if (not _other_type or _other_type==6) and is_shunzi(p_map,nil,start_point) then
            return true,tichu_pai(_cp_list,1)
        end

        return false
    end
    return false
end

-- local _cp_list={1,2,5,6,9,10,11,13,14,17}
-- local type,_list=nDdzFunc.intelligent_selection_card(_cp_list,{},0,{})
-- dump(type)
-- dump(_list)

return nDdzFunc






















