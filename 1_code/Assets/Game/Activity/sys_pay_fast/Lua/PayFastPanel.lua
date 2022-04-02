-- 创建时间:2018-07-14
-- 快速购买

local basefunc = require "Game.Common.basefunc"

PayFastPanel = basefunc.class()

function PayFastPanel.Create(config, signup)
    -- 本来要共用一个调用，最后还是将匹配场的和其它的分开了
    if config.match_type then
        return PayFastFreePanel.Create(config, signup)
    end
    return PayFastOtherPanel.Create(config, signup)
end
