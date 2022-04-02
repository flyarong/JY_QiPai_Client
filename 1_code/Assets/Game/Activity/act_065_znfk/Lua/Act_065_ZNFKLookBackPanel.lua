-- 创建时间:2020-08-13
-- Panel:Act_065_ZNFKLookBackPanel
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

Act_065_ZNFKLookBackPanel = basefunc.class()
local C = Act_065_ZNFKLookBackPanel
C.name = "Act_065_ZNFKLookBackPanel"
local M = Act_065_ZNFKManager
local config = {
	[1] = {level = {"VIP0"},award = {[1] = { img = "eznhk_icon_1",txt = "鲸币礼包",tips ="鲸币礼包：最高可获得10万鲸币！",tishi="最高可获得10万鲸币!"}}},
	[2] = {level = {"VIP1、2"},award = { [1] = {img = "xyznq_icon_hjbx",txt = "黄金宝箱",tips ="黄金宝箱：最高可获得50万鲸币！",tishi="最高可获得50万鲸币!"}}},
	[3] = {level = {"VIP3、4"},award = {[1] = { img = "xyznq_icon_bjbx",txt = "铂金宝箱",tips ="铂金宝箱：最高可获得100万鲸币！",tishi="最高可获得100万鲸币!"}}},
	[4] = {level = {"VIP5、6、7"},award = { [1] = {img = "xyznq_icon_zsbx",txt = "钻石宝箱",tips ="钻石宝箱：最高可获得100万鲸币！",tishi="最高可获得100万鲸币!"}}},
	[5] = {level = {"VIP8、9"},award = {[1] = { img = "xyznq_icon_zsbx",txt = "钻石宝箱",tips ="钻石宝箱：最高可获得200万鲸币！"},[2] = { img = "xyznq_icon_jnbz",txt = "纯银纪念币",tips ="纯银纪念币：纯银10g纪念币"}}},
	[6] = {level = {"VIP10"},award = {[1] = { img = "xyznq_icon_wzbx",txt = "王者宝箱",tips ="钻石宝箱：最高可获得500万鲸币！"},[2] = { img = "xyznq_icon_djjnbz",txt = "纯银镀金纪念币",tips ="纯银镀金纪念币：纯银20g镀金纪念币"}}},
	[7] = {level = {"VIP11、12"},award = {[1] = { img = "xyznq_icon_wzbx",txt = "王者宝箱",tips ="王者宝箱：最高可获得500万鲸币！"},[2] = { img = "xyznq_icon_hjysxl",txt = "黄金羽毛吊坠",tips ="黄金羽毛吊坠：黄金羽毛吊坠大版"}}},
}
local vip_config = {{0},{1,2},{3,4},{5,6,7},{8,9},{10},{11,12}}


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
	self.lister["model_task_change_msg"] = basefunc.handler(self,self.on_model_task_change_msg)
	self.lister["get_task_award_response"] = basefunc.handler(self,self.on_get_task_award_response)
	self.lister["share_image_exit"] = basefunc.handler(self, self.share_image_exit)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()

    self.huxiL.Stop()
    self.huxiR.Stop()

	self.Hy:MyExit()
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:ctor()
	ExtPanel.ExtMsg(self)
	local parent = GameObject.Find("Canvas/LayerLv5").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	self.Hy = CommonHYAnim.Create(self.Content,1,true)
	self.Hy:OnIndexCall(
		function(index)
			self:ButtonHideOrShow(index)
		end
	)
	self:MakeLister()
	self:AddMsgListener()
	self:InitAwardUI(config[self:GetCurVIPLevel()].award,self.AwardNode)
	self:InitUI()
	self.str = gameMgr:getMarketPlatform() == "wqp" and "玩棋牌斗地主" or "彩云麻将"
	self.t1_txt.text = "我第一次进入<color=#B83922>".. self.str .. "</color>"
	self.t11_txt.text = "我与<color=#B83922>".. self.str .. "</color>共同度过"
	self.thank_txt.text = "感谢您对游戏的的热爱 为您献上周年回馈礼"
end

function C:InitUI()
	self.close_btn.onClick:AddListener(
		function()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
			self:MyExit()
		end
	)
	self.left_btn.onClick:AddListener(
		function()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
			self.Hy:GoLast()
		end
	)
	self.right_btn.onClick:AddListener(
		function()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
			self.Hy:GoNext()
		end
	)
	self.share_btn.onClick:AddListener(
		function()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
			self.ZNQ_guang_lookback.gameObject:SetActive(false)
			--local b = Act_065_ZNFKSharePrefabMake.Create()
			self:Share()
			local data = GameTaskModel.GetTaskDataByID(M.GetTaskID())
			dump(M.GetLevel(),"<color=red>等级+++</color>")
			dump(M.GetTaskID(),"<color=red>任务ID</color>")
			dump(data,"<color=red>任务数据</color>")
			dump(M.IsAwardCanGet(),"<color=red>x</color>")
	
		end
	)
	self.get_btn.onClick:AddListener(
		function()
			self:GetTaskAward()
		end)
	self:MyRefresh()
	self:RefreshMyGetBtn()

	self.huxiL = CommonHuxiAnim.Go(self.left_btn.gameObject,1.1,0.9,1)
	self.huxiL.Start()

    self.huxiR = CommonHuxiAnim.Go(self.right_btn.gameObject,1.1,0.9,1)
    self.huxiR.Start()
end

function C:Share()
	local share_cfg = basefunc.deepcopy(share_link_config.img_year3rd)
	GameManager.GotoUI({gotoui = "sys_fx", goto_scene_parm = "image", share_cfg = share_cfg})
end

function C:GetTaskAward()
	Network.SendRequest("get_task_award", {id = M.GetTaskID()})
end

function C:RefreshMyGetBtn()
	local data = GameTaskModel.GetTaskDataByID(M.GetTaskID())
	self.get_btn.gameObject:SetActive(data.award_status == 1)
	self.share_btn.gameObject:SetActive(data.award_status ~= 1)
	self.geted_after_share.gameObject:SetActive(data.award_status ~= 2)
end

function C:on_get_task_award_response(_, data)
	dump(data, "<color=red>++++on_get_task_award_response+++</color>")
	if data and data.id == M.GetTaskID() then
		local award_config = config[M.GetLevel()].award
		if #award_config > 1 then
			local _image = award_config[2].img
			local _text = award_config[2].txt
			RealAwardPanel.Create({ image = _image, text = _text })
		end
 	end
end

function C:ButtonHideOrShow(index)
	self.right_btn.gameObject:SetActive(not (index == 3))
	self.left_btn.gameObject:SetActive(not (index == 1))
end

function C:MyRefresh()
	self:RefreshAwardStatus()
	local data = M.GetData()
	self.first_time_txt.text = os.date("<color=#BD1C1C>%Y</color>年<color=#BD1C1C>%m</color>月<color=#BD1C1C>%d</color>日",data.first_login_time)
	self.day_txt.text = math.floor(((os.time() - data.first_login_time) / 86400))
	self.MaxMoney_txt.text = StringHelper.ToCash(data.most_money)
	self.day1_txt.text = os.date("<color=#BD1C1C>%Y</color>年<color=#BD1C1C>%m</color>月<color=#BD1C1C>%d</color>日",data.most_money_time).."\n历史拥有最大财富："
	self.day2_txt.text = os.date("<color=#BD1C1C>%Y</color>年<color=#BD1C1C>%m</color>月<color=#BD1C1C>%d</color>日",data.once_win_most_time)
	self.WinMoney_txt.text = StringHelper.ToCash(data.once_win_most_win_money)
	self.max_game_name_txt.text = "在<color=#BD1C1C>" .. Act_065_ZNFKManager.gameName2Imgs[data.once_win_most_game_name][1] .. "</color>中单笔赢得"
end

function C:InitAwardUI(award_config,obj)
	self.award_ui = {}
	for i = 1,#award_config do
		local temp_ui = {}
		local b = GameObject.Instantiate(self.MoneyItem,obj.transform)
		b.gameObject:SetActive(true)
		LuaHelper.GeneratingVar(b.transform,temp_ui)
		temp_ui.award_txt.text = award_config[i].txt
		temp_ui.award_img.sprite = GetTexture(award_config[i].img)
		temp_ui.award_img:SetNativeSize()
		self.award_ui[#self.award_ui + 1] = temp_ui
	end
end

function C:GetCurVIPLevel()
	return M.GetLevel() or 1
end

function C:on_model_task_change_msg(data)
	dump(data, "<color=red>++++on_model_task_change_msg+++</color>")
	if data and data.id == M.GetTaskID() then
		self:RefreshMyGetBtn()
		if IsEquals(self.gameObject) then
			for i = 1,#self.award_ui do
				if self.award_ui[i] then
					self:RefreshAwardStatus()
				end
			end
		end
	end
end

function C:RefreshAwardStatus()	
	if IsEquals(self.gameObject) then
		local data = GameTaskModel.GetTaskDataByID(M.GetTaskID())
		for i = 1,#self.award_ui do			
			if data then
				self.award_ui[i].Mask.gameObject:SetActive(data.award_status == 2)
			end
		end
	end
end

function C:share_image_exit()
	local data = GameTaskModel.GetTaskDataByID(M.GetTaskID())
	if data and data.award_status == 2 then
		LittleTips.Create("奖励已领取")
	end
end