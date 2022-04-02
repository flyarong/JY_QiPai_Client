SysChangeHeadNamePanel = basefunc.class()
local M = SysChangeHeadNamePanel
M.name = "SysChangeHeadNamePanel"

local instance
function M.Create(parent, parm)
    M.Exit()
    instance = M.New(parent, parm)
    return instance
end
function M.Exit()
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
    self.lister["update_player_name_response"] = basefunc.handler(self, self.update_player_name_response)
    self.lister["set_head_image_response"] = basefunc.handler(self, self.set_head_image_response)
end

function M:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function M:ctor(parent, parm)
    self.parm = parm
    ExtPanel.ExtMsg(self)
    if self.parm.goto_scene_parm =="player_info" then
        parent = GameObject.Find("HallPlayerInfoPanel").transform
    end
    local obj = newObject(M.name, parent)
    local tran = obj.transform
    self.transform = tran
    self.gameObject = obj
    LuaHelper.GeneratingVar(self.transform, self)
    self:MakeLister()
    self:AddMsgListener()
    self:InitUI()
end

--初始化UI
function M:InitUI()
    self:ChangeHeadNameInitHall()
end

function M:MyClose()
	self:MyExit()
end

function M:MyExit()
    PersonalInfo.Exit()
    self:RemoveListener()
    destroy(self.gameObject)
end

function M:ChangeHallPlayerInfoPanel()
    local hpip = GameObject.Find("HallPlayerInfoPanel")
    local player_head_img = hpip.transform:Find("ImgCenter/@player_head_img")
    EventTriggerListener.Get(player_head_img.gameObject).onClick = basefunc.handler(self, self.ChangeHeadIcon)
    hpip = nil
    player_head_img = nil
end

function M:ChangeHeadNameInitHall()
    if not MainModel.UserInfo then return end
    self:ChangeHallPlayerInfoPanel()

    self.change_name_btn.onClick:AddListener(function ()
        --修改昵称
        self:ChangeName()
    end)
    self:ChangeHeadNameRefresh()
end

function M:ChangeHeadNameRefresh()
    if not IsEquals(self.gameObject) then return end
    if not MainModel.UserInfo then 
        self.change_name_btn.gameObject:SetActive(false)
        self.change_name_btn.gameObject:SetActive(false)
        return 
    end
    self.change_name_btn.gameObject:SetActive(true)
end

function M:ChangeName()
    ChangeNamePanel.Create()
end

function M:ChangeHeadIcon()
    ChangeHeadIconPanel.Create()
end

function M:update_player_name_response(_,data)
    dump(data,"<color=white>update_player_name_response</color>")
    if not data then return end
    if data.result ~= 0 then
        if data.result == 6301 or data.result == 6302 or data.result == 6303 or data.result == 6308 then
            LittleTips.Create(errorCode[data.result])
            return
        end
        HintPanel.ErrorMsg(data.result)
        return
    end
    MainModel.UserInfo.name = data.name
    if not  MainModel.UserInfo.udpate_name_num then  MainModel.UserInfo.udpate_name_num = 0 end
    MainModel.UserInfo.udpate_name_num =  MainModel.UserInfo.udpate_name_num + 1
    Event.Brocast("set_player_name")
end

function M:set_head_image_response(_,data)
    dump(data,"<color=white>set_head_image_response</color>")
    if not data then return end
    if data.result ~= 0 then
        if data.result == 6306 or data.result == 6307 then
            LittleTips.Create(errorCode[data.result])
            return
        end
        HintPanel.ErrorMsg(data.result)
        return
    end
    MainModel.UserInfo.img_type = data.img_type
    MainModel.UserInfo.head_image = ChangeHeadNameBindingManager.GetHeadImage()
    Event.Brocast("set_head_image")
end