-- 创建时间:2021-02-04
-- Panel:RXCQFightPrefab
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

RXCQFightPrefab = basefunc.class()
local C = RXCQFightPrefab
C.name = "RXCQFightPrefab"
local player_zero_pos = Vector3.New(-383,-214,0)
RXCQFightPrefab.player_zero_pos = player_zero_pos
RXCQFightPrefab.backup_player_zero_pos = player_zero_pos
local map = {
	[1] = "cq_bg_jsd",
	[2] = "cq_bg_jsd",
	[3] = "cq_bg_kld",
	[4] = "cq_bg_kld",
	[5] = "cq_bg_swsg",
	[6] = "cq_bg_swsg",
	[7] = "cq_bg_zmcx",
	[8] = "cq_bg_wmsm",
	[9] = "cq_bg_zmsd",
	[10] = "cq_bg_brm",
	[11] = "cq_bg_bosszj",
}

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
	self.lister["rxcq_moneyitem_fly_over"] = basefunc.handler(self,self.on_rxcq_moneyitem_fly_over)
	self.lister["rxcq_xuanzhong_over"] = basefunc.handler(self,self.on_rxcq_xuanzhong_over)
	self.lister["rxcq_bet_change"] = basefunc.handler(self,self.on_rxcq_bet_change)
	self.lister["rxcq_clear_over"] = basefunc.handler(self,self.on_rxcq_clear_over)
	self.lister["rxcq_jzsc_in"] = basefunc.handler(self,self.on_rxcq_jzsc_in)
	self.lister["rxcq_jzsc_out"] = basefunc.handler(self,self.on_rxcq_jzsc_out)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	if self.update_player_zero_pos then
		self.update_player_zero_pos:Stop()
	end
	RXCQGuaiWuManager.ClearAllGuaiWu()
	self.playerAction:MyExit()
	self.BG_img.sprite = nil
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:OnDestroy()
	self:MyExit()
end

function C:MyClose()
	self:MyExit()
end

function C:ctor(parent)
	ExtPanel.ExtMsg(self)
	local parent = parent or GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	self.JingBiItem = {}
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	self.Mask = self.transform:Find("Mask"):GetComponent("Mask")
	RXCQModel.SetRegisterObj("RXCQFightPrefab_Mask",self.Mask)
	self.last_parent = self.playerAction.player.gameObject.transform.parent
end

function C:InitUI()
	self.playerAction =  RXCQPlayerAction.Create(self.player_node)
	self.playerAction.player.transform.localPosition = player_zero_pos
	self.update_player_zero_pos = Timer.New(
		function()
			RXCQFightPrefab.player_zero_pos = self.playerAction.player.transform.localPosition
		end,
	0.02,-1)
	self.update_player_zero_pos:Start()
	self:MyRefresh()
end

function C:on_rxcq_bet_change()
	self.BG_img.sprite = GetTexture(map[RXCQModel.BetIndex])
	self.BG_img.gameObject.transform.localScale = Vector3.New(1.1,1.1,1.1)
	RXCQGuaiWuManager.ClearAllGuaiWu()
	self:RefreshMap()
end

function C:MyRefresh()

end
--鲸币动画飞行完成
local anim_over_times = 0
local curr_money = 0
function C:on_rxcq_moneyitem_fly_over(data)
	anim_over_times = anim_over_times + 1
	curr_money = curr_money + data.money
	if curr_money == tonumber(RXCQModel.game_data.award) then
		anim_over_times = 0
		curr_money = 0
		self.JingBiItem = {}
		if not RXCQModel.IsMiniGame(RXCQModel.game_data.cid) then
			for i = 1,#RXCQModel.game_data.monster do
				if RXCQModel.game_data.monster[i] > 0 then
					local guaiwu = RXCQGuaiWuManager.CreateGuaiWu(self,RXCQModel.game_data.monster[i])
					guaiwu:ShowChuanSong(
						function()
							guaiwu:Stand()
						end
					)
				end
			end
			Event.Brocast("rxcq_call_next_anim")
		end
	end
end

function C:on_rxcq_clear_over()
	ExtendSoundManager.PlaySceneBGM(audio_config.rxcq.rxcq_background.audio_name)
	self.playerAction.player.RXCQShowMoneyItem:ReSetMoney()
	self.playerAction.player.RXCQShowMoneyItem:Hide()
	self.playerAction.player:Stand()
	RXCQLotteryAnim.ReSetShow()
	Event.Brocast("rxcq_bet_change")
	if RXCQModel.player_chuansong_type == "mini_game" then
		self.playerAction.player.gameObject.transform.parent = RXCQModel.GetRegisterObj("RXCQGamePanel_temp_player_node").gameObject.transform
		self.playerAction:ShowChuanSong()
		RXCQModel.DelayCall(
			function()
				self.playerAction.player.gameObject.transform.parent = self.last_parent
				RXCQModel.GetRegisterObj("RXCQGamePanel_temp_player_node").gameObject:SetActive(false)
			end
		,0.8)
	end
	Util.ClearMemory()
end
-- 处理怪物死亡
------------
function C:on_rxcq_xuanzhong_over()
	local skill_name = RXCQModel.GetCurrSkill()
	local config = {
		BanYueWanDao = "normal",
        CiShaJianShu = "normal",
        GongShaJianShu = "normal",
        LieHuoJianFa = "normal",
        JueZhanShaCheng = "mini_game",
        TianRenHeYi = "mini_game",
        ShenBinTianJiang = "mini_game",
	}
	local _type = config[skill_name]
	dump(_type,"<color=red>  _type_type_type </color>")
	anim_over_times = 0
	curr_money = 0
	if _type == "normal" then
		RXCQModel.player_chuansong_type = nil		
		self.playerAction:Attack(self,RXCQModel.GetCurrSkill())
	elseif _type == "mini_game" then
		RXCQModel.player_chuansong_type = "mini_game"		
		dump(_type,"<color=red>类型</color>")
		RXCQMiniGameDie.Die(self,skill_name)
	end
end
-----
--处理刷新
function C:RefreshMap()
	RXCQModel.DelayCall(
		function()
			self.black_mask.gameObject:SetActive(false)
			Event.Brocast("rxcq_new_lottery_ready")
		end
	,0.5)
	if RXCQModel.player_chuansong_type == "normal" then
		self.playerAction:ShowChuanSong()
		self.black_mask.gameObject:SetActive(false)
		self.black_mask.gameObject:SetActive(true)
	end
	for i = 1,#rxcq_main_config.base[RXCQModel.BetIndex].GuaiWu_Map	 do
		RXCQGuaiWuManager.CreateGuaiWu(self,i)
	end	
	self.JingBiItem = {}
	anim_over_times = 0
	curr_money = 0
end

function C:on_rxcq_jzsc_in()
	RXCQGuaiWuManager.ClearAllGuaiWu()
	self.BG_img.sprite = nil
end

function C:on_rxcq_jzsc_out()
	self.BG_img.sprite = GetTexture(map[RXCQModel.BetIndex])
	self.BG_img.gameObject.transform.localScale = Vector3.New(1.1,1.1,1.1)
end