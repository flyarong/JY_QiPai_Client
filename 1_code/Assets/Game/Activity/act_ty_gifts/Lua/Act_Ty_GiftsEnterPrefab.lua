-- 创建时间:2020-12-28
-- Panel:Template_NAME
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

Act_Ty_GiftsEnterPrefab = basefunc.class()
local C = Act_Ty_GiftsEnterPrefab
C.name = "Act_Ty_GiftsEnterPrefab"
local  M = Act_Ty_GiftsManager

function C.Create(parent,gift_key)
	return C.New(parent,gift_key)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
	self.lister = {}
	self.lister["ExitScene"] = basefunc.handler(self, self.MyExit)
	self.lister["AssetChange"] = basefunc.handler(self,self.RefreshState)
	self.lister["model_task_change_msg"] = basefunc.handler(self,self.RefreshState)
	self.lister["shop_info_get"] = basefunc.handler(self,self.RefreshState)
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

function C:ctor(parent,gift_key)
	ExtPanel.ExtMsg(self)
	local parent = parent or GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	self.gift_key = gift_key
	--self.cfg = M.GetGiftCfg(self.gift_key)
	self.style_path = M.GetGiftStyle(self.gift_key)
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	-- self.transform:GetComponent("Button").onClick:AddListener(function()
    --     ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    --     self:OnEnterClick()
    --     self:MyRefresh()
    -- end)
	self.gift_btn.onClick:AddListener(function()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        self:OnEnterClick()
        self:MyRefresh()
    end)

	-- if self.cfg.enter_icon then
	-- 	self.enter_img.sprite = GetTexture(self.cfg.enter_icon)
	-- end
	SetTextureExtend(self.icon_img,self.style_path.."_".."icon_1")
	SetTextureExtend(self.txt_img,self.style_path.."_".."imgf_1")
	self.txt_img:SetNativeSize()
	self.txtRectTrans = self.txt_img:GetComponent("RectTransform")
	local w = self.txtRectTrans.rect.width
	local h = self.txtRectTrans.rect.height
	local nW = 33.5 * ( w / h )
	self.txtRectTrans.sizeDelta = {x = nW, y = 33.5}
	self.huxi = CommonHuxiAnim.Go(self.gameObject,nil,1.1,1.3)
	self:MyRefresh()
end

function C:MyRefresh()
    self:RefreshState()
end

function C:OnEnterClick()
	Act_Ty_GiftsPanel.Create(nil,self.gift_key)
end


function C:RefreshState()

	if not IsEquals(self.gameObject) then
		return 
	end

	local num = M.GetBuyGiftsNum(self.gift_key)
	if num and num == 3 then
		self.btn_node.gameObject:SetActive(false)
		self.huxi.Stop()
	else
		self.btn_node.gameObject:SetActive(true)
		self.huxi.Start()
	end
end