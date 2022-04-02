MatchHallLogic = {}
local M = MatchHallLogic

package.loaded["Game.game_MatchHall.Lua.MatchHallModel"] = nil
require "Game.game_MatchHall.Lua.MatchHallModel"
package.loaded["Game.game_MatchHall.Lua.MatchHallPanel"] = nil
require "Game.game_MatchHall.Lua.MatchHallPanel"
package.loaded["Game.game_MatchHall.Lua.MatchHallDetailPanel"] = nil
require "Game.game_MatchHall.Lua.MatchHallDetailPanel"
package.loaded["Game.game_MatchHall.Lua.MatchHallRankPanel"] = nil
require "Game.game_MatchHall.Lua.MatchHallRankPanel"
package.loaded["Game.game_MatchHall.Lua.MatchHallMatchItem"] = nil
require "Game.game_MatchHall.Lua.MatchHallMatchItem"
package.loaded["Game.game_MatchHall.Lua.MatchHallTge"] = nil
require "Game.game_MatchHall.Lua.MatchHallTge"
package.loaded["Game.game_MatchHall.Lua.MatchHallContent"] = nil
require "Game.game_MatchHall.Lua.MatchHallContent"
package.loaded["Game.game_MatchHall.Lua.MatchHallRulePanel"] = nil
require "Game.game_MatchHall.Lua.MatchHallRulePanel"
package.loaded["Game.game_MatchHall.Lua.MatchHallHintQYSPanel"] = nil
require "Game.game_MatchHall.Lua.MatchHallHintQYSPanel"

--捕鱼比赛
package.loaded["Game.normal_fishing_common.Lua.FishingMatchSignupPanel"] = nil
require "Game.normal_fishing_common.Lua.FishingMatchSignupPanel"
package.loaded["Game.normal_fishing_common.Lua.FishingMatchAwardPanel"] = nil
require "Game.normal_fishing_common.Lua.FishingMatchAwardPanel"
package.loaded["Game.normal_fishing_common.Lua.FishingMatchOldRankPanel"] = nil
require "Game.normal_fishing_common.Lua.FishingMatchOldRankPanel"
package.loaded["Game.normal_fishing_common.Lua.FishingBKPanel"] = nil
require "Game.normal_fishing_common.Lua.FishingBKPanel"

package.loaded["Game.normal_commatch_common.Lua.ComMatchLogic"] = nil
require "Game.normal_commatch_common.Lua.ComMatchLogic"

local this
local lister
local cur_panel
local panelNameMap={
	hall="MatchHallPanel",
}
local update_timer
local updateDt = 1
--view关心的事件
local viewLister={}

local function MakeLister()
    lister = {}
end

local function AddMsgListener(lister)
    for proto_name, func in pairs(lister) do
        Event.AddListener(proto_name, func)
    end
end

local function RemoveMsgListener(lister)
    for proto_name, func in pairs(lister) do
        Event.RemoveListener(proto_name, func)
    end
end

local function ViewMsgRegister(registerName)
    if registerName then
        if viewLister and viewLister[registerName] then
            AddMsgListener(viewLister[registerName])
        end
    else
        if viewLister then
            for k, lister in pairs(viewLister) do
                AddMsgListener(lister)
            end
        end
    end
end

local function cancelViewMsgRegister(registerName)
    if registerName then
        if viewLister and viewLister[registerName] then
            RemoveMsgListener(viewLister[registerName])
        end
    else
        if viewLister then
            for k, lister in pairs(viewLister) do
                RemoveMsgListener(lister)
            end
        end
    end
    DOTweenManager.KillAllStopTween()
end

local function clearAllViewMsgRegister()
    cancelViewMsgRegister()
    viewLister = {}
end

function M.setViewMsgRegister(lister, registerName)
    --检测是否已经注册
    if not registerName or viewLister[registerName] then
        return false
    end
    viewLister[registerName] = lister
    ViewMsgRegister(registerName)
end

function M.clearViewMsgRegister(registerName)
    if not registerName then
        return false
    end
    cancelViewMsgRegister(registerName)
    viewLister[registerName] = nil
end

function M.change_panel(panelName)
	if cur_panel then
		if cur_panel.name==panelName then
			cur_panel.instance:MyRefresh()
		else
			DOTweenManager.KillAllStopTween()
			cur_panel.instance:MyClose()
			cur_panel=nil
		end
	end
	if not cur_panel then
		if panelName==panelNameMap.hall then
			cur_panel={name=panelName,instance=MatchHallPanel.Create()}
		end
	end
end

--初始化
function M.Init(parm)
    ExtendSoundManager.PlaySceneBGM(audio_config.game.bgm_main_hall.audio_name)
    dump(parm,"<color=green>比赛场大厅初始化？？？？？</color>")
    this = M
    if parm and parm.hall_type then
        MatchModel.SetCurHallType(parm.hall_type)
    end
    --初始化model
    local model = MatchHallModel.Init()
    MakeLister()
    AddMsgListener(lister)
    M.change_panel(panelNameMap.hall)
    update_timer = Timer.New(M.Update, updateDt, -1, nil, true)
    update_timer:Start()
end

function M.Update()
    
end

function M.Exit()
    if this then
        if update_timer then
            update_timer:Stop()
            update_timer = nil
        end
        MatchHallModel.Exit()
        if cur_panel then
            cur_panel.instance:MyExit()
        end
        cur_panel = nil
        RemoveMsgListener(lister)
        clearAllViewMsgRegister()
        this = nil
    end
end

return M