-- 创建时间:2020-03-31

--指针进度条预制体
local basefunc = require "Game.Common.basefunc"

ZPGPointerPrefab = basefunc.class()

local C = ZPGPointerPrefab
C.name = "ZPGPointerPrefab"


function C.Create(parent)
    return C.New(parent)
end


function C:ctor(parent)
    self.left_dimension = -231
    self.right_dimension = 231
    self.left_highlight = -49
    self.right_highlight = 49
    self.max_offset = 120
    local obj = newObject(C.name,parent)
    self.gameObject = obj
    local tran = obj.transform
    self.transform = tran
    self.Pointer = tran:Find("Pointer")
    self.ProgressBG = tran:Find("ProgressBG")
    self.HighLightArea = tran:Find("ProgressBG/HighLightArea")

    self:InitUI()
end

function C:InitUI()
    local default_y = self.Pointer.transform.localPosition.y
    local tran = self.Pointer.transform
    local seq = DoTweenSequence.Create()
    local start_pos = self.Pointer.transform.localPosition
    local right_end_pos = Vector3.New(self.right_dimension,default_y,0)
    local left_end_pos = Vector3.New(self.left_dimension,default_y,0)
    local randomOffset = self.max_offset * math.random() * math.pow(-1,math.random(1,2))
    self.left_highlight = self.left_highlight + randomOffset
    self.right_highlight = self.right_highlight + randomOffset
    self.HighLightArea.transform.localPosition = Vector3.New(randomOffset,0,0)
    local randomSpeed = 1/math.random(1,4)
    local quarter_loop_time = randomSpeed
    seq:Append(tran:DOLocalMove(right_end_pos,quarter_loop_time):SetEase(DG.Tweening.Ease.Linear))
    seq:Append(tran:DOLocalMove(left_end_pos,quarter_loop_time * 2):SetEase(DG.Tweening.Ease.Linear))
    seq:Append(tran:DOLocalMove(start_pos,quarter_loop_time):SetEase(DG.Tweening.Ease.Linear))
    seq:SetLoops(-1,DG.Tweening.LoopType.Restart)
end

function C:CheckOnHighLight()
    local x = self.Pointer.transform.localPosition.x
    dump(x,"<color=red>x</color>")
    if x > self.left_highlight and x <self. right_highlight then
        dump(true,"<color=red>true</color>")
        return true
    else
        dump(false,"<color=red>false</color>")
        return false
    end
end

function C:MyExit()
    local check_on_highlight = self:CheckOnHighLight()
    GameObject.Destroy(self.gameObject)
    return check_on_highlight
end


