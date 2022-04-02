-- 创建时间:2020-03-02
-- Panel:QFLBSharePanel
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

QFLBNoticePanel = basefunc.class()
local C = QFLBNoticePanel
C.name = "QFLBNoticePanel"

function C.Create(backcall,data)
	return C.New(backcall,data)
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
	if self.backcall then 
		self.backcall()
	end
	self:RemoveListener()
	destroy(self.gameObject)

	 
end

function C:ctor(backcall,data)

	ExtPanel.ExtMsg(self)

	local parent = GameObject.Find("Canvas/LayerLv3").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	self.backcall = backcall
	LuaHelper.GeneratingVar(self.transform, self)
	self.tips_txt.text = data.tips
	self.title_txt.text = data.title
	self._type = data._type
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	self.Go_btn.onClick:AddListener(
		function ()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
			if os.time() > 1585611000 and os.time() < 1586188799 and MainModel.UserInfo.ui_config_id == 1  then 
				if self._type == 2 then
					ActivityYearPanel.Create(nil, nil, { ID =  63}, true)
				else
					ActivityYearPanel.Create(nil, nil, { ID =  64}, true)
				end 
			else
				MoneyCenterQFLBPanel.Create()
			end 
		end	
	)
	self.close_btn.onClick:AddListener(
		function ()
			self:MyExit()
		end	
	)
	self:MyRefresh()
end

function C:MyRefresh()
end
