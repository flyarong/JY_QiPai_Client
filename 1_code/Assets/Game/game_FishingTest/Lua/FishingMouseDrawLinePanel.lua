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
local dis_draw = 10

--设置记录需要存储的点的距离，用于存储鱼的路径
local dis_save = 10

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

local line_draw_type = true
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
    -- if l_tge == false then
    --     return
    -- end
    if not pos_cur or (pos_cur and Vector3.Distance(pos_cur, pos_last) > dis_save) then
        local p_data = self:AddDataToTable(point_data, pos_last)
        local l_data = self:AddDataToTable(line_data_cur, point_data)
    end
end

function M:DrawLine()
    -- if l_tge == false then
    --     return
    -- end
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
