-- 创建时间:2019-12-03

ActQXPrefab = {}
local C = ActQXPrefab

function C.ExtLogic(parm)
	local tag_vec_map = SYSQXManager.m_data.tag_vec_map

	dump(parm,"<color=red>PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPParm</color>")
	
	if not parm.panelSelf.is_ext then
		parm.panelSelf.is_ext = true
	    if parm.key == "dh" then
	    	-- local old_dh_call = parm.panelSelf.OnExchangeClick
	    	-- local call = function ()
			--     local iss = PlayerPrefs.GetInt(MainModel.FreeDHRedHintKey, 0)
			--     if iss == 1 then
			--         iss = true
			--     else
			--         iss = false
			--     end
			--     if not iss then
			--         local rrDH = StringHelper.ToRedNum(parm.panelSelf.ext_model.data.exchange_hongbao.hong_bao2 / 100)
	        --         local jb = 0
			--         if MainModel.myLocation == "game_Mj3D" then
			--         	jb = parm.panelSelf.my_score
			--         elseif MainModel.myLocation == "game_DdzFree" then
			--         	jb = parm.panelSelf.ext_model.data.settlement_info.award[parm.panelSelf.ext_model.GetPlayerSeat()]
			--         elseif MainModel.myLocation == "game_DdzPDK" then
			--         	jb = parm.panelSelf.ext_model.data.settlement_info.score_data[parm.panelSelf.ext_model.GetPlayerSeat()].score
			--         end
			--         local str = string.format("为你将本局赢得的%s鲸币兑换成%s福卡", jb, rrDH)
			--         local pre = HintPanel.Create(2, str, function (b)
			--             Network.SendRequest("fg_settle_exchange_hongbao", {ext_get=1}, "")
			--             if b then
			--                 PlayerPrefs.SetInt(MainModel.FreeDHRedHintKey, 1)
			--             else
			--                 PlayerPrefs.SetInt(MainModel.FreeDHRedHintKey, 0)
			--             end
			--         end)
			--         pre:ShowGou()
			--         pre:SetButtonText(nil, "立即兑换")
			--     else
			--         Network.SendRequest("fg_settle_exchange_hongbao", {ext_get=1}, "")
			--     end
			-- end
			
			-- local isWatchAD_dh = true
			-- local _permission_key = "drt_ignore_watch_ad_3"  --对局兑换红包的权限
			-- local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key=_permission_key, is_on_hint = true}, "CheckCondition")
			-- if a and not b then
			-- 	isWatchAD_dh = false
			-- end

			-- --dump(isWatchAD_dh , "<color=red>-----isActiveDH-----</color>")

	    	-- local new_dh_call = function ()
	    	-- 	if SYSQXManager.IsNeedWatchAD() and isWatchAD_dh then
		    -- 		GetQXPrefab.Create(parm)
	    	-- 	else
	    	-- 		local a = GameButtonManager.RunFun({gotoui="vip", hb=rr, call = function ()
		    -- 			call()
	    	-- 		end}, "CheckHBLimit")
	    	-- 		if not a then	
		    -- 			call()
	    	-- 		end
	    	-- 	end
	    	-- end
	    	-- if (not SYSQXManager.IsNeedWatchAD() or not isActiveDH )and parm.panelSelf.ext_model.data.exchange_hongbao then
    		-- 	local rrDH = parm.panelSelf.ext_model.data.exchange_hongbao.hong_bao2
    		-- 	if IsEquals(parm.panelSelf.ExChongbao) then
    		-- 		parm.panelSelf.ExChongbao.text = StringHelper.ToRedNum(rrDH / 100)
    		-- 	end
	    	-- end
	    	-- parm.panelSelf.OnExchangeClick = new_dh_call
	    elseif parm.key == "djhb" then
			local call = function ()
				if IsEquals(parm.panelSelf) then
					parm.panelSelf.zhuangpan_glow.gameObject:SetActive(true)
					parm.panelSelf.anim_state = "空闲"
					parm.panelSelf:RefreshState()
				end
	    	end
			local old_ShowAward = parm.panelSelf.ShowAward
			local new_ShowAward = function ()

				local isWatchAD_djhb = true
				local _permission_key = "drt_ignore_watch_ad_4"  --累胜奖励的广告权限
				local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key=_permission_key, is_on_hint = true}, "CheckCondition")
				if a and not b then
					isWatchAD_djhb = false
				end
				if SYSQXManager.IsNeedWatchAD() and isWatchAD_djhb then
					parm.call = call
		    		GetQXPrefab.Create(parm)
	    		else
	    			old_ShowAward(parm.panelSelf)
	    		end
			end
			parm.panelSelf.ShowAward = new_ShowAward
		elseif parm.key == "ls" then
			local old_SendGetAward = parm.panelSelf.SendGetAward
			local new_SendGetAward = function ()

				local isWatchAD_ls = true
				local _permission_key = "drt_ignore_watch_ad_5"  --连胜奖励的广告权限
				local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key=_permission_key, is_on_hint = true}, "CheckCondition")
				if a and not b then
					isWatchAD_ls = false
				end

				--dump(isWatchAD_ls , "<color=red>-----isWatchAD_ls-----</color>")

	    		if SYSQXManager.IsNeedWatchAD() and isWatchAD_ls then
		    		GetQXPrefab.Create(parm)
	    		else
	    			old_SendGetAward(parm.panelSelf)
	    		end
			end
			parm.panelSelf.SendGetAward = new_SendGetAward
	    end
	else
		C.MyRefresh(parm)
	end
end
function C.MyRefresh(parm)
	-- print("<color=red>扩展脚本走到了刷新</color>")
	-- print(debug.traceback())
	-- local tag_vec_map = SYSQXManager.m_data.tag_vec_map

	-- if parm.key == "dh" then
    -- 	if not SYSQXManager.IsNeedWatchAD() and parm.panelSelf.ext_model.data.exchange_hongbao then
	-- 		local rr = parm.panelSelf.ext_model.data.exchange_hongbao.hong_bao2
	-- 		if IsEquals(parm.panelSelf.ExChongbao) then
	-- 			parm.panelSelf.ExChongbao.text = StringHelper.ToRedNum(rr / 100)
	-- 		end
	-- 	end
	-- end
end


