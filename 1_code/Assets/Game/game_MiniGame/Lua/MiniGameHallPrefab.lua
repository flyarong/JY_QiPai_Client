-- 创建时间:2019-05-30
-- Panel:MiniGameHallPrefab
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

MiniGameHallPrefab = basefunc.class()
local C = MiniGameHallPrefab
local tag2img = {
	new = "xxc_icon_xy",
	hot = "xxc_icon_hb",
}
local vip2img = {
	[1] = "xxc_imgf_1",
	[3] = "xxc_imgf_3",
}
function C.Create(parent_transform, config, call, panelSelf)
	return C.New(parent_transform, config, call, panelSelf)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
	self.lister = {}
	self.lister["model_vip_upgrade_change_msg"] = basefunc.handler(self, self.on_model_vip_upgrade_change_msg)
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

function C:ctor(parent_transform, config, call, panelSelf)
	ExtPanel.ExtMsg(self)

	self.config = config
	self.call = call
	self.panelSelf = panelSelf
	local str = config.bigpre_name or config.pre_name
	--if not GetPrefab(str) then return end
	local obj = newObject(config.bigpre_name or config.pre_name, parent_transform)
	if not obj then return end

	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
    LuaHelper.GeneratingVar(obj.transform, self)
	self:MakeLister()
	self:AddMsgListener()
	self.HintLock = tran:Find("HintLock")
	self.Button = tran:Find("Button"):GetComponent("Button")
	self.Button.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		if self.config.is_lock and self.config.is_lock == 1 then
			LittleTips.Create("即将开放")
		else
			if self.call then
				self.call(self.panelSelf, self.config)
			end
		end
	end)
	self:InitUI()
	if self["tag_mr"] then
		self["tag_mr"].gameObject:SetActive(config.tag_mr == 1)
	end
	if self.config.tag then
		if gameMgr:getMarketPlatform() == "wqp" then
			if self.config.tag == "hot" then
				if (os.time() - MainModel.FirstLoginTime()) >= 604800 then
					local b = newObject("MiniGameTagPrefab",self.transform)
					b.transform.localPosition = Vector2.New(-153,153)
					b.transform:Find("Image"):GetComponent("Image").sprite = GetTexture(tag2img[self.config.tag])
					b.transform:Find("Image"):GetComponent("Image"):SetNativeSize()
				end
			else
				local b = newObject("MiniGameTagPrefab",self.transform)
				b.transform.localPosition = Vector2.New(-153,153)
				b.transform:Find("Image"):GetComponent("Image").sprite = GetTexture(tag2img[self.config.tag])
				b.transform:Find("Image"):GetComponent("Image"):SetNativeSize()
			end
		else
			if self.config.pre_name == "MiniGameSGXXLPrefab" then
			else
				local b = newObject("MiniGameTagPrefab",self.transform)
				b.transform.localPosition = Vector2.New(-153,153)
				b.transform:Find("Image"):GetComponent("Image").sprite = GetTexture(tag2img[self.config.tag])
				b.transform:Find("Image"):GetComponent("Image"):SetNativeSize()
			end
		end
	end
	if self.config.vip_limit then
		local b = newObject("MiniGameVIPLockPrefab",self.transform)
		b.transform:Find("VIPIMG"):GetComponent("Text").text = self.config.vip_limit
		if VIPManager.get_vip_level() >= self.config.vip_limit then
			b.gameObject:SetActive(false)
		end
		self.vip_lock_obj = b
	end
	if (self.config.show_limit and self:CheckShowPermission(self.config.show_limit)) or not self.config.show_limit then
		self.gameObject:SetActive(true)
	else
		self.gameObject:SetActive(false)
	end
end

function C:InitUI()
	if self.config.is_lock and self.config.is_lock == 1 then
		self.HintLock.gameObject:SetActive(true)
	else
		self.HintLock.gameObject:SetActive(false)
	end
end

function C:SetPosition(pos)
	self.transform.localPosition = pos
end

function C:SetScale(v)
	self.transform.localScale = v
end

function C:MyRefresh()
end

function C:on_model_vip_upgrade_change_msg()
	if IsEquals(self.vip_lock_obj) then
		if VIPManager.get_vip_level() >= self.config.vip_limit then
			self.vip_lock_obj.gameObject:SetActive(false)
		end
	end
end

function C:CheckShowPermission(_permission_key)
    if _permission_key then
        local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key=_permission_key, is_on_hint = true}, "CheckCondition")
        if a and not b then
            return false
        end
    end
    return true
end


--[[
	GetTexture("xxc_icon_xy")
	GetTexture("xxc_icon_hb")
	GetTexture("xxc_imgf_1")
	GetTexture("xxc_imgf_3")
--]]