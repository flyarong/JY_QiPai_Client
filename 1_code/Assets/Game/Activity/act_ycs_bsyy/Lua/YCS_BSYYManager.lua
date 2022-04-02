local basefunc = require "Game/Common/basefunc"
YCS_BSYYManager = {}
local M = YCS_BSYYManager
M.key = "act_ycs_bsyy"
GameButtonManager.ExtLoadLua(M.key, "YCS_BSYYPanel") 
local lister
local m_data
local activity_id = 43
local is_yy = false
function M.CheckIsShow()
	return true
end

function M.GotoUI(parm)
    if parm.goto_scene_parm == "panel" then
        if GameActivityPanel.instance == nil then 
            return SYSACTBASEManager.CreateHallAct(parm.parent,parm.backcall,{ID= GameActivityModel.GetIdByTitle("周年预约有礼")})	
        else
            return YCS_BSYYPanel.Create(parm.parent)
        end 
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
    dump(data,"<color=red>开工大吉赛预约</color>")
    if data and data.result == 0 then 
		if data.status == 1 then 
			is_yy = true
		else
			is_yy = false
		end 
    end
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
    if MainModel.UserInfo.ui_config_id == 1 and os.time() > 1580167800 and os.time() < 1580562000 then
        dump(data,"<color=red>on_act_match_order_msg_change</color>")
        --分页处理
        if data.config and data.GetImage then
            if data.config and data.config.ID == activity_id then 
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
        --分页排序处理
        if data.activityList then 
            if M.IsYuYue() then 
               for i=1,#data.activityList do
                    if data.activityList[i].configId == activity_id then 
                        table.insert(data.activityList,data.activityList[i])
                        table.remove(data.activityList,i)
                        break
                    end 
               end
            end
            dump(data.activityList)
        end
        --只在当日做变化
        if os.time() > 1580486400 and os.time() < 1580562000 then 
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
            --大厅跳转
            if data.goto_parm then 
                data.goto_parm.hall_type = MatchModel.HallType.hks 
            end 
            --大厅界面处理 
            if data.hall_img then
                data.hall_img.sprite = GetTexture("hall_imgf_kgs")
                data.hall_img.gameObject.transform.parent.transform:Find("@qys_jb_img").gameObject:SetActive(true)    
                data.hall_img.gameObject.transform.parent.transform:Find("@qys_jb_img/bmsj").gameObject:SetActive(false)    
            end 
        end 
    end  
end

function M.IsYuYue()
    return is_yy
end
