-- 创建时间:2018-06-06
local basefunc = require "Game.Common.basefunc"
VIPUPPanel = basefunc.class()
VIPUPPanel.name = "VIPUPPanel"

local instance
function VIPUPPanel.Create(data,parent)
	ExtendSoundManager.PlaySound(audio_config.game.bgm_hall_up_level.audio_name)
	if not instance then
		instance = VIPUPPanel.New(data,parent)
	else
		VIPUPPanel.Close()
		instance = VIPUPPanel.New(data,parent)
	end
	return instance
end

function VIPUPPanel.Close()
	if instance then
		instance.data = nil
		instance:RemoveListener()
		GameObject.Destroy(instance.transform.gameObject)
		instance = nil
	end
end

function VIPUPPanel:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function VIPUPPanel:MakeLister()
    self.lister = {}
    self.lister["ExitScene"] = basefunc.handler(self, self.OnExitScene)
end

function VIPUPPanel:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
end

function VIPUPPanel:ctor(data,parent)
	self.data = data
	parent = parent or GameObject.Find("Canvas/LayerLv5").transform
	self:MakeLister()
	self:AddMsgListener()
	local obj = newObject(VIPUPPanel.name, parent)
	self.transform = obj.transform
	LuaHelper.GeneratingVar(self.transform,self)
	self.AwardCellList = {}
	self:InitRect()
	DOTweenManager.OpenPopupUIAnim(self.transform)
end

function VIPUPPanel:InitRect()
	self.confirm_btn.onClick:AddListener(function(  )
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		VIPUPPanel.Close()
	end)
	local cur_cfg = VIPManager.get_vip_up_cfg(self.data.cur)
	self.cur_level_txt.text = self.data.cur
	self.cur_img.sprite = GetTexture(cur_cfg.icon)
	self.cur_img:SetNativeSize()
	local prev_cfg = VIPManager.get_vip_up_cfg(self.data.prev)
	if prev_cfg then
		self.prev_level_txt.text = self.data.prev
		self.prev_txt.text = prev_cfg.qx
		self.prev_img.sprite = GetTexture(prev_cfg.icon)
		self.prev_img:SetNativeSize()
		self.cur_txt.text = cur_cfg.qx
	else
		self.cur.transform.localPosition = Vector3.New(-30,0,0)
		self.prev.gameObject:SetActive(false)
		self.vip_change.gameObject:SetActive(false)
		self.cur_pre_txt.text = cur_cfg.qx
	end
end

function VIPUPPanel:OnExitScene()
	VIPUPPanel.Close()
end