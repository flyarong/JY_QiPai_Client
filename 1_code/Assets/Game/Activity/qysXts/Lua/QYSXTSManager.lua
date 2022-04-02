-- 创建时间:2019-10-22
-- 幸运抽奖管理器
-- 可以存放活动数据，配置，还有广播数据改变的消息

local basefunc = require "Game/Common/basefunc"
QYSXTSManager = {}
local M = QYSXTSManager
M.key = "qysXts"
GameButtonManager.ExtLoadLua(M.key, "QYSXTSEnterPrefab")

local this
local lister
local m_data

function M.CheckIsShow()
    local b = MatchModel.IsTodayHaveMatchByType(MatchModel.MatchType.qydjs)
    return b
end
function M.GotoUI(parm)
    if parm.goto_scene_parm == "panel" then
        print("<color=red> 千元赛提示</color>")
        local desc = ""
        local num = GameItemModel.GetItemTotalCount({ "obj_qianyuansai_ticket", "prop_2" })
        if num > 0 then
            desc = "<size=50>来自鲸鲸的提醒：\n<color=#F2830DFF>千元大奖赛</color>今晚20：30开始报名，21点准时开赛记得参加，不要错过哟~</size>"
        else
            desc = "<size=50>来自鲸鲸的提醒：\n<color=#F2830DFF>千元大奖赛</color>今晚20：30开始报名，21点准时开赛，你还没有门票，请前往\"活动\"页面中获取~</size>"
        end
        local pre = HintPanel.Create(1, desc)
        pre:SetButtonText(nil, "我知道了")
        pre:SetDescLeft()
        return pre
    elseif parm.goto_scene_parm == "enter" then
        return QYSXTSEnterPrefab.Create(parm.parent, parm.cfg)
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

	this = QYSXTSManager
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
