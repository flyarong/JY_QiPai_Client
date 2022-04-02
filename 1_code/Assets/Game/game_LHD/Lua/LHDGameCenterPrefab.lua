-- 创建时间:2019-11-19
-- Panel:LHDGameCenterPrefab
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

LHDGameCenterPrefab = basefunc.class()
local C = LHDGameCenterPrefab
C.name = "LHDGameCenterPrefab"
local M = LHDModel

function C.Create(panelSelf, obj)
	return C.New(panelSelf, obj)
end

function C:AddMsgListener()
	dump(self.lister, "<color=red>EE AddMsgListener</color>")
	print(debug.traceback())
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
	self.lister["ui_fd_anim_finish_msg"] = basefunc.handler(self, self.on_ui_fd_anim_finish_msg)

end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	self:ClearCellList()
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:ctor(panelSelf, obj)
	self.panelSelf = panelSelf
	self.uipos = uipos
	self.transform = obj.transform
	self.gameObject = obj.gameObject
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	
	local max_count = 20
	self.cell_size = {w = 140, h = 185}
	self.map_size = {w = 9, h = 3}
	local py_w = (self.map_size.w + 1) / 2
	local py_h = (self.map_size.h + 1) / 2
	local py_h2 = (self.map_size.h - 1) / 2
	self.pos_list = {}
	-- 上
	for i = 1, self.map_size.w do
		local x = self.cell_size.w * (i-py_w)
		local y = self.cell_size.h * (py_h-1)
		local pos = Vector3.New(x, y, 0)
		self.pos_list[#self.pos_list + 1] = pos
	end
	-- 右
	for i = 1, self.map_size.h-2 do
		local x = self.cell_size.w * (self.map_size.w-py_w)
		local y = self.cell_size.h * (py_h2-i)
		local pos = Vector3.New(x, y, 0)
		self.pos_list[#self.pos_list + 1] = pos
	end
	-- 下
	for i = self.map_size.w, 1, -1 do
		local x = self.cell_size.w * (i-py_w)
		local y = self.cell_size.h * (py_h-self.map_size.h)
		local pos = Vector3.New(x, y, 0)
		self.pos_list[#self.pos_list + 1] = pos
	end
	-- 左
	for i = 1, self.map_size.h-2 do
		local x = self.cell_size.w * (1-py_w)
		local y = self.cell_size.h * (i-py_h2)
		local pos = Vector3.New(x, y, 0)
		self.pos_list[#self.pos_list + 1] = pos
	end
	self:ClearCellList()
	local data = {}
	for i = 1, 20 do
		data[#data + 1] = {index=i}
	end
	for k,v in ipairs(data) do
		local pre = LHDEggPrefab.Create(self.CellRect, v, C.OnEggClick, self)
		pre:SetPos(self.pos_list[k])
		self.EggCellList[#self.EggCellList + 1] = pre
	end

	self:InitUI()
end

function C:InitUI()
	self.all_bet_txt.text = "--"
	self.cur_bet_txt.text = "--"
	self:MyRefresh()
end

function C:MyRefresh()
	if M.data.model_status == M.Model_Status.gaming
		and (M.data.status == M.Status.fp or M.data.status == M.Status.dz or M.data.status == M.Status.mopai or M.data.status == M.Status.buqi) then
		self.gameObject:SetActive(true)
		self.jc.gameObject:SetActive(true)
		self.za.gameObject:SetActive(true)
		self:RefreshEgg()
		self:RefreshMoney()
	else
		self.gameObject:SetActive(false)
	end
end
function C:RefreshEgg()
	if self.EggCellList then
		for k,v in ipairs(self.EggCellList) do
			v:MyRefresh()
			v:SetPos(self.pos_list[k])
		end
	end
end
function C:RefreshMoney()
	if M.data.model_status == M.Model_Status.gaming
		and (M.data.status == M.Status.fp or M.data.status == M.Status.dz or M.data.status == M.Status.mopai or M.data.status == M.Status.buqi) then
		self.all_bet_txt.text = M.GetTotalXZ()
		self.cur_bet_txt.text = M.data.room_info.init_stake * M.GetCurRate()
	end
end

function C:ClearCellList()
	if self.EggCellList then
		for k,v in ipairs(self.EggCellList) do
			v:OnDestroy()
		end
	end
	self.EggCellList = {}
end

function C:on_model_nor_lhd_nor_mopai_msg(data)
	self.EggCellList[data.index]:PlayMPAnim()
	local uiPos = M.GetSeatnoToPos(data.seat_num)
	local beginPos = self.EggCellList[data.index]:GetPos()
	local endPos = self.panelSelf.PlayerClass[uiPos]:GetCardPos(#M.data.player_pai[data.seat_num])
	LHDAnimation.PlayMP(data, self.transform, beginPos, endPos, function ()
		self:RefreshEgg()
	    self.panelSelf.PlayerClass[uiPos]:AddCard(#M.data.player_pai[data.seat_num], data.pai)

	    Event.Brocast("lhd_guide_check")
	end)
end
function C:on_model_nor_lhd_nor_show_pai_msg(data)
	local seat_num = data.seat_num
	local uiPos = M.GetSeatnoToPos(seat_num)
    self.panelSelf.PlayerClass[uiPos]:StopRunTime()

	local beginPos = self.EggCellList[data.index]:GetPos()
	LHDAnimation.PlayTSAnim(self.transform, beginPos, function ()
		self.EggCellList[data.index]:MyRefresh()
	end)
end

function C:OnEggClick(index)
	if M.data.cur_p == M.data.seat_num then
		local egg = M.GetEggByIndex(index)
		if M.data.buf.is_ts_oper then
			if egg and egg.card_num == 0 then
				Network.SendRequest("nor_lhd_nor_show_pai", {index=index}, "", function (data)
					if data.result ~= 0 then
						if data.result == 1003 then
							M.hintCondition()
						else
							HintPanel.ErrorMsg(data.result)
						end
					end
				end)
			else
				print("蛋已经被打开或者已经被透视")
				dump(egg)
			end
		else
			if egg and egg.card_num ~= -1 then
				Network.SendRequest("nor_lhd_nor_mopai", {rate=M.data.stake_rate, index=index}, "", function (data)
					if data.result ~= 0 then
						if data.result == 1003 then
							M.hintCondition()
						else
							HintPanel.ErrorMsg(data.result)
						end
					end
				end)
			else
				print("蛋已经被打开")
				dump(egg)
			end
		end
	end
end

function C:FDAnim(delay)
	delay = delay or 0
	local seq = DoTweenSequence.Create()
	if delay and delay > 0.00001 then
		seq:AppendInterval(delay)
	end
	seq:OnKill(function ()
		self.gameObject:SetActive(true)
		self.jc.gameObject:SetActive(false)
		self.za.gameObject:SetActive(false)
		self.cur_anim_num = 0
		local tt = 0.05
		for i = 1, 20 do
			local pre = self.EggCellList[i]
			pre:SetData({card_num=0})
			pre:SetPos(Vector3.zero)
			LHDAnimation.PlayFD(pre.transform, self.pos_list[i], tt*(i-1))
		end
	end)
end

function C:on_ui_fd_anim_finish_msg()
	self.cur_anim_num = self.cur_anim_num + 1
	if self.cur_anim_num == 20 then -- 发蛋完成，开始选透明蛋
		self.jc.gameObject:SetActive(true)
		self.za.gameObject:SetActive(true)
		self.EggCellList[M.GetSysTMdan()]:MyRefresh()
	end
end