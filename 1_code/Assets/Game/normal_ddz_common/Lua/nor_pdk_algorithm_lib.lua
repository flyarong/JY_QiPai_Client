
package.path=package.path..";/Users/hewei/project/JyQipai_client/1_code/Assets/?.lua"
-- local basefunc = require "basefunc"
require "Game.Common.printfunc"
local basefunc = require "Game.Common.basefunc"
local nor_ddz_base_lib = require "Game.normal_ddz_common.lua.nor_pdk_base_lib"
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
    -- 15：假炸弹

--]]
local nor_ddz_algorithm =basefunc.class()


local pai_type=nor_ddz_base_lib.pai_type
local other_type=nor_ddz_base_lib.other_type
local pai_map=nor_ddz_base_lib.pai_map
local pai_to_startId_map=nor_ddz_base_lib.pai_to_startId_map
local pai_to_endId_map=nor_ddz_base_lib.pai_to_endId_map
local lz_id=nor_ddz_base_lib.lz_id
local lz_id_to_type=nor_ddz_base_lib.lz_id_to_type
--各种牌型的关键牌数量
local key_pai_num=nor_ddz_base_lib.key_pai_num
local KAIGUAN=nor_ddz_base_lib.KAIGUAN

local game_type
--[[
phash 备选的牌hash
lz_num 癞子的数量
lz_type 癞子牌的牌类型
start 起始点
c_num 选择数量
no_choose 不能选择的type map
返回值 牌类型 普通牌使用数量  癞子使用数量 
--]]
local function add_value_to_map(map,k,v)
    map[k]=map[k] or 0
    map[k]=map[k]+v
end
local function choose_paiType_by_num(phash,lz_num,lz_type,start,c_num,no_choose)
    --优先选天生符合的
    local p_type,u_num,u_lz_num
    -- dump(no_choose,"xxxxxxxxxxxxxxxxxx")
    for type,num in pairs(phash) do
        -- print("ddddddddddddddddddddddd",type,num)
        if not no_choose[type] and type>=start and num==c_num then
            -- print("ddddddddddddddddddddddd",start,c_num)
            if not p_type then
                p_type=type
                u_num=num 
                u_lz_num=0
            --尽量选小牌
            elseif type<p_type then
                p_type=type
                u_num=num 
                u_lz_num=0
            end
        end
    end
    if p_type then
        --print(ptype,"choose_type")
        return p_type,u_num,u_lz_num
    end
    if c_num>1 then
        --其次选比他小的 但加上癞子符合的
        for type,num in pairs(phash) do
            --癞子不能变大小王 所以要小于16      num必须大于零因为 为零时 癞子只能是他自己本身
            if not no_choose[type] and type>=start and num>0 and num<c_num  and num+lz_num>=c_num and type<16 then
                if not p_type then
                    p_type=type
                    u_num=num 
                    u_lz_num=c_num-num
                --使用癞子少的牌
                elseif (num>u_num) or (num==u_num and type<p_type) then
                    p_type=type
                    u_num=num 
                    u_lz_num=c_num-num
                end
            end
        end
        if p_type then
            return p_type,u_num,u_lz_num
        end
    end
    if c_num<4 then
        local max_num
        --再其次选比他大的符合的
        for type,num in pairs(phash) do
            if not no_choose[type] and type>=start and num>c_num then
                if not p_type then
                    p_type=type
                    u_num=c_num
                    max_num=num
                    u_lz_num=0
                --尽量选数量少的牌 
                elseif (num<max_num) or (num==max_num and type<p_type) then
                    p_type=type
                    u_num=c_num
                    max_num=num 
                    u_lz_num=0
                end
            end
        end
        if p_type then
            -- print("p_type",p_type)
            return p_type,u_num,u_lz_num
        end
    end
    return nil
end
--单牌或者对子
local function get_dpOrDz_combination(phash,lz_num,lz_type,start,no_choose,n_num)

    local c_t_1,u_n_1,u_lz_n_1=choose_paiType_by_num(phash,lz_num,lz_type,start,n_num,no_choose)
    if c_t_1 then
        return n_num,{c_t_1},{nor={[c_t_1]=u_n_1},lz={[c_t_1]=u_lz_n_1}}
    end
    return nil
end
local function get_3dn_combination(phash,lz_num,lz_type,start,no_choose,n_num,self)
       -- print("aaaaaaaaaaaaaaaaaaaaaaaaaaa-----------",game_type,n_num)
    if game_type == "nor_pdk_nor" and n_num == 2 then
        local c_t_1,u_n_1,u_lz_n_1=choose_paiType_by_num(phash,lz_num,lz_type,start,3,no_choose)
        if c_t_1 then
            local nc={[c_t_1]=true}
            local c_t_2,u_n_2,u_lz_n_2=choose_paiType_by_num(phash,lz_num-u_lz_n_1,lz_type,0,n_num-1,nc)
            if c_t_2 then
                local _phash=basefunc.copy(phash)
                --3带2
                if n_num==2 and _phash[c_t_2] and _phash[c_t_2] > 0 then
                    _phash[c_t_2]=_phash[c_t_2] - 1
                end
                local c_t_3,u_n_3,u_lz_n_3=choose_paiType_by_num(_phash,lz_num-u_lz_n_1-u_lz_n_2,lz_type,0,n_num-1,nc)
                if c_t_3 then
                    --成功选取到
                    local use_info={nor={},lz={}}
                    add_value_to_map(use_info.nor,c_t_1,u_n_1)
                    add_value_to_map(use_info.nor,c_t_2,u_n_2)
                    add_value_to_map(use_info.nor,c_t_3,u_n_3)
                    add_value_to_map(use_info.lz,c_t_1,u_lz_n_1)
                    add_value_to_map(use_info.lz,c_t_2,u_lz_n_2)
                    add_value_to_map(use_info.lz,c_t_3,u_lz_n_3)
                    return 28+n_num,{c_t_1,c_t_2,c_t_3},use_info
                end
            end
        end
    else
        local c_t_1,u_n_1,u_lz_n_1=choose_paiType_by_num(phash,lz_num,lz_type,start,3,no_choose)
        if c_t_1 then
            if n_num and n_num>0 then
                local c_t_2,u_n_2,u_lz_n_2=choose_paiType_by_num(phash,lz_num-u_lz_n_1,lz_type,3,n_num,{[c_t_1]=true})
                if c_t_2 then
                    local use_info={nor={},lz={}}
                    add_value_to_map( use_info.nor,c_t_1,u_n_1)
                    add_value_to_map( use_info.nor,c_t_2,u_n_2)
                    add_value_to_map( use_info.lz,c_t_1,u_lz_n_1)
                    add_value_to_map( use_info.lz,c_t_2,u_lz_n_2)
                    --成功选取到
                    return 3+n_num,{c_t_1,c_t_2},use_info
                end
            else
                --3不带
                return 3,{c_t_1},{nor={[c_t_1]=u_n_1},lz={[c_t_1]=u_lz_n_1}}
            end
        end
    end
    return nil
end
local function get_4dn_combination(phash,lz_num,lz_type,start,no_choose,n_num,self)
    if game_type == "nor_pdk_nor" and n_num == 3 then
        local c_t_1,u_n_1,u_lz_n_1=choose_paiType_by_num(phash,lz_num,lz_type,start,4,no_choose)
        if c_t_1 then
            local nc={[c_t_1]=true}
            local c_t_2,u_n_2,u_lz_n_2=choose_paiType_by_num(phash,lz_num-u_lz_n_1,lz_type,0,1,nc)
            if c_t_2 then
                local _phash=basefunc.copy(phash)
                --4带3
                if _phash[c_t_2] and _phash[c_t_2]>0 then
                    _phash[c_t_2]=_phash[c_t_2]-1
                end
                local c_t_3,u_n_3,u_lz_n_3=choose_paiType_by_num(_phash,lz_num-u_lz_n_1-u_lz_n_2,lz_type,0,1,nc)

                if c_t_3 then
                    if _phash[c_t_3] and _phash[c_t_3]>0 then
                        _phash[c_t_3]=_phash[c_t_3]-1
                        local c_t_4,u_n_4,u_lz_n_4=choose_paiType_by_num(_phash,lz_num-u_lz_n_1-u_lz_n_2-u_lz_n_3,lz_type,0,1,nc)
                        if c_t_4 then
                            local use_info={nor={},lz={}}
                            add_value_to_map(use_info.nor,c_t_1,u_n_1)
                            add_value_to_map(use_info.nor,c_t_2,u_n_2)
                            add_value_to_map(use_info.nor,c_t_3,u_n_3)
                            add_value_to_map(use_info.nor,c_t_4,u_n_4)
                            add_value_to_map(use_info.lz,c_t_1,u_lz_n_1)
                            add_value_to_map(use_info.lz,c_t_2,u_lz_n_2)
                            add_value_to_map(use_info.lz,c_t_3,u_lz_n_3)
                            add_value_to_map(use_info.lz,c_t_4,u_lz_n_4)
                            return 28+n_num,{c_t_1,c_t_2,c_t_3,c_t_4},use_info
                        end
                    end
                end
            end
        end
    elseif game_type == "nor_pdk_nor" and n_num == 2 then
        local c_t_1,u_n_1,u_lz_n_1=choose_paiType_by_num(phash,lz_num,lz_type,start,4,no_choose)
        if c_t_1 then
            local nc={[c_t_1]=true}
            local c_t_2,u_n_2,u_lz_n_2=choose_paiType_by_num(phash,lz_num-u_lz_n_1,lz_type,0,1,nc)
            if c_t_2 then
                local _phash=basefunc.copy(phash)
                --4带3
                if _phash[c_t_2] and _phash[c_t_2]>0 then
                    _phash[c_t_2]=_phash[c_t_2]-1
                end
                local c_t_3,u_n_3,u_lz_n_3=choose_paiType_by_num(_phash,lz_num-u_lz_n_1-u_lz_n_2,lz_type,0,1,nc)

                if c_t_3 then
                    local use_info={nor={},lz={}}
                    add_value_to_map(use_info.nor,c_t_1,u_n_1)
                    add_value_to_map(use_info.nor,c_t_2,u_n_2)
                    add_value_to_map(use_info.nor,c_t_3,u_n_3)
                    add_value_to_map(use_info.lz,c_t_1,u_lz_n_1)
                    add_value_to_map(use_info.lz,c_t_2,u_lz_n_2)
                    add_value_to_map(use_info.lz,c_t_3,u_lz_n_3)
                    return 8,{c_t_1,c_t_2,c_t_3},use_info
                end
            end
        end
    elseif game_type == "nor_pdk_nor" and n_num == 1 then
        local c_t_1,u_n_1,u_lz_n_1=choose_paiType_by_num(phash,lz_num,lz_type,start,4,no_choose)
        if c_t_1 then
            local nc={[c_t_1]=true}
            local c_t_2,u_n_2,u_lz_n_2=choose_paiType_by_num(phash,lz_num-u_lz_n_1,lz_type,0,1,nc)
            if c_t_2 then
                local use_info={nor={},lz={}}
                add_value_to_map(use_info.nor,c_t_1,u_n_1-1)
                add_value_to_map(use_info.nor,c_t_2,u_n_2)
                add_value_to_map(use_info.nor,c_t_1,1)
                add_value_to_map(use_info.lz,c_t_1,u_lz_n_1)
                add_value_to_map(use_info.lz,c_t_2,u_lz_n_2)
                add_value_to_map(use_info.lz,c_t_1,0)
                return 30,{c_t_1,c_t_2,c_t_1},use_info
            end
        end 
    end
    return nil
end
local function get_lianxu_combination(phash,lz_num,lz_type,start,lx_num,count)
    local s=start
    local e=14-lx_num+1
    while s<=e do
        local _num=phash[s] or 0
        if _num+lz_num>=count then
            local _lz=lz_num
            local _e=s+lx_num-1
            local nor={}
            local lz={}
            for i=s,_e do
                _num=phash[i] or 0
                if _num+_lz<count then
                    s=s+1
                    break
                else
                    local nor_use=_num
                    if nor_use>count then
                        nor_use=count
                    end
                    nor[i]=nor_use
                    lz[i]=count-nor_use
                    _lz=_lz-(count-nor_use)
                end
                --成功匹配
                if i==_e then
                    return {s,_e},{nor=nor,lz=lz},lz_num-_lz
                end 
            end
        else
            s=s+1
        end
    end
    return nil
end
--顺子
local function get_shunzi_combination(phash,lz_num,lz_type,start,lx_num)
    local pai,use,u_lz_n=get_lianxu_combination(phash,lz_num,lz_type,start,lx_num,1)
    if pai then
        return 6,pai,use
    end
    return nil
end
--连队
local function get_liandui_combination(phash,lz_num,lz_type,start,lx_num)
    local pai,use,u_lz_n=get_lianxu_combination(phash,lz_num,lz_type,start,lx_num,2)
    if pai then
        return 7,pai,use
    end
    return nil
end
--飞机  不带
local function get_feiji_combination(phash,lz_num,lz_type,start,lx_num)
    local pai,use,u_lz_n=get_lianxu_combination(phash,lz_num,lz_type,start,lx_num,3)
    if pai then
        return 12,pai,use
    end
    return nil
end
--飞机带对子（只能全部带对子）（pdk可以带单排）
local function get_feijid2_combination(phash,lz_num,lz_type,start,lx_num,self)
    local s=start
    local e=14-lx_num+1
    --要考虑所有情况
    while s<=e do 
        local pai,use,u_lz_n=get_lianxu_combination(phash,lz_num,lz_type,start,lx_num,3)
        -- dump(pai,"pai")
        if pai then
            local flag=true
            local nc={}
            for i=pai[1],pai[2] do
                if phash[i] > 3 then
                    phash[i] = phash[i] - 3
                else
                    nc[i]=true
                end
            end
            if game_type =="nor_pdk_nor" then
                local hash={}
                _lz_num=lz_num-u_lz_n
                local _phash=basefunc.copy(phash)
                for i=1,lx_num*2 do
                    -- dump(_phash,"phash")
                    local ptype,u_num,u_lz_num=choose_paiType_by_num(_phash,_lz_num,lz_type,0,1,nc)
                    -- print("ptype",ptype)
                    -- print("u_num",u_num)

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
                        -- if hash[ptype]==2 and ptype==pai[1]-1 and ptype>=3  then
                        --     nc[ptype]=true
                        -- end
                        -- if hash[ptype]==2 and ptype==pai[2]+1 and ptype<15  then
                        --     nc[ptype]=true
                        -- end
                        if _phash[ptype] and _phash[ptype]>0 then
                            _phash[ptype]=_phash[ptype]-u_num
                        end
                        _lz_num=_lz_num-u_lz_num
                        pai[#pai+1]=ptype
                        add_value_to_map(use.nor,ptype,u_num)
                        add_value_to_map(use.lz,ptype,u_lz_num)
                    else
                        flag=false
                        break
                    end
                end
                if flag then
                    --成功
                    return 32,pai,use 
                end 
            else
                _lz_num=lz_num-u_lz_n
                for i=1,lx_num do
                    local ptype,u_num,u_lz_num=choose_paiType_by_num(phash,_lz_num,lz_type,0,2,nc)
                    if ptype then
                        nc[ptype]=true
                        _lz_num=_lz_num-u_lz_num
                        pai[#pai+1]=ptype
                        add_value_to_map(use.nor,ptype,u_num)
                        add_value_to_map(use.lz,ptype,u_lz_num)
                    else
                        flag=false
                        break
                    end
                end
                if flag then
                    --成功
                    return 11,pai,use 
                end
            end
        else
            return nil
        end
        s=s+1
    end
    return nil
end
--飞机带单牌
local function get_feijid1_combination(phash,lz_num,lz_type,start,lx_num)
    local s=start
    local e=14-lx_num+1
    --要考虑所有情况
    while s<=e do 
        local pai,use,u_lz_n=get_lianxu_combination(phash,lz_num,lz_type,start,lx_num,3)
        if pai then
            local flag=true
            local nc={}
            for i=pai[1],pai[2] do
                if phash[i] > 3 then
                    phash[i] = phash[i] - 3
                else
                    nc[i]=true
                end
            end
            local hash={}
            _lz_num=lz_num-u_lz_n
            local _phash=basefunc.copy(phash)
            for i=1,lx_num do
                local ptype,u_num,u_lz_num=choose_paiType_by_num(_phash,_lz_num,lz_type,3,1,nc)
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
                    -- if hash[ptype]==2 and ptype==pai[1]-1 and ptype>=3  then
                    --     nc[ptype]=true
                    -- end
                    -- if hash[ptype]==2 and ptype==pai[2]+1 and ptype<15  then
                    --     nc[ptype]=true
                    -- end
                    if _phash[ptype] and _phash[ptype]>0 then
                        _phash[ptype]=_phash[ptype]-u_num
                    end
                    _lz_num=_lz_num-u_lz_num
                    pai[#pai+1]=ptype
                    add_value_to_map(use.nor,ptype,u_num)
                    add_value_to_map(use.lz,ptype,u_lz_num)
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
local function get_wazha_combination(phash,lz_num,lz_type)
    if phash[16]==1 and phash[17]==1 then
        return 14,{16,17},{nor={[16]=1,[17]=1},lz={}}
    end
    return nil
end
local function get_realZhadan_combination(phash,lz_num,lz_type,start,no_choose)
    local c_t_1,u_n_1,u_lz_n_1=choose_paiType_by_num(phash,0,lz_type,start,4,no_choose)
    if c_t_1 then
        --  真炸弹
        return 13,{c_t_1},{ nor={ [c_t_1]=u_n_1},lz={ [c_t_1]=u_lz_n_1} }
    else
        if lz_num==4 and lz_type>=start then
            return 13,{lz_type},{ nor={ [lz_type]=0},lz={ [lz_type]=4} }
        end
    end
    return nil
end
local function get_jiaZhadan_combination(phash,lz_num,lz_type,start,no_choose) 
    local c_t_1,u_n_1,u_lz_n_1=choose_paiType_by_num(phash,lz_num,lz_type,start,4,no_choose)
    if c_t_1 then
        if u_lz_n_1 and u_lz_n_1>0 and u_lz_n_1<4 then
          --  假炸弹
            return 15,{c_t_1},{ nor={ [c_t_1]=u_n_1},lz={ [c_t_1]=u_lz_n_1} }
        else
            no_choose[c_t_1]=true
            return get_jiaZhadan_combination(phash,lz_num,lz_type,start,no_choose) 
        end
    end
    return nil
end

local function check_chupai_safe_by_type(_type,_pai,_other_type,_other_pai)
    _other_type=_other_type or 0
    if _other_type==0 then
        return true
    end

    --上个人出的王炸
    if _other_type==14 then 
        return false
    end
    print("type",_type)
    dump(_pai,"_pai")
    print("_other_type",_other_type)
    dump(_other_pai,"_other_pai")
    --必须要和上个人出的牌的类型一致
    if _type==_other_type then
        if _type<6 or _type==13 or _type==15 or _type==8 or _type==9 or _type == 30 or _type == 31 then 
            if _other_pai[1] and _pai[1]>_other_pai[1] then 
                return true
            end
        else
            local sum=_pai[2]-_pai[1]
            if sum==_other_pai[2]-_other_pai[1] and _pai[1]>_other_pai[1] then 
                return true
            end
        end
    else
        --当前人出的是炸弹或王炸
        if _other_type~=13 or _type==15 then 
            return true
        end
        --当前人出的是炸弹或王炸
        if _type==13 or _type==14 then 
            return true
        end
    end
    return false
end
--检测根据类型检测出的牌是否合法          
local function check_chupai_safe_by_act(_act_list,_type,_pai)
    local _is_must=nor_ddz_base_lib.is_must_chupai(_act_list)
    if _type==0 then 
        if _is_must then
            return false
        end
        return true
    end
    if _is_must then 
        return true
    end
    local _pos=nor_ddz_base_lib.get_real_chupai_pos_by_act(_act_list)

    return check_chupai_safe_by_type(_type,_pai,_act_list[_pos].type,_act_list[_pos].pai)
end





local function get_pai_type(_pai_list, _lz_num)
    if type(_pai_list) ~= "table" or #_pai_list == 0 then return {type = 0} end
    local _pai = nor_ddz_base_lib.sort_pai_by_amount(
                     nor_ddz_base_lib.get_pai_typeHash_by_list(_pai_list))
    if not _pai then return false end
    -- 最大的相同牌数量
    local _max_num = _pai[1].amount
    -- 牌的种类  忽略花色
    local _type_count = #_pai

    if _type_count == 1 then
        if _max_num == 4 then
            -- 假炸弹
            if _lz_num and _lz_num < 4 and _lz_num > 0 then
                return {type = 15, pai = {_pai[1].type}}
            end
            return {type = 13, pai = {_pai[1].type}}
        elseif _max_num < 4 then
            return {type = _max_num, pai = {_pai[1].type}}
        end
    elseif _max_num == 4 then
        if _type_count == 2 then
            -- 四带二  被带的牌相同情况
            if _pai[2].amount == 2 then
                return {
                    type = 8,
                    pai = {_pai[1].type, _pai[2].type, _pai[2].type}
                }
                -- 四带三 被带的牌相同情况
            elseif _pai[2].amount == 3 then
                return {type = 31, pai = {_pai[1].type, _pai[2].type}}
            elseif _pai[2].amount == 1 then
                return {type = 30, pai = {_pai[1].type, _pai[2].type}}
            end
        elseif _type_count == 3 then
            -- 四带二
            if _pai[2].amount == 1 and _pai[3].amount == 1 and
                (_pai[2].type ~= 16 or _pai[3].type ~= 17) then
                return {
                    type = 8,
                    pai = {_pai[1].type, _pai[2].type, _pai[3].type}
                }
                -- --四带两对
                -- elseif _pai[2].amount == 2 and _pai[3].amount == 2 then
                --     return {type = 9, pai = {_pai[1].type, _pai[2].type, _pai[3].type}}
                -- 四带三 两相同一不同
            elseif _pai[2].amount == 2 and _pai[3].amount == 1 then
                return {
                    type = 31,
                    pai = {_pai[1].type, _pai[2].type, _pai[3].type}
                }
            end
        elseif _type_count == 4 then
            -- 四带三
            if _pai[2].amount == 1 and _pai[3].amount == 1 and _pai[4].amount ==
                1 then
                return {
                    type = 31,
                    pai = {
                        _pai[1].type, _pai[2].type, _pai[3].type, _pai[4].type
                    }
                }
            end
        end

        if game_type == "nor_pdk_nor" then
            local pai_type = nor_ddz_base_lib.sort_pai_by_type(
                nor_ddz_base_lib.get_pai_typeHash_by_list(_pai_list))
                
            -- 记录下来的总头尾
            local _max_len = 1
            local _head = pai_type[1].type
            local _tail = pai_type[1].type
            -- 临时记录的头尾
            local _cur_len = 1
            local _cur_head = pai_type[1].type
            local _cur_tail = pai_type[1].type

            local tot_num = 4
            local len_4 = 1

            for _i = 2, _type_count do
                tot_num = tot_num + _pai[_i].amount
                if pai_type[_i].amount >= 3 then
                    if _pai[_i].amount == 4 then
                        len_4 = len_4 + 1
                    end
                    if pai_type[_i - 1].type + 1 == pai_type[_i].type and pai_type[_i].type < 15 and pai_type[_i - 1].amount >= 3 then
                        _cur_len = _cur_len + 1
                        _cur_tail = pai_type[_i].type
                    else
                        _cur_len = 1
                        _cur_head = pai_type[_i].type
                        _cur_tail = pai_type[_i].type
                    end
                    if _cur_len >= _max_len then
                        _max_len = _cur_len
                        _head = _cur_head
                        _tail = _cur_tail
                    end
                end
            end

            for _i = 1, _type_count do
                if _head == _pai[_i].type then
                    _head = _i
                end
                if _tail == _pai[_i].type then
                    _tail = _i
                end
            end

            local _count = 0
            -- 大小王统计
            local _boss_count = 0
            for _i = 1, _type_count do
                if _i < _head or _i > _tail then
                    _count = _count + _pai[_i].amount
                    if _pai[_i].type == 16 or _pai[_i].type == 17 then
                        _boss_count = _boss_count + 1
                    end
                end
            end
            if (_count + len_4) == _max_len and _boss_count < 2 then
                -- 三带2
                if _max_len == 1 and _count == 1 then
                    return {type = 30, pai = {_pai[1].type, _pai[2].type}}
                else
                    -- 飞机带单牌
                    local _pai_type = {
                        type = 10,
                        pai = {_pai[_head].type, _pai[_tail].type}
                    }
                    for _i = 1, _type_count do
                        if _i < _head or _i > _tail then
                            for _k = 1, _pai[_i].amount do
                                _pai_type.pai[#_pai_type.pai + 1] =
                                    _pai[_i].type
                            end
                        end
                    end
                    return _pai_type
                end
            elseif _count > 0 and (_count + len_4) == _max_len * 2 then
                -- 三带2
                if _max_len == 1 then
                    return {
                        type = 30,
                        pai = {_pai[1].type, _pai[2].type, _pai[3].type}
                    }
                else
                    -- 飞机带2*n
                    local _pai_type = {
                        type = 32,
                        pai = {_pai[_head].type, _pai[_tail].type}
                    }
                    for _i = 1, _type_count do
                        if _i < _head or _i > _tail then
                            _pai_type.pai[#_pai_type.pai + 1] = _pai[_i].type
                        end
                    end
                    return _pai_type
                end
            elseif (tot_num / 4) == _max_len and _max_len > 1 then

                local _pai_type = {
                        type = 10,
                        pai = {_pai[_head].type, _pai[_tail].type}
                    }
                    for _i = 1, _type_count do
                        if _i < _head or _i > _tail then
                            _pai_type.pai[#_pai_type.pai + 1] = _pai[_i].type
                        end
                    end
                    return _pai_type
            elseif (tot_num / 5) == _max_len and _max_len > 1 then

                local _pai_type = {
                        type = 32,
                        pai = {_pai[_head].type, _pai[_tail].type}
                    }
                    for _i = 1, _type_count do
                        if _i < _head or _i > _tail then
                            _pai_type.pai[#_pai_type.pai + 1] = _pai[_i].type
                        end
                    end
                    return _pai_type
            elseif (tot_num / 4) == _max_len - 1 and _max_len > 1 then

                _head = _head + 1
                local _pai_type = {
                    type = 10,
                    pai = {_pai[_head].type, _pai[_tail].type}
                }
                for _i = 1, _type_count do
                    if _i < _head or _i > _tail then
                        _pai_type.pai[#_pai_type.pai + 1] = _pai[_i].type
                    end
                end
                return _pai_type
            elseif (tot_num / 5) == _max_len - 1 and _max_len > 1 then

                _head = _head + 1
                local _pai_type = {
                    type = 32,
                    pai = {_pai[_head].type, _pai[_tail].type}
                }
                for _i = 1, _type_count do
                    if _i < _head or _i > _tail then
                        _pai_type.pai[#_pai_type.pai + 1] = _pai[_i].type
                    end
                end
                return _pai_type
            end
        end
    elseif _max_num == 2 then
        if _type_count >= 2 then
            local _flag = true
            for _i = 2, _type_count do
                if _pai[_i].amount ~= 2 then
                    _flag = false
                    break
                end
            end
            if _flag and _pai[_type_count].type < 15 and _pai[_type_count].type -
                _pai[1].type == _type_count - 1 then
                return {type = 7, pai = {_pai[1].type, _pai[_type_count].type}}
            end
        end
    elseif _max_num == 1 then
        if _type_count == 2 then
            -- 王炸
            if _pai[1].type == 16 and _pai[2].type == 17 then
                return {type = 14, pai = {_pai[1].type, _pai[2].type}}
            end
        elseif _type_count > 4 then
            -- 顺子
            if _pai[_type_count].type < 15 and _pai[_type_count].type -
                _pai[1].type == _type_count - 1 then
                return {type = 6, pai = {_pai[1].type, _pai[_type_count].type}}
            end
        end
    elseif _max_num == 3 then
        -- 记录下来的总头尾
        local _max_len = 1
        local _head = 1
        local _tail = 1
        -- 临时记录的头尾
        local _cur_len = 1
        local _cur_head = 1
        local _cur_tail = 1
        local tot_num = 3
        for _i = 2, _type_count do
            tot_num = tot_num + _pai[_i].amount
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
            end
        end
        if _max_len == _type_count then
            -- 裸飞机
            return {type = 12, pai = {_pai[1].type, _pai[_type_count].type}}
        else
            local _count = 0
            -- 是否全部为对子
            local _is_double = true
            -- 大小王统计
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
                -- 三带一
                if _max_len == 1 then
                    return {type = 4, pai = {_pai[1].type, _pai[2].type}}
                else
                    -- 飞机带单牌
                    local _pai_type = {
                        type = 10,
                        pai = {_pai[_head].type, _pai[_tail].type}
                    }
                    for _i = 1, _type_count do
                        if _i < _head or _i > _tail then
                            for _k = 1, _pai[_i].amount do
                                _pai_type.pai[#_pai_type.pai + 1] =
                                    _pai[_i].type
                            end
                        end
                    end
                    return _pai_type
                end
            elseif _count == _max_len * 2 and _is_double then
                -- 三带对
                if _max_len == 1 then
                    return {type = 30, pai = {_pai[1].type, _pai[2].type}}
                else
                    -- 飞机带对子
                    local _pai_type = {
                        type = 32,
                        pai = {_pai[_head].type, _pai[_tail].type}
                    }
                    for _i = 1, _type_count do
                        if _i < _head or _i > _tail then
                            _pai_type.pai[#_pai_type.pai + 1] = _pai[_i].type
                        end
                    end
                    return _pai_type
                end
            elseif _count == _max_len * 2 then
                -- 三带2
                if _max_len == 1 then
                    return {
                        type = 30,
                        pai = {_pai[1].type, _pai[2].type, _pai[3].type}
                    }
                else
                    -- 飞机带2*n
                    local _pai_type = {
                        type = 32,
                        pai = {_pai[_head].type, _pai[_tail].type}
                    }
                    for _i = 1, _type_count do
                        if _i < _head or _i > _tail then
                            _pai_type.pai[#_pai_type.pai + 1] = _pai[_i].type
                        end
                    end
                    return _pai_type
                end
            elseif tot_num / 4 == _max_len - 1 then
                _head = _head + 1
                local _pai_type = {
                    type = 10,
                    pai = {_pai[_head].type, _pai[_tail].type}
                }
                for _i = 1, _type_count do
                    if _i < _head or _i > _tail then
                        _pai_type.pai[#_pai_type.pai + 1] = _pai[_i].type
                    end
                end
                return _pai_type 
            elseif tot_num / 5 == _max_len - 1 then
                _head = _head + 1
                local _pai_type = {
                    type = 32,
                    pai = {_pai[_head].type, _pai[_tail].type}
                }
                for _i = 1, _type_count do
                    if _i < _head or _i > _tail then
                        _pai_type.pai[#_pai_type.pai + 1] = _pai[_i].type
                    end
                end
                return _pai_type
            end
        end
    end
    return false
end
function nor_ddz_algorithm:get_pai_type(_pai_list,_lz_num)
    local data=get_pai_type(_pai_list,_lz_num)
    return data
end
--按单牌 ，对子，三不带，炸弹的顺序选择一种牌   ###_test
function nor_ddz_algorithm:auto_choose_by_order(pai_id_map, pai_type_map, lz_num, lz_type)
    local package=function (pai_id_map,type,pai,use_info)
                    local cp_list=self:get_cp_list_by_useInfo(pai_id_map,use_info)
                    local lazi_num=0
                    if cp_list.lz then
                        lazi_num=#cp_list.lz
                    end
                    local nor_list=nor_ddz_base_lib.merge_nor_and_lz(cp_list)
                    local show_list=nor_ddz_base_lib.sort_pai_for_show(nor_list,type,pai,use_info.lz)
                    return {
                              type=type,
                              cp_list=cp_list,
                              merge_cp_list=nor_ddz_base_lib.merge_nor_and_lz(cp_list),
                              lazi_num=lazi_num,
                              show_list = show_list,
                              pai=pai
                            }
            end

    local _type = nil
    local _pai={}
    for _i = 3, 17 do
        if pai_type_map[_i] then
            --danpai
            if pai_type_map[_i] == 1 then
                _pai[1] = _i
                _type=1
                break
            elseif pai_type_map[_i] == 2 then
                if not _type or _type > 2 then
                    _type = 2
                    _pai[1] = _i
                end
            elseif pai_type_map[_i] == 3 then
                if not _type or _type > 3 then
                    --如果没有开三不带则不能三不带除了只剩最后三张
                    if self.kaiguan[3] then
                        _type = 3
                        _pai[1] = _i
                    else
                        local count=0
                        for k,v in pairs(pai_id_map) do
                            count=count+1
                        end
                        --只剩最后三张也可以出三不带
                        if count==3 then
                            _type = 3
                            _pai[1] = _i
                        else
                            _type = 2
                            _pai[1] = _i
                        end
                    end
                end
            elseif pai_type_map[_i] == 4 then
                if not _type then
                    _type = 13
                    _pai[1] = _i
                end
            end
        end
    end
    local use_info={nor={},lz={}}  
    if not _type and lz_num>0 then
        _type =1
        _pai[1]=lz_type
        use_info.lz[lz_type]=1
    else
        use_info.nor[_pai[1]]=key_pai_num[_type]
    end
    return package(pai_id_map,_type,_pai,use_info)
end

function nor_ddz_algorithm:auto_choose_by_type(pai_id_map,pai_type_map,lz_num,lz_type,appointType,key_pai)
    dump(pai_id_map,"pai_id_map")
    dump(pai_type_map,"pai_type_map")
    dump(key_pai,"key_pai")
    if appointType==14 then 
        return {type=0}
    end
    if appointType==0 then
        return self:auto_choose_by_order(pai_id_map,pai_type_map,lz_num,lz_type)
    end
    
    local start_pos=3
    if key_pai and key_pai[1] then
        start_pos=key_pai[1]+1
    end
    local result
    local package=function (pai_map,type,pai,use_info)
                    local cp_list=self:get_cp_list_by_useInfo(pai_map,use_info,game_type)
                    local lazi_num=0
                    if cp_list.lz then
                        lazi_num=#cp_list.lz
                    end
                    local nor_list=nor_ddz_base_lib.merge_nor_and_lz(cp_list)
                    local show_list=nor_ddz_base_lib.sort_pai_for_show(nor_list,type,pai,use_info.lz)
                    result={
                              type=type,
                              cp_list=cp_list,
                              show_list=show_list,
                              merge_cp_list=nor_ddz_base_lib.merge_nor_and_lz(cp_list),
                              lazi_num=lazi_num,
                              pai=pai
                            }
            end

    if  appointType==1 then
        --单牌
        local type,pai,use_info=get_dpOrDz_combination(pai_type_map,lz_num,lz_type,start_pos,{},1)
        if type then
            package(pai_id_map,type,pai,use_info)
        end
    elseif appointType==2 then
        --对子
        local type,pai,use_info=get_dpOrDz_combination(pai_type_map,lz_num,lz_type,start_pos,{},2)
        if type then
            package(pai_id_map,type,pai,use_info)
        end
    elseif appointType==3 then
        --三不带
        local type,pai,use_info=get_3dn_combination(pai_type_map,lz_num,lz_type,start_pos,{},nil,self)
        if type then
            package(pai_id_map,type,pai,use_info)
        end
    elseif appointType==4 then
        --三带一
        local type,pai,use_info=get_3dn_combination(pai_type_map,lz_num,lz_type,start_pos,{},1,self)
        if type then
            package(pai_id_map,type,pai,use_info)
        end
    elseif appointType==5 then
        --三带二
        local type,pai,use_info=get_3dn_combination(pai_type_map,lz_num,lz_type,start_pos,{},2,self)
        if type then
            package(pai_id_map,type,pai,use_info)
        end
    elseif appointType==6 then
        --顺子
        local type,pai,use_info=get_shunzi_combination(pai_type_map,lz_num,lz_type,start_pos,key_pai[2]-key_pai[1]+1)
        if type then
            package(pai_id_map,type,pai,use_info)
        end
    elseif appointType==7 then 
        --连队
        local type,pai,use_info=get_liandui_combination(pai_type_map,lz_num,lz_type,start_pos,key_pai[2]-key_pai[1]+1)
        if type then
            package(pai_id_map,type,pai,use_info)
        end 
    elseif appointType==8 then
        --四带2
        local type,pai,use_info=get_4dn_combination(pai_type_map,lz_num,lz_type,start_pos,{},1,self)
        if type then
            package(pai_id_map,type,pai,use_info)
        end
    elseif appointType==9 then
        --四带2对
        local type,pai,use_info=get_4dn_combination(pai_type_map,lz_num,lz_type,start_pos,{},2,self)
        if type then
            package(pai_id_map,type,pai,use_info)
        end
    elseif appointType==10 then
        --飞机带单牌
        local type,pai,use_info=get_feijid1_combination(pai_type_map,lz_num,lz_type,start_pos,key_pai[2]-key_pai[1]+1)
        if type then
            package(pai_id_map,type,pai,use_info)
        end 
    elseif appointType==11 then
        --飞机带对子
        local type,pai,use_info=get_feijid2_combination(pai_type_map,lz_num,lz_type,start_pos,key_pai[2]-key_pai[1]+1,self)
        if type then
            package(pai_id_map,type,pai,use_info)
        end 
    elseif appointType==12 then
        --飞机不带
        local type,pai,use_info=get_feiji_combination(pai_type_map,lz_num,lz_type,start_pos,key_pai[2]-key_pai[1]+1)
        if type then
            package(pai_id_map,type,pai,use_info)
        end
    elseif appointType==13 then
        --真炸弹
        local type,pai,use_info=get_realZhadan_combination(pai_type_map,lz_num,lz_type,start_pos,{})
        if type then
            package(pai_id_map,type,pai,use_info)
        end
    elseif appointType==15 then 
        --假炸弹
        local type,pai,use_info=get_jiaZhadan_combination(pai_type_map,lz_num,lz_type,start_pos,{})
        if type then
            package(pai_id_map,type,pai,use_info)
        end
    elseif appointType==30 then 
        --三带二 单双皆可
        local type,pai,use_info=get_3dn_combination(pai_type_map,lz_num,lz_type,start_pos,{},2,self)
        if type then
            package(pai_id_map,type,pai,use_info)
        else
            local type,pai,use_info=get_4dn_combination(pai_type_map,lz_num,lz_type,start_pos,{},1)
            if type then
                package(pai_id_map,type,pai,use_info)
            end
        end
    elseif appointType==31 then 
        --四带三 
        local type,pai,use_info=get_4dn_combination(pai_type_map,lz_num,lz_type,start_pos,{},3,self)
        if type then
            package(pai_id_map,type,pai,use_info)
        end
    elseif appointType==32 then 
        --飞机带双数，单双皆可 
        local type,pai,use_info=get_feijid2_combination(pai_type_map,lz_num,lz_type,start_pos,key_pai[2]-key_pai[1]+1,self)
        if type then
            package(pai_id_map,type,pai,use_info)
        end    
    end
    dump(result,"===============result")
    if not result and appointType~=13 then 
        local type,pai,use_info=get_realZhadan_combination(pai_type_map,lz_num,lz_type,3,{})
        if type then
            package(pai_id_map,type,pai,use_info)
        end      
    end
    if not result then 
        --王炸
        local type,pai,use_info=get_wazha_combination(pai_type_map,lz_num,lz_type)
        if type then
            package(pai_id_map,type,pai,use_info)
        end
    end
    if not result or not self.kaiguan[result.type] then
        result={type=0}
    end
    dump(result,"===============result")

    return result
end

--###_test 为修改
function nor_ddz_algorithm:get_cp_list(_c_hash, _type, _pai)
    if _type == 0 then
        return nil
    end
    local _list = {}

    if _type < 4 then
        nor_ddz_base_lib.get_pai_list_by_type(_c_hash, _pai[1], _type, _list)
    elseif _type == 4 then
        nor_ddz_base_lib.get_pai_list_by_type(_c_hash, _pai[1], 3, _list)
        nor_ddz_base_lib.get_pai_list_by_type(_c_hash, _pai[2], 1, _list)
    elseif _type == 5 then
        nor_ddz_base_lib.get_pai_list_by_type(_c_hash, _pai[1], 3, _list)
        nor_ddz_base_lib.get_pai_list_by_type(_c_hash, _pai[2], 2, _list)
    elseif _type == 13 then
        nor_ddz_base_lib.get_pai_list_by_type(_c_hash, _pai[1], 4, _list)
    elseif _type == 14 then
        _list[1] = 53
        _list[2] = 54
    elseif _type == 6 then
        for _i = _pai[1], _pai[2] do
            nor_ddz_base_lib.get_pai_list_by_type(_c_hash, _i, 1, _list)
        end
    elseif _type == 7 then
        for _i = _pai[1], _pai[2] do
            nor_ddz_base_lib.get_pai_list_by_type(_c_hash, _i, 2, _list)
        end
    elseif _type == 8 then
        nor_ddz_base_lib.get_pai_list_by_type(_c_hash, _pai[1], 4, _list)
        if _pai[2] ~= _pai[3] then
            nor_ddz_base_lib.get_pai_list_by_type(_c_hash, _pai[2], 1, _list)
            nor_ddz_base_lib.get_pai_list_by_type(_c_hash, _pai[3], 1, _list)
        else
            nor_ddz_base_lib.get_pai_list_by_type(_c_hash, _pai[2], 2, _list)
        end
    elseif _type == 9 then
        nor_ddz_base_lib.get_pai_list_by_type(_c_hash, _pai[1], 4, _list)
        nor_ddz_base_lib.get_pai_list_by_type(_c_hash, _pai[2], 2, _list)
        nor_ddz_base_lib.get_pai_list_by_type(_c_hash, _pai[3], 2, _list)
    elseif _type == 10 then
        for _i = _pai[1], _pai[2] do
            nor_ddz_base_lib.get_pai_list_by_type(_c_hash, _i, 3, _list)
        end
        local _count = {}
        for _i = 3, 3 + _pai[2] - _pai[1] do
            _count[_pai[_i]] = _count[_pai[_i]] or 0
            _count[_pai[_i]] = _count[_pai[_i]] + 1
        end
        for _id, _num in pairs(_count) do
            nor_ddz_base_lib.get_pai_list_by_type(_c_hash, _id, _num, _list)
        end
    elseif _type == 11 then
        for _i = _pai[1], _pai[2] do
            nor_ddz_base_lib.get_pai_list_by_type(_c_hash, _i, 3, _list)
        end
        for _i = 3, 3 + _pai[2] - _pai[1] do
            nor_ddz_base_lib.get_pai_list_by_type(_c_hash, _pai[_i], 2, _list)
        end
    elseif _type == 12 then
        for _i = _pai[1], _pai[2] do
            nor_ddz_base_lib.get_pai_list_by_type(_c_hash, _i, 3, _list)
        end
    end
    return _list
end

--检测出的牌是否合法 他人出的牌  我出的牌
function nor_ddz_algorithm:check_chupai_safe(_act_list, pai_list,lz_type,_remain_pai_count)
    local _is_must=nor_ddz_base_lib.is_must_chupai(_act_list)

    if not pai_list or #pai_list==0 then
        print("<color=red>选牌张</color>")
        return false
    end
    if _is_must then 
        local all = self:get_all_combination(pai_list,lz_type)

        if all then
            for _type,v in pairs(all) do
                if not self.kaiguan[_type] then
                    print("_type:%d,_remain_pai_count:%d",_type,_remain_pai_count)
                    -- 即便不允许三不带 最后三张也可以出
                    if (_type==3 and _remain_pai_count == 3)
                        or (_type == 4 and _remain_pai_count == 4)
                        or (_type == 5 and _remain_pai_count == 5)
                        or (_type == 8 and _remain_pai_count == 6)
                        or (_type == 10 and _remain_pai_count == #pai_list)
                        or (_type == 12 and _remain_pai_count == #pai_list)
                        then
                        -- 最后一手允许
                    else
                        all[_type]=nil
                    end
                end
            end
            if not next(all) then
                all=nil
            end 
        end
        dump(all,"dump----------all--------in check_chupai_safe")
        if not all then
            print("<color=red>首次失败</color>")
            return false
        end
        return true,all
    end
    local _pos=nor_ddz_base_lib.get_real_chupai_pos_by_act(_act_list)
    print("<color=red>ddddddddddddddddddd</color>")
    dump(_act_list)
    dump(_pos)
    local act=_act_list[_pos]
    local _type = act.type
    local _pai=act.pai

    --上个人出的王炸
    if _type == 14 then
        return false
    end
    local all = self:get_all_combination(pai_list,lz_type,_type,_pai)
    if not all then
        return false
    end
    return true,all
end

function nor_ddz_algorithm:choose_by_type(pai_id_map,pai_type_map,lz_num,lz_type,appointType,key_pai)
    --dump(pai_id_map,"pai_id_map")
    --dump(pai_type_map,"pai_type_map")
    --dump(key_pai,"key_pai")  
    local start_pos=3
    if key_pai and key_pai[1] then
        start_pos=key_pai[1]
    end
    local result
    local package=function (pai_map,type,pai,use_info)
                    local cp_list=self:get_cp_list_by_useInfo(pai_map,use_info,game_type)
                    local lazi_num=0
                    if cp_list.lz then
                        lazi_num=#cp_list.lz
                    end
                    local nor_list=nor_ddz_base_lib.merge_nor_and_lz(cp_list)
                    local show_list=nor_ddz_base_lib.sort_pai_for_show(nor_list,type,pai,use_info.lz)
                    result={
                              type=type,
                              cp_list=cp_list,
                              show_list=show_list,
                              merge_cp_list=nor_ddz_base_lib.merge_nor_and_lz(cp_list),
                              lazi_num=lazi_num,
                              pai=pai
                            }
            end

    if  appointType==1 then
        --单牌
        local type,pai,use_info=get_dpOrDz_combination(pai_type_map,lz_num,lz_type,start_pos,{},1)
        if type then
            package(pai_id_map,type,pai,use_info)
        end
    elseif appointType==2 then
        --对子
        local type,pai,use_info=get_dpOrDz_combination(pai_type_map,lz_num,lz_type,start_pos,{},2)
        if type then
            package(pai_id_map,type,pai,use_info)
        end
    elseif appointType==3 then
        --三不带
        local type,pai,use_info=get_3dn_combination(pai_type_map,lz_num,lz_type,start_pos,{},nil,self)
        if type then
            package(pai_id_map,type,pai,use_info)
        end
    elseif appointType==4 then
        --三带一
        local type,pai,use_info=get_3dn_combination(pai_type_map,lz_num,lz_type,start_pos,{},1,self)
        if type then
            package(pai_id_map,type,pai,use_info)
        end
    elseif appointType==5 then
        --三带二
        local type,pai,use_info=get_3dn_combination(pai_type_map,lz_num,lz_type,start_pos,{},2,self)
        if type then
            package(pai_id_map,type,pai,use_info)
        end
    elseif appointType==6 then
        --顺子
        local type,pai,use_info=get_shunzi_combination(pai_type_map,lz_num,lz_type,start_pos,key_pai[2]-key_pai[1]+1)
        if type then
            package(pai_id_map,type,pai,use_info)
        end
    elseif appointType==7 then 
        --连队
        local type,pai,use_info=get_liandui_combination(pai_type_map,lz_num,lz_type,start_pos,key_pai[2]-key_pai[1]+1)
        if type then
            package(pai_id_map,type,pai,use_info)
        end 
    elseif appointType==8 then
        --四带2
        local type,pai,use_info=get_4dn_combination(pai_type_map,lz_num,lz_type,start_pos,{},1,self)
        if type then
            package(pai_id_map,type,pai,use_info)
        end
    elseif appointType==9 then
        --四带2对
        local type,pai,use_info=get_4dn_combination(pai_type_map,lz_num,lz_type,start_pos,{},2,self)
        if type then
            package(pai_id_map,type,pai,use_info)
        end
    elseif appointType==10 then
        --飞机带单牌
        local type,pai,use_info=get_feijid1_combination(pai_type_map,lz_num,lz_type,start_pos,key_pai[2]-key_pai[1]+1)
        if type then
            package(pai_id_map,type,pai,use_info)
        end 
    elseif appointType==11 then
        --飞机带对子
        local type,pai,use_info=get_feijid2_combination(pai_type_map,lz_num,lz_type,start_pos,key_pai[2]-key_pai[1]+1,self)
        if type then
            package(pai_id_map,type,pai,use_info)
        end 
    elseif appointType==12 then
        --飞机不带
        local type,pai,use_info=get_feiji_combination(pai_type_map,lz_num,lz_type,start_pos,key_pai[2]-key_pai[1]+1)
        if type then
            package(pai_id_map,type,pai,use_info)
        end
    elseif appointType==13 then
        --真炸弹
        local type,pai,use_info=get_realZhadan_combination(pai_type_map,lz_num,lz_type,start_pos,{})
        if type then
            package(pai_id_map,type,pai,use_info)
        end
    elseif appointType==15 then 
        --假炸弹
        local type,pai,use_info=get_jiaZhadan_combination(pai_type_map,lz_num,lz_type,start_pos,{})
        if type then
            package(pai_id_map,type,pai,use_info)
        end
    elseif appointType==30 then 
        --三带二 单双皆可
        local type,pai,use_info=get_3dn_combination(pai_type_map,lz_num,lz_type,start_pos,{},2,self)
        if type then
            package(pai_id_map,type,pai,use_info)
        else
            local type,pai,use_info=get_4dn_combination(pai_type_map,lz_num,lz_type,start_pos,{},1)
            if type then
                package(pai_id_map,type,pai,use_info)
            end
        end
    elseif appointType==31 then 
        --四带三 
        local type,pai,use_info=get_4dn_combination(pai_type_map,lz_num,lz_type,start_pos,{},3,self)
        if type then
            package(pai_id_map,type,pai,use_info)
        end
    elseif appointType==32 then 
        print("enter",start_pos,key_pai[2]-key_pai[1]+1)
        --飞机带双数，单双皆可 
        local type,pai,use_info=get_feijid2_combination(pai_type_map,lz_num,lz_type,start_pos,key_pai[2]-key_pai[1]+1,self)
        if type then
            package(pai_id_map,type,pai,use_info)
        end    
    end
    --dump(result,"===============result")
    return result
end

function nor_ddz_algorithm:auto_choose_by_num(pai_id_map, pai_type_map)
    local result = {}
    local lx_end = function(i,k,pai_type_map)
        local end_pos
        if k==6 then
            if not pai_type_map[i] or pai_type_map[i] < 1 then
                return nil
            end
            for id=i+1,14 do
                if pai_type_map[id] and pai_type_map[id]>=1 then
                    end_pos = id
                else
                    break
                end
            end
            if end_pos and end_pos-i+1 < 5 then
                return nil
            end
        elseif k==7 then
            if not pai_type_map[i] or pai_type_map[i] < 2 then
                return nil
            end
            for id=i+1,14 do
                if pai_type_map[id] and pai_type_map[id]>=2 then
                    end_pos = id
                else
                    break
                end
            end
            if end_pos and end_pos-i+1 < 2 then
                return nil
            end
        elseif k==10 or k==11 or k==12 or k==32 then
            if not pai_type_map[i] or pai_type_map[i] < 3 then
                return nil
            end
            for id=i+1,14 do
                if pai_type_map[id] and pai_type_map[id]>=3 then
                    end_pos = id
                else
                    break
                end
            end
            if end_pos and end_pos-i+1 < 2 then
                return nil
            end
        end
        return end_pos
    end

    for k,v in pairs(pai_type) do
        if v>0 then
            local start = 3
            while start <= 15 do
                if pai_type_map[start] and pai_type_map[start] > 0 then
                    local end_postion     
                    local temp
                    if k==6 or k==7 or k==10 or k==11 or k==12 or k==32 then
                        while true do
                            end_postion = lx_end(start,k,pai_type_map)
                            --print("----------------start",start,end_postion)
                            if start < 15 and not end_postion then
                                start = start + 1
                            else
                                break
                            end
                        end
                        if end_postion then
                            temp = nor_ddz_algorithm:choose_by_type(basefunc.deepcopy(pai_id_map),basefunc.deepcopy(pai_type_map),0,nil,k,{start,end_postion})
                        end
                    else
                        temp = nor_ddz_algorithm:choose_by_type(basefunc.deepcopy(pai_id_map),basefunc.deepcopy(pai_type_map),0,nil,k,{start})
                    end
                    
                    if temp and (self.kaiguan[temp.type] or basefunc.key_count(pai_id_map) == #temp.cp_list.nor and (temp.type == 3 or temp.type == 4 or temp.type == 8 or temp.type == 10 or temp.type == 12)) then
                        --不破炸弹
                        -- for key,pai_id in pairs(temp.cp_list.nor) do
                        -- end
                        result[#result + 1] = temp
                        start = temp.pai[1] + 1
                    else
                        break
                    end
                    --print("xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx")

                else
                    start = start + 1
                end
            end
        end
        --print("===========================================================")
    end

    return result
end


function nor_ddz_algorithm:cp_hint_baopei(type, pai, _my_pai_list,self_type,self_pai)
    local pai_id_map,pai_type_map,lz_num=nor_ddz_base_lib.get_map_and_kickLZ_by_list(_my_pai_list,0) 

    local package=function (pai_map,type,pai,use_info)
            local cp_list=self:get_cp_list_by_useInfo(pai_map,use_info,game_type)
            local lazi_num=0
            if cp_list.lz then
                lazi_num=#cp_list.lz
            end
            local nor_list=nor_ddz_base_lib.merge_nor_and_lz(cp_list)
            local show_list=nor_ddz_base_lib.sort_pai_for_show(nor_list,type,pai,use_info.lz)
            return {
                      type=type,
                      cp_list=cp_list,
                      show_list=show_list,
                      merge_cp_list=nor_ddz_base_lib.merge_nor_and_lz(cp_list),
                      lazi_num=lazi_num,
                      pai=pai
                    }
    end

    local result = {}
    local temp_list = {}
    local temp_pai = pai[1]+1
    while temp_pai<=15 do
        local c_t_1,u_n_1,u_lz_n_1 = choose_paiType_by_num(pai_type_map,0,0,temp_pai,1,{})
        if c_t_1 and (not self_pai or self_pai[1] > c_t_1) then
            temp_list[#temp_list + 1] = package(pai_id_map,1,{c_t_1},{nor={[c_t_1]=u_n_1},lz={[c_t_1]=u_lz_n_1}})
            temp_pai = c_t_1+1
        else
            temp_pai = temp_pai + 1
        end
    end
    table.sort(temp_list,function(a,b)
        return a.pai[1]>b.pai[1]
    end)
    temp_pai = pai[1]+1
    while temp_pai<=15 do
        local c_t_1,u_n_1,u_lz_n_1 = choose_paiType_by_num(pai_type_map,0,0,temp_pai,4,{})
        if c_t_1 then
            temp_list[#temp_list + 1] = package(pai_id_map,13,{c_t_1},{nor={[c_t_1]=u_n_1},lz={[c_t_1]=u_lz_n_1}})
            temp_pai = c_t_1+1
        else
            temp_pai = temp_pai + 1
        end
    end

    if temp_list and temp_list[1] then
        return temp_list[1]
    end

    return {type = 0}
end

--_other_cp_list:其他玩家的出牌，_my_pai_list:我手里的牌
function nor_ddz_algorithm:cp_hint(type, pai, _my_pai_list,lz_type)
    local pai_id_map,pai_type_map,lz_num=nor_ddz_base_lib.get_map_and_kickLZ_by_list(_my_pai_list,lz_type) 
    local result=nil
    print("type",type)
    if type and type>0 then
        print("enter ")
        result = self:auto_choose_by_type(pai_id_map,pai_type_map,lz_num,lz_type,type,pai)
    else
        
        -- local is_have_zhadan=self:check_is_pai_is_have_zhadan(_my_pai_list,lz_type)
        -- local all=self:get_all_combination(_my_pai_list,lz_type)
        -- dump(all,"xxxxxxxxxxxxxx----------------------all-----------")

        -- local pai_data=self:choose_pai_by_all_and_zhadanyouxian(all,is_have_zhadan,#_my_pai_list)
        -- dump(pai_data,"xxxxxxxxxx=====================pai_data=========")
        -- if pai_data then
        --     return pai_data
        -- end 

        --result = self:auto_choose_by_type(pai_id_map,pai_type_map,lz_num,lz_type,0,nil)
        result = self:auto_choose_by_num(pai_id_map, pai_type_map)
        
        --首出不能拆炸弹，能不能有炸弹？
        -- for k,data in ipairs(result)do
        --     if data.type==6 or data.type==7 or data.type==10 or data.type==11 or data.type==12 or data.type==32 then
        --         for t=data.pai[1],data.pai[2] do
        --             if pai_type_map[t] == 4 then
        --                 result[k] = nil
        --             end
        --         end
        --         for i=3,#data.pai do
        --             if data.pai[i] and pai_type_map[data.pai[i]] == 4 then
        --                 result[k] = nil
        --             end
        --         end
        --     else
        --         for i=1,#data.pai do
        --             if data.pai[i] and pai_type_map[data.pai[i]] == 4 then
        --                 result[k] = nil
        --             end
        --         end
        --     end
        -- end



        dump(result,"xxxxxxxxxxxxxx----------------------auto_choose_by_num-----------")
    end
    dump(result,"xxxxxxxxxxxxxx----------------------cp_hint-----------")

    return result
end
--检测自己是否有出牌的能力  0有资格，1没资格，2完全没资格（对方王炸） 对方所出牌的类型，出牌类型类型对应的牌，我的牌的hash
function nor_ddz_algorithm:check_cp_capacity_by_pailist(_act_list,pai_list,lz_type)
    local pai_id_map,pai_type_map,lz_num=nor_ddz_base_lib.get_map_and_kickLZ_by_list(pai_list,lz_type) 
    local _other_type=0
    local _other_pai
    local _pos=nor_ddz_base_lib.get_real_chupai_pos_by_act(_act_list)
    if _pos then
        local _act=_act_list[_pos]
        self:get_cpInfo_by_action(_act)
        _other_type=_act.type
        _other_pai=_act.pai
    end

    if _other_type==0 then
        return 0
    elseif _other_type==14 then 
        return 2
    else
        --如果我有双王
        if  pai_type_map[16]==1 and pai_type_map[17]==1 then
            return 0
        end
        --拥有各种数量的牌的统计
        local _type_num={0,0,0,0}
        for _k,_v in pairs(pai_type_map) do
            if _v>0 then
                _type_num[_v]=_type_num[_v]+1
            end
        end
        dump(_type_num,"phash")
        --我有炸弹 且对方没出炸弹
        if _other_type~=13 and _other_type~=15 and  (_type_num[4]>0 or lz_num==4 or (lz_num>0 and _type_num[3]>0) or (lz_num>1 and _type_num[2]>0) or (lz_num>2 and _type_num[1]>0)) then
            return 0
        end
        if _other_type==15 and (_type_num[4]>0 or lz_num==4) then
            return 0
        end
        local res=self:auto_choose_by_type(pai_id_map,pai_type_map,lz_num,lz_type,_other_type,_other_pai)
        if res and res.type>0 then 
            return 0
        end
        return 1    
    end
end

local function choose_pai_by_mutilated(_cp_list,_my_paiType_map,_kaiguan)

    --求出数量最多的牌的数量
    local cp_pai_map={}
    local max_num=0
    local max_pai_type=3
    local min_pai_type=17
    local lz_num=0
    local cp_type_list={}
    --牌的种类计数
    local all_type_count=0
    for _,v in pairs(_cp_list) do
        if v<55 then
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
        else
            lz_num=lz_num+1
        end
    end
    if lz_num>0 then
        return nil
    end
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
                if cp_pai_map[key[2]]==2 and _kaiguan and _kaiguan[5] then
                    return {[key[1]]=3,[key[2]]=2}
                else
                    return {[key[1]]=3,[key[2]]=1}
                end
                
            end
        end
        return nil
    end
    if #_cp_list==1 then
        local _pai=pai_map[_cp_list[1]]
        if (_pai==16 or _pai==17) and _my_paiType_map[16]==1 and _my_paiType_map[17]==1 then
            return {[16]=1,[17]=1}
        end
        if _my_paiType_map[_pai] and _my_paiType_map[_pai]>2 then
            return {[_pai]=_my_paiType_map[_pai]}
        end
    --查看是否可能是顺子
    elseif max_num==1 and max_pai_type<15 and all_type_count>1 then
        local s=min_pai_type
        local e=max_pai_type
        --玩家提供的关键牌 必须连续才能继续往下走
        for k=s,e do
            if not cp_pai_map[k] then
                return  maybe_3dn()  
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
            local map={}
            for k=s,e do
                map[k]=1
            end
            return map
        end
        return  maybe_3dn()
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
        e=min_pai_type+1
        if e<max_pai_type then
            e=max_pai_type
        elseif e>14 then
            e=14
        end

        local flag=false
        if e-s>=1 then
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
            s=max_pai_type-1
            e=max_pai_type
            if s>min_pai_type then
                s=min_pai_type
            end
            if s<3 then
                s=3
            end

            if e-s>=1 then
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
            
            local map={}
            for k=s,e do
                map[k]=2
            end
            return map
        end
        return  maybe_3dn()
    --判断是否为飞机
    elseif max_num<=3 and  max_pai_type<15 and all_type_count>1 then
        local s=min_pai_type
        local e=max_pai_type
        local flag=true
        for k=s,e do
            if not (_my_paiType_map[k] and _my_paiType_map[k]>2) then
                flag=false
                break    
            end
        end
        if flag then
            local map={}
            for k=s,e do
                map[k]=3
            end
            return map
        end
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
        local lz_num=0

        for _,v in pairs(_cp_list) do
            if v<55 then
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
            else
                lz_num=lz_num+1
            end
        end
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
                    if key[1]>key_pai[1] then
                        if appointType==4 then
                            return {[key[1]]=3,[key[2]]=1}
                        else
                            if _my_paiType_map[key[2]]>1 then
                                return {[key[1]]=3,[key[2]]=2}
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
--智能补全
-- _act_list操作序列 _cp_list我的已经选好的牌  _my_pai_list
--算法思路   只对已选牌数量在3张以下进行智能补全 只提示核心牌（如 三代一  只智能补全 三 的部分）
--根据对手出牌类型 选出自己手中所有可能出牌的组合 如果已选牌全部在组合里 那么进行智能补全 
--###_test 
function nor_ddz_algorithm:intelligent_completion(_other_type,_other_pai,_cp_list,_my_pai_list,lz_type,is_frist_tanchu)

    local pai_id_map,pai_type_map,lz_num=nor_ddz_base_lib.get_map_and_kickLZ_by_list(_my_pai_list,lz_type) 

    local result=nil
  

    --当必须出牌时，只智能补全 炸弹 三带 对子 
    if _cp_list and #_cp_list>0 then
        local ic=basefunc.copy(_cp_list)
        --智能补全中必须要含有的牌的map
        local _must_have_map=nor_ddz_base_lib.list_to_map(ic)

        if _other_type==0 then
            local is_have_zhadan=self:check_is_pai_is_have_zhadan(_my_pai_list,lz_type)
            local all=self:get_all_combination(_my_pai_list,lz_type)

            local pai_data=self:choose_pai_by_all_and_zhadanyouxian(all,is_have_zhadan,#_my_pai_list)
            if pai_data then
                return nor_ddz_base_lib.lzlist_to_map(_my_pai_list,lz_type)
            end

            local res= choose_pai_by_mutilated(_cp_list,pai_type_map,self.kaiguan)
            if res then
                return res 
            end

            if is_frist_tanchu then
                local status,_map=self:intelligent_selection_card(_cp_list,_other_type,_other_pai,lz_type)
                if status then
                    return _map
                end
            end
            return nil
        else
         
            if _other_type>1 then

                local cp_hash=nor_ddz_base_lib.lzlist_to_map(_cp_list,lz_type)
                local res=choose_pai_by_mutilated_by_appointType(_cp_list,pai_type_map,_other_type,_other_pai)
                if res then
                    return res
                end
                while true do
                    local maybe = self:auto_choose_by_type(pai_id_map,pai_type_map,lz_num,lz_type,_other_type,_other_pai)
                    if not maybe or maybe.type==0 then
                        break
                    end
                    local hash=nor_ddz_base_lib.lzlist_to_map(maybe.show_list,lz_type)

                    local flag=true
                    for key,v in pairs(cp_hash) do
                        if not hash[key] or hash[key]<v then
                            flag=false
                            break
                        end 
                    end
                    if flag then
                        return hash
                    end
                    _other_type=maybe.type
                    _other_pai=maybe.pai
                end
                if is_frist_tanchu then
                    local status,_map=self:intelligent_selection_card(_cp_list,_other_type,_other_pai,lz_type)
                    if status then
                        return _map
                    end
                end
            end
            return nil
        end     
    end
    return nil
end

--智能选牌  玩家一次性选好牌后 把多余智能弹回去  目前只支持连队和顺子
function nor_ddz_algorithm:intelligent_selection_card(_cp_list,_other_type,_other_pai,lz_type)
    --是否包含二或者王 或者癞子
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
            local _type,_pai=get_liandui_combination(_pai_map,lz_num,lz_type,start_point,t_count)
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
            local _type,_pai=get_shunzi_combination(_pai_map,lz_num,lz_type,start_point,t_count)
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
            _pai_map[_t]=count
            
        end
        return _pai_map
    end
    local pai_id_map,pai_type_map,lz_num=nor_ddz_base_lib.get_map_and_kickLZ_by_list(_cp_list,lz_type)
    if _cp_list and next(_cp_list) and #_cp_list>4  and lz_num<1 then
        local p_map=nor_ddz_base_lib.get_pai_typeHash_by_list(_cp_list)
        if _other_type==0 or not _other_type then
            _other_type=nil
            _other_pai =nil
        end
        local start_point
        if _other_pai and _other_pai[1] then
            start_point=_other_pai[1]+1
        end
        local _type,_pai=self:get_all_combination(_cp_list,lz_type,_other_type,_other_pai)
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

--[[
获得所有可能的牌型
参数：
    pai_list 非癞子牌的列表
    lz_num 癞子的数量
    lz_type 癞子的牌型
    appointType 指定类型
返回：
    返回所有可能的牌型组合，并按类型从大到小
        {
            type --牌类型
            [type]={
                    [1]={
                        pai  --这种type下的牌型分解
                        show_list    --牌列表 按客户端展示顺序排列
                        cp_list --与服务器通讯的格式  {nor={},lz={}}都是list
                    }
                }
        }

    nil 没有组合
--]]
function nor_ddz_algorithm:get_all_combination(pai_list,lz_type,appointType,key_pai)
    dump(pai_list,"<color=red>pai_list</color>")
    
    --参数不对
    if  not pai_list or type(pai_list)~="table" or #pai_list==0 then
        return nil
    end

    local start_pos=3
    if key_pai and key_pai[1] then
        start_pos=key_pai[1]+1
    end

    local all
    local temp = {}
    local type_flag = {}
    local _pai = nor_ddz_base_lib.sort_pai_by_amount(nor_ddz_base_lib.get_pai_typeHash_by_list(pai_list))
    local find_no_pai = function(pai)
        for i=1,#pai do
            type_flag[pai[i].type] = true
        end
        for k,v in pairs(pai) do
            if v.amount == 4 then
                for i=3,15 do
                    if not type_flag[i] then
                        temp[(v.type - 2) * 4] = (i - 2) * 4
                        type_flag[i] = true
                        break
                    end
                end
            else
                break
            end
        end
        for k,v in pairs(temp) do
            for i,p in pairs(pai_list) do
                if p == k then
                    pai_list[i] = v
                    break
                end
            end
        end
    end
    local count=#pai_list

    local pai_id_map,pai_type_map,lz_num=nor_ddz_base_lib.get_map_and_kickLZ_by_list(pai_list,lz_type)

    local package=function (pai_map,type,pai,use_info)
                if check_chupai_safe_by_type(type,pai,appointType,key_pai) then
                    all=all or {}
                    all[type]=all[type] or {}
                    local cp_list=self:get_cp_list_by_useInfo(pai_map,use_info)
                    local nor_list=nor_ddz_base_lib.merge_nor_and_lz(cp_list)
                    local show_list=nor_ddz_base_lib.sort_pai_for_show(nor_list,type,pai,use_info.lz)
                    all[type][#all[type]+1]={
                                          type=type,
                                          pai=pai,
                                          show_list=show_list,
                                          cp_list=cp_list,
                                        }
                end
            end
   
    --循环匹配情况
    local pipei_all=function (func,_s,_e,pai_type_map,lz_num,lz_type,_count)
        dump(pai_list,"pai_list enter1")
         --print("<color=red>func</color>",func)
         --dump(temp,"temp_start")
        local nc={}
        while _s<=_e do 
            dump(pai_list,"pai_list start")
            if func ~= get_4dn_combination and func ~= get_realZhadan_combination then
                find_no_pai(_pai)
                pai_id_map,pai_type_map,lz_num=nor_ddz_base_lib.get_map_and_kickLZ_by_list(pai_list,lz_type)
            end
            local type,pai,use_info
            if func == get_3dn_combination then
                type,pai,use_info=get_3dn_combination(pai_type_map,lz_num,lz_type,start_pos,nc,2,self)
            else
                type,pai,use_info=func(pai_type_map,lz_num,lz_type,_s,_count)
            end
            
            -- dump(pai_list,"pai_list")
            -- dump(temp,"temp")
            if pai then
                for k,v in pairs(pai) do
                    for i,p in pairs(temp) do
                        if v == pai_map[p] then
                            pai[k] = pai_map[i]
                            break
                        end
                    end
                end
            end
            
            for k,v in pairs(pai_list) do
                for i,p in pairs(temp) do
                    if v == p then
                        print("var",k,v,i,p)
                        pai_list[k] = i
                        break
                    end
                end
            end
            if use_info then
                for k,v in pairs(use_info["nor"]) do
                    for i,p in pairs(temp) do
                        if k == pai_map[p] then
                            use_info["nor"][k] = use_info["nor"][k] - 1

                            if use_info["nor"][k] == 0 then
                                use_info["nor"][k] = nil
                            end
                            use_info["nor"][pai_map[i]] = (use_info["nor"][pai_map[i]] or 0) + 1
                            break
                        end
                    end
                end
            end
            
            dump(pai_list,"pai_list while end")
            pai_id_map,pai_type_map,lz_num=nor_ddz_base_lib.get_map_and_kickLZ_by_list(pai_list,lz_type)
            if type then
                --dump(pai_id_map,"pai_id_map")
                --dump(pai,"pai")
                --dump(use_info,"use_info")
                nc[pai[1]]=true
                dump(pai_id_map,"pai_id_map")
                dump(pai_type_map,"pai_type_map")
                package(pai_id_map,type,pai,use_info)
                
                _s=pai[1]+1
            else
                break
            end
        end
    end

    if count==1 and (not appointType or appointType==1) then
        --单牌
        local type,pai,use_info=get_dpOrDz_combination(pai_type_map,lz_num,lz_type,start_pos,{},1)
        if type then
            package(pai_id_map,type,pai,use_info)
        end
    elseif count==2 then
        if not appointType or appointType==2 then
            --对子
            local type,pai,use_info=get_dpOrDz_combination(pai_type_map,lz_num,lz_type,start_pos,{},2)
            if type then
                package(pai_id_map,type,pai,use_info)
            end
        end
        --王炸
        local type,pai,use_info=get_wazha_combination(pai_type_map,lz_num,lz_type)
        if type then
            package(pai_id_map,type,pai,use_info)
        end
    elseif count==3 and (not appointType or appointType==3) then
        --只能是三不带  
        local type,pai,use_info=get_3dn_combination(pai_type_map,lz_num,lz_type,start_pos,{}, nil, self)
        if type then
            package(pai_id_map,type,pai,use_info)
        end
    elseif count==4 then
        if not appointType or appointType==4 then
            --三带一
            local _s=start_pos
            local nc={}
            while _s<=15 do 
                local type,pai,use_info=get_3dn_combination(pai_type_map,lz_num,lz_type,start_pos,nc,1,self)
                if type then
                    nc[pai[1]]=true
                    package(pai_id_map,type,pai,use_info)
                    _s=pai[1]+1
                else
                    break
                end
            end
        end
        if count%2==0 and (not appointType or appointType==7) then
            local _c=count/2
            pipei_all(get_liandui_combination,start_pos,15-_c,pai_type_map,lz_num,lz_type,_c)
        end
        --真炸弹
        local _s=start_pos
        if not appointType or (appointType and appointType~=13) then
            _s=3
        end 
        dump(pai_type_map,"get_realZhadan_combination-------------pai_type_map")
        dump(pai_id_map,"get_realZhadan_combination-------------pai_id_map")
        local type,pai,use_info=get_realZhadan_combination(pai_type_map,lz_num,lz_type,_s,{})
        dump(pai_type_map,"get_realZhadan_combination-------------pai_type_map")
        dump(pai_id_map,"get_realZhadan_combination-------------pai_id_map")
        if type then
            package(pai_id_map,type,pai,use_info)
        end
    end
    --匹配四带二
    if count==6 and (not appointType or appointType==8) then
            local _s=start_pos
            local nc={}
            while _s<=15 do
                local type,pai,use_info=get_4dn_combination(pai_type_map,lz_num,lz_type,start_pos,nc,2,self)
                if type then
                    nc[pai[1]]=true
                    package(pai_id_map,type,pai,use_info)
                    _s=pai[1]+1
                else
                    break
                end
            end
    end
    --匹配四带三
    if count==7 and ((not appointType and self.kaiguan[31]) or appointType==31) then
            local _s=start_pos
            local nc={}
            while _s<=15 do
                local type,pai,use_info=get_4dn_combination(pai_type_map,lz_num,lz_type,start_pos,nc,3,self)
                if type then
                    nc[pai[1]]=true
                    package(pai_id_map,type,pai,use_info)
                    _s=pai[1]+1
                else
                    break
                end
            end
    end
    --dump(pai_list,"*******pai_list")

    --find_no_pai(_pai)
    --pai_id_map,pai_type_map,lz_num=nor_ddz_base_lib.get_map_and_kickLZ_by_list(pai_list,lz_type)

    if count>=5 then
        --匹配三带二
        if count==5 and ((not appointType and self.kaiguan[30]) or appointType==30)  then
            pipei_all(get_3dn_combination,start_pos,15,pai_type_map,lz_num,lz_type,count)
        end
        --匹配所有顺子
        if count<13 and (not appointType or appointType==6) then
            pipei_all(get_shunzi_combination,start_pos,15-count,pai_type_map,lz_num,lz_type,count)
        end
        --匹配所有连队
        if count%2==0 and (not appointType or appointType==7) then
            local _c=count/2
            pipei_all(get_liandui_combination,start_pos,15-_c,pai_type_map,lz_num,lz_type,_c)
        end
        --匹配飞机
        if count>=6 then
            --print("==",count,appointType,self.kaiguan[12])
            --飞机不带
            if count%3==0 and ((not appointType) or appointType==12) then
                local _c=count/3
                pipei_all(get_feiji_combination,start_pos,15-_c,pai_type_map,lz_num,lz_type,_c)
            end

            -- --飞机带对子
            if count%5==0 and ((not appointType and self.kaiguan[32])  or appointType==32) then
 
                local _c=count/5
                pipei_all(get_feijid2_combination,start_pos,15-_c,pai_type_map,lz_num,lz_type,_c)
            end

            -- if count%5==0 and ((not appointType and self.kaiguan[32])  or appointType==32) then
            --     local _c=count/5
            --     pipei_all(get_feijid2_combination,start_pos+1,15-_c,pai_type_map,lz_num,lz_type,_c)
            -- end
            --飞机带单牌
            if count%4==0 and ((not appointType) or appointType==10) then
                local _c=count/4
                pipei_all(get_feijid1_combination,start_pos,15-_c,pai_type_map,lz_num,lz_type,_c)
            end
        end 
    end 
    dump(pai_list,"<color=red>pai_list</color>")
    dump(all,"nor_ddz_algorithm:get_all_combination============all")
    return all   
end
--通过各种牌的使用信息 或者与服务器通讯的格式 cp_list
function nor_ddz_algorithm:get_cp_list_by_useInfo(pai_map,useInfo)
    local nor_list={}
    if useInfo.nor then
        for k,v in pairs(useInfo.nor) do
            if v>0 then
                nor_ddz_base_lib.get_pai_list_by_type(pai_map, k, v, nor_list)
            end
        end
    end
    local lz_list={}
    if useInfo.lz then
        for k,v in pairs(useInfo.lz) do
            if v>0 then
                for i=1,v do
                    lz_list[#lz_list+1]=pai_to_endId_map[k]
                end
            end
        end
    end
    if #nor_list==0 then
        nor_list=nil
    end
    if #lz_list==0 then
        lz_list=nil
    end
    return {nor=nor_list,lz=lz_list}
end
--[[
根据 action 的 cp_list 获得全部信息
show_list
type
pai
--]]
function nor_ddz_algorithm:get_cpInfo_by_action(act)
    if not act or not act.cp_list  or (act.show_list and act.nor_list) then
        return 
    end
    local cp_list=act.cp_list
    local nor_list=act.nor_list or nor_ddz_base_lib.merge_nor_and_lz(cp_list)
    local cp_type =self:get_pai_type(nor_list,nor_ddz_base_lib.get_cp_list_useLZ_num(cp_list))
    local lz_map =nor_ddz_base_lib.get_pai_typeHash_by_list(cp_list.lz)
    local show_list=act.show_list or nor_ddz_base_lib.sort_pai_for_show(nor_list,cp_type.type,cp_type.pai,lz_map)
    act.nor_list=nor_list
    act.show_list=show_list
    act.pai=cp_type.pai
end
--检查是否是最后一手牌
function nor_ddz_algorithm:check_is_only_last_pai(_act_list,_my_pai_list,_lz_type)
    local _pos=nor_ddz_base_lib.get_real_chupai_pos_by_act(_act_list)
    local _other_type=nil
    local _other_pai=nil
    if _pos then
        self:get_cpInfo_by_action(_act_list[_pos].cp_list)
        _other_type=_act_list[_pos].type
        _other_pai=_act_list[_pos].pai
    end

    local is_have_zhadan=self:check_is_pai_is_have_zhadan(_my_pai_list,_lz_type)
    local all=self:get_all_combination(_my_pai_list,_lz_type,_other_type,_other_pai)

    return self:choose_pai_by_all_and_zhadanyouxian(all,is_have_zhadan,#_my_pai_list)
end
function nor_ddz_algorithm:check_is_pai_is_have_zhadan(_my_pai_list,_lz_type)
    local pai_id_map,pai_type_map,lz_num=nor_ddz_base_lib.get_map_and_kickLZ_by_list(_my_pai_list,_lz_type)
    local is_have_zhadan=nil
    for _,v in pairs(pai_type_map) do
        if v+lz_num>3 then
            is_have_zhadan=true
            break
        end
    end
    return is_have_zhadan
end
--有炸弹得到炸弹没炸弹返回最前的那一个
function nor_ddz_algorithm:choose_pai_by_all_and_zhadanyouxian(all,is_have_zhadan,pai_len)
    
    if not all then
        return nil 
    end
    if not is_have_zhadan then
        for _,v in pairs(all) do
            return v[1]
        end
    end
    for _type,v in pairs(all) do
        if _type>12 and _type<16 then
            return v[1]
        end
    end
end
-- _gametype : laizi  nor  斗地主的类型
function nor_ddz_algorithm:ctor(_kaiguan,_gametype)
    self.type=_gametype
    game_type = _gametype
    nor_ddz_base_lib.set_game_type(self.type)
    self.kaiguan=_kaiguan or KAIGUAN
end



-- local class=nor_ddz_algorithm.New(nil,"laizi")

-- local pai_list={24,23,25,26,27,29,30,33,34,35}
-- local pai_list={1,5,6,9,10,13,17,21,22}
-- -- dump(class:get_all_combination(pai_list,15,6,{3,7}))
-- local _cp_list={
--     37,
--     38,
--     40,
--     88,
--     2,
-- }

-- local _cp_list={
--     13,
--     14,
--     17,
-- }
-- local _my_pai_list={
--     13,
--     14,
--     17,
--     25,
--     26,
--     29,30,31,
--     33,
-- }
-- dump(class:intelligent_completion(0,nil,_cp_list,_my_pai_list,3,false))


-- local s,map=class:intelligent_selection_card(pai_list,nil,nil,12)
-- dump(map)



return nor_ddz_algorithm


















