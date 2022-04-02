local basefunc = require "Game/Common/basefunc"

Act_TY_BSYYPanel_Out = basefunc.class()
local C = Act_TY_BSYYPanel_Out
C.name = "Act_TY_BSYYPanel_Out"
local M = Act_TY_BSYYManager
local t 
local instance
function C.Create(parent,cfg,backcall)
	if instance then
		instance:MyExit()
	end
	instance = C.New(parent,cfg,backcall)
	return instance
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
	instance = nil
	if self.timer then 
		self.timer:Stop()
	end
	if self.backcall then
		self.backcall()
	end
	self.timer = nil
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:ctor(parent,cfg,backcall)
	local parent = parent or GameObject.Find("Canvas/LayerLv3").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	t = M.GetMatchStartTime() - os.time()
	LuaHelper.GeneratingVar(self.transform, self)
	self:InitUI()
	self:MakeLister()
	self:AddMsgListener()
	self:OutTimer()
	self.backcall = backcall
	self.transform:Find("BG"):GetComponent("Image").sprite = GetTexture(cfg.mian_img)
	Network.SendRequest("query_gns_ticket")
end


function C:InitUI()
	self.yuyue_btn.onClick:AddListener(
		function ()
			self.is_not_bind= (not MainModel.UserInfo.phoneData) or (not MainModel.UserInfo.phoneData.phone_no)
			--if GameGlobalOnOff.BindingPhone and self.is_not_bind and false then
			if GameGlobalOnOff.BindingPhone and self.is_not_bind then

				HintPanel.Create(1,"您还没有绑定手机，请先绑定手机",function ()
					AwardBindingPhonePanel.Create()
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
    self.timer = Timer.New(function()
        self.outtime_txt.text = StringHelper.formatTimeDHMS2(t)
        self.cut_txt.text = StringHelper.formatTimeDHMS2(t)
        t = t - 1
    end, 1, -1)
    self.timer:Start()
    self.cut_txt.text = StringHelper.formatTimeDHMS2(t)
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
    Network.SendRequest("query_gns_ticket")
	if data and data.result == 0 then 
		self.after_yuyue.gameObject:SetActive(true)
		self.yuyue.gameObject:SetActive(false)
	end 
end