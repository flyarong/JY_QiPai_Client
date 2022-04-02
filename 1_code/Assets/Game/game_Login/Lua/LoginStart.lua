local basefunc = require "Game.Common.basefunc"
LoginStart = basefunc.class()

function LoginStart:Bind()
	return LoginStart.New()
end

function LoginStart:Awake()
	print("LoginStart -- LoginStart:Awake")
	package.loaded["Game.game_Login.Lua.LoginLogic"] = nil
	require "Game.game_Login.Lua.LoginLogic"
	LoginLogic.Init()
end
