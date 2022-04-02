-- 创建时间:2020-03-23
-- Panel:ZJFMj3DPrefab
--[[*      ┌─┐       ┌─┐
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

ZJFMj3DPrefab = basefunc.class()
local C = ZJFMj3DPrefab
C.name = "ZJFMj3DPrefab"
local df_tb = {}
local jrtj_tb = {}
local fz_pay = 200
local aa_pay = 50

local xishu = 0.01
local enter_base = 10000
local types = {
    "nor_mj_xzdd_er_7",
    "nor_mj_xzdd",            
}

function C.Create(parent, type_index)
    return C.New(parent, type_index)
end

function C:AddMsgListener()
    for proto_name, func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["ExitScene"] = basefunc.handler(self, self.MyExit)
    self.lister["zijianfang_create_room_response"] = basefunc.handler(self, self.on_zijianfang_create_room_response)
end

function C:RemoveListener()
    for proto_name, func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
    self:RemoveListener()
    destroy(self.gameObject)
end

function C:ctor(parent,type_index)
	ExtPanel.ExtMsg(self)
	local parent = parent or GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	self.type_index = type_index
	LuaHelper.GeneratingVar(self.transform, self)
	self:InitDf_tb()
	self:InitJRTJ_tb()
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	self.person = type_index == 1 and 2 or 4
	xishu = GameZJFModel.get_mj_enter_xishu_by_type(types[type_index])
	enter_base = GameZJFModel.get_mj_enter_base_by_type(types[type_index])
	self.tips_txt.text = "保底"..StringHelper.ToCash(enter_base) .."鲸币不会被消耗（服务费和输赢）"
	self.df_slider = self.dfSlider:GetComponent("Slider")
	self.jrtj_slider = self.jrtjSlider:GetComponent("Slider")
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
	self.wf_txt.text = GameZJFModel.get_mj_enter_wanfa_by_type(types[type_index])
	for i = 1 ,4 do
		self["bs"..i.."_txt"].text = GameZJFModel.fengding_bs_mj_int[i].."番"
	end
end

function C:InitUI()
	self.create_btn.onClick:AddListener(
		function ()
			if MainModel.UserInfo.jing_bi >= self:GetJRTJText() and MainModel.UserInfo.jing_bi >= self:GetDiFen() * GameZJFModel.get_mj_create_xishu_by_type(types[self.type_index]) then 
				Network.SendRequest("zijianfang_create_room",
					{
						game_type= types[self.type_index],
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
	self:MyRefresh()
end

function C:MyRefresh()
end

function C:on_zijianfang_create_room_response(_, data)
    dump(data, "<color=red>创建房间的返回</color>")
    if data.result == 0 then
		GameManager.GotoUI({gotoui = "game_MJXzZJF3D"})
    else
        HintPanel.ErrorMsg(data.result)
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
	local beishu = GameZJFModel.fengding_bs_mj_str
	for i = 1,4 do 
		if self["bs"..i.."_tge"].isOn == true then 
			return beishu[i]
		end 
	end
end

--倍数
function C:GetIntBs()
	local beishu = GameZJFModel.fengding_bs_mj_int
	for i = 1,4 do 
		if self["bs"..i.."_tge"].isOn == true then 
			return 2^beishu[i]
		end 
	end
end

-- 总的进入条件（房主看到的和非房主看到的不一致）
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
