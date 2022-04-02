RXCQGuaiWuManager = {}
local M = RXCQGuaiWuManager
local _self = {}
local curr_guaiwu_id = 1
local all_infos = {}
--pos 相对位置 1,2,3,4，
--world_pos Vector3..
function M.CreateGuaiWu(__self,pos)
    _self = __self or _self
    local guaiwu = RXCQGuaiWuPrefab.Create(_self.transform,RXCQModel.GetGuaiWuConfig(RXCQModel.BetIndex,pos).texture,curr_guaiwu_id)
    guaiwu.transform.parent = _self["guaiwu_node"..pos]
    local world_pos = rxcq_main_config.base[RXCQModel.BetIndex].GuaiWu_Pos[pos]
    world_pos = StringHelper.Split(world_pos,"#")
    world_pos = Vector3.New(world_pos[1],world_pos[2],0)
    guaiwu.transform.localPosition = world_pos
    local scale = rxcq_main_config.base[RXCQModel.BetIndex].GuaiWu_Scale[pos]
    guaiwu.transform.localScale = Vector3.New(scale,scale,scale)
    guaiwu:Stand()
    local data = {guaiwu_id = curr_guaiwu_id,guaiwu = guaiwu,pos = pos}
    guaiwu.pos = pos
    all_infos[#all_infos + 1] = data
    curr_guaiwu_id = curr_guaiwu_id + 1
    return guaiwu
end

function M.ClearAllGuaiWu()
    for i = 1,#all_infos do
        all_infos[i].guaiwu:MyExit()
    end
    all_infos = {}
    Util.ClearMemory()
end

function M.GetAllLiveGuaiWu()
    local list = {}
    for i = 1,#all_infos do
        if all_infos[i].guaiwu.status == "活" then
            list[#list + 1] = all_infos[i].guaiwu
        end
    end
    return list
end

function M.GetGuaiWuByPos(pos)
    dump(all_infos,"<color=red>all_infos</color>")
    for i = 1,#all_infos do
        if all_infos[i].pos == pos and all_infos[i].guaiwu.status == "活" then
            return all_infos[i].guaiwu
        end
    end
end

function M.GetGuaiWuByPosliveOrDie(pos)
    dump(all_infos,"<color=red>all_infos</color>")
    for i = 1,#all_infos do
        if all_infos[i].pos == pos and all_infos[i].guaiwu.status then
            return all_infos[i].guaiwu
        end
    end
end