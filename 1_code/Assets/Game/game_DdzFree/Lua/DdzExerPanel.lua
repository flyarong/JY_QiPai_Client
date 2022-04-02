-- 创建时间:2018-06-06

local basefunc = require "Game.Common.basefunc"

DdzExerPanel = basefunc.class()

DdzExerPanel.name = "DdzExerPanel"
local instance
function DdzExerPanel.Create(parent, data, config)
    SysInteractivePlayerManager.Close()
    SysInteractiveChatManager.Hide()

    if not instance then
        instance = DdzExerPanel.New(parent,data,config)
    end
    return instance
end

function DdzExerPanel:MyExit()
    self:RemoveListener()
    destroy(self.gameObject)
    self.data = nil
    self.config = nil
end

function DdzExerPanel.Close()
    if instance then
        instance:MyExit()
		instance = nil
    end
end

function DdzExerPanel:MakeLister()
    self.lister = {}
end

function DdzExerPanel:RemoveListener()
    for proto_name, func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
end

function DdzExerPanel:ctor(parent,data,config)

	ExtPanel.ExtMsg(self)

	parent = parent or GameObject.Find("Canvas/LayerLv3").transform
	self.data = data
	self.config = config
    self:MakeLister()
    local obj = newObject(DdzExerPanel.name, parent)
    local tran = obj.transform
    self.transform = tran
    self.gameObject = obj
    self.CellPrefab = tran:Find("CellPrefab")
    self.BackButton = tran:Find("BackButton"):GetComponent("Button")
    self.BackButton.onClick:AddListener(
        function()
            ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
            self:OnBackClick()
        end
    )

    self.back_btn = tran:Find("back_btn"):GetComponent("Button")
    self.back_btn.onClick:AddListener(
        function()
            ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
            self:OnBackClick()
        end
    )

    self.TopHintText = tran:Find("BGImage/TopHintText"):GetComponent("Text")
    self.WinNumText = tran:Find("CenterNode/WinNumText"):GetComponent("Text")
    self.GameNumText = tran:Find("CenterNode/GameNumText"):GetComponent("Text")
    self.AwardNode = tran:Find("CenterNode/ScrollView/Viewport/Content")

    self.AwardCell = {}

    -- 游戏胜利
    self.winNum = self.data.win_count
    self.gameNum = self.data.all_win
    self.nextAward, self.currAwardIndex = self:getNextAward(self.data.win_count)
    self:InitRect()

    DOTweenManager.OpenClearUIAnim(self.transform)
end

function DdzExerPanel:InitRect()
    for i, v in ipairs(self.config.award) do
        self:CreateItem(v, i)
    end

    local panyi = self.currAwardIndex - 2.5
    if panyi < 0 then
        panyi = 0
    end
    self.AwardNode.transform.localPosition = Vector3.New(-1 * panyi * 300, 0, 0)

    self.WinNumText.text = "" .. self.winNum
    self.GameNumText.text = "" .. self.gameNum
    self.TopHintText.text = self.data.win_count == self.config.award[#self.config.award].win_count and "恭喜您获得胜利" or "加油努力，你将获得一下奖励"
end

-- 创建Itme
function DdzExerPanel:CreateItem(data, i)
    local obj = GameObject.Instantiate(self.CellPrefab)
    local tran = obj.transform
    tran:SetParent(self.AwardNode)
    self.AwardCell[#self.AwardCell + 1] = obj
    tran.localScale = Vector3.one
    obj.gameObject:SetActive(true)

    local left = tran:Find("LeftImage"):GetComponent("Image")
    local right = tran:Find("RightImage"):GetComponent("Image")
    tran:Find("DBImage/DescText"):GetComponent("Text").text = data.win_count .. "胜"
    tran:Find("DBImage/NumText"):GetComponent("Text").text = "x" .. data.count
    local awardImage = tran:Find("DBImage/TypeImage"):GetComponent("Image")
    local tt = AwardManager.GetAwardImage(data.award)
    GetTextureExtend(awardImage, tt.image, tt.is_local_icon)
    
    local get = tran:Find("DBImage/GetImage")
    local mark = tran:Find("MarkImage")
    if data.id == 1 then
        left.gameObject:SetActive(false)
        right.gameObject:SetActive(true)
    elseif data.id == #self.config.award then
        left.gameObject:SetActive(true)
        right.gameObject:SetActive(false)
    else
        left.gameObject:SetActive(true)
        right.gameObject:SetActive(true)
    end
    if self.winNum >= data.win_count then
        left.sprite = GetTexture("freetable_bg_bar_2")
        right.sprite = GetTexture("freetable_bg_bar_2")
        get.gameObject:SetActive(true)
        mark.gameObject:SetActive(false)
    else
        left.sprite = GetTexture("freetable_bg_bar_1")
        right.sprite = GetTexture("freetable_bg_bar_1")
        get.gameObject:SetActive(false)
        mark.gameObject:SetActive(true)
    end
end

-- 返回
function DdzExerPanel:OnBackClick()
    DdzExerPanel.Close()
end

function DdzExerPanel:getNextAward(winCount)
    local currAwardIndex = 1
    for i,v in ipairs(self.config.award) do
        if v.win_count > winCount then
            return v.win_count - winCount, currAwardIndex
        end
        currAwardIndex = i
    end
    return 0, currAwardIndex
end
