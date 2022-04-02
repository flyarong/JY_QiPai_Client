-- 创建时间:2019-03-06
-- Panel:FishingTestGamePanel
local basefunc = require "Game/Common/basefunc"

FishingTestGamePanel = basefunc.class()
local M = FishingTestGamePanel
local MController = FishingTestLogic
local MModel = FishingTestModel
M.name = "FishingTestGamePanel"

local instance
function M.Create()
	if not instance then
		instance = M.New()
		instance = createPanel(instance, M.name)
	else
		instance:MyRefresh()
	end
	return instance
end
function M.Bind()
    local _in = instance
    instance = nil
    return _in
end

function M.Close()
	if instance then
		instance:MyExit()
	end
	instance = nil
end

function M:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function M:MakeLister()
    self.lister = {}
    -- self.lister["model_fish_dead"] = basefunc.handler(self, self.model_fish_dead)
    -- self.lister["model_play_flee"] = basefunc.handler(self, self.PlayFlee)
end

function M:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function M:MyExit()
	self:RemoveListener()
	GameObject.Destroy(self.transform.gameObject)
end

local isPointDownOnUI = false
function M:Update()
    -- 检测是否放在UI上
    if gameRuntimePlatform == "WindowsEditor" or gameRuntimePlatform == "" then
        if EventSystem.current:IsPointerOverGameObject() and UnityEngine.Input.GetMouseButtonDown(0) then
            isPointDownOnUI = true
            return
        end

        if isPointDownOnUI and UnityEngine.Input.GetMouseButtonUp(0) then
            isPointDownOnUI = false
        end
    else
        if UnityEngine.Input.touchCount > 0 and EventSystem.current:IsPointerOverGameObject(UnityEngine.Input.GetTouch(0).fingerId) and UnityEngine.Input.GetTouch(0).phase == UnityEngine.TouchPhase.Began then
            isPointDownOnUI = true
            return
        end

        if isPointDownOnUI and UnityEngine.Input.GetTouch(0).phase == UnityEngine.TouchPhase.Ended then
            isPointDownOnUI = false
        end
    end

    if isPointDownOnUI then
        return
    end

end

function M:Awake()
	local tran = self.transform
	self.gameObject = self.transform.gameObject
	self:MakeLister()
	self:AddMsgListener()
	-- 创建2DUI
	local ui2d = newObject("FishingTest2DUI")
	self.Fishing2DUI_Obj = ui2d
	self.Fishing2DUI_Tran = ui2d.transform
	local tran_2D = ui2d.transform
	self.fish_node_tran = self.Fishing2DUI_Tran:Find("FishNodeTran").transform
	self.bullet_node_tran = self.Fishing2DUI_Tran:Find("BulletNodeTran").transform
	FishManager.Init(self.fish_node_tran)
	BulletManager.Init(self.bullet_node_tran)
	self.camera2d = self.Fishing2DUI_Tran:Find("CatchFish2DCamera"):GetComponent("Camera")

	self.camera = GameObject.Find("Canvas/Camera"):GetComponent("Camera")
    MModel.SetCamera(self.camera2d, self.camera)

    self.by_bg = self.Fishing2DUI_Tran:Find("by_bg"):GetComponent("SpriteRenderer")
    dump(tran:Find("UINode/FishBoomText"), "<color=white>self.boom>>>></color>")
    self.FishBoomText = tran:Find("UINode/FishBoomText"):GetComponent("Text")
    self.PlayerUI = {}
    self.PlayerUI2D = {}
    self.PlayerClass = {}
    for i=1, MModel.maxPlayerNumber do
    	self.PlayerUI[i] = tran:Find("UINode/Player"..i)
    	self.PlayerUI2D[i] = tran_2D:Find("Player"..i)
    end

    self.IceButton = tran:Find("UINode/IceButton"):GetComponent("Button")
    self.LockButton = tran:Find("UINode/LockButton"):GetComponent("Button")
    self.BackButton = tran:Find("UINode/BackButton"):GetComponent("Button")
    self.IceButton.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        self:OnIceClick()
    end)
    self.LockButton.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        self:OnLockClick()
    end)
    self.BackButton.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        self:OnBackClick()
    end)
    

    local width = Screen.width
    local height = Screen.height
    if width / height < 1 then
        width,height = height,width
    end
    local matchWidthOrHeight = MainModel.GetScene_MatchWidthOrHeight(width, height)
    if matchWidthOrHeight == 0 then
        self.by_bg.transform.localScale = Vector3.New(1, 1, 1)
    else
        self.by_bg.transform.localScale = Vector3.New(1.25, 1.25, 1)
    end
    self:InitUI()
end

function M:InitUI()
    self:OnBackClick()
end

function M:MyRefresh()

end

local isIce = false
function M:OnIceClick()
    isIce = not isIce
    if isIce then
    else
    end
    FishManager.SetIceState(isIce)
end

function M:OnBackClick()
    -- MainLogic.ExitGame()
    for k,v in pairs(self.PlayerUI) do
        v.gameObject:SetActive(not v.gameObject.activeSelf)
    end
    for k,v in pairs(self.PlayerUI2D) do
        v.gameObject:SetActive(not v.gameObject.activeSelf)
    end
end

function M:FrameUpdate(time_elapsed)
	if not isIce then
        VehicleManager.FrameUpdate(MModel.Defines.FrameTime)
    end
    FishManager.FrameUpdate()
    BulletManager.FrameUpdate()
end

-- 鱼儿逃离 2秒逃离完成
function M:PlayFlee()
    self.FishBoomText.text = "鱼潮来了!!!"
    VehicleManager.PlayFlee()
    FishManager.PlayFlee()
    self.flee_time = Timer.New(function ()
        self.FishBoomText.text = ""
        VehicleManager.RemoveAll()
        FishManager.RemoveAll()
    end, 2, 1)
    self.flee_time:Start()
end

function M:model_fish_dead(data)
    local bullet = BulletManager.GetIDToBullet(data.id)
    BulletManager.CloseBullet(data.id)

    for k,v in ipairs(data.fish_ids) do
        local fish = FishManager.GetFishByID(v)

        local uipos = MModel.GetSeatnoToPos(bullet.seat_num)
        local userdata = MModel.GetSeatnoToUser(bullet.seat_num)
        local fish_cfg = MModel.Config.fish_map[fish.data.fish_type]
        local bullet_cfg = MModel.Config.fish_gun_map[bullet.index]
        userdata.base.score = userdata.base.score + bullet_cfg.gun_rate * fish_cfg.rate
        self.PlayerClass[uipos]:RefreshMoney()

        if fish then
            fish:Dead()
        end
    end
end