-- 创建时间:2019-11-28
-- Panel:MyPupil
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

MyPupilPanel = basefunc.class()
local C = MyPupilPanel
C.name = "MyPupilPanel"
--控制排序
local order_data = {
	[1] = "apply_item",
	[2] = "repair_item",
	[3] = "broke_item",
	[4] = "pupil_item",
}
--当前各个子物体个数
local index_data = {
	apply_item = 0, 
	broke_item = 0,
	pupil_item = 0,
	repair_item = 0,
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
	-- self.lister["query_apprentice_notify_info_list_response"] = basefunc.handler(self,self.on_query_apprentice_notify_info_list_response)
	-- self.lister["query_apprentice_personal_info_list_response"] = basefunc.handler(self,self.on_query_apprentice_personal_info_list_response)
	self.lister["Pupil_Notify_Finsh"] = basefunc.handler(self,self.Pupil_Notify_Finsh)
	self.lister["Pupil_Info_Finsh"] = basefunc.handler(self,self.Pupil_Info_Finsh)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	self:RemoveListener()
	destroy(self.gameObject)

	 
end

function C:ctor(parent)
	ExtPanel.ExtMsg(self)
	local parent = parent or GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	self.transform.localPosition = Vector3.zero
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	-- Network.SendRequest("query_apprentice_notify_info_list")
	-- Network.SendRequest("query_apprentice_personal_info_list")
	SYSSTXTManager.SendPupilQuery()
end

function C:InitUI()
	self:MyRefresh()
end

function C:MyRefresh()

end

function C:AutoSetSibling(obj)
	index_data[obj.name] = index_data[obj.name] + 1
	local index = 0
	for i = 1,#order_data do
		if obj.name == order_data[i] then 
			obj.transform:SetSiblingIndex(index + index_data[obj.name] - 1)
			return  
		else
			index = index + self:GetItemIndex(order_data[i])
		end
	end
end

function C:GetItemIndex(item)
	return index_data[item]
end

-- message_data type 
--     1 徒弟向师父申请
--     2 师父收到徒弟的申请消息
--     3 徒弟收到的师父对自己的解除关系消息
--     4 师父收到的徒弟对自己的解除关系消息
--     5 徒弟收到的师父对自己的恢复关系消息
--     6 师父收到的徒弟对自己的恢复关系消息
--     7 徒弟收到的师父对自己的拒绝关系消息


function C:Refresh_Notify_UI(data)
	local temp_ui = {}
	if data then
		local data = table.sort(data,function (a,b)
			return a.time > b.time
		end) or data
		for i = 1,#data do 
			if data[i].type == 2 then 
				local b = GameObject.Instantiate(self.apply_item,self.Content)
				LuaHelper.GeneratingVar(b.transform, temp_ui)
				b.name = "apply_item"
				b.gameObject:SetActive(true)
				URLImageManager.UpdateHeadImage(data[i].head_image,temp_ui.head_img)
				temp_ui.name_txt.text = data[i].player_name
				temp_ui.vip_txt.text = "VIP"..data[i].vip_level
				temp_ui.confirm_btn.onClick:AddListener(
					function ()
						ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name) 
						Network.SendRequest("deal_apply_info_from_master",{apprentice_id = data[i].player_id,status = 0},"",function (t_data)
							if t_data and t_data.result == 0 then 
								self:CreatePupil(data[i])
								HintPanel.Create(1,"恭喜您,您已成功收徒【"..data[i].player_name.."】")
							else
								HintPanel.ErrorMsg(data.result)
							end 
						end)
						Event.Brocast("tp_CloseTHENOpen")
						b.gameObject:SetActive(false)										
					end
				)
				temp_ui.refuse_btn.onClick:AddListener(
					function ()
						ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name) 
						Network.SendRequest("deal_apply_info_from_master",{apprentice_id = data[i].player_id,status = 1})
						b.gameObject:SetActive(false)
					end
				)		
				self:AutoSetSibling(b)
			end
			if data[i].type == 4 then 
				local b = GameObject.Instantiate(self.broke_item,self.Content)
				LuaHelper.GeneratingVar(b.transform, temp_ui)
				b.name = "broke_item"
				b.gameObject:SetActive(true)
				URLImageManager.UpdateHeadImage(data[i].head_image,temp_ui.head_img)
				temp_ui.name_txt.text = data[i].player_name
				temp_ui.vip_txt.text = "VIP"..data[i].vip_level
				temp_ui.confirm_btn.onClick:AddListener(
					function ()
						ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name) 
						Network.SendRequest("confirm_message_from_master",{apprentice_id = data[i].player_id,message_type = 1})
						b.gameObject:SetActive(false)
					end
				)
				self:AutoSetSibling(b)
			end
			if data[i].type == 6 then 
				local b = GameObject.Instantiate(self.repair_item,self.Content)
				LuaHelper.GeneratingVar(b.transform, temp_ui)
				b.name = "repair_item"
				b.gameObject:SetActive(true)
				URLImageManager.UpdateHeadImage(data[i].head_image,temp_ui.head_img)
				temp_ui.name_txt.text = data[i].player_name
				temp_ui.vip_txt.text = "VIP"..data[i].vip_level
				temp_ui.confirm_btn.onClick:AddListener(
					function ()
						ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name) 
						Network.SendRequest("confirm_message_from_master",{apprentice_id = data[i].player_id,message_type = 2})
						b.gameObject:SetActive(false)
					end
				)
				self:AutoSetSibling(b)
			end
		end 
	end 
end

function C:Refresh_Info_UI(data)
	local temp_ui = {}
	if data and data.result == 0 then
		if table_is_null(data.apprentice_info) then LittleTips.Create("您还没有徒弟") return end 
		for i=1,#data.apprentice_info do
			self:CreatePupil(data.apprentice_info[i])
		end
	end 
end

function C:OnDestroy()
	self:MyExit()
end

function C:CreatePupil(data)
	local temp_ui = {}
	local b = GameObject.Instantiate(self.pupil_item,self.Content)
	b.name = "pupil_item"
	b.gameObject:SetActive(true)
	LuaHelper.GeneratingVar(b.transform, temp_ui)
	URLImageManager.UpdateHeadImage(data.head_image,temp_ui.head_img)
	LuaHelper.GeneratingVar(b.transform, temp_ui)
	temp_ui.name_txt.text = data.player_name
	temp_ui.vip_txt.text = "VIP"..data.vip_level
	temp_ui.like_txt.text = data.like_num or 0
	if data.online_status == 1 then 
		temp_ui.time_txt.text = self:GetTimeLineStr(tonumber(data.last_exit_time))
		temp_ui.time_txt.color = Color.gray
	else
		temp_ui.time_txt.text = "在线"
		temp_ui.time_txt.color = Color.New(220/255,139/255,66/255,1)
	end
	temp_ui.broke_btn.onClick:AddListener(
		function ()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name) 
			BrokeTPPanel.Create(nil,data,"T")
		end 
	)
	temp_ui.invite_btn.onClick:AddListener(
		function ()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name) 
			InviteGamesPanel.Create(nil,data.apprentice_id)
		end
	)
	temp_ui.gift_btn.onClick:AddListener(
		function ()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name) 
			TpEncouragePanel.Create(nil,data.apprentice_id)
		end
	)
	if table_is_null(data.task_data) or (data.task_data and data.task_data.master_task_status  and data.task_data.master_task_status.master_is_can_get_award == 1) then 
		temp_ui.task_red.gameObject:SetActive(true)	
	else
		temp_ui.task_red.gameObject:SetActive(false)	
	end 
	temp_ui.task_btn.onClick:RemoveAllListeners()
	temp_ui.task_btn.onClick:AddListener(
		function ()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name) 
			if not table_is_null(data.task_data) then
				ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name) 
				TpTaskPanel.Create(nil,data.task_data,"Teacher",data.apprentice_id)						
			else			
				ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name) 
				ConfirmPublishTaskPanel.Create(nil,data.apprentice_id)
			end  
		end
	)
	self:AutoSetSibling(b)
end

function C:GetTimeLineStr(time)
	if not time then return "已下线" end 
	if os.time() - time >= 0 and os.time() - time <= 24 * 3600 then
		if  os.time() - time <= 3600 then
			return math.floor((os.time() - time)/60).."分钟前"
		end 
		return math.floor((os.time() - time)/3600).."小时前"
	elseif os.time() - time > 24 * 3600 then
		return math.floor((os.time() - time)/86400).."天前"
	end 
end

function C:Pupil_Notify_Finsh()
	dump(SYSSTXTManager.Get_Pupil_Notify(),"<color=red>Pupil_Notify_Finsh</color>")
	self:Refresh_Notify_UI(SYSSTXTManager.Get_Pupil_Notify())
end

function C:Pupil_Info_Finsh()
	dump(SYSSTXTManager.Get_Pupil_Info(),"<color=red>Pupil_Info_Finsh</color>")
	self:Refresh_Info_UI(SYSSTXTManager.Get_Pupil_Info())
end