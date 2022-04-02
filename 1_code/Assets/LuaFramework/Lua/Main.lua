-- 主入口函数。从这里开始lua逻辑
function Main()
	--LuaFramework.Util.log("Hello lua")
	print("logic start")
	print("hello lua")
end

-- 场景切换通知
function OnLevelWasLoaded(level)
	collectgarbage("collect")
	Time.timeSinceLevelLoad = 0
end

function OnApplicationQuit()
end