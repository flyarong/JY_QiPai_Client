-- 创建时间:2020-04-20
-- Panel:Act_010_WBGJPanel
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

Act_010_WBGJPanel = basefunc.class()
local C = Act_010_WBGJPanel
C.name = "Act_010_WBGJPanel"
local M = Act_010_WBGJManager
local goods_ids = {22,23,24,25}
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
	self.lister["AssetChange"] = basefunc.handler(self, self.OnAssetChange)
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

	ExtPanel.ExtMsg(self)

	local parent = parent or GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	local temp_ui = {}
	self.curr_txt.text = "x"..GameItemModel.GetItemCount("prop_shovel")
	for i = 1,#M.Base_UI_Data do
		local b = GameObject.Instantiate(self.item,self.node)
		b.gameObject:SetActive(true)
		LuaHelper.GeneratingVar(b.transform,temp_ui)
		local data= GameItemModel.GetItemToKey(M.Base_UI_Data[i]._type)
		temp_ui.award_img.sprite = GetTexture(M.Base_UI_Data[i].image)
		temp_ui.count_txt.text = "x"..StringHelper.ToCash(M.Base_UI_Data[i].count)	
		temp_ui.button_txt.text = "消耗"..StringHelper.ToCash(M.Base_UI_Data[i].need)..data.name
		temp_ui.get_btn.onClick:AddListener(
			function()
				local base = GameItemModel.GetItemCount(M.Base_UI_Data[i]._type)
				if M.Base_UI_Data[i]._type == "shop_gold_sum" then
					base = base / 100
				end
				if base >= M.Base_UI_Data[i].need then
					--发请求
					Network.SendRequest("pay_exchange_goods",
					{goods_type = "prop_shovel", goods_id = goods_ids[i]},"购买道具",function (data)
						if data.result ~= 0 then
							HintPanel.ErrorMsg(data.result)
						end
					end)
				else
					HintPanel.Create(1,"您的"..data.name.."不足",function()
						PayPanel.Create(GOODS_TYPE.jing_bi, "jing_bi")
					end)
				end
			end
		)
	end
	self:MyRefresh()
end

function C:MyRefresh()
	
end

function C:OnDestroy(  )
	self:MyExit()
end

function C:OnAssetChange()
	self.curr_txt.text = "x"..GameItemModel.GetItemCount("prop_shovel")
end