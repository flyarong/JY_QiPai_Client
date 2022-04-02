DDZParticleManager = {}
local M = DDZParticleManager
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

--斗地主特效---------------------------------

function M.DDZShunZi(parent)
	return M.DDZFly("ShunZi_AnimPrefab",parent)
end

function M.DDZLianDui(parent)
	return M.DDZFly("LianDui_AnimPrefab",parent)
end

function M.DDZFeiJi(parent)
	return M.DDZFly("FeiJi_AnimPrefab",parent)
end

function M.DDZFly(obj_name,parent)
	local particle = newObject(obj_name, parent.transform)
    particle.transform.localPosition = Vector3.zero
    local seq = DG.Tweening.DOTween.Sequence()
	local tweenKey = DOTweenManager.AddTweenToStop(seq)
	seq:AppendInterval(3)
	seq:OnKill(function ()
		DOTweenManager.RemoveStopTween(tweenKey)
		GameObject.Destroy(particle)
	end)
	return particle
end

function M.DDZBeiZha(i)
    local parent = GameObject.Find("Canvas/LayerLv2")
    local particle = newObject("beizha_paeticle", parent.transform)
    local vec = Vector3.zero
    if i ==  1 then
        vec = Vector3.New(-687,-284,0)
    elseif i == 2 then
        vec = Vector3.New(687,270,0)
    elseif i == 3 then
        vec = Vector3.New(-687,270,0)
    end
    particle.transform.localPosition = vec
    local seq = DG.Tweening.DOTween.Sequence()
	local tweenKey = DOTweenManager.AddTweenToStop(seq)
	seq:AppendInterval(5)
	seq:OnKill(function ()
		DOTweenManager.RemoveStopTween(tweenKey)
		GameObject.Destroy(particle)
	end)
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
