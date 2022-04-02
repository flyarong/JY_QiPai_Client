-- 创建时间:2019-03-19
-- Panel:GoldenPig2Subsidy
local basefunc = require "Game/Common/basefunc"

GoldenPig2Subsidy = basefunc.class()
local C = GoldenPig2Subsidy
C.name = "GoldenPig2Subsidy"

local instance
function C.Create(leftCount)
	if not instance then
		instance = C.New(leftCount)
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
    self.lister["query_goldpig2_task_today_data_response"] = basefunc.handler(self, self.on_query_goldpig2_task_today_data_response)
	self.lister["ExitScene"] = basefunc.handler(self, self.OnExitScene)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	self:RemoveListener()
	if IsEquals(self.gameObject) then
		GameObject.Destroy(self.gameObject)
	end
end

function C:ctor(leftCount)
	local parent = GameObject.Find("Canvas/LayerLv5").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)

	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	self.SubTitle_txt.text = leftCount and ("总共剩" .. leftCount .. "次可领") or ""
end

function C:InitUI()
	EventTriggerListener.Get(self.confirm_btn.gameObject).onClick = basefunc.handler(self, self.OnConfirmClicked)
	GoldenPigModel.QueryGoldenPig2DayData()
end

function C:MyRefresh()
end

function C:QueryGoldenPig2DayData()
    Network.SendRequest("query_goldpig2_task_today_data", nil, "")
end

function C:on_query_goldpig2_task_today_data_response(pName, data)
    dump(data, "<color=yellow>GoldenPig2Subsidy.on_query_goldpig2_task_today_data_response</color>")
	if not IsEquals(self.desc_txt) then
		if IsEquals(self.transform) then
			self.desc_txt.text = self.transform:Find("@desc_txt"):GetComponent("Text")
		end
	end
    if data.result == 0 and data.total_num > 0 then
		if IsEquals(self.desc_txt) then
		self.desc_txt.text = "每日首次登录游戏自动领取20万鲸币\n每日只能领" .. data.total_num .. "次"
		end
	else
		if IsEquals(self.desc_txt) then
		self.desc_txt.text = "每日首次登录游戏自动领取20万鲸币\n每日只能领1次"
		end
    end
end

function C:OnConfirmClicked()
	ParticleManager.PlayNormal("jingbi_tanchu", nil, 5, nil, GameObject.Find("Canvas/LayerLv5"))
	C.Close()
	package.loaded["Game.CommonPrefab.Lua.GoldenPig2Subsidy"] = nil
end

function C:OnExitScene()
	C.Close()
end