-- 创建时间:2020-08-29
-- Panel:ADMFCJ_JYFLEnterPrefab
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

ADMFCJ_JYFLEnterPrefab = basefunc.class()
local C = ADMFCJ_JYFLEnterPrefab
C.name = "ADMFCJ_JYFLEnterPrefab"

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
    self.lister["by3d_ad_mfcj_query_ad_free_lottery"] = basefunc.handler(self,self.by3d_ad_mfcj_query_ad_free_lottery)
    self.lister["by3d_ad_mfcj_use_ad_free_lottery"] = basefunc.handler(self,self.by3d_ad_mfcj_use_ad_free_lottery)
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

function C:OnDestroy()
	self:MyExit()
end

function C:ctor(parent)
	ExtPanel.ExtMsg(self)
	local parent = parent or GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)

	self.slider = self.HBSlider:GetComponent("Slider")

	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	self.get_img = self.get_btn.transform:GetComponent("Image")
	self.BG_btn.onClick:AddListener(function ()
    	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnGetClick()
	end)
	self.get_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnGetClick()
	end)
	BY3DADMFCJManager.QueryInfoData()
	self:MyRefresh()
end

function C:MyRefresh()
	self.count =  BY3DADMFCJManager.GetNum()
	self.time_num = BY3DADMFCJManager.GetCDTime()
	local b = 5
	self.time_txt.text = string.format("（还可领%d次）", self.count)

	self.slider_txt.text = self.count .. "/" .. b
	self.slider.value = self.count / b

	if self.count > 0 and self.time_num <= 0 then
		self.get_img.sprite = GetTexture("com_btn_5")
	else
		self.get_img.sprite = GetTexture("com_btn_8")
	end
end

function C:OnGetClick()
	BY3DADMFCJPanel.Create()
end
function C:by3d_ad_mfcj_query_ad_free_lottery()
	self:MyRefresh()
end
function C:by3d_ad_mfcj_use_ad_free_lottery()
	self:MyRefresh()
end
