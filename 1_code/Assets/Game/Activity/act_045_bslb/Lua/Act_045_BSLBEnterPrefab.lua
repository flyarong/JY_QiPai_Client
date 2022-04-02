-- 创建时间:2020-10-28
-- Panel:Act_045_BSLBEnterPrefab
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
 -- 取消按钮音效
 -- ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
 -- 确认按钮音效
 -- ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
 --]]

local basefunc = require "Game/Common/basefunc"

Act_045_BSLBEnterPrefab = basefunc.class()
local C = Act_045_BSLBEnterPrefab
C.name = "Act_045_BSLBEnterPrefab"
local M = Act_045_BSLBManager

function C.Create(parent)
	return C.New(parent)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["AssetChange"] = basefunc.handler(self,self.RefreshState)
	self.lister["model_task_change_msg"] = basefunc.handler(self,self.RefreshState)
	self.lister["shop_info_get"] = basefunc.handler(self,self.RefreshState)
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
end

function C:ctor(parent)
    ExtPanel.ExtMsg(self)
    local parent = parent or GameObject.Find("Canvas/GUIRoot").transform
    local obj = newObject("Act_045_BSLBEnterPrefab", parent)
    local tran = obj.transform
    self.transform = tran
    self.gameObject = obj
    LuaHelper.GeneratingVar(self.transform, self)
    self:MakeLister()
    self:AddMsgListener()
    self:InitUI()
    self.huxi = CommonHuxiAnim.Go(self.gameObject)
    self:RefreshState()
end

function C:InitUI()
	self.transform:GetComponent("Button").onClick:AddListener(function()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        PlayerPrefs.SetString(M.key .. MainModel.UserInfo.user_id, os.date("%Y%m%d", os.time()))
        self:OnEnterClick()
        self:MyRefresh()
    end)
    self:MyRefresh()
end

function C:MyRefresh()
    if not IsEquals(self.gameObject) then return end
    if M.GetHintState({ gotoui = M.key }) == ACTIVITY_HINT_STATUS_ENUM.AT_Get then
        self.LFL.gameObject:SetActive(true)
    else
        self.LFL.gameObject:SetActive(false)
        if PlayerPrefs.GetString(M.key .. MainModel.UserInfo.user_id, 0) == os.date("%Y%m%d", os.time()) then
            self.Red.gameObject:SetActive(false)
        else
            self.Red.gameObject:SetActive(true)
        end
    end
end

function C:OnEnterClick()
    local b = GameComGiftT4Panel.Create(nil, nil, M.config[M.level], nil, "Act_045_BSLBPanel")

    for i = 1, 3 do
        local ui = {}
        LuaHelper.GeneratingVar(b["gift_rect" .. i], ui)
        PointerEventListener.Get(ui.icon3_img.gameObject).onDown = function()
            local bx_show = "购买任意1个礼包，上榜倍数增加5%；\n购买任意2个礼包，上榜倍数增加10%，\n购买任意3个礼包，上榜倍数增加20%"
			LTTipsPrefab.Show2(ui.icon3_img.gameObject.transform,"倍数加成:",bx_show)
        end
        PointerEventListener.Get(ui.icon3_img.gameObject).onUp = function()
            LTTipsPrefab.Hide()
        end
    end
    --Act_018_MFCDJPanel.Create()
end

function C:on_global_hint_state_change_msg(parm)
    if parm.gotoui == M.key then
        self:MyRefresh()
    end
end



function C:RefreshState()
	if not IsEquals(self.gameObject) then
		return 
	end

	local num = M.GetBeiShu()
	if num and num == 3 then
		self.btn_node.gameObject:SetActive(false)
		self.huxi.Stop()
	else
		self.btn_node.gameObject:SetActive(true)
		self.huxi.Start()
	end
end

