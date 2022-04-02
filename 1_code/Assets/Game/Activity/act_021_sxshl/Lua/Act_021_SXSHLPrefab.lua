-- 创建时间:2020-07-06
-- Panel:Act_021_SXSHLPrefab
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

Act_021_SXSHLPrefab = basefunc.class()
local C = Act_021_SXSHLPrefab
C.name = "Act_021_SXSHLPrefab"
local M = Act_021_SXSHLManager
local str = {
	game_Fishing="街机捕鱼中1000及以上炮倍击杀黄金龙",
	game_Eliminate ="水果消消乐3万及以上档次触发幸运时刻",
	game_EliminateCS = "财神消消乐3万及以上档次触发天女散花",
	game_EliminateSH ="水浒消消乐3万及以上档次触发≥2个英雄",
	game_EliminateXY ="西游消消乐3万及以上档次触发免费游戏打村姑",
}
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
	self.lister["FishingTaskBigPrefab_ShowOrHide_Changed"] = basefunc.handler(self,self.fishing_pos_change)
	self.lister["act_021_sxshl_get"] = basefunc.handler(self,self.act_021_sxshl_get)
	self.lister["ExitScene"] = basefunc.handler(self,self.MyExit)
	self.lister["model_task_change_msg"] = basefunc.handler(self, self.on_model_task_change_msg)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	self.huxi:Stop()
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:ctor()
	ExtPanel.ExtMsg(self)
	local parent = GameObject.Find("Canvas/LayerLv3").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	local x = MainModel.myLocation == "game_Fishing" and 0 or -87
	self.transform.localPosition = Vector3.New(x,496,0)
	self:act_021_sxshl_get()
	self.huxi = CommonHuxiAnim.Go(self.gameObject,space,min,max)
	--self.task_txt.text = str[MainModel.myLocation]
end

function C:InitUI()
	self.open_btn.onClick:AddListener(
		function ()
			--self.task_node.gameObject:SetActive(true)
			ActivityYearPanel.Create(nil, nil, { ID =  120}, true)
		end
	)
	-- self.close_btn.onClick:AddListener(
	-- 	function ()
	-- 		--self.task_node.gameObject:SetActive(false)
	-- 	end
	-- )
	self:MyRefresh()
end

function C:MyRefresh()
	
end

function C:fishing_pos_change(data)
	if data then
		if data.isShow then
			self.transform.localPosition = Vector3.New(0,347,0)
		else
			self.transform.localPosition = Vector3.New(0,496,0)
		end
	end
end

function C:act_021_sxshl_get()
	local data = M.GetJiangChiVar()
	dump(data,"<color=red>act_021_sxshl_get</color>")
	for i = 7, 1, -1 do
		self["num"..(8 - i).."_txt"].text = data[i]
	end
end

function C:on_model_task_change_msg()
	if M.GetHintState() == ACTIVITY_HINT_STATUS_ENUM.AT_Get then
		self.huxi:Start()
	else
		self.huxi:Stop()
	end
end