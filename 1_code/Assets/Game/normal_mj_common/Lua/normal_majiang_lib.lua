--hewei test*******
-- package.path=package.path..";.Users.hewei.project.JyQipai_client.1_code.Assets.?.lua"
-- require "Game.Common.printfunc"
--hewei test*******


-- Author: hw
-- Date: 2018/3/20
-- 说明：麻将
local basefunc = require "Game.Common.basefunc"
local normal_majiang={}

--[[
	麻将的表示：

	11 ~ 19  : 筒
	21 ~ 29  : 条
	31 ~ 39  : 万

	基础胡牌类型（选其一，不能组合）
	ping_hu		平胡		x1
	qi_dui 		七对  	x4


	基础番型（可相互组合）
	qing_yi_se  清一色	x4
	da_dui_zi   大对子	x2
	dai_geng  	带根	x2 （2 根 x4 ，依次类推）

	特殊番型
	jin_gou_diao	金钩吊 x4
	dai_yao_jiu		带幺九 x4
	jiang_dui		将对 x8

--]]

local random = math.random
local floor = math.floor
local min = math.min
local fmod = math.fmod

normal_majiang.SEAT_COUNT = 4
local SEAT_COUNT = normal_majiang.SEAT_COUNT

-- 基础胡牌类型定义： 番型 -> 倍数
normal_majiang.HU_PAI_TYPES =
{
	ping_hu 		= 1,
	qi_dui 			= 4,
}


-- 基础胡牌类型定义： 番型 -> 番数
normal_majiang.MULTI_TYPES =
{
	-- 牌型
	qing_yi_se 		= 2,
	da_dui_zi 		= 1,
	qi_dui			= 2,
	long_qi_dui		= 3,

	dai_geng 		= 1,

	jiang_dui       = 3, --将对
	men_qing		= 1, --门清
	zhong_zhang		= 1, --中章
	jin_gou_diao    = 1, --金钩钓	
	yao_jiu	 		= 2, --幺九

	-- 其它：和胡牌方式相关的
	hai_di_ly 		= 1, -- 海底捞月 最后一张牌胡牌（自摸）
	hai_di_pao 		= 1, -- 海底炮  最后一张牌胡牌（被人点炮）
	tian_hu 		= 5, -- 天胡：庄家，第一次发完牌既胡牌
	di_hu	 		= 5, -- 地胡：非庄家第一次发完牌 既自摸或 被别人点炮
	gang_shang_hua  = 1, -- 杠上花：自己杠后补杠自摸
	gang_shang_pao  = 1, -- 杠上炮：别人杠后补杠点炮
	zimo            = 1, --自摸
	qiangganghu     = 1,  --抢杠胡 
}

-- 杠收的钱（番数）
normal_majiang.GANG_TYPES =
{
	zg = 1,
	wg = 0,
	ag = 1,
}
-- 游戏开关
local mj_kaiguan={
	qing_yi_se 		= true,
	da_dui_zi 		= true,
	qi_dui			= true,
	long_qi_dui		= true,
	--将对
	jiang_dui       = true,
	men_qing		= true,
	zhong_zhang		= true,
	jin_gou_diao    = true,
	yao_jiu	 		= true, 


	-- 其它：和胡牌方式相关的
	hai_di_ly 		= true, -- 海底捞月 最后一张牌胡牌（自摸）
	hai_di_pao 		= true, -- 海底炮  最后一张牌胡牌（被人点炮）
	tian_hu 		= true, -- 天胡：庄家，第一次发完牌既胡牌
	di_hu	 		= true, -- 地胡：非庄家第一次发完牌 既自摸或 被别人点炮
	gang_shang_hua  = true, -- 杠上花：自己杠后补杠自摸
	gang_shang_pao  = true, -- 杠上炮：别人杠后补杠点炮
	zimo            = true, -- 自摸
	qiangganghu     = true, -- 抢杠胡 
	zimo_jiafan     = true, -- 自摸加翻 
	zimo_jiadian     = true, -- 自摸加点 
}
--jiang 将牌的数量（对子）
--[[ list=
{
	type 1 将  2 大对子 3 连子
	pai_type 牌类型  若type==3 则为起始位置的牌 
}
--]]
local function compute_nor_hupai_info(pai_map,_s,all_num,jiang_num,list,list_pos,info)
	for s=_s,39 do
		if pai_map[s] and pai_map[s]>0 then
			--先取 （大对子）
			if pai_map[s]>2 then

				list[list_pos]=list[list_pos] or {}
				list[list_pos].type=2
				list[list_pos].pai_type=s

				if all_num-3==0 then
					if jiang_num==1 then
						info[#info+1]={jiang_num=jiang_num,list_pos=list_pos,list=basefunc.deepcopy(list)}
					end
					return 
				end	
				pai_map[s]=pai_map[s]-3
				
				local next=s
				if pai_map[s]==0 then
					next=s+1
				end
				compute_nor_hupai_info(pai_map,next,all_num-3,jiang_num,list,list_pos+1,info)

				pai_map[s]=pai_map[s]+3
			end
			--取顺子	
			if s+2<40  and pai_map[s+1] and pai_map[s+2] and pai_map[s+1]>0 and pai_map[s+2]>0 then

				list[list_pos]=list[list_pos] or {}
				list[list_pos].type=3
				list[list_pos].pai_type=s

				if all_num-3==0 then

					if jiang_num==1 then
						info[#info+1]={jiang_num=jiang_num,list_pos=list_pos,list=basefunc.deepcopy(list)}
					end
					return 
				end	
				pai_map[s]=pai_map[s]-1
				pai_map[s+1]=pai_map[s+1]-1
				pai_map[s+2]=pai_map[s+2]-1

				local next=s
				if pai_map[s]==0 then
					next=s+1
				end

				compute_nor_hupai_info(pai_map,next,all_num-3,jiang_num,list,list_pos+1,info)
			
				pai_map[s]=pai_map[s]+1
				pai_map[s+1]=pai_map[s+1]+1
				pai_map[s+2]=pai_map[s+2]+1
			end
			--取将
			if pai_map[s]>1 and jiang_num==0 then
				
				list[list_pos]=list[list_pos] or {}
				list[list_pos].type=1
				list[list_pos].pai_type=s

				if all_num-2==0 then
					info[#info+1]={jiang_num=jiang_num,list_pos=list_pos,list=basefunc.deepcopy(list)}
					return 
				end
				pai_map[s]=pai_map[s]-2	

				local next=s
				if pai_map[s]==0 then
					next=s+1
				end

				compute_nor_hupai_info(pai_map,next,all_num-2,jiang_num+1,list,list_pos+1,info)

				pai_map[s]=pai_map[s]+2

			end	
			
			return 
		end
	end
	return 
end
--7对
local function check_7d_hupai_info(pai_map,all_num,kaiguan)
	if kaiguan and not kaiguan.qi_dui then
		return false
	end
	if all_num~=14 then
		return false
	end
	for k,v in pairs(pai_map) do
		if v>0 and v~=2 and v~=4 then
			return false
		end
	end
	return true
end
--大对子
local function check_is_daduizi(list,kaiguan)
	if kaiguan and not kaiguan.da_dui_zi then
		return false
	end
	for _,v in ipairs(list) do
		if v.type~=1 and v.type~=2 then
			return false
		end
	end
	return true
end
--幺九
local function check_is_yaojiu(list,pg_map,kaiguan)
	if kaiguan and not kaiguan.yao_jiu then
		return false
	end
	for _,v in ipairs(list) do
		if v.type==3 then
			local p=v.pai_type%10
			if p~=1 and p~=7 then 
				return false
			end
		else
			local p=v.pai_type%10
			if p~=1 and p~=9 then 
				return false
			end
		end
	end
	if pg_map then
		for k,v in pairs(pg_map) do
			local c=k%10
			if c~=1 and  c~=9 then
				return false
			end
		end
	end
	return true
end
--将对
local function check_is_jiangdui(list,pai_map,pg_map,kaiguan)	
	if kaiguan and not kaiguan.jiang_dui then
		return false
	end

	for _,v in ipairs(list) do
		if v.type~=1 and v.type~=2 then
			return false
		end
	end

	for k,v in pairs(pai_map) do
		if v>0 then
			local c=k%10
			if c~=2 and  c~=5 and  c~=8 then
				return false
			end
		end
	end
	if pg_map then
		for k,v in pairs(pg_map) do
			local c=k%10
			if c~=2 and  c~=5 and  c~=8 then
				return false
			end
		end
	end
	return true
end
--门清
local function check_is_menqing(pg_map,kaiguan)
	if kaiguan and not kaiguan.men_qing then
		return false
	end
	for k,v in pairs(pg_map) do
		if v~="ag" then
			return false
		end
	end 
	return true
end
--中章
local function check_is_zhongzhang(pai_map,pg_map,kaiguan)
	if kaiguan and not kaiguan.zhong_zhang then
		return false
	end
	for k,v in pairs(pai_map) do
		if v>0 then
			local c=k%10
			if c==1 or c==9 then
				return false
			end
		end
	end
	if pg_map then
		for k,v in pairs(pg_map) do
			local c=k%10
			if c==1 or  c==9 then
				return false
			end
		end
	end
	return true
end
--金钩钓
local function check_is_jingoudiao(pai_map,kaiguan)
	if kaiguan and not kaiguan.jin_gou_diao then
		return false
	end
	local count=0
	for k,v in pairs(pai_map) do
		count=count+v
	end
	if count==2 then
		return true
	end
	return false
end
local function compute_hupai_info(pai_map,pg_map,all_num,huaSe_count,kaiguan)
	local info={}
	compute_nor_hupai_info(basefunc.deepcopy(pai_map),11,all_num,0,{},1,info)

		-- 1 平胡 2 大对子 3 7对 4幺九 5将对
	local hupai_type
	if #info>0 then
		hupai_type=1
		--计算最大胡牌
		for _,v in ipairs(info) do
			--是否为大对子
			if 2>hupai_type then
				if check_is_daduizi(v.list,kaiguan) then
					hupai_type=2
				end
			end
			--是否为将对
			if 5>hupai_type then
				if check_is_jiangdui(v.list,pai_map,pg_map,kaiguan) then
					hupai_type=5
				end
			end
			--幺舅九
			if 4>hupai_type then
				if check_is_yaojiu(v.list,pg_map,kaiguan) then
					hupai_type=4
				end
			end
		end
	end
	if check_7d_hupai_info(pai_map,all_num,kaiguan) then
		if not hupai_type or 3>hupai_type then
			hupai_type=3
		end
	end
	if hupai_type then
		local geng_num=normal_majiang.get_geng_num(pai_map,pg_map)
		local res={}
		
		if hupai_type==3 then
			if geng_num>0 then
				--龙7对
				geng_num=geng_num-1
				res.long_qi_dui=normal_majiang.MULTI_TYPES.long_qi_dui
			else
				--7对
				res.qi_dui=normal_majiang.MULTI_TYPES.qi_dui
			end
		elseif  hupai_type==2 then
			--大对子
			res.da_dui_zi=normal_majiang.MULTI_TYPES.da_dui_zi

		elseif hupai_type==5 then
			--将对
			res.jiang_dui=normal_majiang.MULTI_TYPES.jiang_dui
		elseif hupai_type==4 then
			--幺九
			res.yao_jiu=normal_majiang.MULTI_TYPES.yao_jiu
		end
		if geng_num>0 then
			res.dai_geng = geng_num
		end
		--检查清一色
		if huaSe_count==1 and (not kaiguan or kaiguan.qing_yi_se) then
			res.qing_yi_se=normal_majiang.MULTI_TYPES.qing_yi_se
		end
		--检查中章
		if check_is_zhongzhang(pai_map,pg_map,kaiguan) then
			res.zhong_zhang=normal_majiang.MULTI_TYPES.zhong_zhang
		end
		--检查门清
		if check_is_menqing(pg_map,kaiguan) then
			res.men_qing=normal_majiang.MULTI_TYPES.men_qing
		end
		--检查金钩钓
		if check_is_jingoudiao(pai_map,kaiguan) then
			res.jin_gou_diao=normal_majiang.MULTI_TYPES.jin_gou_diao
		end
		
		local mul=0
		for _,v in pairs(res) do
			mul=mul+v
		end
		return {hu_type_info=res,mul=mul,geng_num=geng_num}
	end
	return nil
end
local function tongji_pai_info(pai_map,huaSe)
	local count=0
	huaSe=huaSe or {0,0,0}
	if pai_map then
		for id,v in pairs(pai_map) do
			if v>0 then 
				local c=math.floor(id/10)
				huaSe[c]=1
				count=count+v
			end
		end
	end
	return count
end
local function tongji_penggang_info(pg_map,huaSe)
	local count=0
	huaSe=huaSe or {0,0,0}
	if pg_map then
		for id,v in pairs(pg_map) do
			if v=="wg" or v=="zg" or v=="ag" or v=="peng" or v==4 or v==3 then
				local c=math.floor(id/10)
				huaSe[c]=1
				count=count+3
			end
		end
	end
	return count
end


function normal_majiang.get_geng_num(pai_map,pg_map)
	local num=0
	if pai_map then
		for id,v in pairs(pai_map) do
			if v==4 then
				num=num+1
			elseif v==1 and pg_map and (pg_map[id]=="peng" or pg_map[id]==3) then
				num=num+1
			end
		end
	end
	if pg_map then
		for _,v in pairs(pg_map) do
			if v=="wg" or v=="zg" or v=="ag" or v==4 then
				num=num+1
			end
		end
	end
	return num
end
--get杠bia
function normal_majiang.check_is_gang(map,pai)
	
	if pai and map[pai]==3 then
		return true
	end
	for _,v in ipairs(map) do
		if v==4 then
			return true
		end
	end
	if num>0 then
		return true
	end

	return false
end
--检查能否碰
function normal_majiang.check_is_peng(map,pai)
	if pai and map[pai]==2 then
		return true
	end
	return false
end

function normal_majiang.check_is_hupai(pai_map,pg_map,must_que,kaiguan)
	
	if normal_majiang.get_hupai_info(pai_map,pg_map,must_que,kaiguan) then
		return true
	end
	return false
end
--[[

 参数 总张数14张
 pai_map  手里还没出的牌
 pg  碰杠的牌
 返回
 {
  hu_type_info nil 表示不糊  其他表示胡牌类型 normal_majiang.MULTI_TYPES
  mul 总倍数
  geng_num
 }
--]] 
function normal_majiang.get_hupai_info(pai_map,pg_map,must_que,kaiguan)

	local huaSeMap={0,0,0}
	local count1=tongji_pai_info(pai_map,huaSeMap)
	local count2=tongji_penggang_info(pg_map,huaSeMap)

	local huaSe_count=huaSeMap[1]+huaSeMap[2]+huaSeMap[3]

	if count1+count2~=14 or huaSe_count>2 then
		return nil
	end
	if must_que and huaSeMap[must_que] and huaSeMap[must_que]>0 then
		return nil
	end

	return compute_hupai_info(basefunc.deepcopy(pai_map),pg_map,count1,huaSe_count,kaiguan)
end
--[[

-参数  总张数13张
  pai_map  手里还没出的牌
 	pg  碰杠的牌
返回
{
  {
  	ting_pai
  	hu_type_info nil 表示不糊  其他表示胡牌类型
  	mul 倍数
  	geng 根的数量
  }
}
--]]
function normal_majiang.get_ting_info(pai_map,pg_map,must_que,kaiguan)
	local huaSeMap={0,0,0}
	local count1=tongji_pai_info(pai_map,huaSeMap)
	local count2=tongji_penggang_info(pg_map,huaSeMap)

	local huaSe_count=huaSeMap[1]+huaSeMap[2]+huaSeMap[3]

	if count1+count2~=13 or huaSe_count>2 then
		return nil
	end
	if must_que and huaSeMap[must_que] and huaSeMap[must_que]>0 then
		return nil
	end
	local check_have_lianzi=function(pm,s)
		if s+2<40 and pm[s] and pm[s+1] and pm[s+2] and pm[s]>0 and pm[s+1]>0 and pm[s+2]>0  then
			return true
		end
		if s-1>10 and s+1<40 and pm[s] and pm[s+1] and pm[s-1] and pm[s]>0 and pm[s+1]>0 and pm[s-1]>0  then
			return true
		end
		if s-2>10  and pm[s] and pm[s-1] and pm[s-2] and pm[s]>0 and pm[s-1]>0 and pm[s-2]>0  then
			return true
		end
		return false
	end
	local pai_map_copy=basefunc.deepcopy(pai_map)
	local list
	for s=11,39 do
		if s%10~=0 then
			local color=normal_majiang.flower(s)
			if color~=must_que then
				pai_map_copy[s]=pai_map_copy[s] or 0
				pai_map_copy[s]=pai_map_copy[s] + 1
				if pai_map_copy[s]>1 or check_have_lianzi(pai_map_copy,s) then
					local count=tongji_pai_info(pai_map_copy)
					local res=compute_hupai_info(basefunc.deepcopy(pai_map_copy),pg_map,count,huaSe_count,kaiguan)
					if res then
						res.ting_pai=s
						list=list or {}
						list[#list+1]=res 
					end
				end
				pai_map_copy[s]=pai_map_copy[s] - 1
				if pai_map_copy[s]==0 then
					pai_map_copy[s]=nil
				end
			end
		end
	end
	--
	return list
end
--检测血流成河胡牌之后还能不能杠
function normal_majiang.check_xueliu_hu_gang(pai_map,pg_map,must_que,gang_pai,ting_map,kaiguan)
	if pai_map[gang_pai] and pai_map[gang_pai]>0 then
		--弯杠一定行
		if pai_map[gang_pai]==1 and pg_map[gang_pai]=="peng" then
			return true
		elseif pai_map[gang_pai]>3 then
			local sum=pai_map[gang_pai]
			pai_map[gang_pai]=nil
			pg_map[gang_pai]="ag"
			local list=normal_majiang.get_ting_info(pai_map,pg_map,must_que,kaiguan)
			pai_map[gang_pai]=sum
			pg_map[gang_pai]=nil
			if list then
				if ting_map.total_count and #list==ting_map.total_count and ting_map.total_count>0 then
					for i,v in ipairs(list) do
						if not ting_map[v.ting_pai] then
							return false
						end
					end
					return true
				end
			end
		end
	end
	return false
end
--[[
-参数 总张数14张
 pai_map  手里还没出的牌
 pg  碰杠的牌
返回
{
	chupai={
		  {
		  	ting_pai
		  	hu_type_info nil 表示不糊  其他表示胡牌类型
		  	mul 倍数
		  	geng 根的数量
		  }
	}
}
--]]
function normal_majiang.get_chupai_ting_info(pai_map,pg_map,must_que,kaiguan)
	local huaSeMap={0,0,0}
	dump(pai_map)
	dump(pg_map)
	local count1=tongji_pai_info(pai_map,huaSeMap)
	local count2=tongji_penggang_info(pg_map,huaSeMap)

	local huaSe_count=huaSeMap[1]+huaSeMap[2]+huaSeMap[3]
	print(count1,count2)
	if count1+count2~=14 then
		return nil
	end
	local map
	local pai_map_copy=basefunc.deepcopy(pai_map)
	for id,v in pairs(pai_map_copy) do
		if v>0 then
			
			pai_map_copy[id]=pai_map_copy[id]-1

			local res=normal_majiang.get_ting_info(pai_map_copy,pg_map,must_que,kaiguan)
			if res then
				map=map or {}
				map[id]=res
			end
			pai_map_copy[id]=pai_map_copy[id]+1
		end
	end

	return map
end


--洗牌
local function new_pai_pool()

	local _pai={
			11,12,13,14,15,16,17,18,19,
			11,12,13,14,15,16,17,18,19,
			11,12,13,14,15,16,17,18,19,
			11,12,13,14,15,16,17,18,19,

			21,22,23,24,25,26,27,28,29,
			21,22,23,24,25,26,27,28,29,
			21,22,23,24,25,26,27,28,29,
			21,22,23,24,25,26,27,28,29,

			31,32,33,34,35,36,37,38,39,
			31,32,33,34,35,36,37,38,39,
			31,32,33,34,35,36,37,38,39,
			31,32,33,34,35,36,37,38,39,
		}
	local _count=#_pai
	local _rand=1
	local _jh
	for _i=1,_count-1 do
		_jh=_pai[_i]
		_rand=random(_i,_count)
		_pai[_i]=_pai[_rand]
		_pai[_rand]=_jh
	end

	return _pai
end

-- 得到牌的花色
function normal_majiang.flower(_pai)
	return floor(_pai/10)
end
local flower = normal_majiang.flower

-- 判断座位上的条件（或）
function normal_majiang.seat_bool_or(_values)
	for i=1,SEAT_COUNT do
		if _values[i] then
			return true
		end
	end

	return false
end

-- 判断座位上的条件（与）
function normal_majiang.seat_bool_and(_values)
	for i=1,SEAT_COUNT do
		if not _values[i] then
			return false
		end
	end

	return true
end

-- map 的牌集合 转换为 list
function normal_majiang.get_pai_list_by_map(_pai_map)
	if _pai_map then
		local list={}
		for _pai_id,_count in pairs(_pai_map) do
			for i=1,_count do
				list[#list+1]=_pai_id
			end
		end
		return list
	end

	return nil
end

-- list 牌的集合 转换为 map
function normal_majiang.get_pai_map_by_list(_pai_list)
	if _pai_list then
		local map = {}
		for _,_pai in ipairs(_pai_list) do
			map[_pai] = (map[_pai] or 0) + 1
		end

		return map
	end
	return nil
end

function normal_majiang.get_pg_map_by_pplist(_pp_list)
	local pg_map={}
	if _pp_list then
		for _,v in ipairs(_pp_list) do
			pg_map[v.pai]=v.type
		end
	end
	return pg_map
end


local function _pai_order(_pai,_que_flower)
	if flower(_pai) == _que_flower then
		return _pai + 99999
	else
		return _pai
	end
end

-- 排序
-- 参数：
--	_pai_list 牌的列表
--	_que_pai （可选）打缺的花色，会排在最后
function normal_majiang.sort_pai(_pai_list,_que_flower)
	if _pai_list and #_pai_list > 0 then
		table.sort(_pai_list,function(_p1,_p2)
			return _pai_order(_p1,_que_flower)  <  _pai_order(_p2,_que_flower)
		end)
	end
end

-- 根据手上的牌，找一个最合适的花色定缺
-- 参数 _pai_list ： 牌的数组
function normal_majiang.ding_que(_pai_list)

	local _flower = {}

	for _,_pai in ipairs(_pai_list) do
		local f = flower(_pai)
		_flower[f] = (_flower[f] or 0) + 1
	end

	local tong = (_flower[1] or 0) <=(_flower[2] or 0) and(_flower[1] or 0) <=(_flower[3] or 0) or false
	local tiao = (_flower[2] or 0) <=(_flower[1] or 0) and(_flower[2] or 0) <=(_flower[3] or 0) or false
	local wan = (_flower[3] or 0) <=(_flower[1] or 0) and(_flower[3] or 0) <=(_flower[2] or 0) or false

	return tong,tiao,wan
end

local function copy_pai_map(_pai_map)
	local ret = {}
	for _pai,_count in pairs(_pai_map) do
		ret[_pai] = _count
	end

	return ret
end

-- ###_temp 递归计算各种基础牌型
-- 参数 _pai_list,_pos,_count ： 牌列表 、 位置 、已取牌数量
-- 参数 _jiang,_j_count ： 将牌，数量
-- 参数 _groups ： 分组
local function calc_hupai_type_base(_pai_list,_pos,_count,_pai_map,_jiang,_j_count,_groups,_out_hu_pay_types)
	for _pai,_count in pairs(_pai_map) do
		if 2 == _count  then
			if  not _jiang then
				-- 两张相同的牌，优先做将
				local _tmp_map = copy_pai_map(_pai_map)
				_tmp_map[_pai] = nil
				calc_hupai_type_base(_tmp_map,_pai,copy_pai_map(_groups),_out_hu_pay_types)
			else
				-- 计算连子

			end
		elseif 3 == _count then

		end
	end
end

-- 计算基础胡牌类型
-- 参数 _pai_map ：手上的牌，不包括 碰杠
-- 返回一个数组，每一项如下：
--	{hu_pai_type="ping_hu",pai_groups={第1靠牌 map,第2靠牌 map,....} }
--	pai_groups 不包括碰杠的牌
--	如果为 "qi_dui"， 则 pai_groups 为 nil
-- 未胡牌，返回空表
local function calc_hupai_type(_pai_map)

	local hu_pay_types = {}

	local pai_list = {}

	-- 先判断 七对 （不能有 碰杠）
	for _pai,_count in pairs(_pai_map) do
		pai_list[#pai_list + 1] = _pai
		if fmod(_count) ~= 0 then
			hu_pay_types[#hu_pay_types + 1] = {hu_pai_type="qi_dui"}
			break
		end
	end

	-- 判断平胡
	local _groups = {}
	calc_hupai_type_base(pai_list,1,1,_pai_map,nil,0,_groups,hu_pay_types)

	return hu_pay_types
end


function normal_majiang.pop_pai(_play_data)
	_play_data.last_fapai_index = _play_data.last_fapai_index + 1
	return _play_data.pai_pool[_play_data.last_fapai_index]
end

-- 下一个座位号
function normal_majiang.next_seat(_cur_seat)
	return fmod(_cur_seat,SEAT_COUNT) + 1
end

function normal_majiang.reset_seat_data(_datas,_value)
	for i=1,SEAT_COUNT do
		_datas[i] = _value
	end
end

function normal_majiang.get_init_jipaiqi()
	local jipaiqi={}
	for i=11,39 do
		jipaiqi[i]=4
	end
	return jipaiqi
end
function normal_majiang.jipaiqi_kick_pai(pai,jipaiqi,num)
	if pai and jipaiqi[pai] then
		num=num or 1
		jipaiqi[pai]=jipaiqi[pai]-num
		if jipaiqi[pai]<0 then
			print("<color=red>记牌器 减牌变成负数</color>")
			jipaiqi[pai]=0
		end
	end

end

----- 加牌
function normal_majiang.jipaiqi_add_pai(pai,jipaiqi,num)
	if pai and jipaiqi[pai] then
		num=num or 1
		jipaiqi[pai]=jipaiqi[pai]+num
		if jipaiqi[pai]>4 then
			print("<color=red>记牌器 加到大于4</color>")
			jipaiqi[pai]=4
		end
	end

end

local jpq_sID_to_norID={
	[1]=11,
	[2]=12,
	[3]=13,
	[4]=14,
	[5]=15,
	[6]=16,
	[7]=17,
	[8]=18,
	[9]=19,
	[10]=21,
	[11]=22,
	[12]=23,
	[13]=24,
	[14]=25,
	[15]=26,
	[16]=27,
	[17]=28,
	[18]=29,
	[19]=31,
	[20]=32,
	[21]=33,
	[22]=34,
	[23]=35,
	[24]=36,
	[25]=37,
	[26]=38,
	[27]=39,
}
function normal_majiang.jipaiqi_server_to_client(s_jipaiqi)
	local c_jipaiqi 
	if s_jipaiqi then
		c_jipaiqi={}
		for id,v in ipairs(s_jipaiqi) do
			c_jipaiqi[jpq_sID_to_norID[id]]=v
		end 
	end
	return c_jipaiqi
end


--- 保存 选中的换三张的牌 数据
function normal_majiang.saveSelectHuanSanZhangePai(text)
	local path = AppDefine.LOCAL_DATA_PATH .. "/" .. MainModel.UserInfo.user_id
    if not Directory.Exists(path) then
        Directory.CreateDirectory(path)
    end

    local filepath = path .. "/huanSanZhang.txt"
    File.WriteAllText(filepath, text)
end

function normal_majiang.getSelectHuanSanZhangePai()
	local path = AppDefine.LOCAL_DATA_PATH .. "/" .. MainModel.UserInfo.user_id
    if not Directory.Exists(path) then
        Directory.CreateDirectory(path)
    end

    local filepath = path .. "/huanSanZhang.txt"
    if File.Exists(filepath) then
    	return File.ReadAllText(filepath)
    else
    	return ""
    end
end

--- 把选中的vec变成一个空格分割的字符串
function normal_majiang.getVecString(vec , splitStr)
	local ret = "0" .. splitStr
	local index = 0
	for key,value in ipairs(vec) do
		if index ~= 0 then
			ret = ret .. splitStr
		end
		ret = ret .. value

		index = index + 1
	end
	return ret
end

function normal_majiang.getStringVec(string , splitStr)
	local vec = basefunc.string.split(string, splitStr)
	if vec then
		for k,v in pairs(vec) do
			vec[k] = tonumber(v)
		end
	end
	return vec or {}
end

----
function normal_majiang.check_shoupai_can_huanpai(shoupaiMap , huanpaiVec)	
	local tem = basefunc.deepcopy( shoupaiMap )
    
    for key,pai in pairs(huanpaiVec) do
        if tem[pai] and tem[pai] >= 1 then
            tem[pai] = tem[pai] - 1
        else
            return false
        end
    end
    return true
end

return normal_majiang












 