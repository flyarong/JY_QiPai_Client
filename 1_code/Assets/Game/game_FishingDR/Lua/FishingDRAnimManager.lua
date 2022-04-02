-- 创建时间:2019-03-19
FishingDRAnimManager = {}
local function FlyingToTarget(node, targetPoint, targetScale, interval, callback, forcecallback, delay)
	if not IsEquals(node) then
		if callback then callback() end
		return
	end

	local seq = DoTweenSequence.Create()
	delay = delay or 0
	if delay > 0 then		
		seq:AppendInterval(delay)
	end

	seq:Append(node.transform:DOMoveBezier(targetPoint, 300, interval))

	targetScale = targetScale or 1
	if targetScale ~= 1 then
		seq:Join(node.transform:DOScale(targetScale, interval))
	end

	seq:OnKill(function ()
		if callback then callback() end
	end)
	seq:OnForceKill(function ()
		if forcecallback then
			forcecallback()
		end
	end)
end

function FishingDRAnimManager.PlayLinesFX(parent, data, speedTime, keepTime, lineName, pointName)
	local pointCount = #data
	if pointCount <= 0 then
		print(string.format("[ErrorFX]: PlayLinesFX(%s) failed pointCount is empty", lineName))
		return
	end

	ExtendSoundManager.PlaySound(audio_config.by_dr.bgm_by_shandianyu_game_fishingdr.audio_name)

	speedTime = speedTime or 1
	keepTime = keepTime or 1
	lineName = lineName or "electricLine_game_fishingdr"
	pointName = pointName or "electricPoint_game_fishingdr"

	local lineTmpl = GetPrefab(lineName)
	if not lineTmpl then
		print(string.format("[ErrorFX]: PlayLinesFX(%s) failed lineTmpl is nil", lineName))
		return
	end
	local lineObject = GameObject.Instantiate(lineTmpl, parent)
	if not lineObject then
		print(string.format("[ErrorFX]: PlayLinesFX(%s) failed lineObject is nil", lineName))
		return
	end
	local lineRenderer = lineObject.transform:GetComponent("LineRenderer");
	if not lineRenderer then
		print(string.format("[ErrorFX]: PlayLinesFX(%s) failed lineRenderer is nil", lineName))
		return
	end

	local pointObjects = {}
	lineRenderer.positionCount = pointCount

	local function setLinePoint(index, position)
		if IsEquals(lineRenderer) then
			for idx = index, pointCount do
				lineRenderer:SetPosition(idx - 1, position)
			end
		end
	end

	local function clearAll()
		dump(pointObjects)
		for _, v in pairs(pointObjects) do
			CachePrefabManager.Back(v)
		end
		pointObjects = {}
		if IsEquals(lineObject) then
			GameObject.Destroy(lineObject.gameObject)
			lineObject = nil
		end
		lineTmpl = nil
	end

	local function getPos(idx)
		return data[idx]
	end

	local function reach(idx)
		local position = getPos(idx)
		local prefab = FishingDRAnimManager.PlayNormal(pointName, nil, 0, nil, parent)
		if prefab then
			prefab.prefab.prefabObj.transform.position = position
			pointObjects[#pointObjects + 1] = prefab
		end
		setLinePoint(idx, position)
	end

	local function playLine(begin_idx, end_idx, peroid, callback)
		local beginPoint = getPos(begin_idx)
		local endPoint = getPos(end_idx)
		local called = false

		setLinePoint(begin_idx, beginPoint)

		local vec3 = Vector3.New(endPoint.x - beginPoint.x, endPoint.y - beginPoint.y, endPoint.z - beginPoint.z)
		local dist = math.max(0.05, Vector3.Magnitude(vec3))
		local speed = dist / (peroid * 60)
		local total = 0
		FishingDRAnimManager.TweenDelay(peroid, function()
			if called then return end
			
			total = total + speed
			factor = Mathf.Clamp(total / dist, 0, 1)
			setLinePoint(end_idx, Vector3.Lerp(beginPoint, getPos(end_idx), factor))

			if factor >= 1 then
				called = true
				if callback then callback(begin_idx, end_idx) end
			end
		end, function()
			if called then return end

			setLinePoint(end_idx, getPos(end_idx))
			if callback then callback(begin_idx, end_idx) end
		end, function (force_kill)
			if force_kill then
				clearAll()
			end
		end)
	end

	local recursion
	recursion = function(idx)
		local next_idx = idx + 1
		if next_idx > pointCount then
			FishingDRAnimManager.TweenDelay(keepTime, nil, nil, function()
				clearAll()
			end)
		else
			playLine(idx, next_idx, speedTime, function(begin_idx, end_idx)
				reach(end_idx)
				recursion(end_idx)
			end)
		end
	end
	
	reach(1)
	recursion(1)
end

function FishingDRAnimManager.PlayLinesFX_FS(parent, fs_pos, data, speedTime, keepTime, lineName, pointName)
	FishingDRAnimManager.PlayShowAndHideFX(parent, "by_qpsd_fkby", fs_pos, 2)
	local pos_list = {}
	for k,v in ipairs(data) do
		local pp = v - fs_pos
		local r = Vec2DAngle(Vec2DNormalize({x = pp.x, y = pp.y}))
		local j = math.floor(r / 30)
		if not pos_list[j+1] then
			pos_list[j+1] = {fs_pos}
		end
		pos_list[j+1][#pos_list[j+1] + 1] = v
	end
	local len_list = {}
	for k,v in pairs(pos_list) do
		len_list[k] = {}
		for k1,v1 in ipairs(v) do
			local cha = fs_pos - v1
			local len = Vec2DLength({x=cha.x, y=cha.y})
			local dd = {}
			dd.len = len
			dd.pos = v1
			len_list[k][#len_list[k] + 1] = dd
		end
	end
	
	--  排序
	for k,v in pairs(len_list) do
		MathExtend.SortList(v, "len", true)
	end
	pos_list = {}
	for k,v in pairs(len_list) do
		pos_list[k] = {}
		for k1, v1 in ipairs(v) do
			pos_list[k][#pos_list[k] + 1] = v1.pos
		end
	end

	for k,v in pairs(pos_list) do
		if #v > 0 then
			FishingDRAnimManager.PlayLinesFX(parent, v, speedTime, keepTime, lineName, pointName, true)
		end
	end
end

-- 捕鱼赛跑激光
function FishingDRAnimManager.PlayDRLaser(parent,seat_num,beginPos)
	local prefab = CachePrefabManager.Take("by_jiguang")
	prefab.prefab:SetParent(parent)
	local obj = prefab.prefab.prefabObj
	local tran = obj.transform
	tran.rotation = Quaternion.Euler(0, 0, 0)
	tran.position = beginPos
	dump(beginPos,"---------------")
	tran.localScale=Vector3.New(1,1,1)
	local seq = DoTweenSequence.Create()
	seq:AppendInterval(2.5)
	seq:OnKill(function ()
		Event.Brocast("ui_play_DRlaser_finish_msg", seat_num)
	end)
	seq:OnForceKill(function ()
		CachePrefabManager.Back(prefab)		
	end)
end

-- 一个固定位置的特效 显示一段时间消失
function FishingDRAnimManager.PlayShowAndHideFX(parent, fx_name, beginPos, keepTime)
	local prefab
	prefab = CachePrefabManager.Take(fx_name)
	prefab.prefab:SetParent(parent)
	if not prefab.prefab.prefabObj then return end
	local tran = prefab.prefab.prefabObj.transform
	tran.position = beginPos
	tran.localScale = Vector3.one
  
	local seq = DoTweenSequence.Create()
	seq:AppendInterval(keepTime)
	seq:OnForceKill(function ()
	  if no_take then
		destroy(prefab)
	  else
		CachePrefabManager.Back(prefab)
	  end
	end)    
  end
  
  -- 前奏表现 放大缩小
  function FishingDRAnimManager.PlayDRFishDeadFX(parent, pos, fish_obj, call)
	local name = tonumber(fish_obj.gameObject.name)
	local seq = DoTweenSequence.Create()
	for i = 1, 6 do
	  seq:Append(fish_obj.transform:DOScale(Vector3.New(1.5, 1.5, 1.5), 0.05))
	  seq:Append(fish_obj.transform:DOScale(Vector3.New(1, 1, 1), 0.05))
	end
	seq:OnKill(function ()
	  if IsEquals(fish_obj) then
		if call then
			call()
			local prefab
		  	local seq1 = DoTweenSequence.Create()
			seq1:AppendInterval(0.5)
			seq1:AppendCallback(function(  )
				local offset ={
					-0.54,-0.6,-0.9,-0.6,-0.7,-1.74,-3.6
				}
				prefab = CachePrefabManager.Take("fishing_dr_dead")
				prefab.prefab:SetParent(parent)
				local obj = prefab.prefab.prefabObj
				local tran = obj.transform
				tran.position = Vector3.New(pos.x + offset[name],pos.y,pos.z)
			end)
			seq1:AppendInterval(0.5)
			seq1:OnForceKill(function ()
				CachePrefabManager.Back(prefab)
			  end)
		end
	  end
	end)
	seq:OnForceKill(function ()
	end)
  end

function FishingDRAnimManager.PlayComMove(target_tran, beginPos, endPos, moveTime, call)
	local tran = target_tran
	tran.position = beginPos
	moveTime = moveTime or 0.2
  
	local seq = DoTweenSequence.Create()
	seq:Append(tran:DOMove(endPos, moveTime):SetEase(DG.Tweening.Ease.InQuint))
	seq:OnKill(function ()
	  if call then
		call()
	  end
	end)
end

function FishingDRAnimManager.FlyItem(item, point, period, callback, delay, inverse)
	if not IsEquals(item) then return end

	local seq = DG.Tweening.DOTween.Sequence()
	local tweenKey = DOTweenManager.AddTweenToStop(seq)
	seq:OnKill(function ()
		DOTweenManager.RemoveStopTween(tweenKey)

		if IsEquals(item) then
			item.transform.localPosition = Vector3.zero
		end

		if callback then callback() end
	end)

	local h = math.random(100, 260)
	if inverse then
		seq:Append(item.transform:DOLocalMove(point, period):From())
	else
		seq:Append(item.transform:DOLocalMove(point, period))
	end

	delay = delay or 0
	if delay > 0 then
		seq:AppendInterval(delay):AppendCallback(function()
			--delay
		end)
	end
end

-- 播放获得额外道具表现(锁定 冰冻)
function FishingDRAnimManager.PlayToolSP(parent, seat_num, beginPos, endPos, attr, num, call, img,t1, t2 )
	--资源整理时的漏网之鱼
	if audio_config.by then
		ExtendSoundManager.PlaySound(audio_config.by.bgm_by_huodejineng.audio_name)
	end

	local prefab = CachePrefabManager.Take("fishingflytoolprefab_game_fishingdr")
	prefab.prefab:SetParent(parent)
	local obj = prefab.prefab.prefabObj
	if not obj then return end
	local tran = obj.transform
	local icon = tran:Find("Icon"):GetComponent("Image")
	tran.position = beginPos
	if img then
		icon.sprite = GetTexture(img)
	else
		if attr == FishingModel.FishDeadAppendType.LockCard then
			icon.sprite = GetTexture("by_btn_sd")
		elseif attr == FishingModel.FishDeadAppendType.IceCard then
			icon.sprite = GetTexture("by_btn_bd")
		end
	end
	t1 = t1 or 0.4
	t2 = t2 or 0.6
	FlyingToTarget(tran, endPos, 1, t1, function()
		if call then call(num) end
	end, function()
		CachePrefabManager.Back(prefab)
	end, t2)
end

function FishingDRAnimManager.PlayNormal(particleName, soundName, interval, callback, parent, pos)
	if not parent then
		parent = GameObject.Find("Canvas/LayerLv2")
	end

	local prefab = CachePrefabManager.Take(particleName)
    prefab.prefab:SetParent(parent.transform)
	local tran = prefab.prefab.prefabObj.transform

	if not prefab then
		print("[PARTICLE] PlayNormal failed. particle is nil:" .. particleName)
		return
	end

	if pos then
		tran.position = pos
	else
		tran.position = Vector3.zero
	end

	if interval > 0 then
		local seq = DoTweenSequence.Create()
		seq:AppendInterval(interval)
		seq:OnKill(function ()
			if callback then
				callback()
			end
		end)
		seq:OnForceKill(function ()
			CachePrefabManager.Back(prefab)			
		end)
	end

	if soundName then
		ExtendSoundManager.PlaySound(soundName)
	end

	return prefab
end

function FishingDRAnimManager.TweenDelay(period, update_callback, final_callback, force_callback)
	local seq = DoTweenSequence.Create()
	seq:AppendInterval(period):OnUpdate(function()
		if update_callback then update_callback() end
	end)
	seq:OnKill(function()
		if final_callback then final_callback() end
	end)
	seq:OnForceKill(function (force_kill)
		if force_callback then
			force_callback(force_kill)
		end
	end)
end