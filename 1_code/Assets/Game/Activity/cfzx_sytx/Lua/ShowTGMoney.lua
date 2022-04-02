-- 创建时间:2019-06-26
-- Panel:New Lua
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

ShowTGMoney = basefunc.class()
local C = ShowTGMoney
C.name = "ShowTGMoney"
-- 当前时间
-- 上次下线时间
function C.Create(parent,backcall)
	if not(MainModel.UserInfo.last_logout_time~=nil and   MainModel.UserInfo.last_sczd_profit_num>0) then 
		if backcall then
			backcall()
		end
		return
	end
	return C.New(parent,backcall)
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
	if self.backcall then 
	   self.backcall()
	end 
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:ctor(parent,backcall)
	self:MakeLister()
	self:AddMsgListener()
	self.backcall=backcall
	local obj = newObject(C.name,parent or GameObject.Find("Canvas/LayerLv4").transform)
	self.gameObject=obj
	self.transform=obj.transform
	local lastlogintime
	if os.time()-MainModel.UserInfo.last_logout_time>24*60*60 then 
		self.transform:Find("Text"):GetComponent("Text").text="恭喜您"..os.date("%m.%d", MainModel.UserInfo.last_logout_time)..
		"-"..os.date("%m.%d",os.time()).."日共新增".."<color=yellow>"..(MainModel.UserInfo.last_sczd_profit_num/100).."</color>".."元收益"..
		"\n请尽快领取！"
	elseif os.time()-MainModel.UserInfo.last_logout_time>0 then 
		self.transform:Find("Text"):GetComponent("Text").text="恭喜您昨日共新增".."<color=yellow>"..(MainModel.UserInfo.last_sczd_profit_num/100).."</color>".."元收益"..
		"\n请尽快领取！"		
	end
	
	--HintPanel.Create(1,"成功创建",backcall,nil,nil,"收益提醒")
	--HintPanel.Create(type,msg,confirmCbk,cancelCbk,parent)
    self.transform:Find("CloseButton"):GetComponent("Button").onClick:AddListener(
		function ()
			self:MyExit()
		end
	)
	self.transform:Find("Button"):GetComponent("Button").onClick:AddListener(
		function ()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
			Event.Brocast("open_game_money_center")
			self.backcall=nil
			self:MyExit()
		end
	)
	
	
	DOTweenManager.OpenPopupUIAnim(self.transform)
end