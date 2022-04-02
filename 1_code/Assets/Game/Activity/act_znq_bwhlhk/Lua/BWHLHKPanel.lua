-- 创建时间:2020-08-05
-- Panel:BWHLHKPanel
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
local config = {
	[1] = {level = {"VIP0"},award = {[1] = { img = "eznhk_icon_1",txt = "鲸币礼包",tips ="鲸币礼包：最高可获得10万鲸币！",tishi="最高可获得10万鲸币!"}}},
	[2] = {level = {"VIP1、2"},award = { [1] = {img = "eznhk_icon_2",txt = "鲸币宝箱",tips ="鲸币宝箱：最高可获得50万鲸币！",tishi="最高可获得50万鲸币!"}}},
	[3] = {level = {"VIP3、4"},award = {[1] = { img = "eznhk_icon_3",txt = "大额鲸币宝箱",tips ="大额鲸币宝箱：最高可获得200万鲸币！",tishi="最高可获得200万鲸币!"}}},
	[4] = {level = {"VIP5、6、7"},award = { [1] = {img = "eznhk_icon_4",txt = "巨额鲸币宝箱",tips ="巨额鲸币宝箱：最高可获得500万鲸币！",tishi="最高可获得500万鲸币!"}}},
	[5] = {level = {"VIP8、9"},award = {[1] = { img = "eznhk_icon_4",txt = "巨额鲸币宝箱",tips ="巨额鲸币宝箱：最高可获得500万鲸币！"},[2] = { img = "activity_icon_gift201_dlb",txt = "回馈大礼包",tips ="回馈大礼包：保温杯，自动雨伞，笔记本和签字笔，联系客服QQ：4008882620领取！"}}},
	[6] = {level = {"VIP10"},award = {[1] = { img = "eznhk_icon_4",txt = "巨额鲸币宝箱",tips ="巨额鲸币宝箱：最高可获得500万鲸币！"},[2] = { img = "activity_icon_gift201_dlb",txt = "回馈大礼包",tips ="回馈大礼包：保温杯，自动雨伞，笔记本和签字笔，联系客服QQ：4008882620领取！"},[3] = {img = "activity_icon_gift203_jnb",txt = "纯银纪念币",tips ="纯银纪念币：鲸鱼新家园专属纪念币，联系客服QQ：4008882620领取！"}}},
	[7] = {level = {"VIP11、12"},award = {[1] = { img = "eznhk_icon_4",txt = "巨额鲸币宝箱",tips ="巨额鲸币宝箱：最高可获得500万鲸币！"},[2] = { img = "activity_icon_gift201_dlb",txt = "回馈大礼包",tips ="回馈大礼包：保温杯，自动雨伞，笔记本和签字笔，联系客服QQ：4008882620领取！"},[3] = {img = "activity_icon_gift202_zyz",txt = "黄金转运珠",tips ="黄金转运珠：12生肖黄金转运珠（可选），联系客服QQ：4008882620领取！"}}},
}

local vip_config = {{0},{1,2},{3,4},{5,6,7},{8,9},{10},{11,12}}


local item_width = 1037.6 


local  tras_config = {
}

BWHLHKPanel = basefunc.class()
local C = BWHLHKPanel
C.name = "BWHLHKPanel"

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
	self.lister["ExitScene"] = basefunc.handler(self, self.OnExitScene)
end
function C:OnExitScene()
	self:OnDestroy()
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	if self.MainTimer then
		self.MainTimer:Stop()
	end
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:ctor(parent)
	ExtPanel.ExtMsg(self)
	local parent = parent or GameObject.Find("Canvas/LayerLv5").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	tras_config = {}
	self:MakeLister()
	self:AddMsgListener()
	self:InitTranConfig()
	self:InitClearConfig()
	self:InitUI()
	self.canMoveByAct = true
	self.MoveByBtn = false
	self:InitMainTimer()
	
end

function C:InitUI()
	self.index = self:GetCurVIPLevel() + 1
	self.index_vip = self:GetCurVIPLevel()

	if self.BigContent.transform.localPosition.x < 0 then
		self.LeftButton_btn.gameObject:SetActive(true)
		self.RightButton_btn.gameObject:SetActive(true)
	end

	local v = Vector2.New(-1*self.index_vip * item_width,self.BigContent.transform.localPosition.y)
	self.BigContent.transform.localPosition = v

	self.RightButton_btn.onClick:AddListener(
		function ()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
			self:GoNext()
		end
	)
	self.LeftButton_btn.onClick:AddListener(
		function ()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
			self:GoLast()
		end
	)
	self.Btn_btn.onClick:AddListener(
		function ()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
			LittleTips.Create("9月1日7:30后可领。")
		end
	)

	EventTriggerListener.Get(self.BigContent.parent.parent.gameObject).onDown = basefunc.handler(self, self.OnBeginDrag)
	EventTriggerListener.Get(self.BigContent.parent.parent.gameObject).onUp = basefunc.handler(self, self.OnEndDrag)
	
	self:InitMainUI()
	self:MyRefresh()

end

function C:OnBeginDrag()
	self.canMoveByAct=false
	--print("关闭")
end
function C:OnEndDrag()
	self.canMoveByAct=true
	--print("开启")
end

function C:MyRefresh()

end


function C:InitMainUI()
	for i = 1,#config do
		local temp_ui = {}
		local b = GameObject.Instantiate(self.LevelItem,self.BigContent)
		b.gameObject:SetActive(true)
		LuaHelper.GeneratingVar(b.transform,temp_ui)
		temp_ui.vipText_txt.text = config[i].level[1]
		self:InitAwardUI(config[i].award,temp_ui.AwardContent,i)
	end		
end

function C:InitAwardUI(award_config,obj,index)

	for i = 1,#award_config do
		local temp_ui = {}
		local b = GameObject.Instantiate(self.award_btn,obj.transform)
		b.gameObject:SetActive(true)
		LuaHelper.GeneratingVar(b.transform,temp_ui)
		temp_ui.award_txt.text = award_config[i].txt
		temp_ui.award_img.sprite = GetTexture(award_config[i].img)
		temp_ui.award_img:SetNativeSize()
		if index<5 then
			temp_ui.tishi.gameObject:SetActive(true)
			temp_ui.tishi_txt.text = award_config[i].tishi
		else
			temp_ui.tishi.gameObject:SetActive(false)
		end
		b.transform:GetComponent("Button").onClick:AddListener(
			function ()
			LittleTips.Create(award_config[i].tips)	
			end
		)
	end
end

function C:InitTranConfig()
	local data = {}
	data.min = 0
	data.max = item_width/2
	tras_config[#tras_config + 1] = data
	for i = 2,7 do
		local data = {}
		data.min = tras_config[i - 1].max
		data.max = data.min + item_width
		tras_config[#tras_config + 1] = data
	end
end


function C:OnDestroy()
	self:MyExit()
end


function C:GoNext()
	if self.MoveByBtn == false then
		self.MoveByBtn = true
		self.index = self.index + 1
	end
end

function C:GoLast()
	if self.MoveByBtn == false then
		self.MoveByBtn = true
		self.index = self.index - 1
	end
end

function C:InitMainTimer()
	self.MainTimer = Timer.New(
		function ()
			self:GoRightPos()
			self:IsEnableClick()
		end
	,0.016,-1)
	self.MainTimer:Start()
end

--去到正确位置
function C:GoRightPos()
	if self.canMoveByAct then
		if self.MoveByBtn then
			self:MoveAnim()
		elseif not self:IsClearRightPos() then
			local index = self:GetClearIndex()
			if index then				
				self:MoveAnim(index)
			end			
		end
	end
end

local clear_config = {}
--是否接近正确位置
function C:IsClearRightPos()
	for i = 1,#clear_config do
		if math.abs(self.BigContent.transform.localPosition.x) <= clear_config[i].max and math.abs(self.BigContent.transform.localPosition.x) >= clear_config[i].min then
			return true
		end
	end
	return false
end

function C:InitClearConfig()
	clear_config = {}
	for i = 1,#config do
		local data = {}
		data.min = (i - 1) * item_width - 11
		data.max = (i - 1) * item_width + 11
		clear_config[#clear_config + 1] = data
	end
end

function C:GetClearIndex()
	for i = 1,#tras_config do
		if math.abs(self.BigContent.transform.localPosition.x) <= tras_config[i].max and math.abs(self.BigContent.transform.localPosition.x ) >= tras_config[i].min then
			return i
		end
	end
end

function C:MoveAnim(index)
	local index = index or self.index
	local val = (index - 1) * item_width * -1
	if math.abs(self.BigContent.transform.localPosition.x - val) <= 80 then
		self.index = index
		local v = Vector2.New(val,self.BigContent.transform.localPosition.y)
		self.BigContent.transform.localPosition  = v
		self.MoveByBtn = false
	else
		local x 
		if val > self.BigContent.transform.localPosition.x  then
			x = self.BigContent.transform.localPosition.x + 35
		elseif val < self.BigContent.transform.localPosition.x  then
			x = self.BigContent.transform.localPosition.x - 35
		end
		local v = Vector2.New(x,self.BigContent.transform.localPosition.y)
		self.BigContent.transform.localPosition  = v
	end
end

function C:IsEnableClick()
	if self.index ~=1 then
		self.LeftButton_btn.gameObject:SetActive(true)
	else
		self.LeftButton_btn.gameObject:SetActive(false)
	end
	if self.index == #config then
		self.RightButton_btn.gameObject:SetActive(false)
	else
		self.RightButton_btn.gameObject:SetActive(true)
	end
end

function C:GetCurVIPLevel()
	self.vip_level = VIPManager.get_vip_level()
	for i=1,#vip_config do
		for j=1,#vip_config[i] do
		 	if vip_config[i][j] == self.vip_level then
		 		return i-1
		 	end
		end 
	end
	return  1
end