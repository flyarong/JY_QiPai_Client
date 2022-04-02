-- 创建时间:2018-06-01

AwardManager = {}

-- award字典
AwardManager.GetAwardTable = function(award)
    local tab = {}
    if not award then
        return tab
    end
    for k, v in pairs(award) do
        local cfg = GameItemModel.GetItemToKey(k)
        if cfg then
            local tt = {}
            tt.image = cfg.image
            tt.is_local_icon = cfg.is_local_icon
            if tonumber(v) then
                v = tonumber(v)
                if k == "shop_gold_sum" then
                    tt.number = v / 100
                elseif k == "cash" then
                    tt.number = v / 100
                elseif k == "prop_npca_hb" then
                    tt.number = v / 100    
                else
                    tt.number = v
                end
            else
                tt.number = tonumber(v.num) or 1
            end
            tab[#tab + 1] = tt
        end
    end
    return tab
end

-- award数组
-- 处理奖励列表
AwardManager.GetAwardList = function(award)
    local tab = {}
    if not award then
        return tab
    end
    for k, v in ipairs(award) do
        local atype = v.asset_type
        local cfg = GameItemModel.GetItemToKey(atype)
        local name = cfg and cfg.name or "道具"
        if atype == "shop_gold_sum" then
            local tt = {}
            tt.type = atype
            tt.value = v.value / 100
            tt.desc = name .. ": " .. tt.value
            tab[#tab + 1] = tt
        elseif atype == "cash" then
            local tt = {}
            tt.type = atype
            tt.value = v.value / 100
            tt.desc = name .. ": " .. tt.value .. "元"
            tab[#tab + 1] = tt
        else
            local tt = {}
            tt.type = atype
            tt.value = v.value
            tt.desc = name .. " X" .. tt.value
            tab[#tab + 1] = tt
        end
    end
    return tab
end

-- 奖励的Icon名
AwardManager.GetAwardImage = function(k)
    local cfg = GameItemModel.GetItemToKey(k)
    if cfg then
        local tt = {}
        tt.image = cfg.image
        tt.is_local_icon = cfg.is_local_icon
        return tt
    else
        local tt = {}
        tt.image = "com_btn_close"
        tt.is_local_icon = 1
        return tt
    end
end

-- 奖励的名称
AwardManager.GetAwardName = function(atype)
    local cfg = GameItemModel.GetItemToKey(atype)
    if cfg then
        return cfg.name
    else
        return "" .. atype
    end
end

-- 获得奖励的列表
AwardManager.GetAssetsList = function(award)
	local tab = {}
    if not award then
        return tab
    end
	for k, v in ipairs(award) do
		local atype = v.asset_type
		local asset = GameItemModel.GetItemToKey(atype)
		local tt = {}
		if asset then
			tt.type = atype
			tt.image = asset.image
			tt.is_local_icon = asset.is_local_icon
			if atype == "shop_gold_sum" then
				tt.value =StringHelper.ToRedNum(v.value / 100)
                tt.desc = asset.name .. " x" .. tt.value
            elseif atype == "prop_npca_hb" then
                tt.value =StringHelper.ToRedNum(v.value / 100)
                tt.desc = asset.name .. " x" .. tt.value
			elseif atype == "cash" then
				tt.value =StringHelper.ToRedNum(v.value / 100)
				tt.desc = asset.name .. " x" .. tt.value .. "元"
			elseif atype == "jing_bi" or atype == "diamond" or atype == "fish_coin" then
				tt.value = StringHelper.ToCash(v.value)
				tt.desc = asset.name .. " x" .. tt.value
			elseif atype == "jipaiqi" then
				tt.value = v.value
				tt.desc = asset.name .. " (" .. tt.value .. "天)"
			elseif atype == "shop_gold_sum_limit" then
				tt.value = v.value
				tt.desc = asset.name .. " +" .. tt.value
			else
				tt.value = v.value
				tt.desc = asset.name .. " x" .. tt.value
			end
			tt.desc_extra = asset.desc_extra or ""
		else
			tt.type = atype
			tt.value = v.value
			tt.desc = "???" .. atype
			tt.is_local_icon = 1
			tt.image = "com_btn_close"
		end
		tab[#tab + 1] = tt
    end
    return tab
end

-- 奖励的名称
AwardManager.GetAwardName = function(atype)
    local cfg = GameItemModel.GetItemToKey(atype)
    if cfg then
        return cfg.name
    else
        return "" .. atype
    end
end

-- 获得奖励的列表
AwardManager.GetHonorAssetsList = function(award)
    local tab = {}
    if not award then
        return tab
    end
    for k, v in ipairs(award) do
        local atype = v.asset_type
		local asset = GameItemModel.GetItemToKey(atype)
		local tt = {}
		if asset then
			tt.type = atype
			tt.image = asset.image
            tt.is_local_icon = asset.is_local_icon
            if atype == "shop_gold_sum" then
                tt.value =StringHelper.ToRedNum(v.value / 100)
                tt.desc = asset.name .. " x" .. tt.value
            elseif atype == "jing_bi" or atype == "diamond" or atype == "fish_coin" then
                tt.value = StringHelper.ToCash(v.value)
                tt.desc = asset.name .. " x" .. tt.value
            elseif atype == "jipaiqi" then
                tt.value = v.value
                tt.desc = asset.name .. " (" .. tt.value .. "天)"
            elseif atype == "shop_gold_sum_limit" then
                tt.value = v.value
                tt.desc = asset.name .. " +" .. tt.value
            elseif string.match( atype, "frame" ) then
                tt.value = v.value
                tt.desc = asset.name .. " 头像框"
            else
                tt.value = v.value
                tt.desc = asset.name .. " x" .. tt.value
			end
		else
			tt.type = atype
			tt.value = v.value
			tt.desc = "???" .. atype
            tt.is_local_icon = 1
			tt.image = "com_btn_close"
		end
		tab[#tab + 1] = tt
    end
    return tab
end

-- 获得奖励的列表
AwardManager.GetLockAssetList = function(award)
    local tab = {}
    if not award then
        return tab
    end
    for k, v in ipairs(award) do
        local atype = v.asset_type
        local asset = PersonalInfoManager.GetConfigMap(v.value)
        dump(asset, "<color=green>解锁物品</color>".. v.value)
		local tt = {}
		if asset then
			tt.type = atype
            tt.image = asset.icon
            tt.desc = asset.name
            tt.value = v.value
		else
			tt.type = atype
			tt.value = v.value
			tt.desc = "???" .. atype
			tt.image = "com_btn_close"
		end
		tab[#tab + 1] = tt
    end
    return tab
end