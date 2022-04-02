-- 创建时间:2019-05-23
-- 消消乐累计赢金
local basefunc = require "Game.Common.basefunc"
EliminateSHLJYJPanel = basefunc.class()
local C = EliminateSHLJYJPanel
C.name = "EliminateSHLJYJPanel"

local TASK_ID = 21014
local PROGRESS_WIDTH = 1680
local PROGRESS_HEIGHT = 32
local Space=278
local StartPos=95
local instance = nil

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
	self.lister["model_query_one_task_data_response"] = basefunc.handler(self, self.handle_one_task_data_response)
	self.lister["model_task_change_msg"] = basefunc.handler(self, self.handle_task_change)

	self.lister["view_sge_close"] = basefunc.handler(self, self.handle_sge_close)
	self.lister["ExitScene"] = basefunc.handler(self, self.OnExitScene)
	self.lister["OnLoginResponse"] = basefunc.handler(self, self.OnExitScene)
	self.lister["will_kick_reason"] = basefunc.handler(self, self.OnExitScene)
	self.lister["DisconnectServerConnect"] = basefunc.handler(self, self.OnExitScene)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C.Create(parent)
	if not instance then
		instance = C.New(parent)
	end
	return instance 
end

function C:ctor(parent)

	ExtPanel.ExtMsg(self)

	BigAwardConfig = XXLSHLJYJManager.GetConfig()
	local obj = newObject(C.name, parent or  GameObject.Find("Canvas/LayerLv5").transform)
	self.transform = obj.transform
	self.thisObj=obj
	LuaHelper.GeneratingVar(self.transform, self)

	self:MakeLister()
	self:AddMsgListener()

	self.task_data = nil
	self.ItemList = {}
    
	self:InitRect()
	Network.SendRequest("query_one_task_data", {task_id = TASK_ID})
    if os.time()> 1569859199 then
		self.transform:Find("Top/Image/CurrTitle").gameObject:SetActive(false)
		self.transform:Find("Top/Image/NextTitle").gameObject:SetActive(false)
		self.transform:Find("Top/Image/OverTitle").gameObject:SetActive(true)
	end
end

function C:MyExit()
	self:RemoveListener()
	self:ClearAll()
	destroy(self.gameObject)
end
function C.Close()
	if instance then
		instance:MyExit()
		instance = nil
	end
end

function C.IsShow()
	if not instance then return false end
	return instance.transform.gameObject.activeSelf
end

function C:InitRect()
	local transform = self.transform

	self.close_btn.onClick:AddListener(function()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		C.Close()
	end)

	self.rule_btn.onClick:AddListener(function()
		IllustratePanel.Create({self.introduce_txt}, transform)
	end)

	self.progress_mask_rect = self.progress_mask:GetComponent("RectTransform")
	self.progress_mask_rect.sizeDelta = {x = 0, y = PROGRESS_HEIGHT}
	self.progress_bg_rect=self.progress_bg:GetComponent("RectTransform")
	self.progress_bg_rect.sizeDelta = {x = #BigAwardConfig.stage * Space - StartPos * 2, y = PROGRESS_HEIGHT}
	self.progress_img_rect=self.progress_mask.transform:Find("progress_img"):GetComponent("RectTransform")
	self.progress_img_rect.sizeDelta = {x = #BigAwardConfig.stage * Space - StartPos * 2, y = PROGRESS_HEIGHT}
	for i = 1, #BigAwardConfig.stage do
		BigAwardConfig.stage[i].progress=StartPos+(i-1)* Space
	end
	for k, v in ipairs(BigAwardConfig.stage) do
		local item = self:CreateItem(self.item_node, self.item_tmpl)

		local item_title = item.transform:Find("title"):GetComponent("Text")
		item_title.text = StringHelper.ToCash(v.money)

		local item_slider = item.transform:Find("slider"):GetComponent("Image")
		item_slider.sprite = GetTexture("gy_15_8_activity_xxlsh_ljyj")

		local item_bg = item.transform:Find("bg"):GetComponent("Image")
		item_bg.sprite = GetTexture(v.icon)

		local item_award = item.transform:Find("bg/award"):GetComponent("Text")
		item_award.text = v.award

		local item_mask = item.transform:Find("bg/mask"):GetComponent("Image")
		item_mask.gameObject:SetActive(false)

		local item_getmask = item.transform:Find("bg/getmask")
		item_getmask.gameObject:SetActive(false)

		local item_btn = item.transform:Find("bg/getmask/go_btn"):GetComponent("Button")
		local item_isgoods=v.isgoods
		if  v.isgoods==true  then	
			item_btn.onClick:AddListener(function ()		
					local string1
					string1="奖品:"..v.award.."，奖励达成后请联系客服领取奖励\n客服QQ：%s"				
					GameManager.GotoUI({gotoui = "sys_service_gzh",goto_scene_parm = "panel",desc=string1, gzh="4008882620"})
					Network.SendRequest("get_task_award_new", {id = TASK_ID,award_progress_lv=v.id})
					Network.SendRequest("query_one_task_data", {task_id = TASK_ID})
					self:RefreshItems()
			end	)	
		else
			item_btn.onClick:AddListener(function ()			
			Network.SendRequest("get_task_award_new", {id = TASK_ID,award_progress_lv=v.id})
			Network.SendRequest("query_one_task_data", {task_id = TASK_ID})
			self:RefreshItems()
		    end)
		end		
		ClipUIParticle(item.transform)
		self.ItemList[#self.ItemList + 1] = item
	end
end

function C:Refresh()
	local transform = self.transform
	if not IsEquals(transform) then return end
	self:RefreshItems()
end

function C:ClearItemList(list)
	for i,v in pairs(list) do
		if IsEquals(v) then
			GameObject.Destroy(v.gameObject)
		end
	end
end

function C:ClearAll()
	if IsEquals(self.transform) then
		self.transform:SetParent(nil)
	end
	self:ClearItemList(self.ItemList)
	self.ItemList = {}
end

function C:CreateItem(parent, tmpl)
	local obj = GameObject.Instantiate(tmpl)
	obj.transform:SetParent(parent)
	obj.transform.localPosition = Vector3.zero
	obj.transform.localScale = Vector3.one

	obj.gameObject:SetActive(true)

	return obj
end

function C:handle_sge_close()
	C.Close()
end

function C:OnExitScene()
	C.Close()
end
function C.isShowDJ(glod)
	self.gameObject.transform:Find("LJYJ/dj").gameObject:SetActive(true)
end
function C:RefreshItems()
	--dump(self.task_data.award_status_all,"<color=red>---------self.task_data.award_status_all1--</color>")
	if self.task_data.award_status_all==nil then
	return 
	end
	dump(self.task_data.award_status_all,"<color=red>---------self.task_data.award_status_all1--</color>")
	if not self.task_data then
		print("[SGE] Event task_data invalid")
		return
	end

	local MAX_LEVEL = #BigAwardConfig.stage

	for k, v in ipairs(self.ItemList) do
		local item_mask = v.transform:Find("bg/mask"):GetComponent("Image")
		item_mask.gameObject:SetActive(false)

		local item_slider = v.transform:Find("slider"):GetComponent("Image")
		item_slider.sprite = GetTexture("gy_15_8_activity_xxlsh_ljyj")

		local item_getmask = v.transform:Find("bg/getmask")
		item_getmask.gameObject:SetActive(false)
			
	end

	--progress dot
	local level = self.task_data.now_lv -1
	-- for idx = 1, level do
	-- 	local item = self.ItemList[idx]
	-- 	local item_slider = item.transform:Find("slider"):GetComponent("Image")
	-- 	item_slider.sprite = GetTexture("gy_15_10_activity_xxlsh_ljyj")
	-- end
	
	for i = 1, #self.task_data.award_status_all do
		if self.task_data.award_status_all[i] ~= 0 then 
			local item = self.ItemList[i]
			local item_slider = item.transform:Find("slider"):GetComponent("Image")
			item_slider.sprite = GetTexture("gy_15_10_activity_xxlsh_ljyj")
		end 
	end

	local full_process = false
	if self.task_data.now_lv >= MAX_LEVEL then
		if self.task_data.now_process == self.task_data.need_process then
			local item = self.ItemList[MAX_LEVEL]
			local item_slider = item.transform:Find("slider"):GetComponent("Image")
			item_slider.sprite = GetTexture("gy_15_10_activity_xxlsh_ljyj")
			full_process = true
		end
	end
	for i = 1, #self.ItemList do
		
	   if	self.task_data.award_status_all[i]==0 then
		    local item = self.ItemList[i]
		    local item_mask = item.transform:Find("bg/getmask")
		    item_mask.gameObject:SetActive(false)    
	   end
	   if	self.task_data.award_status_all[i]==1 then
		    local item = self.ItemList[i] 
		    local item_getmask = item.transform:Find("bg/getmask")
			item_getmask.gameObject:SetActive(true)
			item.transform:Find("bg/getmask/focus").gameObject:SetActive(true)  			
	   end
	   if	self.task_data.award_status_all[i]==2 then
		    local item = self.ItemList[i]
	     	-- local item_mask = item.transform:Find("bg/mask"):GetComponent("Image")
			-- item_mask.gameObject:SetActive(false)
			local item_mask = item.transform:Find("bg/mask"):GetComponent("Image")
			item_mask.gameObject:SetActive(true)
				--print(BigAwardConfig.stage[j].isgoods)
			if BigAwardConfig.stage[i].isgoods==true then
				local item = self.ItemList[i]
				local item_mask = item.transform:Find("bg/getmask")
				item_mask.transform:Find("go_btn/Text"):GetComponent("Text").text="查   看"
				item_mask.gameObject:SetActive(true)    
				item.transform:Find("bg/getmask/focus").gameObject:SetActive(false)					   
			end	
	   end
       

	end
	--get or wait get
	-- for idx = 1, self.task_data.task_round - 1 do
	-- 	local item = self.ItemList[idx]
	-- 	local item_mask = item.transform:Find("bg/mask"):GetComponent("Image")
	-- 	item_mask.gameObject:SetActive(true)
	-- end

	-- if self.task_data.award_status == 1 then
	-- 	local item = self.ItemList[self.task_data.task_round]
	-- 	local item_getmask = item.transform:Find("bg/getmask")
	-- 	item_getmask.gameObject:SetActive(true)

	-- 	--hardcode
	-- 	if level >= (MAX_LEVEL - 1) then
	-- 		item = self.ItemList[MAX_LEVEL - 1]
	-- 		item_getmask = item.transform:Find("bg/getmask")
	-- 		item_getmask.gameObject:SetActive(true)

	-- 		if full_process then
	-- 			item = self.ItemList[MAX_LEVEL]
	-- 			item_getmask = item.transform:Find("bg/getmask")
	-- 			item_getmask.gameObject:SetActive(true)
	-- 		end
	-- 	end
	-- end

	--progress
	local progress_value = 0
	local factor = Mathf.Clamp(self.task_data.now_process / self.task_data.need_process, 0, 1)
	if level == 0 then
		progress_value = BigAwardConfig.stage[1].progress * factor
	elseif level >= MAX_LEVEL then
		progress_value = BigAwardConfig.stage[MAX_LEVEL].progress
	else
		progress_value = BigAwardConfig.stage[level].progress + (BigAwardConfig.stage[level + 1].progress - BigAwardConfig.stage[level].progress) * factor

	end
	
	--	特殊处理
	if self.task_data.now_lv == 1 and self.task_data.need_process == 0 then
		progress_value=121
		local item = self.ItemList[1]
		local item_slider = item.transform:Find("slider"):GetComponent("Image")
		item_slider.sprite = GetTexture("gy_15_10_activity_xxlsh_ljyj")
	end
	self.progress_mask_rect.sizeDelta = {x = progress_value, y = PROGRESS_HEIGHT}
	self.current_money_txt.text = StringHelper.ToCash(self.task_data.now_total_process)
	self.next_money_txt.text = StringHelper.ToCash(self.task_data.need_process - self.task_data.now_process)
end
--获取数据
function C:handle_one_task_data_response(data)
	if data and data.id==TASK_ID then 
		self.task_data = data
		self.task_data.award_status_all = basefunc.decode_task_award_status(self.task_data.award_get_status)
		self.task_data.award_status_all = basefunc.decode_all_task_award_status(self.task_data.award_status_all,self.task_data,#BigAwardConfig.stage)
		if instance then
			instance:Refresh()
		end
	end 
end

function C:handle_task_change(data)
	dump(data, "C.handle_task_change")
	self.task_data = data
	if instance then
		instance:Refresh()
	end
end



function C:CanShowAwards(id)
	local ret = false
	for _, d in ipairs(BigAwardConfig.config) do
		if d.award_id == id then
			ret = true
			break
		end
	end
	return ret
end

function C:CopyWxCode()
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    LittleTips.Create("已复制QQ号请前往QQ进行添加")
    UniClipboard.SetText("4008882620")
end

