-- 创建时间:2019-11-27
-- Panel:VIPShowWealPanel
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

VIPShowWealPanel = basefunc.class()
local C = VIPShowWealPanel
C.name = "VIPShowWealPanel"

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
	if self.seq then
		self.seq:Kill()
		self.seq = nil
	end
	self:RemoveListener()
	destroy(self.gameObject)

	 
end

function C:ctor()

	ExtPanel.ExtMsg(self)

	local parent = GameObject.Find("Canvas/LayerLv5").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self.anim = self.center:GetComponent("Animator")
	self:InitUI()
end

function C:InitUI()
	self.back_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:MyExit()
	end)
	self.vip_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		PayPanel.Create(GOODS_TYPE.jing_bi, "normal")
		DSM.PushAct({info = {vip = "vip_up"}})
		self:MyExit()
	end)
	for i = 1, 7 do
		local obj = self["tips" .. i .. "_btn"]
		local a = i
        PointerEventListener.Get(obj.gameObject).onDown = function ()
        	self:OnDown(a)
        end
        PointerEventListener.Get(obj.gameObject).onUp = basefunc.handler(self, self.OnUp)
	end
	self.tips_cfg = {
		"Vip专属商城，更多福利可兑换",
		"每日高额救济金，每次最高领取2万鲸币",
		"Vip专属超级转盘，福卡大奖摇起来，必中奖！",
		"携带福卡的上限提升",
		"畅玩所有游戏场次",
		"每场千元赛最多可免费复活3次",
		"免费报名明星杯",
		}

	self["tips8_btn"].onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		GameManager.GotoUI({gotoui="vip", goto_scene_parm="info"})
		self:MyExit()
	end)
	self:MyRefresh()
end

function C:MyRefresh()
    self.seq = DoTweenSequence.Create()
    self.seq:AppendInterval(2)
    self.seq:OnKill(function ()
    	if IsEquals(self.gameObject) then
			self.anim:Play("VIPShowWealPanel_xunhuan", -1, 0)
    	end
    end)

	self.data = VIPManager.get_vip_data()
	if not self.data then return end
    self.cfg = VIPManager.GetVIPCfgByType(VIP_CONFIG_TYPE.dangci)
    local now_process = self.data.now_charge_sum / 100
    local need_process = self.cfg[self.data.vip_level + 1].total

    self.cz_txt.text = "" .. (need_process - now_process)
end

function C:OnDown(i)
	if self.tips_cfg[i] then
	    GameTipsPrefab.ShowDesc(self.tips_cfg[i], UnityEngine.Input.mousePosition)
	end
end
function C:OnUp()
    GameTipsPrefab.Hide()
end
