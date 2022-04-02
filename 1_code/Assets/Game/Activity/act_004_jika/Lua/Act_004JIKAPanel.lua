-- 创建时间:2020-03-11
-- Panel:Act_004JIKAPanel
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

Act_004JIKAPanel = basefunc.class()
local C = Act_004JIKAPanel
C.name = "Act_004JIKAPanel"
local hide_time = 17
local Wait_Broadcast_data = {}
local Wait_OBj
local Loop_Order = {"RollPrefab1","RollPrefab2","RollPrefab3"}
local hide_left_pos = -1300
local space = 1100
local M = Act_004JIKAManager
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
	self.lister["query_jika_base_info_response"] = basefunc.handler(self,self.on_query_jika_base_info_response)
	self.lister["jika_everyday_lottery_response"] = basefunc.handler(self,self.on_jika_everyday_lottery_response)
	self.lister["jika_base_info_change_msg"] = basefunc.handler(self,self.jika_base_info_change_msg)
	self.lister["get_one_jika_false_lottery_data_response"] = basefunc.handler(self,self.on_get_one_jika_false_lottery_data_response)
	self.lister["AssetChange"] = basefunc.handler(self, self.OnAssetChange)
	self.lister["AssetsGetPanelConfirmCallback"] = basefunc.handler(self,self.AssetsGetPanelConfirmCallback)
	self.lister["ExitScent"] = basefunc.handler(self,self.MyExit)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	self:RemoveListener()
	if self.backcall then 
		self.backcall()
	end
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
	self.zhizhenAnimator = self.zhizhen.transform:GetComponent("Animator")
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	self.zhizhenAnimator.speed = 0
	self:CloseAnimSound()
	Network.SendRequest("query_jika_base_info")
	self.timer = {}
	for i=1,#Loop_Order do
		self:LoopAnim(self[Loop_Order[i]])
	end
	self:SendBroadcastInfo()
	Network.SendRequest("get_one_jika_false_lottery_data")
	--self:AnimIdle()
end

function C:InitUI()
	self.blackbg = self.transform:Find("blackbg"):GetComponent("Image")
	self.blackbg.color = Color.New(0,0,0,219/255)
	for i = 1,#M.config.base do 
		self["award"..i.."_img"].sprite = GetTexture(M.config.base[i].award_image)
		self["award"..i.."_txt"].text = M.config.base[i].award_text
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
	self.buy_btn.onClick:AddListener(
		function ()
			M.BuyShop()
		end
	)
	self.jika_btn.onClick:AddListener(
		function ()
			MoneyCenterQFLBPanel.Create()
			self:MyExit()
		end
	)
	self.lottery_btn.onClick:AddListener(
		function ()
			self.total_remain_num = self.total_remain_num or 0 
			if self.total_remain_num > 0 and not self.is_during_anim  then 
				Network.SendRequest("jika_everyday_lottery")
			else
				M.BuyShop()
			end 
		end
	)
	self:MyRefresh()
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
	if not IsEquals(self.gameObject) then return end
	if Act_004JIKAManager.isBuy and (MoneyCenterQFLBManager and not MoneyCenterQFLBManager.IsBuy3()) then
		if IsEquals(self.jikanode) then
			self.jikanode.gameObject:SetActive(false)
		end
		self.qflbnode.gameObject:SetActive(true)
	else
		if IsEquals(self.jikanode) then
			self.jikanode.gameObject:SetActive(true)
		end
		self.qflbnode.gameObject:SetActive(false)
	end
end

function C:AnimStart(selectIndex)
	if not self.is_during_anim then
		self.curSoundKey = ExtendSoundManager.PlaySound(audio_config.game.bgm_duijihongbao.audio_name, 1, function()
			self.curSoundKey = nil
		end)
		self.is_during_anim = true
		if IsEquals(self.zhizhenAnimator) then
			self.zhizhenAnimator.speed = 0
		end
		local rota = -360 * 16 - 40 * (selectIndex - 2)
		local seq = DoTweenSequence.Create()
		seq:Append(self.zhizhen:DORotate( Vector3.New(0, 0 , rota), 6, DG.Tweening.RotateMode.FastBeyond360):SetEase(DG.Tweening.Ease.InOutCubic))
		seq:OnKill(function ()
			if IsEquals(self.gameObject) then 
				self.zhizhen.localRotation = Quaternion:SetEuler(0, 0, rota)
				self:CloseAnimSound()
				self:EndRotaAnim()
			end 
		end)
	end 
end

function C:EndRotaAnim()
	self.zhizhenAnimator.speed = 1
	self.de_timer = Timer.New(function ()
		self.zhizhenAnimator.speed = 0
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

function C:on_query_jika_base_info_response(_,data)
	dump(data,"<color=red>季卡  基础信息</color>")
	if data and data.result == 0 then
		self:RefreshUI(data)
	end
end

function C:on_jika_everyday_lottery_response(_,data)
	dump(data,"<color=red>抽奖返回----</color>")
	if data and data.result == 0 then
		local selectIndex = self:GetIndex(data.award_id)
		self:AnimStart(selectIndex)
		local d = {name = data.name,award_id = data.award_id}
		self:AddWaitData(d)
	end 
end

function C:jika_base_info_change_msg(_,data)
	dump(data,"<color=red>信息改变----</color>")
	self:RefreshUI(data)
end

function C:GetIndex(award_id)
	local selectIndex
	for i = 1,#M.config.base do
		if award_id == M.config.base[i].award_id then 
			 selectIndex = M.config.base[i].Index
		end 
	end
	return selectIndex
end

function C:OnAssetChange(data)
	dump(data, "<color=red>----奖励类型-----</color>")
	if data.change_type and data.change_type == "jika_lottery_award" then
		self.cur_award = data
	end
end

function C:RefreshUI(data)
	if not IsEquals(self.gameObject) then return end
	self.total_remain_num = data.total_remain_num
	if data.total_remain_num > 0 then
		if IsEquals(self.num_txt) then
			self.num_txt.text = "X"..data.total_remain_num
		end
		if IsEquals(self.num2_txt) then
			self.num2_txt.text = "X"..data.total_remain_num
		end
		if IsEquals(self.maiqian) then
			self.maiqian.gameObject:SetActive(false)
		end
		self.maihou.gameObject:SetActive(true)
	else
		if IsEquals(self.maiqian) then
			self.maiqian.gameObject:SetActive(true)
		end
		self.maihou.gameObject:SetActive(false)
	end 
	if data.is_lottery == 1 then 
		self.mrcj.gameObject:SetActive(true)
	else
		self.mrcj.gameObject:SetActive(false)
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
				temp_ui.info_txt.text = "恭喜玩家<color=#4eea3d>"..self:GetWaitData().name.."</color>通过抽奖,获得奖励<color=#ff9257>"..self:getNameByID(self:GetWaitData().award_id).."</color>"
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

function C:SendBroadcastInfo()
    local random = math.random(6,10)
    local curr_Hour = tonumber(os.date("%H",os.time()))
    if curr_Hour <= 5 or curr_Hour >= 22 then 
        random = math.random(8,20)
    end 
    local func = function ()
        Network.SendRequest("get_one_jika_false_lottery_data")
    end 
    if self.this_timer then 
        self.this_timer:Stop()
    end
    self.this_timer = nil 
    self.this_timer = Timer.New(function ()
        func()
        self:SendBroadcastInfo()
    end,random,1)
    self.this_timer:Start()
end

function C:on_get_one_jika_false_lottery_data_response(_,data)
	if data and data.result == 0 then 
		local d = {name = data.name,award_id = data.award_id}
		self:AddWaitData(d)
	end
end

function C:getNameByID(award_id)
	for i = 1,#M.config.base do 
		if M.config.base[i].award_id == award_id then 
			return M.config.base[i].award_text
		end
	end 
end

function C:AnimIdle()
	if self.idle_timer then 
		self.idle_timer:Stop()
	end
	self.idle_timer = Timer.New(function ()
		if not self.is_during_anim then
			dump(self.zhizhen.localEulerAngles,"-----------------------------")
			local z = self.zhizhen.localEulerAngles.z
			self.zhizhen.localRotation = Quaternion:SetEuler(0, 0, z - 40 )
		end 
	end,1.67,-1)
	self.idle_timer:Start()
end

function C:AssetsGetPanelConfirmCallback()
	self:MyRefresh()
end