local basefunc = require "Game.Common.basefunc"

GMPanel = basefunc.class()
GMPanel.name = "GMPanel"

local instance

function GMPanel.Create()
	GMPanel.Close()
	if not instance or not IsEquals(instance.gameObject) then
		instance = GMPanel.New()
	end
	return instance
end

function GMPanel.Close()
	if instance then
		instance:ClearCMDList()
		instance:RemoveListener()
		GameObject.Destroy(instance.gameObject)
		instance = nil
	end
end

function GMPanel:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function GMPanel:MakeLister()
	self.lister = {}
	self.lister["gm_command_response"] = basefunc.handler(self, self.gm_command_response)
end

function GMPanel:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
end

function GMPanel:ctor()
	local parent = GameObject.Find("Canvas/LayerLv50").transform
	local obj = newObject(GMPanel.name, parent)
	self.transform = obj.transform
	self.gameObject = self.transform.gameObject
	LuaHelper.GeneratingVar(self.transform, self)
	self:MakeLister()
	self:AddMsgListener()
	self:InitRect()
	DOTweenManager.OpenPopupUIAnim(self.transform)

	self:CreateItem(MainModel.UserInfo.user_id)

    local a,b = GameButtonManager.RunFun({gotoui="sys_qx"}, "debug_test")
    if a and b then
		self:CreateItem(b)
	end
	Event.Brocast("global_game_panel_open_msg", {ui="GMPanel"})
end

function GMPanel:InitRect()
	local transform = self.transform

	self.scrollRect = transform:Find("Scroll View"):GetComponent("ScrollRect")

	self.inputCMDField = transform:Find("InputCMDField"):GetComponent("InputField")
	self.taskInput = transform:Find("TaskInput"):GetComponent("InputField")
	self.taskNumInput = transform:Find("TaskNumInput"):GetComponent("InputField")
	self.lotteryInput = transform:Find("LotteryInput"):GetComponent("InputField")
	self.lotteryNumInput = transform:Find("LotteryNumInput"):GetComponent("InputField")
	self.lotteryTypeInput = transform:Find("LotteryTypeInput"):GetComponent("InputField")
	self.assetInput = transform:Find("assetInput"):GetComponent("InputField")
	self.assetNumInput = transform:Find("assetNumInput"):GetComponent("InputField")
	self.inputCMDField.onValueChanged:AddListener(function (val)
		
	end)
	self.inputCMDField.onEndEdit:AddListener(function ()
		if UnityEngine.Input.GetKeyDown(UnityEngine.KeyCode.Return) or UnityEngine.Input.GetKeyDown(UnityEngine.KeyCode.KeypadEnter) then
			self:DoCommand()
		end
	end)

	self.close_btn.onClick:AddListener(function()
		GMPanel.Close()
	end)

	self.send_btn.onClick:AddListener(function()
		self:DoCommand()
	end)

	self.money_btn.onClick:AddListener(function()
		Network.SendRequest("gm_command",{command="money \""..MainModel.UserInfo.user_id.."\",\"jing_bi\",10000000"})
	end)

	self.money2_btn.onClick:AddListener(function()
		Network.SendRequest("gm_command",{command="money \""..MainModel.UserInfo.user_id.."\",\"jing_bi\",-"..MainModel.UserInfo.jing_bi})
	end)

	self.task_btn.onClick:AddListener(function()		
		Network.SendRequest("gm_command",{command="add_task_progress \""..MainModel.UserInfo.user_id.."\","..self.taskInput.text..","..self.taskNumInput.text..""})
	end)

	self.lottery_btn.onClick:AddListener(function()		
		Network.SendRequest("gm_command",{command="add_lottery_score \""..MainModel.UserInfo.user_id.."\","..self.lotteryInput.text..","..self.lotteryTypeInput.text..","..self.lotteryNumInput.text..""})
	end)

	self.asset_btn.onClick:AddListener(function()	
		Network.SendRequest("gm_command",{command="money \""..MainModel.UserInfo.user_id.."\",\""..self.assetInput.text.."\","..self.assetNumInput.text})
	end)

	self.cmdList = {}
end

function GMPanel:DoCommand()
	local cmd = self.inputCMDField.text
	if cmd == "" then
		return
	end

	self:Refresh(cmd)
	print("[Debug] send gm command: " .. cmd)

	if string.sub(cmd, 1, 1) == "@" then
		local ss = string.sub(cmd, 2, -1)
		print("<color=red><size=20>===========================</size></color>")
		xpcall(function ()
			loadstring(ss)()
		end, function (error)
			dump(error, "<color=red>error</color>")
		end)
	else
		Network.SendRequest("gm_command",{command=cmd})
	end

	self.inputCMDField.text = "";
	self.inputCMDField:ActivateInputField();
end

function GMPanel:Refresh(item)
	local cnt = #self.cmdList
	self.cmdList[cnt + 1] = self:CreateItem(item)

	UnityEngine.Canvas.ForceUpdateCanvases()
	self.scrollRect.verticalNormalizedPosition = 0
end

function GMPanel:ClearCMDList()
	for i,v in pairs(self.cmdList) do
		GameObject.Destroy(v.gameObject)
	end
	self.cmdList = {}
end

function GMPanel:CreateItem(item)
	if not IsEquals(self.cmd_item_tmpl) then return end
	local obj = GameObject.Instantiate(self.cmd_item_tmpl)
	obj.transform:SetParent(self.list_node)
	obj.transform.localScale = Vector3.one
	local cmd_text = obj.transform:GetComponent("Text")
	cmd_text.text = item or ""
	obj.gameObject:SetActive(true)

	-- EventTriggerListener.Get(obj.gameObject).onClick = basefunc.handler(self, self.OnCopyClick)

	return obj
end
function GMPanel:OnCopyClick(obj)
	local tt = obj.transform:GetComponent("Text")
	self.inputCMDField.text = tt.text;
end

--启动事件--
function GMPanel:Awake()
end

function GMPanel:Start()	
end

function GMPanel:OnDestroy()
	GMPanel.Close()
end

function GMPanel:gm_command_response(_, result)
	self:Refresh(result.result)
end
