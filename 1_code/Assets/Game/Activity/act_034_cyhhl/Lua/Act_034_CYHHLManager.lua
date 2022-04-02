-- 创建时间:2
--05-06
-- Act_012_LMLHManager 管理器

local basefunc = require "Game/Common/basefunc"
Act_034_CYHHLManager = {}
local M = Act_034_CYHHLManager
M.key = "act_034_cyhhl"
Act_034_CYHHLManager.config = GameButtonManager.ExtLoadLua(M.key,"act_034_cyhhl_config")
GameButtonManager.ExtLoadLua(M.key,"Act_034_CYHHLItemBase")
GameButtonManager.ExtLoadLua(M.key,"Act_034_CYHHLPanel")
local btn_gameObject

local this
local lister
local gift_ids
local gift_data = {}
M.item_key = "prop_chongyang_chrysanthemum"

-- 是否有活动
function M.IsActive()
    -- 活动的开始与结束时间
    local e_time = 2603728000
    local s_time = 603150200
    if (e_time and os.time() > e_time) or (s_time and os.time() < s_time) then
        return false
    end
    return true
end

-- 创建入口按钮时调用
function M.CheckIsShow()
    if M.IsActive() then
        return true
    end
end
-- 活动面板调用
function M.CheckIsShowInActivity()
    return M.IsActive()
end

-- 所有可以外部创建的UI
function M.GotoUI(parm)
    if parm.goto_scene_parm == "panel" then
        if M.CheckIsShow() then
            return Act_034_CYHHLPanel.Create(parm.parent,parm.backcall)
        end 
    else
        dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
    end
end
-- 活动的提示状态
function M.GetHintState(parm)
	if parm and parm.gotoui == M.key then
        if M.IsItemCanGet() and false then
            return ACTIVITY_HINT_STATUS_ENUM.AT_Get
        else
            local newtime = tonumber(os.date("%Y%m%d", os.time()))
            local oldtime = tonumber(os.date("%Y%m%d", tonumber(PlayerPrefs.GetString(M.key .. MainModel.UserInfo.user_id, 0))))
            if oldtime ~= newtime then
                return ACTIVITY_HINT_STATUS_ENUM.AT_Red
            end
            return ACTIVITY_HINT_STATUS_ENUM.AT_Nor
        end
    end
end


function M.on_global_hint_state_set_msg(parm)
	if parm.gotoui == M.key then
		M.SetHintState()
        Event.Brocast("global_hint_state_change_msg", parm)
	end
end

function M.Refresh_Status()
    Event.Brocast("global_hint_state_change_msg",{gotoui = M.key})
end

-- 更新活动的提示状态(针对那种 打开界面就需要修改状态的需求)
function M.SetHintState()
    PlayerPrefs.SetString(M.key .. MainModel.UserInfo.user_id, os.time())
end


local function AddLister()
    for msg,cbk in pairs(lister) do
        Event.AddListener(msg, cbk)
    end
end

local function RemoveLister()
    if lister then
        for msg,cbk in pairs(lister) do
            Event.RemoveListener(msg, cbk)
        end
    end
    lister=nil
end
local function MakeLister()
    lister = {}
    lister["OnLoginResponse"] = this.OnLoginResponse
    lister["ReConnecteServerSucceed"] = this.OnReConnecteServerSucceed
    lister["global_hint_state_set_msg"] = this.on_global_hint_state_set_msg
    lister["AssetChange"] = this.OnAssetChange
    lister["year_btn_created"] = this.on_year_btn_created

    lister["client_system_variant_data_change_msg"] = this.on_client_system_variant_data_change_msg

    lister["query_gift_bag_status_response"] = this.on_query_gift_bag_status_response
    lister["activity_exchange_response"] = this.on_activity_exchange_response
    lister["finish_gift_shop"] = this.on_finish_gift_shop
end

function M.Init()
	M.Exit()

	this = Act_034_CYHHLManager
	this.m_data = {}
	MakeLister()
    AddLister()
    M.InitUIConfig()
    MainModel.AddUnShow(function(type)
        if type == "task_p_034_chongyang" then
            return true
        end
    end)
end
function M.Exit()
    M.Stop_Query_data()
	if this then
		RemoveLister()
		this = nil
	end
end

function M.InitUIConfig()
    gift_ids = {}
    for i=1,#M.config.Info do
        gift_ids[i] = M.config.Info[i].ID
    end
end


function M.OnLoginResponse(result)
	if result == 0 then
        -- 数据初始化s
        if M.IsActive() then
            Timer.New(function ()
                M.query_data()
            end, 1, 1):Start()
        end
	end
end
function M.OnReConnecteServerSucceed()
end

function M.Refresh()
    Event.Brocast("global_hint_state_change_msg",{gotoui = M.key})--刷新enter
    Event.Brocast("model_lxdh_data_change_msg")--刷新panel
end

function M.IsItemCanGet()
    local item = M.GetItemCount()
    for k,v in ipairs(gift_ids) do
        if gift_data and gift_data[v] and gift_data[v] and gift_data[v] > 0 and item >= tonumber(M.config.Info[k].item_cost_text)  then
            return k
        end
    end
end

function M.GetItemCount()
    return GameItemModel.GetItemCount(M.item_key)
end

function M.QueryGiftData()
    if not this.m_data.time then
        this.m_data.time = 0
    end
    if gift_data and (os.time() - this.m_data.time < 5) then
        Event.Brocast("model_lxdh_data_change_msg")
    else
        M.query_data()
    end
end

function M.GetCurData()
    local _cur_data = {}
    for i=1,#M.config.Info do
        _cur_data[i] = {}
        _cur_data[i].ID = M.config.Info[i].ID--ID
        _cur_data[i].award_name = M.config.Info[i].award_name--奖励的名字
        _cur_data[i].award_image = M.config.Info[i].award_image--奖励的图片
        _cur_data[i].item_cost_text = M.config.Info[i].item_cost_text--道具消耗text
        _cur_data[i].type = M.config.Info[i].type--实物奖励为1,普通奖励为0   
        _cur_data[i].wuxian = M.config.Info[i].wuxian        
        if M.config.Info[i].tips then
            _cur_data[i].tips = M.config.Info[i].tips--奖励特殊描述
        end

        if gift_data[_cur_data[i].ID] then
            --_cur_data[i].status = gift_data[_cur_data[i].gift_id].status
            _cur_data[i].remain_time = gift_data[_cur_data[i].ID]
        else
            --_cur_data[i].status = 0
            _cur_data[i].remain_time = 0
        end
    end
    dump(_cur_data,"<color>+++++++++++++++_cur_data++++++++++++</color>")
    return _cur_data
end


function M.on_client_system_variant_data_change_msg()
    M.IsActive()
    if M.now_level then
        M.query_data()
    end
end


function M.on_query_gift_bag_status_response(_,data)
    dump(data,"<color>+++++++on_query_gift_bag_status_response++++++</color>")
    if data then
        if data.result == 0 then
            this.m_data.time = os.time()
            gift_data[data.gift_bag_id] = data.remain_time
            M.Refresh_Status()
            Event.Brocast("model_lxdh_data_change_msg")
        else
            M.Query_data_timer(false)
        end
    end
end

function M.query_data()
    if M.IsActive() then
        for i = 1,#gift_ids do
            Network.SendRequest("query_gift_bag_status",{gift_bag_id = gift_ids[i]})
        end
    end
end

function M.Query_data_timer(b)
    M.Stop_Query_data()
    if b then
        M.timer1 = Timer.New(function ()
            M.query_data()
            end, 15, -1, false)
        M.timer1:Start()
    end
end

function M.Stop_Query_data()
    if M.timer1 then
        M.timer1:Stop()
        M.timer1 = nil
    end
end

function M.on_finish_gift_shop(id)
    if id then
        if gift_data[id] then
            local cfg = M.GetCFGByShopID(id)
            if cfg then
                if cfg.wuxian ~= 1 then
                    gift_data[id] =  gift_data[id] - 1
                    Event.Brocast("model_lxdh_data_change_msg")
                end     
            end       
        end
    end
end


function M.on_year_btn_created(data)
    if data and data.enterSelf then
        btn_gameObject = data.enterSelf.gameObject
    end
end

function M.FlyAnim(obj)
    if not IsEquals(btn_gameObject) then return end
    if not IsEquals(obj) then return end
   
    local a  = obj.transform.position
    local b  = btn_gameObject.transform.position
    --path[2] = Vector3.New(0,0,0)
    
    if true then
        local targetV3 = btn_gameObject.transform.position
        local seq = DoTweenSequence.Create({dotweenLayerKey = M.key})
        local path = {}
        path[0] = a
        path[1] = Vector3.New(0,0,0)
        seq:Append(obj.transform:DOLocalPath(path,2,DG.Tweening.PathType.CatmullRom))
        seq:AppendInterval(1.6)
        local path2 = {}
        path2[0] = Vector3.New(0,0,0)
        path2[1] = Vector3.New(b.x - 30,b.y + 30 ,0)
        seq:Append(obj.transform:DOLocalPath(path2,2,DG.Tweening.PathType.CatmullRom))
		seq:OnKill(function ()
			if IsEquals(btn_gameObject) and IsEquals(obj) then 
                --obj.transform.position = Vector3.New(path[2].x,path[2].y,path[2].z)
                local temp_ui = {}
                LuaHelper.GeneratingVar(obj.transform, temp_ui)
                temp_ui.Image.gameObject:SetActive(false)
                temp_ui.glow_01.gameObject:SetActive(false)
                temp_ui.num_txt.gameObject:SetActive(true)
                Timer.New(function ()
                    if IsEquals(obj) then
                        destroy(obj)
                    end
                end,2,1):Start()
			end 
		end)
    end
end

function M.OnAssetChange(data)
    Event.Brocast("global_hint_state_change_msg",{gotoui = M.key})
    if data.change_type and data.change_type == "task_p_034_chongyang" then
        print("<color=red>KKKKKKKKKKKKKKKKKKKKKKKKKK</color>")
        M.PrefabCreator(data.data[1].value)
    end
end

function M.PrefabCreator(value)
    if not IsEquals(btn_gameObject) then return end
    local temp_ui = {}
    local can_auto = true
    local can_click = true
    local obj = newObject("Act_034_CYHHLFLYPrefab",GameObject.Find("Canvas/LayerLv50").transform)
    math.randomseed(tostring(os.time()):reverse():sub(1, 7))
    obj.transform.position = Vector3.New(0,550,0)
    LuaHelper.GeneratingVar(obj.transform, temp_ui)
    temp_ui.num_txt.text = "+"..value
    temp_ui.yes_btn.onClick:AddListener(function ()
        if can_click then
            -- M.FlyAnim(obj)
            -- can_auto = false
        end
    end)
    local t = Timer.New(function ()
        if can_auto then
            M.FlyAnim(obj)
            can_click = false
        end
    end,1,1)
    t:Start()
end


function M.GetCFGByShopID(ShopID)
    for i = 1,#M.config.Info do
        if M.config.Info[i].ID == ShopID then
            return M.config.Info[i]
        end
    end
end