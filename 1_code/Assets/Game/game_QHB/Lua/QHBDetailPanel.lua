local basefunc = require "Game/Common/basefunc"

QHBDetailPanel = basefunc.class()
local M = QHBDetailPanel
M.name = "QHBDetailPanel"

local instance
function M.Create(hb_id)
    if instance then
        instance:MyExit()
    end
    instance = M.New(hb_id)
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
    self.lister["model_qhb_hb_detail_response"] = basefunc.handler(self, self.qhb_hb_detail_response)
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

function M:ctor(hb_id)

	ExtPanel.ExtMsg(self)

    self.hb_id = hb_id
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
    QHBModel.request_qhb_hb_detail(self.hb_id)
    self.back_btn.onClick:AddListener(function (  )
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        M.Close()
    end)
end

function M:Refresh()
    -- if table_is_null(self.hb_data) then
    --     LittleTips.CreateSP("数据异常")
    --     M.Close()
    --     return
    -- end
    if not table_is_null(self.hb_data) then
        URLImageManager.UpdateHeadImage(self.hb_data.send_player.head_link, self.head_img)
        if not QHBModel.data or QHBModel.data.game_id == 41 then
            self.name_txt.text = self.hb_data.send_player.name
        else
            self.name_txt.text = basefunc.deal_hide_player_name(self.hb_data.send_player.name)
        end
        self.boom_txt.text = self.hb_data.boom_num
        self.all_txt.text = StringHelper.ToCash(self.hb_data.asset.value)
        self.num_txt.text = string.format("剩余%s/%s个",self.hb_data.total_count - self.hb_data.geted_count,self.hb_data.total_count)
    end
    if not table_is_null(self.get_data) then
        local obj = {}
        destroyChildren(self.content)
        for k,v in pairs(self.get_data) do
            obj.gameObject = GameObject.Instantiate(GetPrefab("hb_detail"),self.content)
            obj.transform = obj.gameObject.transform
            LuaHelper.GeneratingVar(obj.transform,obj)

            URLImageManager.UpdateHeadImage(v.player.head_link, obj.head_img)
            obj.name_txt.text = basefunc.deal_hide_player_name(v.player.name)
            obj.time_txt.text = os.date("%Y-%m-%d %H:%M:%S", v.time)
            obj.jb_txt.text = string.format( "+%s", v.asset.value)
            if v.boom == 1 then
                obj.boom_img.gameObject:SetActive(true)
                local str = v.asset.value
                local str1 = math.modf(str / 10)
                local str2 = str % 10
            else
                obj.boom_img.gameObject:SetActive(false)
            end
            if v.player.id == MainModel.UserInfo.user_id then
                obj.transform:SetAsFirstSibling()
                obj.me_img.gameObject:SetActive(true)
                obj.time_txt.text = string.format( "<color=8e201aff><size=38>%s</size></color>", obj.time_txt.text)
                obj.jb_txt.text = string.format( "<color=8e201aff><size=38>%s</size></color>",obj.jb_txt.text)
            else
                obj.transform:SetAsLastSibling()
                obj.me_img.gameObject:SetActive(false)
            end
            obj.transform.gameObject:SetActive(true)
        end
    end
end

function M:qhb_hb_detail_response(data)
    dump(data, "<color=yellow>qhb_hb_detail_response</color>")
    self.hb_data = data.hb_data
    self.get_data = data.get_data
    self:Refresh()
end
