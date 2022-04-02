-- 创建时间:2020-04-02
-- Panel:ZJFHistoryPanel
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

ZJFHistoryPanel = basefunc.class()
local C = ZJFHistoryPanel
C.name = "ZJFHistoryPanel"

local type2img = {
	nor_ddz_nor = "zjf_imgf_jdddz",
	nor_ddz_lz = "zjf_imgf_lzddz",
	nor_ddz_er = "zjf_imgf_erddz",
	nor_ddz_boom = "zjf_imgf_zdddz",
}
function C.Create()
	return C.New()
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
	self.lister = {}
	self.lister["zijianfang_get_history_record_response"] = basefunc.handler(self,self.on_zijianfang_get_history_record_response)

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

-- .zijianfang_history_record {
-- 	id 0 : integer 		# id
-- 	room_no 1 : string 		# 房号
-- 	game_type 2 : string
-- 	room_owner 3 : string
-- 	end_time 4 :integer
-- 	player_infos 5 : *zijianfang_history_record_player_info 		# 玩家信息
-- }

-- ##房卡场的账单玩家数据项
-- .zijianfang_history_record_player_info {
-- 	id 0 : string 		# 玩家id
-- 	name 1 : string 		# 玩家名字
-- 	head_img_url 2 : string 		# 头像连接
-- 	score 3 : integer 		# 分数
-- }

-- zijianfang_get_history_record 3607 {
-- 	request {
-- 		page_index 0 : integer #
-- 	}
-- 	response {
-- 		result 0 : integer #
-- 		record 1 : zijianfang_history_record #纪录列表
-- 	}
-- }
function C:ctor()

	ExtPanel.ExtMsg(self)

	local parent = GameObject.Find("Canvas/LayerLv5").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	self:MakeLister()
	self:AddMsgListener()
	self.page_index = 1
	self.Scroll = self.SV.transform:GetComponent("ScrollRect")
	EventTriggerListener.Get(self.Scroll.gameObject).onEndDrag = basefunc.handler(self, self.ScrollOnEndDrag)
	Network.SendRequest("zijianfang_get_history_record",{page_index = self.page_index})
	self:InitUI()
end

function C:InitUI()
	self.close_btn.onClick:AddListener(
		function ()
			self:MyExit()
		end
	)
	self:MyRefresh()
end

function C:MyRefresh()
end

function C:ScrollOnEndDrag()
    local VNP = self.Scroll.verticalNormalizedPosition
    if VNP <= 0 then
		Network.SendRequest("zijianfang_get_history_record",{page_index = self.page_index})
    end
end

function C:on_zijianfang_get_history_record_response(_,data)
	dump(data,"<color=red>战绩数据00000</color>")
	local temp_ui = {}
	if data and data.result == 0 then
		if #data.record > 0 then 
			self.page_index = self.page_index + 1
		end
		for i = 1,#data.record do 
			local b = GameObject.Instantiate(self.item,self.Content)
			b.gameObject:SetActive(true)
			LuaHelper.GeneratingVar(b.transform,temp_ui)
			temp_ui.game_img.sprite = GetTexture(type2img[data.record[i].game_type])
			temp_ui.game_img:SetNativeSize()
			temp_ui.fangzhu_txt.text = "房主:"..self:GetFZName(data.record[i])
			temp_ui.time_txt.text = os.date("%Y年%m月%d日",data.record[i].end_time)
			self:InitPlayerItem(data.record[i].player_infos,temp_ui.node)
		end 
	end
end

function C:GetFZName(data)
	for i = 1,#data.player_infos do
		if data.room_owner ==  data.player_infos[i].id then
			return data.player_infos[i].name
		end
	end
end

function C:InitPlayerItem(data,parent)
	local temp_ui = {}
	for i = 1,#data do 
		local b = GameObject.Instantiate(self.player_info,parent)
		b.gameObject:SetActive(true)
		LuaHelper.GeneratingVar(b.transform,temp_ui)
		URLImageManager.UpdateHeadImage(data[i].head_img_url, temp_ui.head_img)
		temp_ui.id_txt.text = "ID:"..data[i].id
		temp_ui.name_txt.text = "昵称:"..data[i].name
		if data[i].score > 0 then 
			temp_ui.win_txt.gameObject:SetActive(true)
			temp_ui.lose_txt.gameObject:SetActive(false)
			temp_ui.win_txt.text = "+"..data[i].score
		else
			temp_ui.win_txt.gameObject:SetActive(false)
			temp_ui.lose_txt.gameObject:SetActive(true)
			temp_ui.lose_txt.text = data[i].score
			temp_ui.win.gameObject:SetActive(false)
		end
	end 
end