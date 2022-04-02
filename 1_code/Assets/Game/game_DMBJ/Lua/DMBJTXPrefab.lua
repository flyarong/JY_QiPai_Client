-- 创建时间:2020-11-30
-- Panel:DMBJTXPrefab
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

DMBJTXPrefab = basefunc.class()
local C = DMBJTXPrefab
C.name = "DMBJTXPrefab"

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
	self.lister["model_dmbj_all_info"] = basefunc.handler(self,self.MyRefreshPro)
	self.lister["dmbj_bet_changed"] = basefunc.handler(self,self.on_dmbj_bet_changed)
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
	local parent = GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	self.P_G = self.pro.transform:GetComponent("Image")
	self.Animator = self.transform:GetComponent("Animator")
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	self.go_btn.onClick:AddListener(
		function()
			if not self.lock then
				if DMBJModel.Explore / DMBJModel.dmbj_base_config.tx[DMBJModel.BetIndex].max >= 1 then
					if DMBJModel.Status ~= DMBJ_Enum.First then
						self.lock = true
						self.Mask.gameObject:SetActive(true)
						ExtendSoundManager.PlaySound(audio_config.dmbj.dmbj_xiaoyouxikaiqi.audio_name)
						self.Animator:Play("DMBJTXPrefab_xuanzhuanshan",-1,0)
						Timer.New(function()
							self.lock = false
							self.Mask.gameObject:SetActive(false)
							if IsEquals(self.gameObject) then
								DMBJMiniGamePanel.Create()
							end
						end,0.85,1):Start()
					else
						LittleTips.Create("请先完成本次探险")
					end
				else
					DMBJMiniHelpGamePanel.Create()
				end
			end
		end
	)

end

function C:SetProg(val,IsInstant)
	if self.change_timer then 
		self.change_timer:Stop()
	end
	if self.glow_timer then 
		self.glow_timer:Stop()
		self.glow.gameObject:SetActive(false)
	end
	if val > 1 then 
		val = 1 
	end 
	if val < 0 then 
		val = 0 
	end
	local set_status_func = function(val)
		if val < 1 then
			self.Animator:Play("DMBJTXPrefab_stop",-1,0)
			self.guangxian.gameObject:SetActive(false)
			self.t.gameObject:SetActive(true)
			self.go_img.gameObject:SetActive(false)
			self.quan_01.gameObject:SetActive(false)
		elseif val == 1 then
			self.guangxian.gameObject:SetActive(true)
			self.go_img.gameObject:SetActive(true)
			self.t.gameObject:SetActive(false)
			self.Animator:Play("DMBJTXPrefab_wenzi",-1,0)
			self.quan_01.gameObject:SetActive(true)
		end
	end
	if val == 0 or IsInstant then 
		self.P_G.fillAmount = val
		set_status_func(val)
		return 
	end
	local c_v = self.P_G.fillAmount
	local dur_time = 0.5 -- 总持续时间
	local performs = 1 --顺滑度
	local each_time = 0.016 * performs -- 单帧时间(可以根据性能减少帧数，性能越差，performs越大)
	local run_times = dur_time / each_time --执行次数
	local s = val - c_v -- 总路程
	local each_s = s / run_times -- 单帧路程
	self.change_timer = Timer.New(function()
		self.P_G.fillAmount = self.P_G.fillAmount + each_s
		set_status_func(self.P_G.fillAmount)
		if math.abs(self.P_G.fillAmount - val) <= 0.01 then 
			self.P_G.fillAmount = val
			self.change_timer:Stop()
			set_status_func(self.P_G.fillAmount)
		end
	end ,each_time,run_times)
	self.change_timer:Start()
end

function C:on_second_kaijiang_finsh()
	self:MyRefreshPro()
end

function C:on_dmbj_bet_changed()
	self:MyRefreshPro()
end


function C:MyRefreshPro()
	local val = DMBJModel.Explore / DMBJModel.dmbj_base_config.tx[DMBJModel.BetIndex].max
	dump(DMBJModel.Explore,"当前的探险值")
	dump(DMBJModel.dmbj_base_config.tx[DMBJModel.BetIndex].max,"当前挡位探险值要求")
	self:SetProg(val)
end
