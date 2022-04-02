-- 创建时间:2018-09-11
GameAnimChatModel = {}
local config = SysInteractiveAniManager.config
local this
local m_data
local lister
local currPanel
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
	GameAnimChatModel.data={
		voiceList = {},-- 声音队列
	}
	m_data = GameAnimChatModel.data
end
function GameAnimChatModel.Init()
    InitData()
    this=GameAnimChatModel

    MakeLister()
    AddLister()
    
    currPanel = GameAnimChatPanel.Create()
    this.isCanPlay = true
    this.SpeedyConfig={
        config={},
    }
    for k,v in ipairs(config.Sheet1) do
    	if v.type == 1 or v.type == 2 then
    		this.SpeedyConfig.config[#this.SpeedyConfig.config + 1] = v
    	end
    end
    this.SpeedyConfig.mapconfig = {}
    for k,v in ipairs(this.SpeedyConfig.config) do
        this.SpeedyConfig.mapconfig[v.item_id] = v
    end

    return this
end
function GameAnimChatModel.Exit()
    if this then
        GameAnimChatPanel.Exit()
        currPanel = nil
        RemoveLister()
        this=nil
        m_data=nil
    end
end

function GameAnimChatModel.on_recv_voice_chat(_, data)
    dump(data, "<color=green>on_recv_voice_chat</color>")
    if not this.SpeedyConfig.mapconfig[tonumber(data.parm)] then
        return
    end
	this.PlayAnimChat(data)
end
function GameAnimChatModel.PlayAnimChat(data)
	if currPanel then
		currPanel:PlayAnimChat(data)
	end
end
function GameAnimChatModel.PlayFinish()
end
