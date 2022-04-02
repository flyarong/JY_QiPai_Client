-- 创建时间:2019-12-02
-- 1元比赛权限对应逻辑

MatchQX1YuanPrefab = {}
local C = MatchQX1YuanPrefab

function C.ExtLogic(parm)
    if true then return end
    -- DSM.ADTrigger(parm.key)
	local tag_vec_map = SYSQXManager.m_data.tag_vec_map
    local config = parm.panelSelf.config
    local ad_tag = parm.key .. "_" .. config.game_id
    if parm.key == "match_js" then
        config = MatchModel.GetGameCfg(parm.panelSelf.parm.game_id)
    end

    if parm.key == "match_hall" then
		local old_obj = parm.panelSelf.transform:Find("match_1yuan_prefab")
	    if IsEquals(old_obj) then
	        destroy(old_obj)
	    end
        if SYSQXManager.IsNeedWatchAD() then
            local p = GameObject.Instantiate(GetPrefab("match_1yuan_prefab"), parm.panelSelf.transform)
            local ui = {}
            LuaHelper.GeneratingVar(p.transform, ui)
            if SYSQXManager.IsNeedWatchAD() then
                ui.sysqx_hint1.gameObject:SetActive(false)
                ui.sysqx_hint2.gameObject:SetActive(true)
            else
                ui.sysqx_hint1.gameObject:SetActive(true)
                ui.sysqx_hint2.gameObject:SetActive(false)
            end
        end
    end

    if parm.key == "match_detail" then
		local old_obj = parm.panelSelf.transform:Find("match_detail_prefab")
	    if IsEquals(old_obj) then
	        destroy(old_obj)
	    end
        local p = GameObject.Instantiate(GetPrefab("match_detail_prefab"), parm.panelSelf.transform)
        p.gameObject:SetActive(false)
        if parm.panelSelf.can_share_num and parm.panelSelf.can_share_num == 1 and SYSQXManager.IsNeedWatchAD() then
            DSM.ADTrigger(ad_tag)
            p.gameObject:SetActive(true)
            local ui = {}
            parm.panelSelf.expenses_context_txt.text = ""
            LuaHelper.GeneratingVar(p.transform, ui)
            parm.panelSelf.signup_num_txt = ui.signup_num_txt
            parm.panelSelf.signup_title_txt = ui.signup_title_txt
            ui.gg_btn.onClick:AddListener(function ()
                ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
                AdvertisingManager.RandPlay(ad_tag, function (data)
                    if data.result == 0 and data.isVerify then
                    else
                        if data.result ~= -999 then
                            if data.isVerify then
                                HintPanel.Create(1, "广告观看失败，请重新观看")
                            else
                                HintPanel.Create(1, "您的网络不稳定，待网络稳定后请重试")
                            end
                        end
                    end
                end)
            end)
            parm.panelSelf.share_btn.gameObject:SetActive(false)
        end
    end

    if parm.key == "match_js" then
        local call = function ()
            if Network.SendRequest("nor_mg_replay_game", {id = config.game_id}, "请求报名") then
                parm.panelSelf.ClearMatchData(config.game_id)
            else
                MjAnimation.Hint(2, Vector3.New(0, -350, 0), Vector3.New(0, 0, 0))
            end
        end
        if SYSQXManager.IsNeedWatchAD() then
            if parm.panelSelf.can_share_num and parm.panelSelf.can_share_num == 1 then
                DSM.ADTrigger(ad_tag)
            end
            local old_OneYuanShare = parm.panelSelf.OneYuanShare

            parm.panelSelf.OneYuanShare = function ()
                if parm.panelSelf.can_share_num and parm.panelSelf.can_share_num == 1 then
                    ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
                    AdvertisingManager.RandPlay(ad_tag, function (data)
                        if data.result == 0 and data.isVerify then
                            parm.panelSelf.share_finish_call = call
                        else
                            if data.result ~= -999 then
                                if data.isVerify then
                                    HintPanel.Create(1, "广告观看失败，请重新观看")
                                else
                                    HintPanel.Create(1, "您的网络不稳定，待网络稳定后请重试")
                                end
                            end                        
                        end
                    end)
                else
                    old_OneYuanShare(parm.panelSelf, call)
                end
            end
        end    
    end
end