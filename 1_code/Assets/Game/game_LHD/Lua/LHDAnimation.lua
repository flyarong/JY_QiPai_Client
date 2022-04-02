-- 创建时间:2019-11-20
-- 蛋蛋斗

LHDAnimation = {}
local A = LHDAnimation

-- 一个固定位置的特效 显示一段时间消失
function A.PlayShowAndHideFX(parent, fx_name, beginPos, keepTime, no_take, call)
	local prefab
	if no_take then
		prefab = GameObject.Instantiate(GetPrefab(fx_name), parent).gameObject
		prefab.transform.position = beginPos
	else
		prefab = CachePrefabManager.Take(fx_name)
		prefab.prefab:SetParent(parent)
		local tran = prefab.prefab.prefabObj.transform
		tran.position = beginPos
		tran.localScale = Vector3.one
	end

	local seq = DoTweenSequence.Create()
	seq:AppendInterval(keepTime)
	seq:OnKill(function ()
		if call then
			call()
		end
	end)
	seq:OnForceKill(function ()
		if no_take then
			destroy(prefab)
		else
			CachePrefabManager.Back(prefab)
		end
	end)		
end
-- 通用飞行特效 
function A.PlayMoveAndHideFX_Obj(obj, beginPos, endPos, keepTime, moveTime, call, endTime)
	local tran = obj.transform
	tran.position = beginPos

	local seq = DoTweenSequence.Create()
	seq:AppendInterval(keepTime)
	seq:Append(tran:DOMove(endPos, moveTime):SetEase(DG.Tweening.Ease.InQuint))
	if endTime then
		seq:AppendInterval(endTime)
	end
	seq:OnKill(function ()
		if call then
			call()
		end
	end)
	seq:OnForceKill(function ()
		destroy(obj)
	end)		
end
-- 通用飞行特效 
function A.PlayMoveAndHideFX(parent, fx_name, beginPos, endPos, keepTime, moveTime, call, endTime)
	local prefab = CachePrefabManager.Take(fx_name)
	prefab.prefab:SetParent(parent)
	local tran = prefab.prefab.prefabObj.transform
	tran.position = beginPos

	local seq = DoTweenSequence.Create()
	seq:AppendInterval(keepTime)
	seq:Append(tran:DOMove(endPos, moveTime):SetEase(DG.Tweening.Ease.InQuint))
	if endTime then
		seq:AppendInterval(endTime)
	end
	seq:OnKill(function ()
		if call then
			call()
		end
	end)
	seq:OnForceKill(function ()
		CachePrefabManager.Back(prefab)
	end)		
end

-- 开局动画
function A.PlayKJ(parent)
	-- PlayShowAndHideFX
	local prefab = CachePrefabManager.Take("ks_prefab")
	prefab.prefab:SetParent(parent)
	local obj = prefab.prefab.prefabObj
	local tran = obj.transform
	tran.localScale = Vector3.one
	tran.localPosition = Vector3.zero

    ExtendSoundManager.PlaySound(audio_config.dld.bgm_by_tiaozhanrenxianshi_game_lhd.audio_name)
	local seq = DoTweenSequence.Create()
	seq:AppendInterval(2)
	seq:OnKill(function ()
	end)
	seq:OnForceKill(function ()
		CachePrefabManager.Back(prefab)
	end)
end
-- 定庄
function A.PlayDZ(parent, z_objs, index, delta_t)
	local seq = DoTweenSequence.Create()
	if delta_t and delta_t > 0 then
		seq:AppendInterval(delta_t)
	end
	local len = #z_objs
	local qs = math.floor( 1.5 / (len*0.1) )
	local num = len * qs + index
	for i = 1, num do
		local p = i
		seq:AppendCallback(function ()
			local cc = p % len
			if cc == 0 then
				cc = len
			end
			for j = 1, len do
				if cc == j then
					z_objs[j].gameObject:SetActive(true)
				else
					z_objs[j].gameObject:SetActive(false)
				end
			end
		end)
		seq:AppendInterval(0.1)
	end
	seq:OnKill(function ()
		local cc = index % len
		if cc == 0 then
			cc = len
		end
		LHDAnimation.PlayNewDZAnim(parent, z_objs[cc].transform.position)
		-- A.PlayShowAndHideFX(z_objs[cc].transform, "LHD_zhuanjiaqueding", z_objs[cc].transform.position, 1, true, function ()
		-- 	Event.Brocast("ui_dz_anim_finish_msg")
		-- end)
	end)
end
function A.PlayNewDZAnim(parent, endPos)
	local prefab = CachePrefabManager.Take("lhd_dz_pre")
	prefab.prefab:SetParent(parent)
	local obj = prefab.prefab.prefabObj
	local tran = obj.transform
	tran.localScale = Vector3.New(4, 4, 4)
	tran.localPosition = Vector3.zero

    ExtendSoundManager.PlaySound(audio_config.dld.bgm_by_tiaozhanrenxianshi_game_lhd.audio_name)
	local seq = DoTweenSequence.Create()
	seq:AppendInterval(0.5)
	seq:Append(tran:DOScale(1, 0.5))
	seq:Join(tran:DOMove(endPos, 0.5):SetEase(DG.Tweening.Ease.InQuint))
	seq:OnKill(function ()
		Event.Brocast("ui_dz_anim_finish_msg")
	end)
	seq:OnForceKill(function ()
		CachePrefabManager.Back(prefab)
	end)

end

-- 透视动画
function A.PlayTSAnim(parent, beginPos, call)
	A.PlayShowAndHideFX(parent, "egg_bianhuan", beginPos, 0.5, true, call)
end

-- 透视提示动画
function A.PlayTShint(parent, endPos, call)
	local prefab = GameObject.Instantiate(GetPrefab("LHD_toushi"), parent).gameObject
	prefab.transform.position = Vector3.zero
	prefab.transform.localScale = Vector3.one
	local tran = prefab.transform
	local seq = DoTweenSequence.Create()
	seq:AppendInterval(1)
	seq:AppendCallback(function ()
		prefab:SetActive(false)
	end)
	seq:AppendInterval(0.1)
	seq:OnKill(function ()
		if call then
			call()
		end
	end)
	seq:OnForceKill(function ()
		destroy(prefab)
	end)
end

-- 游戏开始
function A.PlayKSFX(parent, beginPos)
	A.PlayShowAndHideFX(parent, "@LHD_ks_prefab", beginPos, 1, true)
end
-- 过场通用特效 需替换文字
function A.PlayGCFX(parent, beginPos, type, call, data)
	local fx_name = "@LHD_ks_prefab"
	if type == "zd" then
		fx_name = "LHD_zdsk"
	elseif type == "zjxz" or type == "blzdks" then
		fx_name = "LHD_xsxz"
	elseif type == "czxz" then
		fx_name = "@LHD_chuzhanxuanzhe_prefab"
	end
	local prefab = GameObject.Instantiate(GetPrefab(fx_name), parent).gameObject
	prefab.transform.position = beginPos
	prefab.transform.localScale = Vector3.one
	if type == "zdks" or type == "yxks" then
		local ks1 = prefab.transform:Find("@KS"):GetComponent("Image")
		local ks2 = prefab.transform:Find("@KS (1)"):GetComponent("Image")
		if type == "zdks" then
			ks1.sprite = GetTexture("dld_imgf_zdks")
			ks2.sprite = GetTexture("dld_imgf_zdks")
		elseif type == "yxks" then
			ks1.sprite = GetTexture("dld_imgf_yxks")
			ks2.sprite = GetTexture("dld_imgf_yxks")
		end
		ks1:SetNativeSize()
		ks2:SetNativeSize()
	end

	if type == "blzdks" then
		local ks1 = prefab.transform:Find("zi"):GetComponent("Image")
		if data == 2 then
			ks1.sprite = GetTexture("dld_imgf_blzdks")
		elseif data == 3 then
			ks1.sprite = GetTexture("dld_imgf_blzdks2")
		elseif data == 4 then
			ks1.sprite = GetTexture("dld_imgf_blzdks1")
		end
		ks1:SetNativeSize()
	end

	local seq = DoTweenSequence.Create()
	seq:AppendInterval(1)
	seq:OnKill(function ()
		if call then
			call()
		end
	end)
	seq:OnForceKill(function ()
		destroy(prefab)
	end)
end

-- 金币飞行
function A.CreateGold(parent, beginPos, endPos, delay, call, prefab_name)
	local prefab = CachePrefabManager.Take(prefab_name)
	prefab.prefab:SetParent(parent)
	local tran = prefab.prefab.prefabObj.transform
	tran.localScale = Vector3.New(0.5, 0.5, 0)
	tran.position = beginPos

	local seq = DoTweenSequence.Create()
	if delay and delay > 0.00001 then		
		seq:AppendInterval(delay)
	end
	local len = math.sqrt( (beginPos.x - endPos.x) * (beginPos.x - endPos.x) + (beginPos.y - endPos.y) * (beginPos.y - endPos.y) )
	local HH = 35
	local t = len / 1200
	local h = math.random(100, 200)
	seq:Append(tran:DOMove(Vector3.New(beginPos.x, beginPos.y + HH, 0), 0.25))
	seq:Append(tran:DOMove(Vector3.New(beginPos.x, beginPos.y, 0), 0.2))
	seq:Append(tran:DOMove(Vector3.New(beginPos.x, beginPos.y + HH*0.7, 0), 0.2))
	seq:Append(tran:DOMove(Vector3.New(beginPos.x, beginPos.y, 0), 0.2))
	seq:AppendInterval(0.2)
	seq:Append(tran:DOMoveBezier(endPos, h, t))
	seq:OnKill(function ()
		if call then
			call()
		end
	end)
	seq:OnForceKill(function ()
		if prefab then
			CachePrefabManager.Back(prefab)
		end
	end)
end
-- 金币飞行
function A.CreateGold2(parent, beginPos, endPos, delay, call, prefab_name)
	local prefab = CachePrefabManager.Take(prefab_name)
	prefab.prefab:SetParent(parent)
	local tran = prefab.prefab.prefabObj.transform
	tran.localScale = Vector3.New(0.5, 0.5, 0)
	tran.position = beginPos

	local seq = DoTweenSequence.Create()
	if delay and delay > 0.00001 then		
		seq:AppendInterval(delay)
	end
	local len = math.sqrt( (beginPos.x - endPos.x) * (beginPos.x - endPos.x) + (beginPos.y - endPos.y) * (beginPos.y - endPos.y) )
	local HH = 35
	local t = len / 1200
	local h = math.random(100, 200)
	seq:Append(tran:DOMoveBezier(endPos, h, t))
	seq:OnKill(function ()
		if call then
			call()
		end
	end)
	seq:OnForceKill(function ()
		if prefab then
			CachePrefabManager.Back(prefab)
		end
	end)
end
-- 金币数字
function A.PlayGoldText(parent, beginPos, endPos, delay, fx_name, desc)
	local prefab = CachePrefabManager.Take(fx_name)
	prefab.prefab:SetParent(parent)
	local tran = prefab.prefab.prefabObj.transform
	tran.position = beginPos
	local ui = {}
	LuaHelper.GeneratingVar(tran, ui)
	ui.gold_txt.text = desc or "-0"

	local seq = DoTweenSequence.Create()
	if delay and delay > 0.00001 then
		seq:AppendInterval(delay)
	end
	seq:Append(tran:DOMove(endPos, 1):SetEase(DG.Tweening.Ease.InQuint))
	seq:AppendInterval(0.5)
	seq:OnForceKill(function ()
		CachePrefabManager.Back(prefab)
	end)
end
-- 播放金币动画
function A.PlayGold(data, parent, beginPos, endPos, delta_t)
	local num = 6

	local _num = 0
	local _call = function ()
		_num = _num + 1
		if _num == 1 then
			
		end
		if _num == num then
			Event.Brocast("ui_gold_fly_finish_msg", data)
			A.PlayGoldText(parent, endPos, Vector3.New(endPos.x, endPos.y + 100, endPos.z), nil, "lhd_gold_text", data.desc)
		end
	end

	local t = 0.08
	local prefab_name = "ComFlyGlodPrefab"
	if not CachePrefabManager.IsBeCache(prefab_name, num) then
		num = 1
	end

	if num == 1 then
		A.CreateGold(parent, beginPos, endPos, nil, _call, prefab_name)
	elseif num <= 6 then
		local t = 0.08
		for i = 1, num do
			local pos = Vector3.New(beginPos.x + 80 * (i-num/2), beginPos.y, beginPos.z)
			A.CreateGold(parent, pos, endPos, t * (i-1), _call, prefab_name)
		end
	else
		local t = 0.08
		for i = 1, num do
			local x = beginPos.x + math.random(0, 200) - 100
			local y = beginPos.y + math.random(0, 200) - 100

			local pos = Vector3.New(x, y, beginPos.z)
			A.CreateGold(parent, pos, endPos, t * (i-1), _call, prefab_name)
		end
	end
end
-- 倍数变化效果
function A.PlayBSAnim(data, parent, beginPos, delta_t)
	local prefab = GameObject.Instantiate(GetPrefab("@_LHD_beishu"), parent).gameObject
	prefab.transform.position = beginPos
	prefab.transform.localScale = Vector3.one
	local img = prefab.transform:Find("Image"):GetComponent("Image")
	img.sprite = GetTexture("dld_imgf_2b1")
	img:SetNativeSize()

	local seq = DoTweenSequence.Create()
	if delta_t and delta_t > 0.00001 then
		seq:AppendInterval(delay)
	end
	seq:AppendInterval(1)
	seq:OnForceKill(function ()
		destroy(prefab)
	end)
end

-- 发牌 seat_num uipos pai
function A.PlayFP(data, parent, beginPos, endPos, delta_t)
	local prefab = GameObject.Instantiate(GetPrefab("lhd_card"), parent).gameObject
	local tran = prefab.transform
	tran.position = beginPos
	tran.localScale = Vector3.one
	tran.rotation = Quaternion:SetEuler(0, 0, 90*(data.uipos-1))

	local seq = DoTweenSequence.Create()
	if delta_t and delta_t > 0.00001 then
		seq:AppendInterval(delta_t)
	end
	seq:AppendCallback(function ()
		ExtendSoundManager.PlaySound(audio_config.dld.dld_fapai.audio_name)
	end)
	seq:Append(tran:DOMove(endPos, 0.2):SetEase(DG.Tweening.Ease.InQuint))
	seq:OnKill(function ()
		Event.Brocast("ui_fp_anim_finish_msg", data)
	end)
	seq:OnForceKill(function ()
		destroy(prefab)
	end)
end

-- 发蛋
function A.PlayFD(tran, endPos, delta_t)
	local seq = DoTweenSequence.Create()
	if delta_t and delta_t > 0.00001 then
		seq:AppendInterval(delta_t)
	end
	seq:Append(tran:DOLocalMove(endPos, 0.2):SetEase(DG.Tweening.Ease.InQuint))
	seq:OnKill(function ()
		Event.Brocast("ui_fd_anim_finish_msg")
	end)
	seq:OnForceKill(function ()
		destroy(prefab)
	end)
end

-- 摸牌 飞行
function A.PlayMPFX(data, parent, beginPos, endPos, call)
	local prefab = LHDCardPrefab.Create(parent, data.pai)
	local tran = prefab.transform
	tran.position = Vector3.zero
	tran.localScale = Vector3.zero

	local seq = DoTweenSequence.Create()
	if delta_t and delta_t > 0.00001 then
		seq:AppendInterval(delta_t)
	end

	seq:Append(tran:DOScale(2, 0.3))
	seq:AppendInterval(0.5)
	seq:Append(tran:DOMove(endPos, 0.2):SetEase(DG.Tweening.Ease.InQuint))
	seq:Join(tran:DOScale(1, 0.2):SetEase(DG.Tweening.Ease.InQuint))
	seq:OnKill(function ()
		if call then
			call()
		end
	end)
	seq:OnForceKill(function ()
		prefab:OnDestroy()
	end)
end
-- 摸牌动画
function A.PlayMP(data, parent, beginPos, endPos, call)
	local seq = DoTweenSequence.Create()
	seq:AppendInterval(1)
	seq:OnKill(function ()
		ExtendSoundManager.PlaySound(audio_config.dld.gift_poker.audio_name)
		A.PlayMPFX(data, parent, beginPos, endPos, call)
	end)
end
-- 摸牌倍率变化提示
function A.PlayMPRateChange(data, parent, delta_t)
	local beginPos = Vector3.New(0, 60, 0)
	local endPos = Vector3.New(beginPos.x, beginPos.y + 140, beginPos.z)

	local prefab = GameObject.Instantiate(GetPrefab("mp_rate_prefab"), parent).gameObject
	local tran = prefab.transform
	tran.localPosition = beginPos
	tran.localScale = Vector3.one
	tran.gameObject:SetActive(false)
	local txt = prefab.transform:Find("Text"):GetComponent("Text")
	txt.text = data.rate .. "倍"
	local seq = DoTweenSequence.Create()
	if delta_t and delta_t > 0.00001 then
		seq:AppendInterval(delta_t)
		seq:AppendCallback(function ()
			tran.gameObject:SetActive(true)
		end)
	else
		tran.gameObject:SetActive(true)
	end
	seq:Append(tran:DOLocalMove(endPos, 1.5):SetEase(DG.Tweening.Ease.InQuint))
	seq:OnForceKill(function ()
		destroy(prefab)
	end)
end

-- 砸蛋动画
function A.PlayZDAnim(parent, fx_name, beginPos, keepTime, no_take, call)
	A.PlayShowAndHideFX(parent, fx_name, beginPos, keepTime, no_take, call)
end

-- 出战动画
-- data {[1]={ui_pos seat_num is_win beginPos} }
local cz_endPos = {Vector3.New(0, -100, 0), Vector3.New(245, 0, 0), Vector3.New(0, 100, 0), Vector3.New(-245, 0, 0)}
local cz_beginPos = {Vector3.New(84, -310, 0), Vector3.New(740, -30, 0), Vector3.New(124, 345, 0), Vector3.New(-758, -30, 0)}
function A.PlayCZAnim(data, parent)
	--LHDGame_heji
	local all_num = #data
	local num1 = 0
	for k,v in ipairs(data) do
		--cz_beginPos[v.ui_pos]
		A.PlayShowAndHideFX(parent, "LHD_hepai", v.beginPos, 0.5, true)
		local seq = DoTweenSequence.Create()
		seq:AppendInterval(0.2)
		seq:OnKill(function ()
			A.PlayCWAnim(v, parent, v.beginPos, cz_endPos[v.ui_pos], 1.5, function ()
				num1 = num1 + 1
				if num1 == all_num then
					num1 = 0
					A.PlayShowAndHideFX(parent, "LHD_pengzhuang", Vector3.zero, 0.5, true)
					for k,v in ipairs(data) do
						local cw = "LHD_sl_s" .. v.ui_pos
						if not v.is_win then
							cw = "LHS_s" .. v.ui_pos .. "_posui"
						else
							cw = "LHD_sl_s" .. v.ui_pos
						end
						A.PlayShowAndHideFX(parent, cw, cz_endPos[v.ui_pos], 3, true, function ()
							num1 = num1 + 1
							if num1 == all_num then
								print("<color=red>碰撞完成</color>")
								Event.Brocast("ui_combat_finish_msg")
							end
						end)
					end

					local seq1 = DoTweenSequence.Create()
					seq1:AppendInterval(0.8)
					seq1:OnKill(function ()
						print("<color=red>比牌完成</color>")
						Event.Brocast("ui_begin_fly_gold_msg")
					end)

				end
			end)
		end)
	end
end
-- 出战宠物
function A.PlayCWAnim(data, parent, beginPos, endPos, delta_t, call)
	local xl_px = 0
	local xl_py = 0
	if data.ui_pos == 1 then
		xl_py = -40
	elseif data.ui_pos == 2 then
		xl_px = 40
	elseif data.ui_pos == 3 then
		xl_py = 40
	else
		xl_px = -40
	end
	local cw = "LHD_sl_s" .. data.ui_pos
	local prefab = GameObject.Instantiate(GetPrefab(cw), parent).gameObject
	local tran = prefab.transform
	tran.position = beginPos
	tran.localScale = Vector3.one
	tran.gameObject:SetActive(true)

	local seq = DoTweenSequence.Create()
	if delta_t and delta_t > 0.00001 then
		seq:AppendInterval(delta_t)
	end
	local py = Vector3.New(beginPos.x + xl_px, beginPos.y + xl_py, beginPos.z)
	seq:Append(tran:DOMove(py, 0.1))
	seq:Append(tran:DOMove(endPos, 0.3):SetEase(DG.Tweening.Ease.InOutElastic))
	seq:OnKill(function ()
		if call then
			call()
			call = nil
		end
	end)
	seq:OnForceKill(function ()
		destroy(prefab)
	end)
end
function A.PlayNewCZAnim(data, parent, delta_t)
	local call = function()
		local all_num = #data
		local num1 = 0
		
		local obj = GameObject.Instantiate(GetPrefab("LHDGame_heji"), parent).gameObject
		local tran = obj.transform
		local pai_list = {}
		pai_list[#pai_list + 1] = tran:Find("xia/LHD_hepai/pai"):GetComponent("Image")
		pai_list[#pai_list + 1] = tran:Find("you/LHD_hepai/pai"):GetComponent("Image")
		pai_list[#pai_list + 1] = tran:Find("shang/LHD_hepai/pai"):GetComponent("Image")
		pai_list[#pai_list + 1] = tran:Find("zuo/LHD_hepai/pai"):GetComponent("Image")
		local ss_node = {}
		ss_node[#ss_node + 1] = tran:Find("xia")
		ss_node[#ss_node + 1] = tran:Find("you")
		ss_node[#ss_node + 1] = tran:Find("shang")
		ss_node[#ss_node + 1] = tran:Find("zuo")

		for k, v in ipairs(pai_list) do
			v.sprite = GetTexture("LHD_s" .. k)
		end
		for k, v in ipairs(ss_node) do
			v.gameObject:SetActive(false)
		end
		for k,v in ipairs(data) do
			ss_node[v.ui_pos].gameObject:SetActive(true)
		end

		local seq = DoTweenSequence.Create()
		seq:AppendInterval(1.5)
		seq:OnKill(function ()
			destroy(obj)
			for k,v in ipairs(data) do
				local cw = "LHD_sl_s" .. v.ui_pos
				if not v.is_win then
					cw = "LHS_s" .. v.ui_pos .. "_posui"
				else
					cw = "LHD_sl_s" .. v.ui_pos
				end
				local pos = ss_node[v.ui_pos].transform.position
				A.PlayShowAndHideFX(parent, cw, pos, 2.3, true, function ()
					num1 = num1 + 1
					if num1 == all_num then
						print("<color=red>碰撞完成</color>")
						Event.Brocast("ui_combat_finish_msg")
					end
				end)
			end
		end)
	end

	if delta_t and delta_t > 0.00001 then
		local seq1 = DoTweenSequence.Create()
		seq1:AppendInterval(delta_t)
		seq1:OnKill(function()
			call()
		end)
	else
		call()
	end
end

-- 加倍动画
function A.PlayJBAnim(parent, endPos, beishu, call)
	local prefab = GameObject.Instantiate(GetPrefab("LHD_jb"), parent).gameObject
	prefab.transform.position = Vector3.zero
	prefab.transform.localScale = Vector3.one
	local tran = prefab.transform
	local ui = {}
	LuaHelper.GeneratingVar(prefab.transform, ui)
	ui.beishu_txt.text = beishu
	local seq = DoTweenSequence.Create()
	seq:AppendInterval(1)
	seq:Append(tran:DOMove(endPos, 0.4):SetEase(DG.Tweening.Ease.InQuint))
	seq:Join(tran:DOScale(0.5, 0.4):SetEase(DG.Tweening.Ease.InQuint))
	seq:OnKill(function ()
		if call then
			call()
		end
	end)
	seq:OnForceKill(function ()
		destroy(prefab)
	end)
end

-- 播放金币动画
function A.PlayJSGoldAnim(data, parent, beginPos, endPos, delta_t)
	local num = 6
	local prefab_name = "ComFlyGlodPrefab"

	local _num = 0
	local _call = function ()
		_num = _num + 1
		if _num == 1 then
			
		end
		if _num == num then
			A.PlayGoldText(parent, endPos, Vector3.New(endPos.x, endPos.y + 100, endPos.z), nil, "lhd_gold_text", data.desc)
			local seq = DoTweenSequence.Create()
			seq:AppendInterval(0.5)
			seq:OnKill(function ()
				Event.Brocast("ui_gold_fly_finish_msg", data)
			end)
		end
	end
	local t = 0.08
	for i = 1, num do
		A.CreateGold2(parent, beginPos, endPos, t * (i-1), _call, prefab_name)
	end
end
-- 牌型动画
function A.PlayPXAnim(data, parent, delta_t)

	local call = function ()
		local cfg = LHDManager.PAI_STYLE[data]
		local prefab = GameObject.Instantiate(GetPrefab(cfg.fx), parent).gameObject
		prefab.transform.localPosition = Vector3.zero
		prefab.transform.localScale = Vector3.one
		local seq = DoTweenSequence.Create()
		seq:AppendInterval(cfg.fx_t)
		seq:OnKill(function ()
			destroy(prefab)
		end)
	end

	if delta_t and delta_t > 0.00001 then
		local seq1 = DoTweenSequence.Create()
		seq1:AppendInterval(delta_t)
		seq1:OnKill(function()
			call()
		end)
	else
		call()
	end
end
-- 砸一锤 出战 钱变化时的特效
function A.PlayQBHAnim(data, parent, delta_t)
	local call = function ()
		A.PlayShowAndHideFX(parent, "LHDGame_kuang", parent.position, 0.5, true, function ()
			local prefab = GameObject.Instantiate(GetPrefab("lhd_za_cz_bh"), parent).gameObject
			prefab.transform.localPosition = Vector3.New(100, 60, 0)
			prefab.transform.localScale = Vector3.one
			prefab.transform:Find("Text"):GetComponent("Text").text = "+" .. StringHelper.ToCash(data)

			local seq = DoTweenSequence.Create()
			seq:Append(prefab.transform:DOLocalMove(Vector3.New(100, 160, 0), 0.5):SetEase(DG.Tweening.Ease.InQuint))
			seq:OnKill(function ()
				destroy(prefab)
			end)
		end)
	end

	if delta_t and delta_t > 0.00001 then
		local seq1 = DoTweenSequence.Create()
		seq1:AppendInterval(delta_t)
		seq1:OnKill(function()
			call()
		end)
	else
		call()
	end
end
