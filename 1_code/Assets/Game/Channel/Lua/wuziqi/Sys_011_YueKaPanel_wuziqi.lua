local basefunc = require "Game.Common.basefunc"

Sys_011_YueKaPanel_wuziqi = basefunc.class()
local C = Sys_011_YueKaPanel_wuziqi
C.name = "Sys_011_YueKaPanel_wuziqi"

function C.HandleInit(base_self)
	if not base_self then return end
	if IsEquals(base_self.jika_btn) then
		base_self.jika_btn.gameObject:SetActive(false)
	end
	if IsEquals(base_self.yueka_node) then
		base_self.yueka_node.transform.localPosition = Vector3.zero
	end
	local ui
	ui = base_self.transform:Find("@Big/Image (1)")
	if IsEquals(ui) then
		ui.transform.localPosition = Vector3.New(0,ui.transform.localPosition.y,0)
	end
	ui = nil
end

return C.HandleInit