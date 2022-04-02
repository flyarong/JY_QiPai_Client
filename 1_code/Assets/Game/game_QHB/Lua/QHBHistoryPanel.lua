local basefunc = require "Game/Common/basefunc"

QHBHistoryPanel = basefunc.class()
local M = QHBHistoryPanel
M.name = "QHBHistoryPanel"

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
    self.lister["model_qhb_hb_history_response"] = basefunc.handler(self, self.qhb_hb_history_response)
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
    self.back_btn.onClick:AddListener(function(  )
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        M.Close()
    end)
    -- local sv_sr = self.sv.transform:GetComponent("ScrollRect")
    -- --滑动
	-- EventTriggerListener.Get(sv_sr.gameObject).onEndDrag = function()
    --     local VNP = sv_sr.verticalNormalizedPosition
	-- 	if VNP <= 0 then
	-- 		QHBModel.request_qhb_hb_history()
	-- 	end
	-- end

    QHBModel.init_qhb_hb_history()
    QHBModel.request_qhb_hb_history()
end

function M:qhb_hb_history_response(hb_history)
    if table_is_null(hb_history) then return end
    local v = {}
    local obj = {}
    for i,v in ipairs(hb_history) do
        obj.gameObject = GameObject.Instantiate(GetPrefab("hb_history"),self.history_content)
        obj.transform = obj.gameObject.transform
        LuaHelper.GeneratingVar(obj.transform,obj)

        URLImageManager.UpdateHeadImage(v.player.head_link, obj.head_img)
        
        if not QHBModel.data or QHBModel.data.game_id == 41 then
            obj.name_txt.text = v.player.name
        else
            obj.name_txt.text = basefunc.deal_hide_player_name(v.player.name)
        end
        obj.time_txt.text = os.date("%Y-%m-%d\n%H:%M:%S", v.time)
        
        if v.op_type == "fa" then
            obj.jb_txt.text = StringHelper.ToCash(v.asset.value)
            obj.jb_img.sprite = GetTexture("com_icon_hb")
            obj.boom_txt.text = ""
        elseif v.op_type == "qiang" then
            obj.jb_txt.text = v.asset.value
            obj.jb_img.sprite = GetTexture("com_award_icon_jingbi")
            if v.boom == 1 then
                obj.boom_img.gameObject:SetActive(true)
                obj.boom_txt.text = string.format( "-%s", StringHelper.ToCash(v.boom_value))
            else
                obj.boom_img.gameObject:SetActive(false)
                obj.boom_txt.text = ""
            end
        end
        -- local hb_id = v.hb_id
        -- local timeout = v.timeout
        -- obj.bg_btn.onClick:AddListener(function()
        --     --红包过期
        --     if QHBModel.CheckIsTimeOut(timeout) then
        --         --过期红包无法查看详情，无法领取
        --         LittleTips.CreateSP("红包已过期")
        --         return
        --     end
        --     QHBDetailPanel.Create(hb_id)
        -- end)
        obj.transform:SetAsLastSibling()
    end
end