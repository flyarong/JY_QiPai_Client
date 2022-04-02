-- 创建时间:2019-11-19
-- Panel:ComHeadPrefab
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

ComHeadPrefab = basefunc.class()
local C = ComHeadPrefab
C.name = "ComHeadPrefab"

function C.Create(parent, player, parm)
	return C.New(parent, player, parm)
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

function C:ctor(parent, player, parm)
	self.player = player
	self.parm = parm

	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	self.transform.localPosition = Vector3.zero
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	self:MyRefresh()
end

function C:MyRefresh()
	--刷新头像
	if self.player then
		self.gameObject:SetActive(true)
		URLImageManager.UpdateHeadImage(self.player.head_link, self.head_img)
		if _G["VIPManager"] then
			VIPManager.set_vip_text(self.head_vip_txt, self.player.vip_level)
		else
			self.head_vip_txt.text = ""
			self.head_frame_img.sprite = GetTexture("hall_bg_head")
		end
	else
		self.gameObject:SetActive(false)
	end
end
function C:SetData(player)
	self.player = player
	self:MyRefresh()
end
function C:SetActive(b)
	self.gameObject:SetActive(b)
end
