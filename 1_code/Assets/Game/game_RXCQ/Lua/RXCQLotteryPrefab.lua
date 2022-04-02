-- 创建时间:2021-02-04
-- Panel:RXCQLotteryPrefab
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
 -- 取消按钮音效
 -- ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
 -- 确认按钮音效
 -- ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
 --]]

local basefunc = require "Game/Common/basefunc"

RXCQLotteryPrefab = basefunc.class()
local C = RXCQLotteryPrefab
C.name = "RXCQLotteryPrefab"

local refab_map = RXCQModel.refab_map
local qipan = RXCQModel.qipan
local Curr_GameData_Index = 1

-- 保持三个拖尾的标准速度 是每0.2s走一个格子
function C.Create(parent)
	return C.New(parent)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
	self.lister["model_rxcq_kaijiang"] = basefunc.handler(self,self.on_model_rxcq_kaijiang)
	self.lister["rxcq_xuanzhong_next"] = basefunc.handler(self,self.on_rxcq_xuanzhong_next)
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

function C:MyClose()
	self:MyExit()
end

function C:ctor(parent)
	ExtPanel.ExtMsg(self)
	local parent = parent or GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	self.Map = self:CreateLotteryMap(self:CreatePos(),qipan)
	self.Map[1]:ShowChangLiang()
	RXCQLotteryAnim.Init(self.Map)
end

function C:InitUI()
	self.test_btn.onClick:AddListener(
		function()
			--RXCQLotteryAnim.StartLottery(math.random(1,24))
			Event.Brocast("rxcq_test")
		end 
	)
	self:MyRefresh()
end

function C:ReSetShow()
	for i = 1,#self.Map do
		self.Map[i]:ReSetShow()
	end
end

function C:CreatePos()
	local height_space = 216.65 --纵向间隔 
	local width_space = 213.25 --横向间隔
	local x = 9 --横向格子个数
	local y = 5 --纵向格子
	local Pos_List = {}
	local pos
	--创建第一个格子
	local all_width = width_space * (x - 1) 
	local all_height = height_space * (y - 1)
	--以左上角为第一个格子
	local pos = GameObject.Instantiate(self.pos,self.pos_node)
	pos.transform.localPosition = Vector3.New(-(all_width/2),all_height/2,0)
	Pos_List[#Pos_List + 1] = pos
	-- →
	for i = 2,x do
		local pos = GameObject.Instantiate(self.pos,self.pos_node)
		local last_pos = Pos_List[#Pos_List].transform.localPosition		
		pos.transform.localPosition = Vector3.New(last_pos.x + width_space,last_pos.y)
		Pos_List[#Pos_List + 1] = pos
	end
	-- ↓
	for i = 1,y - 1 do
		local pos = GameObject.Instantiate(self.pos,self.pos_node)
		local last_pos = Pos_List[#Pos_List].transform.localPosition		
		pos.transform.localPosition = Vector3.New(last_pos.x,last_pos.y -  height_space)
		Pos_List[#Pos_List + 1] = pos
	end
	-- ←
	for i = 1,x - 1 do
		local pos = GameObject.Instantiate(self.pos,self.pos_node)
		local last_pos = Pos_List[#Pos_List].transform.localPosition		
		pos.transform.localPosition = Vector3.New(last_pos.x - width_space,last_pos.y)
		Pos_List[#Pos_List + 1] = pos
	end
	-- ↑
	for i = 1, y - 2 do
		local pos = GameObject.Instantiate(self.pos,self.pos_node)
		local last_pos = Pos_List[#Pos_List].transform.localPosition		
		pos.transform.localPosition = Vector3.New(last_pos.x,last_pos.y + height_space)
		Pos_List[#Pos_List + 1] = pos
	end
	return self:ResetBeginPos(5,Pos_List)
end
--重新设置起始点
function C:ResetBeginPos(index,list)
	local re = {}
	for i = 1,#list do
		local new_index = index - 1 + i
		while new_index > #list do
			new_index = new_index - #list
		end
		re[#re + 1] = list[new_index]
		re[#re].gameObject.name = "pos"..i
		re[#re]:SetSiblingIndex(i - 1)
	end
	return re
end

function C:CreateLotteryMap(Pos_List,map)
	local Prefab_List = {}
	for i = 1,#Pos_List do
		local prefab = RXCQItem.Create(Pos_List[i].transform,qipan[i])
		Prefab_List[#Prefab_List + 1] = prefab
	end
	return Prefab_List
end

function C:MyRefresh()

end

function C:on_model_rxcq_kaijiang()
	Curr_GameData_Index = 1
	local data =  RXCQModel._all_game_data[Curr_GameData_Index]
	RXCQLotteryAnim.StartLottery(data.cid)
end

function C:on_rxcq_xuanzhong_next()
	dump(RXCQModel._all_game_data)
	dump(Curr_GameData_Index)
	Curr_GameData_Index = Curr_GameData_Index + 1
	if Curr_GameData_Index > #RXCQModel._all_game_data then
		Curr_GameData_Index = 1
		RXCQLotteryAnim.ClearChangLiang()
		Event.Brocast("rxcq_call_next_anim")
		return
	end
	RXCQLotteryAnim.SetChangLiang(RXCQModel._all_game_data[Curr_GameData_Index  - 1].cid)
	local data = RXCQModel._all_game_data[Curr_GameData_Index]
	RXCQLotteryAnim.StartLottery(data.cid)
end