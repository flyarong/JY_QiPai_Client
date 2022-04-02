-- 创建时间:2018-08-07
-- 功能：输入编号，执行请求

local basefunc = require "Game.Common.basefunc"

ZJFJoin = basefunc.class()
ZJFJoin.name = "ZJFJoin"

local instance
local passLen = 6
-- _Type  1 : 通过密码直接进入房间，2：通过具体房间输入密码加入
function ZJFJoin.Create(room_no,_Type)
	instance = ZJFJoin.New(room_no,_Type)
	return instance
end
function ZJFJoin:ctor(room_no,_Type)
	local parent =  GameObject.Find("Canvas/LayerLv5").transform
	local obj = newObject(ZJFJoin.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	self._Type = _Type
	self.room_no = room_no
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
function ZJFJoin:InitUI()
	self.RoomCardTitleNode.gameObject:SetActive(false)
	self.MatchTitleNode.gameObject:SetActive(false)
	-- if self.funtype == ZJFJoin.FunType.FT_RoomCard then
	-- 	self.RoomCardTitleNode.gameObject:SetActive(true)
	-- elseif self.funtype == ZJFJoin.FunType.FT_Match then
	-- 	self.MatchTitleNode.gameObject:SetActive(true)
	-- else
	-- 	dump(self.funtype, "<color=red>这个类型不存在哦</color>")
	-- end
	self:UpdateTopNum()
end
function ZJFJoin:UpdateTopNum()
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
		if self._Type == 2 then 
			Network.SendRequest("zijianfang_join_room",{
				room_no = self.room_no,
				password = tonumber(pass)
			},"正在进入房间",function (data)
				dump(data,"<color=red>自建房00000</color>")
				if data.result == 0 then
					GameManager.GotoUI({gotoui = GameZJFModel.game_type2scence[data.game_type]})
				else
					HintPanel.ErrorMsg(data.result)
				end
			end)
		end
		if self._Type == 1 then 
			Network.SendRequest("zijianfang_join_room_by_password",{
				password = tonumber(pass)
			},"正在进入房间",function (data)
				if data.result == 0 then
					GameManager.GotoUI({gotoui = GameZJFModel.game_type2scence[data.game_type]})
				else
					HintPanel.ErrorMsg(data.result)
				end
			end)
		end
	end
end

-- 输入密码
function ZJFJoin:OnPassClick(obj)
	local num = tonumber(obj.name)
	print(num)
	if #self.PassNum < passLen then
		self.PassNum[#self.PassNum + 1] = num
		self:UpdateTopNum()
	end
end

function ZJFJoin:OnCloseClick(obj)
	self.PassNum = {}
	self:UpdateTopNum()
end
function ZJFJoin:OnDelClick(obj)
	table.remove(self.PassNum, #self.PassNum)
	self:UpdateTopNum()
end
-- 关闭
function ZJFJoin:OnBackClick()
    GameObject.Destroy(self.gameObject)
end
-- 锦标赛提示
function ZJFJoin:OnMatchHintClick()

end
