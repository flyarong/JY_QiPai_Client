-- 创建时间:2020-10-11
-- Panel:WUZIQISYSCSSLPanel
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

WUZIQISYSCSSLPanel = basefunc.class()
local C = WUZIQISYSCSSLPanel
C.name = "WUZIQISYSCSSLPanel"
local M = WUZIQISYSCSSLManager


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
    self.lister["ExitScene"]=basefunc.handler(self,self.MyExit)
    self.lister["sys_jjsl_data_msg"] = basefunc.handler(self,self.on_sys_jjsl_data_msg)
	self.lister["sys_jjsl_Refresh_djs_msg"] = basefunc.handler(self,self.on_sys_jjsl_Refresh_djs_msg)	
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	if self.huxi then
		self.huxi.Stop()
	end
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:OnDestroy()
	self:MyExit()
end

function C:MyClose()
	self:MyExit()
end

function C:ctor()
	local parent = GameObject.Find("Canvas/LayerLv2").transform
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
	EventTriggerListener.Get(self.back_btn.gameObject).onClick = basefunc.handler(self, self.OnBackClick)
	EventTriggerListener.Get(self.activation_btn.gameObject).onClick = basefunc.handler(self, self.OnActivationClick)
	EventTriggerListener.Get(self.get_btn.gameObject).onClick = basefunc.handler(self, self.OnGetClick)
	EventTriggerListener.Get(self.calb_btn.gameObject).onClick = basefunc.handler(self, self.OnEnterCSLB)
	M.QueryData()
	--self:MyRefresh()
end



function C:MyRefresh()
	local status = M.GetStatus()
	local level = M.GetLevel()
	local award = M.GetAward()
	dump({status = status,level = level,award = award},"<color=yellow>+++++++++++++++</color>")
	if status == 1 then--立即激活
		self.award_txt.text = award
	elseif status == 2 then--立即领取
		self.award_txt.text = award
		if level < 1991 then
			self.level_txt.text = "Lv."..level
		elseif level == 1991 then
			self.level_txt.text = "满级"
		end
	elseif status == 3 then--倒计时
		self.award_txt.text = award
		if level < 1991 then
			self.level_txt.text = "Lv."..level
		elseif level == 1991 then
			self.level_txt.text = "满级"
		end
	end
	M.RunDownCount(status == 3)
	self:SetActive(status)
	self:RefreshAddBtn()
	self:RefreshCslbBtn()
end

function C:OnBackClick()
	self:MyExit()
end

function C:on_sys_jjsl_data_msg()
	self:MyRefresh()
end

function C:SetActive(status)
	self.activation_btn.gameObject:SetActive(status == 1)
	self.get_btn.gameObject:SetActive(status == 2)
	self.djs.gameObject:SetActive(status == 3)
	self.before.gameObject:SetActive(status == 1)
	self.after.gameObject:SetActive(status == 2 or status == 3)
end

function C:OnActivationClick()
	WUZIQISYSCSLBPanel.Create()
	--PayPanel.Create(GOODS_TYPE.jing_bi, "normal")
end

function C:OnGetClick()
	dump("领取奖励")
    Network.SendRequest("get_jjsl_award")
end

--财神礼包入口
function C:OnEnterCSLB()
	WUZIQISYSCSLBPanel.Create()
end

function C:RefreshDJS()
	local temp = 0
	local hour = 0
	local minute = 0
	local second
	temp = self.remain_time
	hour = math.floor(temp/3600)
	minute = math.floor((temp - hour*3600)/60)
	second = temp - hour*3600 - minute*60
	if string.len(hour) == 1 then
		hour = "0"..hour
	end
	if string.len(minute) == 1 then
		minute = "0"..minute
	end
	if string.len(second) == 1 then
		second = "0"..second
	end
	self.djs_txt.text = hour..":"..minute..":"..second
end

function C:RefreshAddBtn()
	if M.GetLevel() == 1991 then
		self.add_btn.gameObject:SetActive(false)
		return 
	end
	self.add_btn.gameObject:SetActive(true)
	self.add_btn.onClick:AddListener(function ()
		if M.IsCanGetGift() then
			WUZIQISYSCSLBPanel.Create()
		else
			PayPanel.Create(GOODS_TYPE.jing_bi, "normal")
		end
	end)
end

function C:RefreshCslbBtn()
	self.calb_btn.gameObject:SetActive(M.IsCanGetGift())
	if M.IsCanGetGift() then
		if self.huxi then
			self.huxi.Stop()
		end
		self.huxi =  CommonHuxiAnim.Go(self.calb_btn.gameObject,1)
		self.huxi.Start()
	end
end

function C:on_sys_jjsl_Refresh_djs_msg(time)
	self.remain_time = time
	self:RefreshDJS()
	self:RefreshCslbBtn()
end
