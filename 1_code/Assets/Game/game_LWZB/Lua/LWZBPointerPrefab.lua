-- 创建时间:2020-08-27
-- Panel:LWZBPointerPrefab
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

LWZBPointerPrefab = basefunc.class()
local C = LWZBPointerPrefab
C.name = "LWZBPointerPrefab"
local M = LWZBModel

function C.Create(parent)
	return C.New(parent)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["ExitScene"] = basefunc.handler(self,self.MyExit)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	self:RemoveListener()
	destroy(self.gameObject)

    local check_on_highlight = self:CheckOnHighLight()
    return check_on_highlight
end

function C:OnDestroy()
	self:MyExit()
end

function C:MyClose()
	self:MyExit()
end

function C:ctor(parent)
    if M.GetCurStatus() ~= M.Model_Status.bet then
        self:RemoveListener()
        destroy(self.gameObject)
        return
    end

    self.left_dimension = -160
    self.right_dimension = 160
    self.left_highlight = -49
    self.right_highlight = 49
    self.max_offset = 80
    local obj = newObject(C.name,parent)
    self.gameObject = obj
    local tran = obj.transform
    self.transform = tran
    self.Pointer = tran:Find("Pointer")
    self.ProgressBG = tran:Find("ProgressBG")
    self.HighLightArea = tran:Find("ProgressBG/HighLightArea")

    self:MakeLister()
    self:AddMsgListener()

    self:InitUI()
end

function C:InitUI()
    local default_y = self.Pointer.transform.localPosition.y
    local tran = self.Pointer.transform
    self.seq = DoTweenSequence.Create()
    local start_pos = self.Pointer.transform.localPosition
    local right_end_pos = Vector3.New(self.right_dimension,default_y,0)
    local left_end_pos = Vector3.New(self.left_dimension,default_y,0)
    local randomOffset = self.max_offset * math.random() * math.pow(-1,math.random(1,2))
    self.left_highlight = self.left_highlight + randomOffset
    self.right_highlight = self.right_highlight + randomOffset
    self.HighLightArea.transform.localPosition = Vector3.New(randomOffset,-4,0)
    local randomSpeed = 1/math.random(1,4)
    local quarter_loop_time = randomSpeed
    self.seq:Append(tran:DOLocalMove(right_end_pos,quarter_loop_time):SetEase(DG.Tweening.Ease.Linear))
    self.seq:Append(tran:DOLocalMove(left_end_pos,quarter_loop_time * 2):SetEase(DG.Tweening.Ease.Linear))
    self.seq:Append(tran:DOLocalMove(start_pos,quarter_loop_time):SetEase(DG.Tweening.Ease.Linear))
    self.seq:SetLoops(-1,DG.Tweening.LoopType.Restart)
end

function C:CheckOnHighLight()
    local x = self.Pointer.transform.localPosition.x
    if x > self.left_highlight and x < self.right_highlight then
        return true
    else
        return false
    end
end

--[[function C:on_lwzb_force_exit_pointer_msg()
    self:MyExit()
end--]]