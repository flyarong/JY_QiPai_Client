-- 创建时间:2020-03-26
-- Panel:MjxzZJFRuleChangeNoticePrefab
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

MjxzZJFRuleChangeNoticePrefab = basefunc.class()
local C = MjxzZJFRuleChangeNoticePrefab
C.name = "MjxzZJFRuleChangeNoticePrefab"
local xishu  = 0.01
local enter_base = 10000
function C.Create(data,yes_callback,no_callback)
	return C.New(data,yes_callback,no_callback)
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
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:ctor(data,yes_callback,no_callback)
	local parent = GameObject.Find("Canvas/LayerLv5").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	self.data = data
	self.yes_callback = yes_callback
	self.no_callback = no_callback
	self.person = MjXzFKModel.data.game_type == "nor_mj_xzdd_er_7" and 2 or 4
	--总的进入条件（房主看到的和非房主看到的不一致）
	if MjXzFKModel.IsFZPaY() then
		xishu = 0
	else
		xishu = GameZJFModel.get_ddz_enter_xishu_by_type(MjXzFKModel.data.game_type)
	end
	enter_base = GameZJFModel.get_ddz_enter_base_by_type(MjXzFKModel.data.game_type)
	LuaHelper.GeneratingVar(self.transform, self)
	Event.Brocast("DDZ_ResetAutoExitTime")
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	self.close_btn.onClick:AddListener(
		function ()
			self:MyExit()
		end
	)
	self.old_df_txt.text = MjXzFKModel.get_ori_game_cfg_byOption("init_stake")
	self.new_df_txt.text = self.data.diff_cfg.init_stake

	self.old_bs_txt.text = MjXzFKModel.GetCurrBeiShu()
	self.new_bs_txt.text = self.data.diff_cfg.feng_ding  

	self.old_jrtj_txt.text = (MjXzFKModel.get_ori_game_cfg_byOption("enter_limit") *  MjXzFKModel.GetCurrBeiShu() + xishu ) * MjXzFKModel.get_ori_game_cfg_byOption("init_stake") + enter_base
	if self.data.diff_cfg.fangzhu_pay == 1 then
		xishu = 0
	else
		xishu = GameZJFModel.get_ddz_enter_xishu_by_type(MjXzFKModel.data.game_type)
	end
	self.new_jrtj_txt.text = (self.data.diff_cfg.enter_limit * self.data.diff_cfg.feng_ding + xishu ) * self.data.diff_cfg.init_stake + enter_base

	self.fwf_txt.text = self.data.diff_cfg.fangzhu_pay == 1 and "服务费为房主包,("..self.data.diff_cfg.init_stake* self.person * xishu ..")鲸币" or "服务费为AA制（每位玩家每局服务费"..self.data.diff_cfg.init_stake * xishu .."鲸币)"

	self.yfd_txt.text = self.data.diff_cfg.yingfengding == 1 and "赢封顶" or " "

	self.name_txt.text = "房主【"..MjXzFKModel.GetFzName().."】修改了房间规则"

	self.no_btn.onClick:AddListener(
		function ()
			if self.no_callback then 
				self.no_callback()
			end
			self:MyExit()
		end
	)
	self.yes_btn.onClick:AddListener(
		function ()
			if MainModel.UserInfo.jing_bi >= (self.data.diff_cfg.enter_limit + xishu) * self.data.diff_cfg.init_stake + enter_base then 
				if self.yes_callback then 
					self.yes_callback()
				end
				self:MyExit()
			else
				Event.Brocast("show_gift_panel")
			end 
		end
	)
	self:MyRefresh() 
end

function C:MyRefresh()

end
