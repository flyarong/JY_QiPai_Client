-- 创建时间:2019-03-19
EliminatePartManager = {}
local M = EliminatePartManager
M.objs = {}
M.temp_objs = {}

function M.ExitTimer(  )
	if M.create_fruit_blows_timer then M.create_fruit_blows_timer:Stop() end
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

function M.CreateNumGold(data,win_lucky)
	local pos = eliminate_algorithm.get_center_pos(data)
	local tmpl = M.GetPrefab("xxl_NumGlodPrefab")
	local rootNode = M.GetRootNode()
	if not IsEquals(tmpl) or not IsEquals(rootNode) then
		return
	end
	local obj = GameObject.Instantiate(tmpl, rootNode)
	obj.transform.localPosition = Vector3.New(pos.x,pos.y,0)
	obj.transform.localScale = Vector3.zero
	local canvas = obj.transform:GetComponent("Canvas")
	canvas.sortingOrder = 3
	-- obj.gameObject:SetActive(false)
	local tiem = Timer.New(function(  )
		
	end,1,2)
	local gold_txt = obj.transform:Find("gold_txt"):GetComponent("Text")
	gold_txt.font = GetFont("by_tx1")	
	if win_lucky then
		local win_lucky_index
		for i,win_list in ipairs(win_lucky.win_list) do
			for j,v in ipairs(win_list) do
				if v.x == data[1].x and v.y == data[1].y and v.id == data[1].id then
					win_lucky_index = i
				end
			end
		end
		if not win_lucky_index then
			gold_txt.text = EliminateInfoPanel.ReturnAward(data)
		else
			if EliminateModel.data.all_award_data and next(EliminateModel.data.all_award_data) then
				for i,v in ipairs(EliminateModel.data.all_award_data) do
					if v.is_lucky == 1 and v.jb then
						gold_txt.text = v.jb
					end
				end
			else
				gold_txt.text = EliminateInfoPanel.ReturnAward(data)
			end
		end
	else
		gold_txt.text = EliminateInfoPanel.ReturnAward(data)
	end
	
	obj.transform:Find("crite").gameObject:SetActive(false)
	local is_crite = #data >= 5
	local t = is_crite and 1.2 or 2
	local seq = DoTweenSequence.Create()
	seq:AppendInterval(t)
	seq:Append(obj.transform:DOScale(Vector3.one,0.02))
	seq:Append(obj.transform:DOLocalMoveY(pos.y + 80,0.3))
	seq:SetEase(DG.Tweening.Ease.OutCirc)
	seq:OnForceKill(function ()
		Destroy(obj)
	end)
end

function M.CreateCrit(data,win_lucky)
	if #data < 5 then
		M.CreateNumGold(data,win_lucky)
		return
	end
	local pos = eliminate_algorithm.get_center_pos(data)

	local obj = GameObject.Instantiate(M.GetPrefab("xxl_crit_game_eliminate"),M.GetRootNode())
	obj.transform.localPosition = Vector3.New(pos.x,pos.y,0)
	local seq = DoTweenSequence.Create()
	-- seq:AppendInterval(0.4)
	seq:Append(obj.transform:DOScale(Vector3.one * 2,0.4)):SetEase(DG.Tweening.Ease.OutBack)
	seq:AppendInterval(0.4)
	seq:Append(obj.transform:DOScale(Vector3.zero,0.1))
	seq:OnForceKill(function ()
		M.CreateNumGold(data,win_lucky)
		Destroy(obj)
	end)
end

function M.CreateEliminateParticleItem(data,templet,win_lucky)
	local templet_t = {}
	for k,v in pairs(data) do
		local obj = GameObject.Instantiate(templet,M.GetRootNode())
		obj.transform.localPosition = eliminate_algorithm.get_pos_by_index(v.x,v.y)
		table.insert(M.temp_objs,obj )
		table.insert(templet_t,obj )
	end
	local seq = DoTweenSequence.Create()
	seq:AppendInterval(5)
	seq:OnForceKill(function ()
		for k,v in pairs(templet_t) do
			Destroy(v)
		end
	end)
	M.CreateCrit(data,win_lucky)
end

function M.CreateEliminateOpenEye(data)
	local templet_t = {}
	for k,v in pairs(data) do
		local obj = GameObject.Instantiate(M.GetPrefab("eliminate_dongwu_" .. v.id),M.GetRootNode())
		obj.transform.localPosition = eliminate_algorithm.get_pos_by_index(v.x,v.y)
		table.insert(M.temp_objs,obj )
		table.insert(templet_t,obj )
	end
	local seq = DoTweenSequence.Create()
	seq:AppendInterval(0.8)
	seq:OnForceKill(function ()
		for k,v in pairs(templet_t) do
			Destroy(v)
		end
	end)
end

function M.CreateEliminateNor(data)
	M.CreateEliminateOpenEye(data)
	M.CreateEliminateParticleItem(data,M.GetPrefab("XXL_baodian"))
end

function M.CreateEliminateLuckyNor(data)
	M.CreateEliminateNor(data)
end

function M.CreateEliminateLuckyType(data,win_lucky)
	-- print("<color=green>清除同类特效</color>")
	M.CreateEliminateParticleItem(data,M.GetPrefab("XXL_baodian_BAR"),win_lucky)
end

function M.CreateEliminateLuckyClear(data,win_lucky)
	-- print("<color=green>清除全屏特效</color>")
	local p_obj = GameObject.Instantiate(M.GetPrefab("xxl_quanpinbao"),M.GetRootNode())
	table.insert(M.temp_objs,p_obj )
	p_obj.transform.localPosition = eliminate_algorithm.get_center_pos(data)
	local seq = DoTweenSequence.Create()
	seq:AppendInterval(5)
	seq:OnForceKill(function ()
		Destroy(p_obj)
	end)
end

function M.CreateLuckyRight(obj,t)
	-- dump(obj, "<color=yellow>lucky自己闪光特效</color>")
	local p_obj = GameObject.Instantiate(M.GetPrefab("xxl_luck1_xunhuan"),M.GetRootNode())
	p_obj.transform.localPosition = eliminate_algorithm.get_pos_by_index(obj.data.x,obj.data.y)
	local seq = DoTweenSequence.Create()
	seq:AppendInterval(t)
	seq:OnForceKill(function ()
		Destroy(p_obj)
	end)
end

function M.CreateLuckyBlow(obj,t)
	
end

function M.CreateFruitRight(obj,t)
	local p_obj = GameObject.Instantiate(M.GetPrefab("xxl_kuang_tishi"),M.GetRootNode())
	table.insert(M.temp_objs,p_obj )
	p_obj.transform.localPosition = eliminate_algorithm.get_pos_by_index(obj.data.x,obj.data.y)
	local seq = DoTweenSequence.Create()
	seq:AppendInterval(t)
	seq:OnForceKill(function ()
		Destroy(p_obj)
	end)
	return p_obj
end

function M.CreateFruitBlow(obj)
	local p_obj = GameObject.Instantiate(M.GetPrefab("xxl_luck_bianhuan_game_eliminate"),M.GetRootNode())
	table.insert(M.temp_objs,p_obj )
	p_obj.transform.localPosition = eliminate_algorithm.get_pos_by_index(obj.x,obj.y)
	local seq = DoTweenSequence.Create()
	seq:AppendInterval(5)
	seq:OnForceKill(function ()
		Destroy(p_obj)
	end)
end

function M.CreateFruitBlows(item_map)
	ExtendSoundManager.PlaySound(audio_config.xxl.bgm_xxl_lucky2.audio_name)
	for x=1,EliminateModel.cfg.size.max_x do
		for y=1,EliminateModel.cfg.size.max_y do
			if item_map[x] and item_map[x][y] then
				M.CreateFruitBlow({x = x,y = y})
			end
		end
	end
end


function M.CreateQPSG(item_maps)
	local p_obj = GameObject.Instantiate(M.GetPrefab("xxl_quabnnpin_shaoguang"),M.GetRootNode())
	table.insert(M.temp_objs,p_obj )
	p_obj.transform.localPosition = eliminate_algorithm.get_center_pos(item_maps)
	local seq = DoTweenSequence.Create()
	seq:AppendInterval(5)
	seq:OnForceKill(function ()
		Destroy(p_obj)
	end)
end

function M.CreateLuckyChange(obj,t)
	local p_obj = GameObject.Instantiate(M.GetPrefab("spine_xxl_jb"),M.GetRootNode())
	table.insert(M.temp_objs,p_obj )
	p_obj.transform.localPosition = eliminate_algorithm.get_pos_by_index(obj.x,obj.y)
	local seq = DoTweenSequence.Create()
	seq:AppendInterval(t)
	seq:OnForceKill(function ()
		Destroy(p_obj)
	end)
end

function M.CreateLucky4(del_list,t)
	local p_obj = GameObject.Instantiate(M.GetPrefab("xxl_lucky4l"),M.GetRootNode())
	p_obj.transform.localPosition = Vector3.zero

	local item_map = {}
	for i,data in ipairs(del_list) do
		item_map[data.x] = item_map[data.x] or {}
		local _obj = EliminateFruitItem.Create(data)
		_obj.ui.transform.parent = p_obj.transform
		item_map[data.x][data.y] = _obj
		table.insert(M.temp_objs,item_map[data.x][data.y] )
		local seq = DoTweenSequence.Create()
		seq:Append(_obj.ui.transform:DOScale(Vector3.one * 1.5,0.5):SetLoops(6,DG.Tweening.LoopType.Yoyo))
	end

	ExtendSoundManager.PlaySound(audio_config.xxl.bgm_xxl_lucky4xiaozi.audio_name)
	local bj_obj = GameObject.Instantiate(M.GetPrefab("xxl_tlbj"),M.GetRootNode())
	table.insert(M.temp_objs,bj_obj )
	local seq = DoTweenSequence.Create()
	bj_obj.transform.parent = p_obj.transform
	bj_obj.transform.localScale = Vector3.one * 4
	bj_obj.transform.localPosition = eliminate_algorithm.get_pos_by_index(5,5)
	seq:Append(bj_obj.transform:DOScale(Vector3.one,0.4))
	seq:OnForceKill(function (  )
		bj_obj.transform.localScale = Vector3.one
	end)

	table.insert(M.temp_objs,p_obj )
	local seq = DoTweenSequence.Create()
	seq:AppendInterval(t)
	seq:OnForceKill(function ()
		for x,_v in pairs(item_map) do
			for y,v in pairs(_v) do
				Destroy(v.ui.gameObject)
			end
		end
		Destroy(p_obj)
	end)
end

function M.CreateQPBJ(t)
	ExtendSoundManager.PlaySound(audio_config.xxl.bgm_xxl_lucky5xiaozi.audio_name)
	local p_obj = GameObject.Instantiate(M.GetPrefab("xxl_qpbj"),M.GetRootNode())
	table.insert(M.temp_objs,p_obj )
	p_obj.transform.localPosition = eliminate_algorithm.get_pos_by_index(5,5)
	local seq = DoTweenSequence.Create()
	seq:AppendInterval(t)
	seq:OnForceKill(function ()
		Destroy(p_obj)
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
			local obj = GameObject.Instantiate(EliminateObjManager.item_obj["EliminateFruitItemPhysics" .. v.data.id],M.GetRootNode())
			item_map[x][y] = obj
			obj.transform.localPosition = eliminate_algorithm.get_pos_by_index(x,y)
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

local fx_item_map = {}
local fx_seq = {}
function M.CreateFix(data)
	local obj = newObject("xxl_Luckymoments_Prefab",M.GetRootNode())
	obj.transform.localPosition = Vector3.zero
	obj.transform.localPosition = eliminate_algorithm.get_pos_by_index(5,5)
	local img = obj.transform:Find("Luckymoments/tubiao/tu"):GetComponent("Image")
	img.sprite = EliminateObjManager.item_obj["xxl_icon_" .. data.cur_del_list[1].id]
	local fx_map = {}
	local xx_map = {}

	local seq = DoTweenSequence.Create()
	table.insert( fx_seq,seq)
	seq:AppendInterval(1)
	seq:AppendCallback(function()
		for i,v in ipairs(data.cur_del_list) do
			fx_map[v.x] = fx_map[v.x] or {}
			fx_map[v.x][v.y] = newObject("xxl_Luckymoments_fx",M.GetRootNode())
			fx_map[v.x][v.y].transform.gameObject:SetActive(false)
			fx_map[v.x][v.y].transform.localPosition = eliminate_algorithm.get_pos_by_index(5,5)
			local t_pos = eliminate_algorithm.get_pos_by_index(v.x,v.y)
			local seq_xx = DoTweenSequence.Create()
			table.insert( fx_seq,seq_xx)
			seq_xx:AppendInterval(2)
			seq_xx:AppendCallback(function()
				fx_map[v.x][v.y].transform.gameObject:SetActive(true)
			end)
			seq_xx:Append(fx_map[v.x][v.y].transform:DOLocalMove(t_pos,0.6))
			seq_xx:SetEase(DG.Tweening.Ease.OutCirc)
			seq_xx:OnKill(function(  )
				if v and v.x and v.y and fx_map and next(fx_map) and fx_map[v.x] and fx_map[v.x][v.y] and IsEquals(fx_map[v.x][v.y]) then
					Destroy(fx_map[v.x][v.y].gameObject)
					fx_map[v.x][v.y] = nil
				end
			end)
			seq_xx:OnForceKill(function ()
				-- if v and v.x and v.y and fx_map and next(fx_map) and fx_map[v.x] and fx_map[v.x][v.y] and fx_map[v.x][v.y].gameObject then
				-- 	Destroy(fx_map[v.x][v.y].gameObject)
				-- 	fx_map[v.x][v.y] = nil
				-- end
			end)
		end
	end)
	seq:AppendInterval(1)
	seq:AppendCallback(function()
		for i,v in ipairs(data.cur_del_list) do
			xx_map[v.x] = xx_map[v.x] or {}
			xx_map[v.x][v.y] = newObject("xxl_luckymoments_xx",M.GetRootNode())
			xx_map[v.x][v.y].transform.localPosition = eliminate_algorithm.get_pos_by_index(v.x,v.y)
			local seq_xx = DoTweenSequence.Create()
			seq_xx:AppendInterval(0.5)
			seq_xx:AppendCallback(function(  )
				if xx_map[v.x] and xx_map[v.x][v.y] and IsEquals(xx_map[v.x][v.y]) then
					xx_map[v.x][v.y].gameObject:SetActive(true)
				end
			end)
			-- seq_xx:OnKill(function()
			-- 	if xx_map[v.x][v.y] then
			-- 		Destroy(xx_map[v.x][v.y].gameObject)
			-- 		xx_map[v.x][v.y] = nil
			-- 	end
			-- end)
			-- seq_xx:OnForceKill(function ()
			-- 	if xx_map[v.x][v.y] then
			-- 		Destroy(xx_map[v.x][v.y].gameObject)
			-- 		xx_map[v.x][v.y] = nil
			-- 	end
			-- end)
		end
	end)
	seq:AppendInterval(1)
	seq:AppendCallback(function()
		for i,data in ipairs(data.cur_del_list) do
			fx_item_map[data.x] = fx_item_map[data.x] or {}
			local _obj = EliminateFruitItem.Create(data)
			if _obj and _obj.ui and IsEquals(_obj.ui.transform) then
				_obj.ui.transform.parent = M.GetRootNode()
				_obj.ui.transform.localScale = Vector3.one * 0.1
			end
			fx_item_map[data.x][data.y] = _obj
			table.insert(M.temp_objs,fx_item_map[data.x][data.y] )
			if _obj and _obj.ui and IsEquals(_obj.ui.transform) then
				local seq = DoTweenSequence.Create()
				table.insert( fx_seq,seq)
				seq:Append(_obj.ui.transform:DOScale(Vector3.one,0.4))
				seq:Append(_obj.ui.transform:DOScale(Vector3.one * 1.2,0.4):SetLoops(6,DG.Tweening.LoopType.Yoyo))
			end
		end
	end)
	seq:AppendInterval(4)
	seq:OnForceKill(function ()
		Destroy(obj)
		for x,_v in pairs(fx_map) do
			for y,v in pairs(_v) do
				Destroy(v.gameObject)
				v = nil
			end
		end
		for x,_v in pairs(xx_map) do
			for y,v in pairs(_v) do
				Destroy(v.gameObject)
				v = nil
			end
		end
	end)
end

function M.ClearFxItemMap()
	for x,_v in pairs(fx_item_map) do
		for y,v in pairs(_v) do
			Destroy(v.ui.gameObject)
			v = nil
		end
	end

	for i,v in ipairs(fx_seq) do
		v:Kill()
	end
end