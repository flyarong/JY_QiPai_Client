local basefunc = require "Game/Common/basefunc"
Act_026_SJYYSManager = {}
local M = Act_026_SJYYSManager
M.key = "act_026_sjyys"
GameButtonManager.ExtLoadLua(M.key, "Act_026_SJYYSPanel") 
GameButtonManager.ExtLoadLua(M.key, "Act_026_SJYYSPanel_Out") 
local lister
local m_data
local activity_id_year = 119
local activity_id_game = 169
local activity_ID_game = 169
local is_yy = false
local end_time = 1601308799
local start_time = 1600731000
local match_start_time = 1601384400
local match_day_time = 1601308800--比赛当天零点,比如比赛当天是5月1日21:00点.那么这个值就是5月1日00:00点
function M.CheckIsShow()
	return true
end

function M.GotoUI(parm)
    if parm.goto_scene_parm == "panel" then
        return Act_026_SJYYSPanel.Create(parm.parent)
    elseif parm.goto_scene_parm == "panel_out" then
        return Act_026_SJYYSPanel_Out.Create(parm.parent)
    elseif parm.goto_scene_parm == "enter" then
        
    else
        dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
    end
end

local function AddLister()
    for msg, cbk in pairs(lister) do
        Event.AddListener(msg, cbk)
    end
end

local function RemoveLister()
    if lister then
        for msg, cbk in pairs(lister) do
            Event.RemoveListener(msg, cbk)
        end
    end
    lister = nil
end
local function MakeLister()
    lister = {}
    lister["OnLoginResponse"] = M.SendQuery
	lister["act_match_order_msg_change"] = M.on_act_match_order_msg_change
    lister["query_gns_ticket_response"] = M.SetData
    lister["PPC_Created"] = M.on_PPC_Created
    lister["JBS_Created"] = M.on_JBS_Created
    lister["get_gns_ticket_response"] = M.on_get_gns_ticket_response
end

function M.Init()
    M.Exit()
    m_data = {}
    MakeLister()
    AddLister()
end

function M.Exit()
    if M then
        RemoveLister()
    end
end

function M.SetData(_,data)
    dump(data,"<color=red>美的冰箱品牌赛预约</color>")
    if data and data.result == 0 then 
		if data.status == 1 then 
			is_yy = true
		else
			is_yy = false
		end 
        Event.Brocast("global_hint_state_change_msg",{gotoui = M.key})   
    end
end
function M.on_get_gns_ticket_response( ... )
    Event.Brocast("global_hint_state_change_msg",{gotoui = M.key})   
end

function M.SendQuery(result)
    if result == 0 then
        Network.SendRequest("query_gns_ticket")
    end
end

function M.GetData()
    if table_is_null(m_data) then
        return nil
    end
    return m_data
end

function M.on_act_match_order_msg_change(data)
    if  os.time() > start_time and os.time() < end_time then
        --dump(data,"<color=red>on_act_match_order_msg_change</color>")
        --分页红点处理
        if data.config and data.GetImage then
            if data.config and data.config.ID == activity_id_year then 
                if M.IsYuYue() then 
                    data.GetImage:GetComponent("Image").sprite = GetTexture("hall_icon_lfl")
                    data.GetImage:GetComponent("Image"):SetNativeSize()   
                    data.GetImage.gameObject:SetActive(false)                
                else
                    data.GetImage:GetComponent("Image").sprite = GetTexture("hall_icon_lmp")
                    data.GetImage:GetComponent("Image"):SetNativeSize() 
                    data.GetImage.gameObject:SetActive(true)                          
                end 
            end 
        end

        if data.config_game and data.GetImage_game then
            -- dump(activity_ID_game,"<color=yellow>++++++++++++++++++++++++++</color>")
            if data.config_game and data.config_game.ID == activity_ID_game then 
                if M.IsYuYue() then 
                    data.GetImage_game:GetComponent("Image").sprite = GetTexture("hall_icon_lfl")
                    data.GetImage_game:GetComponent("Image"):SetNativeSize()   
                    data.GetImage_game.gameObject:SetActive(false)                
                else
                    data.GetImage_game:GetComponent("Image").sprite = GetTexture("hall_icon_lmp")
                    data.GetImage_game:GetComponent("Image"):SetNativeSize() 
                    data.GetImage_game.gameObject:SetActive(true)                          
                end 
            end 
        end

        --分页排序处理
        if data.year_activityList then 
            if M.IsYuYue() then 
               for i=1,#data.year_activityList do
                    if data.year_activityList[i].configId == activity_id_year then 
                        table.insert(data.year_activityList,data.year_activityList[i])
                        table.remove(data.year_activityList,i)
                        break
                    end 
               end
            end
            dump(data.year_activityList)
        end
        --分页排序处理
        if data.game_activityList then
            if M.IsYuYue() then 
               for i=1,#data.game_activityList do
                    if data.game_activityList[i].configId == activity_id_game then 
                        table.insert(data.game_activityList,4,data.game_activityList[i])
                        table.remove(data.game_activityList,i)
                        break
                    end 
               end
            end
            dump(data.game_activityList)
        end

         --大厅按钮的提示处理
         if data.ButtonGet then 
            --if MainModel.UserInfo.ui_config_id == 1 then return end
            if SYSACTBASEManager.GetHintState() ~= ACTIVITY_HINT_STATUS_ENUM.AT_Get then 
                if M.IsYuYue() then 
                    data.ButtonGet.sprite = GetTexture("hall_icon_lfl")
                else
                    data.ButtonGet.gameObject:SetActive(true)
                    data.ButtonGet.sprite = GetTexture("hall_icon_lmp")
                    data.ButtonGet:SetNativeSize()
                end 
            else
                data.ButtonGet.sprite = GetTexture("hall_icon_lfl")
            end 
        end

        if data.ButtonGet_Game then      
            if MainModel.UserInfo.ui_config_id == 1 then return end
            if not GameActivityManager.GetActiveGetHint() then 
                if M.IsYuYue() then 
                    data.ButtonGet_Game.sprite = GetTexture("hall_icon_lfl")
                else
                    data.ButtonGet_Game.gameObject:SetActive(true)
                    data.ButtonGet_Game.sprite = GetTexture("hall_icon_lmp")
                    data.ButtonGet_Game:SetNativeSize()
                end 
            else
                data.ButtonGet_Game.sprite = GetTexture("hall_icon_lfl")
            end 
        end
    end  
    --只在当日做变化
    if os.time() > match_day_time and os.time() < match_start_time then 
    --大厅跳转
        if data.goto_parm then 
            data.goto_parm.match_type_id = 9 
        end 
    --大厅界面处理 
        if data.hall_img then
            data.hall_img.sprite = GetTexture("wyfls_imgf_fls")
            data.hall_img:SetNativeSize()
            data.hall_img.gameObject.transform.parent.transform:Find("@qys_jb_img").gameObject:SetActive(true)    
            data.hall_img.gameObject.transform.parent.transform:Find("@qys_jb_img/bmsj").gameObject:SetActive(false)    

            local QYBox = data.hall_img.gameObject.transform.parent.transform:Find("@QYBox")
            if not IsEquals(QYBox) then
                QYBox = data.hall_img.gameObject.transform.parent.transform:Find("@QYSBox1")
            end
            if IsEquals(QYBox) then
                QYBox = QYBox:GetComponent("PolygonClick")
                QYBox.PointerClick:RemoveAllListeners()
                QYBox.PointerClick:AddListener(function (obj)
                    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
                    MatchModel.SetCurHallType(MatchModel.HallType.hks)
                    local goto_scene_parm = {hall_type = MatchModel.HallType.hks, down_style={panel=obj.transform.parent.transform}}
                    --年末回馈修改UI
                    Event.Brocast("act_match_order_msg_change",{goto_parm = goto_scene_parm})
                    local parm = {
                        gotoui = GameConfigToSceneCfg.game_MatchHall.SceneName,
                        goto_scene_parm = goto_scene_parm,
                    }
                    GameManager.GotoUI(parm)
                end)
            end
        end 
    end 
end

function M.IsYuYue()
    return is_yy
end

function M.on_PPC_Created()
    if os.time() > start_time and os.time() < end_time then
        if not is_yy and MainModel.GetHBValue() >= 1 then 
            local newtime = tonumber(os.date("%Y%m%d", os.time()))
            local oldtime = tonumber(os.date("%Y%m%d", tonumber(PlayerPrefs.GetString(M.key .. MainModel.UserInfo.user_id, 0))))
            if oldtime ~= newtime then
                Act_026_SJYYSPanel_Out.Create()
                PlayerPrefs.SetString(M.key .. MainModel.UserInfo.user_id, os.time())
            end
        end
    end 
end

function M.on_JBS_Created()
    if os.time() > start_time and os.time() < end_time then
        if not is_yy and MainModel.GetHBValue() >= 1 then 
            local newtime = tonumber(os.date("%Y%m%d", os.time()))
            local oldtime = tonumber(os.date("%Y%m%d", tonumber(PlayerPrefs.GetString(M.key .. MainModel.UserInfo.user_id.."jbs", 0))))
            if oldtime ~= newtime then
                Act_026_SJYYSPanel_Out.Create()
                PlayerPrefs.SetString(M.key .. MainModel.UserInfo.user_id.."jbs", os.time())
            end
        end
    end 
end

function M.GetMatchStartTime()
    return match_start_time
end

function M.IButton()
    
end