local basefunc = require "Game/Common/basefunc"
TGLBManager = {}
local M = TGLBManager
M.key = "btn_tglb"
GameButtonManager.ExtLoadLua(M.key, "BtnTGLBEnterPrefab")
function M.CheckIsShow()
	if MainModel.GetGiftShopStatusByID(43) == 1 then 
		return true
	end 
end

function M.GotoUI(parm)
    if parm.goto_scene_parm == "enter" then
        return BtnTGLBEnterPrefab.Create(parm.parent, parm.cfg)
    else
        dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
    end
end

local function AddLister()
    for msg, cbk in pairs(lister) do
        Event.AddListener(msg, cbk)
    end
end

local function RemoveLister()
    if lister then
        for msg, cbk in pairs(lister) do
            Event.RemoveListener(msg, cbk)
        end
    end
    lister = nil
end
local function MakeLister()
    lister = {}
    lister["global_hint_state_set_msg"] = M.SetHintState
end

function M.Init()
    M.Exit()
    m_data = {}
    MakeLister()
    AddLister()
end

function M.Exit()
    if M then
        RemoveLister()
    end
end

function M.SetData()
    Event.Brocast("ui_button_data_change_msg", { key = M.key })
    Event.Brocast("global_hint_state_set_msg", { gotoui = M.key })
end

