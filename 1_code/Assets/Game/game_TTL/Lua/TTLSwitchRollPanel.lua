-- 创建时间:2020-03-26
-- Panel:TTLSwitchRollPanel
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

TTLSwitchRollPanel = basefunc.class()
local C = TTLSwitchRollPanel
C.name = "TTLSwitchRollPanel"

function C.Create(random_award,award)
	return C.New(random_award,award)
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
	Event.Brocast("Bullet_behit_by_bullet_msg_fx_finish","roll")
	self:RemoveListener()
	destroy(self.gameObject)

	 
end

function C:ctor(random_award,award)

	ExtPanel.ExtMsg(self)

	local parent = GameObject.Find("Canvas/LayerLv2").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	dump(random_award,"<color=yellow>+++++++++++++++++++随机奖励+++++++++++++++++++</color>")
	local t = 1
	self.arr = self:number_to_array(random_award, 2)
	if not self.index then
		self.index=#self.arr
	end

	self.seq = DoTweenSequence.Create()
	self.seq:AppendInterval(0.4)
	self.seq:AppendCallback(function ()
		ExtendSoundManager.PlaySound(audio_config.ttl.bgm_ttl_labazaxia.audio_name)
		Event.Brocast("TTL_ui_shake_screen_msg",2,60)
	end)
	self.seq:AppendInterval(0.8)
	self.seq:AppendCallback(function ()
		ExtendSoundManager.PlaySound(audio_config.ttl.bgm_ttl_labalaxia.audio_name)							
	end)
	self.seq:AppendInterval(0.8)
	self.seq:AppendCallback(function ()
		self:gundong(self.arr[self.index],2,3)
		self.index=self.index-1
		self:gundong(self.arr[self.index],6,4)
		ExtendSoundManager.PlaySound(audio_config.ttl.bgm_ttl_labagundong.audio_name)
	end)
	self.seq:AppendInterval(3)
	self.seq:AppendCallback(function ()
		self:bomb_time(random_award,award)
	end)

	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	self:MyRefresh()
end

function C:MyRefresh()
end

function C:number_to_array( number,len )
	local tbl = {}
	local nn = number
	while nn > 0 do
		tbl[#tbl + 1] = nn % 10
		nn = math.floor(nn / 10)
	end

	local array = {}
	if len then
		if len > #tbl then
			for idx = len, 1, -1 do
				if idx > #tbl then
					array[#array + 1] = 0
				else
					array[#array + 1] = ""..tbl[idx]
				end
			end
		else
			for idx = #tbl, 1, -1 do
				array[#array + 1] = ""..tbl[idx]
			end
			print("<color=red>EEE 长度定义不合理 number = " .. number .. "  len = " .. len .. "</color>")
		end
	else
		for idx = #tbl, 1, -1 do
			array[#array + 1] = ""..tbl[idx]
		end
	end
	return array
end

function C:gundong(number,_change_down_t,_change_uni_d)
	-- 滚动数据
	local item_list = {}
	item_list[1] = self["txt"..self.index].gameObject
	
	dump(item_list)
	dump(number)
	local arr={} 
	arr[1]= number
	self:ScrollLuckyChangeToFiurt(item_list,arr,function ( )
		print("完成")
		-- body
	end,_change_down_t,_change_uni_d)

	-- body
end

--膨脹爆炸
function C:bomb_time(random_award,award)

	local seq_boom1 = DoTweenSequence.Create()
	seq_boom1:AppendInterval(1)
	seq_boom1:AppendCallback(function ()
		ExtendSoundManager.PlaySound(audio_config.ttl.bgm_ttl_labatingzhi.audio_name)
	end)
	seq_boom1:AppendInterval(2.5)
	seq_boom1:AppendCallback(function ()
		ExtendSoundManager.PlaySound(audio_config.ttl.bgm_ttl_labatingzhi.audio_name)
	end)
	seq_boom1:OnKill(function ()
		local seq_boom = DoTweenSequence.Create()
		seq_boom:Append(self.transform:DOScale(Vector3.New(1,1,1),0.1)):SetLoops(10,DG.Tweening.LoopType.Yoyo)
		seq_boom:OnKill(function ()
			self.TTL_laba_xunhuan.gameObject:SetActive(false)
			ExtendSoundManager.PlaySound(audio_config.ttl.bgm_ttl_lababaozha.audio_name)
			self.TTL_laba_bao.gameObject:SetActive(true)
			ExtendSoundManager.PlaySound(audio_config.ttl.bgm_ttl_saqian.audio_name)
			self.TTL_laba_bao_jingbi.gameObject:SetActive(true)	
			self.switch.gameObject:SetActive(false)
			self.Rollscore_txt.transform:GetComponent("Text").text=random_award*award
			local seq_score = DoTweenSequence.Create()
			seq_score:Append(self.Rollscore_txt.transform:DOScale(Vector3.New(6,6,6),4):SetEase(DG.Tweening.Ease.OutElastic))
			seq_score:OnKill(function ()
				Event.Brocast("SwitchRollPanel_get_Award__TTL",random_award*1000)
				--Event.Brocast("SwitchRollPanel_on_roll_end_TTL")--整個拉霸過程結束
				Event.Brocast("model_bullet_pause_msg",{type="roll",is_pause=true})
				self:MyExit()
				end)
		end)
	end)
end

function C:ScrollLuckyChangeToFiurt(item_list,data_list,callback,_change_down_t,_change_uni_d)
	local item_map = {}--数据转换
	for x=1,#item_list do
		item_map[x] = item_map[x] or {}
		item_map[x][1] = {}
		item_map[x][1].data = {id=data_list[x], x=x, y=1}
		item_map[x][1].ui = {}
		item_map[x][1].ui.gameObject = item_list[x]
		item_map[x][1].ui.transform = item_map[x][1].ui.gameObject.transform
		LuaHelper.GeneratingVar(item_map[x][1].ui.transform, item_map[x][1].ui)
		item_map[x][1].ui.num_txt.text = item_map[x][1].data.id
	end

	local change_up_t = 0.2 --加速时间
	local change_uni_t = 0.02 --每一次滚动时间
	local change_down_t = _change_down_t or 0.2 --减速时间
	local change_uni_d = _change_uni_d or 2 --匀速滚动时长
	local change_up_d = 0.04 --滚动加速间隔

	local speed_status = {
		speed_up = "speed_up",
		speed_uniform = "speed_uniform",
		speed_down = "speed_down",
		speed_end = "speed_end",
	}
	local material_FrontBlur = GetMaterial("FrontBlur")
	local spacing = 65 + 0
	local add_y_count = 3
	local down_count = 0
	local all_count = 0
	local all_fruit_map = {}
	for x,_v in pairs(item_map) do
		for y,v in pairs(_v) do
			all_count = all_count + 1
		end
	end
	all_count = all_count * add_y_count

	local speed_uniform
	local speed_up
	local speed_down

	local function get_pos_by_index(x,y,size_x,size_y,spac_x,spac_y)
		size_x = size_x or 46
		size_y = size_y or 65
		spac_x = spac_x or 0
		spac_y = spac_y or 0
		local pos = {x = 0,y = 0}
		pos.x = (x - 1) * (size_x + spac_x)
		pos.y = (y - 1) * (size_y + spac_y)
		return pos
	end

	local function get_index_by_pos(x,y,size_x,size_y,spac_x,spac_y)
		size_x = size_x or 46
		size_y = size_y or 65
		spac_x = spac_x or 0
		spac_y = spac_y or 0
		local index = {x = 1,y = 1}
		index.x = math.floor(x / (size_x + spac_x)) + 1
		index.y = math.floor(y / (size_y + spac_y)) + 1
		return index
	end

	local function create_obj(data)
		local _obj = {}
		_obj.ui = {}
		_obj.data = data
		local parent = _obj.data.parent
		if not parent then return end
		_obj.ui.gameObject = GameObject.Instantiate(data.obj, parent)
		_obj.ui.transform = _obj.ui.gameObject.transform
		_obj.ui.transform.localPosition = get_pos_by_index(_obj.data.x,_obj.data.y)
		_obj.ui.gameObject.name = _obj.data.x .. "_" .. _obj.data.y
		LuaHelper.GeneratingVar(_obj.ui.transform, _obj.ui)
		_obj.ui.num_txt.text = data.id
		return _obj
	end

	local function call(v)
		if not v.obj.ui or not v.obj.ui.transform or not IsEquals(v.obj.ui.transform) then return end
		if v.status == speed_status.speed_up or v.status == speed_status.speed_uniform or v.status == speed_status.speed_down then
			if v.status == speed_status.speed_up then
				v.obj.ui.num_txt.material = material_FrontBlur
			elseif v.status == speed_status.speed_down then
				v.obj.ui.num_txt.material = nil
			end
			if v.obj.ui.transform.localPosition.y < -spacing then
				v.obj.ui.transform.localPosition = get_pos_by_index(1,2)
				v.obj.ui.num_txt.text = math.random( 0,9)
			end
		elseif v.status == speed_status.speed_end then
			down_count = down_count + 1
			if down_count == all_count then
				for x,_v in pairs(item_map) do
					for y,v in pairs(_v) do
						v.ui.num_txt.gameObject:SetActive(true)
					end
				end
				for x1,_v1 in pairs(all_fruit_map) do
					for y1,v1 in pairs(_v1) do
						for x2,_v2 in pairs(v1) do
							for y2,v2 in pairs(_v2) do
								Destroy(v2.obj.ui.gameObject)
							end
						end
					end
				end
				all_fruit_map = {}
				if callback and type(callback) == "function" then
					callback()
				end
			end
		end
		if v.status == speed_status.speed_up then
			v.status = speed_status.speed_uniform --加速完成进入匀速状态
		end
		if v.status == speed_status.speed_uniform then
			speed_uniform(v)
		elseif v.status == speed_status.speed_up then
			speed_up(v)
		elseif v.status == speed_status.speed_down then
			speed_down(v)
		end
	end

	speed_up = function  (v)
		v.status = speed_status.speed_up
		local seq = DoTweenSequence.Create()
		local t_y = v.obj.ui.transform.localPosition.y - spacing
		seq:Append(v.obj.ui.transform:DOLocalMoveY(t_y, change_up_t))
		seq:SetEase(DG.Tweening.Ease.InCirc)
		seq:OnForceKill(function ()
			call(v)
		end)
	end

	speed_uniform = function (v)
		v.status = speed_status.speed_uniform
		local seq = DoTweenSequence.Create()
		local t_y = v.obj.ui.transform.localPosition.y - spacing
		seq:Append(v.obj.ui.transform:DOLocalMoveY(t_y, change_uni_t))
		seq:SetEase(DG.Tweening.Ease.Linear)
		seq:OnForceKill(function ()
			call(v)
		end)
	end

	speed_down = function (v)
		v.status = speed_status.speed_down
		local index = get_index_by_pos(v.obj.ui.transform.localPosition.x,v.obj.ui.transform.localPosition.y)
		if index.y == 2 then
			local id = item_map[v.real_x][v.real_y].data.id
			v.obj.ui.num_txt.text = id
		end
		local seq = DoTweenSequence.Create()
		local t_y = v.obj.ui.transform.localPosition.y - spacing
		seq:Append(v.obj.ui.transform:DOLocalMoveY(t_y, change_down_t))
		seq:SetEase(DG.Tweening.Ease.OutCirc)
		seq:OnForceKill(function ()
			v.status = speed_status.speed_end
			call(v)
		end)
	end

	local function lucky_chang_to_fruit(v_obj,index_x)
		if not IsEquals(item_map[index_x][1].ui.gameObject) then
			return
		end
		local fruit_map = {}
		local id
		local ins_obj = GameObject.Instantiate(item_map[index_x][1].ui.gameObject)
		for y=1,add_y_count do
			if y == 1 then
				id = v_obj.data.id
			else
				id = math.random(0,9)
			end
			fruit_map[1] = fruit_map[1] or {}
			fruit_map[1][y] ={obj = create_obj({obj = ins_obj,x = 1,y = y,id = id ,parent = v_obj.ui.transform}),status = speed_status.speed_up,real_x = v_obj.data.x,real_y = v_obj.data.y}
			local v = fruit_map[1][y]
			if v.obj.ui.transform.localPosition.y < -spacing then
				v.obj.ui.transform.localPosition = get_pos_by_index(1,2)
				v.obj.ui.num_txt.text = math.random(0,9)
			end
			speed_up(fruit_map[1][y])
		end
		--隐藏自己
		v_obj.ui.num_txt.gameObject:SetActive(false)
		Destroy(ins_obj)
		return fruit_map
	end

	--一列一列加速改变
	local x = 1
	local change_up_timer
	if change_up_timer then change_up_timer:Stop() end
	change_up_timer = Timer.New(function()
		if item_map[x] then
			for y=1,8 do
				local v = item_map[x][y]
				if v then
					all_fruit_map[x] = all_fruit_map[x] or {}
					all_fruit_map[x][y] = lucky_chang_to_fruit(v,x)
				end
			end
		end
		x = x + 1
		if x == 8 then
			local m_callback = function(  )
				for x,_v in pairs(all_fruit_map) do
					for y,v in pairs(_v) do
						for x1,v1 in pairs(v) do
							for y1,v2 in pairs(v1) do
								v2.status = speed_status.speed_down
							end
						end
					end
				end
			end
			local change_uni_timer = Timer.New(function ()
				m_callback()
			end,change_uni_d,1)
			change_uni_timer:Start()
		end
	end,change_up_d,8)
	change_up_timer:Start()
end




