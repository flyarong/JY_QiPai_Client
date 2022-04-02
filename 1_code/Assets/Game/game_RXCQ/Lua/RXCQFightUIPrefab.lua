-- 创建时间:2021-02-04
-- Panel:RXCQFightUIPrefab
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

RXCQFightUIPrefab = basefunc.class()
local C = RXCQFightUIPrefab
C.name = "RXCQFightUIPrefab"

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
	self.lister["AssetChange"] = basefunc.handler(self, self.OnAssetChange)
	self.lister["rxcq_query_game_history_response"] = basefunc.handler(self,self.on_rxcq_query_game_history_response)
	self.lister["rxcq_bet_change"] = basefunc.handler(self,self.on_rxcq_bet_change)
	self.lister["rxcq_new_lottery_ready"] = basefunc.handler(self,self.on_rxcq_new_lottery_ready)
	self.lister["rxcq_clear_over"] = basefunc.handler(self,self.on_rxcq_clear_over)
	self.lister["model_rxcq_all_info_response"] = basefunc.handler(self,self.on_model_rxcq_all_info_response)
	self.lister["bet_rate_list_change"] = basefunc.handler(self,self.on_bet_rate_list_change)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	if self.check_timer then
		self.check_timer:Stop()
	end
	if self.game_btn_pre then
		self.game_btn_pre:MyExit()
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

function C:ctor(parent)
	ExtPanel.ExtMsg(self)
	local parent = parent or GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	self.bet_index = 1
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	RXCQModel.SetRegisterObj("RXCQFightUIPrefab_help_btn",self.help_btn)
	RXCQModel.SetRegisterObj("RXCQFightUIPrefab_back_btn",self.back_btn)
	RXCQModel.SetRegisterObj("RXCQFightUIPrefab_history_btn",self.history_btn)
	RXCQModel.SetRegisterObj("RXCQFightUIPrefab_player_info",self.player_info)
	RXCQModel.SetRegisterObj("RXCQFightUIPrefab_bet",self.bet)
	RXCQModel.SetRegisterObj("RXCQFightUIPrefab_mini",self.mini)

	self.mini.gameObject:SetActive(true)
	self.out.gameObject:SetActive(false)

	self.check_timer = Timer.New(function()
		if self.lock then
			self.add_bet_btn.enabled = false
			self.red_bet_btn.enabled = false
			self.mian_btn.enabled = false
			self.pay_btn.gameObject:SetActive(false)
		else
			self.add_bet_btn.enabled = true
			self.red_bet_btn.enabled = true
			self.mian_btn.enabled = true
			self.pay_btn.gameObject:SetActive(true)
		end
		RXCQLogic.SetIsLock(self.lock)
	end,0.1,-1,nil,true)
	self.check_timer:Start()
	self.bet_index = self:GetUserBet()
	RXCQModel.SetBetIndex(self.bet_index)
	Event.Brocast("rxcq_bet_change")
	RXCQModel.DelayCall(function()
		self:CreateHistroyItem()
	end,2)
	self:InitExtraBetUI()
	self:on_bet_rate_list_change()

	local btn_map = {}
	btn_map["left_top"] = {self.left_top}
    self.game_btn_pre = GameButtonPanel.Create(btn_map, "rxcq_game")
end

function C:InitUI()
	self.open_out_btn.onClick:AddListener(
		function()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
			self.out.gameObject:SetActive(true)
		end
	)
	self.close_out_btn.onClick:AddListener(
		function()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
			self.out.gameObject:SetActive(false)
		end
	)
	self.help_btn.onClick:AddListener(
		function()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
			RXCQHelpPanel.Create()
		end
	)
	self.pay_btn.onClick:AddListener(
		function()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
			PayPanel.Create(GOODS_TYPE.jing_bi, "normal")
		end
	)
	self.back_btn.onClick:AddListener(
		function()
			if self.lock then 
				HintPanel.Create(1,"当前无法退出游戏哦~")
				return 
			end
			ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
			RXCQLogic.quit_game()
		end
	)
	URLImageManager.UpdateHeadImage(MainModel.UserInfo.head_image, self.head_img)
	self.playname_txt.text = MainModel.UserInfo.name
	self.curr_show_money = MainModel.UserInfo.jing_bi
	self.gold_txt.text = StringHelper.ToCash(self.curr_show_money)
	self.add_bet_btn.onClick:AddListener(
		function()
			if self.lock then return end
			RXCQModel.player_chuansong_type = "normal"
			ExtendSoundManager.PlaySound(audio_config.rxcq.rxcq_reductionchange.audio_name)
			local te = self.bet_index + 1
			if te > #rxcq_main_config.base then
				te = 1
			end 
			local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key="rxcq_bet_".. te,vip_hint_type = 2, cw_btn_desc = "确定"}, "CheckCondition")
			if a and not b then
				return
			end
			self.bet_index = self.bet_index + 1
			if self.bet_index > #rxcq_main_config.base then
				self.bet_index = 1
			end
			RXCQModel.SetBetIndex(self.bet_index)
			Event.Brocast("rxcq_bet_change")
		end
	)
	self.red_bet_btn.onClick:AddListener(
		function()
			if self.lock then return end
			RXCQModel.player_chuansong_type = "normal"
			ExtendSoundManager.PlaySound(audio_config.rxcq.rxcq_reductionchange.audio_name)
			local te = self.bet_index - 1
			if te == 0 then
				te = #rxcq_main_config.base
			end
			local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key="rxcq_bet_".. te,vip_hint_type = 2, cw_btn_desc = "确定"}, "CheckCondition")
			if a and not b then
				return
			end
			self.bet_index = self.bet_index - 1
			if self.bet_index == 0 then
				self.bet_index = #rxcq_main_config.base
			end
			RXCQModel.SetBetIndex(self.bet_index)
			Event.Brocast("rxcq_bet_change")
		end
	)
	PointerEventListener.Get(self.mian_btn.gameObject).onDown = function ()
		self:MainBtnDown()
	end
	PointerEventListener.Get(self.mian_btn.gameObject).onUp = function ()
		self:MainBtnUp()
	end
	self.history_btn.onClick:AddListener(
		function()
			RXCQHistoryPanel.Create()
		end
	)
	self.mian_btn_img = self.mian_btn.gameObject.transform:GetComponent("Image")
	self:MyRefresh()
end

function C:MainBtnDown()
	if self.main_btn_timer then
		self.main_btn_timer:Stop()
	end
	self.main_btn_down_time = 0
	self.main_btn_timer = Timer.New(
		function()
			self.main_btn_down_time = self.main_btn_down_time + 0.02
			if self.main_btn_down_time > 2 then
				self.gongji_img.sprite = GetTexture("cq_imgf_qxzd")
				self.goji_img.sprite = GetTexture("cq_imgf_zdgj")
				self.mian_btn_img.sprite = GetTexture("cq_btn_zdgj")
				self.goji_img:SetNativeSize()
			end
		end
	,0.02,-1)
	self.main_btn_timer:Start()
end

function C:MainBtnUp()
	dump(self.main_btn_down_time,"<color=red>按下时间</color>")
	if self.main_btn_timer then
		self.main_btn_timer:Stop()
	end
	if self.main_btn_down_time > 2 then
		dump(self.lock,"<color=red>解锁状态+++++++++++</color>")
		RXCQModel.Is_Auto = true
		self.gongji_img.sprite = GetTexture("cq_imgf_qxzd")
		self.goji_img.sprite = GetTexture("cq_imgf_zdgj")
		self.goji_img:SetNativeSize()
		self.mian_btn_img.sprite = GetTexture("cq_btn_zdgj")
		if not self.lock then
			if MainModel.UserInfo.jing_bi < self:GetExpend() then
				PayPanel.Create(GOODS_TYPE.jing_bi, "normal")
				return
			end
			self.curr_show_money = MainModel.UserInfo.jing_bi - self:GetExpend()
			self.gold_txt.text = StringHelper.ToCash(self.curr_show_money)
			Network.SendRequest("rxcq_kaijiang",{bet_id = RXCQModel.BetIndex,bet_rate_list = RXCQModel.BetRateList})
			self.lock = true
		end
	else
		RXCQModel.Is_Auto = false
		self.gongji_img.sprite = GetTexture("cq_imgf_cazd")
		self.goji_img.sprite = GetTexture("cq_imgf_gj")
		self.goji_img:SetNativeSize()
		self.mian_btn_img.sprite = GetTexture("cq_btn_gj")
		dump(self.lock,"<color=red>解锁状态+++++++++++</color>")
		if not self.lock then
			if MainModel.UserInfo.jing_bi < self:GetExpend() then
				PayPanel.Create(GOODS_TYPE.jing_bi, "normal")
				return
			end
			self.curr_show_money = MainModel.UserInfo.jing_bi - self:GetExpend()
			self.gold_txt.text = StringHelper.ToCash(self.curr_show_money)			
			Network.SendRequest("rxcq_kaijiang",{bet_id = RXCQModel.BetIndex,bet_rate_list = RXCQModel.BetRateList})
			self.lock = true
		end
	end
end

function C:on_rxcq_new_lottery_ready()
	if RXCQModel.Is_Auto == true then
		if not self.lock then
			if MainModel.UserInfo.jing_bi < self:GetExpend() then
				PayPanel.Create(GOODS_TYPE.jing_bi, "normal")
				RXCQModel.Is_Auto = false
				self.gongji_img.sprite = GetTexture("cq_imgf_cazd")
				self.goji_img.sprite = GetTexture("cq_imgf_gj")
				self.goji_img:SetNativeSize()
				self.mian_btn_img.sprite = GetTexture("cq_btn_gj")
				self.is_auto_repeat = false
				self:refresh_auto()
				return
			end
			self.curr_show_money = MainModel.UserInfo.jing_bi - self:GetExpend()
			self.gold_txt.text = StringHelper.ToCash(self.curr_show_money)			
			Network.SendRequest("rxcq_kaijiang",{bet_id = RXCQModel.BetIndex,bet_rate_list = RXCQModel.BetRateList})
			self.lock = true
		end
	end
end

function C:on_rxcq_bet_change()
	Util.ClearMemory()
	RXCQModel.ClearBetRateList()
	self.bet_num_txt.text = StringHelper.ToCash(rxcq_main_config.base[RXCQModel.BetIndex].Bet)
end

function C:MyRefresh()
	
end

function C:on_rxcq_query_game_history_response(_,data)
	dump(data,"<color=red>数据+++++++++++++++++++++++++++++++++++++++++++++++++</color>")
	if data then

	end
end

function C:on_rxcq_clear_over()
	Util.ClearMemory()
	self:ClearToStart()
	RXCQModel.ClearBetRateList()
	if self.is_auto_repeat then
		if MainModel.UserInfo.jing_bi < self:GetExpend() then
			self.is_auto_repeat = false
			self:refresh_auto()
		else
			RXCQModel.ReSetBetRateList()
		end
	end
	self:CreateHistroyItem()
end

function C:on_model_rxcq_all_info_response()
	self:ClearToStart()
	RXCQModel.Is_Auto = false
	self.gongji_img.sprite = GetTexture("cq_imgf_cazd")
	self.goji_img.sprite = GetTexture("cq_imgf_gj")
	self.goji_img:SetNativeSize()
	self.mian_btn_img.sprite = GetTexture("cq_btn_gj")
end

function C:ClearToStart()
	self.lock = false
	self.curr_show_money = MainModel.UserInfo.jing_bi
	self.gold_txt.text = StringHelper.ToCash(self.curr_show_money)
end

function C:OnAssetChange(data)
	dump(data,"<color=red>数据+++++++++++++++++++++++++++++++</color>")
	if data.change_type == "rxcq_game_award" or data.change_type == "rxcq_bet_spend" then
	else
		local sum = 0
		for i = 1,#data.data do
			if data.data[i].asset_type == "jing_bi" then
				sum = sum + data.data[i].value
			end
		end
		self.curr_show_money = self.curr_show_money + sum
		self.gold_txt.text = StringHelper.ToCash(self.curr_show_money)
	end
end

function C:GetUserBet()
	local data =
		{
			[1]=
			{
				line = 1,
				min = 0,
				max = 5000,
			},
			[2]=
			{
				line = 2,
				min = 5000,
				max = 20000,
			},
			[3]=
			{
				line = 3,
				min = 20000,
				max = 40000,
			},
			[4]=
			{
				line = 4,
				min = 40000,
				max = 80000,
			},
			[5]=
			{
				line = 5,
				min = 80000,
				max = 160000,
			},
			[6]=
			{
				line = 6,
				min = 160000,
				max = 320000,
			},
			[7]=
			{
				line = 7,
				min = 320000,
				max = 640000,
			},
			[8]=
			{
				line = 8,
				min = 640000,
				max = 1280000,
			},
			[9]=
			{
				line = 9,
				min = 1280000,
				max = 2560000,
			},
			[10]=
			{
				line = 10,
				min = 2560000,
				max = 5120000,
			},
			[11]=
			{
				line = 11,
				min = 5120000,
			},
		}
	local qx_max = #data
    for i=#data,1,-1 do
        local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key="rxcq_bet_".. i, is_on_hint=true,vip_hint_type = 2, cw_btn_desc = "确定"}, "CheckCondition")
        if not a or b then
            qx_max = i
            break
        end 
	end
	dump(qx_max,"<color=red>权限允许的最高等级</color>")
    for i = qx_max,1,-1 do
        if not data[i].min or MainModel.UserInfo.jing_bi >= data[i].min then 
            return i
        end 
    end
    return 1
end

function C:CreateHistroyItem()
	local config = {
		BanYueWanDao = "cq_icon_by1",
		CiShaJianShu = "cq_icon_cs1",
		GongShaJianShu = "cq_icon_gs1",
		LieHuoJianFa = "cq_icon_lh1",
	}
	if self.history_items then
		for i = 1,#self.history_items do
			destroy(self.history_items[i].gameObject)
		end
	end
	self.history_items = {}
	for i = 1,#RXCQModel.HistoryData do
		if not RXCQModel.IsMiniGame(RXCQModel.HistoryData[i].cid) then
			if #RXCQModel.HistoryData[i].monster > 0 then
				local temp_ui = {}
				local b = GameObject.Instantiate(self.history_item,self.history_node)
				b.gameObject:SetActive(true)
				LuaHelper.GeneratingVar(b.transform,temp_ui)
				temp_ui.main_img.sprite = GetTexture(config[RXCQModel.GetSkillNameByCid(RXCQModel.HistoryData[i].cid)])
				self.history_items[#self.history_items + 1] = b
				if #self.history_items >= 6 then
					break
				end
			end
		end
	end

	local config2 = {
		BanYueWanDao = 3,
		CiShaJianShu = 2,
		GongShaJianShu = 1,
		LieHuoJianFa = 4,
	}
	if self.history_items2 then
		for i = 1,#self.history_items2 do
			destroy(self.history_items2[i].gameObject)
		end
	end
	self.history_items2 = {}
	for i = 1,#RXCQModel.HistoryData do
		if not RXCQModel.IsMiniGame(RXCQModel.HistoryData[i].cid) then
			if #RXCQModel.HistoryData[i].monster > 0 then
				local temp_ui = {}
				local b = GameObject.Instantiate(self.list_item,self.Content)
				b.gameObject:SetActive(true)
				LuaHelper.GeneratingVar(b.transform,temp_ui)
				temp_ui["tip"..config2[RXCQModel.GetSkillNameByCid(RXCQModel.HistoryData[i].cid)]].gameObject:SetActive(true)
				self.history_items2[#self.history_items2 + 1] = b
				if #self.history_items2 >= 50 then
					break
				end
			end
		end
	end
end

--额外买ma
function C:InitExtraBetUI()
	--技能对应的编号
	local config = {
		GongShaJianShu = 1,
		CiShaJianShu = 2,
		BanYueWanDao = 3,
		LieHuoJianFa = 4,
	}
	self.gongshajianshu_btn.onClick:AddListener(
		function()
			if self.lock then return end
			if not self:IsCanRate() then return end
			RXCQModel.AddBetRateList(1)
		end
	)
	self.cishajianshu_btn.onClick:AddListener(
		function()
			if self.lock then return end
			if not self:IsCanRate() then return end
			RXCQModel.AddBetRateList(2)
		end
	)
	self.banyuewandao_btn.onClick:AddListener(
		function()
			if self.lock then return end
			if not self:IsCanRate() then return end
			RXCQModel.AddBetRateList(3)
		end
	)
	self.liehuodaofa_btn.onClick:AddListener(
		function()
			if self.lock then return end
			if not self:IsCanRate() then return end
			RXCQModel.AddBetRateList(4)
		end
	)
	self.gongshajianshu_add_btn.onClick:AddListener(
		function()
			if self.lock then return end
			if not self:IsCanRate() then return end
			RXCQModel.AddBetRateList(1)
		end
	)
	self.cishajianshu_add_btn.onClick:AddListener(
		function()
			if self.lock then return end
			if not self:IsCanRate() then return end
			RXCQModel.AddBetRateList(2)
		end
	)
	self.banyuewandao_add_btn.onClick:AddListener(
		function()
			if self.lock then return end
			if not self:IsCanRate() then return end
			RXCQModel.AddBetRateList(3)
		end
	)
	self.liehuodaofa_add_btn.onClick:AddListener(
		function()
			if self.lock then return end
			if not self:IsCanRate() then return end
			RXCQModel.AddBetRateList(4)
		end
	)

	self.unmake_btn.onClick:AddListener(
		function()
			if self.lock then return end
			RXCQModel.ClearBetRateList()
		end
	)
	self.repeat_btn.onClick:AddListener(
		function()
			if self.lock then return end
			RXCQModel.ReSetBetRateList()
		end
	)
	self.is_auto_repeat = false
	self.auto_repeat_btn_img = self.auto_repeat_btn.gameObject.transform:GetComponent("Image")
	self:refresh_auto()
	self.auto_repeat_btn.onClick:AddListener(
		function()
			if self.lock then return end
			self.is_auto_repeat = not self.is_auto_repeat
			self:refresh_auto()
		end
	)
end

function C:refresh_auto()
	if self.is_auto_repeat then
		self.auto_repeat_btn_img.sprite = GetTexture("rxcq_button_2")
	else
		self.auto_repeat_btn_img.sprite = GetTexture("rxcq_button_1")
	end
	self.auto_repeat1.gameObject:SetActive( not self.is_auto_repeat)
	self.auto_repeat2.gameObject:SetActive(self.is_auto_repeat)
	self.auto_tips.gameObject:SetActive(self.is_auto_repeat)
end

function C:on_bet_rate_list_change()
	self.gongshajianshu_txt.text = "x"..RXCQModel.BetRateList[1] + 1
	self.cishajianshu_txt.text = "x"..RXCQModel.BetRateList[2] + 1
	self.banyuewandao_txt.text = "x"..RXCQModel.BetRateList[3] + 1
	self.liehuodaofa_txt.text = "x"..RXCQModel.BetRateList[4] + 1

	self.gongshajianshu_add_txt.text = "威力".."x"..RXCQModel.BetRateList[1] + 1
	self.cishajianshu_add_txt.text = "威力".."x"..RXCQModel.BetRateList[2] + 1
	self.banyuewandao_add_txt.text = "威力".."x"..RXCQModel.BetRateList[3] + 1
	self.liehuodaofa_add_txt.text = "威力".."x"..RXCQModel.BetRateList[4] + 1

	self.gongshajianshu_add_txt.gameObject:SetActive(RXCQModel.BetRateList[1] ~= 0)
	self.cishajianshu_add_txt.gameObject:SetActive(RXCQModel.BetRateList[2] ~= 0)
	self.banyuewandao_add_txt.gameObject:SetActive(RXCQModel.BetRateList[3] ~= 0)
	self.liehuodaofa_add_txt.gameObject:SetActive(RXCQModel.BetRateList[4] ~= 0)
	self.gongshajianshu_txt.gameObject:SetActive(RXCQModel.BetRateList[1] ~= 0)
	self.cishajianshu_txt.gameObject:SetActive(RXCQModel.BetRateList[2] ~= 0)
	self.banyuewandao_txt.gameObject:SetActive(RXCQModel.BetRateList[3] ~= 0)
	self.liehuodaofa_txt.gameObject:SetActive(RXCQModel.BetRateList[4] ~= 0)
	self.gongshajianshu_bei.gameObject:SetActive(RXCQModel.BetRateList[1] ~= 0)
	self.cishajianshu_bei.gameObject:SetActive(RXCQModel.BetRateList[2] ~= 0)
	self.banyuewandao_bei.gameObject:SetActive(RXCQModel.BetRateList[3] ~= 0)
	self.liehuodaofa_bei.gameObject:SetActive(RXCQModel.BetRateList[4] ~= 0)
end

function C:GetExpend()
	local num = 1
	for i = 1,#RXCQModel.BetRateList do
		num = num + RXCQModel.BetRateList[i]
	end
	return num * rxcq_main_config.base[RXCQModel.BetIndex].Bet
end

function C:IsCanRate()
	local _permission_key = "rxcq_bet_rate"
    -- 对应权限的key
    if _permission_key then
        local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key=_permission_key, vip_hint_type = 2, cw_btn_desc = "确定"}, "CheckCondition")
        if a and not b then
            return false
        end
        return true
    else
        return true
    end
end