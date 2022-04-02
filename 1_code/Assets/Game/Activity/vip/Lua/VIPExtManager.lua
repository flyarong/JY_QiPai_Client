-- 创建时间:2020-04-13
-- VIPExtManager 管理器
-- 4.21 vip功能新增部分的manager
local basefunc = require "Game/Common/basefunc"
VIPExtManager = {}
local M = VIPExtManager
local this
local lister
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
    lister["global_hint_state_set_msg"] = this.on_global_hint_state_set_msg
end

function M.Init()
	M.Exit()

	this = VIPExtManager
	this.m_data = {}
	MakeLister()
    AddLister()
    M.InitUIConfig()
    HandleLoadChannelLua("VIPExtManager",VIPExtManager)
end
function M.Exit()
	if this then
		RemoveLister()
		this = nil
	end
end
function M.InitUIConfig()
    this.UIConfig = {}
end

function M.OnLoginResponse(result)
	if result == 0 then
        -- 数据初始化
	end
end

function M.OnReConnecteServerSucceed()

end

--获取玩家可以达到的VIP等级上限
function M.GetUserMaxVipLevel()
    if M.IsCanUpLevel() then
        return 12
    else
        return 10
    end
end
--是否可以升级VIP等级
function M.IsCanUpLevel()
    return true
end
M.Exit()
M.Init()