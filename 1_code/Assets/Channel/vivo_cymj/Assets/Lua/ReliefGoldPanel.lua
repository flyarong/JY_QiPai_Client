-- 创建时间:2019-11-25
-- 转运金 ReliefGoldPanel
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

ReliefGoldPanel = basefunc.class()
local C = ReliefGoldPanel
C.name = "ReliefGoldPanel"
local instance
function C.Create(call)
	if instance then
		instance:MyExit()
	end
	return C.New(call)
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
	if self.call then
		self.call()
	end
	instance = nil
end

function C:ctor(call)
	instance = self
	ExtPanel.ExtMsg(self)

	self.call = call
	self.ui_ceng = 5 -- ui层级
	local parent = GameObject.Find("Canvas/LayerLv5").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	local canvas = self.center.transform:GetComponent("Canvas")
	canvas.sortingOrder = self.ui_ceng + 2

	change_renderer(self.lingqu_GC, self.ui_ceng + 2, true)
	change_renderer(self.lingqu_ZT, self.ui_ceng + 2)
	local shareCount = MainModel.UserInfo.shareCount or 0 
	self.tips_txt.text = shareCount == 0 and "今日已领完" or  "还可领"..shareCount.."次"
	self.ast_data = {{asset_type = "jing_bi", value = 3000}}
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	self.confirm_txt.text = "领取"
	self.confirm_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnClick()
		self:MyExit()
	end)
	self.back_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:MyExit()
	end)
	self:MyRefresh()
end

function C:MyRefresh()
	self:CloseAwardCell()
	self.data = AwardManager.GetAssetsList(self.ast_data)
	for i = 1, #self.data do
		local v = self.data[i]
		self.AwardCellList[#self.AwardCellList + 1] = self:CreateItem(v)
	end
    Event.Brocast("global_sysqx_uichange_msg", {key="zyj", panelSelf=self})
end
function C:CloseAwardCell()
	if self.AwardCellList then
		for i,v in ipairs(self.AwardCellList) do
			destroy(v.gameObject)
		end
	end
	self.AwardCellList = {}
end
function C:CreateItem(data)
	local obj = GameObject.Instantiate(self.AwardPrefab)
	obj.transform:SetParent(self.AwardNode)
	obj.transform.localScale = Vector3.one
	local obj_t = {}
	LuaHelper.GeneratingVar(obj.transform,obj_t)
	obj_t.DescText_txt.text = data.desc
	if data.desc_extra then
		obj_t.DescExtra_txt.text = data.desc_extra
	else
		obj_t.DescExtra_txt.text = ""
	end
	GetTextureExtend(obj_t.AwardIcon_img, data.image, data.is_local_icon)
	if data.type == "shop_gold_sum" then		
		obj_t.NameText_txt.text = data.value
		obj_t.NameText_txt.gameObject:SetActive(true)
	end
	obj.gameObject:SetActive(true)
	return obj
end

function C:OnClick()
    Network.SendRequest("broke_subsidy", nil, "请求数据")
end
