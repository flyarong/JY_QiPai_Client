MJParticleManager = {}
local M = MJParticleManager

function ParticleSystemLength(particleSystems)
   
    local maxDuration = 0;

    for k,ps in pairs(particleSystems) do
        if ps.emission then
            if ps.loop then
                return -1;
            end
            local dunration = 0;
            if ps.emissionRate <=0 then
                dunration = ps.startDelay + ps.startLifetime;
            else
                dunration = ps.startDelay + Mathf.Max(ps.duration,ps.startLifetime);
            end
            if dunration > maxDuration then
                maxDuration = dunration
            end
        end
    end
    return maxDuration
end

function M.Play(particleSystems)
    for k,ps in pairs(particleSystems) do
        ps:Play()
    end
end

function M.MJFanPai(pos , parentPar)
	local parent = parentPar or GameObject.Find("Canvas/LayerLv2").transform
	local particle = newObject("ParticleMJFanPai", parent.transform)
    particle.transform.position = pos

    local seq = DG.Tweening.DOTween.Sequence()
    local tweenKey = DOTweenManager.AddTweenToStop(seq)
    seq:AppendInterval(3)
    seq:OnKill(function ()
        DOTweenManager.RemoveStopTween(tweenKey)
        GameObject.Destroy(particle)
    end)
end

function M.MJKaiJu(callback)
    ExtendSoundManager.PlaySound(audio_config.mj.sod_majiang_gamestart.audio_name)
	local parent = GameObject.Find("Canvas/LayerLv2")
	local particle = newObject("ParticleMJKaiJu", parent.transform)
	particle.transform.position = Vector3.zero
    particle.transform.localPosition = Vector3.zero

    local seq = DG.Tweening.DOTween.Sequence()
    local tweenKey = DOTweenManager.AddTweenToStop(seq)
    seq:AppendInterval(2)
    seq:OnComplete(function ()
        if callback then
            callback()
        end
    end)
    seq:OnKill(function ()
        DOTweenManager.RemoveStopTween(tweenKey)
        GameObject.Destroy(particle)
    end)
end

function M.MJDQSwitchCreate(parent)
	local particle = newObject("ParticleMJDQSwitch", parent)
    particle.transform.localPosition = Vector3.zero
    return particle
end

function M.MJDQIcon(pos)
	local parent = GameObject.Find("Canvas/LayerLv2")
	local particle = newObject("ParticleMJDQIcon", parent.transform)
    particle.transform.position = pos

    local seq = DG.Tweening.DOTween.Sequence()
    local tweenKey = DOTweenManager.AddTweenToStop(seq)
    seq:AppendInterval(3)
    seq:OnKill(function ()
        DOTweenManager.RemoveStopTween(tweenKey)
        GameObject.Destroy(particle)
    end)
end

function M.MJMoPai(parent)
	local particle = newObject("ParticleMJMoPai", parent.transform)
    particle.transform.localPosition = Vector3.zero

    local seq = DG.Tweening.DOTween.Sequence()
    local tweenKey = DOTweenManager.AddTweenToStop(seq)
    seq:AppendInterval(3)
    seq:OnKill(function ()
        DOTweenManager.RemoveStopTween(tweenKey)
        GameObject.Destroy(particle)
    end)
end

local PGH_TABLE = {
	[1] = Vector3.New(0,-200,0),
	[2] = Vector3.New(500,0,0),
	[3] = Vector3.New(0,200,0),
	[4] = Vector3.New(-500,0,0)
}
function M.MJPGH(p,mjType)
    local parent = GameObject.Find("Canvas/LayerLv2")
    local parStr = ""
    local childStr = ""
    if mjType == MjCard.PaiType.hp then
        parStr = "ParticleMJHintHu"
        childStr = "hu/zi"
	elseif mjType == MjCard.PaiType.zg or mjType == MjCard.PaiType.wg or mjType == MjCard.PaiType.ag then
        parStr = "ParticleMJHintGane"
        childStr = "gang/zi"
	elseif mjType == MjCard.PaiType.pp then
        parStr = "ParticleMJHintPeng"
        childStr = "peng/zi"
	end
    local particle = newObject(parStr, parent.transform)
    particle.transform.localPosition = Vector3.zero
    particle.transform.localScale = Vector3.New(12.5,12.5,12.5)     --- 先放大一点

    local seq_move = particle.transform:DOMove(PGH_TABLE[p],0.5):SetEase (DG.Tweening.Ease.Linear)
    local seq_scale = particle.transform:Find(childStr):DOScale(0.7,0.5):SetEase (DG.Tweening.Ease.Linear)

    local seq = DG.Tweening.DOTween.Sequence()
    local tweenKey = DOTweenManager.AddTweenToStop(seq)
    seq:AppendInterval(1):Append(seq_move):Join(seq_scale):AppendInterval(1.5)
    seq:OnKill(function ()
        DOTweenManager.RemoveStopTween(tweenKey)
        GameObject.Destroy(particle)
    end)
end

function M.MJHuPaiAni(p,callback)
    local parent = GameObject.Find("Canvas/LayerLv2")
    local particle = newObject("ParticleMJHintHu", parent.transform)
    
    particle.transform.localPosition = Vector3.zero

    local seq_move = particle.transform:DOMove(PGH_TABLE[p],0.5):SetEase (DG.Tweening.Ease.Linear)
    local seq_scale = particle.transform:Find("hu/zi"):DOScale(0.5,0.5):SetEase (DG.Tweening.Ease.Linear)

    local seq = DG.Tweening.DOTween.Sequence()
    local tweenKey = DOTweenManager.AddTweenToStop(seq)
    seq:AppendInterval(1):Append(seq_move):Join(seq_scale):AppendInterval(1.5)
    seq:OnKill(function ()
        DOTweenManager.RemoveStopTween(tweenKey)
        GameObject.Destroy(particle)
        if callback then
            callback()
        end
    end)
end

local HUPAI_TABLE = {
	[1] = Vector3.New(0,-145,0),
	[2] = Vector3.New(-600,150,0),
	[3] = Vector3.New(0,400,0),
	[4] = Vector3.New(630,150,0)
}
function M.MJHuPai(p, huType, huIdx, huPai,parent)
    -- local parent = GameObject.Find("Canvas/LayerLv2")
    local parStr=""
	if huType == "zimo" then
        parStr = "ParticleMJZiMo_"..huIdx
    elseif huType == "pochan" then
        parStr = "PoChanIcon"
	else
		parStr = "ParticleMJHu_"..huIdx
    end
	local particle = newObject(parStr, parent.transform)
    particle.transform.localPosition = HUPAI_TABLE[p]

	return particle
end

local  GANG_TABLE = {
	[1] = Vector3.New(0,160,0),
	[2] = Vector3.New(520,440,0),
	[3] = Vector3.New(0,450,0),
	[4] = Vector3.New(-520,440,0)
}

local  GANG_GuaFeng_TABLE = {
	[1] = Vector3.New(0,0,0),
	[2] = Vector3.New(550,20,0),
	[3] = Vector3.New(0,170,0),
	[4] = Vector3.New(-550,20,0)
}

function M.MJLJF()
    ExtendSoundManager.PlaySound(audio_config.mj.sod_majiang_wind.audio_name)
    local parent = GameObject.Find("Canvas/LayerLv2")
	local particle = newObject("ParticleMJG_GF", parent.transform)
    particle.transform.localPosition = Vector3.New(-500,0,0)

    local seq = particle.transform:DOMove(Vector3.New(500,0,0),2)
    local tweenKey = DOTweenManager.AddTweenToStop(seq)
    seq:OnKill(function()
        DOTweenManager.RemoveStopTween(tweenKey)
        GameObject.Destroy(particle)
    end)
	return particle
end

function M.MJLJFOther(p)
    ExtendSoundManager.PlaySound(audio_config.mj.sod_majiang_wind.audio_name)
    local parent = GameObject.Find("Canvas/LayerLv2")
	local particle = newObject("ParticleMJG_GF", parent.transform)
    particle.transform.localPosition = GANG_GuaFeng_TABLE[p]

    local seq = DG.Tweening.DOTween.Sequence()
    local tweenKey = DOTweenManager.AddTweenToStop(seq)
    seq:AppendInterval(2)
    seq:OnKill(function ()
        DOTweenManager.RemoveStopTween(tweenKey)
        GameObject.Destroy(particle)
    end)
end

function M.MJXY(p)
    ExtendSoundManager.PlaySound(audio_config.mj.sod_majiang_Rain.audio_name)
    local parent = GameObject.Find("Canvas/LayerLv2")
    local particle = newObject("ParticleMJG_XY", parent.transform)
    particle.transform.localPosition = GANG_TABLE[p]

    local seq = DG.Tweening.DOTween.Sequence()
    local tweenKey = DOTweenManager.AddTweenToStop(seq)
    seq:AppendInterval(2)
    seq:OnKill(function ()
        DOTweenManager.RemoveStopTween(tweenKey)
        GameObject.Destroy(particle)
    end)
end

function M.JieSuanLose(parent)
	local particle = newObject("ParticleJieSuanLose", parent.transform)
    particle.transform.localPosition = Vector3.zero
	return particle
end

function M.JieSuanWin(parent)
	local particle = newObject("ParticleJieSuanWin", parent.transform)
    particle.transform.localPosition = Vector3.zero
	return particle
end

function M.PlayNormal(particleName, soundName, interval, callback, parent)
	if not parent then
		parent = GameObject.Find("Canvas/LayerLv2")
	end

	local particle = newObject(particleName, parent.transform)
	if not particle then
		print("[PARTICLE] PlayNormal failed. particle is nil:" .. particleName)
		return
	end

	particle.transform.position = Vector3.zero
	particle.transform.localPosition = Vector3.zero

	if interval > 0 then
		local seq = DG.Tweening.DOTween.Sequence()
		local tweenKey = DOTweenManager.AddTweenToStop(seq)
		seq:AppendInterval(interval)
		seq:OnKill(function ()
			if callback then
				callback()
			end

			DOTweenManager.RemoveStopTween(tweenKey)

			if IsEquals(particle) then
				GameObject.Destroy(particle)
			end
		end)
	end

	if soundName then
		ExtendSoundManager.PlaySound(soundName)
	end

	return particle
end
