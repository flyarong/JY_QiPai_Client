-- 创建时间:2019-05-30
-- Panel:HintCopyPanel
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

HintCopyPanel = basefunc.class()
local C = HintCopyPanel
C.name = "HintCopyPanel"

function C.Create(parm)
	return C.New(parm)
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

function C:ctor(parm)

	ExtPanel.ExtMsg(self)

	self.parm = parm
    local tf = GameObject.Find("Canvas/LayerLv5")
    local parent = tf.transform

	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj

	self:MakeLister()
	self:AddMsgListener()
    LuaHelper.GeneratingVar(obj.transform, self)
	self.close_btn.onClick:AddListener(function ()
		self:OnCloseClick()
	end)
	self.copy_btn.onClick:AddListener(function ()
	   	self:OnCopyClick()
	end)
	self.copyqq_btn.onClick:AddListener(function ()
	   	self:OnCopyClick()
	end)

	if self.parm.isQQ then
		self.copy_value = "4008882620"
		self.desc = "联系客服QQ%s领取奖励"
		self.copy_btn.gameObject:SetActive(false)
		self.copyqq_btn.gameObject:SetActive(true)
	else
		self.copy_value = "JYDDZ05"
		self.desc = "联系微信客服%s领取奖励"
		self.copy_btn.gameObject:SetActive(true)
		self.copyqq_btn.gameObject:SetActive(false)
	end
    
	self:InitUI()
end

function C:InitUI()
	if self.parm then
		self.copy_value = self.parm.copy_value or self.copy_value
		self.desc =  self.parm.desc or self.desc
		if self.parm.title then--是否修改title
		   self.transform:Find("ImgPopupBG/ImgTitle/Image").gameObject:SetActive(false)
		   self.transform:Find("ImgPopupBG/ImgTitle/Text").gameObject:SetActive(true)
		   self.transform:Find("ImgPopupBG/ImgTitle/Text"):GetComponent("Text").text=self.parm.title
		end
	end
	self.hint_info_txt.text = string.format(self.desc, self.copy_value)
end

function C:MyRefresh()
end

function C:OnCloseClick()
	self:MyExit()
end
function C:OnCopyClick()
	print("<color=red>复制内容"..self.copy_value.."</color>")
	
	if self.parm.isQQ then
		LittleTips.Create("已复制QQ号请前往QQ进行添加")
	else
		if self.parm and self.parm.gowx then--是否是直接跳转微信
		   if   self.parm.gowx==true then 
				Application.OpenURL("weixin://");
				print("跳转到微信")
		   end 
		end
		LittleTips.Create("已复制微信号请前往微信进行添加")
	end

	UniClipboard.SetText(self.copy_value)
	self:MyExit()
end
