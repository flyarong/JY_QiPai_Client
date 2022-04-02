local basefunc = require "Game/Common/basefunc"

ACT_005BSYYPanel_Out = basefunc.class()
local C = ACT_005BSYYPanel_Out
C.name = "ACT_005BSYYPanel_Out"
local t 
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
	self.lister["query_gns_ticket_response"] = basefunc.handler(self,self.OnGetInfo)
	self.lister["get_gns_ticket_response"] = basefunc.handler(self,self.OnGetAward)
	self.lister["ExitScene"] = basefunc.handler(self,self.MyExit)
end

function C:RemoveListener()
	for proto_name,func in pairs(self.lister) do
		Event.RemoveListener(proto_name, func)
	end
	self.lister = {}
end

function C:MyExit()
	if self.timer then 
		self.timer:Stop()
	end
	self.timer = nil
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:ctor(parent)
	local parent = parent or GameObject.Find("Canvas/LayerLv3").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	t = 1585659600 - os.time()
	LuaHelper.GeneratingVar(self.transform, self)
	self:InitUI()
	self:MakeLister()
	self:AddMsgListener()
	self:OutTimer()
	Network.SendRequest("query_gns_ticket")
end


function C:InitUI()
	self.yuyue_btn.onClick:AddListener(
		function ()
			self.is_not_bind= (not MainModel.UserInfo.phoneData) or (not MainModel.UserInfo.phoneData.phone_no)
			if GameGlobalOnOff.BindingPhone and self.is_not_bind then
				HintPanel.Create(1,"您还没有绑定手机，请先绑定手机",function ()
					GameManager.GotoUI({gotoui = "sys_binding_phone_award",goto_scene_parm = "panel"})
				end)
			else
				if MainModel.GetHBValue() >= 1 then 
					Network.SendRequest("get_gns_ticket")					
				else
					HintPanel.Create(1,"福卡不足哦，快去商城充值吧！",function ()
						PayPanel.Create(GOODS_TYPE.jing_bi, "normal")
					end)
				end 
			end 
		end
    )
    self.close_btn.onClick:AddListener(
        function ()
            self:MyExit()
        end
    )
end


function C:OnDestroy()
	self:MyExit()
end

function C:OutTimer()
	if self.timer then 
		self.timer:Stop()
	end
	self.timer = nil 
	self.timer = Timer.New(function ()
		self.outtime_txt.text = StringHelper.formatTimeDHMS2(t)
		t = t -1 
	end,1,-1)
	self.timer:Start()
	self.outtime_txt.text = StringHelper.formatTimeDHMS2(t)
end

function C:OnGetInfo(_,data)
	dump(data,"预约-----")
	if data and data.result == 0 then 
		if data.status == 1 then 
			self.after_yuyue.gameObject:SetActive(true)
			self.yuyue.gameObject:SetActive(false)
		else
			self.after_yuyue.gameObject:SetActive(false)
			self.yuyue.gameObject:SetActive(true)
		end 
	end 
end

function C:OnGetAward(_,data)
	dump(data,"预约返回")
	if data and data.result == 0 then 
		self.after_yuyue.gameObject:SetActive(true)
		self.yuyue.gameObject:SetActive(false)
	end 
end