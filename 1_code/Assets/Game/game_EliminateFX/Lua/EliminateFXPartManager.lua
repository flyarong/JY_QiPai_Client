-- 创建时间:2019-03-19
EliminateFXPartManager = {}
local M = EliminateFXPartManager
M.objs = {}
M.temp_objs = {}
M.lucky_objs = {}
function M.ExitTimer()
	M.ClearAllObj()
end

local fire_map = {}
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
	for k,v in pairs(M.lucky_objs) do
		Destroy(v)
	end
	M.lucky_objs = {}
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
	for k,v in pairs(M.lucky_objs) do
		if IsEquals(v) and IsEquals(v.gameObject) then
			Destroy(v)
		end
	end
	M.lucky_objs = {}
	destroyChildren(M.GetRootNode())
	--destroyChildren(M.GetCenterRootNode())
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
	
	local t = EliminateFXModel.time.xc_jb_pt_sz_fei_jg
	local seq = DoTweenSequence.Create()
	seq:AppendInterval(EliminateFXModel.GetTime(t * 2))
	seq:Append(obj.transform:DOScale(Vector3.one,EliminateFXModel.time.xc_jb_pt_sz_fd_jg))
	seq:Append(obj.transform:DOLocalMoveY(obj.transform.localPosition.y + 80,EliminateFXModel.time.xc_jb_pt_sz_yd_sj))
	seq:SetEase(DG.Tweening.Ease.OutCirc)
	seq:OnForceKill(function ()
		Destroy(obj)
	end)
end

function M.CreateNumGold(data,gold)
	if gold == 0 then return end 
	local pos = eliminate_fx_algorithm.get_center_pos(data)
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
	local t = is_crite and EliminateFXModel.time.xc_jb_bj_sz_fei_jg or EliminateFXModel.time.xc_jb_pt_sz_fei_jg
	local seq = DoTweenSequence.Create()
	seq:AppendInterval(EliminateFXModel.GetTime(t * 2))
	seq:Append(obj.transform:DOScale(Vector3.one,EliminateFXModel.time.xc_jb_pt_sz_fd_jg))
	seq:Append(obj.transform:DOLocalMoveY(pos.y + 80,EliminateFXModel.time.xc_jb_pt_sz_yd_sj))
	seq:SetEase(DG.Tweening.Ease.OutCirc)
	seq:OnForceKill(function ()
		Destroy(obj)
	end)
end

--暴击
function M.CreateCrit(data,gold)
	local pos = eliminate_fx_algorithm.get_center_pos(data)
	local seq1 = DoTweenSequence.Create()
	local is_crite = #data >= 5
	local t = is_crite and EliminateFXModel.time.xc_jb_bj_sz_fei_jg or EliminateFXModel.time.xc_jb_pt_sz_fei_jg
	seq1:AppendInterval(t)
	seq1:AppendCallback(function ()
		local seq = DoTweenSequence.Create()
		local obj = GameObject.Instantiate(M.GetPrefab("xxl_crit"),M.GetRootNode())
		obj.transform.localPosition = Vector3.New(pos.x,pos.y,0)
		seq:Append(obj.transform:DOScale(Vector3.one * 2,EliminateFXModel.time.xc_bj_fd)):SetEase(DG.Tweening.Ease.OutBack)
		seq:AppendInterval(EliminateFXModel.time.xc_bj_jg)
		seq:Append(obj.transform:DOScale(Vector3.zero,EliminateFXModel.time.xc_bj_sx))
		seq:OnForceKill(function ()
			M.CreateNumGold(data,gold)
			Destroy(obj)
		end)
	end)
end

function M.CreateEliminateParticleItem(data,templet,gold)
	--if gold==0 then return end
	local templet_t = {}
	local seq = DoTweenSequence.Create()
	seq:AppendInterval(EliminateFXModel.time.xc_jb_pt_bjb_ys)
	seq:AppendCallback(function ()
		for k,v in pairs(data) do
			local obj = GameObject.Instantiate(templet,M.GetRootNode())
			obj.transform.localPosition = eliminate_fx_algorithm.get_pos_by_index(v.x,v.y)
			table.insert(M.temp_objs,obj )
			table.insert(templet_t,obj )
		end
	end)
	local pos = eliminate_fx_algorithm.get_center_pos(data)
	M.CreateTW(pos)
	seq:AppendInterval(EliminateFXModel.GetTime(10))
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

--爆金币
function M.CreateEliminateNor1(data,gold)
	local fx_name = "YX_xc_01"
	M.CreateEliminateParticleItem(data,M.GetPrefab(fx_name),gold)
end

function M.CreateEliminateNor2(data,gold)
	local fx_name = "YX_xc_02"
	M.CreateEliminateParticleItem(data,M.GetPrefab(fx_name),gold)
end

function M.CreateEliminateNor3(data,gold)
	local fx_name = "YX_xc_03"
	M.CreateEliminateParticleItem(data,M.GetPrefab(fx_name),gold)
end

function M.CreateTW(pos)
	local obj = GameObject.Instantiate(M.GetPrefab("TW_lizi_gx") ,M.GetRootNode())
	obj.transform.localPosition = Vector3.New(pos.x,pos.y,0)
	local path = {}
	local a = pos
	local b = Vector3.New(-605,186,0)
	path[0] = a
	path[1] = b
	local seq = DoTweenSequence.Create()
	seq:Append(obj.transform:DOPath(path,EliminateFXModel.GetTime(1),DG.Tweening.PathType.CatmullRom))
	seq:OnKill(function ()
    end)
    seq:OnForceKill(function ()
        destroy(obj)
    end)
end

function M.CreateTR()
	local obj = GameObject.Instantiate(M.GetPrefab("UI_jinbi_tw") ,M.GetRootNode())
	obj.transform.localPosition = Vector3.New(1080,-40,0)
	local path = {}
	local a = pos
	local b = Vector3.New(10,250,0)
	path[0] = a
	path[1] = b
	local seq = DoTweenSequence.Create()
	seq:Append(obj.transform:DOPath(path,EliminateFXModel.GetTime(1.5),DG.Tweening.PathType.CatmullRom))
	local obj1
	seq:AppendCallback(function ()
		destroy(obj)
		obj1 = GameObject.Instantiate(M.GetPrefab("UI_jc_sg") ,M.GetRootNode())
		obj1.transform.localPosition = Vector3.New(338,578,0)
	end)
	seq:AppendInterval(1)
	seq:OnKill(function ()
    end)
    seq:OnForceKill(function ()
        destroy(obj)
        destroy(obj1)
    end)
end

local tw_map = {
	[100] = "UI_yb_tw",
	[101] = "TW_caishen_01",
	[102] = "TW_caishen_02",
	[103] = "TW_caishen_03",
}

local boom_map = {
	[100] = "UI_yb_fankui",
	[101] = "TW_baozha_01",
	[102] = "TW_baozha_02",
	[103] = "TW_baozha_03",
}

function M.CreateAddRateFly(startPos, endPos, sendId, time)
	-- dump(sendId, "sendId")
	local preName = tw_map[sendId]
	-- dump(preName, "preName")
	local obj = GameObject.Instantiate(M.GetPrefab(preName) ,M.GetRootNode())
	obj.transform.localPosition = startPos
	local path = {}
	path[0] = startPos
	if sendId == 100 then
		local halfPos = Vector3.New((startPos.x + endPos.x) * 0.5, (startPos.y + endPos.y) * 0.5, 0)
		local dPos = startPos - endPos
		local dx = math.random( (- 0.3) * dPos.x , 0.3 * dPos.x)
		local dy = math.random( (- 0.3) * dPos.y , 0.3 * dPos.y)
		path[1] = Vector3.New(halfPos.x + dx, halfPos.y + dy, 0)
		path[2] = endPos
	else
		path[1] = endPos
	end
	local seq = DoTweenSequence.Create()
	seq:Append(obj.transform:DOLocalPath(path,EliminateFXModel.GetTime(time),DG.Tweening.PathType.CatmullRom))
	seq:AppendCallback(function ()
		destroy(obj)
	end)
end

function M.CreateAddRateBoom(endPos, sendId, time)
	-- dump(sendId, "sendId")
	local preName = boom_map[sendId]
	-- dump(preName, "preName")
	local obj = GameObject.Instantiate(M.GetPrefab(preName) ,M.GetRootNode())
	obj.transform.localPosition = endPos
	local seq = DoTweenSequence.Create()

	if sendId == 100 then
		ExtendSoundManager.PlaySound(audio_config.fxgz.bgm_fxgz_yuanbao.audio_name)
	else
		ExtendSoundManager.PlaySound(audio_config.fxgz.bgm_fxgz_caishen.audio_name)
	end
	seq:AppendInterval(0.5)
	seq:OnForceKill(function ()
		destroy(obj)
	end)
end

function M.CreateAddMoneyToJc(startPos, endPos, time, endCall)
	local obj = GameObject.Instantiate(M.GetPrefab("TW_caishen_01") ,M.GetRootNode())
	obj.transform.localPosition = startPos
	local path = {}
	path[0] = startPos
	path[1] = endPos
	local seq = DoTweenSequence.Create()
	seq:Append(obj.transform:DOLocalPath(path,EliminateFXModel.GetTime(time),DG.Tweening.PathType.CatmullRom))
	seq:AppendCallback(function ()
		if endCall then
			endCall()
		end
		destroy(obj)
	end)
end

function M.CreateLuckyRight(map,t)
	for x,_v in pairs(map) do
		for y,v in pairs(_v) do
			if IsEquals(M.GetRootNode()) then
				local p_obj = GameObject.Instantiate(M.GetPrefab("UI_xc_04"),M.GetRootNode())
				p_obj.transform.localPosition = eliminate_fx_algorithm.get_pos_by_index(x,y)

				table.insert(M.lucky_objs,p_obj)
			end
		end
	end
end

function M.DeleteLuckyRight()
	for k,v in pairs(M.lucky_objs) do
		if IsEquals(v) and IsEquals(v.gameObject) then
			Destroy(v)
		end
	end
	M.lucky_objs = {}
end

function M.ChangeAni(callback)
	ExtendSoundManager.PlaySound(audio_config.fxgz.bgm_fxgz_guochang.audio_name)
	local seq = DoTweenSequence.Create()
	--播红布动画
	local obj = GameObject.Instantiate(GetPrefab("UI_cl_rc"), M.GetRootNode()).gameObject
	obj.transform.localPosition = Vector3.New(338,298,0)
	local width = Screen.width
	local height = Screen.height
	local coefficient = (width/1920) / (height/1080)
	obj.transform.localScale = Vector3.New(coefficient*1,1,1)
	seq:AppendInterval(1.5)
	seq:AppendCallback(function ()
		M.DeleteLuckyRight()
		Event.Brocast("eliminatefx_change_money_title_msg")
	end)
	seq:AppendInterval(2.5)
	seq:OnKill(function ()
		
	end)
	seq:OnForceKill(function ()
		destroy(obj)
		if callback then
			callback()
		end
	end)
end

--触发虎符特效
function M.HFfly(data, finish_call)
	local data = eliminate_fx_algorithm.change_map_to_list(data)
    local obj = GameObject.Instantiate(GetPrefab("TW_lizi_gx"), M.GetRootNode()).gameObject
    local path = {}
    local tab = {}
    if #data % 2 == 0 then
    	tab = data[#data/2]
    elseif #data % 2 == 1 then
		tab = data[(#data + 1)/2]
    end
    local a = eliminate_fx_algorithm.get_pos_by_index(tab.x,tab.y)
    local b = Vector3.New(620,300,0)
    obj.transform.localPosition = a
    path[0] = a
    --path[1] = Vector3.New((a.x > b.x and math.random(a.x,b.x) or math.random(b.x,a.x)) + 20,(a.y > b.y and math.random(a.y,b.y) or math.random(b.y,a.y)) + 20,0)
    path[1] = Vector3.New(b.x,b.y,0)
    local seq = DoTweenSequence.Create()
    seq:Append(obj.transform:DOPath(path,EliminateFXModel.GetTime(1),DG.Tweening.PathType.CatmullRom))
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