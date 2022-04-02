-- 创建时间:2018-06-06

local basefunc = require "Game.Common.basefunc"

RoomCardGameOver = basefunc.class()

RoomCardGameOver.name = "RoomCardGameOver"

local instance
function RoomCardGameOver.Create(parent, gameover_info, playerInfo, game_type,room_owner, confirmCallback)
    if not instance then
        instance = RoomCardGameOver.New(parent, gameover_info, playerInfo, game_type,room_owner, confirmCallback)
    end
    return instance
end
-- 关闭
function RoomCardGameOver.Close()
    if instance then
        instance:MyExit()
        instance = nil
    end
end
function RoomCardGameOver:MakeLister()
    self.lister = {}
    self.lister["screen_shot_end"] = basefunc.handler(self, self.screen_shot_end)
    self.lister["screen_shot_begin"] = basefunc.handler(self, self.screen_shot_begin)
end

function RoomCardGameOver:AddLister()
	for proto_name,func in pairs(self.lister or {}) do
        Event.AddListener(proto_name, func)
    end
end

function RoomCardGameOver:RemoveListener()
    for proto_name, func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = nil
end

function RoomCardGameOver:ctor(parent, gameover_info, playerInfo, game_type,room_owner, confirmCallback)
    parent = GameObject.Find("Canvas/LayerLv3").transform
    self.confirmCallback = confirmCallback
    self.gameover_info = gameover_info
    self.playerInfo = playerInfo
	self.game_type = game_type
	self.room_owner = room_owner
    self:MakeLister()
    self:AddLister()
    local obj = newObject(RoomCardGameOver.name, parent)
    local tran = obj.transform
    self.transform = tran
    self.gameObject = obj

    self.node1 = tran:Find("node1")
    self.node2 = tran:Find("node2")
    self.camera = GameObject.Find("Canvas/Camera"):GetComponent("Camera")
    LuaHelper.GeneratingVar(obj.transform, self)
    self.BackButton_btn.onClick:AddListener(
        function()
            ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
            if self.confirmCallback then
                self.confirmCallback()
            end
            self:OnBackClick()
        end
    )
    self.share_btn.onClick:AddListener(
        function()
            ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
            self:OnShareClick()
        end
    )

    self.icon_img.gameObject:SetActive(false)
    self.qr_code_img.gameObject:SetActive(false)
    self.share_cfg = basefunc.deepcopy(share_link_config.img_room_card_over)
    ShareHelper.RefreshQRCode(self.qr_code_img,self.share_cfg)
    ShareHelper.RefreshImage(self.head_img,self.icon_img,self.invite_txt)

    self:InitRect()
end

function RoomCardGameOver:InitRect()
    local gameover_info = self.gameover_info -- MjXzFKModel.data.gameover_info
	local player_info = self.playerInfo -- MjXzFKModel.data.playerInfo
    if gameover_info and player_info then
        --数据转换
        local data = {}
        for i, v in ipairs(player_info) do
            --总分数
            local grade = 0
            for k, v_g in ipairs(gameover_info) do
                if v_g.grades[v.base.seat_num] then
                    grade = grade + v_g.grades[v.base.seat_num]
                end
            end
            v.grades = grade or 0
            if self.game_type == "DDZ" then
                --斗地主统计
                local ddz_nor_settle_info = {}
                local bomb_count = 0
                local dizhu_count = 0
                local chuntian_count = 0
                for k, v_g in ipairs(gameover_info) do
                    if v_g.ddz_nor_statistics then
                        if v_g.ddz_nor_statistics.bomb_count[v.base.seat_num] then
                            bomb_count = bomb_count + v_g.ddz_nor_statistics.bomb_count[v.base.seat_num]
                        end
                        if v_g.ddz_nor_statistics.dizhu_count[v.base.seat_num] then
                            dizhu_count = dizhu_count + v_g.ddz_nor_statistics.dizhu_count[v.base.seat_num]
                        end
                        if v_g.ddz_nor_statistics.chuntian_count[v.base.seat_num] then
                            chuntian_count = chuntian_count + v_g.ddz_nor_statistics.chuntian_count[v.base.seat_num]
                        end
                    end
                end
                ddz_nor_settle_info.bomb_count = bomb_count
                ddz_nor_settle_info.dizhu_count = dizhu_count
                ddz_nor_settle_info.chuntian_count = chuntian_count
                v.ddz_nor_settle_info = ddz_nor_settle_info
            elseif self.game_type == "MJ" then
                --麻将统计
                local mj_xzdd_settle_info = {}
                local zi_mo_count = 0
                local jie_pao_count = 0
                local dian_pao_count = 0
                local an_gang_count = 0
                local ming_gang_count = 0
                local cha_da_jiao_count = 0
                for k, v_g in ipairs(gameover_info) do
                    if v_g.mj_xzdd_statistics then
                        if v_g.mj_xzdd_statistics.zi_mo_count[v.base.seat_num] then
                            zi_mo_count = zi_mo_count + v_g.mj_xzdd_statistics.zi_mo_count[v.base.seat_num]
                        end
                        if v_g.mj_xzdd_statistics.jie_pao_count[v.base.seat_num] then
                            jie_pao_count = jie_pao_count + v_g.mj_xzdd_statistics.jie_pao_count[v.base.seat_num]
                        end
                        if v_g.mj_xzdd_statistics.dian_pao_count[v.base.seat_num] then
                            dian_pao_count = dian_pao_count + v_g.mj_xzdd_statistics.dian_pao_count[v.base.seat_num]
                        end
                        if v_g.mj_xzdd_statistics.an_gang_count[v.base.seat_num] then
                            an_gang_count = an_gang_count + v_g.mj_xzdd_statistics.an_gang_count[v.base.seat_num]
                        end
                        if v_g.mj_xzdd_statistics.ming_gang_count[v.base.seat_num] then
                            ming_gang_count = ming_gang_count + v_g.mj_xzdd_statistics.ming_gang_count[v.base.seat_num]
                        end
                        if v_g.mj_xzdd_statistics.cha_da_jiao_count[v.base.seat_num] then
                            cha_da_jiao_count = cha_da_jiao_count + v_g.mj_xzdd_statistics.cha_da_jiao_count[v.base.seat_num]
                        end
                    end
                end
                mj_xzdd_settle_info.zi_mo_count = zi_mo_count
                mj_xzdd_settle_info.jie_pao_count = jie_pao_count
                mj_xzdd_settle_info.dian_pao_count = dian_pao_count
                mj_xzdd_settle_info.an_gang_count = an_gang_count
                mj_xzdd_settle_info.ming_gang_count = ming_gang_count
                mj_xzdd_settle_info.cha_da_jiao_count = cha_da_jiao_count
                v.mj_xzdd_settle_info = mj_xzdd_settle_info
            end
        end
        data.player_infos = player_info

        local max_score = nil

        for k, v_palyer in ipairs(data.player_infos) do
            if not max_score then
                max_score = v_palyer.grades
            end
            if v_palyer.grades > max_score then
                max_score = v_palyer.grades
            end
        end

        for k, v_palyer in ipairs(data.player_infos) do
            local playerGO = self.transform:Find("Genter/Players/Player" .. k).gameObject
            local playerGOTable = {}
            LuaHelper.GeneratingVar(playerGO.transform, playerGOTable)
            URLImageManager.UpdateHeadImage(v_palyer.base.head_link, playerGOTable.head_img)
            playerGOTable.name_txt.text = v_palyer.base.name
            playerGOTable.id_txt.text = v_palyer.base.id
            local is_me = v_palyer.base.id == MainModel.UserInfo.user_id
            playerGOTable.me_img.gameObject:SetActive(is_me)
            playerGOTable.other_img.gameObject:SetActive(not is_me)

            local is_win = v_palyer.grades == max_score and v_palyer.grades > 0
            playerGOTable.win_score_txt.text = v_palyer.grades
            playerGOTable.score_txt.text = v_palyer.grades
            playerGOTable.win_score_txt.gameObject:SetActive(is_win)
            playerGOTable.win_img.gameObject:SetActive(is_win)
            playerGOTable.score_txt.gameObject:SetActive(not is_win)

            -- 房主
			if v_palyer.base.id == self.room_owner then
				playerGOTable.fang_img.gameObject:SetActive(true)		
			else
				playerGOTable.fang_img.gameObject:SetActive(false)
			end

            local DescNode = playerGO.transform:Find("DescNode")
			local DescCell = playerGO.transform:Find("DescNode/DescCell")
            self:CreateDesc(DescNode, DescCell, v_palyer,playerGOTable)

            playerGO.gameObject:SetActive(true)
        end
    else
        HintPanel.Create(1, "总结算数据异常")
    end

    self:OnOff()
end
function RoomCardGameOver:CreateDesc(node, cell, data,playerGOTable)
	if data.ddz_nor_settle_info then
		for k,v in pairs(data.ddz_nor_settle_info) do
			if k == "bomb_count" then
				playerGOTable.zd_num_txt.text = v
			elseif k == "dizhu_count" then
				playerGOTable.dz_num_txt.text = v
			elseif k == "chuntian_count" then
				playerGOTable.ct_num_txt.text = v
			end
		end
		playerGOTable.DDZDescNode.gameObject:SetActive(true)
	elseif data.mj_xzdd_settle_info then
		for k,v in pairs(data.mj_xzdd_settle_info) do
			if k == "zi_mo_count" then
				playerGOTable.zm_num_txt.text = v
			elseif k == "jie_pao_count" then
				playerGOTable.jp_num_txt.text = v
			elseif k == "dian_pao_count" then
				playerGOTable.dp_num_txt.text = v
			elseif k == "an_gang_count" then
				playerGOTable.ag_num_txt.text = v
			elseif k == "ming_gang_count" then
				playerGOTable.mg_num_txt.text = v
			elseif k == "cha_da_jiao_count" then
				playerGOTable.cdj_num_txt.text = v
			end
		end
		playerGOTable.MJDescNode.gameObject:SetActive(true)
	end
end

function RoomCardGameOver:OnOff()
    if GameGlobalOnOff.ShowOff then
        self.share_btn.gameObject:SetActive(true)
    else
        self.share_btn.gameObject:SetActive(false)
    end
end

function RoomCardGameOver:MyExit()
    self:RemoveListener()
    self.confirmCallback = nil
    self.gameover_info = nil
    self.playerInfo = nil
    self.game_type = nil
    self.room_owner = nil
    GameObject.Destroy(self.transform.gameObject)
end

-- 分享战绩
function RoomCardGameOver:OnShareClick()
    self.share_cfg.isCircleOfFriends = false
    GameManager.GotoUI({gotoui = "sys_fx",goto_scene_parm = "image",share_cfg = self.share_cfg})
end

-- 返回
function RoomCardGameOver:OnBackClick()
    RoomCardGameOver.Close()
    MainLogic.ExitGame()
    MainLogic.GotoScene("game_Hall")
end
function RoomCardGameOver:ShowBack(b)
    self.icon_img.gameObject:SetActive(not b)
    self.qr_code_img.gameObject:SetActive(not b)

    self.share_btn.gameObject:SetActive(b)
    self.BackButton_btn.gameObject:SetActive(b)
end

function RoomCardGameOver:screen_shot_begin()
    self:ShowBack(false)
    AddCanvasAndSetSort(self.gameObject, 100)
end

function RoomCardGameOver:screen_shot_end()
    self:ShowBack(true)
    RemoveCanvas(self.gameObject)
end