-- 创建时间:2019-06-10
-- 鱼的基类

local basefunc = require "Game/Common/basefunc"
-- 表现模式 高级
local show_pattern = false
FishBase = basefunc.class()
local C = FishBase
C.name = "FishBase"

FishBase.FishState = 
{
	FS_Nor="正常",
	FS_Flee="逃离",
	FS_Hit="受击",
	FS_Dead="死亡",
	FS_FeignDead="假装死亡",
}
local r_zero = Quaternion.Euler(0, 0, 0)

function C.Create(parent, data, parm, is_game_create)
	return C.New(parent, data, parm, is_game_create)
end

function C:FrameUpdate()
	if not self.isInPool then
		-- 初始化
		if self:CheckIsInPool_Whole() then
			self.isInPool = 1
		else
			self.isInPool = -1
		end
	else
		if self.isInPool == -1 and self:CheckIsInPool_Whole() then
			self.isInPool = 1
		elseif self.isInPool == 1 and not self:CheckIsInPool_Whole() then
			self.isInPool = -1
			-- 从池子游出去
			if self.m_fish_state == FishBase.FishState.FS_Flee or
				self.m_fish_state == FishBase.FishState.FS_Dead or
				self.m_fish_state == FishBase.FishState.FS_FeignDead then
				return
			end

			if self.data.fish_id then
				Event.Brocast("fish_out_pool", "fish_out_pool", self.data.fish_id)
			end
		end
	end
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
    for proto_name,func in pairs(self.lister or {}) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:UpdateTransform(pos, r)
	if not IsEquals(self.transform) then return end
	local is_change_move_fw
	if self.fish_cfg.change_lookat and self.fish_cfg.change_lookat == 1 then
		-- 处理倒游	自适应方向
		local old_x = self.transform.localPosition.x
		if old_x < pos.x then
			if not self.fish_move_fw or self.fish_move_fw ~= -1 then
				is_change_move_fw = true
				self.fish_move_fw = -1--从左往右游动
			end
		else
			if not self.fish_move_fw or self.fish_move_fw ~= 1 then
				is_change_move_fw = true
				self.fish_move_fw = 1--从右往左游动
			end
		end
	end

	if is_change_move_fw then
		if self.fish_cfg.prefab == "Fish_Act" or self.fish_cfg.prefab == "Fish052" then
			if self.fish_move_fw == 1 then
				self.transform.localScale = Vector3.New(-1,1,1)
			else
				self.transform.localScale = Vector3.New(1,1,1)
			end
		end
	end

	self.transform.localPosition = Vector3.New(pos.x, pos.y, 0)
	if not (self.fish_cfg and self.fish_cfg.close_rota and self.fish_cfg.close_rota == 1) then
		self.transform.rotation = Quaternion.Euler(0, 0, r)
		--活动道具类背的东西不旋转
		if self.use_fish_cfg and self.use_fish_cfg.attr_id == FishingSkillManager.FishDeadAppendType.Zongzi then
			self.hang_node.transform.rotation = r_zero
		end
	end
	if self.is_show_blood then
		self.transform_ui.position = FishingModel.Get2DToUIPoint(self.transform.position)
	end

	if self.is_one_pos then
		self.is_one_pos = false
		if self.is_game_create and self.fish_cfg.whirlpool and self:CheckIsInPool_Whole() then
			FishingAnimManager.PlayCreateFishFX(self.transform, self.fish_cfg.whirlpool)
		end
	end
end

function C:MyExit()
	if self.anim_time then
		self.anim_time:Stop()
		self.anim_time = nil
	end
	if self.time_face_fx then
		self.time_face_fx:Stop()
		self.time_face_fx = nil
	end
	if self.time_face_run then
		self.time_face_run:Stop()
		self.time_face_run = nil
	end
	if self.cx_seq then
		self.cx_seq:Kill()
		self.cx_seq = nil
	end
	if self.data.fish_id then
		FishManager.RemoveFishByID(self.data.fish_id)
	end
	self:RemoveListener()
	self:Back_attrobj()
	self:Back_iceobj()
	self:Back_deadattrobj()
	self:Back_faceobj()
	self:Back_fishfxobj()
	
	if show_pattern then
		for i = 1, #self.fish do
			self.fish[i].material = FishManager.material1
		end
	end
	if self.fish then
		for i = 1, #self.fish do
			self.fish[i].color = Color.New(1, 1, 1, 1)
			if self.fish_cfg and self.fish_cfg.id == 20 then
				self.fish[i].transform.localScale = Vector3.New(1.3, 1.3, 1.3)
			else
				self.fish[i].transform.localScale = self.BeforeScale[i] or Vector3.one
			end
		end
	end
	if IsEquals(self.fish_shadow) then
		self.fish_shadow.color = Color.New(0, 0, 0, 80/255)
	end
	if IsEquals(self.anim_pay) then
		self.anim_pay.speed = 1
	end
	self.transform.localScale = Vector3.New(1, 1, 1)

	if self.prefab_blood then
		CachePrefabManager.Back(self.prefab_blood)
		self.prefab_blood = nil
	end

	CachePrefabManager.Back(self.prefab)
end

function C:ctor(parent, data, parm, is_game_create)
	self.parent = parent
	self.data = data
	self.parm = parm
	self.is_game_create = is_game_create

	self.panelSelf = FishingLogic.GetPanel()

	self.use_fish_cfg = FishingModel.Config.use_fish_map[data.fish_type]
	self.fish_cfg = FishingModel.Config.fish_map[self.use_fish_cfg.fish_id]
	self.append_attr = self.use_fish_cfg.attr_id

	if self.fish_cfg.prefab == "Fish_Act" then
		local a, _cfg = GameButtonManager.RunFunExt("act_ty_by_drop", "GetFishConfig")
		if a and _cfg then
			self.m_fish_name = _cfg.prefab
		else
			self.m_fish_name = "Fish_Act"
		end
	else
		if self.parm.prefab then
			self.m_fish_name = self.parm.prefab
		else
			self.m_fish_name = self.fish_cfg.prefab
		end
	end

	self.prefab = CachePrefabManager.Take(self.m_fish_name, nil, 10)
	if self.prefab == nil then return end
    self.prefab.prefab:SetParent(parent)
	local tran = self.prefab.prefab.prefabObj.transform
	self.transform = tran
	self.gameObject = tran.gameObject
	tran.localRotation = Quaternion.Euler(0, 0, 0)

	self.gameObject.name = self.parm.obj_name
	self.isInPool = nil
	self.m_fish_state = FishBase.FishState.FS_Nor
	self.is_one_pos = true

	self.box2d = tran:GetComponent("BoxCollider2D")
	self.lock_node = tran:Find("lock_node")
	self.hang_node = tran:Find("hang_node")
	if self.parm.fish_anim then
		self.anim_pay = tran:Find(self.parm.fish_anim):GetComponent("Animator")
	else
		self.anim_pay = tran:GetComponent("Animator")
	end
	local sortingOrder
	if self.parm.sortingOrder then
		sortingOrder = self.parm.sortingOrder
	else
		sortingOrder = self.fish_cfg.id * 10
		self.parm.sortingOrder = sortingOrder
	end
	if self.parm.fish_list then
		self.fish = {}
		self.BeforeScale = {}
		for i = 1, #self.parm.fish_list do
			self.fish[#self.fish + 1] = tran:Find(self.parm.fish_list[i]):GetComponent("SpriteRenderer")
			self.fish[i].sortingOrder = sortingOrder + i - 1
			local bs = self.fish[i].transform.localScale
			self.BeforeScale[i] = bs
			if show_pattern then
				self.fish[i].material = FishManager.material2
				if self.append_attr and self.append_attr == FishingSkillManager.FishDeadAppendType.Boom then
					self.fish[1].material:SetColor("_LightColor", Color.red)
				else
					self.fish[1].material:SetColor("_LightColor", Color.New(109/255, 76/255, 34/255))
				end
			end
		end
	end
	if self.parm.fish_tran then
		self.fish_tran = tran:Find(self.parm.fish_tran):GetComponent("Transform")
	end
	if self.parm.fish_shadow then
		self.fish_shadow = tran:Find(self.parm.fish_shadow):GetComponent("SpriteRenderer")
		self.fish_shadow.sortingOrder = sortingOrder - 1
	end

	self.sizeDelta = {x=self.fish_cfg.size_w, y=self.fish_cfg.size_h}

	self:MakeLister()
	self:AddMsgListener()
	--亲嘴鱼
	if self.fish_cfg.id == 30 then
		self.transform:Find("aixin").gameObject:SetActive(true)
	end

	--配合活动鱼的左右，暂时不走这
	if false and self.is_game_create then
		if self.data.rate and self.data.rate == 1 then
			self.transform.localScale = Vector3.zero
			self.cx_seq = DoTweenSequence.Create()
		    self.cx_seq:Join(self.transform:DOScale(1.5, 0.75))
		    self.cx_seq:Append(self.transform:DOScale(1, 0.75))
		    self.cx_seq:OnKill(function()
		    	self.cx_seq = nil
		    	self.transform.localScale = Vector3.one
	        end)
		else
			self.transform.localScale = Vector3.zero
			self.cx_seq = DoTweenSequence.Create()
		    self.cx_seq:Join(self.transform:DOScale(1, 0.5))
		    self.cx_seq:OnKill(function()
		    	self.cx_seq = nil
		    	self.transform.localScale = Vector3.one
	        end)
		end
	end
end

-----*******************------
-- 血量鱼相关
-----*******************------
function C:CreateBlood()
	local pos = self.fish_cfg.blood_pos
	local scale =self.fish_cfg.blood_scale
	self.max_ui_len = 416

	self.is_show_blood = true
	-- UI表现
	self.prefab_blood = CachePrefabManager.Take("FishComBloodUI")
    self.prefab_blood.prefab:SetParent(self.panelSelf.FXNode)
	local tran_ui = self.prefab_blood.prefab.prefabObj.transform
	self.transform_ui = tran_ui
	self.gameObject_ui = tran_ui.gameObject
	self.gameObject_ui.name = "Blood" .. self.data.fish_id
	
	self.Node = tran_ui:Find("Node")
	self.Node.localRotation = Quaternion.Euler(0, 0, 0)
	self.Node.localPosition = pos
	self.Node.localScale = scale

	self.blood = tran_ui:Find("Node/blood_mask/blood")
	self.blood_mask = tran_ui:Find("Node/blood_mask")
	self.BloodImage = self.blood:GetComponent("Image")
	self.BloodRect = self.blood:GetComponent("RectTransform")

	-- 血量相关
	self.blood_state = 1
	self.blood_color_list = { Color.New(117/ 255,244/ 255,48/ 255), Color.New(255/ 255,183/ 255,20/ 255), Color.New(241/ 255,50/ 255,2/ 255) }
	self:SetColorLerp(0)
	self:UpdateBlood({data={self.data.ori_life}})
end
function C:SetColorLerp(lerp)
	local colorStart = self.blood_color_list[self.blood_state]
	local colorEnd = self.blood_color_list[self.blood_state + 1]
	self.BloodImage.color = Color.Lerp(colorStart, colorEnd, lerp)
end
-- 刷新血量
function C:UpdateBlood(data)
	if not self.is_show_blood then
		return
	end
	if not data or not data.data or #data.data ~= 1 then
		dump(data, "<color=red>刷新数据改变</color>")
		return
	end
	local rr = data.data[1]/self.data.ori_life
	if rr > 1 then
		rr = 1
	end
	local ww = self.max_ui_len * rr
	local c1 = rr
	self.BloodImage.color = Color.New(1, c1, c1)
	if rr > 0.5 then
		self.blood_state = 1
		self:SetColorLerp((1 - rr) / (0.5))
	else
		self.blood_state = 2
		self:SetColorLerp((0.5 - rr) / (0.5))
	end

	self.BloodRect.sizeDelta = {x=ww, y=26}
end

-- 设置层级
function C:SetLayer(order)
	local ps = self.gameObject:GetComponentsInChildren(typeof(UnityEngine.Renderer), true)
	local cha = order - self.fish[1].sortingOrder
	for i = 0, ps.Length - 1 do
		ps[i].sortingOrder = ps[i].sortingOrder + cha
	end
end

function C:Back_attrobj()
	if self.attr_obj then
		local ps = self.attr_obj.prefab.prefabObj:GetComponentsInChildren(typeof(UnityEngine.ParticleSystem), true)
		for i = 0, ps.Length - 1 do
			local _s = ps[i].transform.localScale
			ps[i].transform.localScale = Vector3.New(_s.x / self.attr_scale, _s.y / self.attr_scale, _s.z / self.attr_scale)
		end

		CachePrefabManager.Back(self.attr_obj)
		self.attr_obj = nil
	end	
end

function C:Back_iceobj()
	if self.IceCubePrefab then
		local ps = self.IceCubePrefab.prefab.prefabObj:GetComponentsInChildren(typeof(UnityEngine.ParticleSystem), true)
		for i = 0, ps.Length - 1 do
			local _s = ps[i].transform.localScale
			ps[i].transform.localScale = Vector3.New(_s.x / self.ice_scale, _s.y / self.ice_scale, _s.z / self.ice_scale)
		end

		CachePrefabManager.Back(self.IceCubePrefab)
		self.IceCubePrefab = nil
		self.IceCubeAnim = nil
	end	
end
function C:Back_deadattrobj()
	if self.dead_attr_obj then
		local ps = self.dead_attr_obj.prefab.prefabObj:GetComponentsInChildren(typeof(UnityEngine.ParticleSystem), true)
		for i = 0, ps.Length - 1 do
			local _s = ps[i].transform.localScale
			ps[i].transform.localScale = Vector3.New(_s.x / self.dead_attr_scale, _s.y / self.dead_attr_scale, _s.z / self.dead_attr_scale)
		end

		CachePrefabManager.Back(self.dead_attr_obj)
		self.dead_attr_obj = nil
	end	
end
-- 表情
function C:Back_faceobj()
	if self.face_obj then
		CachePrefabManager.Back(self.face_obj)
		self.face_obj = nil
	end	
end
-- 常规特效
function C:Back_fishfxobj()
	if self.fish_fx_obj then
		for k,v in ipairs(self.fish_fx_obj) do
			CachePrefabManager.Back(v)
		end
		self.fish_fx_obj = nil
	end	
end

-- 修改鱼身上的特效层级
function C:ChangeLayer(obj, scale, isUp)
	local vec_scale = Vector3.New(scale, scale, scale)

	local meshs = obj.gameObject:GetComponentsInChildren(typeof(UnityEngine.SpriteRenderer))
	local ps = obj.gameObject:GetComponentsInChildren(typeof(UnityEngine.Renderer), true)
	obj.transform.localScale = vec_scale
	local min = 9999999
	local max = -9999999
	for i = 0, ps.Length - 1 do
		ps[i].sortingLayerName = "1"
		local _s = ps[i].transform.localScale
		ps[i].transform.localScale = Vector3.New(_s.x * scale, _s.y * scale, _s.z * scale)
		if max < ps[i].sortingOrder then
			max = ps[i].sortingOrder
		end
		if min > ps[i].sortingOrder then
			min = ps[i].sortingOrder
		end
	end
	for i = 0, meshs.Length - 1 do
		local _s = meshs[i].transform.localScale
		meshs[i].transform.localScale = Vector3.New(_s.x / scale, _s.y / scale, _s.z / scale)
	end

	if isUp then
		max = self.fish[1].sortingOrder - min + 1
	else
		max = self.fish[1].sortingOrder - max - 1
	end

	for i = 0, ps.Length - 1 do
		ps[i].sortingOrder = ps[i].sortingOrder + max
	end
end
function C:InitUI()
	self:SetBox2D(true)
	local prefab_name
	local is_show_up
	local scale = 1
	local attr = self.use_fish_cfg.attr_id
	
	if attr then
		local cfg = FishingModel.Config.fish_attr_map[attr]
		if cfg then
			prefab_name = cfg.prefab
			is_show_up = cfg.is_show_up
			if attr == FishingSkillManager.FishDeadAppendType.Boom then
				scale = self.fish_cfg.fx_scale
			elseif attr == FishingSkillManager.FishDeadAppendType.Lightning then
				scale = self.fish_cfg.ice_lightning
			elseif attr == FishingSkillManager.FishDeadAppendType.LockCard or
				attr == FishingSkillManager.FishDeadAppendType.IceCard
				or attr == FishingSkillManager.FishDeadAppendType.Zongzi
				or attr == FishingSkillManager.FishDeadAppendType.summon_fish then

				scale = self.fish_cfg.ice_card
			elseif attr == FishingSkillManager.FishDeadAppendType.ZT_bullet then
				scale = 0.6
			else
				scale = self.fish_cfg.gq_scale
			end
		end
	elseif self.data.isTeam then
		prefab_name = "turntable_1"
		is_show_up = 0
		scale = self.fish_cfg.gq_scale
	elseif self.data.group_id then
		-- 一网打尽要区分颜色 nmg todo
		prefab_name = "turntable_ywdj"
		is_show_up = 0
		scale = self.fish_cfg.gq_scale
	end
	
	if prefab_name then
		if prefab_name == "zongzi" then
			local a, _pre = GameButtonManager.RunFunExt("act_ty_by_drop", "GetFishAttrPrefab", nil, self.use_fish_cfg.ex_id)
			if a and _pre then
				self.attr_obj = _pre
			end
		end
		if not self.attr_obj then
			self.attr_obj = CachePrefabManager.Take(prefab_name)
		end
		self.attr_obj.prefab:SetParent(self.hang_node)
		self.attr_obj.prefab.prefabObj.transform.localPosition = Vector3.zero
		self.attr_obj.prefab.prefabObj.transform.localRotation = Quaternion.Euler(0, 0, 0)
		local cfg = FishingModel.Config.fish_attr_map[attr]		
		
		self.attr_scale = scale
		if is_show_up == 1 then
			self:ChangeLayer(self.attr_obj.prefab.prefabObj, self.attr_scale, true)
		else
			self:ChangeLayer(self.attr_obj.prefab.prefabObj, self.attr_scale, false)
		end
	end
	self:PlayFaceAnim()

	-- 常规特效
	if self.fish_cfg.fish_fx then
		self.fish_fx_obj = {}
		for i = 1, #self.fish_cfg.fish_fx, 2 do
			local nn = self.fish_cfg.fish_fx[i]
			local up = self.fish_cfg.fish_fx[i+1]
			obj = CachePrefabManager.Take(nn)
			obj.prefab:SetParent(self.hang_node)
			obj.prefab.prefabObj:SetActive(false)
			obj.prefab.prefabObj.transform.localPosition = Vector3.zero
			obj.prefab.prefabObj.transform.localRotation = Quaternion.Euler(0, 0, 0)
			obj.prefab.prefabObj:SetActive(true)
			if up == 1 then
				self:ChangeLayer(obj.prefab.prefabObj, scale, true)
			else
				self:ChangeLayer(obj.prefab.prefabObj, scale, false)
			end
			self.fish_fx_obj[#self.fish_fx_obj + 1] = obj
		end
	end
end

function C:MyRefresh()
end

function C:PlayFaceAnim()
	if self.fish_cfg.face_ids then
		local t = math.random(10, 20)
		self.time_face_fx = Timer.New(function ()
			self.time_face_fx:Stop()

			local f_id = math.random(1, #self.fish_cfg.face_ids)
			local cfg = FishingModel.Config.fish_face_map[f_id]
			if cfg then
				self.face_obj = CachePrefabManager.Take(cfg.effect)
				self.face_obj.prefab:SetParent(self.hang_node)
				self.face_obj.prefab.prefabObj.transform.localPosition = Vector3.New(0.48, 0, 0)
				self.face_obj.prefab.prefabObj.transform.localRotation = Quaternion.Euler(0, 0, 0)
				self:ChangeLayer(self.face_obj.prefab.prefabObj, 1, true)
				if cfg.voice then
					ExtendSoundManager.PlaySound(cfg.voice .. ".mp3", 1)
				end
				self.time_face_run = Timer.New(function ()
					self:Back_faceobj()
				end, cfg.run_time or 2)
				self.time_face_run:Start()
				self:PlayFaceAnim()
			end
		end, t)
		self.time_face_fx:Start()
	end	
end

function C:Print()
	dump(self.data, "<color=red>Print 1111</color>")
	dump(self.parm, "<color=red>Print 2222</color>")
end

function C:GetFishState()
	return self.m_fish_state
end
-- 是否在鱼池中
function C:CheckIsInPool()
	if self.m_fish_state == FishBase.FishState.FS_Flee or
		self.m_fish_state == FishBase.FishState.FS_Dead or
		self.m_fish_state == FishBase.FishState.FS_FeignDead then
		return false
	end
    if math.abs(self.transform.position.x) < FishingModel.Defines.WorldDimensionUnit.xMax and 
    	math.abs(self.transform.position.y) < FishingModel.Defines.WorldDimensionUnit.yMax then
        return true
    else
        return false
    end
end
-- 是否完全在鱼池中
function C:CheckIsInPool_Whole()
	if self.m_fish_state == FishBase.FishState.FS_Flee or
		self.m_fish_state == FishBase.FishState.FS_Dead or
		self.m_fish_state == FishBase.FishState.FS_FeignDead then
		return false
	end
    if (math.abs(self.transform.position.x) + 0.5) < FishingModel.Defines.WorldDimensionUnit.xMax and 
    	(math.abs(self.transform.position.y) + 0.5) < FishingModel.Defines.WorldDimensionUnit.yMax then
        return true
    else
        return false
    end
end

-- 是否完全在鱼池外
function C:CheckIsOutPool_Whole()
	local pp = {}
    pp[1] = PointToWorldSpace({x=-1 * self.sizeDelta.x/2, y=self.sizeDelta.y/2}, self.fish_tran.right, self.fish_tran.up, self.fish_tran.position)
    pp[2] = PointToWorldSpace({x=1 * self.sizeDelta.x/2, y=self.sizeDelta.y/2}, self.fish_tran.right, self.fish_tran.up, self.fish_tran.position)
    pp[3] = PointToWorldSpace({x=-1 * self.sizeDelta.x/2, y=-1 * self.sizeDelta.y/2}, self.fish_tran.right, self.fish_tran.up, self.fish_tran.position)
    pp[4] = PointToWorldSpace({x=1 * self.sizeDelta.x/2, y=-1 * self.sizeDelta.y/2}, self.fish_tran.right, self.fish_tran.up, self.fish_tran.position)
    pp[5] = {x=pp[1].x, y=pp[1].y}
    local xMax = FishingModel.Defines.WorldDimensionUnit.xMax
    local yMax = FishingModel.Defines.WorldDimensionUnit.yMax
    local ww = {}
	ww[1] = {x = -1 * xMax, y = yMax}
	ww[2] = {x = 1 * xMax, y = yMax}
	ww[3] = {x = -1 * xMax, y = -1 * yMax}
	ww[4] = {x = 1 * xMax, y = -1 * yMax}
	ww[5] = {x = -1 * xMax, y = yMax}
    for i = 1, 4 do
    	local a = pp[i]
    	local b = pp[i+1]
    	for j = 1, 4 do
    		local c = ww[j]
    		local d = ww[j+1]
	    	if (math.min(a.x,b.x) <= math.max(c.x,d.x) and math.min(c.y,d.y) <= math.max(a.y,b.y)
	    		and math.min(c.x,d.x) <= math.max(a.x,b.x) and  math.min(a.y,b.y) <= math.max(c.y,d.y)) then	    		
	    		return false
	    	end
    	end
    end
    return true
end

-- 设置冰冻状态
function C:SetIceState(isIce)
	if self.m_fish_state == FishBase.FishState.FS_Dead or self.m_fish_state == FishBase.FishState.FS_Flee then
		return
	end
	self.isIce = isIce
	if isIce then
		self.anim_pay.speed = 0
		if not self:CheckIsOutPool_Whole() then
			if self.fish_cfg.ice_type == "bytx_cool1" then
				self.IceCubePrefab = CachePrefabManager.Take("IceCubePrefab1")
				self.IceCubePrefab.prefab:SetParent(self.hang_node)
			else
				self.IceCubePrefab = CachePrefabManager.Take("IceCubePrefab2")
				self.IceCubePrefab.prefab:SetParent(self.hang_node)
			end
			local tran = self.IceCubePrefab.prefab.prefabObj.transform
			tran.localPosition = Vector3.zero
			tran.localRotation = Quaternion.Euler(0, 0, 0)
			local scale = self.fish_cfg.ice_scale
			self.ice_scale = scale
			self:ChangeLayer(self.IceCubePrefab.prefab.prefabObj, scale, true)
			self.IceCubeAnim = self.IceCubePrefab.prefab.prefabObj.transform:GetComponent("Animator")
			self.IceCubeAnim:Play("binrongjie_nor_anim", -1, 0)
		end
	else
		self.anim_pay.speed = 1
		self:Back_iceobj()
	end
end
-- 冰冻解封
function C:SetIceDeblocking()
	if self.IceCubeAnim then
		self.IceCubeAnim:Play("binrongjie_anim", -1, 0)
	end
end

function C:SetBox2D(b)
	if self.box2d then
		self.box2d.enabled = b
	end
end

-- 标记鱼假死
function C:SetFeignDead(b)
	if self.m_fish_state == FishBase.FishState.FS_Dead or self.m_fish_state == FishBase.FishState.FS_Flee then
		return
	end
	if b then
		self.m_fish_state = FishBase.FishState.FS_FeignDead
		self:SetBox2D(false)
	else
		self.m_fish_state = FishBase.FishState.FS_Nor
		self:SetBox2D(true)
	end
end

function C:Flee()
	if self.m_fish_state ~= FishBase.FishState.FS_Dead and self.m_fish_state ~= FishBase.FishState.FS_Flee and
		self.m_fish_state ~= FishBase.FishState.FS_FeignDead then
		self:Back_attrobj()
		self:Back_iceobj()
		self:Back_fishfxobj()

		self.m_fish_state = FishBase.FishState.FS_Flee
		self:SetBox2D(false)
		if self.anim_time then
			self.anim_time:Stop()
		end
		local a = 1
		local sa = 0.05
		self.anim_time = Timer.New(function ()
			for i = 1, #self.fish do
				self.fish[i].color = Color.New(1, 1, 1, a)
			end
			if IsEquals(self.fish_shadow) then
				self.fish_shadow.color = Color.New(0, 0, 0, 80/255 * a)
			end
			a = a - sa
		end, 0.1, 20)
		self.anim_time:Start()
	end
end

function C:Hit()
	if self.m_fish_state ~= FishBase.FishState.FS_Dead and self.m_fish_state ~= FishBase.FishState.FS_Flee then
		self.m_fish_state = FishBase.FishState.FS_Hit
		if self.anim_time then
			self.anim_time:Stop()
		end

		if show_pattern then
			for i = 1, #self.fish do
				self.fish[i].material:SetColor("_LightColor", Color.white)
			end
		else
			for i = 1, #self.fish do
				self.fish[i].color = Color.New(1, 0.1, 0.2, 1)
			end
		end
		self.anim_time = Timer.New(function ()
			if show_pattern then
				if self.append_attr and self.append_attr == FishingSkillManager.FishDeadAppendType.Boom then
					for i = 1, #self.fish do
						self.fish[i].material:SetColor("_LightColor", Color.red)
					end
				else
					for i = 1, #self.fish do
						self.fish[i].material:SetColor("_LightColor", Color.New(109/255, 76/255, 34/255))
					end
				end
			else
				for i = 1, #self.fish do
					self.fish[i].color = Color.New(1, 1, 1, 1)
				end
			end
			self.anim_time = nil
			self.m_fish_state = FishBase.FishState.FS_Nor
		end, 0.1, 1)
		self.anim_time:Start()
	end
end

function C:Dead(_dead_index, call)
	if self.data.isTeam or self.data.group_id then
		self.dead_attr_obj = CachePrefabManager.Take("Ywdj_Siwang")
		self.dead_attr_obj.prefab:SetParent(self.hang_node)
		self.dead_attr_obj.prefab.prefabObj.transform.localPosition = Vector3.zero
		self.dead_attr_obj.prefab.prefabObj.transform.localRotation = Quaternion.Euler(0, 0, 0)

		self.dead_attr_scale = self.fish_cfg.gq_scale * 1.5
		self:ChangeLayer(self.dead_attr_obj.prefab.prefabObj, self.dead_attr_scale, true)

		self:ShowDead(_dead_index, call)
	else
		self:ShowDead(_dead_index, call)
	end
end

-- 死亡表现
function C:ShowDead(_dead_index, call)
	if audio_config.by["bgm_by_siwang"..self.fish_cfg.id] and audio_config.by["bgm_by_siwang"..self.fish_cfg.id].audio_name then
		ExtendSoundManager.PlaySound(audio_config.by["bgm_by_siwang"..self.fish_cfg.id].audio_name)
	end
	
	if self.prefab_blood then
		CachePrefabManager.Back(self.prefab_blood)
		self.prefab_blood = nil
	end
	self:SetBox2D(false)
	self.m_fish_state = FishBase.FishState.FS_Dead
	if self.anim_time then
		self.anim_time:Stop()
	end
	-- 特效不删，有表现
	if not self.data.isTeam and not self.data.group_id then
		self:Back_attrobj()
	end
	self:Back_iceobj()
	self:Back_fishfxobj()

	VehicleManager.RemoveVehicle(self.data.fish_id)

	for i = 1, #self.fish do
		self.fish[i].color = Color.New(1, 1, 1, 1)
	end
	local dead_index = self.fish_cfg.dead_index
	if _dead_index then
		dead_index = _dead_index
	end

	local dead_cfg = FishingModel.Config.fish_dead_map[dead_index] or FishingModel.Config.fish_dead_map[1]

	self.anim_pay.speed = dead_cfg.anim_speed or 1
	local step_t = 0.02
	local all_t = dead_cfg.anim_time or 1
	local run_t = 0
	local scale
	if dead_cfg.anim_scale and dead_cfg.anim_scale ~= 1 then
		scale = (dead_cfg.anim_scale or 1) - 1
	end
	--亲嘴鱼
	if self.fish_cfg.id == 30 then
		self.transform:Find("aixin").gameObject:SetActive(false)
	end
	local rota
	local rota_speed
	if dead_cfg.anim_rota and dead_cfg.anim_rota ~= 0 then
		rota_speed = dead_cfg.anim_rota
	end

	self.anim_time = Timer.New(function ()
		local a = (all_t-run_t) / all_t
		local b = run_t / all_t
		for i = 1, #self.fish do
			self.fish[i].color = Color.New(1, 1, 1, a)
		end
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
			if call then
				call()
			end
		end
	end, step_t, -1)
	self.anim_time:Start()

	if self.data.fish_id then
		Event.Brocast("fish_out_pool", "fish_out_pool", self.data.fish_id)
	end
end

function C:Tag()
	self:SetBox2D(false)
	for i = 1, #self.fish do
		self.fish[i].color = Color.New(1, 1, 1, 1)
	end
	if self.data.fish_id then
		VehicleManager.RemoveVehicle(self.data.fish_id)
		FishManager.RemoveFishByID(self.data.fish_id)
	end

	self.anim_pay.speed = 0
end

--鱼的类型
function C:GetFishType()
	return self.fish_cfg.id
end
--鱼的特殊奖励？？？
function C:GetFishAward()
	return nil
end

-- 鱼的组别
function C:GetFishGroup()
	return self.data.group_id
end

-- 鱼的额外属性
function C:GetFishAttr()
	return self.use_fish_cfg.attr_id
end
-- 鱼是否是敢死队
function C:GetFishTeam()
	return self.data.isTeam
end

-- 鱼的倍率
function C:GetFishRate()
	return self.fish_cfg.rate
end
-- 锁定点
function C:GetLockPos()
	return self.lock_node.transform.position
end
-- 鱼的名字 图片
function C:GetFishNameToSprite()
	return self.fish_cfg.name_image
end

-- 爆炸表现 pos是爆炸鱼的坐标
function C:BoomHit(pos)
	VehicleManager.Stop(self.data.fish_id)
	local tpos = self:GetPos()
	local cha = tpos - pos
	local len = Vec2DLength({x=cha.x, y=cha.y})
	if len > 4 then
		len = 4
	end
	local mass = self.fish_cfg.mass or 1
	if mass == 0 then
		mass = 1
	end
	local scale = (4-len) / 4 * (1/mass)
	local epos = Vector3.Normalize(cha) * 3 * scale + tpos

	local seq = DoTweenSequence.Create()
	seq:Append(self.transform:DOMove(epos, 0.5):SetEase(DG.Tweening.Ease.OutQuint))
	seq:OnKill(function ()
		if IsEquals(self.transform) then
		VehicleManager.Recover(self.data.fish_id, self.transform.position)
		end
	end)
end

function C:GetPos()
	local tpos = self.transform.position
	return Vector3.New(tpos.x, tpos.y, 0)
end