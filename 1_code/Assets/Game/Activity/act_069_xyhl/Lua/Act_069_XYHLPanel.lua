-- 创建时间:2021-11-09
-- Panel:Act_069_XYHLPanel
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

Act_069_XYHLPanel = basefunc.class()
local C = Act_069_XYHLPanel
C.name = "Act_069_XYHLPanel"
local M = Act_069_XYHLManager

local link_cfg = {
	jjddz_cpl = {
		image = "",
		link = "http://cwww.jyhd919.cn/webpages/commonDownload.html?platform=wqp&market_channel=wqp&pageType=wanqipai&category=1",
	},
	wqp_cpl = {
		image = "",
		link = "http://cwww.jyhd919.cn/webpages/commonDownload.html?platform=normal&market_channel=normal&pageType=normal&category=1",
	}
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
    self.lister["model_xyhl_get_data_msg"] = basefunc.handler(self,self.on_model_xyhl_get_data_msg)

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

function C:OnDestroy()
	self:MyExit()
end

function C:MyClose()
	self:MyExit()
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
	self:RefreshView()
end

function C:on_model_xyhl_get_data_msg()
	self:RefreshView()
end

function C:RefreshView()
	self.cplKey = M.GetCplKey()
	if self.cplKey then 
		dump(self.cplKey)
		self.cfg = link_cfg[self.cplKey]
		dump(self.cfg)
		self.recommend_img.sprite = GetTexture(self.cfg.image)
		self.download_btn.onClick:RemoveAllListeners()
		self.download_btn.onClick:AddListener(function()
			UnityEngine.Application.OpenURL(self.cfg.link)
		end)
	end
end

function C:MyRefresh()
end
