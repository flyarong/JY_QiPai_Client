-- 创建时间:2020-04-07
-- Panel:act_008ItemBase
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

act_008ItemBase = basefunc.class()
local C = act_008ItemBase
C.name = "act_008ItemBase"

function C.Create(parent,data)
	return C.New(parent,data)
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


function C:ctor(parent,data)
	self.data = data
	local parent = parent or GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)


	self.slider=self.Slider:GetComponent("Slider")
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	EventTriggerListener.Get(self.go_btn.gameObject).onClick = basefunc.handler(self, self.go_Recharge)
	EventTriggerListener.Get(self.get_btn.gameObject).onClick = basefunc.handler(self, self.get_Award)
	self.light_BG = self.light_img.transform:GetComponent("Animator")
	self.dangci_txt.text = self.data[2]
	self.award_img.sprite = GetTexture(self.data[3])
	self.award_img:SetNativeSize()
	self.bx_img.sprite = GetTexture(self.data[4])
	self.bx_img:SetNativeSize()
	if self.data[5] then
		self.slider.value=self.data[5]
		self.slider_txt.text=self.data[5].." / 3"
		if	self.data[5]==3 then
			self.go_btn.gameObject:SetActive(false)
			if self.data[6]==2 then
				self.get_btn.gameObject:SetActive(false)
			else
				self.light_BG:Play("@light_ani", -1, 0)
			end 
		end
	end


	self:MyRefresh()
end

function C:MyRefresh()
end

--打开充值界面
function C:go_Recharge()
	PayPanel.Create(GOODS_TYPE.jing_bi, "normal")
end

--领取
function C:get_Award()
	if	self.data[1]==Act_008LGFLManager.config.Info[1].ID then
		self:Type_ID1()
	elseif self.data[1]==Act_008LGFLManager.config.Info[2].ID then
		self:Type_ID2()
	elseif self.data[1]==Act_008LGFLManager.config.Info[3].ID then
		self:Type_ID3()
	elseif self.data[1]==Act_008LGFLManager.config.Info[4].ID then
		self:Type_ID4()
	elseif self.data[1]==Act_008LGFLManager.config.Info[5].ID then
		self:Type_ID5()
	end
	-- body
end


function C:Type_ID1()
	dump(self.data,"2498")
	Network.SendRequest("get_task_award", {id = self.data[7]}, "领取奖励")
end

function C:Type_ID2()
	dump(self.data,"998")
	Network.SendRequest("get_task_award", {id = self.data[7]}, "领取奖励")
end

function C:Type_ID3()
	dump(self.data,"498")
	Network.SendRequest("get_task_award", {id = self.data[7]}, "领取奖励")
end

function C:Type_ID4()
	dump(self.data,"198")
	Network.SendRequest("get_task_award", {id = self.data[7]}, "领取奖励")
end

function C:Type_ID5()
	dump(self.data,"98")
	Network.SendRequest("get_task_award", {id = self.data[7]}, "领取奖励")
end

