-- 创建时间:2019-10-22
-- 幸运抽奖管理器
-- 可以存放活动数据，配置，还有广播数据改变的消息

local basefunc = require "Game/Common/basefunc"
BYBSXTSManager = {}
local M = BYBSXTSManager
M.key = "bybsXts"
GameButtonManager.ExtLoadLua(M.key, "BYBSXTSEnterPrefab")

local this
local lister
local m_data

function M.CheckIsShow()
    local b = FishingManager.IsTodayHaveMatch()
    return b
end
function M.GotoUI(parm)
    if parm.goto_scene_parm == "panel" then
        print("<color=red> 捕鱼大奖赛提示</color>")
        local desc = ""
        local num = GameItemModel.GetItemTotalCount({ "obj_fish_match", "prop_fish" })
        if num > 0 then
            desc = "<size=50>来自鲸鲸的提醒：\n<color=#F2830DFF>捕鱼大奖赛</color>今晚20：30开始报名，21点准时开赛记得参加，不要错过哟~</size>"
        else
            desc = "<size=50>来自鲸鲸的提醒：\n<color=#F2830DFF>捕鱼大奖赛</color>今晚20：30开始报名，21点准时开赛，你还没有门票，可以在比赛报名界面获取特惠门票哟~</size>"
        end
        local pre = HintPanel.Create(1, desc)
        pre:SetButtonText(nil, "我知道了")
        pre:SetDescLeft()
        return pre
    elseif parm.goto_scene_parm == "enter" then
        return BYBSXTSEnterPrefab.Create(parm.parent, parm.cfg)
    else
        dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
    end
    
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
end

function M.Init()
	M.Exit()

	this = BYBSXTSManager
	m_data = {}
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
	end
end
function M.OnReConnecteServerSucceed()
end
