-- 创建时间:2020-10-28
-- Panel:EliminateCJHelpPanel
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

EliminateCJHelpPanel = basefunc.class()
local C = EliminateCJHelpPanel
C.name = "EliminateCJHelpPanel"
local line_cfg = EliminateCJModel.xiaoxiaole_line_cfg.base
function C.Create()
	return C.New()
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

function C:ctor()
	ExtPanel.ExtMsg(self)
	local parent = GameObject.Find("Canvas/LayerLv3").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	DOTweenManager.OpenPopupUIAnim(self.transform)
	self:SwitchBtn(1)
end

function C:InitUI()
	self.close_btn.onClick:AddListener(function()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:MyExit()
	end)
	self.jlxx_btn.onClick:AddListener(
		function()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
			self:SwitchBtn(1)
		end
	)
	self.yxfb_btn.onClick:AddListener(
		function()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
			self:SwitchBtn(2)
		end
	)
	self:InitYXFBUI()
	self:MyRefresh()
end

-- 向量减法
local function Vec2DSub(vec1, vec2)
	return {x=vec1.x-vec2.x, y=vec1.y-vec2.y}
end

local function Vec2DLength(vec)
	return math.sqrt(vec.x*vec.x + vec.y*vec.y)
end

function C:InitYXFBUI()
	for i = 1,#line_cfg do
		local temp = {}
		local b = GameObject.Instantiate(self.yxfb_item,self.yxfb_node)
		b.gameObject:SetActive(true)
		LuaHelper.GeneratingVar(b.transform,temp)
		temp.tag_img.sprite = GetTexture("cjxxl_help_"..i)
		temp.point_img.sprite = GetTexture("cjxxl_help_"..i.."_2")
		temp.line_img.sprite = GetTexture("cjxxl_help_"..i.."_1")
		local point_pos = {}
		for j = 1,#line_cfg[i].line do
			local pos = self:GetPointPos(line_cfg[i].line[j])
			local point = GameObject.Instantiate(temp.point_img.gameObject,temp.point_node)
			point.gameObject:SetActive(true)
			point_pos[#point_pos + 1] =  Vector3.New(pos.X,pos.Y)
			point.gameObject.transform.localPosition = point_pos[#point_pos]
		end
		for i = 2,#point_pos do
			local dirVec = Vec2DSub(point_pos[i],point_pos[i - 1])
			local r = math.atan2(dirVec.y, dirVec.x) * 180 / math.pi
			local length = Vec2DLength(dirVec)
			local line = GameObject.Instantiate(temp.line_img.gameObject,temp.line_node)
			line.gameObject:SetActive(true)
			line.transform.sizeDelta = {x = length, y = line.transform.sizeDelta.y}
			line.gameObject.transform.localPosition = Vector2.New((point_pos[i].x + point_pos[i - 1].x)/2,(point_pos[i].y + point_pos[i - 1].y)/2)
			line.transform.rotation = Quaternion.Euler(0, 0, r)
		end
	end
end

function C:GetPointPos(index)
	local space = 53
	local X_Y = EliminateCJItemManager.One2Two(index)
	X_Y = {X = X_Y.X - 3,Y = X_Y.Y - 2}
	return {X = X_Y.X * space,Y = X_Y.Y * space}
end

function C:SwitchBtn(index)
	self.jlxx_panel.gameObject:SetActive(index == 1)
	self.jlxx_mask.gameObject:SetActive(index == 1)
	self.yxfb_mask.gameObject:SetActive(index == 2)
	self.yxfb_panel.gameObject:SetActive(index == 2)
end

function C:MyRefresh()

end
