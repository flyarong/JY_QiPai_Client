-- 创建时间:2020-03-23
-- Panel:ZJFDdzPrefab
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

ZJFDdzPrefab = basefunc.class()
local C = ZJFDdzPrefab
C.name = "ZJFDdzPrefab"
local df_tb = {}
local jrtj_tb = {}
local fz_pay = 200
local aa_pay = 50

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
	self.lister["zijianfang_create_room_response"] = basefunc.handler(self,self.on_zijianfang_create_room_response)
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

function C:ctor(parent)
	local parent = parent or GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	self:InitDf_tb()
	self:InitJRTJ_tb()
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	self.df_slider = self.dfSlider:GetComponent("Slider")
	self.jrtj_slider = self.jrtjSlider:GetComponent("Slider")
	self.df_slider.onValueChanged:AddListener(
		function (val)
			self.df_txt.text = StringHelper.ToCash(self:GetDiFen()).."鲸币"
		end
	)
	self.jrtj_slider.onValueChanged:AddListener(
		function (val)
			self.jrtj_txt.text = StringHelper.ToCash(self:GetJRTJText()).."鲸币"
		end
	)	
end

function C:InitUI()
	self.create_btn.onClick:AddListener(
		function ()
			Network.SendRequest("zijianfang_create_room",{
				{game_type= "nor_pdk_nor" ,
				game_cfg={{option="enter_limit",value =  self:GetJRTJText(),},
							{option="init_stake",value = self:GetDiFen(),},
							{option=self:GetBs(),value = 1,},
							{option="fangzhu_pay",value = self:GetFuWModel()},
							{option="yingfengding",value = self:GetIsYFD()},
							},
				password = 1}
			})
		end
	)
	self:MyRefresh()
end

function C:MyRefresh()
end

function C:on_zijianfang_create_room_response(_,data)
	dump(data,"<color=red>创建房间的返回</color>")
	if data.result == 0 then
		GameManager.GotoUI({gotoui = "game_DdzZJF"})
	else
		HintPanel.ErrorMsg(data.result)
	end
end

function C:InitDf_tb()
	for i = 1 , 100 do 
		df_tb[i] = i * 1000 
	end
end

function C:InitJRTJ_tb()
	jrtj_tb[1] = 0
	jrtj_tb[2] = 2
	jrtj_tb[3] = 5
	for i = 1, 20 do 
		jrtj_tb[i+3] = 10
	end
end
-- 底分 * 倍数
function C:GetEnterLimit()
	return jrtj_tb[self.jrtj_slider.value] * self:GetDiFen()
end

function C:GetDiFen()
	return df_tb[self.df_slider.value] * 1000
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
		return 1
	else
		return 0
	end
end
--倍数
function C:GetBs()
	local beishu = {"feng_ding_32b","feng_ding_64b","feng_ding_128b","feng_ding_256b"}
	for i = 1,4 do 
		if self["bs"..i.."_tge"].isOn == true then 
			return beishu[i]
		end 
	end
end
-- 总的进入条件
function C:GetJRTJText()
	--AA制基础房费
	local base = aa_pay + 10000
	-- 房主付款 基础房费
	if self:GetFuWModel() == 1 then 
		base = 10000
	end

	return self:GetEnterLimit() + base
end
-- 赢封顶
function C:GetIsYFD()
	if self.tx_tge.isOn == true then 
		return 1
	else
		return 0
	end
end