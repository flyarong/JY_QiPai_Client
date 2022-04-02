local basefunc = require "Game/Common/basefunc"

Act_029_ZNQCJPanel = basefunc.class()
local C = Act_029_ZNQCJPanel
C.name = "Act_029_ZNQCJPanel"
local config = 	Act_029_ZNQCJManager.config
local DESCRIBE_TEXT = {
	[1] = "1.活动时间：9月15日7:30-9月21日23:59:59",
	[2] = "2.实物奖励，请联系客服QQ：4008882620领取，否则视为自动放弃奖励",
	[3] = "3.活动中的图片仅作为参考，请以实际发出的奖励为准",	
}

local offset = {
	0,10,50,100,200,500
}

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
	self.backcall = backcall
	LuaHelper.GeneratingVar(self.transform, self)
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	self:UpDateQiPao()
	self.transform:Find("bg/Text (5)"):GetComponent("Text").text = "28.8福卡"
	self.transform:Find("bg/Text (4)"):GetComponent("Text").text = "12.8福卡"
	Network.SendRequest("query_one_task_data", {task_id = Act_029_ZNQCJManager.task_id})
end

function C:InitUI()
	self.lottery1_btn.onClick:AddListener(
		function () 
			ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
			if GameItemModel.GetItemCount("prop_2year_jinianbi3") < 10 then 
				HintPanel.Create(1,"纪念币不足！")
			else	
				Network.SendRequest("box_exchange",{id = 66,num = 1})				
			end 
		end
	)
	self.lottery2_btn.onClick:AddListener(
		function ()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
			if GameItemModel.GetItemCount("prop_2year_jinianbi3") < 100 then 
				HintPanel.Create(1,"纪念币不足！")
			else
				Network.SendRequest("box_exchange",{id = 66,num = 10})
			end 
		end
	)
	self.more_btn.onClick:AddListener(
		function()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
			LTTipsPrefab.Show(self.more_btn.gameObject.transform,1,"<color=#FFF9B8><size=46>还有机会获得：</size>\n<size=36>200优惠券，100优惠券，50优惠券，\n10优惠券，5优惠券，\n怡宝矿泉水，大枣夹核桃，网红小麻花，\n金龙鱼大豆油，夏日短袜，大量鲸币，\n鱼币，话费碎片和福卡</size></color>")
		end
	)
	self.help_btn.onClick:AddListener(
		function ()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
			self:OpenHelpPanel()
		end
	)
	self.Anims = {}
	for i = 1,5 do
		self.Anims[#self.Anims + 1] = CommonHuxiAnim.Go(self["award"..i.."_btn"].gameObject,0.9,1,1.3)
		self["award"..i.."_btn"].onClick:AddListener(
			function()
				local data = GameTaskModel.GetTaskDataByID(Act_029_ZNQCJManager.task_id)
				if data then
					local b = basefunc.decode_task_award_status(data.award_get_status)
					b = basefunc.decode_all_task_award_status(b, data, 5)
					if b[i] == 1 then
						Network.SendRequest("get_task_award_new", { id = Act_029_ZNQCJManager.task_id, award_progress_lv = i })
						if i == 5 then
							RealAwardPanel.Create({image = "activity_icon_gift225_jgdlb",text = "坚果大礼包"})
						end
					end
				end
			end
		)
	end
	self.num_txt.text = "x"..GameItemModel.GetItemCount("prop_2year_jinianbi3")
	self:MyRefresh()
end

function C:MyRefresh()
end

function C:on_box_exchange_response(_,data)
	dump(data,"<color=red>----------抽奖数据-----------</color>")
	if data.result == 0 then
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

function C:on_model_task_change_msg(data)
	dump(data,"<color=red>----------任务改变-----------</color>")
	if data and data.id == Act_029_ZNQCJManager.task_id then
		--self.num_txt.text = data.now_total_process
		local b = basefunc.decode_task_award_status(data.award_get_status)
		b = basefunc.decode_all_task_award_status(b, data, 5)
		self:ReFreshProgress(data.now_total_process)
		self:ReFreshTaskButtons(b)
	end 
end

function C:on_model_query_one_task_data_response(data)
	dump(data,"<color=red>----------任务信息获得-----------</color>")
	if data and data.id == Act_029_ZNQCJManager.task_id then
		--self.num_txt.text = data.now_total_process
		local b = basefunc.decode_task_award_status(data.award_get_status)
		b = basefunc.decode_all_task_award_status(b, data, 5)
		self:ReFreshProgress(data.now_total_process)
		self:ReFreshTaskButtons(b)
	end 
end
--在奖励列表里面获取实物奖励的ID
function C:GetRealInList(award_id)
	local r_list = {}
	local temp
	for i=1,#award_id do
		temp = self:GetConfigByServerID(award_id[i])
		if temp then
			r_list[#r_list + 1] = temp
		end
	end
	return r_list
end
--根据ID获取配置信息
function C:GetConfigByServerID(server_award_id)
	return Act_029_ZNQCJManager.config[server_award_id]
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
		data.image[#data.image + 1] = real_list[i].image
	end
	return data
end

function C:OnAssetChange(data)
	dump(data,"<color=red>----奖励类型-----</color>")
	if data.change_type and data.change_type == "box_exchange_active_award_66" and not table_is_null(data.data) then
		self.Award_Data = data
		self:TryToShow()
	end
	self.num_txt.text = "x"..GameItemModel.GetItemCount("prop_2year_jinianbi3")
end

function C:TryToShow()
	if self.Award_Data and self.call then
		self.call() 
		Event.Brocast("AssetGet",self.Award_Data)
		self.Award_Data = nil
		self.call = nil 
	end
end

function C:ReFreshTaskButtons(list)
	for i = 1,#list do
		if list[i] == 1 then
			self.Anims[i].Start()
			self["get"..i].gameObject:SetActive(true)
		else
			self.Anims[i].Stop()
			self["get"..i].gameObject:SetActive(false)
		end
		self["mask"..i].gameObject:SetActive(list[i] == 2)
	end
end

function C:ReFreshProgress(total)
	local len = {
		[1] = {min = 0,max = 66.71},
		[2] = {min = 107.58,max = 235.98},
		[3] = {min = 279.8,max = 408.37},
		[4] = {min = 447.73,max = 577.65},
		[5] = {min = 620.21,max = 779.29},
	}
	local now_level = 1
	for i = #offset,1,-1 do
		if total >= offset[i] then
			now_level = i
			break
		end
	end
	if now_level > 5 then
		self.progress.sizeDelta={x = len[#len].max,y = 29.78}
	else
		local now_need = offset[now_level + 1] - offset[now_level]
		local now_have = total - offset[now_level]
		local l = (now_have/now_need) * (len[now_level].max - len[now_level].min) + len[now_level].min
		self.progress.sizeDelta={x = l,y = 20.8}
	end
	self:RefreshNum(total)
end

function C:GetCurrPercentage(nowlv,total)
	
end

function C:GetProgressX(percentage,o_d)
	
end

function C:OpenHelpPanel()
	local str = DESCRIBE_TEXT[1]
	for i = 2, #DESCRIBE_TEXT do
		str = str .. "\n" .. DESCRIBE_TEXT[i]
	end
	self.introduce_txt.text = str
	IllustratePanel.Create({ self.introduce_txt.gameObject }, GameObject.Find("Canvas/LayerLv5").transform)
end

function C:OnDestroy()
	self:MyExit()
end

function C:RefreshNum(total)
	for i = 1,5 do
		local num = total >= offset[i + 1] and  offset[i + 1] or total
		self["n"..i.."_txt"].text = num.."/"..offset[i + 1]
	end
end

function C:UpDateQiPao()
	local seq = DoTweenSequence.Create()
    seq:AppendInterval(10)
    seq:AppendCallback(function ()
		if IsEquals(self.gameObject) then
			self.qipao.gameObject:SetActive(true)
		end
    end)
    seq:AppendInterval(2)
    seq:AppendCallback(function ()
	    if IsEquals(self.gameObject) then
			self.qipao.gameObject:SetActive(false)
		end
	end)
	seq:SetLoops(-1,DG.Tweening.LoopType.Restart)
end