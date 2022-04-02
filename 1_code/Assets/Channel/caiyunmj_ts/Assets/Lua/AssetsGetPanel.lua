-- 创建时间:2018-06-06
local basefunc = require "Game.Common.basefunc"
AssetsGetPanel = basefunc.class()
AssetsGetPanel.name = "AssetsGetPanel"

local instance
function AssetsGetPanel.Create(data,is_force)
	if not GameItemModel then 
		dump("GameItemModel", "<color=green>GameItemModel 未初始化</color>")
		return 
	end
	dump(data, "<color=green>获得物品</color>")
	if not is_force then
		MainModel.asset_change_list = MainModel.asset_change_list or {}
		table.insert(MainModel.asset_change_list,data)	
	end
	dump(MainModel.asset_change_list, "<color=green>asset_change_list</color>")
	if not is_force and (not table_is_null(MainModel.asset_change_list) and #MainModel.asset_change_list > 1 )then
		return
	end
	ExtendSoundManager.PlaySound(audio_config.game.bgm_hall_huodewupin.audio_name)
	if MainLogic.IsHideAssetsGetPanel then
		MainLogic.IsHideAssetsGetPanel = nil
	else
		if instance then
			AssetsGetPanel.Close()
		end
		instance = AssetsGetPanel.New(data)
		Event.Brocast("AssetsGetPanelCreating",data)
		return instance
	end
end

function AssetsGetPanel.Close()
	MainLogic.AssetsGetCallback = nil
	if instance then
		instance.data = nil
		instance:RemoveListener()
		if IsEquals(instance.gameObject) then
			GameObject.Destroy(instance.gameObject)
		end
		CommonAwardPanelManager.DelPanel(instance)
		if instance.timer then
			instance.timer:Stop()
			instance.timer = nil
		end
		if instance.timer1 then
			instance.timer1:Stop()
			instance.timer1 = nil
		end
		instance = nil
	end
end

function AssetsGetPanel:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function AssetsGetPanel:MakeLister()
    self.lister = {}
    self.lister["ExitScene"] = basefunc.handler(self, self.OnExitScene)
    self.lister["EnterScene"] = basefunc.handler(self, self.OnExitScene)
    self.lister["CloseAssetsPanel"] = basefunc.handler(self, self.OnExitScene)
end

function AssetsGetPanel:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
end

function AssetsGetPanel:ctor(data)
	self.data = data
	dump(self.data,"<color=blue>++++++++++++++++++++++++++++</color>")
	local parent = GameObject.Find("Canvas/LayerLv50")
	if not parent then
		parent = GameObject.Find("Canvas/LayerLv5")
	end
	if not parent then
		parent = GameObject.Find("Canvas")
	end
	self:MakeLister()
	self:AddMsgListener()
	local obj = newObject(AssetsGetPanel.name, parent.transform)
	self.gameObject = obj
	self.transform = obj.transform

	LuaHelper.GeneratingVar(self.transform,self)
	self.AwardCellList = {}
	--VIP提示
	if self:is_jingbi_in_shop(data.change_type) then
		self.tips_txt.text = ""--"提高vip等级可额外获得充值加成~"
		self.tips_txt.gameObject:SetActive(true)	
	else
		self.tips_txt.gameObject:SetActive(false)
	end
	self:InitRect()
	DOTweenManager.OpenPopupUIAnim(self.transform)
	CommonAwardPanelManager.AddPanel(self)
	self:ShowAd()
end

function AssetsGetPanel:InitRect()
	local shareCount = MainModel.UserInfo.shareCount or 0
    local freeSubsidyNum = MainModel.UserInfo.freeSubsidyNum or 0
	local func_back = function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		if MainLogic.AssetsGetCallback then
			MainLogic.AssetsGetCallback ()
		end
		Event.Brocast("AssetsGetPanelConfirmCallback",self.data)
		Event.Brocast("WZQGuide_Check",{guide = 3 ,guide_step =4})

		local waitFrame = false
		if self.data then
			local callback = self.data.callback
			if callback ~= nil then
				waitFrame = callback() or true
			end
			self.data.callback = nil
		end

		if waitFrame then
			coroutine.start(function ()
				Yield(0)
				AssetsGetPanel.Close()
			end)
		else
			AssetsGetPanel.Close()
		end

		if not table_is_null(MainModel.asset_change_list) then
			table.remove( MainModel.asset_change_list,1)
			if not table_is_null(MainModel.asset_change_list[1]) then
				AssetsGetPanel.Create(MainModel.asset_change_list[1],true)
			end
		end
	end

	self.confirm_btn.onClick:AddListener(func_back)
	self.BG_btn.onClick:AddListener(func_back)


	local change_type = self.data.change_type
	self.zyj_desc_txt.gameObject:SetActive(false)
	self.title_img.gameObject:SetActive(true)
	self.title_zyj.gameObject:SetActive(false)
	if change_type then
		local title = ""
		if change_type == ASSET_CHANGE_TYPE.GLORY_AWARD then
			title = "com_imgf_sjjl"
		elseif change_type == ASSET_CHANGE_TYPE.FREE_BROKE_SUBSIDY or change_type == ASSET_CHANGE_TYPE.BROKE_SHARE_POP then
			self.title_img.gameObject:SetActive(false)
			self.title_zyj.gameObject:SetActive(true)
			if change_type == ASSET_CHANGE_TYPE.BROKE_SHARE_POP then
				self.zyj_desc_txt.text = "还可领<color=#20D1FF>"..shareCount.."</color>次，".."提高vip等级可领取更多救济金~"
				self.zyj_desc_txt.gameObject:SetActive(true)
				self.confirm_btn.transform:Find("ImgOneMore"):GetComponent("Text").text = "分享领取"
				self.tips_txt.text = "还可领"..shareCount.."次"
				self.tips_txt.gameObject:SetActive(false)
			else
				self.tips_txt.text = "还可领"..freeSubsidyNum + shareCount.."次"
				self.zyj_desc_txt.gameObject:SetActive(true)
				self.tips_txt.gameObject:SetActive(false)
				self.zyj_desc_txt.text = "还可领<color=#20D1FF>"..freeSubsidyNum + shareCount.."</color>次，"..(OneYuanGift.isProtected and "新手特权" or "提高vip等级可领取更多救济金~")
			end
		elseif change_type == ASSET_CHANGE_TYPE.BROKE_SUBSIDY then
			self.title_img.gameObject:SetActive(false)
			self.title_zyj.gameObject:SetActive(true)
			if MainModel.UserInfo.shareCount then
				MainModel.UserInfo.shareCount = MainModel.UserInfo.shareCount - 1
				Event.Brocast("share_count_change_msg")
	        end
	        shareCount = MainModel.UserInfo.shareCount or 0
			if shareCount <= 0 then 
				self.tips_txt.text = "今日已领完,"
			else
				self.tips_txt.text = "还可领<color=#20D1FF>"..shareCount.."</color>次,"
			end 
			self.tips_txt.gameObject:SetActive(false)
			self.zyj_desc_txt.gameObject:SetActive(true)
			self.zyj_desc_txt.text = self.tips_txt.text.."提高vip等级可领取更多救济金~"
		elseif change_type == ASSET_CHANGE_TYPE.BIND_PHONE_AWARD then
			title = "com_imgf_sjbdjl"
		else
			title = "com_imgf_gxhd"
		end
		if change_type == ASSET_CHANGE_TYPE.VIP_CHARGE_AWARD then
			self.info_desc_txt.text = "VIP等级加成"
		end
		self:ChangeTitle(title)
	end
	local had_show_hongbaoyu = false
	local data = self.data.data
	if data then
		for i=1,#data do
			if data[i].asset_type == "shop_gold_sum" and MainModel.UserInfo.vip_level == 0 then
				self.wenxintip_txt.gameObject:SetActive(true)
			end
			if data[i].asset_type == "shop_gold_sum" and had_show_hongbaoyu == false then
				if IsEquals(self.transform) then
					local pre = GameObject.Instantiate(GetPrefab("AssetsGet_hongbaoyu"),self.transform)
					had_show_hongbaoyu = true
					self.timer = Timer.New(function ()
						if IsEquals(pre.gameObject) then
							pre.gameObject:SetActive(false)
						end
					end,4,1,false)
					self.timer:Start()
				end
			end
		end
	end
	local skip_data = self.data.skip_data or false
	if not skip_data then
		data = AwardManager.GetAssetsList(data)
	end
	self:CloseAwardCell()
	for i=1,#data do
		local v = data[i]
		self.AwardCellList[#self.AwardCellList + 1] = self:CreateItem(v)
	end

	--荣誉解锁道具
	if change_type and change_type == ASSET_CHANGE_TYPE.GLORY_AWARD then
		local unlock_assets =  AwardManager.GetLockAssetList(self.data.unlock_assets)
		if unlock_assets then
			for i,v in ipairs(unlock_assets) do
				self.AwardCellList[#self.AwardCellList + 1] = self:CreateItem(v)
			end
		end
	end

	-- 支持自定义tips描述
	if self.data.tips then
		self.tips_txt.text = self.data.tips
		self.tips_txt.gameObject:SetActive(true)
	end

	local animation = self.data.animation or false
	if animation then
		self:AnimationList(self.AwardCellList)
	end

	if GuideLogic then
		GuideLogic.CheckRunGuide("get_award")
	end

	--福利券跳转到抽奖
	self:SetXYCJCoin(data,func_back)

	self.zyj_desc_txt.gameObject:SetActive(false)
end

function AssetsGetPanel:CloseAwardCell()
	for i,v in ipairs(self.AwardCellList) do
		GameObject.Destroy(v.gameObject)
	end
	self.AwardCellList = {}
end

function AssetsGetPanel:CreateItem(data,index)
	local obj = GameObject.Instantiate(self.AwardPrefab)
	obj.transform:SetParent(self.AwardNode)
	obj.transform.localScale = Vector3.one
	if index then
		obj.transform:SetSiblingIndex(index - 1)
	end
	local obj_t = {}
	LuaHelper.GeneratingVar(obj.transform,obj_t)
	obj_t.DescText_txt.text = data.desc
	if data.desc_extra then
		obj_t.DescExtra_txt.text = data.desc_extra
	else
		obj_t.DescExtra_txt.text = ""
	end
	GetTextureExtend(obj_t.AwardIcon_img, data.image, data.is_local_icon)
	if data.type == "shop_gold_sum" then		
		obj_t.NameText_txt.text = data.value  .. ""
		obj_t.NameText_txt.gameObject:SetActive(true)
	end
	obj.gameObject:SetActive(true)
	return obj
end

function AssetsGetPanel:OnExitScene()
	MainModel.asset_change_list = {}
	AssetsGetPanel.Close()
end

function AssetsGetPanel:ChangeTitle(titleFile)
	if self.title_img == nil then return end
	self.title_img.sprite = GetTexture(titleFile)
	self.title_img:SetNativeSize()
end

function AssetsGetPanel:AnimationList(list)
	for k, v in pairs(list) do
		v.gameObject:SetActive(false)
	end

	local interval = 0.5
	local loop = #list

	local cursor = 0
	self.timer1 = Timer.New(function()
		cursor = cursor + 1
		local ui = list[cursor]

		local tween1 = ui.transform:DOScale(0.3, 0.3):OnComplete(function()
			if IsEquals(ui.gameObject) then
				ui.gameObject:SetActive(true)
			end
		end)
		local tween2 = ui.transform:DOScale(1.3, 0.3)
		local tween3 = ui.transform:DOScale(1.0, 0.3)
		local seq = DG.Tweening.DOTween.Sequence()
		local tweenKey = DOTweenManager.AddTweenToStop(seq)
		seq:Append(tween1):Append(tween2):Append(tween3):OnKill(function()
			DOTweenManager.RemoveStopTween(tweenKey)
			if IsEquals(ui.gameObject) then
				ui.transform.localScale = Vector3.one
				ui.gameObject:SetActive(true)
			end
		end)
	end, interval, loop)
	self.timer1:Start()
end
--是不是在商城买的鲸币
function AssetsGetPanel:is_jingbi_in_shop(change_type)
	if not change_type or change_type == "" then
		return
	end
	if change_type == "buy" then 
		return  true
	end 
	local key = string.gsub(change_type,"buy_gift_bag_","")
	if shoping_config and shoping_config.goods then 
		for i=1, #shoping_config.goods do
			if shoping_config.goods[i].gift_id and shoping_config.goods[i].gift_id == 	tonumber(key)  then
				return  true
			end 
		end
	end
	return false
end
--实物奖励混合在虚拟奖励一起展示，由MixAwardPopManager调用 type  qq 或者 微信
function AssetsGetPanel.CreatRealAwardItem(data,WXorQQ)
	if instance then
		math.randomseed(os.time())
		local romMax = instance.AwardNode.childCount
		local rom = math.random(1,romMax)
		if type(data.image) == "table" then
			for i = 1, #data.image do
				instance:CreateItem({desc = data.desc[i],image = data.image[i]},rom)
			end		
		else
			instance:CreateItem(data,rom)
		end 
		local WXorQQ = WXorQQ or {qq = "4008882620"}
		if WXorQQ.qq then 
			instance.tips_txt.text = "实物奖励请联系QQ:"..WXorQQ.qq.. "领取奖励"
			instance.tips_txt.gameObject:SetActive(true)
			instance.confirm_btn.transform:Find("ImgOneMore"):GetComponent("Text").text = "复制QQ"
			instance.confirm_btn.onClick:AddListener(
				function ()
					UniClipboard.SetText(WXorQQ.qq)
					LittleTips.Create("已复制QQ号请前往QQ进行添加")
				end
			)
		elseif WXorQQ.wx then 
			instance.tips_txt.text = "实物奖励请联系微信:"..WXorQQ.wx.. "领取奖励"
			instance.tips_txt.gameObject:SetActive(true)
			instance.confirm_btn.transform:Find("ImgOneMore"):GetComponent("Text").text = "复制微信"
			instance.confirm_btn.onClick:AddListener(
				function ()
					UniClipboard.SetText(WXorQQ.wx)
					LittleTips.Create("已复制微信号请前往微信进行添加")
				end
			)
		end 
	else
		print("<color=red>面板不存在</color>")
	end 
end 

function AssetsGetPanel:SetXYCJCoin(data,func_back)
	if table_is_null(data) or #data > 1 then return end
	local v = data[1]
	if v.type ~= "prop_xycj_coin" then return end
	self.confirm_btn.onClick:RemoveAllListeners() 
	self.confirm_btn.onClick:AddListener(function(  )
		func_back()
		GameManager.GotoUI({gotoui = "xycj",goto_scene_parm = "panel"})
	end)
	local txt = self.confirm_btn.transform:Find("ImgOneMore"):GetComponent("Text")
	if IsEquals(txt) then
		txt.text = "前往使用"
	end
end

function AssetsGetPanel:ShowAd()
	AdvertisingManager.RandPlay("awrdg")
end

--[[
	GetTexture("com_imgf_sjbdjl")
	GetTexture("com_imgf_gxhd")
]]