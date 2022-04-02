
LoginModel={}

local this

--[[
    youke
    wechat
    device_id
    device_os
]]
local loginData
local lastLoginChannel

local ykKey = "yk_login_id"
local wxKey = "wx_login_id"
local qqKey = "qq_login_id"
local wxTokenKey = "wx_login_refresh_token"
local qqTokenKey = "qq_login_refresh_token"
local lastLoginChannelKey = "last_login_channel"

local function SaveLocalLoginData(channel,_id,_token)
    local path
    if AppDefine.IsEDITOR() then
        path = Application.dataPath
    else
        path = AppDefine.LOCAL_DATA_PATH
    end
    if channel == "youke" then
        File.WriteAllText(path .. "/" .. ykKey .. ".txt", _id)
    elseif channel == "yyb_wechat" then
        File.WriteAllText(path .. "/" .. wxKey .. ".txt", _id)
	File.WriteAllText(path .. "/" .. wxTokenKey .. ".txt", _token)
    elseif channel == "yyb_qq" then
        File.WriteAllText(path .. "/" .. qqKey .. ".txt", _id)
	File.WriteAllText(path .. "/" .. qqTokenKey .. ".txt", _token)
    elseif channel == "token" then
    end

    File.WriteAllText(path .. "/" .. lastLoginChannelKey .. ".txt", channel)
end
local function CloseLastLoginData()
    local path
    if AppDefine.IsEDITOR() then
        path = Application.dataPath
    else
        path = AppDefine.LOCAL_DATA_PATH
    end
    File.WriteAllText(path .. "/" .. lastLoginChannelKey .. ".txt", "")
end
local function GetLocalLoginData(name)
    local path
    if AppDefine.IsEDITOR() then
        path = Application.dataPath .. "/" .. name .. ".txt"
    else
        path = AppDefine.LOCAL_DATA_PATH .. "/" .. name .. ".txt"
    end
    if File.Exists(path) then
        return File.ReadAllText(path)
    else
        return ""
    end
end


local login_LTD = nil

local function SaveChannelLuaTable(tbl)
	local fileName = AppDefine.LOCAL_DATA_PATH .. "/" .. "_LLTD_.txt"
	if tbl then
		File.WriteAllText(fileName, lua2json(tbl))
	else
		File.WriteAllText(fileName, "")
	end
end
local function LoadChannelLuaTable()
	local tbl = nil

	local fileName = AppDefine.LOCAL_DATA_PATH .. "/" .. "_LLTD_.txt"
	if File.Exists(fileName) then
		local txt = File.ReadAllText(fileName)
		if txt ~= nil and txt ~= "" then
			tbl = json2lua(txt)
		end
	end

	return tbl
end

function LoginModel.UpdateChannelLuaTable(channel, tbl)
	if not this then return end

	this.login_LTD = this.login_LTD or {}
	if not tbl then
		this.login_LTD[channel] = nil
	else
		this.login_LTD[channel] = this.login_LTD[channel] or {}
		for k, v in pairs(tbl) do
			this.login_LTD[channel][k] = v
		end
	end
end

function LoginModel.ChannelLuaTableToJson(channel, kvs, mergeTbl)
	if not this or not this.login_LTD or not this.login_LTD[channel] then return "" end

	local luaTbl = {}

	local LTDC = this.login_LTD[channel]
	for k, v in pairs(kvs) do
		luaTbl[k] = LTDC[v]
	end

	for _, key in pairs(mergeTbl or {}) do
		luaTbl[key] = mergeTbl[key]
	end

	return lua2json(luaTbl)
end

function LoginModel.GetChannelLuaTable(channel)
	if not this or not this.login_LTD then return nil end
	return this.login_LTD[channel]
end

--[[
channel = {
},
last_channel = xxx

eg:
yk={
	id = xxxx,
	token = xxxx,
	refresh_token = xxxx,
	pf = xxxx,
	pfkey = xxxx,
	paytoken = xxxx,
	stamp = xxxx
},
qq={
	id = xxxx,
	token = xxxx,
	refresh_token = xxxx,
	pf = xxxx,
	pfkey = xxxx,
	paytoken = xxxx,
	stamp = xxxx
},
...
last_channel = qq
]]--

function SetChannelData(channel, _id, _token)
    SaveLocalLoginData(channel, _id, _token)
end

--初始化登录数据
local function InitLoginData( )

    this.loginData={
        youke=GetLocalLoginData(ykKey),
        wechat=GetLocalLoginData(wxKey),
	qq=GetLocalLoginData(qqKey),
	wx_refresh_token=GetLocalLoginData(wxTokenKey),
	qq_refresh_token=GetLocalLoginData(qqTokenKey),
        lastLoginChannel=GetLocalLoginData(lastLoginChannelKey),
    }

    --override
    this.login_LTD = LoadChannelLuaTable()
    if this.login_LTD then

        local yk = this.login_LTD.youke or {}
        local wx = this.login_LTD.yyb_wechat or {}
        local qq = this.login_LTD.yyb_qq or {}
        this.loginData.wx_refresh_token=wx.refresh_token or ""
        this.loginData.qq_refresh_token=qq.refresh_token or ""
        dump(this.login_LTD, "[LTD] override login data")
        dump(this.loginData, "[LTD] override login data loginData")
    end

    if this.loginData.youke == "" then
        this.loginData.youke = nil
    end

    if this.loginData.wechat == "" then
        this.loginData.wechat = nil
    end

    if this.loginData.qq == "" then
        this.loginData.qq = nil
    end

    if this.loginData.lastLoginChannel == "" then
        this.loginData.lastLoginChannel = nil
    end

    this.loginData.device_id = MainModel.LoginInfo.device_id
    this.loginData.device_os = MainModel.LoginInfo.device_os
end



local lister
local function AddLister()
    lister={}
    lister["OnLoginResponse"] = this.OnLoginResult
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

function LoginModel.Init()
    this = LoginModel

    AddLister()

    InitLoginData( )

    return this
end



function LoginModel.OnLoginResult(result)

    if result == 0 then
        local channel = MainModel.UserInfo.channel_type
        local loginId = MainModel.UserInfo.login_id
	local token = ""
	if channel == "yyb_wechat" then
		token = this.loginData.wx_refresh_token
	elseif channel == "yyb_qq" then
		token = this.loginData.qq_refresh_token
	end

        SetChannelData(channel,loginId,token)

	 --override
	this.login_LTD = this.login_LTD or {}
	this.login_LTD.last_channel = channel
	this.login_LTD[channel] = this.login_LTD[channel] or {}
	this.login_LTD[channel].loginid = loginId
	this.login_LTD[channel].refresh_token = token

	SaveChannelLuaTable(this.login_LTD)
        
    end

end



function LoginModel.ClearChannelData(channel)
    if this then
        this.loginData.channel = nil
    end

    if channel == "youke" then
        SaveLocalLoginData("youke", "", "")
        if this then
            this.loginData.youke = nil
        end
    elseif channel == "yyb_wechat" then
        SaveLocalLoginData("yyb_wechat", "", "")
        if this then
            this.loginData.wechat = nil
        end
    elseif channel == "yyb_qq" then
    	SaveLocalLoginData("yyb_qq", "", "")
        if this then
            this.loginData.qq = nil
        end
    else
    	print(debug.traceback())
    	return
    end

    --override
    if this and this.login_LTD then
	this.login_LTD.last_channel = nil
	this.login_LTD[channel] = nil
	SaveChannelLuaTable(this.login_LTD)
    end
end


function LoginModel.ClearLastLoginData()
    CloseLastLoginData()
    if this then
        this.loginData.lastLoginChannel=nil
    end
end

function LoginModel.Exit()
    
    if this then
        
        RemoveLister()

	this.loginData = {}
	this.loginData.device_id = MainModel.LoginInfo.device_id
	this.loginData.device_os = MainModel.LoginInfo.device_os
        this = nil
    end

end
