-- 创建时间:2018-09-10
GameSpeedyModel = {}
local config = SysInteractiveChatManager.config
local this
local m_data
local lister
local voicePanel
local function MakeLister()
    lister = {}
    lister["recv_player_easy_chat"] = this.on_recv_voice_chat
end
local function AddLister()
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
local function InitData()
	GameSpeedyModel.data={
		voiceList = {},-- 声音队列
	}
	m_data = GameSpeedyModel.data
end
function GameSpeedyModel.Init()
    InitData()
    this=GameSpeedyModel

    MakeLister()
    AddLister()
    
    this.isCanPlay = true
    this.SpeedyConfig={
        config={},
    }
    this.SpeedyConfig.mapconfig = {}
    for k,v in ipairs(config.Sheet1) do
        if v.type == 0 then
            this.SpeedyConfig.mapconfig[v.item_id] = v
        end
    end
    voicePanel = GameSpeedyPanel.Create()

    return this
end
function GameSpeedyModel.Exit()
    if this then
        GameSpeedyPanel.Exit()
        voicePanel = nil
        RemoveLister()
        this=nil
        m_data=nil
    end
end

function GameSpeedyModel.GetSpeedyData()
    this.SpeedyConfig.config = {}
    local data = PersonalInfoManager.GetSpeedyData(true)
    for k,v in ipairs(data) do
        if v.type == 0 and (not v.sex or v.sex == MainModel.UserInfo.sex) then
            this.SpeedyConfig.config[#this.SpeedyConfig.config + 1] = v
        end
    end
    return this.SpeedyConfig.config
end

function GameSpeedyModel.on_recv_voice_chat(_, data)
    dump(data, "<color=red>快捷聊天数据</color>")
    if not this.SpeedyConfig.mapconfig[tonumber(data.parm)] then
        return
    end
    if GameSpeedyModel.IsInMatch() then
        dump("<color=red>锦标赛中不接受语音</color>")
        return
    end
	this.PlayVoice(data)
end
function GameSpeedyModel.PlayVoice(data)
    if voicePanel then
        voicePanel:PlayVoice(data)
    end
end
function GameSpeedyModel.PlayFinish(key)
    if voicePanel then
        voicePanel:PlayFinish(key)
    end
end

--是否在锦标赛中
function GameSpeedyModel.IsInMatch()
    local myLocation = MainModel.myLocation
    if string.match(myLocation, "Match") then
        return true
    end
    return false
end
