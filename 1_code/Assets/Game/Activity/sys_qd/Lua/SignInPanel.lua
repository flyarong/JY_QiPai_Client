-- 创建时间:2019-09-18
-- Panel:New Lua
--[[ *      ┌─┐       ┌─┐
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

SignInPanel = basefunc.class()
local C = SignInPanel
C.name = "SignInPanel"


local daySpr_normal =
	{ 
		"qrqd_imgf_dyt1",
		"qrqd_imgf_det1",
		"qrqd_imgf_dst1",
		"qrqd_imgf_d4t1",
		"qrqd_imgf_dwt1",
		"qrqd_imgf_dlt1",
	}

local daySpr_cur =
	{ 
		"qrqd_imgf_dyt2",
		"qrqd_imgf_det2",
		"qrqd_imgf_dst2",
		"qrqd_imgf_d4t2",
		"qrqd_imgf_dwt2",
		"qrqd_imgf_dlt2",
	}
local progressX = 
{
	[1] = {min =0,  max = 15 },
	[2] = {min =15, max = 138 },
	[3] = {min =138,max = 334 },
	[4] = {min =334,max = 553 },
	[5] = {min =553,max = 809 },
}

--Vip直通礼包的等级，如果大于Vip大于这个等级时前往商城
local vip_gifts_level = 5

SignInPanel.IsLj = false
function C.Create(backcall)
	DSM.PushAct({panel = C.name})
    return C.New(backcall)
end

function C:AddMsgListener()
    for proto_name, func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
	self.lister["query_sign_in_data_response"] = basefunc.handler(self, self.OnGetInfo)
	self.lister["model_vip_upgrade_change_msg"]=basefunc.handler(self,self.OnRefreshVipInfo)
	self.lister["AssetChange"] = basefunc.handler(self, self.OnAssetChange)
	self.lister["ExitScene"] = basefunc.handler(self, self.MyExit)
end

function C:RemoveListener()
    for proto_name, func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	DSM.PopAct()
	self:RemoveListener()
	
	if self.huxi then
		self.huxi:Stop()
		self.huxi = nil
	end

	if self.backcall then
		self.backcall()
	end

    destroy(self.gameObject)

	 
end

function C:OnAssetChange(data)
	dump(data,"<color=red>assetchange</color>")
	if data.change_type and (data.change_type == "sign_in_award" or data.change_type == "sign_in_acc_award")  then
		Network.SendRequest("query_sign_in_data")
	end
end

function C:ctor(backcall)

	ExtPanel.ExtMsg(self)
    self.backcall = backcall
    local parent = GameObject.Find("Canvas/LayerLv4").transform
    local obj = newObject(C.name, parent)
    local tran = obj.transform
    self.transform = tran
    self.gameObject = obj
    LuaHelper.GeneratingVar(self.transform, self)
    self.MaxDay = self:get_month_day_count(tonumber(os.date("%Y", os.time())), tonumber(os.date("%m", os.time())))
    self:MakeLister()
    self:AddMsgListener()

    self.config = SYSQDManager.UIConfig.config
    self.backcall = backcall
    self:InitUI()
    self:OnClickButton()
    Network.SendRequest("query_sign_in_data")
end

function C:InitUI()
    self.VIPButton = self.transform:Find("VIPButton"):GetComponent("Button")
    self.CloseButton = self.transform:Find("CloseButton"):GetComponent("Button")
    self.SunDayItem = self.transform:Find("SunDay")
    --self.WeekItem = self.transform:Find("WeekItem")
    --self.MonthItem = self.transform:Find("MonthItem")
    --self.WeekContent = self.transform:Find("WeekContent")
    --self.MonthContent = self.transform:Find("MonthContent")

	self.DayNode = self.transform:Find("day_node")
	self.TotalNode = self.transform:Find("total_node")
	
	self.InfoText = self.transform:Find("InfoText"):GetComponent("Text")
	self.TimeText = self.transform:Find("TimeText"):GetComponent("Text")

	--self.TopText = self.transform:Find("TopText"):GetComponent("Text")
    self.GetAwardPanel = self.transform:Find("GetAwardPanel")
	self.VipUpPanel = self.transform:Find("VipUpPanel")
	self.VipButtonImage=self.transform:Find("VIPButton"):GetComponent("Image")
	self.ProgressRect = self.transform:Find("progress"):GetComponent("RectTransform")


    self.WeekChilds = {}
    for i = 1, #self.config.week - 1 do
        --local b = GameObject.Instantiate(self.WeekItem, self.WeekContent)
		local b = self.DayNode.transform:GetChild(i-1)
        b.gameObject:SetActive(true)
        b.gameObject.transform:Find("DayImage"):GetComponent("Image").sprite = GetTexture(daySpr_normal[i])
        b.gameObject.transform:Find("AwardText"):GetComponent("Text").text = self.config.week[i].info
        b.gameObject.transform:Find("AwardImage"):GetComponent("Image").sprite = GetTexture(self.config.week[i].img)
        if self.config.week[i].vip then
            b.gameObject.transform:Find("Tag").gameObject:SetActive(true)
            if self.config.week[i].vip == 1 then
                b.gameObject.transform:Find("Tag"):GetComponent("Image").sprite = GetTexture("qrqd_icon_v1")
            elseif self.config.week[i].vip == 2 then
                b.gameObject.transform:Find("Tag"):GetComponent("Image").sprite = GetTexture("qrqd_icon_v2")
            elseif self.config.week[i].vip == 3 then
                b.gameObject.transform:Find("Tag"):GetComponent("Image").sprite = GetTexture("qrqd_icon_v3")    
            else
                print("<color=red>没有这个tag</color>")
            end
        else
            b.gameObject.transform:Find("Tag").gameObject:SetActive(false)
        end
        self.WeekChilds[i] = b
    end

    self.SunDayItem.gameObject.transform:Find("AwardImage"):GetComponent("Image").sprite = GetTexture(self.config.week[#self.config.week].img)
    --self.SunDayItem.gameObject.transform:Find("AwardText"):GetComponent("Text").text = self.config.week[#self.config.week].info
    self.WeekChilds[7] = self.SunDayItem

	for i = 1, #self.WeekChilds do
		self.WeekChilds[i].gameObject.transform:Find("GetBtn"):GetComponent("Button").onClick:AddListener(
			function ()
				self:GetWeekAward(self.config.week[i],i)
			end
		)

		self.WeekChilds[i].gameObject.transform:Find("AwardImage"):GetComponent("Button").onClick:AddListener(
			function ()
				LTTipsPrefab.Show2(self.WeekChilds[i].gameObject.transform:Find("AwardImage").transform,
				self.config.tips[i][1],self.config.tips[i][2])
			end
		)
	end

    self.MonthChilds = {}
    for i = 1, #self.config.month do
        --local b = GameObject.Instantiate(self.MonthItem, self.MonthContent)
		local b = self.TotalNode.transform:GetChild(i-1)
        b.gameObject:SetActive(true)
		if self.config.month[i].day == "M" or self.config.month[i].day == self.MaxDay then 
			self.config.month[i].day = self.MaxDay
		end
        b.gameObject.transform:Find("Tag/Text"):GetComponent("Text").text = self.config.month[i].day .. "天"
        b.gameObject.transform:Find("AwardText"):GetComponent("Text").text = self.config.month[i].info
        b.gameObject.transform:Find("AwardImage"):GetComponent("Image").sprite = GetTexture(self.config.month[i].img)
		self.MonthChilds[i] = b
		b.gameObject.transform:GetComponent("Button").onClick:AddListener(
			function ()
				self:GetMonthAward(i)
			end
		)
    end
	--self.MonthChilds[#self.MonthChilds].gameObject.transform:Find("Progress").gameObject:SetActive(false)
end


function C:InitDaysUI()

end

--注册按钮事件
function C:OnClickButton()
    self.VIPButton.onClick:AddListener(
		function()
			--PayPanel.Create(GOODS_TYPE.jing_bi, "normal")
			self:GotoVipBuy()
		end
    )
    self.CloseButton.onClick:AddListener(
		function()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
			self:MyExit()
		end
	)
	self.vip_no_btn.onClick:AddListener(
		function ()
			self.VipUpPanel.gameObject:SetActive(false)
		end
	)
	self.vip_close_btn.onClick:AddListener(
		function ()
			self.VipUpPanel.gameObject:SetActive(false)
		end
	)
	self.vip_yes_btn.onClick:AddListener(
		function ()
			self.VipUpPanel.gameObject:SetActive(false)
			--PayPanel.Create(GOODS_TYPE.jing_bi, "normal")
			--GameManager.GotoUI({ gotoui = "hall_activity", goto_scene_parm = "panel" })
			self:GotoVipBuy()
		end
	)
	self.getaward_close_btn.onClick:AddListener(
		function ()
			self.GetAwardPanel.gameObject:SetActive(false)
		end
	)
end

function C:get_month_day_count(year, month)
    local t
    if ((year % 4 == 0) and (year % 100 ~= 0)) or (year % 400 == 0) then
        t = { 31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 }
    else
        t = { 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 }
    end
    return t[month]
end

function C:OnGetInfo(_, data)
	dump(data, "<color=red>每日签到信息</color>")
	if not IsEquals(self.gameObject) then return end  
	self:OnRefreshVipInfo()
    if data and data.result == 0 then
        for i = 1, #self.WeekChilds do
            --self.WeekChilds[i].transform:Find("BG_klj/GetBtn"):GetComponent("Button").enabled = false
            self.WeekChilds[data.sign_in_day].gameObject.transform:Find("BG_klj").gameObject:SetActive(false)
			self.WeekChilds[i].transform:Find("GetBtn").gameObject:SetActive(false)
            self.WeekChilds[i].gameObject.transform:Find("TX").gameObject:SetActive(false)
			self.WeekChilds[i].gameObject.transform:Find("AwardImage"):GetComponent("Button").enabled = false
        end
        for i = 1, data.sign_in_day - 1 do
            self.WeekChilds[i].gameObject.transform:Find("Mask").gameObject:SetActive(true)
		end

		for i =  data.sign_in_day + 1 ,#self.WeekChilds do
			self.WeekChilds[i].gameObject.transform:Find("AwardImage"):GetComponent("Button").enabled = true
		end

		local toptext = data.sign_in_day - 1
        if data.sign_in_award == 1 then
            self.WeekChilds[data.sign_in_day].gameObject.transform:Find("TX").gameObject:SetActive(true)
            --self.WeekChilds[data.sign_in_day].transform:Find("BG_klj/GetBtn"):GetComponent("Button").enabled = true
            --self.WeekChilds[data.sign_in_day].gameObject.transform:Find("BG"):GetComponent("Image").sprite = GetTexture("qrqd_bg_klq")
            self.WeekChilds[data.sign_in_day].gameObject.transform:Find("BG_klj").gameObject:SetActive(true)
			if data.sign_in_day ~= 7 then
				local huxiObj = self.WeekChilds[data.sign_in_day].gameObject.transform:Find("BG_klj/Image").gameObject
				if self.huxi then
					self.huxi:Stop()
					self.huxi = nil
				end
				self.huxi = CommonHuxiAnim.Go(huxiObj)
				self.huxi:Start()
			end
			self.WeekChilds[data.sign_in_day].transform:Find("GetBtn").gameObject:SetActive(true)
			SignInPanel.IsLj = true
		else
			self.WeekChilds[data.sign_in_day].gameObject.transform:Find("Mask").gameObject:SetActive(true)
            self.WeekChilds[data.sign_in_day].gameObject.transform:Find("BG_klj").gameObject:SetActive(false)
			toptext = toptext + 1
		end
		--self.TopText.text = "已经连续签到<color=#e82c06>"..toptext.."</color>天"
		--self.InfoText.text = "VIP1及以上等级专属累计签到奖励（本月累计签到" .. data.acc_day  .. "天）"
		self.TimeText.text = "（本月累计签到" .. data.acc_day .. "天）"
		dump(self.config.month,"<color=red>month</color>")
		dump(data.acc_day,"<color=red>data.acc_day</color>")

		local cur_lv = 1
		local rate
		for i = 1, #self.config.month do
			self.MonthChilds[i].gameObject:GetComponent("Button").enabled = false
			if self.config.month[i].day == "M" then  self.config.month[i].day = self.MaxDay end
            if self.config.month[i].day <= data.acc_day  then
				self.MonthChilds[i].gameObject.transform:Find("Mask").gameObject:SetActive(true)
				self.MonthChilds[i].gameObject.transform:Find("TX_1").gameObject:SetActive(false)
			else
				
            end
			-- dump(data.acc_day,"<color=red>data.acc_day</color>")
			-- dump(self.config.month[i].day,"<color=red>self.config.month[i].day</color>")
			if data.acc_day >= self.config.month[i].day then
				cur_lv = i + 1
			end
        end
		cur_lv = cur_lv > 5 and 5 or cur_lv
		--dump(cur_lv,"<color=red>cur_lv</color>")
		if cur_lv == 1 then
			rate = data.acc_day / self.config.month[cur_lv].day
		else
			rate = (data.acc_day - self.config.month[cur_lv - 1].day)/(self.config.month[cur_lv].day - self.config.month[cur_lv - 1].day)
		end
		local offX = progressX[cur_lv].min + rate * (progressX[cur_lv].max - progressX[cur_lv].min)
		self.ProgressRect.sizeDelta = { x = offX , y = 13.27 }

        if not table_is_null(data.acc_award) then
            SignInPanel.IsLj = true
            for i = 1, #data.acc_award do
				self.MonthChilds[data.acc_award[i]].gameObject.transform:Find("TX_1").gameObject:SetActive(true)
				self.MonthChilds[data.acc_award[i]].gameObject.transform:Find("Mask").gameObject:SetActive(false)
                self.MonthChilds[data.acc_award[i]].gameObject:GetComponent("Button").enabled = true
                --self.MonthChilds[data.acc_award[i]].gameObject.transform:Find("BG2").gameObject:SetActive(true)
            end
        end
	end
	Event.Brocast("JYFLInfoChange")

	if data and data.result == 0 then
		Event.Brocast("trace_task_msg", {task_id = 10000, task_name = "signin", status = "1"})
	else
		Event.Brocast("trace_task_msg", {task_id = 10000, task_name = "signin", status = "2"})
	end
end

function C:GetWeekAward(config, _index)
	if VIPManager.get_vip_data() == nil then return end 
	if config.vip then
		if config.vip > VIPManager.get_vip_data().vip_level then
			self.GetAwardPanel.transform:Find("Award1/Text"):GetComponent("Text").text=config.info
			self.GetAwardPanel.transform:Find("Award2/Text"):GetComponent("Text").text=config.vipinfo
			self.award_yes_txt.text = "VIP"..config.vip.."领取"
			self.award_yes_btn.onClick:RemoveAllListeners()
			self.award_no_btn.onClick:RemoveAllListeners()
			self.award_yes_btn.onClick:AddListener(
				function ()
					if config.vip > VIPManager.get_vip_data().vip_level then
						--PayPanel.Create(GOODS_TYPE.jing_bi, "normal")
						self.VipUpPanel.gameObject:SetActive(true)
						self:SetVipUpPanelLv(config.vip)
					else
						Network.SendRequest("get_sign_in_award", { type = "sign_in", index = _index })
						self.GetAwardPanel.gameObject:SetActive(false)	
					end 
				end
			)
			self.award_no_btn.onClick:AddListener(
				function ()
					Network.SendRequest("get_sign_in_award", { type = "sign_in", index = _index })
					self.GetAwardPanel.gameObject:SetActive(false)	
				end
			)
			self.GetAwardPanel.gameObject:SetActive(true)
		else
			Network.SendRequest("get_sign_in_award", { type = "sign_in", index = _index })	
			self.GetAwardPanel.gameObject:SetActive(false)		
		end		
    else
		Network.SendRequest("get_sign_in_award", { type = "sign_in", index = _index })
		self.GetAwardPanel.gameObject:SetActive(false)
    end
end

function C:GetMonthAward(_index)
	if VIPManager.get_vip_data() and VIPManager.get_vip_data().vip_level>=1 then 
		Network.SendRequest("get_sign_in_award",{type = "acc", index = _index })
	else
		self.VipUpPanel.gameObject:SetActive(true)
		self:SetVipUpPanelLv(1)
	end
end

function C:OnRefreshVipInfo()
	if VIPManager.get_vip_data() and VIPManager.get_vip_data().vip_level >= 1 then
		self.VipButtonImage.sprite = GetTexture("qrqd_btn_tsvip")
	end 
end

function C:GotoVipBuy()
	if VIPManager.get_vip_level() < vip_gifts_level then
		GameManager.GotoUI({ gotoui = "hall_activity", goto_scene_parm = "panel" })
	else
		PayPanel.Create(GOODS_TYPE.jing_bi, "normal")
	end
end


local vip_up_const_txt  = "及以上等级才能领取此奖励\n是否确认提升VIP等级"
function C:SetVipUpPanelLv(index)
	local hint_info_txt = self.VipUpPanel.transform:Find("ImgPopupPanel/hint_info_txt"):GetComponent("Text")
	local vip_txt = "<color=#FF5A00FF>VIP".. index .. "</color>"
	hint_info_txt.text = vip_txt .. vip_up_const_txt
end

--[[
	GetTexture("gy_61_27")
	GetTexture("ls_icon_hb3")
]]