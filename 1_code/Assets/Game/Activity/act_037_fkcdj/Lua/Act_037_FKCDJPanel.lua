-- 创建时间:2020-11-05
-- Panel:Act_037_FKCDJPanel
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
 -- 取消按钮音效
 -- ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
 -- 确认按钮音效
 -- ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
 --]]
local basefunc = require "Game/Common/basefunc"

Act_037_FKCDJPanel = basefunc.class()
local C = Act_037_FKCDJPanel
C.name = "Act_037_FKCDJPanel"
local M = Act_037_FKCDJManager

local DESCRIBE_TEXT = {
    [1] = "1.活动时间：11月10日7:30~11月16日23:59:59",
    [2] = "2.活动期间消耗福卡或抽奖券有机会获得超级大奖",
    [3] = "3.实物奖励，请在活动结束后7个工作日内联系QQ公众号：4008882620领取，否则视为自动放弃奖励",
    [4] = "4.奖励图片仅供参考，请以实际发出的奖励为准",
    [5] = "5.实物奖励将在活动结束后7个工作日内统一发放",
}

local offset = {
	0,10,50,100,200,500
}

function C.Create(parent, backcall)
    return C.New(parent, backcall)
end

function C:AddMsgListener()
    for proto_name, func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["box_exchange_response"] = basefunc.handler(self, self.on_box_exchange_response)
    self.lister["model_task_change_msg"] = basefunc.handler(self, self.on_model_task_change_msg)
    self.lister["model_query_one_task_data_response"] = basefunc.handler(self, self.on_model_query_one_task_data_response)
    self.lister["AssetChange"] = basefunc.handler(self, self.OnAssetChange)
    self.lister["query_fake_data_response"] = basefunc.handler(self, self.AddPMD)
    self.lister["ExitScene"] = basefunc.handler(self, self.MyExit)
end

function C:RemoveListener()
    for proto_name, func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
    self:RemoveListener()
    if self.backcall then
        self.backcall()
    end
    if self.UpdatePMD then
        self.UpdatePMD:Stop()
    end
    destroy(self.gameObject)
end

function C:ctor(parent, backcall)
    ExtPanel.ExtMsg(self)
    local parent = parent or GameObject.Find("Canvas/LayerLv3").transform
    local obj = newObject(C.name, parent)
    local tran = obj.transform
    self.transform = tran
    self.gameObject = obj
    self.backcall = backcall
    LuaHelper.GeneratingVar(self.transform, self)
    self:MakeLister()
    self:AddMsgListener()
    self:InitUI()
    Network.SendRequest("query_one_task_data", { task_id = Act_037_FKCDJManager.task_id })

    self.pmd_cont = CommonPMDManager.Create({ parent = self.pmd_node, speed = 18, space_time = 10, start_pos = 1000 })
    self:UpDatePMD()
end

function C:InitUI()
    self.lottery1_btn.onClick:AddListener(
		function()
			self:OnClickLottery(1)
		end
    )
    self.lottery2_btn.onClick:AddListener(
		function()
			self:OnClickLottery(10)
		end
    )

    self.more_btn.onClick:AddListener(
		function()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
			LTTipsPrefab.Show(self.more_btn.gameObject.transform, 1, "<color=#FFF9B8><size=46>还有机会获得：</size>\n<size=36>充值优惠券，鲸币，福卡，鱼币，话费碎片</size></color>")
		end
    )
    self.help_btn.onClick:AddListener(
		function()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
			self:OpenHelpPanel()
		end
    )

    --dump(self,"<color=white>      self    </color>")
    for i = 1, 5 do

        self["award" .. i .. "_btn"].onClick:AddListener(
        function()
            local data = GameTaskModel.GetTaskDataByID(Act_037_FKCDJManager.task_id)
            if data then
                local b = basefunc.decode_task_award_status(data.award_get_status)
                b = basefunc.decode_all_task_award_status(b, data, 5)
                if b[i] == 1 then
                    --Network.SendRequest("get_task_award_new", { id = Act_037_FKCDJManager.task_id, award_progress_lv = i })
                	Network.SendRequest("get_task_award_new", { id = Act_037_FKCDJManager.task_id, award_progress_lv = i })
                    if i == 5 then
                        RealAwardPanel.Create({ image = "activity_icon_gift66", text = "大米" })
                    end
                end
            end
        end
        )
    end
    --self.num_txt.text = "x"..GameItemModel.GetItemCount("bzth_iocn_xfq")
    self:RefreshConvertUI()
    self:MyRefresh()
end

function C:MyRefresh()

end

function C:on_box_exchange_response(_, data)
    dump(data, "<color=red>----------抽奖数据-----------</color>")
    if data.result == 0 then
        self:AddMyPMD(data.award_id) --PMD Self

        local real_list = self:GetRealInList(data.award_id)
        dump(real_list, "<color=red>-------实物奖励------</color>")
        if self:IsAllRealPop(data.award_id, real_list) then
            RealAwardPanel.Create(self:GetShowData(real_list))
        else
            self.call = function()
                if not table_is_null(real_list) then
                    MixAwardPopManager.Create(self:GetShowData(real_list), nil, 2)
                end
            end
        end
        self:TryToShow()
    end
end

function C:on_model_task_change_msg(data)
    dump(data, "<color=red>----------任务改变-----------</color>")
    if data and data.id == Act_037_FKCDJManager.task_id then
        --self.num_txt.text = data.now_total_process
        local b = basefunc.decode_task_award_status(data.award_get_status)
        b = basefunc.decode_all_task_award_status(b, data, 5)
        self:ReFreshProgress(data.now_total_process)
        self:ReFreshTaskButtons(b)
    end
end

function C:on_model_query_one_task_data_response(data)
    dump(data, "<color=red>----------任务信息获得-----------</color>")
    if data and data.id == Act_037_FKCDJManager.task_id then
        --self.num_txt.text = data.now_total_process
        local b = basefunc.decode_task_award_status(data.award_get_status)
        b = basefunc.decode_all_task_award_status(b, data, 5)
		self:ReFreshProgress(data.now_total_process)
		--dump(b,"<color=white>bbbbbbbbbbbbbbbbbbbbbbbbbb</color>")
        self:ReFreshTaskButtons(b)
    end
end
--在奖励列表里面获取实物奖励的ID
function C:GetRealInList(award_id)
    local r_list = {}
    local temp
    for i = 1, #award_id do
        temp = self:GetConfigByServerID(award_id[i])
        if temp then
            r_list[#r_list + 1] = temp
        end
    end
    return r_list
end
--根据ID获取配置信息
function C:GetConfigByServerID(server_award_id)
    return Act_037_FKCDJManager.config[server_award_id]
end
--如果全都是实物奖励，就直接用 realawardpanel
function C:IsAllRealPop(award_id, real_list)
    if #real_list >= #award_id then
        return true
    else
        return false
    end
end
--把配置数据转换为奖励展示面板所需要的数据格式
function C:GetShowData(real_list)
    local data = {}
    data.text = {}
    data.image = {}
    for i = 1, #real_list do
        data.text[#data.text + 1] = real_list[i].text
        data.image[#data.image + 1] = real_list[i].image
    end
    return data
end

function C:OnAssetChange(data)
    dump(data, "<color=red>----奖励类型-----</color>")
    ------
    if data.change_type and (data.change_type == "box_exchange_active_award_113" or data.change_type == "box_exchange_active_award_112") and not table_is_null(data.data) then
        self.Award_Data = data
        self:TryToShow()
        --self:AddMyPMD()
    end
    --self.num_txt.text = "x"..GameItemModel.GetItemCount("bzth_iocn_xfq")
    self:RefreshConvertUI()
end

function C:TryToShow()
    if self.Award_Data and self.call then
        self.call()
        Event.Brocast("AssetGet", self.Award_Data)
        self.Award_Data = nil
        self.call = nil
    end
end

--刷新是否获得
function C:ReFreshTaskButtons(list)
	--dump(list,"<color=white>lllllllllllllllllllllllllist</color>")
	for i = 1,#list do
		if list[i] == 1 then
			self["anim"..i.."_get"].gameObject:SetActive(true)
		else
			self["anim"..i.."_get"].gameObject:SetActive(false)
		end
		self["award"..i.."_mask"].gameObject:SetActive(list[i] == 2)
	end
end

function C:ReFreshProgress(total)
    local len = {
        [1] = { min = 0, max = 119.31 },
        [2] = { min = 219.12, max = 297.81 },
        [3] = { min = 395.81, max = 474.93 },
        [4] = { min = 574.79, max = 653.89 },
        [5] = { min = 751.25, max = 831.28 },
    }
    local now_level = 1
    for i = #offset, 1, -1 do
        if total >= offset[i] then
            now_level = i
            break
        end
    end
    if now_level > 5 then
        self.progress.sizeDelta = { x = len[#len].max, y = 29.78 }
    else
        local now_need = offset[now_level + 1] - offset[now_level]
        local now_have = total - offset[now_level]
        local l = (now_have / now_need) * (len[now_level].max - len[now_level].min) + len[now_level].min
        self.progress.sizeDelta = { x = l, y = 20.8 }
    end
    self:RefreshNum(total)
end

function C:GetCurrPercentage(nowlv, total)

end

function C:GetProgressX(percentage, o_d)

end


function C:OnClickLottery(lottery_num)
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)

    local amount_cjq = GameItemModel.GetItemCount(M.convert_item_1)
    local amount_fk = GameItemModel.GetItemCount(M.convert_item_2) / 100

    local unenought_cfk_str = "抽奖券不足！"
    local unenought_fk_str = "福卡不足！"

    local cjq_id = 112
    local fk_id = 113

    if M.IsCanUse_XFJ(10) then
        self:LotteryFun(amount_cjq, M.amount_min_1, lottery_num, cjq_id, unenought_cfk_str)
    elseif not M.IsCanUse_XFJ(10) and M.IsCanUse_XFJ(1) then
        if lottery_num == 1  then 
            self:LotteryFun(amount_cjq, M.amount_min_1, lottery_num, cjq_id, unenought_cfk_str)
        else
            self:LotteryFun(amount_fk, M.amount_min_2, lottery_num, fk_id, unenought_fk_str)
        end
    else
        self:LotteryFun(amount_fk, M.amount_min_2, lottery_num, fk_id, unenought_fk_str)
    end
end

function C:LotteryFun(convert_item, amount_min, lottery_num, id, hint_show)
    --local amount = GameItemModel.GetItemCount(M.convert_item)
    if convert_item >= amount_min * lottery_num then
        M.BoxChangeToNet(id, lottery_num)
    else
        HintPanel.Create(1, hint_show)
    end
end

function M.BoxChangeToNet(id, num)
    Network.SendRequest("box_exchange", { id = id, num = num })
end

function C:RefreshConvertUI()
    self.num_txt.text = "x" .. GameItemModel.GetItemCount(M.convert_item_1)
    local fk_sprite = "bzdh_icon_hb" 
    local cjq_sprite = "com_award_icon_dhq" 

    if M.IsCanUse_XFJ(10) then
        self:RefreshConvertItem(cjq_sprite, cjq_sprite, M.amount_min_1, M.amount_min_1)
    elseif not M.IsCanUse_XFJ(10) and M.IsCanUse_XFJ(1) then
        self:RefreshConvertItem(cjq_sprite, fk_sprite, M.amount_min_1, M.amount_min_2)
    else
        self:RefreshConvertItem(fk_sprite, fk_sprite, M.amount_min_2, M.amount_min_2)
    end
end

function C:RefreshConvertItem(item_icon1, item_icon2, amount_min1, amount_min2)
    self.num1_img.sprite, self.num2_img.sprite = GetTexture(item_icon1), GetTexture(item_icon2)
    self.num1_txt.text = "x" .. amount_min1
    self.num2_txt.text = "x" .. amount_min2 * 10
end

function C:OpenHelpPanel()
    local str = DESCRIBE_TEXT[1]
    for i = 2, #DESCRIBE_TEXT do
        str = str .. "\n" .. DESCRIBE_TEXT[i]
    end
    self.introduce_txt.text = str
    IllustratePanel.Create({ self.introduce_txt.gameObject }, GameObject.Find("Canvas/LayerLv5").transform)
end

function C:OnDestroy()
    self:MyExit()
end

function C:RefreshNum(total)
    for i = 1, 5 do
        local num = total >= offset[i + 1] and offset[i + 1] or total
        self["n" .. i .. "_txt"].text = num .. "/" .. offset[i + 1]
    end
end

function C:UpDatePMD()
    if self.UpdatePMD then
        self.UpdatePMD:Stop()
    end
    Network.SendRequest("query_fake_data", { data_type = "crazy_lottery_20_11_10" })
    self.UpdatePMD = Timer.New(
        function()
            --dump("<color=red>-------------------------------------------   query_fake_data-------------------------------------------------</color>")
			Network.SendRequest("query_fake_data", { data_type = "crazy_lottery_20_11_10" })
		end
    , 20, -1)
    self.UpdatePMD:Start()
end


function C:AddMyPMD(data)
    if table_is_null(data) then return end
    local _data_info = self.Award_Data.data
    local _data = data
    for i = 1, #_data do
        local cur_data_info = M.config_pmd[_data[i]]
        if cur_data_info ~= nil then
            local cur_data_pmd = {}
            cur_data_pmd["result"] = 0
            cur_data_pmd["player_name"] = MainModel.UserInfo.name
            cur_data_pmd["award_data"] = tostring(cur_data_info)
            if tonumber(_data[i]) == 12884 or tonumber(_data[i]) == 12887 then
                cur_data_pmd["award_data"] = _data_info[i].value .. tostring(cur_data_info)
            elseif tonumber(_data[i]) == 12885  then
                cur_data_pmd["award_data"] = _data_info[i].value/100 .. tostring(cur_data_info)
            end
            self:AddPMD(0, cur_data_pmd)
        end
    end
end

function C:AddPMD(_, data)
    dump(data, "<color=red>PMD</color>")
    if not IsEquals(self.gameObject) then return end
    if data and data.result == 0 then
        local b = GameObject.Instantiate(self.pmd_item, self.pmd_node)
        b.gameObject:SetActive(true)
        local temp_ui = {}
        LuaHelper.GeneratingVar(b.transform, temp_ui)
        temp_ui.t1_txt.text = "恭喜" .. data.player_name .. "鸿运当头，抽中了" .. data.award_data
        UnityEngine.UI.LayoutRebuilder.ForceRebuildLayoutImmediate(b.transform)
        self.pmd_cont:AddObj(b)
    end
end

