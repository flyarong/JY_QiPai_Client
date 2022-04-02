--
-- Author: lyx
-- Date: 2018/4/14
-- Time: 10:31
-- 说明：血战到底 配置转换 函数
--

local basefunc = require "Game.Common.basefunc"

local mj_xzdd = {}

mj_xzdd.trans = 
{
	-- 封顶
	feng_ding_3f = {{name="feng_ding",value=3}},
	feng_ding_4f = {{name="feng_ding",value=4}},
	feng_ding_5f = {{name="feng_ding",value=5}},
	feng_ding_8f = {{name="feng_ding",value=8}},

	-- 自摸模式： 自摸加番，自摸加点
	zimo_jiafan = {{group="zimo_model",value=1}},
	zimo_jiadi = {{group="zimo_model",value=1}},

	da_dui_zi_x2 = {{name="da_dui_zi",value=1}},
	hai_di_ly_x2 = {{name="hai_di_ly",value=1}},  
	hai_di_pao_x2 = {{name="hai_di_pao",value=1}},

	-- 天地胡
	tian_di_hu = {{name="tian_hu",value=5}, {name="di_hu",value=5}},
}

-- 开关配置
mj_xzdd.kaiguan = 
{
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

-- 番数配置
mj_xzdd.multi = 
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
	jin_gou_diao    = 2, --金钩钓
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


-- 转换 游戏规则
-- 返回值： 开关表，番数表
function mj_xzdd.translate(_options)
	
	local ret = {
		kaiguan = basefunc.deepcopy(mj_xzdd.kaiguan),
		multi = basefunc.deepcopy(mj_xzdd.multi),
	}

	-- 先把 trans 中的开关默认为 false
	for _name,_trans in pairs(mj_xzdd.trans) do
		for _,_opt in ipairs(_trans) do
			local _real_name = _opt.name or _name
			ret.kaiguan[_real_name] = false
		end
	end

	for _,_opt in ipairs(_options) do
		if _opt.option ~= "empty" then
			local _trans = mj_xzdd.trans[_opt.option]
			if _trans then
				-- 处理每一项
				for _,_real_opt in ipairs(_trans) do

					-- 真实选项名字
					local _real_name = _real_opt.name or _opt.option

					ret.kaiguan[_real_name] = true
					ret.multi[_real_name] = _opt.value
				end
			end
		end
	end
	
	return ret
end

return mj_xzdd