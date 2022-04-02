-- 创建时间:2019-09-25
-- Panel:VIPEnterPrefab
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

VIPEnterPrefab = basefunc.class()
local C = VIPEnterPrefab
C.name = "VIPEnterPrefab"

function C.Create(parent, cfg)
	return C.New(parent, cfg)
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
	RedHintManager.RemoveRed(RedHintManager.RedHintKey.RHK_VIP2, self.vip2_red.gameObject)
	
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:ctor(parent, cfg)
	self.config = cfg

	local obj = newObject("vip2_btn", parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()

	self.transform.localPosition = Vector3.zero

	self:InitUI()
end

function C:InitUI()
	self.enter_btn = self.transform:GetComponent("Button")
	self.enter_btn.onClick:AddListener(function ()
    	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnEnterClick()
	end)
	RedHintManager.AddRed(RedHintManager.RedHintKey.RHK_VIP2, self.vip2_red.gameObject)
	self:MyRefresh()
	HandleLoadChannelLua(C.name,self)
end

function C:MyRefresh()
	local data = GameTaskModel.GetTaskDataByID(21314)
	if data and PlayerPrefs.GetInt(MainModel.UserInfo.user_id.."vip2enter",0) == 0 then
		self.parm = {goto_ui = "vipzzlb"}
		self.vip2_red.gameObject:SetActive(true)
	end
	if VIPManager.get_vip_level() == 1 and os.date("%w", os.time()) == "0" and PlayerPrefs.GetInt(MainModel.UserInfo.user_id.."vip_enter_notice",0) == 0 then
		self.vipnotice.gameObject:SetActive(true)
	else
		self.vipnotice.gameObject:SetActive(false)
	end
end

function C:OnEnterClick()
	if VIPManager.get_vip_level() == 1 and os.date("%w", os.time()) == "0" then
		VIP1NoticetPanel.Create()
	else
		VipShowTaskPanel2.Create(nil,self.parm)
		self.parm = nil
	end
	PlayerPrefs.SetInt(MainModel.UserInfo.user_id.."vip2enter",1)
	PlayerPrefs.GetInt(MainModel.UserInfo.user_id.."vip_enter_notice",1)
	self.vipnotice.gameObject:SetActive(false)
end

function C:OnDestroy()
	self:MyExit()
end
