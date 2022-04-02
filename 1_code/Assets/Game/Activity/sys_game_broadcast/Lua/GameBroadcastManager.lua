-- 创建时间:2018-11-26
-- 游戏滚动广播管理器

local basefunc = require "Game.Common.basefunc"
local config = SysGameBroadcastManager.config
local fish_cfg_list = {}
GameBroadcastManager = {}

local this
local lister
local listermsg
local autoKey = 1
local autoMax = 1000000000
local beginBroadcast
local multicastRepMsg = {}

local function AddLister(data)
    for msg,cbk in pairs(data) do
        Event.AddListener(msg, cbk)
    end
end

local function RemoveLister(data)
    if data then
        for msg,cbk in pairs(data) do
            Event.RemoveListener(msg, cbk)
        end
    end
end
local function MakeLister()
    lister = {}
    listermsg = {}
    lister["OnLoginResponse"] = this.OnLoginResponse
    lister["ExitScene"] = this.OnExitScene
    lister["EnterScene"] = this.OnEnterScene

    listermsg["multicast_msg"] = this.on_multicast_msg
end

function GameBroadcastManager.Init()
	GameBroadcastManager.Exit()
	print("<color=red>初始化游戏滚动广播管理器</color>")
	this = GameBroadcastManager
    
    MakeLister()
    AddLister(lister)

    autoKey = 1
    autoMax = 1000000000
    beginBroadcast = true

    this.InitConfig(config)
end

function GameBroadcastManager.Exit()
	if this then
		this.MulticastMsg = nil
        this.SysMulticastMsg = nil
        this.BulletQueue = nil
        this.WinSleepQueue = nil
		RemoveLister(lister)
        RemoveLister(listermsg)
		this = nil
	end
end
function GameBroadcastManager.InitConfig(cfg)
    fish_cfg_list = {}
    for i,v in ipairs(cfg.fishing_match) do
        fish_cfg_list.master = fish_cfg_list.master or {}
        fish_cfg_list.vice = fish_cfg_list.vice or {}
        if v.master == 1 then
            fish_cfg_list.master[#fish_cfg_list.master +1] = v
        elseif v.master == 0 then
            fish_cfg_list.vice[#fish_cfg_list.vice + 1] = v
        end
    end
end

--正常登录成功
function GameBroadcastManager.OnLoginResponse(result)
    if result==0 then
        RemoveLister(listermsg)
	    AddLister(listermsg)
    	this.StartManager()
    else
    end
end

function GameBroadcastManager.OnEnterScene()
    beginBroadcast = true
end
function GameBroadcastManager.OnExitScene()
    beginBroadcast = false
end

function GameBroadcastManager.StartManager()
	this.MulticastMsg = basefunc.queue.New()
    this.SysMulticastMsg = basefunc.queue.New()
    this.BulletQueue = basefunc.queue.New()
    this.WinSleepQueue = basefunc.queue.New()
end

local getKey =function (data)
    if autoKey >= autoMax then
        autoKey = 1
    else
        autoKey = autoKey + 1
    end
    return "Broadcast" .. autoKey
end
-- 滚动广播消息监听
function GameBroadcastManager.on_multicast_msg(_, msg)
	if not GameGlobalOnOff.MulticastMsg then return end
--[[
    multicastRepMsg[msg.content] = multicastRepMsg[msg.content] or {num=0,time=os.time()}
    local mrm = multicastRepMsg[msg.content]
    mrm.num = mrm.num + 1
    if mrm.num > 3 and os.time()-mrm.time<2 then
        return
    elseif os.time()-mrm.time>1 then
        multicastRepMsg[msg.content] = nil
    end

    local key=getKey(msg)
    this.MulticastMsg:push_back({key=key, msg=msg, time=os.time()})
    if this.MulticastMsg:size()>50 then
        this.MulticastMsg:pop_front()
    end
--]]
    local key=getKey(msg)
    if msg.type == 1 then
        this.MulticastMsg:push_back({key=key, msg=msg, time=os.time()})
        if this.MulticastMsg:size()>50 then
            this.MulticastMsg:pop_front()
        end
    elseif msg.type == 2 then
        this.SysMulticastMsg:push_back({key=key, msg=msg, time=os.time()})
        if this.SysMulticastMsg:size()>50 then
            this.SysMulticastMsg:pop_front()
        end
    elseif msg.type == 3 then
        --捕鱼比赛广播
        this.BulletQueue:push_back({key=key, msg=msg, time=os.time()})
        if this.BulletQueue:size()>50 then
            this.BulletQueue:pop_front()
        end
    elseif msg.type == 5 then
        --赢一把就睡觉
        this.WinSleepQueue:push_back({key=key, msg=msg, time=os.time()})
        if this.WinSleepQueue:size()>50 then
            this.WinSleepQueue:pop_front()
        end
    end

    --登录场景广播条不显示
    if beginBroadcast and MainModel.myLocation ~= "game_Login" and MainModel.myLocation ~= "game_Loding" then
        GameBroadcastRollPanel.PlayRoll()
        GameSysBroadcastRollPanel.PlayRoll()
        GameBroadcastBulletPanel.PlayRoll()
        Event.Brocast("manager_multicast_msg")
    end
end


function GameBroadcastManager.PlayFinish(key)
    GameBroadcastRollPanel.PlayFinish(key)
end

function GameBroadcastManager.PlaySysFinish(key)
    GameSysBroadcastRollPanel.PlayFinish(key)
end

function GameBroadcastManager.PlayBulletFinish(key)
    GameBroadcastBulletPanel.PlayFinish(key)
end

-- 获取最前面的滚动广播数据
function GameBroadcastManager.GetRollFront()
    if this.MulticastMsg then
        return this.MulticastMsg:pop_front()
    end
end

-- 获取最前面的滚动系统广播数据
function GameBroadcastManager.GetSysRollFront()
    if this.SysMulticastMsg then
        return this.SysMulticastMsg:pop_front()
    end
end

-- 获取最前面的弹幕广播数据
function GameBroadcastManager.GetBulletFront()
    if this.BulletQueue then
        return this.BulletQueue:pop_front()
    end
end

-- 获取最前面的赢一把就睡觉广播数据
function GameBroadcastManager.GetWinSleepFront()
    if this.WinSleepQueue then
        return this.WinSleepQueue:pop_front()
    end
end

function GameBroadcastManager.GetFMCfg()
    return fish_cfg_list
end

function GameBroadcastManager.CreateRandomViceBroadcast()
    math.randomseed(tostring(os.time()):reverse():sub(1, 6))
    local num = math.random(30,50)
    local k = 1
    --时间随机
    for i=1,num do
        math.randomseed(tostring(os.time() + k):reverse():sub(1, 6))
        k = k + 1
        local index = math.random( 1,#fish_cfg_list.vice)
        local cfg = fish_cfg_list.vice[index]
        Event.Brocast("multicast_msg", "multicast_msg", {type = 3,master = 0, broadcast_content=cfg.content})
    end
end

