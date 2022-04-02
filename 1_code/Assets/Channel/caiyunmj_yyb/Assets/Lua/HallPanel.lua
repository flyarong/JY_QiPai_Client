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
	lister["model_update_init_rapid_id"] = basefunc.handler(self, self.model_update_init_rapid_id)
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
	instance=HallPanel.New(call)
	return instance
end

function HallPanel:SetupBtns()
	self.JBSBox.PointerClick:AddListener(function (obj)
		self:OnMatchClick(obj)
	end)
	self.JBSTSBox.PointerClick:AddListener(function (obj)
		self:OnMatchClick(obj)
	end)
	self.QPBox.PointerClick:AddListener(function (obj)
		local _,ksdata = GameFreeModel.CheckRapidBeginGameID ()
		dump(ksdata, "----------------- rapid begin game ----------------------")
		if ksdata and ksdata.order == 1 and GameGlobalOnOff.Shop_10_gift_bag and GameFreeModel.IsRoomEnter(ksdata.game_id) == 1 then
			OneYuanGift.Create(nil, function ()
				GameFreeModel.RapidBeginGame()			
			end)
		else
			GameFreeModel.RapidBeginGame()
		end
	end)
	self.PEBox.PointerClick:AddListener(function (obj)
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		GameFreeModel.RapidBeginGameLevel(1)
	end)
	self.FISHINGBox.PointerClick:AddListener(function (obj)
		self:OnFishingClick(obj)
	end)
	self.MINIGAMEBox.PointerClick:AddListener(function (obj)
		self:OnMiniGameClick(obj)
	end)

	self.QYBox.PointerClick:AddListener(function (obj)
		self.OnMatchQYSClick(obj)
	end)
end

function HallPanel:ctor(call)
	local parent = GameObject.Find("Canvas/LayerLv1").transform
	local obj = newObject(HallPanel.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj

	self.openCall = call
	LuaHelper.GeneratingVar(self.transform, self)

	EventTriggerListener.Get(self.pay_btn.gameObject).onClick = basefunc.handler(self, self.OnPayClick)
	EventTriggerListener.Get(self.set_btn.gameObject).onClick = basefunc.handler(self, self.OnSetClick)
	EventTriggerListener.Get(self.service_btn.gameObject).onClick = basefunc.handler(self, self.OnServiceClick)
	EventTriggerListener.Get(self.LBDH_btn.gameObject).onClick = basefunc.handler(self, self.OnLBDHClick)

	EventTriggerListener.Get(self.AddGold_btn.gameObject).onClick = basefunc.handler(self, self.OnAddGoldClick)
	EventTriggerListener.Get(self.AddDiamond_btn.gameObject).onClick = basefunc.handler(self, self.OnAddDiamondClick)
	EventTriggerListener.Get(self.activity_btn.gameObject).onClick = basefunc.handler(self, self.OnActivityClick)
	EventTriggerListener.Get(self.bag_btn.gameObject).onClick = basefunc.handler(self, self.OnBagClick)
	EventTriggerListener.Get(self.scanner_btn.gameObject).onClick = basefunc.handler(self, self.OnScannerClick)

	EventTriggerListener.Get(self.change_city_btn.gameObject).onClick = basefunc.handler(self, self.OnChangeCityClick)

	EventTriggerListener.Get(self.PhoneButton_btn.gameObject).onClick = basefunc.handler(self, self.OnPhoneClick)
	EventTriggerListener.Get(self.GZHButton_btn.gameObject).onClick = basefunc.handler(self, self.OnGZHClick)

	EventTriggerListener.Get(self.Area_btn.gameObject).onClick = basefunc.handler(self, self.OnAreaClick)
	
	HallBannerWidget.Create(self.BannerNode)

	self.updateAssetInfoHandler = function ()
		self:UpdateAssetInfo()
	end

	self.JBSBox = self.JBSBox:GetComponent("PolygonClick")
	self.JBSTSBox = self.JBSTSBox:GetComponent("PolygonClick")
	self.FKBox = self.FKBox:GetComponent("PolygonClick")
	self.QPBox = self.QPBox:GetComponent("PolygonClick")
	self.PEBox = self.PEBox:GetComponent("PolygonClick")
	self.MINIGAMEBox = self.MINIGAMEBox:GetComponent("PolygonClick")
	self.FISHINGBox = self.FISHINGBox:GetComponent("PolygonClick")
	self.QYBox = self.QYBox:GetComponent("PolygonClick")
    EventTriggerListener.Get(self.ServiceTop.gameObject).onClick = basefunc.handler(self, self.SetServiceTopClick)

	self.headimage = self.player_center_btn.gameObject:GetComponent("Image")
	self:update_dressed_head_frame()
	
	--刷新头像
	URLImageManager.UpdateHeadImage(MainModel.UserInfo.head_image, self.player_head_img)
	
	self.player_name_txt.text = MainModel.UserInfo.name
	self.shop_gold_txt.text = StringHelper.ToCash(MainModel.UserInfo.jing_bi)
	self.shop_diamond_txt.text = StringHelper.ToCash(MainModel.UserInfo.diamond)

	self.QPJJHintKey = "QPJJHintKey" .. MainModel.UserInfo.user_id

	self.ServiceNode.gameObject:SetActive(false)
	self:InitAnim()
	self:EnterAnim()

	--更新部分
	self.updateHintTmpl = self.transform:Find("UpdateHintTmpl")
	self.updateUI = {}
	self:UpdateUpdateHint()

	self.ksSpine = self.dt_dizhu:GetComponent("SkeletonAnimation")

	self:MakeLister()
	self:AddLister()

	local deeplink = sdkMgr:GetDeeplink()
	if not deeplink or deeplink == "" then
		print("<color=red>deeplink is null</color>")
	else
		print("<color=red>deeplink = " .. deeplink .. "</color>")
		MainLogic.HandleOpenURL(deeplink)
	end
	self:model_update_init_rapid_id()

	MainModel.GetVerifyStatus()
	MainModel.GetBindPhone()
	-- GameTaskModel.InitTaskRedHint()
	GameTaskModel.ChangeTaskCanGetRedHint()

	RedHintManager.AddRed(RedHintManager.RedHintKey.RHK_Head, self.head_red.gameObject)
	RedHintManager.AddRed(RedHintManager.RedHintKey.RHK_Bag, self.bag_red.gameObject)
	RedHintManager.AddRed(RedHintManager.RedHintKey.RHK_PhoneAward, self.phone_award_red.gameObject)
	RedHintManager.AddRed(RedHintManager.RedHintKey.RHK_Activity, self.activity_red.gameObject)
	RedHintManager.AddRed(RedHintManager.RedHintKey.RHK_Activity_GET, self.activity_get.gameObject)
	RedHintManager.AddRed(RedHintManager.RedHintKey.RHK_GD, self.service_red.gameObject)

	RedHintManager.UpdateRedHint(RedHintManager.RedHintKey.RHK_XYCJ)

	self:OnOff()
	--大厅活动图标更新
	self:RefreshActivityUI()
	self:OpenUIAnim()

	HandleLoadChannelLua("HallPanel", self)

	GameMoneyCenterModel.GetSCZDBaseInfo()

	local btn_map = {}
	btn_map["center"] = {self.hall_btn_5, self.hall_btn_6, self.hall_btn_7, self.hall_btn_8}
	btn_map["right_top"] = {self.hall_btn_4, self.hall_btn_3, self.hall_btn_2, self.hall_btn_1}
	btn_map["top"] = {self.hall_btn_top}
	self.game_btn_pre = GameButtonPanel.Create(btn_map, "hall_config")
	self:MyRefresh()
end
function HallPanel:MyRefresh()
	self:UpdateAssetInfo()
	self:RefreshQYSMatch()
end

-- 刷新千元赛比赛提示
function HallPanel:RefreshQYSMatch()
	local b = MatchModel.IsTodayHaveMatchByType("qydjs")
	if b then
		self.qys_jb_img.gameObject:SetActive(true)
		self.qys_jb_not_img.gameObject:SetActive(false)
	else
		self.qys_jb_img.gameObject:SetActive(false)
		self.qys_jb_not_img.gameObject:SetActive(true)
	end
end

function HallPanel:model_update_init_rapid_id()
	local _,ksdata = GameFreeModel.CheckRapidBeginGameID ()
	if not IsEquals(self.KS_img) then
		return
	end
	if ksdata then
		self.KS_img.gameObject:SetActive(true)
		self.KS_img.sprite = GetTexture(ksdata.image)
		self.KS_img:SetNativeSize()
		self.KS_txt.text = "底分 " .. ksdata.base

		if self.QP.gameObject.activeSelf and self.ksSpine and IsEquals(self.ksSpine) then
			if string.sub(ksdata.game_type, 1, 7) == "game_Mj" then
				self.ksSpine.AnimationName = "majiang"
			else
				self.ksSpine.AnimationName = "doudizhu"
			end
		end
	else
		self.KS_img.gameObject:SetActive(false)
		self.KS_txt.text = ""
	end
end

function HallPanel:update_dressed_head_frame()
	if true then return end
	PersonalInfoManager.SetHeadFarme(self.headimage)
end
-- 界面打开的动画
function HallPanel:OpenUIAnim()
	if true then
		local tt = 0.25

		self.RectTop.transform.localPosition = Vector3.New(0, 118, 0)
		self.RectLeft.transform.localPosition = Vector3.New(-1400, -13.8, 0)
		self.RectRight.transform.localPosition = Vector3.New(1560, 0, 0)
		self.RectDownL.transform.localPosition = Vector3.New(0, -94, 0)
		self.log_img.transform.localScale = Vector3.New(0.1,0.1,0.1)

		local seq = DG.Tweening.DOTween.Sequence()
		local tweenKey = DOTweenManager.AddTweenToStop(seq)
		seq:Join(self.RectTop.transform:DOLocalMoveY(-92, tt))
		-- seq:AppendInterval(-1 * tt)
		seq:Join(self.RectLeft.transform:DOLocalMoveX(-540, tt))
		-- seq:AppendInterval(-1 * tt)
		seq:Join(self.RectRight.transform:DOLocalMoveX(360, tt))
		-- seq:AppendInterval(-1 * tt)
		seq:Join(self.RectDownL.transform:DOLocalMoveY(42, tt))
		-- seq:AppendInterval(-1 * tt)
		seq:Join(self.log_img.transform:DOScale(Vector3.New(1,1,1), tt))
		seq:OnComplete(function ()
		end)
		seq:OnKill(function ()
			DOTweenManager.RemoveStopTween(tweenKey)
			self:OpenUIAnimFinish()
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
	self.RectRight.transform.localPosition = Vector3.New(360, 0, 0)
	self.RectDownL.transform.localPosition = Vector3.New(0, 42, 0)
	self.log_img.transform.localScale = Vector3.New(1,1,1)

	--add listener
	self:SetupBtns()
	
	--同步一下任务数据
	local SYNC_TASK_TBL = { 53, 54 }
	for _, v in pairs(SYNC_TASK_TBL) do
		Network.SendRequest("query_one_task_data", {task_id = v})
	end
	
	if self.openCall then
		self.openCall()
	end
end
-- 客服全局点击控制
function HallPanel:SetServiceTopClick()
	self.ServiceNode.gameObject:SetActive(false)
end

function HallPanel:OnOff()
	if GameGlobalOnOff.IOSTS then
		self.JBSTS.gameObject:SetActive(true)
		self.JBS.gameObject:SetActive(false)
	else
		self.JBSTS.gameObject:SetActive(false)
		self.JBS.gameObject:SetActive(true)
	end

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

	if GameGlobalOnOff.Shop then
		self.pay_btn.gameObject:SetActive(true)
	else
		self.pay_btn.gameObject:SetActive(false)
	end

	--[[if GameGlobalOnOff.IOSTS then
		self.FISHING.gameObject:SetActive(false)
	else
		self.FISHING.gameObject:SetActive(true)
	end]]--
end

function HallPanel:OnAddGoldClick(go)
	PayPanel.Create(GOODS_TYPE.jing_bi, "normal")
end

function HallPanel:OnAddDiamondClick(go)
	PayPanel.Create(GOODS_TYPE.goods, "normal")
end

--比赛场
function HallPanel:OnMatchClick(go)
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	GameManager.GotoUI({gotoui = GameConfigToSceneCfg.game_MatchHall.SceneName})
end

-- 捕鱼场
function HallPanel:OnFishingClick(go)
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	if GameGlobalOnOff.Fishing then
		
		self:SignFishing()
	else
		HintPanel.Create(1, "即将开放，敬请期待")
	end
end

local FishingGoldLevelTbl = {
	{1000, 2000000}, {10000, 20000000}, {100000, }, {0, 20000}
}
local function CheckGoldLevel(gold_min, gold_max, gold)
    if gold_min and gold_max then
        if gold >= gold_min and gold <= gold_max then
            return true
        elseif gold < gold_min then
            return false
        elseif gold > gold_max then
            return false
        end
    elseif gold_min and not gold_max then
        if gold >= gold_min then
            return true
        else
            return false
        end
    elseif not gold_min and gold_max then
        if gold <= gold_max then
            return true
        else
            return false
        end
    end
    return false
end

function HallPanel:SignFishing()
	local g_id = 0
	local gold = (MainModel.UserInfo.jing_bi or 0) + (MainModel.UserInfo.fish_coin or 0)
	for k, v in pairs(FishingGoldLevelTbl) do
		if CheckGoldLevel(v[1], v[2], gold) then
			g_id = k
			break
		end
	end

	if g_id <= 0 then
		PayPanel.Create("jing_bi")
		return
	end
	GameManager.CommonGotoScence({gotoui = "game_Fishing",p_requset = {id = g_id},goto_scene_parm={game_id = g_id}})
end

-- 小游戏
function HallPanel:OnMiniGameClick(go)
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	GameManager.GotoUI({gotoui = "game_MiniGame"})	
end

-- 千元赛
function HallPanel:OnMatchQYSClick()
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	local parm = {hall_type = MatchModel.HallType.djs}
	GameManager.GotoUI({gotoui = GameConfigToSceneCfg.game_MatchHall.SceneName,goto_scene_parm = parm})
end

function HallPanel:OnAreaClick()
	HintPanel.Create(1, "敬请期待")
end

--打开充值
function HallPanel:OnPayClick(go)
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
	if GameGlobalOnOff.IOSTS then
		HintPanel.Create(1, "敬请期待")
		return
	end

	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	GameManager.GotoUI({gotoui="hall_activity", goto_scene_parm="panel"})
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
	if IsEquals(self.shop_diamond_txt) then
		self.shop_diamond_txt.text = StringHelper.ToCash(MainModel.UserInfo.diamond)
	end
	self:model_update_init_rapid_id()
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
	self:RemoveLister()
	HallBannerWidget.Close()
	RoomCardHallPopPrefab.Close()
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
	self.anim_jbs = self.JBS:GetComponent("Animator")
	self.fx_pay = self.chongzhi.gameObject

end
function HallPanel:EnterAnim()
	self:PlayPayFX()
	self:PlayJBSFX()
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

-- 充值特效
function HallPanel:PlayPayFX()
	local t = math.random(5, 10)
	self.time_pay_fx = Timer.New(function ()
		self.fx_pay:SetActive(false)
		self.fx_pay:SetActive(true)
		self.time_pay_fx:Stop()
		self:PlayPayFX()
	end, t)
	self.time_pay_fx:Start()
end
-- 充值特效
function HallPanel:PlayJBSFX()
	local t = math.random(5, 10)
	self.time_jbs_fx = Timer.New(function ()
		self.time_jbs_fx:Stop()
		if IsEquals(self.anim_jbs_jbs) then
			self.anim_jbs:Play("@JBS_liuguang", -1, 0)
		end
		self:PlayJBSFX()
	end, t)
	self.time_jbs_fx:Start()
end

function HallPanel.GetQYSZhouKaRemain()
	return HallPanel.qys_zhouka_remain or -1
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

	if GameGlobalOnOff.IOSTS then return end
	  
end

