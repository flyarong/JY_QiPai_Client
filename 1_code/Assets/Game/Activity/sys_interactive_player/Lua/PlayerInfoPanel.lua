-- 创建时间:2018-09-11

local basefunc = require "Game.Common.basefunc"

PlayerInfoPanel = basefunc.class()

local instance = nil
function PlayerInfoPanel.Create(pinfo, uipos, uinode)
	if not pinfo then
		return
	end
	print("<color=red>PlayerInfoPanel.Create uipos = " .. uipos .. "</color>")
	instance = PlayerInfoPanel.New(pinfo, uipos, uinode)
	return instance
end
function PlayerInfoPanel.Exit()
	if instance then
		instance:ExitUI()
		instance = nil
	end
end

function PlayerInfoPanel:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function PlayerInfoPanel:MakeLister()
    self.lister = {}
    self.lister["model_dress_data"] = basefunc.handler(self, self.model_dress_data)
end

function PlayerInfoPanel:RemoveListener()
    for proto_name,func in pairs(self.lister or {}) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function PlayerInfoPanel:ctor(pinfo, uipos, uinode)

	ExtPanel.ExtMsg(self)

	local parent = GameObject.Find("Canvas/LayerLv4").transform
    self.gameObject = newObject("PlayerInfoPanel", parent)
    self.transform = self.gameObject.transform
    local tran = self.transform

    self:MakeLister()
    self:AddMsgListener()

    self.pinfo = pinfo
    self.uipos = uipos
    self.uinode = uinode

    self.HeadIcon = tran:Find("InfoRect/TopRect/HeadNode/HeadIcon"):GetComponent("Image")
    self.HeadBG = tran:Find("InfoRect/TopRect/HeadNode/HeadBG"):GetComponent("Image")
    self.head_vip_txt = tran:Find("InfoRect/TopRect/HeadNode/@head_vip_txt"):GetComponent("Text")
    self.PlayerNameText = tran:Find("InfoRect/TopRect/PlayerNameText"):GetComponent("Text")
    self.PlayerIDText = tran:Find("InfoRect/TopRect/PlayerIDText"):GetComponent("Text")
    self.WomanImage = tran:Find("InfoRect/TopRect/WomanImage")
    self.ManImage = tran:Find("InfoRect/TopRect/ManImage")

    self.LevelText = tran:Find("InfoRect/TopRect/LevelText"):GetComponent("Text")

    self.InfoRect = tran:Find("InfoRect")
    self.Cell = tran:Find("InfoRect/DownRect/Cell")
    self.Content = tran:Find("InfoRect/DownRect/ScrollView/Viewport/Content")
    self.TopButton = tran:Find("TopButton"):GetComponent("MyButton")
    EventTriggerListener.Get(self.TopButton.gameObject).onClick = basefunc.handler(self, self.ExitUI)
    self:InitRect()
end

function PlayerInfoPanel:model_dress_data()
	self.list = {}
	local bqtype = 2
	if self.pinfo.id == MainModel.UserInfo.user_id then
		bqtype = 1
	end
	local data = PersonalInfoManager.GetAnimChatData()
    for k,v in ipairs(data) do
    	if v.type == bqtype then
    		self.list[#self.list + 1] = v
    	end
    end
    dump(self.list, "<color=red>PlayerInfoPanel list</color>")

	for k,v in ipairs(self.list) do
		local obj = GameObject.Instantiate(self.Cell, self.Content)
		obj.gameObject:SetActive(true)
		obj.gameObject.name = v.item_id
		local tran = obj.transform
		tran:Find("Icon"):GetComponent("Image").sprite = GetTexture(v.icon)
		local btn = tran:GetComponent("Button")

		local lock_icon = tran:Find("Lock")
		local lock = not v.isCanUser

		local NumText = tran:Find("NumText"):GetComponent("Text")
		if v.num then
			if v.num == 0 then
				NumText.text = "<color=#D12B19>0</color>"
			else
				NumText.text = "<color=#126F81>" .. v.num .. "</color>"
			end
		else
			NumText.text = ""
		end

		lock_icon.gameObject:SetActive(lock)
		btn.onClick:AddListener(function ()
			self:OnClick(obj,lock,v.ct_id)
		end)

		local condition_config = ConditionManager.GetConditionToID(v.ct_id)
		if condition_config then
			if condition_config.ct_type == "honor" then
				if GameGlobalOnOff.Honor == false then
					obj.gameObject:SetActive(false)
				end
			elseif condition_config.ct_type == "vip" then
				if GameGlobalOnOff.Vip == false then
					obj.gameObject:SetActive(false)
				end
			end
		end
	end

	if MainModel.GetLocalType() == "mj" then
		if self.uipos == 1 then
			self.InfoRect.localPosition = Vector3.New(-284, -93, 0)
		elseif self.uipos == 2 then
			self.InfoRect.localPosition = Vector3.New(307, 190, 0)
		elseif self.uipos == 3 then
			self.InfoRect.localPosition = Vector3.New(-112, 340, 0)
		else
			self.InfoRect.localPosition = Vector3.New(-358, 227, 0)
		end
	else
		if self.uinode then
			local parent = GameObject.Find("Canvas/LayerLv4").transform
			local lpos = parent:InverseTransformPoint(self.uinode.position)
			self.InfoRect.localPosition = lpos
		else
			if self.uipos == 1 then
				self.InfoRect.localPosition = Vector3.New(-274, -86, 0)
			elseif self.uipos == 2 then
				self.InfoRect.localPosition = Vector3.New(274, 227, 0)
			else
				self.InfoRect.localPosition = Vector3.New(-274, 227, 0)
			end
		end
	end
	-- self.curlvl = GameHonorModel.GetHonorData(self.pinfo.glory_score)
	-- self.LevelText.text = string.format( "%s",self.curlvl.level_name)
end

function PlayerInfoPanel:InitRect()
	URLImageManager.UpdateHeadImage(self.pinfo.head_link, self.HeadIcon)	
	PersonalInfoManager.SetHeadFarme(self.HeadBG, self.pinfo.dressed_head_frame)
	VIPManager.set_vip_text(self.head_vip_txt,self.pinfo.vip_level)


	self.PlayerNameText.text = self.pinfo.name
	self.PlayerIDText.text = self.pinfo.id
	if not self.pinfo.sex or self.pinfo.sex == 1 then
		self.ManImage.gameObject:SetActive(true)
	else
		self.WomanImage.gameObject:SetActive(true)
	end

	PersonalInfoManager.ReqDressData()
end
function PlayerInfoPanel:OnClick(obj,lock,ct_id)
	if lock == true then
		ConditionManager.CheckCondition(ct_id, 1)
		return
	end

    local key = obj.name
	local vv = PersonalInfoManager.GetDressDataToID(tonumber(key))
	if vv and vv.num and vv.num <= 0 then
		local ct = ConditionManager.GetConditionToID(vv.ct_id)
		if ct and ct.ct_type == "shop" then
			-- if vv.item_id == 54 or vv.item_id == 56 then
			if vv.item_id == 56 then
				HintPanel.Create(2, "敬请期待！")
			else
				HintPanel.Create(2, "表情使用数量不足，请在游戏结束后前往商城购买！")
			end
		else
			LittleTips.Create("次数不足")
		end
	    self:ExitUI()
		return
	end
	if self.pinfo then
		GameManager.GotoUI({gotoui = "sys_interactive_ani",goto_scene_parm = "panel",u_id = MainModel.UserInfo.user_id,p_id = self.pinfo.id,key = key})
	end
	self:ExitUI()
end

function PlayerInfoPanel:MyExit()
	self:RemoveListener()
	destroy(self.gameObject)
end

function PlayerInfoPanel:ExitUI()
	self:MyExit()
end


--[[
	GetTexture("ddz_game_ui_zt")
]]