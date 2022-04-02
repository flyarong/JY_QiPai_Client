-- 创建时间:2020-03-18
-- Panel:SYSMFLHBEnterPrefab
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

SYSMFLHBEnterPrefab = basefunc.class()
local C = SYSMFLHBEnterPrefab
C.name = "SYSMFLHBEnterPrefab"
local M = SYSMFLHBManager

function C.Create(parent, parm)
	return C.New(parent, parm)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["model_everyday_free_hb_msg_sys_mflhb"] = basefunc.handler(self, self.on_model_everyday_free_hb_msg_sys_mflhb)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	self:RemoveListener()
	destroy(self.gameObject)
end
function C:OnDestroy()
	self:MyExit()
end

function C:ctor(parent, parm)
	local obj = newObject("MFLHBEnterPrefab", parent)
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
end

function C:MyRefresh()

end

function C:on_model_everyday_free_hb_msg_sys_mflhb()
	self:MyRefresh()
end

function C:OnEnterClick()
	local num = M.GetNum()
	if num > 0 then
		local cd = M.GetCD()
		if cd == 0 then
			self:PlayAD()
		else
			LittleTips.Create("玩一会，" .. StringHelper.formatTimeDHMS(cd) .. "后再来领奖哦！")
		end
	else
		LittleTips.Create("领取次数已达到上限，请明日再来领取！")
	end
end

function C:PlayAD()
	AdvertisingManager.RandPlay("mflhb", function (data)
        if data.result == 0 and data.isVerify then
			if SYSMFLHBManager.GetHintState() == ACTIVITY_HINT_STATUS_ENUM.AT_Get then
				Network.SendRequest("get_everyday_free_hb", nil, "领取")
			else
				LittleTips.Create("不能领取")
			end
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
