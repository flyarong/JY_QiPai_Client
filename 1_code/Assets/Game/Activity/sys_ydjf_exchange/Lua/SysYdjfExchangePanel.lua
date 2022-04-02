-- 创建时间:2021-04-26
-- Panel:SysYdjfExchangePanel
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

SysYdjfExchangePanel = basefunc.class()
local C = SysYdjfExchangePanel
C.name = "SysYdjfExchangePanel"


local o1 = {x = 1340 , y = 720}
local o2 = {x = 1024 , y = 720}

function C.Create(parent ,type)
	return C.New(parent, type)
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
end

function C:OnDestroy()
	self:MyExit()
end

function C:MyClose()
	self:MyExit()
end

function C:ctor(parent, type)
	ExtPanel.ExtMsg(self)
	local parent = parent or GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	self.type = type
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	self.exchange_btn.onClick:AddListener(function()
		self:OnClickExchangeBtn()
	end)
	self.check_btn.onClick:AddListener(function()
		self:OnClickCheckBtn()
	end)
	self:AdaptTransToPay()
	self:MyRefresh()
end

function C:MyRefresh()

end

--立即兑换，跳转到兑换网页
function C:OnClickExchangeBtn()
	local url = "http://nakehui.cn/cycs/changyouMarket.html?pid=000001&token=00063765&storeId=LL10199"
	UnityEngine.Application.OpenURL(url)
end

--鲸币核销，验证并兑换
function C:OnClickCheckBtn()
	SysYdjfVerifyPanel.Create()
end

function C:AdaptTransToPay()
	if self.type and self.type == "pay" then
		self.content.transform.localPosition = Vector3.New(502, -189, 0)
		self.bg_img.transform.sizeDelta = {x = 1340 , y = 712}
		self.bg_img.sprite = GetTexture("yijhdh_bg02")
	end
end
