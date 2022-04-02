local basefunc = require "Game/Common/basefunc"

QHBAwardPanel = basefunc.class()
local M = QHBAwardPanel
M.name = "QHBAwardPanel"

local instance
function M.Create(hb_data)
    if instance then
        instance:MyExit()
    end
    instance = M.New(hb_data)
	return instance
end
function M.Close()
	if instance then
		instance:MyExit()
	end
	instance = nil
end

function M:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function M:MakeLister()
    self.lister = {}
end

function M:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function M:MyExit()
    if self.timer then
        self.timer:Stop()
    end
    self.timer = nil
    self:RemoveListener()
    GameObject.Destroy(self.gameObject)
    self = nil

	 
end

function M:ctor(hb_data)

	ExtPanel.ExtMsg(self)

    self.hb_data = hb_data
	local parent = GameObject.Find("Canvas/LayerLv2").transform
	local obj = newObject(M.name, parent)
	local tran = obj.transform
	self.transform = tran
    self.gameObject = obj
    LuaHelper.GeneratingVar(self.transform, self)
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function M:InitUI()
    self.back_btn.onClick:AddListener(function(  )
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        M.Close()
    end)
    if self.hb_data.boom_value then
        self.boom_num_txt.text = self.hb_data.boom_value
    end
    self.hb_num_txt.text = self.hb_data.asset.value
    self.tx.gameObject:SetActive(true)
    ExtendSoundManager.PlaySound(audio_config.qhb.bgm_qhb_ying.audio_name)
    local cd = 0
    --没有暴雷
    self.timer = Timer.New(function ()
        cd = cd + 1
        if cd == 2 then
            if self.hb_data.boom ~= 1 then
                self.hb.gameObject:SetActive(true)
                DOTweenManager.OpenPopupUIAnim(self.hb.transform,function(  )
                    self.back_btn.gameObject:SetActive(true)
                end)
            elseif self.hb_data.boom == 1 then
                self.hb.gameObject:SetActive(true)
                DOTweenManager.OpenPopupUIAnim(self.hb.transform)
            end
        elseif cd == 3 then
            if self.hb_data.boom ~= 1 then
                if self.timer then
                    self.timer:Stop()
                    self.timer = nil
                end
            elseif self.hb_data.boom == 1 then
                self.hb.gameObject:SetActive(false)
                self.boom.gameObject:SetActive(true)
                if QHBModel.IsSysScene() then
                    local ani = self.boom.transform:GetComponent("Animator")
                    if IsEquals(ani) then
                        ani:Play("QHBAwardPanel_boom_sys")
                    end
                else
                    if self.hb_data.send_player and self.hb_data.send_player.id == MainModel.UserInfo.user_id then
                        local ani = self.boom.transform:GetComponent("Animator")
                        if IsEquals(ani) then
                            ani:Play("QHBAwardPanel_boom_me")
                        end
                    end
                end
            end
        elseif cd == 4 then
            self.back_btn.gameObject:SetActive(true)
            ExtendSoundManager.PlaySound(audio_config.qhb.bgm_qhb_shu.audio_name)
        elseif cd >= 10 then
            if self.timer then
                self.timer:Stop()
                self.timer = nil
            end
        end
    end,1,-1,true)
    self.timer:Start()
    self.timer:SetStopCallBack(function (  )
        self.back_btn.gameObject:SetActive(true)
    end)
end