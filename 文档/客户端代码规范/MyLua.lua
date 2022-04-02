--[[
	Code

	类, 方法, 枚举, public 字段, public 属性, 命名空间的命名规则用: PascalCase.
	局部变量，函数参数命名规则用: camelCase.
	local 字段和属性的命名规则用: _camelCase.
	命名规则不受const, static, readonly等修饰符影响.
	对于缩写，也按PascalCase 命名，比如 MyRpc而不是MyRPC.

	特殊的：对于局部方法，认为是局部变量：小写字母加下划线隔开 
			例如：local function get_string() end
				  local get_string
				  get_string = function() end

	Files

	文件和文件夹 命名规则为PascalCase, 例如 MyFile.lua.
	文件名尽量和文件中主要的类名一直, 例如 MyClass.lua.
	通常，一个文件中一个类.
	

	Other:
	-- 网络协议消息以小写字母加下划线隔开 xxx_yyy，对应函数前加on_, 如：on_xxx_yyy。方法放一起
	-- 普通消息用PascalCase 如：LoginFinish，对应函数前加On, 如: OnLoginFinish。方法放一起
	--注释后留空格 -- xxxxx
]]

--[[
	资源命名规则应当为 PascalCase.   MyPrefab, MyMat , MyTexture, MyTexture1, MyTexture2
	资源名字应当有意义：如 NewSprite, T1, T2 等无意义的资源命名是错误的
	特殊的：
		1，当前美术出的资源全部小写字母加下划线加数字后缀  aaa_bbb, aaa_bbb_1,aaa_bbb_2，程序自己添加的资源是否需要使用 PascalCase 命名规则
		2，预制体中的节点命名规则应当为 PascalCase. 带 @符号的为小写字母加下划线：@youke_login_btn
]]

local _basefunc = require "Game/Common/basefunc" -- local私有成员 _camelCase

MyLua = _basefunc.class() -- classes 命名规则为 PascalCase.
local M = MyLua		-- 使用M持有类

MyEnum = {		-- Enumerations 命名规则为 PascalCase.
    Yes = 1, 	-- Enumerations 命名规则为 PascalCase，并显示标注对应值
    No = 2, 	
}

MyValue = ""		-- 全局变量 命名规则为 PascalCase.
M.Name = "MyLua"	-- Public 公有成员变量命名规则为 PascalCase.

local _instance		-- Private 私有成员变量命名规则为 _camelCase.

local function MyFunc() -- 方法函数 命名规则为 PascalCase 
	
end

local function GetId()	-- 对于缩写，也按PascalCase 命名，比如 MyRpc而不是MyRPC.
	
end

local function GetUrl() -- 对于缩写，也按PascalCase 命名，比如 MyRpc而不是MyRPC.
	
end

local _listener
local function MakeListener()
	_listener = {}
	-- 网络协议消息以小写字母加下划线隔开 xxx_yyy，对应函数前加on_, 如：on_xxx_yyy
	_listener["driver_ready_ok_msg"] = M.on_driver_ready_ok_msg
	_listener["drive_game_player_op_req_response"] = M.on_drive_game_player_op_req_response

	-- 普通消息用PascalCase 如：LoginFinish，对应函数前加On, 如: OnLoginFinish
	_listener["LoginFinish"] = M.OnLoginFinish
	_listener["EnterScene"] = M.OnEnterScene
end

local function AddListener()
    MakeListener()
    for name, func in pairs(_listener) do
        Event.AddListener(name, func)
    end
end

local function RemoveMsgListener()
    for name, func in pairs(_listener) do
        Event.RemoveListener(name, func)
    end
end

-- local 成员放在最上面^^^

function M.Create()	-- 方法函数 命名规则为 PascalCase 
	_instance = M.New()	-- 操作符前后用个空格分割
	return _instance
end

function M.FrameUpdate(timeElapsed)	-- 函数参数命名规则用: camelCase.
    SpawnBulletManager.FrameUpdate(timeElapsed)
end

function M:AddMsgListener()
    for protoName,func in pairs(self.lister) do -- Local variables (protoName, self.lister) 局部变量命名规则为camelCase.
        Event.AddListener(protoName, func)
    end
end

function M:MakeLister()
    self.lister = {}
	self.lister["login_finish"] = _basefunc.handler(self,self.on_login_finish)
end

function M:RemoveListener()
    for protoName,func in pairs(self.lister) do
        Event.RemoveListener(protoName, func)
    end
    self.lister = {}
end

function M:MyExit()
	self:RemoveListener()
	destroy(self.gameObject)
end

function M:OnDestroy()
	self:MyExit()
end

function M:MyClose()
	self:MyExit()
end

function M:ctor()	--错误示例：需要更改
	ExtPanel.ExtMsg(self)
	local parent = GameObject.Find("Canvas/GUIRoot").transform	-- Local variables 局部变量命名规则为camelCase.
	local obj = newObject(M.name, parent)
	local tran = obj.transform
	self.transform = tran	-- Local variables (self.xxx) 局部变量命名规则为camelCase.
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	local function get_string() -- Local variables (self.xxx) 局部变量命名规则为camelCase.
		
	end

	local set_string
	set_string = function ()
		
	end

	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function M:InitUI()
	self:MyRefresh()
end

function M:MyRefresh()
end

function M.on_driver_ready_ok_msg()
	
end

function M.on_drive_game_player_op_req_response()
	
end

function M.OnEnterScene()
	
end

function M.OnLoginFinish()
	
end

return M	-- 最后返回类