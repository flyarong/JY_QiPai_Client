-- 创建时间:2018-08-15

GameVoiceModel = {}

local this
local m_data
local lister
local voicePanel
local duration = 0.1
local UpdateTime
local isPlaying
local function MakeLister()
    lister = {}
    lister["recv_voice_chat"] = this.on_recv_voice_chat
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
	GameVoiceModel.data={
		voiceList = {},-- 声音队列
	}
	m_data = GameVoiceModel.data
end
function GameVoiceModel.Init()
    InitData()
    this=GameVoiceModel

	voicePanel = GameVoicePanel.Create()

    MakeLister()
    AddLister()
	UpdateTime = Timer.New(this.Update, duration, -1)
	UpdateTime:Start()
	isPlaying = false
    return this
end
function GameVoiceModel.Exit()
    if this then
        RemoveLister()
        if UpdateTime then
        	UpdateTime:Stop()
        end
        UpdateTime = nil
        this=nil
        m_data=nil
    end
end

function GameVoiceModel.on_recv_voice_chat(proto_name, data)
	dump(data.player_id, "<color=red>语音数据ID</color>")
    dump(string.len(data.data), "<color=red>语音数据长度</color>")
    if GameVoiceModel.IsInMatch() then
        dump("<color=red>锦标赛中不接受语音</color>")
        return
    end
	m_data.voiceList[#m_data.voiceList + 1] = data
end

function GameVoiceModel.Update()
	if not isPlaying and #m_data.voiceList > 0 then
		GameVoiceModel.PlayVoice()
	end
end
function GameVoiceModel.PlayVoice()
	isPlaying = true
	local v = m_data.voiceList[1]
	table.remove(m_data.voiceList, 1)
	voicePanel:PlayVoice(v)
end
function GameVoiceModel.PlayFinish()
	isPlaying = false
end

--是否在锦标赛中
function GameVoiceModel.IsInMatch()
    local myLocation = MainModel.myLocation
    if string.match(myLocation, "Match") then
        return true
    end
    return false
end
