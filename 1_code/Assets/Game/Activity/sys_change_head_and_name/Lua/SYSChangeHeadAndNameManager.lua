-- 创建时间:2020-07-31
-- SYSChangeHeadAndNameManager 管理器

local basefunc = require "Game/Common/basefunc"
SYSChangeHeadAndNameManager = {}
local M = SYSChangeHeadAndNameManager
M.key = "sys_change_head_and_name"
M.config = GameButtonManager.ExtLoadLua(M.key, "sys_change_head_and_name_config")
GameButtonManager.ExtLoadLua(M.key, "SYSChangeHeadAndNamePanel")
GameButtonManager.ExtLoadLua(M.key, "SYSChangeHeadItemBase")
GameButtonManager.ExtLoadLua(M.key, "SYSChangeHeadPanel")
GameButtonManager.ExtLoadLua(M.key, "SYSChangeNamePanel")
GameButtonManager.ExtLoadLua(M.key, "SYSChangePageItemBase")
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
function M.CheckIsShow(parm, type)
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
    lister["ReConnecteServerSucceed"] = this.OnReConnecteServerSucceed
    lister["global_hint_state_set_msg"] = this.on_global_hint_state_set_msg


    lister["NewPersonPanel_to_SYSChangeHeadAndNameManager_msg"] = this.on_NewPersonPanel_to_SYSChangeHeadAndNameManager_msg
    lister["update_player_name_response"] = this.on_update_player_name_response
    lister["set_head_image_response"] = this.on_set_head_image_response
end

function M.Init()
	M.Exit()

	this = SYSChangeHeadAndNameManager
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
    M.InitImgList()
    this.UIConfig = {}
end

function M.OnLoginResponse(result)
	if result == 0 then
        -- 数据初始化
	end
end
function M.OnReConnecteServerSucceed()
end


function M.on_update_player_name_response(_,data)
    dump(data,"<color=yellow>++++++++++++++on_update_player_name_response+++++++++++++++</color>")
    if data then
        if data.result == 0 then
            this.m_data.new_name = data.name
            MainModel.UserInfo.name = data.name
            MainModel.UserInfo.udpate_name_num =  MainModel.UserInfo.udpate_name_num + 1
            Event.Brocast("SYSChangeHeadAndNameManager_Change_Name_Success_msg")
        else
            HintPanel.ErrorMsg(data.result)
        end
    end
end

function M.on_set_head_image_response(_,data)
    dump(data,"<color=yellow>++++++++on_set_head_image_response+++++++</color>")
    if data then
        if data.result == 0 then
            MainModel.UserInfo.head_image = M.config.img_type_list[data.img_type].url
            Event.Brocast("SYSChangeHeadAndNameManager_Change_Head_Success_msg")
        else
            HintPanel.ErrorMsg(data.result)
        end
    end
end

function M.GetNewName()
    return this.m_data.new_name
end

function M.on_NewPersonPanel_to_SYSChangeHeadAndNameManager_msg(data)
    if M.IsActive() then
        if data.head_node then
            local obj = newObject("@Change_head_node", data.head_node)
            local temp_ui1 = {}
            LuaHelper.GeneratingVar(obj.transform, temp_ui1)
            temp_ui1.head_enter_btn.onClick:AddListener(
                function()
                    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
                    SYSChangeHeadPanel.Create()
                end
            )
        end
        if data.name_node then
            local obj = newObject("@Change_name_node", data.name_node)
            local temp_ui2 = {}
            LuaHelper.GeneratingVar(obj.transform, temp_ui2)
            temp_ui2.name_enter_btn.onClick:AddListener(
                function()
                    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
                    SYSChangeNamePanel.Create()
                end
            )
        end
    end
end

function M.GetImgTypeList()
    return M.config.img_type_list
end

function M.GetFreeImgTypeList()
    return this.m_data.freeList
end

function M.GetVIPImgTypeList()
   return this.m_data.vipList
end

function M.InitImgList()
    this.m_data.freeList = {}
    this.m_data.vipList = {}
    for i=1,#M.config.img_type_list do
        if M.config.img_type_list[i].vip_permission == 0 then
            this.m_data.freeList[#this.m_data.freeList + 1] = M.config.img_type_list[i]
        else
            this.m_data.vipList[#this.m_data.vipList + 1] = M.config.img_type_list[i]
        end
    end
end

function M.GetHeadImage()
    if not M.config or not MainModel or not MainModel.UserInfo or not MainModel.UserInfo.img_type then return end
    return M.config.img_type_list[MainModel.UserInfo.img_type].url
end