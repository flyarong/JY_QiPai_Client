-- 创建时间:2019-03-06
package.loaded["Game.game_FishingTest.Lua.FishingTestModel"] = nil
require "Game.game_FishingTest.Lua.FishingTestModel"
package.loaded["Game.game_FishingTest.Lua.FishingTestGamePanel"] = nil
require "Game.game_FishingTest.Lua.FishingTestGamePanel"
package.loaded["Game.game_Fishing.Lua.Vehicle"] = nil
require "Game.game_Fishing.Lua.Vehicle"
package.loaded["Game.game_Fishing.Lua.FishManager"] = nil
require "Game.game_Fishing.Lua.FishManager"
package.loaded["Game.game_Fishing.Lua.BulletManager"] = nil
require "Game.game_Fishing.Lua.BulletManager"
package.loaded["Game.game_Fishing.Lua.BulletPrefab"] = nil
require "Game.game_Fishing.Lua.BulletPrefab"
package.loaded["Game.game_Fishing.Lua.FishingPlayer"] = nil
require "Game.game_Fishing.Lua.FishingPlayer"
package.loaded["Game.game_Fishing.Lua.FishingGun"] = nil
require "Game.game_Fishing.Lua.FishingGun"
package.loaded["Game.game_Fishing.Lua.Fish"] = nil
require "Game.game_Fishing.Lua.Fish"
package.loaded["Game.game_Fishing.Lua.FishNetPrefab"] = nil
require "Game.game_Fishing.Lua.FishNetPrefab"
package.loaded["Game.game_Fishing.Lua.FishingPlayerAIManager"] = nil
require "Game.game_Fishing.Lua.FishingPlayerAIManager"
package.loaded["Game.game_Fishing.Lua.FishingAnimManager"] = nil
require "Game.game_Fishing.Lua.FishingAnimManager"
require "Game.game_Fishing.Lua.VehicleManager"
package.loaded["Game.game_FishingTest.Lua.FishingMouseDrawLinePanel"] = nil
require "Game.game_FishingTest.Lua.FishingMouseDrawLinePanel"

FishingTestLogic = {}
local M = FishingTestLogic
local MModel = FishingTestModel
local MView = FishingTestGamePanel
local MViewInstance
local MDrawLine = FishingMouseDrawLinePanel
local MDrawLineInstance

-- Logic 的 Update
local update

function M.RefreshViewPanel()
    if MViewInstance then
        MViewInstance:MyRefresh()
    end
end

function M.Update()
	if MViewInstance then
        MViewInstance:FrameUpdate()
	end
end

function M.Init(isNotSendAllInfo)
    --初始化model
    local model = MModel.Init()
    update = Timer.New(M.Update, MModel.Defines.FrameTime, -1)
    update:Start()
    MainLogic.EnterGame()
    MViewInstance = MView.Create()
    MDrawLineInstance = MDrawLine.Create()
end

function M.Exit()
    if M then
        M = nil
        update:Stop()
        update = nil
        if MViewInstance then
            MViewInstance:MyExit()
        end
        MViewInstance = nil
        if MDrawLineInstance then
            MDrawLineInstance:MyExit()
        end
        MDrawLineInstance = nil
        MModel.Exit()
    end
end

return M