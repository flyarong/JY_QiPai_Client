-- 创建时间:2021-12-07
-- Panel:Act_071_SDZFPanel
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
 -- 取消按钮音效
 -- ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
 -- 确认按钮音效
 -- ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
 --]]

local basefunc = require "Game/Common/basefunc"

Act_071_SDZFPanel = basefunc.class()
local C = Act_071_SDZFPanel
C.name = "Act_071_SDZFPanel"
local M = Act_071_SDZFManager

local progressFullW = 435.2

local rules = {
	"1.活动时间：12月21日7:30~12月27日23:59:59",
	"2.所有小游戏（不包含苹果大战）均可获得袜子道具",
	"3.请及时使用袜子道具进行升级，活动结束后将清除所有袜子道具",
	"4.活动结束后，所有已解锁未领取的奖励将通过邮件发送到您的邮箱",
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
	self.lister["act_071_sdzf_level_data_change"] = basefunc.handler(self, self.on_act_071_sdzf_level_data_change)
	self.lister["act_071_sdzf_award_data_change"] = basefunc.handler(self, self.on_act_071_sdzf_award_data_change)
	self.lister["AssetChange"] = basefunc.handler(self, self.OnAssetChange)
    self.lister["ExitScene"] = basefunc.handler(self, self.OnExitScene)
	self.lister["finish_gift_shop"] = basefunc.handler(self, self.on_finish_gift_shop)
	
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	self:ClearTween()
	self.taskScroll.onValueChanged:RemoveAllListeners()
	self:ClearPool()
	self:ClearContainers()
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:OnDestroy()
	self:MyExit()
end

function C:MyClose()
	self:MyExit()
end

function C:ctor(parent)
	ExtPanel.ExtMsg(self)
	local parent = parent or GameObject.Find("Canvas/LayerLv4").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:UpdateData()
	self:InitUI()
end

function C:UpdateData()
	self.data = M.GetData()
	self.curLvCfg = M.GetConfigFromLevel(self.data.curLv)
	self.nextLvCfg = M.GetConfigFromLevel(self.data.curLv + 1)
	-- dump(self.nextLvCfg, "<color=white>NNNNNNNNNNNNNNNNNNNNNNNNNNNNN</color>")
end

function C:InitUI()

	self:InitAwardPool()
	self.up_grade_btn.onClick:AddListener(function()
		self:UpGrade()
	end)
	self.get_all_btn.onClick:AddListener(function()
		self:GetAllAward()
	end)
	self.buy_gift_btn.onClick:AddListener(function()
		GameManager.BuyGift(M.gift_id)
	end)
	self.add_btn.onClick:AddListener(function()
		if MainModel.myLocation == "game_Hall" then
			GameManager.GotoUI({gotoui="game_MiniGame"})
		else
			LittleTips.Create("已在对应场景")
		end
	end)

	self.rule_btn.onClick:AddListener(function()
		self:OpenHelpPanel()
	end)

	self.gradeProgressTrans = self.progress:GetComponent("RectTransform")
	self.gradeProgressTransRect = self.gradeProgressTrans.rect
	self.taskScroll = self.TaskScroll:GetComponent("ScrollRect")

	EventTriggerListener.Get(self.taskScroll.gameObject).onEndDrag = function()
		local VNP = self.taskScroll.verticalNormalizedPosition  
		if VNP <= 0 then 
			LittleTips.Create("最多展示当前等级+20级的奖励")
		end
	end

	-- self:MyRefresh()
	self:RefreshMyItemNum()
	self:RefreshGrade(true)
	self:RefreshAllAward()
	self:RefreshGiftBuyBtn()

	--判断容器是否将要进入mask或者已离开mask一定距离，此时回收容器内的award入对象池
	self.taskScroll.onValueChanged:AddListener(function(value)
		self:CheckAwardContain(value)
	end)
	CommonTimeManager.GetCutDownTimer(M.endTime, self.remain_time_txt)
	-- local data = {
	-- 	change_asset = {
	-- 		[1] = { asset_type = "jing_bi", asset_value = "5000" }
	-- 	},
	-- 	no = 3,
	-- 	type = "christmas_blessing_recieve_award1"
	-- }
	-- M.SetGetAwardSigns(1)
	-- MainModel.OnNotifyAssetChangeMsg("",data)
end

function C:InitAwardPool()
	self.awardPool = {}
	self.awardPool.pools = {}
	self.awardPool.Recycle = function(awardItem)
		awardItem:RecycleToPool(self.award_pool)
		self.awardPool.pools[#self.awardPool.pools + 1] = awardItem
	end

	self.awardPool.Take = function(containerTrans)
		local len = #self.awardPool.pools
		local poolTakeItem = nil
		if len > 0 then
			poolTakeItem = self.awardPool.pools[len]
		end
		if poolTakeItem then
			poolTakeItem:TakeFromPool(containerTrans)
			self.awardPool.pools[len] = nil
			return poolTakeItem
		else
			dump("<color=white>对象池触底</color>")
			self:MyExit()
		end
	end

	local awardPoolLen = 20
	for i = 1, awardPoolLen do
		local awardItem = Act_071_SDZFAwardItem.Create(self.award_pool)
		self.awardPool.Recycle(awardItem)
	end

	dump(self.awardPool.pools, "<color=white>初始化的对象池</color>")
end

function C:ClearPool()
	for i = 1, #self.awardPool.pools do
		self.awardPool.pools[i]:MyExit()
	end
	self.awardPool.pools = nil
end

function C:ClearContainers()
	for i = 1, #self.awardContainerPre do
		if self.awardContainerPre[i].isContainAward then
			self.awardContainerPre[i].awardItem:MyExit()
		end
		self.awardContainerPre[i].obj:MyExit()
	end
	self.awardContainerPre = nil
end

function C:UpGrade()
	if GameItemModel.GetItemCount(M.item_key) > 0 then
		Network.SendRequest("christmas_blessing_lv_up")
	else
		LittleTips.Create("所需道具数量不足")
	end
end

function C:OpenHelpPanel()
	local str = rules[1]
	for i = 2, #rules do
		str = str .. "\n" .. rules[i]
	end
	self.introduce_txt.text = str
	IllustratePanel.Create({ self.introduce_txt.gameObject }, GameObject.Find("Canvas/LayerLv5").transform)
end
 
function C:CheckAwardContain(value)
	-- local checkOrder = 1
	-- --判断滑动的方向
	-- if value then
	-- 	if not self.taskScrollValue then
	-- 		self.taskScrollValue = value
	-- 	else
	-- 		if self.taskScrollValue > value then
	-- 			checkOrder = 1
	-- 		else
	-- 			checkOrder = -1
	-- 		end
	-- 		self.taskScrollValue = value
	-- 	end
	-- end

	for i = 1, #self.awardContainerPre do
		local y = self.awardContainerPre[i].obj.transform.position.y
		if self.awardContainerPre[i].isContainAward == true then
			self:CheckIsShowFx(self.awardContainerPre[i], y)
			if y > 400 or y < -300 then
				-- dump("isContainAward == true " .. self.awardContainerPre[i].index)
				self.awardPool.Recycle(self.awardContainerPre[i].awardItem)
				self.awardContainerPre[i].awardItem = nil 
				self.awardContainerPre[i].isContainAward = false
			end
		else
			if y < 400 and y > -300 then
				self.awardContainerPre[i].awardItem = self.awardPool.Take(self.awardContainerPre[i].obj.transform)
				self.awardContainerPre[i].isContainAward = true
				self.awardContainerPre[i].awardItem:RefreshView(self.awardContainerPre[i].index)
				self.awardContainerPre[i].awardItem:ShowFx() 
				self:CheckIsShowFx(self.awardContainerPre[i], y)
			end
		end
	end	
end

function C:CheckIsShowFx(awardContainer, y)
	if y > 150 or y < -270 then
		if not awardContainer.isHideFx then
			awardContainer.awardItem:HideFx()
			awardContainer.isHideFx = true
		end
	else
		if awardContainer.isHideFx then
			awardContainer.awardItem:ShowFx()
			awardContainer.isHideFx = false
		end
	end
end

--level 领取的等级  award_type 1 普通 2 至尊
function C:GetAward(award_type)
	Network.SendRequest("christmas_blessing_lv_up", {award_type = award_type})
end

function C:GetAllAward()
	local noAward = false
	if self.data.curLv == 0 then
		noAward = true
	elseif self.data.isZZZF then
		if self.data.curLv < self.data.curGetLvNormal and self.data.curLv < self.data.curGetLvZZ then
			noAward = true
		end
	elseif not self.data.isZZZF then
		if self.data.curLv < self.data.curGetLvNormal then
			noAward = true
		end
	end

	if noAward then
		LittleTips.Create("无奖励可领")
		return
	end
	Network.SendRequest("christmas_blessing_recieve_award", {award_type = -1})
	M.SetGetAwardSigns(-1)
end

function C:MyRefresh()
end

function C:RefreshMyItemNum()
	self.num_txt.text = GameItemModel.GetItemCount(M.item_key)
end

function C:RefreshGrade(isInit)
	self.grade_txt.text = self.data.curLv .. "级"
	self.progress_txt.text = self.data.curPorgress .. "/" .. self.nextLvCfg.consume_num
	local gradeProgressRectW 
	if self.data.curPorgress < self.nextLvCfg.consume_num * 0.98 then
		gradeProgressRectW = (self.data.curPorgress / self.nextLvCfg.consume_num) * progressFullW
	else
		gradeProgressRectW =  0.98 * progressFullW
	end
	if isInit then
		self.gradeProgressTrans.sizeDelta = Vector2.New(gradeProgressRectW, self.gradeProgressTransRect.height)
	else
		self:RefreshExpProgress(gradeProgressRectW)
	end
end

function C:ClearTween()
	if self.DT then
		self.DT:Kill()
		self.DT = nil
	end
end

function C:RefreshExpProgress(newRectW)
	self:ClearTween()
	if newRectW < self.gradeProgressTrans.sizeDelta.x then
		self.gradeProgressTrans.sizeDelta = Vector2.New(0, self.gradeProgressTransRect.height)
	end
	local startW = self.gradeProgressTrans.sizeDelta.x
    self.DT = DG.Tweening.DOTween.To(
        DG.Tweening.Core.DOGetter_float(
            function(value)
                return startW 
            end
        ),
        DG.Tweening.Core.DOSetter_float(
			function(value)
				if IsEquals(self.gameObject) then
					self.gradeProgressTrans.sizeDelta = Vector2.New(value, self.gradeProgressTransRect.height)
				end
            end
        ),
        newRectW, 1.2
    ):OnComplete(
		function()
		
        end 
	)
	self.DT:SetEase(DG.Tweening.Ease.OutCubic)
end


function C:CreateAwardContaniner(num)
	for i = 1, num do
		local awardContainer = {}
		awardContainer.index = #self.awardContainerPre + 1
		awardContainer.obj = Act_071_SDZFAwardContainer.Create(self.Content)
		awardContainer.isContainAward = false
		awardContainer.isHideFx = false
		awardContainer.awardItem = nil
		self.awardContainerPre[#self.awardContainerPre + 1] = awardContainer
	end
	-- for i = 1, #self.awardContainerPre do
	-- 	dump("y = " .. self.awardContainerPre[i].obj.transform.position.y)
	-- end
	self.taskScroll.verticalNormalizedPosition = 1
	self:CheckAwardContain()
	
end

function C:RefreshAllAward()
	self.awardContainerPre = self.awardContainerPre or {}
	--显示当前等级+20级的奖励
	local awardLen = self.data.curLv + 20
	if awardLen > #self.awardContainerPre then
		local createLen = awardLen - #self.awardContainerPre
		self:CreateAwardContaniner(createLen)
	end
	for i = 1, #self.awardContainerPre do
		if self.awardContainerPre[i].isContainAward then
			self.awardContainerPre[i].awardItem:RefreshView(self.awardContainerPre[i].index)
		end
	end

	local indexShow = self.data.curLv
	if self.data.curGetLvNormal <= indexShow then
		indexShow = self.data.curGetLvNormal
	end

	if self.data.isZZZF and self.data.curGetLvZZ <= indexShow then
		indexShow = self.data.curGetLvZZ
	end

	local dNormalizedPosition = 1 / (#self.awardContainerPre - 4.4)
	coroutine.start(
        function()
            -- 下一帧
            Yield(0)
			if self.taskScroll then
				self.taskScroll.verticalNormalizedPosition = 1 - dNormalizedPosition * (indexShow - 1)
			end
		end)
	-- self.taskScroll.normalizedPosition = { x = self.taskScroll.normalizedPosition.x, y = 1 - dNormalizedPosition * (indexShow - 1)} 
end

function C:RefreshGiftBuyBtn()
	local gift_status = MainModel.GetGiftShopStatusByID(M.gift_id)
	self.buy_gift_btn.gameObject:SetActive(gift_status == 1)
end

function C:on_act_071_sdzf_level_data_change()
	self:UpdateData()
	self:RefreshGrade(false)
	-- self:RefreshAllAward()
end

function C:on_act_071_sdzf_award_data_change()
	self:UpdateData()
	self:RefreshAllAward()
end

function C:OnAssetChange(data)
	self:RefreshMyItemNum()
	if data.change_type == "christmas_blessing_recieve_award1" 
	or data.change_type == "christmas_blessing_recieve_award-1" 
	or data.change_type == "christmas_blessing_recieve_award2" then
		dump(data, "<color=white> 圣诞祝福 资产改变 AssetChange</color>")
		if table_is_null(data.data) then
			return
		end
		if self.data.isZZZF or M.GetGetAwardSignsAwardType() == -1 then
			Event.Brocast("AssetGet", data)
		else
			Act_071_SDZFAssetGet.Create(data)
		end
	end	
end

function C:OnExitScene()
	self:MyExit()
end

function C:OnDestroy()
	self:MyExit()
end

function C:on_finish_gift_shop(id)
	dump(id, "<color=white> 圣诞祝福 购买返回 </color>")
	if id == M.gift_id then
		self:RefreshGiftBuyBtn()
		Network.SendRequest("christmas_blessing_get_info")
	end
end
