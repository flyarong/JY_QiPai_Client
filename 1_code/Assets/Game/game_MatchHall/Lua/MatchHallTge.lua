MatchHallTge = basefunc.class()
local M = MatchHallTge

M.name = "MatchHallTge"
local instance
function M.Create(parent, config)
    if instance then
        instance:MyExit()
    end
    instance = M.New(parent, config)
	return instance
end

function M.Close()
    if instance then
        instance:MyExit()
    end
end

function M:ctor(parent, config)
	self.config = config
	local obj = newObject(M.name, parent)
	self.gameObject = obj
    LuaHelper.GeneratingVar(obj.transform, self)
    self:Init()
end

function M:MyExit()
    GameObject.Destroy(self.gameObject)
end

function M:Init()
    local list = {}
    for k, v in pairs(self.config) do
        list[#list + 1] = v
    end
    table.sort(list,function(a, b)
        return a.order < b.order
    end)
    self.tge_obj_list = {}
    local TG = self.SV.transform:GetComponent("ToggleGroup")
    for k, v in ipairs(list) do
        if v.is_show and v.is_show == 1 then
            self:SetMatchTgeItem(v,TG)
        end
    end
    TG.allowSwitchOff = false
end

function M:SetMatchTgeItem(config,TG)
    local go = GameObject.Instantiate(GetPrefab("MatchHallTgeItem"), self.switch_content)
    go.gameObject:SetActive(config.is_show == 1)
    go.name = config.hall_type
    local ui_table = {}
    LuaHelper.GeneratingVar(go.transform, ui_table)
    ui_table.item_tge = go.transform:GetComponent("Toggle")
    ui_table.item_tge.group = TG
    ui_table.item_tge.onValueChanged:AddListener(
        function(val)
            ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
            ui_table.tge_txt.gameObject:SetActive(not val)
            ui_table.check_mark_txt.gameObject:SetActive(val)

            if val then
                if self.selectConfig and self.selectConfig.hall_type == config.hall_type then
                    return
                end
                self.selectConfig = config
                MatchHallPanel.UpdateRightUI(config)
                Event.Brocast("jbs_hall_switched",{hall_type = config.hall_type})
            end
        end
    )
    ui_table.tge_txt.text = config.match_name
    ui_table.check_mark_txt.text = config.match_name
    self.tge_obj_list[config.hall_type] = ui_table

    if config.is_tj and config.is_tj == 1 then
        ui_table.hint_node.gameObject:SetActive(true)
    else
        ui_table.hint_node.gameObject:SetActive(false)
    end
end

function M.SetTgeIsOn(hall_type)
    if instance and instance.tge_obj_list[hall_type] then
        local tge_item = instance.tge_obj_list[hall_type]
        tge_item.item_tge.isOn = true
    end
end

function M.SetLoadownIsShow(hall_type,bool)
    if instance and instance.tge_obj_list[hall_type] then
        local tge_item = instance.tge_obj_list[hall_type]
        tge_item.loadown_img.gameObject:SetActive(bool)
    end
end