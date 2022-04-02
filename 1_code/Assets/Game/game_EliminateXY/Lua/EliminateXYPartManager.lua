-- 创建时间:2019-03-19
EliminateXYPartManager = {}
local M = EliminateXYPartManager
M.objs = {}
M.temp_objs = {}
function M.ExitTimer()
	M.ClearAllObj()
end
local _bgj_xf_obj = {}
local scroll_add_kuang = {}
function M.GetPrefab(name)
	if not M.objs[name] then
		M.objs[name] = newObject(name,M.GetRoot())
		M.objs[name].transform.position = Vector3.New(10000,10000,-10000)
	end
	return M.objs[name]
end

function M.GetRootNode()
	if not M.root_node then
		M.root_node = GameObject.Find("ParticleContent").transform
	end
	return M.root_node
end

function M.GetCenterRootNode()
	if not M.root_center_node then
		M.root_center_node = GameObject.Find("ParticleCenterContent").transform
	end
	return M.root_center_node
end

function M.GetRoot()
	if not M.root then
		M.root = GameObject.Find("GameObject").transform
	end
	return M.root
end

function M.Exit()
	M.root = nil
	for k,v in pairs(M.objs) do
		Destroy(v)
	end
	M.objs = {}
	for k,v in pairs(M.temp_objs) do
		Destroy(v)
	end
	M.temp_objs = {}

	for k,v in pairs(_bgj_xf_obj) do
		Destroy(v)
	end
	_bgj_xf_obj = {}
	for x,_v in pairs(scroll_add_kuang) do
		for y,v in pairs(_v) do
			Destroy(v.gameObject)
		end
	end
	scroll_add_kuang = {}
end

function M.ClearAllObj()
	for k,v in pairs(M.objs) do
		Destroy(v)
	end
	M.objs = {}
	for k,v in pairs(M.temp_objs) do
		if IsEquals(v) and IsEquals(v.gameObject) then
			Destroy(v)
		end
	end
	M.temp_objs = {}

	for k,v in pairs(_bgj_xf_obj) do
		Destroy(v)
	end
	_bgj_xf_obj = {}
	for x,_v in pairs(scroll_add_kuang) do
		for y,v in pairs(_v) do
			Destroy(v.gameObject)
		end
	end
	scroll_add_kuang = {}

	destroyChildren(M.GetRootNode())
	destroyChildren(M.GetCenterRootNode())
end

function M.CreateNumGoldInPos(pos,gold)
	if gold == 0 then return end 
	local obj = GameObject.Instantiate(M.GetPrefab("xxl_num") ,M.GetRootNode())
	obj.transform.position = Vector3.New(pos.x,pos.y,0)
	obj.transform.localScale = Vector3.zero
	local canvas = obj.transform:GetComponent("Canvas")
	canvas.sortingOrder = 3
	local gold_txt = obj.transform:Find("gold_txt"):GetComponent("Text")
	gold_txt.font = GetFont("by_tx1")	
	gold_txt.text = gold or 0
	
	local t = EliminateXYModel.time.xc_jb_pt_sz_fei_jg
	local seq = DoTweenSequence.Create()
	seq:AppendInterval(EliminateXYModel.GetTime(t * 2))
	seq:Append(obj.transform:DOScale(Vector3.one,EliminateXYModel.time.xc_jb_pt_sz_fd_jg))
	seq:Append(obj.transform:DOLocalMoveY(obj.transform.localPosition.y + 80,EliminateXYModel.time.xc_jb_pt_sz_yd_sj))
	seq:SetEase(DG.Tweening.Ease.OutCirc)
	seq:OnForceKill(function ()
		Destroy(obj)
	end)
end

function M.CreateNumGold(data,gold)
	if gold == 0 then return end 
	local pos = eliminate_xy_algorithm.get_center_pos(data)
	local obj = GameObject.Instantiate(M.GetPrefab("xxl_num") ,M.GetRootNode())
	obj.transform.localPosition = Vector3.New(pos.x,pos.y,0)
	obj.transform.localScale = Vector3.zero
	local canvas = obj.transform:GetComponent("Canvas")
	canvas.sortingOrder = 3
	-- obj.gameObject:SetActive(false)
	local gold_txt = obj.transform:Find("gold_txt"):GetComponent("Text")
	gold_txt.font = GetFont("by_tx1")	
	gold_txt.text = gold or 0
	
	local is_crite = #data >= 5
	local t = is_crite and EliminateXYModel.time.xc_jb_bj_sz_fei_jg or EliminateXYModel.time.xc_jb_pt_sz_fei_jg
	local seq = DoTweenSequence.Create()
	seq:AppendInterval(EliminateXYModel.GetTime(t * 2))
	seq:Append(obj.transform:DOScale(Vector3.one,EliminateXYModel.time.xc_jb_pt_sz_fd_jg))
	seq:Append(obj.transform:DOLocalMoveY(pos.y + 80,EliminateXYModel.time.xc_jb_pt_sz_yd_sj))
	seq:SetEase(DG.Tweening.Ease.OutCirc)
	seq:OnForceKill(function ()
		Destroy(obj)
	end)
end

function M.CreateCrit(data,gold)
	local pos = eliminate_xy_algorithm.get_center_pos(data)
	local seq1 = DoTweenSequence.Create()
	local is_crite = #data >= 5
	local t = is_crite and EliminateXYModel.time.xc_jb_bj_sz_fei_jg or EliminateXYModel.time.xc_jb_pt_sz_fei_jg
	seq1:AppendInterval(t)
	seq1:AppendCallback(function ()
		local seq = DoTweenSequence.Create()
		local obj = GameObject.Instantiate(M.GetPrefab("xxl_crit"),M.GetRootNode())
		obj.transform.localPosition = Vector3.New(pos.x,pos.y,0)
		seq:Append(obj.transform:DOScale(Vector3.one * 2,EliminateXYModel.time.xc_bj_fd)):SetEase(DG.Tweening.Ease.OutBack)
		seq:AppendInterval(EliminateXYModel.time.xc_bj_jg)
		seq:Append(obj.transform:DOScale(Vector3.zero,EliminateXYModel.time.xc_bj_sx))
		seq:OnForceKill(function ()
			M.CreateNumGold(data,gold)
			Destroy(obj)
		end)
	end)
end

function M.CreateEliminateParticleItem(data,templet,gold)
	if gold==0 then return end
	local templet_t = {}
	local seq = DoTweenSequence.Create()
	seq:AppendInterval(EliminateXYModel.time.xc_jb_pt_bjb_ys)
	seq:AppendCallback(function ()
		for k,v in pairs(data) do
			local obj = GameObject.Instantiate(templet,M.GetRootNode())
			obj.transform.localPosition = eliminate_xy_algorithm.get_pos_by_index(v.x,v.y)
			table.insert(M.temp_objs,obj )
			table.insert(templet_t,obj )
		end
	end)
	
	seq:AppendInterval(EliminateXYModel.GetTime(10))
	seq:OnForceKill(function ()
		for k,v in pairs(templet_t) do
			Destroy(v)
		end
	end)
	if gold==0 then return end
	if #data < 5 then
		M.CreateNumGold(data,gold)
		return
	end
	M.CreateCrit(data,gold)
end

function M.CreateEliminateNor1(data,gold)
	M.CreateEliminateParticleItem(data,M.GetPrefab("xxl_xy_bao_01"),gold)
end

function M.CreateEliminateNor2(data,gold)
	M.CreateEliminateParticleItem(data,M.GetPrefab("xxl_xy_bao_02"),gold)
end

function M.CreateEliminateNor3(data,gold)
	M.CreateEliminateParticleItem(data,M.GetPrefab("xxl_xy_bao_03"),gold)
end

function M.CreateEliminateSWK(data,lv)
	lv = lv or 1
	local templet = M.GetPrefab("xxl_xy_bao_0" .. lv)
	local templet_t = {}
	local seq = DoTweenSequence.Create()
	seq:AppendInterval(EliminateXYModel.time.xc_jb_pt_bjb_ys)
	seq:AppendCallback(function ()
		for k,v in pairs(data) do
			local obj = GameObject.Instantiate(templet,M.GetRootNode())
			obj.transform.localPosition = eliminate_xy_algorithm.get_pos_by_index(v.x,v.y)
			table.insert(M.temp_objs,obj )
			table.insert(templet_t,obj )
		end
	end)
	
	seq:AppendInterval(EliminateXYModel.GetTime(10))
	seq:OnForceKill(function ()
		for k,v in pairs(templet_t) do
			Destroy(v)
		end
	end)
end

function M.CreateEliminateTS(data,lv)
	lv = lv or 1
	local templet = M.GetPrefab("xxl_xy_bao_0" .. lv)
	local templet_t = {}
	local seq = DoTweenSequence.Create()
	seq:AppendInterval(EliminateXYModel.time.xc_jb_pt_bjb_ys)
	seq:AppendCallback(function ()
		for k,v in pairs(data) do
			local obj = GameObject.Instantiate(templet,M.GetRootNode())
			obj.transform.localPosition = eliminate_xy_algorithm.get_pos_by_index(v.x,v.y)
			table.insert(M.temp_objs,obj )
			table.insert(templet_t,obj )
		end
	end)
	
	seq:AppendInterval(EliminateXYModel.GetTime(5))
	seq:OnForceKill(function ()
		for k,v in pairs(templet_t) do
			Destroy(v)
		end
	end)
end

function M.CreateEliminateBGJ(data,lv,pd)
	lv = lv or 1
	local templet = M.GetPrefab("xxl_xy_bgj_bao")
	local templet_t = {}
	local seq = DoTweenSequence.Create()
	seq:AppendInterval(EliminateXYModel.time.xc_jb_pt_bjb_ys)
	seq:AppendCallback(function ()
		for k,v in pairs(data) do
			local obj = GameObject.Instantiate(templet,M.GetRootNode())
			obj.transform.localPosition = eliminate_xy_algorithm.get_pos_by_index(v.x,v.y)
			table.insert(M.temp_objs,obj )
			table.insert(templet_t,obj )
		end
	end)
	
	seq:AppendInterval(EliminateXYModel.GetTime(10))
	seq:OnForceKill(function ()
		for k,v in pairs(templet_t) do
			Destroy(v)
		end
	end)
	local rate = 0
	for x,_v in pairs(pd.bgj_rate_map) do
		for y,v in pairs(_v) do
			rate = v 
			if pd.bgj_rate_add_map and pd.bgj_rate_add_map[x] and pd.bgj_rate_add_map[x][y] then
				rate = rate + pd.bgj_rate_add_map[x][y]
			end
		end
	end
	local gold = EliminateXYModel.GetAwardGold(rate)
	if gold==0 then return end
	if #data < 5 then
		M.CreateNumGold(data,gold)
		return
	end
	M.CreateCrit(data,gold)
end

function M.CreateEliminateBGJ1(data,lv,rate,swk_skill)
	lv = lv or 1
	local templet = M.GetPrefab("xxl_xy_bgj_bao")
	local templet_t = {}
	local seq = DoTweenSequence.Create()
	-- seq:AppendInterval(EliminateXYModel.time.xc_jb_pt_bjb_ys)
	seq:AppendCallback(function ()
		for k,v in pairs(data) do
			local obj = GameObject.Instantiate(templet,M.GetRootNode())
			obj.transform.localPosition = eliminate_xy_algorithm.get_pos_by_index(v.x,v.y)
			table.insert(M.temp_objs,obj )
			table.insert(templet_t,obj )
		end
	end)
	
	seq:AppendInterval(EliminateXYModel.GetTime(10))
	seq:OnForceKill(function ()
		for k,v in pairs(templet_t) do
			Destroy(v)
		end
	end)

	local jb = function (  )
		if not swk_skill then return end
		local prefab
		if swk_skill == 1 then
			prefab = "xxl_swk_jiabei"
		elseif swk_skill == 2 then
			prefab = "xxl_swk_jiajiang"
		else
			return
		end
		for k,v in pairs(data) do
			local obj = GameObject.Instantiate(M.GetPrefab(prefab) ,M.GetRootNode())
			obj.transform.localPosition = eliminate_xy_algorithm.get_pos_by_index(v.x,v.y)
			table.insert(M.temp_objs,obj )
			table.insert(templet_t,obj )
		end
	end
	jb()
	local gold = EliminateXYModel.GetAwardGold(rate)
	if gold==0 then return end
	if #data < 5 then
		M.CreateNumGold(data,gold)
		return
	end
	M.CreateCrit(data,gold)
end

function M.CreateAllBlom(data)
	local radius = 100000
	local power = 40000
	local thrust = 30000

	local item_map = {}
	for x,_v in pairs(data) do
		for y,v in pairs(_v) do
			item_map[x] = item_map[x] or {}
			local obj = GameObject.Instantiate(EliminateXYObjManager.item_obj["EliminateXYItemPhysics" .. v.data.id],M.GetRootNode())
			item_map[x][y] = obj
			obj.transform.localPosition = eliminate_xy_algorithm.get_pos_by_index(x,y)
		end
	end
	local colliders = UnityEngine.Physics.OverlapSphere(Vector3.zero, radius)
	local rb_list = {}
	for i=0,colliders.Length - 1 do
		local hit = colliders[i]
		local rb = hit:GetComponent("Rigidbody")
		if rb then
			table.insert( rb_list,rb )
			rb.useGravity = true
			rb:AddExplosionForce(power, Vector3.New(-100,1500,-100), radius, 1800);
		end
	end

	local seq = DoTweenSequence.Create()
	seq:AppendInterval(EliminateXYModel.GetTime(8))
	seq:OnForceKill(function ()
		for x,_v in pairs(item_map) do
			for y,v in pairs(_v) do
				Destroy(v)
			end
		end
	end)
end

function M.XCNor(data,callback)
	local obj
	local fx_item_map = {}
	local fx_seq = {}
	local fx_map = {}
	local fx_obj
	local k_map = {}
	local seq = DoTweenSequence.Create()
	seq:AppendInterval(EliminateXYModel.GetTime(EliminateXYModel.time.xc_pt))
	seq:AppendCallback(function(  )
		local pos = eliminate_xy_algorithm.get_center_pos(data.cur_del_map)
		fx_obj = newObject("xxl_xy_tuowei_huang",M.GetRootNode())
		fx_obj.transform.localPosition = pos
		fx_obj.gameObject:SetActive(false)
		local t_pos =  Vector3.New(100,560,0)
		local seq_xx = DoTweenSequence.Create()
		table.insert( fx_seq,seq_xx)
		seq_xx:AppendInterval(EliminateXYModel.GetTime(0.02))
		seq_xx:AppendCallback(function(  )
			fx_obj.gameObject:SetActive(true)
		end)
		seq_xx:Append(fx_obj.transform:DOLocalMove(t_pos,0.6))
		seq_xx:SetEase(DG.Tweening.Ease.OutCirc)
		seq_xx:OnKill(function(  )
			Destroy(fx_obj.gameObject)
			fx_obj = nil
		end)
		seq_xx:OnForceKill(function(  )
			if fx_obj and IsEquals(fx_obj.gameObject) then
				Destroy(fx_obj.gameObject)
				fx_obj = nil
			end
		end)
	end)
	seq:AppendInterval(EliminateXYModel.GetTime(EliminateXYModel.time.swk_xc_hy))
	seq:AppendCallback(
		function()
			if callback and type(callback) == "function" then
				callback()
			end
		end
	)
	seq:AppendInterval(EliminateXYModel.GetTime(8))
	seq:OnForceKill(function ()
		for x,_v in pairs(fx_map) do
			for y,v in pairs(_v) do
				Destroy(v.gameObject)
				v = nil
			end
		end
		for i,v in ipairs(fx_seq) do
			v:Kill()
		end
	end)
end

function M.CreateChangeBlow(obj)
	if not IsEquals(EliminateSHHeroManager.GetHeroItemContent()) then return end
	local p_obj = GameObject.Instantiate(M.GetPrefab("xxl_luck_bianhuan"),EliminateSHHeroManager.GetHeroItemContent())
	table.insert(M.temp_objs,p_obj )
	p_obj.transform.localPosition = eliminate_xy_algorithm.get_pos_by_index(obj.x,obj.y)
	local seq = DoTweenSequence.Create()
	seq:AppendInterval(EliminateXYModel.GetTime(10))
	seq:OnForceKill(function ()
		Destroy(p_obj)
	end)
end

--唐僧摇奖出现
function M.CreateTSKuang(data)
	local k_map = {}
	local obj
	local seq = DoTweenSequence.Create()
	seq:AppendCallback(function()
		--框
		for x,_v in ipairs(data.map_base) do
			for y,v in ipairs(_v) do
				if v == EliminateXYModel.eliminate_enum.ts then
					k_map[x] = k_map[x] or {}
					k_map[x][y] = newObject("xxl_xy_ts_kuang",M.GetRootNode())
					k_map[x][y].transform.localPosition = eliminate_xy_algorithm.get_pos_by_index(x,y)
					k_map[x][y].gameObject:SetActive(true)	
				end
			end
		end
	end)
	seq:AppendInterval(EliminateXYModel.GetTime(EliminateXYModel.time.ts_cxtsk))
	seq:AppendCallback(function(  )
		for x,_v in pairs(k_map) do
			for y,v in pairs(_v) do
				Destroy(v.gameObject)
			end
		end
	end)
end

function M.XCSWK(data,callback)
	local obj
	local fx_item_map = {}
	local fx_seq = {}
	local fx_map = {}
	local fx_obj
	local k_map = {}
	local seq = DoTweenSequence.Create()
	-- table.insert( fx_seq,seq)
	seq:AppendInterval(EliminateXYModel.GetTime(0.2))
	seq:AppendCallback(function()
		obj = newObject("xxl_xy_black_mini",M.GetCenterRootNode())
		obj.transform.localPosition = Vector3.zero
		ExtendSoundManager.PlaySound(audio_config.sdbgj.bgm_sdbgj_swk_huo.audio_name)
		--框
		for i,v in ipairs(data.cur_del_map) do
			k_map[v.x] = k_map[v.x] or {}
			k_map[v.x][v.y] = newObject("xxl_xy_swk_kuang",M.GetRootNode())
			local pos = eliminate_xy_algorithm.get_pos_by_index(v.x,v.y)
			k_map[v.x][v.y].transform.localPosition = {x = pos.x,y = pos.y -  12,z = 0}
			k_map[v.x][v.y].gameObject:SetActive(true)
		end

		--放大缩小
		for i,data in ipairs(data.cur_del_map) do
			fx_item_map[data.x] = fx_item_map[data.x] or {}
			local _obj = EliminateXYItem.Create({x = data.x, y = data.y, id = data.v})
			if _obj and _obj.ui and IsEquals(_obj.ui.transform) then
				_obj.ui.transform.parent = M.GetRootNode()
				_obj.ui.transform.localScale = Vector3.one
			end
			fx_item_map[data.x][data.y] = _obj
			table.insert(M.temp_objs,fx_item_map[data.x][data.y] )
		end
	end)
	seq:AppendInterval(EliminateXYModel.GetTime(EliminateXYModel.time.swk_xc_qy))
	seq:AppendCallback(function(  )
		Destroy(obj)
		for x,_v in pairs(fx_item_map) do
			for y,v in pairs(_v) do
				v:Exit()
			end
		end	
	end)
	seq:AppendInterval(EliminateXYModel.GetTime(EliminateXYModel.time.xc_pt))
	seq:AppendCallback(function(  )
		local pos = eliminate_xy_algorithm.get_center_pos(data.cur_del_map)
		fx_obj = newObject("xxl_xy_tuowei_huang",M.GetRootNode())
		fx_obj.transform.localPosition = pos
		fx_obj.gameObject:SetActive(false)
		local t_pos = Vector3.New(100,560,0)
		local seq_xx = DoTweenSequence.Create()
		table.insert( fx_seq,seq_xx)
		seq_xx:AppendInterval(EliminateXYModel.GetTime(0.02))
		seq_xx:AppendCallback(function(  )
			fx_obj.gameObject:SetActive(true)
		end)
		seq_xx:Append(fx_obj.transform:DOLocalMove(t_pos,0.6))
		seq_xx:SetEase(DG.Tweening.Ease.OutCirc)
		seq_xx:OnKill(function(  )
			Destroy(fx_obj.gameObject)
			fx_obj = nil
		end)
		seq_xx:OnForceKill(function (  )
			if fx_obj and IsEquals(fx_obj.gameObject) then
				Destroy(fx_obj.gameObject)
				fx_obj = nil
			end
		end)
	end)
	--孙悟空后摇
	seq:AppendInterval(EliminateXYModel.GetTime(EliminateXYModel.time.swk_xc_hy))
	seq:AppendCallback(
		function()
			if callback and type(callback) == "function" then
				callback()
			end
			fx_item_map = {}
			for x,_v in pairs(k_map) do
				for y,v in pairs(_v) do
					Destroy(v.gameObject)
				end
			end
			k_map = {}
		end
	)
	seq:AppendInterval(EliminateXYModel.GetTime(8))
	seq:OnForceKill(function ()
		Destroy(obj)
		for x,_v in pairs(k_map) do
			for y,v in pairs(_v) do
				Destroy(v.gameObject)
			end
		end
		k_map = {}
		for x,_v in pairs(fx_item_map) do
			for y,v in pairs(_v) do
				v:Exit()
			end
		end
		for x,_v in pairs(fx_map) do
			for y,v in pairs(_v) do
				Destroy(v.gameObject)
				v = nil
			end
		end
		for i,v in ipairs(fx_seq) do
			v:Kill()
		end
	end)
end

function M.XCTS(data)
	local obj
	local fx_item_map = {}
	local fx_seq = {}
	local fx_map = {}
	local fx_obj
	local k_map = {}
	local seq = DoTweenSequence.Create()
	seq:AppendCallback(function()
		obj = newObject("xxl_xy_black_mini",M.GetCenterRootNode())
		obj.transform.localPosition = Vector3.zero

		--框
		for i,v in ipairs(data.cur_del_map) do
			k_map[v.x] = k_map[v.x] or {}
			k_map[v.x][v.y] = newObject("xxl_xy_ts_kuang",M.GetRootNode())
			k_map[v.x][v.y].transform.localPosition = eliminate_xy_algorithm.get_pos_by_index(v.x,v.y)
			k_map[v.x][v.y].gameObject:SetActive(true)
		end

		for i,data in ipairs(data.cur_del_map) do
			fx_item_map[data.x] = fx_item_map[data.x] or {}
			local _obj = EliminateXYItem.Create({x = data.x, y = data.y, id = data.v})
			if _obj and _obj.ui and IsEquals(_obj.ui.transform) then
				_obj.ui.transform.parent = M.GetRootNode()
				_obj.ui.transform.localScale = Vector3.one
				fx_item_map[data.x][data.y] = _obj
				table.insert(M.temp_objs,fx_item_map[data.x][data.y] )
			end
		end
	end)
	seq:AppendInterval(EliminateXYModel.GetTime(EliminateXYModel.time.ts_xc_qy))
	seq:AppendCallback(function(  )
		Destroy(obj)
		for x,_v in pairs(fx_item_map) do
			for y,v in pairs(_v) do
				v:Exit()
			end
		end	
	end)
	seq:AppendInterval(EliminateXYModel.GetTime(EliminateXYModel.time.xc_pt))
	seq:AppendCallback(function(  )
		local pos = eliminate_xy_algorithm.get_center_pos(data.cur_del_map)
		fx_obj = newObject("xxl_xy_tuowei_huang",M.GetRootNode())
		fx_obj.transform.localPosition = pos
		fx_obj.gameObject:SetActive(false)
		local t_pos = Vector3.New(1180,850,0)
		local seq_xx = DoTweenSequence.Create()
		table.insert( fx_seq,seq_xx)
		seq_xx:AppendInterval(EliminateXYModel.GetTime(0.02))
		seq_xx:AppendCallback(function(  )
			fx_obj.gameObject:SetActive(true)
		end)
		seq_xx:Append(fx_obj.transform:DOLocalMove(t_pos,0.6))
		seq_xx:SetEase(DG.Tweening.Ease.OutCirc)
		seq_xx:OnKill(function(  )
			Destroy(fx_obj.gameObject)
			fx_obj = nil
		end)
		seq_xx:OnForceKill(function (  )
			if fx_obj and IsEquals(fx_obj.gameObject) then
				Destroy(fx_obj.gameObject)
				fx_obj = nil
			end
		end)
	end)

	seq:AppendInterval(EliminateXYModel.GetTime(EliminateXYModel.time.ts_xc_hy))
	seq:AppendCallback(
		function()
			fx_item_map = {}
			for x,_v in pairs(k_map) do
				for y,v in pairs(_v) do
					Destroy(v.gameObject)
				end
			end
			k_map = {}
		end
	)
	seq:AppendInterval(EliminateXYModel.GetTime(8))
	seq:OnForceKill(function ()
		Destroy(obj)
		for x,_v in pairs(fx_item_map) do
			for y,v in pairs(_v) do
				v:Exit()
			end
		end
		for x,_v in pairs(fx_map) do
			for y,v in pairs(_v) do
				Destroy(v.gameObject)
				v = nil
			end
		end
		for i,v in ipairs(fx_seq) do
			v:Kill()
		end
	end)
end

function M.CreateSWKTW(o_pos,data)
	if table_is_null(data.bgj_xc_map) then return end
	local total_time = 1
	local xc_count = eliminate_xy_algorithm.get_xc_count(data.bgj_xc_map)
	local t = total_time / xc_count
	local temp_objs = {}
	local seq = DoTweenSequence.Create()
	seq:AppendInterval(EliminateXYModel.GetTime(EliminateXYModel.time.swk_jb_sg))
	for x,_v in pairs(data.bgj_xc_map) do
		for y,v in pairs(_v) do
			seq:AppendCallback(function(  )
				local pos = eliminate_xy_algorithm.get_pos_by_index(x,y)
				local seq2 = DoTweenSequence.Create()
				local obj = GameObject.Instantiate( M.GetPrefab("xxl_xy_tuowei_huang"),M.GetRootNode())
				table.insert(M.temp_objs,obj)
				table.insert(temp_objs,obj)
				obj.gameObject:SetActive(false)
				obj.transform.position = o_pos
				seq2:AppendInterval(EliminateXYModel.GetTime(0.02))
				seq2:AppendCallback(function(  )
					obj.gameObject:SetActive(true)
				end)
				seq2:Append(obj.transform:DOLocalMove(Vector3.New(pos.x,pos.y,0),EliminateXYModel.GetTime(EliminateXYModel.time.swk_jb_sg_yd))):SetEase(DG.Tweening.Ease.OutBack)
				seq2:OnForceKill(function ()
					Destroy(obj.gameObject)
				end)				
			end)	
		end
	end
	seq:AppendInterval(EliminateXYModel.GetTime(6))
	seq:OnForceKill(function ()
		for k,v in pairs(temp_objs) do
			Destroy(v)
		end
	end)
end

function M.CreateSWKTW1(o_pos,bgj_xc_map)
	if table_is_null(bgj_xc_map) then return end
	local temp_objs = {}
	local xc_count = eliminate_xy_algorithm.get_xc_count(bgj_xc_map)
	local seq = DoTweenSequence.Create()
	for x,_v in pairs(bgj_xc_map) do
		for y,v in pairs(_v) do
			local pos = eliminate_xy_algorithm.get_pos_by_index(x,y)
			local obj = GameObject.Instantiate( M.GetPrefab("xxl_xy_tuowei_huang"),M.GetRootNode())
			table.insert(M.temp_objs,obj)
			table.insert(temp_objs,obj)
			obj.gameObject:SetActive(false)
			obj.transform.position = o_pos
			seq:AppendInterval(EliminateXYModel.GetTime(0.02))
			seq:AppendCallback(function(  )
				obj.gameObject:SetActive(true)
			end)
			seq:Append(obj.transform:DOLocalMove(Vector3.New(pos.x,pos.y,0),EliminateXYModel.GetTime(EliminateXYModel.time.swk_jb_sg_yd)))
			seq:AppendInterval(EliminateXYModel.GetTime(0.04))
			seq:AppendCallback(function ()
				EliminateXYAnimManager.DOShakePositionCamer(nil,EliminateXYModel.GetTime(EliminateXYModel.time.bgj_xc_zd))
				Destroy(obj.gameObject)
			end)
		end
	end
	seq:AppendInterval(EliminateXYModel.GetTime(6))
	seq:OnForceKill(function ()
		for i,v in ipairs(temp_objs) do
			Destroy(v)
		end
	end)
end

function M.CreateTW(o_pos,t_pos,obj_name,callback)
	local temp_objs = {}
	local seq = DoTweenSequence.Create()
	local obj = GameObject.Instantiate( M.GetPrefab(obj_name),M.GetRootNode())
	table.insert(M.temp_objs,obj)
	table.insert(temp_objs,obj)
	obj.gameObject:SetActive(false)
	obj.transform.localPosition = o_pos
	seq:AppendInterval(EliminateXYModel.GetTime(0.02))
	seq:AppendCallback(function(  )
		obj.gameObject:SetActive(true)
	end)
	seq:Append(obj.transform:DOLocalMove(Vector3.New(t_pos.x,t_pos.y,0),EliminateXYModel.GetTime(EliminateXYModel.time.swk_jb_sg_yd)))
	seq:AppendInterval(EliminateXYModel.GetTime(0.04))
	seq:AppendCallback(function ()
		EliminateXYAnimManager.DOShakePositionCamer(nil,EliminateXYModel.GetTime(EliminateXYModel.time.bgj_xc_zd))
		Destroy(obj.gameObject)
	end)	
	seq:AppendInterval(EliminateXYModel.GetTime(6))
	seq:OnForceKill(function ()
		for i,v in ipairs(temp_objs) do
			Destroy(v)
		end
	end)
end



function M.XCBGJ(data,_tpos)
	local fx_seq = {}
	local fx_obj
	local seq = DoTweenSequence.Create()
	seq:AppendInterval(EliminateXYModel.GetTime(EliminateXYModel.time.bgj_xc))
	seq:AppendCallback(function(  )
		local pos = eliminate_xy_algorithm.get_center_pos(data.cur_del_map)
		fx_obj = newObject("xxl_xy_tuowei",M.GetRootNode())
		fx_obj.transform.localPosition = pos
		fx_obj.gameObject:SetActive(true)
		local t_pos = _tpos or Vector3.New(730,560,0)
		local seq_xx = DoTweenSequence.Create()
		table.insert( fx_seq,seq_xx)
		seq_xx:Append(fx_obj.transform:DOLocalMove(t_pos,EliminateXYModel.GetTime(EliminateXYModel.time.bgj_xc_fx)))
		seq_xx:SetEase(DG.Tweening.Ease.OutCirc)
		seq_xx:OnKill(function(  )
			Destroy(fx_obj.gameObject)
			fx_obj = nil
		end)
		seq_xx:OnForceKill(function (  )
			if fx_obj and IsEquals(fx_obj.gameObject) then
				Destroy(fx_obj.gameObject)
			end
		end)
	end)
	seq:AppendInterval(EliminateXYModel.GetTime(8))
	seq:OnForceKill(function ()
		for i,v in ipairs(fx_seq) do
			v:Kill()
		end
	end)
end

function M.CreateBGJTW(o_pos,next_data)
	if table_is_null(next_data.xc_change_data) then return end
	local total_time = 1
	local xc_count = eliminate_xy_algorithm.get_xc_count(next_data.xc_change_data)
	local t = total_time / xc_count
	local _temp_obj = {}
	local seq = DoTweenSequence.Create()
	for x,_v in pairs(next_data.xc_change_data) do
		for y,v in pairs(_v) do
			seq:AppendCallback(function(  )
				local seq2 = DoTweenSequence.Create()
				local pos = eliminate_xy_algorithm.get_pos_by_index(x,y)
				local obj = GameObject.Instantiate( M.GetPrefab("xxl_xy_bgj_huo_tuowei"),M.GetRootNode())
				table.insert(M.temp_objs,obj)
				table.insert(_temp_obj,obj)
				obj.gameObject:SetActive(true)
				obj.transform.position = o_pos
				seq2:AppendInterval(EliminateXYModel.GetTime(EliminateXYModel.time.bgj_sl_tw_dd))
				seq2:AppendCallback(function(  )
					local r = M.BGJRotation[x][y]
					obj.transform.rotation = Quaternion.Euler(0, 0, r)
				end)
				seq2:Append(obj.transform:DOLocalMove(Vector3.New(pos.x,pos.y,0),EliminateXYModel.GetTime(EliminateXYModel.time.bgj_sl_tw_yd))):SetEase(DG.Tweening.Ease.OutBack)
				seq2:AppendInterval(EliminateXYModel.GetTime(EliminateXYModel.time.bgj_sl_tw_zs))
				seq2:AppendCallback(function(  )
					Destroy(obj.gameObject)
					local bs_obj = GameObject.Instantiate( M.GetPrefab("xxl_xy_bianshen_mini"),M.GetRootNode())
					table.insert(M.temp_objs,bs_obj)
					table.insert(_temp_obj,bs_obj)
					bs_obj.transform.localPosition = pos
					ExtendSoundManager.PlaySound(audio_config.sdbgj.bgm_sdbgj_bgj_sl.audio_name)
				end)
				seq2:AppendInterval(EliminateXYModel.GetTime(EliminateXYModel.time.bgj_sl_gb))
				seq2:AppendCallback(function ()
					local money = StringHelper.ToCash(EliminateXYModel.GetAwardGold(next_data.bgj_rate_map[x][y]))
					local obj1 = EliminateXYObjManager.item_obj["EliminateXYItem" .. v]
					if obj1 and IsEquals(obj1) then
						local parent = M.GetRootNode()
						obj1 = GameObject.Instantiate(obj1,parent)
						obj1.transform.localPosition = eliminate_xy_algorithm.get_pos_by_index(x,y)
						local bg = obj1.gameObject.transform:Find("@bg")
						bg.gameObject:SetActive(true)
						local money_txt = obj1.gameObject.transform:Find("@money_txt"):GetComponent("Text")
						money_txt.text = money or ""
						EliminateXYItem.ChangeMoneyTxtLayer(money_txt,6)
						EliminateXYItem.MoneyPlayAni(money_txt,money,6,true)
						table.insert(M.temp_objs,obj1)
						-- table.insert(_temp_obj,obj1)
						_bgj_xf_obj = _bgj_xf_obj or {}
						table.insert(_bgj_xf_obj,obj1)
					end
				end)
			end)
			seq:AppendInterval(EliminateXYModel.GetTime(EliminateXYModel.time.bgj_sl_tw_jg))
		end
	end
	seq:AppendInterval(EliminateXYModel.GetTime(6))
	seq:OnForceKill(function ()
		for k,v in pairs(_temp_obj) do
			Destroy(v)
		end
		_temp_obj = {}
	end)
end

function M.DestroyBGJXFObj()
	for k,v in pairs(_bgj_xf_obj) do
		Destroy(v)
	end
	_bgj_xf_obj = {}
end

function M.BGJBSMini(x,y)
	local _temp_obj = {}
	local seq = DoTweenSequence.Create()
	seq:AppendCallback(function(  )
		local seq2 = DoTweenSequence.Create()
		local pos = eliminate_xy_algorithm.get_pos_by_index(x,y)
		local bs_obj = GameObject.Instantiate( M.GetPrefab("xxl_xy_bianshen_mini"),M.GetRootNode())
		bs_obj.transform.localPosition = pos
		table.insert(M.temp_objs,bs_obj)
		table.insert(_temp_obj,bs_obj)
	end)
	seq:AppendInterval(EliminateXYModel.GetTime(4))
	seq:OnForceKill(function ()
		for k,v in pairs(_temp_obj) do
			Destroy(v)
		end
		_temp_obj = {}
	end)
end

function M.CreateBGJBlom(obj)
	local radius = 100000
	local power = 40000
	local thrust = 30000
	local colliders = UnityEngine.Physics.OverlapSphere(Vector3.zero, radius)
	local rb_list = {}
	for i=0,colliders.Length - 1 do
		local hit = colliders[i]
		local rb = hit:GetComponent("Rigidbody")
		if rb then
			table.insert( rb_list,rb )
			rb.useGravity = true
			rb:AddExplosionForce(power, Vector3.New(-100,1500,-100), radius, 1800);
		end
	end

	local seq = DoTweenSequence.Create()
	seq:AppendInterval(EliminateXYModel.GetTime(8))
	seq:OnForceKill(function ()
		if IsEquals(obj) then
			Destroy(obj)
		end
	end)
end

--额外转动的提示框
function M.CreateScrollAddKuang(_x,y,id)
	local seq = DoTweenSequence.Create()
	seq:AppendInterval(EliminateXYModel.GetTime(1))
	seq:AppendCallback(function ()
		EliminateXYHeroManager.ShowNodeHuo(_x,true)
		local pre
		if id == EliminateXYModel.eliminate_enum.swk then
			pre = "xxl_xy_swk_kuang"
		elseif id == EliminateXYModel.eliminate_enum.ts then
			pre = "xxl_xy_ts_kuang"
		end
		for x=_x - 2, _x - 1 do
			scroll_add_kuang[x] = scroll_add_kuang[x] or {}
			scroll_add_kuang[x][y] = newObject(pre,M.GetRootNode())
			scroll_add_kuang[x][y].transform.localPosition = eliminate_xy_algorithm.get_pos_by_index(x,y)
			scroll_add_kuang[x][y].gameObject:SetActive(true)
		end
	end)
end

function M.DestroyScrollAddKuang(_x,y)
	EliminateXYHeroManager.ShowNodeHuo(_x,false)
	for x=_x - 2, _x - 1 do
		if scroll_add_kuang[x] and scroll_add_kuang[x][y] and IsEquals(scroll_add_kuang[x][y]) then
			Destroy(scroll_add_kuang[x][y].gameObject)
			scroll_add_kuang[x][y] = nil
		end
	end
end

function M.DestroyAllScrollAddKuang(  )
	for x=1,EliminateXYModel.size.max_x do
		EliminateXYHeroManager.ShowNodeHuo(x,false)
	end
	for x,_v in pairs(scroll_add_kuang) do
		for y,v in pairs(_v) do
			Destroy(v.gameObject)
		end
	end
	scroll_add_kuang = {}
end

function M.ClearAll()
	M.DestroyBGJXFObj()
    M.DestroyAllScrollAddKuang()
end

M.BGJRotation = {
	[1] = {
		[1] = -35,[2] = -40,[3] = -50,[4] = -70
	},
	[2] = {
		[1] = -15,[2] = -30,[3] = -45,[4] = -60
	},
	[3] = {
		[1] = 0,[2] = 0,[3] = 0,[4] = 0
	},
	[4] = {
		[1] = 15,[2] = 30,[3] = 45,[4] = 60
	},
	[5] = {
		[1] = 35,[2] = 40,[3] = 50,[4] = 70
	},
}