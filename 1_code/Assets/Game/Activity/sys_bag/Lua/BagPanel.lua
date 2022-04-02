local basefunc = require "Game.Common.basefunc"

BagPanel = basefunc.class()
function BagPanel:ctor()

	ExtPanel.ExtMsg(self)

    PlayerPrefs.SetString(MainModel.RecentlyOpenBagTime, os.time())
    Event.Brocast("UpdateHallBagRedHint")
    self.parent = GameObject.Find("Canvas/LayerLv3")
    self.gameObject = newObject("BagPanel", self.parent.transform)
    self.transform = self.gameObject.transform
    LuaHelper.GeneratingVar(self.gameObject.transform, self)
    self.bagData = GameItemModel.GetBagItem()
    self.AssetChange = function()
        self:RefreshAssets()
    end
    Event.AddListener("AssetChange", self.AssetChange)
    self.Exit = function()
        self:MyExit()
    end
    Event.AddListener("ExitScene", self.Exit)

    self.close_btn.onClick:AddListener(
        function()
            self:MyExit()
        end
    )

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

    self:RefreshAssets()

    DOTweenManager.OpenPopupUIAnim(self.transform)
end

function BagPanel:MyExit()
    if self.timer then
        self.timer:Stop()
        self.timer = nil
    end
    Event.RemoveListener("AssetChange", self.AssetChange)
    Event.RemoveListener("ExitScene", self.Exit)
    destroy(self.gameObject)
end

function BagPanel:Close()
    self:MyExit()
end


function BagPanel:CreateBagItem(index)

    if not self.bagData then
        return false
    end

    local v = self.bagData[index]

    if not v then
        return false
    end

    if GameItemModel.GetItemType(v) == GameItemModel.ItemType.act then
        if tonumber(v.bullet_num) > 0 or (v.data and tonumber(v.date) > 0) then
            BagItem.Create(self.content.transform, v, nil, self)
        end
    else
        if v.num > 0 or v.date > 0 then
            BagItem.Create(self.content.transform, v, nil, self)
        end
    end

    return true
end


function BagPanel:RefreshAssets()
    destroyChildren(self.content)


    self.bagData = GameItemModel.GetBagItem()
    if table_is_null(self.bagData) then return end

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
