-- 创建时间:2019-03-19
EliminateCSPartManager = {}
local M = EliminateCSPartManager
M.objs = {}
M.temp_objs = {}

function M.ExitTimer()
	M.DestroyTNSH()
	M.DestroyTNSHZXH()
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
	local pos = eliminate_cs_algorithm.get_center_pos(data)
	local obj = GameObject.Instantiate(M.GetPrefab("xxl_num_game_eliminatecs") ,M.GetRootNode())
	obj.transform.localPosition = Vector3.New(pos.x,pos.y,0)
	obj.transform.localScale = Vector3.zero
	local canvas = obj.transform:GetComponent("Canvas")
	canvas.sortingOrder = 3
	-- obj.gameObject:SetActive(false)
	local gold_txt = obj.transform:Find("gold_txt"):GetComponent("Text")
	gold_txt.font = GetFont("by_tx1")	
	gold_txt.text = gold or 0
	
	local is_crite = #data >= 5
	local t = is_crite and EliminateCSModel.time.xc_jb_bj_sz_fei_jg or EliminateCSModel.time.xc_jb_pt_sz_fei_jg
	local seq = DoTweenSequence.Create()
	seq:AppendInterval(t)
	seq:Append(obj.transform:DOScale(Vector3.one,EliminateCSModel.time.xc_jb_pt_sz_fd_jg))
	seq:Append(obj.transform:DOLocalMoveY(pos.y + 80,EliminateCSModel.time.xc_jb_pt_sz_yd_sj))
	seq:SetEase(DG.Tweening.Ease.OutCirc)
	seq:OnForceKill(function ()
		Destroy(obj)
	end)
end

function M.CreateCrit(data,gold)
	local pos = eliminate_cs_algorithm.get_center_pos(data)
	local seq1 = DoTweenSequence.Create()
	local is_crite = #data >= 5
	local t = is_crite and EliminateCSModel.time.xc_jb_bj_sz_fei_jg or EliminateCSModel.time.xc_jb_pt_sz_fei_jg
	seq1:AppendInterval(t)
	seq1:AppendCallback(function ()
		local seq = DoTweenSequence.Create()
		local obj = GameObject.Instantiate(M.GetPrefab("xxl_crit_game_eliminatecs"),M.GetRootNode())
		obj.transform.localPosition = Vector3.New(pos.x,pos.y,0)
		seq:Append(obj.transform:DOScale(Vector3.one * 2,EliminateCSModel.time.xc_bj_fd)):SetEase(DG.Tweening.Ease.OutBack)
		seq:AppendInterval(EliminateCSModel.time.xc_bj_jg)
		seq:Append(obj.transform:DOScale(Vector3.zero,EliminateCSModel.time.xc_bj_sx))
		seq:OnForceKill(function ()
			M.CreateNumGold(data,gold)
			Destroy(obj)
		end)
	end)
end

function M.CreateEliminateParticleItem(data,templet,gold,ishero1)
	if gold==0 then return end
	local templet_t = {}
	local seq = DoTweenSequence.Create()
	seq:AppendInterval(EliminateCSModel.time.xc_jb_pt_bjb_ys)
	seq:AppendCallback(function ()
		for k,v in pairs(data) do
			local obj = GameObject.Instantiate(templet,M.GetRootNode())
			obj.transform.localPosition = eliminate_cs_algorithm.get_pos_by_index(v.x,v.y)
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
	if #data < 5 then
		M.CreateNumGold(data,gold)
		return
	end
	M.CreateCrit(data,gold)
end

function M.CreateEliminateNor1(data,gold)
	M.CreateEliminateParticleItem(data,M.GetPrefab("EliminateCS_xiaochu"),gold)
end

function M.CreateEliminateNor2(data,gold)
	M.CreateEliminateParticleItem(data,M.GetPrefab("EliminateCS_xiaochu"),gold)
end

function M.CreateEliminateNor3(data,gold)
	M.CreateEliminateParticleItem(data,M.GetPrefab("EliminateCS_xiaochu"),gold)
end

function M.CreateEliminateJD1(data,gold)
	M.CreateEliminateParticleItem(data,M.GetPrefab("EliminateCS_xiaochu"),gold,true)
end

function M.CreateEliminateJD2(data,gold)
	M.CreateEliminateParticleItem(data,M.GetPrefab("EliminateCS_xiaochu"),gold,true)
end

function M.CreateEliminateJD3(data,gold)
	M.CreateEliminateParticleItem(data,M.GetPrefab("EliminateCS_xiaochu"),gold,true)
end

--集齐3个字时再消蛋
function M.CreateXCZ3(map,t)
	-- dump(obj, "<color=yellow>lucky自己闪光特效</color>")
	local objs = {}
	for x,_v in pairs(map) do
		for y,v in pairs(_v) do
			if IsEquals(M.GetRootNode()) then
				local p_obj = GameObject.Instantiate(M.GetPrefab("EliminateCS_dan_xiaochu"),M.GetRootNode())
				p_obj.transform.localPosition = eliminate_cs_algorithm.get_pos_by_index(x,y)
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

function M.CreateAllBlom(data)
	local radius = 100000
	local power = 40000
	local thrust = 30000

	local item_map = {}
	for x,_v in pairs(data) do
		for y,v in pairs(_v) do
			item_map[x] = item_map[x] or {}
			local obj = GameObject.Instantiate(EliminateCSObjManager.item_obj["EliminateCSItemPhysics" .. v.data.id],M.GetRootNode())
			item_map[x][y] = obj
			obj.transform.localPosition = eliminate_cs_algorithm.get_pos_by_index(x,y)
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

function M.CreateTNSH()
	local h_obj = GameObject.Instantiate(M.GetPrefab("EliminateCS_huabanhuo"),M.GetCenterRootNode())
	h_obj.transform.localPosition = Vector3.zero
	table.insert(M.objs,h_obj)
	local k_obj = GameObject.Instantiate(M.GetPrefab("EliminateCS_kuang_glow"),M.GetCenterRootNode())
	k_obj.transform.localPosition = Vector3.zero
	table.insert(M.objs,k_obj)
	M.obj_tnsh  = h_obj
	M.obj_tnsh_k = k_obj
end

function M.DestroyTNSH()
	Destroy(M.obj_tnsh)
	Destroy(M.obj_tnsh_k)
end

function M.CreateHBRight(map,t)
	print("<color=white>花瓣特效</color>")
	local seq = DoTweenSequence.Create()
	local objs = {}
	math.randomseed(os.time())
	local max_t = 0
	seq:AppendInterval(EliminateCSModel.time.hb_dd)
	seq:AppendCallback(function(  )
		for x,_v in pairs(map) do
			for y,v in pairs(_v) do
				if IsEquals(M.GetRootNode()) then
					local t = math.random(EliminateCSModel.time.hb_lx_min * 100, EliminateCSModel.time.hb_lx_max * 100) / 100.0
					if max_t < t then max_t = t end
					local _seq = DoTweenSequence.Create()
					_seq:AppendInterval(t)
					_seq:AppendCallback(function(  )
						ExtendSoundManager.PlaySound(audio_config.csxxl.bgm_csxxl_yuansugaibian.audio_name)
						local item_map = {}
						item_map[x] = {}
						item_map[x][y] = EliminateCSObjManager.GetEliminateItem(x,y)
						--选中特效
						local xz_obj = M.CreateHBXZ({x = x,y = y})
						local _map = {}
						_map[x] = _map[x] or {}
						_map[x][y] = v
						EliminateCSObjManager.RemoveEliminateItem(_map)
						EliminateCSObjManager.AddEliminateItem(_map)
						M.CreateHBBlow({x = x,y = y})
						table.insert(objs,xz_obj)
					end)

					--滚动改变
					-- local p_obj = GameObject.Instantiate(M.GetPrefab("EliminateCS_huabanhuo_yipian"),M.GetRootNode())
					-- p_obj.transform.localPosition = eliminate_cs_algorithm.get_pos_by_index(x,y)
					-- local o_pos = Vector3.New(p_obj.transform.localPosition.x,p_obj.transform.localPosition.y,p_obj.transform.localPosition.z)
					-- local r_x = math.random(-100,100)
					-- local r_y = math.random(0,100)
					-- local t_pos = Vector3.New(p_obj.transform.localPosition.x + r_x,p_obj.transform.localPosition.y + 1080 + r_y,0)
					-- p_obj.transform.localPosition = t_pos
					-- table.insert(objs,p_obj)
					-- local h = math.random(100, 260)
					-- local t = math.random(EliminateCSModel.time.hb_lx_min * 100, EliminateCSModel.time.hb_lx_max * 100) / 100.0
					-- local _seq = DoTweenSequence.Create()
					-- _seq:Append(p_obj.transform:DOMoveLocalBezier(o_pos,h,t)):SetEase(DG.Tweening.Ease.OutSine)
					-- _seq:OnComplete(function (  )
					-- 	Destroy(p_obj)
					-- end)
					-- _seq:OnForceKill(function ()
					-- 	local item_map = {}
					-- 	item_map[x] = {}
					-- 	item_map[x][y] = EliminateCSObjManager.GetEliminateItem(x,y)
					-- 	--选中特效
					-- 	local xz_obj = M.CreateHBXZ({x = x,y = y})
					-- 	EliminateCSAnimManager.ScrollDefaultChangeToRandom(item_map,v,function(  )
					-- 		local _map = {}
					-- 		_map[x] = _map[x] or {}
					-- 		_map[x][y] = v
					-- 		EliminateCSObjManager.RemoveEliminateItem(_map)
					-- 		EliminateCSObjManager.AddEliminateItem(_map)
					-- 		Destroy(xz_obj)
					-- 	end)
					-- end)
				end
			end
		end
	end)
	
	seq:AppendInterval(t - EliminateCSModel.time.hb_dd - max_t)
	seq:OnForceKill(function ()
		for i,v in ipairs(objs) do
			Destroy(v)
		end
	end)
end

function M.CreateHBBlow(obj)
	-- ExtendSoundManager.PlaySound(audio_config.csxxl.bgm_csxxl_luzhishen3.audio_name)
	if not IsEquals(M.GetRootNode()) then return end;
	local p_obj = GameObject.Instantiate(M.GetPrefab("EliminateCS_glow_01"),M.GetRootNode())
	table.insert(M.temp_objs,p_obj )
	p_obj.transform.localPosition = eliminate_cs_algorithm.get_pos_by_index(obj.x,obj.y)
	local seq = DoTweenSequence.Create()
	seq:AppendInterval(5)
	seq:OnForceKill(function ()
		Destroy(p_obj)
	end)
end

function M.CreateHBXZ(obj)
	local prefab = M.GetPrefab("EliminateCS_xuanzhong")
	if not IsEquals(prefab) then return end
	if not IsEquals(M.GetRootNode()) then return end
	local p_obj = GameObject.Instantiate(prefab,M.GetRootNode())
	table.insert(M.temp_objs,p_obj )
	p_obj.transform.localPosition = eliminate_cs_algorithm.get_pos_by_index(obj.x,obj.y)
	local seq = DoTweenSequence.Create()
	seq:AppendInterval(EliminateCSModel.GetTime(EliminateCSModel.time.hb_xz))
	seq:OnForceKill(function ()
		Destroy(p_obj)
	end)
	return p_obj
end

--集字
function M.CreateJDZ(data,zi,is_geted)
	EliminateCSZiPanel.AddZi(zi)
	local pos = eliminate_cs_algorithm.get_center_pos(data)
	local seq = DoTweenSequence.Create()
	if not IsEquals(M.GetRootNode()) then return end
	local obj = GameObject.Instantiate(M.GetPrefab("EliminateCS_zi_chuxian"),M.GetRootNode())
	obj.transform.localPosition = Vector3.New(pos.x,pos.y,0)
	obj.transform.localScale = Vector3.zero
	local img = obj.transform:Find("zi"):GetComponent("Image")
	local i = 6 + zi
	img.sprite = EliminateCSObjManager.item_obj["xxl_icon_" .. i]
	local tf = EliminateCSZiPanel.GetZiNode(zi)
	local t_pos = tf.transform.localPosition
	ExtendSoundManager.PlaySound(audio_config.csxxl.bgm_csxxl_feizi.audio_name)
	seq:Append(obj.transform:DOScale(Vector3.one,EliminateCSModel.time.ji_zi_fd)):SetEase(DG.Tweening.Ease.OutBack)
	seq:AppendCallback(function ()
		obj.transform:SetParent(M.GetCenterRootNode())
		local _obj = newObject("EliminateCS_xiaochu_feixing",obj.transform)
		_obj.transform.localPosition = Vector3.zero
		_obj.gameObject:SetActive(true)
	end)
	seq:AppendInterval(EliminateCSModel.time.ji_zi_dd)
	seq:Append(obj.transform:DOLocalMove(Vector3.New(t_pos.x,t_pos.y,0),EliminateCSModel.time.ji_zi_fx)):SetEase(DG.Tweening.Ease.OutBack)
	seq:AppendInterval(EliminateCSModel.time.ji_zi_fx - 0.2)
	seq:AppendCallback(function(  )
		if not is_geted then
			M.CreateZi(zi)
		end
	end)
	seq:OnForceKill(function ()
		Destroy(obj)
	end)
end

function M.CreateZi(zi)
	local tf = EliminateCSZiPanel.GetZiNode(zi)
	local obj = GameObject.Instantiate(M.GetPrefab("EliminateCS_zi_dianliang") ,M.GetCenterRootNode())
	obj.transform.localPosition = Vector3.New(tf.localPosition.x,tf.localPosition.y,tf.localPosition.z)
	local quan_img = obj.transform:Find("quan"):GetComponent("Image")
	quan_img.sprite = GetTexture("csxxl_bg_tnsh" .. zi)
	local zi_img = obj.transform:Find("zi"):GetComponent("Image")
	local i = 6 + zi
	zi_img.sprite =  EliminateCSObjManager.item_obj["xxl_icon_" .. i]
	local seq = DoTweenSequence.Create()
	seq:AppendInterval(EliminateCSModel.time.ji_zi_zddd)
	seq:AppendCallback(function(  )
		ExtendSoundManager.PlaySound(audio_config.csxxl.bgm_csxxl_zichuxian.audio_name)
		EliminateCSAnimManager.DOShakePositionCamer(nil,EliminateCSModel.time.ji_zi_zd,Vector3.zero)
	end)
	seq:AppendInterval(4)
	seq:OnForceKill(function ()
		EliminateCSZiPanel.Refresh()
		Destroy(obj)
	end)
end

function M.CreateZDJH1()
	local obj = GameObject.Instantiate(M.GetPrefab("EliminateCS_zi_jiqi") ,M.GetCenterRootNode())
	obj.transform.localPosition = Vector3.zero
	local cg = obj.transform:Find("BGImg"):GetComponent("CanvasGroup")
	local seq = DoTweenSequence.Create()
	seq:Append(cg:DOFade(1,EliminateCSModel.time.ji_zi_jq_cx))
	seq:AppendCallback(function (  )
		local l = obj.transform:Find("Luckymoments")
		l.gameObject:SetActive(true)
	end)
	seq:AppendInterval(EliminateCSModel.time.xc_zi4 - EliminateCSModel.time.ji_zi_jq_cx)
	seq:OnForceKill(function ()
		Destroy(obj)
	end)
end

function M.CreateZiComplete()
	local obj = GameObject.Instantiate(M.GetPrefab("EliminateCS_zi_jiqi1") ,M.GetCenterRootNode())
	obj.transform.localPosition = Vector3.zero
	local seq = DoTweenSequence.Create()
	seq:AppendInterval(2)
	seq:OnForceKill(function ()
		Destroy(obj)
	end)
end

--集进度条
function M.CreateJDJDT(data,all_jindan_value)
	local pos, index = eliminate_cs_algorithm.get_center_pos(data)
	local item = EliminateCSObjManager.GetEliminateItem(index.x,index.y)
	if not item then return end
	local seq = DoTweenSequence.Create()
	local obj = newObject("EliminateCS_xiaochu_feixing_jindan",item.ui.transform)
	obj.transform.localPosition = Vector3.zero
	obj.transform:SetParent(M.GetCenterRootNode())
	obj.gameObject:SetActive(true)
	local tf = EliminateCSProgPanel.GetDanNode()
	local t_pos = tf.transform.localPosition
	ExtendSoundManager.PlaySound(audio_config.csxxl.bgm_csxxl_feizi.audio_name)
	seq:Append(obj.transform:DOLocalMove(Vector3.New(t_pos.x,t_pos.y + 30,0),EliminateCSModel.time.ji_jdt_fx)):SetEase(DG.Tweening.Ease.OutBack)
	seq:OnForceKill(function ()
		local data = {
			all_jindan_value = all_jindan_value or 0
		}
		EliminateCSProgPanel.SetPro(data)
		Destroy(obj)
	end)
end

function M.CreateZPJH()
	local obj = GameObject.Instantiate(M.GetPrefab("EliminateCS_jjt_jindan_dianjihou") ,M.GetCenterRootNode())	
	obj.transform.localPosition = Vector3.New(375,-543,0)
	local seq = DoTweenSequence.Create()
	seq:AppendInterval(7)
	seq:OnForceKill(function ()
		Destroy(obj)
	end)
end

function M.CreateZDTNSH(rate)
	ExtendSoundManager.PlaySound(audio_config.csxxl.bgm_csxxl_hua.audio_name)
	local obj = GameObject.Instantiate(M.GetPrefab("EliminateCS_zd_tvsh") ,M.GetCenterRootNode())	
	obj.transform.localPosition = Vector3.zero
	local psr = obj.transform:Find("hua"):GetComponent("ParticleSystemRenderer")
	psr.material = GetMaterial("csxxl_icon_1" .. rate)
	local seq = DoTweenSequence.Create()
	seq:AppendInterval(3)
	seq:AppendCallback(function (  )
		M.CreateTNSHZXH()
	end)
	seq:AppendInterval(4)
	seq:OnForceKill(function ()
		Destroy(obj)
	end)
end

function M.CreateZDJH()
	local obj = GameObject.Instantiate(M.GetPrefab("EliminateCS_tvsh_shanguang_root") ,M.GetCenterRootNode())	
	obj.transform.localPosition = Vector3.zero
	local seq = DoTweenSequence.Create()
	seq:AppendInterval(7)
	seq:OnForceKill(function ()
		Destroy(obj)
	end)
end

function M.CreateZaDanComplete(luck)
	local obj = GameObject.Instantiate(M.GetPrefab("EliminateCS_zadan_jiqi") ,M.GetCenterRootNode())
	obj.transform.localPosition = Vector3.zero
	local text = obj.transform:Find("@num_txt"):GetComponent("Text")
	local n
	if luck == 1 then
		n = 16
	elseif luck == 2 then
		n = 8
	elseif luck == 3 then
		n = 4
	end
	text.text = "免费" .. n  .."次"
	local cg = obj.transform:Find("BGImg"):GetComponent("CanvasGroup")
	local seq = DoTweenSequence.Create()
	seq:Append(cg:DOFade(1,EliminateCSModel.time.zd_gzs))
	seq:AppendCallback(function (  )
		M.CreateZDTNSH(luck)
	end)
	seq:AppendInterval(EliminateCSModel.time.xc_zd_xs - EliminateCSModel.time.zd_gzs)
	seq:OnForceKill(function ()
		Destroy(obj)
	end)
end

function M.CreateTNSHZXH()
	local obj = GameObject.Instantiate(M.GetPrefab("EliminateCS_zi_xunhuan") ,M.GetCenterRootNode())	
	M.obj_tnsh_zxh = obj
	obj.transform.localPosition = Vector3.zero
	obj.gameObject:SetActive(true)
	table.insert(M.temp_objs,obj)
end

function M.DestroyTNSHZXH(  )
	Destroy(M.obj_tnsh_zxh)
end

--[[
    GetTexture("csxxl_icon_11")
    GetTexture("csxxl_icon_12")
    GetTexture("csxxl_icon_13")
]]