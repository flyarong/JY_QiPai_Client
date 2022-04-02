-- 创建时间:2019-06-12
-- Panel:FishingBagPanel
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

FishingBagPanel = basefunc.class()
local C = FishingBagPanel
C.name = "FishingBagPanel"

FishingBagPanel.TYPE_ENUM = {
    free = "free",
    match = "match",
    free_3d = "free_3d",
}

local instance
function C.Create(parm)
    instance = C.New(parm)
	return instance
end
function C.Close()
    if instance then
        instance:OnBackClick()
    end
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    -- self.lister["AssetChange"] = basefunc.handler(self, self.onAssetChange)
    self.lister["ExitScene"] = basefunc.handler(self, self.onExitScene)
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
        self.timer = nil
    end
	self:RemoveListener()
    destroy(self.gameObject)	 
end

function C:ctor(parm)

	ExtPanel.ExtMsg(self)

    self.parm = parm
    PlayerPrefs.SetString(MainModel.RecentlyOpenBagTimeFishing, os.time())
    Event.Brocast("UpdateFishingBagRedHint")
    self.parent = GameObject.Find("Canvas/LayerLv4")
    self.gameObject = newObject(C.name, self.parent.transform)
    self.transform = self.gameObject.transform
    self:MakeLister()
    self:AddMsgListener()
    LuaHelper.GeneratingVar(self.gameObject.transform, self)
    if self.parm.game_type == C.TYPE_ENUM.free then
        self.bagData = GameItemModel.GetFishingBagItem(FishingModel.data.game_id)
    elseif self.parm.game_type == C.TYPE_ENUM.match then
        self.bagData = GameItemModel.GetFishingMatchBagItem(FishingModel.data.game_id)
    elseif self.parm.game_type == C.TYPE_ENUM.free_3d then
        self.bagData = GameItemModel.GetFishing3DBagItem(FishingModel.data.game_id)
    end

    self.close_btn.onClick:AddListener(function()
        self:OnBackClick()
    end)

    self.ci = 0
    self.pci = 10
    self.delayCreateFunc = function ()
        
        self.ci = self.ci + 1
        local ok = self:CreateBagItem(self.ci)
        if ok then
            
            local t = 0.03 * math.floor(self.ci/10)
            t = math.min(t,0.12)

            self.timer = Timer.New(self.delayCreateFunc,t)
            self.timer:Start()

        end

    end

    self:InitUI()
    DOTweenManager.OpenPopupUIAnim(self.transform)
end

function C:RefreshAssets()
    destroyChildren(self.content)

    if self.timer then
        self.timer:Stop()
        self.timer = nil
    end

    self.ci = 0

    for k, v in ipairs(self.bagData) do
        self.ci = self.ci + 1
        self:CreateBagItem(self.ci)
        if self.ci >= self.pci then
            break
        end
    end

    self.delayCreateFunc()

end

function C:InitUI()
	self:RefreshAssets()
end


function C:CreateBagItem(index)
    
    if not self.bagData then
        return false
    end

    local v = self.bagData[index]
    if not v then
        return false
    end

    if v.num > 0 or v.date > 0 then
        FishingBagItem.Create(self.content.transform, v, nil, self, self.parm.game_type)
    end

    return true

end

function C:MyRefresh()
end
function C:OnBackClick()
    self:MyExit()
end

function C:onAssetChange()
	self:RefreshAssets()
end
function C:onExitScene()
	self:OnBackClick()
end