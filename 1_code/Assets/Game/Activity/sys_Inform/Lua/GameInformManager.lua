-- 创建时间:2018-09-10
-- 游戏本地通知管理器

local config = require "Game.CommonPrefab.Lua.game_inform_config"	--配置

GameInformManager = {}

local this
local UpdateTimer
local lister
local InformList = {}

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
    lister["EnterScene"] = this.OnEnterScene
    lister["ExitScene"] = this.OnExitScene
    lister["ReConnecteServerSucceed"] = this.OnReConnecteServerSucceed
    lister["OnLoginResponse"] = this.OnLoginResponse
end

function GameInformManager.Init()
	GameInformManager.Exit()
	print("<color=red>初始化游戏本地通知管理器</color>")
	this = GameInformManager

    MakeLister()
    AddLister()
    -- 能否提示
    this.isCanHint = false

    this.InformConfig={
        config={},
    }
    this.InformConfig.config = config.config

    UpdateInformTimer = Timer.New(this.UpdateInform, 1, -1, nil, true)
	UpdateInformTimer:Start()

	this.InitUpdateInform()
end
function GameInformManager.UpdateInform()
	if this then
		if this.isCanHint and InformList and next(InformList) then
			print("<color=red>通知 UpdateInform</color>")
			local v = InformList[1]
			table.remove(InformList, 1)
			GameInformPanel.AddInform(v)
		end
	end
end
function GameInformManager.AddInform(key)
	print("<color=red>AddInform = " .. key .. "</color>")
	InformList[#InformList + 1] = key
end

-- 是否在范围内
local IsOnRange = function (t1, t2, tt)
    if tt >= t1 and tt <= t2 then
        return true
    end
    return false
end

function GameInformManager.CloseInform()
	if UpdateTimer then
		for k,v in ipairs(UpdateTimer) do
			v:Stop()
		end
	end
	UpdateTimer = {}
end
function GameInformManager.InitUpdateInform()
	if this then
		this.CloseInform()
		local nowtime = os.time()
		print("nowtime = " .. nowtime)
		for k,v in ipairs(this.InformConfig.config) do
			if v.isOnOff == 1 then
				if nowtime < v.beginTime then
					local t = v.beginTime - nowtime
					print("<color=red>通知倒计时 tt = " .. t .. "</color>")
					local kk = k
					local tt = Timer.New(function ()
						this.AddInform(kk)
					end, t, 1, nil, true)
	    			tt:Start()
	    			UpdateTimer[#UpdateTimer + 1] = tt
				elseif IsOnRange(v.beginTime, v.endTime, nowtime) then
					this.AddInform(k)
				else
					print("不满足条件" .. k)
				end
			end
		end
	end
end

function GameInformManager.Exit()
	if this then
		RemoveLister()
		this.CloseInform()
		if UpdateInformTimer then
			UpdateInformTimer:Stop()
		end
		UpdateInformTimer = nil
		this = nil
	end
end

--正常登录成功
function GameInformManager.OnLoginResponse(result)
    if result==0 then
    else
    end
end
--断线重连后登录成功
function GameInformManager.OnReConnecteServerSucceed(result)
    if result==0 then
    else
    end
end
-- 进入场景
function GameInformManager.OnEnterScene()
    if MainModel.myLocation == "game_Login" or MainModel.myLocation == "game_Loding" then
    	this.isCanHint = false
    else
    	this.isCanHint = true
    end
end
-- 退出场景
function GameInformManager.OnExitScene()
	this.isCanHint = false
	GameInformPanel.Close()
end




