-- 创建时间:2020-03-05
-- Panel:FishingActCaijinEnterPrefab
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

FishingActCaijinEnterPrefab = basefunc.class()
local C = FishingActCaijinEnterPrefab
C.name = "FishingActCaijinEnterPrefab"
local M = BYActCaijinManager

local tips_speed = 200
local wait_time = 2

local TipsState = 
{
	Close = 0, -- 关闭 
	Enter = 1, -- 进入
	Wait = 2, -- 等待
	Exit = 3, -- 退出
}

function C.Create(parent)
	return C.New(parent)
end
function C:AddMsgListener()
	for proto_name, func in pairs(self.lister) do
		Event.AddListener(proto_name, func)
	end
end

function C:MakeLister()
	self.lister = {}
	self.lister["model_by_act_caijin_change"] = basefunc.handler(self, self.on_caijin_change)
	self.lister["model_by_act_caijin_all_info"] = basefunc.handler(self, self.on_all_info)
	self.lister["model_by_act_caijin_lottery"] = basefunc.handler(self, self.on_caijin_lottery)
end

function C:RemoveListener()
	for proto_name, func in pairs(self.lister) do
		Event.RemoveListener(proto_name, func)
	end
	self.lister = {}
end

function C:MyExit()
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:OnDestroy()
	if self.updateTimer then
        self.updateTimer:Stop()
        self.updateTimer=nil
	end

	self:MyExit()
end

function C:ctor(parent)
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self) 
	self.transform.localPosition = Vector3.zero

	self.tipsState = TipsState.Close
	self.curWaitTime = 0

	self.last_tick = os.clock()
	self.updateTimer = Timer.New(basefunc.handler(self, self.update), 0.016, -1, nil, true)
	self.updateTimer:Start()

	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()

	M.QueryCaijinAllInfo()
end

function C:InitUI()
	self.prog_default_rect = self.prog_bar.rect

	self.enter_btn.onClick:AddListener(function()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnEnterClick()
	end)
	
	self:MyRefresh()
end

function C:on_all_info()
	dump( "<color=red>on_caijin_all_info</color>")
	
	local data = M.GetCaijinData()

	if data.result ~= 0 then 
		self:MyExit() 
		return
	end

	self:MyRefresh()
end

function C:checkLotteryNum()
	local d = M.GetCaijinData()
	local next = d.lottery_num + 1

	return next >= 1 and next <= #M.caijin_config.caijin_condition_config
	--return true
end


function C:on_caijin_change()
	self:refreshLotteryButton()
	self:refreshLotteryTips()
end

function C:on_caijin_lottery()

	local data = M.GetCaijinData()

	self:MyRefresh()
end

function C:refreshLotteryButton()
	if self:checkLotteryNum() then
		local type = self:findCurentType()
		self:setButtonType(type)
	else
		self:setButtonType(-1)
	end
	--self.enter_btn.gameObject:SetActive(type > 0)
end

function C:refreshLotteryTips()
	if self:checkLotteryNum() then
		self:addLotteryTip()
		self:refreshLotteryTipsInfo()
	end
end

function C:addLotteryTip()
	if self.tipsState == TipsState.Close then
		self.tipsState = TipsState.Enter
	elseif self.tipsState == TipsState.Enter then
	elseif self.tipsState == TipsState.Wait then
		self.curWaitTime = wait_time
	elseif self.tipsState == TipsState.Exit then
		self.tipsState = TipsState.Enter
	end
end

function C:refreshLotteryTipsInfo()
	local data = M.GetCaijinData()
	self.gold_change_txt.text = string.format("+%d", data.score_change)

	local type = self:findCurentType()
	local next = type + 1
	if next > #M.caijin_config.caijin_type_config then
		self:SetProgress(1, 1)
	else
		self:SetProgress(data.score, M.caijin_config.caijin_type_config[next].score_limit)
	end

end

function C:SetProgress(cur, total)
	percent = cur / total

	if percent < 0 then
		percent = 0
	elseif percent > 1 then
		percent = 1
	end

	if percent > 0 and percent < 0.08 then
		percent = 0.08
	end 

	self.prog_bar.sizeDelta = {x = self.prog_default_rect.width * percent, y = self.prog_default_rect.height}
end

function C:update()
	local cur_tick = os.clock()
	local dt = cur_tick - self.last_tick

	if self.tipsState == TipsState.Close then
		self.tips_panel.gameObject:SetActive(true)
		self:setTipsPanelPosX(0)
	elseif self.tipsState == TipsState.Enter then
		self.tips_panel.gameObject:SetActive(true)
		self:setTipsPanelPosX(self.tips_panel.gameObject.transform.localPosition.x + dt * tips_speed)
		if self.tips_panel.gameObject.transform.localPosition.x >= self.tips_panel.gameObject.transform.rect.width then
			self:setTipsPanelPosX(self.tips_panel.gameObject.transform.rect.width)
			self.tipsState = TipsState.Wait
			self.curWaitTime = wait_time
		end
	elseif self.tipsState == TipsState.Wait then
		self.tips_panel.gameObject:SetActive(true)
		self.curWaitTime = self.curWaitTime - dt
		if self.curWaitTime <= 0 then
			self.curWaitTime = 0
			self.tipsState = TipsState.Exit
		end
	elseif self.tipsState == TipsState.Exit then
		self.tips_panel.gameObject:SetActive(true)
		self:setTipsPanelPosX(self.tips_panel.gameObject.transform.localPosition.x - dt * tips_speed)
		if self.tips_panel.gameObject.transform.localPosition.x <= 0 then
			self:setTipsPanelPosX(0)
			self.tipsState = TipsState.Close
		end
	else
		assert(0)
	end

	self.last_tick = cur_tick
end

function C:setTipsPanelPosX(x)
	local v = Vector3.New(x, self.tips_panel.gameObject.transform.localPosition.y, self.tips_panel.gameObject.transform.localPosition.z)
	self.tips_panel.gameObject.transform.localPosition = v
end

function C:setButtonType(type)
	if type > 0 then
		self.btn_type_img.gameObject:SetActive(true)
		self.btn_type_img.sprite = GetTexture("jjcjy_imgf_ts"..type)
	else
		self.btn_type_img.gameObject:SetActive(false)
	end
end

function C:OnEnterClick()
	FishingActCaijinPanel.Create()
end

function C:MyRefresh()
	self:refreshLotteryButton()
	self:refreshLotteryTipsInfo()
	self:update()
end

function C:findCurentType()
	local d = M.GetCaijinData()

	local total = #M.caijin_config.caijin_type_config
	for i = total, 1, -1 do
		if d.score >= M.caijin_config.caijin_type_config[i].score_limit then
			return M.caijin_config.caijin_type_config[i].type
		end
    end

    return 0
end

--[[
	GetTexture("jjcjy_imgf_ts1")
	GetTexture("jjcjy_imgf_ts2")
	GetTexture("jjcjy_imgf_ts3")
	GetTexture("jjcjy_imgf_ts4")
	GetTexture("jjcjy_imgf_ts5")
	GetTexture("jjcjy_imgf_ts6")
]]