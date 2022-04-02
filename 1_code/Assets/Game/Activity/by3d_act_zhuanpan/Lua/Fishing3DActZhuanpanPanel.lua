-- 创建时间:2020-02-19
-- Panel:Fishing3DActZhuanpanPanel
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


Fishing3DActZhuanpanPanel = basefunc.class()
local C = Fishing3DActZhuanpanPanel
C.name = "Fishing3DActZhuanpanPanel"
local M = BY3DActZhuanpanManager

local t1 = 1    --1阶段的时间
local t2 = 3    --2阶段的时间
local v2 = 4000 --2阶段的速度（匀速）
local loop_count3 = 2 -- 3阶段的循环次数


local award_tick = 0.1
local speed = 4000
local timeout = 3

local runTimer
local delayTimer
local timeoutTimer

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
	self.lister["model_by3d_act_zhuanpan_lottery"] = basefunc.handler(self, self.on_zhuanpan_lottery)
	self.lister["nor_fishing_panel_active_finish"] = basefunc.handler(self, self.OnAssetChange)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	if runTimer then
        runTimer:Stop()
        runTimer=nil
	end

	if delayTimer then
        delayTimer:Stop()
        delayTimer=nil
	end

	if timeoutTimer then
		timeoutTimer:Stop()
		timeoutTimer=nil
	end

	self.is_wait = false
	self.wait_award_data = nil

 	self:RemoveListener()
	destroy(self.gameObject)
end

function C:ctor()
	print("Fishing3DActZhuanpanPanel init!")
	local parent = GameObject.Find("Canvas/LayerLv3").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self.wait_award_data = nil

	self:MakeLister()
	self:AddMsgListener()
		
	self.curPos = 0 
	self.curRound = 0 
	self.curTimeout = 0

	self:InitUI()
end

function C:InitUI()
	-- self.back_btn.onClick:AddListener(function()
	-- 	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	-- 	self:OnBackClick()
	-- end)
	self.lottery_btn.onClick:AddListener(function()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnLotteryBtnClick()
    end)

	self:InitScroll()

	self:initTimeoutTimer()

	self.is_wait = false
end

function C:initTimeoutTimer()
	self.curTimeout = timeout
	timeoutTimer = Timer.New(function()
		self.curTimeout = self.curTimeout - 1
		if self.curTimeout <= 0 then
			self.curTimeout = 0

			if timeoutTimer then
				timeoutTimer:Stop()
				timeoutTimer=nil
			end

			self:OnLotteryBtnClick()
		end

		self.timeout_txt.text = self.curTimeout
	end, 1, -1, nil, true)
	
	timeoutTimer:Start()

	self.timeout_info.gameObject:SetActive(true)
	self.timeout_txt.text = self.curTimeout
end

function C:on_zhuanpan_lottery()
	local data = M.GetZhuanpanData()
	if data.result ~= 0 then
		print("zhuanpan error")
		self:MyExit()
		return
	end

	local total_count = #M.getConfig()
	local last_tick = os.clock()

	local a1 = v2 / t1
	local a3 = 0
	local cur_time = 0
	local cur_speed = 0

	runTimer = Timer.New(function()
		local cur_tick = os.clock()
		local dt = cur_tick - last_tick
		--local dt = 0.016
		
		local s = 0

		if cur_time < t1 then
			-- 第一阶段 匀加速
			s = cur_speed * dt + 0.5 * a1 * dt * dt
			cur_speed = cur_speed + a1 * dt
			if cur_speed > v2 then
				cur_speed = v2
			end
		elseif cur_time < t2 then
			-- 第二阶段 匀速
			cur_speed = v2	
			s = cur_speed * dt
		else
			-- 第三阶段 匀加速
			if a3 == 0 then
				s = cur_speed * dt
			else
				s = cur_speed * dt + 0.5 * a3 * dt * dt
				cur_speed = cur_speed + a3 * dt
				if cur_speed <= 0 then
					print("end a3")
					cur_speed = 0
					a3 = 0

					--self:JumpScrollPos(M.GetZhuanpanData().award_index)
					self:EndScroll()
					return
				end
			end
		end

		cur_time = cur_time + dt
		
		for i = 1, #self.bk_list do
			local b = self.bk_list[i]
			local x = b.gameObject.transform.localPosition.x - s
			b.gameObject.transform.localPosition = Vector3.New(x, 0, 0)
		end

		local first = self.bk_list[1] 		
		if self.bk_list[1].gameObject.transform.localPosition.x <= self.returnPos then
			local diff = math.abs(self.returnPos - self.bk_list[1].gameObject.transform.localPosition.x)
			
			local first = table.remove(self.bk_list, 1)
			table.insert(self.bk_list, first)

			-- for i = 1, #self.bk_list do
			-- 	local b = self.bk_list[i]
			-- 	print(b:getIndex())
			-- end

			local new_first_index = self.bk_list[1]:getIndex()
			local idx = new_first_index + 6
			if idx > total_count then
				idx = idx - total_count
			end

			first:setIndex(idx)

			self:RefreshScrollPos(-diff)

			if cur_time >= t2 then
				if a3 == 0 then
					local need_s = 0
					local dis = 0
					local endPos = M.GetZhuanpanData().award_index
					if endPos >= self.curPos then
						dis = endPos - self.curPos
					else
						dis = total_count - self.curPos + endPos
					end
					local half = math.ceil(total_count / 2)
					if dis <= half then
						need_s = (loop_count3 * total_count + dis) * self.box_width - diff
					else
						need_s = (loop_count3 * total_count + dis) * self.box_width - diff
						--need_s = dis * self.box_width - diff
					end
		
					a3 = -cur_speed * cur_speed / (2 * need_s)
				end
			end

			self:onPosChanged()
		end

		last_tick = cur_tick
	end, 0.016, -1, nil, true)

	runTimer:Start()

end

function C:JumpScrollPos(pos)
	local total_count = #M.getConfig()
	while true do
		if self.curPos == pos then
			self:RefreshScrollPos()
			return
		end 
		
		local first = table.remove(self.bk_list, 1)
		table.insert(self.bk_list, first)

		local new_first_index = self.bk_list[1]:getIndex()
		local idx = new_first_index + 6
		if idx > total_count then
			idx = idx - total_count
		end
		first:setIndex(idx)
	end
end

function C:RefreshScrollPos(diff)
	diff = diff or 0
	for i = 1, #self.bk_list do
		local b = self.bk_list[i]

		local index = i - 3		
		b.gameObject.transform.localPosition = Vector3.New(index * self.box_width + diff, 0, 0)
	end

	self.curPos = self.bk_list[3]:getIndex()
end

function C:onPosChanged()
	--print("onPosChanged " .. self.curPos)
	
end

function C:EndScroll()
	self.curRound = 0

	if runTimer then
        runTimer:Stop()
        runTimer=nil
	end

	delayTimer = Timer.New(function()
		if delayTimer then
			delayTimer:Stop()
			delayTimer=nil
		end

		self:EndLottery()
	end, 1, -1, nil, true)
	
	delayTimer:Start()
end

function C:EndLottery()
	self.is_wait = false

	self:show_asset_change()

	self:MyExit()
end

function C:InitScroll()
	self.bk_list = {}
	for i = 1, 7 do
    	local pre = Fishing3DActZhuanpanBoxPrefab.Create(self, self.box_rect, i)
		self.bk_list[#self.bk_list + 1] = pre
		pre:setIndex(i)
	end

	local boxPanel = self.bk_list[1]
	self.box_width = boxPanel.gameObject.transform.rect.width
	--self.box_width = 288

	self.returnPos = -3 * self.box_width

	self:RefreshScrollPos()
end

function C:OnLotteryBtnClick()
	if timeoutTimer then
		timeoutTimer:Stop()
		timeoutTimer=nil
	end

	self.timeout_info.gameObject:SetActive(false)

	if self.is_wait then return end

	M.RequestLottery()

	self.is_wait = true
end

function C:OnAssetChange(_,data)
	dump(data, "<color=red>----奖励结果-----</color>")
	if data.type == 28 then
		self.wait_award_data = {data = data.assets, change_type = "nor_fishing_panel_active_finish_" .. data.type}
	end
end

function C:show_asset_change()
	if self.wait_award_data then
		Event.Brocast("AssetGet", self.wait_award_data)
	end

	self.wait_award_data = nil
end