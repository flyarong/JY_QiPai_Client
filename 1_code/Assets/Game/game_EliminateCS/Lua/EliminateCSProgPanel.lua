-- 创建时间:2020-02-14
-- Panel:EliminateCSProgPanel
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

EliminateCSProgPanel = basefunc.class()
local C = EliminateCSProgPanel
C.name = "EliminateCSProgPanel"
local Instance
local PG_width = 911.62
local config = EliminateCSModel.xiaoxiaole_cs_defen_cfg.jd
local Curr_Jd_Num = 0
--data: all_jindan_value --当前的金蛋个数
function C.Create(data)
	if Instance then 
		return Instance
	else
		Instance = C.New(data)
		return Instance
	end 
end

--data: all_jindan_value --当前的金蛋个数
function C.SetPro(data)
	if Instance then 
		--设置当前进度
		Curr_Jd_Num = data.all_jindan_value
		local bl = EliminateCSModel.GetBetLevel()
		local total = EliminateCSModel.xiaoxiaole_cs_defen_cfg.jd[bl].jd
		Instance:SetProg(data.all_jindan_value / total)
	end 
end
--瞬间进度变化
function C.SetProInstant(data)
	if Instance then 
		--设置当前进度
		if not data.all_jindan_value then return end
		Curr_Jd_Num = data.all_jindan_value
		local bl = EliminateCSModel.GetBetLevel()
		local total = EliminateCSModel.xiaoxiaole_cs_defen_cfg.jd[bl].jd
		Instance:SetProg(data.all_jindan_value / total,true)
	end 
end

function C.GetDanNode()
	if Instance then 
		return Instance.open_btn.transform
	end
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
	self.lister = {}
	self.lister["view_lottery_end"] = basefunc.handler(self, self.view_lottery_end)
	self.lister["csxxl_betlevel_changed"] = basefunc.handler(self,self.on_csxxl_betlevel_changed)
	self.lister["view_quit_game"] = basefunc.handler(self, self.MyExit)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	if self.change_timer then 
		self.change_timer:Stop()
		self.change_timer = nil
	end
	if self.glow_timer then 
		self.glow_timer:Stop()
		self.glow_timer = nil
		self.glow.gameObject:SetActive(false)
	end
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
	self.P_G = self.Progress_PG.transform:GetComponent("Image")
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	self:SetProg(0,true)
end

function C:InitUI()
	self.glow.gameObject:SetActive(false)
	self:MyRefresh()
	self.open_btn.onClick:AddListener(
		function ()
			if false then
				LittleTips.Create("下周二（3月17日）开启")
				return
			end
			local status = EliminateCSModel.data.status_lottery
			local auto = EliminateCSModel.GetAuto()
			if self.val >= 1 then
				if status == EliminateCSModel.status_lottery.wait and not auto then
					EliminateCSGamePanel.LotteryZP()
				else
					LittleTips.Create("您正在游戏中，请在该局结束后再开启财运蛋")
				end
			else
				EliminateCSZPGamePanel.Create(nil,EliminateCSModel.xiaoxiaole_cs_defen_cfg.zp,nil,self.state)
			end
		end
	)
end

function C:MyRefresh()

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
	if val == 0 or IsInstant then 
		self.P_G.fillAmount = val
		self:SetTxPos(val)
		return 
	end
	local c_v = self.P_G.fillAmount
	local dur_time = 2 -- 总持续时间
	local performs = 1 --顺滑度
	local each_time = 0.016 * performs -- 单帧时间(可以根据性能减少帧数，性能越差，performs越大)
	local run_times = dur_time / each_time --执行次数
	local s = val - c_v -- 总路程
	local each_s = s / run_times -- 单帧路程
	self.change_timer = Timer.New(function()
		self.P_G.fillAmount = self.P_G.fillAmount + each_s
		self:SetTxPos(self.P_G.fillAmount)
		if math.abs(self.P_G.fillAmount - val) <= 0.01 then 
			self.P_G.fillAmount = val
			self:SetTxPos(val)
			self.change_timer:Stop()
		end
	end ,each_time,run_times)
	self.change_timer:Start()

	self.glow_timer = Timer.New(function(  )
		self.glow.gameObject:SetActive(false)
	end,0.5,1)
	self.glow.gameObject:SetActive(true)
	self.glow_timer:Start()
end

--设置特效位置
function C:SetTxPos(val)
	self.tx_pos.transform.localPosition  = Vector2.New(PG_width * val,self.tx_pos.transform.localPosition.y)
	self.val = val
	local b = val >= 1
	self.tishi.gameObject:SetActive(b)
	self.tx_pos.gameObject:SetActive(not b)
	local ls = 1
	if b then
		ls = 2
	end
	self.open_btn.transform.localScale = Vector3.one * ls
	-- self.open_btn.enabled = b
end

function C.Close()
	if Instance then 
		Instance:MyExit()
		Instance = nil
	end
end

function C:view_lottery_end(data)
	dump(data, "<color=white>刷新进度条</color>")
	C.SetProInstant(data)
end

function C:on_csxxl_betlevel_changed()
	if Instance then 
		--设置当前进度
		local bl = EliminateCSModel.GetBetLevel()
		local total = EliminateCSModel.xiaoxiaole_cs_defen_cfg.jd[bl].jd
		Instance:SetProg(Curr_Jd_Num / total)
	end 
end