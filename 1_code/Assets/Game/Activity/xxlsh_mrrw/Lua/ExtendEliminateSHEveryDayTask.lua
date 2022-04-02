local basefunc = require "Game/Common/basefunc"
ExtendEliminateSHEveryDayTask = basefunc.class()
local M = ExtendEliminateSHEveryDayTask
M.name = "ExtendEliminateSHEveryDayTask"

local config
local TASK_TYPE = "sh_xxl_daily_children_task"
local instance
function M.Create(_parent, _cfg)
	if instance then
		M.Close()
	end
	instance = M.New(_parent, _cfg)
	return instance
end

function M.Close()
	if instance then
		instance:MyExit()
	end
end

function M:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function M:MakeLister()
	print("<color=red>makelister</color>")
    self.lister = {}
	self.lister["query_xxl_children_tasks_response"] = basefunc.handler(self, self.query_xxl_children_tasks)
    self.lister["xiaoxiaole_daily_children_tasks_change_msg"] = basefunc.handler(self, self.xiaoxiaole_daily_children_tasks_change_msg)
	self.lister["model_task_change_msg"] = basefunc.handler(self, self.on_task_change)
	
	
	self.lister["view_lottery_sucess"]= basefunc.handler(self,self.lottery_success)
	self.lister["view_lottery_error"]=basefunc.handler(self,self.lottery_error)
	self.lister["view_lottery_end"]= basefunc.handler(self,self.view_lottery_end)
	self.lister["view_lottery_award"]= basefunc.handler(self,self.view_lottery_award)
	-- self.lister["OnLoginResponse"] = basefunc.handler(self, self.OnLoginResponse)
	-- self.lister["DisconnectServerConnect"] = basefunc.handler(self, self.DisconnectServerConnect)
end

function M:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function M:OnDestroy(  )
	self:MyExit()
end

function M:MyExit()
	--根据场景不同功能不同
	self.cur_scene = MainLogic.GetCurSceneName()
	dump(self.cur_scene, "<color=white>self.cur_scene</color>")
	if self.cur_scene == "game_MiniGame" then
		destroy(self.ui.gameObject)
	elseif self.cur_scene == "game_EliminateSH" then
		self:ResetGame()
		self:RemoveListener()
		if self.update_time then
			self.update_time:Stop()
			self.update_time = nil
		end
		destroy(self.ui.gameObject)
		self.data = nil
		self.cfg = nil
		self.ui = nil
		self.game = nil
	end
	config = nil
	instance = nil
end

function M:ctor(_parent, _cfg)
	--根据场景不同功能不同
	self.cur_scene = MainLogic.GetCurSceneName()
	dump(self.cur_scene, "<color=white>self.cur_scene</color>")
	if self.cur_scene == "game_MiniGame" then
		local obj = newObject("XXLSHMRRWEnterPrefab2", _parent)
		self.ui = {}
		self.ui.transform = obj.transform
		self.ui.gameObject = obj
		LuaHelper.GeneratingVar(self.ui.transform,self.ui)
	elseif self.cur_scene == "game_EliminateSH" then
		self:Init(_parent, _cfg)
	end
end

function M:Init(_parent, _cfg)
	self:InitUI(_parent, _cfg)
	self:InitConfig()
	self:InitData()
end

function M:InitConfig()
	config = XXLSHMRRWManager.GetConfig()
	if not config then return end
	self.cfg = {}
	self.cfg.config = {}
	for i,v in ipairs(config.base) do
		self.cfg.config[v.task_id] = v
	end
end

function M:InitData()
	self:MakeLister()
	self:AddMsgListener()
	self.data = {}
	Network.SendRequest("query_xxl_children_tasks", {game_type = "sh_xxl"})
end

function M:InitUI(_parent, _cfg)
	local obj = newObject("XXLSHMRRWEnterPrefab1", _parent)
	self.ui = {}
	self.ui.transform = obj.transform
	self.ui.gameObject = obj
	LuaHelper.GeneratingVar(self.ui.transform,self.ui)
	self.ui.get_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self.data.cur_task = self:GetCurTaskData()
		if not self.data.cur_task then return end
        Network.SendRequest("get_task_award", {id = self.data.cur_task.id})
	end)
end

function M:MyRefresh()
	self.data.cur_task = self:GetCurTaskData()
	dump(self.data.cur_task, "<color=white>cur_task</color>")
	if not self.data.cur_task then 
		self.ui.run.gameObject:SetActive(false)
		self.ui.get.gameObject:SetActive(false)
		self:ResetGame()
		return
	end
	self.cfg.cur_cfg = self.cfg.config[self.data.cur_task.id]
	self:ChangeGame()
	if self.data.cur_task.award_status == 0 then
		self.ui.run.gameObject:SetActive(true)
		self.ui.get.gameObject:SetActive(false)
		self.ui.target_img.sprite = GetTexture(self.cfg.cur_cfg.icon)
		self.ui.target_txt.text = string.format( "%s/%s",self.data.cur_task.now_process,self.data.cur_task.need_process)
		local award = GameItemModel.GetItemToKey(self.cfg.cur_cfg.award_type)
		local award_count = self.cfg.cur_cfg.award_count 
		if self.cfg.cur_cfg.award_type == "cash" or self.cfg.cur_cfg.award_type == "shop_gold_sum" then
			award_count = award_count / 100
		end
		self.ui.award_txt.text = string.format( "%s",award_count)
		self.ui.award_img.sprite = GetTexture(award.image)
	elseif self.data.cur_task.award_status == 1 then
		self.ui.target_txt.text = string.format( "%s/%s",self.data.cur_task.now_process,self.data.cur_task.need_process)
		self.ui.run.gameObject:SetActive(false)
		self.ui.get.gameObject:SetActive(true)
	end
end

function M:query_xxl_children_tasks(_, data)
	dump(data, "<color=white>on_query_response</color>")
	if data.result == 0 then
		self:FilterTaskData(data.children_tasks)
		self:MyRefresh()
	end
end

function M:xiaoxiaole_daily_children_tasks_change_msg(_, data)
	dump(data, "<color=white>xiaoxiaole_daily_children_tasks_change_msg</color>")
	-- if data.game_type ~= TASK_TYPE then return end
	self:FilterTaskData(data.children_tasks)
	self:MyRefresh()
end

function M:on_task_change(data)
	if not data.task_type or data.task_type ~= TASK_TYPE then return end
	if not self.data.child_task_hash or not self.data.child_task_hash[data.id] then return end
	self:UpdateTaskData(data)
	-- self:MyRefresh()
end

function M:lottery_success(_,data)
	self.data.cur_lottery_task = self:GetCurTaskData()
end

function M:lottery_error(_,data)
	self.data.cur_lottery_task = self:GetCurTaskData()
end

function M:view_lottery_end(_,data)
	self:MyRefresh()
end

function M:view_lottery_award(_data)
	if not _data.cur_del_list then return end
	local xc_id = M.get_xc_id(_data.cur_del_list)
	-- self:MyRefresh()
	self.data.cur_task = self:GetCurTaskData()
	if not self.data.cur_task then
		return
	end

	if self.data.cur_lottery_task and self.data.cur_lottery_task.id ~= self.data.cur_task.id then return end

	self.cfg.cur_cfg = self.cfg.config[self.data.cur_task.id]
	if tonumber(xc_id) ~= tonumber(self.cfg.cur_cfg.xc_id) then
		return
	end
	local count = M.get_xc_count(_data.cur_del_list)
	local str = self.ui.target_txt.text
	local strs = split(str,"/")
	count = count + tonumber(strs[1])
	if tonumber(count) > tonumber(self.data.cur_task.now_process) then
		count = self.data.cur_task.now_process
	end
	self.ui.target_txt.text = string.format( "%s/%s",count,self.data.cur_task.need_process)
	if tonumber(count) >= tonumber(self.data.cur_task.need_process) then
		self.ui.run.gameObject:SetActive(false)
		self.ui.get.gameObject:SetActive(true)
	end
end

function M.get_xc_id(xc_map)
	if table_is_null(xc_map) then return 6 end
	for x,v1 in pairs(xc_map) do
		if x ~= "hero_del" and v1 and next(v1) then
			for y,v in pairs(v1) do
				return v
			end
		end
	end
end

function M.get_xc_count(xc_map)
	local count = 0
	if table_is_null(xc_map) then return count end
	for x,_v in pairs(xc_map) do
		if x ~= "hero_del" and _v and next(_v) then
			for x,v in pairs(_v) do
				count = count + 1
			end	
		end
	end
	return count
end

function M:OnLoginResponse()
	
end

function M:DisconnectServerConnect()
	
end

function M:FilterTaskData(data)
	if not data then return end
	self.data.child_task_list = self.data.child_task_list or {}
	self.data.child_task_hash = self.data.child_task_hash or {}
	for i,v in ipairs(data) do
		if v.task_type == TASK_TYPE then
			self.data.child_task_hash[v.id] = v
			table.insert( self.data.child_task_list,v)
		end
	end
end

function M:UpdateTaskData(data)
	if not data or data.task_type ~= TASK_TYPE then return end
	self.data.child_task_hash[data.id] = data
	local v
	for i=1,#self.data.child_task_list do
		v = self.data.child_task_list[i]
		if v.id == data.id then
			self.data.child_task_list[i] = data
		end
	end
end

function M:GetCurTaskData()
	if not self.data or not self.data.child_task_list or not next(self.data.child_task_list) then return end
	for i,v in ipairs(self.data.child_task_list) do
		if tonumber(v.over_time) > os.time() then
			if v.award_status == 0 or v.award_status == 1 then
				return v
			end
		end
	end
end

function M:ChangeGame()
	self.game = self.game or {}
	if not self.game.bgs then
		--第一次才改变具体看自己的需求
		local info_panel = GameObject.Find("EliminateSHInfoPanel")
		if IsEquals(info_panel) then
			local bgs = info_panel.transform:Find("bgs")
			if IsEquals(bgs) then
				local rt = bgs:GetComponent("RectTransform")
				self.game.bgs = {}
				self.game.bgs.pos = {}
				self.game.bgs.pos.x = rt.anchoredPosition.x
				self.game.bgs.pos.y = rt.anchoredPosition.y
				self.game.bgs.size = {}
				self.game.bgs.size.x = rt.sizeDelta.x
				self.game.bgs.size.y = rt.sizeDelta.y
				rt.anchoredPosition = Vector2.New(2,20)
				rt.sizeDelta = Vector2.New(296,550)
			end
		end		
	end
end

function M:ResetGame()
	if not self.game then return end
	if self.game.bgs then
		local info_panel = GameObject.Find("EliminateSHInfoPanel")
		if IsEquals(info_panel) then
			local bgs = info_panel.transform:Find("bgs")
			if IsEquals(bgs) then
				local rt = bgs:GetComponent("RectTransform")
				if IsEquals(rt) then
					rt.anchoredPosition = Vector2.New(self.game.bgs.pos.x,self.game.bgs.pos.y)
					rt.sizeDelta = Vector2.New(self.game.bgs.size.x,self.game.bgs.size.y)
				end
			end
		end						
	end
	self.game = nil
end