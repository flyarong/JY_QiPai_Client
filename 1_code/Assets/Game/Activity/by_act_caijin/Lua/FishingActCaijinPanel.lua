-- 创建时间:2020-02-19
-- Panel:FishingActCaijinPanel
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

FishingActCaijinPanel = basefunc.class()
local C = FishingActCaijinPanel
C.name = "FishingActCaijinPanel"
local M = BYActCaijinManager

local award_round = 3
local award_tick = 0.1

local type_count = 6
local award_count = 6

local delayTimer

function C.Create()
	return C.New()

end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
	self.lister = {}
	--self.lister["model_by_act_caijin_all_info"] = basefunc.handler(self, self.on_all_info)
	self.lister["model_by_act_caijin_lottery"] = basefunc.handler(self, self.on_caijin_lottery)
	self.lister["AssetChange"] = basefunc.handler(self, self.OnAssetChange)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	if delayTimer then
        delayTimer:Stop()
        delayTimer=nil
	end
	
    self:BoxExit()
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:ctor()

	ExtPanel.ExtMsg(self)

	print("FishingActCaijinPanel init!")
	local parent = GameObject.Find("Canvas/LayerLv5").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self.choose_type = 1
	self.is_wait = false
	self._curChooseAward = 0
	self.wait_award_data = nil

	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	
	self.timer_count = 10
end

function C:InitUI()
	-- self.Text2 = self.helpPanel:find("Text2"):GetComponent("Text")
	-- self.Text2.text = 
	-- [[1.玩家在游戏内击杀奖金鱼：黄金锤头鲨、胖胖鱼、黄金大白鲨、黄金魔鬼鱼、黄金灯笼鱼、黄金海龟，会有10%的鲸币进入奖池，用于抽奖。
	-- 2.免费抽奖分为6档：普通抽奖、青铜抽奖、白银抽奖、黄金抽奖、铂金抽奖、至尊抽奖。
	-- 3.消耗所有奖池进行免费抽奖，获得对应奖品。
	-- 4.奖池每日0点重置。]]

	self.prog_default_rect = self.prog_bar.rect
	self.back_btn.onClick:AddListener(function()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnBackClick()
	end)
	self.lottery_btn.onClick:AddListener(function()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnLotteryBtnClick()
    end)
	self.help_btn.onClick:AddListener(function()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnHelpClick()
	end)
	self.close_help_btn.onClick:AddListener(function()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnCloseHelpClick()
    end)

	for i = 1, type_count do
		self[string.format("type_btn%d_tge",i)].onValueChanged:AddListener(function(val)
			ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
			self:OnTypeClick(val, i)
		end)
	end

	self.helpPanel.gameObject:SetActive(false)

	self.bk_list = {}
    for i = 1, award_count do
    	local pre = FishingActCaijinBoxPrefab.Create(self, self["box_node"..i], i)
		self.bk_list[#self.bk_list + 1] = pre

		if i == 1 or i == 2 then
			pre:showFlash(true)
		else
			pre:showFlash(false)
		end
	end
	self:chooseType(1)
	
	self:showLottery(false)
	
	self:RefreshInfo()

	--M.QueryCaijinAllInfo()

	--self.is_wait = true

	self:on_all_info()
end

function C:on_all_info()
	--dump( "<color=red>on_all_info</color>")
	
	local data = M.GetCaijinData()

	-- if data.result ~= 0 then 
	-- 	self:MyExit() 
	-- 	return
	-- end

	-- self.is_wait = false

	local type = self:findCurentType()
	self:chooseType(type)
		
	self:RefreshShowLottery()
	self:RefreshInfo()
end

function C:findCurentType()
	local d = M.GetCaijinData()

	local total = #M.caijin_config.caijin_type_config
	for i = total, 1, -1 do
		if d.score >= M.caijin_config.caijin_type_config[i].score_limit then
			return M.caijin_config.caijin_type_config[i].type
		end
	end

    return 1
end

-- function C:checkKillEnough()
-- 	local d = M.GetCaijinData()
-- 	local next = d.lottery_num + 1
-- 	if next >= 1 and next <= #M.caijin_config.caijin_condition_config then
-- 		local cond_cfg = M.caijin_config.caijin_condition_config[next]
-- 		local total = cond_cfg.kill_num
-- 		local cur = d.kill_num
-- 		return cur >= total
-- 	end

-- 	return nil
-- end

function C:checkLotteryNum()
	local d = M.GetCaijinData()
	local next = d.lottery_num + 1

	return next >= 1 and next <= #M.caijin_config.caijin_condition_config
	--return true
end


function C:RefreshShowLottery()
	-- 次数限定
	local show = self:checkLotteryNum()
	
	-- 积分限定
	if show then
		local type = self:findCurentType()
		show = self.choose_type >= type
	end

	self:showLottery(show)
end

function C:chooseType(type)
	assert(type >= 1 and type <= #M.caijin_config.caijin_type_config)

	self.choose_type = type

	-- 按钮
	self[string.format("type_btn%d_tge",type)].isOn = true

	-- 刷新奖励信息
	local awards = M.caijin_config.caijin_type_config[type].award
	for i = 1, #self.bk_list do
		if awards[i] then
			self.bk_list[i]:setVisible(true)
			self.bk_list[i]:setName(awards[i].name)
			self.bk_list[i]:setIcon(awards[i].icon)
			self.bk_list[i]:setChoosed(false)
		else
			self.bk_list[i]:setVisible(false)
			self.bk_list[i]:setName("")
			self.bk_list[i]:setChoosed(false)
		end
	end

	self:chooseAward(0)
end

function C:chooseAward(index)
	for i = 1, #self.bk_list do
		self.bk_list[i]:setChoosed(index == i)
	end

	self._curChooseAward = index
end

function C:on_caijin_lottery()
	dump( "<color=red>on_caijin_lottery</color>")

	local data = M.GetCaijinData()

	if data.result ~= 0 then 
		self:MyExit() 
		return
	end

	self:chooseType(data.type)

	if data.award_index >= 1 and data.award_index <= #self.bk_list then

		local total_count = award_round * award_count + data.award_index - 1

		local cur_count = 0
		self:chooseAward(1)

		delayTimer = Timer.New(function()

			cur_count = cur_count + 1
			
			if cur_count <= total_count then
				self._curChooseAward = self._curChooseAward + 1
				if self._curChooseAward > award_count then
					self._curChooseAward = 1
				end
				self:chooseAward(self._curChooseAward)

			elseif cur_count >= total_count + 10 then
				-- 结束
				if delayTimer then
					delayTimer:Stop()
					delayTimer=nil
				end
		
				self.is_wait = false

				self:show_award_panel()
		
				self:chooseAward(data.award_index)

				local type = self:findCurentType()
				self:chooseType(type)
					
				self:RefreshShowLottery()
				self:RefreshInfo()
			end
			
		end, award_tick, -1, nil, true)
	
		delayTimer:Start()
	end
end

function C:RefreshInfo()
	local data = M.GetCaijinData()
	
	-- 名字
	self.fish_name_txt.text = M.caijin_config.caijin_type_config[self.choose_type].name
	
	-- 进度条
	local enable = self:checkLotteryNum()
	if enable == false then
		self:SetProgress(0, 1)
		self.percent_txt.text = "今日抽奖次数已用完"
	else		
		local nextType = #M.caijin_config.caijin_type_config
		local total = #M.caijin_config.caijin_type_config
		for i = 1, total, 1 do
			if data.score < M.caijin_config.caijin_type_config[i].score_limit then
				nextType = i
				break
			end
		end
		
		local cfg = M.caijin_config.caijin_type_config[self.choose_type]
		self:SetProgress(data.score, cfg.score_limit, self.choose_type <= nextType)
	end
end

function C:SetProgress(cur, total, show_total)
	local txt = string.format("%d", cur)
	if show_total then
		txt = string.format("%d/%d", cur, total)
	end

	self.percent_txt.text = txt
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

function C:BoxExit()
	if self.bk_list then
		for k,v in ipairs(self.bk_list) do
			v:MyExit()
		end
	end
	self.bk_list = {}
end

function C:OnBackClick()
	if self.is_wait then return end

	self:MyExit()
end

function C:OnTypeClick(val, type)
	if val then
		dump( "<color=red>OnTypeClick</color>")

		if self.is_wait then return end
		
		self:chooseType(type)
		self:RefreshShowLottery()

		self:RefreshInfo()
	end
end

function C:showLottery(show)
	--self.lottery_btn.enabled = enable
	self.lottery_btn.gameObject:SetActive(show)
end

function C:OnLotteryBtnClick()
	if self.is_wait then return end

	local data = M.caijin_config.caijin_type_config[self.choose_type]
	local d = M.GetCaijinData()
	if d.score < data.score_limit then
		LittleTips.Create("奖池鲸币不满足当前抽奖")
		return 
	end

	local nextType = 0
	local total = #M.caijin_config.caijin_type_config
	for i = 1, total, 1 do
		if d.score < M.caijin_config.caijin_type_config[i].score_limit then
			nextType = i
			break
		end
	end
	if nextType > 0 then
		local cfg = M.caijin_config.caijin_type_config[nextType]
		local diff = cfg.score_limit - d.score

		HintPanel.Create(2, string.format("您距离%s仅差%d鲸币，您确定继续抽奖吗？",cfg.name, diff), function()
			M.RequestLottery()
			self.is_wait = true
		end, nil, nil, "温馨提示")
	else
		M.RequestLottery()
		self.is_wait = true
	end
end

function C:OnCloseHelpClick()	
	self.helpPanel.gameObject:SetActive(false)
end

function C:OnHelpClick()
	--FishingBKPanel.New()
	
	self.helpPanel.gameObject:SetActive(true)
end

function C:OnAssetChange(data)
	dump(data, "<color=red>----奖励类型-----</color>")
	if data.change_type and data.change_type == "fish_caijin_award" then
		self.wait_award_data = data
	end
end

function C:show_award_panel()
	-- 普通奖励
	if self.wait_award_data then
		Event.Brocast("AssetGet", self.wait_award_data)
		self.wait_award_data = nil
	end

	-- 实物奖励
	local data = M.GetCaijinData()
	local award_index = data.award_index
	local awardCfg = M.caijin_config.caijin_type_config[self.choose_type].award[award_index]
	if awardCfg.real == 1 then
		local real = {text = awardCfg.name, image = awardCfg.real_img}
		RealAwardPanel.Create(real)
	end
end