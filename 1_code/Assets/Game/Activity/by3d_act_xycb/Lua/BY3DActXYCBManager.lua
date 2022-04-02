-- 创建时间:2020-02-21
-- BY3DActXYCBManager 管理器

local basefunc = require "Game/Common/basefunc"
BY3DActXYCBManager = {}
local M = BY3DActXYCBManager
M.key = "by3d_act_xycb"
GameButtonManager.ExtLoadLua(M.key, "Fishing3DActXYCBPanel")
GameButtonManager.ExtLoadLua(M.key, "Fishing3DActBKPrefab")
GameButtonManager.ExtLoadLua(M.key, "Fishing3DActXYCBOpenPrefab")
GameButtonManager.ExtLoadLua(M.key, "Fishing3DActXYCBHelpPanel")
GameButtonManager.ExtLoadLua(M.key, "Fishing3DActBKEnterPrefab")
local fish3d_caibei_config = GameButtonManager.ExtLoadLua(M.key, "fish3d_caibei_config")

local this
local lister
local send_data

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
function M.CheckIsShow()
    return M.IsActive()
end
-- 活动面板调用
function M.CheckIsShowInActivity()
    return M.IsActive()
end

-- 所有可以外部创建的UI
function M.GotoUI(parm)
    if parm.goto_scene_parm == "panel" then
        if M.CheckIsShow() then
            return Fishing3DActXYCBPanel.Create()
        end 
    elseif parm.goto_scene_parm == "enter" then
        if M.CheckIsShow() then
            return Fishing3DActBKEnterPrefab.Create(parm.parent)
        end 
    else
        dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
    end
end
-- 活动的提示状态
function M.GetHintState(parm)
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

    lister["nor_fishing_3d_caibei_all_info_response"] = this.on_nor_fishing_3d_caibei_all_info_response
    lister["nor_fishing_3d_free_caibei_obtain_response"] = this.on_nor_fishing_3d_free_caibei_obtain_response
    lister["nor_fishing_3d_caibei_start_response"] = this.on_nor_fishing_3d_caibei_start_response
    lister["nor_fishing_3d_caibei_complete_use_jingbi_response"] = this.on_nor_fishing_3d_caibei_complete_use_jingbi_response
    lister["nor_fishing_3d_caibei_complete_response"] = this.on_nor_fishing_3d_caibei_complete_response
end

function M.Init()
	M.Exit()

	this = BY3DActXYCBManager
	this.m_data = {}
	MakeLister()
    AddLister()
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

    this.UIConfig.free_get_cd = {900, 1800, 1800} -- 免费领取海贝的CD间隔
    this.UIConfig.free_get_max_num = 3 -- 免费领取的最大数
    this.UIConfig.caibei_list = {}
    for k,v in ipairs(fish3d_caibei_config.config) do
        this.UIConfig.caibei_list[k] = v
    end
end

function M.OnLoginResponse(result)
	if result == 0 then
        -- 数据初始化
	end
end
function M.OnReConnecteServerSucceed()
end

function M.QueryAllInfo()
    Network.SendRequest("nor_fishing_3d_caibei_all_info", nil, "请求数据")
end
function M.on_nor_fishing_3d_caibei_all_info_response(_, data)
    dump(data, "<color=red>on_nor_fishing_3d_caibei_all_info_response</color>")
    this.m_data.caibei_all_info = data.caibei_all_info
    this.m_data.free_caibei_obtain_info = data.free_caibei_obtain_info

    Event.Brocast("model_by3d_act_xycb_all_info")
end
function M.on_nor_fishing_3d_free_caibei_obtain_response(_, data)
    dump(data, "<color=red>on_nor_fishing_3d_free_caibei_obtain_response</color>")
    if data.result == 0 then
        local pos = M.GetLastNullPos()
        if pos then
            this.m_data.caibei_all_info[pos].state = 1
            this.m_data.caibei_all_info[pos].type = data.type
            this.m_data.free_caibei_obtain_info = data.obtain_info
            Event.Brocast("model_nor_fishing_3d_free_caibei_obtain", {index = pos, type=data.type})
        else
            print("<color=red>没有空的彩贝</color>")
        end
    else
        HintPanel.ErrorMsg(data.result)
    end
end

-- Fun
-- 获取开启中的彩贝数
function M.GetOpeningCBNum()
    local num = 0
    if this.m_data.caibei_all_info then
        local cur_t = os.time()
        for k,v in ipairs(this.m_data.caibei_all_info) do
            local cfg = this.UIConfig.caibei_list[v.index]
            if v.state == 2 then
                num = num + 1
            end
        end
    end
    return num
end
-- 开启彩贝的最大数
function M.GetOpeningCBMax()
    local max_open_bk_num = 1
    if VIPManager.get_vip_level() >= 5 then
        max_open_bk_num = 2
    end
    return max_open_bk_num
end
-- 当前拥有的彩贝数
function M.GetCurCBNum()
    local num = 0
    if this.m_data.caibei_all_info then
        for k,v in ipairs(this.m_data.caibei_all_info) do
            if v.state ~= 0 then
                num = num + 1
            end
        end
    end
    return num
end
-- 可拥有的彩贝最大数
function M.GetCBMaxNum()
    if VIPManager.get_vip_level() >= 3 then
        return 5
    else
        return 4
    end
end
-- 获取免费领取的CD
function M.GetFreeGetCD()
    local dd = this.m_data.free_caibei_obtain_info
    local cd = 0
    if dd then
        if dd.obtain_num > 0 and dd.obtain_num < this.UIConfig.free_get_max_num then
            local cur_t = os.time()
            dump(cur_t)
            local n = this.UIConfig.free_get_cd[dd.obtain_num]
            local tt = dd.last_obtain_time + n
            dump(tt)
            if tt > cur_t then
                return tt - cur_t
            end
        end
    end
    return cd
end
-- 最近的一个空位置
function M.GetLastNullPos()
    for k,v in ipairs(this.m_data.caibei_all_info) do
        if v.state == 0 then
            return k
        end
    end
end

function M.GetIDConfig(id)
    return this.UIConfig.caibei_list[id]
end

function M.OpenXYCB(index)
    send_data = {index=index}
    Network.SendRequest("nor_fishing_3d_caibei_start", send_data, "打开")
end
function M.on_nor_fishing_3d_caibei_start_response(_, data)
    dump(data, "<color=red>on_nor_fishing_3d_caibei_start_response</color>")
    local index = send_data.index
    send_data = nil
    if data.result == 0 then
        this.m_data.caibei_all_info[index].state = 2
        this.m_data.caibei_all_info[index].start_time = os.time()
        Event.Brocast("model_nor_fishing_3d_caibei_start", {index = index})
    else
        HintPanel.ErrorMsg(data.result)
    end
end
function M.FinishXYCB(index)
    send_data = {index=index}
    Network.SendRequest("nor_fishing_3d_caibei_complete_use_jingbi", send_data, "完成")
end
function M.on_nor_fishing_3d_caibei_complete_use_jingbi_response(_, data)
    dump(data, "<color=red>on_nor_fishing_3d_caibei_complete_use_jingbi_response</color>")
    local index = send_data.index
    send_data = nil
    if data.result == 0 then
        this.m_data.caibei_all_info[index].state = 0
        Event.Brocast("model_nor_fishing_3d_caibei_complete_use_jingbi", {index = index})
    else
        HintPanel.ErrorMsg(data.result)
    end
end
function M.AutoFinishXYCB(index)
    send_data = {index=index}
    Network.SendRequest("nor_fishing_3d_caibei_complete", send_data, "完成")
end
function M.on_nor_fishing_3d_caibei_complete_response(_, data)
    dump(data, "<color=red>on_nor_fishing_3d_caibei_complete_response</color>")
    local index = send_data.index
    send_data = nil
    if data.result == 0 then
        this.m_data.caibei_all_info[index].state = 0
        Event.Brocast("model_nor_fishing_3d_caibei_complete", {index = index})
    else
        HintPanel.ErrorMsg(data.result)
    end
end

