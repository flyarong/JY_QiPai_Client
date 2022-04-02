-- 创建时间:2020-01-15
-- Panel:LHDGuidePanel
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

LHDGuidePanel = basefunc.class()
local C = LHDGuidePanel
C.name = "LHDGuidePanel"
local M = LHDModel

-- 引导步骤
local GuideStepConfig = {
	[1] = {
		id = 1,
		type="button",
		isHideBG=false, 
		isHideSZ = false,
		szPos={x=-162, y=-320, z=0},
		desc="点击砸蛋,进入砸蛋状态",
		descRot={x=0, y=0, z=180},
		descPos={x=-62, y=100, z=0},
		headPos={x=0, y=0},
	},
	[2] = {
		id = 2,
		type="button",
		isHideBG=false, 
		isHideSZ = false,
		szPos={x=-162, y=-320, z=0},
		desc="点击砸开这个蛋",
		descPos={x=0, y=-184, z=0},
		headPos={x=0, y=0},
	},
	[5] = {
		id = 5,
		type="button",
		isHideBG=false, 
		isHideSZ = false,
		szPos={x=-162, y=-320, z=0},
		desc="选择跟，进入战斗",
		descPos={x=0, y=-184, z=0},
		headPos={x=0, y=0},
	},
	[6] = {
		id = 6,
		type="GuideStyle1",
		isHideBG=false, 
		isHideSZ = true,
		desc="又获得一个A，形成了三条牌型",
		descRot={x=180, y=0, z=0},
		descPos={x=-74, y=150, z=0},
		headPos={x=0, y=0},
	},
	[7] = {
		id = 7,
		type="GuideStyle1",
		isHideBG=false, 
		isHideSZ = true,
		desc="让我们用一种更简单的方式来砸蛋吧",
		descRot={x=180, y=0, z=0},
		descPos={x=-348, y=144, z=0},
		headPos={x=0, y=0},
	},
	[8] = {
		id = 8,
		type="GuideStyle1",
		isHideBG=false, 
		isHideSZ = true,
		desc="又得到一张A，我们形成了很大的【炸弹】牌型",
		descRot={x=180, y=0, z=0},
		descPos={x=-74, y=220, z=0},
		headPos={x=0, y=0},
	},
	[9] = {
		id = 9,
		type="GuideStyle1",
		isHideBG=false, 
		isHideSZ = true,
		desc="对手已经有一对Q，不可能是同花顺，\n我们的牌型肯定大过他",
		descPos={x=0, y=-144, z=0},
		headPos={x=0, y=0},
	},
	[10] = {
		id = 10,
		type="GuideStyle1",
		isHideBG=false, 
		isHideSZ = true,
		desc="你已经学会怎么砸蛋了，来自己操作一下吧",
		descRot={x=180, y=0, z=0},
		descPos={x=-390, y=220, z=0},
		headPos={x=0, y=0},
	},
	[11] = {
		id = 11,
		type="GuideStyle1",
		isHideBG=false, 
		isHideSZ = true,
		desc="对方名牌有三张Q，加上暗牌，有可能是【炸弹】，\n有可能是【三条】，也有可能是【葫芦】",
		descPos={x=-390, y=260, z=0},
		headPos={x=0, y=0},
	},
	[12] = {
		id = 12,
		type="GuideStyle1",
		isHideBG=false, 
		isHideSZ = true,
		desc="我们牌型为A炸弹，比对方所有有可能出现的牌型都大",
		descRot={x=180, y=0, z=0},
		descPos={x=-430, y=-210, z=0},
		headPos={x=0, y=0},
	},
}

function C.Create(panelSelf)
	return C.New(panelSelf)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["lhd_guide_check"] = basefunc.handler(self, self.CheckGuide)
    self.lister["EnterBackGround"] = basefunc.handler(self, self.OnEnterBackGround)
end
function C:OnEnterBackGround()
	self:StopRunTime()
end
function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	if self.com_guide then
		self.com_guide:MyExit()
		self.com_guide = nil
	end
	self:RemoveListener()
end

function C:ctor(panelSelf)	
	self:MakeLister()
	self:AddMsgListener()

	-- 游戏面板
	self.panelSelf = panelSelf
	self:InitUI()
end

function C:InitUI()
	self.com_guide = ComGuideToolPanel.Create()
	local sz = self.com_guide.transform:Find("Canvas/SZAnim1/SZAnim1")
	sz.transform.localPosition = Vector3.New(0,0,0)
end
function C:StopRunTime()
	if self.guide_t then
		self.guide_t:Stop()
	end
	self.guide_t = nil
end

function C:CheckGuide()
	if self.is_bengin_run_guide then
		print("<color=red>引导开始运行中，一帧的延迟启动</color>")
		print(debug.traceback())
		return
	end
	coroutine.start(function ()
		Yield(0)
		self.is_bengin_run_guide = false
	end)
	self:StopRunTime()

	self.is_bengin_run_guide = true
	if not LHDModel.data.xsyd or LHDModel.data.xsyd == 0 then
		return
	end
	if M.data.cur_p == 0 or M.data.cur_p == M.data.seat_num then
		self.com_guide:CloseGuide()
	end

	-- if M.data.model_status == M.Model_Status.wait_begin and not M.IsPlayerReady(M.data.seat_num) then
	-- 	self.com_guide:RunGuide(GuideStepConfig[1], self.panelSelf.ready_btn.gameObject)
	-- 	return
	-- end
	local xj = M.GetXJSeatno(M.data.seat_num)
	if M.data.model_status == M.Model_Status.gaming
		and M.data.cur_p == 0
		and #M.data.player_pai[M.data.seat_num] == 3
		and #M.data.player_pai[xj] == 2 then
			self.com_guide:RunGuide(GuideStepConfig[6], self.panelSelf.guide_ckpx1.gameObject)
			self.guide_t = Timer.New(function ()
				self.guide_t = nil
				self.com_guide:CloseGuide()
			end,3, 1)
			self.guide_t:Start()
			return
	end
	if M.data.model_status == M.Model_Status.gaming
		and M.data.cur_p == 0
		and #M.data.player_pai[M.data.seat_num] == 4
		and #M.data.player_pai[xj] == 3 then
			self.com_guide:RunGuide(GuideStepConfig[8], self.panelSelf.guide_ckpx2.gameObject)
			self.guide_t = Timer.New(function ()
				self.guide_t = nil
				self.com_guide:CloseGuide()
				self.com_guide:RunGuide(GuideStepConfig[9], self.panelSelf.guide_ckpx3.gameObject)
				self.guide_t = Timer.New(function ()
					self.guide_t = nil
					self.com_guide:CloseGuide()
				end,3, 1)
				self.guide_t:Start()
			end,3, 1)
			self.guide_t:Start()
			return
	end

	if M.data.cur_p == M.data.seat_num and M.data.status then
		local cur_round = M.GetCurRound()
		if M.data.status == M.Status.mopai or M.data.status == M.Status.buqi then
			if cur_round == 3 then
				if M.data.status == M.Status.mopai then
					if self.panelSelf.oper_pre.qxz_zd_node.gameObject.activeSelf then
						local index = M.RandEggIndex()
						self.com_guide:RunGuide(GuideStepConfig[2], self.panelSelf.center_pre.EggCellList[index].gameObject)
					else
						self.com_guide:RunGuide(GuideStepConfig[1], self.panelSelf.oper_pre.za_btn)
					end
				end
			elseif cur_round == 4 then
				if M.data.status == M.Status.mopai then
					self.com_guide:RunGuide(GuideStepConfig[7], self.panelSelf.guide_node1.gameObject)
					self.guide_t = Timer.New(function ()
						self.guide_t = nil
						self.com_guide:CloseGuide()
						local index = M.RandEggIndex()
						self.com_guide:RunGuide(GuideStepConfig[2], self.panelSelf.center_pre.EggCellList[index].gameObject)
					end,3, 1)
					self.guide_t:Start()
				end
			elseif cur_round == 5 then
				if M.data.status == M.Status.mopai then
					self.com_guide:RunGuide(GuideStepConfig[10], self.panelSelf.guide_node1.gameObject)
					self.guide_t = Timer.New(function ()
						self.guide_t = nil
						self.com_guide:CloseGuide()
					end,3, 1)
					self.guide_t:Start()
				end
			end
		elseif M.data.status == M.Status.equip and (not M.data.player_equip_rate or not M.data.player_equip_rate[M.data.seat_num] or M.data.player_equip_rate[M.data.seat_num] <= 0) then
			self.com_guide:RunGuide(GuideStepConfig[11], self.panelSelf.guide_node1.gameObject)
			self.guide_t = Timer.New(function ()
				self.guide_t = nil
				self.com_guide:CloseGuide()
				self.com_guide:RunGuide(GuideStepConfig[12], self.panelSelf.guide_node1.gameObject)
				self.guide_t = Timer.New(function ()
					self.guide_t = nil
					self.com_guide:CloseGuide()
					self.com_guide:RunGuide(GuideStepConfig[5], self.panelSelf.combat_pre.cz_gen_btn.gameObject)
				end,3, 1)
				self.guide_t:Start()
			end,3, 1)
			self.guide_t:Start()
		end
	end
end

