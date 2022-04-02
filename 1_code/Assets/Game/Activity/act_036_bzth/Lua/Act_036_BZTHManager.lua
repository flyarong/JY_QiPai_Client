-- 创建时间:2020-10-19
-- Act_036_BZTHManager 管理器

local basefunc = require "Game/Common/basefunc"
Act_036_BZTHManager = {}
local M = Act_036_BZTHManager
M.key = "act_036_bzth"
local gift_data = nil
local Update_Time = nil
GameButtonManager.ExtLoadLua(M.key, "Act_036_BZTHPanel") 
M.config = {
    [1] = {
        shop_id = 10468,
        award_name = "5元充值优惠券",
        award_image = "com_award_icon_czyhq1",
        need_xfq = 50,
        yuanjia = "原价: 5元",
        wuxian = 1,
        tips = "充值商城中购买50元档次鲸币时使用，可抵扣5元（有首冲加赠时无法使用）\n 剩余时间：7天",
    },
    [2] = {
        shop_id = 10469,
        award_name = "10元充值优惠券",
        award_image = "com_award_icon_czyhq2",
        need_xfq = 100,
        yuanjia = "原价: 10元",
        wuxian = 1,
        tips = "充值商城中购买98元档次鲸币时使用，可抵扣10元（有首冲加赠时无法使用）\n 剩余时间：7天",
    },
    [3] = {
        shop_id = 10470,
        award_name = "20元充值优惠券",
        award_image = "com_award_icon_czyhq3",
        need_xfq = 200,
        yuanjia = "原价: 20元",
        wuxian = 1,
        tips = "充值商城中购买198元档次鲸币时使用，可抵扣20元（有首冲加赠时无法使用）\n 剩余时间：7天",
    },
    [4] = {
        shop_id = 10471,
        award_name = "50元充值优惠券",
        award_image = "com_award_icon_czyhq4",
        need_xfq = 400,
        yuanjia = "原价: 50元",
        wuxian = 1,
        tips = "充值商城中购买498元档次鲸币时使用，可抵扣50元（有首冲加赠时无法使用）\n 剩余时间：7天",
    },
    [5] = {
        shop_id = 10472,
        award_name = "100元充值优惠券",
        award_image = "com_award_icon_czyhq5",
        need_xfq = 800,
        yuanjia = "原价: 100元",
        wuxian = 1,
        tips = "充值商城中购买998元档次鲸币时使用，可抵扣100元（有首冲加赠时无法使用）\n 剩余时间：7天",
    },
    [6] = {
        shop_id = 10473,
        award_name = "28万鲸币",
        need_xfq = 120,
        yuanjia = "原价: 28元",
        award_image = "pay_icon_gold2",
    },
    [7] = {
        shop_id = 10474,
        award_name = "68万鲸币",
        need_xfq = 400,
        yuanjia = "原价: 68元",
        award_image = "pay_icon_gold2",
    },
    [8] = {
        shop_id = 10475,
        award_name = "138万鲸币",
        need_xfq = 800,
        yuanjia = "原价: 138元",
        award_image = "pay_icon_gold2",
        wuxian = 1,
    }
}
local btn_gameObject

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
        return Act_036_BZTHPanel.Create(parm.parent)
    end
    dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
end
-- 活动的提示状态
function M.GetHintState(parm)
	if parm and parm.gotoui == M.key then
        if not M.CheckIsShowInActivity(parm) then
            return ACTIVITY_HINT_STATUS_ENUM.AT_Nor
        end
        if GameItemModel.GetItemCount("prop_bzth_coupon") >= 50  then
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
	end
end
-- 更新活动的提示状态(针对那种 打开界面就需要修改状态的需求)
function M.SetHintState()
    PlayerPrefs.SetString(M.key .. MainModel.UserInfo.user_id, os.time())
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
    lister["AssetChange"] = this.OnAssetChange
    lister["year_btn_created"] = this.on_year_btn_created
    lister["ReConnecteServerSucceed"] = this.OnReConnecteServerSucceed
    lister["global_hint_state_set_msg"] = this.on_global_hint_state_set_msg
    lister["query_gift_bag_status_response"] = this.on_query_gift_bag_status_response
    lister["finish_gift_shop"] = this.on_finish_gift_shop
end

function M.Init()
	M.Exit()

	this = Act_036_BZTHManager
    this.m_data = {}
    gift_data = {}
    if Update_Time then
        Update_Time:Stop()
    end
    MainModel.AddUnShow(function(type)
        if type == "task_beizhantehui_11_3" then
            return true
        end
    end)
    Update_Time = nil
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
    dump("<color = white >==============000==================================</color>")

	if result == 0 then
        -- 数据初始化
        if M.IsActive() then
            M.UpdateData()
        end
	end
end

function M.on_query_gift_bag_status_response(_,data)
    if data then
        if data.result == 0 then
            gift_data[data.gift_bag_id] = data.remain_time         
            Event.Brocast("bztg_036_refresh")
        else

        end
    end
end

function M.OnReConnecteServerSucceed()

end


function M.GetShopData(shop_id)
    return gift_data[shop_id]
end

function M.UpdateData()
    for i = 1,#M.config do 
        dump("<color = white >================================================</color>")
        Network.SendRequest("query_gift_bag_status",{gift_bag_id = M.config[i].shop_id})
    end    if Update_Time then
        Update_Time:Stop()
    end
    Update_Time = Timer.New(
        function()
            for i = 1,#M.config do 
                Network.SendRequest("query_gift_bag_status",{gift_bag_id = M.config[i].shop_id})
            end
        end
    ,30,-1)
    Update_Time:Start()
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
    if data.change_type and data.change_type == "task_beizhantehui_11_3" then
        M.PrefabCreator(data.data[1].value)
    end
    Event.Brocast("bztg_036_refresh")
end

function M.PrefabCreator(value)
    if not IsEquals(btn_gameObject) then return end
    local temp_ui = {}
    local can_auto = true
    local can_click = true
    local obj = newObject("Act_036_BZTHFLYPrefab",GameObject.Find("Canvas/LayerLv50").transform)
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

function M.on_finish_gift_shop(id)
    local cfg = M.GetCFGByShopID(id)
    if cfg then
        if cfg.wuxian ~= 1 then
            gift_data[id] =  gift_data[id] - 1
            Event.Brocast("bztg_036_refresh")
            Event.Brocast("global_hint_state_change_msg",{gotoui = M.key})
        end  
    end
end

function M.GetCFGByShopID(shop_id)
    for i = 1,#M.config do
        if M.config[i].shop_id == shop_id then
            return M.config[i]
        end
    end
end