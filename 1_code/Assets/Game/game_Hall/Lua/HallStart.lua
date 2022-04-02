
local basefunc = require "Game.Common.basefunc"
HallStart = basefunc.class()

function HallStart:Bind()
	return HallStart.New()
end

function HallStart:Awake()
	print("HallStart --- HallStart:Awake")
	package.loaded["Game.game_Hall.Lua.HallLogic"] = nil
	require "Game.game_Hall.Lua.HallLogic"
	HallLogic.Init()
end
