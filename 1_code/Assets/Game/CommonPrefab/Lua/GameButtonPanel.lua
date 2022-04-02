-- 创建时间:2019-09-20
-- Panel:GameButtonPanel
--[[
 *      ┌─┐       ┌─┐
 *   ┌──┘ ┴───────┘ ┴──┐
 *   │                 │
 *   │       ───       │
 *   │  ─┬┘       └┬─  │
 *   │                 │
 *   │       ─┴─       │
 *   │                 │
 *   └───┐         ┌───┘
 *       │         │
 *       │         │
 *       │         │
 *       │         └──────────────┐
 *       │                        │
 *       │                        ├─┐
 *       │                        ┌─┘
 *       │                        │
 *       └─┐  ┐  ┌───────┬──┐  ┌──┘
 *         │ ─┤ ─┤       │ ─┤ ─┤
 *         └──┴──┘       └──┴──┘
 *                神兽保佑
 *               代码无BUG!
 --]]

local basefunc = require "Game/Common/basefunc"

GameButtonPanel = basefunc.class()
local C = GameButtonPanel
C.name = "GameButtonPanel"

function C.Create(node_map, type, com_parent)
	return C.New(node_map, type, com_parent)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}

    self.lister["EnterForeGround"] = basefunc.handler(self, self.onEnterForeGround)
    self.lister["EnterBackGround"] = basefunc.handler(self, self.onEnterBackGround)

    self.lister["ui_button_state_change_msg"] = basefunc.handler(self, self.CreateEnterBtn)
    self.lister["ui_button_data_change_msg"] = basefunc.handler(self, self.on_ui_button_data_change_msg)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	if not self.type then
		return
	end
	self:ClearCell()
	if self.update_time then
		self.update_time:Stop()
	end
	self.update_time = nil

	self:RemoveListener()
	for k,v in pairs(self) do
		if k ~= "MyExit" then
			self[k] = nil
		end
	end
end

function C:ctor(node_map, type, com_parent)
	self.node_map = node_map
	self.type = type
	self.com_parent = com_parent

	self.config = GameButtonManager.GetGameEnterMap(type)

	self:MakeLister()
	self:AddMsgListener()

	-- 每20秒统一刷新一次
	self.update_time = Timer.New(function ()
		self:Update()
	end, 20, -1, nil, true)
	self.update_time:Start()

	self:InitUI()
end

function C:InitUI()
	self:MyRefresh()
end

function C:MyRefresh()
	self:ClearCell()
	self.cur_btn_map = self:GetBtnMap()
	for k, v in pairs(self.cur_btn_map) do
		local cur_i = 1
		for _, v1 in pairs(v) do
			local cc = GameButtonManager.GetEnterConfig( v1 )
			local module_cc = GameButtonManager.GetModuleByKey(cc.parm[1])
			if module_cc then
				local parm = {cfg=cc, ui_type=self.type, condi_key = cc.condi_key}
				SetTempParm(parm, cc.parm, "enter")
				local pre
				if self.node_map[k] and IsEquals(self.node_map[k][cur_i]) then
					parm.parent = self.node_map[k][cur_i]
					pre = _G[module_cc.lua].GotoUI(parm)
					self.node_map[k][cur_i].gameObject:SetActive(true)
				else
					if k == "wuquyu" and IsEquals(self.com_parent) then
						parm.parent = self.com_parent
						pre = _G[module_cc.lua].GotoUI(parm)
					end
				end
				if pre then
					self.cell_map[k] = self.cell_map[k] or {}
					if self.node_map[k] then
						self.cell_map[k][#self.cell_map[k] + 1] = {prefab = pre, cfg = cc}
					else
						self.cell_map[k][v1] = {prefab = pre, cfg = cc}
					end
					cur_i = cur_i + 1
				else
					dump(cc.parm, "<color=red>[Debug] cc.parm</color>")
					if AppDefine.IsEDITOR() then
						print("<color=red>没有 创建成功，可能是条件不一致</color>")
					end
				end
			end
		end
	end
end

function C:Update()
	self:CreateEnterBtn()
end

function C:ClearCell()
	if self.cell_map then
		for k, v in pairs(self.cell_map) do
			for _, v1 in pairs(v) do
				if v1.prefab then
					if v1.prefab.OnDestroy then
						v1.prefab:OnDestroy()
					else
						dump(v1, "<color=red>EEE EnterPrefab </color>")
					end
				else
					dump(v1, "<color=red><size=20>EEE EnterPrefab </size></color>")
				end
			end
		end
	end
	if self.node_map then
		for k, v in pairs(self.node_map) do
			for _, v1 in ipairs(v) do
				if v1 and IsEquals(v1.gameObject) then
					v1.gameObject:SetActive(false)
				end
			end
		end
	end
	self.cell_map = {}
	self.cur_btn_map = {}
end

local function tableMore(a,b)
    local bm = {}
    local ret = {}
    for k,v in ipairs(b) do
        bm[v] = 1
    end
    for k,v in ipairs(a) do
        if not bm[v] then
            ret[#ret+1]=v
        end
    end
    return ret
end
function C:CreateEnterBtn()
	local btn_map = self:GetBtnMap()
	local hb_btn_map = {}
	for k, v in pairs(self.cur_btn_map) do
		hb_btn_map[k] = hb_btn_map[k] or {id1={}, id2={}}
		for _, v1 in pairs(v) do
			hb_btn_map[k].id1[#hb_btn_map[k].id1 + 1] = v1
		end
	end
	for k, v in pairs(btn_map) do
		hb_btn_map[k] = hb_btn_map[k] or {id1={}, id2={}}
		for _, v1 in pairs(v) do
			hb_btn_map[k].id2[#hb_btn_map[k].id2 + 1] = v1
		end
	end
	dump(hb_btn_map, "<color=red><size=20>hb_btn_map</size></color>")

	for k,v in pairs(hb_btn_map) do
		if self.node_map[k] then
			local len = #v.id1
			if len < #v.id2 then
				len = #v.id2
			end
			for i=len, 1, -1 do
				local k1 = i
				local id1 = v.id1[k1]
				local id2 = v.id2[k1]
				if id1 and (id1 ~= id2) then
					if self.cell_map[k] and self.cell_map[k][k1] and self.cell_map[k][k1].prefab then
						if self.cell_map[k][k1].prefab.OnDestroy then
							self.cell_map[k][k1].prefab:OnDestroy()
							table.remove( self.cell_map[k], k1)
							if self.node_map[k] and self.node_map[k][k1] and IsEquals(self.node_map[k][k1].gameObject) then
								self.node_map[k][k1].gameObject:SetActive(false)
							end
						else
							if AppDefine.IsEDITOR() then
								-- dump(self.cell_map[k][k1], "Error 11")
								HintPanel.Create(1, "没有 OnDestroy")
							end
						end
					else
						dump({map =self.cell_map,k1 = k1,k = k},"<color=red>ERROR!!! ---------------------------</color>")
						if AppDefine.IsEDITOR() then
							HintPanel.Create(1,"可能是M.GotoUI()返回空，但是M.CheckIsShow()的检测是通过的")
						end
					end
					
				end
			end
		else
			-- 无区域 待删除的
			local sc = tableMore(v.id1, v.id2)
			for k1,v1 in ipairs(sc) do
				if self.cell_map[k] and self.cell_map[k][v1] then
					dump(self.cell_map[k][v1], "<color=red><size=20>无区域 待删除的</size></color>")
					if self.cell_map[k][v1].prefab.OnDestroy then
						self.cell_map[k][v1].prefab:OnDestroy()
						self.cell_map[k][v1] = nil
					else
						if AppDefine.IsEDITOR() then
							dump(self.cell_map[k][v1], "Error 11")
							HintPanel.Create(1, "没有 OnDestroy")
						end
					end
				end
			end
		end
	end
	for k,v in pairs(hb_btn_map) do
		if self.node_map[k] then
			for k1, v1 in ipairs(v.id2) do
				if v1 and (not v.id1[k1] or v1 ~= v.id1[k1]) then
					local cc = GameButtonManager.GetEnterConfig( v1 )
					local module_cc = GameButtonManager.GetModuleByKey(cc.parm[1])
					if module_cc then
						local parm = {cfg=cc, ui_type=self.type, condi_key = cc.condi_key}
						SetTempParm(parm, cc.parm, "enter")
						parm.parent = self.node_map[k][k1]
						if IsEquals(self.node_map[k][k1]) then
							self.node_map[k][k1].gameObject:SetActive(true)
							local pre = _G[module_cc.lua].GotoUI(parm)
							if pre then
								self.cell_map[k] = self.cell_map[k] or {}
								self.cell_map[k][k1] = {prefab = pre, cfg = cc}
							end
						end
					end
				end
			end
		else
			if k == "wuquyu" and IsEquals(self.com_parent) then
				-- 无区域 待增加的
				local sc = tableMore(v.id2, v.id1)
				dump(sc, "<color=red><size=20>无区域 待增加的</size></color>")
				for k1,v1 in ipairs(sc) do
					local cc = GameButtonManager.GetEnterConfig( v1 )
					local module_cc = GameButtonManager.GetModuleByKey(cc.parm[1])
					if module_cc then
						local parm = {cfg=cc, ui_type=self.type, condi_key = cc.condi_key}
						SetTempParm(parm, cc.parm, "enter")
						parm.parent = self.com_parent
						local pre = _G[module_cc.lua].GotoUI(parm)
						if pre then
							self.cell_map[k] = self.cell_map[k] or {}
							self.cell_map[k][v1] = {prefab = pre, cfg = cc}
						end
					end
				end
			end
		end
	end

	self.cur_btn_map = btn_map
end

function C:onEnterForeGround()
	self:CreateEnterBtn()
end
function C:onEnterBackGround()
end

-- 获取需要创建的按钮
function C:GetBtnMap()
	local btn_map = {}
	for k, v in pairs(self.config) do
		local max -- 区域最多创建的按钮个数
		if self.node_map[k] then
			max = #self.node_map[k]
		else
			max = 10 -- 无限制，10应该够用了
		end
		local cur_i = 1
		for _, v1 in ipairs(v) do
			for _, v2 in ipairs(v1) do
				local cc = GameButtonManager.GetEnterConfig( v2 )
				if cc then
					local module_cc = GameButtonManager.GetModuleByKey(cc.parm[1])
					if module_cc then
						if module_cc.lua and _G[module_cc.lua] then
							local cclua = _G[module_cc.lua]
							local parm = {condi_key = cc.condi_key}
							SetTempParm(parm, cc.parm, "enter")
							if not cclua.CheckIsShow or cclua.CheckIsShow(parm, self.type) then
								btn_map[k] = btn_map[k] or {}
								if self.node_map[k] then
									btn_map[k][#btn_map[k] + 1] = v2
								else
									btn_map[k][v2] = v2
								end
								cur_i = cur_i + 1
								break
							end
						end
					else
						print("<color=red>v2 = " .. v2 .. "</color>")
					end
				end
			end
			if cur_i > max then
				break
			end
		end
	end
	dump(btn_map, "<color=red>btn_map----------</color>")
	return btn_map
end

function C:on_ui_button_data_change_msg(data)
	if not self.cell_map then
		self:CreateEnterBtn()
		return
	end

	for k, v in pairs(self.cell_map) do
		for k1, v1 in pairs(v) do
			if v1.cfg.parm[1] == data.key then
				local module_cc = GameButtonManager.GetModuleByKey(data.key)
				if module_cc then
					if module_cc.lua and _G[module_cc.lua] then
						local cclua = _G[module_cc.lua]
						local parm = {condi_key = v1.condi_key}
						SetTempParm(parm, v1.cfg.parm, "enter")
						local is_show = false
						if not cclua.CheckIsShow or cclua.CheckIsShow(parm, self.type) then
							is_show = true
						end
						if is_show and v1.prefab.MyRefresh then
							v1.prefab:MyRefresh()
						elseif not is_show and v1.prefab.OnDestroy then
							if self.node_map[k] then
								self.cell_map[k][k1].prefab:OnDestroy()
								table.remove( self.cell_map[k], k1)
								self.node_map[k][k1].gameObject:SetActive(false)
								table.remove( self.cur_btn_map[k], k1)
							else
								self.cell_map[k][v1].prefab:OnDestroy()
								self.cell_map[k][v1] = nil
								self.cur_btn_map[k][v1] = nil
							end
						else
							dump(v1,"<color=red>按钮没有实现MyRefresh或OnDestroy----------</color>")
							print(debug.traceback())
						end 
					end
				end
				return
			end
		end
	end
	self:CreateEnterBtn()
end