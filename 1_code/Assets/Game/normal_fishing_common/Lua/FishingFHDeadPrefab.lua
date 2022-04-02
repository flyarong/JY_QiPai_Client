-- 创建时间:2021-11-25
local basefunc = require "Game/Common/basefunc"

FishingFHDeadPrefab = basefunc.class()
local C = FishingFHDeadPrefab
C.name = "FishingFHDeadPrefab"

function C.Create(skill_data)
	return C.New(skill_data)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["ExitScene"] = basefunc.handler(self, self.OnExitScene)
    self.lister["EnterBackGround"] = basefunc.handler(self, self.on_background_msg)
    self.lister["skill_fish_explode_dead_msg"] = basefunc.handler(self, self.on_skill_fish_explode_dead_msg)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	if self.seq then
		self.seq:Kill()
		self.seq = nil
	end
	if IsEquals(self.sw1_obj) then
		destroy(self.sw1_obj)
		self.sw1_obj = nil
	end

	if self.fish and self.fish.MyExit then
		self.fish:MyExit()
	end
	self:RemoveListener()
end

function C:ctor(skill_data)
	dump(skill_data, "<color=white>EEE 凤凰skill_data</color>")
	self.skill_data = skill_data

	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	self.seat_num = self.skill_data.seat_num
	self.score = self.skill_data.add_score or 0
	self.time = self.skill_data.time or 1
	-- if self.skill_data and self.skill_data.score_list then
	-- 	self.score_map = {}
	-- 	for k,v in ipairs(self.skill_data.score_list) do
	-- 		self.score_map[v] = 1
	-- 	end
	-- end

	self:MyRefresh()
end

function C:MyRefresh()
	local fish_data = {}
	fish_data.fish_id = -1
	fish_data.path = 61
    fish_data.fish_type = 364
    local use_fish_cfg = FishingModel.Config.use_fish_map[fish_data.fish_type]
	for i = 1, #FishingModel.Config.use_fish_map do
		if FishingModel.Config.use_fish_map[i].fish_id == 61 then
			dump(FishingModel.Config.use_fish_map[i].fish_id, "<color=red>fish_id</color>")
			dump(i)
		end
	end

    local panel = FishingLogic.GetPanel()
    local node = panel.fish_group_node_tran
    self.fish = Fish.Create(node, fish_data)
    self.fish.fish_speed = 1
    self.fish:SetBox2D(false)
	self.fish.fish_base.anim_pay.speed = 1
    self.fish.fish_base.anim_pay:Play("Fish052_dead", -1, 0)
	-- self.fish.gameObject.name = "111111111111111"
	self.fish.transform.localPosition = Vector3.zero
	self.fish.transform.localScale = Vector3.New(3, 3, 3)
    self.seq = DoTweenSequence.Create()
	self.seq:AppendInterval(2)
	self.seq:OnKill(function ()
		self:BeginAnim()
		self.seq = nil
	end)
end

function C:BeginAnim()
    --震动
	Event.Brocast("ui_shake_screen_msg", 2, 0.6)
    --放火和爆炸
	local panel = FishingLogic.GetPanel()
	self.sw1_obj = newObject("Fish052_dead1", panel.FlyGoldNode.transform)
	-- dump(self.skill_data.score_list, "<color=white>EEE 凤凰 要处理的数据</color>")
	-- self.scores = {}
	-- for i = 1, #self.skill_data.score_list do
	-- 	self.scores[#self.scores + 1] = self.skill_data.score_list[i]
	-- end
	FishingAnimManager.FengHuangJs(panel.FlyGoldNode.transform, self.score, self.time, self.seat_num, 36, "Fish052_dead_jiesuan")
	self.seq = DoTweenSequence.Create()
	local time = self.time * 3.65
	self.seq:AppendInterval(time)
	self.seq:AppendCallback(function ()
		if self.fish and self.fish.MyExit then
			self.fish:MyExit()
			self.fish = nil
		end
		destroy(self.sw1_obj)
		self.sw1_obj = nil
		FishingAnimManager.PlayShowAndHideFX(panel.FlyGoldNode.transform, "Fish052_dead2", Vector3.zero, 1)
	end)

	self.seq:AppendInterval(1)
	self.seq:OnKill(function ()
		if self.fish_ids then
			for k,v in ipairs(self.fish_ids) do
				local fish = FishManager.GetFishByID(v)
				if fish then
	                fish:Dead()
	            end
			end
		end
		self.seq = nil
		self:MyExit()
	end)

	-- local sw1_tran = self.sw1_obj.transform
	-- local call = function (skill_id)
	-- 	local data = {}
	-- 	data.msg_type = "activity"
	-- 	data.type = FishingSkillManager.FishDeadAppendType.Boom
	-- 	data.id = skill_id
	-- 	data.seat_num = self.seat_num
	-- 	data.status = 0
	--     data.parm = "fenghuang"

	-- 	Event.Brocast("model_dispose_skill_data", data)
	-- end
	-- dump(self.skill_data.score_list, "<color=white>EEE 凤凰 发送进技能</color>")

	-- if self.skill_data.score_list then
	-- 	-- 发送技能
	-- 	-- dump("<color=white>BBBBBBBBBBBBBBBBBBBBBBBBB</color>")
	-- 	call(self.skill_data.score_list[#self.skill_data.score_list])
	-- else
	-- 	self:MyExit()
	-- end
end

function C:PlayAnim()
	local panel = FishingLogic.GetPanel()
	--结算动画
	FishingAnimManager.FengHuangJs(panel.FlyGoldNode.transform, self.moneys, self.seat_num, 36, "Fish052_dead_jiesuan")
	self.seq = DoTweenSequence.Create()
	self.seq:AppendInterval(10)
	self.seq:AppendCallback(function ()
		destroy(self.sw1_obj)
		self.sw1_obj = nil
		FishingAnimManager.PlayShowAndHideFX(panel.FlyGoldNode.transform, "Fish052_dead2", Vector3.zero, 1)
	end)
	self.seq:AppendInterval(1)
	self.seq:OnKill(function ()
		if self.fish_ids then
			for k,v in ipairs(self.fish_ids) do
				local fish = FishManager.GetFishByID(v)
				if fish then
	                fish:Dead()
	            end
			end
		end
		self.seq = nil
		self:MyExit()
	end)
end

function C:on_skill_fish_explode_dead_msg(data)
	if self.score_map and self.score_map[data.id] then
		self.moneys = data.moneys
		self.moneys[#self.moneys + 1] = self.score
		self.fish_ids = data.fish_ids
		for k, v in ipairs(self.fish_ids) do
			local fish = FishManager.GetFishByID(v)
            if fish then
                fish:CloseFishID()
            end
		end
		self:PlayAnim()
	end
end


function C:OnExitScene()
	self:MyExit()
end

function C:on_background_msg()
	self:MyExit()
end