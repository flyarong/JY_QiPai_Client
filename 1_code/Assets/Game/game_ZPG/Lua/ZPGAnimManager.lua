-- 创建时间:2020-04-07

--种苹果动画管理器
ZPGAnimManager = {}

ZPGAnimManager.glow_obj = nil

function ZPGAnimManager.PlayPlantStart(parent)
    ExtendSoundManager.PlaySound(audio_config.pgdz.bgm_pgdz_kaishi.audio_name)
    local pre = newObject("ZPGGameStartPrefab",parent)
    local seq = DoTweenSequence.Create()
    seq:AppendInterval(1)
    seq:OnKill(function ()
        Destroy(pre.gameObject)
    end)
end

function ZPGAnimManager.PlayPlantEnd(parent,callback)
    ExtendSoundManager.PlaySound(audio_config.pgdz.bgm_pgdz_jieshu.audio_name)
    local pre = newObject("ZPGGameEndPrefab",parent)
    local seq = DoTweenSequence.Create()
    seq:AppendInterval(1)
    seq:OnForceKill(function()
        if callback then callback() end
        Destroy(pre.gameObject)
    end)
end

function ZPGAnimManager.PlaySpecialPlant(parent)
    ExtendSoundManager.PlaySound(audio_config.pgdz.bgm_pgdz_shuangbei.audio_name)
    local pre = newObject("ZPGDoubleAwardPrefab",parent)
    local seq = DoTweenSequence.Create()
    seq:AppendInterval(2.5)
    seq:OnKill(function ()
        Destroy(pre.gameObject)
    end)
end

function ZPGAnimManager.PlayAppleAnim(objects,parent,callback)
    local seq = DoTweenSequence.Create()
    local winner = ZPGModel.data.winner
    local anim1 = objects[1].Anim
    local anim3 = objects[3].Anim
    anim1:Play("@BetArea3_shu")
    anim1.speed = 1
    anim3:Play("@BetArea3_shu")
    anim3.speed = 1
    local anim2 = objects[2].Anim
    anim2:Play("@BetArea2_shu")
    anim2.speed = 1
    seq:AppendInterval(0.4)
    seq:AppendCallback(function ()
        if winner ~= 2 then
            if IsEquals(anim2) then
                anim2.speed = 0
            end
        end
    end)
    seq:AppendInterval(2.6)
    seq:OnKill(function()
        if ZPGModel.data and ZPGModel.data.apple_data.is_gold_coin == 1 then
            ZPGAnimManager.PlaySpecialPlant(parent)
        end
        if(callback) then callback() end
    end)
end

function ZPGAnimManager.ShowApple(objects,winner)
    if winner ~= 2 then
        local anim1 = objects[1].Anim
        local anim3 = objects[3].Anim
        anim1:Play("@BetArea3_shu",-1,4)
        anim1.speed = 0
        anim3:Play("@BetArea3_shu",-1,4)
        anim3.speed = 0
    else
        local anim2 = objects[2].Anim
        anim2:Play("@BetArea2_shu",-1,3)
        anim2.speed = 0
    end
end

function ZPGAnimManager.PlayAreaGlow(panelSelf,interval)
    if not ZPGModel.data then return end
    local targetObj = panelSelf["bg_" .. ZPGModel.data.winner]
    interval = interval or 4.5
    if not targetObj then return end
    targetObj.gameObject:SetActive(true)
    ZPGAnimManager.glow_obj = targetObj
    local seq = DoTweenSequence.Create()
    seq:AppendInterval(interval)
    seq:OnKill(function ()
        targetObj.gameObject:SetActive(false)
        ZPGAnimManager.glow_obj = nil
    end)
end

function ZPGAnimManager.EndAreaGlow()
    if ZPGAnimManager.glow_obj then
        ZPGAnimManager.glow_obj.gameObject:SetActive(false)
    end
end

function ZPGAnimManager.PlayHistroyItem(history_node,history_grid,callback)
    local height = 82
    local startPos =  Vector3(history_node.transform.localPosition.x,history_node.transform.localPosition.y + height,0)
    local seq = DoTweenSequence.Create()
    if IsEquals(history_node) then
        history_node.transform.localPosition = startPos
    end
    seq:AppendCallback(function()
        if not IsEquals(history_grid) then
            return
        end
        history_grid.transform:SetParent(history_node.transform)
        history_grid.transform:SetAsFirstSibling()
        history_grid.gameObject:SetActive(true)
    end)
    seq:AppendInterval(0.1)
    seq:Append(history_node.transform:DOLocalMoveY(startPos.y - height,0.6))
    seq:OnForceKill(function ()
        if callback then callback() end
    end)
    return history_grid
end