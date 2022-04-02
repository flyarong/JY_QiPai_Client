-- 创建时间:2019-11-28
-- Panel:LHDClearingPanel
--[[
 *      ┌─┐       ┌─┐
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

LHDClearingPanel = basefunc.class()
local C = LHDClearingPanel
C.name = "LHDClearingPanel"
local M = LHDModel

function C.Create(parm)
	return C.New(parm)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["model_fg_gameover_msg"] = basefunc.handler(self, self.on_fg_gameover_msg)
    self.lister["fg_ready_response_code"] = basefunc.handler(self, self.on_fg_ready_response_code)
    self.lister["fg_lhd_huanzhuo_response_code"] = basefunc.handler(self, self.on_fg_lhd_huanzhuo_response_code)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
    if self.room_rent_time then
        self.room_rent_time:Stop()
        self.room_rent_time = nil
    end
    ExtendSoundManager.PlayOldBGM()
	self:RemoveListener()
	destroy(self.gameObject)

	 
end

function C:ctor(parm)

	ExtPanel.ExtMsg(self)

	self.parm = parm
	local parent = GameObject.Find("Canvas/LayerLv2").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	self.player_ui = {}
	self.player_ui[#self.player_ui + 1] = self.player1
	self.player_ui[#self.player_ui + 1] = self.player2
	self.player_ui[#self.player_ui + 1] = self.player3
	self.player_ui[#self.player_ui + 1] = self.player4
	self.zb_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        self:OnReadyClick()
    end)
    self.hz_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        self:OnHZClick()
    end)
    self.back_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        self:OnBackClick()
    end)
    self.help_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        LHDHelpPanel.Create()
    end)

    if M.baseData.room_rent then
        self.room_rent_txt.text = "服务费：" .. M.baseData.room_rent.asset_count
    end
    self.room_rent_time = Timer.New(function()
        if IsEquals(self.room_rent_txt.gameObject) then
            -- self.room_rent_txt.gameObject:SetActive(false)
        end
    end, 3, 1, true)
    self.room_rent_time:Start()
    self.game_exit_time_txt.text = os.date("%Y.%m.%d %H:%M:%S", os.time())

	self:MyRefresh()
end

function C:MyRefresh()
	self:SetBackAndConfirmBtn()
	self.js_dta = M.data.settlement_info
	self.js_player = {}
    for k,v in ipairs(self.js_dta.player_info) do
        self.js_player[v.seat_num] = v
    end
    dump(self.js_dta, "<color=red>EEE LHDClearingPanel js_dta</color>")
    dump(self.js_player, "<color=red>EEE LHDClearingPanel js_player</color>")

    self.is_my_game = false
    -- 显示顺序
    local show_pos = {}
    show_pos[#show_pos + 1] = self.js_dta.winner
    for k, v in ipairs(self.js_dta.player_pai) do
        if v.pai and #v.pai > 0 then
            if self.js_dta.winner ~= k then
                show_pos[#show_pos + 1] = k
            end
            if M.data.seat_num == k then
                self.is_my_game = true
            end
        end
    end
    dump(show_pos, "<color=red>EEE LHDClearingPanel show_pos</color>")

    -- 我没有参与游戏，显示胜利
    if not self.is_my_game then
        self.is_win = true
    else
        self.is_win = false
        if self.js_dta.winner == M.data.seat_num then
            self.is_win = true
        end
    end
	if self.is_win then
        ExtendSoundManager.PlaySceneBGM(audio_config.dld.gameWin.audio_name)
		self.win_rect.gameObject:SetActive(true)
		self.lose_rect.gameObject:SetActive(false)
	else
        ExtendSoundManager.PlaySceneBGM(audio_config.dld.gameLose.audio_name)
		self.win_rect.gameObject:SetActive(false)
		self.lose_rect.gameObject:SetActive(true)
	end
    Timer.New(function ()
        if IsEquals(self.gameObject) then
            ExtendSoundManager.PlayOldBGM()    
        end
    end, 5, 1):Start()
    
	self:ClearCellList()

	for i = 1, M.maxPlayerNumber do
        if i <= #show_pos then
            self.player_ui[i].gameObject:SetActive(true)
            local seat_num = show_pos[i]
            if self.js_player and self.js_player[seat_num] then
                local player = self.js_player[seat_num]
                local ui_t = {}
                LuaHelper.GeneratingVar(self.player_ui[i], ui_t)

                if self.js_dta.winner == seat_num then
                    ui_t.gold_txt.text = "+" .. StringHelper.ToCash( self.js_dta.award - M.GetPlayerXZ(seat_num) )
                else
                    ui_t.gold_txt.text = "-" .. StringHelper.ToCash( M.GetPlayerXZ(seat_num) )
                end
                ui_t.name_txt.text = player.name or ("name" .. seat_num)
                URLImageManager.UpdateHeadImage(player.head_link, ui_t.head_img)

                local card = self.js_dta.player_pai[seat_num]
                for k,v in ipairs(card.pai) do
                    local pre = LHDCardPrefab.Create(ui_t.card_node, v)
                    self.CellList[#self.CellList + 1] = pre
                end
                if self.js_dta.pai_type[seat_num] > 0 and #card.pai == 5 then
                    ui_t.pai_type_img.gameObject:SetActive(true)
                    if LHDManager.PAI_STYLE[self.js_dta.pai_type[seat_num]] then
                        ui_t.pai_type_img.sprite = GetTexture(LHDManager.PAI_STYLE[self.js_dta.pai_type[seat_num]].img)
                        ui_t.pai_type_img:SetNativeSize()
                    else
                        dump(LHDManager.PAI_STYLE, "没有对应牌型")
                        ui_t.pai_type_img.gameObject:SetActive(false)
                    end                    
                else
                    ui_t.pai_type_img.gameObject:SetActive(false)
                end
            else
                print("<color=red>EEE 结算信息不对 玩家数据没有 seat_num = " .. seat_num .. "</color>")
            end
        else
            self.player_ui[i].gameObject:SetActive(false)
        end
	end

    self:RefreshGuide()
end
function C:RefreshGuide()
    if LHDManager.is_use_aq_style then
        self.guide_desc_txt.text = "牌型：飞龙在天>炸弹>飞机>同色>一条>三虎>双龙>对子>单牌"
    else
        self.guide_desc_txt.text = "牌型：同花顺>炸弹>葫芦>同花>顺子>三条>两对>一对>单牌"
    end
    if LHDModel.data.xsyd == 1 then
        self.guide_rect.gameObject:SetActive(true)
        self.hz_btn.gameObject:SetActive(false)
        self.zb_btn.gameObject:SetActive(true)
        self.zb_btn.transform.localPosition = Vector3.zero
    else
        self.guide_rect.gameObject:SetActive(false)
    end
end
function C:ClearCellList()
	if self.CellList then
		for k,v in ipairs(self.CellList) do
			v:OnDestroy()
		end
	end
	self.CellList = {}
end

function C:CheckShow1YuanGift(call)
    if GameGlobalOnOff.Shop_10_gift_bag ~= nil and GameGlobalOnOff.Shop_10_gift_bag == false then
    	if call then call() end
    	return
    end
	local brokeUp = false
	local myScore = MainModel.UserInfo.jing_bi
    local gameCfg = GameFreeModel.GetGameIDToConfig(M.baseData.game_id)
    if myScore and gameCfg then
        if gameCfg.order == 1 and myScore < gameCfg.enterMin then
            brokeUp = true
        else
            local uiConfigs = GameFreeModel.UIConfig.gameConfigMap
            for _, config in ipairs(uiConfigs) do
                if config.game_type == gameCfg.game_type and config.order == 1 and myScore < config.enterMin then
                    brokeUp = true
                    break
                end
            end
        end
    end

    if brokeUp then
        OneYuanGift.Create(nil, call)
    else
        if call then
            call()
        end
	end
end

function C:OnReadyClick()
    if LHDModel.data.xsyd == 1 then
        self:OnBackClick()
        return
    end
	self:CheckShow1YuanGift(function ()
        M.ZBCheck()
    end)
end

function C:OnHZClick()
	self:CheckShow1YuanGift(function ()
        M.HZCheck()
    end)
end


function C:on_fg_ready_response_code(result)
    if result == 0 then
        self:MyExit()
    end
end
function C:on_fg_lhd_huanzhuo_response_code(result)
    if result == 0 then
        self:MyExit()
    end
end
function C:on_fg_gameover_msg()
    -- self.room_rent_txt.text = "服务费：" .. M.baseData.room_rent.asset_count
    -- if M.data.glory_score_count then
    --     local v1 = M.data.glory_score_count
    --     local v2 = M.data.glory_score_change
    --     --GameHonorModel.UpdateHonorValue(v1)
    -- end
end
function C:SetBackAndConfirmBtn()
    local is_game_over = M.data.model_status == M.Model_Status.gameover
    if is_game_over then
    end
    self.back_btn.gameObject:SetActive(is_game_over)
    self.hz_btn.gameObject:SetActive(is_game_over)
    self.zb_btn.gameObject:SetActive(is_game_over)
end

function C:OnBackClick()
    Network.SendRequest("fg_lhd_quit_game", nil, "请求退出")
end

