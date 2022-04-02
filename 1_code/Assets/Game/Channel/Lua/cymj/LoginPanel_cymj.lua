local basefunc = require "Game.Common.basefunc"

LoginPanel_cymj = basefunc.class()
local C = LoginPanel_cymj
C.name = "LoginPanel_cymj"

function C.HandleInit(panel)

	if not panel then return end

	local transform = panel.transform
	if not IsEquals(transform) then return end

	local pn_txt = transform:Find("Image/pn_txt"):GetComponent("Text")

    pn_txt.text="文网文证号：川网文(2017)8862-373号  新广出审[2018]1561号：978-7-498-04903-2  著作权人：四川高手互娱网络科技有限公司"
end

return C.HandleInit
