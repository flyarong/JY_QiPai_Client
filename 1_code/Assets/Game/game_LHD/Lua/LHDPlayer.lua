-- 创建时间:2019-11-19
-- Panel:LHDPlayer
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

LHDPlayer = basefunc.class()
local C = LHDPlayer
C.name = "LHDPlayer"

local M = LHDModel

-- 计时器Rect参数
local clock_pos = {}
clock_pos[#clock_pos + 1] = {pos1=Vector3.New(0,442,0), scale1=1, pos2=Vector3.zero, scale2=1}
clock_pos[#clock_pos + 1] = {pos1=Vector3.New(-285,54,0), scale1=1, pos2=Vector3.zero, scale2=1}
clock_pos[#clock_pos + 1] = {pos1=Vector3.New(0,24,0), scale1=1, pos2=Vector3.zero, scale2=1}
clock_pos[#clock_pos + 1] = {pos1=Vector3.New(285,54,0), scale1=1, pos2=Vector3.zero, scale2=1}
-- 头像位置
local head_pos = {}
head_pos[#head_pos + 1] = {pos1=Vector3.New(-596,0,0), pos2=Vector3.New(-596,0,0)}
head_pos[#head_pos + 1] = {pos1=Vector3.New(-64,151,0), pos2=Vector3.New(-64,362,0)}
head_pos[#head_pos + 1] = {pos1=Vector3.New(-368,40,0), pos2=Vector3.New(-368,40,0)}
head_pos[#head_pos + 1] = {pos1=Vector3.New(64,152,0), pos2=Vector3.New(64,362,0)}

function C.Create(panelSelf, obj, uipos)
	return C.New(panelSelf, obj, uipos)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	if self.p_time then
		self.p_time:Stop()
		self.p_time = nil
	end
	self.clock_pre:MyExit()
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:ctor(panelSelf, obj, uipos)
	self.panelSelf = panelSelf
	self.uipos = uipos
	self.transform = obj.transform
	self.gameObject = obj.gameObject
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()

	self.clock_pre = LHDPlayerClockPrefab.Create(self.clock_node)
	self.clock_pre:SetActive(false)

	self.CellList = {}
	for i = 1, 5 do
		local pre = LHDCardPrefab.Create(self["card_node"..i], 0)
		pre:SetActive(false)
		if i == 1 or i == 5 then
			pre:SetAPTag(true)
		end
		self.CellList[#self.CellList + 1] = pre
	end
	self:InitUI()
end

function C:InitUI()
	local obj = GameObject.Instantiate(GetPrefab("LHD_caozuozhong"), self.bq).gameObject
	obj.transform.localPosition = Vector3.zero
	obj = GameObject.Instantiate(GetPrefab("LHD_chuzhanzhong"), self.czing).gameObject
	obj.transform.localPosition = Vector3.zero
	obj = GameObject.Instantiate(GetPrefab("LHD_yzb"), self.zb_hint).gameObject
	obj.transform.localPosition = Vector3.zero

	self:MyRefresh()
end
-- 玩家数据
function C:GetUser()
    self.seat_num = M.GetPosToSeatno(self.uipos)
    return M.GetPosToPlayer(self.uipos)
end
-- 设置玩家进入
function C:SetPlayerEnter()
	self:MyRefresh()
end
-- 设置玩家离开
function C:SetPlayerExit()
	self:MyRefresh()
end

function C:MyRefresh()
    self.userdata = self:GetUser()

	if self.userdata and self.userdata.base then
		self.gameObject:SetActive(true)

		if M.data.model_status == M.Model_Status.gaming and M.data.zhuang_seat_num == self.seat_num then
			self.zj_node.gameObject:SetActive(true)
		else
			self.zj_node.gameObject:SetActive(false)
		end
		self.cur_opr_node.gameObject:SetActive(false)
		self:RefreshMoney()
		self:RefreshCard()
		self:RefreshPermit()
		self:RefreshHead()
		self:RefreshBJ()

		if M.data.model_status == M.Model_Status.wait_begin
			or M.data.model_status == M.Model_Status.wait_table
			or M.data.model_status == M.Model_Status.gameover then
			self.card_db_node.gameObject:SetActive(false)
		else
			if M.data.player_state[self.seat_num] == 1 then
				self.card_db_node.gameObject:SetActive(true)
			else
				self.card_db_node.gameObject:SetActive(false)
			end
		end

		if M.data.model_status ~= M.Model_Status.gaming then
			if self.userdata.base.ready == 1 then
				self.zb_hint.gameObject:SetActive(true)
			else
				self.zb_hint.gameObject:SetActive(false)
			end
		else
			self.zb_hint.gameObject:SetActive(false)
		end
	else
		self.head_node.gameObject:SetActive(false)
		self.gameObject:SetActive(false)
	end
end
-- 刷新钱
function C:RefreshMoney()
	if self.uipos == 1 then
	    self.gold_txt.text = StringHelper.ToCashAndBit(self.userdata.base.score, 2)
	end
end

function C:RefreshCard()
	local m_data = M.data
	for i = 1, 5 do
		self.CellList[i]:SetActive(false)
	end
	if M.data.model_status == M.Model_Status.gaming then
		if m_data.player_pai[self.seat_num] then
			local card = m_data.player_pai[self.seat_num]
			for k,v in ipairs(card) do
				self.CellList[k]:SetData(v)
				self.CellList[k]:SetActive(true)
			end
		end
	end
end
function C:AddCard(index, v)
	self.CellList[index]:SetData(v)
	self.CellList[index]:SetActive(true)
end
-- 刷新权限
function C:RefreshPermit()
	local m_data = M.data
	self.max_t = m_data.countdown
	self.cur_t = m_data.countdown
	if m_data and m_data.cur_p == self.seat_num and M.data.player_state[self.seat_num] == 1 and (M.data.status == M.Status.mopai or M.data.status == M.Status.equip) then
		self.clock_pre:RunDownTime(self.cur_t)
		if M.data.model_status == M.Model_Status.gaming then
			self.clock_pre:SetRectAttr( clock_pos[self.uipos].pos2, clock_pos[self.uipos].scale2 )
		else
			self.clock_pre:SetRectAttr( clock_pos[self.uipos].pos1, clock_pos[self.uipos].scale1 )
		end
		self.cur_opr_node.gameObject:SetActive(true)
		self.select_node.gameObject:SetActive(false)
		self.head_icon_node.localScale = Vector3.New(1.4, 1.4, 1.4)
	else
		self.cur_opr_node.gameObject:SetActive(false)
		self.select_node.gameObject:SetActive(false)
		self:StopRunTime()
	end
end
function C:RefreshHead()
	self.name_txt.text = self.userdata.base.name
	self.head_node.gameObject:SetActive(true)
	URLImageManager.UpdateHeadImage(self.userdata.base.head_link, self.head_img)
	-- if M.data.model_status == M.Model_Status.gaming then
	-- 	self.head_node.localPosition = head_pos[self.uipos].pos2
	-- else
	-- 	self.head_node.localPosition = head_pos[self.uipos].pos1
	-- end
end
function C:RefreshBJ()
	if M.data.status == M.Status.buqi then
		if M.data.buqi_seats and M.data.buqi_seats[self.seat_num] then
			if M.GetCurRoundMPRate() ~= M.data.player_mopai_rate[self.seat_num] then
				self.bq.gameObject:SetActive(true)
				self.gengpai.gameObject:SetActive(false)
			else
				self.bq.gameObject:SetActive(false)
				self.gengpai.gameObject:SetActive(true)
			end
		else
			self.bq.gameObject:SetActive(false)
		end
	else
		self.bq.gameObject:SetActive(false)
		self.gengpai.gameObject:SetActive(false)
	end

	if M.data.status == M.Status.mopai then
		if M.data.cur_p == self.seat_num and self.seat_num ~= M.data.seat_num then
			self.bq.gameObject:SetActive(true)
		else
			self.bq.gameObject:SetActive(false)
		end
	end

	--gengpai 跟

	if M.data.model_status == M.Model_Status.gaming and self.userdata.base.ready == 1 and M.data.player_state[self.seat_num] == 2 then
		dump(M.data.player_state)
		self.qz.gameObject:SetActive(true)
		self:StopRunTime()
	else
		self.qz.gameObject:SetActive(false)
	end

	if M.data.status == M.Status.equip and M.data.player_state[self.seat_num] == 1 then
		if M.data.player_equip_rate and M.data.player_equip_rate[self.seat_num] and M.data.player_equip_rate[self.seat_num] > 0 then
			if self.seat_num == M.data.cur_p then
				self.cur_cz.gameObject:SetActive(false)
				self.czing.gameObject:SetActive(true)
			else
				self.cur_cz.gameObject:SetActive(true)
				local val = M.data.stake_rate_data[ M.data.player_equip_rate[self.seat_num] ] * M.data.room_info.init_stake
				self.cur_cz_txt.text = StringHelper.ToCash(val) .. "出战"
				self.czing.gameObject:SetActive(false)
			end
		else
			if self.seat_num == M.data.cur_p then
				self.cur_cz.gameObject:SetActive(false)
				self.czing.gameObject:SetActive(true)
			else
				self.cur_cz.gameObject:SetActive(false)
				self.czing.gameObject:SetActive(false)
			end
		end
	else
		self.cur_cz.gameObject:SetActive(false)
		self.czing.gameObject:SetActive(false)
	end

	if M.data.model_status == M.Model_Status.gaming and M.data.player_state[self.seat_num] == 0 then
		self.gz.gameObject:SetActive(true)
	else
		self.gz.gameObject:SetActive(false)
	end
end

function C:GetPos(type)
	return self.head_node.position
end
function C:StopRunTime()
	self.clock_pre:StopRunTime()
	self.head_icon_node.localScale = Vector3.one
end
function C:GetCardPos(index)
	return self.CellList[index]:GetCardPos()
end

-- 显示手牌
function C:ShowSPAnim(data)
	if data then
		for k,v in ipairs(data) do
			self.CellList[k]:RunFPAnim(v)
		end
	end
end


