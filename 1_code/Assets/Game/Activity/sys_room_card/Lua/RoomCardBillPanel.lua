-- 创建时间:2018-07-14

local basefunc = require "Game.Common.basefunc"

RoomCardBillPanel = basefunc.class()

RoomCardBillPanel.name = "RoomCardBillPanel"


local instance = nil
local lister

function RoomCardBillPanel:AddLister()
    lister={}
    lister["model_friendgame_get_all_history_record_response"] = basefunc.handler(self,self.model_friendgame_get_all_history_record_response)
    for msg,cbk in pairs(lister) do
        Event.AddListener(msg, cbk)
    end
end

function RoomCardBillPanel:RemoveLister()
    for msg,cbk in pairs(lister) do
        Event.RemoveListener(msg, cbk)
    end
    lister=nil
end

function RoomCardBillPanel.Show()
	return RoomCardBillPanel.Create()
end
function RoomCardBillPanel.Create()
	instance = RoomCardBillPanel.New()
	return instance
end
function RoomCardBillPanel:ctor()

	ExtPanel.ExtMsg(self)

	local parent = GameObject.Find("Canvas/LayerLv5").transform
	
	local obj = newObject(RoomCardBillPanel.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	self:AddLister()

	self.back_btn.onClick:AddListener(function (val)
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:OnBackClick()
	end)
	self.RoomCardBillInfoItem = newObject("RoomCardBillInfoItem",self.transform)
	self.RoomCardBillInfoItem.gameObject:SetActive(false)
	RoomCardModel.InitRoomCardBill()
end

function RoomCardBillPanel:MyExit()
	destroy(self.gameObject)
	self:RemoveLister()
end
function RoomCardBillPanel:OnBackClick()
	self:MyExit()
	instance = nil
end

--[[初始化数据]]
function RoomCardBillPanel:model_friendgame_get_all_history_record_response(data)
	local histroy_record = data
	dump(histroy_record, "<color=yellow>账单数据</color>")
	if histroy_record then
		destroyChildren(self.content.transform)
		for i,v in ipairs(histroy_record) do
			local go = GameObject.Instantiate(self.RoomCardBillInfoItem.gameObject, self.content)
			local gameGO = go.transform:Find("GameImg").gameObject
			local gameGOTable = {}
			LuaHelper.GeneratingVar(gameGO.transform, gameGOTable)
			gameGOTable.game_type_txt.text = v.game_name
			gameGOTable.date_txt.text =RoomCardBillPanel.GetConvertTime(v.time)
			gameGOTable.id_txt.text = v.room_no
			local max_score = nil
			for k,v_palyer in ipairs(v.player_infos) do
				if not max_score then
					max_score = v_palyer.score
				end
				if v_palyer.score > max_score then
					max_score = v_palyer.score
				end
			end
			for k,v_palyer in ipairs(v.player_infos) do
				local playerGO = go.transform:Find("PlayersImg/player" .. k).gameObject
				local playerGOTable = {}
				LuaHelper.GeneratingVar(playerGO.transform, playerGOTable)
				URLImageManager.UpdateHeadImage(v_palyer.head_img_url, playerGOTable.head_img)
				playerGOTable.name_txt.text = v_palyer.name
				playerGOTable.id_txt.text = v_palyer.id
				if v_palyer.score == max_score then
					playerGOTable.win_score_txt.text = v_palyer.score
					playerGOTable.win_score_txt.gameObject:SetActive(true)
					playerGOTable.win_img.gameObject:SetActive(true)
					playerGOTable.score_txt.gameObject:SetActive(false)
				else
					playerGOTable.score_txt.text = v_palyer.score
				end 

				playerGO.gameObject:SetActive(true)
			end
			go.gameObject:SetActive(true)
			go.transform:SetAsFirstSibling()
		end
	else
		self.no_bill.gameObject:SetActive(true)
	end
end

-- 时间显示转换
function RoomCardBillPanel.GetConvertTime(val)
    return os.date("%Y-%m-%d %H:%M", val)
end