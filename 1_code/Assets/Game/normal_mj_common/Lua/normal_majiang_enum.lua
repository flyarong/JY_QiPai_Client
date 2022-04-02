--
-- Author: gsf
-- Date: 2018/6/25
-- Time: 10:31
-- 说明：麻将公用的 枚举变量

-- 
NOR_MAJIANG_MULTI_TYPE =
{
	ping_hu = "平胡",
	
	dai_geng = "带根",

	qing_yi_se = "清一色",
    da_dui_zi = "大对子",
    qi_dui = "七对",
	long_qi_dui = "龙七对",

	jiang_dui= "将对",
    men_qing = "门清",
    zhong_zhang = "中张",
    jin_gou_diao = "金钩钓",
     yao_jiu = "幺九",

	hai_di_ly = "海底捞月",
	hai_di_pao = "海底炮",
    tian_hu = "天胡",
    di_hu = "地胡",
    gang_shang_hua = "杠上花",
	gang_shang_pao = "杠上炮",

	zimo = "自摸",
    qiangganghu = "抢杠胡", 
}

NOR_MAJIANG_SETTLE_TYPE =
{
	hu = "胡牌",
	ting = "听牌",
	wujiao =  "",--"未听牌"
	hz =  "花猪",
}

NOR_MAJIANG_HU_TYPE =
{
	zimo = "自摸",
	pao = "点炮胡",
	qghu = "抢杠胡",
	tian_hu = "天胡",
}


NOR_GANG_TYPE =
{
	wg = "弯杠",
	zg = "直杠",
	ag = "暗杠",
}

local share_pai_type =
{
	qing_yi_se = "清一色",
    da_dui_zi = "大对子",
	long_qi_dui = "龙七对",
	jiang_dui= "将对",
    jin_gou_diao = "金钩钓",
}
local share_hu_type = 
{
	hai_di_ly = "海底捞月",
	hai_di_pao = "海底炮",
    tian_hu = "天胡",
    di_hu = "地胡",
    gang_shang_hua = "杠上花",
	gang_shang_pao = "杠上炮",
    qghu = "抢杠胡",
}
function IsMjShareCondition(data, share_fan_shu)
	local pai_type
	local hu_type
	local fanshu = 0
	if data then
		for k,v in pairs(data) do
			fanshu = fanshu + v
			if share_pai_type[k] and not pai_type then
				pai_type = k
			end
			if share_hu_type[k] and not hu_type then
				hu_type = k
			end
		end
	end
	if fanshu >= share_fan_shu then
		if not pai_type and not hu_type then
			return "",""
		else
			return pai_type,hu_type
		end
	end
	return nil,nil
end

