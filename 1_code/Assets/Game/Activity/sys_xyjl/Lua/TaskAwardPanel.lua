-- 创建时间:2018-06-06
local basefunc = require "Game.Common.basefunc"
TaskAwardPanel = basefunc.class()
TaskAwardPanel.name = "TaskAwardPanel"

local instance
function TaskAwardPanel.Create(data)
	dump(data, "<color=green>活动奖励</color>")
	if not instance then
		instance = TaskAwardPanel.New(data)
	end
	return instance
end

function TaskAwardPanel.Close()
	if instance then
		instance.data = nil
		instance:RemoveListener()
		if IsEquals(instance.gameObject) then
			GameObject.Destroy(instance.gameObject)
		end
		instance = nil
	end
end

function TaskAwardPanel:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function TaskAwardPanel:MakeLister()
    self.lister = {}
    self.lister["ExitScene"] = basefunc.handler(self, self.OnExitScene)
end

function TaskAwardPanel:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
end

function TaskAwardPanel:ctor(data)
	self.data = data

	local parent = GameObject.Find("Canvas/LayerLv50")
	if not parent then
		parent = GameObject.Find("Canvas/LayerLv5")
	end
	if not parent then
		parent = GameObject.Find("Canvas")
	end
	self:MakeLister()
	self:AddMsgListener()
	local obj = newObject(TaskAwardPanel.name, parent.transform)
	self.gameObject = obj
	self.transform = obj.transform

	LuaHelper.GeneratingVar(self.transform,self)
	self.AwardCellList = {}
	self:InitRect()
	DOTweenManager.OpenPopupUIAnim(self.transform)
end

function TaskAwardPanel:InitRect()
	local func_back = function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnExitScene()
	end

	self.confirm_btn.onClick:AddListener(func_back)
	self.close_btn.onClick:AddListener(func_back)

	local data = self.data
	self:CloseAwardCell()
	for i=1,#data do
		local v = data[i]
		self.AwardCellList[#self.AwardCellList + 1] = self:CreateItem(v)
	end
end

function TaskAwardPanel:CloseAwardCell()
	for i,v in ipairs(self.AwardCellList) do
		GameObject.Destroy(v.gameObject)
	end
	self.AwardCellList = {}
end

function TaskAwardPanel:CreateItem(data)
	local obj = GameObject.Instantiate(self.AwardPrefab)
	obj.transform:SetParent(self.AwardNode)
	obj.transform.localScale = Vector3.one
	local obj_t = {}
	LuaHelper.GeneratingVar(obj.transform,obj_t)
	obj_t.DescText_txt.text = data.desc
	PointerEventListener.Get(obj_t.AwardIcon_img.gameObject).onDown = function(  )
		local pos = UnityEngine.Input.mousePosition
		GameTipsPrefab.ShowDesc(data.tip, pos)
	end
	PointerEventListener.Get(obj_t.AwardIcon_img.gameObject).onUp = function(  )
		GameTipsPrefab.Hide()
	end
	GetTextureExtend(obj_t.AwardIcon_img, data.icon, data.is_local_icon)
	if data.asset_type == "shop_gold_sum" then		
		obj_t.NameText_txt.text = data.value / 100
		obj_t.NameText_txt.gameObject:SetActive(true)
	end
	obj.gameObject:SetActive(true)
	return obj
end

function TaskAwardPanel:OnExitScene()
	TaskAwardPanel.Close()
end
