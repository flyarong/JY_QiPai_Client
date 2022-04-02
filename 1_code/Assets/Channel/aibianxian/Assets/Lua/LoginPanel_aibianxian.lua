local basefunc = require "Game.Common.basefunc"

LoginPanel_aibianxian = basefunc.class()
local C = LoginPanel_aibianxian
C.name = "LoginPanel_aibianxian"

function C.HandleInit(panel)

	if not panel then return end

	local transform = panel.transform
	if not IsEquals(transform) then return end

	local logo = transform:Find("login_logo")
	if logo then
		logo.gameObject:SetActive(false)
	end

	local pn_txt = transform:Find("Image/pn_txt"):GetComponent("Text")

    pn_txt.text="文网文证号：川网文(2018)0367-008号  国新出审[2019]1382号：978-7-498-06486-8  著作权人：四川竟娱互动网络科技有限公司"
end

return C.HandleInit
