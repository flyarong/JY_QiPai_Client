-- 创建时间:2019-12-02
-- 5元比赛权限对应逻辑

MatchQX5YuanPrefab = {}
local C = MatchQX5YuanPrefab

function C.ExtLogic(parm)
    if true then return end
	local tag_vec_map = SYSQXManager.m_data.tag_vec_map
    local config = parm.panelSelf.config
    local ad_tag = parm.key .. "_" .. config.game_id
	if parm.key == "match_js" then
        config = MatchModel.GetGameCfg(parm.panelSelf.parm.game_id)
    end

    local old_obj = parm.panelSelf.transform:Find("match_5yuan_prefab")
    if IsEquals(old_obj) then
        destroy(old_obj)
    end

    local zj_bm_call
    local kgg_bm_call

    local on_click = function ()
        if AdvertisingManager.IsCloseAD() then
            zj_bm_call(parm.panelSelf)
        else
            local pre = HintPanel.Create(6, "请选择报名方式", function ()
                AdvertisingManager.RandPlay(ad_tag, function (data)
                    if data.result == 0 and data.isVerify then
                        kgg_bm_call(parm.panelSelf)
                    else
                        zj_bm_call(parm.panelSelf)
                    end
                end)
            end, function ()
                zj_bm_call(parm.panelSelf)
            end)
            pre:SetButtonText("5000报名", "1万报名")
            pre.payBtnEntity.transform.localPosition = Vector3.New(210, -122, 0)
            pre.confirmBtnEntity.transform.localPosition = Vector3.New(-210, -122, 0)
            local ii = pre.payBtnEntity.transform:GetComponent("Image")
            ii.sprite = GetTexture("ggw_btn_lq_activity_sys_qx")
            pre.close_txt.transform.localPosition = Vector3.New(32, 14, 0)
        end
    end

    local item_key, item_count = MatchModel.GetMatchCanUseTool(config.enter_condi_itemkey, config.enter_condi_item_count)
    if (item_key and item_key == "jing_bi") or (not item_key and config.enter_condi_count) then

		local new_signup_jing_bi
		if SYSQXManager.IsNeedWatchAD() then
	        if item_key then
	            new_signup_jing_bi = item_count * 2
	        else
	            new_signup_jing_bi = config.enter_condi_count * 2
	        end
	    else
	    	if item_key then
	            new_signup_jing_bi = item_count
	        else
	            new_signup_jing_bi = config.enter_condi_count
	        end
	    end

        local signup_call = function ()
            local signup = function ()
                local request = {id = tonumber(config.game_id), watch_ad=0}
                MatchModel.SetCurrGameID(config.game_id)
                local scene_name = MatchModel.GetGameIDToScene(config.game_id)
                local parm = {
                    gotoui = scene_name,
                    goto_scene_parm = true,
                    enter_scene_call = function(  )
                        if not Network.SendRequest("nor_mg_signup", request, "正在报名") then
                            HintPanel.Create(1, "网络异常", function()
                                GameManager.GotoUI({gotoui = "game_MatchHall"})
                            end)
                        end
                    end
                }
                GameManager.GotoUI(parm)
            end
            if new_signup_jing_bi <= MainModel.UserInfo.jing_bi then
                signup()
            else
                PayFastPanel.Create(config, signup)
            end
        end

        -- 结算界面的重玩消息
        local replay_call = function ()
            local signup = function ()
                local request = {id = tonumber(config.game_id), watch_ad=0}
                Network.SendRequest("nor_mg_replay_game", request, "请求报名")
            end
            if new_signup_jing_bi <= MainModel.UserInfo.jing_bi then
                signup()
            else
                PayFastPanel.Create(config, signup)
            end
        end

        if parm.key == "match_hall" then
	        local old_signup = parm.panelSelf.OnSignupClick
        	if SYSQXManager.IsNeedWatchAD() then
	            local p = GameObject.Instantiate(GetPrefab("match_5yuan_prefab"), parm.panelSelf.transform)
	            local ui = {}
	            LuaHelper.GeneratingVar(p.transform, ui)
	            if SYSQXManager.IsNeedWatchAD() then
	                local new_signup
	                ui.sysqx_hint1.gameObject:SetActive(false)
	                ui.sysqx_hint2.gameObject:SetActive(true)
	                ui.sysqx_hint3.gameObject:SetActive(false)
	                if item_key then
	                    parm.panelSelf.enter_num_txt.text = StringHelper.ToCash(item_count * 2)
	                    new_signup = item_count * 2
	                else
	                    parm.panelSelf.enter_num_txt.text = StringHelper.ToCash(config.enter_condi_count * 2)
	                    new_signup = config.enter_condi_count * 2
	                end
                    parm.panelSelf.OnSignupClick = function ()
                        on_click()
	                end
                    zj_bm_call = signup_call
                    kgg_bm_call = old_signup
	            else
	                ui.sysqx_hint1.gameObject:SetActive(true)
	                ui.sysqx_hint2.gameObject:SetActive(false)
	                ui.sysqx_hint3.gameObject:SetActive(false)
	            end
	        end
        elseif parm.key == "match_detail" then
	        local old_signup = parm.panelSelf.SignupHBS
            if SYSQXManager.IsNeedWatchAD() then
                parm.panelSelf.selected_txt.text = "鲸币x1万(看广告打5折)"
            else
                parm.panelSelf.selected_txt.text = "鲸币x5000(已充值打折)"
            end
            if SYSQXManager.IsNeedWatchAD() then
                parm.panelSelf.SignupHBS = function ()
                    on_click()
                end
                zj_bm_call = signup_call
                kgg_bm_call = old_signup
            end
        elseif parm.key == "match_js" then
        	local old_OnClickOneMore = parm.panelSelf.OnClickOneMore
            if SYSQXManager.IsNeedWatchAD() then
                parm.panelSelf.OnClickOneMore = function ()
                    on_click()
                end
                zj_bm_call = replay_call
                kgg_bm_call = old_OnClickOneMore
            end
        end
    end
end