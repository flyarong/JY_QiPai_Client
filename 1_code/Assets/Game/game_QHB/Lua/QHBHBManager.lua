local basefunc = require "Game/Common/basefunc"
QHBHBManager = basefunc.class()
local M = QHBHBManager
M.name = "QHBHBManager"
function M.Init()
    M.hb_info = {}
    M.hb_me = GetPrefab("hb_me")
    M.hb_other = GetPrefab("hb_other")
    if M.timer then
        M.timer:Stop()
        M.timer = nil
    end
    M.timer = Timer.New(function (  )
        M.Update()
    end,3,-1,true,true)
    M.timer:Start()
end

function M.Exit()
    if M.timer then
        M.timer:Stop()
        M.timer = nil
    end
    M.Clear()
    M.hb_info = nil
    M.hb_me = nil
    M.hb_other = nil
end

function M.Update()
    if table_is_null(M.hb_info) then return end
    for k,v in pairs(M.hb_info) do
        M.RefreshHB(v.hb_data)
    end
end

function M.Refresh(hb_datas)
    if table_is_null(hb_datas) then return end
    for i=#hb_datas,1,-1 do
        local hb_data = hb_datas[i]
        if M.hb_info[hb_data.hb_id] then
            M.RefreshHB(hb_data)
        else
            M.AddHB(hb_data)
        end
    end
end

function M.Clear()
    if table_is_null(M.hb_info) then return end
    for k,v in pairs(M.hb_info) do
        if IsEquals(v.gameObject) then
            Destroy(v.gameObject)
        end
    end
end

function M.AddHBFirst(hb_data)
    local hb = M.AddHB(hb_data)
    hb.transform:SetAsFirstSibling()
end

function M.AddHBLast(hb_data)
    local hb = M.AddHB(hb_data)
    hb.transform:SetAsLastSibling()
end

function M.AddHB(hb_data)
    M.parent = M.parent or GameObject.Find("hb_content")
    M.hb_info = M.hb_info or {}
    if M.hb_info[hb_data.hb_id] then
        M.RefreshHB(hb_data)
        return M.hb_info[hb_data.hb_id]
    end
    M.hb_info[hb_data.hb_id] = {}
    M.hb_info[hb_data.hb_id].hb_data = hb_data
    local hb = M.hb_info[hb_data.hb_id]
    local obj
    if hb_data.send_player.id == MainModel.UserInfo.user_id then
        obj = GameObject.Instantiate(M.hb_me.gameObject,M.parent.transform)
    else
        obj = GameObject.Instantiate(M.hb_other.gameObject,M.parent.transform)
    end
    hb.gameObject = obj.gameObject
    hb.transform = obj.transform
    LuaHelper.GeneratingVar(hb.transform,hb)
    URLImageManager.UpdateHeadImage(hb_data.send_player.head_link, hb.head_img)
    if not QHBModel.data or QHBModel.data.game_id == 41 then
        hb.name_txt.text = hb_data.send_player.name
    else
        hb.name_txt.text = basefunc.deal_hide_player_name(hb_data.send_player.name)
    end
    if gameRuntimePlatform == "WindowsEditor" or gameRuntimePlatform == "" then
        hb.name_txt.text = hb.name_txt.text .. "/" .. hb_data.hb_id
    end
    hb.jb_txt.text = StringHelper.ToCash(hb_data.asset.value)
    M.RefreshHB(hb_data)

    local index = 0
    for hb_id,v in pairs(M.hb_info) do
        if hb_id < hb_data.hb_id then
            index = index + 1
        end
    end

    hb.transform:SetSiblingIndex(index)
    return hb
end

function M.RefreshHB(hb_data)
    if not hb_data or not M.hb_info[hb_data.hb_id] then return end
    local hb = M.hb_info[hb_data.hb_id]
    hb.hb_data = hb_data
    local is_view = QHBModel.IsHBView(hb_data.hb_id)
    local is_timeout = QHBModel.CheckIsTimeOut(hb_data.timeout)
    local is_over = hb_data.total_count == hb_data.geted_count
    local is_myself = hb_data.geted_myself == 1

    hb.cai_img.gameObject:SetActive(not is_myself)
    hb.ling_img.gameObject:SetActive(is_myself)
    hb.ylq_img.gameObject:SetActive(is_myself)
    hb.qgl_img.gameObject:SetActive(is_view and is_over)
    -- hb.ygq_img.gameObject:SetActive(is_view and not is_over and is_timeout)
    hb.ygq_img.gameObject:SetActive(not is_over and is_timeout)
    hb.hs_img.gameObject:SetActive(is_view or is_myself or (is_view and is_over) or (not is_over and is_timeout))

    hb.bg_btn.onClick:RemoveAllListeners()
    hb.bg_btn.onClick:AddListener(function (  )
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        QHBModel.SetLocalData(hb_data)
        M.RefreshHB(hb_data)
        --红包过期
        if  QHBModel.CheckIsTimeOut(hb_data.timeout) then
            --过期红包无法查看详情，无法领取
            LittleTips.CreateSP("红包已过期")
            return
        end
        if hb_data.geted_myself == 1 then
            QHBDetailPanel.Create(hb_data.hb_id)
        else
            --红包抢完
            if hb_data.total_count == hb_data.geted_count then
                QHBDetailPanel.Create(hb_data.hb_id)
                LittleTips.CreateSP("该红包已被抢光，快换一个红包吧")
                return
            end

            --红包领取
            QHBGetPanel.Create(hb_data)
        end
    end)
    hb.gameObject:SetActive(true)
end

function M.RefreshHBByID(hb_id)
    if not hb_id or not M.hb_info[hb_id] or not M.hb_info[hb_id].hb_data then return end
    M.RefreshHB(M.hb_info[hb_id].hb_data)
end

function M.RemoveHB(hb_id)
    if not M.hb_info[hb_id] then return end
    Destroy(M.hb_info[hb_id].gameObject)
    M.hb_info[hb_id] = nil
end