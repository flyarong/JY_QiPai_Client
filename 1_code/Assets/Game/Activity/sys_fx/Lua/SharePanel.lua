
local basefunc = require "Game.Common.basefunc"
SharePanel = basefunc.class()
local M = SharePanel
M.name = "SharePanel"

local lister
function M:MakeLister()
	lister={}
	lister["query_everyday_shared_award_response"] = basefunc.handler(self, self.query_everyday_shared_award_response)
end

function M:AddLister()
    for proto_name,func in pairs(lister or {}) do
        Event.AddListener(proto_name, func)
    end
end

function M:RemoveLister()
    if lister and next(lister) then
		for msg,cbk in pairs(lister) do
			Event.RemoveListener(msg, cbk)
		end	
	end
    lister=nil
end

function M.Create(share_cfg,share_info)
    return M.New(share_cfg,share_info)
end

function M:ctor(share_cfg, share_info)
    ExtPanel.ExtMsg(self)
    self.share_cfg = share_cfg
    self.share_info = share_info
    self.parent = GameObject.Find("Canvas/LayerLv5")
    self.gameObject = newObject(M.name, self.parent.transform)
    self.transform = self.gameObject.transform
    LuaHelper.GeneratingVar(self.gameObject.transform,  self)
    self:InitUI()
    self:MakeLister()
    self:AddLister()
    DOTweenManager.OpenPopupUIAnim(self.transform)
end

function M:InitUI()
    self.wx_btn.onClick:AddListener(function ()
        self:Share(false)
    end)

    self.pyq_btn.onClick:AddListener(function ()
        self:Share(true)
    end)
    
    self.close_btn.onClick:AddListener(function ()
        self:OnBackClick()
    end)

    if self.share_info then
        self.share_info_txt = self.share_info
    else
        self.share_info_txt.text = "<color=#9D5514FF>邀请好友兑换2元福卡，您可得<color=#FF1E00><size=50> 3元/人奖励</size></color></color>"
    end

    local share_source = self.share_cfg.share_source
    if share_source == "hallfx_" then
        ShareModel.ReqQueryEverydaySharedAward(ShareModel.EverydaySharedAwardType.shared_timeline)
        ShareModel.ReqQueryEverydaySharedAward(ShareModel.EverydaySharedAwardType.shared_friend)
    end
end

function M:MyExit()
    self:RemoveLister()
    destroy(self.gameObject)
    self.wx_btn.onClick:RemoveAllListeners()
    self.pyq_btn.onClick:RemoveAllListeners()
    self.close_btn.onClick:RemoveAllListeners()
end

function M:OnBackClick()
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    self:MyExit()
end

function M:Share(isCircleOfFriends)
    self.share_cfg.isCircleOfFriends = isCircleOfFriends
    GameManager.GotoUI({gotoui = "sys_fx",goto_scene_parm = "image",share_cfg = self.share_cfg})
    self:MyExit()
end

function M:query_everyday_shared_award_response(data)
    if data.type == ShareModel.EverydaySharedAwardType.shared_timeline then
        if IsEquals(self.sharepyq_hint) then
            if data.status and data.status > 0 then
                self.sharepyq_hint.gameObject:SetActive(true)
            else
                self.sharepyq_hint.gameObject:SetActive(false)
            end           
        end
    elseif data.type == ShareModel.EverydaySharedAwardType.shared_friend then
        if IsEquals(self.sharehy_hint) then
            if data.status and data.status > 0 then
                self.sharehy_hint.gameObject:SetActive(true)
            else
                self.sharehy_hint.gameObject:SetActive(false)
            end
        end
    end
end