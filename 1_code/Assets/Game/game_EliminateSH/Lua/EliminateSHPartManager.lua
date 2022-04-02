-- 创建时间:2019-03-19
EliminateSHPartManager = {}
local M = EliminateSHPartManager
M.objs = {}
M.temp_objs = {}

function M.ExitTimer()

end

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

function M.GetRoot()
	if not M.root then
		M.root = GameObject.Find("GameObject").transform
	end
	return M.root
end

function M.Exit()
	M.root = nil
	M.ClearFxItemMap()
	for k,v in pairs(M.objs) do
		Destroy(v)
	end
	M.objs = {}
	for k,v in pairs(M.temp_objs) do
		Destroy(v)
	end
	M.temp_objs = {}
end

function M.CreateNumGold(data,gold)
	if gold == 0 then return end 
	local pos = eliminate_sh_algorithm.get_center_pos(data)
	local obj = GameObject.Instantiate(M.GetPrefab("xxl_sh_NumGlodPrefab") ,M.GetRootNode())
	obj.transform.localPosition = Vector3.New(pos.x,pos.y,0)
	obj.transform.localScale = Vector3.zero
	local canvas = obj.transform:GetComponent("Canvas")
	canvas.sortingOrder = 3
	-- obj.gameObject:SetActive(false)
	local gold_txt = obj.transform:Find("gold_txt"):GetComponent("Text")
	gold_txt.font = GetFont("by_tx1")	
	gold_txt.text = gold or 0
	
	local is_crite = #data >= 5
	local t = is_crite and EliminateSHModel.time.xc_jb_bj_sz_fei_jg or EliminateSHModel.time.xc_jb_pt_sz_fei_jg
	local seq = DoTweenSequence.Create()
	seq:AppendInterval(t)
	seq:Append(obj.transform:DOScale(Vector3.one,EliminateSHModel.time.xc_jb_pt_sz_fd_jg))
	seq:Append(obj.transform:DOLocalMoveY(pos.y + 80,EliminateSHModel.time.xc_jb_pt_sz_yd_sj))
	seq:SetEase(DG.Tweening.Ease.OutCirc)
	seq:OnForceKill(function ()
		Destroy(obj)
	end)
end

function M.CreateCrit(data,gold)
	local pos = eliminate_sh_algorithm.get_center_pos(data)
	local seq1 = DoTweenSequence.Create()
	local is_crite = #data >= 5
	local t = is_crite and EliminateSHModel.time.xc_jb_bj_sz_fei_jg or EliminateSHModel.time.xc_jb_pt_sz_fei_jg
	seq1:AppendInterval(t)
	seq1:AppendCallback(function ()
		local seq = DoTweenSequence.Create()
		local obj = GameObject.Instantiate(M.GetPrefab("xxl_crit_game_eliminatesh"),M.GetRootNode())
		obj.transform.localPosition = Vector3.New(pos.x,pos.y,0)
		seq:Append(obj.transform:DOScale(Vector3.one * 2,EliminateSHModel.time.xc_bj_fd)):SetEase(DG.Tweening.Ease.OutBack)
		seq:AppendInterval(EliminateSHModel.time.xc_bj_jg)
		seq:Append(obj.transform:DOScale(Vector3.zero,EliminateSHModel.time.xc_bj_sx))
		seq:OnForceKill(function ()
			M.CreateNumGold(data,gold)
			Destroy(obj)
		end)
	end)
end

function M.CreateDouble(data)
	local pos = eliminate_sh_algorithm.get_center_pos(data)
	local seq1 = DoTweenSequence.Create()
	seq1:AppendInterval(EliminateSHModel.time.yx_1_jn_jb_sz_ks_jg)
	seq1:AppendCallback(function ()
		--print(debug.traceback())
		if not IsEquals(M.GetRootNode()) then return end
		local seq = DoTweenSequence.Create()
		local obj = GameObject.Instantiate(M.GetPrefab("xxl_double"),M.GetRootNode())
		obj.transform.localPosition = Vector3.New(pos.x,pos.y + 100,0)
		seq:Append(obj.transform:DOLocalMoveY(pos.y + 180,EliminateSHModel.time.yx_1_jn_jb_sz_yd))
		seq:SetEase(DG.Tweening.Ease.OutCirc)
		seq:Insert(0,obj.transform:DOScale(Vector3.one * 1.2,EliminateSHModel.time.xc_bj_fd)):SetEase(DG.Tweening.Ease.OutBack)
		seq:Insert(EliminateSHModel.time.xc_bj_jg +  EliminateSHModel.time.xc_bj_fd,obj.transform:DOScale(Vector3.one,EliminateSHModel.time.xc_bj_sx))
		seq:OnForceKill(function ()
			Destroy(obj)
		end)
	end)
end

function M.CreateHero1TW(o_pos,data)
	local pos = eliminate_sh_algorithm.get_center_pos(data)
	local obj0 =  GameObject.Instantiate(M.GetPrefab("xxl_sh_wusong_shouxian"),M.GetRootNode())
	table.insert(M.temp_objs,obj0)
	obj0.transform.position = o_pos
	local seq1 = DoTweenSequence.Create()
	seq1:AppendInterval(EliminateSHModel.GetTime(EliminateSHModel.time.yx_1_jn_jb_sg))
	seq1:AppendCallback(function ()
		local seq = DoTweenSequence.Create()
		local mb = EliminateSHHeroManager.GetHero1TW()
		local obj = GameObject.Instantiate(mb,EliminateSHHeroManager.GetHero1Part3())
		table.insert(M.temp_objs,obj)
		obj.gameObject:SetActive(true)
		obj.transform.localPosition = Vector3.zero
		seq:Append(obj.transform:DOLocalMove(Vector3.New(pos.x,pos.y,0),EliminateSHModel.GetTime(EliminateSHModel.time.yx_1_jn_jb_sg_yd))):SetEase(DG.Tweening.Ease.OutBack)
		seq:OnForceKill(function ()
			M.CreateDouble(data)
			Destroy(obj.gameObject)
		end)
	end)
	seq1:AppendInterval(EliminateSHModel.GetTime(EliminateSHModel.time.yx_1_jn_jb_sg_js))
	seq1:OnForceKill(function ()
		Destroy(obj0)
	end)
end

function M.CreateEliminateParticleItem(data,templet,gold,ishero1)
	if gold==0 then return end
	local templet_t = {}
	for k,v in pairs(data) do
		local obj = GameObject.Instantiate(M.GetPrefab("xxl_sh_kuang"),M.GetRootNode())
		obj.transform.localPosition = eliminate_sh_algorithm.get_pos_by_index(v.x,v.y)
		table.insert(M.temp_objs,obj )
		table.insert(templet_t,obj )
	end
	local seq = DoTweenSequence.Create()
	seq:AppendInterval(EliminateSHModel.time.xc_jb_pt_bjb_ys)
	seq:AppendCallback(function ()
		for k,v in pairs(data) do
			local obj = GameObject.Instantiate(templet,M.GetRootNode())
			obj.transform.localPosition = eliminate_sh_algorithm.get_pos_by_index(v.x,v.y)
			table.insert(M.temp_objs,obj )
			table.insert(templet_t,obj )
		end
	end)
	
	seq:AppendInterval(5)
	seq:OnForceKill(function ()
		for k,v in pairs(templet_t) do
			Destroy(v)
		end
	end)

	if gold==0 then return end

	-- if ishero1 then
	-- 	M.CreateDouble(data)
	-- end

	if #data < 5 then
		M.CreateNumGold(data,gold)
		return
	end
	M.CreateCrit(data,gold)
end

function M.CreateEliminateNor1(data,gold)
	M.CreateEliminateParticleItem(data,M.GetPrefab("xxl_sh_bao1"),gold)
end

function M.CreateEliminateNor2(data,gold)
	M.CreateEliminateParticleItem(data,M.GetPrefab("xxl_sh_bao2"),gold)
end

function M.CreateEliminateNor3(data,gold)
	M.CreateEliminateParticleItem(data,M.GetPrefab("xxl_sh_bao3"),gold)
end

function M.CreateEliminateWS1(data,gold)
	M.CreateEliminateParticleItem(data,M.GetPrefab("xxl_sh_bao1_ws_buff"),gold,true)
end

function M.CreateEliminateWS2(data,gold)
	M.CreateEliminateParticleItem(data,M.GetPrefab("xxl_sh_bao2_ws_buff"),gold,true)
end

function M.CreateEliminateWS3(data,gold)
	M.CreateEliminateParticleItem(data,M.GetPrefab("xxl_sh_bao3_ws_buff"),gold,true)
end

function M.CreateLuckyRight(map,t)
	-- dump(obj, "<color=yellow>lucky自己闪光特效</color>")
	local objs = {}
	for x,_v in pairs(map) do
		for y,v in pairs(_v) do
			if IsEquals(M.GetRootNode()) then
				local p_obj = GameObject.Instantiate(M.GetPrefab("xxl_sh_lingpai"),M.GetRootNode())
				p_obj.transform.localPosition = eliminate_sh_algorithm.get_pos_by_index(x,y)
				table.insert(objs,p_obj)
			end
		end
	end
	
	local seq = DoTweenSequence.Create()
	seq:AppendInterval(t)
	seq:OnForceKill(function ()
		for i,v in ipairs(objs) do
			Destroy(v)
		end
	end)
end

function M.CreateFruitBlow(obj)
	ExtendSoundManager.PlaySound(audio_config.shxxl.bgm_shxxl_luzhishen3.audio_name)
	if not IsEquals(EliminateSHHeroManager.GetHeroItemContent()) then return end
	local p_obj = GameObject.Instantiate(M.GetPrefab("xxl_luck_bianhuan_game_eliminatesh"),EliminateSHHeroManager.GetHeroItemContent())
	table.insert(M.temp_objs,p_obj )
	p_obj.transform.localPosition = eliminate_sh_algorithm.get_pos_by_index(obj.x,obj.y)
	local seq = DoTweenSequence.Create()
	seq:AppendInterval(5)
	seq:OnForceKill(function ()
		Destroy(p_obj)
	end)
end

function M.ChangeAllItem(cur_result)
	local item_map = EliminateSHObjManager.GetAllEliminateItem()
	local x1 = 4
	local x2 = 5
	local y1 = 4
	local y2 = 5
	local y = 1
	local map = {}
	local hash_map = {}
	local add_item_map = {}
	local id = cur_result.hero_skill[3].id
	local seq = DoTweenSequence.Create()
	for i=1,4 do
		seq:AppendCallback(function ()
			map = {}
			for x=x1,x2 do
				for y=y1,y2 do
					if not hash_map or not hash_map[x] or not hash_map[x][y] then
						map[x] = map[x] or {}
						map[x][y] = id
						hash_map[x] = hash_map[x] or {}
						hash_map[x][y] = id
					end
				end
			end
			EliminateSHObjManager.RemoveEliminateItem(map)
			add_item_map = EliminateSHObjManager.AddEliminateItem(map)
			EliminateSHAnimManager.DOShakePositionObjs(add_item_map,EliminateSHModel.GetTime(EliminateSHModel.time.yx_3_jn_dd))
			x1 = x1 - 1
			x2 = x2 + 1
			y1 = y1 - 1		
			y2 = y2 + 1		
		end)
		seq:AppendInterval(EliminateSHModel.GetTime(EliminateSHModel.time.yx_3_jn_gb_jg))
	end
end

function M.ChangeAllItemOverall(cur_result)
	local item_map = EliminateSHObjManager.GetAllEliminateItem()
	local random_count = 6
	local id = cur_result.hero_skill[3].id
	local random_map = {}
	local add_item_map = {}
	local seq = DoTweenSequence.Create()
	for i=1,random_count do
		seq:AppendCallback(function ()
			local _id = i
			for x=1,8 do
				for y=1,8 do
					random_map[x] = random_map[x] or {}
					random_map[x][y] = _id
				end
			end
			EliminateSHObjManager.RemoveEliminateItem(random_map)
			EliminateSHObjManager.AddEliminateItem(random_map)
		end)
		seq:AppendInterval(EliminateSHModel.GetTime(EliminateSHModel.time.yx_3_jn_gb_jg2))
	end
	seq:AppendCallback(function ()
		for x=1,8 do
			for y=1,8 do
				random_map[x] = random_map[x] or {}
				random_map[x][y] = id
			end
		end
		EliminateSHObjManager.RemoveEliminateItem(random_map)
		add_item_map = EliminateSHObjManager.AddEliminateItem(random_map)
		EliminateSHAnimManager.DOShakePositionObjs(add_item_map,EliminateSHModel.GetTime(EliminateSHModel.time.yx_3_jn_dd))
	end)
end

function M.CreateAllBlom(data)
	local radius = 100000
	local power = 40000
	local thrust = 30000

	local item_map = {}
	for x,_v in pairs(data) do
		for y,v in pairs(_v) do
			item_map[x] = item_map[x] or {}
			local obj = GameObject.Instantiate(EliminateSHObjManager.item_obj["EliminateSHItemPhysics" .. v.data.id],M.GetRootNode())
			item_map[x][y] = obj
			obj.transform.localPosition = eliminate_sh_algorithm.get_pos_by_index(x,y)
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
	seq:AppendInterval(4)
	seq:OnForceKill(function ()
		for x,_v in pairs(item_map) do
			for y,v in pairs(_v) do
				Destroy(v)
			end
		end
	end)
end