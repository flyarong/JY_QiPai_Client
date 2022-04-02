-- 创建时间:2018-11-09
-- 游戏个人中心管理器

-- 快捷聊天 互动表情 头像框
ext_require_audio("Game.Activity.sys_interactive_player.Lua.audio_player_config","player")
PersonalInfoManager = {}
local config_player = SysInteractivePlayerManager.config
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
    lister["EnterScene"] = this.OnEnterScene
    lister["ExitScene"] = this.OnExitScene
    lister["ReConnecteServerSucceed"] = this.OnReConnecteServerSucceed
    lister["OnLoginResponse"] = this.OnLoginResponse
    lister["notify_dress_change_msg"] = this.notify_dress_change_msg
    lister["query_dress_data_response"] = this.query_dress_data_response
    lister["notify_dress_item_change_msg"] = this.notify_dress_item_change_msg

    lister["recv_player_easy_chat"] = this.on_recv_voice_chat

end

function PersonalInfoManager.Init()
	PersonalInfoManager.Exit()
	print("<color=red>初始化游戏个人中心管理器</color>")
	this = PersonalInfoManager
    MakeLister()
	AddLister()
    this.InitConfig()
end

function PersonalInfoManager.Exit()
	if this then
		RemoveLister()
		this = nil
	end
end
function PersonalInfoManager.InitConfig()
	this.Config={
		dressMap={},
        speedy={},
        anim={},
        head={},
    }

    for k,v in ipairs(config_player.Sheet1) do
    	this.Config.dressMap[v.item_id] = v
    	if v.type == 0 then
    		this.Config.speedy[#this.Config.speedy + 1] = v
		elseif v.type == 1 or v.type == 2 then
			this.Config.anim[#this.Config.anim + 1] = v
		else
			this.Config.head[#this.Config.head + 1] = v
    	end
    end
end

--正常登录成功
function PersonalInfoManager.OnLoginResponse(result)
    if result==0 then
    else
    end
end
--断线重连后登录成功
function PersonalInfoManager.OnReConnecteServerSucceed(result)
end
-- 进入场景
function PersonalInfoManager.OnEnterScene()
	-- todo nmg 装扮数据第一次获取
	if not this.dress_data_map then
		if MainModel.myLocation == "game_Hall" then
			Network.SendRequest("query_dress_data", nil, "请求装扮数据")
		end
	end
end
-- 退出场景
function PersonalInfoManager.OnExitScene()
end

function PersonalInfoManager.UpdateDressData(data)
	this.dress_data_map = {}
	for kk, vv in pairs(data) do
		for k,v in ipairs(vv) do
			local dd = {}
			dd.id = v.id
			dd.num = v.num
			dd.time = v.time
			this.dress_data_map[v.id] = dd
		end
	end

	Event.Brocast("model_dress_data")
end

-- 装扮数据
function PersonalInfoManager.query_dress_data_response(_,data)
	dump(data, "<color=yellow>装扮数据</color>")
	PersonalInfoManager.UpdateDressData(data.dress_data)
end

-- 通知装扮数据
function PersonalInfoManager.notify_dress_change_msg(_,data)
	PersonalInfoManager.UpdateDressData(data.dress_data)
end

-- 通知一个装扮数据
function PersonalInfoManager.notify_dress_item_change_msg(_,data)
	local v = {}
	v.id = data.dress_id
	v.num = data.dress_num
	v.time = data.dress_time
	this.dress_data_map[data.dress_id] = v
end

-- 请求装扮数据
function PersonalInfoManager.ReqDressData()
	if this.dress_data_map then
		Event.Brocast("model_dress_data")
	else
		Network.SendRequest("query_dress_data")
	end
end

-- 获取自己的头像框ID
function PersonalInfoManager.GetSelfHeadID()
	return MainModel.UserInfo.dressed_head_frame
end
-- 设置自己的头像框ID
function PersonalInfoManager.SetSelfHeadID(id)
	MainModel.UserInfo.dressed_head_frame = id
	Event.Brocast("update_dressed_head_frame")
end

local callSort = function (v1, v2)
	if v1.isCanUser and not v2.isCanUser then
		return false
	elseif not v1.isCanUser and v2.isCanUser then
		return true
	else
		if v1.order > v2.order then
			return true
		else
			return false
		end
	end
end
-- 获取个人中心头像框数据
function PersonalInfoManager.GetHeadData(isAll)
	local data = {}
	for k,v in ipairs(this.Config.head) do
		if isAll or (v.show_playerinfo and v.show_playerinfo == 1) then
			local vv = {}
	        for k1,v1 in pairs(v) do
	            vv[k1] = v1
	        end
	        if this.dress_data_map[v.item_id] then
	        	vv.isCanUser = true
	        	vv.num = this.dress_data_map[v.item_id].num
	        	vv.time = this.dress_data_map[v.item_id].time
	        elseif not v.ct_id then
	        	vv.isCanUser = true
	        else
	        	vv.isCanUser = false
	        end
	        data[#data + 1] = vv
		end
	end
	MathExtend.SortListCom(data, callSort)
	return data
end

-- 获取个人中心快捷聊天数据
function PersonalInfoManager.GetSpeedyData(isAll)
	local data = {}
	for k,v in ipairs(this.Config.speedy) do
		if (isAll or (v.show_playerinfo and v.show_playerinfo == 1)) and (not v.sex or v.sex == MainModel.UserInfo.sex) then
			local vv = {}
	        for k1,v1 in pairs(v) do
	            vv[k1] = v1
	        end
	        if this.dress_data_map and this.dress_data_map[v.item_id] then
	        	vv.isCanUser = true
	        	vv.num = this.dress_data_map[v.item_id].num
	        	vv.time = this.dress_data_map[v.item_id].time
	        elseif not v.ct_id then
	        	vv.isCanUser = true
	        else
	        	vv.isCanUser = false
	        end
	        data[#data + 1] = vv
		end
	end
	MathExtend.SortListCom(data, callSort)
	return data
end

-- 获取个人中心互动表情数据
function PersonalInfoManager.GetAnimChatData(isAll)
	local data = {}
	for k,v in ipairs(this.Config.anim) do
		if isAll or (v.show_playerinfo and v.show_playerinfo == 1) then
			local vv = {}
	        for k1,v1 in pairs(v) do
	            vv[k1] = v1
	        end
    		local ct = ConditionManager.GetConditionToID(vv.ct_id)
	        if this.dress_data_map and this.dress_data_map[v.item_id] then
	        	vv.isCanUser = true
	        	vv.num = this.dress_data_map[v.item_id].num
	        	vv.time = this.dress_data_map[v.item_id].time
		    	if not vv.num and ct.ct_type == "shop" then
		    		vv.num = 0
		    	end
	        elseif not ct then
	        	vv.isCanUser = true
	        else
	        	if ct.ct_type == "shop" then
	        		vv.num = 0
		        	vv.isCanUser = true
	        	else
		        	vv.isCanUser = false
	        	end
	        end
	        data[#data + 1] = vv
		end
	end
	MathExtend.SortListCom(data, callSort)
	return data
end

-- 设置头像框 id为空使用自己的头像框id
function PersonalInfoManager.SetHeadFarme(image, id)
	id = 58
	if not id then
		id = PersonalInfoManager.GetSelfHeadID()
	end
	local v = this.Config.dressMap[id]
	if v.type ~= 3 then
		id = 58
		v = this.Config.dressMap[id]
	end
	image.transform.localRotation = Quaternion:SetEuler(0, 0, 0)
	if GameGlobalOnOff.Vip then
		image.sprite = GetTexture(v.icon)
	else
		image.sprite = GetTexture("hall_bg_head")
	end
end

-- 根据ID获取装扮数据
function PersonalInfoManager.GetDressDataToID(id)
	local v = this.Config.dressMap[id]
	local vv = {}
	local ct = ConditionManager.GetConditionToID(v.ct_id)
    if this.dress_data_map and this.dress_data_map[id] then
    	vv.isCanUser = true
    	vv.num = this.dress_data_map[id].num
    	if not vv.num and ct.ct_type == "shop" then
    		vv.num = 0
    	end
    	vv.time = this.dress_data_map[id].time
    elseif not ct then
    	vv.isCanUser = true
    else
    	if ct.ct_type == "shop" then
    		vv.num = 0
        	vv.isCanUser = true
    	else
        	vv.isCanUser = false
    	end
    end
    local cfg = this.Config.dressMap[id]
    if cfg then
	    for k,v in pairs(cfg) do
	        vv[k] = v
	    end
    end
    return vv
end

function PersonalInfoManager.GetConfigMap(id)
	dump(this.Config.dressMap, "<color=green>GetConfigMap</color>")
	return this.Config.dressMap[id]
end

function PersonalInfoManager.on_recv_voice_chat(_, data)
	-- 使用成功后服务器会推送最新数据过来
	-- dump(data, "使用成功")
	-- if data.player_id == MainModel.UserInfo.user_id then
	-- 	local id = tonumber(data.parm)
	-- 	if this.Config.dressMap[id] then
	-- 		local cfg = this.Config.dressMap[id]
	-- 		if cfg.type == 1 or cfg.type == 2 then
	-- 			PersonalInfoManager.UseBQFinish(id)
	-- 		end
	-- 	end
	-- end
end

function PersonalInfoManager.UseBQFinish(id)
	if this.dress_data_map[id] then
		local v = this.dress_data_map[id]
		if v.num and v.num > 0 then
			v.num = v.num - 1
			PersonalInfoManager.UpdateDressData()
		end
	end
end
