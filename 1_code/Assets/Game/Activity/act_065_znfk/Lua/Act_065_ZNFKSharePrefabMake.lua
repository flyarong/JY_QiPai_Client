-- 创建时间:2020-08-13
-- Panel:Act_065_ZNFKSharePrefabMake
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
 -- 取消按钮音效
 -- ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
 -- 确认按钮音效
 -- ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
 --]]

local basefunc = require "Game/Common/basefunc"

Act_065_ZNFKSharePrefabMake = basefunc.class()
local C = Act_065_ZNFKSharePrefabMake
C.name = "Act_065_ZNFKSharePrefabMake"

local M = Act_065_ZNFKManager

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

function C:ctor()
	ExtPanel.ExtMsg(self)
	local parent = GameObject.Find("Canvas/LayerLv5").transform
	local obj = newObject("ZNQ_3rd_ShareImage", parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	local data = Act_065_ZNFKManager.GetData()
	self.t1_txt.text = os.date("%Y年%m月%d日",data.most_money_time).."\n历史拥有最大财富".."\n"..StringHelper.ToCash(data.most_money)
	self.t2_txt.text = os.date("%Y年%m月%d日",data.once_win_most_time).."\n游戏中单笔赢得".."\n"..StringHelper.ToCash(data.once_win_most_win_money)
	self.t3_txt.text = M.gameName2Imgs[data.once_win_most_game_name][1]
	self.t4_img.sprite = GetTexture(M.gameName2Imgs[data.once_win_most_game_name][2])
	self.t5_img.sprite = GetTexture(M.gameName2Imgs[data.once_win_most_game_name][3])
	self.t4_img:SetNativeSize()
	self.t5_img:SetNativeSize()
	self:MyRefresh()
end

function C:MyRefresh()

end
