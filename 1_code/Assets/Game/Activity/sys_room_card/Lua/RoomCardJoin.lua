-- 创建时间:2018-08-07
-- 功能：输入编号，执行请求

local basefunc = require "Game.Common.basefunc"

RoomCardJoin = basefunc.class()
RoomCardJoin.FunType = 
{
	FT_RoomCard="FT_RoomCard",-- 房卡场
	FT_Match="FT_Match",-- 锦标赛
}
RoomCardJoin.name = "RoomCardJoin"

local instance
local passLen = 6
function RoomCardJoin.Create(funtype,game_id,signup_callback, parent)
	instance = RoomCardJoin.New(funtype,game_id,signup_callback, parent)
	return instance
end
function RoomCardJoin:ctor(funtype,game_id,signup_callback, parent)
	parent = parent or GameObject.Find("Canvas/LayerLv5").transform
	local obj = newObject(RoomCardJoin.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj

	self.funtype = funtype
	self.game_id = game_id
	self.signup_callback = signup_callback
	self.RoomCardTitleNode = tran:Find("BGImg2/RoomCardTitleNode")
	self.MatchTitleNode = tran:Find("BGImg2/MatchTitleNode")
	self.MatchHintButton = tran:Find("BGImg2/MatchTitleNode/MatchHintButton"):GetComponent("Button")
	EventTriggerListener.Get(self.MatchHintButton.gameObject).onClick = basefunc.handler(self, self.OnMatchHintClick)

	self.BackButton = tran:Find("BackButton")
	EventTriggerListener.Get(self.BackButton.gameObject).onClick = basefunc.handler(self, self.OnBackClick)


	self.PassNum = {}
	self.NumText = {}
	for i = 1, passLen do
		self.NumText[#self.NumText + 1] = tran:Find("Center/TopBG/NumText" .. i):GetComponent("Text")
	end
	for i = 1, 10 do
		local obj = tran:Find("Center/Button" .. (i-1))
		obj.gameObject.name = "" .. (i-1)
		EventTriggerListener.Get(obj.gameObject).onClick = basefunc.handler(self, self.OnPassClick)
	end
	self.ButtonClose = tran:Find("Center/ButtonClose")
	EventTriggerListener.Get(self.ButtonClose.gameObject).onClick = basefunc.handler(self, self.OnCloseClick)
	self.ButtonDel = tran:Find("Center/ButtonDel")
	EventTriggerListener.Get(self.ButtonDel.gameObject).onClick = basefunc.handler(self, self.OnDelClick)

	self:InitUI()
	DOTweenManager.OpenPopupUIAnim(self.transform)
end
function RoomCardJoin:InitUI()
	self.RoomCardTitleNode.gameObject:SetActive(false)
	self.MatchTitleNode.gameObject:SetActive(false)
	if self.funtype == RoomCardJoin.FunType.FT_RoomCard then
		self.RoomCardTitleNode.gameObject:SetActive(true)
	elseif self.funtype == RoomCardJoin.FunType.FT_Match then
		self.MatchTitleNode.gameObject:SetActive(true)
	else
		dump(self.funtype, "<color=red>这个类型不存在哦</color>")
	end
	self:UpdateTopNum()
end
function RoomCardJoin:UpdateTopNum()
	local pass = ""
	for i = 1, passLen do
		if i > #self.PassNum then
			self.NumText[i].text = ""
		else
			self.NumText[i].text = self.PassNum[i]
			pass = pass .. self.PassNum[i]
		end
	end
	if passLen == #self.PassNum then
		if self.funtype == RoomCardJoin.FunType.FT_RoomCard then
			Network.SendRequest("friendgame_join_room", {room_no=pass}, "请求加入房间", function(data)
				if data.result == 0 then
					self:OnBackClick()
					RoomCardModel.data.game_type = data.game_type
					RoomCardLogic.JoinRoomCardByData()
				elseif data.result == 1026 then
					self:OnCloseClick()
				    HintPanel.Create(
				        3,
				        "房卡数量不足，请前往购买",
				        function()
				            PayPanel.Create(GOODS_TYPE.item)
				        end
				    )				
				else
					self:OnCloseClick()
					HintPanel.ErrorMsg(data.result)
				end
			end)
		elseif self.funtype == RoomCardJoin.FunType.FT_Match then
			print("<color=red>发送加入锦标赛请求</color>")
			local join_id = tostring(pass)
			local id = tonumber(self.game_id)
			Network.SendRequest("nm_mg_signup", {id = id,join_id = join_id}, "请求加入房间", function(data)
				if data.result == 0 then
					self:OnBackClick()
					if self.signup_callback then
						self.signup_callback()
					end
				elseif data.result == 3601 then
					self:OnBackClick()
					HintPanel.Create(2,"您已经参加过该比赛了，更多福卡赛等你来，是否立刻前往福卡赛？",function()
						MatchHallDetailGMPanel.Close()
						MatchHallPanel.SetTgeByID(1)
					end)
				else
					self:OnCloseClick()
					HintPanel.ErrorMsg(data.result)
				end
			end)
		else
			dump(self.funtype, "<color=red>这个类型不存在哦</color>")
		end

	end
end

-- 输入密码
function RoomCardJoin:OnPassClick(obj)
	local num = tonumber(obj.name)
	print(num)
	if #self.PassNum < passLen then
		self.PassNum[#self.PassNum + 1] = num
		self:UpdateTopNum()
	end
end
function RoomCardJoin:OnCloseClick(obj)
	self.PassNum = {}
	self:UpdateTopNum()
end
function RoomCardJoin:OnDelClick(obj)
	table.remove(self.PassNum, #self.PassNum)
	self:UpdateTopNum()
end
-- 关闭
function RoomCardJoin:OnBackClick()
    GameObject.Destroy(self.gameObject)
end
-- 锦标赛提示
function RoomCardJoin:OnMatchHintClick()
	
end
