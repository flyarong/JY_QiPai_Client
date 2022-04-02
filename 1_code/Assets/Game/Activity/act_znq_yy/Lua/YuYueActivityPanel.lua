-- 创建时间:2019-08-14
-- Panel:YuYueActivityPanel
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

YuYueActivityPanel = basefunc.class()
local C = YuYueActivityPanel
C.name = "YuYueActivityPanel"

function C.Create(parent)
	--return 
	return C.New(parent)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
	self.lister = {}
	self.lister["query_yuyue_base_info_response"]=basefunc.handler(self,self.onGetBaseInfo)
	self.lister["yuyue_activity_response"]=basefunc.handler(self,self.onResult)
	self.lister["AssetsGetPanelConfirmCallback"]=basefunc.handler(self,self.AssetChange)
end


function C:AssetChange(data)
	if data.change_type and data.change_type == "bind_phone_award"  and  os.time() < 1567439999 then 		
		HintPanel.Create(1, "预约成功，预约奖励已经发到邮箱啦!",nil,nil,nil,"周年预约有礼")	
	end
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

function C:ctor(parent)

	ExtPanel.ExtMsg(self)

	local parent = parent
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	self.day_txt=self.transform:Find("Text"):GetComponent("Text")
	self.button=self.transform:Find("Button"):GetComponent("Button")
	self.buttonmask=self.transform:Find("ButtonMask")
	self.isnotbind= (not MainModel.UserInfo.phoneData) or (not MainModel.UserInfo.phoneData.phone_no)
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	self:RefreshDay()
	Network.SendRequest("query_yuyue_base_info")
end

function C:InitUI()
	self.buttonmask.gameObject:SetActive(false)
	self.button.onClick:AddListener(
		function ()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
			if  self.isnotbind then --false then 
			   BindingYuYuePanel.Create(nil,"礼包内容:5000鲸币+周年感恩公益赛门票",
			   function ()
				    self:yuyue_activity()
			   end)
			else
				self:yuyue_activity()
			end 
		end
	)

	self:MyRefresh()
end

function C:MyRefresh()
end

function C:OnDestroy()
	self:MyExit()
end

function C:yuyue_activity()
	Network.SendRequest("yuyue_activity")
	Network.SendRequest("query_yuyue_base_info")
end

function C:RefreshDay()
	-- if day<=0 then 
	-- 	day=0
	-- end 
	-- self.day_txt.text=day
end

function C:onResult(_,data)
	if data and data.result then 
		if   data.result ==0 then 
			 self:GetMask()
			--  dump(self.isnotbind,"----------------")
			--  dump( MainModel.UserInfo.phoneData.phone_no ,"--------222---------")
			 if  not self.isnotbind then 
			 	 HintPanel.Create(1, "预约成功，预约奖励已经发到邮箱啦!",nil,nil,nil,"周年预约有礼")	
			 end 
		else
			HintPanel.ErrorMsg(data.result)
		end 
	end 
end

function C:GetMask()
	self.buttonmask.gameObject:SetActive(true)
end

function C:onGetBaseInfo(_,data)
	if data and data.result and  data.result ==0 then 
		if data.is_yuyue ==1 then 
			self:GetMask()
		end 
	end 
end