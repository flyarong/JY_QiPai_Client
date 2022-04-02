-- 创建时间:2020-01-06
-- Panel:SJJBJLEnterPrefab
--[[
 *      ┌─┐       ┌─┐
 *   ┌──┘ ┴───────┘ ┴──┐
 *   │                 │
 *   │       ───       │
 *   │  ─┬┘       └┬─  │
 *   │                 │
 *   │       ─┴─       │
 *   │                 │
 *   └───┐         ┌───┘
 *       │         │
 *       │         │
 *       │         │
 *       │         └──────────────┐
 *       │                        │
 *       │                        ├─┐
 *       │                        ┌─┘
 *       │                        │
 *       └─┐  ┐  ┌───────┬──┐  ┌──┘
 *         │ ─┤ ─┤       │ ─┤ ─┤
 *         └──┴──┘       └──┴──┘
 *                神兽保佑
 *               代码无BUG!
 --]]

local basefunc = require "Game/Common/basefunc"

SJJBJLEnterPrefab = basefunc.class()
local C = SJJBJLEnterPrefab
C.name = "SJJBJLEnterPrefab"

function C.Create(parent, cfg)
	return C.New(parent, cfg)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
	self.lister["global_hint_state_change_msg"] = basefunc.handler(self, self.on_global_hint_state_change_msg)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	SYSSJJBJLManager.m_data.state = 0
	self:RemoveListener()
	destroy(self.gameObject)
end
function C:OnDestroy()
	self:MyExit()
end

function C:ctor(parent, cfg)
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	self.transform.localPosition = Vector3.zero

	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	self.enter_btn = self.transform:GetComponent("Button")
	self.enter_btn.onClick:AddListener(function ()
    	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnEnterClick()
	end)
	self:MyRefresh()
	DSM.ADTrigger("sjjbjl")
end

function C:MyRefresh()
	-- 所有看广告后的额外鲸币奖励砍半
    local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key="drt_cpl_half_ad_award", is_on_hint = true}, "CheckCondition")
    if a and b then
        self.hint_txt.text = "500-5万"
    else
        self.hint_txt.text = "1千-10万"
    end
	if not SYSSJJBJLManager.m_data.state or SYSSJJBJLManager.m_data.state ~= 1 then
	    Event.Brocast("ui_button_state_change_msg")
        return
    end
end

function C:OnEnterClick()
	AdvertisingManager.RandPlay("sjjbjl", function (data)
        if data.result == 0 and data.isVerify then
			Network.SendRequest("fg_get_random_jingbi_box_award", nil, "")
        else
            if data.result ~= -999 then
                if data.isVerify then
                    HintPanel.Create(1, "广告观看失败，请重新观看")
                else
                    HintPanel.Create(1, "您的网络不稳定，待网络稳定后请重试")
                end
            end
        end
    end)
end

function C:on_global_hint_state_change_msg(parm)
	if parm.gotoui == SYSSJJBJLManager.key then
		self:MyRefresh()
	end
end