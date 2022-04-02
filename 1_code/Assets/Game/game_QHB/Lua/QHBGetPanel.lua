local basefunc = require "Game/Common/basefunc"

QHBGetPanel = basefunc.class()
local M = QHBGetPanel
M.name = "QHBGetPanel"

local instance
function M.Create(hb_data)
    dump(hb_data, "<color=white>抢红包</color>")
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
    self.lister["model_qhb_hb_get_response"] = basefunc.handler(self, self.qhb_hb_get_response)
    self.lister["model_qhb_get_qhb_data_response"] = basefunc.handler(self, self.qhb_get_qhb_data_response)
end

function M:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function M:MyExit()
    self.hb_data = nil
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
    LuaHelper.GeneratingVar(self.transform,self)
    self.quan = self.transform:Find("quan")
    self.quan.transform.localScale = Vector2.New(1,1)
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function M:InitUI()
    URLImageManager.UpdateHeadImage(self.hb_data.send_player.head_link, self.head_img)
    self.info_txt.text = "未领取的红包在2分钟过期后回自动退款给发红包的用户"
    if not QHBModel.data or QHBModel.data.game_id == 41 then
        self.name_txt.text = self.hb_data.send_player.name
    else
        self.name_txt.text = basefunc.deal_hide_player_name(self.hb_data.send_player.name)
    end
    
    self.boom_txt.text = self.hb_data.boom_num
    self.all_txt.text = StringHelper.ToCash(self.hb_data.asset.value)
    self.num_txt.text = string.format( "剩余 %s/%s 个",self.hb_data.total_count - self.hb_data.geted_count,self.hb_data.total_count)
    self.get_btn.onClick:AddListener(function (  )
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        if self.get_time and os.time() - self.get_time < 1 then
            LittleTips.CreateSP("点击太频繁")
        else
            --红包过期
            if  QHBModel.CheckIsTimeOut(self.hb_data.timeout) then
                -- QHBDetailPanel.Create(self.hb_data.hb_id)
                LittleTips.CreateSP("红包已过期")
                M.Close()
                return
            end

            --红包抢完
            if self.hb_data.total_count == self.hb_data.geted_count then
                -- QHBDetailPanel.Create(self.hb_data.hb_id)
                LittleTips.CreateSP("该红包已被抢光，快换一个红包吧")
                M.Close()
                return
            end

            if QHBModel.IsSysScene() then
                -- if QHBModel.data.player_hb_data.use_num >= QHBModel.data.player_hb_data.total_num then
                --     LittleTips.CreateSP("您当日的抢红包次数不足，请明日再来")
                --     return
                -- end
            else
                --鲸币限制
                local cfg = QHBModel.cfg.get[QHBModel.data.game_id]
                if cfg and cfg.xz_bl then
                    --倍率限制
                    local val = GameItemModel.GetItemCount(self.hb_data.asset.asset_type)
                    val = val * cfg.xz_bl
                    if val < self.hb_data.asset.value then
                        local item = GameItemModel.GetItemToKey(self.hb_data.asset.asset_type)
                        HintPanel.Create(2,string.format( "需要身上携带%s%s才能打开这个红包\n您当前鲸币不足，是否前往商城充值？",self.hb_data.asset.value,item.name),function(  )
                            PayPanel.Create(GOODS_TYPE.jing_bi)
                        end,nil,nil,nil,"HintPanelSP")
                        return
                    end
                end
            end
            --领取红包
            QHBModel.request_qhb_hb_get(self.hb_data.hb_id)
            self.wait_img.gameObject:SetActive(true)
            self.get_time = os.time()
        end
    end)
    self.back_btn.onClick:AddListener(function()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        M.Close()
    end)
end

function M:qhb_hb_get_response(data)
    self.wait_img.gameObject:SetActive(false)
    M.Close()
end

function M:qhb_get_qhb_data_response(data)
    --更新剩余次数
    
end