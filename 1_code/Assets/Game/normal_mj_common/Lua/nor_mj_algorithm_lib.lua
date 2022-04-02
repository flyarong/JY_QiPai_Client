--
-- Author: hw
-- Date: 2018/3/20
-- 说明：麻将
-- package.path=package.path..";/Users/hewei/project/JyQipai_server/skynet/game/common/?.lua"
local basefunc = require "Game.Common.basefunc"
local nor_mj_base_lib = require "Game.normal_mj_common.Lua.nor_mj_base_lib"

local nor_mj_algorithm=basefunc.class()

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

-- 基础胡牌类型定义： 番型 -> 番数
local MULTI_TYPES =
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
	zimo            = 1, -- 自摸
	qiangganghu     = 1, -- 抢杠胡 
}

local KAIGUAN={
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
	zimo_jiadian    = nil, -- 自摸加点
	zimo_bujiadian  = nil,  --自摸不加
 	max_fan         = nil,   --封顶番数	
}

----------------------------------------------------------7张 二人麻将的开关&番数
-- 开关配置
local mjErRen7_kaiguan = 
{
    qing_yi_se      = true,
    da_dui_zi       = true,
    qi_dui          = true,
    long_qi_dui     = true,
    --将对
    jiang_dui       = false,
    men_qing        = false,
    zhong_zhang     = false,
    jin_gou_diao    = true,
    yao_jiu         = false, 


    -- 其它：和胡牌方式相关的
    hai_di_ly       = true, -- 海底捞月 最后一张牌胡牌（自摸）
    hai_di_pao      = true, -- 海底炮  最后一张牌胡牌（被人点炮）
    tian_hu         = true, -- 天胡：庄家，第一次发完牌既胡牌
    di_hu           = true, -- 地胡：非庄家第一次发完牌 既自摸或 被别人点炮
    gang_shang_hua  = true, -- 杠上花：自己杠后补杠自摸
    gang_shang_pao  = true, -- 杠上炮：别人杠后补杠点炮
    zimo            = true, -- 自摸
    qiangganghu     = true, -- 抢杠胡 
    zimo_jiafan     = true, -- 自摸加翻 
    zimo_jiadian     = true, -- 自摸加点 
    da_piao         = true,  -- 打漂
}

-- 番数配置
local mjErRen7_multi = 
{
    -- 牌型
    qing_yi_se      = 2,
    da_dui_zi       = 1,
    qi_dui          = 2,
    long_qi_dui     = 3,

    dai_geng        = 1,
    
    jiang_dui       = 3, --将对
    men_qing        = 1, --门清
    zhong_zhang     = 1, --中章
    jin_gou_diao    = 1, --金钩钓
    yao_jiu         = 3, --幺九

    -- 其它：和胡牌方式相关的
    hai_di_ly       = 1, -- 海底捞月 最后一张牌胡牌（自摸）
    hai_di_pao      = 1, -- 海底炮  最后一张牌胡牌（被人点炮）
    tian_hu         = 3, -- 天胡：庄家，第一次发完牌既胡牌
    di_hu           = 2, -- 地胡：非庄家第一次发完牌 既自摸或 被别人点炮
    gang_shang_hua  = 1, -- 杠上花：自己杠后补杠自摸
    gang_shang_pao  = 1, -- 杠上炮：别人杠后补杠点炮
    zimo            = 1, -- 自摸
    qiangganghu     = 1, -- 抢杠胡 
}

----------------------------------------------------------13张 二人麻将的开关&番数
-- 开关配置
local mjErRen13_kaiguan = 
{
    qing_yi_se      = true,
    da_dui_zi       = true,
    qi_dui          = true,
    long_qi_dui     = true,
    --将对
    jiang_dui       = false,
    men_qing        = false,
    zhong_zhang     = false,
    jin_gou_diao    = true,
    yao_jiu         = false, 


    -- 其它：和胡牌方式相关的
    hai_di_ly       = true, -- 海底捞月 最后一张牌胡牌（自摸）
    hai_di_pao      = true, -- 海底炮  最后一张牌胡牌（被人点炮）
    tian_hu         = true, -- 天胡：庄家，第一次发完牌既胡牌
    di_hu           = true, -- 地胡：非庄家第一次发完牌 既自摸或 被别人点炮
    gang_shang_hua  = true, -- 杠上花：自己杠后补杠自摸
    gang_shang_pao  = true, -- 杠上炮：别人杠后补杠点炮
    zimo            = true, -- 自摸
    qiangganghu     = true, -- 抢杠胡 
    zimo_jiafan     = true, -- 自摸加翻 
    zimo_jiadian     = true, -- 自摸加点 
}

-- 番数配置
local mjErRen13_multi = 
{
    -- 牌型
    qing_yi_se      = 2,
    da_dui_zi       = 1,
    qi_dui          = 2,
    long_qi_dui     = 3,

    dai_geng        = 1,
    
    jiang_dui       = 3, --将对
    men_qing        = 1, --门清
    zhong_zhang     = 1, --中章
    jin_gou_diao    = 1, --金钩钓
    yao_jiu         = 3, --幺九

    -- 其它：和胡牌方式相关的
    hai_di_ly       = 1, -- 海底捞月 最后一张牌胡牌（自摸）
    hai_di_pao      = 1, -- 海底炮  最后一张牌胡牌（被人点炮）
    tian_hu         = 3, -- 天胡：庄家，第一次发完牌既胡牌
    di_hu           = 2, -- 地胡：非庄家第一次发完牌 既自摸或 被别人点炮
    gang_shang_hua  = 1, -- 杠上花：自己杠后补杠自摸
    gang_shang_pao  = 1, -- 杠上炮：别人杠后补杠点炮
    zimo            = 1, -- 自摸
    qiangganghu     = 1, -- 抢杠胡 
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
			if s+2<=39 and pai_map[s] and pai_map[s+1] and pai_map[s+2] and pai_map[s+1]>0 and pai_map[s+2]>0 then


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
local function check_7d_hupai_info(pai_map,all_num,kaiguan , maxShouPaiNum)
	if kaiguan and not kaiguan.qi_dui then
		return false
	end
	if all_num~=maxShouPaiNum then
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
			if c==1 or  c==9 then
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
--杠上花
local function check_is_gangshanghua(act_list,seat_num,kaiguan)
	if kaiguan and not kaiguan.gang_shang_hua then
		return false
	end
	if act_list then
		if #act_list>1 then
			local act1=act_list[#act_list]
			local act2=act_list[#act_list-1]
			if act1.type=="mo_pai" and act1.p==seat_num and (act2.type=="wg" or act2.type=="zg" or act2.type=="ag")  and act2.p==seat_num then
				return true
			end
		end
	end
	return false
end
--杠上炮
local function check_is_gangshangpao(act_list,cp_seat_num,kaiguan)
	if kaiguan and not kaiguan.gang_shang_pao then
		return false
	end
	if act_list then
		if #act_list>2 then
			local act1=act_list[#act_list]
			local act2=act_list[#act_list-1]
			local act3=act_list[#act_list-2]
			if act1.type=="cp" and act1.p==cp_seat_num and act2.type=="mo_pai" and act2.p==cp_seat_num and (act3.type=="wg" or act3.type=="zg" or act3.type=="ag")  and act3.p==cp_seat_num then
				return true
			end
		end
	end
	return false
end

local function compute_hupai_info(pai_map,pg_map,all_num,huaSe_count,kaiguan,multi_types, maxShouPaiNum)
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
	if check_7d_hupai_info(pai_map,all_num,kaiguan, maxShouPaiNum) then
		if not hupai_type or 3>hupai_type then
			hupai_type=3
		end
	end
	if hupai_type then
		local geng_num=nor_mj_base_lib.get_geng_num(pai_map,pg_map)
		local res={}

		if hupai_type==3 then
			if geng_num>0 then
				--龙7对
				geng_num=geng_num-1
				res.long_qi_dui=multi_types.long_qi_dui
			else
				--7对
				res.qi_dui=multi_types.qi_dui
			end
		elseif  hupai_type==2 then
			--大对子
			res.da_dui_zi=multi_types.da_dui_zi

		elseif hupai_type==5 then
			--将对
			res.jiang_dui=multi_types.jiang_dui
		elseif hupai_type==4 then
			--幺九
			res.yao_jiu=multi_types.yao_jiu
		end
		if geng_num>0 then
			res.dai_geng = geng_num
		end
		--检查清一色
		if huaSe_count==1 and kaiguan.qing_yi_se then
			res.qing_yi_se=multi_types.qing_yi_se
		end
		--检查中章
		if check_is_zhongzhang(pai_map,pg_map,kaiguan) then
			res.zhong_zhang=multi_types.zhong_zhang
		end
		--检查门清
		if check_is_menqing(pg_map,kaiguan) then
			res.men_qing=multi_types.men_qing
		end
		--检查金钩钓
		if check_is_jingoudiao(pai_map,kaiguan) then
			res.jin_gou_diao=multi_types.jin_gou_diao
		end

		local mul=0
		for _,v in pairs(res) do
			mul=mul+v
		end
		return {hu_type_info=res,mul=mul,geng_num=geng_num}
	end
	return nil
end



function nor_mj_algorithm:ctor(_kaiguan,_multi_types,game_type)
	self.gameType = game_type or "nor_mj_xzdd"
	self.kaiguan = _kaiguan
	self.multi_types = _multi_types
	
	if not self.kaiguan then
		if self.gameType == "nor_mj_xzdd_er_7" then
			self.kaiguan = mjErRen7_kaiguan
		elseif self.gameType == "nor_mj_xzdd_er_13" then
			self.kaiguan = mjErRen13_kaiguan
		else
			self.kaiguan = KAIGUAN
		end
	end

	if not self.multi_types then
		if self.gameType == "nor_mj_xzdd_er_7" then
			self.multi_types = mjErRen7_multi
		elseif self.gameType == "nor_mj_xzdd_er_13" then
			self.multi_types = mjErRen13_multi
		else
			self.multi_types = MULTI_TYPES
		end
	end

	--- 基础的手牌数量,默认13
	self.baseShouPaiNum = 13
	--- 最多的手牌数量
	self.maxShouPaiNum = self.baseShouPaiNum + 1
end

function nor_mj_algorithm:getSelfKaiguan()
	return self.kaiguan
end

function nor_mj_algorithm:getSelfMulti()
	return self.multi_types
end

function nor_mj_algorithm:set_kaiguan(kaiguan)
	self.kaiguan = kaiguan
end

function nor_mj_algorithm:set_multi(multi)
	self.multi_types = multi
end

function nor_mj_algorithm.getDefault_kaiguan()
	return KAIGUAN
end

function nor_mj_algorithm.getDefault_multi()
	return MULTI_TYPES
end

function nor_mj_algorithm.getMjXzEr7_kaiguan()
	return mjErRen7_kaiguan
end

function nor_mj_algorithm.getMjXzEr7_multi()
	return mjErRen7_multi
end

function nor_mj_algorithm.getMjXzEr13_kaiguan()
	return mjErRen13_kaiguan
end

function nor_mj_algorithm.getMjXzEr13_multi()
	return mjErRen13_multi
end



--[[

 参数 总张数14张
 pai_map  手里还没出的牌
 pg  碰杠的牌
 返回
 {
  hu_type_info 其他表示胡牌类型 
  mul 总番数
  geng_num
 }
 返回 nil 表示不糊
--]]
function nor_mj_algorithm:get_hupai_info(pai_map,pg_map,must_que)

  local huaSeMap={0,0,0}
  local count1=nor_mj_base_lib.tongji_pai_info(pai_map,huaSeMap)
  local count2=nor_mj_base_lib.tongji_penggang_info(pg_map,huaSeMap)

  local huaSe_count=huaSeMap[1]+huaSeMap[2]+huaSeMap[3]

  if count1+count2~=self.maxShouPaiNum or huaSe_count>2 then
    return nil
  end
  if must_que and huaSeMap[must_que] and huaSeMap[must_que]>0 then
    return nil
  end

  return compute_hupai_info(basefunc.deepcopy(pai_map),pg_map,count1,huaSe_count,self.kaiguan,self.multi_types,self.maxShouPaiNum)
end


function nor_mj_algorithm:get_last_cp_by_act_list(act_list,seat_num)
	if act_list then
		local len=#act_list
		for i=len,1,-1 do
			if act_list[i].type=="cp" then
				if seat_num then
					if seat_num and act_list[i].p==seat_num then
						return nil
					end
				end
				return act_list[i],i
			end
		end
	end
	return nil
end
--[[
{
  hu_type_info 其他表示胡牌类型 
  mul 总番数
  total 总倍数
  geng_num
  dianpao_p --点炮人  自摸没有
  hu_pai  --胡的牌  天胡没有
 }
 --]]
function nor_mj_algorithm:get_hupai_all_info(pai_map,pg_map,must_que,act_list,seat_num,zj_seat_num,mopai_count,chupai_count,remain_card)
	local huaSeMap={0,0,0}

	local count1=nor_mj_base_lib.tongji_pai_info(pai_map,huaSeMap)
	local count2=nor_mj_base_lib.tongji_penggang_info(pg_map,huaSeMap)

	local huaSe_count=huaSeMap[1]+huaSeMap[2]+huaSeMap[3]

	if  huaSe_count>2 then
	    return nil
	end
	if must_que and huaSeMap[must_que] and huaSeMap[must_que]>0  then
	    return nil
	end
	--是否是自摸
	local is_zimo=true
	--是否是强杠胡
	local is_qiangganghu=false
	--点炮的牌
	local pao_pai
	--点炮的人的座位号
	local pao_p

	local kaiguan=self.kaiguan
	local multi_types=self.multi_types
	--
	if count1+count2== self.baseShouPaiNum then
		local act,pos=self:get_last_cp_by_act_list(act_list,seat_num)
		if not act or pos~=#act_list then
			if  kaiguan.qiangganghu and act_list and #act_list>0 and act_list[#act_list].type=="wg" and act_list[#act_list].p~=seat_num then
				act=act_list[#act_list]
				is_qiangganghu=true
			else
				return nil
			end
		end
		is_zimo=false
		pao_pai=act.pai
		pao_p=act.p
		if nor_mj_base_lib.flower(pao_pai) ==must_que then
			return nil
		end
		pai_map[pao_pai]=(pai_map[pao_pai] or 0) +1

	end
	local res=self:get_hupai_info(pai_map,pg_map,must_que)
	if not is_zimo then
		pai_map[pao_pai]=pai_map[pao_pai] - 1
	end

	if res then
		res.total=0
		--判断自摸
		if is_zimo then
			--自摸加翻
			if kaiguan.zimo_jiafan then
				res.hu_type_info.zimo=multi_types.zimo
			--自摸加点
			elseif kaiguan.zimo_jiadian then
				res.total=res.total+1
			end
			--判断杠上花
			if check_is_gangshanghua(act_list,seat_num,kaiguan) then
				res.hu_type_info.gang_shang_hua=multi_types.gang_shang_hua
			end
			--判断海底捞月
			if kaiguan.hai_di_ly and remain_card==0 then
				res.hu_type_info.hai_di_ly=multi_types.hai_di_ly
			end
			--判断天胡
			if  kaiguan.tian_hu and seat_num==zj_seat_num and chupai_count==0 and mopai_count==0 then
				res.hu_type_info.tian_hu=multi_types.tian_hu
				--天胡不算自摸
				res.hu_type_info.zimo=nil
			else
				--自摸的牌  --天胡没有胡的牌
				res.hu_pai=act_list[#act_list].pai
			end
		else
			--判断杠上炮
			if check_is_gangshangpao(act_list,pao_p,kaiguan) then
				res.hu_type_info.gang_shang_pao=multi_types.gang_shang_pao
			end

			--判断海底炮
			if  kaiguan.hai_di_pao and remain_card==0 then
				res.hu_type_info.hai_di_pao=multi_types.hai_di_pao
			end
			--判断地胡
			if kaiguan.di_hu and pao_p==zj_seat_num and chupai_count==0 and mopai_count==0 and remain_card==55 then
				res.hu_type_info.di_hu=multi_types.di_hu
			end
			if is_qiangganghu then
				res.hu_type_info.qiangganghu=multi_types.qiangganghu
			end
			res.dianpao_p=pao_p
			res.hu_pai=pao_pai
		end
		res.mul=0
		for _,v in pairs(res.hu_type_info) do
			res.mul=res.mul+v
		end
		res.total=res.total+2^res.mul
		--封番
		if kaiguan.max_fan then
			local max_bei=2^kaiguan.max_fan
			if res.mul>kaiguan.max_fan then
				res.mul=kaiguan.max_fan
			end
			if res.total>max_bei then
				res.total=max_bei
			end
		end
	end
	return res
end
--[[

-参数  总张数13张
  pai_map  手里还没出的牌
   pg  碰杠的牌
返回
{
  {
    ting_pai
    hu_type_info  表示胡牌类型
    mul 倍数
    geng_num 根的数量
  }
}
如果 未听牌，返回 nil
--]]
function nor_mj_algorithm:get_ting_info(pai_map,pg_map,must_que)
  local huaSeMap={0,0,0}
  local count1=nor_mj_base_lib.tongji_pai_info(pai_map,huaSeMap)
  local count2=nor_mj_base_lib.tongji_penggang_info(pg_map,huaSeMap)

  local huaSe_count=huaSeMap[1]+huaSeMap[2]+huaSeMap[3]
  if count1+count2~=self.baseShouPaiNum or huaSe_count>2 then
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
	    pai_map_copy[s]=pai_map_copy[s] or 0
	    pai_map_copy[s]=pai_map_copy[s] + 1
	    if pai_map_copy[s]>1 or check_have_lianzi(pai_map_copy,s) then
	    	local count=nor_mj_base_lib.tongji_pai_info(pai_map_copy)
	      	local res=compute_hupai_info(basefunc.deepcopy(pai_map_copy),pg_map,count,huaSe_count,self.kaiguan,self.multi_types,self.maxShouPaiNum)
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
  --
  return list
end
function nor_mj_algorithm:get_ting_map_info(pai_map,pg_map,must_que)
	local list=self:get_ting_info(pai_map,pg_map,must_que)
	local map
	if list then
		map = {}
		for i,v in ipairs(list) do
			map[v.ting_pai]=v
			map.total_count=i
		end
	end
	return map
end
--[[
{
  ting_pai
  hu_type_info 其他表示胡牌类型 
  mul 总番数
  total 总倍数
  geng_num
  hu_pai  --胡的牌  天胡没有
 }
 --]]
function nor_mj_algorithm:get_max_ting_all_info(pai_map,pg_map,must_que)
	local list=self:get_ting_info(pai_map,pg_map,must_que)
	if list and #list > 0 then
		local _max_mul
		local _res
		for _,v in ipairs(list) do
			if not _max_mul or v.mul>_max_mul then
				_max_mul=v.mul
				_res=v
			end
		end

		local kaiguan=self.kaiguan
		local multi_types=self.multi_types
		_res.hu_pai=_res.ting_pai
		_res.total=0
		_res.total=_res.total+2^_res.mul

		--封番
		if kaiguan.max_fan then
			local max_bei=2^kaiguan.max_fan
			if _res.mul>kaiguan.max_fan then
				_res.mul=kaiguan.max_fan
			end
			if _res.total>max_bei then
				_res.total=max_bei
			end
		end
		
		return _res
	end
	return nil
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
        hu_type nil 表示不糊  其他表示胡牌类型
        mul 倍数
        geng 根的数量
      }
  }
}
--]]
function nor_mj_algorithm:get_chupai_ting_info(pai_map,pg_map,must_que)
  local huaSeMap={0,0,0}
  local count1=nor_mj_base_lib.tongji_pai_info(pai_map,huaSeMap)
  local count2=nor_mj_base_lib.tongji_penggang_info(pg_map,huaSeMap)

  local huaSe_count=huaSeMap[1]+huaSeMap[2]+huaSeMap[3]

  if count1+count2~=self.maxShouPaiNum or (huaSeMap[1]>1 and huaSeMap[2]>1 and  huaSeMap[3]>1) then
    return nil
  end
  local map
  local pai_map_copy=basefunc.deepcopy(pai_map)
  for id,v in pairs(pai_map_copy) do
    if v>0 then
      pai_map_copy[id]=pai_map_copy[id]-1

      local res=self:get_ting_info(pai_map_copy,pg_map,must_que)
      if res then
        map=map or {}
        map[id]=res
      end
      pai_map_copy[id]=pai_map_copy[id]+1
    end
  end

  return map
end

--检测血流成河胡牌之后还能不能杠   只能暗杠  弯杠
function nor_mj_algorithm:check_xueliu_hu_gang(pai_map,pg_map,must_que,gang_pai,ting_map)
	if pai_map[gang_pai] and pai_map[gang_pai]>0 then

		if pai_map[gang_pai]==1 and pg_map[gang_pai]=="peng" then
			pai_map[gang_pai]=nil
			pg_map[gang_pai]="wg"
			local list=self:get_ting_map_info(pai_map,pg_map,must_que)
			pai_map[gang_pai]=1
			pg_map[gang_pai]="peng"
			if list then
				if list.total_count==ting_map.total_count and list.total_count and list.total_count>0 then
					for i,v in ipairs(list) do
						if not ting_map[v.ting_pai] then
							return false
						end
					end
					return true
				end
			end
		elseif pai_map[gang_pai]>3 then

			local sum=pai_map[gang_pai]
			pai_map[gang_pai]=nil
			pg_map[gang_pai]="ag"
			local list=self:get_ting_map_info(pai_map,pg_map,must_que)
			pai_map[gang_pai]=sum
			pg_map[gang_pai]=nil
			if list then
				if list.total_count==ting_map.total_count and list.total_count and list.total_count>0 then
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
function nor_mj_algorithm:check_is_hupai(pai_map,pg_map,must_que)
	
	if self:get_hupai_info(pai_map,pg_map,must_que) then
		return true
	end
	return false
end
--[[ 计算 碰 杠 胡
 参数：
 	_pai_map,_pai_pg_map ： 手上的牌，碰杠的牌
 	_pai : 牌，如果为 nil ，则为 判断天胡
 	_is_self : 是否是自己摸起来的牌
 返回 nil 或一个表：
	{
		peng=_pai
		gang=, （"zg" 直杠, "ag" 暗杠， "wg" 弯杠）
		hu={
			hu_type_info={qing_yi_se=2,da_dui_zi=1,...}, -- 胡牌牌型（所有方案里面最大的）
			mul      总倍数
			geng_num 总根数
		}
	}
--]]
-- function nor_mj_algorithm:get_peng_gang_hu(_pai_map,_pai_pg_map,_pai,_is_self)

-- 	-- 处理天胡的 情况
-- 	if not _pai then
-- 		local _hu = self:get_hupai_info(_pai_map,_pai_pg_map)
-- 		if _hu then
-- 			return {hu = _hu }
-- 		else
-- 			return nil
-- 		end
-- 	end

-- 	local ret

-- 	if (_pai_map[_pai] or 0) >= 2 then
-- 		if not ret then ret = {} end
-- 		ret.peng = _pai
-- 	end

-- 	if (_pai_map[_pai] or 0) >= 3 then
-- 		if not ret then ret = {} end
-- 		ret.gang = _is_self and "ag" or "zg"
-- 	elseif _is_self and (_pai_pg_map[_pai] or 0) >= 3 then
-- 		if not ret then ret = {} end
-- 		ret.gang = "wg"
-- 	end

-- 	-- 调用胡牌函数
-- 	local _count = _pai_map[_pai] or 0
-- 	_pai_map[_pai] = _count + 1
-- 	local hu_pai = self:get_hupai_info(_pai_map,_pai_pg_map)
-- 	_pai_map[_pai] = _count > 0 and _count or nil

-- 	if hu_pai then
-- 		if not ret then ret = {} end
-- 		ret.hu = hu_pai
-- 	end

-- 	return ret
-- end

function nor_mj_algorithm.transform_seat(seatNum,s2cSeatNum,mySeatNum, maxP)
    maxP = maxP or 4
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
---------------------------------------------
---- 获取默认的换三张的牌
function nor_mj_algorithm:get_default_huansanzhang_pai(pai_map)
	local ret = {}
	--[[local selectNum = 0
	local totalNum = 3
	for i=11,39 do
		if pai_map[i] and pai_map[i] > 0 then
			ret[#ret+1] = i
			selectNum = selectNum + 1
			if selectNum >= totalNum then
				break
			end
		end
	end--]]

	--- 花色的数量
	local flowerNumVec = {}        
	local singlePaiVec = {}
	local singlePaiKeyVec = {}
	local singleFlowerNumVec = {0,0,0}
	local lastFlower = 0
	
	for i=11,39 do
		if pai_map[i] and pai_map[i] > 0 then
			local flowerIndex = math.floor(i/10)
			local lastIndex = #flowerNumVec
			if lastFlower ~= flowerIndex then
				lastFlower = flowerIndex
				lastIndex = #flowerNumVec + 1
			end


			flowerNumVec[lastIndex] = flowerNumVec[lastIndex] or {}
			flowerNumVec[lastIndex].flowerIndex = flowerIndex
			flowerNumVec[lastIndex].paiNum = flowerNumVec[lastIndex].paiNum or 0
			flowerNumVec[lastIndex].paiNum = flowerNumVec[lastIndex].paiNum + pai_map[i]
			flowerNumVec[lastIndex].paiMap = flowerNumVec[lastIndex].paiMap or {}
			for key = 1,pai_map[i] do
				flowerNumVec[lastIndex].paiMap[#flowerNumVec[lastIndex].paiMap + 1] = i
			end

			if pai_map[i] == 1 then
				local offset = -1
				local shunziNum = 1
				local index = 0
				local offsetIndex = 0
				while true do
					index = index + 1
					offsetIndex = offsetIndex + 1
					if index >= 4 then
						break
					end

					local nextIndex = i+offset*offsetIndex
					if pai_map[nextIndex] and pai_map[nextIndex] > 0 then 
						shunziNum = shunziNum + 1
					else
						if offset ~= 1 then
							offset = 1
							offsetIndex = 0
						else
							break
						end
					end

				end	
				--- 确认是单牌
				if shunziNum < 2 then
					singlePaiVec[#singlePaiVec+1] = i
					singlePaiKeyVec[i] = 1
					singleFlowerNumVec[flowerIndex] = singleFlowerNumVec[flowerIndex] or 0
					singleFlowerNumVec[flowerIndex] = singleFlowerNumVec[flowerIndex] + 1
				end

			end

		end
	end

	--- 获得一个单牌的数组
	local getSinglePaiVec = function( ret , startFlowerIndex , getPaiNum )
		--local ret = {}
		local startIndex = startFlowerIndex*10
		local findNum = 0
		local index = 0
		while true do
			index = index + 1
			if index > 39 then
				break
			end

			startIndex = startIndex + 1
			if startIndex > 39 then
				startIndex = 11
			end

			if singlePaiKeyVec[startIndex] and singlePaiKeyVec[startIndex] == 1 then
				findNum = findNum + 1
				ret[#ret+1] = startIndex

				if findNum >= getPaiNum then
					break
				end
			end
		end
		return ret
	end

	print("<color=yellow>------------- #flowerNumVec: </color>",#flowerNumVec)
	dump(singleFlowerNumVec,"<color=yellow>------------- singleFlowerNumVec: </color>")
	
	----------------------------------------------------------------------------------------------------------------------
	if #flowerNumVec == 3 then	
		--- 如果花色等于三张，选花色最少的。
		local firstFlowerIndex = flowerNumVec[1].flowerIndex
		local secondFlowerIndex = flowerNumVec[2].flowerIndex
		local thirdFlowerIndex = flowerNumVec[3].flowerIndex

		local paiNumVec = basefunc.deepcopy(flowerNumVec)
		table.sort( paiNumVec , function(a,b) 	
			return a.paiNum < b.paiNum
		end)
		dump( paiNumVec , "---------------------- get_default_huansanzhang_pai,paiNumVec" )

		if paiNumVec[1].paiNum < 3 then
			return paiNumVec[1].paiMap
		elseif paiNumVec[1].paiNum == 3 then
			if paiNumVec[2].paiNum ~= 3 then
				return paiNumVec[1].paiMap
			else
				local random = math.random()
				if random > 0.5 then
					return paiNumVec[1].paiMap
				else
					return paiNumVec[2].paiMap
				end
			end
		elseif paiNumVec[1].paiNum > 3 then
			local targetVec = paiNumVec[1]
			---- 两个4 ，任选1
			if paiNumVec[1].paiNum == 4 and paiNumVec[2].paiNum == 4 then
				local random = math.random()
				if random > 0.5 then
					targetVec = paiNumVec[1]
				else
					targetVec = paiNumVec[2]
				end
			end

			local random_index = math.random(1,targetVec.paiNum)	

			local ret = {}
			for i=1,3 do
				local targetIndex = (random_index + (i-1) - 1) % targetVec.paiNum + 1

				ret[#ret+1] = targetVec.paiMap[targetIndex]
			end
			return ret
		end

	else
		---- 如果两人麻将，牌池花色 不等于3 ，那么选牌规则是 选单牌
		--[[if #singlePaiVec <= 3 then
			return singlePaiVec
		else
			--- 大于3个，随机选3个出来
			local randomPaiVec = {}

			local indexSelectVec = {}
			local selectNum = 0

			for key,pai in ipairs(singlePaiVec) do
				local randomValue = math.random()
				if randomValue < 0.5 then
					indexSelectVec[key] = true
					selectNum = selectNum + 1
				end
				if selectNum >= 3 then
					break
				end
			end

			if selectNum < 3 then
				for key,pai in ipairs(singlePaiVec) do
					if not indexSelectVec[key] then
						indexSelectVec[key] = true
						selectNum = selectNum + 1
					end
					if selectNum >= 3 then
						break
					end
				end
			end

			-----
			for key,value in pairs(indexSelectVec) do
				ret[#ret + 1] = singlePaiVec[key]
			end

			--getSinglePaiVec(ret , numMoreFlowerIndex , 3)
		end--]]
	end

	dump(ret , "<color=yellow>------------- get_default_huansanzhang_pai: </color>")
	return ret
end




return nor_mj_algorithm






