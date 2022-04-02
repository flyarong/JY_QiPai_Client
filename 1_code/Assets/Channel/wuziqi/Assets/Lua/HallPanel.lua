local basefunc = require "Game.Common.basefunc"

if GameGlobalOnOff.IOSTS then
	require "Game.game_Hall.Lua.GiftBoxPanel"
end
HallPanel = basefunc.class()

HallPanel.name = "HallPanel"

-- by lyx 商城的 url
local shop_url
local instance

--自己关心的事件
local lister
function HallPanel:MakeLister()
	lister={}
    lister["AssetChange"] = self.updateAssetInfoHandler
	lister["update_dressed_head_frame"] = basefunc.handler(self, self.update_dressed_head_frame)

	lister["model_query_vip_base_info_response"] = basefunc.handler(self, self.set_vip_info)
	lister["model_vip_upgrade_change_msg"] = basefunc.handler(self, self.set_vip_info)
	lister["shop_info_get"] = basefunc.handler(self, self.set_vip_info)

	lister["MainModelUpdateVerify"] = basefunc.handler(self, self.UpdateVerifide)
	lister["ReConnecteServerSucceed"] = basefunc.handler(self, self.ReConnecteServerSucceed)

	lister["set_head_image"] = basefunc.handler(self, self.set_head_image)
	lister["set_player_name"] = basefunc.handler(self, self.set_player_name)

	lister["SYSChangeHeadAndNameManager_Change_Name_Success_msg"] = basefunc.handler(self,self.on_SYSChangeHeadAndNameManager_Change_Name_Success_msg)
	lister["SYSChangeHeadAndNameManager_Change_Head_Success_msg"] = basefunc.handler(self,self.on_SYSChangeHeadAndNameManager_Change_Head_Success_msg)
end

function HallPanel:AddLister()
    for proto_name,func in pairs(lister) do
        Event.AddListener(proto_name, func)
    end
end

function HallPanel:RemoveLister()
    if lister and next(lister) then
		for msg,cbk in pairs(lister) do
			Event.RemoveListener(msg, cbk)
		end	
	end
    lister=nil
end

function HallPanel.Create(call)
	DSM.PushAct({panel = "HallPanel"})
	instance=HallPanel.New(call)
	return instance
end

local IsSecondDayHallPanelEnter = function ()
	local _permission_key = "next_day_gswzq"  --次日登录的权限
	local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key=_permission_key, is_on_hint = true}, "CheckCondition")
	if a and not b then
		return  false
	end
	return true
end

function HallPanel:SetupBtns()
	self.qhb_btn.onClick:AddListener(function (obj)
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		GameManager.GotoUI({gotoui="game_MiniGame",goto_scene_parm={down_style={panel=self.qhb.transform}}})
	end)
	self.zpg_btn.onClick:AddListener(function (obj)
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		--判断种苹果显示权限
		local CheckZPGPermission = function()
			local _permission_key = "drt_guess_apple_play"
			if _permission_key then
				local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key=_permission_key, is_on_hint = false}, "CheckCondition")
				if a and not b then
					return false
				end
				return true
			else
				return true
			end
		end
		if CheckZPGPermission() then
			GameManager.GotoUI({gotoui = "game_ZPG",goto_scene_parm={down_style={panel=self.zpg.transform}}})
		end
	end)
	self.qql_btn.onClick:AddListener(function (obj)
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		if IsSecondDayHallPanelEnter() then
			GameManager.GotoUI({ gotoui = "xxl" })
		else
			GameManager.GotoUI({gotoui = "game_Zjd"})
		end
	end)
	self.wzq_btn.onClick:AddListener(function (obj)
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		local game_id = 44 --五子棋固定id
		GameManager.CommonGotoScence({gotoui="game_Gobang", p_requset={id = game_id}})
	end)
end

function HallPanel:ctor(call)

    Event.Brocast("Now_In_Game_Hall")
	local parent = GameObject.Find("Canvas/LayerLv1").transform
	local obj = newObject(HallPanel.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj

	self.openCall = call
	LuaHelper.GeneratingVar(self.transform, self)

	EventTriggerListener.Get(self.player_center_btn.gameObject).onClick = basefunc.handler(self, self.OnPlayerCenterClick)
	EventTriggerListener.Get(self.duihuan_btn.gameObject).onClick = basefunc.handler(self, self.OnStoreClick)

	EventTriggerListener.Get(self.pay_btn.gameObject).onClick = basefunc.handler(self, self.OnPayClick)
	EventTriggerListener.Get(self.set_btn.gameObject).onClick = basefunc.handler(self, self.OnSetClick)
	EventTriggerListener.Get(self.service_btn.gameObject).onClick = basefunc.handler(self, self.OnServiceClick)
	EventTriggerListener.Get(self.LBDH_btn.gameObject).onClick = basefunc.handler(self, self.OnLBDHClick)

	EventTriggerListener.Get(self.AddGold_btn.gameObject).onClick = basefunc.handler(self, self.OnAddGoldClick)
	EventTriggerListener.Get(self.AddDiamond_btn.gameObject).onClick = basefunc.handler(self, self.OnAddDiamondClick)
	EventTriggerListener.Get(self.activity_btn.gameObject).onClick = basefunc.handler(self, self.OnActivityClick)
	EventTriggerListener.Get(self.money_center_btn.gameObject).onClick = basefunc.handler(self, self.OnMoneyConterClick)
	EventTriggerListener.Get(self.bag_btn.gameObject).onClick = basefunc.handler(self, self.OnBagClick)
	EventTriggerListener.Get(self.email_btn.gameObject).onClick = basefunc.handler(self, self.OnEmailClick)
	EventTriggerListener.Get(self.scanner_btn.gameObject).onClick = basefunc.handler(self, self.OnScannerClick)

	EventTriggerListener.Get(self.change_city_btn.gameObject).onClick = basefunc.handler(self, self.OnChangeCityClick)

	EventTriggerListener.Get(self.PhoneButton_btn.gameObject).onClick = basefunc.handler(self, self.OnPhoneClick)
	EventTriggerListener.Get(self.GZHButton_btn.gameObject).onClick = basefunc.handler(self, self.OnGZHClick)

	EventTriggerListener.Get(self.Area_btn.gameObject).onClick = basefunc.handler(self, self.OnAreaClick)
	EventTriggerListener.Get(self.VIP_btn.gameObject).onClick = basefunc.handler(self, self.OnVIPClick)
	EventTriggerListener.Get(self.fuli_btn.gameObject).onClick = basefunc.handler(self, self.OnFuliClick)
    EventTriggerListener.Get(self.ServiceTop.gameObject).onClick = basefunc.handler(self, self.SetServiceTopClick)
	EventTriggerListener.Get(self.KFFKButton_btn.gameObject).onClick = basefunc.handler(self, self.OnKFFKClick)

	
	self.updateAssetInfoHandler = function ()
		self:UpdateAssetInfo()
	end

	self.headimage = self.player_center_btn.gameObject:GetComponent("Image")
	self:update_dressed_head_frame()
	self:set_vip_info()
	
	--刷新头像
	URLImageManager.UpdateHeadImage(MainModel.UserInfo.head_image, self.player_head_img)
	
	self.player_name_txt.text = MainModel.UserInfo.name
	self.shop_gold_txt.text = StringHelper.ToCash(MainModel.UserInfo.jing_bi)
	self.red_packet_txt.text = StringHelper.ToRedNum(MainModel.GetHBValue())
	self.shop_diamond_txt.text = StringHelper.ToCash(MainModel.UserInfo.diamond)

	self:UpdateDHHint()

	self.ServiceNode.gameObject:SetActive(false)
	self:InitAnim()
	self:EnterAnim()

	if IsSecondDayHallPanelEnter() then
		self.sgxxl_anim.gameObject:SetActive(true)
		self.qql_anim.gameObject:SetActive(false)
	else
		self.sgxxl_anim.gameObject:SetActive(false)
		self.qql_anim.gameObject:SetActive(true)
	end

	--更新部分
	self.updateHintTmpl = self.transform:Find("UpdateHintTmpl")
	self.updateUI = {}
	self:UpdateUpdateHint()


	self:MakeLister()
	self:AddLister()

	local deeplink = sdkMgr:GetDeeplink()
	if not deeplink or deeplink == "" then
		print("<color=red>deeplink is null</color>")
	else
		print("<color=red>deeplink = " .. deeplink .. "</color>")
		MainLogic.HandleOpenURL(deeplink)
	end

	MainModel.GetVerifyStatus()
	MainModel.GetBindPhone()
	-- GameTaskModel.InitTaskRedHint()
	if GameTaskModel then
		GameTaskModel.ChangeTaskCanGetRedHint()
	end

	RedHintManager.AddRed(RedHintManager.RedHintKey.RHK_Email, self.email_red.gameObject)
	RedHintManager.AddRed(RedHintManager.RedHintKey.RHK_EmailHint, self.email_hint.gameObject)
	RedHintManager.AddRed(RedHintManager.RedHintKey.RHK_Head, self.head_red.gameObject)
	RedHintManager.AddRed(RedHintManager.RedHintKey.RHK_Bag, self.bag_red.gameObject)
	local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key="drt_block_binding_phone_num", is_on_hint = true}, "CheckCondition")
	local bindphone = (not a or (a and not b)) and GameGlobalOnOff.BindingPhone
	if bindphone then
		RedHintManager.AddRed(RedHintManager.RedHintKey.RHK_PhoneAward, self.phone_award_red.gameObject)
	else
		self.phone_award_red.gameObject:SetActive(false)
	end
	RedHintManager.AddRed(RedHintManager.RedHintKey.RHK_Activity, self.activity_red.gameObject)
	RedHintManager.AddRed(RedHintManager.RedHintKey.RHK_Activity_GET, self.activity_get.gameObject)
	RedHintManager.AddRed(RedHintManager.RedHintKey.RHK_GD, self.service_red.gameObject)
	RedHintManager.AddRed(RedHintManager.RedHintKey.RHK_Money_Center, self.money_center_red.gameObject)
	RedHintManager.AddRed(RedHintManager.RedHintKey.RHK_Fuli, self.fuli_red.gameObject)
	RedHintManager.AddRed(RedHintManager.RedHintKey.RHK_Fuli_GET, self.fuli_get.gameObject)

	RedHintManager.UpdateRedHint(RedHintManager.RedHintKey.RHK_XYCJ)
	self:OnOff()
	--大厅活动图标更新
	self:RefreshActivityUI()
	self:OpenUIAnim()

	HandleLoadChannelLua("HallPanel", self)

	if GameMoneyCenterModel then
		GameMoneyCenterModel.GetSCZDBaseInfo()
	end

	local btn_map = {}
	btn_map["center"] = {self.hall_btn_5, self.hall_btn_6, self.hall_btn_7, self.hall_btn_8}
	btn_map["right_top"] = {self.hall_btn_5_2,self.hall_btn_5_1,self.hall_btn_4, self.hall_btn_3, self.hall_btn_2, self.hall_btn_1}
	btn_map["top"] = {self.hall_btn_top}
	btn_map["top1"] = {self.hall_btn_top1}
	self.game_btn_pre = GameButtonPanel.Create(btn_map, "hall_config", self.transform)
	self:MyRefresh()
	MainModel.SetGameBGScale(self.BGImg)
	self:SetQMZQ()
	Event.Brocast("hallpanel_created",{panelSelf = self})
	local DownR = self.transform:Find("DownR").transform
	DownR.gameObject.transform.anchorMin = Vector2.New(0.5,0.5)
	DownR.gameObject.transform.anchorMax  = Vector2.New(0.5,0.5)
	DownR.gameObject.transform.pivot  = Vector2.New(0.5,0.5)
	DownR.gameObject.transform.localPosition = Vector2.New(795,-428.6)
	self.duihuan_hint.gameObject.transform.localPosition = Vector2.New(3,71)
end

function HallPanel:MyRefresh()
	self:UpdateAssetInfo()
	self:UpdateVerifide()
end

function HallPanel:update_dressed_head_frame()
	if true then return end
	PersonalInfoManager.SetHeadFarme(self.headimage)
end
function HallPanel:UpdateDHHint()
	if MainModel.GetHBValue() >= 10 then
		local newtime = tonumber(os.date("%Y%m%d", os.time()))
        local oldtime = tonumber(os.date("%Y%m%d", tonumber(PlayerPrefs.GetString("HallDHHintTime" .. MainModel.UserInfo.user_id, 0))))
		if oldtime ~= newtime then
			self.duihuan_hint_txt.text = "您有" .. StringHelper.ToRedNum(MainModel.GetHBValue()) .. "元可兑换"
			if IsEquals(self.duihuan_hint) then
				self.duihuan_hint.gameObject:SetActive(true)
			end
		else
			if IsEquals(self.duihuan_hint) then
				self.duihuan_hint.gameObject:SetActive(false)
			end
		end
	else
		if IsEquals(self.duihuan_hint) then
			self.duihuan_hint.gameObject:SetActive(false)
		end
	end
end
-- 界面打开的动画
function HallPanel:OpenUIAnim()
	if true then
		local tt = 0.25

		self.RectTop.transform.localPosition = Vector3.New(0, 118, 0)
		self.RectLeft.transform.localPosition = Vector3.New(-1400, -13.8, 0)
		self.RectRight.transform.localPosition = Vector3.New(1560, 0, 0)
		self.RectDownL.transform.localPosition = Vector3.New(0, -94, 0)
		self.RectDownR.transform.localPosition = Vector3.New(435, 0, 0)
		--self.log_img.transform.localScale = Vector3.New(0.1,0.1,0.1)

		local seq = DG.Tweening.DOTween.Sequence()
		local tweenKey = DOTweenManager.AddTweenToStop(seq)
		seq:Join(self.RectTop.transform:DOLocalMoveY(-92, tt))
		-- seq:AppendInterval(-1 * tt)
		seq:Join(self.RectLeft.transform:DOLocalMoveX(-540, tt))
		-- seq:AppendInterval(-1 * tt)
		seq:Join(self.RectRight.transform:DOLocalMoveX(140, tt))
		-- seq:AppendInterval(-1 * tt)
		seq:Join(self.RectDownL.transform:DOLocalMoveY(42, tt))
		-- seq:AppendInterval(-1 * tt)
		seq:Join(self.RectDownR.transform:DOLocalMoveX(0, tt))
		--seq:Join(self.log_img.transform:DOScale(Vector3.New(1,1,1), tt))
		seq:Append(self.RectDownR.transform:DOScale(Vector3.New(2,2,2), 0.1))
		seq:Append(self.RectDownR.transform:DOScale(Vector3.New(1,1,1), 0.1))
		seq:OnComplete(function ()
		end)
		seq:OnKill(function ()
			DOTweenManager.RemoveStopTween(tweenKey)
			self:OpenUIAnimFinish()
			Event.Brocast("WZQGuide_Check",{guide = 1 ,guide_step =1})
			--Event.Brocast("WZQGuide_Check",{guide = 2 ,guide_step =4})
			--Event.Brocast("WZQGuide_Check",{guide = 3 ,guide_step =5})
			Event.Brocast("WZQGuide_Check",{guide = 4 ,guide_step =1})
		end)
	else
		self:OpenUIAnimFinish()
	end
end
function HallPanel:OpenUIAnimFinish()
	if not IsEquals(self.RectTop) then
		return
	end
	self.RectTop.transform.localPosition = Vector3.New(0, -92, 0)
	self.RectLeft.transform.localPosition = Vector3.New(-540, -13.8, 0)
	self.RectRight.transform.localPosition = Vector3.New(140, 0, 0)
	self.RectDownL.transform.localPosition = Vector3.New(0, 42, 0)
	self.RectDownR.transform.localPosition = Vector3.New(0, 0, 0)
	--self.log_img.transform.localScale = Vector3.New(1,1,1)
	self.RectDownR.transform.localScale = Vector3.New(1,1,1)

	--add listener
	self:SetupBtns()
	
	--同步一下任务数据
	local SYNC_TASK_TBL = { 53, 54 }
	for _, v in pairs(SYNC_TASK_TBL) do
		Network.SendRequest("query_one_task_data", {task_id = v})
	end
	
	local call = function ()
		if self.openCall then
			self.openCall()
		end
		Event.Brocast("hallpanel_open_anim_finish")
	end

	call()
end
-- 客服全局点击控制
function HallPanel:SetServiceTopClick()
	self.ServiceNode.gameObject:SetActive(false)
end

function HallPanel:OnOff()
	if GameGlobalOnOff.IOSTS then
		self.LBDH_btn.gameObject:SetActive(false)
	else
		self.LBDH_btn.gameObject:SetActive(true)
	end

	if GameGlobalOnOff.PlayerInfo then
		self.player_center_btn:GetComponent("Image").raycastTarget = true
	else
		self.player_center_btn:GetComponent("Image").raycastTarget = false
	end

	if GameGlobalOnOff.Exchange then
		self.duihuan_btn.gameObject:SetActive(true)
	else
		self.duihuan_btn.gameObject:SetActive(false)
	end

	if GameGlobalOnOff.Shop then
		self.pay_btn.gameObject:SetActive(true)
	else
		self.pay_btn.gameObject:SetActive(false)
	end

	if GameGlobalOnOff.Money_Center then
		self.money_center_btn.gameObject:SetActive(true)

		if gameRuntimePlatform == "Ios" then
			local image = self.money_center_btn.transform:Find("money_center_btn/hall_btn_sc/Image"):GetComponent("Image")
			image.sprite = GetTexture("hall_btn_tg")
		end
	else
		self.money_center_btn.gameObject:SetActive(false)
	end
end

function HallPanel:OnAddGoldClick(go)
	PayPanel.Create(GOODS_TYPE.jing_bi, "normal")
end

function HallPanel:OnAddDiamondClick(go)
	PayPanel.Create(GOODS_TYPE.goods, "normal")
end

function HallPanel:OnAreaClick()
	HintPanel.Create(1, "敬请期待")
end

function HallPanel:OnVIPClick()
	local vip_l = VIPManager.get_vip_level()
	-- if vip_l > 0 then
	-- 	GameManager.GotoUI({gotoui="vip", goto_scene_parm="vip_task", goto_scene_parm1 = "vip_tq"})
	-- else
	-- 	GameManager.GotoUI({gotoui="vip", goto_scene_parm="VIP2"})
	-- end
	if vip_l == 0 then
		SYSACTBASEManager.CreateHallAct(nil,nil,{ID = 15})
	elseif vip_l == 1 then
		SYSACTBASEManager.CreateHallAct(nil,nil,{ID = 14})
	elseif vip_l == 2 then
		SYSACTBASEManager.CreateHallAct(nil,nil,{ID = 7})
	elseif vip_l == 3 then
		SYSACTBASEManager.CreateHallAct(nil,nil,{ID = 8})
	elseif vip_l == 4 then 
		SYSACTBASEManager.CreateHallAct(nil,nil,{ID = 16})
	else
		GameManager.GotoUI({gotoui="vip", goto_scene_parm="vip_task", goto_scene_parm1 = "vip_tq"})
	end
	self:SetVipClick()
end

--打开邮件
function HallPanel:OnEmailClick(go)
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	EmailLogic.GotoUI({gotoui="sys_email", goto_scene_parm="panel"})
	self.ServiceNode.gameObject:SetActive(false)
end

--打开兑换
function HallPanel:OnStoreClick(go)
	DSM.PushAct({button = "store_btn"})
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	MainModel.OpenDH()
	if MainModel.GetHBValue() >= 10 then
		PlayerPrefs.SetString("HallDHHintTime" .. MainModel.UserInfo.user_id, os.time())
		self:UpdateDHHint()
	end
end

--打开充值
function HallPanel:OnPayClick(go)
	DSM.PushAct({button = "pay_btn"})
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	HallLogic.gotoPay()
end

--打开设置
function HallPanel:OnSetClick(go)
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	SettingPanel.Show()
	self.ServiceNode.gameObject:SetActive(false)
end

--打开礼包兑换
function HallPanel:OnLBDHClick(go)
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	self.ServiceNode.gameObject:SetActive(false)
	ExchangeGiftPanel.Create()
end

-- 打开活动
function HallPanel:OnActivityClick(go)
	DSM.PushAct({button = "activity_btn"})
	if GameGlobalOnOff.IOSTS then
		HintPanel.Create(1, "敬请期待")
		return
	end

	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	GameManager.GotoUI({gotoui="hall_activity", goto_scene_parm="panel"})
end

--财富中心
function HallPanel:OnMoneyConterClick(go)
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	Event.Brocast("open_game_money_center")
	PlayerPrefs.SetInt("qmzq" .. MainModel.UserInfo.user_id,1)
	PlayerPrefs.SetInt("qmzq_time"..MainModel.UserInfo.user_id,os.time())
	self:SetQMZQ()
end

--打开背包
function HallPanel:OnBagClick(go)
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	BagPanel.New()
	self.ServiceNode.gameObject:SetActive(false)
end

--扫码
function HallPanel:OnScannerClick(go)
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	MainLogic.TryStartScan(function(k, v)
	end)
end

-- 打电话
function HallPanel:OnPhoneClick()
	ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
	--sdkMgr:CallUp("400-8882620")
	Event.Brocast("callup_service_center", "400-8882620")
	self.ServiceNode.gameObject:SetActive(false)
end

function HallPanel:OnKFFKClick()
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	MainModel.OpenKFFK()
	self.ServiceNode.gameObject:SetActive(false)
end

-- 公众号
function HallPanel:OnGZHClick()
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	ServiceGzhPrefab.Create()
	self.ServiceNode.gameObject:SetActive(false)
end

-- 客服中心
function HallPanel:OnServiceClick(go)
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	local b = self.ServiceNode.gameObject.activeInHierarchy
	self.ServiceNode.gameObject:SetActive(not b)
end

--打开玩家中心
function HallPanel:OnPlayerCenterClick(go)
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	local parm
	if not MainModel.UserInfo.phoneData or not MainModel.UserInfo.phoneData.phone_no then
		parm = {}
		parm.open_award = 1
	end
	--点击头像后，实名认证提示消失
	PlayerPrefs.SetInt(MainModel.UserInfo.user_id.."smrz_headimg_hadclick",1)
	self:UpdateVerifide()
	PersonalInfoPanel.Create(parm)
end

-- 切换地区
function HallPanel:OnChangeCityClick(go)
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	if GameGlobalOnOff.ChangeCity then
		HintPanel.Create(1,"敬请期待")
	else
		HintPanel.Create(1,"目前只支持成都地区")
	end
end

function HallPanel:UpdateAssetInfo()
	if IsEquals(self.player_name_txt) then
		self.player_name_txt.text = MainModel.UserInfo.name
	end
	if IsEquals(self.shop_gold_txt) then
		self.shop_gold_txt.text = StringHelper.ToCash(MainModel.UserInfo.jing_bi)
	end
	if IsEquals(self.red_packet_txt) then
		self.red_packet_txt.text = StringHelper.ToRedNum(MainModel.GetHBValue())
	end
	if IsEquals(self.shop_diamond_txt) then
		self.shop_diamond_txt.text = StringHelper.ToCash(MainModel.UserInfo.diamond)
	end
	self:UpdateDHHint()
	RedHintManager.UpdateRedHint(RedHintManager.RedHintKey.RHK_XYCJ)

	RedHintManager.UpdateRedHint(RedHintManager.RedHintKey.RHK_Activity_Year)
	RedHintManager.UpdateRedHint(RedHintManager.RedHintKey.RHK_Activity_Year_Get)
end

function HallPanel.HandleDownloadNetworkError()
	HintPanel.ErrorMsg(3001)
end

function HallPanel:SetBtnFade(nodeType, node, value)
	if nodeType == "spine" then
		local render = node.gameObject:GetComponent("Renderer")
		if render then
			render.sharedMaterial:SetFloat("_FillPhase", 1 - value)
		end
	else
		local images = node.gameObject:GetComponentsInChildren(typeof(UnityEngine.UI.Image))
		for i = 0, images.Length - 1 do
			images[i].color = Color.New(value, value, value, 1)
		end
	end
end
function HallPanel:SetBtnNotice(nodeType, node, value)
	local updateUI = self.updateUI
	local spineTbl = updateUI["spineTbl"] or {}

	local nodeName = node.name
	local go = spineTbl[nodeName]
	
	if value then
		local tmpl = self.updateHintTmpl
		if not go then
			local parent = GameObject.Find("Canvas/LayerLv1").transform
			go = GameObject.Instantiate(tmpl, parent)
			go.transform.localPosition = Vector3.zero
			go.transform.position = node.transform:Find("UpdateHintNode").position
			go.gameObject:SetActive(true)
			spineTbl[nodeName] = go
		end
	else
		if go then
			go.transform:SetParent(nil)
			GameObject.Destroy(go.gameObject)
			spineTbl[nodeName] = nil
		end

	end

	self.updateUI["spineTbl"] = spineTbl
end

function HallPanel:UpdateSceneState(sceneCfg)
	local sceneName = sceneCfg.SceneName
	if sceneName == "" then return end
	if sceneCfg.BtnName == nil or sceneCfg.BtnName == "" then return end

	local transform = self.transform
	local node = transform:Find(sceneCfg.BtnName)
	if not node then
		print(string.format("<color=red>[Update] UpdateSceneState(%d) error: btnNode(%s) not find</color>", sceneCfg.ID, sceneCfg.BtnName))
		return
	end

	if not node.gameObject.activeSelf then return end

	local state = gameMgr:CheckUpdate(sceneName)
	-- state = "Install"
	if state == "Install" or state == "Update" then
		self:SetBtnFade(sceneCfg.BtnType, node, 0.6)
		self:SetBtnNotice(sceneCfg.BtnType, node, true)
	else
		self:SetBtnFade(sceneCfg.BtnType, node, 1.0)
		self:SetBtnNotice(sceneCfg.BtnType, node, false)
	end
end

function HallPanel:UpdateUpdateHint()
	local sceneTbl = HallModel.GetGameSceneCfgByPanel(HallPanel.name)
	if sceneTbl == nil or #sceneTbl <= 0 then return end

	for _, v in pairs(sceneTbl) do
		self:UpdateSceneState(v)
	end
end

function HallPanel:ClearUpdateUI()
	local updateUI = self.updateUI

	local spineTbl = updateUI["spineTbl"] or {}
	for _, v in pairs(spineTbl) do
		GameObject.Destroy(v.gameObject)
	end

	self.updateUI = {}
end

function HallPanel:MyExit()
	DSM.PopAct()
	self:RemoveLister()
	EmailLogic.ClosePanel()
	PersonalInfoPanel.Exit()
	self:ExitAnim()
	if self.game_btn_pre then
		self.game_btn_pre:MyExit()
	end
end

function HallPanel:MyClose()
    self:MyExit()
    closePanel(HallPanel.name)
end

function HallPanel:InitAnim()
end

function HallPanel:EnterAnim()
	
end
function HallPanel:ExitAnim()
	if self.time_pay_anim then
		self.time_pay_anim:Stop()
	end
	if self.time_pay_fx then
		self.time_pay_fx:Stop()
	end
	if self.time_jbs_fx then
		self.time_jbs_fx:Stop()
	end
end

function HallPanel:RefreshActivityUI()
	local transform = self.transform
	if not IsEquals(transform) then return end

	local function check_activity_time(time_table, current_time)
		for k, v in pairs(time_table) do
			if v[1] <= current_time and v[2] > current_time then
				return true
			end
		end
		return false
	end

	local function find_node(trans, node_name)
		local result = trans:Find(node_name)
		
		if not result then
			for idx = 0, trans.childCount - 1 do
				local child = trans:GetChild(idx)
				result = find_node(child, node_name)
				if result then return result end
			end
		end

		return result
	end

	local current_time = os.time()
	local timeTable = HallLogic.GetActivityTimeTable() or {}
	for k, v in pairs(timeTable) do
		if v.activity_node and v.activity_node ~= "" then
			local node = find_node(transform, v.activity_node)	--transform:Find(v.activity_node)
			if node then
				if check_activity_time(v.activity_time, current_time) then
					node.gameObject:SetActive(true)
				else
					node.gameObject:SetActive(false)
				end
			end
		end
	end
end

function HallPanel:set_vip_info()
	if not VIPManager then return end
	VIPManager.set_vip_text(self.head_vip_txt)
	for i = 1,7 do
		if not IsEquals(self["vipnode" .. i]) then return end
		self["vipnode"..i].gameObject:SetActive(false)
	end
	local vip_l = VIPManager.get_vip_level()
	if vip_l == 0 then
		self["vipnode"..1].gameObject:SetActive(true)
	elseif vip_l == 1 then
		self["vipnode"..2].gameObject:SetActive(true)
	elseif vip_l == 2 then
		self["vipnode"..3].gameObject:SetActive(true)
	elseif vip_l == 3 then
		self["vipnode"..4].gameObject:SetActive(true)
	elseif vip_l == 4 then
		if Sys_018_VIP4FFYDManager.GetCanBuyShopIDIndex() == 4 then
			self["vipnode"..7].gameObject:SetActive(true)
		else
			self["vipnode"..6].gameObject:SetActive(true)
		end
	else
		self["vipnode"..5].gameObject:SetActive(true)
	end
	if PlayerPrefs.GetInt(VIPManager.get_vip_level().."_hall_vip_click",0) == 1 then
		self.VIP_btn_red.gameObject:SetActive(false)
	else
		self.VIP_btn_red.gameObject:SetActive(true)
	end
end

function HallPanel:UpdateVerifide()
    local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key="drt_block_real_name_verify", is_on_hint = true}, "CheckCondition")
    if (a and b) or not GameGlobalOnOff.Certification then
        self.authentication.gameObject:SetActive(false)
        return
    end
	--print("HallPanel:UpdateVerifide: " .. MainModel.UserInfo.verifyData.status)
    if MainModel.UserInfo and MainModel.UserInfo.verifyData and MainModel.UserInfo.verifyData.status then
        local status = MainModel.UserInfo.verifyData.status == 1
        self.authentication.gameObject:SetActive(not status)
    else
        self.authentication.gameObject:SetActive(true)
	end
	--实名认证点头像后，提示消失
	if PlayerPrefs.GetInt(MainModel.UserInfo.user_id.."smrz_headimg_hadclick",0) == 1 then
		self.authentication.gameObject:SetActive(false)
	end
end
function HallPanel:ReConnecteServerSucceed()
	MainModel.GetVerifyStatus(basefunc.handler(self, self.UpdateVerifide))
end

function HallPanel:OnFuliClick()
	GameButtonManager.GotoUI({gotoui = "jyfl",goto_scene_parm = "panel"})
end

function HallPanel:SetQMZQ()
	self.is_qmzq_opened = PlayerPrefs.GetInt("qmzq" .. MainModel.UserInfo.user_id, 0) == 1
	self.is_opened_time_over_a_day = os.time() - PlayerPrefs.GetInt("qmzq_time"..MainModel.UserInfo.user_id,0) <= 86400

	self.money_center_red.gameObject:SetActive(not self.is_qmzq_opened and self.is_opened_time_over_a_day)
end

function HallPanel:set_head_image()
	--刷新头像
	URLImageManager.UpdateHeadImage(MainModel.UserInfo.head_image, self.player_head_img)
end

function HallPanel:set_player_name()
	self.player_name_txt.text = MainModel.UserInfo.name
end

function HallPanel:SetVipClick()
	PlayerPrefs.SetInt(VIPManager.get_vip_level().."_hall_vip_click",1)
	if PlayerPrefs.GetInt(VIPManager.get_vip_level().."_hall_vip_click",0) == 1 then
		self.VIP_btn_red.gameObject:SetActive(false)
	else
		self.VIP_btn_red.gameObject:SetActive(true)
	end
end

--修改昵称成功,刷新昵称显示
function HallPanel:on_SYSChangeHeadAndNameManager_Change_Name_Success_msg()
    self.player_name_txt.text = MainModel.UserInfo.name
end

--设置头像成功,刷新头像显示
function HallPanel:on_SYSChangeHeadAndNameManager_Change_Head_Success_msg()
    URLImageManager.UpdateHeadImage(MainModel.UserInfo.head_image, self.player_head_img)
end