-- 创建时间:2018-11-06
local vip_cfg = {}
VIPManager = {}
local M = VIPManager
M.key = "vip"
local vip_showinfo_cfg = GameButtonManager.ExtLoadLua(M.key, "vip2_config")
GameButtonManager.ExtLoadLua(M.key, "VIPExtManager")
GameButtonManager.ExtLoadLua(M.key, "VipShowTaskPanel")
GameButtonManager.ExtLoadLua(M.key, "VIPEnterPrefab")
GameButtonManager.ExtLoadLua(M.key, "VipShowInfoPanel")
GameButtonManager.ExtLoadLua(M.key, "VIPPayPrefab")
GameButtonManager.ExtLoadLua(M.key, "VIPShowWealPanel")
GameButtonManager.ExtLoadLua(M.key, "VIPHintPanel")
GameButtonManager.ExtLoadLua(M.key, "VIPUPPanel")

--测试 VipShowTaskPanel2
GameButtonManager.ExtLoadLua(M.key, "VipShowTaskPanel2")
GameButtonManager.ExtLoadLua(M.key, "VipShowYJTZPanel")
GameButtonManager.ExtLoadLua(M.key, "VipShowLBPanel")
GameButtonManager.ExtLoadLua(M.key, "VipShowTQPanel")
GameButtonManager.ExtLoadLua(M.key, "VipShowMZFLPanel")
GameButtonManager.ExtLoadLua(M.key, "VipShowMXBPanel")
GameButtonManager.ExtLoadLua(M.key, "VipShowQYSPanel")
GameButtonManager.ExtLoadLua(M.key, "VipShowZZLBPanel")
GameButtonManager.ExtLoadLua(M.key, "VIPLJYJ88GetPanel")
GameButtonManager.ExtLoadLua(M.key, "VIPSWGetPanel")
GameButtonManager.ExtLoadLua(M.key, "VIPNoticetPanel")
GameButtonManager.ExtLoadLua(M.key, "VIP1NoticetPanel")


local vip_up_cfg = GameButtonManager.ExtLoadLua(M.key, "vip_up_config")

local permission_hb_limit = GameButtonManager.ExtLoadLua(M.key, "permission_hb_limit")

--VIP任务类型
VIP_TASK_TYPE = {
    day = 1,
    level = 2,
    gold = 3,
    match = 4,
    week = 5,
}

VIP_CONFIG_TYPE = {
    dangci = "dangci",
    task = "task",
    level = "level",
}

M.CanGetStatus = {
    vip2 = false,
}

function M.CheckIsShow()
    return true
end

function M.GotoUI(parm)
    if parm.goto_scene_parm == "vip_task" then
        return VipShowTaskPanel2.Create(nil,{gotoui = "viptq"})
    elseif parm.goto_scene_parm == "vip_task_match" then
        local is_have = MatchModel.IsTodayHaveMatchByType("mxb")
        local vip_level = VIPManager.get_vip_level()
        parm.goto_scene_parm1 = "mxb"
        if is_have and vip_level > 3 then
            return VipShowTaskPanel2.Create(nil,{gotoui = "vipmxb"})
        end
    elseif parm.goto_scene_parm == "info" then
        return VipShowInfoPanel.Create()
    elseif parm.goto_scene_parm == "VIP2" then
        local v = M.get_vip_level()
        if v > 0 then
            return VipShowInfoPanel.Create()
        else
            return VIPShowWealPanel.Create()
        end
    elseif parm.goto_scene_parm == "enter" then
        return VIPEnterPrefab.Create(parm.parent, parm.cfg)
    elseif parm.goto_scene_parm == "hint" then
        return VIPHintPanel.Create(parm.data)
    elseif parm.goto_scene_parm == "notice" then
        if PlayerPrefs.GetInt(MainModel.UserInfo.user_id.."vip10",0) == 0 and VIPManager.get_vip_level() == 10  then
            PlayerPrefs.SetInt(MainModel.UserInfo.user_id.."vip10",1)
            return VIPNoticetPanel.Create()
        end
    else
        dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
    end
end

local this
local m_data
local lister
local function MakeLister()
    lister = {}
    lister["HallModelInitFinsh"] = this.HallModelInitFinsh
    lister["PayPanelCreate"] = this.PayPanelCreate
    lister["PayPanelClosed"] = this.PayPanelClosed

    lister["query_vip_base_info_response"] = this.query_vip_base_info_response
    lister["vip_upgrade_change_msg"] = this.on_vip_upgrade_change_msg

    lister["model_query_task_data_response"] = this.on_task_req_data_response
    lister["model_get_task_award_response"] = this.on_get_task_award_response
    lister["model_task_change_msg"] = this.on_task_change_msg
    lister["model_query_one_task_data_response"] = this.model_query_one_task_data_response

    lister["on_player_hb_limit_convert"] = this.on_player_hb_limit_convert
    
    --比赛场报名VIP限制
	lister["MatchHallMatchItemCreate"] = this.MatchHallMatchItemCreate
end

local function AddLister()
    for msg,cbk in pairs(lister) do
        Event.AddListener(msg, cbk)
    end
end
local function RemoveLister()
    if lister == nil then return end
    for msg,cbk in pairs(lister) do
        Event.RemoveListener(msg, cbk)
    end
    lister=nil
end
local function InitData()
	M.data={}
	m_data = M.data
end
function M.Init()
    M.Exit()
    print("<color=red>VIP初始化>>>>>>>>>>>>>>>>>>>>>>>>>>>></color>")
    this=M
    vip_cfg = this.InitCfg(vip_showinfo_cfg)
    this.Config = {}
    this.Config.hb_limit_map = permission_hb_limit.main
    for k,v in pairs(this.Config.hb_limit_map) do
        if not this.Config.min_hb_limit or this.Config.min_hb_limit > v.hb_limit then
            this.Config.min_hb_limit = v.hb_limit
        end
        if not this.Config.max_hb_limit or this.Config.max_hb_limit < v.hb_limit then
            this.Config.max_hb_limit = v.hb_limit
        end
    end
    InitData()
    MakeLister()
    AddLister()
    return this
end

function M.Exit()
    if this then
        RemoveLister()
        m_data=nil
        this=nil
    end
end

function M.InitCfg(cfg)
    local m_cfg = {}
    m_cfg.dangci = {}
    for i,v in ipairs(cfg.dangci) do
        if not m_cfg.dangci[v.vip] then
            m_cfg.dangci[v.vip] = {}
        end
        m_cfg.dangci[v.vip].xycj = v.xycj
        m_cfg.dangci[v.vip].total = v.total
        m_cfg.dangci[v.vip].help = v.help
        m_cfg.dangci[v.vip].cfz = v.cfz
        if not m_cfg.dangci[v.vip].info then
            m_cfg.dangci[v.vip].info = {}
        end
        m_cfg.dangci[v.vip].info[#m_cfg.dangci[v.vip].info + 1] = {desc = v.info, gotoUI = v.gotoUI}
    end
    m_cfg.task = {}
    for i,v in ipairs(cfg.task) do
        m_cfg.task[v.id] = v
    end
    m_cfg.level = {}
    for i,v in ipairs(cfg.level) do
        m_cfg.level[v.level] = v
    end
    m_cfg.lb = {}
    for i,v in ipairs(cfg.lb) do
        m_cfg.lb[v.index] = v
    end
    m_cfg.yjtz = {}
    for i,v in ipairs(cfg.yjtz) do
        m_cfg.yjtz[v.index] = v
    end
    m_cfg.qys = {}
    for i,v in ipairs(cfg.qys) do
        m_cfg.qys[v.index] = v
    end
    m_cfg.vipmzfl = {}
    for i,v in ipairs(cfg.vipmzfl) do
        m_cfg.vipmzfl[v.index] = v
    end
    m_cfg.yjtz_new = {}
    for i,v in ipairs(cfg.yjtz_new) do
        m_cfg.yjtz_new[v.index] = v
    end
    m_cfg.yjtz_three = {}
    for i,v in ipairs(cfg.yjtz_three) do
        m_cfg.yjtz_three[v.index] = v
    end
    return m_cfg
end

function M.GetVIPCfgByType(type)
    if type then
        return vip_cfg[type]
    end
    return vip_cfg
end

function M.GetVIPCfg()
    return vip_cfg
end

function M.HallModelInitFinsh()
    print("<color=yellow>请求VIP数据</color>")
    Network.SendRequest("query_vip_base_info", nil,"请求VIP数据")
    M.set_vip_task()
    M.ChangeTaskCanGetRedHint()
    dump(m_data.vip_task, "<color=yellow>VIP任务数据</color>")
end

function M.PayPanelCreate(tf)
    if GameGlobalOnOff.VIPGift then
        VIPPayPrefab.Create(tf)
    end
end

function M.PayPanelClosed(tf)
    if GameGlobalOnOff.VIPGift then
        VIPPayPrefab.Close()
    end
end

function M.query_vip_base_info_response(_,data)
    dump(data, "<color=white>query_vip_base_info_response</color>")
    if data.result == 0 then
        m_data.vip_data = data
        Event.Brocast("model_query_vip_base_info_response")
    else
        HintPanel.ErrorMsg(data.result)
    end
end

function M.on_vip_upgrade_change_msg(_,data)
	if not GameGlobalOnOff.Vip then return end

    dump(data, "<color=white>on_vip_upgrade_change_msg</color>")
    local up_data = {prev = MainModel.UserInfo.vip_level,cur = data.vip_level}
    if data.vip_level - MainModel.UserInfo.vip_level > 0 then
        VIPUPPanel.Create(up_data)
    end
    m_data.vip_data = data
    MainModel.UserInfo.vip_level = data.vip_level
    Event.Brocast("model_vip_upgrade_change_msg",m_data.vip_data)

    Event.Brocast("trace_honor_msg", {honor_id = 10001, vip_level = data.vip_level})

    M.MatchHallMatchItemDestroy()
end

--重新初始化VIP任务数据
function M.on_task_req_data_response()
    M.set_vip_task()
    M.ChangeTaskCanGetRedHint()
    dump(m_data.vip_task, "<color=white>on_task_req_data_response</color>")
end

function M.on_get_task_award_response(data)
    if not M.check_is_vip_task(data.id) then return end
    dump(data, "<color=white>on_get_task_award_response</color>")
    --这里 GameTaskModel 会处理
end

function M.on_task_change_msg(data)
    if not M.check_is_vip_task(data.id) then return end
    dump(data, "<color=white>on_task_change_msg__________________</color>")
    m_data.vip_task = m_data.vip_task or {}
    m_data.vip_task[data.id] = data
    M.ChangeTaskCanGetRedHint()
    Event.Brocast("model_vip_task_change_msg",data)
end

function M.model_query_one_task_data_response(data)
    if not M.check_is_vip_task(data.id) then return end
    dump(data, "<color=white>model_query_one_task_data_response_________________</color>")
    m_data.vip_task = m_data.vip_task or {}
    m_data.vip_task[data.id] = data
    M.ChangeTaskCanGetRedHint()
    Event.Brocast("model_vip_upgrade_change_msg",data)
end

function M.get_vip_level()
    local vl = MainModel.UserInfo.vip_level or 0
    return vl
end

function M.get_vip_data()
    return m_data.vip_data
end

function M.check_is_vip_task(task_id)
    if vip_cfg and vip_cfg.task then
        return vip_cfg.task[task_id]
    end
end

function M.set_vip_task()
    m_data.vip_task = {}
    local t = {}
    for k,v in pairs(vip_cfg.task) do
        t = GameTaskModel.GetTaskDataByID(k)
        m_data.vip_task[k] = t
    end
end

function M.get_vip_task(id)
    if table_is_null(m_data.vip_task) then
        M.set_vip_task()
    end
    if id then
        return m_data.vip_task[id]
    end
    return m_data.vip_task
end

function M.get_vip_task_by_type(type)
    if type then
        local t = {}
        for k,v in pairs(vip_cfg.task) do
            if v.type == type then
                table.insert(t, M.get_vip_task(k))
            end
        end
        return t
    end
    return m_data.vip_task
end

function M.set_vip_text(txt,vip_level)
    if not IsEquals(txt) then
        return
    end
    if GameGlobalOnOff.Vip then
	    if vip_level then
		txt.text = "VIP" .. vip_level
	    else
		txt.text = "VIP" .. M.get_vip_level()
	    end
	    txt.gameObject:SetActive(true)
    else
        txt.text = "VIP" .. M.get_vip_level()
    	txt.gameObject:SetActive(false)
    end
end

function M.set_vip_image(img)
    local cfg = M.GetVIPCfgByType(VIP_CONFIG_TYPE.level)[ M.get_vip_level()]
    img.sprite = GetTexture(cfg.head_img)
end

function M.ChangeTaskCanGetRedHint()
    if GameGlobalOnOff.VIPGift == true then
        M.CheckTaskCanGet()
        Event.Brocast("UpdateHallVIP2RedHint")
    end
end

--检测是否有可领取的任务
function M.CheckTaskCanGet()
    M.CanGetStatus.vip2 = false
    if m_data.vip_task then
        for k,v in pairs(m_data.vip_task) do
            if M.CanGetStatus.vip2 == false and v.id~=110  then
                if v.id == 21016 or v.id == 21017 or v.id == 21314 then 
                    if os.date("%w", os.time()) == "0"  then
                        M.CanGetStatus.vip2 = v.award_status == 1
                    end  
                else    
                    M.CanGetStatus.vip2 = v.award_status == 1
                end 
            end
            if M.CanGetStatus.vip2 then
                return M.CanGetStatus.vip2
            end
        end
    end
    return M.CanGetStatus.vip2
end

function M.MatchHallMatchItemCreate(obj)
	if not GameGlobalOnOff.Vip then return end

    M.match_item = M.match_item or {}
    local cfg = obj.config
    if cfg.game_type == MatchModel.GameType.game_DdzMatch or 
        cfg.game_type == MatchModel.GameType.game_MjXzMatch3D then
        --福卡赛特殊设置
        if cfg.game_id == 4 or cfg.game_id == 7 or cfg.game_id == 11 or cfg.game_id == 12 then
            local config = MatchModel.GetGameCfg(cfg.game_id)
            local itemkey, item_count = MatchModel.GetMatchCanUseTool(config.enter_condi_itemkey, config.enter_condi_item_count)
            --鲸币报名玩家
            if not itemkey or itemkey == "jing_bi" then
                local l = M.get_vip_level()
                local vip_limit = (cfg.game_id == 4 or cfg.game_id == 7) and 2 or 1 
                if (l < 1 and vip_limit ==  1) or (l < 2 and vip_limit ==  2) then
                    local item = newObject("VIPMatchHallMatchItem",obj.UINode.transform)
                    local tf = {}
                    LuaHelper.GeneratingVar(item.transform,tf)
                    tf.signup_btn.onClick:AddListener(function()
                        GameManager.GotoUI({gotoui="vip", goto_scene_parm="hint", data={desc="您的VIP等级不足，成为VIP"..vip_limit.."即可畅玩游戏高级场哦！",cw_btn_desc = "确定"}})
                        -- HintPanel.Create(1,"您的VIP等级不足，成为VIP1即可畅玩游戏高级场哦！",function(  )
                        --     PayPanel.Create(GOODS_TYPE.jing_bi)
                        --     DSM.PushAct({info = {vip = "vip_up"}})
                        -- end)
                    end)
                    tf.vip_txt.text = vip_limit
                    M.match_item[cfg.game_id]  = {obj = item,vip_limit = vip_limit}
                end
            end
        end
    end
end

function M.MatchHallMatchItemDestroy()
    if not table_is_null(M.match_item) then
        for k,v in pairs(M.match_item) do
            local l = M.get_vip_level()
            if l >= v.vip_limit then 
                if IsEquals(v.obj) then
                    destroy(v.obj)
                end
            end
            M.match_item[k] = nil
        end
    end
end

function M.GetHBLimit()
    local k = "player_vip_" .. M.get_vip_level()
    if this.Config.hb_limit_map[k] then
        return this.Config.hb_limit_map[k].hb_limit
    else
        print("<color=red>hb limit no find</color>")
        return this.Config.min_hb_limit or 0
    end
end

-- 检查福卡是否超出上限，可能超出就给提示
function M.CheckHBLimit(parm)
    local hb = parm.hb or 0 -- 本次操作可能获得的福卡数
    local call = parm.call
    local hb_limit = M.GetHBLimit()
    if (hb + MainModel.UserInfo.shop_gold_sum) > hb_limit then
        local desc = "您当前不可兑换，如兑换后那么福卡将超出上限！\n成为VIP后可增加携带福卡的上限！"
        VIPHintPanel.Create({desc=desc, type=2})
    else
        if call then
            call()
        end
    end
    return true
end

function M.on_player_hb_limit_convert(_, data)
    local hb_limit = M.GetHBLimit()
    local desc = string.format("您当前携带的福卡已达到上限:%s，超出的%s福卡将转换成%s鲸币！\n成为VIP后可增加福卡上限！",
                                StringHelper.ToMoneyNum(hb_limit), StringHelper.ToMoneyNum(data.shop_gold_change), StringHelper.ToCash(data.jing_bi_change))
    VIPHintPanel.Create({desc=desc, type=2, cw_cb = function (  )
        DSM.PushAct({info = {vip = "vip_up_hb_limit"}})
    end})
end

function M.get_vip_up_cfg(v_l)
    if v_l then
        return vip_up_cfg.vip_up[v_l]
    end
    return vip_up_cfg.vip_up
end


function M.CheakRed(button_gotoui)
    if button_gotoui == "viplb" then 
        return M.CheakRed_viplb()
    end
    if button_gotoui == "viptq" then 
        return M.CheakRed_viptq()
    end 
    if button_gotoui == "vipmzfl" then 
        return M.CheakRed_vipmzfl()
    end 
    if button_gotoui == "vipmxb" then 
        return  M.CheakRed_vipmxb()
    end 
    if button_gotoui == "vipyjtz" then 
        return  M.CheakRed_vipyjtz()
    end 
    if button_gotoui == "vipqys" then 
        return M.CheakRed_vipqys()
    end
    if button_gotoui == "vipzzlb" then
        return M.CheakRed_vipzzlb()
    end
    return false
end


function M.CheakRed_viplb()
    if M.get_vip_task(111) and M.get_vip_task(111).award_status == 1 then 
        return true
    else
        return false
    end   
end

function M.CheakRed_viptq()
    return false
end

function M.CheakRed_vipmzfl()
    if M.get_vip_task(21016) then 
        if M.get_vip_task(21016).award_status == 1 then 
            return true
        end 
    end
    if M.get_vip_task(21017) then 
        if M.get_vip_task(21017).award_status == 1 then 
            return true
        end
    end
    if M.get_vip_task(21314) then 
        if M.get_vip_task(21314).award_status == 1 then 
            return true
        end
    end
    return false 
end

function M.CheakRed_vipmxb()
    local is_have = MatchModel.IsTodayHaveMatchByType("mxb")
    if  is_have then 
        return true
    else
        return false
    end 
end

function M.CheakRed_vipyjtz()
    if (M.get_vip_task(112) and M.get_vip_task(112).award_status == 1) 
    or (M.get_vip_task(21243) and M.get_vip_task(21243).award_status == 1) 
    or (M.get_vip_task(21315) and M.get_vip_task(21315).award_status == 1) then 
        return true
    else
        return false
    end 
end

function M.CheakRed_vipqys()
    local QYSdata = {}
    for i = 1, 8 do
        QYSdata[i] =  M.get_vip_task(112 + i)
    end
    for k, v in pairs(QYSdata) do 
        if v and v.award_status == 1 then
            return true
        end 
    end
    return false 
end

function M.CheakRed_vipzzlb()
    local tasks = {21248,21249,21250,21551}
    local func = function (task_id)
        local data = GameTaskModel.GetTaskDataByID(task_id)
        if data and data.award_status == 1 then
            return true
        end
    end
    for i = 1,#tasks do
        if func(tasks[i]) then
            return true
        end
    end
    return false
end

function M.IsQuDaoChannel()
    local cheakfunc = function (_permission_key)
		if _permission_key then
			local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key=_permission_key, is_on_hint = true}, "CheckCondition")
			if a and not b then
				return false
			end
			return true
		else
			return false
		end
	end
	if cheakfunc("vip11_treasure_to_gift_remain_hard") then
		return true
    else
        return false
    end
end