-- 创建时间:2020-02-21
-- BYActCaijinManager 管理器

local basefunc = require "Game/Common/basefunc"
BYActCaijinManager = {}
local M = BYActCaijinManager
M.key = "by_act_caijin"
GameButtonManager.ExtLoadLua(M.key, "FishingActCaijinPanel")
GameButtonManager.ExtLoadLua(M.key, "FishingActCaijinBoxPrefab")
GameButtonManager.ExtLoadLua(M.key, "FishingActCaijinEnterPrefab")

local this
local lister
local send_data
 
-- 是否有活动
function M.IsActive()
    -- 活动的开始与结束时间
    local e_time = this.e_time
    local s_time = this.s_time
    print ("caijin11111111111111111111111111111")
    dump(string.format("%d   %d   %d", os.time(), this.s_time, this.e_time), "caijin2222222222222222222222222")
    if (e_time and os.time() > e_time) or (s_time and os.time() < s_time) then
        return false
    end

    print ("caijin333333333333333333333333333333")
    -- 对应权限的key
    local _permission_key = "fish_caijin_hongbao"
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

function M.CheckGameID()
    return #M.caijin_config.caijin_type_config > 0
end

-- 所有可以外部创建的UI
function M.GotoUI(parm)
    if parm.goto_scene_parm == "panel" then
        if M.CheckIsShow() then
            return FishingActCaijinPanel.Create()
        end 
    elseif parm.goto_scene_parm == "enter" then
        print("caijin enter")
        if M.CheckIsShow() then
            M.on_fishing_enter_game()
            if M.CheckGameID() then
                print ("caijin 333333333333333333333333333333")
                return FishingActCaijinEnterPrefab.Create(parm.parent)
            end
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

    lister["nor_fishing_caijin_all_info_response"] = this.on_nor_fishing_caijin_all_info_response
    lister["nor_fishing_caijin_lottery_response"] = this.on_nor_fishing_caijin_lottery_response
    lister["nor_fishing_caijin_change"] = this.on_nor_fishing_caijin_change
    --lister["fishing_enter_game"] = this.on_fishing_enter_game

end

function M.Init()
    print("caijin init!")
	M.Exit()

	this = BYActCaijinManager

    this.getActivTimeConfig()

    this.InitCaijinData()

	MakeLister()
    AddLister()
end

function M.Exit()
	if this then
		RemoveLister()
		this = nil
	end
end

function M.OnLoginResponse(result)
	if result == 0 then
        -- 数据初始化
	end
end
function M.OnReConnecteServerSucceed()
end

function M.getActivTimeConfig()
    local fish_caijin_config = GameButtonManager.ExtLoadLua(M.key, "fish_caijin_config")
    this.s_time = fish_caijin_config.Common[1].begin_time
    this.e_time = fish_caijin_config.Common[1].end_time
end

function M.on_fishing_enter_game()
    this.initConfig()
end

function M.QueryCaijinAllInfo()
    Network.SendRequest("nor_fishing_caijin_all_info", nil, "进入彩金界面")
end

function M.RequestLottery()
    Network.SendRequest("nor_fishing_caijin_lottery", nil, "抽奖")
end

function M.on_nor_fishing_caijin_all_info_response(_, data)
    dump(data, "<color=red>on_nor_fishing_caijin_all_info_response</color>")
    this.m_caijin_data.result = data.result
    this.m_caijin_data.lottery_num = data.lottery_num
    this.m_caijin_data.lottery_time = data.lottery_time
    this.m_caijin_data.score = data.score
    this.m_caijin_data.kill_num = data.kill_num

    Event.Brocast("model_by_act_caijin_all_info")
end

function M.on_nor_fishing_caijin_lottery_response(_, data)
    dump(data, "<color=red>on_nor_fishing_caijin_lottery_response</color>")
    this.m_caijin_data.result = data.result
    this.m_caijin_data.award_index = data.award_index
    this.m_caijin_data.lottery_num = data.lottery_num
    this.m_caijin_data.lottery_time = data.lottery_time
    this.m_caijin_data.type = data.type
    this.m_caijin_data.score = data.score
    this.m_caijin_data.kill_num = data.kill_num

    Event.Brocast("model_by_act_caijin_lottery")
end

function M.on_nor_fishing_caijin_change(_, data)
    dump(data, "<color=red>on_nor_fishing_caijin_change</color>")
    this.m_caijin_data.result = data.result
    this.m_caijin_data.lottery_num = data.lottery_num
    this.m_caijin_data.lottery_time = data.lottery_time
    this.m_caijin_data.score_change = data.score_change
    this.m_caijin_data.score = data.score
    this.m_caijin_data.kill_num = data.kill_num

    Event.Brocast("model_by_act_caijin_change")
end

function M.GetCaijinData()
    return this.m_caijin_data
end

function M.InitCaijinData()
    this.m_caijin_data = {}

    this.m_caijin_data.result = 0
    this.m_caijin_data.award_index = 0
    this.m_caijin_data.lottery_num = 0
    this.m_caijin_data.lottery_time = 0
    this.m_caijin_data.type = 0
    this.m_caijin_data.score_change = 0
    this.m_caijin_data.score = 0
    this.m_caijin_data.kill_num = 0
end

function M.initConfig()
    local fish_caijin_config = GameButtonManager.ExtLoadLua(M.key, "fish_caijin_config")
    this.caijin_config = {}

    local _config = fish_caijin_config
	local caijin_type_config = {}

	local load_award_config=function (award_id,cfg)
		for key, data in pairs(_config.award) do
			if data.config_id == award_id then
				cfg[#cfg + 1] = data
			end
        end
        
        table.sort(cfg, function (a,b)
            return a.index < b.index
        end)
	end

    for key, data in pairs(_config.lottery) do
        if data.game_id == FishingModel.game_id then
            caijin_type_config[data.type] = data
            if data.award_config_id then
                data.award = {}

                load_award_config(data.award_config_id, data.award)

                if #data.award == 0 then
                    print("error caibei award config")
                end
            end
        end
	end

	local caijin_fishs_id = {}
	if _config.Common[1].caijin_fish_id then
		for idx, fishid in pairs(_config.Common[1].caijin_fish_id) do
			caijin_fishs_id[fishid] = idx
		end
	end
    
	this.caijin_config.caijin_type_config = caijin_type_config
	this.caijin_config.caijin_fishs_id = caijin_fishs_id
	this.caijin_config.caijin_common_config = _config.Common[1]
    this.caijin_config.caijin_condition_config = _config.condition
    
end
