local basefunc = require "Game.Common.basefunc"

MiniGameHallPanel_wuziqi = basefunc.class()
local C = MiniGameHallPanel_wuziqi
C.name = "MiniGameHallPanel_wuziqi"


local function IsSecondDayMiniGameEnter()
	local _permission_key = "next_day_gswzq"  --次日登录的权限
	local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key=_permission_key, is_on_hint = true}, "CheckCondition")
	if a and not b then
		return  false
	end
	return true
end

local function GetPreName( _base_self, _key)
	for k,v in pairs(_base_self.pre_config) do
		if v.key == _key then
			return v.pre_name
		end
	end
end

function C.HandleInit(base_self)
    if not base_self then return end
	local ui = base_self.transform:Find("TopRect/RectTop/TitleImage")
	if IsEquals(ui) then
		ui = ui.transform:GetComponent("Image")
		ui.sprite = GetTexture("hbc_imgf_hbc")
	end
	ui = nil

	--次日登录游戏，游戏大厅中敲敲乐小游戏入口改为水果消消乐游戏入口
	--并在红包场中增加敲敲乐小游戏入口，同时去掉红包场中水果消消乐小游戏入口
	local unEnablePreKey 
	if IsSecondDayMiniGameEnter() then --[水果消消乐]入口隐藏
		dump(IsSecondDayMiniGameEnter() , "<color=red>true次日登录</color>")
		unEnablePreKey = "xxl"
	else --[敲敲乐]入口隐藏
		dump(IsSecondDayMiniGameEnter() , "<color=red>非次日登录</color>")
		unEnablePreKey = "qql"
	end

	local unEnablePre =  base_self.Content:Find(GetPreName(base_self,unEnablePreKey))
	unEnablePre.gameObject:SetActive(false)
end


return C.HandleInit