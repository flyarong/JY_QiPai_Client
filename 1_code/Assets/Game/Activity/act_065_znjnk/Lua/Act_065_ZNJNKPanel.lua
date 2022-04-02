local basefunc = require "Game/Common/basefunc"
Act_065_ZNJNKPanel = basefunc.class()
local C = Act_065_ZNJNKPanel
C.name = "Act_065_ZNJNKPanel"
local lottery_type = {
	day = 1,
	week = 2,
	month = 3,
}

local award_pos = {
	[1] = {x = 66,y = 112,z = 0},
	[2] = {x = 156,y = 20,z = 0},
	[3] = {x = 162,y = -110,z = 0},
	[4] = {x = 66,y = -198,z = 0},
	[5] = {x = -66,y = -198,z = 0},
	[6] = {x = -162,y = -110,z = 0},
	[7] = {x = -156,y = 20,z = 0},
	[8] = {x = -66,y = 112,z = 0},
}

local Mgr = Act_065_ZNJNKManager
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
	self.lister["model_query_jinianka_3_anniversary_data_response"] = basefunc.handler(self,self.on_query_jinianka_3_anniversary_data_response)
	self.lister["model_jinianka_3_anniversary_data_change"] = basefunc.handler(self,self.jinianka_3_anniversary_data_change)
	self.lister["get_jinianka_3_anniversary_award_response"] = basefunc.handler(self,self.on_get_jinianka_3_anniversary_award_response)
	self.lister["AssetsGetPanelConfirmCallback"] = basefunc.handler(self,self.AssetsGetPanelConfirmCallback)
	self.lister["AssetChange"] = basefunc.handler(self, self.OnAssetChange)
	self.lister["act_065_znjnk_close"] = basefunc.handler(self, self.MyExit)
	self.lister["EnterBackGround"] = basefunc.handler(self, self.OnEnterBackGround)
end

function C:OnAssetChange(data)
	dump(data, "<color=red>----奖励类型-----</color>")
	if data.change_type and data.change_type == "jinianka_3_anniversary_award" then
		self.cur_award = data
	end
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	if self.backcall then 
		self.backcall()
	end
	self:ClearTimer()
	if self.cur_award then 
		Event.Brocast("AssetGet", self.cur_award)
		self.cur_award = nil
	end 
	self:RemoveListener()
	destroy(self.gameObject) 
end

function C:ctor(parent,backcall)
	ExtPanel.ExtMsg(self)
	local parent = parent or GameObject.Find("Canvas/LayerLv5").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	self.backcall = backcall
	self.zhizhenAnimator = {}
	self.zhizhen = {}
	for k,v in pairs(lottery_type) do
		self.zhizhenAnimator[v] = self[k .. "_zhizhen"].transform:GetComponent("Animator")
		self.zhizhen[v] = self[k .. "_zhizhen"]
	end
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	for k,v in pairs(lottery_type) do
		self.zhizhenAnimator[v].speed = 0
	end
	self:CloseAnimSound()
	Network.SendRequest("query_jinianka_3_anniversary_data")
	self.timer = {}
	Network.SendRequest("query_gift_bag_num",{gift_bag_id = Mgr.gift_id_998})
	Network.SendRequest("query_gift_bag_num",{gift_bag_id = Mgr.gift_id_2498})
end

function C:InitUI()
	self.time_txt.text = "活动时间：" .. os.date("%m月%d日%H:%M:%S", Mgr.start_time) .."-" .. os.date("%m月%d日%H:%M:%S", Mgr.end_time)
	local ui = {}
	local obj,obj_ui
	for k,j in pairs(lottery_type) do
		ui = {}
		LuaHelper.GeneratingVar(self[k.. "_zp"], ui)
		for i,v in ipairs(Mgr.config[k]) do
			obj = GameObject.Instantiate(self.award.gameObject,self[k.. "_zp"])
			obj_ui = {}
			LuaHelper.GeneratingVar(obj.transform, obj_ui)
			obj.transform.localPosition = award_pos[i]
			obj_ui.award_img.sprite = GetTexture(v.award_image)
			obj_ui.award_txt.text = v.award_text
			obj:SetActive(true)
			obj_ui = nil
			obj = nil
		end
		self[k .. "_lottery_btn"].onClick:AddListener(
		function ()
			if self.is_during_anim then
				LittleTips.Create("正在抽奖...")
				return
			end
			Network.SendRequest("get_jinianka_3_anniversary_award",{award_type = j}) 
		end
	)
	end
	obj = nil
	ui = nil

	self.help_btn.onClick:AddListener(
		function ()
			self:OpenHelpPanel()
		end
	)
	self.close_btn.onClick:AddListener(
		function ( )
			self:MyExit()
		end
	)
	self.buy_btn.onClick:AddListener(
		function ()
			--是否先查询
			Network.SendRequest("query_gift_bag_num",{gift_bag_id = Mgr.gift_id_998},"",function(data)
				if data.result == 0 then
					if data.num < 1 then
						HintPanel.Create(2,"折扣礼包已经购买完，是否使用2498元继续购买",function(  )
							Mgr.BuyShop(Mgr.gift_id_2498)
						end)
						self:MyRefresh()
						return
					end
					Mgr.BuyShop(Mgr.gift_id_998)
				else
					LittleTips.Create(errorCode[data.result] or "查询礼包异常")
				end
			end,true)
		end
	)
	self.buy1_btn.onClick:AddListener(
		function ()
			Mgr.BuyShop(Mgr.gift_id_2498)
		end
	)
	self:MyRefresh()
end

function C:OpenHelpPanel()
	local str = Mgr.config.help_info[1].text
	for i = 2, #Mgr.config.help_info do
		str = str .. "\n" .. Mgr.config.help_info[i].text
	end
	self.introduce_txt.text = str
	IllustratePanel.Create({ self.introduce_txt.gameObject }, GameObject.Find("Canvas/LayerLv5").transform)
end

function C:MyRefresh()
	if not IsEquals(self.gameObject) then return end
	if not Mgr.data then return end
	for k,j in pairs(lottery_type) do
		self[k .. "_hint_txt"].gameObject:SetActive(Mgr.data.is_buy == 1)
	end
	if Mgr.data.is_buy == 1 then
		--已购买
		self.gift.gameObject:SetActive(false)
		self.zs_txt.gameObject:SetActive(true)
		self.zp.localPosition = Vector3.zero
		for k,j in pairs(lottery_type) do
			self[k .. "_num_txt"].fontSize =  38
			self[k .. "_num_txt"].text = Mgr.data[k .. "_remain_award"]
			self[k .. "_mrcj"].gameObject:SetActive(Mgr.data[k .. "_award_can_get"] == 0)
		end
	else
		--未购买
		for k,j in pairs(lottery_type) do
			self[k .. "_num_txt"].fontSize =  38
			self[k .. "_mrcj"].gameObject:SetActive(false)
		end
		self.day_num_txt.text = 365
		self.week_num_txt.text = 48
		self.month_num_txt.text = 12
		self.gift.gameObject:SetActive(true)
		self.zs_txt.gameObject:SetActive(false)
		self.zp.localPosition = Vector3.New(0,60,0)
		local num = MainModel.GetGiftBagCount(Mgr.gift_id_998)
		dump(num,"<color=white>礼包个数</color>")
		num = tonumber(num)
		num = num or 0
		self.zk_txt.text = "限时折扣，再卖<color=#E65964>".. num .."</color>份，恢复2498元" 
		local is_yh = num > 0
		self.zk_txt.gameObject:SetActive(is_yh)
		self.buy_btn.gameObject:SetActive(is_yh)
		self.buy1_btn.gameObject:SetActive(not is_yh)
		num,is_yh = nil
	end
end

function C:AnimStart(selectIndex,award_type)
	if not self.is_during_anim then
		self.curSoundKey = ExtendSoundManager.PlaySound(audio_config.game.bgm_duijihongbao.audio_name, 1, function()
			self.curSoundKey = nil
		end)
		self.is_during_anim = true
		self.zhizhenAnimator[award_type].speed = 0
		self.zhizhen[award_type].gameObject:SetActive(true)
		self.rotateTween = -360 * 16 - 45 * (selectIndex - 1)
		self.awardtypeTween = award_type
		local seq = DoTweenSequence.Create()
		seq:Append(self.zhizhen[award_type]:DORotate( Vector3.New(0, 0 , self.rotateTween), 6, DG.Tweening.RotateMode.FastBeyond360):SetEase(DG.Tweening.Ease.InOutCubic))
		seq:OnKill(function ()
			if IsEquals(self.gameObject) then 
				self.rotateTween = nil
				self.awardtypeTween = nil
				--self.zhizhen[award_type].transform.localRotation = Quaternion:SetEuler(0, 0, self.rotateTween)
				self:CloseAnimSound()
				self:EndRotaAnim(award_type)
			end 
		end)
	else
		LittleTips.Create("正在抽奖...")
	end 
end

function C:EndRotaAnim(award_type)
	-- self.zhizhen[award_type].gameObject:SetActive(false)
	self.zhizhenAnimator[award_type].speed = 1
	self.de_timer = Timer.New(function ()
		self.zhizhenAnimator[award_type].speed = 0
		if self.cur_award then 
			Event.Brocast("AssetGet", self.cur_award)
			self.cur_award = nil
		end
		self.is_during_anim = false
	end,1.4,1)
	self.de_timer:Start()
end


function C:CloseAnimSound()
	if self.curSoundKey then
		soundMgr:CloseLoopSound(self.curSoundKey)
		self.curSoundKey = nil
	end
end

function C:on_query_jinianka_3_anniversary_data_response(data)
	dump(data,"<color=red>纪念卡  基础信息</color>")
	if data and data.result == 0 then
		self:MyRefresh()
	end
end

function C:on_get_jinianka_3_anniversary_award_response(_,data)
	dump(data,"<color=red>抽奖返回----</color>")
	if data and data.result == 0 then
		local index_data = self:GetIndexData(data.award_index,data.award_type)
		self:AnimStart(index_data.Index,data.award_type)
		local d = {name = index_data.award_text,award_id = data.award_index}
	else
		LittleTips.Create(errorCode[data.result] or "错误：" ..data.result)
	end 
end

function C:jinianka_3_anniversary_data_change(data)
	dump(data,"<color=red>信息改变----</color>")
	self:MyRefresh()
end

function C:GetIndexData(award_id,award_type)
	local selectIndex
	local cfg = {}
	if award_type == 1 then
		cfg = Mgr.config.day
	elseif award_type == 2 then
		cfg = Mgr.config.week
	elseif award_type == 3 then
		cfg = Mgr.config.month
	end
	for i = 1,#cfg do
		if tonumber(award_id) == cfg[i].award_id then
			return cfg[i]
		end 
	end
end

function C:AssetsGetPanelConfirmCallback()
	self:MyRefresh()
end

function C:OnEnterBackGround()
	self:ClearTimer()
	if self.cur_award then 
		Event.Brocast("AssetGet", self.cur_award)
		self.cur_award = nil
	end 
	if self.rotateTween and self.awardtypeTween then
		self.zhizhen[self.awardtypeTween].transform.localRotation = Quaternion:SetEuler(0, 0, self.rotateTween)
	end
end

function C:ClearTimer()
	if self.this_timer then 
        self.this_timer:Stop()
    end
	for i = 1,#self.timer do 
		if self.timer[i] then 
			self.timer[i]:Stop()
		end
	end
	if self.DelayToShow_Timer then
		self.DelayToShow_Timer:Stop()
	end
	if self.Cheak_Timer then 
		self.Cheak_Timer:Stop()
	end
	if self.idle_timer then 
		self.idle_timer:Stop()
	end
	if self.cur_award then 
		Event.Brocast("AssetGet", self.cur_award)
		self.cur_award = nil
	end 
end

