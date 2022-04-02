-- 创建时间:2020-06-09
-- Act_017_ExxzhhlManager 管理器

local basefunc = require "Game/Common/basefunc"
Act_017_ExxzhhlManager = {}
local M = Act_017_ExxzhhlManager
M.key = "act_017_EXxzhhl"

local this
local lister
local btn_gameObject

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
    lister["OnLoginResponse"] = this.OnLoginResponse
    lister["AssetChange"] = this.OnAssetChange

    lister["year_btn_created"] = this.on_year_btn_created
    lister["ReConnecteServerSucceed"] = this.OnReConnecteServerSucceed
    lister["global_hint_state_set_msg"] = this.on_global_hint_state_set_msg
end

function M.Init()
	M.Exit()

	this = Act_017_ExxzhhlManager
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


function M.OnReConnecteServerSucceed()

end

function M.on_year_btn_created(data)
    if data and data.enterSelf then
        btn_gameObject = data.enterSelf.gameObject
    end
end

function M.FlyAnim(obj)
    if IsEquals(btn_gameObject) == false then return end
    if IsEquals(obj) == false then return end
   
    local a  = obj.transform.position
    local b  = btn_gameObject.transform.position
    --path[2] = Vector3.New(0,0,0)
    
    if true then
        local targetV3 = btn_gameObject.transform.position
        local seq = DoTweenSequence.Create()
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
			if IsEquals(btn_gameObject) then 
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
    if data.change_type and string.sub(data.change_type, 1, 22) == "task_p_zongzi_convert_" then
        M.PrefabCreator(data.data[1].value)
    end
end

function M.PrefabCreator(value)
    if not IsEquals(btn_gameObject) then return end
    local temp_ui = {}
    local can_auto = true
    local can_click = true
    local obj = newObject("Act_017_CZHHLZongZiPrefab",GameObject.Find("Canvas/LayerLv50").transform)
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