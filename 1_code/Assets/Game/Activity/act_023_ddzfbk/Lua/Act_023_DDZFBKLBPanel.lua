-- 创建时间:2020-07-30
-- Panel:Act_023_DDZFBKLBPanel
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

Act_023_DDZFBKLBPanel = basefunc.class()
local C = Act_023_DDZFBKLBPanel
C.name = "Act_023_DDZFBKLBPanel"
local M = Act_023_DDZFBKManager

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
    self.lister["AssetChange"] = basefunc.handler(self, self.OnAssetChange)
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
	local parent = GameObject.Find("Canvas/LayerLv4").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
    self.close_btn.onClick:AddListener(
        function ()
            ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
            self.bg.gameObject:SetActive(false)
            local timer
            timer = Timer.New(function ()
                if IsEquals(self.gameObject) then
                    self.transform.localPosition = self:ExtLerp({x = self.transform.localPosition.x,y = self.transform.localPosition.y},{x = 712,y = 96},0.1)
                    self.transform.localScale = self:ExtLerp({x = self.transform.localScale.x,y = self.transform.localScale.y},{x = 0.059,y = 0.059},0.1)
                end
                if self.transform.localScale.x <= 0.06 then
                    timer:Stop()
                    self:MyExit()
                end
            end,0.02,-1)
            timer:Start()
        end
    )
    self.buy_btn.onClick:AddListener(
        function ()
            ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
            self:BuyShop()
        end
    )
	self:MyRefresh()
end

function C:MyRefresh()
 
end

function C:BuyShop()
    local shopid = M.shopid
    local gb =  MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, shopid)
    if not gb then return end
	local price = gb.price
	if  GameGlobalOnOff.PGPay and gameRuntimePlatform == "Ios" then
		ServiceGzhPrefab.Create({desc="请前往公众号获取"})
	else
		PayTypePopPrefab.Create(shopid, "￥" .. (price / 100))
	end
end

function C:SetText(string1,string2)
    self._1_txt.text = string1
    self._2_txt.text = string2
end

function C:OnAssetChange(data)
	if data and data.change_type == "freestyle_fanbeika_award" then
		self:MyExit()
	end
end


function C:ExtLerp(v1,v2,f)
    local data = {}
    data.x = Mathf.Lerp(v1.x,v2.x,f)
    data.y = Mathf.Lerp(v1.y,v2.y,f)
    return data
end