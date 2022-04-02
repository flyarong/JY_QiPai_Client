-- 创建时间:2021-03-17
-- Panel:RXCQShowMoneyItem
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

RXCQShowMoneyItem = basefunc.class()
local C = RXCQShowMoneyItem
C.name = "RXCQShowMoneyItem"

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
end

function C:OnDestroy()
	self:MyExit()
end

function C:MyClose()
	self:MyExit()
end

function C:ctor(parent)
	ExtPanel.ExtMsg(self)
	self.parent = parent or GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject("RXCQShowMoneyItem_sbtj", parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()

end

function C:ReSetMoney()
	self.money = 0
	self.num_txt.text = money
end

function C:Hide()
	self.gameObject:SetActive(false)
end

function C:Show(str)
	destroy(self.gameObject)
	self.gameObject = newObject(C.name.."_"..str, self.parent)
	self.gameObject:SetActive(true)
	self.transform = self.gameObject.transform
	if str == "trhy" then
		self.transform.localPosition = Vector3.New(-160,698,0)
	elseif str == "sbtj" then
		self.transform.localPosition = Vector3.New(43,150,0)
	end
	LuaHelper.GeneratingVar(self.transform, self)
end

function C:DoPopAnim(money,is_last,overcall)
	local seq = DoTweenSequence.Create({dotweenLayerKey = C.name})
	seq:Append(self.num_txt.gameObject.transform:DOScale(Vector3.New(2,2,2),0.05))
	seq:Join(self.num_txt.gameObject.transform:DOLocalMove(Vector3.New(-103.2,109,0),0.05))
	seq:AppendCallback(
		function()
			self.money = self.money or 0
			self.money = self.money + money
			self.num_txt.text = self.money
			if is_last then
				self.num_txt.text = RXCQModel.game_data.award
				RXCQModel.DelayCall(
					function()
						if overcall then
							overcall()
						end
					end
				,0.6)
			end
		end
	)
    seq:AppendInterval(0.05)
	seq:Append(self.num_txt.gameObject.transform:DOScale(Vector3.New(1,1,1),0.2))
	seq:Join(self.num_txt.gameObject.transform:DOLocalMove(Vector3.New(-103.2,58,0),0.2))
end