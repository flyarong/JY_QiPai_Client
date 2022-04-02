-- 创建时间:2020-03-23
-- Panel:MjxzZJFChangePrefab
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

MjxzZJFChangePrefab = basefunc.class()
local C = MjxzZJFChangePrefab
C.name = "MjxzZJFChangePrefab"
local df_tb = {}
local jrtj_tb = {}
local fz_pay = 200
local aa_pay = 50

local xishu = 0.01
local enter_base = 10000
local base_k_v = {
	"enter_limit"
}

local types = {
	"nor_mj_xzdd_er_7",
	"nor_mj_xzdd",
}

function C.Create(parent,_type)
	return C.New(parent,_type)
end

function C:AddMsgListener()
	for proto_name,func in pairs(self.lister) do
		Event.AddListener(proto_name, func)
	end
end

function C:MakeLister()
	self.lister = {}
	self.lister["zijianfang_begin_rule_alter_vote_response"] = basefunc.handler(self,self.on_zijianfang_begin_rule_alter_vote_response)
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

function C:ctor(parent,_type)
	local parent = parent or GameObject.Find("Canvas/LayerLv4").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	self._type = _type
	self.person = _type == "nor_mj_xzdd_er_7" and 2 or 4
	LuaHelper.GeneratingVar(self.transform, self)
	self:InitDf_tb()
	self:InitJRTJ_tb()
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	xishu = GameZJFModel.get_mj_enter_xishu_by_type(_type)
	enter_base = GameZJFModel.get_mj_enter_base_by_type(_type)
	self.df_slider = self.dfSlider:GetComponent("Slider")
	self.jrtj_slider = self.jrtjSlider:GetComponent("Slider")
	self.tips_txt.text = "保底"..StringHelper.ToCash(enter_base) .."鲸币不会被消耗（服务费和输赢）"
	self:RefreshText()
	self.df_slider.onValueChanged:AddListener(
		function (val)
			self:RefreshText()
		end
	)
	self.jrtj_slider.onValueChanged:AddListener(
		function (val)
			self:RefreshText()
		end
	)
	self.fwq1_tge.onValueChanged:AddListener(
		function (val)	
			self:RefreshText()
		end
	)
	self.fwq2_tge.onValueChanged:AddListener(
		function (val)
			self:RefreshText()
		end
	)
	self.bs1_tge.onValueChanged:AddListener(
		function (val)
			self:RefreshText()
		end
	)
	self.bs2_tge.onValueChanged:AddListener(
		function (val)
			self:RefreshText()
		end
	)
	self.bs3_tge.onValueChanged:AddListener(
		function (val)
			self:RefreshText()
		end
	)
	self.bs4_tge.onValueChanged:AddListener(
		function (val)
			self:RefreshText()
		end
	)
	self:SetUI()
	for i = 1 ,4 do
		self["bs"..i.."_txt"].text = GameZJFModel.fengding_bs_ddz_int[i].."倍"
	end
end

function C:InitUI()
	self.change_btn.onClick:AddListener(
		function ()
			if MainModel.UserInfo.jing_bi >= self:GetJRTJText() and MainModel.UserInfo.jing_bi >= self:GetDiFen() * GameZJFModel.get_ddz_create_xishu_by_type(self._type) then 
				Network.SendRequest("zijianfang_begin_rule_alter_vote",
					{
						game_cfg={
							{ option = "enter_limit", value = self:GetEnterLimitRate(),},
							{ option = "init_stake", value = self:GetDiFen(),},
							{ option = self:GetBs(), value = 1,},
							{ option = self:GetFuWModel(), value = 1 },
							--{ option = "zimo_jiafan", value = 1 },
							{ option = "yingfengding", value = self:GetIsYFD() },
						},
						password = self:GetIsOpenModel()
					}, "")
					
			else
				Event.Brocast("show_gift_panel")
			end 
		end
	)
	self.close_btn.onClick:AddListener(function ()
		self:MyExit()
	end)
	self:MyRefresh()
end

function C:MyRefresh()
end

function C:on_zijianfang_begin_rule_alter_vote_response(_,data)
	dump(data,"<color=red>修改房间的返回</color>")
	if data.result ~= 0 then
		HintPanel.ErrorMsg(data.result)
	else
		self:MyExit()
		MjXzFKClearing.Close()
		MjXzFKModel.on_js_xyj()
		Network.SendRequest("zijianfang_req_info_by_send", {type = "all"}, "",function()
			
		end)
	end
end

function C:InitDf_tb()
	for i = 1 , 20 do 
		df_tb[i] = i
	end
end

function C:InitJRTJ_tb()
	jrtj_tb[1] = 0
	for i = 1, 10 do 
		jrtj_tb[i+1] = i
	end
end
-- 底分 * 倍数
function C:GetEnterLimit()
	return jrtj_tb[self.jrtj_slider.value + 1] * self:GetDiFen()
end

-- 进入条件 倍数
function C:GetEnterLimitRate()
	return jrtj_tb[self.jrtj_slider.value + 1] 
end

function C:GetDiFen()
	return df_tb[self.df_slider.value + 1] * 1000
end
--房间类型 1:有密码 0:没有密码
function C:GetIsOpenModel()
	if self.fjlx1_tge.isOn == true then 
		return 0
	else
		return 1
	end
end
-- 服务费模式 1:房主付费 0：平摊付费
function C:GetFuWModel()
	if self.fwq1_tge.isOn == true then 
		return "fangzhu_pay"
	else
		return "aa_pay"
	end
end
--倍数
function C:GetBs()
	local beishu = GameZJFModel.fengding_bs_ddz_str
	for i = 1,4 do 
		if self["bs"..i.."_tge"].isOn == true then 
			return beishu[i]
		end 
	end
end

--倍数
function C:GetIntBs()
	local beishu = GameZJFModel.fengding_bs_ddz_int
	for i = 1,4 do 
		if self["bs"..i.."_tge"].isOn == true then 
			return beishu[i]
		end 
	end
end
-- 总的进入条件
function C:GetJRTJText()
	--AA制基础房费
	local aa_pay = self:GetDiFen() * xishu
	local base = aa_pay + enter_base
	-- 房主付款 基础房费
	if self:GetFuWModel() == "fangzhu_pay" then 
		base = enter_base + aa_pay * self.person
	end

	return self:GetEnterLimit() * self:GetIntBs() + base
end
-- 赢封顶
function C:GetIsYFD()
	if self.tx_tge.isOn == true then 
		return 1
	else
		return 0
	end
end

function C:RefreshText()
	self.df_txt.text = StringHelper.ToCash(self:GetDiFen()).."鲸币"
	self.jrtj_txt.text = StringHelper.ToCash(self:GetJRTJText()).."鲸币"
	self.fzb_txt.text = "房主包（<color=#F87935FF>"..StringHelper.ToCash(self:GetDiFen() * xishu * self.person).."鲸币</color>".."/局）"
	self.aa_txt.text = "AA制（<color=#F87935FF>"..StringHelper.ToCash(self:GetDiFen() * xishu).."鲸币</color>".."/局/人）"
end

function C:OldRoomData()
	
end

function C:SetUI()
	local beishu = GameZJFModel.fengding_bs_ddz_str
	self.tx_tge.isOn = MjXzFKModel.get_ori_game_cfg_byOption("yingfengding") == 1
	self.jrtj_slider.value = self:getJrtj_ui_value()
	self.df_slider.value = self:getDf_ui_value()
	for i = 1,4 do 
		if MjXzFKModel.get_ori_game_cfg_byOption(beishu[i]) == 1 then 
			self["bs"..i.."_tge"].isOn = true
		end
	end
	self.fwq1_tge.isOn = MjXzFKModel.IsFZPaY()
	self.fwq2_tge.isOn = not MjXzFKModel.IsFZPaY()
end


function C:getJrtj_ui_value()
	local  v = MjXzFKModel.get_ori_game_cfg_byOption("enter_limit")
	dump(v,"进入条件的倍数----")
	for i = 1,#jrtj_tb do 
		if jrtj_tb[i] == v then
			dump(i)
			return i - 1
		end
	end
end


function C:getDf_ui_value()
	local v = MjXzFKModel.get_ori_game_cfg_byOption("init_stake")
	dump(v,"底分-------")
	for i = 1,#df_tb do 
		if df_tb[i] * 1000 == v then 
			dump(i)
			return i - 1
		end
	end
end
