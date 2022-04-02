-- 创建时间:2020-08-27

LWZBAnimManager = {}
local M = LWZBAnimManager
--[[-- 激光
function M.PlayLinesFX(parent, beginPos, endPos, speedTime, keepTime, call)
	ExtendSoundManager.PlaySound(audio_config.by.bgm_by_shandianyu.audio_name)

	speedTime = speedTime or 1
	keepTime = keepTime or 1
	lineName = lineName or "LWZB_xuneng"
	pointName = pointName or "electricPoint"

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
	local lineRenderer = lineObject.transform:GetComponent("LineRenderer")
	if not lineRenderer then
		print(string.format("[ErrorFX]: PlayLinesFX(%s) failed lineRenderer is nil", lineName))
		return
	end

	local pointObjects = {}
	lineRenderer.positionCount = 2
	lineRenderer:SetPosition(0, beginPos)
	lineRenderer:SetPosition(1, endPos)

	local seq = DoTweenSequence.Create()
	seq:AppendInterval(keepTime)
	seq:OnKill(function ()
		if call then
			call()
		end
	end)
	seq:OnForceKill(function ()
		destroy(lineObject)
	end)
end--]]

-- 子弹
function M.PlayBullet(parent, beginPos, endPos, moveTime, call)
	local index = LWZBModel.GetCurRateIndex()
	local pre_name = "LWZBBullet"..index
	local obj = GameObject.Instantiate(GetPrefab(pre_name), parent)
	local tran = obj.transform
	tran.position = beginPos

    local p = endPos - beginPos
    local len = LWZBModel.Vec2DLength(p)
    p = p.normalized
    local r = LWZBModel.Vec2DAngle(p)
    tran.rotation = Quaternion.Euler(0, 0, r - 90)
    moveTime = len / 1600

	local seq = DoTweenSequence.Create()
	seq:Append(tran:DOMove(endPos, moveTime):SetEase(DG.Tweening.Ease.Linear))
	seq:OnKill(function ()
		if call then
			call()
		end
	end)
	seq:OnForceKill(function ()
		destroy(obj)
	end)
end

-- 激光
function M.PlayLinesFX(parent, keepTime,index,call)
	ExtendSoundManager.PlaySound(audio_config.lwzb.bgm_by_shandianyu_game_lwzb.audio_name)
	local pos
	local scale 
	if index == 1 then
		pos = Vector3.New(0,800,0)
		scale = Vector3.New(1,1.4,1)
	elseif index == 2 then
		pos = Vector3.New(-10,430,0)
		scale = Vector3.New(1,0.6,1)
	elseif index == 3 then
		pos = Vector3.New(-10,430,0)
		scale = Vector3.New(1,0.6,1)
	elseif index == 4 then
		pos = Vector3.New(0,800,0)
		scale = Vector3.New(1,1.4,1)
	end
	local obj = GameObject.Instantiate(GetPrefab("LWZB_xuneng"), parent)
	local tran = obj.transform
	tran.localPosition = pos
	tran.localScale = scale
	tran.localRotation = Vector3.New(0,0,0)
	local seq = DoTweenSequence.Create()
	seq:AppendInterval(keepTime)
	seq:OnKill(function ()
		if call then
			call()
		end
	end)
	seq:OnForceKill(function ()
		destroy(obj)
	end)
end