-- 创建时间:2020-05-18
-- Panel:Act_014_XYCDIconInGame
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

Act_014_XYCDIconInGame = basefunc.class()
local C = Act_014_XYCDIconInGame
C.name = "Act_014_XYCDIconInGame"

function C.Create(score,parent)
	return C.New(score,parent)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["ExitScene"]=basefunc.handler(self,self.MyExit)   
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	self:StopSeq()
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:OnDestroy()
    self:StopSeq()
    self:RemoveListener()
    destroy(self.gameObject)
end

function C:StopSeq()
    if self.seq then
        self.seq:Kill()
        self.seq = nil
    end
    if self.seq0 then
        self.seq0:Kill()
        self.seq0 = nil
    end
    if self.seq1 then
        self.seq1:Kill()
        self.seq1 = nil
    end
    if self.seq11 then
        self.seq11:Kill()
        self.seq11 = nil
    end
    if self.seq2 then
        self.seq2:Kill()
        self.seq2 = nil
    end
    if self.seq22 then
        self.seq22:Kill()
        self.seq22 = nil
    end
end

function C:ctor(score,parent)
	local parent = parent or GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self.score = score
	self.parent_pos = parent.localPosition
	self.seq = DoTweenSequence.Create()
    self.seq:AppendInterval(3.5)
    self.seq:AppendCallback(function ()
    	--local x = math.random(-700, 700)
    	--local y = math.random(-400, 400) 
    	self.transform.position = Vector3.New(0,550,0)
        self.SunItemInGame_btn.gameObject:SetActive(true)
        self.sunBKicon_img.gameObject:SetActive(true)
    	self.seq0 = DoTweenSequence.Create()
        self.seq0:Append(self.transform:DOMove(Vector3.New(0,0,0), 2))
        self.seq0:Join(self.sunBKicon_img.transform:DOLocalRotate(Vector3.New(0,0,360),2,DG.Tweening.RotateMode.FastBeyond360):SetLoops(-1,DG.Tweening.LoopType.Restart):SetEase(DG.Tweening.Ease.Linear))
        self.seq0:AppendCallback(function ()
            self.is_btn = true
            self:SunMoveWait3(self.score)
        end)
    end)

	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	EventTriggerListener.Get(self.SunItemInGame_btn.gameObject).onClick = 	basefunc.handler(self,self.ClickSunItemPre)
	self:MyRefresh()
end

function C:MyRefresh()
end

function C:SunMoveNow(score)
    if self.is_btn then
	    self.seq1 = DoTweenSequence.Create()
	    self.seq1:Append(self.transform:DOLocalMove(self.parent_pos, 1))
        self.seq1:Join(self.sunBKicon_img.transform:DOLocalRotate(Vector3.New(0,0,360),2,DG.Tweening.RotateMode.FastBeyond360):SetLoops(-1,DG.Tweening.LoopType.Restart):SetEase(DG.Tweening.Ease.Linear))
        self.seq1:AppendCallback(function ()
    	   self.SunItemInGame_btn.gameObject:SetActive(false)
           self.sunBKicon_img.gameObject:SetActive(false)
    	   self.score_txt.gameObject:SetActive(true)
    	   self.score_txt.text = "+"..self.score
		   self.seq11 = DoTweenSequence.Create()
    	   self.seq11:Append(self.score_txt.transform:DOLocalMove(self.score_txt.transform.localPosition+Vector3.New(0,100,0), 1.5))
    	   self.seq11:AppendCallback(function ()
    		  self:MyExit()
            end)
    	end)
    end
end


function C:SunMoveWait3(score)
	self.seq2 = DoTweenSequence.Create()
    self.seq2:Append(self.sunBKicon_img.transform:DOLocalRotate(Vector3.New(0,0,360),2,DG.Tweening.RotateMode.FastBeyond360):SetLoops(-1,DG.Tweening.LoopType.Restart):SetEase(DG.Tweening.Ease.Linear))
	self.seq2:AppendInterval(2)	
	if self.now then
		return
	end
	self.seq2:Join(self.transform:DOLocalMove(self.parent_pos, 1))
    self.seq2:Join(self.sunBKicon_img.transform:DOLocalRotate(Vector3.New(0,0,360),2,DG.Tweening.RotateMode.FastBeyond360):SetLoops(-1,DG.Tweening.LoopType.Restart):SetEase(DG.Tweening.Ease.Linear))
    self.seq2:AppendCallback(function ()
    	self.SunItemInGame_btn.gameObject:SetActive(false)
        self.sunBKicon_img.gameObject:SetActive(false)
    	self.score_txt.gameObject:SetActive(true)
    	self.score_txt.text = "+"..self.score
		self.seq22 = DoTweenSequence.Create()
    	self.seq22:Append(self.score_txt.transform:DOLocalMove(self.score_txt.transform.localPosition+Vector3.New(0,100,0), 1.5))
    	self.seq22:AppendCallback(function ()
    		self:MyExit()
    	end)
    end)
end


function C:ClickSunItemPre()
    --dump("<color=red>PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP</color>")
   	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    self:SunMoveNow(self.score)
    self.now = true
end
