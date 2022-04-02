-- 创建时间:2019-11-19
-- Panel:LHDCardPrefab
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

LHDCardPrefab = basefunc.class()
local C = LHDCardPrefab
C.name = "LHDCardPrefab"

function C.Create(parent, parm)
	return C.New(parent, parm)
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
	self:StopFPAnim()
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:ctor(parent, parm)
	self.parm = parm
	local obj
	if LHDManager.is_use_aq_style then
		obj = newObject("LHDCardPrefabAQ", parent)
	else
		obj = newObject("LHDCardPrefab", parent)
	end

	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	self.transform.localScale = Vector3.one
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	self:MyRefresh()
end
function C:OnDestroy()
	self:MyExit()
end
function C:MyRefresh()
	if LHDManager.is_use_aq_style then
		self:RefreshStyle2()
	else
		self:RefreshStyle1()
	end
end

-- 扑克牌
function C:RefreshStyle1()
	if self.parm and self.parm > 0 then
		self.card_img.gameObject:SetActive(true)
		self.bg_img.gameObject:SetActive(false)
		local dd = lhd_fun_lib.get_pai_info(self.parm)
		self.type_img.sprite = GetTexture(dd.hsIcon)
		self.num_img.sprite = GetTexture(dd.numIcon)
		self.type_big_img.sprite = GetTexture(dd.hsIcon)
	else
		self.card_img.gameObject:SetActive(false)
		self.bg_img.gameObject:SetActive(true)
	end
end
function C:RefreshStyle2()
	local hs_list = {"t", "m", "y", "j"}
	if self.parm and self.parm > 0 then
		self.card_img.gameObject:SetActive(true)
		self.bg_img.gameObject:SetActive(false)
		local hs = (self.parm - 1) % 4 + 1
		local ds = math.floor( (self.parm + 3) / 4)
		self.card_img.sprite = GetTexture("dld_p_tdk_" .. hs_list[hs] .. "dk")
		self.num_img.sprite = GetTexture("dld_p_tdk_" .. hs_list[hs] .. "_" .. ds)
		self.card_img:SetNativeSize()
		self.num_img:SetNativeSize()
	else
		self.card_img.gameObject:SetActive(false)
		self.bg_img.gameObject:SetActive(true)
	end
end

function C:SetActive(b)
	self.center.gameObject:SetActive(b)
end
function C:SetData(parm)
	self.parm = parm
	self:MyRefresh()
end
function C:GetCardPos()
	return self.center.position
end
function C:SetAPTag(b)
	self.tag_ap_img.gameObject:SetActive(b)
end
-- 翻牌动画
function C:RunFPAnim(pai)
	if self.parm ~= pai then
		self:StopFPAnim()
		self.seq = DoTweenSequence.Create()
		self.seq:Append(self.center.transform:DOLocalRotate(Vector3.New(0, 90.0, 0), 0.2, DG.Tweening.RotateMode.FastBeyond360))
		self.seq:AppendCallback(function ()
			self.parm = pai
			self:MyRefresh()
		end)
		self.seq:Append(self.center.transform:DOLocalRotate(Vector3.New(0, 0, 0), 0.2, DG.Tweening.RotateMode.FastBeyond360))
		self.seq:AppendInterval(0.4)
	end
end
function C:StopFPAnim()
	if self.seq then
		self.seq:Kill()
	end
	self.seq = nil
end
