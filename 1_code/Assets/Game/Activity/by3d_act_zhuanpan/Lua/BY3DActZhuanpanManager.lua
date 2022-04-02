-- 创建时间:2020-02-21
-- BY3DActZhuanpanManager 管理器

local basefunc = require "Game/Common/basefunc"
BY3DActZhuanpanManager = {}
local M = BY3DActZhuanpanManager
M.key = "by3d_act_zhuanpan"
GameButtonManager.ExtLoadLua(M.key, "Fishing3DActZhuanpanPanel")
GameButtonManager.ExtLoadLua(M.key, "Fishing3DActZhuanpanBoxPrefab")
--GameButtonManager.ExtLoadLua(M.key, "Fishing3DActZhuanpanEnterPrefab")

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
    --dump(parm,"<color=white>PPPPPPPPPPPPPPPP宝藏章鱼，幸运转盘PPPPPPPPPPPPPPPPPPPPPPPPPP</color>")
    if parm.goto_scene_parm == "panel" then
        if M.CheckIsShow() then
            --this.m_zhuanpan_data.bullet_stake = parm.data.bullet_stake
            M.SetZhuanPanBulletStake(parm.data.bullet_stake)
            return Fishing3DActZhuanpanPanel.Create()
        end 
    elseif parm.goto_scene_parm == "enter" then
        --  if M.CheckIsShow() then
        --     return Fishing3DActZhuanpanEnterPrefab.Create(parm.parent)
        -- end 
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

    lister["nor_fishing_3d_zhuanpan_start"] = this.on_nor_fishing_3d_zhuanpan_start
    lister["nor_fishing_zhuanpan_lottery_response"] = this.on_nor_fishing_zhuanpan_lottery_response
end

function M.Init()
    print("zhuanpan manager init!")
	M.Exit()

	this = BY3DActZhuanpanManager

    this.initConfig()
    this.InitZhuanpanData()

	MakeLister()
    AddLister()
end
function M.Exit()
	if this then
		RemoveLister()
		this = nil
	end
end

function M.on_nor_fishing_3d_zhuanpan_start(_, data)
    dump(data, "<color=red>on_nor_fishing_3d_zhuanpan_start</color>")
    --Event.Brocast("model_by3d_act_zhuanpan_start")
    this.m_zhuanpan_data.bullet_stake = data.bullet_stake
    
    Fishing3DActZhuanpanPanel.Create()
end


function M.OnLoginResponse(result)
	if result == 0 then
        -- 数据初始化
	end
end
function M.OnReConnecteServerSucceed()
end

function M.RequestLottery()
    Network.SendRequest("nor_fishing_zhuanpan_lottery", nil, "抽奖")
end

function M.on_nor_fishing_zhuanpan_lottery_response(_, data)
    dump(data, "<color=red>on_nor_fishing_zhuanpan_lottery_response</color>")
    
    this.m_zhuanpan_data.result = data.result
    this.m_zhuanpan_data.award_index = data.award_index

    Event.Brocast("model_by3d_act_zhuanpan_lottery")
end

function M.GetZhuanpanData()
    return this.m_zhuanpan_data
end

function M.InitZhuanpanData()
    this.m_zhuanpan_data = {}

    this.m_zhuanpan_data.result = 0
    this.m_zhuanpan_data.bullet_stake = 10
    this.m_zhuanpan_data.award_index = 0
end

function M.SetZhuanPanBulletStake(_bullet_stake)
    this.m_zhuanpan_data.bullet_stake = _bullet_stake
end

function M.initConfig()
    local fish_3d_zhuanpan_config = GameButtonManager.ExtLoadLua(M.key, "fish_3d_zhuanpan_config")
    this.zhuanpan_config = fish_3d_zhuanpan_config.award
end

function M.getConfig()
    return this.zhuanpan_config
end
