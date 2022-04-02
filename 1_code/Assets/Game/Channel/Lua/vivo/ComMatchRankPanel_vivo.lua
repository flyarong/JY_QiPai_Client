
local basefunc = require "Game.Common.basefunc"

ComMatchRankPanel_vivo = basefunc.class()
local M = ComMatchRankPanel_vivo
M.name = "ComMatchRankPanel_vivo"

function M.HandleInit(base_self)
   if not base_self then return end

    local transform = base_self.transform
    if not IsEquals(transform) then return end
    base_self.share_btn.gameObject:SetActive(false)
    base_self.Share2Wx_btn.gameObject:SetActive(false)
    base_self.Share2Pyq_btn.gameObject:SetActive(false)
end

return M.HandleInit