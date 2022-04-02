-- 创建时间:2020-01-06
-- Panel:VowExtGetPanel
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

VowExtGetPanel = basefunc.class()
local C = VowExtGetPanel
C.name = "VowExtGetPanel"

function C.Create(award)
    if AdvertisingManager.IsCloseAD() then
        Event.Brocast("AssetGet",award)
        return
    end

    if SYSQXManager.IsNeedWatchAD() then
        return C.New(award)
    else
        Event.Brocast("AssetGet",award)
    end
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	self:RemoveListener()
    destroy(self.gameObject)
    Event.Brocast("AssetsGetPanelConfirmCallback")
    CommonAwardPanelManager.DelPanel(self)
end

function C:ctor(award)

	ExtPanel.ExtMsg(self)

    self.award_data = award
	local parent = GameObject.Find("Canvas/LayerLv5").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
    CommonAwardPanelManager.AddPanel(self)
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	self.mf_btn.onClick:AddListener(function()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        self:OnMFClick()
    end)
	self.pt_btn.onClick:AddListener(function()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        self:OnPTClick()
		self:MyExit()
    end)
    self.back_btn.onClick:AddListener(function()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        self:MyExit()
    end)
    self.back_btn.gameObject:SetActive(false)
    self:MyRefresh()
    DSM.ADTrigger("vow")
end

function C:MyRefresh()
    dump(self.award_data)
    local aw = AwardManager.GetAssetsList(self.award_data.data)
    dump(aw)
    local data = aw[1]
    self.DescText_txt.text = data.desc
    if data.desc_extra then
        self.DescExtra_txt.text = data.desc_extra
    else
        self.DescExtra_txt.text = ""
    end
    GetTextureExtend(self.AwardIcon_img, data.image, data.is_local_icon)
    if data.type == "shop_gold_sum" then        
        self.NameText_txt.text = data.value  .. ""
        self.NameText_txt.gameObject:SetActive(true)
    end

    -- 所有看广告后的额外鲸币奖励砍半
    local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key="drt_cpl_half_ad_award", is_on_hint = true}, "CheckCondition")
    if a and b then
        self.ew_hint_txt.text = "额外获得750鲸币"
    else
        self.ew_hint_txt.text = "额外获得1500鲸币"
    end
end

function C:OnMFClick()
	AdvertisingManager.RandPlay("vow", function (data)
        if data.result == 0 and data.isVerify then
			Network.SendRequest("xuyuanchi_ext_get_award", nil, "", function (data)
                if data.result ~= 0 then
                    HintPanel.ErrorMsg(data.result)
                end
            end)
        else
            if data.result ~= -999 then
                if data.isVerify then
                    HintPanel.Create(1, "广告观看失败，请重新观看")
                else
                    HintPanel.Create(1, "您的网络不稳定，待网络稳定后请重试")
                end
            end
        end
        self:MyExit()
    end)
end
function C:OnPTClick()
    self:MyExit()
end
