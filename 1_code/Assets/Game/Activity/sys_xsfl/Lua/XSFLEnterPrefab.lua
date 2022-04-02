-- 创建时间:2019-09-25
-- Panel:XSFLEnterPrefab
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

XSFLEnterPrefab = basefunc.class()
local C = XSFLEnterPrefab
C.name = "XSFLEnterPrefab"

local shopids = {
	[1] = {10016,10017,10018},
	[2] = {10019,10020,10021},
	[3] = {10022,10023,10024}
}

function C.Create(parent, cfg)
	return C.New(parent, cfg)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
	self.lister = {}
	for i = 1,#shopids do
		for j = 1,#shopids[i] do
			self.NumData[shopids[i][j]] = 0   
			self.lister["model_query_gift_bag_num_shopid_"..shopids[i][j]]=basefunc.handler(self,self.OnGetGiftNum)
		end 
	end
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	if self.update_time then
		self.update_time:Stop()
	end
	self.update_time = nil

	self:RemoveListener()
	destroy(self.gameObject)
end

function C:OnGetGiftNum(data)
	if not  IsEquals(self.gameObject) then 
		return 
	end 
	self.NumData[data.shopid]=data.count

end

function C:ctor(parent, cfg)
	self.config = cfg
	self.year_xsflcfg = SYSXSFLManager.GetConfig()

	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	self.NumData = {}
	self:MakeLister()
	self:AddMsgListener()
	self.transform.localPosition = Vector3.zero
	self.time_call_map = {}
	self.update_time = Timer.New(function ()
    	self:Update()
    end, 1, -1)
	self.update_time:Start()
	self:InitUI()
end

function C:InitUI()
	self.enter_btn = self.transform:GetComponent("Button")
	self.enter_btn.onClick:AddListener(function ()
    	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnEnterClick()
	end)
	self.time_call_map["check_shop_num"] = {time_call = self:GetCall(1), run_call = basefunc.handler(self, self.CheakNum)}
	self:MyRefresh()	
end

function C:MyRefresh()
	local cur_t = os.time()
	-- 判断是否活动过去了
	if cur_t >= self.year_xsflcfg.time[#self.year_xsflcfg.time].endtime or cur_t < self.year_xsflcfg.time[#self.year_xsflcfg.time].starttime then 
	    Event.Brocast("ui_button_state_change_msg")
	    self:OnDestroy()
		return
	end

	-- 活动时间到后执行
	local t = self.year_xsflcfg.time[#self.year_xsflcfg.time].endtime - cur_t
	if t < 1 then
		t = 1
	end
    self.time_call_map["activity_over"] = {time_call = self:GetCall(2), run_call = basefunc.handler(self, self.MyRefresh)}

	local index = 0
	for i = 1, #self.year_xsflcfg.time - 1 do
		if cur_t < self:GetDurTime(self.year_xsflcfg.time[i].endtime) and cur_t >= self:GetDurTime(self.year_xsflcfg.time[i].starttime) then
			index = i
			break
		end 
	end
	self.shopid_index = index	
	if index >= 1 then 
		local t =  self:GetDurTime(self.year_xsflcfg.time[index].endtime) - cur_t
		self.down_time = t
	    self.time_call_map["time"] = {time_call = self:GetCall(1), run_call = basefunc.handler(self, self.UpdateTime)}
	    self:UpdateTime(true)
		self.time_node.gameObject:SetActive(true)
		for i = 1, #shopids[index] do
			if MainModel.GetGiftShopStatusByID(shopids[index][i]) == 1 and self.NumData[shopids[index][i]] > 0  then
				YearXSFLpanel.IsGoodsHave = true
				self.LFL.gameObject:SetActive(YearXSFLpanel.IsGoodsHave)
				return
			end  
		end		
		self.LFL.gameObject:SetActive(false)
	else
		self.time_call_map["time"] = nil
		self.time_node.gameObject:SetActive(false)
		self.LFL.gameObject:SetActive(false)
	end
end
--返回当天的某一时间的unix时间戳
function C:GetDurTime(x)
	local t = os.time() + 8 * 60 * 60
	local f = math.floor(t / 86400)
	return f * 86400 + x - 8 * 60 * 60
end

function C:GetCall(t)
	local tt = t
	local cur = 0
	return function (st)
		cur = cur + st
		if cur >= tt then
			cur = cur - tt
			return true
		end
		return false
	end
end
function C:Update()
	for k,v in pairs(self.time_call_map) do
		if v.time_call(1) then
			v.run_call()
		end
	end
end
function C:UpdateTime(b)
	if not b then
		if self.down_time then
			self.down_time = self.down_time - 1
		end
		if self.down_time <= 0 then
			self:MyRefresh()
			return
		end
	end
	if not self.down_time then
		self.time_txt.text = "--:--"
	else
		self.time_txt.text = StringHelper.formatTimeDHMS(self.down_time)
	end
end

function C:OnEnterClick()
	YearXSFLpanel.Create()
end

function C:OnDestroy()
	self:MyExit()
end

function C:CheakNum()
	if not self.shopid_index or self.shopid_index < 1 then 
		return 
	end 	
	Network.SendRequest("query_gift_bag_num",{gift_bag_id=shopids[self.shopid_index][1]})
	Network.SendRequest("query_gift_bag_num",{gift_bag_id=shopids[self.shopid_index][2]})
	Network.SendRequest("query_gift_bag_num",{gift_bag_id=shopids[self.shopid_index][3]})
	self.time_call_map["check_shop_num"] = {time_call = self:GetCall(30), run_call = basefunc.handler(self, self.CheakNum)}
end

