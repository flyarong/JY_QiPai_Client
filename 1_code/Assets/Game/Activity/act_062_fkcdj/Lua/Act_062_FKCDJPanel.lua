-- 创建时间:2021-07-05
-- Panel:Act_062_FKCDJPanel
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

Act_062_FKCDJPanel = basefunc.class()
local C = Act_062_FKCDJPanel
C.name = "Act_062_FKCDJPanel"
local M = Act_062_FKCDJManager


local State = {
	wait = "wait",
	lottery = "lottery",
	endlottery = "endlottery",
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
    self.lister["model_fkcdj_asset_change"] = basefunc.handler(self, self.on_model_fkcdj_asset_change)
    self.lister["model_fkcdj_task_change"] = basefunc.handler(self, self.on_model_fkcdj_task_change)
    self.lister["box_exchange_response"] = basefunc.handler(self, self.on_box_exchange_response)
	self.lister["query_fake_data_response"] = basefunc.handler(self, self.AddPMD)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	self:CheckShowAward()
	if self.runTimer then
		self.runTimer:Stop()
		self.runTimer = nil
	end
	if self.checkTimer then
		self.checkTimer:Stop()
		self.checkTimer = nil
	end
	if self.UpdatePMD then
        self.UpdatePMD:Stop()
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
	
	self:MakeLister()
	self:AddMsgListener()

	self.realCfg = {
		[13430] = {text = "电热毯",image = "activity_icon_gift307_drt"},
		[13431] = {text = "小太阳",image = "activity_icon_gift245_xty"},
		[13432] = {text = "大米",image = "activity_icon_gift308_jlydm"},
		[13433] = {text = "大豆油",image = "activity_icon_gift227_ddy"},
		[13434] = {text = "大枣夹核桃",image = "activity_icon_gift217_dzjht"},
		[13435] = {text = "鸡蛋面",image = "activity_icon_gift223_jlyjdm"},
	}
	self.pmdCfg = {
		[13430] = "电热毯",
		[13431] = "小太阳",
		[13432] = "大米",
		[13433] = "大豆油",
		[13434] = "大枣夹核桃",
		[13435] = "鸡蛋面",
		[13436] = "鲸币",
		[13437] = "鱼币",
		[13438] = "高级游戏卡碎片",
		[13439] = "10元充值优惠券",
		[13440] = "中级游戏卡碎片",
		[13441] = "鲸币",
		[13442] = "鱼币",
	}

	self.ruleCfg = {
		[1] = "1.活动时间：11月9日7:30:00~11月15日23:59:59",
		[2] = "2.活动结束后将清除所有礼盒道具，请及时使用",
		[3] = "3.实物奖励请联系客服QQ公众号：4008882620",
		[4] = "4.实物奖励图片仅供参考，请以实际收到的奖励为准（注：利用游戏漏洞获得的一切奖励将全部被扣除）",
	}
	self:InitUI()
end

function C:InitUI()
	
	self.lottery1_btn.onClick:AddListener(
		function()
			self:OnClickLottery(1)
		end
    )
    self.lottery10_btn.onClick:AddListener(
		function()
			self:OnClickLottery(10)
		end
    )
    self.help_btn.onClick:AddListener(
		function()
			self:OpenHelpPanel()
		end
    )
	self:InitBoxUI()
	self:InitItem()
	self:MyRefresh()
	self:RefreshItem()
	CommonTimeManager.GetCutDownTimer(1636991999, self.cur_time_txt)
    self.pmd_cont = CommonPMDManager.Create({ parent = self.pmd_node, speed = 15, space_time = 10, start_pos = 500, end_pos = -800 })
	self:UpDatePMD()
	self:MakeCheckPMDInViewTimer()
	self.state = State.wait
end

function C:InitBoxUI()
	local cfg = M.GetBoxCfg()
	for i = 1, 5 do
		self["can"..i.."_get_btn"].onClick:AddListener(function ()
				ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
				Network.SendRequest("get_task_award_new", {id = 21855, award_progress_lv = i}) 
			end)
		self["tip"..i.."_btn"].onClick:AddListener(function ()
				LTTipsPrefab.Show2(self["tip"..i.."_btn"].transform, cfg[i].tip_name, cfg[i].tip_desc)
			end)
	end
end

--[1,10]
function C:OnClickLottery(lottery_times)
	if self.state == State.lottery then
		LittleTips.Create("抽奖中")
		return
	end
	local curIndex
	if lottery_times == 1 then
		curIndex = self.lottery1Index
	elseif lottery_times == 10 then
		curIndex = self.lottery10Index
	end
	local cfg = M.GetLotteryCfg(curIndex)
	if M.GetItemCount(curIndex) < cfg.lottery_consume * lottery_times then
        LittleTips.Create(GameItemModel.GetItemToKey(cfg.lottery_item).name ..  "不足")
		return
	end
	dump({ id = cfg.box_change_id, num = lottery_times }, "<color=red>疯狂抽大奖:进行抽奖</color>")
	Network.SendRequest("box_exchange", { id = cfg.box_change_id, num = lottery_times })
end

function C:MyRefresh()
end

function C:RefreshItem()
	self.lottery1Index = M.GetCurConsume(1)
	self.lottery10Index = M.GetCurConsume(2)
	self:RefreshItemUI()
end

function C:RefreshItemUI()
	self.item1_txt.text = "x" .. M.GetItemCount(2) / 100
	self.item2_txt.text = "x" .. M.GetItemCount(1)

	self:RefreshLotteryBtn(self.lottery1Index, self.lottery1_img, self.lottery1_txt, self.lottery1_btn, 1)
	self:RefreshLotteryBtn(self.lottery10Index, self.lottery10_img, self.lottery10_txt, self.lottery10_btn, 10)
end

function C:RefreshLotteryBtn(index, imageObj, txtObj, btnObj,times)
	local cfg = M.GetLotteryCfg(index)
	imageObj.sprite = GetTexture(cfg.image)
	if cfg.lottery_item == "shop_gold_sum" then
		txtObj.text = cfg.lottery_consume * times / 100
	else
		txtObj.text = cfg.lottery_consume * times
	end
	local btnImg = btnObj:GetComponent("Image")
	local btnOutLine = btnObj.transform:Find("Text"):GetComponent("Outline")
	if M.GetItemCount(index) < cfg.lottery_consume * times then
		btnImg.sprite = GetTexture("ty_btn_lan")
		btnOutLine.effectColor = Color.New(27/255,66/255,129/255,1)
	else
		btnImg.sprite = GetTexture("ty_btn_huang1_com")
		btnOutLine.effectColor = Color.New(186/255,57/255,32/255,1)
	end
end

function C:RefreshBoxUI()
	self:RefreshBoxBtn()
	self:RefreshProgress()
end

function C:RefreshBoxBtn()
	local status = M.GetCurBoxStatus()
	for i=1,#status do
		self["can"..i.."_get_btn"].gameObject:SetActive(status[i] == 1)
		self["tip"..i.."_btn"].gameObject:SetActive(status[i] == 0)
		self["mask"..i].gameObject:SetActive(status[i] == 2)
	end
	status = nil
end

local offset_data = {
	{min = 0,max = 69},
	{min = 9,max = 115},
	{min = 9,max = 115},
	{min = 9,max = 115},
	{min = 9,max = 115},
}

local max_size_x = 115
local max_size_y = 21.08

function C:RefreshProgress()
	local cfg = M.GetBoxCfg()
	local data = M.GetCurBoxData()

	for i = 1, 5 do
		if i > data.now_lv then 
			self["p"..i].sizeDelta = {x = 0,y = max_size_y}
		end
		if i < data.now_lv then 
			self["p"..i].sizeDelta = {x = max_size_x,y = max_size_y}
		end
		if i == data.now_lv then 
			local rate = data.now_process / data.need_process 
			local dis = offset_data[i].max - offset_data[i].min 
			self["p"..i].sizeDelta = {x = offset_data[i].min + dis * rate ,y = max_size_y}
		end
		if data.now_total_process < cfg[i].times  then
			self["pg"..i]:GetComponent("Text").text = data.now_total_process .. "/" .. cfg[i].times 
		else
			self["pg"..i]:GetComponent("Text").text = cfg[i].times .. "/" .. cfg[i].times 
		end
	end
	cfg, data = nil
end

--**********************************************************
function C:on_model_fkcdj_asset_change(data)
	self:RefreshItem()
	
	self.awardData = data
	--self:TryToShow()
end

function C:on_model_fkcdj_task_change()
	self:RefreshBoxUI()
end

function C:on_box_exchange_response(_, data)
    dump(data, "<color=red>疯狂抽大奖:抽奖结果</color>")
    if data.result == 0 then
        self:AddMyPMD(data.award_id) --PMD Self
        local real_list = self:GetRealInList(data.award_id)
		local index = M.GetAwardIndex(data.award_id[1])
		self:StartScroll(index)
        dump(real_list, "<color=red>疯狂抽大奖:抽奖结果实物奖励</color>")
		-- 因为是必送积分
        -- if #real_list >= #data.award_id then
        --     RealAwardPanel.Create(self:GetShowData(real_list))
        -- else
            self.call = function()
                if not table_is_null(real_list) then
                    MixAwardPopManager.Create(self:GetShowData(real_list), nil, 2)
                end
            end
        --end
        --self:TryToShow()
    end
end

function C:GetRealInList(award_id)
	local r_list = {}
    local temp
    for i = 1, #award_id do
        temp = self.realCfg[award_id[i]]
        if temp then
            r_list[#r_list + 1] = temp
        end
    end
    return r_list
end

function C:GetShowData(real_list)
	local data = {}
    data.text = {}
    data.image = {}
    for i = 1, #real_list do
        data.text[#data.text + 1] = real_list[i].text
        data.image[#data.image + 1] = real_list[i].image
    end
    return data
end

function C:TryToShowAward()
	dump(self.awardData, "<color=red>疯狂抽大奖:奖励数据</color>")
	if self.awardData and self.call then
		dump(self.awardData, "<color=red>疯狂抽大奖:显示奖励</color>")
        self.call()
        Event.Brocast("AssetGet", self.awardData)
        self.awardData = nil
        self.call = nil
		self.state = State.wait
    end
end
--**********************************************************

local offSet = -383
local changeOff = 215
local t1 = 0.5   --1阶段的时间
local t2 = 1.5   --2阶段的时间

local v0 = 200
local v2 = 2000
local a1 = v2 / t1

local primaryX = function(index)
	return offSet + (index - 1) * changeOff
end

function C:InitItem()
	self.itemPre = {}
	local cfg = M.GetAwardsCfg()
	for i = 1, #cfg do
		local b = newObject("Act_062_FKCDJItem",self.viewRect)
		local bUI = {}
		LuaHelper.GeneratingVar(b.transform, bUI)
		bUI.name_txt.text = cfg[i].name
		bUI.num_txt.text = cfg[i].count
		bUI.icon_img.sprite = GetTexture(cfg[i].image)
		bUI.obj = b
		bUI.index = cfg[i].ID
		b.gameObject.name = i
		self.itemPre[#self.itemPre + 1] = bUI
	end
	self.returnPos = primaryX(-3) 

	self:RefreshItemPos()
	self:MakeRuntTimer()
	--self:StartScroll(3)
end

function C:RefreshItemPos(index)
	local index = index or 0
	for i = 1, #self.itemPre do
		local b = self.itemPre[i].obj
		b.gameObject.transform.localPosition = Vector2.New(primaryX(i) + index * changeOff, 0)
	end
end

function C:ResetRunTimer()
	self.isCheckShowAward = false
	self.cur_time = 0
end

function C:MakeRuntTimer()
	self.cur_time = 0
	self.cur_speed = 0
	self.change_diff = 0
	self.endP = primaryX(3)
	self.isCheckShowAward = false
	self.state = State.wait
	self.runTimer = Timer.New(function()
		local dt = Time.deltaTime
		local l = 0
		local a3 = 0
		if self.state == State.wait then
			self.cur_speed = v0
			self.change_diff = self.cur_speed * dt
		elseif self.state == State.lottery then
			if self.cur_time < t1 then
				self.cur_speed = self.cur_speed + a1 * dt
				self.change_diff = self.cur_speed * dt + 0.5 * a1 * dt * dt	
				if self.cur_speed > v2 then
					self.cur_speed = v2
				end
			elseif self.cur_time < t2 then
				self.cur_speed = v2	
				self.change_diff = self.cur_speed * dt
			else
				self.endIndex = self:GetCurIndex(self.lottery_index)
				self.startP = self.itemPre[self.endIndex].obj.gameObject.transform.localPosition.x
				if Mathf.Abs(self.startP - self.endP) < 0.1 or self.change_diff < 0.1 then
					dump("<color=red>滚动结束</color>")
					self.cur_speed = 0
					self.change_diff = 0
					self:CheckShowAward()
				else
					local a3 = - self.cur_speed * self.cur_speed / (2 * (self.startP - self.endP))
					self.cur_speed = self.cur_speed + a3 * dt
					self.change_diff = self.cur_speed * dt + 0.5 * a3 * dt * dt	
				end
			end
		end
		self.cur_time = self.cur_time + dt
		for i = 1, #self.itemPre do
			local b = self.itemPre[i].obj
			b.gameObject.transform.localPosition = Vector2.New(b.gameObject.transform.localPosition.x - self.change_diff , 0)
		end
		if self.itemPre[1].obj.gameObject.transform.localPosition.x < primaryX(-3) then
			self.itemPre[1].obj.gameObject.transform.localPosition = Vector2.New(primaryX(13), 0)
			local first = table.remove(self.itemPre, 1)
			table.insert(self.itemPre, first)
			self:RefreshItemPos(-3)
			--dump(tonumber(self.itemPre[1].index))
			first = nil
		end

		if isEnd then
			self:RefreshItemPos(-4)
			isEnd = false
		end
		dt, l , a3 = nil
	end, 0.016, -1)
	self.runTimer:Start()
end

function C:StartScroll(index)
	self.state = State.lottery
	self.lottery_index = index
	self:ResetRunTimer()
end

function C:CheckShowAward()
	if self.isCheckShowAward then
		return
	end
	dump("<color=red>滚动结束检测是否有奖励</color>")
	self.state = State.endlottery
	self:TryToShowAward()
	self.isCheckShowAward = true
end

function C:GetCurIndex(_index)
	for i = 1, #self.itemPre do
		if self.itemPre[i].index == _index then
			return i 
		end
	end
end
--**********************************************************

function C:UpDatePMD()
    if self.UpdatePMD then
        self.UpdatePMD:Stop()
    end
    Network.SendRequest("query_fake_data", { data_type = "crazy_lottery_20_11_10" })
    self.UpdatePMD = Timer.New(
        function()
			Network.SendRequest("query_fake_data", { data_type = "crazy_lottery_20_11_10" })
		end
    , 20, -1)
    self.UpdatePMD:Start()
end

function C:AddMyPMD(data)
    dump(data, "<color=red>PMD ADD</color>")
    if table_is_null(data) then return end
    local _data = data
    for i = 1, #_data do
        local cur_data_info = self.pmdCfg[_data[i]]
        if cur_data_info ~= nil then
            local cur_data_pmd = {}
            cur_data_pmd["result"] = 0
            cur_data_pmd["player_name"] = MainModel.UserInfo.name
            cur_data_pmd["award_data"] = tostring(cur_data_info)
            self:AddPMD(0, cur_data_pmd)
        end
    end
end

function C:AddPMD(_, data)
    dump(data, "<color=red>PMD</color>")
    if not IsEquals(self.gameObject) then return end
    if data and data.result == 0 then
        local b = GameObject.Instantiate(self.pmd_item, self.pmd_node)
        b.gameObject:SetActive(true)
        local temp_ui = {}
        LuaHelper.GeneratingVar(b.transform, temp_ui)
        temp_ui.t1_txt.text = "恭喜" .. data.player_name .. ",抽到" .. data.award_data
        UnityEngine.UI.LayoutRebuilder.ForceRebuildLayoutImmediate(b.transform)
        self.pmd_cont:AddObj(b)
    end
end

function C:OpenHelpPanel()
    local str = self.ruleCfg[1]
    for i = 2, #self.ruleCfg do
        str = str .. "\n" .. self.ruleCfg[i]
    end
    self.introduce_txt.text = str
    IllustratePanel.Create({ self.introduce_txt.gameObject }, GameObject.Find("Canvas/LayerLv5").transform)
end

function C:CheckAndActivePmgBg(isActive)
	if self.isShowPmgBg ~= isActive then
		self.pmd_bg.gameObject:SetActive(isActive)
		self.isShowPmgBg = isActive
	end
end

function C:MakeCheckPMDInViewTimer()
	self.pmd_bg.gameObject:SetActive(false)
	self.isShowPmgBg = false
	self.checkTimer = Timer.New(function()
		if self.pmd_node.transform.childCount > 0 then
			local isActiveBg = false
			for i = 1, self.pmd_node.transform.childCount do
				self.curPmd = self.pmd_node.transform:GetChild(i - 1)
				if self.curPmd.transform.localPosition.x < 400
				and self.curPmd.transform.localPosition.x > -400 then
					isActiveBg = true
				end
			end
			self:CheckAndActivePmgBg(isActiveBg)
			isActiveBg = nil
		else
			self:CheckAndActivePmgBg(false)
		end
	end, 0.2, -1)
	self.checkTimer:Start()
end