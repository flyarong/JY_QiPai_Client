-- 创建时间:2020-01-06
-- Panel:SYSMFLHB_JYFLEnterPrefab
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

SYSMFLHB_JYFLEnterPrefab = basefunc.class()
local C = SYSMFLHB_JYFLEnterPrefab
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
    self.lister["global_hint_state_change_msg"] = basefunc.handler(self, self.on_global_hint_state_change_msg)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	-- 清除状态
	SYSMFLHBManager.m_data.get_state = 0
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:ctor(parent, parm)
	self.parm = parm
	ExtPanel.ExtMsg(self)
	local obj = newObject("MFLHBCellPrefab", parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	self.get_img = self.get_btn.transform:GetComponent("Image")

	self:MakeLister()
	self:AddMsgListener()

	self:InitUI()
end

function C:InitUI()
	self.BG_btn.onClick:AddListener(function ()
    	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnEnterClick()
	end)
	self.get_btn.onClick:AddListener(function ()
    	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnGetClick()
	end)
	self.title_img.sprite = GetTexture("jyfl_btn_mfhb")

	self:MyRefresh()
	DSM.ADTrigger("mflhb")
end

function C:MyRefresh()
	local num = M.GetNum()
	if not num then num = "" end
	self.title_txt.text = "免费领福卡"
	self.info_txt.text = "点击后随机获得0.01-1福卡(今日可领" .. num ..  "次)"
	if num > 0 then
		local cd = M.GetCD()
		if cd == 0 and SYSMFLHBManager.GetHintState() == ACTIVITY_HINT_STATUS_ENUM.AT_Get then
			self.get_txt.text = "领 取"
			self.get_img.sprite = GetTexture("com_btn_5")
		else
			self.get_img.sprite = GetTexture("com_btn_8")
			self.get_txt.text = "稍后领取"
		end
	else
		self.get_txt.text = "明日再来"
		self.get_img.sprite = GetTexture("com_btn_8")
	end
end

function C:OnEnterClick()
	self:OnGetClick()
end
function C:OnGetClick()
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

function C:OnDestroy()
	self:MyExit()
end

function C:on_global_hint_state_change_msg(parm)
	if parm.gotoui == SYSMFLHBManager.key then
		self:MyRefresh()
	end
end

