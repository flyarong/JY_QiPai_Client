-- 创建时间:2020-07-30
-- Act_023_DDZFBKManager 管理器

local basefunc = require "Game/Common/basefunc"
Act_023_DDZFBKManager = {}
local M = Act_023_DDZFBKManager
M.key = "act_023_ddzfbk"
M.shopid = 10347
M.care_game_id = {1,33,21}
GameButtonManager.ExtLoadLua(M.key,"Act_023_DDZFBKLBPanel")
GameButtonManager.ExtLoadLua(M.key,"Act_023_DDZFBKPrefab")

local this
local lister  

-- 是否有活动
function M.IsActive()
    -- 活动的开始与结束时间
    local e_time
    local s_time
    if (e_time and os.time() > e_time) or (s_time and os.time() < s_time) then
        return false
    end

    -- 对应权限的key
    local _permission_key = "actp_buy_gift_bag_10347"
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
    dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
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
    lister["ddzfreeclear_created"] = this.on_ddzfreeclear_created
    lister["OnLoginResponse"] = this.OnLoginResponse
    lister["ReConnecteServerSucceed"] = this.OnReConnecteServerSucceed
    lister["global_hint_state_set_msg"] = this.on_global_hint_state_set_msg
end

function M.Init()
	M.Exit()

	this = Act_023_DDZFBKManager
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
end

function M.OnLoginResponse(result)
	if result == 0 then
        -- 数据初始化
	end
end

function M.on_ddzfreeclear_created(data)
    dump(data,"<color=red>xxxxxxxxxxxxxxxxx</color>")
    if DdzFreeModel and DdzFreeModel.baseData and M.IsCareShopID(DdzFreeModel.baseData.game_id) and MainModel.UserInfo.xsyd_status == 1 then
        local panelSelf = data.panelSelf
        if panelSelf.isWin then
            --还没有购买礼包时候的创建条件
            if tonumber(panelSelf.self_times_txt.text) >= 6 and MainModel.GetGiftShopStatusByID(M.shopid) == 1 then  
                local b = Act_023_DDZFBKPrefab.Create(panelSelf.transform,panelSelf)
                if PlayerPrefs.GetInt("act_024_fbk" .. MainModel.UserInfo.user_id..os.date("%Y%m%d",os.time()), 0) == 0 then
                    --没有通过引导的时候
                    if M.IsOutGuide() then
                        b:OpenPanel()
                        PlayerPrefs.SetInt("act_024_fbk" .. MainModel.UserInfo.user_id..os.date("%Y%m%d",os.time()),1)
                    end
                end
            --胜利就会创建，但是暂时隐藏
            else
                local b = Act_023_DDZFBKPrefab.Create(panelSelf.transform,panelSelf)
                b.gameObject:SetActive(false)
            end
        end
    end
end


function M.IsCareShopID(game_id)
   for i = 1,#M.care_game_id do
        if game_id == M.care_game_id[i] then
            return true
        end
   end
   return false
end


function M.OnReConnecteServerSucceed()

end

function M.IsOutGuide()
    local  is_out_guide = true
    --玩棋牌CPL渠道
    -- if gameMgr:getMarketPlatform() == "wqp" and gameMgr:getMarketChannel() ~= "wqp" then
    --     if WQPCPLYHGuideModel.IsCanRunGuide() then
    --         is_out_guide = false        
    --     end
    -- else --鲸鱼斗地主和 玩棋牌自营渠道
    if MainModel.UserInfo.xsyd_status ~= 1 then
        is_out_guide = false
    end
    --end
    return  is_out_guide
end


--胜利，并且倍数大于6
--胜利，并且消耗过翻倍卡

print(tonumber("+106655"))