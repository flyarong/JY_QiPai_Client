local basefunc = require "Game/Common/basefunc"
MoneyCenterQFLBPanel = basefunc.class()
local C = MoneyCenterQFLBPanel
C.name = "MoneyCenterQFLBPanel"

function C.Create(parent,backcall)
	return C.New(parent,backcall)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
	self.lister["ExitScene"] = basefunc.handler(self, self.OnExitScene)
	self.lister["cfzx_qflb_finish_gift_shop"] = basefunc.handler(self, self.on_finish_gift_shop)
	self.lister["model_all_return_lb_change_msg"] = basefunc.handler(self, self.model_all_return_lb_change_msg)
	self.lister["cfzx_task_change_msg"] = basefunc.handler(self, self.model_task_change_msg)
	self.lister["model_get_task_award_response"] = basefunc.handler(self, self.model_get_task_award_response)
	self.lister["AssetsGetPanelConfirmCallback"] = basefunc.handler(self,self.AssetsGetPanelConfirmCallback)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	if self.timers then
		for i,v in pairs(self.timers) do
			v:Stop()
		end
		self.timers = {}
	end
	if self.backcall then
		self.backcall()
	end 
	GameTipsPrefab.Hide()
	self:RemoveListener()
	destroy(self.gameObject)

	 
end

function C:ctor(parent,backcall)

	ExtPanel.ExtMsg(self)

	self.cfg = MoneyCenterQFLBManager.get_cfg()
	self.data = MoneyCenterQFLBManager.get_data_all_return_lb_info()
	local parent = parent or GameObject.Find("Canvas/LayerLv5").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	self.backcall = backcall
	LuaHelper.GeneratingVar(self.transform, self)
	self.timers = {}
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	Network.SendRequest("query_sczd_all_return_base_info", nil, "正在获取数据")
end

function C:InitUI()
	self.back_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:OnBackClick()
	end)
	self.hidedesc_btn.onClick:AddListener(
		function ()
			self.hidedesc_btn.gameObject:SetActive(false)
			for i=1,3 do
				self["showdisc"..i].gameObject:SetActive(false)
			end
		end
	)

	self.items = {}
	local item
	if not table_is_null(self.cfg) then
		for i,v in ipairs(self.cfg.qflb) do
			item = GameObject.Instantiate(self.gift_task_item,self["gift_rect" .. i].transform)
			self.items[i] = {}
			self.items[i].gameobjec = item
			LuaHelper.GeneratingVar(item.transform, self.items[i])
			self.items[i].title_img.sprite = GetTexture(v.title_img)
			self.items[i].title_img:SetNativeSize()
			self.items[i].buy_img.sprite = GetTexture(v.buy_img)
			self.items[i].buy_btn_img = self.items[i].buy_btn.transform:GetComponent("Image")
			self.items[i].buy_btn_img.sprite = GetTexture(v.buy_btn)
			self.items[i].buy_no_img.sprite = GetTexture(v.buy_no_img)
			self.items[i].task_img.sprite = GetTexture(v.task_img)
			self.items[i].task_title_txt.text = v.task_title_txt
			self.items[i].slider_txt.text = v.slider_txt
			if i == 1 then 
				self.items[i].only.gameObject:SetActive(true)
			end
			self.items[i].buy_btn.onClick:AddListener(function ()
				ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
				self:OnBuyClick(v.good_id)
			end)
			self.items[i].buy_again_btn.onClick:AddListener(function ()
				ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
				self:OnBuyClick(v.good_id)
			end)
			self.items[i].share_btn.onClick:AddListener(function ()
				ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
				if i == 1 then 
					QFLBSharePanel.Create(nil,{title = "",tips = "全返礼包I仅限新人购买哦！\n<size=40>邀请好友购买立赚<color=#ea1e1e>3元。</color></size>"})
				end
			end)
			self.items[i].get_btn.onClick:AddListener(function ()
				ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
				self:OnGetClick(v.task_id)
			end)
			self.items[i].goto_btn.onClick:AddListener(function ()
				ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
				self:OnGotoClick(v)
			end)
			self.items[i].info_btn.onClick:AddListener(
				function ()
					self:OnDown(v.explanation,self["discnode"..i])
				end
			)
			-- PointerEventListener.Get(self.items[i].info_btn.gameObject).onDown = function ()
			-- 	GameTipsPrefab.ShowDesc(v.explanation, UnityEngine.Input.mousePosition)
			-- end
			-- PointerEventListener.Get(self.items[i].info_btn.gameObject).onUp = function ()
			-- 	GameTipsPrefab.Hide()
			-- end

			self.items[i].slider = self.items[i].Slider.transform:GetComponent("Slider")
			item.gameObject:SetActive(true)

			self.data = MoneyCenterQFLBManager.get_data_all_return_lb_info()
			local n = "all_return_lb_"
			local t_v  = self.data[n .. i]
			if t_v and t_v.over_time then
				self.timers = self.timers or {}
				self:StartTimer(i,t_v,v)
			end
		end
	end

	self.items[3].buy_btn.gameObject.transform:Find("Image").gameObject:SetActive(false)
	self.bing_zfb_btn.onClick:AddListener(
		function (  )
			ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
			GameManager.GotoUI({gotoui = "sys_binding_zfb",goto_scene_parm = "panel"})
			-- GameManager.GotoUI({gotoui = "sys_cfzx",goto_scene_parm = "panel",goto_scene_parm1 = "wdhy"})
			-- self:MyExit()
		end
    )
    -- if not GameMoneyCenterModel.CheckIsNewPlayerSys() then
    --     self.bing_zfb_btn.gameObject:SetActive(true)
	-- end
	if not MainModel.IsWeChatChannel() then
		self.bing_zfb_btn.gameObject:SetActive(true)
	end

	self:MyRefresh()
end


--当全返礼包3没购买，或者购买时间在3.10 7点半之前的时候，会额外赠送30万鲸币
function C:MyRefresh()
	self.data = MoneyCenterQFLBManager.get_data_all_return_lb_info()
	dump(self.data, "<color=white>self.data</color>")
	dump(self.cfg, "<color=white>self.cfg</color>")
	-- self.data.all_return_lb_1.over_time = os.time() + 10
	-- self.data.all_return_lb_2.remain_num = 0
	if self.data and self.cfg then
		local n = "all_return_lb_"
		local v
		local task_data
		for i,v_ in ipairs(self.cfg.qflb) do
			v = self.data[n .. i]
			if v and self.items[i] then
				if v.is_buy == 0 then
					--刷新礼包相关
					self.items[i].buy_btn.gameObject:SetActive(v.is_buy == 0)
					if i == 3 then
						self.items[i].libao3_notice.gameObject:SetActive(true)
					end
				elseif v.is_buy == 1 then
					--刷新任务相关
					if i == 3 and v.buy_time <= 1583796600 then
						self.items[i].libao3_notice.gameObject:SetActive(true)
					end
					task_data = GameTaskModel.GetTaskDataByID(v_.task_id)
					if task_data then
						if task_data.award_status == 2 then
							self.items[i].progress_txt.text = ""
						else
							self.items[i].progress_txt.text = string.format("%s/%s", StringHelper.ToCash(task_data.now_process), StringHelper.ToCash(task_data.need_process))
						end
						local now_process = task_data.now_process
						local need_process = task_data.need_process
						
						local process = now_process / need_process
						if process > 1 then process = 1 end
						self.items[i].slider.value = process == 0 and 0 or 0.95 * process + 0.05
					
						self:HideTaskBtn(i)
						if task_data.award_status == 0 then
							self.items[i].goto_btn.gameObject:SetActive(true)
						elseif task_data.award_status == 1 then
							self.items[i].get_btn.gameObject:SetActive(true)
						elseif task_data.award_status == 2 then
							self.items[i].over_btn.gameObject:SetActive(true)
						elseif task_data.award_status == 3 then
							self.items[i].not_on_btn.gameObject:SetActive(true)
						end
					else
						if self.timers[i] then
							self.timers[i]:Stop()
						end
						self.timers[i] = nil
						self.items[i].slider.value = 1
						self.items[i].progress_txt.text = ""
					end

					self.items[i].num_txt.text = string.format( v_.num_txt,v.remain_num)
					self.items[i].time_txt.text = string.format( v_.time_txt,StringHelper.formatTimeDHMS(v.over_time - os.time()))
				end
				self.items[i].gift_node.gameObject:SetActive(v.is_buy == 0)
				self.items[i].task_node.gameObject:SetActive(v.is_buy == 1)
				self.items[i].title_img.gameObject:SetActive(v.is_buy == 1)
				self.items[i].buy_again_btn.gameObject:SetActive(false)
				if v.is_buy == 1 then
					--已过期
					if v.over_time <= os.time() then
						if self.timers[i] then
							self.timers[i]:Stop()
						end
						self.timers[i] = nil
						self.items[i].out_time_img.gameObject:SetActive(true)
						self.items[i].buy_again_btn.gameObject:SetActive(true)
						if i == 1 then 
							self.items[i].share_btn.gameObject:SetActive(true)
							self.items[i].buy_again_btn.gameObject:SetActive(false)
						else
							self.items[i].tips2_txt.gameObject:SetActive(true)
							self.items[i].tips3_txt.gameObject:SetActive(true)		
						end
						self:HideTaskBtn(i)
					else
						self:StartTimer(i,v,v_)
						self.items[i].out_time_img.gameObject:SetActive(false)
					end
					--已完成
					if v.remain_num == 0 then
						if self.timers[i] then
							self.timers[i]:Stop()
						end
						self.timers[i] = nil
						self.items[i].end_img.gameObject:SetActive(true)
						self.items[i].out_time_img.gameObject:SetActive(false)
						self.items[i].time_txt.gameObject:SetActive(false)
						self.items[i].buy_again_btn.gameObject:SetActive(true)
						if i == 1 then 
							self.items[i].share_btn.gameObject:SetActive(true)
							self.items[i].buy_again_btn.gameObject:SetActive(false)
						else
							self.items[i].tips2_txt.gameObject:SetActive(true)
							self.items[i].tips3_txt.gameObject:SetActive(true)		
						end
						self:HideTaskBtn(i)
					else
						self:StartTimer(i,v,v_)
						self.items[i].end_img.gameObject:SetActive(false)
						self.items[i].time_txt.gameObject:SetActive(true)
					end
				end
			end
		end
	end
	self.my_money = MoneyCenterQFLBManager.get_my_money()
	self.my_money_txt.text = self.my_money
end

function C:HideTaskBtn(i)
	self.items[i].goto_btn.gameObject:SetActive(false)
	self.items[i].get_btn.gameObject:SetActive(false)
	self.items[i].over_btn.gameObject:SetActive(false)
	self.items[i].not_on_btn.gameObject:SetActive(false)
end

function C:OnBackClick()
	self:MyExit()
end

function C:OnExitScene()
	self:MyExit()
end

function C:OnBuyClick(id)
	local a,b
	if id == self.cfg.qflb[1].good_id then
		a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key="actp_buy_gift_bag_" .. id, is_on_hint = true}, "CheckCondition")
		if a and not b then 
			QFLBSharePanel.Create(nil,{title = "",tips = "全返礼包I仅限新人购买哦！\n<size=40>邀请好友购买立赚<color=#ea1e1e>3元。</color></size>"})
			return
		end
		if not a then
			LittleTips.Create("发生未知错误")
			return
		end
	end

	local gift_config = MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, id)
	local status = MainModel.GetGiftShopStatusByID(gift_config.id)
	dump(status,"<color=yellow>+++++++++++++++status+++++++++++++</color>")
    local b1 = MathExtend.isTimeValidity(gift_config.start_time, gift_config.end_time)
    if b1 then
		if status ~= 1 then
			LittleTips.Create("请重新登录后购买")
			return
		end
    else
		LittleTips.Create("抱歉，此商品不在售卖时间内")
		return
    end
    
	if GameGlobalOnOff.PGPay and gameRuntimePlatform == "Ios" then
		GameManager.GotoUI({gotoui = "sys_service_gzh",goto_scene_parm = "panel",desc="请前往公众号获取"})
	else
		PayTypePopPrefab.Create(gift_config.id, "￥" .. (gift_config.price / 100))
	end

end

function C:on_finish_gift_shop(id)
	local is_re
	if self.cfg and self.cfg.qflb then
		for i,v in ipairs(self.cfg.qflb) do
			if id == v.good_id then
				is_re = true
			end
		end
	end
	if not is_re then return end
	self:MyRefresh()
end

function C:model_all_return_lb_change_msg()
	self:MyRefresh()
end

function C:model_task_change_msg(task)
	local is_re
	if self.cfg and self.cfg.qflb then
		for i,v in ipairs(self.cfg.qflb) do
			if task.id == v.task_id then
				is_re = true
			end
		end
	end
	if not is_re then return end
	self:MyRefresh()
end

function C:OnGetClick(id)
	if not MainModel.IsWeChatChannel() then
		--检查支付宝
		MainModel.GetBindZFB(function(  )
			if table_is_null(MainModel.UserInfo.zfbData) or MainModel.UserInfo.zfbData.name == "" then
				LittleTips.Create("请先绑定支付宝")
				GameManager.GotoUI({gotoui = "sys_binding_zfb",goto_scene_parm = "panel"})
			else
				Network.SendRequest("get_task_award", {id = id}, "领取")
			end
		end)
		return
	end
	Network.SendRequest("get_task_award", {id = id}, "领取")
end

function C:OnGotoClick(v)
	local gotoparm = {gotoui = v.gotoui[1],goto_scene_parm = v.gotoui[2]}
	GameManager.GotoUI(gotoparm)
end

function C:OnDown(desc,node)
	if node.transform.childCount == 0 then 
		if type(desc) == "table" then	
			for i = 1,#desc do 
				local b = GameObject.Instantiate(self.desc_item,self.transform)
				local t = b.gameObject.transform:GetComponent("Text")
				b.transform.parent = node
				t.text = desc[i]
				b.gameObject:SetActive(true)
			end 
		else
			local b = GameObject.Instantiate(self.desc_item,self.transform)
			local t = b.gameObject.transform:GetComponent("Text")
			b.transform.parent = node
			t.text = desc
			b.gameObject:SetActive(true)
		end 
	end
	node.parent.transform.gameObject:SetActive(true)
    self.hidedesc_btn.gameObject:SetActive(true)
end

function C:StartTimer(i,v,v_)
	if self.timers[i] then
		self.timers[i]:Stop()
		self.timers[i] = nil
	end
	self.timers[i] = Timer.New(function(  )
		self.items[i].time_txt.text = string.format( v_.time_txt,StringHelper.formatTimeDHMS(v.over_time - os.time()))
		if v.over_time <= os.time() then
			if self.timers[i] then
				self.timers[i]:Stop()
			end
			self.items[i].out_time_img.gameObject:SetActive(true)
			if i ~= 1 then 
				self.items[i].buy_again_btn.gameObject:SetActive(true)
				self.items[i].tips2_txt.gameObject:SetActive(true)
				self.items[i].tips3_txt.gameObject:SetActive(true)		
			end
			self:HideTaskBtn(i)
		end
	end,1,-1,false,false)
	self.timers[i]:Start()
end

function C:AssetsGetPanelConfirmCallback(data)
	if data and data.change_type == "buy_gift_bag_10085" then 
		QFLBSharePanel.Create(nil,{title = "购买成功",tips = "\n邀请好友购买立赚<color=#ea1e1e>30元</color>"})
	end
	if data and data.change_type == "buy_gift_bag_10086" then 
		QFLBSharePanel.Create(nil,{title = "购买成功",tips = "\n邀请好友购买立赚<color=#ea1e1e>100元</color>"})
	end
end

function C:model_get_task_award_response(data)
--[[	if data and data.id == 78 then
		QFLBSharePanel.Create(nil,{title = "领取成功",tips = "干的漂亮！您已成功提现<color=#ea1e1e>1元</color>到支付宝！\n<size=40>邀好友购买立赚<color=#ea1e1e>3元</color></size>"})
	end
	if data and data.id == 79 then 
		QFLBSharePanel.Create(nil,{title = "领取成功",tips = "干的漂亮！您已成功提现<color=#ea1e1e>10元</color>到支付宝！\n<size=40>邀好友购买立赚<color=#ea1e1e>30元</color></size>"})
	end
	if data and data.id == 80 then
		QFLBSharePanel.Create(nil,{title = "领取成功",tips = "干的漂亮！您已成功提现<color=#ea1e1e>5元</color>到支付宝！\n<size=40>邀好友购买立赚<color=#ea1e1e>100元</color></size>"})
	end--]]
	if data and data.id == 78 then
		Share_Panel.Create(1)
	end
	if data and data.id == 79 then 
		Share_Panel.Create(2)
	end
	if data and data.id == 80 then
		Share_Panel.Create(3)
	end
end