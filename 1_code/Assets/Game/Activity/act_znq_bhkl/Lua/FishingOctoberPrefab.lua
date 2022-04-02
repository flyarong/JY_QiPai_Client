-- 创建时间:2019-05-29
--[[ *      ┌─┐       ┌─┐
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

FishingOctoberPrefab = basefunc.class()
local C = FishingOctoberPrefab
C.name = "FishingOctoberPrefab"

function C.Create(parent_transform, config, call, panelSelf)
    return C.New(parent_transform, config, call, panelSelf)
end

function C:AddMsgListener()
    for proto_name, func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
end


function C:RemoveListener()
    for proto_name, func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
    self:RemoveListener()
end

function C:ctor(parent_transform, config, call, panelSelf)
    self.config = config
    self.call = call
    self.panelSelf = panelSelf
    local obj = newObject(C.name, parent_transform)
    local tran = obj.transform
    self.transform = tran
    self.gameObject = obj

    self:MakeLister()
    self:AddMsgListener()
    LuaHelper.GeneratingVar(obj.transform, self)

    self.dh_yes_btn.onClick:AddListener(function()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
        self:OnClick()
    end)
    self.sw_not_btn.onClick:AddListener(function()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
        self:OnSWClick()
    end)
    self:InitUI()
end
function C:OnDestroy()
    self:MyExit()
    destroy(self.gameObject)
end
function C:InitUI()
    self.award_img.sprite = GetTexture(self.config.award_icon)
    self.award_img:SetNativeSize()
    self.award_txt.text = self.config.award_name
    self.zz_txt.text = self.config.zz_num.."积分兑换"
end

function C:MyRefresh()
end

function C:OnClick()
    local zz = FishOctoberPanel.Info_Score
    if self.config.zz_num > zz then
        LittleTips.Create("积分不足")
    else
        if self.call then
            self.call(self.panelSelf, self.config.id)
        end
    end
end

function C:OnSWClick()
    if self.config.is_sw == 1 then
        RealAwardPanel.Create({ text = self.config.award_name, image = self.config.award_icon })
    end 
end
