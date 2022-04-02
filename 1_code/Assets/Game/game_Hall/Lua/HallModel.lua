

HallModel={}
local this
local lister
local function AddLister()
    lister={}
    lister["UpdateHallHeroRedHint"] = HallModel.UpdateHallHeroRedHint
    lister["UpdateHallBagRedHint"] = HallModel.UpdateHallBagRedHint
    lister["shared_finish_response"] = HallModel.UpdateHallShareRedHint
    lister["UpdateHallActivityYearRedHint"] = HallModel.UpdateHallActivityYearRedHint
    lister["UpdateHallTaskRedHint"] = HallModel.UpdateHallTaskRedHint
    lister["UpdateHallTaskRedHint"] = HallModel.UpdateHallTaskAccurateRedHint
    lister["UpdateHallBBSCTaskRedHint"] = HallModel.UpdateHallBBSCTaskRedHint
    lister["UpdateHallGoldenPigRedHint"] = HallModel.UpdateHallGoldenPigRedHint
    lister["UpdateHallVIPGiftRedHint"] = HallModel.UpdateHallVIPGiftRedHint
    lister["UpdataHallMoneyCenterRedHint"] = HallModel.UpdataHallMoneyCenterRedHint

    lister["model_task_change_msg"] = HallModel.on_model_task_change_msg
    lister["UpdateHallVIP2RedHint"] = HallModel.UpdateHallVIP2RedHint
    for msg,cbk in pairs(lister) do
        Event.AddListener(msg, cbk)
    end
end

local function RemoveLister()
    for msg,cbk in pairs(lister) do
        Event.RemoveListener(msg, cbk)
    end
    lister=nil
end

-- 初始化Data
local function InitMatchData()
    HallModel.data={
    rate = nil,
    }
end

function HallModel.Init()
    InitMatchData()
    this = HallModel

    AddLister()

    this.data.gameVersionStatus = nil
    local checkVersion = LuaFramework.AppConst.CheckVersionMode
    if checkVersion then
    	this.data.gameVersionStatus = {}
        local dict = gameMgr:GetGameStatus()
        local iter = dict:GetEnumerator()
        while iter:MoveNext() do
            local k = iter.Current.Key
            local v = iter.Current.Value
            this.data.gameVersionStatus[k] = v
            print("upd: " .. k .. " -- " .. v)
        end
    end
    Event.Brocast("HallModelInitFinsh")
    return this
end
function HallModel.Exit()

	if this then
	    
	    RemoveLister()

        m_data=nil

	    this = nil
    end
end

function HallModel.GetGameSceneCfgByPanel(panelName)
	local ret = {}
	local cfgTbl = GameSceneCfg
	for _, v in pairs(cfgTbl) do
		if v.PanelName == panelName then
			table.insert(ret, v)
		end
	end
	table.sort(ret, function(a, b) return a.ID < b.ID end)
	return ret
end

function HallModel.GetGameSceneCfgByScene(sceneName)
	local ret = {}
	local cfgTbl = GameSceneCfg
	for _, v in pairs(cfgTbl) do
		if v.SceneName == sceneName then
			table.insert(ret, v)
		end
	end
	table.sort(ret, function(a, b) return a.ID < b.ID end)
	return ret
end

function HallModel.UpdateHallHeroRedHint()
    RedHintManager.UpdateRedHint(RedHintManager.RedHintKey.RHK_Head)
    RedHintManager.UpdateRedHint(RedHintManager.RedHintKey.RHK_PhoneAward)
end
function HallModel.UpdateHallBagRedHint()
    RedHintManager.UpdateRedHint(RedHintManager.RedHintKey.RHK_Bag)
    --RedHintManager.UpdateRedHint(RedHintManager.RedHintKey.RHK_GD)
end
function HallModel.UpdateHallShareRedHint()
    RedHintManager.UpdateRedHint(RedHintManager.RedHintKey.RHK_Share)
end
function HallModel.UpdateHallActivityShareRedHint()
    RedHintManager.UpdateRedHint(RedHintManager.RedHintKey.RHK_ActivitySharePanel)
end

function HallModel.UpdateHallActivityYearRedHint()
    RedHintManager.UpdateRedHint(RedHintManager.RedHintKey.RHK_Activity)
    RedHintManager.UpdateRedHint(RedHintManager.RedHintKey.RHK_Activity_GET)

    RedHintManager.UpdateRedHint(RedHintManager.RedHintKey.RHK_Activity_Year)
    RedHintManager.UpdateRedHint(RedHintManager.RedHintKey.RHK_Activity_Year_Get)
end

function HallModel.UpdateHallTaskRedHint()
    RedHintManager.UpdateRedHint(RedHintManager.RedHintKey.RHK_Task)
    RedHintManager.UpdateRedHint(RedHintManager.RedHintKey.RHK_Weekly_Card)
end

function HallModel.UpdateHallTaskAccurateRedHint()
    RedHintManager.UpdateRedHint(RedHintManager.RedHintKey.RHK_Task_Accurate)
end

function HallModel.UpdataHallMoneyCenterRedHint()
    RedHintManager.UpdateRedHint(RedHintManager.RedHintKey.RHK_Money_Center)
end
function HallModel.UpdateHallBBSCTaskRedHint()
    RedHintManager.UpdateRedHint(RedHintManager.RedHintKey.RHK_BBSC_Task)
    local isRed = RedHintManager.IsKeyRed(RedHintManager.RedHintKey.RHK_BBSC_Task)
    Event.Brocast("HallModelBBSCTaskRedHint", isRed)
end

function HallModel.UpdateHallGoldenPigRedHint()
    RedHintManager.UpdateRedHint(RedHintManager.RedHintKey.RHK_Golded_Pig)
end

function HallModel.UpdateHallVIPGiftRedHint()
    RedHintManager.UpdateRedHint(RedHintManager.RedHintKey.RHK_VIP_Gift)
end

function HallModel.on_model_task_change_msg(data)
    if data and data.id then
        if data.id == 53 or data.id == 54 then
            RedHintManager.UpdateRedHint(RedHintManager.RedHintKey.RHK_Weekly_Card)
        end
    end
    if data and data.id then
        if data.id == 106 or data.id == 107 then
            Network.SendRequest("query_one_task_data", {task_id = data.id})
        end
    end
end

function HallModel.UpdateHallVIP2RedHint()
    RedHintManager.UpdateRedHint(RedHintManager.RedHintKey.RHK_VIP2)
end