-- 创建时间:2020-04-15
-- Panel:VIPSWGetPanel
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

VIPSWGetPanel = basefunc.class()
local C = VIPSWGetPanel
C.name = "VIPSWGetPanel"

function C.Create(data)
	return C.New(data)
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
	VIPManager.CheckAndShoWBoxYJTZ()
	-- local data = GameTaskModel.GetTaskDataByID(21244)
	-- dump(data,"<color=white>任务21244</color>")
	-- if data then
	-- 	if data.award_status == 1 then
	-- 		local str = "感谢你对游戏的支持，\n在踏上新征途之前，请收下我们为您准备的宝箱"
	-- 		local td = VIPManager.get_vip_task(21243)
	-- 		if td and td.award_status == 2 then
	-- 			str = "真了不起！恭喜您已完成第二阶段的赢金挑战，\n点击领取我们为你准备的勇者宝箱"
	-- 			local td1 = VIPManager.get_vip_task(21315)
	-- 			if td1 and td1.award_status == 2 then
	-- 				str = "真了不起！恭喜您已完成第三阶段的赢金挑战，\n点击领取我们为你准备的勇者宝箱"
	-- 			end
	-- 		end
	-- 		VIPLJYJ88GetPanel.Create({dec = str})
	-- 	end
    -- end
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:ctor(data)

	ExtPanel.ExtMsg(self)

	local parent = GameObject.Find("Canvas/LayerLv5").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	self.conten_txt.text = data.text
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	self.close_btn.onClick:AddListener(
		function()
			self:MyExit()
		end
	)
	self.get_btn.onClick:AddListener(
		function()
			self:CopyQQCode()
		end
	)
	self:MyRefresh()
end

function C:MyRefresh()

end

function C:CopyQQCode()
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	--LittleTips.Create("已复制QQ号请前往QQ进行添加")
	UniClipboard.SetText("4008882620")
end
