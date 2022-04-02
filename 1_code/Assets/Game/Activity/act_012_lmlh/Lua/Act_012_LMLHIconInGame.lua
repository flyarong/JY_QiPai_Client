-- 创建时间:2020-05-06
-- Panel:Act_012_LMLHIconInGame
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

Act_012_LMLHIconInGame = basefunc.class()
local C = Act_012_LMLHIconInGame
C.name = "Act_012_LMLHIconInGame"

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

function C:StopSeq()
    if self.seq then
        self.seq:Kill()
    end
    if self.seq0 then
        self.seq0:Kill()
    end
    if self.seq1 then
        self.seq1:Kill()
    end
    if self.seq11 then
        self.seq11:Kill()
    end
    if self.seq2 then
        self.seq2:Kill()
    end
    if self.seq22 then
        self.seq22:Kill()
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
    	self.transform.position = Vector3.New(0,550,0)
        self.ItemInGame_btn.gameObject:SetActive(true)

    	self.seq0 = DoTweenSequence.Create()
        self.seq0:Append(self.transform:DOMove(Vector3.New(0,0,0), 2))
        self.seq0:AppendCallback(function ()
            self.is_btn = true
            self:IconMoveWait3(self.score)
         end)
    end)

	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	EventTriggerListener.Get(self.ItemInGame_btn.gameObject).onClick = basefunc.handler(self,self.ClickItemPre)
	self:MyRefresh()
end

function C:MyRefresh()
end


function C:IconMoveNow(score)
    if self.is_btn then --
	    self.seq1 = DoTweenSequence.Create()
	    self.seq1:Append(self.transform:DOLocalMove(self.parent_pos, 1))
        self.seq1:AppendCallback(function ()
    	   self.ItemInGame_btn.gameObject:SetActive(false)
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


function C:IconMoveWait3(score)
	self.seq2 = DoTweenSequence.Create()
	self.seq2:AppendInterval(2)	
	if self.now then
		return
	end
	self.seq2:Append(self.transform:DOLocalMove(self.parent_pos, 1))
    self.seq2:AppendCallback(function ()
    	self.ItemInGame_btn.gameObject:SetActive(false)
    	self.score_txt.gameObject:SetActive(true)
    	self.score_txt.text = "+"..self.score
		self.seq22 = DoTweenSequence.Create()
    	self.seq22:Append(self.score_txt.transform:DOLocalMove(self.score_txt.transform.localPosition+Vector3.New(0,100,0), 1.5))
    	self.seq22:AppendCallback(function ()
    		self:MyExit()
    	end)
    end)
end


function C:ClickItemPre()
   	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    self:IconMoveNow(self.score)
    self.now = true
end