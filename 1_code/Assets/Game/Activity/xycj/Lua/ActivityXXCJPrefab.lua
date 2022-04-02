-- 创建时间:2019-06-04
-- Panel:ActivityXXCJPrefab
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

ActivityXXCJPrefab = basefunc.class()
local C = ActivityXXCJPrefab
C.name = "ActivityXXCJPrefab"

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
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	self:RemoveListener()
	destroy(self.transform.gameObject)
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
    self.zoumadeng = newObject("choujiang_zoumadeng_jin_prefab", tran)
    self.zoumadeng.gameObject:SetActive(false)
    self.zoumadeng_anim = self.zoumadeng.transform:GetComponent("Animator")
    self.bg1_img = self.bg1:GetComponent("Image")
    self.bg2_img = self.bg2:GetComponent("Image")
	self:InitUI()
end

function C:InitUI()
	if self.panelSelf.type == 2 then
		self.bg1_img.sprite = GetTexture("hbdzp_bg_vip1")
		self.bg2_img.sprite = GetTexture("hbdzp_bg_vip2")
		self.award_db_img.sprite = GetTexture("hbdzp_bg_vip3")
	else
		self.bg1_img.sprite = GetTexture("hbdzp_bg_hb1")
		self.bg2_img.sprite = GetTexture("hbdzp_bg_hb2")
		self.award_db_img.sprite = GetTexture("hbdzp_bg_hb3_activity_xycj")
	end
	if self.config.id % 2 == 0 then
		self.bg1.gameObject:SetActive(false)
		self.bg2.gameObject:SetActive(true)
	else
		self.bg1.gameObject:SetActive(true)
		self.bg2.gameObject:SetActive(false)
	end
	self.icon_img.sprite = GetTexture(self.config.icon)
	local scale = self.config.scale or 1
	self.icon_img.transform.localScale = Vector3.New(scale * 0.7, scale * 0.7, scale * 0.7)
	self.award_txt.text = self.config.desc
end

function C:MyRefresh()
end
function C:OnDestroy()
	self:MyExit()
	destroy(self.gameObject)
end
function C:SetPos(pos)
	self.transform.localPosition = pos
end
function C:RunFX()
	self.zoumadeng.gameObject:SetActive(false)
	self.zoumadeng.gameObject:SetActive(true)
end
function C:PlayXZ()
	self.zoumadeng_anim:Play("choujiang_zoumadeng_xuanzhong", -1, 0)
end
function C:RunEnd()
	self.zoumadeng.gameObject:SetActive(false)
end


