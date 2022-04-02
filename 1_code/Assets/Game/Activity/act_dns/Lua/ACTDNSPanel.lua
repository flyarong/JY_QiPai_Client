-- 创建时间:2021-05-17
-- Panel:ACTDNSPanel
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

ACTDNSPanel = basefunc.class()
local C = ACTDNSPanel
C.name = "ACTDNSPanel"
local M = ACTDNSManager

local instance 

function C.Create(parent, backcall)
	if not instance then
		instance = C.New(parent, backcall)
	end
	return instance
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["ExitScene"]=basefunc.handler(self,self.MyExit)

	self.lister["kill_activity_getInfo_response_msg"] = basefunc.handler(self, self.on_kill_activity_getInfo_response_msg)
	self.lister["kill_activity_dice_response_msg"] = basefunc.handler(self, self.on_kill_activity_dice_response_msg)
	self.lister["kill_activity_killBoss_response_msg"] = basefunc.handler(self,self.on_kill_activity_killBoss_response_msg)

	self.lister["AssetChange"] = basefunc.handler(self, self.OnAssetChange)

	self.lister["EnterForeGround"] = basefunc.handler(self, self.on_backgroundReturn_msg)
    self.lister["EnterBackGround"] = basefunc.handler(self, self.on_background_msg)

    self.lister["act_ty_giftspanel_create_msg"] = basefunc.handler(self, self.on_act_ty_giftspanel_create_msg)
    self.lister["model_task_change_msg"] = basefunc.handler(self,self.on_model_task_change_msg)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()	
	self:DelPre()
	if self.Award_Data then
		if #self.Award_Data.data > 1 then
			local pre = AssetsGet10Panel.Create(self.Award_Data.data)
			pre:SetCopyButton(false)
			self.Award_Data = nil
		else
			if not table_is_null(self.Award_Data.data) then
				Event.Brocast("AssetGet", self.Award_Data)
				self.Award_Data = nil
			end
		end
	end
	if not table_is_null(self.kill_Award_Data) then
		Event.Brocast("AssetGet", self.kill_Award_Data)
		self.kill_Award_Data = nil
	end
	if self.cutdown_timer then
		self.cutdown_timer:Stop()
	end
	if self.move_seq then
		self.move_seq:Kill()
		self.move_seq = nil
	end
	if self.bp_seq then
		self.bp_seq:Kill()
		self.bp_seq = nil
	end
	if self.yh_seq then
		self.yh_seq:Kill()
		self.yh_seq = nil
	end
	if self.seq then
		self.seq:Kill()
		self.seq = nil
	end
	if self.pre then
		self.pre = nil
	end
	instance = nil
	self:RemoveListener()
	destroy(self.gameObject)
	if self.backcall then
		self.backcall()
	end
end

function C:OnDestroy()
	self:MyExit()
end

function C:MyClose()
	self:MyExit()
end

function C:ctor(parent, backcall)
	self.backcall = backcall
	ExtPanel.ExtMsg(self)
	self.parent = parent or GameObject.Find("Canvas/LayerLv4").transform
	local obj = newObject(C.name, self.parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	self.page_index = PlayerPrefs.GetInt(M.key .. MainModel.UserInfo.user_id .. "page_index",1)
    self.ysz_btn.onClick:AddListener(function()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        if self.is_anim_runing then
        	LittleTips.Create("财神移动中...")
        	return
        end
        if self.is_bp_anim_runing then
        	LittleTips.Create("打年兽中...")
        	return
        end
        if M.OutTime() then
        	LittleTips.Create("活动已结束...")
        	return
        end
		self:OnYSZClick(1)
    end)
    self.ysz10_btn.onClick:AddListener(function()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        if self.is_anim_runing then
        	LittleTips.Create("财神移动中...")
        	return
        end
        if self.is_bp_anim_runing then
        	LittleTips.Create("打年兽中...")
        	return
        end
        if M.OutTime() then
        	LittleTips.Create("活动已结束...")
        	return
        end
		self:OnYSZClick(10)
    end)
    self.left_btn.onClick:AddListener(function()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        if self.is_anim_runing then
        	LittleTips.Create("财神移动中...")
        	return
        end
        if self.is_bp_anim_runing then
        	LittleTips.Create("打年兽中...")
        	return
        end
		self:OnSwitchClick("left")
    end)
    self.right_btn.onClick:AddListener(function()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        if self.is_anim_runing then
        	LittleTips.Create("财神移动中...")
        	return
        end
        if self.is_bp_anim_runing then
        	LittleTips.Create("打年兽中...")
        	return
        end
		self:OnSwitchClick("right")
    end)
    self.help_btn.onClick:AddListener(function()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnHelpClick()
    end)
    self.nianshou_btn.onClick:AddListener(function()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnNianShouClick()
    end)
    self.bp_btn.onClick:AddListener(function()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        if self.is_anim_runing then
        	LittleTips.Create("财神移动中...")
        	return
        end
        if self.is_bp_anim_runing then
        	LittleTips.Create("打年兽中...")
        	return
        end
        if M.OutTime() then
        	LittleTips.Create("活动已结束...")
        	return
        end
		self:OnBPClick()
    end)

    self.help_img = self.help_btn.transform:GetComponent("Image")
    self.tzsz_anim = self.sz_anim:GetComponent("Animator")
    for i=1,10 do
    	self["tzsz_anim" .. i] = self["sz" .. i .. "_anim"]:GetComponent("Animator")
    end
    self.player_anim = self.player_node:GetComponent("Animator")
    self.slider = self.Slider.transform:GetComponent("Slider")

	self.cur_pos = 1

	self.cutdown_timer = CommonTimeManager.GetCutDownTimer(M.GetActEndtime(), self.djs_txt)

	self:RefreshAsset()
	M.QueryBaseData()
end
function C:DelPathObj()
	if self.cur_path then
		for k,v in ipairs(self.cur_path) do
			v.pre:MyExit()
		end
	end
	self.cur_path = {}
end
function C:MyRefresh()
	self.baseData = M.GetBaseData()
	self.map_config = M.GetMapConfigByPage(self.page_index)
	if self.page_index == 1 then
		self.cur_pos = self.baseData.spec_pos
		self.value = self.baseData.spec_surplus
		self.help_img.sprite = GetTexture("dns_btn_gjgz")
		self.one_txt.text = "消耗1000元宝"
		self.ten_txt.text = "消耗10000元宝"
		self.bp_img.sprite = GetTexture("dns_icon_gjbp")
	elseif self.page_index == 2 then
		self.cur_pos = self.baseData.nor_pos
		self.value = self.baseData.nor_surplus
		self.help_img.sprite = GetTexture("dns_btn_djgz")
		self.one_txt.text = "消耗100元宝"
		self.ten_txt.text = "消耗1000元宝"
		self.bp_img.sprite = GetTexture("dns_icon_djbp")
	end
	self.left_btn.gameObject:SetActive(self.page_index == 1)
	self.right_btn.gameObject:SetActive(self.page_index == 2)
	local data = GameTaskModel.GetTaskDataByID(M.GetLJConfig(self.page_index)[1].task)
	if data then
		self.kill_txt.text = data.now_total_process
	end
	self:DelPathObj()
	for i = 1, #self.map_config do
		local data = {}
		data.pre = ACTDNSPathPrefab.Create(self["pre_node" .. i], i, self.map_config[i])
		data.pos = data.pre:GetPos()
		self.cur_path[i] = data
	end

	--self.player_node.localPosition = self.cur_path[self.cur_pos].pos
	self:SetPlayerNodePos(self.cur_pos)

	self.cur_path[self.cur_pos].pre:SetSelect(true)
	self.finger.gameObject:SetActive(M.GetCurBPNum(self.page_index) > 0)
	self:RefreshLJ()
	self:RefreshNS()
end

function C:RefreshAsset()
	self.yb_txt.text = "x" .. M.GetCurYuanBaoNum()
	if not self.is_anim_runing then
		self.bp_txt.text = "x" .. M.GetCurBPNum(self.page_index)
		self.finger.gameObject:SetActive(M.GetCurBPNum(self.page_index) > 0)
	end
end

function C:RefreshNS()
	local hurt_data = M.GetCurHurtData()
	if not table_is_null(self.baseData) then
		if self.page_index == 1 then
			self.ns_img.sprite = GetTexture("dns_icon_ns")
			self.slider.value = self.baseData.spec_surplus/100
			self.xl_txt.text = self.baseData.spec_surplus .. "%"
			self.value = self.baseData.spec_surplus
		elseif self.page_index == 2 then
			self.ns_img.sprite = GetTexture("dns_icon_ns")
			self.slider.value = self.baseData.nor_surplus/100
			self.xl_txt.text = self.baseData.nor_surplus .. "%"
			self.value = self.baseData.nor_surplus
		end
	end
end

function C:SetPlayerNodePos(posIndex)
	if posIndex == 1 then
		self.player_node.localPosition = self.cur_path[self.cur_pos].pos
	else
		self.player_node.localPosition = self.cur_path[self.cur_pos].pos
	end
end


--基础数据获取返回
function C:on_kill_activity_getInfo_response_msg()
	if not self.is_anim_runing then
		self:MyRefresh()
	end
end

function C:run10()
	self.move_seq = DoTweenSequence.Create()
	local obj
	if self.count ~= 0 then
		if self.cur_pos == 1 then
			self.move_seq:AppendInterval(1)
		else
			obj = newObject("dns_award",self.player_node.transform)
			obj.transform.localPosition = Vector3.New(0,50,0)
			obj.transform:Find("@icon_img").transform:GetComponent("Image").sprite = GetTexture(self.cur_path[self.cur_pos].pre:GetImg())
			obj.transform:Find("@award_txt").transform:GetComponent("Text").text = self.cur_path[self.cur_pos].pre:GetTxt()
			self.move_seq:Append(obj.transform:DOLocalMove(Vector3.New(0,180,0),1))
			self.move_seq:Join(obj.transform:GetComponent("CanvasGroup"):DOFade(0,1))
		end
	end
	self.move_seq:OnKill(function ()
		if IsEquals(obj) then
			Destroy(obj)
		end
		self.move_seq = nil
		self.count = self.count + 1
		if self.count > #self.dicData then 
			self:MoveFinish10_2()
		 	return 
		end
		local target_pos = self.cur_pos + self.dicData[self.count]
		if target_pos > #self.cur_path then
			target_pos = target_pos - #self.cur_path
		end
		self:PlayMove10(target_pos)
	end)
end	

--摇骰子返回
function C:on_kill_activity_dice_response_msg()
	self.count = 0
	self.baseData = M.GetBaseData()
	self.dicData = M.GetDicData()
	self:SetAwardData()
	self.sz_node.gameObject:SetActive(#self.dicData == 1)
	self.sz10_node.gameObject:SetActive(#self.dicData ~= 1)
	if #self.dicData == 1 then
		self.dot = self.dicData[1]
		self.tzsz_anim:SetBool("sz".. self.dot, true)
		self.tzsz_anim:Play("run", -1, 0)
		local run = function ()
			self.move_seq = DoTweenSequence.Create()
			self.move_seq:AppendInterval(1)
			self.move_seq:OnKill(function ()
				self.move_seq = nil
				self.sz_node.gameObject:SetActive(false)
				self.sz10_node.gameObject:SetActive(false)
				self:PlayMove()
			end)
		end	
		run()
	else
		for i=1,#self.dicData do
			self.dot = self.dicData[i]
			self["tzsz_anim" .. i]:SetBool("sz".. self.dot, true)
			self["tzsz_anim" .. i]:Play("run", -1, 0)
		end
		self.seq = DoTweenSequence.Create()
		self.seq:AppendInterval(2)
		self.seq:AppendCallback(function ()
			self.sz_node.gameObject:SetActive(false)
			self.sz10_node.gameObject:SetActive(false)
			self:run10()
		end)
	end
end

function C:OnAssetChange(data)
	if data.change_type and ((string.sub(data.change_type,1,23) == "kill_activity_kill_nor_") or (string.sub(data.change_type,1,24) == "kill_activity_kill_spec_") or (string.sub(data.change_type,1,24) == "kill_activity_dice_spec_") or (string.sub(data.change_type,1,23) == "kill_activity_dice_nor_")) then
		Event.Brocast("global_hint_state_change_msg",{gotoui = M.key})
	end
    if data.change_type and ((string.sub(data.change_type,1,23) == "kill_activity_kill_nor_") or (string.sub(data.change_type,1,24) == "kill_activity_kill_spec_")) and not table_is_null(data.data) then
        self.kill_Award_Data = data
    end

    self:RefreshAsset()
end

function C:on_backgroundReturn_msg()
	if self.is_bp_anim_runing then
		self.is_bp_anim_runing = false
		if not table_is_null(self.kill_Award_Data) then
			Event.Brocast("AssetGet", self.kill_Award_Data)
			self.kill_Award_Data = nil
		end
	end
	self:RefreshNS()
	if self.is_anim_runing then
		self.cur_path[self.cur_pos].pre:SetSelect(false)
		if self.page_index == 1 then
			self.cur_pos = self.baseData.spec_pos
		elseif self.page_index == 2 then
			self.cur_pos = self.baseData.nor_pos
		end
		self:SetPlayerNodePos(self.cur_pos)
		if self.move_seq then
			self.move_seq = nil
		end
		self.sz_node.gameObject:SetActive(false)
		self.sz10_node.gameObject:SetActive(false)
		if self.Award_Data.data and #self.Award_Data.data > 1 then
			self:MoveFinish10_2()
		else
			self:MoveFinish()
		end
	end
end

function C:on_background_msg()

end

function C:PlayMove()
	-- dump(self.baseData.position, "self.baseData.position")
	-- dump(self.cur_pos, "self.cur_pos")
	local position
	if self.page_index == 1 then
		position = self.baseData.spec_pos
	elseif self.page_index == 2 then
		position = self.baseData.nor_pos
	end
	if position ~= self.cur_pos then
		self.cur_path[self.cur_pos].pre:SetSelect(false)
		local index = self.cur_pos + 1
		if index > #self.cur_path then
			index = 1
		end
		local endPos = self.cur_path[index].pos
		if index == 1 then
			endPos = self.cur_path[index].pos
		else
			endPos = self.cur_path[index].pos
		end

		self.player_anim:Play("run", -1, 0)
		self.move_seq = DoTweenSequence.Create()
		self.move_seq:AppendInterval(0.1)
		self.move_seq:Append(self.player_node:DOLocalMove(endPos, 0.2))
		self.move_seq:AppendInterval(0.2)
		self.move_seq:OnKill(function ()
			self.move_seq = nil
			self.cur_pos = index
			self:PlayMove()
		end)
	else
		self.move_seq = DoTweenSequence.Create()
		self.move_seq:AppendInterval(0.1)
		self.move_seq:OnKill(function ()
			self.move_seq = nil
			self:MoveFinish()
		end)
	end
end

function C:PlayMove10(target_pos)
	-- dump(self.baseData.position, "self.baseData.position")
	-- dump(self.cur_pos, "self.cur_pos")
	if target_pos ~= self.cur_pos then
		self.cur_path[self.cur_pos].pre:SetSelect(false)
		local index = self.cur_pos + 1
		if index > #self.cur_path then
			index = 1
		end
		local endPos = self.cur_path[index].pos
		if index == 1 then
			endPos = self.cur_path[index].pos
		else
			endPos = self.cur_path[index].pos
		end

		self.player_anim:Play("run", -1, 0)
		self.move_seq = DoTweenSequence.Create()
		self.move_seq:AppendInterval(0.1)
		self.move_seq:Append(self.player_node:DOLocalMove(endPos, 0.2))
		self.move_seq:AppendInterval(0.2)
		self.move_seq:OnKill(function ()
			self.move_seq = nil
			self.cur_pos = index
			self:PlayMove10(target_pos)
		end)
	else
		self.move_seq = DoTweenSequence.Create()
		self.move_seq:AppendInterval(0.1)
		self.move_seq:OnKill(function ()
			self.move_seq = nil
			self:MoveFinish10_1()
		end)
	end
end

function C:MoveFinish()
	self.is_anim_runing = false
	local data = self.cur_path[self.cur_pos]

	self.cur_path[self.cur_pos].pre:SetSelect(true)

	if self.Award_Data and self.cur_pos ~= 1 then
		Event.Brocast("AssetGet", self.Award_Data)
		self:RefreshAsset()
		self.Award_Data = nil
	end

end

function C:MoveFinish10_1()
	local data = self.cur_path[self.cur_pos]

	self.cur_path[self.cur_pos].pre:SetSelect(true)
	self:run10()
end

function C:MoveFinish10_2()
	self.is_anim_runing = false
	if self.Award_Data then
		local pre = AssetsGet10Panel.Create(self.Award_Data.data)
		pre:SetCopyButton(false)
		self:RefreshAsset()
		--Event.Brocast("AssetGet", self.Award_Data)
		self.Award_Data = nil
	end
end

function C:OnYSZClick(num)
	local my_num = M.GetCurYuanBaoNum()
	local x = 1
	if self.page_index == 1 then
		x = 1000
	elseif self.page_index == 2 then
		x = 100
	end
	if my_num >= num * x then
		dump("<color=white>摇骰子</color>")
		self.is_anim_runing = true
		Network.SendRequest("kill_activity_dice",{act_type = M.act_type,sec_type = self.page_index,dice_times = num})
	else
		LittleTips.Create("元宝数量不足")
	end
end


function C:OnSwitchClick(type)
	if type == "left" then
		self.page_index = 2
	elseif type == "right" then
		self.page_index = 1
	end
	PlayerPrefs.SetInt(M.key .. MainModel.UserInfo.user_id .. "page_index",self.page_index)
	self.bp_txt.text = "x" .. M.GetCurBPNum(self.page_index)
	self:MyRefresh()
end

function C:RefreshLJ()
	self:DelPre()
	local config = M.GetLJConfig(self.page_index)
	for i=1,#config do
		local pre = ACTDNSLJItemBase.Create(self.Content.transform,config[i])
		self.lj_cell[#self.lj_cell + 1] = pre
	end
end

function C:DelPre()
	if not table_is_null(self.lj_cell) then
		for k,v in pairs(self.lj_cell) do
			v:MyExit()
		end
	end
	self.lj_cell = {}
end

function C:OnHelpClick()
	local help_info1 = {
		"(1)玩小游戏均可获得元宝道具",
		"(2)打死高阶年兽随机获得100万~200万鲸币或100万~300万鱼币或100~200福卡",
		"(3)活动时间：1月25日7:30~2月14日23:59:59",
		"(4)请及时使用活动中的道具，活动结束后将被全部清除",
		"(5)高阶年兽奖励每掷一次骰子获得的100积分",
		"(6)积分用于参与积分排行榜活动",
	}
	local help_info2 = {
		"(1)玩小游戏均可获得元宝道具",
		"(2)打死低阶年兽随机获得10万~20万鲸币或10万~30万鱼币或10~20福卡",
		"(3)活动时间：1月25日7:30~2月14日23:59:59",
		"(4)请及时使用活动中的道具，活动结束后将被全部清除",
		"(5)低阶年兽奖励每掷一次骰子获得的10积分",
		"(6)积分用于参与积分排行榜活动",
	}
	local help_info
	if self.page_index == 1 then
		help_info = help_info1
	elseif self.page_index == 2 then
		help_info = help_info2
	end
	local str = help_info[1]
	for i = 2, #help_info do
		str = str .. "\n" .. help_info[i]
	end
	self.introduce_txt.text = str
	self.Slider.gameObject:SetActive(false)
	IllustratePanel.Create({ self.introduce_txt.gameObject }, GameObject.Find("Canvas/LayerLv5").transform,nil,function ()
		self.Slider.gameObject:SetActive(true)
	end)
end

function C:OnBPClick()
	local num = M.GetCurBPNum(self.page_index)
	if num > 0 then
		self.is_bp_anim_runing = true
		Network.SendRequest("kill_activity_killBoss",{act_type = M.act_type, sec_type = self.page_index})
	else
		LittleTips.Create("道具不足")
	end
end

function C:on_kill_activity_killBoss_response_msg()
	self.baseData = M.GetBaseData()
	self.dicData = M.GetDicData()
	self:HitNS()
end

function C:HitNS(count)
	local count = count or 1
	local hurt_data = M.GetCurHurtData()
	if count > #hurt_data then
		self:CheckNSDead()
		return
	end
	if self.bp_seq then
		self.bp_seq:Kill()
		self.bp_seq = nil
	end
	if not self.page_index then return end
	
	self.bp_seq = DoTweenSequence.Create()
	local bp_obj = newObject("dns_bianpao" .. self.page_index, self.bp_btn.transform)
	local bz_obj
	bp_obj.transform.localPosition = Vector3.New(0,0,0)
	self.bp_seq:Append(bp_obj.transform:DOLocalMove(Vector3.New(-380,130,0),0.3))
	self.bp_seq:Join(bp_obj.transform:DORotate(Vector3.New(0, 0, 360), 0.3, DG.Tweening.RotateMode.FastBeyond360))
	self.bp_seq:AppendCallback(function ()
		if not IsEquals(self.bp_btn) then return end
		bz_obj = newObject("BQ_biaopao_02", self.bp_btn.transform)
		bz_obj.transform.localPosition = Vector3.New(-380,130,0)
	end)
	self.bp_seq:AppendInterval(0.5)
	self.bp_seq:AppendCallback(function ()
		self.bp_seq = nil
		if IsEquals(bp_obj) then
			Destroy(bp_obj)
		end
		if IsEquals(bz_obj) then
			Destroy(bz_obj)
		end
		if self.value then
			self.value = self.value - hurt_data[count]
			if self.value <= 0 then
				self.value = 0 
			end
			self.xl_txt.text = self.value .. "%"
			self.slider.value = (self.slider.value * 100 - hurt_data[count])/100
		end
		self:HitNS(count + 1)
	end)
	self.bp_seq:OnForceKill(function ()
		self.bp_seq = nil
	end)
end

function C:CheckNSDead()
	if self.slider.value <= 0 then
		self.yh_seq = DoTweenSequence.Create()
		local yh_obj = newObject("nianshou_yanhua", self.ns_img.transform)
		yh_obj.transform.localPosition = Vector3.New(0,0,0)
		self.yh_seq:AppendInterval(2.5)
		self.yh_seq:OnKill(function ()
			self.yh_seq = nil
			self.is_bp_anim_runing = false
			if not table_is_null(self.kill_Award_Data) then
				Event.Brocast("AssetGet", self.kill_Award_Data)
				self.kill_Award_Data = nil
			end
			self:RefreshNS()
			Destroy(yh_obj)
		end)
	else
		self.is_bp_anim_runing = false
	end
end

function C:SetAwardData()
	self.pos_count = 0
	self.Award_Data = {}
	self.Award_Data.data = {}
	for i=1,#self.dicData do
		self.pos_count = self.pos_count + self.dicData[i]
		local pos = M.GetLastPos(self.page_index)
		local target_pos = pos + self.pos_count
		target_pos = math.fmod(target_pos,#self.cur_path)
		if target_pos == 0 then
			target_pos = 16
		end
		if target_pos ~= 1 then
			local asset_type = self.cur_path[target_pos].pre:GetKey()
			local desc = self.cur_path[target_pos].pre:GetTxt() .. GameItemModel.GetItemToKey(asset_type).name
			local image = self.cur_path[target_pos].pre:GetImg()
			local value = self.cur_path[target_pos].pre:GetValue()
			self.Award_Data.data[#self.Award_Data.data + 1] = {asset_type = asset_type,desc = desc,image = image,value = value}
		end
	end
	M.SetLastPos()
end

function C:on_act_ty_giftspanel_create_msg(b)
	self.nianshou_node.gameObject:SetActive(not b)
	self.player_node.gameObject:SetActive(not b)
end


local tip_tab = {
	[1] = "打死高阶年兽随机获得100万~200万鲸币或100万~300万鱼币或100~200福卡",
	[2] = "打死低阶年兽随机获得10万~20万鲸币或10万~30万鱼币或10~20福卡",
}
function C:OnNianShouClick()
	LittleTips.Create(tip_tab[self.page_index])
end

function C:on_model_task_change_msg(data)
	if data and data.id == M.GetLJConfig(self.page_index)[1].task then
		local _data = GameTaskModel.GetTaskDataByID(M.GetLJConfig(self.page_index)[1].task)
		if _data then
			self.kill_txt.text = _data.now_total_process
		end
	end
end