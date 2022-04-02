-- 创建时间:2020-12-21
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

Act_045_CQGPanel = basefunc.class()
local C = Act_045_CQGPanel
C.name = "Act_045_CQGPanel"
local M = Act_045_CQGManager

local instance

function C.Create(parent)
	if not instance then
		instance = C.New(parent)
	end
	return instance
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
	self.lister = {}
	self.lister["query_deposit_data_response"] = basefunc.handler(self, self.on_query_deposit_data_response)
	self.lister["get_deposit_award_response"] = basefunc.handler(self, self.on_get_deposit_award_response)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	self:RemoveListener()
	instance = nil
	destroy(self.gameObject)
end

function C:ctor(parent)
	ExtPanel.ExtMsg(self)
	local parent = parent or  GameObject.Find("Canvas/LayerLv5").transform
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
	self.unlock_get_btn.onClick:AddListener(function ()
		self:UnLoackGet()
	end)

	self.back_btn.onClick:AddListener(function ()
		self:MyExit()
	end)

	self:RefreshCQG(0)
	Act_045_CQGManager.QueryCqgData()
	self:MyRefresh()
end

function C:UnLoackGet()

    if VIPManager.get_vip_level() ~= 0 then
        Network.SendRequest("get_deposit_award")
    else
        -- if GameGlobalOnOff.IOSTS then
        --     HintPanel.Create(1, "敬请期待")
        --     return
        -- end
		self:ExchangeLayerDown()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        GameManager.GotoUI({ gotoui = "hall_activity", goto_scene_parm = "panel" })
    end
end

function C:ExchangeLayerDown()
	local lv4 = GameObject.Find("Canvas/LayerLv4").transform
	self.transform:SetParent(lv4)
end

function C:MyRefresh()
end

--获取存钱罐数据
function C:on_query_deposit_data_response(_,data)
	--dump(data,"<color=white>+++++on_query_deposit_data_response+++++</color>")
	if data.result == 0 then
		self:RefreshCQG(data.value)
	end
end

function C:on_get_deposit_award_response(_,data)
	if data.result == 0 then
		LittleTips.Create("领取成功")
		M.ReSetDepositValue()
		self:MyExit()
		Event.Brocast("JYFL_Refresh")
		JYFLManager.InitRedHint()
	end
end

function C:RefreshCQG(value)
	self.cqg_txt.text = StringHelper.ToCash(value)
	if value == 0 then
		self.unlock_get_gray.gameObject:SetActive(true)
	else
		self.unlock_get_gray.gameObject:SetActive(false)
	end
end