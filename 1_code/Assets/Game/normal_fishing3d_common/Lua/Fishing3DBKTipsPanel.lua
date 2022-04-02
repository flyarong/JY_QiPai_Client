-- 创建时间:2020-03-05
-- Panel:Fishing3DBKTipsPanel
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

Fishing3DBKTipsPanel = basefunc.class()
local C = Fishing3DBKTipsPanel
C.name = "Fishing3DBKTipsPanel"

function C.Create(cfg)
	return C.New(cfg)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["ExitScene"] = basefunc.handler(self, self.onExitScene)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	if self.taskMove1 then
		self.taskMove1:Stop()
		self.taskMove1 = nil
	end
	--[[if self.taskMove2 then
		self.taskMove2:Stop()
		self.taskMove2=nil
	end]]
	self:RemoveListener()
	destroy(self.gameObject)

	 
end

function C:ctor(cfg)

	ExtPanel.ExtMsg(self)

	self.config = cfg
	local parent = GameObject.Find("Canvas/LayerLv5").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)

	self.camera = GameObject.Find("Canvas/Camera"):GetComponent("Camera")
	self.camera2d = self["2DCamera"]:GetComponent("Camera")

	self:MakeLister()
	self:AddMsgListener()
--update旋转
	self.taskMove1 = Timer.New(basefunc.handler(self, self.TipMoveIn), 0.02, -1, false)
	self.taskMove1:Start()
--[[update缩放
	self.taskMove2=Timer.New(basefunc.handler(self,self.ChangeScale),0.02,-1,false)
	self.taskMove2:Start()]]

	EventTriggerListener.Get(self.top_btn.gameObject).onDown = function ()
		self:onDown()
	end
	EventTriggerListener.Get(self.top_btn.gameObject).onUp = function ()
		self:onUp()
	end


	self:InitUI()
end
function C:onDown()
	self.is_down = true
end
function C:onUp()
	self.is_down = false	
end
function C:TipMoveIn()
	if self.is_down then
		if  not self.fish_obj.transform:GetComponent("Animator") then   --2D图片不提供旋转
			local MouseX = UnityEngine.Input.GetAxis("Mouse X")
			--local MouseY = UnityEngine.Input.GetAxis("Mouse Y")
			self.fish_obj.transform:Rotate(Vector3.New(0,0,1),MouseX*10)
			--fish.transform:Rotate(Vector3.New(1,0,0),MouseY*1.8)
		end
	end	
end

function C:InitUI()
	self.BGImg_btn.onClick:AddListener(function()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
        self:OnBackClick()
    end)
    local pp = self:GetUITo2DPoint(self.mx_node.position)
    self.FishNodeTran.position = pp
	self:MyRefresh()
end

function C:MyRefresh()
	self.name_txt.text = self.config.name
	self.bs_txt.text = self.config.rate or ""
	self.desc_txt.text = self.config.tips or "未知"
	if self.config.prefab then
		self:RefreshFish()
	end
end
function C:RefreshFish()
	self.fish_obj = GameObject.Instantiate(GetPrefab(self.config.prefab), self.FishNodeTran)
	local fish_tran = self.fish_obj.transform
	local scale = self.config.scale or 1
	fish_tran.localScale = Vector3(scale, scale, scale)
	fish_tran.localPosition = Vector3(0,0,50)
	if self.config.rotation and #self.config.rotation == 3 then
		fish_tran.localRotation = Quaternion.Euler(self.config.rotation[1], self.config.rotation[2], self.config.rotation[3])
	end

	local fish3dyz = fish_tran:Find("fish3dyz")
	if IsEquals(fish3dyz) then
		fish3dyz.gameObject:SetActive(false)
	end
end

function C:OnBackClick()
    self:MyExit()
end
function C:onExitScene()
    self:MyExit()
end
-- UI坐标转2D坐标
function C:GetUITo2DPoint(vec)
    vec = self.camera:WorldToScreenPoint(vec)
    vec = self.camera2d:ScreenToWorldPoint(vec)
    return vec
end

