-- 创建时间:2019-03-19
-- Panel:LWZBLoadingPanel
local basefunc = require "Game/Common/basefunc"

LWZBLoadingPanel = basefunc.class()
local C = LWZBLoadingPanel
C.name = "LWZBLoadingPanel"

C.LoadingState = 
{
	LS_Res = "加载资源",
	LS_Ready = "发送准备",
	LS_Recover = "恢复场景",
	LS_Finish = "加载完成",
}
local length = 100

function C.Create(call)
	return C.New(call)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["model_lwzb_recover_finish"] = basefunc.handler(self, self.model_recover_finish)
    self.lister["ExitScene"] = basefunc.handler(self, self.onExitScene)
end

function C:onExitScene()
	self:MyExit()
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	if self.timerUpdate then
		self.timerUpdate:Stop()
		self.timerUpdate = nil
	end
	if self.call then
		if type(self.call) == "function" then
			self.call()
			self.call = nil
		end
	end
	self:RemoveListener()
	self.Rate_img.sprite = nil
	destroy(self.gameObject)
end

function C:ctor(call)

	ExtPanel.ExtMsg(self)
	local prefab_name = "LWZB_loadingPrefab"
	local parent = GameObject.Find("Canvas/LayerLv1").transform
	local obj = newObject(prefab_name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	self.call = call
	LuaHelper.GeneratingVar(self.transform, self)

	self.width = 1000
	self.load_state = C.LoadingState.LS_Res
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()

	--[[local bg = self.transform:Find("UINode/BGImage")
	MainModel.SetGameBGScale(bg)--]]
end

function C:InitUI()
    local width = Screen.width
    local height = Screen.height
    if width / height < 1 then
        width,height = height,width
    end
	--local matchWidthOrHeight = MainModel.GetScene_MatchWidthOrHeight(width, height)
    if width / height <= 1920 / 1080 then
        self.transform.localScale = Vector3.New(1, 1, 1)
    else
        self.transform.localScale = Vector3.New(1.35, 1.35, 1)
        self.Rate.transform.localScale = Vector3.New(0.75,0.75,1)
    end

	self.Rate_img.fillAmount = 0
	self.RateText_txt.text = "0%"
	self.RateNode.localPosition = Vector3.New(-self.width/2, 0, 0)

	self.rate_val = 0
	self.currLoadCount = 0
	self.allLoadCount = length
	self.timerUpdate = Timer.New(function ()
		self:Update()
	end, -1, -1, true)
	self.timerUpdate:Start()
	
end

function C:LoadAssetAsync()
    -- 加载
    for i=1,length do
    	Yield(0)
		self.currLoadCount = self.currLoadCount or 0
        self.currLoadCount = self.currLoadCount + 1
    end
end

function C:Update()
	if self.load_state == C.LoadingState.LS_Res then
		coroutine.start(function ( )
			self:LoadAssetAsync()
		end)
		self.load_state = C.LoadingState.LS_Res_Loading
	elseif self.load_state == C.LoadingState.LS_Res_Loading then
		if not self.allLoadCount or self.allLoadCount <= 0 then
			self.load_state = C.LoadingState.LS_Ready
			return
		end
		self.rate_val = self.currLoadCount / self.allLoadCount * 0.9
		self:UpdateRate(self.rate_val)
		if self.rate_val >= 0.899999 then
			--self.load_state = C.LoadingState.LS_Ready
			self.load_state = C.LoadingState.LS_Finish
		end
	elseif self.load_state == C.LoadingState.LS_Ready then
	    self.load_state = C.LoadingState.LS_Recover
	elseif self.load_state == C.LoadingState.LS_Recover then

	elseif self.load_state == C.LoadingState.LS_Finish then
		Event.Brocast("loding_finish")
		self:MyExit()
	end
end

function C:model_recover_finish()

	--self.load_state = C.LoadingState.LS_Finish
end

function C:UpdateRate(val)
	self.Rate_img.fillAmount = val
	self.RateText_txt.text = string.format("%.2f", val * 100) .. "%"

	self.RateNode.localPosition = Vector3.New(-self.width/2 + self.width * val, 0, 0)
end
