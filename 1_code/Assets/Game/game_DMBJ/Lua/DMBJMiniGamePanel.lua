-- 创建时间:2020-12-04
-- Panel:DMBJMiniGamePanel
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
local max_t = 30
DMBJMiniGamePanel = basefunc.class()
local C = DMBJMiniGamePanel
C.name = "DMBJMiniGamePanel"

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
	self.lister["dmbj_free_game_changed"] = basefunc.handler(self,self.dmbj_free_game_changed)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	ExtendSoundManager.PauseSceneBGM()
	ExtendSoundManager.PlaySceneBGM(audio_config.dmbj.dmbj_beijing.audio_name)
	if self.DTTimer then
		self.DTTimer:Stop()
	end
	if self.Timer then
		self.Timer:Stop()
	end
	if self.Timer2 then
		self.Timer2:Stop()
	end
	DMBJModel.Status = DMBJ_Enum.Start
	DMBJModel.MiniAward = 0
	DMBJModel.Round = 0
	DMBJModel.IsEnd = 0
	self:RemoveListener()
	destroy(self.gameObject)
	Event.Brocast("dmbj_bet_changed")
	Event.Brocast("dmbj_mini_game_panel_closed")
end

function C:ctor()
	ExtPanel.ExtMsg(self)
	local parent = GameObject.Find("Canvas/LayerLv2").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	self.close.gameObject:SetActive(false)
	self.open.gameObject:SetActive(true)
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	ExtendSoundManager.PauseSceneBGM()
	ExtendSoundManager.PlaySceneBGM(audio_config.dmbj.dmbj_xiaoyouxibeijing.audio_name)
end

function C:InitUI()
	self.take_btn.onClick:AddListener(
		function()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
			self:TakeAward()
		end
	)
	self.goon_btn.onClick:AddListener(
		function()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
			self:GoOn()
		end
	)
	self.diandeng_btn.onClick:AddListener(
		function()
			DMBJModel.Explore =  DMBJModel.Explore - DMBJModel.dmbj_base_config.tx[DMBJModel.BetIndex].max
			self:DianDeng()
		end
	)
	self.close_lose_btn.onClick:AddListener(
		function()
			self:MyExit()
		end
	)
	self.award_txt.text = DMBJModel.MiniAward == 0 and DMBJModel.dmbj_base_config.tx[DMBJModel.BetIndex].award  or  DMBJModel.MiniAward * 2
	self.num_txt.text = 7 - DMBJModel.Round
	if DMBJModel.IsEnd == 1 then
		if DMBJModel.MiniAward == 0 then
			self.lose.gameObject:SetActive(true)
			local t = 5
			self.lose_cut_txt.text = "("..t..")~" 
			self.Timer2 = Timer.New(function()
				t = t - 1
				self.lose_cut_txt.text = "("..t..")~" 
				if t == 0 then
					self:MyExit()
				end
			end,1,-1,nil,true)
			self.Timer2:Start()
			Timer.New(function()
				self.close.gameObject:SetActive(true)
				self.open.gameObject:SetActive(false)
			end,0.6,1):Start()
		else
			self:MyExit()
		end
	else
		if DMBJModel.Round > 0 then
			local t = DMBJModel.GetCurrCutDown() < 0 and 0 or DMBJModel.GetCurrCutDown()
			if t <= 15 then
				self.go_txt.text = "点灯倒计时: "..t.."s~"
				self.DTTimer = Timer.New(
					function()
						t = t - 1
						self.go_txt.text = "点灯倒计时: "..t.."s~"
						if t <= 0 then
							self:DianDeng()
							if self.DTTimer then
								self.DTTimer:Stop()
							end
						end
					end,1,30,nil,true
				)
			else
				local t = t - 15
				self.go2_txt.text = "拿宝走人:"..t.."s~"
				self.DTTimer = Timer.New(
					function()
						t = t - 1
						self.go2_txt.text = "拿宝走人:"..t.."s~"
						if t <= 0 then
							self:TakeAward()
							if self.DTTimer then
								self.DTTimer:Stop()
							end
						end
					end,1,15,nil,true
				)
			end
			self.DTTimer:Start()
		else
			local t = 30
			self.DTTimer = Timer.New(
			function()
				t = t - 1
				self.go_txt.text = "点灯倒计时: "..t.."s~"
				if t <= 0 then
					self:DianDeng()
					if self.DTTimer then
						self.DTTimer:Stop()
					end
				end
			end,1,30,nil,true
			)
			self.DTTimer:Start()
		end
	end
	self:CutTimer()
end

function C:MyRefresh()
	if self.DTTimer then
		self.DTTimer:Stop()
	end

	if DMBJModel.IsEnd == 0 then
		Timer.New(function()
			if IsEquals(self.gameObject) then
				self.boom.gameObject:SetActive(false)
				self.boom.gameObject:SetActive(true)
				self.wending_huoyan.gameObject:SetActive(true)
				self.buwending_huoyan.gameObject:SetActive(false)
				self.award_txt.text = DMBJModel.MiniAward
				self.num_txt.text = 7 - DMBJModel.Round
				self.take_btn.gameObject:SetActive(true)
				self.goon_btn.gameObject:SetActive(true)
				self.diandeng_btn.gameObject:SetActive(false)
				ExtendSoundManager.PlaySound(audio_config.dmbj.dmbj_xiaoyouxishengli.audio_name)
				local t = 15
				self.go2_txt.text = "拿宝走人:"..t.."s~"
				self.DTTimer = Timer.New(
					function()
						t = t - 1
						self.go2_txt.text = "拿宝走人:"..t.."s~"
						if t <= 0 then
							self:TakeAward()
							if self.DTTimer then
								self.DTTimer:Stop()
							end
						end
					end,1,15,nil,true
				)
				self.DTTimer:Start()
			end
		end,2,1):Start()
	else
		if DMBJModel.MiniAward == 0 then
			Timer.New(function()
				if IsEquals(self.gameObject) then
					self.close.gameObject:SetActive(true)
					self.open.gameObject:SetActive(false)
					self.wending_huoyan.gameObject:SetActive(false)
					self.buwending_huoyan.gameObject:SetActive(false)
					self.award_txt.text = DMBJModel.MiniAward
					self.num_txt.text = 7 - DMBJModel.Round
					Timer.New(function()
						self.lose.gameObject:SetActive(true)
						ExtendSoundManager.PlaySound(audio_config.dmbj.dmbj_xiaoyouxishibai.audio_name)
						local t = 5
						self.lose_cut_txt.text = "("..t..")~" 
						self.Timer2 = Timer.New(function()
							t = t - 1
							self.lose_cut_txt.text = "("..t..")~" 
							if t == 0 then
								self:MyExit()
							end
						end,1,-1,nil,true)
						self.Timer2:Start()
					end,2,1,nil,true):Start()
				end
			end,2,1,nil,true):Start()
			
		else
			ExtendSoundManager.PlaySound(audio_config.dmbj.dmbj_xiaoyouxihuojiang.audio_name)
			Event.Brocast("AssetGet",{data = {
												{asset_type = "jing_bi",value = DMBJModel.MiniAward}
											},
									change_type	= "dmbj_free_game_award"
									}
									)
			self:MyExit()
		end
	end
end

function C:GoOn()
	if self.DTTimer then
		self.DTTimer:Stop()
	end
	self.award_txt.text = DMBJModel.MiniAward == 0 and DMBJModel.dmbj_base_config.tx[DMBJModel.BetIndex].award  or  DMBJModel.MiniAward * 2
	self.wending_huoyan.gameObject:SetActive(false)
	self.buwending_huoyan.gameObject:SetActive(false)
	self.T.gameObject:SetActive(true)
	self.take_btn.gameObject:SetActive(false)
	self.goon_btn.gameObject:SetActive(false)
	self.diandeng_btn.gameObject:SetActive(true)
	self.go_txt.gameObject:SetActive(true)
	self.go2_txt.gameObject:SetActive(false)
end

function C:DianDeng()
	if self.DTTimer then
		self.DTTimer:Stop()
	end
	Network.SendRequest("dmbj_free_game_kaijiang",{bet_index = DMBJModel.BetIndex,is_end = 0})
	self.T.gameObject:SetActive(false)
	self.go_txt.gameObject:SetActive(false)
	self.go2_txt.gameObject:SetActive(true)
	self.buwending_huoyan.gameObject:SetActive(true)
	self.take_btn.gameObject:SetActive(false)
	self.goon_btn.gameObject:SetActive(false)
	self.diandeng_btn.gameObject:SetActive(false)
end

function C:TakeAward()
	Network.SendRequest("dmbj_free_game_kaijiang",{bet_index = DMBJModel.BetIndex,is_end = 1})
end

function C:dmbj_free_game_changed()
	self:MyRefresh()
end

function C:CutTimer()
	local func = function()
		if DMBJModel.Status == DMBJ_Enum.Free then
			local cut = DMBJModel.GetCurrCutDown() < 0 and 0 or DMBJModel.GetCurrCutDown()
			self.go_txt.text = "点灯倒计时: "..cut.."s~"
		end
	end
	func()
	self.Timer = Timer.New(
		function()
			func()
		end,1,-1,nil,true
	)
	self.Timer:Start()
end