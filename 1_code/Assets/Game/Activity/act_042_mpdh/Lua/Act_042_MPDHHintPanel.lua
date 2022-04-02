local basefunc = require "Game/Common/basefunc"
Act_042_MPDHHintPanel = basefunc.class()
local M = Act_042_MPDHHintPanel
M.name = "Act_042_MPDHHintPanel"

local Mgr = Act_042_MPDHManager
function M.Create(cfg)
    return M.New(cfg)
end

function M:AddMsgListener()
    for proto_name, func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function M:MakeLister()
    self.lister = {}
    self.lister["act_042_mpdh_close"] = basefunc.handler(self, self.MyExit)
end

function M:RemoveListener()
    for proto_name, func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function M:MyExit()
    self:RemoveListener()
    destroy(self.gameObject)
end

function M:ctor(cfg)
    ExtPanel.ExtMsg(self)
    local parent = GameObject.Find("Canvas/LayerLv5").transform
    local obj = newObject(M.name, parent)
    local tran = obj.transform
    self.transform = tran
    self.gameObject = obj
    LuaHelper.GeneratingVar(self.transform, self)
    self.cfg = cfg
    self:MakeLister()
    self:AddMsgListener()
    self:InitUI()
end

function M:InitUI()
    local ui = self.transform:Find("ComMatchBG/@title_img"):GetComponent("Image")
    ui.sprite = GetTexture("dh_imgf_dh")
    self.close_btn.onClick:AddListener(function(  )
        self:MyExit()
    end)
    self.no_btn.onClick:AddListener(function(  )
        self:MyExit()
    end)
    self.hint_tge.onValueChanged:AddListener(function(val)
        if val then
            PlayerPrefs.SetString(Mgr.hint_key, os.time())
        else
            PlayerPrefs.DeleteKey(Mgr.hint_key)
        end
    end)
    if self.cfg then
        self.hint_info_txt.text = "是否消耗" .. StringHelper.ToCash(self.cfg.use_count / 100) .. "福卡兑换1张" .. self.cfg.ui_title .. "?"
        self.yes_btn.onClick:AddListener(
            function()
                Network.SendRequest(
                    "pay_exchange_goods",
                    {goods_type = self.cfg.type, goods_id = self.cfg.id},
                    "兑换门票",
                    function(data)
                        if data.result ~= 0 then
                            HintPanel.ErrorMsg(data.result)
                        end
                    end
                )
                self:MyExit()
            end
        )
    end
    self:MyRefresh()
end

function M:MyRefresh()
end
