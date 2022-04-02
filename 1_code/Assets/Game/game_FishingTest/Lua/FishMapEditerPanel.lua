-- 创建时间:2019-03-06
-- Panel:FishingMouseDrawLinePanel
local basefunc = require "Game/Common/basefunc" 

FishingMouseDrawLinePanel = basefunc.class()
local M = FishingMouseDrawLinePanel
M.name = "FishingMouseDrawLinePanel"
local MModel = FishingTestModel

local f_tge = false
local m_tge = false
local l_tge = false
local p_tge = false

--LineRenderer
local lr
--定义一个Vector3,用来存储鼠标点击的位置
local pos_cur
--最后一次记录的点
local pos_last

--"设置多远距离记录一个位置"，用于画线
local dis_draw = 1

--设置记录需要存储的点的距离，用于存储鱼的路径
local dis_save = 5

local map_obj = {}
local line_data_list = {}
local line_data_cur = {}
local line_obj = {}
local point_data_list = {}
local point_data = {}
local point_obj = {}

local lr_go_list = {}

local update
local update_dt = 0.02

local line_draw_type = 1
local line_type_enum = {
	[1] = "自动",
	[2] = "手动",
}

local point_type = 1
local point_type_enum = {
    [1] = "直线",
    [2] = "圆形",
    [3] = "等待",
}

--base_data
--出生位置
local m_vPos = {}

--moving_data
-- 实体的质量
local m_dMass = 1
-- 实体的最大速度
local m_dMaxSpeed = 100
-- 实体产生的供以自己动力的最大力（想一下火箭和发动机推力）
local m_dMaxForce = 100
-- 交通工具能旋转的最大速率（弧度每秒）
local m_dMaxTurnRate = 40

--FollowPath
-- 停止巡逻距离
local patrolArrivalDistance = 150
-- 巡逻方式1一次 2循环 3往返
local patroMode = 1

local instance
function M.Create()
    if not instance then
        instance = M.New()
    end
    return instance
end
function M.Close()
    if instance then
        instance:MyExit()
    end
    instance = nil
end

function M:MyExit()
    if update then
        update:Stop()
        update = nil
    end
    destroy(self.gameObject)
end

function M:ctor()

	ExtPanel.ExtMsg(self)

    local parent = GameObject.Find("Canvas/GUIRoot").transform
    self.parent = parent
    local obj = newObject(M.name, parent)
    local tran = obj.transform
    self.transform = tran
    self.gameObject = obj
    LuaHelper.GeneratingVar(self.transform, self)
    self.camera = GameObject.Find("Canvas/Camera"):GetComponent("Camera")
    self:InitUI()
end

function M:InitUI()
    update =
        Timer.New(
        function()
            self:Update()
        end,
        update_dt,
        -1
    )
    update:Start()

    self.fish_tge.onValueChanged:AddListener(
        function(val)
            f_tge = val
            self.fish.gameObject:SetActive(val)
        end
    )
	self.fish_tge.isOn = f_tge
	
	--鱼图
	self.map_tge.onValueChanged:AddListener(
        function(val)
            m_tge = val
			if m_tge then
				self:ShowOrHideMap(true,MModel.GetMapData(1))
			else
				self:ShowOrHideMap(false)
			end
        end
    )
	self.map_tge.isOn = m_tge
	self.map_all_dpd = self.map_all_dpd:GetComponent("Dropdown")
	self.map_all_dpd.onValueChanged:AddListener(
        function(val)
            dump(val, "<color=white>val>>>>>>>>></color>")
            self:UpdateMap(val + 1,MModel.GetAllMapData())
        end
    )

	--鱼线
	self.line_tge.onValueChanged:AddListener(
        function(val)
            l_tge = val
			if l_tge then
				self:ShowOrHideLine(true,MModel.GetAllLineData(self.map_all_dpd.value + 1))
			else
				self:ShowOrHideLine(false)
				self.point_tge.gameObject:SetActive(false)
				self:ShowOrHidePoint(false)
			end
        end
    )
	self.line_tge.isOn = l_tge
	self.line_all_dpd = self.line_all_dpd:GetComponent("Dropdown")
	self.line_all_dpd.onValueChanged:AddListener(
        function(val)
            dump(val, "<color=white>val>>>>>>>>></color>")
            self:UpdateLine(val + 1,MModel.GetAllLineData(self.map_all_dpd.value + 1))
        end
	)
	
	--鱼点
	self.point_tge.onValueChanged:AddListener(
        function(val)
            p_tge = val
			if p_tge then
				self:ShowOrHidePoint(true,point_data_list)
			else
				self:ShowOrHidePoint(false)
			end
        end
    )
	self.point_tge.isOn = p_tge
	self.point_all_dpd = self.point_all_dpd:GetComponent("Dropdown")
	self.point_all_dpd.onValueChanged:AddListener(
        function(val)
            dump(val, "<color=white>val>>>>>>>>></color>")
            self:UpdatePoint(val + 1,point_data_list)
        end
    )

	self.line_draw_type_dpd = self.line_draw_type_dpd:GetComponent("Dropdown")
    self:UpdateDropDown(self.line_draw_type_dpd, line_type_enum)
    self:UpdateLineType(line_draw_type)
    self.line_draw_type_dpd.onValueChanged:AddListener(
        function(val)
            dump(val, "<color=white>val>>>>>>>>></color>")
            self:UpdateLineType(val + 1)
        end
    )
	
	self.point_type_dpd = self.point_type_dpd:GetComponent("Dropdown")
    self:UpdateDropDown(self.point_type_dpd, point_type_enum)
    self:UpdatePointType(point_type)
    self.point_type_dpd.onValueChanged:AddListener(
        function(val)
            dump(val, "<color=white>val>>>>>>>>></color>")
            self:UpdatePointType(val + 1)
        end
    )

    self.map_add_btn.onClick:AddListener(
		function()
			self:AddFishMapData()
        end
    )
    self.map_remove_btn.onClick:AddListener(
        function()
            self:RemoveFishMapData()
        end
	)
	
	self.line_add_btn.onClick:AddListener(
		function()
			self:AddFishLineData()
        end
    )
    self.line_remove_btn.onClick:AddListener(
        function()
            self:RemoveFishLineData()
        end
	)

	self.point_add_btn.onClick:AddListener(
		function()
			self:AddFishPointData()
        end
    )
    self.point_remove_btn.onClick:AddListener(
        function()
            self:RemoveFishPointData()
        end
	)
end

function M:AddFishPointData()
	if not M.CheckTxtIsNull(self.point_add_txt) then
		LittleTips.Create("请输入鱼点id")
		return
	end
	local id = tonumber(self.point_add_txt.text)
	if not id then
		LittleTips.Create("请输入数字")
		return
	end
	if id <= 0 then
		LittleTips.Create("请输入大于0的数字")
		return
	end

	if point_type == 1 then
		point_data_list.WayPoints = point_data_list.WayPoints or {}
		if id > #point_data_list.WayPoints + 2 then
			LittleTips.Create(string.format( "输入的id不连续,应该输入 ",id,#point_data_list + 1))
			return
		end
		if point_data_list.WayPoints[id] then
			LittleTips.Create(string.format( "鱼点中已经有了该id,确认将更新"))
			return
		end
		if not M.CheckTxtIsNull(self.path_pos_txt) then
			LittleTips.Create("请输入鱼点位置")
			return
		else
			local pos = split(self.path_pos_txt.text,",")
			dump(pos, "<color=white>鱼点pos</color>")
			if not pos or #pos ~= 2 then
				LittleTips.Create("请输入出生位置正确格式 x,y")
				return
			end
		end
		point_data_list.WayPoints[id].x = pos[1]
		point_data_list.WayPoints[id].y = pos[2]
	elseif point_type == 2 then
		if id ~= 1 then
			LittleTips.Create(string.format( "id只能是 1"))
			return
		end
		if not M.CheckTxtIsNull(self.circle_angle_txt) then
			LittleTips.Create("请输入鱼点旋转角度")
			return
		else
			local angle = tonumber(self.circle_angle_txt.text)
			if not angle then
				LittleTips.Create("请输入旋转角度的正确格式整数")
				return
			end
		end
		if not M.CheckTxtIsNull(self.circle_radius_txt) then
			LittleTips.Create("请输入鱼点旋转半径")
			return
		else
			local radius = tonumber(self.circle_radius_txt.text)
			if not radius then
				LittleTips.Create("请输入旋转半径的正确格式整数")
				return
			end
		end
		if not M.CheckTxtIsNull(self.circle_perp_txt) then
			LittleTips.Create("请输入鱼点旋转方向")
			return
		else
			local perp = tonumber(self.circle_perp_txt.text)
			if not perp then
				LittleTips.Create("请输入旋转方向的正确格式整数")
				return
			end
			if perp ~= 0 or perp == 1 then
				LittleTips.Create("旋转方向只能是 0 或 1")
				return
			end
		end
		point_data_list.angle = angle
		point_data_list.radius = radius
		point_data_list.isPerp = perp
	elseif point_type == 3 then
		if id ~= 1 then
			LittleTips.Create(string.format( "id只能是 1"))
			return
		end
		if not M.CheckTxtIsNull(self.wait_time_txt) then
			LittleTips.Create("请输入鱼点等待时间")
			return
		else
			local wait_time = tonumber(self.wait_time_txt.text)
			if not wait_time then
				LittleTips.Create("请输入等待时间的正确格式整数")
				return
			end
		end
		point_data_list.waitTime = wait_time
	end
	point_data_list.type = point_type
end

function M:RemoveFishPointData()
	if not M.CheckTxtIsNull(self.point_remove_txt) then
		LittleTips.Create("请输入删除点的id")
		return
	end
	local id = tonumber(self.point_remove_txt.text)
	if not id then
		LittleTips.Create("请输入数字")
		return
	end
	
	if point_type == 1 then
		if not point_data_list.WayPoints[id] then
			LittleTips.Create("请输入正确的id")
			return
		end
		table.remove(point_data_list.WayPoints,id)
	elseif point_type == 2 then
		point_data_list = nil
	elseif point_type == 3 then
		point_data_list = nil
	end
	--从鱼图和鱼线中删除 待完成
	
	LittleTips.Create(string.format( "id为%s的鱼线已删除",id))
end

function M:AddFishLineData()
	if not M.CheckTxtIsNull(self.line_add_txt) then
		LittleTips.Create("请输入鱼线id")
		return
	end
	local id = tonumber(self.line_add_txt.text)
	if not id then
		LittleTips.Create("请输入数字")
		return
	end
	if id <= 0 then
		LittleTips.Create("请输入大于0的数字")
		return
	end
	if id > #MModel.GetAllLineData(self.map_all_dpd.value + 1) + 2 then
		LittleTips.Create(string.format( "输入的id不连续,应该输入 ",id,#MModel.GetAllLineData(self.map_all_dpd.value + 1) + 1))
		return
	end
	if MModel.GetLineData(self.line_all_dpd.value + 1,self.map_all_dpd.value + 1) then
		LittleTips.Create(string.format( "鱼图中已经有了该id,确认将更新"))
		return
	end

	--保存鱼线 待完成
	local line_data_cur = {}
	local p_data = MModel.GetPointData(self.point_all_dpd.value + 1,self.line_all_dpd.value + 1,self.map_all_dpd.value + 1)
	
end

function M:RemoveFishLineData()
	if not M.CheckTxtIsNull(self.line_remove_txt) then
		LittleTips.Create("请输入删除线的id")
		return
	end
	local id = tonumber(self.line_remove_txt.text)
	if not id then
		LittleTips.Create("请输入数字")
		return
	end
	local l_data = MModel.GetLineData(self.line_all_dpd.value + 1,self.map_all_dpd.value + 1)
	if not l_data then
		LittleTips.Create("请输入正确的id")
		return
	end
	MModel.RemoveMapData(self.line_all_dpd.value + 1,self.map_all_dpd.value + 1)
	LittleTips.Create(string.format( "id为%s的鱼线已删除",id))
end

function M:AddFishMapData(  )
	if not M.CheckTxtIsNull(self.map_pos_txt) then
		LittleTips.Create("请输入出生位置")
		return
	else
		local pos = split(self.map_pos_txt.text,",")
		dump(pos, "<color=white>鱼图pos</color>")
		if not pos or #pos ~= 2 then
			LittleTips.Create("请输入出生位置正确格式 x,y")
			return
		end
	end
	if not M.CheckTxtIsNull(self.map_head_txt) then
		LittleTips.Create("请输入出生朝向")
		return
	else
		local head = split(self.map_pos_txt.text,",")
		dump(head, "<color=white>鱼图head</color>")
		if not head or #head ~= 2 then
			LittleTips.Create("请输入出生朝向正确格式 x,y")
			return
		end
	end
	if not M.CheckTxtIsNull(self.map_add_txt) then
		LittleTips.Create("请输入鱼图id")
		return
	end
	local id = tonumber(self.map_add_txt.text)
	if not id then
		LittleTips.Create("请输入数字")
		return
	end
	if id <= 0 then
		LittleTips.Create("请输入大于0的数字")
		return
	end
	if id > #MModel.GetAllMapData() + 2 then
		LittleTips.Create(string.format( "输入的id不连续,应该输入 ",id,#MModel.GetAllMapData() + 1))
		return
	end
	if MModel.GetMapData(id) then
		LittleTips.Create(string.format( "鱼图中已经有了该id,确认将更新"))
		return
	end

	local l_data = MModel.GetLineData(self.line_all_dpd.value + 1,self.map_all_dpd.value + 1)
	if not next(l_data) then
		LittleTips.Create(string.format( "请线编辑鱼线"))
		return
	end

	local map_data_cur = {}
	--保存鱼图 待完成
	map_data_cur.id = id
	map_data_cur.headX = head[1]
	map_data_cur.headY = head[2]
	map_data_cur.posX = pos[1]
	map_data_cur.posY = pos[2]
	map_data_cur.steer = l_data
	M.SaveMapData(id,map_data_cur)
end

function M:RemoveFishMapData()
	if not M.CheckTxtIsNull(self.map_remove_txt) then
		LittleTips.Create("请输入删除鱼图的id")
		return
	end
	local id = tonumber(self.map_remove_txt.text)
	if not id then
		LittleTips.Create("请输入数字")
		return
	end
	if not MModel.GetMapData(id) then
		LittleTips.Create("请输入正确的id")
		return
	end
	MModel.RemoveMapData(id)
	LittleTips.Create(string.format( "id为%s的鱼图已删除",id))
end

-------map
function M:InitMap()
	self.map_pos_ipf.text = ""
	self.map_head_ipf.text = ""
	self.map_remove_ipf.text = ""
	self:UpdateDropDown(self.map_all_dpd,nil)
	--关闭鱼线和鱼点
	self.line_tge.gameObject:SetActive(false)
	self:ShowOrHideLine(false)
	self.point_tge.gameObject:SetActive(false)
	self:ShowOrHidePoint(false)
end

function M:UpdateMap(i,data)
	if not data or not next(data) or not i then
		self:InitMap()
	else
		if not data[i] then
			self:InitMap()
		else
			local v = data[i]
			self.map_pos_ipf.text = string.format( "%s,%s",v.posX,v.posY)
			self.map_head_ipf.text =  string.format( "%s,%s",v.headX,v.headY)
			self.map_remove_ipf.text = ""
			self.map_all_dpd.value = i - 1
		end
	end
end

function M:ShowOrHideMap(is_view,data)
	if is_view and data and next(data) then
		self:UpdateDropDown(self.map_all_dpd,data)
		self:UpdateMap(#data,data)
	else
		self:InitMap()
	end
	self.map.gameObject:SetActive(is_view)
end

---------line
function M:InitLine()
	self.line_remove_ipf.text = ""
	self:UpdateDropDown(self.line_all_dpd,nil)
	--关闭鱼点
	self.point_tge.gameObject:SetActive(false)
	self:ShowOrHidePoint(false)
end

function M:UpdateLine(i,data)
	if not data or not next(data) or not i then
		self:InitLine()
		--关闭鱼点
	else
		if not data[i] then
			self:InitLine()
		else
			self.line_remove_ipf.text = ""
			self.line_all_dpd.value = i - 1
		end
	end
end

function M:ShowOrHideLine(is_view,data)
	if is_view and data and next(data) then
		self:UpdateDropDown(self.line_all_dpd,data)
		self:UpdateLine(#data,data)
	else
		self:InitLine()
	end
	self:UpdateLineType(1)
	self.line.gameObject:SetActive(is_view)
end

function M:UpdateLineType(v)
	line_draw_type = v
	self.line_draw_type_dpd.value = line_draw_type - 1
    self.auto.gameObject:SetActive(v == 1)
	self.auto_save_dis_ipf.text = ""
    if line_draw_type == 1 then
        --自动取点不能手动取
		self.point_tge.gameObject:SetActive(false)
		self.point_type_dpd.gameObject:SetActive(false)
        p_tge = false
        self.point_tge.isOn = p_tge
    else
		self.point_tge.gameObject:SetActive(true)
		self.point_type_dpd.gameObject:SetActive(true)
        p_tge = false
        self.point_tge.isOn = p_tge
    end
end

----point
function M:InitPoint()
	self.point_remove_ipf.text = ""
	self:UpdateDropDown(self.point_all_dpd,nil)
end

function M:UpdatePoint(i,data)
	if not data or not next(data) or not i then
		self:InitPoint()
	else
		if not data[i] then
			self:InitPoint()
		else
			self.point_remove_ipf.text = ""
			self.point_all_dpd.value = i - 1
			local _type = tonumber(data.type)
			if _type then
				self:UpdateCurPointData(data,i)
				self:UpdatePointType(_type)
			end
		end
	end
end

function M:ShowOrHidePoint(is_view,data)
	if is_view and data and next(data) then
		if data.type == 1 then
			self:UpdateDropDown(self.point_all_dpd,data.WayPoints)
		elseif data.type == 2 then
			self:UpdateDropDown(self.point_all_dpd,data)
		elseif data.type == 3 then
			self:UpdateDropDown(self.point_all_dpd,data)
		end
		self:UpdatePoint(#data,data)
	else
		self:InitPoint()
	end
	self:UpdatePointType(1)
	self.point.gameObject:SetActive(is_view)
end

function M:UpdatePointType(i)
	point_type = i
	self.path.gameObject:SetActive(i == 1)
    self.circle.gameObject:SetActive(i == 2)
	self.wait.gameObject:SetActive(i == 3)
	self.point_type_dpd.value = point_type - 1
end

function M:UpdateCurPointData(data,i)
	local function init_ui( )
		self.path_pos_ipf.text = ""
		self.circle_angle_ipf.text = ""
		self.circle_radius_ipf.text = ""
		self.circle_perp_ipf.text = ""
		self.wait_time_ipf.text = ""
	end
	if data.type == 1 then
		local pos = data.WayPoints[i]
		self.path_pos_ipf.text = string.format( "%s,%s",pos.x,pos.y)
	elseif data.type == 2 then
		self.circle_angle_ipf.text = string.format( "%s",data.angle )
		self.circle_radius_ipf.text = string.format( "%s",data.radius )
		self.circle_perp_ipf.text = string.format( "%s",data.isPerp )
	elseif data.type == 3 then
		self.wait_time_ipf.text = string.format( "%0.2f",data.waitTime)
	end
end

function M.CheckTxtIsNull(txt)
    local input_str = txt.text
    if not input_str or input_str == "" then
        return false
    end
    return true
end

function M:Update()
    self:DrawLine()
end

function M:GetCurPos(pos_last, dis_draw)
    --将鼠标点击的屏幕坐标转换为世界坐标，然后存储到position中
    local pos_cur =
        self.camera.main:ScreenToWorldPoint(
        Vector3.New(UnityEngine.Input.mousePosition.x, UnityEngine.Input.mousePosition.y, 1)
    )
    if not pos_last then
        return pos_cur
    end
    if Vector3.Distance(pos_cur, pos_last) > dis_draw then
        return pos_cur
    else
        return nil
    end
end

function M:AddLineRenderer()
    --添加LineRenderer组件
    local go = GameObject.Instantiate(self.go_line_renderer, self.transform)
    go.transform.parent = self.line_node.transform
    line_data_list = line_data_list or {}
    go.name = tostring(#line_data_list)
    go.gameObject:SetActive(true)
    --获取LineRenderer组件
    local lr = go.transform:GetComponent("LineRenderer")
    if lr then
        lr.positionCount = 0
    end
    return lr
end

function M:GetLineRender(lr)
    if not lr then
        lr = self:AddLineRenderer()
    end
    return lr
end

function M:AddDataToTable(t, d)
    t = t or {}
    if t[#t] ~= d then
        table.insert(t, d)
    end
    return t
end

function M:RemoveDataInTable(t, i)
    table.remove(t, i)
end

function M:SaveAutoPointToLine(line_data_cur, point_data, pos_cur, pos_last, dis_save)
    if l_tge == false then
        return
    end
    if not pos_cur or (pos_cur and Vector3.Distance(pos_cur, pos_last) > dis_save) then
        local p_data = self:AddDataToTable(point_data, pos_last)
        local l_data = self:AddDataToTable(line_data_cur, point_data)
    end
end

function M:DrawLine()
    if l_tge == false then
        return
    end
    --抬起鼠标
    if UnityEngine.Input.GetMouseButtonUp(0) or UnityEngine.Input.GetMouseButtonDown(0) then
        pos_cur = nil
        pos_last = nil
        lr = nil
        point_data = {}
        if UnityEngine.Input.GetMouseButtonUp(0) then
            dump(line_data_cur, "<color=white>line_data_cur</color>", 10000)
            dump(point_data, "<color=white>point_data</color>")
            dump(line_obj, "<color=white>line_obj</color>", 1000)
        end
    end

    if UnityEngine.Input.GetMouseButton(0) then
        pos_last = self:GetCurPos(pos_cur, dis_draw)
        --最后一次取到了
        if pos_last then
            --自动保存数据
            if line_draw_type == true then
                self:SaveAutoPointToLine(line_data_cur, point_data, pos_cur, pos_last, dis_save)
            end
            lr = self:GetLineRender(lr)
            lr.positionCount = lr.positionCount + 1
            lr:SetPosition(lr.positionCount - 1, pos_last)
            self:AddDataToTable(line_obj, lr)
            pos_cur = pos_last
        end
    end
end

function M:UpdateDropDown(dpd, list)
	dpd:ClearOptions()
	if not list or not next(list) then return end
    for k, v in ipairs(list) do
        local d = OptionData.New()
        d.text = k
        dpd:AddOptionData(d)
    end
    dpd.transform:Find("Label"):GetComponent("Text").text = list[1]
end

function M:CheckIsPointDownOnUI()
    local isPointDownOnUI = false
    if gameRuntimePlatform == "WindowsEditor" or gameRuntimePlatform == "" then
        if EventSystem.current:IsPointerOverGameObject() and UnityEngine.Input.GetMouseButtonDown(0) then
            isPointDownOnUI = true
        end

        if isPointDownOnUI and UnityEngine.Input.GetMouseButtonUp(0) then
            isPointDownOnUI = false
        end
    else
        if
            UnityEngine.Input.touchCount > 0 and
                EventSystem.current:IsPointerOverGameObject(UnityEngine.Input.GetTouch(0).fingerId) and
                UnityEngine.Input.GetTouch(0).phase == UnityEngine.TouchPhase.Began
         then
            isPointDownOnUI = true
        end

        if isPointDownOnUI and UnityEngine.Input.GetTouch(0).phase == UnityEngine.TouchPhase.Ended then
            isPointDownOnUI = false
        end
    end
    return isPointDownOnUI
end
