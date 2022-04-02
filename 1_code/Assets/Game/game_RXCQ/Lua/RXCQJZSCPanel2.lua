local basefunc = require "Game/Common/basefunc"

RXCQJZSCPanel2 = basefunc.class()
local C = RXCQJZSCPanel2
C.name = "RXCQJZSCPanel2"

local Map_Start_Pos = Vector3.New(
	593,239
)
local Player_Start_Pos = Vector3.New(
	-406,-270
)

local Player_Stop_Pos = Vector3.New(
	51,-72
)
local Map_Stop_Pos = Vector3.New(
	-538,-264
)


local GuaiWu_Dui_Pos = {	
	[1] = Vector3.New(246,209),
	[2] = Vector3.New(1888,1065),
}

local GuaiWu_Dui_Stop_Pos = {	
	[1] = Vector3.New(-222,-74),
	[2] = Vector3.New(750,390),
}


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
	self.lister["rxcq_moneyitem_fly_over"] = basefunc.handler(self,self.on_rxcq_moneyitem_fly_over)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	if self.huo_sound_key then
		ExtendSoundManager.CloseSound(self.huo_sound_key)
	end
	if self.change_money_timer then
		self.change_money_timer:Stop()
	end
	if self.kill_num_timer then
		self.kill_num_timer:Stop()
	end
	if self.shandian_timer then
		self.shandian_timer:Stop()
	end
	if self.bing_timer then
		self.bing_timer:Stop()
	end
	self.map_img.sprite = nil
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:OnDestroy()
	self:MyExit()
end

function C:MyClose()
	self:MyExit()
end

function C:StopFenWei()
	if self.shandian_timer then
		self.shandian_timer:Stop()
	end
	if self.bing_timer then
		self.bing_timer:Stop()
	end
end

function C:ctor(parent)
	ExtPanel.ExtMsg(self)
	local parent = parent or GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject("RXCQJZSCPanel", parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	self.pos_item_list = {}
	self.curr_money = 0
	self:StartChangeMoneyTimer()
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	self.npc_death_num = 0
end

function C:InitUI()
	self.playeraction = RXCQPlayerAction.Create(self.play_node,2)
	self.play = self.playeraction.player
	self.play.transform.localPosition = Player_Start_Pos
end

function C:ReSet()
	if self.huo_sound_key then
		ExtendSoundManager.CloseSound(self.huo_sound_key)
	end
	for k,v in pairs(self.fenweizu_list) do
		if v then
			destroy(v)
		end
	end
	self.play.transform.localPosition = Player_Start_Pos
	self.map_img.gameObject.transform.localPosition = Map_Start_Pos
	for k,v in pairs(self.npc_map) do
		for k1,v1 in pairs(v) do
			destroy(v1.gameObject)
		end
	end
	self.npc_map = {}
	self.Curr_Step = 1
	for i = 1,#self.pos_item_list do
		destroy(self.pos_item_list[i])
	end
	self.pos_item_list = {}
end

function C:CreateNpc(wodian_index,num,wodian_max)
	self.wodian_max = wodian_max
	self.npc_map = self.npc_map or {}
	local temp_ui = {}
	local npc = {"fs1","fs2","ds1","ds2","zs1","zs2"}
	local pos_item = GameObject.Instantiate(self.npc_pos_item,self.transform) 
	pos_item.gameObject:SetActive(true)
	pos_item.transform:SetSiblingIndex(2)
	pos_item.transform.parent = self.map_img.gameObject.transform
	pos_item.transform.localPosition = GuaiWu_Dui_Pos[wodian_index]
	self.pos_item_list[#self.pos_item_list + 1] = pos_item.gameObject
	LuaHelper.GeneratingVar(pos_item.transform,temp_ui)
	self.npc_map[wodian_index] = self.npc_map[wodian_index] or {}
	num = num > 12 and 12 or num
	for i = 1,num do
		local random = math.random(1,4)
		if i <= 3 then
			random = math.random(5,6)
		end
		local npc = RXCQNpcPrefab.Create(temp_ui["npc_pos_"..i],npc[random])
		if random < 3 then
			npc.gameObject.transform:Find("RXCQ_FenWei_ZhaoZi").gameObject:SetActive(true)
		else
			npc.gameObject.transform:Find("RXCQ_FenWei_ZhaoZi").gameObject:SetActive(false)
		end
		self.npc_map[wodian_index][#self.npc_map[wodian_index] + 1] = npc
		npc.gameObject.transform.localScale = Vector3.New(0.7,0.7,0.7)
		npc:Stand()
	end
end

function C:SetImg(img)
	local config = {
		cq_bg_cm = {
			[1] = {
				zero = {x = -1250.8,y = -542.7},
				size = {x = 720,y = 331.7},
			},
			[2] = {
				zero = {x = -491,y = -215},
				size = {x = 720,y = 331.7},
			},
			[3] = {
				zero = {x = 168,y = 43},
				size = {x = 720,y = 331.7},
			},
			[4] = {
				zero = {x = 807,y = 359},
				size = {x = 720,y = 331.7},
			},
		},
		cq_bg_gm = {
			[1] = {
				zero = {x = -1250.8,y = -542.7},
				size = {x = 720,y = 331.7},
			},
			[2] = {
				zero = {x = -491,y = -215},
				size = {x = 720,y = 331.7},
			},
			[3] = {
				zero = {x = 168,y = 43},
				size = {x = 720,y = 331.7},
			},
			[4] = {
				zero = {x = 807,y = 359},
				size = {x = 720,y = 331.7},
			},
		},
		cq_bg_dd = {
			[1] = {
				zero = {x = -1250.8,y = -542.7},
				size = {x = 720,y = 331.7},
			},
			[2] = {
				zero = {x = -491,y = -215},
				size = {x = 720,y = 331.7},
			},
			[3] = {
				zero = {x = 168,y = 43},
				size = {x = 720,y = 331.7},
			},
			[4] = {
				zero = {x = 807,y = 359},
				size = {x = 720,y = 331.7},
			},
		},
		cq_bg_hg1 = {
			[1] = {
				zero = {x = -1250.8,y = -542.7},
				size = {x = 720,y = 331.7},
			},
			[2] = {
				zero = {x = -491,y = -215},
				size = {x = 720,y = 331.7},
			},
			[3] = {
				zero = {x = 168,y = 43},
				size = {x = 720,y = 331.7},
			},
			[4] = {
				zero = {x = 807,y = 359},
				size = {x = 720,y = 331.7},
			},
		},
		cq_bg_hg2 = {
			[1] = {
				zero = {x = -1250.8,y = -542.7},
				size = {x = 720,y = 331.7},
			},
			[2] = {
				zero = {x = -491,y = -215},
				size = {x = 720,y = 331.7},
			},
			[3] = {
				zero = {x = 168,y = 43},
				size = {x = 720,y = 331.7},
			},
			[4] = {
				zero = {x = 807,y = 359},
				size = {x = 720,y = 331.7},
			},
		},
		cq_bg_hgdd = {
			[1] = {
				zero = {x = 593,y = 239},
				size = {x = 3802,y = 1723},
			},
		},
	}
	self:CreateFengWeiZu(config[img])
	self.map_img.sprite = nil
	Util.ClearMemory()
	self.map_img.sprite = GetTexture(img)
end

function C:PlayerActtack(level)
	self.Curr_Level = level
	self.Curr_Step = 1
	self.playeraction:Run(Player_Stop_Pos,function()
		self.playeraction:Hit(nil,"CiShaJianShu")
		self:CreateQiFen()
		RXCQModel.DelayCall(
			function()
				self.playeraction:Hit(nil,"CiShaJianShu")
			end,1.1
		)
		RXCQModel.DelayCall(
			function()
				self.playeraction:Hit(function()
					self.playeraction:Stand()
					self:PlayNpcHit()
					self:NpcDie()
					self.Curr_Step = self.Curr_Step + 1
					self:CallNextStep()	
				end,"LieHuoJianFa")
			end,2.2
		)
	end)
	for i = 1,#self.npc_map[self.Curr_Step] do 
		local cha_v ={x = GuaiWu_Dui_Stop_Pos[self.Curr_Step].x - GuaiWu_Dui_Pos[self.Curr_Step].x,y = GuaiWu_Dui_Stop_Pos[self.Curr_Step].y - GuaiWu_Dui_Pos[self.Curr_Step].y}
		local target_pos
		local curr_pos = self.npc_map[self.Curr_Step][i].gameObject.transform.parent.transform.localPosition
		curr_pos = {x = curr_pos.x,y = curr_pos.y}
		local space_time = 0
		if i <= 3 then
			target_pos = Vector3.New(curr_pos.x + cha_v.x,curr_pos.y + cha_v.y)
		else
			target_pos = Vector3.New(curr_pos.x + cha_v.x * 0.75,curr_pos.y + cha_v.y)
			space_time = 0.01
		end
		self.npc_map[self.Curr_Step][i]:Run(target_pos,function()
			self.npc_map[self.Curr_Step][i]:Attack(self.play.gameObject)
			RXCQModel.DelayCall(
				function()
					self.npc_map[self.Curr_Step][i]:Attack(self.play.gameObject)
				end,0.6 + space_time * i
			)
			RXCQModel.DelayCall(
				function()
					self.npc_map[self.Curr_Step][i]:Attack(self.play.gameObject)
				end,1.5 + space_time * i
			)
		end,0.8 + space_time * i)
	end
end

function C:PlayNpcHit()
	for i = 1,#self.npc_map[self.Curr_Step] do
		local npc = self.npc_map[self.Curr_Step][i]
		npc:Hit()
	end
end

function C:NpcDie()
	self.curr_kill_num = self.curr_kill_num or 0
	for i = 1,#self.npc_map[self.Curr_Step] do
		local npc = self.npc_map[self.Curr_Step][i]
		npc:Death()
		self.npc_death_num = self.npc_death_num + 1
	end
	if self.kill_num_timer then
		self.kill_num_timer:Stop()
	end
	self.kill_num_timer = Timer.New(
		function()
			if self.npc_death_num > self.curr_kill_num then
				self.curr_kill_num = self.curr_kill_num + 3
				self.num2_txt.gameObject.transform.localScale = Vector3.New(1.3,1.3,1.3)
			end
			if self.curr_kill_num >= self.npc_death_num then
				self.curr_kill_num = self.npc_death_num
				self.num2_txt.gameObject.transform.localScale = Vector3.New(1,1,1)
			end
			self.num2_txt.text = "x"..self.npc_death_num
		end,
	0.1,-1,nil,true)
	self.kill_num_timer:Start()
	RXCQModel.AddTimers(self.kill_num_timer)
	self:all_die_gold()
end

local fen_jingbi = function(min,max,all,lengh)
	local re = {}
	local all_money = all
	local max_num = math.random(min,max)
	local max_value = math.floor(all_money * 0.3)
	local remain_value = all_money - max_value
	local sum = 0
	for i = 1,max_num do
		local d = math.floor(max_value / max_num)
		sum = sum + d
		re[#re + 1] = d
	end
	local remain_num = lengh - max_num
	local org = math.floor(remain_value / remain_num)
	for i = #re + 1,lengh - 1 do
		re[#re + 1] = org
		sum = sum + org
	end
	local remain = all_money - sum
	re[#re + 1] = remain
	re = RXCQNormalDie.romdomlist(re)
	return re
end

function C:all_die_gold()
	--当全部怪物死亡
	local zero = GuaiWu_Dui_Pos[1]
	local map = RXCQNormalDie.create_gold_pos(8,6,Vector3.New(zero.x + 200,zero.y-200))
	local gold = fen_jingbi(1,2,RXCQJZSCManager2.GetMoneyMap(self.Curr_Level,self.Curr_Step),48)
	self.JingBiItem = {}
	for i = 1,#map do
		local b = RXCQMoneyItem.Create(self.jb_node,gold[i],self.money_item.transform.localPosition,nil,Vector3.New(map[i].x,map[i].y,0))
		b.transform.localPosition = zero
		b.transform:SetSiblingIndex(0)
		b:ForceSetTargetPos()
		self.JingBiItem[#self.JingBiItem + 1] = b
	end
end

function C:on_rxcq_moneyitem_fly_over(data)
	self:ToAddMoney(data.money)
end

function C:ToAddMoney(money)
	self.curr_money = self.curr_money + money
end

function C:StartChangeMoneyTimer()
	self.timer_curr_money = 0
	if self.change_money_timer then
		self.change_money_timer:Stop()
	end
	self.change_money_timer = Timer.New(
		function()
			local add = self.curr_money - self.timer_curr_money
			if add < self.curr_money / 2 then
				add = self.curr_money / 2
			end
			self.timer_curr_money = self.timer_curr_money + math.floor(add/4)
			if self.timer_curr_money ~= self.curr_money and (self.timer_curr_money >= self.curr_money) then
				self.timer_curr_money = self.curr_money
				self.num_txt.gameObject.transform.localScale = Vector3.New(1,1,1)
			else
				self.num_txt.gameObject.transform.localScale = Vector3.New(1.3,1.3,1.3)
			end
			self.num_txt.text = "+"..self.timer_curr_money
		end
	,0.1,-1,nil,true)
	self.change_money_timer:Start()
	RXCQModel.AddTimers(self.change_money_timer)
end

function C:CallNextStep()
	local call = function()
		self.playeraction:Run()
		local seq = DoTweenSequence.Create({dotweenLayerKey = "rxcq"})
		seq:Append(self.map_img.gameObject.transform:DOLocalMove(Map_Stop_Pos, 2.6):SetEase(DG.Tweening.Ease.Linear))
		RXCQModel.DelayCall(
			function()
				self:CreateQiFen()
				self.playeraction:Hit(nil,"CiShaJianShu")
			end,2.6
		)
		RXCQModel.DelayCall(
			function()
				self.playeraction:Hit(nil,"CiShaJianShu")
			end,2.6 + 1.1
		)
		RXCQModel.DelayCall(
			function()
				self.playeraction:Hit(function()
					self.playeraction:Stand()
					self:PlayNpcHit()
					self:NpcDie()
					RXCQJZSCManager2.CallNextLevel()
				end,"LieHuoJianFa")
			end,2.6 + 1.1 + 1.1
		)

		for i = 1,#self.npc_map[self.Curr_Step] do 
			local cha_v ={x = GuaiWu_Dui_Stop_Pos[self.Curr_Step].x - GuaiWu_Dui_Pos[self.Curr_Step].x,y = GuaiWu_Dui_Stop_Pos[self.Curr_Step].y - GuaiWu_Dui_Pos[self.Curr_Step].y}
			local target_pos
			local curr_pos = self.npc_map[self.Curr_Step][i].gameObject.transform.parent.transform.localPosition
			curr_pos = {x = curr_pos.x,y = curr_pos.y}
			local space_time = 0
			if i <= 3 then
				target_pos = Vector3.New(curr_pos.x + cha_v.x,curr_pos.y + cha_v.y)
			else
				target_pos = Vector3.New(curr_pos.x + cha_v.x * 1,curr_pos.y + cha_v.y * 1)
				space_time = 0.01
			end
			self.npc_map[self.Curr_Step][i]:Run(target_pos,function()
				self.npc_map[self.Curr_Step][i]:Attack(self.play.gameObject)
				RXCQModel.DelayCall(
					function()
						self.npc_map[self.Curr_Step][i]:Attack(self.play.gameObject)
					end,0.6 + space_time * i
				)
				RXCQModel.DelayCall(
					function()
						self.npc_map[self.Curr_Step][i]:Attack(self.play.gameObject)
					end,1.5 + space_time * i
				)
			end,2.6 + space_time * i)
		end
	end

	if self.Curr_Step > self.wodian_max then
		RXCQJZSCManager2.CallNextLevel()
	else
		RXCQModel.DelayCall(call,2)
	end
end

local qifen = {
	"RXCQ_FenWei_Mo",
	"RXCQ_FenWei_Fang",
}

function C:CreateQiFen()
	local zero = GuaiWu_Dui_Pos[1]
	local X = zero.x - 50
	local Y = zero.y - 50
	local pos = {
		[1] = Vector3.New(X + 50,Y + 50),
		[2] = Vector3.New(X + 50,Y - 50),
		[3] = Vector3.New(X - 50,Y + 50),
		[4] = Vector3.New(X - 50,Y - 50),
	}
	local call = function()
		local qifen_name = qifen[math.random(1,#qifen)]
		local qifen_obj = GameObject.Instantiate(RXCQPrefabManager.Prefabs[qifen_name],self.jb_node.gameObject.transform)
		GameObject.Destroy(qifen_obj,1.2)
		qifen_obj.gameObject.name = "qifen_obj"
		qifen_obj.transform.localPosition = pos[math.random(1,#pos)]
		qifen_obj.transform.localScale =Vector3.New(1.3,1.3,1.3)
	end
	call()
	RXCQModel.DelayCall(call,math.random(0.3,0.9))
	self.fenweizu_list[#self.fenweizu_list + 1] = qifen_obj
end

function C:CreateFengWeiZu(config)
	self.fenweizu_list = {}
	local huo = function()
		local max_huo = math.random(10,20)
		for i = 1,max_huo do
			local random_1 = math.random(1,#config)
			local c = config[random_1]
			local pos = Vector3.New(c.zero.x + (math.random(c.size.x/2 * -1,c.size.x/2)),c.zero.y + (math.random(c.size.y/2 * -1,c.size.y/2)))
			local b = GameObject.Instantiate(RXCQPrefabManager.Prefabs["RXCQ_FenWei_Huo"],self.map_img.gameObject.transform)
			b.transform.localPosition = pos
			b.transform:SetSiblingIndex(0)
			self.fenweizu_list[#self.fenweizu_list + 1] = b
		end
		self.huo_sound_key = ExtendSoundManager.PlaySound("rxcq_hqhit",200)
	end
	huo()
end
