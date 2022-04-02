local basefunc = require "Game/Common/basefunc"

QHBSendPanel = basefunc.class()
local M = QHBSendPanel
M.name = "QHBSendPanel"

local instance
function M.Create()
    if instance then
        instance:MyExit()
    end
    instance = M.New()
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
    self.lister["model_qhb_hb_send_response"] = basefunc.handler(self, self.qhb_hb_send_response)
end

function M:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function M:MyExit()
    self:RemoveListener()
    GameObject.Destroy(self.gameObject)
    self = nil

	 
end

function M:ctor()

	ExtPanel.ExtMsg(self)

	local parent = GameObject.Find("Canvas/LayerLv2").transform
	local obj = newObject(M.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
    LuaHelper.GeneratingVar(self.transform,self)
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function M:InitUI()
    local cfg = QHBModel.cfg.send[QHBModel.data.game_id]
    if not cfg then
        LittleTips.CreateSP("未知错误，请重试")
        M.Close()
        return
    end
    --红包个数
    self.hb_num = 10
    self.hb_num_txt.text = self.hb_num
    --鲸币
    local xz_min = cfg.xz_count[1]
    local xz_max = cfg.xz_count[2]

    self.jb_num = xz_min
    self.jb_num_txt.text = StringHelper.ToCash(self.jb_num)
    for i,v in ipairs(cfg.add_count) do
        self["add" .. i .. "_jb_txt"].text = "+" .. StringHelper.ToCash(v)
        self["add" .. i .. "_jb_btn"].onClick:AddListener(function(  )
            if self.jb_num + v > xz_max then
                LittleTips.CreateSP(string.format("红包鲸币最多为%s" ,xz_max))
                self.jb_num = xz_max
                self.jb_num_txt.text = StringHelper.ToCash(self.jb_num)
                return
            end
            self.jb_num = self.jb_num + v
            self.jb_num_txt.text = StringHelper.ToCash(self.jb_num)
        end)
    end
    self.clear_jb_btn.onClick:AddListener(function(  )
        self.jb_num = 0
        self.jb_num_txt.text = ""
    end)

    self.boom_num = math.random(0,9)
    self.boom_num_txt.text = self.boom_num
    self.rem_boom_btn.onClick:AddListener(function(  )
        self.boom_num = self.boom_num - 1
        if self.boom_num < 0 then
            self.boom_num = 9
        end
        self.boom_num_txt.text = self.boom_num
    end)
    self.add_boom_btn.onClick:AddListener(function(  )
        self.boom_num = self.boom_num + 1
        if self.boom_num > 9 then
            self.boom_num = 0
        end
        self.boom_num_txt.text = self.boom_num
    end)

    self.back_btn.onClick:AddListener(function(  )
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        M.Close()
    end)

    self.hb_send_btn.onClick:AddListener(function()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        local hb_data = {}
        if not self.hb_num then
            LittleTips.CreateSP("请输入红包数量")
            return
        end
        if not self.jb_num or self.jb_num == 0 then
            LittleTips.CreateSP("请输入鲸币金额")
            return
        else
            if self.jb_num < xz_min then
                LittleTips.CreateSP(string.format("红包鲸币最少为%s" ,xz_min))
                return
            elseif self.jb_num > xz_max then
                LittleTips.CreateSP(string.format("红包鲸币最多为%s" ,xz_max))
                return
            end
            if self.jb_num > MainModel.UserInfo.jing_bi then
                HintPanel.Create(2,string.format( "您发红包还差%s，是否前往商城充值", StringHelper.ToCash(self.jb_num - MainModel.UserInfo.jing_bi)),function(  )
                    PayPanel.Create(GOODS_TYPE.jing_bi)
                end,nil,nil,nil,"HintPanelSP")
                return
            end
        end
        if not self.boom_num then
            LittleTips.CreateSP("请输入尾号雷点")
            return
        end
        hb_data.hb_count = self.hb_num
        hb_data.asset = {
            asset_type = "jing_bi",
            value = self.jb_num
        }
        hb_data.boom_num = self.boom_num
        QHBModel.request_qhb_hb_send(hb_data)
    end)
end

function M:qhb_hb_send_response()
    M.Close()
end