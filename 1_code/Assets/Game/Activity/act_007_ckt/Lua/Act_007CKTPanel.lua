-- 创建时间:2020-03-11
-- Panel:Act_007CKTPanel
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

Act_007CKTPanel = basefunc.class()
local C = Act_007CKTPanel
C.name = "Act_007CKTPanel"
local hide_time = 17
local Wait_Broadcast_data = {}
local Wait_OBj
local Loop_Order = {"RollPrefab1","RollPrefab2","RollPrefab3"}
local hide_left_pos = -1300
local space = 1100
local M = Act_007CKTManager
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
	self.lister["box_exchange_response"] = basefunc.handler(self,self.on_box_exchange_response)
	self.lister["model_task_change_msg"] = basefunc.handler(self,self.on_model_task_change_msg)
	self.lister["model_query_one_task_data_response"] = basefunc.handler(self,self.on_model_query_one_task_data_response)
	self.lister["AssetChange"] = basefunc.handler(self, self.OnAssetChange)
	self.lister["get_task_award_new_response"] = basefunc.handler(self,self.on_get_task_award_new_response)
	self.lister["Act_007_ckt_Broadcast_Info"] = basefunc.handler(self,self.on_Act_007_ckt_Broadcast_Info)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:on_Act_007_ckt_Broadcast_Info(data)
    self:AddWaitData(data)
end

function C:MyExit()
	if self.backcall then 
		self.backcall()
	end
	if self.this_timer then 
        self.this_timer:Stop()
	end
	if self.de_timer then 
		self.de_timer:Stop()
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
	if self.Award_Data then 
		Event.Brocast("AssetGet", self.Award_Data)
		self.Award_Data = nil
	end 
	self:RemoveListener()
	destroy(self.gameObject)

	 
end

function C:ctor(parent,backcall)
	ExtPanel.ExtMsg(self)
	local parent = parent or GameObject.Find("Canvas/LayerLv3").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	self.backcall = backcall
	self.zhizhenAnimator = self.zhizhen.transform:GetComponent("Animator")
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	self.zhizhenAnimator:Play("act_007_ckt_normal")
	self:CloseAnimSound()
	self.timer = {}
	for i=1,#Loop_Order do
		self:LoopAnim(self[Loop_Order[i]])
	end
	Network.SendRequest("query_one_task_data", {task_id = M.task_id})
	--self:AnimIdle()
end

function C:InitUI()
	self.blackbg = self.transform:Find("blackbg"):GetComponent("Image")
	self.blackbg.color = Color.New(0,0,0,219/255)
	for i = 1,#M.config.base do 
		self["award"..i.."_img"].sprite = GetTexture(M.config.base[i].img)
		self["award"..i.."_txt"].text = M.config.base[i].text
	end
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
	self.can1_get_btn.onClick:AddListener(
		function ()
			Network.SendRequest("get_task_award_new", {id = M.task_id, award_progress_lv = 1})
		end
	)
	self.can2_get_btn.onClick:AddListener(
		function ()
			Network.SendRequest("get_task_award_new", {id = M.task_id, award_progress_lv = 2})
			self.task_award_real = true
		end
	)
	self.lottery1_btn.onClick:AddListener(
		function ()
			if MainModel.GetHBValue() < 1 then 
				HintPanel.Create(1,"您的福卡不足！")
			else
				if not self.is_during_anim then 
					Network.SendRequest("box_exchange",{id = 15,num = 1})
				end
			end 
		end
	)

	self.lottery10_btn.onClick:AddListener(
		function ()
			if MainModel.GetHBValue() < 10 then 
				HintPanel.Create(1,"您的福卡不足！")
			else
				if not self.is_during_anim then 
					Network.SendRequest("box_exchange",{id = 15,num = 10})
				end
			end 
		end
	)
	self:MyRefresh()
end

function C:GetIndex(award_id)
	local selectIndex
	for i = 1,#M.config.base do
		if award_id == M.config.base[i].server_award_id then 
			selectIndex = M.config.base[i].Index
		end 
	end
	return selectIndex
end


function C:OpenHelpPanel()
	local str = M.config.help_info[1].text
	for i = 2, #M.config.help_info do
		str = str .. "\n" .. M.config.help_info[i].text
	end
	self.introduce_txt.text = str
	IllustratePanel.Create({ self.introduce_txt.gameObject }, GameObject.Find("Canvas/LayerLv5").transform)
end

function C:MyRefresh()

end

function C:AnimStart(selectIndex)
	if not self.is_during_anim then
		self.curSoundKey = ExtendSoundManager.PlaySound(audio_config.game.bgm_duijihongbao.audio_name, 1, function()
			self.curSoundKey = nil
		end)
		self.is_during_anim = true
		self.zhizhenAnimator:Play("act_007_ckt_normal")
		local rota = -360 * 16 - 40 * (selectIndex - 2)
		local seq = DG.Tweening.DOTween.Sequence()
		local tweenKey = DOTweenManager.AddTweenToStop(seq)
		seq:Append(self.zhizhen:DORotate( Vector3.New(0, 0 , rota), 6, DG.Tweening.RotateMode.FastBeyond360):SetEase(DG.Tweening.Ease.InOutCubic))
		seq:OnKill(function ()
			DOTweenManager.RemoveStopTween(tweenKey)
			if IsEquals(self.gameObject) then
				self.zhizhen.localRotation = Quaternion:SetEuler(0, 0, rota)
				self:CloseAnimSound()
				self:EndRotaAnim()
			end 
		end)
	end 
end

function C:EndRotaAnim()
	self.zhizhenAnimator:Play("act_004JIKAPanel_zhizhen")
	if self.de_timer then 
		self.de_timer:Stop()
	end
	self.de_timer = Timer.New(function ()
		self.zhizhenAnimator:Play("act_007_ckt_normal")
		if self.Award_Data then 
			Event.Brocast("AssetGet", self.Award_Data)
			self.Award_Data = nil
			self.is_during_anim = false
		end
	end,1.4,1)
	self.de_timer:Start()
end


function C:CloseAnimSound()
	if self.curSoundKey then
		soundMgr:CloseLoopSound(self.curSoundKey)
		self.curSoundKey = nil
	end
end


function C:AddWaitData(data)
	self:CheakNode()
    table.insert(Wait_Broadcast_data,1,data)
end

function C:RemoveWaitData()
    table.remove(Wait_Broadcast_data,#Wait_Broadcast_data)
end

function C:GetWaitData()
	return Wait_Broadcast_data[#Wait_Broadcast_data]
end


function C:LoopAnim(obj)
	local temp_ui = {}
	self.timer[#self.timer + 1] = Timer.New(function ()
        obj.transform:Translate(Vector3.left * 3)
		if obj.transform.localPosition.x <= hide_left_pos then
			LuaHelper.GeneratingVar(obj.transform, temp_ui)
			temp_ui.info_txt.text = ""
			obj.transform.localPosition = Vector3.New(hide_left_pos + space * #Loop_Order,0,0)
			if self:GetWaitData() then
				temp_ui.info_txt.text = "恭喜玩家<color=#4eea3d>"..self:GetWaitData().playname.."</color>通过抽奖,获得<color=#ff9257>"..self:GetWaitData().awardname.."</color>"
				self:RemoveWaitData()
			end
        end
	end,0.02,-1,nil,true)
	self:SetPos()
end

function C:CheakNode()
	local ht = hide_time
	if self.DelayToShow_Timer then
		self.DelayToShow_Timer:Stop()
	end
	self.DelayToShow_Timer = Timer.New(
		function ()
			self.UINode.gameObject:SetActive(true)
		end
	,7,1) 
	self.DelayToShow_Timer:Start()
	if self.Cheak_Timer then 
		self.Cheak_Timer:Stop()
	end
	for i = 1,#self.timer do 
		if self.timer[i] then 
			self.timer[i]:Start()
		end
	end
	self.Cheak_Timer = Timer.New(
		function()
			ht = ht - 0.1
			if ht <= 0 then 
				ht = 9999999
				self.UINode.gameObject:SetActive(false)
				self:SetPos()
				for i = 1,#self.timer do 
					if self.timer[i] then 
						self.timer[i]:Stop()
					end
				end
			end 
		end 
	,0.1,-1)
	self.Cheak_Timer:Start()
end

function C:SetPos()
	for i=1,#Loop_Order do
		self[Loop_Order[i]].transform.localPosition = Vector3.New(hide_left_pos + space * (i - 1) + 2,0,0)
	end
end

function C:on_box_exchange_response(_,data)
	dump(data,"<color=red>----------抽奖数据-----------</color>")
	if data.result == 0 then
		if #data.award_id == 1 then 
			local selectIndex = self:GetIndex(data.award_id[1])
			self:AnimStart(selectIndex)
		else
			local real_list = self:GetRealInList(data.award_id)
			dump(real_list,"<color=red>-------实物奖励------</color>")

			if self:IsAllRealPop(data.award_id,real_list) then 
				RealAwardPanel.Create(self:GetShowData(real_list))
			else
				self.call = function ()
					if not table_is_null(real_list) then 
						MixAwardPopManager.Create(self:GetShowData(real_list),nil,2)
					end
				end 
			end
			self:TryToShow()
		end
	end 
end

function C:on_model_task_change_msg(data)
	dump(data,"<color=red>----------任务改变-----------</color>")
	if data and data.id == M.task_id then
		self:ReFreshTask(data)
	end 
end

function C:on_model_query_one_task_data_response(data)
	dump(data,"<color=red>----------任务信息获得-----------</color>")
	if data and data.id == M.task_id then
		self:ReFreshTask(data)
	end 
end


function C:ReFreshTask(data)
	local b = basefunc.decode_task_award_status(data.award_get_status)
	b = basefunc.decode_all_task_award_status(b, data, 2)
	self.total_times_txt.text = "当前抽奖次数："..data.now_total_process
	for i = 1,#b do 
		if b[i] == 0 then
			self["can"..i.."_get_btn"].gameObject:SetActive(false)
			self["mask"..i].gameObject:SetActive(false)
		elseif b[i] == 1 then
			self["can"..i.."_get_btn"].gameObject:SetActive(true)
			self["mask"..i].gameObject:SetActive(false)
		elseif b[i] == 2 then
			self["can"..i.."_get_btn"].gameObject:SetActive(false)
			self["mask"..i].gameObject:SetActive(true)
		end 
	end
end


--在奖励列表里面获取实物奖励的ID
function C:GetRealInList(award_id)
	local r_list = {}
	local temp
	for i=1,#award_id do
		temp = self:GetConfigByServerID(award_id[i])
		if temp.real == 1 then 
			r_list[#r_list + 1] = temp
		end
	end
	return r_list
end
--根据ID获取配置信息
function C:GetConfigByServerID(server_award_id)
	for i=1,#M.config.base do
		if M.config.base[i].server_award_id == server_award_id then 
			return M.config.base[i]
		end 
	end
end
--如果全都是实物奖励，就直接用 realawardpanel
function C:IsAllRealPop(award_id,real_list)
	if #real_list >= #award_id then 
		return true
	else
		return false
	end 
end
--把配置数据转换为奖励展示面板所需要的数据格式
function C:GetShowData(real_list)
	local data = {}
	data.text = {}
	data.image = {}
	for i=1,#real_list do
		data.text[#data.text + 1] = real_list[i].text
		data.image[#data.image + 1] = real_list[i].img
	end
	return data
end

function C:OnAssetChange(data)
	dump(data,"<color=red>----奖励类型-----</color>")
	if data.change_type and data.change_type == "box_exchange_active_award_15" and not table_is_null(data.data) then
		for i = 1, #data.data do
			local award_name
			if data.data[i].asset_type == "shop_gold_sum" then
				award_name = "福卡".." x"..(data.data[i].value/100)
			elseif data.data[i].asset_type == "jing_bi" then 
				award_name = "鲸币".." x"..data.data[i].value
			end
			local data = {playname = MainModel.UserInfo.name,awardname = award_name}
			self:AddWaitData(data)
		end
		self.Award_Data = data
		self:TryToShow()
	end
end

function C:TryToShow()
	dump(self.Award_Data,"1")
	dump(self.call,"2")

	if self.Award_Data and self.call then
		self.call() 
		Event.Brocast("AssetGet",self.Award_Data)
		self.Award_Data = nil
		self.call = nil 
	end 
end

function C:OnDestroy()
	self:MyExit()
end

function C:on_get_task_award_new_response(_,data)
	if data and data.result == 0 then
		if self.task_award_real then 
			RealAwardPanel.Create({image = "activity_icon_gift66",text = "东北大米"})
			self.task_award_real = false
		end
	end 
end