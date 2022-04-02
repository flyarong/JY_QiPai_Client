-- 创建时间:2019-09-26
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

SYSSQDFSEnterPrefab = basefunc.class()
local C = SYSSQDFSEnterPrefab
C.name = "SYSSQDFSEnterPrefab"

function C.CheckIsShow(cfg)
	if not cfg.is_on_off or cfg.is_on_off == 0 then
		return
	end
	if cfg.startTime >= os.time() or os.time() >= cfg.endTime then 
		return 
	end 
	return true
end

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
	self.lister["xxl_xcfn_common_lottery_base_info"] = basefunc.handler(self, self.on_query_common_lottery_base_info_response)
	self.lister["xxl_xcfn_common_lottery_base_info"] = basefunc.handler(self, self.on_common_lottery_base_info_change)
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

function C:ctor(parent, cfg)
	self.config = cfg

	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()

	self.transform.localPosition = Vector3.zero

	self:InitUI()
	self.data = XXLXCFNManager.GetBaseData()
	self:MyRefresh()
end

function C:InitUI()
	self.enter_btn = self.transform:GetComponent("Button")
	self.enter_btn.onClick:AddListener(function ()
    	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnEnterClick()
	end)

	self:MyRefresh()
end

function C:MyRefresh()
	local at_state = XXLXCFNManager.GetHintState()
	self.LFL.gameObject:SetActive(false)
	if at_state == ACTIVITY_HINT_STATUS_ENUM.AT_Get then
		self.LFL.gameObject:SetActive(true)
	end
end

function C:OnEnterClick()
	Lottery10YuePanelBIG.Create()
end

function C:OnDestroy()
	self:MyExit()
end

function C:on_query_common_lottery_base_info_response(_, data)
	if data.lottery_type  == "19_october_lottery" then
		self.data = data
		self:MyRefresh()
	end
end

function C:on_common_lottery_base_info_change(_,data)
	if data.lottery_type  == "19_october_lottery" then
		self.data = data
		self:MyRefresh()
	end	
end
