-- 创建时间:2019-04-28
-- Panel:ShatterGoldenEvent2Egg
local basefunc = require "Game/Common/basefunc"

ShatterGoldenEvent2Egg = basefunc.class()
local C = ShatterGoldenEvent2Egg
C.name = "ShatterGoldenEvent2Egg"

local instance
function C.Create(parent)
	if not instance then
		instance = C.New(parent)
	else
		instance:MyRefresh()
	end
	return instance
end
function C.Close()
	if instance then
		instance:MyExit()
	end
	instance = nil
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
	self.lister = {}
	self.lister["get_zjd_cs_ls_act_cur_ls_response"] = basefunc.handler(self, self.OnQueryLS)
	self.lister["ExitScene"] = C.Close
	self.lister["OnLoginResponse"] = C.Close
	self.lister["will_kick_reason"] = C.Close
	self.lister["DisconnectServerConnect"] = C.Close
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	self:RemoveListener()
	GameObject.Destroy(self.gameObject)
end

function C:ctor(parent)
	local node = parent or GameObject.Find("Canvas/LayerLv5").transform
	local obj = newObject(C.name, node)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)

	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	self:QueryLSCount()
end

function C:InitUI()
	local config = ShatterGoldenEggModel.GetActivityConfig("caishen")
	if config then
		self.title_txt.text = "活动时间：" .. os.date("%m月%d日 %H:%M - ", config.start_time) .. os.date("%m月%d日 %H:%M", config.over_time)
	end

	self.desc_txt.text = "连出财神：0次"

	self.close_btn.onClick:AddListener(C.Close)
	self.rule_btn.onClick:AddListener(basefunc.handler(self, self.ShowRule))
end

function C:MyRefresh()
end

function C:ShowRule()
	IllustratePanel.Create({self.rule_txt}, self.transform)
end

function C.IsActivated()
	local curT = os.time()
end

function C:QueryLSCount()
	Network.SendRequest("get_zjd_cs_ls_act_cur_ls", {level = ShatterGoldenEggLogic.GetHammer()})
end

function C:OnQueryLS(pName, data)
	dump(data, "<color=yellow>--->>>OnQueryLS:</color>")
	if data.result == 0 then
		self.desc_txt.text = "连出财神：" .. data.cur_ls .. "次"
	else
		HintPanel.ErrorMsg(data.result)
	end
end
