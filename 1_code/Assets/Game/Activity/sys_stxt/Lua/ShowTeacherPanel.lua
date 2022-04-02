-- 创建时间:2019-11-28
-- Panel:ShowTeacherPanel
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

ShowTeacherPanel = basefunc.class()
local C = ShowTeacherPanel
C.name = "ShowTeacherPanel"

function C.Create(parent,data)
	return C.New(parent,data)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
	self.lister = {}
	self.lister["bai_shi_response"] = basefunc.handler(self,self.on_bai_shi_response)
	self.lister["del_publish_master_info_response"] = basefunc.handler(self,self.on_del_publish_master_info_response)
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

function C:ctor(parent,data)

	ExtPanel.ExtMsg(self)

	local parent = parent or GameObject.Find("Canvas/LayerLv5").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	self.data = data
	LuaHelper.GeneratingVar(self.transform, self)
	self.transform.localPosition =  Vector3.zero
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	self.close_btn.onClick:AddListener(
		function ()
			self:MyExit()
		end
	)
	self.name_txt.text = self.data.player_name
	self.id_txt.text = self.data.player_id
	self.vip_txt.text = "VIP"..self.data.vip_level
	local is_myself =  self.data.player_id == MainModel.UserInfo.user_id
	self.button_txt.text = is_myself and "删 除" or "拜 师"
	URLImageManager.UpdateHeadImage(self.data.head_image,self.head_img)
	self.get_btn.onClick:AddListener(
		function ()
			if not is_myself then
				if VIPManager.get_vip_level() >= SYSSTXTManager.GetLimitByKey("vip_t_limit") then
					Network.SendRequest("bai_shi",{master_id = self.data.player_id})
				else
					HintPanel.Create(2,"您的VIP等级不足，前往提升VIP等级",function ()
						PayPanel.Create(GOODS_TYPE.jing_bi, "normal")
					end)
				end
			else
				local b = HintPanel.Create(4," 是否删除您的拜师消息？\n\n<size=30>注意:费用不会返还</size>",function ()
					self:DeleteMyInfo()
				end)
				b:SetBtnTitle("确 定","取 消")
			end 
		end
	)
	self.like_txt.text = self.data.total_like_num
	self.message_txt.text = self:GetMessageByID(self.data.message_id)
	self:MyRefresh()
end

function C:MyRefresh()

end

function C:GetMessageByID(__id)
	return SYSSTXTManager.master_message_config.master_message_config[__id].master_message
end

function C:on_bai_shi_response(_,data)
	dump(data,"<color=red>拜师反应</color>")
	if data and data.result == 0 then 
		HintPanel.Create(1,"申请拜师已发送")
		self:MyExit()
	else
		HintPanel.ErrorMsg(data.result)
	end 
end

function C:DeleteMyInfo()
	Network.SendRequest("del_publish_master_info",{info_id = self.data.id})
end 

function C:on_del_publish_master_info_response(_,data)
	if data and data.result == 0 then 
		HintPanel.Create(1,"操作成功",function ()
			Event.Brocast("tp_CloseTHENOpen")
		end)
		self:MyExit()
	else
		HintPanel.ErrorMsg(data.result)
	end
end