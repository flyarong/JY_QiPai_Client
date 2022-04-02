-- 创建时间:2019-03-19
EliminateBSPartManager = {}
local M = EliminateBSPartManager
M.objs = {}
M.temp_objs = {}
M.special_map = {}
function M.ExitTimer()
	M.ClearAllObj()
end
local _bgj_xf_obj = {}
local scroll_add_kuang = {}
local fire_map = {}
function M.GetPrefab(name)
	if not M.objs[name] then

		M.objs[name] = newObject(name,M.GetRoot())
		M.objs[name].transform.position = Vector3.New(10000,10000,-10000)
	end
	return M.objs[name]
end

function M.GetRootNode()
	M.root_node = GameObject.Find("ParticleContent").transform
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
		local pp = GameObject.Find("GameObject")
		if IsEquals(pp) then
			M.root = pp.transform
		end
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
	for k,v in pairs(M.special_map) do
		if IsEquals(v) and IsEquals(v.gameObject) then
			Destroy(v)
		end
	end
	M.special_map = {}
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
	for k,v in pairs(M.special_map) do
		if IsEquals(v) and IsEquals(v.gameObject) then
			Destroy(v)
		end
	end
	M.special_map = {}
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
	for x,_v in pairs(fire_map) do
		for y,v in pairs(_v) do
			Destroy(v.gameObject)
		end
	end
	fire_map = {}

	destroyChildren(M.GetRootNode())
	destroyChildren(M.GetCenterRootNode())
end

function M.CreateNumGoldInPos(pos, gold)
	if gold == 0 then return end 
	local obj = GameObject.Instantiate(M.GetPrefab("xxl_num") ,M.GetRootNode())
	obj.transform.position = Vector3.New(pos.x,pos.y,0)
	obj.transform.localScale = Vector3.zero
	local canvas = obj.transform:GetComponent("Canvas")
	canvas.sortingOrder = 3
	local gold_txt = obj.transform:Find("gold_txt"):GetComponent("Text")
	gold_txt.font = GetFont("by_tx1")	
	gold_txt.text = gold or 0
	
	local t = EliminateBSModel.time.xc_jb_pt_sz_fei_jg
	local seq = DoTweenSequence.Create()
	seq:AppendInterval(EliminateBSModel.GetTime(t * 2))
	seq:Append(obj.transform:DOScale(Vector3.one,EliminateBSModel.time.xc_jb_pt_sz_fd_jg))
	seq:Append(obj.transform:DOLocalMoveY(obj.transform.localPosition.y + 80,EliminateBSModel.time.xc_jb_pt_sz_yd_sj))
	seq:SetEase(DG.Tweening.Ease.OutCirc)
	seq:OnForceKill(function ()
		Destroy(obj)
	end)
end

function M.CreateNumGold(data,gold)
	if gold == 0 then return end 
	local pos = eliminate_bs_algorithm.get_center_pos(data)
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
	local t = is_crite and EliminateBSModel.time.xc_jb_bj_sz_fei_jg or EliminateBSModel.time.xc_jb_pt_sz_fei_jg
	local seq = DoTweenSequence.Create()
	seq:AppendInterval(EliminateBSModel.GetTime(t * 2))
	seq:Append(obj.transform:DOScale(Vector3.one,EliminateBSModel.time.xc_jb_pt_sz_fd_jg))
	seq:Append(obj.transform:DOLocalMoveY(pos.y + 80,EliminateBSModel.time.xc_jb_pt_sz_yd_sj))
	seq:SetEase(DG.Tweening.Ease.OutCirc)
	seq:OnForceKill(function ()
		Destroy(obj)
	end)
end

function M.CreateNumGold_2(data,gold)
	local num = 0
	for k,v in pairs(gold) do
		num = math.max(num,v)
	end
	if num == 0 then return end 
	local tab = {}
	for i=1,#data do
		if data[i].v >= 200 then
			tab[#tab + 1] = data[i]
		end
	end
	for i=1,#tab do
		local pos = eliminate_bs_algorithm.get_pos_by_index(tab[i].x,tab[i].y)
		local obj = GameObject.Instantiate(M.GetPrefab("xxl_num") ,M.GetRootNode())
		obj.transform.localPosition = Vector3.New(pos.x,pos.y,0)
		obj.transform.localScale = Vector3.zero
		local canvas = obj.transform:GetComponent("Canvas")
		canvas.sortingOrder = 3
		local gold_txt = obj.transform:Find("gold_txt"):GetComponent("Text")
		gold_txt.font = GetFont("by_tx1")	
		gold_txt.text = gold[i] or 0
		local t = EliminateBSModel.time.xc_jb_pt_sz_fei_jg
		local seq = DoTweenSequence.Create()
		seq:AppendInterval(EliminateBSModel.GetTime(t * 2))
		seq:Append(obj.transform:DOScale(Vector3.one,EliminateBSModel.time.xc_jb_pt_sz_fd_jg))
		seq:Append(obj.transform:DOLocalMoveY(pos.y + 80,EliminateBSModel.time.xc_jb_pt_sz_yd_sj))
		seq:SetEase(DG.Tweening.Ease.OutCirc)
		seq:OnForceKill(function ()
			Destroy(obj)
		end)
	end
end

function M.CreateCrit(data,gold)
	local pos = eliminate_bs_algorithm.get_center_pos(data)
	local seq1 = DoTweenSequence.Create()
	local is_crite = #data >= 5
	local t = is_crite and EliminateBSModel.time.xc_jb_bj_sz_fei_jg or EliminateBSModel.time.xc_jb_pt_sz_fei_jg
	seq1:AppendInterval(t)
	seq1:AppendCallback(function ()
		local seq = DoTweenSequence.Create()
		local obj = GameObject.Instantiate(M.GetPrefab("xxl_crit"),M.GetRootNode())
		obj.transform.localPosition = Vector3.New(pos.x,pos.y,0)
		seq:Append(obj.transform:DOScale(Vector3.one * 2,EliminateBSModel.time.xc_bj_fd)):SetEase(DG.Tweening.Ease.OutBack)
		seq:AppendInterval(EliminateBSModel.time.xc_bj_jg)
		seq:Append(obj.transform:DOScale(Vector3.zero,EliminateBSModel.time.xc_bj_sx))
		seq:OnForceKill(function ()
			M.CreateNumGold(data,gold)
			Destroy(obj)
		end)
	end)
end

function M.CreateCrit_2(data,gold)
	--[[local pos = eliminate_bs_algorithm.get_center_pos(data)
	local seq1 = DoTweenSequence.Create()
	local is_crite = #data >= 5
	local t = is_crite and EliminateBSModel.time.xc_jb_bj_sz_fei_jg or EliminateBSModel.time.xc_jb_pt_sz_fei_jg
	seq1:AppendInterval(t)
	seq1:AppendCallback(function ()
		local seq = DoTweenSequence.Create()
		local obj = GameObject.Instantiate(M.GetPrefab("xxl_crit"),M.GetRootNode())
		obj.transform.localPosition = Vector3.New(pos.x,pos.y,0)
		seq:Append(obj.transform:DOScale(Vector3.one * 2,EliminateBSModel.time.xc_bj_fd)):SetEase(DG.Tweening.Ease.OutBack)
		seq:AppendInterval(EliminateBSModel.time.xc_bj_jg)
		seq:Append(obj.transform:DOScale(Vector3.zero,EliminateBSModel.time.xc_bj_sx))
		seq:OnForceKill(function ()
			M.CreateNumGold_2(data,gold)
			Destroy(obj)
		end)
	end)--]]
end

function M.CreateEliminateParticleItem(data,templet,gold)
	--if gold==0 then return end
	local templet_t = {}
	local seq = DoTweenSequence.Create()
	seq:AppendInterval(EliminateBSModel.time.xc_jb_pt_bjb_ys)
	seq:AppendCallback(function ()
		for k,v in pairs(data) do
			local obj = GameObject.Instantiate(templet,M.GetRootNode())
			obj.transform.localPosition = eliminate_bs_algorithm.get_pos_by_index(v.x,v.y)
			table.insert(M.temp_objs,obj )
			table.insert(templet_t,obj )
		end
	end)
	seq:AppendInterval(0.5)
	seq:AppendCallback(function ()
		for k,v in pairs(data) do
			local obj = GameObject.Instantiate(M.GetPrefab("bsmz_eff_jbdg"),M.GetRootNode())
			obj.transform.localPosition = eliminate_bs_algorithm.get_pos_by_index(v.x,v.y)
			table.insert(M.temp_objs,obj )
			table.insert(templet_t,obj )
		end
	end)
	
	seq:AppendInterval(EliminateBSModel.GetTime(10))
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

function M.CreateEliminateParticleItem_hecheng(data,templet,gold)
	--if gold==0 then return end
	local templet_t = {}
	local seq = DoTweenSequence.Create()
	seq:AppendInterval(EliminateBSModel.time.xc_jb_pt_bjb_ys)
	seq:AppendCallback(function ()
		for k,v in pairs(data) do
			local obj = GameObject.Instantiate(templet,M.GetRootNode())
			obj.transform.localPosition = eliminate_bs_algorithm.get_pos_by_index(v.x,v.y)
			table.insert(M.temp_objs,obj )
			table.insert(templet_t,obj )
		end
	end)
	
	seq:AppendInterval(EliminateBSModel.GetTime(10))
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

function M.CreateEliminateParticleItem_2_1(data,gold)
	--if gold==0 then return end
	local templet_t = {}
	local seq = DoTweenSequence.Create()
	seq:AppendInterval(0.2)
	seq:AppendCallback(function ()
		for k,v in pairs(data) do
			if v.v >= 200 and v.v < 210 then
				local obj = GameObject.Instantiate(M.GetPrefab("bsmz_eff_siysbao"),M.GetRootNode())
				obj.transform.localPosition = eliminate_bs_algorithm.get_pos_by_index(v.x,v.y)
				table.insert(M.temp_objs,obj )
				table.insert(templet_t,obj )
			end
		end
	end)
	seq:AppendInterval(0.25)
	seq:AppendCallback(function ()
		for k,v in pairs(data) do
			local obj = GameObject.Instantiate(M.GetPrefab("bsmz_eff_siysxc"),M.GetRootNode())
			obj.transform.localPosition = eliminate_bs_algorithm.get_pos_by_index(v.x,v.y)
			table.insert(M.temp_objs,obj )
			table.insert(templet_t,obj )
		end
	end)
	seq:AppendInterval(0.25)
	seq:AppendCallback(function ()
		for k,v in pairs(data) do
			local obj = GameObject.Instantiate(M.GetPrefab("bsmz_eff_jbdg"),M.GetRootNode())
			obj.transform.localPosition = eliminate_bs_algorithm.get_pos_by_index(v.x,v.y)
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
	if table_is_null(gold) then return end
	local time = 0.7
	local seq0 = DoTweenSequence.Create()
	seq0:AppendInterval(time)
	seq0:AppendCallback(function ()
		M.CreateNumGold_2(data,gold)
	end)
end

function M.CreateEliminateParticleItem_2_2(data,gold)
	--if gold==0 then return end
	local templet_t = {}
	local seq = DoTweenSequence.Create()
	seq:AppendInterval(0.2)
	seq:AppendCallback(function ()
		for k,v in pairs(data) do
			if v.v >= 210 and v.v < 220 then
				local obj = GameObject.Instantiate(M.GetPrefab("bsmz_eff_wuysbao"),M.GetRootNode())
				obj.transform.localPosition = eliminate_bs_algorithm.get_pos_by_index(v.x,v.y)
				table.insert(M.temp_objs,obj )
				table.insert(templet_t,obj )
			end
		end
	end)
	seq:AppendInterval(0.25)
	seq:AppendCallback(function ()
		for k,v in pairs(data) do
			local obj = GameObject.Instantiate(M.GetPrefab("bsmz_eff_wuysxcgz"),M.GetRootNode())
			obj.transform.localPosition = eliminate_bs_algorithm.get_pos_by_index(v.x,v.y)
			table.insert(M.temp_objs,obj )
			table.insert(templet_t,obj )
		end
	end)
	seq:AppendInterval(0.25)
	seq:AppendCallback(function ()
		for k,v in pairs(data) do
			local obj = GameObject.Instantiate(M.GetPrefab("bsmz_eff_jbdg"),M.GetRootNode())
			obj.transform.localPosition = eliminate_bs_algorithm.get_pos_by_index(v.x,v.y)
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
	if table_is_null(gold) then return end
	local time = 0.7
	local seq0 = DoTweenSequence.Create()
	seq0:AppendInterval(time)
	seq0:AppendCallback(function ()
		M.CreateNumGold_2(data,gold)
	end)
end

function M.GetRotations(data)
	local tab = {}
	for k,v in pairs(data) do
		if v.v >= 220 then
			if (v.x > 2) and (v.x < 7) and (v.y > 2) and (v.y < 7) then--中
				M.GetRotation(1,v,tab)
			elseif (v.x <= 2) and (v.y <= 2) then--左下
				M.GetRotation(2,v,tab)
			elseif (v.x <= 2) and (v.y > 2) and (v.y < 7) then--左
				M.GetRotation(3,v,tab)
			elseif (v.x <= 2) and (v.y >= 7) then--左上
				M.GetRotation(4,v,tab)
			elseif (v.x > 2) and (v.x < 7) and (v.y >= 7) then--上
				M.GetRotation(5,v,tab)
			elseif (v.x >= 7) and (v.y >= 7) then--右上
				M.GetRotation(6,v,tab)
			elseif (v.x >= 7) and (v.y > 2) and (v.y < 7) then--右
				M.GetRotation(7,v,tab)
			elseif (v.x >= 7) and (v.y <= 2) then--右下
				M.GetRotation(8,v,tab)
			elseif (v.x > 2) and (v.x < 7) and (v.y <= 2) then--下
				M.GetRotation(9,v,tab)
			end
		end
	end
	return tab
end

function M.GetRotation(type,data,tab)
	local r = 0
	local jian_ge = 0
	local count = 0
	local insert = true
	if type == 1 then--中
		r = math.random(0,360)
		jian_ge = 50
		count = 6
	elseif type == 2 then--左下
		r = math.random(90,180)
		jian_ge = 20
		count = 3
	elseif type == 3 then--左
		r = math.random(0,180)
		jian_ge = 35
		count = 4
	elseif type == 4 then--左上
		r = math.random(0,90)
		jian_ge = 20
		count = 3
	elseif type == 5 then--上
		local n = math.random(0,10)
		if n <= 5 then
			r = math.random(0,90)
		else
			r = math.random(270,360)
		end
		jian_ge = 35
		count = 4
	elseif type == 6 then--右上
		r = math.random(270,360)
		jian_ge = 20
		count = 3
	elseif type == 7 then--右
		r = math.random(180,360)
		jian_ge = 35
		count = 4
	elseif type == 8 then--右下
		r = math.random(180,270)
		jian_ge = 20
		count = 3
	elseif type == 9 then--下
		r = math.random(90,270)
		jian_ge = 35
		count = 4
	end
	--[[if not table_is_null(tab) then
		for k,v in pairs(tab) do
			if math.abs(v.ratation - r) < jian_ge then
				insert = false
				break
			end
		end
	end--]]
	if insert then
		tab[#tab + 1] = {x = data.x, y = data.y, rotation = r}
	end
	if #tab < count then
		M.GetRotation(type,data,tab)
	end
end

function M.CreateEliminateParticleItem_2_3(data,gold)
	--if gold==0 then return end
	local templet_t = {}
	local seq = DoTweenSequence.Create()
	seq:AppendInterval(0.2)
	seq:AppendCallback(function ()
		for k,v in pairs(data) do
			if v.v >= 220 then
				local obj = GameObject.Instantiate(M.GetPrefab("bsmz_eff_liubzzhongxin"),M.GetRootNode())
				obj.transform.localPosition = eliminate_bs_algorithm.get_pos_by_index(v.x,v.y)
				table.insert(M.temp_objs,obj )
				table.insert(templet_t,obj )
			end
		end
	end)
	seq:AppendInterval(0.25)
	local tab = M.GetRotations(data)
	seq:AppendCallback(function ()
		for k,v in pairs(tab) do
			local obj = GameObject.Instantiate(M.GetPrefab("bsmz_eff_lssd"),M.GetRootNode())
			obj.transform.localPosition = eliminate_bs_algorithm.get_pos_by_index(v.x,v.y)
			obj.transform.rotation = Quaternion.Euler(0, 0, v.rotation)
			table.insert(M.temp_objs,obj )
			table.insert(templet_t,obj )
		end
	end)
	seq:AppendInterval(0.8)
	seq:AppendCallback(function ()
		for k,v in pairs(data) do
			local obj = GameObject.Instantiate(M.GetPrefab("bsmz_eff_liuysxc"),M.GetRootNode())
			obj.transform.localPosition = eliminate_bs_algorithm.get_pos_by_index(v.x,v.y)
			table.insert(M.temp_objs,obj )
			table.insert(templet_t,obj )
		end
	end)
	seq:AppendInterval(0.25)
	seq:AppendCallback(function ()
		for k,v in pairs(data) do
			local obj = GameObject.Instantiate(M.GetPrefab("bsmz_eff_jbdg"),M.GetRootNode())
			obj.transform.localPosition = eliminate_bs_algorithm.get_pos_by_index(v.x,v.y)
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
	if table_is_null(gold) then return end
	local time = 1.5
	local seq0 = DoTweenSequence.Create()
	seq0:AppendInterval(time)
	seq0:AppendCallback(function ()
		M.CreateNumGold_2(data,gold)
	end)
end

--三消	横竖特效不一样
function M.CreateEliminateNor1(data,gold)
	local x
	local y
	local fx_name = "xxl_sg_bao_01"
	for k,v in pairs(data) do
		if x and v.x == x then
			fx_name = "bsmz_eff_xcsheng"
			--LittleTips.Create("竖排")
			break
		end
		if y and v.y == y then
			fx_name = "bsmz_eff_xcsheng"
			--LittleTips.Create("横排")
			break
		end
		if not x then
			x = v.x
		end
		if not y then
			y = v.y
		end
	end
	M.CreateEliminateParticleItem(data,M.GetPrefab(fx_name),gold)
end

--合成消		不播普通消除特效,直接播对应的合成特效
function M.CreateEliminateNor2(data,gold)
	--LittleTips.Create("合成消")
	local fx_name = "bsmz_eff_hechengyuansu"
	M.CreateEliminateParticleItem_hecheng(data,M.GetPrefab(fx_name),gold)
end

--特殊消(一)
function M.CreateEliminateNor1_2(data,gold)
	if table_is_null(data) then return end
	M.CreateEliminateParticleItem_2_1(data,gold)
end

--特殊消(二)
function M.CreateEliminateNor2_2(data,gold)
	if table_is_null(data) then return end
	M.CreateEliminateParticleItem_2_2(data,gold)
end

--特殊消(三)
function M.CreateEliminateNor3_2(data,gold)
	if table_is_null(data) then return end
	M.CreateEliminateParticleItem_2_3(data,gold)
end

function M.CreateEliminateSWK(data,lv)
	lv = lv or 1
	local templet = M.GetPrefab("xxl_xy_bao_0" .. lv)
	local templet_t = {}
	local seq = DoTweenSequence.Create()
	seq:AppendInterval(EliminateBSModel.time.xc_jb_pt_bjb_ys)
	seq:AppendCallback(function ()
		for k,v in pairs(data) do
			local obj = GameObject.Instantiate(templet,M.GetRootNode())
			obj.transform.localPosition = eliminate_bs_algorithm.get_pos_by_index(v.x,v.y)
			table.insert(M.temp_objs,obj )
			table.insert(templet_t,obj )
		end
	end)
	
	seq:AppendInterval(EliminateBSModel.GetTime(10))
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
	seq:AppendInterval(EliminateBSModel.time.xc_jb_pt_bjb_ys)
	seq:AppendCallback(function ()
		for k,v in pairs(data) do
			local obj = GameObject.Instantiate(templet,M.GetRootNode())
			obj.transform.localPosition = eliminate_bs_algorithm.get_pos_by_index(v.x,v.y)
			table.insert(M.temp_objs,obj )
			table.insert(templet_t,obj )
		end
	end)
	
	seq:AppendInterval(EliminateBSModel.GetTime(5))
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
	seq:AppendInterval(EliminateBSModel.time.xc_jb_pt_bjb_ys)
	seq:AppendCallback(function ()
		for k,v in pairs(data) do
			local obj = GameObject.Instantiate(templet,M.GetRootNode())
			obj.transform.localPosition = eliminate_bs_algorithm.get_pos_by_index(v.x,v.y)
			table.insert(M.temp_objs,obj )
			table.insert(templet_t,obj )
		end
	end)
	
	seq:AppendInterval(EliminateBSModel.GetTime(10))
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
	local gold = EliminateBSModel.GetAwardGold(rate)
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
	-- seq:AppendInterval(EliminateBSModel.time.xc_jb_pt_bjb_ys)
	seq:AppendCallback(function ()
		for k,v in pairs(data) do
			local obj = GameObject.Instantiate(templet,M.GetRootNode())
			obj.transform.localPosition = eliminate_bs_algorithm.get_pos_by_index(v.x,v.y)
			table.insert(M.temp_objs,obj )
			table.insert(templet_t,obj )
		end
	end)
	
	seq:AppendInterval(EliminateBSModel.GetTime(10))
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
			obj.transform.localPosition = eliminate_bs_algorithm.get_pos_by_index(v.x,v.y)
			table.insert(M.temp_objs,obj )
			table.insert(templet_t,obj )
		end
	end
	jb()
	local gold = EliminateBSModel.GetAwardGold(rate)
	if gold==0 then return end
	if #data < 5 then
		M.CreateNumGold(data,gold)
		return
	end
	M.CreateCrit(data,gold)
end

--[[function M.CreateAllBlom(data)
	local radius = 100000
	local power = 40000
	local thrust = 30000

	local item_map = {}
	for x,_v in pairs(data) do
		for y,v in pairs(_v) do
			item_map[x] = item_map[x] or {}
			local obj = GameObject.Instantiate(EliminateBSObjManager.item_obj["EliminateXYItemPhysics" .. v.data.id],M.GetRootNode())
			item_map[x][y] = obj
			obj.transform.localPosition = eliminate_bs_algorithm.get_pos_by_index(x,y)
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
	seq:AppendInterval(EliminateBSModel.GetTime(8))
	seq:OnForceKill(function ()
		for x,_v in pairs(item_map) do
			for y,v in pairs(_v) do
				Destroy(v)
			end
		end
	end)
end--]]

function M.XCNor(data,callback)
	local obj
	local fx_item_map = {}
	local fx_seq = {}
	local fx_map = {}
	local fx_obj
	local k_map = {}
	local seq = DoTweenSequence.Create()
	seq:AppendInterval(EliminateBSModel.GetTime(EliminateBSModel.time.xc_pt))
	seq:AppendCallback(function(  )
		local pos = eliminate_bs_algorithm.get_center_pos(data.cur_del_map)
		fx_obj = newObject("xxl_xy_tuowei_huang",M.GetRootNode())
		fx_obj.transform.localPosition = pos
		fx_obj.gameObject:SetActive(false)
		local t_pos =  Vector3.New(100,560,0)
		local seq_xx = DoTweenSequence.Create()
		table.insert( fx_seq,seq_xx)
		seq_xx:AppendInterval(EliminateBSModel.GetTime(0.02))
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
	seq:AppendInterval(EliminateBSModel.GetTime(EliminateBSModel.time.swk_xc_hy))
	seq:AppendCallback(
		function()
			if callback and type(callback) == "function" then
				callback()
			end
		end
	)
	seq:AppendInterval(EliminateBSModel.GetTime(8))
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
	p_obj.transform.localPosition = eliminate_bs_algorithm.get_pos_by_index(obj.x,obj.y)
	local seq = DoTweenSequence.Create()
	seq:AppendInterval(EliminateBSModel.GetTime(10))
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
				if v == EliminateBSModel.eliminate_enum.ts then
					k_map[x] = k_map[x] or {}
					k_map[x][y] = newObject("xxl_xy_ts_kuang",M.GetRootNode())
					k_map[x][y].transform.localPosition = eliminate_bs_algorithm.get_pos_by_index(x,y)
					k_map[x][y].gameObject:SetActive(true)	
				end
			end
		end
	end)
	seq:AppendInterval(EliminateBSModel.GetTime(EliminateBSModel.time.ts_cxtsk))
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
	seq:AppendInterval(EliminateBSModel.GetTime(0.2))
	seq:AppendCallback(function()
		obj = newObject("xxl_xy_black_mini",M.GetCenterRootNode())
		obj.transform.localPosition = Vector3.zero
		ExtendSoundManager.PlaySound(audio_config.sdbgj.bgm_sdbgj_swk_huo.audio_name)
		--框
		for i,v in ipairs(data.cur_del_map) do
			k_map[v.x] = k_map[v.x] or {}
			k_map[v.x][v.y] = newObject("xxl_xy_swk_kuang",M.GetRootNode())
			local pos = eliminate_bs_algorithm.get_pos_by_index(v.x,v.y)
			k_map[v.x][v.y].transform.localPosition = {x = pos.x,y = pos.y -  12,z = 0}
			k_map[v.x][v.y].gameObject:SetActive(true)
		end

		--放大缩小
		for i,data in ipairs(data.cur_del_map) do
			fx_item_map[data.x] = fx_item_map[data.x] or {}
			local _obj = EliminateBSItem.Create({x = data.x, y = data.y, id = data.v})
			if _obj and _obj.ui and IsEquals(_obj.ui.transform) then
				_obj.ui.transform.parent = M.GetRootNode()
				_obj.ui.transform.localScale = Vector3.one
			end
			fx_item_map[data.x][data.y] = _obj
			table.insert(M.temp_objs,fx_item_map[data.x][data.y] )
		end
	end)
	seq:AppendInterval(EliminateBSModel.GetTime(EliminateBSModel.time.swk_xc_qy))
	seq:AppendCallback(function(  )
		Destroy(obj)
		for x,_v in pairs(fx_item_map) do
			for y,v in pairs(_v) do
				v:Exit()
			end
		end	
	end)
	seq:AppendInterval(EliminateBSModel.GetTime(EliminateBSModel.time.xc_pt))
	seq:AppendCallback(function(  )
		local pos = eliminate_bs_algorithm.get_center_pos(data.cur_del_map)
		fx_obj = newObject("xxl_xy_tuowei_huang",M.GetRootNode())
		fx_obj.transform.localPosition = pos
		fx_obj.gameObject:SetActive(false)
		local t_pos = Vector3.New(100,560,0)
		local seq_xx = DoTweenSequence.Create()
		table.insert( fx_seq,seq_xx)
		seq_xx:AppendInterval(EliminateBSModel.GetTime(0.02))
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
	seq:AppendInterval(EliminateBSModel.GetTime(EliminateBSModel.time.swk_xc_hy))
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
	seq:AppendInterval(EliminateBSModel.GetTime(8))
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
			k_map[v.x][v.y].transform.localPosition = eliminate_bs_algorithm.get_pos_by_index(v.x,v.y)
			k_map[v.x][v.y].gameObject:SetActive(true)
		end

		for i,data in ipairs(data.cur_del_map) do
			fx_item_map[data.x] = fx_item_map[data.x] or {}
			local _obj = EliminateBSItem.Create({x = data.x, y = data.y, id = data.v})
			if _obj and _obj.ui and IsEquals(_obj.ui.transform) then
				_obj.ui.transform.parent = M.GetRootNode()
				_obj.ui.transform.localScale = Vector3.one
				fx_item_map[data.x][data.y] = _obj
				table.insert(M.temp_objs,fx_item_map[data.x][data.y] )
			end
		end
	end)
	seq:AppendInterval(EliminateBSModel.GetTime(EliminateBSModel.time.ts_xc_qy))
	seq:AppendCallback(function(  )
		Destroy(obj)
		for x,_v in pairs(fx_item_map) do
			for y,v in pairs(_v) do
				v:Exit()
			end
		end	
	end)
	seq:AppendInterval(EliminateBSModel.GetTime(EliminateBSModel.time.xc_pt))
	seq:AppendCallback(function(  )
		local pos = eliminate_bs_algorithm.get_center_pos(data.cur_del_map)
		fx_obj = newObject("xxl_xy_tuowei_huang",M.GetRootNode())
		fx_obj.transform.localPosition = pos
		fx_obj.gameObject:SetActive(false)
		local t_pos = Vector3.New(1180,850,0)
		local seq_xx = DoTweenSequence.Create()
		table.insert( fx_seq,seq_xx)
		seq_xx:AppendInterval(EliminateBSModel.GetTime(0.02))
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

	seq:AppendInterval(EliminateBSModel.GetTime(EliminateBSModel.time.ts_xc_hy))
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
	seq:AppendInterval(EliminateBSModel.GetTime(8))
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
	local xc_count = eliminate_bs_algorithm.get_xc_count(data.bgj_xc_map)
	local t = total_time / xc_count
	local temp_objs = {}
	local seq = DoTweenSequence.Create()
	seq:AppendInterval(EliminateBSModel.GetTime(EliminateBSModel.time.swk_jb_sg))
	for x,_v in pairs(data.bgj_xc_map) do
		for y,v in pairs(_v) do
			seq:AppendCallback(function(  )
				local pos = eliminate_bs_algorithm.get_pos_by_index(x,y)
				local seq2 = DoTweenSequence.Create()
				local obj = GameObject.Instantiate( M.GetPrefab("xxl_xy_tuowei_huang"),M.GetRootNode())
				table.insert(M.temp_objs,obj)
				table.insert(temp_objs,obj)
				obj.gameObject:SetActive(false)
				obj.transform.position = o_pos
				seq2:AppendInterval(EliminateBSModel.GetTime(0.02))
				seq2:AppendCallback(function(  )
					obj.gameObject:SetActive(true)
				end)
				seq2:Append(obj.transform:DOLocalMove(Vector3.New(pos.x,pos.y,0),EliminateBSModel.GetTime(EliminateBSModel.time.swk_jb_sg_yd))):SetEase(DG.Tweening.Ease.OutBack)
				seq2:OnForceKill(function ()
					Destroy(obj.gameObject)
				end)				
			end)	
		end
	end
	seq:AppendInterval(EliminateBSModel.GetTime(6))
	seq:OnForceKill(function ()
		for k,v in pairs(temp_objs) do
			Destroy(v)
		end
	end)
end

function M.CreateSWKTW1(o_pos,bgj_xc_map)
	if table_is_null(bgj_xc_map) then return end
	local temp_objs = {}
	local xc_count = eliminate_bs_algorithm.get_xc_count(bgj_xc_map)
	local seq = DoTweenSequence.Create()
	for x,_v in pairs(bgj_xc_map) do
		for y,v in pairs(_v) do
			local pos = eliminate_bs_algorithm.get_pos_by_index(x,y)
			local obj = GameObject.Instantiate( M.GetPrefab("xxl_xy_tuowei_huang"),M.GetRootNode())
			table.insert(M.temp_objs,obj)
			table.insert(temp_objs,obj)
			obj.gameObject:SetActive(false)
			obj.transform.position = o_pos
			seq:AppendInterval(EliminateBSModel.GetTime(0.02))
			seq:AppendCallback(function(  )
				obj.gameObject:SetActive(true)
			end)
			seq:Append(obj.transform:DOLocalMove(Vector3.New(pos.x,pos.y,0),EliminateBSModel.GetTime(EliminateBSModel.time.swk_jb_sg_yd)))
			seq:AppendInterval(EliminateBSModel.GetTime(0.04))
			seq:AppendCallback(function ()
				EliminateBSAnimManager.DOShakePositionCamer(nil,EliminateBSModel.GetTime(EliminateBSModel.time.bgj_xc_zd))
				Destroy(obj.gameObject)
			end)
		end
	end
	seq:AppendInterval(EliminateBSModel.GetTime(6))
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
	seq:AppendInterval(EliminateBSModel.GetTime(0.02))
	seq:AppendCallback(function(  )
		obj.gameObject:SetActive(true)
	end)
	seq:Append(obj.transform:DOLocalMove(Vector3.New(t_pos.x,t_pos.y,0),EliminateBSModel.GetTime(EliminateBSModel.time.swk_jb_sg_yd)))
	seq:AppendInterval(EliminateBSModel.GetTime(0.04))
	seq:AppendCallback(function ()
		EliminateBSAnimManager.DOShakePositionCamer(nil,EliminateBSModel.GetTime(EliminateBSModel.time.bgj_xc_zd))
		Destroy(obj.gameObject)
	end)	
	seq:AppendInterval(EliminateBSModel.GetTime(6))
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
	seq:AppendInterval(EliminateBSModel.GetTime(EliminateBSModel.time.bgj_xc))
	seq:AppendCallback(function(  )
		local pos = eliminate_bs_algorithm.get_center_pos(data.cur_del_map)
		fx_obj = newObject("xxl_xy_tuowei",M.GetRootNode())
		fx_obj.transform.localPosition = pos
		fx_obj.gameObject:SetActive(true)
		local t_pos = _tpos or Vector3.New(730,560,0)
		local seq_xx = DoTweenSequence.Create()
		table.insert( fx_seq,seq_xx)
		seq_xx:Append(fx_obj.transform:DOLocalMove(t_pos,EliminateBSModel.GetTime(EliminateBSModel.time.bgj_xc_fx)))
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
	seq:AppendInterval(EliminateBSModel.GetTime(8))
	seq:OnForceKill(function ()
		for i,v in ipairs(fx_seq) do
			v:Kill()
		end
	end)
end

function M.CreateBGJTW(o_pos,next_data)
	if table_is_null(next_data.xc_change_data) then return end
	local total_time = 1
	local xc_count = eliminate_bs_algorithm.get_xc_count(next_data.xc_change_data)
	local t = total_time / xc_count
	local _temp_obj = {}
	local seq = DoTweenSequence.Create()
	for x,_v in pairs(next_data.xc_change_data) do
		for y,v in pairs(_v) do
			seq:AppendCallback(function(  )
				local seq2 = DoTweenSequence.Create()
				local pos = eliminate_bs_algorithm.get_pos_by_index(x,y)
				local obj = GameObject.Instantiate( M.GetPrefab("xxl_xy_bgj_huo_tuowei"),M.GetRootNode())
				table.insert(M.temp_objs,obj)
				table.insert(_temp_obj,obj)
				obj.gameObject:SetActive(true)
				obj.transform.position = o_pos
				seq2:AppendInterval(EliminateBSModel.GetTime(EliminateBSModel.time.bgj_sl_tw_dd))
				seq2:AppendCallback(function(  )
					local r = M.BGJRotation[x][y]
					obj.transform.rotation = Quaternion.Euler(0, 0, r)
				end)
				seq2:Append(obj.transform:DOLocalMove(Vector3.New(pos.x,pos.y,0),EliminateBSModel.GetTime(EliminateBSModel.time.bgj_sl_tw_yd))):SetEase(DG.Tweening.Ease.OutBack)
				seq2:AppendInterval(EliminateBSModel.GetTime(EliminateBSModel.time.bgj_sl_tw_zs))
				seq2:AppendCallback(function(  )
					Destroy(obj.gameObject)
					local bs_obj = GameObject.Instantiate( M.GetPrefab("xxl_xy_bianshen_mini"),M.GetRootNode())
					table.insert(M.temp_objs,bs_obj)
					table.insert(_temp_obj,bs_obj)
					bs_obj.transform.localPosition = pos
					ExtendSoundManager.PlaySound(audio_config.sdbgj.bgm_sdbgj_bgj_sl.audio_name)
				end)
				seq2:AppendInterval(EliminateBSModel.GetTime(EliminateBSModel.time.bgj_sl_gb))
				seq2:AppendCallback(function ()
					local money = StringHelper.ToCash(EliminateBSModel.GetAwardGold(next_data.bgj_rate_map[x][y]))
					local obj1 = EliminateBSObjManager.item_obj["EliminateBSItem" .. v]
					if obj1 and IsEquals(obj1) then
						local parent = M.GetRootNode()
						obj1 = GameObject.Instantiate(obj1,parent)
						obj1.transform.localPosition = eliminate_bs_algorithm.get_pos_by_index(x,y)
						local bg = obj1.gameObject.transform:Find("@bg")
						bg.gameObject:SetActive(true)
						local money_txt = obj1.gameObject.transform:Find("@money_txt"):GetComponent("Text")
						money_txt.text = money or ""
						EliminateBSItem.ChangeMoneyTxtLayer(money_txt,6)
						EliminateBSItem.MoneyPlayAni(money_txt,money,6,true)
						table.insert(M.temp_objs,obj1)
						-- table.insert(_temp_obj,obj1)
						_bgj_xf_obj = _bgj_xf_obj or {}
						table.insert(_bgj_xf_obj,obj1)
					end
				end)
			end)
			seq:AppendInterval(EliminateBSModel.GetTime(EliminateBSModel.time.bgj_sl_tw_jg))
		end
	end
	seq:AppendInterval(EliminateBSModel.GetTime(6))
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
		local pos = eliminate_bs_algorithm.get_pos_by_index(x,y)
		local bs_obj = GameObject.Instantiate( M.GetPrefab("xxl_xy_bianshen_mini"),M.GetRootNode())
		bs_obj.transform.localPosition = pos
		table.insert(M.temp_objs,bs_obj)
		table.insert(_temp_obj,bs_obj)
	end)
	seq:AppendInterval(EliminateBSModel.GetTime(4))
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
	seq:AppendInterval(EliminateBSModel.GetTime(8))
	seq:OnForceKill(function ()
		if IsEquals(obj) then
			Destroy(obj)
		end
	end)
end

--额外转动的提示框
function M.CreateScrollAddKuang(_x,y,id)
	local seq = DoTweenSequence.Create()
	seq:AppendInterval(EliminateBSModel.GetTime(1))
	seq:AppendCallback(function ()
		local pre
		if id == EliminateBSModel.eliminate_enum.swk then
			pre = "xxl_xy_swk_kuang"
		elseif id == EliminateBSModel.eliminate_enum.ts then
			pre = "xxl_xy_ts_kuang"
		end
		for x=_x - 2, _x - 1 do
			scroll_add_kuang[x] = scroll_add_kuang[x] or {}
			scroll_add_kuang[x][y] = newObject(pre,M.GetRootNode())
			scroll_add_kuang[x][y].transform.localPosition = eliminate_bs_algorithm.get_pos_by_index(x,y)
			scroll_add_kuang[x][y].gameObject:SetActive(true)
		end
	end)
end

function M.DestroyScrollAddKuang(_x,y)
	for x=_x - 2, _x - 1 do
		if scroll_add_kuang[x] and scroll_add_kuang[x][y] and IsEquals(scroll_add_kuang[x][y]) then
			Destroy(scroll_add_kuang[x][y].gameObject)
			scroll_add_kuang[x][y] = nil
		end
	end
end

function M.DestroyAllScrollAddKuang(  )
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

--触发虎符特效
function M.HFfly(data, finish_call)
	local data = eliminate_bs_algorithm.change_map_to_list(data)
    local obj = GameObject.Instantiate(GetPrefab("xxl_sg_hf_prefab"), M.GetRootNode()).gameObject
    local path = {}
    local tab = {}
    if #data % 2 == 0 then
    	tab = data[#data/2]
    elseif #data % 2 == 1 then
		tab = data[(#data + 1)/2]
    end
    local a = eliminate_bs_algorithm.get_pos_by_index(tab.x,tab.y)
    local b = Vector3.New(660,380,0)
    obj.transform.localPosition = a
    path[0] = a
    --path[1] = Vector3.New((a.x > b.x and math.random(a.x,b.x) or math.random(b.x,a.x)) + 20,(a.y > b.y and math.random(a.y,b.y) or math.random(b.y,a.y)) + 20,0)
    path[1] = Vector3.New(b.x,b.y,0)
    local seq = DoTweenSequence.Create()
    seq:Append(obj.transform:DOPath(path,EliminateBSModel.GetTime(1),DG.Tweening.PathType.CatmullRom))
    seq:OnKill(function ()
        if finish_call and type(finish_call) == "function" then
            finish_call()
        end
        finish_call = nil
    end)
    seq:OnForceKill(function ()
        destroy(obj)
    end)
end

--蔓延特效
function M.PlaySpread(data, finish_call)
    local obj = GameObject.Instantiate(GetPrefab("ranshao_manyan"), M.GetRootNode()).gameObject
    local a = eliminate_bs_algorithm.get_pos_by_index(data.x,data.y)
    obj.transform.localPosition = a
    local seq = DoTweenSequence.Create()
    seq:AppendInterval(0.85)
    seq:AppendCallback(function ()
    	if finish_call and type(finish_call) == "function" then
            finish_call()
        end
        finish_call = nil
    end)
    seq:AppendInterval(0.15)
    seq:OnKill(function ()
        if finish_call and type(finish_call) == "function" then
            finish_call()
        end
        finish_call = nil
    end)
    seq:OnForceKill(function ()
        destroy(obj)
    end)
end

--刮东风
function M.PlayWind(keepTime, call_time,finish_call)
	local obj = GameObject.Instantiate(GetPrefab("xxl_likui_dksj_longjuanfeng"), M.GetRootNode()).gameObject
    obj.transform.position = Vector3.zero
    local seq = DoTweenSequence.Create()
    if call_time then
        seq:AppendInterval(call_time)
        seq:AppendCallback(function ()
            if finish_call and type(finish_call) == "function" then
                finish_call()
            end
            finish_call = nil
        end)
        keepTime = keepTime - call_time
        if keepTime <= 0 then
            keepTime = nil
        end
    end

    if keepTime and keepTime > 0.001 then
        seq:AppendInterval(keepTime)
    end
    seq:OnKill(function ()
        if finish_call and type(finish_call) == "function" then
            finish_call()
        end
        finish_call = nil
    end)
    seq:OnForceKill(function ()
        destroy(obj)
    end)
end

--虎符闪光特效
function M.CreateLuckyRight(map,t)
	local objs = {}
	for x,_v in pairs(map) do
		for y,v in pairs(_v) do
			if IsEquals(M.GetRootNode()) then
				local p_obj = GameObject.Instantiate(M.GetPrefab("xxl_sg_hufu"),M.GetRootNode())
				p_obj.transform.localPosition = eliminate_bs_algorithm.get_pos_by_indexTX(x,y)

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

--点亮火
function M.LitFire(data)
	if fire_map[data.x] and fire_map[data.x][data.y] then
	else
		local obj = GameObject.Instantiate(GetPrefab("ranshao_xunhuan"), M.GetRootNode()).gameObject
	    local pos = eliminate_bs_algorithm.get_pos_by_index(data.x,data.y)
	    obj.transform.localPosition = pos
	    fire_map[data.x] = fire_map[data.x] or {}
	    fire_map[data.x][data.y] = obj
	end
end

--熄灭火
function M.PutOutFire(data)
	--[[print(debug.traceback())
	dump(data,"<color=yellow><size=15>++++++++++熄灭++++++++++</size></color>")
	if fire_map[data.x] and fire_map[data.x][data.y] then
		destroy(fire_map[data.x][data.y])
		fire_map[data.x][data.y] = nil
	end--]]
end

function M.CreateSpecialItemPart(data, finish_call)
    local obj = GameObject.Instantiate(GetPrefab("bsmz_eff_hecheng"), M.GetRootNode()).gameObject
    local a = eliminate_bs_algorithm.get_pos_by_index(data.x,data.y)
    obj.transform.localPosition = a
    local seq = DoTweenSequence.Create()
    seq:AppendInterval(EliminateBSModel.GetTime(1))
    seq:OnKill(function ()
        if finish_call and type(finish_call) == "function" then
            finish_call(data)
        end
        finish_call = nil
    end)
    seq:OnForceKill(function ()
        destroy(obj)
    end)
end

function M.AddEliminateItem_SpecialTX(data)
	if M.special_map[data.x] and M.special_map[data.x][data.y] then return end
	local pre_name
	if data.id >= 200 and data.id < 210 then
		pre_name = "bsmz_eff_siyuansu"
	elseif data.id >= 210 and data.id < 220 then
		pre_name = "bsmz_eff_wuiyuansu"
	elseif data.id >= 220 then
		pre_name = "bsmz_eff_liuyuansu"
	else
		return
	end
	local obj = GameObject.Instantiate(GetPrefab(pre_name), M.GetRootNode()).gameObject
	local a = eliminate_bs_algorithm.get_pos_by_index(data.x,data.y)
    obj.transform.localPosition = a
    M.special_map[data.x] = M.special_map[data.x] or {}
    M.special_map[data.x][data.y] = obj
end

function M.RemoveEliminateItem_SpecialTX(data)
	if M.special_map[data.x] and M.special_map[data.x][data.y] then
		Destroy(M.special_map[data.x][data.y])
		M.special_map[data.x][data.y] = nil
	end
end

function M.RemoveEliminateItem_SpecialTXAll()
	for k,v in pairs(M.special_map) do
		for kk,vv in pairs(v) do
			Destroy(vv)
		end
	end
	M.special_map = {}
end

function M.DOShakePositionCamer(camer,t,end_pos,finish_call)
	if not camer then
		camer = GameObject.Find("Camera")
		end_pos = Vector3.New(0,0,-406)
	end

	local o_pos = camer.transform.localPosition
	local seq = DoTweenSequence.Create()
	seq:Append(camer.transform:DOShakePosition(t, Vector3.New(30,30,0),20))
	seq:OnKill(function(  )
		if finish_call and type(finish_call) == "function" then
            finish_call()
        end
		if IsEquals(camer) then
			camer.transform.localPosition = o_pos
			if end_pos then
				camer.transform.localPosition = end_pos
			end
		end
	end)
	seq:OnForceKill(function ()
		if IsEquals(camer) then
			camer.transform.localPosition = o_pos
			if end_pos then
				camer.transform.localPosition = end_pos
			end
		end
	end)
end

--*************************宝石幻境******************************
M.bshjTweens = {}
local offSetBsLotteryed = {
	x = -114.3,
	y = -347,
}
local offSetBs = {
	x = -114.3,
	y = -204.7,
}

local dXBsLotteryed = 125.4
local dYBs = 126.7

local FxPre = {
	[1] = {openPre = "bsmz_eff_ptysbao", tuoweiPre = "bsmz_eff_ptystw", matchPre = "bsmz_eff_ptysgz",},
	[2] = {openPre = "bsmz_eff_bxpt", tuoweiPre = "bsmz_eff_bxpttw", matchPre = "bsmz_eff_bxptz",},
	[3] = {openPre = "bsmz_eff_bxts", tuoweiPre = "bsmz_eff_bxtstw", matchPre = "bsmz_eff_bxtsgz1",},
}

local FxTime = {
	[1] = {openTime = 0.3, tuoweiTime = 0.9, matchTime = 2,},
	[2] = {openTime = 0.7, tuoweiTime = 0.9, matchTime = 1,},
	[3] = {openTime = 0.7, tuoweiTime = 1.2, matchTime = 2,},
}

local extPos = {
	[1] = {i = 2, j = 3},
	[2] = {i = 3, j = 2},
	[3] = {i = 3, j = 4},
	[4] = {i = 4, j = 3},
}

M.bshjTweens = {}
function M.AddTweenBSHJ(seq)
	M.bshjTweens[#M.bshjTweens + 1] = seq
end

function M.ClearTweenBSHJ()
	if table_is_null(M.bshjTweens) then
		return
	end
	for i = 1, #M.bshjTweens do
		M.bshjTweens[i]:Kill()
	end
	M.bshjTweens = {}
end

--宝石幻境	抽奖的特效
function M.CreateBsLotteryedFX(finishCall, i, endPos, fxType, fxTrans)
	local seq = DoTweenSequence.Create({dotweenLayerKey = "bshj_lottery_fx"})
	local objOpen = newObject(FxPre[fxType].openPre, fxTrans)
	local posStart = Vector3.New(offSetBsLotteryed.x + (i - 1) * dXBsLotteryed, offSetBsLotteryed.y, 0)
	local posEnd
	if fxType == 3 then
		posEnd = Vector3.New(offSetBsLotteryed.x + (endPos.x - 1) * dXBsLotteryed, offSetBs.y + (endPos.y - 1) * dYBs, 0)
	else
		posEnd = Vector3.New(posStart.x, offSetBs.y + (endPos.y - 1) * dYBs, 0)
	end
	objOpen.transform.localPosition = posStart
	seq:AppendInterval(FxTime[fxType].openTime)
	seq:AppendCallback(function()
		destroy(objOpen)
	end)
	local objTuowei = newObject(FxPre[fxType].tuoweiPre, fxTrans)
	objTuowei.transform.localPosition = posStart
	if fxType == 1 then
		seq:Append(objTuowei.transform:DOLocalMove(posEnd, FxTime[fxType].tuoweiTime))
		seq:SetEase(DG.Tweening.Ease.InQuad)
	else
		local path = {}
		local offX = math.random( -(i * 20), (i * 20))
		path[0] = posStart
		path[1] = Vector3.New(posStart.x + offX, posStart.y + (posEnd.y - posStart.y) * 0.618, 0)
		path[2] = posEnd
		seq:Append(objTuowei.transform:DOLocalPath(path, FxTime[fxType].tuoweiTime, DG.Tweening.PathType.CatmullRom))
	end
	seq:OnKill(function()
		destroy(objTuowei)
    	ExtendSoundManager.PlaySound(audio_config.bsmz.bgm_bsmz_gezi.audio_name)
		local seq2 = DoTweenSequence.Create()
		local objMatch = newObject(FxPre[fxType].matchPre, fxTrans)
		objMatch.transform.localPosition = posEnd
		seq2:AppendInterval(FxTime[fxType].matchTime)
		seq2:AppendCallback(function()
			destroy(objMatch)
			if finishCall then
				finishCall()
			end
		end)
		M.AddTweenBSHJ(seq2)
	end)
	M.AddTweenBSHJ(seq)
end

--宝石幻境	连线的特效 lineType:1横线 2竖线 3斜线 
function M.CreateLineFx(finishCall, index, lineType, awardGetFX, fxTrans)
	local prefabName
	if lineType == 1 or lineType == 2 then
		prefabName = "bsmz_eff_lxhss"
	else
		prefabName = "bsmz_eff_lxxx"
	end
	local rotateZ = 0
	if lineType == 3 then
		if index == 1 then
			rotateZ = 90
		end
	elseif lineType == 2 then
		rotateZ = 90
	end

	local seq = DoTweenSequence.Create()
	local lineObj = newObject(prefabName, fxTrans)
	local posX = lineObj.transform.localPosition.x
	local posY = lineObj.transform.localPosition.y
	if lineType == 1 then
		posY = offSetBs.y + (index - 1) * dYBs
	end
	if lineType == 2 then
		posX = offSetBs.x + (index - 1) * dXBsLotteryed
		posY = posY - 2 * dYBs
	end
	lineObj.transform.localPosition = Vector3.New(posX, posY, 0)
	lineObj.transform.localRotation = Quaternion:SetEuler(0, 0, rotateZ)
	local objBaozha = newObject("bsmz_eff_lxbz", fxTrans)
	seq:AppendInterval(1)
	seq:AppendCallback(function()
		destroy(lineObj)
		local seq2 = DoTweenSequence.Create()
		local posLinePosX = {}
		local posLinePosY = {}
		local upPos = {1, 2, 3, 4, 5}
		local downPos = {5, 4, 3, 2, 1}
		local indexPos = {index, index, index, index, index}
		if lineType == 1 then
			posLinePosX, posLinePosY = upPos, indexPos
		elseif lineType == 2 then
			posLinePosX, posLinePosY = indexPos, upPos
		elseif lineType == 3 then
			if index == 1 then
				posLinePosX, posLinePosY = upPos, upPos
			else
				posLinePosX, posLinePosY = upPos, downPos
			end
		end
		local objLineBsObjs = {}
		for i = 1, 5 do
			objLineBsObjs[i] = newObject("bsmz_eff_madeng", fxTrans)
			objLineBsObjs[i].transform.localPosition = Vector3.New(offSetBs.x + (posLinePosX[i] - 1) * dXBsLotteryed - 2, offSetBs.y + (posLinePosY[i] - 1) * dYBs + 1, 0)
		end
		seq2:AppendInterval(2)
		seq2:AppendCallback(function()
			for i = 1, #objLineBsObjs do
				destroy(objLineBsObjs[i])
			end
		end)
		M.AddTweenBSHJ(seq2)
	end)
	seq:AppendInterval(1.5)
	seq:AppendCallback(function()
		local seq3 =  DoTweenSequence.Create()
		local lxTuoweiObj = newObject("bsmz_eff_lxtuowei", fxTrans)
		ExtendSoundManager.PlaySound(audio_config.bsmz.bgm_bsmz_lianxianaward.audio_name)
		lxTuoweiObj.transform.localPosition = Vector3.New(-363, -95, 0)
		local path = {}
		path[0] = Vector3.New(-309, -83, 0)
		path[1] = Vector3.New(-583, 17, 0)
		path[2] = Vector3.New(-642, 226, 0)
		seq3:Append(lxTuoweiObj.transform:DOPath(path, 1, DG.Tweening.PathType.CatmullRom))
		seq3:OnKill(function()
			awardGetFX.gameObject:SetActive(false)
			awardGetFX.gameObject:SetActive(true)
			destroy(objBaozha)
			destroy(lxTuoweiObj)
			if finishCall then
				finishCall()
			end
		end)
		M.AddTweenBSHJ(seq3)
	end)
	M.AddTweenBSHJ(seq)
end

--宝石幻境	额外奖励特效
function M.CreateExtLotteryFx(call, fxTrans)
	local seq = DoTweenSequence.Create()
	local extLotteryObj = newObject("bsmz_eff_gwyszi", fxTrans)
	seq:AppendInterval(1)
	seq:AppendCallback(function()
		local objsExtFx = {}
		for i = 1, #extPos do
			local b = newObject("bsmz_eff_gwyszigz", fxTrans)
			b.transform.localPosition = Vector3.New(offSetBsLotteryed.x + (extPos[i].i - 1) * dXBsLotteryed, offSetBs.y + (extPos[i].j - 1) * dYBs, 0)
			objsExtFx[#objsExtFx + 1] = b
		end
		local seq2 = DoTweenSequence.Create()
		seq2:AppendInterval(2.5)
		seq2:AppendCallback(function()
			destroy(extLotteryObj)
			for i = 1, #objsExtFx do
				destroy(objsExtFx[i])
			end
			if call then
				call()
			end
		end)
		M.AddTweenBSHJ(seq2)
	end)
	M.AddTweenBSHJ(seq)
end
--宝石幻境	金币生成的特效
function M.CreateNumGoldInPosBSHJ(pos,gold,fatherTrans)
	if gold == 0 then return end 
	local obj = newObject("xxl_num", fatherTrans)
	obj.transform.position = Vector3.New(pos.x,pos.y,0)
	obj.transform.localScale = Vector3.New(0.3, 0.3, 1)
	local gold_txt = obj.transform:Find("gold_txt"):GetComponent("Text")
	gold_txt.font = GetFont("by_tx1")	
	gold_txt.text = gold or 0
	gold_txt.transform.localScale = Vector3.New(0.2, 0.2, 1)
	
	local t = EliminateBSModel.time.xc_jb_pt_sz_fei_jg
	local seq = DoTweenSequence.Create()
	seq:AppendInterval(EliminateBSModel.GetTime(t * 2))
	seq:Append(obj.transform:DOScale(Vector3.one, EliminateBSModel.time.xc_jb_pt_sz_fd_jg * 1.5))
	seq:Append(obj.transform:DOLocalMoveY(obj.transform.localPosition.y + 40, EliminateBSModel.time.xc_jb_pt_sz_yd_sj * 1.5))
	seq:SetEase(DG.Tweening.Ease.OutCirc)
	seq:OnKill(function ()
		Destroy(obj)
	end)
	M.AddTweenBSHJ(seq)
end