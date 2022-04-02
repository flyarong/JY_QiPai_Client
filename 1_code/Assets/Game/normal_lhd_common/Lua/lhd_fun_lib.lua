-- 创建时间:2020-02-17

local basefunc = require "Game.Common.basefunc"

lhd_fun_lib = {}
local C = lhd_fun_lib

-- 牌的值
function C.get_pai_info(val)
	local hs = (val - 1) % 4 + 1 -- (4黑桃 3红心 2梅花 1方)
	local ds = math.floor( (val + 3) / 4) -- 1表示8 2表示9 3表示10 4表示J 。。。

    local paiType = ds + 7
    local noIcon = "poker_icon_"
    local typeIcon = "poker_"
    if hs == 4 then
        noIcon = noIcon .. "nb" .. paiType
        typeIcon = typeIcon .. "spade"
    elseif hs == 3 then
        noIcon = noIcon .. "nr" .. paiType
        typeIcon = typeIcon .. "heart"
    elseif hs == 2 then
        noIcon = noIcon .. "nb" .. paiType
        typeIcon = typeIcon .. "plum"
    elseif hs == 1 then
        noIcon = noIcon .. "nr" .. paiType
        typeIcon = typeIcon .. "block"
    end

    return {hs=hs,num=ds, numIcon = noIcon, hsIcon=typeIcon}
end

