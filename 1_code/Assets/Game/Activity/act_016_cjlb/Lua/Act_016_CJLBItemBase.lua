-- 创建时间:2020-06-02
-- Panel:Act_016_CJLBItemBase
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

Act_016_CJLBItemBase = basefunc.class()
local C = Act_016_CJLBItemBase
C.name = "Act_016_CJLBItemBase"
local M = Act_016_CJLBManager

function C.Create(parent,index,ids)
	return C.New(parent,index,ids)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["ExitScene"]=basefunc.handler(self,self.MyExit)
    self.lister["CJLB_itembase_change_msg"] = basefunc.handler(self,self.isAlreadyGet)
    self.lister["CJLB_on_box_exchange_response"] = basefunc.handler(self,self.isAlreadyGet)
end

function C:OnDestroy()
	self:MyExit()
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

function C:ctor(parent,index,ids)
	self.ids = ids
	local parent = parent or GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	local config = M.GetConfig()
	self.config = config[index]

	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	if self.ids == 6 then--头奖
		self.best_img.gameObject:SetActive(true)
	else
		self.best_img.gameObject:SetActive(false)
	end
	self.award_img.sprite = GetTexture(self.config.award_images[self.ids])
	self.award_txt.text = self.config.award_descs[self.ids].."鲸币"

end

function C:MyRefresh()

end

--是否已经领取过
function C:isAlreadyGet(data,ID)
	--dump(data,"<color=green>+++++++++++ids++++++++++</color>")
	--dump(ID,"<color=red>++++++++++++++ID+++++++++++++++</color>")
	local ids = data[ID].exchange_record
	for i=1,#ids do
		if ids[i].id == self.ids then
			self.already_img.gameObject:SetActive(true)
		end
	end
end


