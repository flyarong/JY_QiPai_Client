-- 创建时间:2019-03-12
-- Panel:FishingDRFishPrefab
local basefunc = require "Game/Common/basefunc"
FishingDRFishPrefab = basefunc.class()
local C = FishingDRFishPrefab
C.name = "FishingDRFishPrefab"

local hp_blink_limit = 0.1
local hp_red_limit = 0.1

FishingDRFishPrefab.FishState = 
{
	FS_Nor="正常",
	FS_Flee="逃离",
	FS_Hit="受击",
	FS_Dead="死亡",
	FS_FeignDead="假装死亡",
}
function C.Create(parent, data)
	return C.New(parent, data)
end

function C:FrameUpdate(time_elapsed)
	self.testfirst = true

	if not time_elapsed then
		time_elapsed = 0.1
	end

	if not FishingModel.check_is_dead_or_flee(self.data.fish_id) then
		if self.cur_hp > 0 then
			self.cur_hp = self.cur_hp - FishingModel.Defines.fish_hp_hurt * time_elapsed
			if self.cur_hp < 0 then
				self.cur_hp = 0
			end
		end
	end

	local cur_location = self.data.cur_location
	local next_idx = self.cur_deal_bj_idx + 1
	local bj_data = FishingModel.data.flood_data[self.data.fish_id].bj_data

	if next_idx <= #bj_data then
		local bj_location = bj_data[next_idx].location
		if cur_location >= bj_location then
			self.cur_deal_bj_idx = next_idx
			if self.cur_hp > 0 then
				self.cur_hp = self.cur_hp - bj_data[next_idx].value
				if self.cur_hp < 0 then
					self.cur_hp = 0
				end
			end

			self.baoji_data = bj_data[next_idx]
		end
	end
	if self.m_fish_state == FishingDRFishPrefab.FishState.FS_Dead
	or self.m_fish_state == FishingDRFishPrefab.FishState.FS_FeignDead then
		return
	end
	if IsEquals(self.transform) then
		if self.transform.localPosition.x > 30 then return end
		self.transform.localPosition = self.transform.localPosition + Vector3.New(1,0,0) * time_elapsed *  FishingModel.get_fish_sp(self.data.fish_id)
	end
	self:RefreshUIPos()
end

function C:MyExit()
	if self.anim_time then
		self.anim_time:Stop()
		self.anim_time = nil
	end
	self:BackBing()
	self:BackJB()
	self:BackHPBlink()

	if IsEquals(self.transform) then
		self.anim_pay.speed = 1
		self.fish_sr.color = Color.New(1, 1, 1, 1)
		self.fish_shadow_sr.color = Color.New(0, 0, 0, 80/255)
		self.transform.localScale = Vector3.zero
	end
	CachePrefabManager.Back(self.prefab)

	for k,v in pairs(self.texiao) do
		if v and v.prefab and IsEquals(v.prefab.prefabObj) then
			CachePrefabManager.Back(v)
		end
	end
end

function C:ctor(parent, data)
	self.testfirst = false
	self.data = data
	self.prefab = CachePrefabManager.Take("FishDR00" .. self.data.fish_type)
	self.prefab.prefab:SetParent(parent)
	self.transform = self.prefab.prefab.prefabObj.transform
	self.gameObject = self.transform.gameObject
	self.transform.rotation = Quaternion.Euler(0, 0, self.data.angle)
	self.transform.position = self.data.pos
	self.gameObject.name = self.data.fish_id
	self.box2d = self.transform:GetComponent("BoxCollider2D")
	self.lock_node = self.transform:Find("lock_node")
	self.hang_node = self.transform:Find("hang_node")
	self.tail_node = self.transform:Find("tail_node")
	self.hp_node = self.transform:Find("hp_node")

	self.fish_sr = self.transform:Find("fish"):GetComponent("SpriteRenderer")
	self.fish_shadow_sr = self.transform:Find("fish/shadow"):GetComponent("SpriteRenderer")
	self.anim_pay = self.transform:GetComponent("Animator")
	-- self.fish_sr.sortingOrder = 10
	-- self.fish_shadow_sr.sortingOrder = 9
	self.box2d.enabled = true
	self.m_fish_state = FishingDRFishPrefab.FishState.FS_Flee

	self.baoji_data = nil

	self.total_hp = FishingModel.Defines.fish_hp_total[self.data.fish_id] or 0
	self.cur_hp = self.total_hp
	self.texiao = {}
	self.cur_deal_bj_idx = 0
	
	--local newMat = GetMaterial("MyDefault")
	--newMat.shader = UnityEngine.Shader.Find("Sprites/Default")
	--self.fish_sr.material = newMat

	self:CreateHP()
	self:RefreshHP()
end

function C:MyRefresh()
	-- if not self.data then return end
	-- local m_fish = FishingDRModel.get_fish(self.data.fish_id)
	-- if not table_is_null(m_fish) then

	-- end		
end

function C:SetFishState(state)
	self.m_fish_state = state
end

function C:SetBox2D(b)
	if IsEquals(self.box2d) then
		self.box2d.enabled = b
	end
end

-- 设置层级
function C:SetLayer(order)
	print("1111111111111111111111111111111xxxxs11111111111")
	print(debug.traceback())
	local ps = self.gameObject:GetComponentsInChildren(typeof(UnityEngine.Renderer), true)
	local cha = order - self.fish_sr.sortingOrder
	for i = 0, ps.Length - 1 do
		ps[i].sortingOrder = ps[i].sortingOrder + cha
	end
end
-- 清除减速特效
function C:BackBing()
	if self.attr_obj then
		CachePrefabManager.Back(self.attr_obj)
		self.attr_obj = nil
	end	
end

-- 刷新血条
function C:RefreshHP()
	self:SetProgress(self.cur_hp, self.total_hp)

	percent = self.cur_hp / self.total_hp
	if percent < 0 then
		percent = 0
	elseif percent > 1 then
		percent = 1
	end 

	if percent <= hp_blink_limit then
		self:PlayHPBlink()
	else
		self:BackHPBlink()
	end
end

-- 创建血条
function C:CreateHP()
	if self.hp_obj then
		return
	end
	self.hp_obj = CachePrefabManager.Take("by_fish_hp_bar")
	self.hp_obj.prefab:SetParent(self.hp_node)
	self.hp_obj.prefab.prefabObj.transform.localPosition = Vector3.zero
	self.hp_obj.prefab.prefabObj.transform.localRotation = Quaternion.Euler(0, 0, 0)

	local tran = self.hp_obj.prefab.prefabObj.transform
	self.prog_bar1 = tran:Find("hp_node/prog_bg/prog_bar1"):GetComponent("SpriteRenderer")
	self.prog_bar2 = tran:Find("hp_node/prog_bg/prog_bar2"):GetComponent("SpriteRenderer")
	self.hp_default_size = self.prog_bar1.size

	--self:SetProgress(1, 2)
end

function C:SetProgress(cur, total)
	percent = cur / total

	if percent < 0 then
		percent = 0
	elseif percent > 1 then
		percent = 1
	end

	if percent > 0 and percent < 0.03 then
		percent = 0.03
	end 

	local pos_x = -(self.hp_default_size.x - self.hp_default_size.x * percent) / 2
	self.prog_bar1.size = {x = self.hp_default_size.x * percent, y = self.hp_default_size.y}
	self.prog_bar2.size = {x = self.hp_default_size.x * percent, y = self.hp_default_size.y}
	
	self.prog_bar1.transform.localPosition = Vector3.New(pos_x, 0, 0)
	self.prog_bar2.transform.localPosition = Vector3.New(pos_x, 0, 0)

	self.prog_bar1.gameObject:SetActive(percent > hp_red_limit)
	self.prog_bar2.gameObject:SetActive(percent <= hp_red_limit)
end

-- 创建减速特效
function C:CreateBing()
	if self.attr_obj then
		return
	end
	self.attr_obj = CachePrefabManager.Take("by_bs_jiansu_chixu")
	self.attr_obj.prefab:SetParent(self.hang_node)
	self.attr_obj.prefab.prefabObj.transform.localPosition = Vector3.zero
	self.attr_obj.prefab.prefabObj.transform.localRotation = Quaternion.Euler(0, 0, 0)
end
-- 清除加倍特效
function C:BackJB()
	if self.jb_obj then
		CachePrefabManager.Back(self.jb_obj)
		self.jb_obj = nil
	end	
end
-- 创建加倍特效
function C:CreateJB(rate)
	if self.jb_obj then
		return
	end
	self.jb_obj = CachePrefabManager.Take("by_fbjlx" .. rate)
	self.jb_obj.prefab:SetParent(self.hang_node)
	self.jb_obj.prefab.prefabObj:SetActive(false)
	local tran = self.jb_obj.prefab.prefabObj.transform
	tran.localPosition = Vector3.zero
	tran.localRotation = Quaternion.Euler(0, 0, 0)
	self.jb_obj.prefab.prefabObj:SetActive(true)
end

function C:Flee()
	FishingModel.set_fish_sp(self.data.fish_id)
	self:SetBox2D(false)
	if self.anim_time then
		self.anim_time:Stop()
	end
	local a = 1
	local sa = 0.1
	self.anim_time = Timer.New(function ()
		self.fish_sr.color = Color.New(1, 1, 1, a)
		if IsEquals(self.fish_shadow_sr) then
			self.fish_shadow_sr.color = Color.New(0, 0, 0, 80/255 * a)
		end
		a = a - sa
		if a < 0.1 then
			self:MyExit()
			if self.anim_time then
				self.anim_time:Stop()
			end
		end
	end, 0.1, 20)
	self.anim_time:Start()
end

function C:Hit()
	if self.anim_time then
		self.anim_time:Stop()
	end
	self.fish_sr.color = Color.New(1, 0.1, 0.2, 1)
	self.anim_time = Timer.New(function ()
		self.fish_sr.color = Color.New(1, 1, 1, 1)
		self.anim_time = nil
	end, 0.1, 1,true,false)
	self.anim_time:Start()
	self:RefreshHP()

	if self.baoji_data then
		self:RefreshBaoJi()
	else
		self:PlayHurt()
	end
end

function C:Dead(_dead_index,callback)
	_dead_index = 3
	if self.m_fish_state == FishingDRFishPrefab.FishState.FS_Dead then return end
	self.m_fish_state = FishingDRFishPrefab.FishState.FS_Dead
	self:SetBox2D(false)
	if self.anim_time then
		self.anim_time:Stop()
	end
	self:BackBing()
	self:BackJB()
	self:BackHPBlink()

	if IsEquals(self.fish_sr) then
		self.fish_sr.color = Color.New(1, 1, 1, 1)
	end
	local dead_cfg = FishingModel.Config.fish_dead_map[_dead_index] or FishingModel.Config.fish_dead_map[1]
	if self.anim_pay and IsEquals(self.anim_pay) then
		self.anim_pay.speed = dead_cfg.anim_speed or 1
	end
	local step_t = 0.02
	local all_t = 1
	local run_t = 0
	local scale
	if dead_cfg.anim_scale and dead_cfg.anim_scale ~= 1 then
		scale = (dead_cfg.anim_scale or 1) - 1
	end
	local rota
	local rota_speed
	if dead_cfg.anim_rota and dead_cfg.anim_rota ~= 0 then
		rota_speed = dead_cfg.anim_rota
	end

	self.anim_time = Timer.New(function ()
		local a = (all_t-run_t) / all_t
		local b = run_t / all_t
		self.fish_sr.color = Color.New(1, 1, 1, a)
		if self.fish_shadow then
			self.fish_shadow.color = Color.New(0, 0, 0, 80/255 * a)
		end
		if scale then
			local s = scale * b + 1
			self.transform.localScale = Vector3.New(s, s, s)
		end
		if rota_speed then
			rota = rota_speed * run_t
			self.transform.localRotation = Quaternion.Euler(0, 0, rota)
		end
		run_t = run_t + step_t
		if run_t >= all_t then
			self.anim_time:Stop()
			self.anim_time = nil
			self:MyExit()
			if callback then
				callback()
			end
		end
	end, step_t, -1,true,false)
	self.anim_time:Start()

	self.cur_hp = 0 
	self:RefreshHP()
end

function C:RefreshBaoJi()
	if self.baoji_data then
		-- 暴击效果
		-- print(string.format("!!!!!!!!!!!!!!!!!!!!!!!!!!baoji %d", self.data.fish_id))
		self:PlayBaoji()

		self.baoji_data = nil
	end	
end

-- 播放伤害特效
function C:PlayHurt()
	local hurt_obj = CachePrefabManager.Take("FishingDR_shouji")
	self.texiao[#self.texiao + 1] = hurt_obj

	--hurt_obj.prefab:SetParent(self.hang_node)
	local tran = hurt_obj.prefab.prefabObj.transform
	hurt_obj.prefab.prefabObj.transform.parent = GameObject.Find("Canvas/GUIRoot/FishingDRGamePanel").transform
	hurt_obj.prefab.prefabObj.transform.position = FishingModel.Get2DToUIPoint(self.hang_node.transform.position)

	--tran.localPosition = Vector3.zero
	--tran.localRotation = Quaternion.Euler(0, 0, 0)

	local timer = Timer.New(function()
		if hurt_obj then
			CachePrefabManager.Back(hurt_obj)
			hurt_obj = nil
		end
	end, 2, 1, false, false)
	timer:Start()
end

-- 播放暴击特效
function C:PlayBaoji()
	local baoji_obj = CachePrefabManager.Take("FishingDR_baoji")
	self.texiao[#self.texiao + 1] = baoji_obj

	local tran = baoji_obj.prefab.prefabObj.transform
	baoji_obj.prefab.prefabObj.transform.parent = GameObject.Find("Canvas/GUIRoot/FishingDRGamePanel").transform
	baoji_obj.prefab.prefabObj.transform.position = FishingModel.Get2DToUIPoint(self.hang_node.transform.position)

	-- tran.localPosition = Vector3.zero
	-- tran.localRotation = Quaternion.Euler(0, 0, 0)

	local timer = Timer.New(function()
		if baoji_obj then
			CachePrefabManager.Back(baoji_obj)
			baoji_obj = nil
		end
	end, 2, 1, false, false)
	timer:Start()
end

-- 播放血条闪烁特效
function C:PlayHPBlink()
	if self.hp_blink_obj then return end

	self.hp_blink_obj = CachePrefabManager.Take("by_fish_hp_bar_glow")
	self.hp_blink_obj.prefab:SetParent(self.hp_node)
	self.hp_blink_obj.prefab.prefabObj.transform.localPosition = Vector3.zero
	self.hp_blink_obj.prefab.prefabObj.transform.localRotation = Quaternion.Euler(0, 0, 0)
	self.hp_blink_obj.prefab.prefabObj.transform.localScale = Vector3.one
end

-- 清除血条闪烁特效
function C:BackHPBlink()
	if self.hp_blink_obj then
		CachePrefabManager.Back(self.hp_blink_obj)
		self.hp_blink_obj = nil
	end	
end


function C:RefreshUIPos()
	for k,v in pairs(self.texiao) do
		if v and v.prefab and IsEquals(v.prefab.prefabObj) and self.hang_node and IsEquals(self.hang_node) then
			--dump(v.prefab.prefabObj.transform.position)
			--dump((self.hang_node.transform.position),"<color=red>11111111111111111111111111111111111111111111111111111111111111111111</color>")
			v.prefab.prefabObj.transform.position = FishingModel.Get2DToUIPoint(self.hang_node.transform.position)
		end
	end
end 

--[[
	GetTexture("fkby_xt_icon_3")
]]