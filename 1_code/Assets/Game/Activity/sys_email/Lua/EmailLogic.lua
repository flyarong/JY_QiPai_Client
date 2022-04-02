-- 创建时间:2018-06-02
-- 邮件

EmailLogic = {}
local M = EmailLogic
M.key = "sys_email"
GameButtonManager.ExtLoadLua(M.key, "EmailModel")
GameButtonManager.ExtLoadLua(M.key, "EmailPanel")
GameButtonManager.ExtLoadLua(M.key, "EmailCellPrefab")

local this
local lister
local viewLister

local AddLister
local RemoveLister
local AddEmail

function M.CheckIsShow()
    return true
end
function M.GotoUI(parm)
    if parm.goto_scene_parm == "panel" then
        return EmailPanel.Create()
    else
        dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
    end
end

-- 活动的提示状态
function M.GetHintState(parm)
	local b = EmailModel.IsRedHint()
	local a = EmailModel.IsGetHint()
	if a then
		return ACTIVITY_HINT_STATUS_ENUM.AT_Get
	else
		if b then
			return ACTIVITY_HINT_STATUS_ENUM.AT_Red
		else
			return ACTIVITY_HINT_STATUS_ENUM.AT_Nor
		end	
	end

end
function M.on_global_hint_state_set_msg(parm)
	if parm.gotoui == M.key then
		M.SetHintState()
	end
end
function M.SetHintState()
end

--初始化
function EmailLogic.Init()
	EmailLogic.Exit()
	this = EmailLogic
	AddLister()
	return this
end

-- 退出logic
function EmailLogic.Exit()
	if this then
		RemoveLister()
		EmailModel.Exit()

		this = nil
	end
end

-- 关闭邮件panel
function EmailLogic.ClosePanel()
end

function EmailLogic.OnReConnecteServerResponse(data)
end

function EmailLogic.OnEmailEtateChange(data)
	Event.Brocast("model_set_email_state_change", data)
end

function EmailLogic.OnNewEmail(_, data)
	AddEmail(data)
end
function EmailLogic.OnReqEmail(data)
	AddEmail(data)
end
function EmailLogic.OnLoginResponse(result)
	if result==0 then
		EmailModel.Exit()
		EmailModel.Init()
		CommonRankEmail.Init()
    end
end

function EmailLogic.IsShowInExXSYD()
    return EmailModel.IsGetHint()
end

AddEmail = function (data)
	dump(data, "<color=red>邮件内容</color>")
	EmailModel.AddEmail(data)
	Event.Brocast("model_add_email_data", data.email.id)
end

-- 注册Logic监听事件
AddLister = function ()
	lister = {}
	-- get_email_list_finish
    lister["notify_new_email_msg"] = this.OnNewEmail
    lister["req_call_email_msg"] = this.OnReqEmail
    lister["OnLoginResponse"] = this.OnLoginResponse
    lister["set_email_state_change"] = this.OnEmailEtateChange
    lister["ReConnecteServerSucceed"] = this.OnReConnecteServerResponse

    for msg, cbk in pairs(lister) do
        Event.AddListener(msg, cbk)
    end
end
-- 移除Logic监听事件
RemoveLister = function ()
	if lister then
	    for proto_name,func in pairs(lister) do
	        Event.RemoveListener(proto_name, func)
	    end
	end
end

