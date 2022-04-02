-- 创建时间:2020-10-19
-- Panel:Act_036_YYSSYPanel
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

Act_036_YYSSYPanel = basefunc.class()
local C = Act_036_YYSSYPanel
C.name = "Act_036_YYSSYPanel"
local M = Act_036_YYSSYManager
function C.Create(parent)
	return C.New(parent)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
	self.lister = {}
	self.lister["activity_exchange_response"] = basefunc.handler(self,self.on_activity_exchange_response)
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

function C:ctor(parent)
	ExtPanel.ExtMsg(self)
	local parent = parent or GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:OnDestroy()
	self:MyExit()
end

function C:InitUI()
	self.get_btn.onClick:AddListener(
		function()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
			if MainModel.UserInfo.jing_bi >= 5000 then 
				Network.SendRequest("activity_exchange",{ type = 16 , id = 1 })
			else
				LittleTips.Create("您的鲸币不足")
			end
		end
	)
	self:MyRefresh()
end

function C:MyRefresh()
	local x = PlayerPrefs.GetInt(M.key..MainModel.UserInfo.user_id.."是否已经领取",0)
	self.get_btn.gameObject:SetActive(x == 0)
	self.mask.gameObject:SetActive(x == 1)
end

--
function C:on_activity_exchange_response(_,data)
	dump(data,"请求数据")
	if data.result == 0 then
		PlayerPrefs.SetInt(M.key..MainModel.UserInfo.user_id.."是否已经领取",1)
		self:MyRefresh()
	else
		if data.result == 4704 then
			PlayerPrefs.SetInt(M.key..MainModel.UserInfo.user_id.."是否已经领取",1)
			LittleTips.Create("您已经领过奖励了")
			self:MyRefresh()
		end
	end
end