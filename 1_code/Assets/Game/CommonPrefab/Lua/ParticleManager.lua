ParticleManager = {}

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

function ParticleManager.Play(particleSystems)
    for k,ps in pairs(particleSystems) do
        ps:Play()
    end
end

function ParticleManager.PlayNormal(particleName, soundName, interval, callback, parent)
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
