local basefunc = require "Game/Common/basefunc"

BrokeTPPanel = basefunc.class()
local C = BrokeTPPanel
C.name = "BrokeTPPanel"

function C.Create(parent,data,TorP)
	return C.New(parent,data,TorP)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
	self.lister = {}
	self.lister["remove_apprentice_response"] = basefunc.handler(self,self.on_remove_apprentice_response)
	self.lister["change_info_from_apprentice_response"] = basefunc.handler(self,self.on_change_info_from_apprentice_response)
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

function C:ctor(parent,data,TorP)

	ExtPanel.ExtMsg(self)

	local parent = parent or GameObject.Find("Canvas/LayerLv5").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	self.data = data
	self.TorP = TorP
	LuaHelper.GeneratingVar(self.transform, self)
	self:MakeLister()
	self:AddMsgListener()
	
	self:InitUI()
end

function C:InitUI()
	self.message_txt.text = "你确定与<color=#ED8813FF>【"..self.data.player_name.."】</color>解除师徒关系吗？"
	self.confirm_btn.onClick:AddListener(
		function ()
			if self.TorP == "T" then 
				Network.SendRequest("remove_apprentice",{apprentice_id = self.data.apprentice_id})
			else
				Network.SendRequest("change_info_from_apprentice",{message_type = 1,master_id = self.data.master_id})
			end
		end
	)
	self.refuse_btn.onClick:AddListener(
		function ()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
			self:MyExit() 
		end
	)
	self:MyRefresh()
end

function C:MyRefresh()

end

function C:on_remove_apprentice_response(_,data)
	if data and data.result == 0 then 
		HintPanel.Create(1,"关系解除申请已发送")
		Event.Brocast("tp_CloseTHENOpen")
	end
	self:MyExit() 
end

function C:on_change_info_from_apprentice_response(_,data)
	if data and data.result == 0 then 
		HintPanel.Create(1,"关系解除申请已发送")
		Event.Brocast("tp_CloseTHENOpen")
	end 
	self:MyExit() 
end