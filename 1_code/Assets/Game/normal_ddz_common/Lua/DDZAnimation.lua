--[[
ganshuangfeng 斗地主动画，在加载斗地主资源时，将需要用到
2018-4-26
]]
DDZAnimation = {}
local nDdzFunc = require "Game.normal_ddz_common.Lua.normal_ddz_func_lib"

function DDZAnimation.FaPai(paiList, duration)
    local cardBg = GameObject.Instantiate(GetPrefab("DdzCardBg"), paiList[#paiList].transform.parent)
    cardBg.transform:SetAsFirstSibling()
    for k, v in pairs(paiList) do
        v.gameObject:SetActive(false)
    end
    local wait_time = 0.05
    local cneter = tls.p(0, 500)
    cardBg.transform.localPosition = cneter
    for idx, v in ipairs(paiList) do
        local seq = DG.Tweening.DOTween.Sequence()

        local tweenKey = DOTweenManager.AddTweenToStop(seq)

        local pos = v.transform.localPosition
        local tween1 = v.transform:DOScale(1, wait_time * (idx - 1))
        local tween2 =
            v.transform:DOLocalMove(cneter, 0.15):From():OnStart(
            function()
                ExtendSoundManager.PlaySound(audio_config.ddz.sod_game_deal.audio_name)
                if v and IsEquals(v.gameObject) then
                    v.gameObject:SetActive(true)
                end
                if idx == #paiList then
                    if cardBg and IsEquals(cardBg.gameObject) then
                        GameObject.Destroy(cardBg)
                    end
                    cardBg = nil
                end
            end
        )
        seq:Append(tween1):Append(tween2):OnKill(
            function()
                DOTweenManager.RemoveStopTween(tweenKey)
                if v and IsEquals(v.gameObject) then
                    v.gameObject:SetActive(true)
                    v.transform.localPosition = pos
                end
                if cardBg then
                    GameObject.Destroy(cardBg)
                    cardBg = nil
                end
				if idx == #paiList then
					Util.ClearMemory()
				end
            end
        )
    end
end

function DDZAnimation.clockCountdown(wait_time_txt)
    local tween_tab = {}
    local tween1 = wait_time_txt.transform:DOScale(1.3, 0.6)
    local tween2 = wait_time_txt.transform:DOScale(1, 0.2)
    tween_tab[#tween_tab + 1] = tween1
    tween_tab[#tween_tab + 1] = tween2
    --动画队列播放动画
    local seq = DG.Tweening.DOTween.Sequence()
    local tweenKey = DOTweenManager.AddTweenToStop(seq)
    seq:Join(tween_tab[1]):Join(tween_tab[2]):OnKill(
        function()
            DOTweenManager.RemoveStopTween(tweenKey)
            if IsEquals(wait_time_txt) then
                wait_time_txt.transform.localScale = Vector3.one
            end
        end
    )
    -- return seq
end

--其他玩家出牌动画
function DDZAnimation.MyChuPai(cards_out)
    if cards_out then
        local tweenKey
        local act =
            cards_out.transform:DOLocalMoveY(50, 0.1):OnKill(
            function()
                DOTweenManager.RemoveStopTween(tweenKey)
                cards_out:Destroy()
            end
        )
        tweenKey = DOTweenManager.AddTweenToStop(act)
    else
        print("DDZAnimation.MyChuPai")
        print(debug.traceback())
    end
end
function DDZAnimation.ShowChupaiCard(cards_out, func)
    cards_out.gameObject:SetActive(false)
    local tran = cards_out.transform:GetChild(0)
    local tween1 =
        tran:DOScale(1.4, 0.2):OnComplete(
        function()
            if cards_out and IsEquals(cards_out.gameObject) then
                cards_out.gameObject:SetActive(true)
            end
            if func then
                func()
            end
        end
    )
    local tween2 = tran:DOScale(0.9, 0.15)
    local tween3 = tran:DOScale(1, 0.1)

    --动画队列播放动画
    local seq = DG.Tweening.DOTween.Sequence()

    local tweenKey = DOTweenManager.AddTweenToStop(seq)
    seq:Append(tween1):Append(tween2):Append(tween3):OnKill(
        function()
            DOTweenManager.RemoveStopTween(tweenKey)
            if not IsEquals(cards_out.gameObject) then
                dump(cards_out, "<color=yellow>DDZAnimation.ShowChupaiCard card_out is null</color>")
                return
            end
            cards_out.gameObject:SetActive(true)
            tran.localScale = Vector3.one
        end
    )
end

function DDZAnimation.effect_bomb(seat)
    local bombObj = {"ani_bobm"}
    resMgr:LoadPrefab(
        bombObj,
        function(objs)
            local count = objs.Length
            for i = 0, count - 1, 1 do
                local obj = objs[i]
                local go = newObject(obj, seat.child.ani)
                local spriteAni = go.gameObject:GetComponent("UI2DSpriteAnimation")
                spriteAni.loop = false
                spriteAni:Play(
                    function()
                        destroy(go.gameObject)
                    end
                )
            end
        end
    )
end

function DDZAnimation.plain_animation()
    local parent = GameObject.Find("Canvas/LayerLv1")
    local UIEntity = newObject("PlainAnimPrefab", parent.transform)

    local seq = DG.Tweening.DOTween.Sequence()
    local tweenKey = DOTweenManager.AddTweenToStop(seq)
    seq:AppendInterval(3)
    seq:OnKill(
        function()
            DOTweenManager.RemoveStopTween(tweenKey)
            destroy(UIEntity)
			Util.ClearMemory()
        end
    )
end

function DDZAnimation.rocket_animation()
    local parent = GameObject.Find("Canvas/LayerLv1")
    local UIEntity = newObject("RocketAnimPrefab", parent.transform)
    ExtendSoundManager.PlaySound(audio_config.ddz.sod_game_card_rocketssod.audio_name)
    local seq = DG.Tweening.DOTween.Sequence()
    local tweenKey = DOTweenManager.AddTweenToStop(seq)
    seq:AppendInterval(3)
    seq:OnKill(
        function()
            DOTweenManager.RemoveStopTween(tweenKey)
            destroy(UIEntity)
			Util.ClearMemory()
        end
    )
end

function DDZAnimation.bomb_animation(direction)
    ExtendSoundManager.PlaySound(audio_config.ddz.sod_game_card_bombsod.audio_name)
    local parent = GameObject.Find("Canvas/LayerLv1")
    local UIEntity = newObject("ZDAnimPrefab", parent.transform)
    if direction == 2 then
        --右边的玩家
        local mn = UIEntity.transform:Find("MoveNode")
        mn.transform.localScale = Vector3.New(-1, 1, 1)
    end

    local seq = DG.Tweening.DOTween.Sequence()
    local tweenKey = DOTweenManager.AddTweenToStop(seq)
    seq:AppendInterval(3)
    seq:OnKill(
        function()
            DOTweenManager.RemoveStopTween(tweenKey)
			
			destroy(UIEntity)
			Util.ClearMemory()
        end
    )
end

function DDZAnimation.ShowLaizi(laizi, card, callback)
    card.gameObject:SetActive(false)

    local parent = GameObject.Find("Canvas/LayerLv1")
    local flipTime = 0.075
    local donghua
    donghua =
        function(count)
        local my_card
        if count == 0 then
            my_card = laizi
        else
            my_card = math.random(1, 52)
        end
        local cardFx = DdzCard.New(GetPrefab("DdzLaiziTurnCard"), parent.transform, my_card, my_card, 0)
        local tran = cardFx.transform
        local fgIcon = cardFx.card_img
        local bgIcon = cardFx.bg
        bgIcon.gameObject:SetActive(true)
        fgIcon.gameObject:SetActive(false)
        local tweenRot1 =
            tran:DORotate(Vector3.New(0, 90.0, 0), flipTime, DG.Tweening.RotateMode.FastBeyond360):OnComplete(
            function()
                tran.rotation = Quaternion:SetEuler(0, -270, 0)
                bgIcon.gameObject:SetActive(false)
                fgIcon.gameObject:SetActive(true)
            end
        )

        local seq = DG.Tweening.DOTween.Sequence()
        local tweenKey = DOTweenManager.AddTweenToStop(seq)

        if count == 0 then
            local tweenRot2 =
                tran:DORotate(Vector3.New(0, 0, 0), flipTime * 2, DG.Tweening.RotateMode.FastBeyond360):OnComplete(
                function()
                    local lz_glow = newObject("Lz_glow", fgIcon.transform)
                end
            )
            local scaleTime = 0.2
            local tweenScale = tran:DOScale(Vector3.New(0.35, 0.2, 1.0), scaleTime)
            local transTime = 0.2
            local dstPos = card.transform.position
            local tweenMove = tran:DOMove(dstPos, transTime)

            seq:Append(tweenRot1):Append(tweenRot2):AppendInterval(0.75):Append(tweenScale):Join(tweenMove):OnComplete(
                function()
                    DOTweenManager.RemoveStopTween(tweenKey)
                    GameObject.Destroy(cardFx.gameObject)
                    cardFx = nil
                    if card and IsEquals(card.gameObject) then
                        card.gameObject:SetActive(true)
                    end
                    if callback then
                        callback()
                    end
                end
            ):OnKill(
                function()
                    if cardFx then
                        GameObject.Destroy(cardFx.gameObject)
                        cardFx = nil
                    end
                    -- body
                end
            )
        else
            local tweenRot2 =
                tran:DORotate(Vector3.New(0, -90, 0), flipTime * 2, DG.Tweening.RotateMode.FastBeyond360):OnComplete(
                function()
                    tran.rotation = Quaternion:SetEuler(0, 90, 0)
                    bgIcon.gameObject:SetActive(true)
                    fgIcon.gameObject:SetActive(false)
                end
            )
            local tweenRot3 =
                tran:DORotate(Vector3.New(0, 0, 0), flipTime, DG.Tweening.RotateMode.FastBeyond360):OnComplete(
                function()
                end
            )
            seq:Append(tweenRot1):Append(tweenRot2):Append(tweenRot3):OnComplete(
                function()
                    DOTweenManager.RemoveStopTween(tweenKey)
                    GameObject.Destroy(cardFx.gameObject)
                    cardFx = nil
                    donghua(count - 1)
                end
            ):OnKill(
                function()
                    if cardFx then
                        GameObject.Destroy(cardFx.gameObject)
                        cardFx = nil
                    end
                    -- body
                end
            )
        end
    end
    donghua(4)
end

function DDZAnimation.Spring()
    local parent = GameObject.Find("Canvas/LayerLv1")
    local UIEntity = newObject("CTAnimPrefab", parent.transform)

    local seq = DG.Tweening.DOTween.Sequence()
    local tweenKey = DOTweenManager.AddTweenToStop(seq)
    seq:AppendInterval(3)
    seq:OnKill(
        function()
            DOTweenManager.RemoveStopTween(tweenKey)
			destroy(UIEntity)
			Util.ClearMemory()
        end
    )
end

function DDZAnimation.ChangeScore(cSeat, score, parent)
    local type = score > 0 and 1 or 2
    local typeStr = type == 1 and "ItemDdzScoreAdd" or "ItemDdzScoreRem"
    local typeParticle = type == 1 and "glow_hong" or "glow_lan"
    local scoreItem = GameObject.Instantiate(GetPrefab(typeStr), parent.transform)
    local particleItem = GameObject.Instantiate(GetPrefab(typeParticle), parent.transform)
    local textCom = scoreItem.transform:GetComponent("Text")
    textCom.text = type == 1 and "+" .. score or score
    if cSeat == 2 then
        textCom.alignment = UnityEngine.TextAnchor.LowerRight
    end

    local tweenKey
    local act =
        scoreItem.transform:DOLocalMoveY(300, 1.5):OnKill(
        function()
            DOTweenManager.RemoveStopTween(tweenKey)
            GameObject.Destroy(scoreItem)
            GameObject.Destroy(particleItem)
        end
    )
    tweenKey = DOTweenManager.AddTweenToStop(act)
end

function DDZAnimation.ChangeRate(cur_multiple, rate)
    local fanBeiItem = GetPrefab("ItemDdzGameFanBei")
    local beishu = GetPrefab("beishu")
    local beishu_qh = GetPrefab("qiehuan_beishu")
    local fan_bei = GameObject.Instantiate(fanBeiItem, cur_multiple.transform.parent.transform)
    fan_bei.gameObject:SetActive(true)
    local fan_bei_p = GameObject.Instantiate(beishu, cur_multiple.transform.parent.transform)
    fan_bei_p.gameObject:SetActive(false)
    local fan_bei_p_qh = GameObject.Instantiate(beishu_qh, cur_multiple.transform)
    fan_bei_p_qh.gameObject:SetActive(false)
    fan_bei_p_qh.transform.localPosition = Vector3.New(0, -30, 0)

    fan_bei.transform:GetChild(0).gameObject:GetComponent("Text").text = "x" .. rate
    local targetPos = cur_multiple.transform.position

    local tween1 =
        fan_bei.transform:DOScale(Vector3.one * 4, 0.25):From():OnComplete(
        function()
            fan_bei_p.gameObject:SetActive(true)
        end
    )
    local tween2 =
        fan_bei.transform:DOMove(targetPos, 0.5):OnStart(
        function()
            fan_bei_p.gameObject:SetActive(true)
            fan_bei.transform:DOScale(Vector3.one * 0.2, 0.3)
        end
    ):OnComplete(
        function()
            cur_multiple.text = rate .. "倍"
            GameObject.Destroy(fan_bei.gameObject)
            fan_bei = nil
        end
    )
    local tween3 =
        cur_multiple.transform:DOScale(Vector3.one * 1.2, 0.1):OnComplete(
        function()
            fan_bei_p_qh.gameObject:SetActive(true)
            cur_multiple.transform:DOScale(Vector3.one * 0.65, 0.1):OnComplete(
                function()
                    cur_multiple.transform:DOScale(Vector3.one * 1.1, 0.1):OnComplete(
                        function()
                            cur_multiple.transform:DOScale(Vector3.one * 1, 0.1)
                        end
                    )
                end
            )
        end
    )
    local seq = DG.Tweening.DOTween.Sequence()
    local tweenKey = DOTweenManager.AddTweenToStop(seq)
    seq:Append(tween1):AppendInterval(0.7):Append(tween2):AppendInterval(0.5):Join(tween3):OnKill(
        function()
            DOTweenManager.RemoveStopTween(tweenKey)
            if fan_bei then
                GameObject.Destroy(fan_bei.gameObject)
                fan_bei = nil
            end
            if fan_bei_p then
                GameObject.Destroy(fan_bei_p.gameObject)
                fan_bei_p = nil
            end
            if fan_bei_p_qh then
                GameObject.Destroy(fan_bei_p_qh.gameObject)
                fan_bei_p_qh = nil
            end
        end
    )
end

--type : 1 出牌不合法 2 操作失败
function DDZAnimation.Hint(type, startPos, targetPos)
    local parent = GameObject.Find("Canvas/LayerLv1").transform
    local hintItem = GameObject.Instantiate(GetPrefab("ItemDdzGameHint"), parent)
    local sprite = ""
    if type == 2 then
        print("Hint!!!!!!!!")
        print(debug.traceback())
    end
    --1 出牌不合法
    if type == 1 then
        sprite = "ddz_font_inconformity_normal_ddz_common"
    elseif type == 2 then
        sprite = "game_imgf_failure"
    end
    local img = hintItem:GetComponent("Image")
    img.sprite = GetTexture(sprite)
    img:SetNativeSize()
    --出现一段时间后消失
    hintItem.transform.localPosition = Vector3.New(0, -128, 0)

    local seq = DG.Tweening.DOTween.Sequence()
    local tweenKey = DOTweenManager.AddTweenToStop(seq)
    seq:AppendInterval(1)
    seq:OnKill(
        function()
            DOTweenManager.RemoveStopTween(tweenKey)
            GameObject.Destroy(hintItem.gameObject)
        end
    )
end

function DDZAnimation.StartAgainCard(parent)
    local startAgainItem = GameObject.Instantiate(GetPrefab("ItemDdzStartAgainCard"), parent)
    local tween1 =
        startAgainItem.transform:DOLocalMoveX(-1200, 0.5):From():OnKill(
        function()
            if startAgainItem ~= nil then
                GameObject.Destroy(startAgainItem.gameObject)
                startAgainItem = nil
            end
        end
    )
    local tween2 =
        startAgainItem.transform:DOLocalMoveX(1200, 0.5):OnComplete(
        function()
            if startAgainItem ~= nil then
                GameObject.Destroy(startAgainItem.gameObject)
                startAgainItem = nil
            end
        end
    )
    local seq = DG.Tweening.DOTween.Sequence()
    local tweenKey = DOTweenManager.AddTweenToStop(seq)
    seq:Append(tween1):AppendInterval(1):Append(tween2):OnKill(
        function()
            DOTweenManager.RemoveStopTween(tweenKey)
            if startAgainItem ~= nil then
                GameObject.Destroy(startAgainItem.gameObject)
                startAgainItem = nil
            end
        end
    )
end

function DDZAnimation.CurRace(curRace, parent)
    local curRaceItem = GameObject.Instantiate(GetPrefab("ItemDdzCurRace"), parent)
    local curRaceText = curRaceItem.transform:GetComponent("Text")
    curRaceText.text = "第" .. curRace .. "副"
    local tween1 = curRaceItem.transform:DOLocalMoveX(-1200, 0.5):From()
    local tween2 = curRaceItem.transform:DOLocalMoveX(1200, 0.5)
    local seq = DG.Tweening.DOTween.Sequence()
    local tweenKey = DOTweenManager.AddTweenToStop(seq)
    seq:Append(tween1):AppendInterval(1):Append(tween2):OnKill(
        function()
            DOTweenManager.RemoveStopTween(tweenKey)
            GameObject.Destroy(curRaceItem.gameObject)
        end
    )
end

function DDZAnimation.ChangeWaitUI(fill_img, effect, startFillAmount, endFillAmount)
    local totalTime = 0.4
    local direction = 0.02
    local countNum = totalTime / direction
    local angleDire = (endFillAmount - startFillAmount) * 360 / countNum
    local fillAmountDire = (endFillAmount - startFillAmount) / countNum
    local timer =
        Timer.New(
        function()
            fill_img.fillAmount = fill_img.fillAmount + fillAmountDire
            if IsEquals(effect) then
                if IsEquals(fill_img) then
                    effect.transform:RotateAround(fill_img.transform.position, Vector3.back, angleDire)
                else
                    effect.transform:RotateAround(Vector3.zero, Vector3.back, angleDire)
                end
            end
        end,
        direction,
        countNum
    )
    timer:Start()
    return timer
end

-- 新手引导福卡动画
function DDZAnimation.GuideRedAnim(hongbaoSpine, redNode, textCanvasGroup)
    local spine = hongbaoSpine:GetComponent("SkeletonAnimation")

    spine.AnimationName = "animation"

    hongbaoSpine.gameObject:SetActive(true)

    redNode.gameObject:SetActive(false)
    textCanvasGroup.alpha = 0.1
    local seq = DG.Tweening.DOTween.Sequence()
    local tweenKey = DOTweenManager.AddTweenToStop(seq)
    seq:AppendInterval(1.2)
    seq:AppendCallback(
        function()
            spine.AnimationName = "doudong"
            redNode.gameObject:SetActive(true)
        end
    )
    seq:Append(textCanvasGroup:DOFade(1, 1))
    seq:OnKill(
        function()
            DOTweenManager.RemoveStopTween(tweenKey)
            spine.AnimationName = "doudong"
            redNode.gameObject:SetActive(true)
            textCanvasGroup.alpha = 1
        end
    )
end

function DDZAnimation.KillAll()
    -- DG.Tweening.DOTween.KillAll()
end

function DDZAnimation.MoveSR(sr, offsetY)
    local tweenKey
    local act =
        sr.transform:DOLocalMoveY(offsetY, 0.5):OnKill(
        function()
            DOTweenManager.RemoveStopTween(tweenKey)
        end
    )
    tweenKey = DOTweenManager.AddTweenToStop(act)
end


-- 一个固定位置的特效 显示一段时间消失
function DDZAnimation.PlayShowAndHideFX(parent, fx_name, beginPos, keepTime, call)
    local prefab
    prefab = GameObject.Instantiate(GetPrefab(fx_name), parent).gameObject
    prefab.transform.position = beginPos
    prefab.transform.localScale = Vector3.one

    local seq = DoTweenSequence.Create()
    seq:AppendInterval(keepTime)
    seq:OnKill(function ()
        if call then
            call()
        end
    end)
    seq:OnForceKill(function ()
        destroy(prefab)
    end)        
end
-- 2,被关   3,反关   4,单关   5,双关  6,包赔  7,被包赔
local pdk_type_map = {
    [2] = {img="pdk_settlement_imgf_bg"},
    [3] = {img="pdk_settlement_imgf_dg"},
    [4] = {img="pdk_settlement_imgf_dg"},
    [5] = {img="pdk_settlement_imgf_sg"},
    [6] = {img="pdk_settlement_imgf_bp"},
    [7] = {img="pdk_settlement_imgf_bbp"},
}
-- 跑得快结算动画
function DDZAnimation.PlayPDKJS(parent, type)
    local cfg = pdk_type_map[type]
    if cfg then
        local prefab = GameObject.Instantiate(GetPrefab("PDKAnimJS"), parent).gameObject
        prefab.transform.localPosition = Vector3.zero
        prefab.transform.localScale = Vector3.one
        local icon = prefab.transform:Find("Icon"):GetComponent("Image")
        icon.sprite = GetTexture(cfg.img)
        icon:SetNativeSize()

        local seq = DoTweenSequence.Create()
        seq:AppendInterval(2)
        seq:OnForceKill(function ()
            destroy(prefab)
        end)        
    end
end
-- 跑得快首出动画
function DDZAnimation.PlayPDKSC(parent, ui_num, tag)
    if tag == "first_cp" then
        local prefab = GameObject.Instantiate(GetPrefab("psk_sc_prefab"), parent).gameObject
        prefab.transform.localPosition = Vector3.zero
        prefab.transform.localScale = Vector3.one
        local tran = prefab.transform
        local endPos
        local r
        if ui_num == 1 then
            endPos = Vector3.New(-732, -225, 0)
            r = 130
        elseif ui_num == 2 then
            endPos = Vector3.New(781, 284, 0)
            r = -70
        else
            endPos = Vector3.New(-781, 284, 0)
            r = 64
        end
        local seq = DoTweenSequence.Create()
        seq:AppendInterval(1)
        seq:Append(tran:DORotate(Vector3.New(0, 0, r), 0.1, DG.Tweening.RotateMode.FastBeyond360))
        seq:Append(tran:DOMove(endPos, 0.5):SetEase(DG.Tweening.Ease.InQuint))
        seq:Join(tran:DOScale(0.2, 0.5):SetEase(DG.Tweening.Ease.InQuint))
        seq:OnForceKill(function ()
            destroy(prefab)
        end)    
    else
        local prefab = GameObject.Instantiate(GetPrefab("psk_sc_prefab1"), parent).gameObject
        prefab.transform.localPosition = Vector3.zero
        prefab.transform.localScale = Vector3.one
        local tran = prefab.transform
        local img = tran:Find("Image")
        local txt = tran:Find("Image/Text")

        local endPos
        if ui_num == 1 then
            endPos = Vector3.New(-732, -225, 0)
        elseif ui_num == 2 then
            endPos = Vector3.New(781, 284, 0)
            img.localRotation = Quaternion:SetEuler(0, 180, 0)
            txt.localRotation = Quaternion:SetEuler(0, 180, 0)
        else
            endPos = Vector3.New(-781, 284, 0)
        end
        tran.localPosition = endPos
        local seq = DoTweenSequence.Create()
        seq:AppendInterval(2)
        seq:OnForceKill(function ()
            destroy(prefab)
        end)
    end
end
