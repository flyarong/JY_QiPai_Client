local basefunc = require "Game/Common/basefunc"
ACT_005BSYYManager = {}
local M = ACT_005BSYYManager
M.key = "act_005_bsyy"
GameButtonManager.ExtLoadLua(M.key, "ACT_005BSYYPanel") 
GameButtonManager.ExtLoadLua(M.key, "ACT_005BSYYPanel_Out") 
local lister
local m_data
local activity_id_year = 57
local activity_id_game = 111
local activity_ID_game = 122
local is_yy = false
function M.CheckIsShow()
	return true
end

function M.GotoUI(parm)
    if parm.goto_scene_parm == "panel" then
        return ACT_005BSYYPanel.Create(parm.parent)
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
    dump(data,"<color=red>月末福利赛预约</color>")
    if data and data.result == 0 then 
		if data.status == 1 then 
			is_yy = true
		else
			is_yy = false
		end 
    end
    Event.Brocast("global_hint_state_change_msg",{gotoui = M.key})   
end
function M.on_get_gns_ticket_response( ... )
    Event.Brocast("global_hint_state_change_msg",{gotoui = M.key})   
end

function M.SendQuery()
    Network.SendRequest("query_gns_ticket")
end

function M.GetData()
    if table_is_null(m_data) then
        return nil
    end
    return m_data
end

function M.on_act_match_order_msg_change(data)
    if  os.time() > 1585006200 and os.time() < 1585584000 then
        dump(data,"<color=red>on_act_match_order_msg_change</color>")
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
            if GameActivityManager.GetActiveGetHint() == false then 
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
    if os.time() > 1585584000 and os.time() < 1585659600 then 
    --大厅跳转
        if data.goto_parm then 
            data.goto_parm.hall_type = MatchModel.HallType.hks 
        end 
    --大厅界面处理 
        if data.hall_img then
            data.hall_img.sprite = GetTexture("ymfl_imgf_yms")
            data.hall_img.gameObject.transform.parent.transform:Find("@qys_jb_img").gameObject:SetActive(true)    
            data.hall_img.gameObject.transform.parent.transform:Find("@qys_jb_img/bmsj").gameObject:SetActive(false)    
        end 
    end 
end

function M.IsYuYue()
    return is_yy
end

function M.on_PPC_Created()
    if os.time() > 1585006200 and os.time() < 1585584000 then
        if not is_yy and MainModel.GetHBValue() >= 1 then 
            local newtime = tonumber(os.date("%Y%m%d", os.time()))
            local oldtime = tonumber(os.date("%Y%m%d", tonumber(PlayerPrefs.GetString(M.key .. MainModel.UserInfo.user_id, 0))))
            if oldtime ~= newtime then
                ACT_005BSYYPanel_Out.Create()
                PlayerPrefs.SetString(M.key .. MainModel.UserInfo.user_id, os.time())
            end
        end
    end 
end

function M.on_JBS_Created()
    if os.time() > 1585006200 and os.time() < 1585584000 then
        if not is_yy and MainModel.GetHBValue() >= 1 then 
            local newtime = tonumber(os.date("%Y%m%d", os.time()))
            local oldtime = tonumber(os.date("%Y%m%d", tonumber(PlayerPrefs.GetString(M.key .. MainModel.UserInfo.user_id.."jbs", 0))))
            if oldtime ~= newtime then
                ACT_005BSYYPanel_Out.Create()
                PlayerPrefs.SetString(M.key .. MainModel.UserInfo.user_id.."jbs", os.time())
            end
        end
    end 
end