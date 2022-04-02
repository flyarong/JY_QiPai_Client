-- 创建时间:2020-04-07
-- Panel:Act_007_FKFLChoosePanel
--[[ *      ┌─┐       ┌─┐
 *   ┌──┘ ┴───────┘ ┴──┐
 *   │                 │
 *   │       ───       │
 *   │  ─┬┘       └┬─  │
 *   │                 │
 *   │       ─┴─       │
 *   │                 │
 *   └───┐         ┌───┘
 *       │         │
 *       │         │
 *       │         │
 *       │         └──────────────┐
 *       │                        │
 *       │                        ├─┐
 *       │                        ┌─┘
 *       │                        │
 *       └─┐  ┐  ┌───────┬──┐  ┌──┘
 *         │ ─┤ ─┤       │ ─┤ ─┤
 *         └──┴──┘       └──┴──┘
 *                神兽保佑
 *               代码无BUG!
 --]]
local basefunc = require "Game/Common/basefunc"

Act_007_FKFLChoosePanel = basefunc.class()
local C = Act_007_FKFLChoosePanel
C.name = "Act_007_FKFLChoosePanel"
local M = Act_007_FKFLManager
local instance
function C.Create()
    if instance then
        instance:MyRefresh()
        return
    end
    instance = C.New()
    return instance
end
local str = {
    sh_xxl = 1, sg_xxl = 2, xy_xxl = 3, cs_xxl = 4,bs_xxl = 5,fx_xxl = 6
}
local mask_img = {
    "fkfl_btn_shxxl_1", "fkfl_btn_sgxxl_1", "fkfl_btn_xyxxl_1", "fkfl_btn_csxxl_1" ,"fkfl_btn_bsxxl_1" , "fkfl_btn_fxxxl_1"
}
function C:AddMsgListener()
    for proto_name, func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["force_set_task_data_for_little_game_response"] = basefunc.handler(self, self.force_set_task_data_for_little_game)
end

function C:RemoveListener()
    for proto_name, func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
    self:RemoveListener()
    destroy(self.gameObject)
    instance = nil

	 
end

function C:ctor()

	ExtPanel.ExtMsg(self)

    local parent = GameObject.Find("Canvas/GUIRoot").transform
    local obj = newObject(C.name, parent)
    local tran = obj.transform
    self.transform = tran
    self.gameObject = obj
    LuaHelper.GeneratingVar(self.transform, self)

    self:MakeLister()
    self:AddMsgListener()
    self:InitUI()
    dump(C:CheakIsHadChoose(), "<color=red>当前已经选择的</color>")
end

function C:InitUI()
    self.yes_btn.onClick:AddListener(
    function()
        dump(M.config["base_" .. M.now_level][M.CheakIsNotSetTask()].task_id, "<color=red>任务ID</color>")
        dump(self:GetIndex(), "<color=red>当前选中</color>")
        if self:GetIndex() then
            M.SetOhterData(M.config["base_" .. M.now_level][M.CheakIsNotSetTask()].task_id, self:GetIndex())
        else
            self.gameObject:SetActive(false)
            HintPanel.Create(1, "请选择一个游戏", function()
                if self.gameObject then
                    self.gameObject:SetActive(true)
                end
            end)
        end
    end
    )
    local data = self:CheakIsHadChoose()
    if data then
        for i = 1, #data do
            local index = str[data[i]]
            self["item" .. index].transform:SetAsLastSibling()
            self["i" .. index .. "_img"].sprite = GetTexture(mask_img[index])
            self["T" .. index].gameObject:SetActive(true)
            self["t" .. index .. "_tge"].gameObject:SetActive(false)
        end
    end
    self:MyRefresh()
end

function C:MyRefresh()

end

function C:GetIndex()
    for i = 1, #mask_img do
        if self["t" .. i .. "_tge"].isOn == true then
            return i
        end
    end
end
--检查是否已经选了
function C:CheakIsHadChoose()
    local had_choose = {}
    local base = M.config["base_"..M.now_level]
    for i = 1, #base do
        local data = GameTaskModel.GetTaskDataByID(base[i].task_id)
        if data and data.other_data_str then--(data.other_data_str and not (data.now_lv == #M.GetTaskConfig()[i] and data.need_process == data.now_process )) then
            had_choose[#had_choose + 1] = data.other_data_str
        end
    end
    return had_choose
end

function C:force_set_task_data_for_little_game(_, data)
    dump(data, "<color=red>选中游戏提交</color>")
    if data and data.result == 0 then
        self:MyExit()
    else
        self.gameObject:SetActive(false)
        HintPanel.ErrorMsg(data.result, function()
            self.gameObject:SetActive(true)
        end)
    end
end