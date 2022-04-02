-- 创建时间:2020-07-21
-- Panel:CommonCellAnim
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
 -- 取消按钮音效
 -- ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
 -- 确认按钮音效
 -- ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
 --]]

local basefunc = require "Game/Common/basefunc"

CommonCellAnim = basefunc.class()
local C = CommonCellAnim
C.name = "CommonCellAnim"

function C.Create()
	return C.New()
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()

end

function C:ctor()
	
end

function C:InitUI()
	self:MyRefresh()
end

function C:MyRefresh()

end

function C:SetShake(obj)
	if not obj or not IsEquals(obj) then return end
	local seq = DoTweenSequence.Create({dotweenLayerKey = "hall_cell"})
	seq:Append(obj.transform:DOShakePosition (1,Vector3.New(4,4,0)))
	seq:AppendInterval(3)
	seq:Append(obj.transform:DOShakePosition (1,Vector3.New(4,4,0)))
end

function C:SetLoopAnim(obj,showtime,Direction,call)
	if not obj or not IsEquals(obj) then return end
	local seq = DoTweenSequence.Create({dotweenLayerKey = "hall_cell"})
	seq:Append(obj.transform:DOLocalMoveX(0,0.6))
	seq:AppendInterval(showtime)
	seq:Append(obj.transform:DOLocalMoveX(-300 * Direction,0.6))
	seq:AppendCallback(
		function ()
			if call then
				call()
			end
		end
	)
	seq:OnKill(function ()
    end)
end

function C:SetLoop(waitTime,ShowTime,call)
	local seq = DoTweenSequence.Create({dotweenLayerKey = "hall_cell"})
	seq:AppendInterval(waitTime + 1.2 + (ShowTime or 0))
	seq:AppendCallback(
		function ()
			if call then
				call()
			end
		end
	)
	seq:SetLoops(-1,DG.Tweening.LoopType.Restart)
	seq:OnKill(function ()
    end)
end


--再次封装  "需要抽屉动作的物体","需要抖动的物体","抽屉展出的时间"，"完成一次循环后的等待时间"
function C:Go(Cellobj,Shakeobj,ShowTime,WaitTime,Direction)
	Direction = Direction or 1
	local shake_func = function ()
		self:SetShake(Shakeobj)
	end
	local set_loop_anim_func = function ()
		self:SetLoopAnim(Cellobj,ShowTime,Direction,shake_func)
	end
	local set_loop_func = function ()
		self:SetLoop(WaitTime,ShowTime,set_loop_anim_func)
	end
	set_loop_func()
end