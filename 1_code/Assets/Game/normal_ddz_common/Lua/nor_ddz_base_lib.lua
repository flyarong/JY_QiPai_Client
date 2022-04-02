-- package.path=package.path..";.Users.hewei.project.JyQipai_client.1_code.Assets.?.lua"
-- local basefunc = require "basefunc"
-- require "Game.Common.printfunc"
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
    -- 15：假炸弹

--]]
local nor_ddz_base_lib ={}
--key=牌类型  value=此类型的牌的张数，特殊牌（如：顺子）则是最少张数
nor_ddz_base_lib.pai_type = {
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
nor_ddz_base_lib.other_type = {
    jdz = 100,
    jiabei = 101
}
nor_ddz_base_lib.pai_map = {
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
--各类型的牌的起始id
nor_ddz_base_lib.pai_to_startId_map = {
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

--各类型的牌的结束id
nor_ddz_base_lib.pai_to_endId_map = {
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
    54
}
nor_ddz_base_lib.lz_id={
    0,
    0,
    60,  --3
    64,  --4
    68,  --5
    72,  --6
    76,  --7
    80,  --8
    84,  --9
    88,  --10
    92,  --11
    96,  --12
    100,  --13
    104,  --14
    108,  --15
}
nor_ddz_base_lib.lz_id_to_type={
    [60]=3,
    [61]=3,
    [62]=3,
    [63]=3,
    [64]=4,
    [65]=4,
    [66]=4,
    [67]=4,
    [68]=5,
    [69]=5,
    [70]=5,
    [71]=5,
    [72]=6,
    [73]=6,
    [74]=6,
    [75]=6,
    [76]=7,
    [77]=7,
    [78]=7,
    [79]=7,
    [80]=8,
    [81]=8,
    [82]=8,
    [83]=8,
    [84]=9,
    [85]=9,
    [86]=9,
    [87]=9,
    [88]=10,
    [89]=10,
    [90]=10,
    [91]=10,
    [92]=11,
    [93]=11,
    [94]=11,
    [95]=11,
    [96]=12,
    [97]=12,
    [98]=12,
    [99]=12,
    [100]=13,
    [101]=13,
    [102]=13,
    [103]=13,
    [104]=14,
    [105]=14,
    [106]=14,
    [107]=14,
    [108]=15,
    [109]=15,
    [110]=15,
    [111]=15, 
}
nor_ddz_base_lib.key_pai_num={1,2,3,3,3,1,2,4,4,3,3,3,4,2,}

nor_ddz_base_lib.KAIGUAN={
    [0]=true,
    [1]=true,
    [2]=true,
    [3]=true,
    [4]=true,
    [5]=true,
    [6]=true,
    [7]=true,
    [8]=true,
    [9]=true,
    [10]=true,
    [11]=true,
    [12]=true,
    [13]=true,
    [14]=true,
    [15]=true,
}
nor_ddz_base_lib.KAIGUAN_MLD={
    [0]=true,
    [1]=true,
    [2]=true,
    [3]=false,
    [4]=true,
    [5]=false,
    [6]=true,
    [7]=true,
    [8]=true,
    [9]=false,
    [10]=true,
    [11]=false,
    [12]=false,
    [13]=true,
    [14]=true,
    [15]=true,
}

local KAIGUAN=nor_ddz_base_lib.KAIGUAN
local pai_type=nor_ddz_base_lib.pai_type
local other_type=nor_ddz_base_lib.other_type
local pai_map=nor_ddz_base_lib.pai_map
local pai_to_startId_map=nor_ddz_base_lib.pai_to_startId_map
local pai_to_endId_map=nor_ddz_base_lib.pai_to_endId_map
local lz_id=nor_ddz_base_lib.lz_id
local lz_id_to_type=nor_ddz_base_lib.lz_id_to_type
--各种牌型的关键牌数量
local key_pai_num=nor_ddz_base_lib.key_pai_num

-- --统计牌的类型
function nor_ddz_base_lib.get_pai_typeHash_by_list(_pai_list)
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
function nor_ddz_base_lib.get_pai_typeHash(_pai)
    local _hash = {}
    for _id, _v in pairs(_pai) do
        if _v then
            _hash[pai_map[_id]] = _hash[pai_map[_id]] or 0
            _hash[pai_map[_id]] = _hash[pai_map[_id]] + 1
        end
    end
    return _hash
end
function nor_ddz_base_lib.get_pai_list_by_map(_map)
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
function nor_ddz_base_lib.sort_pai_by_amount(_pai_count)
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
--获得牌的list  牌的类型，数量
function nor_ddz_base_lib.get_pai_list_by_type(_pai_map, _type, _num, _list)
    _list = _list or {}
    if type(_num) == "number" and _num > 0 then
        for _i = pai_to_startId_map[_type], pai_to_startId_map[_type] + 3 do
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
end
function nor_ddz_base_lib.list_to_map(_list)
    if _list then
        local _map = {}
        for _, _id in ipairs(_list) do
            _map[_id] = _map[_id] or 0
            _map[_id]= _map[_id]+1
        end
        return _map
    end
    return nil
end
--从出牌序列中获得最近出牌的人的位置
function nor_ddz_base_lib.get_real_chupai_pos_by_act(_act_list)
    local _pos
    local _limit
    if nor_ddz_base_lib.game_type=="nor_ddz_er" then
        _pos=#_act_list
        _limit=_pos-1
    else
        _pos=#_act_list
        _limit=_pos-2 
    end

    if _limit<0 then 
        _limit=0
    end
    while _pos>_limit do
        if _act_list[_pos].type>0 and _act_list[_pos].type<16 then 
            break
        end
        _pos=_pos-1
    end
    if _pos==_limit then
        return nil
    end
    return _pos 

end

function nor_ddz_base_lib.is_must_chupai(_act_list)
    if nor_ddz_base_lib.game_type=="nor_ddz_er" then
        if #_act_list==0  or _act_list[#_act_list].type>=100 or _act_list[#_act_list].type==0 then 
            return true
        end
    else
        if #_act_list==0  or _act_list[#_act_list].type>=100 or ( #_act_list>1 and  _act_list[#_act_list].type==0 and _act_list[#_act_list-1].type==0) then 
            return true
        end
    end
    return false
end

--获得出牌中使用的癞子数量
function nor_ddz_base_lib.get_cp_list_useLZ_num(cp_list)
    local num=0
    if cp_list.lz then
        num=#cp_list.lz
    end
    return num
end
function nor_ddz_base_lib.get_paiType_sound(type,pai)
    if not type then
        type=0
    end
    --假炸弹和真炸弹音效一样
    if type==15 then
        type=13
    end
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
    local sound=prefix[type+1]
    if type==1 or type==2 then
        sound=sound..pai[1]
    end
    if not sound then
        print("<color=red>问题：没有对应的音效</color>")
        dump(type)
        dump(pai)
        if AppDefine.IsEDITOR() then
            HintPanel.Create(1, "问题：没有对应的音效!")
        end
        sound = "sod_game_but_buchu"
    end
    return sound
end
function nor_ddz_base_lib.getAllPaiCount()
    if nor_ddz_base_lib.game_type=="nor_ddz_er" then
        return {
            [1]=0,
            [2]=0,
            [3]=0,
            [4]=0,
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
    elseif nor_ddz_base_lib.game_type=="nor_pdk_nor" then
        return {
            [1]=0,
            [2]=0,
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
            [14]=3,
            [15]=1,
            [16]=0,
            [17]=0,
        }
    else
        return {
            [1]=0,
            [2]=0,
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
end
function nor_ddz_base_lib.jipaiqi(_cp_list,_jipaiqi,_laizi_type)
    local pai=nil
    if _cp_list then
        if _cp_list.nor then
            local k
            for _,v in ipairs(_cp_list.nor) do
                k=pai_map[v]
                _jipaiqi[k]=_jipaiqi[k]-1
            end
        end
        if _cp_list.lz then
            _jipaiqi[_laizi_type]=_jipaiqi[_laizi_type]-#_cp_list.lz
        end
    end
    return _jipaiqi
end

function nor_ddz_base_lib.get_pai_info(no)
    if no<55 then 
        local type=pai_map[no]
        local start=pai_to_startId_map[type]
        
        local color=no-start+1
        --1 红桃 黑桃  梅花  方片 
        return {type=type,color=color}
    else
        local type=lz_id_to_type[no]
        --5癞子
        return {type=type,color=5}    
    end
end
function nor_ddz_base_lib.lzlist_to_map(list,lz_type)
    local hash={} 
    local _pai
    for _,no in ipairs(list) do
        if no<60 then
            _pai=pai_map[no]
        else
            _pai=lz_type
        end
       
        hash[_pai]=hash[_pai] or 0
        hash[_pai]=hash[_pai]+1
        
    end 
    return hash
end
--如果一个序列里面的牌是癞子变化而来的 则将其转换为癞子序号
function nor_ddz_base_lib.list_convert_to_lz(list,lz_map)
    if lz_map then
        local lz_id_add={}
        for idx,v in ipairs(list) do
            local _v=pai_map[v]
            if lz_map[_v] and lz_map[_v]>0 then
                --变为lz对应的序号 保证lzID不重复
                local lzID=lz_id[_v]
                lz_id_add[lzID]=lz_id_add[lzID] or lzID

                list[idx]=lz_id_add[lzID]

                lz_id_add[lzID]=lz_id_add[lzID]+1

                lz_map[_v]=lz_map[_v]-1
            end
        end
    end
    return list
end
function nor_ddz_base_lib.norId_convert_to_lzId(list,lz_type)
    if lz_type and lz_type>0 then
        local s=pai_to_startId_map[lz_type]
        local e=pai_to_endId_map[lz_type]
        local _lz_id=lz_id[lz_type]
        if type(list)=="table" then
            local new_list={}
            for idx,v in ipairs(list) do
                if v<=e and v>=s then
                    new_list[#new_list+1]=_lz_id
                    --保证lzID不重复
                    _lz_id=_lz_id+1
                else
                    new_list[#new_list+1]=v
                end
            end
            return new_list
        else
            if list<=e and list>=s then
                return _lz_id
            end
            return list
        end
    end
    return list
end
function nor_ddz_base_lib.lzId_convert_to_norId(list,lz_type)
    if lz_type and lz_type>0 then
        local s=lz_id[lz_type]
        local e=s+3
        local _norId=pai_to_startId_map[lz_type]
        if type(list)=="table" then
            local new_list={}
            for idx,v in ipairs(list) do
                if  v>59 then
                    new_list[#new_list+1]=_norId
                    _norId=_norId+1
                else
                    new_list[#new_list+1]=v
                end
            end
            return new_list
        else
            if list>59 then
                return pai_to_endId_map[lz_type]
            end
            return list
        end
    end
    return list
end
function nor_ddz_base_lib.get_lzId(id)
    return lz_id[id]
end

--对牌进行排序得到客户端需要展示的序列
function nor_ddz_base_lib.sort_pai_for_show(cp_list,type,pai,lz_map)
    local list=basefunc.copy(cp_list)
    table.sort(list,function (a,b)
        if a>b then
            return true
        end
        return false
    end)
    if type then
        local flag=false
        local new_list={}
        local beifen_list={}
        if type==4 or type==5 or type==8 or type==9 then
            flag=true
            for idx,v in ipairs(list) do
                if pai_map[v]==pai[1] then
                    new_list[#new_list+1]=v
                else
                    beifen_list[#beifen_list+1]=v
                end
            end
        elseif type==10 or type==11 then
            flag=true
             for idx,v in ipairs(list) do
                if pai_map[v]>=pai[1] and pai_map[v]<=pai[2] then
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
            return nor_ddz_base_lib.list_convert_to_lz(new_list,lz_map) 
        end
    end
    return nor_ddz_base_lib.list_convert_to_lz(list,lz_map)
end
function nor_ddz_base_lib.get_map_and_kickLZ_by_list(pai_list,lz_type)
    local nor_list=nor_ddz_base_lib.lzId_convert_to_norId(pai_list,lz_type)
    local pai_id_map=nor_ddz_base_lib.list_to_map(nor_list)
    local pai_type_map=nor_ddz_base_lib.get_pai_typeHash_by_list(nor_list)
    local lz_num=pai_type_map[lz_type] or 0
        
    if not lz_type then
        print("<color=red>lz_typelz_type</color>")
    end
    pai_type_map[lz_type]=nil
    return pai_id_map,pai_type_map,lz_num
end
--将普通牌和癞子牌合并  参数 服务器通讯的格式 cp_list 并返回是否含有lz
function nor_ddz_base_lib.merge_nor_and_lz(cp_list)
    local list={}
    local is_have_lz=false
    if cp_list then
        if cp_list.nor then
            for _,v in ipairs(cp_list.nor) do
                list[#list+1]=v
            end
        end
        if cp_list.lz then
            for _,v in ipairs(cp_list.lz) do
                --癞子只能在1-52之间
                if v<1 or v>52 then
                    return false
                end
                list[#list+1]=v
                is_have_lz=true
            end
        end 
    end 
    return list,is_have_lz
end

function nor_ddz_base_lib.get_action_status(act)
    if act.type<100 then
        return "cp"
    elseif act.type==100 then
        return "jdz"
    elseif act.type==101 then 
        return "jiabei"
    end
end


function nor_ddz_base_lib.transform_seat(seatNum,s2cSeatNum,mySeatNum, maxP)
    maxP = maxP or 3
    if mySeatNum then
        seatNum[1]=mySeatNum
        s2cSeatNum[mySeatNum]=1
        for i=2,maxP do
            mySeatNum=mySeatNum+1
            if mySeatNum>maxP then
                mySeatNum=1
            end
            seatNum[i]=mySeatNum
            s2cSeatNum[mySeatNum]=i
        end
    end
end
local function nor_GetSettlementDetailedInfo(m_data)
    dump(m_data , "<color=yellow>--------------------- nor_GetSettlementDetailedInfo ------------------</color>")
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

        if nor_ddz_base_lib.game_type=="nor_ddz_er" then
            data.q_dizhu=m_data.er_qiang_dizhu_count+1  
            data.all= data.all* data.q_dizhu
        end


        return data
    end
    return nil
end
local function er_GetSettlementDetailedInfo(m_data)
    dump(m_data , "<color=yellow>--------------------- er_GetSettlementDetailedInfo ------------------</color>")
     if m_data and m_data.settlement_info then
        local s=m_data.settlement_info
        local data={}
        data.base= m_data.base_rate + m_data.init_rate
        data.q_dizhu = data.base 
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

        data.dizhu=1
        data.nongmin=1
        data.all= data.nongmin*data.dizhu*data.base


        return data
    end
    return nil
end
function nor_ddz_base_lib.GetSettlementDetailedInfo(m_data)
    print("<color=yellow>------------------------- GetSettlementDetailedInfo ---- </color>",nor_ddz_base_lib.game_type)
    if nor_ddz_base_lib.game_type=="nor_ddz_er" then
        return  er_GetSettlementDetailedInfo(m_data)
    else
        return  nor_GetSettlementDetailedInfo(m_data)
    end
end


function nor_ddz_base_lib.set_game_type(_g_type)
    nor_ddz_base_lib.game_type=_g_type
end

--是否必倒
function nor_ddz_base_lib.is_must_dao(_my_pai_list)
    local map=nor_ddz_base_lib.get_pai_typeHash_by_list(_my_pai_list)
    local wang=0
    local two=0
    if map[16]==1 then
        wang=wang+1
    end
    if map[17]==1 then
        wang=wang+1
    end
    if map[15] then
        two=map[15]
    end
    if wang==2 or wang+two>2 then
        return true
    end
    local zhadan=0
    for _,v in pairs(map) do
        if v==4 then
            zhadan=zhadan+1
        end
    end
    if zhadan>1 or zhadan+wang+two>2 then
        return true
    end
    return false
end
--是否必抓
function nor_ddz_base_lib.is_must_zhua(_my_pai_list)

    local map=nor_ddz_base_lib.get_pai_typeHash_by_list(_my_pai_list)
    local wang=0
    local two=0
    if map[16]==1 then
        wang=wang+1
    end
    if map[17]==1 then
        wang=wang+1
    end
    if map[15] then
        two=map[15]
    end
    if wang==2 or wang+two>2 then
        return true
    end
    local zhadan=0
    for _,v in pairs(map) do
        if v==4 then
            zhadan=zhadan+1
        end
    end
    if zhadan>1 or zhadan+wang+two>2 then
        return true
    end
    return false
end

return nor_ddz_base_lib























