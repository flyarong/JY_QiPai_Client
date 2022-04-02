-- 创建时间:2019-08-29
-- Panel:GameMoneyCenterTGPHBPanel
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

GameMoneyCenterTGPHBPanel = basefunc.class()
local C = GameMoneyCenterTGPHBPanel
C.name = "GameMoneyCenterTGPHBPanel"

local award={
	500,200,100,50,50,50,20,20,20,20,20
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
	self.lister["query_rank_base_info_response"] = basefunc.handler(self,self.onMyInfoGet)
	self.lister["query_rank_data_response"] = basefunc.handler(self,self.onInfoGet)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end


function C:onMyInfoGet(_,data)
	dump(data,"<color=red>----推广员自身数据----------</color>")	
	if data and data.result == 0  then 
		local str = "未上榜"
		local str2 = "--"
		if data.rank ~= -1 then
			str=data.rank 
			if data.rank<=10 and data.rank >	0 then 
				str2=award[data.rank]
			end 
		end 				 
		self.my_rank_txt.text = str
		self.my_num_txt.text=data.score 
		self.my_name_txt.text=MainModel.UserInfo.name
		self.my_award_txt.text=str2
	else
		LittleTips.Create("暂无新数据",{x = 160,y =150})
	end 
end

function C:onInfoGet(_,data)	
	dump(data,"<color=red>----推广员排行榜----------</color>")
	if data and data.result == 0  then 
		for i = 1, #data.rank_data do
			local b = GameObject.Instantiate(self.info,self.content)
			LuaHelper.GeneratingVar(b.transform, self)
			self.rank_txt.text=data.rank_data[i].rank
			if data.rank_data[i].rank == 1 then
				self.hg_img.gameObject:SetActive(true)
				self.hg_img.sprite = GetTexture("localpop_icon_1")
			elseif data.rank_data[i].rank == 2 then
				self.hg_img.gameObject:SetActive(true)
				self.hg_img.sprite = GetTexture("localpop_icon_2")
			elseif data.rank_data[i].rank == 3 then
				self.hg_img.gameObject:SetActive(true)
				self.hg_img.sprite = GetTexture("localpop_icon_3")
			end
			if data.rank_data[i].rank%2 == 1 then
				self.bg_img.sprite = GetTexture("sczd_tgzq_bg3")
			else
				self.bg_img.sprite = GetTexture("sczd_tgzq_bg2")
			end
			self.num_txt.text=data.rank_data[i].score 
			self.name_txt.text=data.rank_data[i].name 
			self.award_txt.text=award[i]
			b.gameObject:SetActive(true)
			if i == 10 then return end 
		end
	else
		LittleTips.Create("暂无新数据",{x = 160,y =150})
	end 	
end




function C:MyExit()
	self:RemoveListener()
	destroy(self.gameObject)

	 
end

function C:MyClose()
	self:MyExit()
end

function C:ctor(parent)

	ExtPanel.ExtMsg(self)

	local parent = parent or  GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.transform.localPosition = Vector3.New(self.transform.localPosition.x,-50,self.transform.localPosition.z)
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	Network.SendRequest("query_rank_base_info",{rank_type="yqshl_040_rank"})
	Network.SendRequest("query_rank_data",{rank_type="yqshl_040_rank",page_index=1})
end

function C:InitUI()
	self.help_btn.onClick:AddListener(
		function ()
			self:onHelpClick()
		end
	)
	self.GoShare_btn.onClick:AddListener(
		function ()
			self:onGoShareClick()
		end
	)
	self:MyRefresh()
end
--当帮助按钮按下
function C:onHelpClick()
	self.introduce=self.transform:Find("Introduce"):GetComponent("Text")
    IllustratePanel.Create({self.introduce}, GameObject.Find("Canvas/LayerLv5").transform)
end

function C:MyRefresh()
end
--跳转到推广二维码
function C:onGoShareClick()
	GameMoneyCenterPanel.GotoPanel("tgewm")
end
