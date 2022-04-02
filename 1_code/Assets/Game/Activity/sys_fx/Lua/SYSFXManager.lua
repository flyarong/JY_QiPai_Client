-- 创建时间:2019-10-24
-- 分享管理器

local basefunc = require "Game/Common/basefunc"
SYSFXManager = {}
local M = SYSFXManager
M.key = "sys_fx"
share_link_config = GameButtonManager.ExtLoadLua(M.key, "share_link_config")
GameButtonManager.ExtLoadLua(M.key, "ShareModel")
GameButtonManager.ExtLoadLua(M.key, "ShareLogic")
GameButtonManager.ExtLoadLua(M.key, "SharePanel")
GameButtonManager.ExtLoadLua(M.key, "FXEnterPrefab")
GameButtonManager.ExtLoadLua(M.key, "ShareImage")
GameButtonManager.ExtLoadLua(M.key, "ShareHelper")

local this
local lister

function M.CheckIsShow()
    return true
end
function M.GotoUI(parm)
    if parm.goto_scene_parm == "panel" then
        return SharePanel.Create(parm.share_cfg,parm.share_info)
    elseif parm.goto_scene_parm == "image" then
        return ShareLogic.ShareImage(parm.share_cfg,parm.finish_parm)
    elseif parm.goto_scene_parm == "url" then
        return ShareLogic.ShareUrl(parm.share_cfg,parm.finish_parm)
    elseif parm.goto_scene_parm == "enter" then
    	return FXEnterPrefab.Create(parm.parent, parm.cfg)
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
function M.SetHintState()
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
end

function M.Init()
	M.Exit()

	this = SYSFXManager
	this.m_data = {}
	MakeLister()
    AddLister()
    M.InitUIConfig()
    ShareHelper.Init()
    ShareLogic.Init()
end

function M.Exit()
    ShareHelper.Exit()
    ShareLogic.Exit()
	if this then
		RemoveLister()
		this = nil
	end
end
function M.InitUIConfig()
    
end

function M.OnLoginResponse(result)
    if result == 0 then
        --分享替换
        M.ReplaceWebSeverShare()
	end
end
function M.OnReConnecteServerSucceed()
end

function M.InitShareLinkConfig()
    local share_link_cfg = {}
    for _k,_v in pairs(share_link_config) do
        for index,v in pairs(_v) do
			if v.key then
				share_link_cfg[v.key] = v
			end
        end
    end
    share_link_config = share_link_cfg
    dump(share_link_config,"<color=white>share_link_config</color>")
end

function M.ReplaceWebSeverShare()
    dump(MainModel.UserInfo.web_server,"<color=green>web_server >>>>>>>>></color>")
    if not MainModel.UserInfo.web_server then return end
    local slc = {}
    for k,v in pairs(share_link_config) do
        if v.url and string.find(v.url,"http://es-caller.jyhd919.cn",1,true) then
            v.url = string.gsub(v.url,"http://es%-caller%.jyhd919%.cn",MainModel.UserInfo.web_server)
        end
    end
    dump(share_link_config,"<color=green>分享配置</color>")
end

M.InitShareLinkConfig()