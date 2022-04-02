-- 创建时间:2021-01-20
-- Template_NAME 管理器

local basefunc = require "Game/Common/basefunc"
Act_Ty_ExchangeManager = {}
local M = Act_Ty_ExchangeManager
M.key = "act_ty_exchange"
local config =  GameButtonManager.ExtLoadLua(M.key,"act_ty_exchange_config")
GameButtonManager.ExtLoadLua(M.key,"Act_Ty_ExchangeItemBase")
GameButtonManager.ExtLoadLua(M.key,"Act_Ty_ExchangePanel")

local this
local lister

local limit_icons = 
{
    "xqdh_icon_xl1_activity_act_042_yghhl",
    "xqdh_icon_xl2_activity_act_042_yghhl",
    "xqdh_icon_xl3_activity_act_042_yghhl"
}

-- 是否有活动
function M.IsActive()
    -- 活动的开始与结束时间
    local e_time
    local s_time
    if (e_time and os.time() > e_time) or (s_time and os.time() < s_time) then
        return false
    end

    -- 对应权限的key
    local _permission_key
    if _permission_key then
        local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key=_permission_key, is_on_hint = true}, "CheckCondition")
        if a and not b then
            return false
        end
        return true
    else
        return true
    end
end
-- 创建入口按钮时调用
function M.CheckIsShow(parm)
    
    if not M.IsActive() then
        return false
    end
    --dump(parm,"<cccccccccccccccccccccccccc>")
    if not M.IsExchangeActive(parm.goto_type) then
        dump(parm.goto_type,"<color=red>不在活动时间</color>")
        return false
    end

    return true
end
-- 活动面板调用
function M.CheckIsShowInActivity()
    return M.IsActive()
end

-- 所有可以外部创建的UI
function M.GotoUI(parm)
    --dump(parm,"<color=red>PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPARM</color>")
    if not M.CheckIsShow(parm) then
        return false
    end

    if parm.goto_scene_parm == "panel" then
        local exchange_key = parm.goto_type
        return Act_Ty_ExchangePanel.Create(parm.parent, exchange_key)
    end
end
-- Act_Ty_ExchangeManager.GetHintState({gotoui="act_ty_exchange",goto_type="exchange_xnhl"})
-- Event.Brocast("global_hint_state_change_msg", { gotoui = Act_Ty_ExchangeManager.key ,goto_type="exchange_xnhl"})
-- 活动的提示状态
function M.GetHintState(parm)
    if parm.gotoui ~= M.key then
        return 
    end

    local _exchange_key = parm.goto_type

    if not M.CheckIsShow(parm) then
        return ACTIVITY_HINT_STATUS_ENUM.AT_Nor
    end
    if M.IsCanGet(_exchange_key) then
        return ACTIVITY_HINT_STATUS_ENUM.AT_Get
    end

	return ACTIVITY_HINT_STATUS_ENUM.AT_Nor
end
function M.on_global_hint_state_set_msg(parm)
	if parm.gotoui == M.key then
		M.SetHintState()
end
end
-- 更新活动的提示状态(针对那种 打开界面就需要修改状态的需求)
function M.SetHintState()
    Event.Brocast("global_hint_state_change_msg", { gotoui = M.key })
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
    lister["query_activity_exchange_response"] = this.on_query_activity_exchange_response
    lister["finish_gift_shop"] = this.on_finish_gift_shop
    lister["model_task_change_msg"] = this.on_model_task_change_msg
    lister["AssetChange"] = this.on_asset_change
    lister["query_gift_bag_status_by_ids_response"] = this.on_query_gift_bag_status_by_ids_response
    lister["year_btn_created"] = this.on_year_btn_created
    lister["activity_exchange_response"] = this.on_activity_exchange_response
    --lister["ty_exchange_base_item_create_finish"] = this.on_base_item_creat
end

function M.Init()
	M.Exit()

	this = Act_Ty_ExchangeManager
    this.m_data = {}
    this.m_data.exchange_cfg = {}
    this.m_data.exchange_data = {}                      --每日的数据
    this.m_data.exchange_data_all = {}                  --总共的数据
	MakeLister()
    AddLister()
    M.InitExchangesCfg()
    M.AddUnShowAward()
    -- dump(this.m_data.exchange_cfg,"<color=red>Exchange_Cfg</color>")
    M.QueryAllExchanegData()
    M.InitUIConfig()
end
function M.Exit()
	if this then
		RemoveLister()
		this = nil
	end
end
function M.InitUIConfig()
    this.UIConfig = {}
end

function M.OnLoginResponse(result)
	if result == 0 then
        -- 数据初始化
	end
end
function M.OnReConnecteServerSucceed()
end

function M.InitExchangesCfg()
    this.m_data.exchange_cfg = {}
    for i = 1, #config.base do
        local cur_cfg = config.base[i]
        if cur_cfg.isOnOff == 1 then
            cur_cfg.exchanges = M.GetExchangeFromId(config.base[i].exchange_ids)
            this.m_data.exchange_cfg[cur_cfg.exchange_key] = cur_cfg
        end
    end
end

function M.InitExchangeData(exchange_key , _data)
    this.m_data.exchange_data[exchange_key] = _data
end

function M.InitExchangeDataAll(exchange_key, all_data)
    --dump({exchange_key = exchange_key,all_data = all_data},"<color=white>+++++InitExchangeDataAll+++++</color>")
    this.m_data.exchange_data_all[exchange_key] = all_data
end

function M.GetExchangeFromId(exchange_id)
    local cur_exchanges = {}
    for i = 1, #exchange_id do
        local id = exchange_id[i]
        cur_exchanges[#cur_exchanges + 1] = config.exchanges[id] 
    end
    return cur_exchanges
end

function M.GetExchangeCfg(exchange_key)
    if this.m_data.exchange_cfg[exchange_key] then
        return this.m_data.exchange_cfg[exchange_key]
    end
end

function M.GetExchangeData(exchange_key)
    -- dump(this.m_data.exchange_data, "<color=white>AAAAAAAAAAAAAAAAAAAAAAAAAA</color>")
    if this.m_data.exchange_data[exchange_key] then
        return this.m_data.exchange_data[exchange_key]
    end
end

--兑换活动的剩余次数 exchange_key = key值 ， _ID = 兑换的Id值
function M.GetRemainTime( exchange_key, _ID)
    local data = M.GetExchangeData(exchange_key)
    if data then
        return data[_ID]
    else
        return 0 
    end
end


function M.IsExchangeActive(exchange_key)
    if not M.GetExchangeCfg(exchange_key) then
        return false
    end
    --do return true end
    if not M.IsExchangeInTime(exchange_key)then
        return false
    end
    return true
end

function M.IsExchangeInTime(exchange_key)
    if M.GetExchangeCfg(exchange_key) then
        local cfg = M.GetExchangeCfg(exchange_key)
        return MathExtend.isTimeValidity(cfg.start_time, cfg.end_time)
    end
    return false
end

--针对那种配置有限制总的兑换数量的兑换
function M.IsAllExhcange(exchange_key,ID)
    --dump(this.m_data.exchange_data_all,"<color=red>+++++this.m_data.exchange_data_all+++++</color>")
    if M.GetExchangeCfg(exchange_key) then
       if this.m_data.exchange_data_all[exchange_key] then
           return this.m_data.exchange_data_all[exchange_key][ID] == 0
       end
    end
    return false
end

--请求所有的数据
function M.QueryAllExchanegData()
    for k, v in pairs(this.m_data.exchange_cfg) do
        if M.IsExchangeInTime(v.exchange_key) then
            if v.type == 1 then
                M.QueryExchangeData(v.exchange_type)  --兑换
            else
                M.QueryGiftData(v.exchange_key)  --礼包兑换
            end
        end
    end
end

--请求兑换数据
function M.QueryExchangeData(_exchange_type)
    Network.SendRequest("query_activity_exchange",{type = _exchange_type})
end

--请求礼包数据
function M.QueryGiftData(exchange_key)
    local cfg = M.GetExchangeCfg(exchange_key)
    local exchanges = M.GetExchangeFromId(cfg.exchange_ids)
    local gift_ids = {}
    for i = 1, #exchanges do
        gift_ids[#gift_ids + 1] = exchanges[i].gift_id
    end
    Network.SendRequest("query_gift_bag_status_by_ids",{gift_bag_ids = gift_ids})
    gift_ids = nil
end

---------------------------Get Key-----------------------------

function M.GetKeyFromExchangeType(_exchange_type)
    for k, v in pairs(this.m_data.exchange_cfg) do
        if v.exchange_type == _exchange_type then
            return k
        end
    end
end

function M.GetKeyFromItemKey(_item_key)
    local re_tab = {}
    for k, v in pairs(this.m_data.exchange_cfg) do
        if v.item_key == _item_key then
            re_tab[#re_tab + 1] = k
        end
    end
    return re_tab
end

function M.GetKeyFromGiftID(_gift_id)
    for k, v in pairs(this.m_data.exchange_cfg) do
        for i = 1, #v.exchanges do
            if _gift_id == v.exchanges[i].gift_id then
                return k
            end
        end
    end
end

function M.IsCanGet(exchange_key)
    local item_count = M.GetItemCount(exchange_key)
    local cfg = M.GetExchangeCfg(exchange_key)
    local data = M.GetExchangeData(exchange_key)
    for i = 1, #cfg.exchanges do
        if item_count >= cfg.exchanges[i].item_cost_text and data and data[i] ~= 0 then
            --dump(item_count ,"<color=red>---------------item_count------------</color>")
            --dump(cfg.exchanges[i].item_cost_text ,"<color=red>---------------cost_count------------</color>")
            --dump(item_count ,"<color=red>---------------item_count------------</color>")
            return true 
        end
    end
    return false
end

----------------------------------------------------------------

--获取道具数量
function M.GetItemCount(exchange_key)
    if M.GetExchangeCfg(exchange_key) then
        local cfg = M.GetExchangeCfg(exchange_key)
        return GameItemModel.GetItemCount(cfg.item_key)
    end
    return 0
end

--获取限量的角标
function M.GetLimitIcon(_index)
    if _index == -1  then
        return "xqdh_icon_bxl"
    else
        return limit_icons[_index]
    end
end

local function HandleExchangeData(exchange_data,exchange_day_data)
    local re_data = {}
    for i = 1,#exchange_data do
        if exchange_data[i] == -1 then
            re_data[i] = exchange_day_data[i]
        else
            re_data[i] = exchange_data[i]
        end
    end
    return re_data
end

--请求兑换数据的服务器返回
function M.on_query_activity_exchange_response(_, data)
    dump(data, "<color=white>+++++++on_query_activity_exchange_response++++++</color>")
    if data then
        if data.result == 0 then
            local _exchange_key = M.GetKeyFromExchangeType(data.type)
            if _exchange_key then
                M.InitExchangeDataAll(_exchange_key,data.exchange_data)
                local data = HandleExchangeData(data.exchange_data,data.exchange_day_data)
                M.InitExchangeData(_exchange_key, data)
                M.RefreshHint(_exchange_key)
                Event.Brocast("model_ty_exchange_data_change_msg", { exchange_key = _exchange_key })
            else
                --dump("<color=yellow>兑换活动的配置可能有错误exchange_type!!!</color>")
            end
        end
    end
end

--兑换的服务器返回
function M.on_activity_exchange_response(_,data)
    dump(data,"<color=white>+++++++on_activity_exchange_response++++++</color>")
    if data then
        if data.result == 0 then
            local _exchange_key = M.GetKeyFromExchangeType(data.type)
            if _exchange_key then
                M.QueryExchangeData(data.type)
                --dump("<color=red>------------------RefreshHint----------exchange_response-----</color>")
                M.RefreshHint(_exchange_key)
                Event.Brocast("model_ty_activity_exchange_msg",{exchange_key = _exchange_key, id = data.id})
            else
                --dump("<color=yellow>兑换活动的配置可能有错误exchange_type!!!</color>")
            end
        else
            --HintPanel.ErrorMsg(data.result)
        end
    end
end

function M.on_query_gift_bag_status_by_ids_response(_,data)
    dump(data,"<color>+++++++on_query_gift_bag_status_by_ids_response++++++</color>")
    if data.result == 0 then
        if not data.gift_bag_data or #data.gift_bag_data < 1 then
            return 
        end
        M.HandleGiftData(data)
    end
end

--处理礼包数据
function M.HandleGiftData(data)
    local _exchange_key = M.GetKeyFromGiftID(data.gift_bag_data[1].gift_bag_id)
    local cfg = M.GetExchangeCfg(_exchange_key)
    local exchanges = M.GetExchangeFromId(cfg.exchange_ids)
    local data = {}
    for i = 1, #exchanges do
        --data[#data + 1] = exchanges[i].gift_id
        local remain_time = MainModel.GetRemainTimeByShopID(exchanges[i].gift_id)
        local limit_num = exchanges[i].limit_num
        local ID = exchanges[i].ID
        if limit_num == -1 then
            data[ID] = limit_num
        else
            data[ID] = remain_time
        end
        local _gift_id = exchanges[i].gift_id
    end
    M.InitExchangeData( _exchange_key, data)
    Event.Brocast("model_ty_exchange_data_change_msg",{exchange_key = _exchange_key})
end

function M.on_asset_change(_data)
    if not _data then
        return 
    end
    for k,v in pairs(this.m_data.exchange_cfg) do
        for _k,_v in pairs(_data.data) do
            if _v.asset_type and _v.asset_type == v.item_key then
                M.RefreshHint(v.exchange_key)
                if M.CheckShowFly(v.exchange_key,_data.change_type) then
                    M.PrefabCreator(v.exchange_key , _data.data[_k].value)
                end
            end
        end
    end
end

function M.on_model_task_change_msg()
    for i = 1, #this.m_data.exchange_cfg do
        local key = this.m_data.exchange_cfg[i].exchange_key
        Event.Brocast("model_ty_exchange_data_change_msg",{exchange_key = key})
    end
end

function M.on_finish_gift_shop(_data)
    if not _data then
        return 
    end
    for k,v in pairs(this.m_data.exchange_cfg) do
        for i = 1, #v.exchanges do
            if v.exchanges[i].gift_id and  _data == v.exchanges[i].gift_id then
                M.RefreshHint(v.exchange_key)
                M.QueryAllExchanegData()
                return 
            end
        end
    end
end

local function color16z10(str)
	if str and string.len(str) == 6 then
		local n1 = string.sub(str, 1, 2)
		local n2 = string.sub(str, 3, 4)
		local n3 = string.sub(str, 5, 6)
		local num1 = tonumber(string.format("%d", "0x"..n1))
		local num2 = tonumber(string.format("%d", "0x"..n2))
		local num3 = tonumber(string.format("%d", "0x"..n3))
        return Color.New(num1/255, num2/255, num3/255)
    elseif str and  string.len(str) == 8 then
        local n1 = string.sub(str, 1, 2)
		local n2 = string.sub(str, 3, 4)
		local n3 = string.sub(str, 5, 6)
		local n4 = string.sub(str, 7, 8)
		local num1 = tonumber(string.format("%d", "0x"..n1))
		local num2 = tonumber(string.format("%d", "0x"..n2))
		local num3 = tonumber(string.format("%d", "0x"..n3))
		local num4 = tonumber(string.format("%d", "0x"..n4))
        return Color.New(num1/255, num2/255, num3/255, num4/255)
	end
end

function M.ColorToRGB(str)
    return color16z10(str)
end

function M.RefreshHint(_exchange_key)
    Event.Brocast("global_hint_state_change_msg",{gotoui = M.key,goto_type = _exchange_key})
end

-----------------------图标飞行------------------------

local btn_gameObject

function M.CheckShowFly(exchange_key,asset_change_type)
   
    if MainModel.myLocation == "game_Fishing" then 
        return false 
    end
    if asset_change_type == "task_p_continuity_shop_nor" then
        return false
    end
    if asset_change_type == "task_award" then
        return false
    end
    return M.IsExchangeActive(exchange_key)
end

function M.AddUnShowAward()
    for k,v in pairs(this.m_data.exchange_cfg) do
        if M.IsExchangeActive(v.exchange_key) then
            local cur_type = v.item_key
            local check_func = function (type)
                if type == "task_p_xxlyj_drop_nor" or type == "task_p_xxlyj_drop_cpl" then
                    return true
                end
            end
            MainModel.AddUnShow(check_func)
        end
    end
end

function M.on_year_btn_created(_data)
    if _data and _data.enterSelf then
        btn_gameObject = _data.enterSelf.gameObject
    end
end

function M.PrefabCreator(exchange_key, value)
    local base_layer = GameObject.Find("Canvas/LayerLv50")
    if not base_layer then return end
    local temp_ui = {}
    local can_auto = true
    local can_click = true
    local obj = newObject("Act_Ty_ExchangeItemGetPrefab", base_layer.transform)
    --math.randomseed(tostring(os.time()):reverse():sub(1, 7))
    obj.transform.position = Vector3.New(0, 550, 0)
    LuaHelper.GeneratingVar(obj.transform, temp_ui)
    local cfg = M.GetExchangeCfg(exchange_key)
    if not cfg then
        return
    end
    --temp_ui.Image:GetComponent("Image").sprite = GetTexture(cfg.style_key.."_".."icon_1")
    local fly_img = temp_ui.Image:GetComponent("Image")
	SetTextureExtend(fly_img,cfg.style_key.."_".."icon_1")
    temp_ui.num_txt.text = "+" .. value
    local t = Timer.New(function()
        if can_auto then
            M.FlyAnim(obj, exchange_key)
            can_click = false
        end
    end, 1, 1)
    t:Start()
end

function M.FlyAnim(obj, exchange_key)
    if not IsEquals(obj) then return end
    local a = obj.transform.position
    local seq = DoTweenSequence.Create({ dotweenLayerKey = exchange_key })
    local path = {}
    path[0] = a
    path[1] = Vector3.New(0, 0, 0)
    seq:Append(obj.transform:DOLocalPath(path, 2, DG.Tweening.PathType.CatmullRom))
    seq:AppendInterval(1.6)
    if IsEquals(btn_gameObject) then
        local b = btn_gameObject.transform.position
        local path2 = {}
        path2[0] = Vector3.New(0, 0, 0)
        --path2[1] = Vector3.New(b.x - 30, b.y + 30, 0)
        path2[1] = Vector3.New(b.x, b.y, 0)
        seq:Append(obj.transform:DOPath(path2, 2, DG.Tweening.PathType.CatmullRom))
    end
    seq:OnKill(function()
        if IsEquals(obj) then
            local temp_ui = {}
            LuaHelper.GeneratingVar(obj.transform, temp_ui)
            temp_ui.Image.gameObject:SetActive(false)
            temp_ui.glow_01.gameObject:SetActive(false)
            temp_ui.num_txt.gameObject:SetActive(true)
            Timer.New(function()
                if IsEquals(obj) then
                    destroy(obj)
                end
            end, 2, 1):Start()
        end
    end)
end