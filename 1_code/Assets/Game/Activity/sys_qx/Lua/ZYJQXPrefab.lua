-- 创建时间:2019-12-02
-- 转运金对应逻辑

ZYJQXPrefab = {}
local C = ZYJQXPrefab

function C.ExtLogic(parm)
    DSM.ADTrigger(parm.key)
	local tag_vec_map = SYSQXManager.m_data.tag_vec_map
    local old_obj = parm.panelSelf.transform:Find("zyj_xr_prefab")
    if IsEquals(old_obj) then
        destroy(old_obj)
    end
    local p = GameObject.Instantiate(GetPrefab("zyj_xr_prefab"), parm.panelSelf.transform)
    local ui = {}
    p.gameObject:SetActive(false)
    LuaHelper.GeneratingVar(p.transform, ui)
    ui.xr_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		if parm.panelSelf.call then
			parm.panelSelf.call()
		end
		parm.panelSelf:MyExit()
		Network.SendRequest("broke_subsidy", nil, "请求数据")
    end)
    ui.mf_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		if parm.panelSelf.call then
			parm.panelSelf.call()
		end
		parm.panelSelf:MyExit()
		AdvertisingManager.RandPlay(parm.key, function (data)
            if data.result == 0 and data.isVerify then
                Network.SendRequest("broke_subsidy", nil, "请求数据")
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

    if SYSQXManager.IsNeedWatchAD() then
    	p.gameObject:SetActive(true)
    	ui.xr_btn.gameObject:SetActive(false)
    	ui.mf_btn.gameObject:SetActive(true)
        parm.panelSelf.confirm_btn.gameObject:SetActive(false)
    	parm.panelSelf.info_desc_txt.text = "单笔充值6元以上(不包含礼包),可以免视频领取转运金."
    else
        p.gameObject:SetActive(false)
    end
    local txt = ui.xr_btn.transform:Find("Text"):GetComponent("Text")
    txt.text = "领取"
end