local basefunc = require "Game/Common/basefunc"
Act_042_MPDHPanel = basefunc.class()
local M = Act_042_MPDHPanel
M.name = "Act_042_MPDHPanel"

local Mgr = Act_042_MPDHManager
function M.Create(parent, backcall)
    return M.New(parent, backcall)
end

function M:AddMsgListener()
    for proto_name, func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function M:MakeLister()
    self.lister = {}
    self.lister["act_042_mpdh_close"] = basefunc.handler(self, self.MyExit)
    self.lister["AssetChange"] = basefunc.handler(self, self.MyRefresh)
end

function M:RemoveListener()
    for proto_name, func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function M:MyExit()
    self.items = nil
    if self.backcall then
        self.backcall()
    end
    self:RemoveListener()
    destroy(self.gameObject)
end

function M:ctor(parent, backcall)
    ExtPanel.ExtMsg(self)
    local parent = parent or GameObject.Find("Canvas/LayerLv5").transform
    local obj = newObject(M.name, parent)
    local tran = obj.transform
    self.transform = tran
    self.gameObject = obj
    LuaHelper.GeneratingVar(self.transform, self)
    self.backcall = backcall
    self:MakeLister()
    self:AddMsgListener()
    self:InitUI()
end

function M:InitUI()
	self.close_btn.onClick:AddListener(function(  )
		self:MyExit();
	end)
	self.items = {}
    local obj
    for i, v in ipairs(Mgr.config.shop) do
		local cfg = MainModel.GetShopingConfig(GOODS_TYPE.item, v.item_id, v.item_type)
		if cfg then
			local ui = {}
            obj = GameObject.Instantiate(self.item, self.content)
            LuaHelper.GeneratingVar(obj.transform, ui)
            ui.title_txt.text = cfg.ui_title or ""
			ui.icon_img.sprite = GetTexture(cfg.ui_icon)
			ui.icon_img.gameObject:SetActive(true)
            ui.hb_txt.text = StringHelper.ToCash(cfg.use_count / 100)
            ui.dh_btn.onClick:AddListener(
				function()
					local newtime = tonumber(os.date("%Y%m%d", os.time()))
                    local oldtime = tonumber(os.date("%Y%m%d", tonumber(PlayerPrefs.GetString(Mgr.hint_key, 0))))
					if newtime ~= oldtime then
						Act_042_MPDHHintPanel.Create(cfg)
						return
					end
                    Network.SendRequest(
                        "pay_exchange_goods",
                        {goods_type = cfg.type, goods_id = cfg.id},
                        "兑换门票",
                        function(data)
                            if data.result ~= 0 then
                                HintPanel.ErrorMsg(data.result)
                            end
                        end
                    )
                end
            )
            ui.no_btn.gameObject:SetActive(MainModel.UserInfo.shop_gold_sum < cfg.use_count)
            ui.no_btn.onClick:AddListener(
                function(  )
                    LittleTips.Create("您还差" .. StringHelper.ToCash((cfg.use_count - MainModel.UserInfo.shop_gold_sum)/100) .. "福卡才能兑换")
                end
            )
            if (v.discount) then
                ui.zk_txt.text = v.discount
                ui.zk.gameObject:SetActive(true)
            end
            obj.gameObject:SetActive(true)
            table.insert(self.items,{cfg = cfg,ui = ui})
        end
    end
    self:MyRefresh()
end

function M:MyRefresh()
    if not IsEquals(self.gameObject) then
        return
    end
    for k,v in pairs(self.items) do
        v.ui.no_btn.gameObject:SetActive(MainModel.UserInfo.shop_gold_sum < v.cfg.use_count)
    end
end
